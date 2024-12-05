RegisterServerEvent('bcc-ranch:DeleteRanchFromDB', function(ranchId)
    MySQL.update("DELETE FROM bcc_ranch WHERE ranchid = ?", { ranchId })
end)

RegisterServerEvent('bcc-ranch:ChangeRanchCondAdminMenu', function(ranchId, cond)
    MySQL.update("UPDATE bcc_ranch SET ranchCondition = ? WHERE ranchid = ?", { cond, ranchId })
end)

RegisterServerEvent('bcc-ranch:ChangeRanchRadius', function(ranchId, radius)
    MySQL.update('UPDATE bcc_ranch SET ranch_radius_limit = ? WHERE ranchid = ?', { radius, ranchId })
end)

RegisterServerEvent('bcc-ranch:ChangeRanchname', function(ranchId, name)
    MySQL.update('UPDATE bcc_ranch SET ranchname = ? WHERE ranchid = ?', { name, ranchId })
end)

-- Registering the RPC on the server-side for fetching all ranches
BccUtils.RPC:Register("bcc-ranch:GetAllRanches", function(params, cb)
    local _source = source
    local success, result = pcall(MySQL.query.await, "SELECT * FROM ranch")

    if not success then
        print("^1[ERROR] Failed to fetch ranches: ^4" .. result)
        VORPcore.NotifyRightTip(_source, _U("DatabaseError"), 4000)
        return cb(false)  -- Indicate failure
    end

    if result and #result > 0 then
        -- Send the result back to the client using the callback
        cb(true, result)  -- Success: return bcc_ranch data
    else
        VORPcore.NotifyRightTip(_source, _U("NoRanches"), 4000)
        cb(false)  -- No data found
    end
end)
