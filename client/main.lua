IsAdmin, RanchData, IsOwnerOfRanch, IsInMission = false, nil, false, false
local ranchBlip = nil

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    TriggerServerEvent('bcc-ranch:AdminCheck')
    local player = GetPlayerServerId(tonumber(PlayerId()))
    TriggerServerEvent("bcc-ranch:StoreAllPlayers", player)
    TriggerServerEvent('bcc-ranch:CheckIfPlayerOwnsARanch')
    TriggerServerEvent('bcc-ranch:CheckIfPlayerIsEmployee')
end)

RegisterCommand(Config.commands.devModeCommand, function()
    if Config.devMode then
        TriggerServerEvent('bcc-ranch:AdminCheck')
        local player = GetPlayerServerId(tonumber(PlayerId()))
        TriggerServerEvent("bcc-ranch:StoreAllPlayers", player)
        TriggerServerEvent('bcc-ranch:CheckIfPlayerOwnsARanch')
        TriggerServerEvent('bcc-ranch:CheckIfPlayerIsEmployee')
    end
end)

-- Handling Initial Ranch Startup
---@param ranchData table
---@param isOwnerOfRanch boolean
RegisterNetEvent("bcc-ranch:PlayerOwnsARanch", function(ranchData, isOwnerOfRanch)
    RanchData = ranchData
    if isOwnerOfRanch then
        IsOwnerOfRanch = true
    end

    -- Having to setup the coords to work, as they are encoded when recieved
    RanchData.ranchcoords = json.decode(RanchData.ranchcoords)
    RanchData.ranchcoordsVector3 = vector3(RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z)

    ranchBlip = BccUtils.Blip:SetBlip(RanchData.ranchname, Config.ranchSetup.ranchBlip, 0.2, RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z)

    local promptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = promptGroup:RegisterPrompt(_U("manage"), Config.ranchSetup.manageRanchKey, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    if Config.commands.manageMyRanchCommand then
        RegisterCommand(Config.commands.manageMyRanchCommandName, function()
            local dist = #(RanchData.ranchcoordsVector3 - GetEntityCoords(PlayerPedId()))
            if dist < 5 then
                if not IsInMission then
                    MainRanchMenu()
                else
                    VORPcore.NotifyRightTip(_U("cantManageRanch"), 4000)
                end
            else
                VORPcore.NotifyRightTip(_U("tooFarFromRanch"), 4000)
            end
        end)
    end

    while true do
        if Config.commands.manageMyRanchCommand then break end
        if not IsInMission then
            local dist = #(RanchData.ranchcoordsVector3 - GetEntityCoords(PlayerPedId()))
            local sleep = false
            if dist < 5 then
                promptGroup:ShowGroup(_U("yourRanch"))
                if firstprompt:HasCompleted() then
                    if not IsInMission then
                        MainRanchMenu()
                    else
                        VORPcore.NotifyRightTip(_U("cantManageRanch"), 4000)
                    end
                end
            elseif dist > 50 then
                sleep = true
            end

            if sleep then
                Wait(1000)
            else
                Wait(5)
            end
        else
            Wait(500)
        end
    end
end)

---@param admin boolean
RegisterNetEvent("bcc-ranch:IsAdminClientReceiver", function(admin)
    IsAdmin = admin
end)

---@param ranchData table
RegisterNetEvent('bcc-ranch:UpdateRanchData', function (ranchData)
    if not IsInMission then
        IsInMission = true -- This is to stop the player from being able to manage their ranch while the Ranchdata is updating
        RanchData = nil
        RanchData = ranchData
        RanchData.ranchcoords = json.decode(RanchData.ranchcoords)
        RanchData.ranchcoordsVector3 = vector3(RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z)
        IsInMission = false
    else
        while true do
            Wait(200)
            if not IsInMission then
                RanchData = nil
                RanchData = ranchData
                RanchData.ranchcoords = json.decode(RanchData.ranchcoords)
                RanchData.ranchcoordsVector3 = vector3(RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z)
                break
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if ranchBlip then
            ranchBlip:Remove()
        end
    end
end)