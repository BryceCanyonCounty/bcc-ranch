CreateThread(function() --Tax handling
    local date = os.date("%d")
    local ranches = MySQL.query.await("SELECT * FROM ranch")
    if tonumber(date) == tonumber(Config.ranchSetup.taxDay) then --for some reason these have to be tonumbered
        if #ranches > 0 then
            for k, v in pairs(ranches) do
                local param = { ['ranchid'] = v.ranchid, ['taxamount'] = tonumber(v.taxamount) }
                if v.taxescollected == 'false' then
                    if tonumber(v.ledger) < tonumber(v.taxamount) then
                        exports.oxmysql:execute("UPDATE ranch SET charidentifier=0 WHERE ranchid=@ranchid", param)
                        v.charidentifier = 0
                        --taxes failed remove ranch
                    else
                        exports.oxmysql:execute("UPDATE ranch SET ledger=ledger-@taxamount, taxescollected='true' WHERE ranchid=@ranchid", param)
                        v.taxescollected = true
                        --taxes paid
                    end
                end
            end
        end
    elseif tonumber(date) == tonumber(Config.ranchSetup.taxResetDay) then
        if #ranches > 0 then
            for k, v in pairs(ranches) do
                local param = { ['ranchid'] = v.ranchid }
                exports.oxmysql:execute("UPDATE ranch SET taxes_collected='false' WHERE ranchid=@ranchid", param)
                v.taxes_collected = false
            end
        end
    end
end)