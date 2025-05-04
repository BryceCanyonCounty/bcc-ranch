local animalsConfig = {
    cows = { coordsKey = "cow_coords", peds = {} },
    pigs = { coordsKey = "pig_coords", peds = {} },
    sheeps = { coordsKey = "sheep_coords", peds = {} },
    goats = { coordsKey = "goat_coords", peds = {} },
    chickens = { coordsKey = "chicken_coords", peds = {} },
}

CreateThread(function()
    while true do
        Wait(10000)
        if RanchData then
            for animalType, config in pairs(animalsConfig) do
                local coordString = RanchData[config.coordsKey]
                if coordString and coordString ~= "none" and #config.peds <= 0 then
                    devPrint(("[Ranch] Spawning %s..."):format(animalType))
                    spawnWanderingAnimals(animalType)
                end
            end
        end
    end
end)

function GetAnimalPeds(animalType)
    return animalsConfig[animalType] and animalsConfig[animalType].peds or {}
end

function spawnWanderingAnimals(animalType)
    local config = animalsConfig[animalType]
    if not config then
        devPrint("Error: Invalid animal type: " .. tostring(animalType))
        return
    end

    local coordData = RanchData[config.coordsKey]
    if not coordData or coordData == "none" then
        devPrint("Error: Missing or invalid coordinates for " .. animalType)
        return
    end

    local spawnCoords = safeDecode(coordData)
    if not spawnCoords then
        devPrint("Error: Failed to decode coordinates for " .. animalType)
        return
    end

    local modelMap = {
        cows = "a_c_cow",
        pigs = "a_c_pig_01",
        sheeps = "a_c_sheep_01",
        goats = "a_c_goat_01",
        chickens = "a_c_chicken_01"
    }

    local model = joaat(modelMap[animalType])
    local roamDist = ConfigAnimals.animalSetup[animalType].roamingRadius

    local repAmount = 0
    repeat
        repAmount = repAmount + 1
        local createdPed = spawnpedsroam(spawnCoords, model, roamDist)
        if createdPed then
            table.insert(config.peds, createdPed)
            devPrint(("[Spawned] %s #%d | NetID: %s | Coords: %.2f %.2f %.2f"):format(
                animalType, repAmount, tostring(createdPed.netId), createdPed.coords.x, createdPed.coords.y, createdPed.coords.z))
        end
    until repAmount == 5
end

function spawnpedsroam(coords, model, roamDist)
    if not coords or not coords.x or not coords.y or not coords.z then
        devPrint("Error: Invalid spawn coordinates.")
        return nil
    end

    devPrint(("[Spawn] Requesting model %s"):format(tostring(model)))
    RequestModel(model)
    while not HasModelLoaded(model) do 
        Wait(100) 
        devPrint("[Spawn] Waiting for model to load...")
    end

    local spawnCoords = {
        x = coords.x + math.random(1, 5),
        y = coords.y + math.random(1, 5),
        z = coords.z
    }

    local ped = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 50.0, false, false)
    if not DoesEntityExist(ped) then
        devPrint("Error: Failed to create ped.")
        return nil
    end

    devPrint("[Spawn] Ped created.")

    if not NetworkGetEntityIsNetworked(ped) then 
        SetEntityAsMissionEntity(ped, true, true)
        NetworkRegisterEntityAsNetworked(ped)
        devPrint("[Network] Registered entity as networked.")
    end
    
    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityVisible(ped, true)
    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedCanRagdoll(ped, true)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanPlayAmbientBaseAnims(ped, true)

    SetRandomOutfitVariation(ped, true)
    PlaceEntityOnGroundProperly(ped, true)
    SetEntityHeading(ped, math.random(0, 360))
    SetModelAsNoLongerNeeded(model)
    devPrint("[Outfit] Random outfit variation applied.")

    ClearPedTasksImmediately(ped)
    Citizen.InvokeNative(0xE054346CA3A0F315, ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, roamDist + 0.1, tonumber(1077936128), tonumber(1086324736), 1)
    devPrint(("[AI] WanderInArea task applied at (%.2f, %.2f, %.2f) with radius %.1f"):format(spawnCoords.x, spawnCoords.y, spawnCoords.z, roamDist))

    Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, ped)
    devPrint("[AI] Ambient animal group set.")

    local pedGroup = GetPedRelationshipGroupHash(ped)
    local playerGroup = joaat("PLAYER")
    Citizen.InvokeNative(0xBF25EB89375A37AD, 1, playerGroup, pedGroup)
    Citizen.InvokeNative(0xBF25EB89375A37AD, 1, pedGroup, playerGroup)
    devPrint("[AI] Relationship group set between player and " .. tostring(pedGroup))

    return {
        ped = ped,
        netId = netId,
        coords = spawnCoords
    }
end

function safeDecode(data)
    if type(data) == "string" then
        local success, result = pcall(json.decode, data)
        if success then
            return result
        end
    end
    devPrint("[Error] Failed to decode JSON data.")
    return nil
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        devPrint("[Cleanup] Deleting all spawned animals...")
        for animalType, config in pairs(animalsConfig) do
            for _, entry in pairs(config.peds) do
                local ped = entry.ped or entry
                if DoesEntityExist(ped) then
                    DeletePed(ped)
                end
            end
            config.peds = {} -- clear the table
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    devPrint("[Disconnect] Player dropped. Cleaning up ranch animals...")
    for animalType, config in pairs(animalsConfig) do
        for _, entry in pairs(config.peds) do
            local ped = entry.ped or entry
            if DoesEntityExist(ped) then
                DeletePed(ped)
            end
        end
        config.peds = {} -- clear the table
    end
end)