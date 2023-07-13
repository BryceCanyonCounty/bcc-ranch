---------- Pulling Essentials -------------
VORPcore = {} --Pulls vorp core
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = exports['bcc-utils'].initiate()

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

------ Create Ranch Db Handler -----
RegisterServerEvent('bcc-ranch:InsertCreatedRanchIntoDB', function(ranchName, ranchRadius, ownerStaticId, coords)
    local _source = source

    local param = { ['ranchname'] = ranchName, ['ranch_radius_limit'] = ranchRadius, ['charidentifier'] = ownerStaticId, ['ranchcoords'] = json.encode(coords) }
    exports.oxmysql:execute("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param, function(result)
        if not result[1] then
            exports.oxmysql:execute("INSERT INTO ranch ( `charidentifier`,`ranchcoords`,`ranchname`,`ranch_radius_limit` ) VALUES ( @charidentifier,@ranchcoords,@ranchname,@ranch_radius_limit )", param)
            local character = VORPcore.getUser(_source).getUsedCharacter
            VORPcore.NotifyRightTip(_source, _U("RanchMade"), 4000)
            BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', Config.Webhooks.RanchCreation.TitleText .. tostring(character.charIdentifier), Config.Webhooks.RanchCreation.Text .. tostring(ownerStaticId))
        else
            VORPcore.NotifyRightTip(_source, _U("AlreadyOwnRanch"), 4000)
        end
    end)
end)

