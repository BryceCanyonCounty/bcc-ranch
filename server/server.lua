---------- Pulling Essentials -------------
VORPcore = {} --Pulls vorp core
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = exports['bcc-utils'].initiate()

------ Commands Admin Check --------
RegisterServerEvent('bcc-ranch:AdminCheck', function(nextevent, servevent)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    for k, v in pairs(Config.AdminSteamIds) do
        if Character.identifier == v.steamid then
            if servevent then
                TriggerEvent(nextevent)
            else
                TriggerClientEvent(nextevent, _source)
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

---------------------- DB AREA ----------------------------------

------ Create Ranch Db Handler -----
RegisterServerEvent('bcc-ranch:InsertCreatedRanchIntoDB', function(ranchname, ranchradius, ownerstaticid, coords)
    local _source = source

    local param = {
        ['ranchname'] = ranchname,
        ['ranch_radius_limit'] = ranchradius,
        ['charidentifier'] = ownerstaticid,
        ['ranchcoords'] = json.encode(coords)
    }
    exports.oxmysql:execute("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param, function(result)
        if not result[1] then
            exports.oxmysql:execute(
                "INSERT INTO ranch ( `charidentifier`,`ranchcoords`,`ranchname`,`ranch_radius_limit` ) VALUES ( @charidentifier,@ranchcoords,@ranchname,@ranch_radius_limit )",
                param)
            local _source = source
            local Character = VORPcore.getUser(_source).getUsedCharacter
            VORPcore.NotifyRightTip(_source, _U("RanchMade"), 4000)
            BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch',
                'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg',
                Config.Webhooks.RanchCreation.TitleText .. tostring(Character.charIdentifier),
                Config.Webhooks.RanchCreation.Text .. tostring(ownerstaticid))
        else
            VORPcore.NotifyRightTip(_source, _U("AlreadyOwnRanch"), 4000)
        end
    end)
end)


RegisterServerEvent('bcc-ranch:CheckisOwner', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local result = exports['bcc-ranch']:CheckIfRanchIsOwned(Character.charIdentifier)
    TriggerClientEvent('bcc-ranch:IsOwned', _source, result)
end)


RegisterServerEvent('bcc-ranch:GetLedger', function(ranchid)
    local _source = source
    local param = { ['ranchid'] = ranchid }

    exports.oxmysql:execute("SELECT ledger FROM ranch WHERE ranchid=@ranchid", param, function(result)
        local ledger = result[1].ledger
        TriggerClientEvent('bcc-ranch:LedgerMenu', _source, ledger)
    end)
end)

RegisterServerEvent('bcc-ranch:AffectLedger', function(ranchid, type, amount)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchid, ['amount'] = amount }
    local ledger
    exports.oxmysql:execute("SELECT ledger FROM ranch WHERE ranchid=@ranchid", param, function(result)
        ledger = result[1].ledger
        if type == 'withdraw' then
            exports.oxmysql:execute("UPDATE ranch SET ledger= ledger-@amount WHERE ranchid=@ranchid", param)
            Character.addCurrency(0, amount)
            VORPcore.NotifyRightTip(_source, _U("TookLedger") .. amount .. _U("FromtheLedger"), 4000)
        else
            exports.oxmysql:execute("UPDATE ranch SET ledger= ledger+@amount WHERE ranchid=@ranchid", param)
            Character.removeCurrency(0, amount)
            VORPcore.NotifyRightTip(_source, _U("PutLedger") .. amount .. _U("IntheLedger"), 4000)
        end
    end)
end)


----- Checking If Character Owns a ranch -----
RegisterServerEvent('bcc-ranch:CheckIfRanchIsOwned', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = Character.charIdentifier }
    exports.oxmysql:execute("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param, function(result)
        if result[1] then
            VORPInv.registerInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv', Config.RanchSetup.InvName,
                Config.RanchSetup.InvLimit)
            TriggerClientEvent('bcc-ranch:HasRanchHandler', _source, result[1])
        end
    end)
