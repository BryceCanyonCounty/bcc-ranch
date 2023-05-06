InMission = false
----- This will run to check if the player owns a ranch when they select char -----
RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    Wait(7000)
    TriggerServerEvent('bcc-ranch:CheckIfRanchIsOwned')
end)

RegisterCommand('ranchstart', function()
    TriggerServerEvent('bcc-ranch:CheckIfRanchIsOwned')
end)

---- This will handle opening ranch menu -----
RegisterNetEvent('bcc-ranch:HasRanchHandler', function(ranch)
    RanchCoords = json.decode(ranch.ranchcoords)
    RanchRadius = ranch.ranch_radius_limit
    RanchId = ranch.ranchid
    local pl = PlayerPedId()
    local blip = VORPutils.Blips:SetBlip(ranch.ranchname, Config.RanchSetup.BlipHash, 0.2, RanchCoords.x, RanchCoords.y, RanchCoords.z)
    while true do
        Citizen.Wait(10)
        local plc = GetEntityCoords(pl)
        if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, true) < 5 then
            BccUtils.Misc.DrawText3D(RanchCoords.x, RanchCoords.y, RanchCoords.z, Config.Language.OpenRanchMenu)
            if IsControlJustReleased(0, 0x760A9C6F) then
                if not Inmenu then
                    if not InMission then
                        MainMenu()
                    else
                        VORPcore.NotifyRightTip(Config.Language.inmission, 4000)
                    end
                end
            end
        end
    end
end)

---- This Event Will Create The Sale Locations Blips -----
Citizen.CreateThread(function()
    for k, v in pairs(Config.SaleLocations) do
        local  blip = VORPutils.Blips:SetBlip(v.LocationName, Config.SaleLocations.BlipHash, 0.2, v.Coords.x, v.Coords.y, v.Coords.z)
    end
end)