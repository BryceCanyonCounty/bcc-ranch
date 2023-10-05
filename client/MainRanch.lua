InMission = false

----- This will run to check if the player owns a ranch when they select char -----
RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    Wait(50)
    local player = GetPlayerServerId(tonumber(PlayerId())) --credit vorp_admin
    Wait(200)
    TriggerServerEvent("bcc-ranch:getPlayersInfo", player) --credit vorp_admin
    TriggerServerEvent('bcc-ranch:CheckIfRanchIsOwned')
    TriggerServerEvent('bcc-ranch:CheckIfInRanch')
end)

CreateThread(function()
    if Config.Debug then
        RegisterCommand('ranchstart', function()
            local player = GetPlayerServerId(tonumber(PlayerId())) --credit vorp_admin
            Wait(200)
            TriggerServerEvent("bcc-ranch:getPlayersInfo", player) --credit vorp_admin
            TriggerServerEvent('bcc-ranch:CheckIfRanchIsOwned')
            TriggerServerEvent('bcc-ranch:CheckIfInRanch')
        end)
    end
end)


---- This will handle opening ranch menu -----
RegisterNetEvent('bcc-ranch:HasRanchHandler', function(ranch)
    RanchCoords = json.decode(ranch.ranchcoords)
    RanchRadius = ranch.ranch_radius_limit
    RanchId = ranch.ranchid
    ChickenCoop = ranch.chicken_coop
    ChickenCoop_coords = json.decode(ranch.chicken_coop_coords)
    TriggerEvent('bcc-ranch:StartCondDec')
    TriggerServerEvent('bcc-ranch:AgeCheck', RanchId)
    -- added by Little Creek
    -- coords needed for Wandering.lua
    Cowcoords = json.decode(ranch.cowcoords)
    Pigcoords = json.decode(ranch.pigcoords)
    Chickencoords = json.decode(ranch.chickencoords)
    Goatcoords = json.decode(ranch.goatcoords)
    Herdlocation = json.decode(ranch.herdlocation)
    FeedWagonLocation = json.decode(ranch.wagonfeedcoords)
    Haycoords = json.decode(ranch.shovehaycoords)
    WaterAnimalCoords = json.decode(ranch.wateranimalcoords)
    RepairTroughCoords = json.decode(ranch.repairtroughcoords)
    ScoopPoopCoords = json.decode(ranch.scooppoopcoords)
    -- end added by Little Creek
    Wait(200)
    local blip = VORPutils.Blips:SetBlip(ranch.ranchname, Config.RanchSetup.BlipHash, 0.2, RanchCoords.x, RanchCoords.y,
        RanchCoords.z)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("OpenRanchMenu"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    if Config.RanchSetup.AnimalsRoamRanch then
        TriggerServerEvent('bcc-ranch:WanderingSetup', RanchId)
    end
    if Config.RanchSetup.manageRanchCommand.enabled then
        RegisterCommand(Config.RanchSetup.manageRanchCommand.commandName, function()
            local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
            if GetDistanceBetweenCoords(px, py, pz, RanchCoords.x, RanchCoords.y, RanchCoords.z, true) <= tonumber(RanchRadius) then
                MainMenu()
            else
                VORPcore.NotifyRightTip(_U("toFar"), 4000)
            end
        end)
    end

    while true do
        Wait(5)
        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, true)
        if dist < 5 then
            PromptGroup:ShowGroup(_U("OpenRanchMenu_desc"))
            if firstprompt:HasCompleted() then
                if not InMission then
                    TriggerServerEvent('bcc-ranch:CheckisOwner')
                    Wait(250)
                    MainMenu()
                else
                    VORPcore.NotifyRightTip(_U("inmission"), 4000)
                end
            end
        elseif dist > 200 then
            Wait(2000)
        end
        if Inmenu and dist > RanchRadius + 20 and not CreationMenu then
            MenuData.CloseAll()
        end
    end
end)

---- This Event Will Create The Sale Locations Blips and decrease the ranches cond over time -----
AddEventHandler('bcc-ranch:StartCondDec', function()
    for k, v in pairs(Config.SaleLocations) do
        local blip = VORPutils.Blips:SetBlip(v.LocationName, Config.SaleLocationBlipHash, 0.2, v.Coords.x, v.Coords.y,
            v.Coords.z)
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

RegisterNetEvent('bcc-ranch:IsOwned', function(result)
    IsOwner = result
end)

--------------------------- Set Animals out State----------------------------------
RegisterNetEvent('bcc-ranch:AnimalsOutCl', function(outstate)
    IsAnimalOut = outstate
end)

--------------------------- Checks if the current player ----------------------------------
RegisterNetEvent('bcc-ranch:CheckPlayerHerding', function(result)
    IsOwner = result
end)

RegisterNetEvent('bcc-ranch:SendList', function(result)
    table.insert(Employees, result)
end)