end)

RegisterServerEvent('bcc-ranch:CheckIfInRanch', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = Character.charIdentifier }
    exports.oxmysql:execute("SELECT ranchid FROM characters WHERE charidentifier=@charidentifier", param,
        function(result)
            if result[1].ranchid ~= nil and 0 then
                local ranchid = result[1].ranchid
                print(result[1].ranchid, ranchid)
                exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid = ranchid", param,
                    function(result)
                        if result[1].ranchid == ranchid then
                            TriggerClientEvent('bcc-ranch:HasRanchHandler', _source, result[1])
                        end
                    end)
            end
        end)
end)

RegisterServerEvent('bcc-ranch:HireEmployee', function(ranchId, charid)
    local _source = charid
    local param = {
        ['charidentifier'] = charid,
        ['ranchid'] = ranchId,

    }
    exports.oxmysql:execute(
        'UPDATE characters SET ranchid=@ranchid WHERE charidentifier=@charidentifier', param)
    BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch',
        'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg',
        Config.Webhooks.RanchCreation.TitleText .. tostring(charid),
        Config.Webhooks.RanchCreation.Text .. tostring(charid))
end)

RegisterServerEvent('bcc-ranch:FireEmployee', function(charid)
    local _source = charid
    local param = {
        ['charidentifier'] = charid,

    }
    exports.oxmysql:execute(
        'UPDATE characters SET ranchid=0 WHERE charidentifier=@charidentifier', param)
    BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch',
        'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg',
        Config.Webhooks.RanchCreation.TitleText .. tostring(charid),
        Config.Webhooks.RanchCreation.Text .. tostring(charid))
end)

