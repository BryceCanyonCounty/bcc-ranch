-- Global variables
IsAdmin, RanchData, IsOwnerOfRanch, IsEmployeeOfRanch, IsInMission, agingActive, ranchBlip, activeBlips = false, {},
    false, false, false, false, nil, {}
OwnedRanchData = nil
EmployedRanchData = nil
activePeds = {}

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    IsAdmin = BccUtils.RPC:CallAsync("bcc-ranch:AdminCheck")

    BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerOwnsARanch", {}, function(success, ranchData)
        if success then
            devPrint("Player owns a ranch: " .. ranchData.ranchname)
            OwnedRanchData = ranchData
            handleRanchData(ranchData, true)
        else
            devPrint("Player does not own a ranch.")

            BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee", {}, function(success, ranchData)
                if success then
                    devPrint("Player is an employee at ranch: " .. ranchData.ranchname)
                    EmployedRanchData = ranchData
                    handleRanchData(ranchData, false)
                else
                    devPrint("Player is not an employee at any ranch.")
                end
            end)
        end
    end)
end)

function SetActiveRanchContext(ranchData)
    RanchData = ranchData
end

function handleRanchData(ranchData, isOwner)
    if not ranchData or not ranchData.ranchname then
        devPrint("[RanchLogic] Ranch data is missing or invalid.")
        return
    end

    RanchData = ranchData
    if isOwner then
        IsOwnerOfRanch = true
    else
        IsEmployeeOfRanch = true
    end

    devPrint("Ranch data valid: " .. ranchData.ranchname)

    -- Decode ranch coordinates
    local decoded
    if RanchData.ranchcoords then
        local ok, coords = pcall(json.decode, RanchData.ranchcoords)
        if ok and coords then
            RanchData.ranchcoords = coords
            RanchData.ranchcoordsVector3 = vector3(coords.x, coords.y, coords.z)
        else
            devPrint("[RanchLogic] Failed to decode ranchcoords.")
            return
        end
    else
        devPrint("[RanchLogic] Missing or nil ranchcoords.")
        return
    end

    -- Blip
    local x, y, z = RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z
    ranchBlip = BccUtils.Blip:SetBlip(RanchData.ranchname, ConfigRanch.ranchSetup.ranchBlip, 0.2, x, y, z)
    local modifier = BccUtils.Blips:AddBlipModifier(ranchBlip, 'BLIP_MODIFIER_MP_COLOR_8')
    modifier:ApplyModifier()
    table.insert(activeBlips, ranchBlip)

    if RanchData.ranch_npc_enabled == 1 then
        npcRanch = BccUtils.Ped:Create(
            ConfigRanch.ranchSetup.npc.model,
            x, y, z - 1,
            RanchData.ranch_npc_heading or 0.0,
            'world',
            true,
            nil,
            nil,
            true,
            nil
        )

        if npcRanch then
            npcRanch:Freeze()
            npcRanch:SetHeading(RanchData.ranch_npc_heading or 0.0)
            npcRanch:Invincible()
            npcRanch:SetBlockingOfNonTemporaryEvents(true)
            table.insert(activePeds, npcRanch)
        else
            devPrint("[RANCH NPC] Failed to create ranch NPC at coords: ", x, y, z)
        end
    end


    -- Prompt
    local promptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstPrompt = promptGroup:RegisterPrompt(_U("manage"), BccUtils.Keys[ConfigRanch.ranchSetup.manageRanchKey], 1,
        1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    -- Command
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

    -- Set spawner flag
    isSpawner = RanchData.isSpawner == true

    -- Check for aging condition
    agingActive = false
    for animalType, config in pairs(ConfigAnimals.animalSetup) do
        if RanchData[animalType] == "true" then
            BccUtils.RPC:Call("bcc-ranch:GetAnimalCondition", {
                ranchId = RanchData.ranchid,
                animalType = animalType
            }, function(condition)
                if condition and condition >= config.maxCondition then
                    devPrint("[RanchLogic] " .. animalType .. " max condition. Aging activated.")
                    agingActive = true
                end
            end)
        end
    end

    -- Prompt loop
    CreateThread(function()
        while true do
            if Config.commands.manageMyRanchCommand then break end

            if not IsInMission then
                local dist = #(RanchData.ranchcoordsVector3 - GetEntityCoords(PlayerPedId()))
                local sleep = false
                if dist < 5 and not IsEntityDead(PlayerPedId()) then
                    promptGroup:ShowGroup(_U("yourRanch"))
                    if firstPrompt:HasCompleted() then
                        if not IsInMission then
                            MainRanchMenu()
                        else
                            Notify(_U("cantManageRanch"), "error", 4000)
                        end
                    end
                elseif dist > 50 then
                    sleep = true
                end
                Wait(sleep and 1000 or 5)
            else
                Wait(500)
            end
        end
    end)

    checkIfAgingShouldBeActive()
end

CreateThread(function()
    IsAdmin = BccUtils.RPC:CallAsync("bcc-ranch:AdminCheck")

    BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerOwnsARanch", {}, function(success, ranchData)
        if success then
            devPrint("Player owns a ranch: " .. ranchData.ranchname)
            OwnedRanchData = ranchData
            SetActiveRanchContext(ranchData)
            handleRanchData(ranchData, true)
        else
            devPrint("Player does not own a ranch.")

            BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee", {}, function(success, ranchData)
                if success then
                    devPrint("Player is an employee at ranch: " .. ranchData.ranchname)
                    EmployedRanchData = ranchData
                    SetActiveRanchContext(ranchData)
                    handleRanchData(ranchData, false)
                else
                    devPrint("Player is not an employee at any ranch.")
                end
            end)
        end
    end)
