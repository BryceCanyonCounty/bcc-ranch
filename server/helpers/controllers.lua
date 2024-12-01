-- Creation and checking if in ranch area --
RanchersOnline = {} -- This will be used to store the ranchers who are online of each ranch so we can sync changes firing etc to all online players of the ranch (It will store the playersSource and remove it if they leave (done by checking if they are online using getplayerped(plrysrc) native))

local function checkOnlineRanchers(ranchId)
    devPrint("Checking online ranchers for ranchId: " .. ranchId)
    if RanchersOnline[ranchId] then
        devPrint("Current RanchersOnline: " .. json.encode(RanchersOnline[ranchId]))
        for k, v in pairs(RanchersOnline[ranchId]) do
            devPrint("Checking rancher source: " .. tostring(v.rancherSource))
            if not GetPlayerPed(v.rancherSource) then
                devPrint("Rancher with source " .. v.rancherSource .. " is offline. Removing from RanchersOnline.")
                if v.doesRancherHaveAnimalsOut then
                    MySQL.update.await("UPDATE ranch SET is_any_animals_out = 'false' WHERE ranchid = ?", { ranchId })
                end
                table.remove(RanchersOnline[ranchId], k)
            end
        end
    else
        devPrint("No RanchersOnline entry for ranchId: " .. ranchId)
    end
end

local function newRancherOnline(sourceToInput, ranchId)
    devPrint("Adding new rancher with source: " .. sourceToInput .. " to ranchId: " .. ranchId)
    if not RanchersOnline[ranchId] then
        RanchersOnline[ranchId] = {}
    end
    devPrint("Current RanchersOnline before adding: " .. json.encode(RanchersOnline[ranchId]))
    if #RanchersOnline[ranchId] > 0 then
        local alreadyExists = false
        for k, v in pairs(RanchersOnline[ranchId]) do
            if sourceToInput == v.rancherSource then
                alreadyExists = true
                devPrint("Rancher source already exists: " .. tostring(sourceToInput))
                break
            end
        end
        if not alreadyExists then
            table.insert(RanchersOnline[ranchId], { rancherSource = sourceToInput, isRancherAging = false, doesRancherHaveAnimalsOut = false })
            devPrint("Added rancher source: " .. tostring(sourceToInput))
        end
    else
        table.insert(RanchersOnline[ranchId], { rancherSource = sourceToInput, isRancherAging = false })
        devPrint("First rancher added for ranchId: " .. ranchId)
    end
    devPrint("Updated RanchersOnline: " .. json.encode(RanchersOnline[ranchId]))
end

function UpdateAllRanchersRanchData(ranchId)
    devPrint("Updating ranch data for ranchId: " .. ranchId)

    -- Ensure RanchersOnline is up-to-date
    checkOnlineRanchers(ranchId)

    -- Fetch ranch data
    local ranchData = MySQL.query.await("SELECT * FROM ranch WHERE ranchid = ?", { ranchId })
    if not ranchData or #ranchData == 0 or not ranchData[1].ranchcoords then
        devPrint("Invalid ranch data for ranchId: " .. ranchId)
        return
    end

    -- Ensure there are online ranchers for this ranchId
    if not RanchersOnline[ranchId] or #RanchersOnline[ranchId] == 0 then
        devPrint("No ranchers online for ranchId: " .. ranchId)
        return
    end

    -- Send data to all online ranchers
    for _, rancher in pairs(RanchersOnline[ranchId]) do
        devPrint("Sending ranch data to rancherSource: " .. tostring(rancher.rancherSource))

        TriggerClientEvent('bcc-ranch:UpdateRanchData', rancher.rancherSource, ranchData[1])
    end
end

