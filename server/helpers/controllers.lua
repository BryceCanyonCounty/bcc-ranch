-- Creation and checking if in ranch area --
RanchersOnline = {} --this will be used to store the ranchers who are online of each ranch so we can sync changes firing etc to all online players of the ranch (It will store the playersSource and remove it if they leave (done by checking if they are online using getplayerped(plrysrc) native))

--These two functions are used to sync coord changes etc across all clients in the ranch
---@param ranchId integer
local function checkOnlineRanchers(ranchId) --will ensure the RanchersOnline table is up to date
    if RanchersOnline[ranchId] then
        for k, v in pairs(RanchersOnline[ranchId]) do
            if not GetPlayerPed(v.rancherSource) then
                if v.doesRancherHaveAnimalsOut then
                    MySQL.query.await("UPDATE ranch SET is_any_animals_out='false' WHERE ranchid=@ranchid", { ['ranchid'] = ranchId })
                end
                table.remove(RanchersOnline[ranchId], k)
            end
        end
    end
end

---@param sourceToInput integer
---@param ranchId integer
local function newRancherOnline(sourceToInput, ranchId)
    if not RanchersOnline[ranchId] then
        RanchersOnline[ranchId] = {}
    end
    if #RanchersOnline[ranchId] > 0 then
        for k, v in pairs(RanchersOnline[ranchId]) do
            if sourceToInput ~= v.rancherSource then
                table.insert(RanchersOnline[ranchId], {rancherSource = sourceToInput, isRancherAging = false, doesRancherHaveAnimalsOut = false})
            end
        end
    else
        table.insert(RanchersOnline[ranchId], {rancherSource = sourceToInput, isRancherAging = false})
    end
end

---@param ranchId integer
function UpdateAllRanchersRanchData(ranchId)
    checkOnlineRanchers(ranchId)
    local ranchData = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", { ['ranchid'] = ranchId })
    for k, v in pairs(RanchersOnline[ranchId]) do
        TriggerClientEvent('bcc-ranch:UpdateRanchData', v.rancherSource, ranchData[1])
    end
end

--This thread is used to ensure that every ranch has someone doing aging (we do this as otherwise it would make aging vulnerable to thread abuse aka multiple employees aging an animal at the same time)
CreateThread(function()
    while true do
        if #RanchersOnline > 0 then
            local firstIteration = true --needed as if theres no previous ranchId then the if would never trigger
            local currentRanchCheck = {
                ranchId = nil,
                isRancherAging = false
            }
            for k, v in pairs(RanchersOnline) do
                if currentRanchCheck.ranchId ~= nil and firstIteration or currentRanchCheck.ranchId ~= k and currentRanchCheck.isRancherAging == false then --this checks the last ranch that was looped over before the current ranchId loop, and makes sure that if no one is aging then we can trigger it on an online client this ensures only one client is aging at a time to prevent threading abuse
                    checkOnlineRanchers(currentRanchCheck.ranchId)
                    if not firstIteration then
                        TriggerClientEvent('bcc-ranch:AgingTriggered', RanchersOnline[k][1].rancherSource)
                    else
                        TriggerClientEvent('bcc-ranch:AgingTriggered', RanchersOnline[k][1].rancherSource, true)
                    end
                end
                currentRanchCheck.ranchId = k
                if v[1].isRancherAging then
                    currentRanchCheck.isRancherAging = true
                end
            end
            firstIteration = false
            currentRanchCheck.isRancherAging = false
            currentRanchCheck.ranchId = nil
        end
        Wait(30000)
    end
end)

