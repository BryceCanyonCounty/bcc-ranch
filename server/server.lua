---------- Pulling Essentials -------------
VORPcore = {} --Pulls vorp core
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = exports['bcc-utils'].initiate()
local ranches = {}

------ Commands Admin Check --------
RegisterServerEvent('bcc-ranch:AdminCheck', function(nextEvent, servEvent)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    for k, v in pairs(Config.AdminSteamIds) do
        if character.identifier == v.steamid then
            if servEvent then
                TriggerEvent(nextEvent)
            else
                TriggerClientEvent(nextEvent, _source)
            end
        end
    end
end)

function LoadDB()
    local loading = true
    exports.ghmattimysql:execute('SELECT * FROM ranch', {}, function(result)
        ranches = result
        loading = false
    end)
    while loading do
        Wait(10)
    end
end
local allemployees = {}

AddEventHandler('onResourceStart', function(resourceName)
    LoadDB()
    GetAllRanchEmployees()
end)

function getRanchById(ranchId)
    for i=1, #ranches do
        if ranches[i].ranchid == ranchId then
            return ranches[i]
        end
    end
    return nil
end

function CheckIfRanchIsOwnedLocal(charIdentifier)
    for _, ranch in pairs(ranches) do
        if tonumber(ranch.charidentifier) == tonumber(charIdentifier) then
            return true
        end
    end
    return false
end

function getRanchByCharIdentifier(charIdentifier)
    for i=1, #ranches do
        if ranches[i].charidentifier == charIdentifier then
            return ranches[i]
        end
    end
    return nil
end

function GetAllRanchEmployees()
    local loading = true

    exports.ghmattimysql:execute('SELECT charidentifier, ranchid FROM characters WHERE ranchid != 0', {}, function(result)
        if #result ~= 0 then
            allemployees = result
        end
        loading = false
    end)
    
    while loading do
        Wait(10)
    end 
end

function CheckEmployeesbyranch(ranchid)
    local emps = {}
    for _, emp in pairs(allemployees) do
        if emp.ranchid == ranchid then
            table.insert(emps, emp)
        end
    end
    return emps
end

function isinemp(charid)
    for _, emps in pairs(allemployees) do
        if emps.charidentifier == charid then
            return true
        end
    end
    return false
end

function isEmployeeOnServer(charid)
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        if DoesEntityExist(playerPed) then
            local user = VORPcore.getUser(playerId)
            local Character = user.getUsedCharacter
            local charId = Character.charIdentifier
            if charId == charid then
                if isinemp(charId) then
                    return playerId
                end
            end
        end
    end
    return false
end

function senddatatoemployees(ranchid)
    local emps = CheckEmployeesbyranch(ranchid)
    for _, e in pairs(emps) do
        local ison = isEmployeeOnServer(e.charidentifier)
        if ison then
            local ranch = getRanchById(ranchid)
            TriggerClientEvent("bcc-ranch:GetData", ison, ranch)
        end
    end
end

CreateThread(function() --Tax handling
    local date = os.date("%d")
    if tonumber(date) == tonumber(Config.TaxDay) then --for some reason these have to be tonumbered
        if #ranches > 0 then
            for k, v in pairs(ranches) do
                local param = { ['ranchid'] = v.ranchid, ['taxamount'] = tonumber(v.taxamount) }
                if v.taxescollected == 'false' then
                    if tonumber(v.ledger) < tonumber(v.taxamount) then
                        exports.oxmysql:execute("UPDATE ranch SET charidentifier=0 WHERE ranchid=@ranchid", param)
                        v.charidentifier = 0
                        BccUtils.Discord.sendMessage(Config.Webhooks.Taxes.WebhookLink,
                            _U("ranchIdWebhook") .. tostring(v.ranchid), _U("taxPaidFailedWebhook"))
                    else
                        exports.oxmysql:execute(
                            "UPDATE ranch SET ledger=ledger-@taxamount, taxescollected='true' WHERE ranchid=@ranchid",
                            param)
                            v.taxescollected = true
                        BccUtils.Discord.sendMessage(Config.Webhooks.Taxes.WebhookLink,
                            _U("ranchIdWebhook") .. tostring(v.ranchid), _U("taxPaidWebhook"))
                    end
                end
            end
        end
    elseif tonumber(date) == tonumber(Config.TaxResetDay) then
        if #ranches > 0 then
            for k, v in pairs(ranches) do
                local param = { ['ranchid'] = v.ranchid }
                exports.oxmysql:execute("UPDATE ranch SET taxes_collected='false' WHERE ranchid=@ranchid", param)
                v.taxes_collected = false
            end
        end
    end
end)

RegisterServerEvent('bcc-ranch:CheckAnimalsOut', function(RanchId, getOnlyCurrentState, otherSource)
    local _source = otherSource or source
    local param = { ['RanchId'] = RanchId }


    local ranch = getRanchById(RanchId)
    if not ranch then
        print('No ranch found for ranch id: ', RanchId, ' Current source: ', _source)
    end

    local isherding = ranch.isherding

    if isherding > 0 then
        TriggerClientEvent('bcc-ranch:AnimalsOutCl', _source, isherding)
    else
        if getOnlyCurrentState ~= true then
            ranch.isherding = 1
        end
        TriggerClientEvent('bcc-ranch:AnimalsOutCl', _source, isherding)
    end
end)

--------- Put Animals Back --------------
RegisterServerEvent('bcc-ranch:PutAnimalsBack', function(RanchId)
    local param = { ['RanchId'] = RanchId }
    local ranch = getRanchById(RanchId)
    if not ranch then
        print('No ranch found for ranch id: ', RanchId, ' Current source: ', source)
    end
    ranch.ranch.isherding = 0
end)

