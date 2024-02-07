CreateThread(function() --Tax handling
    local date = os.date("%d")
    local ranches = MySQL.query.await("SELECT * FROM ranch")
    if tonumber(date) == tonumber(Config.ranchSetup.taxDay) then --for some reason these have to be tonumbered
        if #ranches > 0 then
            for k, v in pairs(ranches) do
                if v.taxescollected == 'false' then
                    if tonumber(v.ledger) < tonumber(v.taxamount) then
                        exports.oxmysql:execute("UPDATE ranch SET charidentifier = 0 WHERE ranchid = ?", { v.ranchid })
                        v.charidentifier = 0
                    else
                        exports.oxmysql:execute("UPDATE ranch SET ledger = ledger - ?, taxescollected = 'true' WHERE ranchid = ?", { tonumber(v.taxamount), v.ranchid })
                        v.taxescollected = true
                    end
                end
            end
        end
    elseif tonumber(date) == tonumber(Config.ranchSetup.taxResetDay) then
        if #ranches > 0 then
            for k, v in pairs(ranches) do
                exports.oxmysql:execute("UPDATE ranch SET taxes_collected = 'false' WHERE ranchid = ?", { v.ranchid })
                v.taxes_collected = false
            end
        end
    end
end)