BccUtils.RPC:Register("bcc-ranch:GetAnimalCondition", function(params, cb)
    local ranchId = params.ranchId
    local animalType = params.animalType
    local conditionQuery = ""
    local maxCondition = 0  -- Default max condition value

    -- Define the query based on the animal type and get the max condition from Config
    if animalType == 'cows' then
        conditionQuery = "SELECT cows_cond FROM ranch WHERE ranchid = ?"
        maxCondition = Config.animalSetup.cows.maxCondition  -- Get max condition from config
    elseif animalType == 'chickens' then
        conditionQuery = "SELECT chickens_cond FROM ranch WHERE ranchid = ?"
        maxCondition = Config.animalSetup.chickens.maxCondition
    elseif animalType == 'pigs' then
        conditionQuery = "SELECT pigs_cond FROM ranch WHERE ranchid = ?"
        maxCondition = Config.animalSetup.pigs.maxCondition
    elseif animalType == 'sheeps' then
        conditionQuery = "SELECT sheeps_cond FROM ranch WHERE ranchid = ?"
        maxCondition = Config.animalSetup.sheeps.maxCondition
    elseif animalType == 'goats' then
        conditionQuery = "SELECT goats_cond FROM ranch WHERE ranchid = ?"
        maxCondition = Config.animalSetup.goats.maxCondition
    else
        devPrint("Error: Invalid animal type provided: " .. tostring(animalType))
        cb(nil)  -- Return nil to indicate an error
        return
    end

    -- Query the database for the animal's current condition
    MySQL.scalar(conditionQuery, { ranchId }, function(condition)
        if condition then
            -- Check if the animal's condition is at its max
            if condition >= maxCondition then
                devPrint(animalType .. " condition is at max (" .. maxCondition .. ")")
            end
            -- Return the condition to the client
            cb(condition)
        else
            devPrint("Error: Failed to fetch animal condition for " .. animalType)
            cb(nil)  -- Return nil to indicate an error
        end
    end)
end)

BccUtils.RPC:Register("bcc-ranch:CreateRanch", function(params, cb, source)
    devPrint("Received Ranch Params: " .. json.encode(params))
    local ranchName = params.ranchName
    local ranchRadius = params.ranchRadius
    local ranchTaxAmount = params.ranchTaxAmount
    local ownerCharId = params.ownerCharId
    local ownerSource = params.ownerSource
    local coords = params.coords

    -- Retrieve character data for creator and owner
    local creatorChar = VORPcore.getUser(source).getUsedCharacter
    local ownerChar = VORPcore.getUser(ownerSource).getUsedCharacter

    if not creatorChar or not ownerChar then
        VORPcore.NotifyRightTip(source, _U("invalidPlayer"), 4000)
        cb(false)
        return
    end

    -- Validate inputs
    if not ranchName or ranchName == "" or not ranchRadius or ranchRadius == "" or not ranchTaxAmount or ranchTaxAmount == "" then
        cb(false)
        return
    end

    -- Check if the owner already owns a ranch
    local ownerHasRanch = MySQL.query.await("SELECT * FROM ranch WHERE charidentifier = ?", { ownerCharId })
    if #ownerHasRanch > 0 then
        VORPcore.NotifyRightTip(source, _U("alreadyOwnsRanch"), 4000)
        cb(false) -- Indicate failure to the client
        return
    end
    -- Check for duplicate ranch names
    local ranchNameExists = MySQL.query.await("SELECT * FROM ranch WHERE ranchname = ?", { ranchName })
    if #ranchNameExists > 0 then
        VORPcore.NotifyRightTip(_source, _U("ranchNameAlreadyExists"), 4000)
        cb(false)
        return
    end

    -- Create the ranch
    local insertSuccess = MySQL.insert.await("INSERT INTO ranch (ranchname, charidentifier, taxamount, ranch_radius_limit, ranchcoords) VALUES (?, ?, ?, ?, ?)", {
        ranchName, ownerCharId, ranchTaxAmount, ranchRadius, json.encode(coords)
    })

    if insertSuccess then
        -- Retrieve newly created ranch data
        local insertedRanch = MySQL.query.await("SELECT * FROM ranch WHERE ranchname = ? AND charidentifier = ?", { ranchName, ownerCharId })
        if #insertedRanch > 0 then
            local ranch = insertedRanch[1]
            -- Update the owner's character with the ranch ID
            MySQL.query.await("UPDATE characters SET ranchid = ? WHERE charidentifier = ?", { ranch.ranchid, ownerCharId })

            -- Log the ranch creation
            BccUtils.Discord.sendMessage(Config.adminLogsWebhook, Config.WebhookTitle, Config.WebhookAvatar,
                _U("ranchCreatedLog"),
                _U("ranchCreatedBy") .. (creatorChar.firstname or "Unknown") .. " " .. (creatorChar.lastname or "Unknown") ..
                _U("ranchName") .. ranchName .. _U("ranchOwner") .. (ownerChar.firstname or "Unknown") .. " " .. (ownerChar.lastname or "Unknown")
            )
            BccUtils.RPC:Call("bcc-ranch:PlayerOwnsARanch", { ranchData = ranch, isOwnerOfRanch = true }, ownerSource)
            cb(true)
        else
            VORPcore.NotifyRightTip(_source, _U("databaseError"), 4000)
            cb(false)
        end
    else
        VORPcore.NotifyRightTip(_source, _U("databaseError"), 4000)
        cb(false)
    end
end)