--------- Open Inv Handler --------------
RegisterServerEvent('bcc-ranch:OpenInv', function(ranchid)
    local _source = source
    VORPInv.OpenInv(_source, 'Player_' .. ranchid .. '_bcc-ranchinv')
end)

-------- Adding Items ----------
RegisterServerEvent('bcc-ranch:AddItem', function(item, amount)
    local _source = source
    VORPInv.addItem(_source, item, amount)
end)

-------- Adding Items Random ----------
RegisterServerEvent('bcc-ranch:AddItemRandom', function(item)
    math.randomseed(os.time())
    local _source = source
    local amount = math.random(5, 30)
    VORPInv.addItem(_source, item, amount)
end)

------ Create Ranch Db Handler -----
RegisterServerEvent('bcc-ranch:InsertCreatedRanchIntoDB',
    function(ranchName, ranchRadius, ownerStaticId, coords, taxes, ownerSource)
        local _source = source
        local param = {
            ['ranchname'] = ranchName,
            ['ranch_radius_limit'] = ranchRadius,
            ['charidentifier'] = ownerStaticId,
            ['ranchcoords'] = json.encode(coords),
            ['taxamount'] = taxes
        }

        local result = MySQL.query.await("SELECT * FROM characters WHERE charidentifier=@charidentifier AND ranchid != 0", param)

        if #result >= 1 then
            VORPcore.NotifyRightTip(_source, _U("AlreadyOwnRanch"), 4000)
        else
            -- Create ranch and get created ranchid
            local create_ranch_query = "INSERT INTO ranch ( `charidentifier`,`ranchcoords`,`ranchname`,`ranch_radius_limit` ,`taxamount`) VALUES ( @charidentifier,@ranchcoords,@ranchname,@ranch_radius_limit,@taxamount )"
            local ranchid = MySQL.insert.await(create_ranch_query, param)
                
            -- Update owners ranchid in characters
            local update_characters_query = "UPDATE characters SET ranchid=@ranchid WHERE charidentifier=@charidentifier"
            local update_characters_param = {
              ranchid = ranchid,
              charidentifier = ownerStaticId
            }
            local param2 = {
                ['ranchname'] = ranchName,
                ['ranch_radius_limit'] = ranchRadius,
                ['charidentifier'] = ownerStaticId,
                ['ranchcoords'] = json.encode(coords),
                ['ranchid'] = ranchid,
                ['taxamount'] = taxes
            }
            table.insert(ranches, param2)
            
            MySQL.query.await(update_characters_query, update_characters_param)
            
            local character = VORPcore.getUser(_source).getUsedCharacter
            VORPcore.NotifyRightTip(_source, _U("RanchMade"), 4000)
            BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch',
                'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg',
                Config.Webhooks.RanchCreation.TitleText .. tostring(character.charIdentifier),
                Config.Webhooks.RanchCreation.Text .. tostring(ownerStaticId))
            TriggerEvent('bcc-ranch:CheckIfRanchIsOwned', ownerSource)
        end
    end)