RegisterServerEvent('bcc-ranch:InsertShoveHayCdsIntoDB', function(coords, RanchId)
    local _source = source
    local param = { ['shovehaycoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET shovehaycoords = @shovehaycoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("ShoveHaySave"), 4000)
end)

RegisterServerEvent('bcc-ranch:InsertWaterAnimalCdsIntoDB', function(coords, RanchId)
    local _source = source
    local param = { ['wateranimalcoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET wateranimalcoords = @wateranimalcoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("WaterAnimalSave"), 4000)
end)

RegisterServerEvent('bcc-ranch:InsertRepairTroughCdsIntoDB', function(coords, RanchId)
    local _source = source
    local param = { ['repairtroughcoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET repairtroughcoords = @repairtroughcoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("RepairTroughSave"), 4000)
end)

RegisterServerEvent('bcc-ranch:InsertScoopPoopCdsIntoDB', function(coords, RanchId)
    local _source = source
    local param = { ['scooppoopcoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET scooppoopcoords = @scooppoopcoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("ScoopPoopSave"), 4000)
end)

RegisterServerEvent('bcc-ranch:InserHerdLocation', function(coords, RanchId)
    local _source = source
    local param = { ['herdlocation'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET herdlocation = @herdlocation WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
end)

RegisterServerEvent('bcc-ranch:InserPigCoord', function(coords, RanchId)
    local _source = source
    local param = { ['pigcoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET pigcoords = @pigcoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
end)

RegisterServerEvent('bcc-ranch:InserCowCoord', function(coords, RanchId)
    local _source = source
    local param = { ['cowcoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET cowcoords = @cowcoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
end)

RegisterServerEvent('bcc-ranch:InserGoatCoord', function(coords, RanchId)
    local _source = source
    local param = { ['goatcoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET goatcoords = @goatcoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
end)

RegisterServerEvent('bcc-ranch:InserChickenCoord', function(coords, RanchId)
    local _source = source
    local param = { ['chickencoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET chickencoords = @chickencoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
end)

RegisterServerEvent('bcc-ranch:InsertWagonFeedCoords', function(coords, RanchId)
    local _source = source
    local param = { ['wagonfeedcoords'] = json.encode(coords), ['ranchid'] = RanchId }
    exports.oxmysql:execute("UPDATE ranch SET wagonfeedcoords = @wagonfeedcoords WHERE ranchid=@ranchid", param)
    VORPcore.NotifyRightTip(_source, _U("Coordsset"), 4000)
end)

RegisterServerEvent('bcc-ranch:CheckisOwner', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local result = exports['bcc-ranch']:CheckIfRanchIsOwned(character.charIdentifier)
    TriggerClientEvent('bcc-ranch:IsOwned', _source, result)
end)

------ Ledger Area ------
RegisterServerEvent('bcc-ranch:GetLedger', function(ranchid)
    local _source = source
    local param = { ['ranchid'] = ranchid }

    exports.oxmysql:execute("SELECT ledger FROM ranch WHERE ranchid=@ranchid", param, function(result)
        TriggerClientEvent('bcc-ranch:LedgerMenu', _source, result[1].ledger)
    end)
end)

RegisterServerEvent('bcc-ranch:AffectLedger', function(ranchid, type, amount)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchid, ['amount'] = amount }
    exports.oxmysql:execute("SELECT ledger FROM ranch WHERE ranchid=@ranchid", param, function(result)
        if type == 'withdraw' then
         if tonumber(amount) <= tonumber(result[1].ledger) then
            exports.oxmysql:execute("UPDATE ranch SET ledger= ledger-@amount WHERE ranchid=@ranchid", param)
            character.addCurrency(0, amount)
            VORPcore.NotifyRightTip(_source, _U("TookLedger") .. amount .. _U("FromtheLedger"), 4000)
          else
              VORPcore.NotifyRightTip(_source, _U("Notenough"), 4000)
            end
        else
            exports.oxmysql:execute("UPDATE ranch SET ledger= ledger+@amount WHERE ranchid=@ranchid", param)
            character.removeCurrency(0, amount)
            VORPcore.NotifyRightTip(_source, _U("PutLedger") .. amount .. _U("IntheLedger"), 4000)
        end
    end)
end)

----- Checking If Character Owns a ranch -----
RegisterServerEvent('bcc-ranch:CheckIfRanchIsOwned', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = character.charIdentifier }
    exports.oxmysql:execute("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param, function(result)
        if result[1] then
            VORPInv.removeInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv')
            Wait(50)
            VORPInv.registerInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv', Config.RanchSetup.InvName, Config.RanchSetup.InvLimit, true, true, true)
            TriggerClientEvent('bcc-ranch:HasRanchHandler', _source, result[1])
        end
    end)
end)

--------- Employee Area -----------
RegisterServerEvent('bcc-ranch:CheckIfInRanch', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = character.charIdentifier }
    exports.oxmysql:execute("SELECT ranchid FROM characters WHERE charidentifier=@charidentifier", param, function(result)
        if result[1].ranchid ~= nil and 0 then
            local ranchid = result[1].ranchid
            local param2 = { ["ranchid"] = ranchid}
            exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid=@ranchid", param2, function(result2)
                if result2[1] then
                    if result2[1].ranchid == ranchid then
                        VORPInv.removeInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv')
                        Wait(50)
                        VORPInv.registerInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv', Config.RanchSetup.InvName, Config.RanchSetup.InvLimit, true, true, true)
                        TriggerClientEvent('bcc-ranch:HasRanchHandler', _source, result2[1])
                    end
                end
            end)
        end
    end)
end)

RegisterServerEvent('bcc-ranch:HireEmployee', function(ranchId, charid)
    local param = { ['charidentifier'] = charid, ['ranchid'] = ranchId }
    exports.oxmysql:execute('UPDATE characters SET ranchid=@ranchid WHERE charidentifier=@charidentifier', param)
    BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', Config.Webhooks.RanchCreation.TitleText .. tostring(charid), Config.Webhooks.RanchCreation.Text .. tostring(charid))
end)

RegisterServerEvent('bcc-ranch:FireEmployee', function(charid)
    local param = { ['charidentifier'] = charid }
    exports.oxmysql:execute('UPDATE characters SET ranchid=0 WHERE charidentifier=@charidentifier', param)
    BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', Config.Webhooks.RanchCreation.TitleText .. tostring(charid), Config.Webhooks.RanchCreation.Text .. tostring(charid))
end)

RegisterServerEvent("bcc-ranch:GetEmployeeList")
AddEventHandler("bcc-ranch:GetEmployeeList", function(ranchid)
    local _source = source
    local result = MySQL.query.await("SELECT firstname, lastname, charidentifier FROM characters WHERE ranchid = @ranchid", { ["ranchid"] = ranchid })
    TriggerClientEvent('bcc-ranch:ViewEmployeeMenu', _source, result)
end)

---- Event To Check for Ranchcondition For chores ----
RegisterServerEvent('bcc-ranch:ChoreCheckRanchCondition', function(ranchid, chore)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    exports.oxmysql:execute("SELECT ranchCondition FROM ranch WHERE ranchid=@ranchid", param, function(result)
        if result[1].ranchCondition >= 100 then
            VORPcore.NotifyRightTip(_source, _U("ConditionMax"), 4000)
        else
            TriggerClientEvent('bcc-ranch:ShovelHay', _source, chore)
        end
    end)
end)

---- Event To Increase Ranch Condition Upon Chore Completion -----
RegisterServerEvent('bcc-ranch:RanchConditionIncrease', function(increaseAmount, ranchid)
    local param = { ['ranchid'] = ranchid, ['ConditionIncrease'] = increaseAmount }
    exports.oxmysql:execute("UPDATE ranch SET `ranchCondition`=ranchCondition+@ConditionIncrease WHERE ranchid=@ranchid", param)
end)

---- Event To Display Ranch Condition To Player -----
RegisterServerEvent('bcc-ranch:DisplayRanchCondition', function(ranchid)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    exports.oxmysql:execute("SELECT ranchCondition FROM ranch WHERE ranchid=@ranchid", param, function(result)
        VORPcore.NotifyRightTip(_source, tostring(result[1].ranchCondition), 4000)
    end)
end)

---- Buy Animals Event ----
RegisterServerEvent('bcc-ranch:BuyAnimals', function(ranchid, animalType)
    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalBought.WebhookLink, 'BCC Ranch', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg')
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchid }
    if animalType == 'cows' then
        if character.money >= Config.RanchSetup.RanchAnimalSetup.Cows.Cost then
            exports.oxmysql:execute("SELECT cows FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].cows == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'cows', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `cows`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Cows.Cost, Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText, Config.Webhooks.AnimalBought.Cows, _source, ranchid, discord, character)
                else
                    VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
        end
    elseif animalType == 'pigs' then
        if character.money >= Config.RanchSetup.RanchAnimalSetup.Pigs.Cost then
            exports.oxmysql:execute("SELECT pigs FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].pigs == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'pigs', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `pigs`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Pigs.Cost, Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText, Config.Webhooks.AnimalBought.Pigs, _source, ranchid, discord, character)
                else
                    VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
        end
    elseif animalType == 'goats' then
        if character.money >= Config.RanchSetup.RanchAnimalSetup.Goats.Cost then
            exports.oxmysql:execute("SELECT goats FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].goats == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'goats', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `goats`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Goats.Cost, Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText, Config.Webhooks.AnimalBought.Goats, _source, ranchid, discord, character)
                else
                    VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
        end
    elseif animalType == 'chickens' then
        if character.money >= Config.RanchSetup.RanchAnimalSetup.Chickens.Cost then
            exports.oxmysql:execute("SELECT chickens FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].chickens == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'chickens', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `chickens`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Chickens.Cost, Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText, Config.Webhooks.AnimalBought.Chickens, _source, ranchid, discord, character)
                else
                    VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
        end
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
    local eventTriggger = false
    local _source = source
    local animalCondition, ranchCond
    exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid=@ranchid", param, function(result)
        ranchCond = result[1].ranchCondition
        if result[1].cows ~= 'false' and animalType == 'cows' then
            eventTriggger = true
            animalCondition = result[1].cows_cond
        elseif result[1].pigs ~= 'false' and animalType == 'pigs' then
            eventTriggger = true
            animalCondition = result[1].pigs_cond
        elseif result[1].chickens ~= 'false' and animalType == 'chickens' then
            eventTriggger = true
            animalCondition = result[1].chickens_cond
        elseif result[1].goats ~= 'false' and animalType == 'goats' then
            eventTriggger = true
            animalCondition = result[1].goats_cond
        else
            VORPcore.NotifyRightTip(_source, _U("AnimalNotOwned"), 4000)
        end

        if eventTriggger then
            TriggerClientEvent('bcc-ranch:OwnedAnimalManagerMenu', _source, animalCondition, animalType, ranchCond)
        end
    end)
end)

----- Event that will pay player and delete thier animals from db upon sell ------
RegisterServerEvent('bcc-ranch:AnimalsSoldHandler', function(payAmount, animalType, ranchid)
    local param = { ['ranchid'] = ranchid }
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local ledger
    
    exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid=@ranchid", param, function(result)
        ledger = result[1].ledger
        exports.ghmattimysql:execute("UPDATE ranch SET ledger=@1 WHERE ranchid=@id", { ["@id"] = ranchid, ["@1"] = ledger + tonumber(payAmount) })
    end)

    -- Remove the -- below if you want to add money to the player
    --character.addCurrency(0, tonumber(payAmount))

    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalSold.WebhookLink, 'BCC Ranch', 'https://i.imgur.com/vLy5jKH.png')
    if animalType == 'cows' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Cows .. tostring(payAmount))
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'chickens' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Chickens .. tostring(payAmount))
        exports.oxmysql:execute('UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'pigs' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Pigs .. tostring(payAmount))
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'goats' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Goats .. tostring(payAmount))
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', param)
    end
end)

------ Raises animal cond upon herd success ------------
RegisterServerEvent('bcc-ranch:AnimalCondIncrease', function(animalType, amounToInc, ranchid)
    local param = { ['ranchid'] = ranchid, ['levelinc'] = amounToInc }

    if animalType == 'cows' then
        exports.oxmysql:execute('UPDATE ranch SET `cows_cond`=cows_cond+@levelinc WHERE ranchid=@ranchid', param)
    elseif animalType == 'chickens' then
        exports.oxmysql:execute('UPDATE ranch SET `chickens_cond`=chickens_cond+@levelinc WHERE ranchid=@ranchid', param)
    elseif animalType == 'pigs' then
        exports.oxmysql:execute('UPDATE ranch SET `pigs_cond`=pigs_cond+@levelinc WHERE ranchid=@ranchid', param)
    elseif animalType == 'goats' then
        exports.oxmysql:execute('UPDATE ranch SET `goats_cond`=goats_cond+@levelinc WHERE ranchid=@ranchid', param)
    end
end)

-------- Remove Animals from db after butcher -------
RegisterServerEvent('bcc-ranch:ButcherAnimalHandler', function(animalType, ranchid, table)
    local param = { ['ranchid'] = ranchid }
    local _source = source

    if animalType == 'cows' then
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'chickens' then
        exports.oxmysql:execute(
            'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'pigs' then
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'goats' then
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', param)
    end

    for k, v in pairs(table.ButcherItems) do
        VORPInv.addItem(_source, v.name, v.count)
    end
end)

------ Decrease ranch cond over time ------------
RegisterServerEvent('bcc-ranch:DecranchCondIncrease', function(ranchid)
    local param = { ['ranchid'] = ranchid, ['levelinc'] = Config.RanchSetup.RanchCondDecreaseAmount }
    exports.oxmysql:execute("SELECT ranchCondition from ranch WHERE ranchid=@ranchid", param, function(resut)
        if resut[1].ranchCondition > 0 then
            exports.oxmysql:execute('UPDATE ranch SET `ranchCondition`=ranchCondition-@levelinc WHERE ranchid=@ranchid', param)
        end
    end)
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

    if animalType == 'cows' then
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'chickens' then
        exports.oxmysql:execute(
            'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'pigs' then
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid', param)
    elseif animalType == 'goats' then
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid', param)
    end
end)

------- Animal Wandering Setup Area -----------
RegisterServerEvent('bcc-ranch:WanderingSetup', function(ranchid)
    local param = { ['ranchid'] = ranchid }
    local _source = source
    exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid=@ranchid", param, function(result)
        if result[1].cows == 'true' then
            TriggerClientEvent('bcc-ranch:CowsWander', _source)
        end
        if result[1].chickens == 'true' then
            TriggerClientEvent('bcc-ranch:ChickensWander', _source)
        end
        if result[1].goats == 'true' then
            TriggerClientEvent("bcc-ranch:GoatsWander", _source)
        end
        if result[1].pigs == 'true' then
            TriggerClientEvent("bcc-ranch:PigsWander", _source)
        end
    end)
end)

---------- Ageing Setup -----------------------
RegisterServerEvent('bcc-ranch:AgeCheck', function(ranchid)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid=@ranchid", param, function(result)
        Wait(500)
        if result[1].cows == 'true' then
            TriggerClientEvent('bcc-ranch:CowsAgeing', _source, result[1].cows_age)
        end
        if result[1].chickens == 'true' then
            TriggerClientEvent('bcc-ranch:ChickensAgeing', _source, result[1].chickens_age)
        end
        if result[1].goats == 'true' then
            TriggerClientEvent('bcc-ranch:GoatsAgeing', _source, result[1].goats_age)
        end
        if result[1].pigs == 'true' then
            TriggerClientEvent('bcc-ranch:PigsAgeing', _source, result[1].pigs_age)
        end
    end)
end)

AddEventHandler('bcc-ranch:IndAnimalAgeStart', function(animalType, _source)
    if animalType == 'cows' then
        TriggerClientEvent('bcc-ranch:CowsAgeing', _source, 0)
    end
    if animalType == 'chickens' then
        TriggerClientEvent('bcc-ranch:ChickensAgeing', _source, 0)
    end
    if animalType == 'goats' then
        TriggerClientEvent('bcc-ranch:GoatsAgeing', _source, 0)
    end
    if animalType == 'pigs' then
        TriggerClientEvent('bcc-ranch:PigsAgeing', _source, 0)
    end
end)

RegisterServerEvent('bcc-ranch:AgeIncrease', function(animalType, ranchid)
    if animalType == 'cows' then
        local param = { ['ranchid'] = ranchid, ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseAmount }
        exports.oxmysql:execute("UPDATE ranch SET `cows_age`=cows_age+@increaseamount WHERE ranchid=@ranchid", param)
    elseif animalType == 'chickens' then
        local param = { ['ranchid'] = ranchid, ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseAmount }
        exports.oxmysql:execute("UPDATE ranch SET `chickens_age`=chickens_age+@increaseamount WHERE ranchid=@ranchid",
            param)
    elseif animalType == 'goats' then
        local param = { ['ranchid'] = ranchid, ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseAmount }
        exports.oxmysql:execute("UPDATE ranch SET `goats_age`=goats_age+@increaseamount WHERE ranchid=@ranchid", param)
    elseif animalType == 'pigs' then
        local param = { ['ranchid'] = ranchid, ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseAmount }
        exports.oxmysql:execute("UPDATE ranch SET `pigs_age`=pigs_age+@increaseamount WHERE ranchid=@ranchid", param)
    end
end)

------ Coop Setup -----
RegisterServerEvent('bcc-ranch:CoopDBStorage', function(ranchId, coopCoords) --storing coop to db
    local param = { ['ranchid'] = ranchId, ['coopcoords'] = json.encode(coopCoords) }
    exports.oxmysql:execute("UPDATE ranch SET `chicken_coop`='true', `chicken_coop_coords`=@coopcoords WHERE ranchid=@ranchid", param)
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
        coopCooldowns[shopid] = os.time() --Store the current time
        TriggerClientEvent('bcc-ranch:ChickenCoopHarvest', _source)    --Robbery is not on cooldown
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
      VORPcore.NotifyRightTip(_source, _U("HarvestedTooSoon"), 4000)
    end
  else
        cowMilkingCooldowns[shopid] = os.time() --Store the current time
        TriggerClientEvent('bcc-ranch:MilkCows', _source)    --Robbery is not on cooldown
  end
end)

----- Version Check ----
BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-ranch')
