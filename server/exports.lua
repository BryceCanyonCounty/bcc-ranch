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
    exports.oxmysql:execute('UPDATE ranch SET `ranchCondition`=ranchCondition+@amount WHERE charidentifier=@charidentifier', param)
end)

--Decrease Ranch Condition Export
exports('DecreaseRanchCondition', function(charIdentifier, amount)
    local param = { ['charidentifier'] = charIdentifier, ['amount'] = amount }
    exports.oxmysql:execute('UPDATE ranch SET `ranchCondition`=ranchCondition-@amount WHERE charidentifier=@charidentifier', param)
end)