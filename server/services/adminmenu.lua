---@param ranchId integer
RegisterServerEvent('bcc-ranch:DeleteRanchFromDB', function(ranchId)
    exports.oxmysql:execute("DELETE FROM ranch WHERE ranchid = ?", { ranchId })
end)

---@param ranchId integer
---@param cond integer
RegisterServerEvent('bcc-ranch:ChangeRanchCondAdminMenu', function(ranchId, cond)
    exports.oxmysql:execute("UPDATE ranch SET ranchCondition = ? WHERE ranchid = ?", { cond, ranchId })
end)

---@param ranchId integer
---@param radius integer
RegisterServerEvent('bcc-ranch:ChangeRanchRadius', function(ranchId, radius)
    exports.oxmysql:execute('UPDATE ranch SET ranch_radius_limit = ? WHERE ranchid = ?', { radius, ranchId })
end)

---@param ranchId integer
---@param name string
RegisterServerEvent('bcc-ranch:ChangeRanchname', function(ranchId, name)
    exports.oxmysql:execute('UPDATE ranch SET ranchname = ? WHERE ranchid = ?', { name, ranchId })
end)

RegisterServerEvent('bcc-ranch:GetAllRanches', function()
    local _source = source
    local result = MySQL.query.await("SELECT * FROM ranch")
    if #result > 0 then
        TriggerClientEvent('bcc-ranch:CatchAllRanches', _source, result)
    else
        VORPcore.NotifyRightTip(_source, _U("NoRanches"), 4000)
    end
end)