RegisterServerEvent('bcc-ranch:CheckIfPlayerOwnsARanch', function()
    local _source = source
    devPrint("Checking if player owns a ranch for source: " .. _source)
    local character = VORPcore.getUser(_source).getUsedCharacter
    local result = MySQL.query.await("SELECT * FROM ranch WHERE charidentifier = ?", { character.charIdentifier })
    if #result > 0 then
        Wait(50)
        local data = {
            id = 'Player_' .. result[1].ranchid .. '_bcc-ranchinv',
            name = _U("inventoryName"),
            limit = Config.ranchSetup.ranchInvLimit,
            acceptWeapons = true,
            shared = true,
            ignoreItemStackLimit = true,
            whitelistItems = false,
            UsePermissions = false,
            UseBlackList = false,
            whitelistWeapons = false
        }
        
        -- Register the ranch inventory
        exports.vorp_inventory:registerInventory(data)

        BccUtils.RPC:Call("bcc-ranch:PlayerOwnsARanch", { ranchData = result[1], isOwnerOfRanch = true}, _source)
        if not RanchersOnline[result[1].ranchid] or not table.contains(RanchersOnline[result[1].ranchid], _source) then
            newRancherOnline(_source, result[1].ranchid)
        end
    end
end)

RegisterServerEvent('bcc-ranch:CheckIfPlayerIsEmployee')
AddEventHandler('bcc-ranch:CheckIfPlayerIsEmployee', function(recSource)
    local _source = nil
    if not recSource then
        _source = source
    else
        _source = recSource
    end
    devPrint("Checking if player is an employee for source: " .. _source)
    local character = VORPcore.getUser(_source).getUsedCharacter

    local result = MySQL.query.await("SELECT ranchid FROM characters WHERE charidentifier = ?", { character.charIdentifier })
    if #result > 0 then
        if result[1].ranchid ~= nil and 0 then
            local ranchEmployedAt = MySQL.query.await("SELECT * FROM ranch WHERE ranchid = ?", { result[1].ranchid })
            if #ranchEmployedAt > 0 then
                Wait(50)
                local data = {
                    id = 'Player_' .. result[1].ranchid .. '_bcc-ranchinv',
                    name = _U("inventoryName"),
                    limit = Config.ranchSetup.ranchInvLimit,
                    acceptWeapons = true,
                    shared = true,
                    ignoreItemStackLimit = true,
                    whitelistItems = false,
                    UsePermissions = false,
                    UseBlackList = false,
                    whitelistWeapons = false
                }
                
                -- Register the ranch inventory
                exports.vorp_inventory:registerInventory(data)
                BccUtils.RPC:Call("bcc-ranch:PlayerOwnsARanch", { ranchData = ranchEmployedAt[1], isOwnerOfRanch = false}, _source)
                if not RanchersOnline[result[1].ranchid] or not table.contains(RanchersOnline[result[1].ranchid], _source) then
                    newRancherOnline(_source, result[1].ranchid)
                end
            end
        end
    end
end)

