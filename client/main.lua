-- Global variables
IsAdmin, RanchData, IsOwnerOfRanch, IsEmployeeOfRanch, IsInMission, agingActive, ranchBlip, activeBlips = false, {}, false, false, false, false, nil, {}

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    -- Fetch Admin, Ownership, and Employment data asynchronously
    IsAdmin = BccUtils.RPC:CallAsync("bcc-ranch:AdminCheck")
    BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerOwnsARanch", {}, function(success, ranchData)
        if success then
            devPrint("Player owns a ranch: " .. ranchData.ranchname)
            -- Handle ranch ownership logic
            handleRanchData(ranchData, true) -- true indicates the player owns the ranch
        else
            devPrint("Player does not own a ranch.")
        end
    end)

    BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee", {}, function(success, ranchData)
        if success then
            devPrint("Player is an employee at ranch: " .. ranchData.ranchname)
            -- Handle employee ranch logic
            handleRanchData(ranchData, false) -- false indicates the player is an employee, not the owner
        else
            devPrint("Player is not an employee at any ranch.")
        end
    end)
end)

-- Helper function to handle ranch data for both ownership and employee status
function handleRanchData(ranchData, isOwner)
    if ranchData and ranchData.ranchname then
        -- Safely assign ranch data to global variable
        RanchData = ranchData
        devPrint("Ranch data valid: " .. ranchData.ranchname)
        
        -- Update the ownership flag if the player owns the ranch
        if isOwner then
            IsOwnerOfRanch = true
        end

        -- Decode ranch coordinates if they exist
        if RanchData.ranchcoords then
            local success, decoded = pcall(json.decode, RanchData.ranchcoords)
            if success and decoded then
                RanchData.ranchcoords = decoded
                RanchData.ranchcoordsVector3 = vector3(decoded.x, decoded.y, decoded.z)
            else
                devPrint("[RanchLogic] Failed to decode ranchcoords. Invalid format.")
                return
            end
        else
            devPrint("[RanchLogic] Missing or nil ranchcoords.")
            return
        end

        -- Create ranch blip on the map
        local x, y, z = RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z
        ranchBlip = BccUtils.Blip:SetBlip(RanchData.ranchname, ConfigRanch.ranchSetup.ranchBlip, 0.2, x, y, z)
        local modifier = BccUtils.Blips:AddBlipModifier(ranchBlip, 'BLIP_MODIFIER_MP_COLOR_8')
        modifier:ApplyModifier()
        table.insert(activeBlips, ranchBlip)

        -- Setup prompt for ranch management
        local promptGroup = BccUtils.Prompts:SetupPromptGroup()
        local firstPrompt = promptGroup:RegisterPrompt(_U("manage"), BccUtils.Keys[ConfigRanch.ranchSetup.manageRanchKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

        -- Command registration for managing ranch
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
        isSpawner = RanchData.isSpawner == true -- only one client gets true
        -- Check for aging system
        agingActive = false
        for animalType, config in pairs(ConfigAnimals.animalSetup) do
            if RanchData[animalType] == "true" then
                BccUtils.RPC:Call("bcc-ranch:GetAnimalCondition", { ranchId = RanchData.ranchid, animalType = animalType }, function(condition)
                    if condition and condition >= config.maxCondition then
                        devPrint("[RanchLogic] Condition for " .. animalType .. " is at max. Activating aging.")
                        agingActive = true
                    end
                end)
            end
        end

        -- Start prompt loop
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
                if sleep then Wait(1000) else Wait(5) end
            else
                Wait(500)
            end
        end

        -- Final check for aging system activation
        checkIfAgingShouldBeActive()
    else
        devPrint("[RanchLogic] Ranch data is missing or invalid.")
    end
end

-- CreateThread to check if a player owns or is an employee at a ranch and manage ranch logic
CreateThread(function()
    IsAdmin = BccUtils.RPC:CallAsync("bcc-ranch:AdminCheck")
    -- Call the "CheckIfPlayerOwnsARanch" RPC
    BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerOwnsARanch", {}, function(success, ranchData)
        if success then
            devPrint("Player owns a ranch: " .. ranchData.ranchname)
            -- Handle ranch ownership logic
            handleRanchData(ranchData, true) -- true indicates the player owns the ranch
        else
            devPrint("Player does not own a ranch.")
        end
    end)

    -- Call the "CheckIfPlayerIsEmployee" RPC to check if the player is an employee at any ranch
    BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee", {}, function(success, ranchData)
        if success then
            devPrint("Player is an employee at ranch: " .. ranchData.ranchname)
            -- Handle employee ranch logic
            handleRanchData(ranchData, false) -- false indicates the player is an employee, not the owner
        else
            devPrint("Player is not an employee at any ranch.")
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
        { key = "shovel_hay_coords", as = "shovelHayCoords" },
        { key = "water_animal_coords", as = "waterAnimalCoords" },
        { key = "repair_trough_coords", as = "repairTroughCoords" },
        { key = "scoop_poop_coords", as = "scoopPoopCoords" },
    }

    for _, entry in ipairs(choreFields) do
        local raw = RanchData[entry.key]
        if raw and raw ~= "" then
            local ok, decoded = pcall(json.decode, raw)
            if ok and decoded then
                RanchData[entry.key] = raw -- raw string
                RanchData[entry.as] = decoded -- usable vector
                devPrint(("[UpdateRanchData] Decoded %s -> %s"):format(entry.key, entry.as))
            else
                devPrint(("[UpdateRanchData] Failed to decode %s"):format(entry.key))
            end
        end
    end

    checkIfAgingShouldBeActive()
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
