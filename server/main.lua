BccUtils.RPC:Register("bcc-ranch:AdminCheck", function(params, cb, src)
    local user = VORPcore.getUser(src)
    if not user then return cb(false) end

    local character = user.getUsedCharacter
    if not character then return cb(false) end

    local group = character.group
    local job = character.job

    -- Check admin group
    for _, g in ipairs(Config.RanchAdminGroup) do
        if group == g then
            return cb(true)
        end
    end

    -- Check allowed job (optional)
    for _, j in ipairs(Config.RanchAllowedJobs or {}) do
        if job == j then
            return cb(true)
        end
    end

    return cb(false)
end)

BccUtils.RPC:Register("bcc-ranch:GetPlayers", function(_, cb, source)
    devPrint("[GetPlayers] RPC called by source:", source)

    local AllPlayersTable = {}
    local rawPlayers = GetPlayers()
    devPrint("[GetPlayers] Found " .. #rawPlayers .. " players online.")

    for _, playerId in ipairs(rawPlayers) do
        local name = GetPlayerName(playerId)
        local user = VORPcore.getUser(tonumber(playerId))

        if not user then
            devPrint(("[GetPlayers] Skipping playerId %s (no user found)"):format(playerId))
        else
            local character = user.getUsedCharacter
            if not character then
                devPrint(("[GetPlayers] Skipping playerId %s (no character found)"):format(playerId))
            else
                devPrint(("[GetPlayers] Found player: %s (%s %s, charId: %s)")
                    :format(name, character.firstname, character.lastname, character.charIdentifier))

                table.insert(AllPlayersTable, {
                    source = tonumber(playerId),
                    charId = character.charIdentifier,
                    firstname = character.firstname,
                    lastname = character.lastname,
                    name = name .. " | ID: " .. character.charIdentifier .. " | " .. character.firstname .. " " .. character.lastname
                })
            end
        end
    end

    devPrint("[GetPlayers] Returning " .. #AllPlayersTable .. " valid players to client.")
    cb(AllPlayersTable)
end)

CreateThread(function()
    -- Ensure a valid interval is set
    if ConfigRanch.ranchSetup.ranchConditionDecreaseInterval <= 0 then
        devPrint("Ranch condition decrease interval is not set or invalid. Exiting thread.")
        return
    end

    while true do
        -- Wait for the configured interval
        Wait(ConfigRanch.ranchSetup.ranchConditionDecreaseInterval)

        -- Fetch all ranches with relevant fields
        local allRanches = MySQL.query.await("SELECT ranchid, ranchCondition FROM bcc_ranch")
        if not allRanches or #allRanches == 0 then
            devPrint("No ranches found. Retrying in 15 seconds.")
            Wait(15000)
        else
            for _, ranch in pairs(allRanches) do
                local currentCondition = tonumber(ranch.ranchCondition)
                if currentCondition > 0 then
                    -- Decrease ranch condition in the database
                    MySQL.update.await("UPDATE bcc_ranch SET ranchCondition = ranchCondition - ? WHERE ranchid = ?", { ConfigRanch.ranchSetup.ranchConditionDecreaseAmount, ranch.ranchid })
                    devPrint("RanchID: " .. ranch.ranchid .. " condition decreased by " .. ConfigRanch.ranchSetup.ranchConditionDecreaseAmount)

                    -- Update online ranchers if they exist
                    local onlineRanchers = RanchersOnline[ranch.ranchid]
                    if onlineRanchers and #onlineRanchers > 0 then
                        devPrint("Updating online ranchers for RanchID: " .. ranch.ranchid)
                        UpdateAllRanchersRanchData(ranch.ranchid)
                    end
                else
                    --devPrint("RanchID: " .. ranch.ranchid .. " already has a condition of 0. Skipping.")
                end
            end
        end
    end
end)

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-ranch')