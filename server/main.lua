AllPlayersTable = {}

BccUtils.RPC:Register("bcc-ranch:AdminCheck", function(params, cb, recSource)
    local user = VORPcore.getUser(recSource)
    local character = user.getUsedCharacter
    if not character then
        return cb(false)
    end
    if character.group == Config.adminGroup then
        return cb(true)
    end
    return cb(false)
end)

---@param source integer
RegisterServerEvent("bcc-ranch:StoreAllPlayers", function(source)
    local _source = source
    AllPlayersTable[#AllPlayersTable + 1] = _source -- add all players
end)

------------- Get Players Function Credit to vorp admin for this ------------------
RegisterServerEvent('bcc-ranch:GetPlayers')
AddEventHandler('bcc-ranch:GetPlayers', function()
    local _source = source
    local data = {}

    for _, player in ipairs(AllPlayersTable) do
        local User = VORPcore.getUser(player)
        if User then
            local Character = User.getUsedCharacter

            local playername = Character.firstname .. ' ' .. Character.lastname

            data[tostring(player)] = {
                serverId = player,
                PlayerName = playername,
                staticid = Character.charIdentifier,
            }
        end
    end
    TriggerClientEvent("bcc-ranch:SendPlayers", _source, data)
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
                    MySQL.update.await(
                        "UPDATE bcc_ranch SET ranchCondition = ranchCondition - ? WHERE ranchid = ?",
                        { ConfigRanch.ranchSetup.ranchConditionDecreaseAmount, ranch.ranchid }
                    )
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