RegisterServerEvent("bcc-ranch:GetEmployeeList")
AddEventHandler("bcc-ranch:GetEmployeeList", function(ranchid)
    print('testing')
    local _source = source
    exports.ghmattimysql:execute("SELECT firstname, lastname, charidentifier FROM characters WHERE ranchid = @ranchid",
        { ["ranchid"] = ranchid },
        function(result)
            TriggerClientEvent('bcc-ranch:ViewEmployeeMenu', _source, result)
        end)
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
RegisterServerEvent('bcc-ranch:RanchConditionIncrease', function(increaseamount, ranchid)
    local param = { ['ranchid'] = ranchid, ['ConditionIncrease'] = increaseamount }
    exports.oxmysql:execute("UPDATE ranch SET `ranchCondition`=ranchCondition+@ConditionIncrease WHERE ranchid=@ranchid",
        param)
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
RegisterServerEvent('bcc-ranch:BuyAnimals', function(ranchid, animaltype)
    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalBought.WebhookLink, 'BCC Ranch',
        'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg')
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchid }
    if animaltype == 'cows' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Cows.Cost then
            exports.oxmysql:execute("SELECT cows FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].cows == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'cows', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `cows`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Cows.Cost,
                        Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                        Config.Webhooks.AnimalBought.Cows, _source, ranchid, discord, Character)
                else
                    VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
        end
    elseif animaltype == 'pigs' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Pigs.Cost then
            exports.oxmysql:execute("SELECT pigs FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].pigs == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'pigs', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `pigs`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Pigs.Cost,
                        Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                        Config.Webhooks.AnimalBought.Pigs, _source, ranchid, discord, Character)
                else
                    VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
        end
    elseif animaltype == 'goats' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Goats.Cost then
            exports.oxmysql:execute("SELECT goats FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].goats == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'goats', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `goats`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Goats.Cost,
                        Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                        Config.Webhooks.AnimalBought.Goats, _source, ranchid, discord, Character)
                else
                    VORPcore.NotifyRightTip(_source, _U("AlreadyOwnAnimal"), 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, _U("Notenoughmoney"), 4000)
        end
    elseif animaltype == 'chickens' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Chickens.Cost then
            exports.oxmysql:execute("SELECT chickens FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].chickens == 'false' then
                    TriggerEvent('bcc-ranch:IndAnimalAgeStart', 'chickens', _source)
                    exports.oxmysql:execute('UPDATE ranch SET `chickens`="true" WHERE ranchid=@ranchid', param)
                    AnimalBoughtHandle(Config.RanchSetup.RanchAnimalSetup.Chickens.Cost,
                        Config.Webhooks.AnimalBought.TitleText, Config.Webhooks.AnimalBought.DescText,
                        Config.Webhooks.AnimalBought.Chickens, _source, ranchid, discord, Character)
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
function AnimalBoughtHandle(cost, webhooktitle, webhookdesc, animalwebhookname, _source, ranchid, discord, character)
    character.removeCurrency(0, cost)
    VORPcore.NotifyRightTip(_source, _U("AnimalBought"), 4000)
    discord:sendMessage(webhooktitle .. tostring(ranchid), webhookdesc .. animalwebhookname)
end

---- Event To Check If Animals Are Owned ----
RegisterServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', function(ranchid, animaltype)
    local param = { ['ranchid'] = ranchid }
    local eventtriggger = false
    local _source = source
    local animal_condition, ranchcond
    exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid=@ranchid", param, function(result)
        ranchcond = result[1].ranchCondition
        if result[1].cows ~= 'false' and animaltype == 'cows' then
            eventtriggger = true
            animal_condition = result[1].cows_cond
        elseif result[1].pigs ~= 'false' and animaltype == 'pigs' then
            eventtriggger = true
            animal_condition = result[1].pigs_cond
        elseif result[1].chickens ~= 'false' and animaltype == 'chickens' then
            eventtriggger = true
            animal_condition = result[1].chickens_cond
        elseif result[1].goats ~= 'false' and animaltype == 'goats' then
            eventtriggger = true
            animal_condition = result[1].goats_cond
        else
            VORPcore.NotifyRightTip(_source, _U("AnimalNotOwned"), 4000)
        end

        if eventtriggger then
            TriggerClientEvent('bcc-ranch:OwnedAnimalManagerMenu', _source, animal_condition, animaltype, ranchcond)
        end
    end)
end)

----- Event that will pay player and delete thier animals from db upon sell ------
RegisterServerEvent('bcc-ranch:AnimalsSoldHandler', function(payamount, animaltype, ranchid)
    local param = { ['ranchid'] = ranchid }
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local ledger
    exports.oxmysql:execute("SELECT * FROM ranch WHERE ranchid=@ranchid", param, function(result)
        ledger = result[1].ledger
        exports.ghmattimysql:execute("UPDATE ranch SET ledger=@1 WHERE ranchid=@id",
            {
                ["@id"] = ranchid,
                ["@1"] = ledger + tonumber(payamount)
            })
    end)

    Character.addCurrency(0, tonumber(payamount))
    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalSold.WebhookLink, 'BCC Ranch',
        'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg')

    if animaltype == 'cows' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
            Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Cows)
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid',
            param)
    elseif animaltype == 'chickens' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
            Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Chickens)
        exports.oxmysql:execute(
            'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
    elseif animaltype == 'pigs' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
            Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Pigs)
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid',
            param)
    elseif animaltype == 'goats' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid),
            Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Goats)
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid',
            param)
    end
end)

------ Raises animal cond upon herd success ------------
RegisterServerEvent('bcc-ranch:AnimalCondIncrease', function(animaltype, amountoinc, ranchid)
    local param = { ['ranchid'] = ranchid, ['levelinc'] = amountoinc }

    if animaltype == 'cows' then
        exports.oxmysql:execute('UPDATE ranch SET `cows_cond`=cows_cond+@levelinc WHERE ranchid=@ranchid', param)
    elseif animaltype == 'chickens' then
        exports.oxmysql:execute('UPDATE ranch SET `chickens_cond`=chickens_cond+@levelinc WHERE ranchid=@ranchid', param)
    elseif animaltype == 'pigs' then
        exports.oxmysql:execute('UPDATE ranch SET `pigs_cond`=pigs_cond+@levelinc WHERE ranchid=@ranchid', param)
    elseif animaltype == 'goats' then
        exports.oxmysql:execute('UPDATE ranch SET `goats_cond`=goats_cond+@levelinc WHERE ranchid=@ranchid', param)
    end
end)

