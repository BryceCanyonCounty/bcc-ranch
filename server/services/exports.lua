---@param charIdentifier integer
exports('CheckIfRanchIsOwned', function(charIdentifier) --credit to the whole bcc dev team for help with this
    local result = MySQL.query.await("SELECT * FROM bcc_ranch WHERE charidentifier = ?", { charIdentifier })
    if #result > 0 then
        return true
    else
        return false
    end
end)

---@param charIdentifier integer
---@param amount integer
---@return boolean
exports('IncreaseRanchCondition', function(charIdentifier, amount)
    local result = MySQL.query.await("SELECT * FROM bcc_ranch WHERE charidentifier = ?", { charIdentifier })
    if #result > 0 then
        local ranchId = result[1].ranchid
        MySQL.update.await('UPDATE bcc_ranch SET ranchCondition = ranchCondition + ? WHERE charidentifier = ?', { amount, charIdentifier })
        UpdateAllRanchersRanchData(ranchId)
    else
        return false
    end
end)

---@param charIdentifier integer
---@param amount integer
exports('DecreaseRanchCondition', function(charIdentifier, amount)
    local result = MySQL.query.await("SELECT * FROM bcc_ranch WHERE charidentifier = ?", { charIdentifier })
    if #result > 0 then
        local ranchId = result[1].ranchid
        MySQL.update.await('UPDATE bcc_ranch SET ranchCondition = ranchCondition - ? WHERE charidentifier = ?', { amount, charIdentifier})
        UpdateAllRanchersRanchData(ranchId)
    else
        return false
    end
end)

---@param charidentifier integer
exports('DoesPlayerWorkAtRanch', function(charidentifier)
    local result = MySQL.query.await("SELECT ranchid FROM characters WHERE charidentifier = ?", { charidentifier })
    if #result > 0 then
        return true
    else
        return false
    end
end)