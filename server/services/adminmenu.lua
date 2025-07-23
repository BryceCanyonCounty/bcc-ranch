BccUtils.RPC:Register('bcc-ranch:DeleteRanchFromDB', function(data, cb, src)
    local ranchId = tonumber(data.ranchId)
    if not ranchId then
        NotifyClient(src, _U("invalidRanchId"), "error", 4000)
        return cb(false)
    end

    local existingRanch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if not existingRanch or #existingRanch == 0 then
        NotifyClient(src, _U("ranchNotFound"), "error", 4000)
        return cb(false)
    end

    local ranch = existingRanch[1]
    local ranchName = ranch.ranchname or "Unknown"
    local ownerId = ranch.charidentifier or "Unknown"

    -- Fetch ranch owner info
    local ownerResult = MySQL.query.await('SELECT firstname, lastname FROM characters WHERE charidentifier = ?', { ownerId })
    local ownerChar = ownerResult and ownerResult[1] or { firstname = "Unknown", lastname = "Unknown" }

    -- Fetch executor info (who deleted it)
    local executor = VORPcore.getUser(src).getUsedCharacter
    local executorName = executor.firstname .. " " .. executor.lastname
    local executorId = executor.charIdentifier

    devPrint("[DeleteRanch] Deleting ranch ID " .. ranchId .. " (" .. ranchName .. ") owned by " .. ownerChar.firstname .. " " .. ownerChar.lastname .. ", deleted by " .. executorName .. " [" .. executorId .. "]")

    -- Cleanup
    MySQL.update.await("DELETE FROM bcc_ranch_employees WHERE ranch_id = ?", { ranchId })
    local affected = MySQL.update.await("DELETE FROM bcc_ranch WHERE ranchid = ?", { ranchId })

    if affected and affected > 0 then
        MySQL.update.await("UPDATE characters SET ranchid = NULL WHERE ranchid = ?", { ranchId })

        TriggerClientEvent("bcc-ranch:PlayerOwnsARanch", src, nil, false)
        TriggerClientEvent("bcc-ranch:PlayerIsAEmployee", src, nil, false)
        UpdateAllRanchersRanchData(ranchId)

        NotifyClient(src, _U("ranchDeleted"), "success", 4000)

        -- Send webhook
        BccUtils.Discord.sendMessage(Config.Webhook,
            Config.WebhookTitle,
            Config.WebhookAvatar,
            "🗑️ Ranch Deleted",
            nil,
            {
                {
                    color = 15158332, -- Red
                    title = "🚫 Ranch Deleted",
                    description = table.concat({
                        "**Ranch Name:** `" .. ranchName .. "`",
                        "**Ranch ID:** `" .. ranchId .. "`",
                        "**Owner ID:** `" .. ownerId .. "`",
                        "**Owner Name:** `" .. ownerChar.firstname .. " " .. ownerChar.lastname .. "`",
                        "**Deleted By:** `" .. executorName .. "` (`" .. executorId .. "`)"
                    }, "\n")
                }
            }
        )

        return cb(true)
    else
        devPrint("[DeleteRanch] Failed to delete ranch ID " .. ranchId)
        NotifyClient(src, _U("deletionFailed"), "error", 4000)
        return cb(false)
    end
end)

-- RPC to change ranch condition
BccUtils.RPC:Register("bcc-ranch:ChangeRanchCondAdminMenu", function(data, cb, src)
    local ranchId = tonumber(data.ranchId)
    local cond = tonumber(data.cond)
    if not ranchId or not cond then return cb(false) end

    local affected = MySQL.update.await("UPDATE bcc_ranch SET ranchCondition = ? WHERE ranchid = ?", { cond, ranchId })
    if affected > 0 then
        local executor = VORPcore.getUser(src).getUsedCharacter
        local executorName = executor.firstname .. " " .. executor.lastname
        local executorId = executor.charIdentifier

        BccUtils.Discord.sendMessage(Config.Webhook,
            Config.WebhookTitle,
            Config.WebhookAvatar,
            "🛠️ Ranch Condition Updated",
            nil,
            {{
                color = 3447003,
                title = "📦 Condition Modified",
                description = table.concat({
                    "**Ranch ID:** `" .. ranchId .. "`",
                    "**New Condition:** `" .. cond .. "`",
                    "**Modified By:** `" .. executorName .. "` (`" .. executorId .. "`)"
                }, "\n")
            }}
        )

        cb(true)
    else
        cb(false)
    end
end)

-- RPC to change ranch radius
BccUtils.RPC:Register("bcc-ranch:ChangeRanchRadius", function(data, cb, src)
    local ranchId = tonumber(data.ranchId)
    local radius = tostring(data.radius)
    if not ranchId or not radius then return cb(false) end

    local affected = MySQL.update.await("UPDATE bcc_ranch SET ranch_radius_limit = ? WHERE ranchid = ?", { radius, ranchId })
    if affected > 0 then
        local executor = VORPcore.getUser(src).getUsedCharacter
        local executorName = executor.firstname .. " " .. executor.lastname
        local executorId = executor.charIdentifier

        BccUtils.Discord.sendMessage(Config.Webhook,
            Config.WebhookTitle,
            Config.WebhookAvatar,
            "📏 Ranch Radius Changed",
            nil,
            {{
                color = 10197915,
                title = "📐 Radius Modified",
                description = table.concat({
                    "**Ranch ID:** `" .. ranchId .. "`",
                    "**New Radius Limit:** `" .. radius .. "`",
                    "**Modified By:** `" .. executorName .. "` (`" .. executorId .. "`)"
                }, "\n")
            }}
        )

        cb(true)
    else
        cb(false)
    end
end)

-- RPC to change ranch name
BccUtils.RPC:Register("bcc-ranch:ChangeRanchname", function(data, cb, src)
    local ranchId = tonumber(data.ranchId)
    local name = tostring(data.name)
    if not ranchId or not name or name == "" then return cb(false) end

    local affected = MySQL.update.await("UPDATE bcc_ranch SET ranchname = ? WHERE ranchid = ?", { name, ranchId })
    if affected > 0 then
        local executor = VORPcore.getUser(src).getUsedCharacter
        local executorName = executor.firstname .. " " .. executor.lastname
        local executorId = executor.charIdentifier

        BccUtils.Discord.sendMessage(Config.Webhook,
            Config.WebhookTitle,
            Config.WebhookAvatar,
            "🏷️ Ranch Name Changed",
            nil,
            {{
                color = 15844367,
                title = "📝 Name Modified",
                description = table.concat({
                    "**Ranch ID:** `" .. ranchId .. "`",
                    "**New Ranch Name:** `" .. name .. "`",
                    "**Modified By:** `" .. executorName .. "` (`" .. executorId .. "`)"
                }, "\n")
            }}
        )

        cb(true)
    else
        cb(false)
    end
end)

BccUtils.RPC:Register("bcc-ranch:GetAllRanches", function(params, cb, src)
    devPrint("[bcc-ranch:GetAllRanches] RPC called by source: " .. tostring(src))

    local result = MySQL.query.await([[
        SELECT r.*, c.firstname, c.lastname
        FROM bcc_ranch r
        LEFT JOIN characters c ON CAST(r.charidentifier AS UNSIGNED) = c.charidentifier
    ]])

    if result and #result > 0 then
        devPrint("[bcc-ranch:GetAllRanches] Successfully fetched " .. #result .. " ranches")
        cb(true, result)
    else
        devPrint("[bcc-ranch:GetAllRanches] No ranch data found.")
        NotifyClient(src, _U("NoRanches"), "error", 4000)
        cb(false)
    end
end)