end)

BccUtils.RPC:Register("bcc-ranch:UpdateRanchData", function(data)
    if not data or type(data) ~= "table" or not data.ranch then
        devPrint("[UpdateRanchData] Invalid payload: expecting table with ranch")
        return
    end

    -- Determine if this ranch matches owner or employee
    local id = data.ranch.ranchid
    if OwnedRanchData and OwnedRanchData.ranchid == id then
        OwnedRanchData = data.ranch
        SetActiveRanchContext(data.ranch)
    elseif EmployedRanchData and EmployedRanchData.ranchid == id then
        EmployedRanchData = data.ranch
        SetActiveRanchContext(data.ranch)
    else
        SetActiveRanchContext(data.ranch)
    end

    RanchData = data.ranch
    isSpawner = data.isSpawner or false
    devPrint("[Client] isSpawner:", isSpawner)

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

    local choreFields = {
        { key = "shovel_hay_coords",    as = "shovelHayCoords" },
        { key = "water_animal_coords",  as = "waterAnimalCoords" },
        { key = "repair_trough_coords", as = "repairTroughCoords" },
        { key = "scoop_poop_coords",    as = "scoopPoopCoords" },
    }

    for _, entry in ipairs(choreFields) do
        local raw = RanchData[entry.key]
        if raw and raw ~= "" then
            local ok, decoded = pcall(json.decode, raw)
            if ok and decoded then
                RanchData[entry.key] = raw
                RanchData[entry.as] = decoded
                devPrint(("[UpdateRanchData] Decoded %s -> %s"):format(entry.key, entry.as))
            else
                devPrint(("[UpdateRanchData] Failed to decode %s"):format(entry.key))
            end
        end
    end

    checkIfAgingShouldBeActive()
end)

BccUtils.RPC:Register("bcc-ranch:ForceUpdateRanch", function(params, cb)
    CreateThread(function()
        local ownsOk, ownsData = BccUtils.RPC:CallAsync("bcc-ranch:CheckIfPlayerOwnsARanch", {})
        local empOk, empData = BccUtils.RPC:CallAsync("bcc-ranch:CheckIfPlayerIsEmployee", {})

        if ownsOk and ownsData and ownsData.ranchid then
            devPrint("Handling owner data...")
            OwnedRanchData = ownsData
            SetActiveRanchContext(ownsData)
            handleRanchData(ownsData, true)
        end

        if empOk and empData and empData.ranchid then
            devPrint("Handling employee data...")
            EmployedRanchData = empData
            if not ownsOk then -- Don't override if already set as owner
                SetActiveRanchContext(empData)
                handleRanchData(empData, false)
            end
        end

        if not ownsOk and not empOk then
            devPrint("[RANCH] No ownership or employment found.")
        end

        if cb then cb(true) end
    end)
end)

-- Check if aging should be activated based on animal data
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

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    ClearAllRanchBlips()
    CleanupAllAnimals("[Cleanup]")
    ClearAllRanchEntities()

    for i, v in pairs(activePeds) do
        if type(v) == "table" and v.Remove then
            v:Remove() -- wrapper API handles proper deletion (and any network stuff internally)
        else
            -- Fallback if something stored a raw handle
            local ped = (type(v) == "table" and v.GetPed) and v:GetPed() or v
            if type(ped) == "number" then
                if not NetworkHasControlOfEntity(ped) then
                    NetworkRequestControlOfEntity(ped)
                    local tries = 0
                    while tries < 20 and not NetworkHasControlOfEntity(ped) do
                        Wait(10); tries = tries + 1
                    end
                end
                SetEntityAsMissionEntity(ped, true, true)
                ClearPedTasksImmediately(ped)
                DeletePed(ped)
                DeleteEntity(ped)
            end
        end
    end
    activePeds = {}
    BCCRanchMenu:Close()
end)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    CleanupAllAnimals("[Disconnect]")
end)