-------- Chore Coord Insertion(Citas pr) -------
RegisterServerEvent('bcc-ranch:ChoreInsertIntoDB', function(coords, RanchId, type)
    local _source = source
    local ranch = getRanchById(RanchId)

    local databaseUpdate = {
        ['shovehaycoords'] = function()
            local param = { ['shovehaycoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.shovehaycoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET shovehaycoords = @shovehaycoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("ShoveHaySave"), 4000)
        end,
        ['wateranimalcoords'] = function()
            local param = { ['wateranimalcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.wateranimalcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET wateranimalcoords = @wateranimalcoords WHERE ranchid=@ranchid",
                param)
            VORPcore.NotifyRightTip(_source, _U("WaterAnimalSave"), 4000)
        end,
        ['repairtroughcoords'] = function()
            local param = { ['repairtroughcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.repairtroughcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET repairtroughcoords = @repairtroughcoords WHERE ranchid=@ranchid",
                param)
            VORPcore.NotifyRightTip(_source, _U("RepairTroughSave"), 4000)
        end,
        ['scooppoopcoords'] = function()
            local param = { ['scooppoopcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.scooppoopcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET scooppoopcoords = @scooppoopcoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("ScoopPoopSave"), 4000)
        end
    }

    if databaseUpdate[type] then
        databaseUpdate[type]()
    end

    senddatatoemployees(RanchId)
end)

RegisterServerEvent('bcc-ranch:AnimalLocationDbInserts', function(coords, RanchId, type)
    local _source = source
    local ranch = getRanchById(RanchId)

    local databaseUpdate = { --utilizing good indexing to trigger functions instead of using elseif more optimal skips straight to the funt instead of going through all the elseif statements thanks to apo for the tip
        ['herdcoords'] = function()
            local param = { ['herdlocation'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.herdlocation = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET herdlocation = @herdlocation WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
        end,
        ['pigcoords'] = function()
            local param = { ['pigcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.pigcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET pigcoords = @pigcoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
        end,
        ['cowcoords'] = function()
            local param = { ['cowcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.cowcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET cowcoords = @cowcoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
        end,
        ['sheepcoords'] = function()
            local param = { ['sheepcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.sheepcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET sheepcoords = @sheepcoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
        end,
        ['goatcoords'] = function()
            local param = { ['goatcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.goatcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET goatcoords = @goatcoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
        end,
        ['chickencoords'] = function()
            local param = { ['chickencoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.chickencoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET chickencoords = @chickencoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
        end,
        ['feedwagoncoords'] = function()
            local param = { ['wagonfeedcoords'] = json.encode(coords), ['ranchid'] = RanchId }
            ranch.wagonfeedcoords = json.encode(coords)
            exports.oxmysql:execute("UPDATE ranch SET wagonfeedcoords = @wagonfeedcoords WHERE ranchid=@ranchid", param)
            VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
        end
    }

    if databaseUpdate[type] then
        databaseUpdate[type]()
    end

    senddatatoemployees(RanchId)
end)
---- (End Citas pr) -----

RegisterServerEvent('bcc-ranch:CheckisOwner', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local result = CheckIfRanchIsOwnedLocal(character.charIdentifier)
    TriggerClientEvent('bcc-ranch:IsOwned', _source, result)
end)

------ Ledger Area ------
RegisterServerEvent('bcc-ranch:GetLedger', function(ranchid)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    local ranch = getRanchById(ranchid)
    if not ranch then
        print('No ranch found for ranch id: ', RanchId, ' Current source: ', source)
    end
    TriggerClientEvent('bcc-ranch:LedgerMenu', _source, ranch.ledger)
end)

RegisterServerEvent('bcc-ranch:AffectLedger', function(ranchid, type, amount)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchid, ['amount'] = amount }
    local ranch = getRanchById(ranchid)
    local result = MySQL.query.await("SELECT ledger FROM ranch WHERE ranchid=@ranchid", param)
    if #result > 0 then
        if type == 'withdraw' then
            if tonumber(amount) <= tonumber(result[1].ledger) then
                exports.oxmysql:execute("UPDATE ranch SET ledger= ledger-@amount WHERE ranchid=@ranchid", param)
                ranch.ledger = ranch.ledger - amount
                character.addCurrency(0, amount)
                VORPcore.NotifyRightTip(_source, _U("TookLedger") .. amount .. _U("FromtheLedger"), 4000)
            else
                VORPcore.NotifyRightTip(_source, _U("Notenough"), 4000)
            end
        else
            exports.oxmysql:execute("UPDATE ranch SET ledger= ledger+@amount WHERE ranchid=@ranchid", param)
            ranch.ledger = ranch.ledger + amount
            character.removeCurrency(0, amount)
            VORPcore.NotifyRightTip(_source, _U("PutLedger") .. amount .. _U("IntheLedger"), 4000)
        end
    end
end)

----- Checking If Character Owns a ranch -----
RegisterServerEvent('bcc-ranch:CheckIfRanchIsOwned')
AddEventHandler('bcc-ranch:CheckIfRanchIsOwned',
    function(ownerSource) --Done this way so can be called server or client side
        local _source = nil
        if ownerSource ~= nil or false then
            _source = ownerSource
        else
            _source = source
        end
        
        local character = VORPcore.getUser(_source).getUsedCharacter
        local param = { ['charidentifier'] = character.charIdentifier }
        local ranch = getRanchByCharIdentifier(character.charIdentifier)
        if ranch then
            VORPInv.removeInventory('Player_' .. ranch.ranchid .. '_bcc-ranchinv')
            Wait(50)
            VORPInv.registerInventory('Player_' .. ranch.ranchid .. '_bcc-ranchinv', Config.RanchSetup.InvName,
                Config.RanchSetup.InvLimit, true, true, true)
            TriggerClientEvent('bcc-ranch:HasRanchHandler', _source, ranch)
        end
    end)

--------- Employee Area -----------
RegisterServerEvent('bcc-ranch:CheckIfInRanch')
AddEventHandler('bcc-ranch:CheckIfInRanch', function(employeeSource)
    local _source = nil
    if employeeSource ~= nil or false then
        _source = employeeSource
    else
        _source = source
    end
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = character.charIdentifier }
    local result = MySQL.query.await("SELECT ranchid FROM characters WHERE charidentifier=@charidentifier", param)
    if #result > 0 then
        if result[1].ranchid ~= nil and 0 then
            local ranchid = result[1].ranchid
            local param2 = { ["ranchid"] = ranchid }
            local ranch = getRanchById(ranchid)
            if ranch then
                VORPInv.removeInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv')
                Wait(50)
                VORPInv.registerInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv',
                    Config.RanchSetup.InvName, Config.RanchSetup.InvLimit, true, true, true)
                TriggerClientEvent('bcc-ranch:HasRanchHandler', _source, ranch)
            end
        end
    end
end)

RegisterServerEvent('bcc-ranch:HireEmployee', function(ranchId, charid, employeeSource)
    local param = { ['charidentifier'] = charid, ['ranchid'] = ranchId }
    table.insert(allemployees, { charidentifier = charid, ranchid = ranchId})
    MySQL.query.await('UPDATE characters SET ranchid=@ranchid WHERE charidentifier=@charidentifier', param)
    TriggerEvent('bcc-ranch:CheckIfInRanch', employeeSource)
    BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch',
        'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg',
        Config.Webhooks.RanchCreation.TitleText .. tostring(charid),
        Config.Webhooks.RanchCreation.Text .. tostring(charid))
end)

RegisterServerEvent('bcc-ranch:FireEmployee', function(charid)
    local param = { ['charidentifier'] = charid }
    exports.oxmysql:execute('UPDATE characters SET ranchid=0 WHERE charidentifier=@charidentifier', param)
    BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch',
        'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg',
        Config.Webhooks.RanchCreation.TitleText .. tostring(charid),
        Config.Webhooks.RanchCreation.Text .. tostring(charid))
end)

RegisterServerEvent("bcc-ranch:GetEmployeeList")
AddEventHandler("bcc-ranch:GetEmployeeList", function(ranchid)
    local _source = source
    local result = MySQL.query.await(
        "SELECT firstname, lastname, charidentifier FROM characters WHERE ranchid = @ranchid", { ["ranchid"] = ranchid })
    TriggerClientEvent('bcc-ranch:ViewEmployeeMenu', _source, result)
end)

---- Event To Check for Ranchcondition For chores ----
RegisterServerEvent('bcc-ranch:ChoreCheckRanchCondition', function(ranchid, chore)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    local ranch = getRanchById(ranchid)
    if ranch then
        if ranch.ranchCondition >= 100 then
            VORPcore.NotifyRightTip(_source, _U("ConditionMax"), 4000)
        else
            TriggerEvent('bcc-ranch:ChoreCooldownSV',_source, ranchid, nil, chore, nil)
        end
    end
end)

---- Event To Increase Ranch Condition Upon Chore Completion -----
RegisterServerEvent('bcc-ranch:RanchConditionIncrease', function(increaseAmount, ranchid)
    local param = { ['ranchid'] = ranchid, ['ConditionIncrease'] = increaseAmount }
    local ranch = getRanchById(ranchid)
    ranch.ranchCondition = ranch.ranchCondition + increaseAmount
    exports.oxmysql:execute("UPDATE ranch SET `ranchCondition`=ranchCondition+@ConditionIncrease WHERE ranchid=@ranchid",
        param)
end)

---- Event To Display Ranch Condition To Player -----
RegisterServerEvent('bcc-ranch:DisplayRanchCondition', function(ranchid)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    local ranch = getRanchById(ranchid)
    if ranch then
        VORPcore.NotifyRightTip(_source, tostring(ranch.ranchCondition), 4000)
    end
end)

---- Buy Animals Event ----
RegisterServerEvent('bcc-ranch:BuyAnimals', function(ranchid, animalType)
    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalBought.WebhookLink, 'BCC Ranch',
        'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg')
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchid }
    local ranch = getRanchById(ranchid)

    local buyAnimalsHandler = {
        ['cows'] = function()
            if character.money >= Config.RanchSetup.RanchAnimalSetup.Cows.Cost then
                local result = MySQL.query.await("SELECT cows FROM ranch WHERE ranchid=@ranchid", param)
                if #result > 0 then
                    if result[1].cows == 'false' then
                        TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'cows', _source)
                        ranch.cows = true
                        exports.oxmysql:execute('UPDATE ranch SET `cows`="true" WHERE ranchid=@ranchid', param)
                        AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Cows.Cost,
                            Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                            Config.Webhooks.AnimalBought.Cows, _source, ranchid, discord, character)
                    else
                        VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                    end
                end
            else
                VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
            end
        end,
        ['pigs'] = function()
            if character.money >= Config.RanchSetup.RanchAnimalSetup.Pigs.Cost then
                local result = MySQL.query.await("SELECT pigs FROM ranch WHERE ranchid=@ranchid", param)
                if #result > 0 then
                    if result[1].pigs == 'false' then
                        TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'pigs', _source)
                        ranch.pigs = true
                        exports.oxmysql:execute('UPDATE ranch SET `pigs`="true" WHERE ranchid=@ranchid', param)
                        AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Pigs.Cost,
                            Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                            Config.Webhooks.AnimalBought.Pigs, _source, ranchid, discord, character)
                    else
                        VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                    end
                end
            else
                VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
            end
        end,
        ['sheeps'] = function()
            if character.money >= Config.RanchSetup.RanchAnimalSetup.Sheeps.Cost then
                local result = MySQL.query.await("SELECT sheeps FROM ranch WHERE ranchid=@ranchid", param)
                if #result > 0 then
                    if result[1].sheeps == 'false' then
                        TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'sheeps', _source)
                        ranch.sheeps = true
                        exports.oxmysql:execute('UPDATE ranch SET `sheeps`="true" WHERE ranchid=@ranchid', param)
                        AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Sheeps.Cost,
                            Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                            Config.Webhooks.AnimalBought.Sheeps, _source, ranchid, discord, character)
                    else
                        VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                    end
                end
            else
                VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
            end
        end,
        ['goats'] = function()
            if character.money >= Config.RanchSetup.RanchAnimalSetup.Goats.Cost then
                local result = MySQL.query.await("SELECT goats FROM ranch WHERE ranchid=@ranchid", param)
                if #result > 0 then
                    if result[1].goats == 'false' then
                        TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'goats', _source)
                        ranch.goats = true
                        exports.oxmysql:execute('UPDATE ranch SET `goats`="true" WHERE ranchid=@ranchid', param)
                        AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Goats.Cost,
                            Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                            Config.Webhooks.AnimalBought.Goats, _source, ranchid, discord, character)
                    else
                        VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                    end
                end
            else
                VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
            end
        end,
        ['chickens'] = function()
            if character.money >= Config.RanchSetup.RanchAnimalSetup.Chickens.Cost then
                local result = MySQL.query.await("SELECT chickens FROM ranch WHERE ranchid=@ranchid", param)
                if #result > 0 then
                    if result[1].chickens == 'false' then
                        TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'chickens', _source)
                        ranch.chickens = true
                        exports.oxmysql:execute('UPDATE ranch SET `chickens`="true" WHERE ranchid=@ranchid', param)
                        AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Chickens.Cost,
                            Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                            Config.Webhooks.AnimalBought.Chickens, _source, ranchid, discord, character)
                    else
                        VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                    end
                end
            else
                VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
            end
        end
    }

    if buyAnimalsHandler[animalType] then
        buyAnimalsHandler[animalType]()
    end
end)

--Funct for removing money notiying and webhooking
function AnimalBoughtHandle(cost, webhookTitle, webhookDesc, animalWebhookName, _source, ranchid, discord, character)
    character.removeCurrency(0, cost)
    VORPcore.NotifyRightTip(_source, _U("AnimalBought"), 4000)
    discord:sendMessage(webhookTitle .. tostring(ranchid), webhookDesc .. animalWebhookName)
end

---- Event To Check If Animals Are Owned ----
RegisterServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', function(ranchid, animalType)
    local param = { ['ranchid'] = ranchid }
    local eventTriggger, _source = false, source
    local animalCondition, ranchCond
    local ranch = getRanchById(ranchid)
    if ranch then
        ranchCond = ranch.ranchCondition
        local ownedChecks = {
            ['cows'] = function()
                if ranch.cows ~= 'false' then
                    eventTriggger = true
                    animalCondition = ranch.cows_cond
                else
                    VORPcore.NotifyRightTip(_source, _U("AnimalNotOwned"), 4000)
                end
            end,
            ['pigs'] = function()
                if ranch.pigs ~= 'false' then
                    eventTriggger = true
                    animalCondition = ranch.pigs_cond
                else
                    VORPcore.NotifyRightTip(_source, _U("AnimalNotOwned"), 4000)
                end
            end,
            ['sheeps'] = function()
                if ranch.sheeps ~= 'false' then
                    eventTriggger = true
                    animalCondition = ranch.sheeps_cond
                else
                    VORPcore.NotifyRightTip(_source, _U("AnimalNotOwned"), 4000)
                end
            end,
            ['chickens'] = function()
                if ranch.chickens ~= 'false' then
                    eventTriggger = true
                    animalCondition = ranch.chickens_cond
                else
                    VORPcore.NotifyRightTip(_source, _U("AnimalNotOwned"), 4000)
                end
            end,
            ['goats'] = function()
                if ranch.goats ~= 'false' then
                    eventTriggger = true
                    animalCondition = ranch.goats_cond
                else
                    VORPcore.NotifyRightTip(_source, _U("AnimalNotOwned"), 4000)
                end
            end
        }

        if ownedChecks[animalType] then
            ownedChecks[animalType]()
        end

        if eventTriggger then
            TriggerClientEvent('bcc-ranch:OwnedAnimalManagerMenu', _source, animalCondition, animalType, ranchCond)
        end
    end
end)

