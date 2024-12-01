AllPlayersTable = {}

RegisterServerEvent("bcc-ranch:AdminCheck", function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    if character.group == "admin" then
        TriggerClientEvent("bcc-ranch:IsAdminClientReceiver", _source, true)
    end
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
    if Config.ranchSetup.ranchConditionDecreaseInterval <= 0 then
        devPrint("Ranch condition decrease interval is not set or invalid. Exiting thread.")
        return
    end

    while true do
        -- Wait for the configured interval
        Wait(Config.ranchSetup.ranchConditionDecreaseInterval)

        -- Fetch all ranches with relevant fields
        local allRanches = MySQL.query.await("SELECT ranchid, ranchCondition FROM ranch")
        if not allRanches or #allRanches == 0 then
            devPrint("No ranches found. Retrying in 15 seconds.")
            Wait(15000)
        else
            for _, ranch in pairs(allRanches) do
                local currentCondition = tonumber(ranch.ranchCondition)
                if currentCondition > 0 then
                    -- Decrease ranch condition in the database
                    MySQL.update.await(
                        "UPDATE ranch SET ranchCondition = ranchCondition - ? WHERE ranchid = ?",
                        { Config.ranchSetup.ranchConditionDecreaseAmount, ranch.ranchid }
                    )
                    devPrint("RanchID: " ..
                    ranch.ranchid .. " condition decreased by " .. Config.ranchSetup.ranchConditionDecreaseAmount)

                    -- Update online ranchers if they exist
                    local onlineRanchers = RanchersOnline[ranch.ranchid]
                    if onlineRanchers and #onlineRanchers > 0 then
                        devPrint("Updating online ranchers for RanchID: " .. ranch.ranchid)
                        UpdateAllRanchersRanchData(ranch.ranchid)
                    end
                else
                    devPrint("RanchID: " .. ranch.ranchid .. " already has a condition of 0. Skipping.")
                end
            end
        end
    end
end)

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-ranch')