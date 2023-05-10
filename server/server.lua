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

---------------------- DB AREA ----------------------------------
-------- Creates DB ----------
CreateThread(function()
    exports.oxmysql:execute([[CREATE TABLE if NOT EXISTS `ranch` (
        `charidentifier` varchar(50) NOT NULL,
        `ranchcoords` LONGTEXT NOT NULL,
        `ranchname` varchar(100) NOT NULL,
        `ranch_radius_limit` varchar(100) NOT NULL,
        `ranchid` int NOT NULL AUTO_INCREMENT,
        `ranchCondition` int(10) NOT NULL DEFAULT 0,
        `cows` varchar(50) NOT NULL DEFAULT 'false',
        `cows_cond` int(10) NOT NULL DEFAULT 0,
        `pigs` varchar(50) NOT NULL DEFAULT 'false',
        `pigs_cond` int(10) NOT NULL DEFAULT 0,
        `chickens` varchar(50) NOT NULL DEFAULT 'false',
        `chickens_cond` int(10) NOT NULL DEFAULT 0,
        `goats` varchar(50) NOT NULL DEFAULT 'false',
        `goats_cond` int(10) NOT NULL DEFAULT 0,
        PRIMARY KEY `ranchid` (`ranchid`),
        UNIQUE KEY `charidentifier` (`charidentifier`))
    ]])
end)

------ Create Ranch Db Handler -----
RegisterServerEvent('bcc-ranch:InsertCreatedRanchIntoDB', function(ranchname, ranchradius, ownerstaticid, coords)
    local param = { ['ranchname'] = ranchname, ['ranch_radius_limit'] = ranchradius, ['charidentifier'] = ownerstaticid, ['ranchcoords'] = json.encode(coords) }
    exports.oxmysql:execute("INSERT INTO ranch ( `charidentifier`,`ranchcoords`,`ranchname`,`ranch_radius_limit` ) VALUES ( @charidentifier,@ranchcoords,@ranchname,@ranch_radius_limit )", param)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    VORPcore.NotifyRightTip(_source, Config.Language.RanchMade, 4000)
    BccUtils.Discord.sendMessage(Config.Webhooks.RanchCreation.WebhookLink, 'BCC Ranch', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', Config.Webhooks.RanchCreation.TitleText .. tostring(Character.charIdentifier), Config.Webhooks.RanchCreation.Text .. tostring(ownerstaticid))
end)

----------------------- Ranch Admin Menu Handlers ------------------------------
----- Delete Ranch From Db Hanlder -------------
RegisterServerEvent('bcc-ranch:DeleteRanchFromDB', function(ranchid)
    local param = { ['ranchid'] = ranchid }
    exports.oxmysql:execute("DELETE FROM ranch WHERE ranchid=@ranchid", param)
end)

-------- Change ranch radius handler ------
RegisterServerEvent('bcc-ranch:ChangeRanchRadius', function(ranchid, radius)
    local param = { ['ranchid'] = ranchid, ['radius'] = radius }
    exports.oxmysql:execute('UPDATE ranch SET `ranch_radius_limit`=@radius WHERE ranchid=@ranchid', param)
end)

------- Change ranch name handler ------
RegisterServerEvent('bcc-ranch:ChangeRanchname', function(ranchid, name)
    local param = { ['ranchid'] = ranchid, ['name'] = name }
    exports.oxmysql:execute('UPDATE ranch SET `ranchname`=@name WHERE ranchid=@ranchid', param)
end)

------------ Event Too Get All Ranches For Admin Menu -------------
RegisterServerEvent('bcc-ranch:GetAllRanches', function()
    local _source = source
    local result = MySQL.query.await("SELECT * FROM ranch")
    if #result > 0 then
        TriggerClientEvent('bcc-ranch:CatchAllRanches', _source, result)
    else
        VORPcore.NotifyRightTip(_source, Config.Language.NoRanches, 4000)
    end
end)

----- Checking If Character Owns a ranch -----
RegisterServerEvent('bcc-ranch:CheckIfRanchIsOwned', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = Character.charIdentifier }
    exports.oxmysql:execute("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param, function(result)
        if result[1] then
            VORPInv.registerInventory('Player_' .. result[1].ranchid .. '_bcc-ranchinv', Config.RanchSetup.InvName, Config.RanchSetup.InvLimit)
            TriggerClientEvent('bcc-ranch:HasRanchHandler', _source, result[1])
        end
    end)
end)

