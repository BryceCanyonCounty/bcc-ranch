-- Global variables
IsAdmin, RanchData, IsOwnerOfRanch, IsEmployeeOfRanch, IsInMission, agingActive, ranchBlip, activeBlips = false, {},
    false, false, false, false, nil, {}

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    IsAdmin = BccUtils.RPC:CallAsync("bcc-ranch:AdminCheck")

    BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerOwnsARanch", {}, function(success, ranchData)
        if success then
            devPrint("Player owns a ranch: " .. ranchData.ranchname)
            handleRanchData(ranchData, true)
        else
            devPrint("Player does not own a ranch.")

            -- Only check for employment if not an owner
            BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee", {}, function(success, ranchData)
                if success then
                    devPrint("Player is an employee at ranch: " .. ranchData.ranchname)
                    handleRanchData(ranchData, false)
                else
                    devPrint("Player is not an employee at any ranch.")
                end
            end)
        end
    end)
end)

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
            handleRanchData(ranchData, true)
        else
            devPrint("Player does not own a ranch.")

            BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee", {}, function(success, ranchData)
                if success then
                    devPrint("Player is an employee at ranch: " .. ranchData.ranchname)
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

    RanchData = data.ranch
    isSpawner = data.isSpawner or false
    devPrint("[Client] isSpawner:", isSpawner)

    -- Decode ranchcoords
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

    -- Decode all chore coordinate fields
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
                RanchData[entry.key] = raw    -- raw string
                RanchData[entry.as] = decoded -- usable vector
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
        if ownsOk then
            handleRanchData(ownsData, true)
        else
            devPrint("[RANCH] No ownership found.")
        end

        local empOk, empData = BccUtils.RPC:CallAsync("bcc-ranch:CheckIfPlayerIsEmployee", {})
        if empOk then
            handleRanchData(empData, false)
        else
            devPrint("[RANCH] No employment found.")
        end

        -- Optionally respond with confirmation
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

-- Clean up all blips on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ClearAllRanchBlips()
        BCCRanchMenu:Close()
    end
end)