-- Helper function to check if a table contains a value
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Ledger Area --
RegisterServerEvent('bcc-ranch:AffectLedger', function(ranchId, type, amount)
    local _source = source
    devPrint("Affecting ledger for ranchId: " .. ranchId .. " with type: " .. type .. " and amount: " .. amount)
    local character = VORPcore.getUser(_source).getUsedCharacter
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid = ?", { ranchId })
    if #ranch > 0 then
        if type == "withdraw" then
            if tonumber(amount) <= tonumber(ranch[1].ledger) then
                MySQL.update.await("UPDATE ranch SET ledger = ledger - ? WHERE ranchid = ?", { tonumber(amount), ranchId })
                character.addCurrency(0, tonumber(amount))
                VORPcore.NotifyRightTip(_source, _U("withdrewFromLedger") .. " " .. amount, 4000)
                UpdateAllRanchersRanchData(ranchId)
            else
                VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
            end
        else
            if tonumber(character.money) >= tonumber(amount) then
                MySQL.update.await("UPDATE ranch SET ledger = ledger + ? WHERE ranchid = ?", { tonumber(amount), ranchId })
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
    devPrint("Inserting chore coords for ranchId: " .. ranchId .. " with choreType: " .. choreType)
    local databaseUpdate = {
        ['shovehaycoords'] = function()
            MySQL.update.await("UPDATE ranch SET shovel_hay_coords = ? WHERE ranchid = ?", { json.encode(choreCoords), ranchId })
        end,
        ['wateranimalcoords'] = function()
            MySQL.update.await("UPDATE ranch SET water_animal_coords = ? WHERE ranchid = ?", { json.encode(choreCoords), ranchId })
        end,
        ['repairtroughcoords'] = function()
            MySQL.update.await("UPDATE ranch SET repair_trough_coords = ? WHERE ranchid = ?", { json.encode(choreCoords), ranchId })
        end,
        ['scooppoopcoords'] = function()
            MySQL.update.await("UPDATE ranch SET scoop_poop_coords = ? WHERE ranchid = ?", { json.encode(choreCoords), ranchId })
        end
    }

    if databaseUpdate[choreType] then
        VORPcore.NotifyRightTip(_source, _U("coordsSet"), 4000)
        databaseUpdate[choreType]()
        UpdateAllRanchersRanchData(ranchId)
    end
end)

RegisterServerEvent("bcc-ranch:IncreaseRanchCond", function(ranchId, amount)
    devPrint("Increasing ranch condition for ranchId: " .. ranchId .. " by amount: " .. amount)
    MySQL.update("UPDATE ranch SET ranchCondition = ranchCondition + ? WHERE ranchid = ?", { tonumber(amount), ranchId })
    UpdateAllRanchersRanchData(ranchId)
end)

-- Employee area --
RegisterServerEvent("bcc-ranch:EmployeeHired", function(ranchId, employeeSource, employeeCharId)
    devPrint("Employee hired for ranchId: " .. ranchId .. " with employeeSource: " .. employeeSource .. " and employeeCharId: " .. employeeCharId)
    MySQL.update('UPDATE characters SET ranchid = ? WHERE charidentifier = ?', { ranchId, employeeCharId })
    TriggerEvent('bcc-ranch:CheckIfPlayerIsEmployee', tonumber(employeeSource))
end)