---@param charId integer is characters static id will be a stringed int
---@param ranchName string
---@param ranchRadius integer will be a stringed int
---@param taxes integer will be a stringed int
---@param ranchCoords vector3
---@param ownerSource integer is owners server id
RegisterServerEvent("bcc-ranch:RanchCreationInsert", function(charId, ranchName, ranchRadius, taxes, ranchCoords, ownerSource)
    local _source = source
    local param = { ['charidentifier'] = charId, ["ranch_radius_limit"] = ranchRadius, ["ranchname"] = ranchName, ["taxamount"] = taxes, ["ranchcoords"] = json.encode(ranchCoords) }
    local result = MySQL.query.await('SELECT * FROM characters WHERE charidentifier=@charidentifier AND ranchid != 0', param)
    if #result > 1 then
        VORPcore.NotifyRightTip(_source, _U("alreadyOwnsRanch"), 4000)
    else
        local ranchId = MySQL.insert.await("INSERT INTO ranch (`charidentifier`,`ranchcoords`,`ranchname`,`ranch_radius_limit` ,`taxamount`) VALUES (@charidentifier,@ranchcoords,@ranchname,@ranch_radius_limit,@taxamount)", param)
        local charUpdateParams = { ["ranchid"] = ranchId, ["charidentifier"] = charId }
        MySQL.query.await("UPDATE characters SET ranchid=@ranchid WHERE charidentifier=@charidentifier", charUpdateParams)

        local selectRanchParams = { ["ranchid"] = ranchId }
        local ranchCreatedData = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", selectRanchParams)
        TriggerClientEvent("bcc-ranch:PlayerOwnsARanch", ownerSource, ranchCreatedData[1], true)
        newRancherOnline(ownerSource, ranchId)
        VORPcore.NotifyRightTip(_source, _U("ranchCreated"), 4000)
        local character = VORPcore.getUser(_source).getUsedCharacter
        BccUtils.Discord.sendMessage(Config.webhookLink, 'BCC Ranch', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', "Ranch Created By character Id: " .. tostring(character.charIdentifier), " Ranch given to character id: " .. tostring(charId))
    end
end)

RegisterServerEvent('bcc-ranch:CheckIfPlayerOwnsARanch', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = character.charIdentifier }
    local result = MySQL.query.await("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param)
    if #result > 0 then
        VORPInv.removeInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv')
        Wait(50)
        VORPInv.registerInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv', _U("inventoryName"), Config.ranchSetup.ranchInvLimit, true, true, true)
        TriggerClientEvent("bcc-ranch:PlayerOwnsARanch", _source, result[1], true)
        newRancherOnline(_source, result[1].ranchid)
    end
end)

---@param recSource integer Used only when initially hiring the employee to update thier client without requiring a relog
RegisterServerEvent('bcc-ranch:CheckIfPlayerIsEmployee')
AddEventHandler('bcc-ranch:CheckIfPlayerIsEmployee', function(recSource)
    local _source = nil
    if not recSource then
        _source = source
    else
        _source = recSource
    end
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = character.charIdentifier }

    local result = MySQL.query.await("SELECT ranchid FROM characters WHERE charidentifier=@charidentifier", param)
    if #result > 0 then
        if result[1].ranchid ~= nil and 0 then
            local employedAtParam = { ['ranchid'] = result[1].ranchid }
            local ranchEmployedAt = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", employedAtParam)
            if #ranchEmployedAt > 0 then
                VORPInv.removeInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv')
                Wait(50)
                VORPInv.registerInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv', _U("inventoryName"), Config.ranchSetup.ranchInvLimit, true, true, true)
                TriggerClientEvent('bcc-ranch:PlayerOwnsARanch', _source, ranchEmployedAt[1], false)
                newRancherOnline(_source, result[1].ranchid)
            end
        end
    end
end)