local sells_by_ranch = {}

---@param ranchid number
---@param animalType string
local registerSell = function(ranchid, animalType)

    if not sells_by_ranch[ranchid] then
        sells_by_ranch[ranchid] = {}
    end

    if not sells_by_ranch[ranchid][animalType] then
        sells_by_ranch[ranchid][animalType] = true
    end
end

---@param ranchid number
---@param animalType string
---@return boolean
local hasRegisteredSell = function(ranchid, animalType)

    if not sells_by_ranch[ranchid] then
        return false
    end

    if not sells_by_ranch[ranchid][animalType] then
        return false
    end

    return sells_by_ranch[ranchid][animalType] == true
end

RegisterServerEvent('bcc-ranch:CheckIfCanSellRequest', function(ranchid, animalType)

    local _source = source

    local can_sell_animals_of_type = true

    if Config.RanchSetup.SellAnimalTypeOnlyOncePerServerStart then
        can_sell_animals_of_type = hasRegisteredSell(ranchid, animalType) ~= true
    end

    TriggerClientEvent('bcc-ranch:CheckIfCanSellResponse', _source, can_sell_animals_of_type)
end)

----- Event that will pay player and delete thier animals from db upon sell ------
RegisterServerEvent('bcc-ranch:AnimalsSoldHandler', function(payAmount, animalType, ranchid)
    local param = { ['ranchid'] = ranchid }
    local ranch = getRanchById(ranchid)
    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalSold.WebhookLink, 'BCC Ranch',
        'https://i.imgur.com/vLy5jKH.png')
    local ledger

    local result = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #result > 0 then
        ledger = result[1].ledger
        ranch.ledger = ranch.ledger + tonumber(payAmount)
        exports.ghmattimysql:execute("UPDATE ranch SET ledger=@1 WHERE ranchid=@id",
            { ["@id"] = ranchid, ["@1"] = ledger + tonumber(payAmount) })
    end

    local soldFuncts = {
        ['cows'] = function()
            discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
                Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Cows .. tostring(payAmount))
                ranch.cows = false
            exports.oxmysql:execute(
                'UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['chickens'] = function()
            discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
                Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Chickens .. tostring(payAmount))
                ranch.chickens = false
            exports.oxmysql:execute(
                'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['pigs'] = function()
            discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
                Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Pigs .. tostring(payAmount))
                ranch.pigs = false
            exports.oxmysql:execute(
                'UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['sheeps'] = function()
            discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
                Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Sheeps .. tostring(payAmount))
                ranch.sheeps = false
            exports.oxmysql:execute(
                'UPDATE ranch SET `sheeps`="false", `sheeps_cond`=0, `sheeps_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['goats'] = function()
            discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
                Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Goats .. tostring(payAmount))
                ranch.goats = false
            exports.oxmysql:execute(
                'UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', param)
        end
    }

    if soldFuncts[animalType] then
        soldFuncts[animalType]()

        registerSell(ranchid, animalType)

    end