RegisterServerEvent("bcc-ranch:GetEmployeeList", function(ranchId, type)
    local _source = source
    devPrint("Getting employee list for ranchId: " .. ranchId .. " with type: " .. type)
    local result = MySQL.query.await("SELECT firstname, lastname, charidentifier FROM characters WHERE ranchid = ?", { ranchId })
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

RegisterServerEvent('bcc-ranch:FireEmployee', function(charId)
    devPrint("Firing employee with charId: " .. charId)
    MySQL.update.await('UPDATE characters SET ranchid=0 WHERE charidentifier = ?', { charId })
end)

BccUtils.RPC:Register("bcc-ranch:AnimalBought", function(params, cb, source)
    local ranchId = params.ranchId
    local animalType = params.animalType
    devPrint("Animal bought for ranchId: " .. ranchId .. " with animalType: " .. animalType)

    local character = VORPcore.getUser(source).getUsedCharacter
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid = ?", { ranchId })
    
    if #ranch > 0 then
        local function animalBoughtLogic(cost)
            character.removeCurrency(0, cost)
            VORPcore.NotifyRightTip(source, _U("animalBought"), 4000)
        end

        local buyAnimalOptions = {
            ['cows'] = function()
                if character.money >= Config.animalSetup.cows.cost then
                    if ranch[1].cows == "false" then
                        animalBoughtLogic(Config.animalSetup.cows.cost)
                        MySQL.update.await("UPDATE ranch SET cows='true' WHERE ranchid = ?", { ranchId })
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['pigs'] = function()
                if character.money >= Config.animalSetup.pigs.cost then
                    if ranch[1].pigs == "false" then
                        animalBoughtLogic(Config.animalSetup.pigs.cost)
                        MySQL.update.await("UPDATE ranch SET pigs='true' WHERE ranchid = ?", { ranchId })
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['sheeps'] = function()
                if character.money >= Config.animalSetup.sheeps.cost then
                    if ranch[1].sheeps == "false" then
                        animalBoughtLogic(Config.animalSetup.sheeps.cost)
                        MySQL.update.await("UPDATE ranch SET sheeps='true' WHERE ranchid = ?", { ranchId })
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['goats'] = function()
                if character.money >= Config.animalSetup.goats.cost then
                    if ranch[1].goats == "false" then
                        animalBoughtLogic(Config.animalSetup.goats.cost)
                        MySQL.update.await("UPDATE ranch SET goats='true' WHERE ranchid = ?", { ranchId })
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(source, _U("notEnoughMoney"), 4000)
                end
            end,
            ['chickens'] = function()
                if character.money >= Config.animalSetup.chickens.cost then
                    if ranch[1].chickens == "false" then
                        animalBoughtLogic(Config.animalSetup.chickens.cost)
                        MySQL.update.await("UPDATE ranch SET chickens='true' WHERE ranchid = ?", { ranchId })
                        UpdateAllRanchersRanchData(ranchId)
                    else
                        VORPcore.NotifyRightTip(source, _U("alreadyOwnsAnimal"), 4000)
                    end
                else
                    VORPcore.NotifyRightTip(source, _U("notEnoughMoney"), 4000)
                end
            end
        }

        if buyAnimalOptions[animalType] then
            buyAnimalOptions[animalType]()
            cb(true) -- Return success callback
        else
            VORPcore.NotifyRightTip(source, _U("invalidAnimalType"), 4000)
            cb(false) -- Return failure callback if invalid animal type
        end
    else
        VORPcore.NotifyRightTip(source, _U("ranchNotFound"), 4000)
        cb(false) -- Return failure callback if ranch not found
    end
end)

BccUtils.RPC:Register("bcc-ranch:InsertAnimalRelatedCoords", function(params)
    local _source = source
    local ranchId = params.ranchId
    local coords = params.coords
    local type = params.type
    local moneyToRemove = params.cost

    devPrint("Inserting animal-related coords for ranchId: " .. ranchId .. ", Type: " .. type)

    -- Fetch ranch data
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid = ?", { ranchId })
    if not ranch or #ranch == 0 then
        devPrint("Error: No ranch found for ranchId: " .. ranchId)
        return { success = false, error = "No ranch found" }
    end
    devPrint("Ranch data successfully retrieved for ranchId: " .. ranchId)

    -- Define update actions based on type
    local updateTable = {
        ['herdCoords'] = function()
            devPrint("Updating herdCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET herd_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end,
        ['feedWagonCoords'] = function()
            devPrint("Updating feedWagonCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET feed_wagon_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end,
        ['cowCoords'] = function()
            devPrint("Updating cowCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET cow_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end,
        ['pigCoords'] = function()
            devPrint("Updating pigCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET pig_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end,
        ['sheepCoords'] = function()
            devPrint("Updating sheepCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET sheep_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end,
        ['goatCoords'] = function()
            devPrint("Updating goatCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET goat_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end,
        ['chickenCoords'] = function()
            devPrint("Updating chickenCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET chicken_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end,
        ['coopCoords'] = function()
            devPrint("Updating coopCoords for ranchId: " .. ranchId)
            MySQL.update("UPDATE ranch SET chicken_coop='true' WHERE ranchid = ?", { ranchId })
            MySQL.update("UPDATE ranch SET chicken_coop_coords = ? WHERE ranchid = ?", { json.encode(coords), ranchId })
        end
    }

    -- Execute the appropriate update action
    if updateTable[type] then
        devPrint("Valid type provided: " .. type)
        if moneyToRemove then
            devPrint("Cost to remove: " .. moneyToRemove)
            local character = VORPcore.getUser(_source).getUsedCharacter
            devPrint("Character money: " .. character.money)

            if character.money >= moneyToRemove then
                devPrint("Sufficient funds. Removing money and updating coordinates.")
                character.removeCurrency(0, moneyToRemove)
                updateTable[type]()
                UpdateAllRanchersRanchData(ranchId)
                devPrint("Coordinates successfully updated for type: " .. type)
                return { success = true }
            else
                devPrint("Error: Insufficient funds for _source: " .. _source)
                return { success = false, error = "Not enough money" }
            end
        else
            devPrint("No cost required. Proceeding to update coordinates.")
            updateTable[type]()
            UpdateAllRanchersRanchData(ranchId)
            devPrint("Coordinates successfully updated for type: " .. type)
            return { success = true }
        end
    else
        devPrint("Error: Invalid type provided: " .. type)
        return { success = false, error = "Invalid type" }
    end
end)

BccUtils.RPC:Register("bcc-ranch:UpdateAnimalsOut", function(params, cb, recSource)
    local ranchId = params.ranchId
    local isOut = params.isOut

    devPrint("Updating animals out for ranchId: " .. ranchId .. " with isOut: " .. tostring(isOut))
    devPrint("Received recSource: " .. tostring(recSource))

    if RanchersOnline[ranchId] then
        devPrint("Current RanchersOnline: " .. json.encode(RanchersOnline[ranchId]))
        for k, v in pairs(RanchersOnline[ranchId]) do
            devPrint("Comparing recSource: " .. tostring(recSource) .. " with rancherSource: " .. tostring(v.rancherSource))
            if recSource == v.rancherSource then
                if isOut then
                    devPrint("Setting is_any_animals_out to true for ranchId: " .. ranchId)
                    MySQL.update.await("UPDATE ranch SET is_any_animals_out='true' WHERE ranchid = ?", { ranchId })
                    v.doesRancherHaveAnimalsOut = true
                else
                    devPrint("Setting is_any_animals_out to false for ranchId: " .. ranchId)
                    MySQL.update.await("UPDATE ranch SET is_any_animals_out='false' WHERE ranchid = ?", { ranchId })
                    v.doesRancherHaveAnimalsOut = false
                end
                UpdateAllRanchersRanchData(ranchId)
                devPrint("Successfully updated animals out for rancher source: " .. tostring(v.rancherSource))
                cb(true)
                return
            end
        end
    else
        devPrint("No RanchersOnline entry for ranchId: " .. ranchId)
    end

    devPrint("Failed to update animals out for ranchId: " .. ranchId .. ". Rancher source not found.")
    cb(false)
end)

BccUtils.RPC:Register("bcc-ranch:IncreaseAnimalsCond", function(params, cb, recSource)
    local ranchId = params.ranchId
    local animalType = params.animalType
    local incAmount = params.incAmount

    -- Debugging logs
    devPrint("Increasing animal condition for ranchId: " .. ranchId .. " with animalType: " .. animalType .. " and incAmount: " .. incAmount)

    -- Animal condition update logic
    local animalOptionsTable = {
        ['cows'] = function()
            MySQL.update("UPDATE ranch SET cows_cond = cows_cond + ? WHERE ranchid = ?", { incAmount, ranchId })
        end,
        ['pigs'] = function()
            MySQL.update("UPDATE ranch SET pigs_cond = pigs_cond + ? WHERE ranchid = ?", { incAmount, ranchId })
        end,
        ['sheeps'] = function()
            MySQL.update("UPDATE ranch SET sheeps_cond = sheeps_cond + ? WHERE ranchid = ?", { incAmount, ranchId })
        end,
        ['goats'] = function()
            MySQL.update("UPDATE ranch SET goats_cond = goats_cond + ? WHERE ranchid = ?", { incAmount, ranchId })
        end,
        ['chickens'] = function()
            MySQL.update("UPDATE ranch SET chickens_cond = chickens_cond + ? WHERE ranchid = ?", { incAmount, ranchId })
        end
    }

    -- Check if the animal type is valid
    if animalOptionsTable[animalType] then
        -- Execute the condition increase logic
        animalOptionsTable[animalType]()
        UpdateAllRanchersRanchData(ranchId)

        -- Notify the rancher if applicable
        if recSource then
            VORPcore.NotifyRightTip(recSource, _U("animalCondIncreased") .. tostring(incAmount), 4000)
        end

        -- Return success via callback
        if cb then cb(true) end
    else
        devPrint("Invalid animal type provided: " .. tostring(animalType))
        if cb then cb(false) end -- Return failure via callback
    end
end)

BccUtils.RPC:Register("bcc-ranch:IncreaseAnimalAge", function(params, cb, source)
    local ranchId = params.ranchId
    local animalType = params.animalType
    local incAmount = params.incAmount

    devPrint("IncreaseAnimalAge RPC received from source: " .. tostring(source) .. " with ranchId: " .. tostring(ranchId) .. ", animalType: " .. tostring(animalType) .. ", incAmount: " .. tostring(incAmount))

    -- Define the animal types and their respective columns, max age, and max condition
    local animalTypes = {
        ['cows'] = {column = "cows_age", conditionColumn = "cows_cond", maxAge = Config.animalSetup.cows.maxAge, maxCondition = Config.animalSetup.cows.maxCondition},
        ['pigs'] = {column = "pigs_age", conditionColumn = "pigs_cond", maxAge = Config.animalSetup.pigs.maxAge, maxCondition = Config.animalSetup.pigs.maxCondition},
        ['sheeps'] = {column = "sheeps_age", conditionColumn = "sheeps_cond", maxAge = Config.animalSetup.sheeps.maxAge, maxCondition = Config.animalSetup.sheeps.maxCondition},
        ['goats'] = {column = "goats_age", conditionColumn = "goats_cond", maxAge = Config.animalSetup.goats.maxAge, maxCondition = Config.animalSetup.goats.maxCondition},
        ['chickens'] = {column = "chickens_age", conditionColumn = "chickens_cond", maxAge = Config.animalSetup.chickens.maxAge, maxCondition = Config.animalSetup.chickens.maxCondition}
    }

    -- Check if animalType exists in the animalTypes table
    local animal = animalTypes[animalType]
    if not animal then
        devPrint("Error: Invalid animal type provided: " .. tostring(animalType))
        cb(false) -- Return failure callback for invalid animal type
        return
    end

    -- Query the current age and condition for the specific animal
    MySQL.query("SELECT " .. animal.column .. ", " .. animal.conditionColumn .. " FROM ranch WHERE ranchid = ?", { ranchId }, function(results)
        if results and #results > 0 then
            local result = results[1] -- Get the first result row

            local currentAge = result[animal.column]
            local currentCondition = result[animal.conditionColumn]

            -- Check if the result contains valid data
            if currentAge == nil or currentCondition == nil then
                devPrint("Error: Unable to fetch valid age or condition data for " .. animalType .. " at ranchId: " .. ranchId)
                cb(false) -- Return failure callback if data is missing
                return
            end

            -- Debug print the fetched values
            devPrint("Fetched currentAge: " .. tostring(currentAge) .. ", currentCondition: " .. tostring(currentCondition))

            -- Check if the current condition matches the maxCondition
            if currentCondition == animal.maxCondition then
                -- Only update the animal's age if it has not reached max age
                if currentAge < animal.maxAge then
                    -- Update the animal's age in the database
                    MySQL.update("UPDATE ranch SET " .. animal.column .. " = " .. animal.column .. " + ? WHERE ranchid = ?", { incAmount, ranchId })
                    UpdateAllRanchersRanchData(ranchId)
                    devPrint("Successfully increased age for " .. animalType .. " at ranchId: " .. ranchId)
                    cb(true) -- Return success callback
                else
                    devPrint("Error: Animal age has reached max age (" .. animal.maxAge .. ") and cannot be increased.")
                    cb(false) -- Return failure callback if the animal has reached max age
                end
            else
                devPrint("Error: Animal condition (" .. currentCondition .. ") does not match max condition (" .. animal.maxCondition .. ") and cannot be increased.")
                cb(false)
            end
        else
            devPrint("Error: Unable to fetch current age and condition for " .. animalType .. " at ranchId: " .. ranchId)
            cb(false) -- Return failure callback if data fetch fails
        end
    end)
end)

BccUtils.RPC:Register("bcc-ranch:ButcherAnimalHandler", function(params, cb, recSource)
    local animalType = params.animalType
    local ranchId = params.ranchId
    local table = params.table

    devPrint("Butchering animal for ranchId: " .. ranchId .. " with animalType: " .. animalType)

    local butcherFuncts = {
        ['cows'] = function()
            MySQL.update.await('UPDATE ranch SET cows = "false", cows_cond = 0, cows_age = 0 WHERE ranchid = ?', { ranchId })
        end,
        ['chickens'] = function()
            MySQL.update.await('UPDATE ranch SET chickens = "false", chickens_cond = 0, chickens_age = 0 WHERE ranchid = ?', { ranchId })
        end,
        ['pigs'] = function()
            MySQL.update.await('UPDATE ranch SET pigs = "false", pigs_cond = 0, pigs_age = 0 WHERE ranchid = ?', { ranchId })
        end,
        ['sheeps'] = function()
            MySQL.update.await('UPDATE ranch SET sheeps = "false", sheeps_cond = 0, sheeps_age = 0 WHERE ranchid = ?', { ranchId })
        end,
        ['goats'] = function()
            MySQL.update.await('UPDATE ranch SET goats = "false", goats_cond = 0, goats_age = 0 WHERE ranchid = ?', { ranchId })
        end
    }

    if butcherFuncts[animalType] then
        butcherFuncts[animalType]()
        UpdateAllRanchersRanchData(ranchId)  -- Update ranch data for all ranchers
    end

    -- Adding butcher items to the player's inventory
    for k, v in pairs(table.butcherItems) do
        exports.vorp_inventory:addItem(recSource, v.name, v.count, {})
    end

    -- Indicate success via callback
    cb(true)
end)

BccUtils.RPC:Register("bcc-ranch:AnimalSold", function(params, cb, recSource)
    local payAmount = params.payAmount
    local ranchId = params.ranchId
    local animalType = params.animalType

    -- Fetch the ranch data from the database
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid = ?", { ranchId })

    if #ranch > 0 then
        devPrint("Animal sold for ranchId: " .. ranchId .. " with animalType: " .. animalType .. " and payAmount: " .. payAmount)

        -- Update ledger with the sale amount
        MySQL.update.await("UPDATE ranch SET ledger = ledger + ? WHERE ranchid = ?", { payAmount, ranchId })

        -- Define functions for each animal type that resets animal data
        local soldFuncts = {
            ['cows'] = function()
                MySQL.update.await('UPDATE ranch SET cows = "false", cows_cond = 0, cows_age = 0 WHERE ranchid = ?', { ranchId })
            end,
            ['chickens'] = function()
                MySQL.update.await('UPDATE ranch SET chickens = "false", chickens_cond = 0, chickens_age = 0 WHERE ranchid = ?', { ranchId })
            end,
            ['pigs'] = function()
                MySQL.update.await('UPDATE ranch SET pigs = "false", pigs_cond = 0, pigs_age = 0 WHERE ranchid = ?', { ranchId })
            end,
            ['sheeps'] = function()
                MySQL.update.await('UPDATE ranch SET sheeps = "false", sheeps_cond = 0, sheeps_age = 0 WHERE ranchid = ?', { ranchId })
            end,
            ['goats'] = function()
                MySQL.update.await('UPDATE ranch SET goats = "false", goats_cond = 0, goats_age = 0 WHERE ranchid = ?', { ranchId })
            end
        }

        -- Execute the corresponding function for the given animal type
        if soldFuncts[animalType] then
            soldFuncts[animalType]()
            -- Update ranch data for all ranchers
            UpdateAllRanchersRanchData(ranchId)
        end

        -- Notify success back to the client
        devPrint("Successfully sold animal for ranchId: " .. ranchId .. " with animalType: " .. animalType)
        if cb then cb(true) end
    else
        -- Ranch not found or invalid data
        devPrint("Ranch not found or invalid ranchId: " .. ranchId)
        if cb then cb(false) end
    end
end)

-- Cleanup --
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        MySQL.update.await("UPDATE ranch SET is_any_animals_out = 'false'")
    end
end)