-- Ledger Area --
---@param ranchId integer
---@param type string
---@param amount integer
RegisterServerEvent('bcc-ranch:AffectLedger', function(ranchId, type, amount)
    local _source = source
    local getRanchParam = { ['ranchid'] = ranchId, ['amount'] = tonumber(amount) }
    local character = VORPcore.getUser(_source).getUsedCharacter
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", getRanchParam)
    if #ranch > 0 then
        if type == "withdraw" then
            if tonumber(amount) <= tonumber(ranch[1].ledger) then
                MySQL.query.await("UPDATE ranch SET ledger= ledger-@amount WHERE ranchid=@ranchid", getRanchParam)
                character.addCurrency(0, tonumber(amount))
                VORPcore.NotifyRightTip(_source, _U("withdrewFromLedger") .. " " .. amount, 4000)
                UpdateAllRanchersRanchData(ranchId)
            else
                VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
            end
        else
            if tonumber(character.money) >= tonumber(amount) then
                MySQL.query.await("UPDATE ranch SET ledger= ledger+@amount WHERE ranchid=@ranchid", getRanchParam)
                character.removeCurrency(0, tonumber(amount))
                VORPcore.NotifyRightTip(_source, _U("depositedToLedger") .. " " .. amount, 4000)
                UpdateAllRanchersRanchData(ranchId)
            else
                VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
            end
        end
    end
end)

-- Ranch Condition Area/Caretaking --

RegisterServerEvent("bcc-ranch:InsertChoreCoordsIntoDB", function(choreCoords, ranchId, choreType)
    local _source = source
    local databaseUpdate = {
        ['shovehaycoords'] = function()
            local param = { ['shovel_hay_coords'] = json.encode(choreCoords), ['ranchid'] = ranchId }
            MySQL.query.await("UPDATE ranch SET shovel_hay_coords = @shovel_hay_coords WHERE ranchid=@ranchid", param)
        end,
        ['wateranimalcoords'] = function()
            local param = { ['water_animal_coords'] = json.encode(choreCoords), ['ranchid'] = ranchId }
            MySQL.query.await("UPDATE ranch SET water_animal_coords = @water_animal_coords WHERE ranchid=@ranchid", param)
        end,
        ['repairtroughcoords'] = function()
            local param = { ['repair_trough_coords'] = json.encode(choreCoords), ['ranchid'] = ranchId }
            MySQL.query.await("UPDATE ranch SET repair_trough_coords = @repair_trough_coords WHERE ranchid=@ranchid", param)
        end,
        ['scooppoopcoords'] = function()
            local param = { ['scoop_poop_coords'] = json.encode(choreCoords), ['ranchid'] = ranchId }
            MySQL.query.await("UPDATE ranch SET scoop_poop_coords = @scoop_poop_coords WHERE ranchid=@ranchid", param)
        end
    }

    if databaseUpdate[choreType] then
        VORPcore.NotifyRightTip(_source, _U("coordsSet"), 4000)
        databaseUpdate[choreType]()
        UpdateAllRanchersRanchData(ranchId)
    end
end)

---@param ranchId integer
---@param amount integer
RegisterServerEvent("bcc-ranch:IncreaseRanchCond", function(ranchId, amount)
    local param = { ['ranchid'] = ranchId, ['amount'] = amount }
    MySQL.query.await("UPDATE ranch SET `ranchCondition`=ranchCondition+@amount WHERE ranchid=@ranchid", param)
    UpdateAllRanchersRanchData(ranchId)
end)

-- Employee area --
---@param ranchId integer
---@param employeeSource integer
---@param employeeCharId integer
RegisterServerEvent("bcc-ranch:EmployeeHired", function(ranchId, employeeSource, employeeCharId)
    local param = { ['ranchid'] = ranchId, ['charidentifier'] = employeeCharId }
    MySQL.query.await('UPDATE characters SET ranchid=@ranchid WHERE charidentifier=@charidentifier', param)
    TriggerEvent('bcc-ranch:CheckIfPlayerIsEmployee', tonumber(employeeSource))
end)

---@param ranchId integer
RegisterServerEvent("bcc-ranch:GetEmployeeList", function(ranchId, type)
    local _source = source
    local result = MySQL.query.await( "SELECT firstname, lastname, charidentifier FROM characters WHERE ranchid = @ranchid", { ["ranchid"] = ranchId })
    if type == "fire" then
        if #result > 0 then
            TriggerClientEvent('bcc-ranch:FireEmployeesMenu', _source, result)
        else
            VORPcore.NotifyRightTip(_source, _U("noEmployees"), 4000)
        end
    elseif type == "hire" then
        TriggerClientEvent('bcc-ranch:HireEmployeeMenu', _source, result)
    end
end)

