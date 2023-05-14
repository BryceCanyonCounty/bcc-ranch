InMission = false
----- This will run to check if the player owns a ranch when they select char -----
RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    Wait(50)
    local player = GetPlayerServerId(tonumber(PlayerId())) --credit vorp_admin
    Wait(200)
    TriggerServerEvent("bcc-ranch:getPlayersInfo", player) --credit vorp_admin
    TriggerServerEvent('bcc-ranch:CheckIfRanchIsOwned')
end)

CreateThread(function()
    if Config.Debug then
        RegisterCommand('ranchstart', function()
            local player = GetPlayerServerId(tonumber(PlayerId())) --credit vorp_admin
            Wait(200)
            TriggerServerEvent("bcc-ranch:getPlayersInfo", player) --credit vorp_admin
            TriggerServerEvent('bcc-ranch:CheckIfRanchIsOwned')
        end)
    end
end)

---- This will handle opening ranch menu -----
RegisterNetEvent('bcc-ranch:HasRanchHandler', function(ranch)
    RanchCoords = json.decode(ranch.ranchcoords)
    RanchRadius = ranch.ranch_radius_limit
    RanchId = ranch.ranchid
    TriggerEvent('bcc-ranch:StartCondDec')
    local blip = VORPutils.Blips:SetBlip(ranch.ranchname, Config.RanchSetup.BlipHash, 0.2, RanchCoords.x, RanchCoords.y, RanchCoords.z)
    local  PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("OpenRanchMenu"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    while true do
        Wait(5)
        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, true)
        if dist < 5 then
            PromptGroup:ShowGroup(_U("OpenRanchMenu_desc"))
            if firstprompt:HasCompleted() then
                if not Inmenu then
                    if not InMission then
                        MainMenu()
                    else
                        VORPcore.NotifyRightTip(_U("inmission"), 4000)
                    end
                end
            end
        elseif dist > 200 then
            Wait(2000)
        end
    end
end)

---- This Event Will Create The Sale Locations Blips and decrease the ranches cond over time -----
AddEventHandler('bcc-ranch:StartCondDec', function()
    for k, v in pairs(Config.SaleLocations) do
        local  blip = VORPutils.Blips:SetBlip(v.LocationName, Config.SaleLocationBlipHash, 0.2, v.Coords.x, v.Coords.y, v.Coords.z)
    end
    while true do
        Wait(Config.RanchSetup.RanchCondDecrease)
        TriggerServerEvent('bcc-ranch:DecranchCondIncrease', RanchId)
    end
end)

------ Command To Create Ranch ------
RegisterCommand(Config.CreateRanchCommand, function()
    TriggerServerEvent('bcc-ranch:AdminCheck', 'bcc-ranch:CreateRanchmenu', false)
end)

------ Command To Manage Ranches ------
RegisterCommand(Config.ManageRanchsCommand, function()
    TriggerServerEvent('bcc-ranch:AdminCheck', 'bcc-ranch:Openranchmanagerment', false)
end)

RegisterNetEvent('bcc-ranch:Openranchmanagerment', function()
    TriggerServerEvent('bcc-ranch:GetAllRanches')
end)