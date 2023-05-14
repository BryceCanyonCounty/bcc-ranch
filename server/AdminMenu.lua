----------------------- Ranch Admin Menu Handlers ------------------------------
----- Delete Ranch From Db Hanlder -------------
RegisterServerEvent('bcc-ranch:DeleteRanchFromDB', function(ranchid)
    local param = { ['ranchid'] = ranchid }
    exports.oxmysql:execute("DELETE FROM ranch WHERE ranchid=@ranchid", param)
end)

------ Change Ranch Condition --------
RegisterServerEvent('bcc-ranch:ChangeRanchCondAdminMenu', function(ranchid, cond)
    local param = { ['ranchid'] = ranchid, ['ranchcond'] = cond }
    exports.oxmysql:execute("UPDATE ranch SET `ranchCondition`=@ranchcond WHERE ranchid=@ranchid", param)
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
        VORPcore.NotifyRightTip(_source, _U("NoRanches"), 4000)
    end
end)