---@param charId integer
RegisterServerEvent('bcc-ranch:FireEmployee', function(charId)
    local param = { ['charidentifier'] = charId }
    MySQL.query.await('UPDATE characters SET ranchid=0 WHERE charidentifier=@charidentifier', param)
end)

-- Animal Area --
---@param ranchId integer
---@param animalType string
RegisterServerEvent('bcc-ranch:AnimalBought', function(ranchId, animalType)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchId }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        local function animalBoughtLogic(cost)
            character.removeCurrency(0, cost)
            VORPcore.NotifyRightTip(_source, _U("animalBought"), 4000)
        end

        local buyAnimalOptions = {
            ['cows'] = function()
                if character.money >= Config.animalSetup.cows.cost then
                    if ranch[1].cows == "false" then
                        animalBoughtLogic(Config.animalSetup.cows.cost)
                        MySQL.query.await("UPDATE ranch SET cows='true' WHERE ranchid=@ranchid", param)
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(_source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['pigs'] = function()
                if character.money >= Config.animalSetup.pigs.cost then
                    if ranch[1].pigs == "false" then
                        animalBoughtLogic(Config.animalSetup.pigs.cost)
                        MySQL.query.await("UPDATE ranch SET pigs='true' WHERE ranchid=@ranchid", param)
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(_source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['sheeps'] = function()
                if character.money >= Config.animalSetup.sheeps.cost then
                    if ranch[1].sheeps == "false" then
                        animalBoughtLogic(Config.animalSetup.sheeps.cost)
                        MySQL.query.await("UPDATE ranch SET sheeps='true' WHERE ranchid=@ranchid", param)
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(_source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['goats'] = function()
                if character.money >= Config.animalSetup.goats.cost then
                    if ranch[1].goats == "false" then
                        animalBoughtLogic(Config.animalSetup.goats.cost)
                        MySQL.query.await("UPDATE ranch SET goats='true' WHERE ranchid=@ranchid", param)
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(_source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['chickens'] = function()
                if character.money >= Config.animalSetup.chickens.cost then
                    if ranch[1].chickens == "false" then
                        animalBoughtLogic(Config.animalSetup.chickens.cost)
                        MySQL.query.await("UPDATE ranch SET chickens='true' WHERE ranchid=@ranchid", param)
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(_source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
                end
            end
        }

        if buyAnimalOptions[animalType] then
            buyAnimalOptions[animalType]()
        end
    end
end)

---@param ranchId integer
---@param coords vector3
---@param type string
---@param moneyToRemove integer
RegisterServerEvent('bcc-ranch:InsertAnimalRelatedCoords', function(ranchId, coords, type, moneyToRemove)
    local _source = source
    local param = { ['ranchid'] = ranchId, ['coords'] = json.encode(coords) }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        local updateTable = {
            ['herdCoords'] = function()
                MySQL.query.await("UPDATE ranch SET herd_coords=@coords WHERE ranchid=@ranchid", param)
            end,
            ['feedWagonCoords'] = function()
                MySQL.query.await("UPDATE ranch SET feed_wagon_coords=@coords WHERE ranchid=@ranchid", param)
            end,
            ['cowCoords'] = function()
                MySQL.query.await("UPDATE ranch SET cow_coords=@coords WHERE ranchid=@ranchid", param)
            end,
            ['pigCoords'] = function()
                MySQL.query.await("UPDATE ranch SET pig_coords=@coords WHERE ranchid=@ranchid", param)
            end,
            ['sheepCoords'] = function()
                MySQL.query.await("UPDATE ranch SET sheep_coords=@coords WHERE ranchid=@ranchid", param)
            end,
            ['goatCoords'] = function()
                MySQL.query.await("UPDATE ranch SET goat_coords=@coords WHERE ranchid=@ranchid", param)
            end,
            ['chickenCoords'] = function()
                MySQL.query.await("UPDATE ranch SET chicken_coords=@coords WHERE ranchid=@ranchid", param)
            end,
            ['coopCoords'] = function()
                MySQL.query.await("UPDATE ranch SET chicken_coop='true' WHERE ranchid=@ranchid", param)
                MySQL.query.await("UPDATE ranch SET chicken_coop_coords=@coords WHERE ranchid=@ranchid", param)
            end
        }

        if updateTable[type] then
            if moneyToRemove then
                local character = VORPcore.getUser(_source).getUsedCharacter
                if character.money >= moneyToRemove then
                    character.removeCurrency(0, moneyToRemove)
                    VORPcore.NotifyRightTip(_source, _U("coordsSet"), 4000)
                    updateTable[type]()
                    UpdateAllRanchersRanchData(ranchId)
                else
                    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
                    return
                end
            else
                updateTable[type]()
                UpdateAllRanchersRanchData(ranchId)
            end
        end
    end
end)

---@param isOut boolean
RegisterServerEvent('bcc-ranch:UpdateAnimalsOut', function(ranchId, isOut)
    local _source = source
    local param = { ['ranchid'] = ranchId }
    if RanchersOnline[ranchId] then
        if isOut then
            for k, v in pairs(RanchersOnline[ranchId]) do
                if _source == v.rancherSource then
                    MySQL.query.await("UPDATE ranch SET is_any_animals_out='true' WHERE ranchid=@ranchid", param)
                    v.doesRancherHaveAnimalsOut = true
                    UpdateAllRanchersRanchData(ranchId) break
                end
            end
        else
            for k, v in pairs(RanchersOnline[ranchId]) do
                if _source == v.rancherSource then
                    MySQL.query.await("UPDATE ranch SET is_any_animals_out='false' WHERE ranchid=@ranchid", param)
                    v.doesRancherHaveAnimalsOut = false
                    UpdateAllRanchersRanchData(ranchId) break
                end
            end
        end
    end
end)

---@param ranchId integer
---@param animalType string
---@param incAmount integer
RegisterServerEvent('bcc-ranch:IncreaseAnimalsCond', function(ranchId, animalType, incAmount)
    local _source = source
    local param = { ['ranchid'] = ranchId, ['amount'] = incAmount }
    local animalOptionsTable = {
        ['cows'] = function()
            MySQL.query.await("UPDATE ranch SET cows_cond=cows_cond+@amount WHERE ranchid=@ranchid", param)
        end,
        ['pigs'] = function()
            MySQL.query.await("UPDATE ranch SET pigs_cond=pigs_cond+@amount WHERE ranchid=@ranchid", param)
        end,
        ['sheeps'] = function()
            MySQL.query.await("UPDATE ranch SET sheeps_cond= sheeps_cond+@amount WHERE ranchid=@ranchid", param)
        end,
        ['goats'] = function()
            MySQL.query.await("UPDATE ranch SET goats_cond= goats_cond+@amount WHERE ranchid=@ranchid", param)
        end,
        ['chickens'] = function()
            MySQL.query.await("UPDATE ranch SET chickens_cond= chickens_cond+@amount WHERE ranchid=@ranchid", param)
        end
    }

    if animalOptionsTable[animalType] then
        animalOptionsTable[animalType]()
        UpdateAllRanchersRanchData(ranchId)
        VORPcore.NotifyRightTip(_source, _U("animalCondIncreased") .. tostring(incAmount), 4000)
    end
end)

---@param ranchId integer
---@param animalType string
---@param incAmount integer
RegisterServerEvent("bcc-ranch:IncreaseAnimalAge", function(ranchId, animalType, incAmount)
    local param = { ['ranchid'] = ranchId, ['amount'] = incAmount }
    local animalOptionsTable = {
        ['cows'] = function()
            MySQL.query.await("UPDATE ranch SET cows_age=cows_age+@amount WHERE ranchid=@ranchid", param)
        end,
        ['pigs'] = function()
            MySQL.query.await("UPDATE ranch SET pigs_age=pigs_age+@amount WHERE ranchid=@ranchid", param)
        end,
        ['sheeps'] = function()
            MySQL.query.await("UPDATE ranch SET sheeps_age= sheeps_age+@amount WHERE ranchid=@ranchid", param)
        end,
        ['goats'] = function()
            MySQL.query.await("UPDATE ranch SET goats_age= goats_age+@amount WHERE ranchid=@ranchid", param)
        end,
        ['chickens'] = function()
            MySQL.query.await("UPDATE ranch SET chickens_age= chickens_age+@amount WHERE ranchid=@ranchid", param)
        end
    }

    if animalOptionsTable[animalType] then
        animalOptionsTable[animalType]()
        UpdateAllRanchersRanchData(ranchId)
    end
end)

---@param ranchId integer
---@param animalType string
---@param incAmount integer
RegisterServerEvent('bcc-ranch:ButcherAnimalHandler', function(animalType, ranchId, table)
    local param = { ['ranchid'] = ranchId }
    local _source = source

    local butcherFuncts = {
        ['cows'] = function()
            MySQL.query.await('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['chickens'] = function()
            MySQL.query.await('UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['pigs'] = function()
            MySQL.query.await('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['sheeps'] = function()
            MySQL.query.await('UPDATE ranch SET `sheeps`="false", `sheeps_cond`=0, `sheeps_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['goats'] = function()
            MySQL.query.await('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', param)
        end
    }
    if butcherFuncts[animalType] then
        butcherFuncts[animalType]()
        UpdateAllRanchersRanchData(ranchId)
    end

    for k, v in pairs(table.butcherItems) do
        VORPInv.addItem(_source, v.name, v.count)
    end
end)

---@param ranchId integer
---@param animalType string
---@param incAmount integer
RegisterServerEvent('bcc-ranch:AnimalSold', function(payAmount, ranchId, animalType)
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", { ['ranchid'] = ranchId })
    if #ranch > 0 then
        MySQL.query.await("UPDATE ranch SET ledger= ledger+@payAmount WHERE ranchid=@ranchid", { ['ranchid'] = ranchId, ['payAmount'] = payAmount })
        local soldFuncts = {
            ['cows'] = function()
                MySQL.query.await('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', { ['ranchid'] = ranchId })
            end,
            ['chickens'] = function()
                MySQL.query.await('UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', { ['ranchid'] = ranchId })
            end,
            ['pigs'] = function()
                MySQL.query.await('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', { ['ranchid'] = ranchId })
            end,
            ['sheeps'] = function()
                MySQL.query.await('UPDATE ranch SET `sheeps`="false", `sheeps_cond`=0, `sheeps_age`=0 WHERE ranchid=@ranchid', { ['ranchid'] = ranchId })
            end,
            ['goats'] = function()
                MySQL.query.await('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', { ['ranchid'] = ranchId })
            end
        }
        if soldFuncts[animalType] then
            soldFuncts[animalType]()
            UpdateAllRanchersRanchData(ranchId)
        end
    end
end)

---@param item string
---@param amount integer
RegisterServerEvent('bcc-ranch:AddItem', function(item, amount)
    local _source = source
    VORPInv.addItem(_source, item, amount)
end)

RegisterServerEvent('bcc-ranch:GetAllRanches', function()
    local _source = source
    local result = MySQL.query.await("SELECT * FROM ranch")
    if #result > 0 then
        TriggerClientEvent('bcc-ranch:ShowAllRanchesMenu', _source, result)
    end
end)

-- cleanup --
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        MySQL.query.await("UPDATE ranch SET isherding = 0")
    end
end)