---- Event To Check for Ranchcondition For chores ----
RegisterServerEvent('bcc-ranch:ChoreCheckRanchCondition', function(ranchid, chore)
    local _source = source
    local param = { ['ranchid'] = ranchid }
    exports.oxmysql:execute("SELECT ranchCondition FROM ranch WHERE ranchid=@ranchid", param, function(result)
        if result[1].ranchCondition >= 100 then
            VORPcore.NotifyRightTip(_source, Config.Language.ConditionMax, 4000)
        else
            TriggerClientEvent('bcc-ranch:ShovelHay', _source, chore)
        end
    end)
end)

---- Event To Increase Ranch Condition Upon Chore Completion -----
RegisterServerEvent('bcc-ranch:RanchConditionIncrease', function(increaseamount, ranchid)
    local param = { ['ranchid'] = ranchid, ['ConditionIncrease'] = increaseamount }
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
RegisterServerEvent('bcc-ranch:BuyAnimals', function(ranchid, animaltype)
    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalBought.WebhookLink, 'BCC Ranch', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg')
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['ranchid'] = ranchid }
    if animaltype == 'cows' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Cows.Cost then
            exports.oxmysql:execute("SELECT cows FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].cows == 'false' then
                    exports.oxmysql:execute('UPDATE ranch SET `cows`="true" WHERE ranchid=@ranchid', param)
                    Character.removeCurrency(0, Config.RanchSetup.RanchAnimalSetup.Cows.Cost)
                    VORPcore.NotifyRightTip(_source, Config.Language.AnimalBought, 4000)
                    discord:sendMessage(Config.Webhooks.AnimalBought.TitleText .. tostring(ranchid), Config.Webhooks.AnimalBought.DescText .. Config.Webhooks.AnimalBought.Cows)
                else
                    VORPcore.NotifyRightTip(_source, Config.Language.AlreadyOwnAnimal, 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, Config.Language.Notenoughmoney, 4000)
        end
    elseif animaltype == 'pigs' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Pigs.Cost then
            exports.oxmysql:execute("SELECT pigs FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].pigs == 'false' then
                    exports.oxmysql:execute('UPDATE ranch SET `pigs`="true" WHERE ranchid=@ranchid', param)
                    Character.removeCurrency(0, Config.RanchSetup.RanchAnimalSetup.Pigs.Cost)
                    VORPcore.NotifyRightTip(_source, Config.Language.AnimalBought, 4000)
                    discord:sendMessage(Config.Webhooks.AnimalBought.TitleText .. tostring(ranchid), Config.Webhooks.AnimalBought.DescText .. Config.Webhooks.AnimalBought.Pigs)
                else
                    VORPcore.NotifyRightTip(_source, Config.Language.AlreadyOwnAnimal, 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, Config.Language.Notenoughmoney, 4000)
        end
    elseif animaltype == 'goats' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Goats.Cost then
            exports.oxmysql:execute("SELECT goats FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].goats == 'false' then
                    exports.oxmysql:execute('UPDATE ranch SET `goats`="true" WHERE ranchid=@ranchid', param)
                    Character.removeCurrency(0, Config.RanchSetup.RanchAnimalSetup.Goats.Cost)
                    VORPcore.NotifyRightTip(_source, Config.Language.AnimalBought, 4000)
                    discord:sendMessage(Config.Webhooks.AnimalBought.TitleText .. tostring(ranchid), Config.Webhooks.AnimalBought.DescText .. Config.Webhooks.AnimalBought.Goats)
                else
                    VORPcore.NotifyRightTip(_source, Config.Language.AlreadyOwnAnimal, 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, Config.Language.Notenoughmoney, 4000)
        end
    elseif animaltype == 'chickens' then
        if Character.money >= Config.RanchSetup.RanchAnimalSetup.Chickens.Cost then
            exports.oxmysql:execute("SELECT chickens FROM ranch WHERE ranchid=@ranchid", param, function(result)
                if result[1].chickens == 'false' then
                    exports.oxmysql:execute('UPDATE ranch SET `chickens`="true" WHERE ranchid=@ranchid', param)
                    Character.removeCurrency(0, Config.RanchSetup.RanchAnimalSetup.Chickens.Cost)
                    VORPcore.NotifyRightTip(_source, Config.Language.AnimalBought, 4000)
                    discord:sendMessage(Config.Webhooks.AnimalBought.TitleText .. tostring(ranchid), Config.Webhooks.AnimalBought.DescText .. Config.Webhooks.AnimalBought.Chickens)
                else
                    VORPcore.NotifyRightTip(_source, Config.Language.AlreadyOwnAnimal, 4000)
                end
            end)
        else
            VORPcore.NotifyRightTip(_source, Config.Language.Notenoughmoney, 4000)
        end
    end
end)

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
            VORPcore.NotifyRightTip(_source, Config.Language.AnimalNotOwned, 4000)
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
    Character.addCurrency(0, tonumber(payamount))
    local discord = BccUtils.Discord.setup(Config.Webhooks.AnimalSold.WebhookLink, 'BCC Oil', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg')

    if animaltype == 'cows' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Cows)
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false" WHERE ranchid=@ranchid', param)
        exports.oxmysql:execute('UPDATE ranch SET `cows_cond`=0 WHERE ranchid=@ranchid', param)
    elseif animaltype == 'chickens' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Chickens)
        exports.oxmysql:execute('UPDATE ranch SET `chickens`="false" WHERE ranchid=@ranchid', param)
        exports.oxmysql:execute('UPDATE ranch SET `chickens_cond`=0 WHERE ranchid=@ranchid', param)
    elseif animaltype == 'pigs' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Pigs)
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false" WHERE ranchid=@ranchid', param)
        exports.oxmysql:execute('UPDATE ranch SET `pigs_cond`=0 WHERE ranchid=@ranchid', param)
    elseif animaltype == 'goats' then
        discord:sendMessage(Config.Webhooks.AnimalSold.TitleText .. tostring(ranchid), Config.Webhooks.AnimalSold.Sold .. Config.Webhooks.AnimalSold.Goats)
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false" WHERE ranchid=@ranchid', param)
        exports.oxmysql:execute('UPDATE ranch SET `goats_cond`=0 WHERE ranchid=@ranchid', param)
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
        exports.oxmysql:execute('UPDATE ranch SET `cows`="false" WHERE ranchid=@ranchid', param)
    elseif animaltype == 'chickens' then
        exports.oxmysql:execute('UPDATE ranch SET `chickens`="false" WHERE ranchid=@ranchid', param)
    elseif animaltype == 'pigs' then
        exports.oxmysql:execute('UPDATE ranch SET `pigs`="false" WHERE ranchid=@ranchid', param)
    elseif animaltype == 'goats' then
        exports.oxmysql:execute('UPDATE ranch SET `goats`="false" WHERE ranchid=@ranchid', param)
    end

    for k, v in pairs(table.ButcherItems) do
        VORPInv.addItem(_source , v.name, v.count)
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

------------ Export Area ------------------
exports('CheckIfRanchIsOwned', function(charIdentifier) --credit to the whole bcc dev team for help with this
    local param = { ['charidentifier'] = charIdentifier }
    local result = MySQL.query.await("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param)
    if #result > 0 then
        return true
    else
        return false
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

            local Character = User.getUsedCharacter --get player info

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

----- Version Check ----
BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-ranch')