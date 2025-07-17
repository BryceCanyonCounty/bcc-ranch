local activeBlips = {}
IsAdmin, RanchData, IsOwnerOfRanch, IsInMission, agingActive, ranchBlip = false, {}, false, false, false, nil

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    IsAdmin = BccUtils.RPC:CallAsync("bcc-ranch:AdminCheck")
    local player = GetPlayerServerId(tonumber(PlayerId()))
    TriggerServerEvent("bcc-ranch:StoreAllPlayers", player)
    TriggerServerEvent('bcc-ranch:CheckIfPlayerOwnsARanch')
    TriggerServerEvent('bcc-ranch:CheckIfPlayerIsEmployee')
end)

if Config.devMode then
    IsAdmin = BccUtils.RPC:CallAsync("bcc-ranch:AdminCheck")
    local player = GetPlayerServerId(tonumber(PlayerId()))
    TriggerServerEvent("bcc-ranch:StoreAllPlayers", player)
    TriggerServerEvent('bcc-ranch:CheckIfPlayerOwnsARanch')
    TriggerServerEvent('bcc-ranch:CheckIfPlayerIsEmployee')
end

-- Handle ranch ownership notification
RegisterNetEvent("bcc-ranch:PlayerOwnsARanch", function(ranchData, isOwnerOfRanch)
    RanchData = ranchData
    if isOwnerOfRanch then
        IsOwnerOfRanch = true
    end

    -- Decode ranch coordinates
    RanchData.ranchcoords = json.decode(RanchData.ranchcoords)
    RanchData.ranchcoordsVector3 = vector3(RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z)

    -- Create ranch blip
    local x, y, z = RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z
    ranchBlip = BccUtils.Blip:SetBlip(RanchData.ranchname, ConfigRanch.ranchSetup.ranchBlip, 0.2, x, y, z)
    local modifier = BccUtils.Blips:AddBlipModifier(ranchBlip, 'BLIP_MODIFIER_MP_COLOR_8')
    modifier:ApplyModifier()
    table.insert(activeBlips, ranchBlip)

    -- Set up ranch management prompt
    local promptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = promptGroup:RegisterPrompt(_U("manage"), BccUtils.Keys[ConfigRanch.ranchSetup.manageRanchKey], 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    -- Command for managing the ranch
    if Config.commands.manageMyRanchCommand then
        RegisterCommand(Config.commands.manageMyRanchCommandName, function()
            local dist = #(RanchData.ranchcoordsVector3 - GetEntityCoords(PlayerPedId()))
            if dist < 5 then
                if not IsInMission then
                    MainRanchMenu()
                else
                    Notify(_U("cantManageRanch"), "error", 4000)
                end
            else
                Notify(_U("tooFarFromRanch"), "error", 4000)
            end
        end)
    end

    agingActive = false
    for animalType, config in pairs(ConfigAnimals.animalSetup) do
        if RanchData[animalType] == "true" then
            BccUtils.RPC:Call("bcc-ranch:GetAnimalCondition", {
                ranchId = RanchData.ranchid,
                animalType = animalType
            }, function(condition)
                if condition and condition >= config.maxCondition then
                    devPrint("[PlayerOwnsARanch] Condition for " .. animalType .. " is at max. Activating aging.")
                    agingActive = true
                end
            end)
        end
    end

    while true do
        if Config.commands.manageMyRanchCommand then break end
        if not IsInMission then
            local dist = #(RanchData.ranchcoordsVector3 - GetEntityCoords(PlayerPedId()))
            local sleep = false
            if dist < 5 and not IsEntityDead(PlayerPedId()) then
                promptGroup:ShowGroup(_U("yourRanch"))
                if firstprompt:HasCompleted() then
                    if not IsInMission then
                        MainRanchMenu()
                    else
                        Notify(_U("cantManageRanch"), "error", 4000)
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
    checkIfAgingShouldBeActive()
end)

RegisterNetEvent('bcc-ranch:UpdateRanchData', function(ranchData)
    if not ranchData then
        devPrint("[UpdateRanchData] Received nil ranchData!")
        return
    end

    -- Update ranch data
    RanchData = ranchData
    if RanchData.ranchcoords then
        local success, decoded = pcall(json.decode, RanchData.ranchcoords)
        if success and decoded then
            RanchData.ranchcoords = decoded
            RanchData.ranchcoordsVector3 = vector3(decoded.x, decoded.y, decoded.z)
        else
            devPrint("[UpdateRanchData] Failed to decode ranchcoords")
        end
    else
        devPrint("[UpdateRanchData] Missing ranchcoords field.")
    end

    -- Activate aging system only if needed
    checkIfAgingShouldBeActive()
end)

function checkIfAgingShouldBeActive()
    agingActive = false -- Reset first
    for animalType, _ in pairs(ConfigAnimals.animalSetup) do
        if RanchData[animalType] == "true" then
            agingActive = true
            devPrint("[Aging] Activated aging system for ranchId: " .. tostring(RanchData.ranchid))
            return
        end
    end
    devPrint("[Aging] No animals found in ranch. Aging system remains OFF.")
end

-- Clean up all blips on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, blip in ipairs(activeBlips) do
            blip:Remove()
        end
        activeBlips = {}
        BCCRanchMenu:Close()
    end
end)