end)

------ Raises animal cond upon herd success ------------
RegisterServerEvent('bcc-ranch:AnimalCondIncrease', function(animalType, amounToInc, ranchid)
    local param = { ['ranchid'] = ranchid, ['levelinc'] = amounToInc }
    local ranch = getRanchById(ranchid)

    local condIncFuncts = {
        ['cows'] = function()
            ranch.cows_cond = ranch.cows_cond + amounToInc
            exports.oxmysql:execute('UPDATE ranch SET `cows_cond`=cows_cond+@levelinc WHERE ranchid=@ranchid', param)
        end,
        ['chickens'] = function()
            ranch.chickens_cond = ranch.chickens_cond + amounToInc
            exports.oxmysql:execute('UPDATE ranch SET `chickens_cond`=chickens_cond+@levelinc WHERE ranchid=@ranchid',
                param)
        end,
        ['pigs'] = function()
            ranch.pigs_cond = ranch.pigs_cond + amounToInc
            exports.oxmysql:execute('UPDATE ranch SET `pigs_cond`=pigs_cond+@levelinc WHERE ranchid=@ranchid', param)
        end,
        ['sheeps'] = function()
            ranch.sheeps_cond = ranch.sheeps_cond + amounToInc
            exports.oxmysql:execute('UPDATE ranch SET `sheeps_cond`=sheeps_cond+@levelinc WHERE ranchid=@ranchid', param)
        end,
        ['goats'] = function()
            ranch.goats_cond = ranch.goats_cond + amounToInc
            exports.oxmysql:execute('UPDATE ranch SET `goats_cond`=goats_cond+@levelinc WHERE ranchid=@ranchid', param)
        end
    }

    if condIncFuncts[animalType] then
        condIncFuncts[animalType]()
    end
end)

