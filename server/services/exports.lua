------------ Export Area ------------------
-- Check If player owns ranch exports
exports('CheckIfRanchIsOwned', function(charIdentifier) --credit to the whole bcc dev team for help with this
    local param = { ['charidentifier'] = charIdentifier }
    local result = MySQL.query.await("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param)
    if #result > 0 then
        return true
    else
        return false
    end
end)

--Increase Ranch Condition Export
exports('IncreaseRanchCondition', function(charIdentifier, amount)
    local param = { ['charidentifier'] = charIdentifier, ['amount'] = amount }
    local result = MySQL.query.await("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param)
    if #result > 0 then
        local ranchId = result[1].ranchid
        MySQL.query.await('UPDATE ranch SET `ranchCondition`=ranchCondition+@amount WHERE charidentifier=@charidentifier', param)
        UpdateAllRanchersRanchData(ranchId)
    else
        return false
    end
end)

--Decrease Ranch Condition Export
exports('DecreaseRanchCondition', function(charIdentifier, amount)
    local param = { ['charidentifier'] = charIdentifier, ['amount'] = amount }
    local result = MySQL.query.await("SELECT * FROM ranch WHERE charidentifier=@charidentifier", param)
    if #result > 0 then
        local ranchId = result[1].ranchid
        MySQL.query.await('UPDATE ranch SET `ranchCondition`=ranchCondition-@amount WHERE charidentifier=@charidentifier', param)
        UpdateAllRanchersRanchData(ranchId)
    else
        return false
    end
end)

--Check if player works at a ranch
exports('DoesPlayerWorkAtRanch', function(charidentifier)
    local param = { ['charid'] = charidentifier }
    local result = MySQL.query.await("SELECT ranchid FROM characters WHERE charidentifier=@charid", param)
    if #result > 0 then
        return true
    else
        return false
    end
end)