-------- Remove Animals from db after butcher -------
RegisterServerEvent('bcc-ranch:ButcherAnimalHandler', function(animaltype, ranchid, table)
    local param = { ['ranchid'] = ranchid }
    local _source = source

    if animaltype == 'cows' then
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid',
            param)
    elseif animaltype == 'chickens' then
        exports.oxmysql:execute(
            'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
    elseif animaltype == 'pigs' then
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid',
            param)
    elseif animaltype == 'goats' then
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid',
            param)
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
            exports.oxmysql:execute('UPDATE ranch SET `ranchCondition`=ranchCondition-@levelinc WHERE ranchid=@ranchid',
                param)
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
RegisterServerEvent('bcc-ranch:RemoveAnimalFromDB', function(ranchid, animaltype)
    local param = { ['ranchid'] = ranchid }

    if animaltype == 'cows' then
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false", `cows_cond`=0, `cows_age`=0 WHERE ranchid=@ranchid',
            param)
    elseif animaltype == 'chickens' then
        exports.oxmysql:execute(
            'UPDATE ranch SET `chickens`="false", `chickens_cond`=0, `chickens_age`=0 WHERE ranchid=@ranchid', param)
    elseif animaltype == 'pigs' then
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false", `pigs_cond`=0, `pigs_age`=0 WHERE ranchid=@ranchid',
            param)
    elseif animaltype == 'goats' then
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false", `goats_cond`=0, `goats_age`=0 WHERE ranchid=@ranchid',
            param)
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

AddEventHandler('bcc-ranch:IndAnimalAgeStart', function(animaltype, _source)
    if animaltype == 'cows' then
        TriggerClientEvent('bcc-ranch:CowsAgeing', _source, 0)
    end
    if animaltype == 'chickens' then
        TriggerClientEvent('bcc-ranch:ChickensAgeing', _source, 0)
    end
    if animaltype == 'goats' then
        TriggerClientEvent('bcc-ranch:GoatsAgeing', _source, 0)
    end
    if animaltype == 'pigs' then
        TriggerClientEvent('bcc-ranch:PigsAgeing', _source, 0)
    end
end)

RegisterServerEvent('bcc-ranch:AgeIncrease', function(animaltype, ranchid)
    if animaltype == 'cows' then
        local param = {
            ['ranchid'] = ranchid,
            ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseAmount
        }
        exports.oxmysql:execute("UPDATE ranch SET `cows_age`=cows_age+@increaseamount WHERE ranchid=@ranchid", param)
    elseif animaltype == 'chickens' then
        local param = {
            ['ranchid'] = ranchid,
            ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseAmount
        }
        exports.oxmysql:execute("UPDATE ranch SET `chickens_age`=chickens_age+@increaseamount WHERE ranchid=@ranchid",
            param)
    elseif animaltype == 'goats' then
        local param = {
            ['ranchid'] = ranchid,
            ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseAmount
        }
        exports.oxmysql:execute("UPDATE ranch SET `goats_age`=goats_age+@increaseamount WHERE ranchid=@ranchid", param)
    elseif animaltype == 'pigs' then
        local param = {
            ['ranchid'] = ranchid,
            ['increaseamount'] = Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseAmount
        }
        exports.oxmysql:execute("UPDATE ranch SET `pigs_age`=pigs_age+@increaseamount WHERE ranchid=@ranchid", param)
    end
end)

----- Version Check ----
BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-ranch')