-------- Remove Animals from db after butcher -------
RegisterServerEvent('bcc-ranch:ButcherAnimalHandler', function(animalType, ranchid, table)
    local param = { ['ranchid'] = ranchid }
    local _source = source
    local ranch = getRanchById(ranchid)

    local ButcherFuncts = {
        ['cows'] = function()
            ranch.cows = false
            ranch.cows_cond = 0
            ranch.cows_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['chickens'] = function()
            ranch.chickens = false
            ranch.chickens_cond = 0
            ranch.chickens_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['pigs'] = function()
            ranch.pigs = false
            ranch.pigs_cond = 0
            ranch.pigs_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['sheeps'] = function()
            ranch.sheeps = false
            ranch.sheeps_cond = 0
            ranch.sheeps_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `sheeps`="false", `sheeps_cond`=0, `sheeps_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['goats'] = function()
            ranch.goats = false
            ranch.goats_cond = 0
            ranch.goats_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', param)
        end
    }

    if ButcherFuncts[animalType] then
        ButcherFuncts[animalType]()
    end

    for k, v in pairs(table.ButcherItems) do
        VORPInv.addItem(_source, v.name, v.count)
    end

end)

------ Decrease ranch cond over time ------------
RegisterServerEvent('bcc-ranch:DecranchCondIncrease', function(ranchid)
    local ranch = getRanchById(ranchid)
    local param = { ['ranchid'] = ranchid, ['levelinc'] = Config.RanchSetup.RanchCondDecreaseAmount }
    local result = MySQL.query.await("SELECT ranchCondition from ranch WHERE ranchid=@ranchid", param)
    if #result > 0 then
        if result[1].ranchCondition > 0 then
            ranch.ranchCondition = ranch.ranchCondition - Config.RanchSetup.RanchCondDecreaseAmount
            exports.oxmysql:execute('UPDATE ranch SET `ranchCondition`=ranchCondition-@levelinc WHERE ranchid=@ranchid',
                param)
        end
    end
end)

------------- Get Players Function Credit to vorp admin for this ------------------
--get players info list
PlayersTable = {}
RegisterServerEvent('bcc-ranch:GetPlayers')
AddEventHandler('bcc-ranch:GetPlayers', function()
    local _source = source
    local data = {}

    for _, player in ipairs(PlayersTable) do
        local User = VORPcore.getUser(player)
        if User then
            local Character = User.getUsedCharacter                             --get player info

            local playername = Character.firstname .. ' ' .. Character.lastname --player char name

            data[tostring(player)] = {
                serverId = player,
                PlayerName = playername,
                staticid = Character.charIdentifier,
            }
        end
    end
    TriggerClientEvent("bcc-ranch:SendPlayers", _source, data)
end)

-- check if staff is available
RegisterServerEvent("bcc-ranch:getPlayersInfo", function(source)
    local _source = source
    PlayersTable[#PlayersTable + 1] = _source -- add all players
end)

------- Removing Animal From DB -----------
RegisterServerEvent('bcc-ranch:RemoveAnimalFromDB', function(ranchid, animalType)
    local param = { ['ranchid'] = ranchid }
    local ranch = getRanchById(ranchid)
    local removeAnimalFuncts = {
        ['cows'] = function()
            ranch.cows = false
            ranch.cows_cond = 0
            ranch.cows_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['chickens'] = function()
            ranch.chickens = false
            ranch.chickens_cond = 0
            ranch.chickens_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['pigs'] = function()
            ranch.pigs = false
            ranch.pigs_cond = 0
            ranch.pigs_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['sheeps'] = function()
            ranch.sheeps = false
            ranch.sheeps_cond = 0
            ranch.sheeps_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `sheeps`="false", `sheeps_cond`=0, `sheeps_age`=0 WHERE ranchid=@ranchid', param)
        end,
        ['goats'] = function()
            ranch.goats = false
            ranch.goats_cond = 0
            ranch.goats_age = 0
            exports.oxmysql:execute(
                'UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', param)
        end
    }

    if removeAnimalFuncts[animalType] then
        removeAnimalFuncts[animalType]()
    end
end)

------- Animal Wandering Setup Area -----------
local wanderingBools = {}
RegisterServerEvent('bcc-ranch:WanderingSetup', function(ranchid)
    local alreadySpawned = false
    if #wanderingBools > 0 then
        for k, v in pairs(wanderingBools) do
            if v.ranchId == ranchid and v.status then
                alreadySpawned = true
            end
        end
    end

    if not alreadySpawned then
        local param = { ['ranchid'] = ranchid }
        local _source = source
        local ranch = getRanchById(ranchid)
        if ranch then
            if ranch.cows == 'true' then
                TriggerClientEvent("bcc-ranch:CowsWander", _source)
            end
            if ranch.chickens == 'true' then
                TriggerClientEvent("bcc-ranch:ChickensWander", _source)
            end
            if ranch.sheeps == 'true' then
                TriggerClientEvent("bcc-ranch:SheepsWander", _source)
            end
            if ranch.goats == 'true' then
                TriggerClientEvent("bcc-ranch:GoatsWander", _source)
            end
            if ranch.pigs == 'true' then
                TriggerClientEvent("bcc-ranch:PigsWander", _source)
            end
        end
        table.insert(wanderingBools, { ranchId = ranchid, status = true })
    end
end)

---------- Ageing Setup -----------------------
RegisterServerEvent('bcc-ranch:AgeCheck', function(ranchid)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    local ranch = getRanchById(ranchid)
    if ranch then
        if ranch.cows == 'true' then
            TriggerClientEvent('bcc-ranch:CowsAgeing', _source, ranch.cows_age)
        end
        if ranch.chickens == 'true' then
            TriggerClientEvent('bcc-ranch:ChickensAgeing', _source, ranch.chickens_age)
        end
        if ranch.sheeps == 'true' then
            TriggerClientEvent('bcc-ranch:SheepsAgeing', _source, ranch.sheeps_age)
        end
        if ranch.goats == 'true' then
            TriggerClientEvent('bcc-ranch:GoatsAgeing', _source, ranch.goats_age)
        end
        if ranch.pigs == 'true' then
            TriggerClientEvent('bcc-ranch:PigsAgeing', _source, ranch.pigs_age)
        end
    end
end)

AddEventHandler('bcc-ranch:IndAnimalAgeStart', function(animalType, _source)
    if animalType == 'cows' then
        TriggerClientEvent('bcc-ranch:CowsAgeing', _source, 0)
    end
    if animalType == 'chickens' then
        TriggerClientEvent('bcc-ranch:ChickensAgeing', _source, 0)
    end
    if animalType == 'sheeps' then
        TriggerClientEvent('bcc-ranch:SheepsAgeing', _source, 0)
    end
    if animalType == 'goats' then
        TriggerClientEvent('bcc-ranch:GoatsAgeing', _source, 0)
    end
    if animalType == 'pigs' then
        TriggerClientEvent('bcc-ranch:PigsAgeing', _source, 0)
    end
end)

RegisterServerEvent('bcc-ranch:AgeIncrease', function(animalType, ranchid)
    local ranch = getRanchById(ranchid)
    local ageIncFuncts = {
        ['cows'] = function()
            local param = {
                ['ranchid'] = ranchid,
                ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseAmount
            }
            ranch.cows_age = ranch.cows_age + Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseAmount
            exports.oxmysql:execute("UPDATE ranch SET `cows_age`=cows_age+@increaseamount WHERE ranchid=@ranchid", param)
        end,
        ['chickens'] = function()
            local param = {
                ['ranchid'] = ranchid,
                ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseAmount
            }
            ranch.chickens_age = ranch.chickens_age + Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseAmount
            exports.oxmysql:execute(
                "UPDATE ranch SET `chickens_age`=chickens_age+@increaseamount WHERE ranchid=@ranchid", param)
        end,
        ['sheeps'] = function()
            local param = {
                ['ranchid'] = ranchid,
                ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Sheeps.AgeIncreaseAmount
            }
            exports.oxmysql:execute("UPDATE ranch SET `sheeps_age`=sheeps_age+@increaseamount WHERE ranchid=@ranchid", param)
            ranch.sheeps_age = ranch.sheeps_age + Config.RanchSetup.RanchAnimalSetup.Sheeps.AgeIncreaseAmount
        end,
        ['goats'] = function()
            local param = {
                ['ranchid'] = ranchid,
                ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseAmount
            }
            ranch.goats_age = ranch.goats_age + Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseAmount
            exports.oxmysql:execute("UPDATE ranch SET `goats_age`=goats_age+@increaseamount WHERE ranchid=@ranchid",
                param)
        end,
        ['pigs'] = function()
            local param = {
                ['ranchid'] = ranchid,
                ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseAmount
            }
            ranch.pigs_age = ranch.pigs_age + Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseAmount
            exports.oxmysql:execute("UPDATE ranch SET `pigs_age`=pigs_age+@increaseamount WHERE ranchid=@ranchid", param)
        end
    }

    if ageIncFuncts[animalType] then
        ageIncFuncts[animalType]()
    end
end)

------ Coop Setup -----
RegisterServerEvent('bcc-ranch:CoopDBStorage', function(ranchId, coopCoords) --storing coop to db
    local ranch = getRanchById(ranchId)
    ranch.chicken_coop = true
    ranch.chicken_coop_coords = json.encode(coopCoords)
    local param = { ['ranchid'] = ranchId, ['coopcoords'] = json.encode(coopCoords) }
    exports.oxmysql:execute(
        "UPDATE ranch SET `chicken_coop`='true', `chicken_coop_coords`=@coopcoords WHERE ranchid=@ranchid", param)
end)

RegisterServerEvent('bcc-ranch:ChickenCoopFundsCheck', function() --Checking money to buy coop
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    if character.money >= Config.RanchSetup.RanchAnimalSetup.Chickens.CoopCost then
        character.removeCurrency(0, Config.RanchSetup.RanchAnimalSetup.Chickens.CoopCost)
        TriggerClientEvent('bcc-ranch:PlaceChickenCoop', _source)
    else
        VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
    end
end)

--------- Main Cooldown Area ---------
local coopCooldowns = {} --Coop Collection Cooldown
RegisterServerEvent('bcc-ranch:CoopCollectionCooldown', function(ranchId)
    local _source = source
    local shopid = ranchId
    if coopCooldowns[shopid] then
        if os.difftime(os.time(), coopCooldowns[shopid]) >= Config.RanchSetup.RanchAnimalSetup.Chickens.CoopCollectionCooldownTime then
            coopCooldowns[shopid] = os.time()
            TriggerClientEvent('bcc-ranch:ChickenCoopHarvest', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("HarvestedTooSoon"), 4000)
        end
    else
        coopCooldowns[shopid] = os.time()                           --Store the current time
        TriggerClientEvent('bcc-ranch:ChickenCoopHarvest', _source) --Robbery is not on cooldown
    end
end)

local cowMilkingCooldowns = {} --Cow Milking Cooldown
RegisterServerEvent('bcc-ranch:CowMilkingCooldown', function(ranchId)
    local _source = source
    local shopid = ranchId
    if cowMilkingCooldowns[shopid] then
        if os.difftime(os.time(), cowMilkingCooldowns[shopid]) >= Config.RanchSetup.RanchAnimalSetup.Cows.MilkingCooldown then
            cowMilkingCooldowns[shopid] = os.time()
            TriggerClientEvent('bcc-ranch:MilkCows', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("HarvestedTooSoonCow"), 4000)
        end
    else
        cowMilkingCooldowns[shopid] = os.time()           --Store the current time
        TriggerClientEvent('bcc-ranch:MilkCows', _source) --Robbery is not on cooldown
    end
end)

local sheepShearingCooldowns = {} --Sheep Cooldown
RegisterServerEvent('bcc-ranch:SheepShearingCooldown', function(ranchId)
    local _source = source
    local shopid = ranchId
    if sheepShearingCooldowns[shopid] then
        if os.difftime(os.time(), sheepShearingCooldowns[shopid]) >= Config.RanchSetup.RanchAnimalSetup.Sheeps.ShearCooldownTime then
            sheepShearingCooldowns[shopid] = os.time()
            TriggerClientEvent('bcc-ranch:ShearSheeps', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("HarvestedTooSoonSheep"), 4000)
        end
    else
        sheepShearingCooldowns[shopid] = os.time()           --Store the current time
        TriggerClientEvent('bcc-ranch:ShearSheeps', _source) --Robbery is not on cooldown
    end
end)

local choreCooldowns = {} --Chore and feeding Cooldown

---@param shopid number
---@param _source number
---@param animal string
---@param chore string
---@param feed boolean
---@param checkAnimalsOut boolean|nil
local doCooldownAction = function(shopid, _source, animal, chore, feed, checkAnimalsOut)

    choreCooldowns[shopid] = os.time()

    if checkAnimalsOut == true then
        TriggerEvent('bcc-ranch:CheckAnimalsOut', shopid, false, _source)
    end

    if feed then
        TriggerClientEvent('bcc-ranch:FeedAnimals', _source, animal)
    else
        TriggerClientEvent('bcc-ranch:ShovelHay', _source, chore)
    end
end

---@param shopid number
---@param cooldown number
---@return boolean
local cooldownReached = function(shopid, cooldown)

    if not choreCooldowns[shopid] then
        return true
    end

    if cooldown <= 0 then
        return true
    end

    if os.difftime(os.time(), choreCooldowns[shopid]) >= cooldown then
        return true
    end

    return false
end

---@param feed boolean
---@return number
local getCooldownDuration = function(feed)

    local cooldown

    if feed then
        cooldown = Config.RanchSetup.FeedCooldown
    else
        cooldown = Config.RanchSetup.ChoreCooldown
    end

    if type(cooldown) ~= 'number' or cooldown < 0 then
        cooldown = 0
    end

    return cooldown
end

RegisterServerEvent('bcc-ranch:ChoreCooldownSV', function(source, ranchId, feed, chore, animal, checkAnimalsOut)

    local _source = source
    local shopid = ranchId

    local cooldown = getCooldownDuration(feed)

    if cooldownReached(shopid, cooldown) then
        doCooldownAction(shopid, _source, animal, chore, feed, checkAnimalsOut)
    else
        VORPcore.NotifyRightTip(_source, _U("TooSoon"), 4000)
    end
end)

AddEventHandler('playerDropped', function()
    local character = VORPcore.getUser(source).getUsedCharacter
    local charid = character.charIdentifier

    local select_ranchid_param = { ['charid'] = charid }
    local ranch = MySQL.query.await("SELECT ranchid FROM characters WHERE charidentifier=@charid", select_ranchid_param )

    if ranch and #ranch > 0 and ranch[1] and ranch[1].ranchid and tonumber(ranch[1].ranchid) > 0 then
        local _ranch = getRanchById(ranch[1].ranchid)
        local update_ranch_param = { ranchid = ranch[1].ranchid }
        _ranch.isherding = 0
        MySQL.query.await("UPDATE ranch SET `isherding`=0 WHERE ranchid=@ranchid", update_ranch_param )
    end
end)


----- Version Check ----
BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-ranch')

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    exports.oxmysql:execute("UPDATE ranch SET isherding = 0")
end)
