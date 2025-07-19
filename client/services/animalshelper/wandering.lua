local animalsConfig = {
    cows = { coordsKey = "cow_coords", peds = {}, spawned = false },
    pigs = { coordsKey = "pig_coords", peds = {}, spawned = false },
    sheeps = { coordsKey = "sheep_coords", peds = {}, spawned = false },
    goats = { coordsKey = "goat_coords", peds = {}, spawned = false },
    chickens = { coordsKey = "chicken_coords", peds = {}, spawned = false },
}

local despawnDistance = 50.0

CreateThread(function()
    while true do
        Wait(10000)
        devPrint("[Loop] Running ranch animal spawn check...")
        if RanchData then
            for animalType, config in pairs(animalsConfig) do
                -- Clean out invalid peds
                for i = #config.peds, 1, -1 do
                    if not DoesEntityExist(config.peds[i]) then
                        table.remove(config.peds, i)
                    end
                end

                devPrint(("[Loop] Checking %s - Spawned: %s, Peds Count: %d"):format(animalType, tostring(config.spawned), #config.peds))

                local coordString = RanchData[config.coordsKey]
                local coords = coordString and coordString ~= "none" and safeDecode(coordString) or nil

                if coords then
                    devPrint(("[Decode] Coordinates for %s: %.2f %.2f %.2f"):format(animalType, coords.x, coords.y, coords.z))
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local dist = #(vector3(coords.x, coords.y, coords.z) - playerCoords)
                    devPrint(("[Proximity] Distance from %s spawn point: %.2f"):format(animalType, dist))

                    if dist > despawnDistance then
                        if config.spawned then
                            devPrint(("[Proximity] Player too far from %s, despawning..."):format(animalType))
                            for _, ped in pairs(config.peds) do
                                if DoesEntityExist(ped) then
                                    DeletePed(ped)
                                end
                            end
                            config.peds = {}
                            config.spawned = false
                        end
                    else
                        if not config.spawned and #config.peds == 0 then
                            local amount = ConfigAnimals.animalSetup[animalType].spawnAmount or 5
                            devPrint(("[Ranch] Spawning %s with amount %d..."):format(animalType, amount))
                            spawnWanderingAnimals(animalType, amount)
                            Wait(1000)

                            local aliveCount = 0
                            for _, ped in pairs(config.peds) do
                                if DoesEntityExist(ped) then
                                    aliveCount = aliveCount + 1
                                end
                            end

                            devPrint(("[Ranch] %s alive count: %d"):format(animalType, aliveCount))

                            if aliveCount >= amount then
                                config.spawned = true
                                devPrint(("[Ranch] Marked %s as spawned. Total Alive: %d"):format(animalType, aliveCount))
                            else
                                devPrint(("[Ranch] Not enough %s spawned yet. Total Alive: %d"):format(animalType, aliveCount))
                            end
                        end
                    end
                else
                    devPrint(("[Decode] Failed to decode coordinates for %s. coordString was: %s"):format(animalType, tostring(coordString)))

                end
            end
        end
    end
end)

function GetAnimalPeds(animalType)
    return animalsConfig[animalType] and animalsConfig[animalType].peds or {}
end

function spawnWanderingAnimals(animalType, count)
    local config = animalsConfig[animalType]
    devPrint(("[SpawnFunc] Called for %s with count = %d"):format(animalType, count))

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

    for i = 1, count do
        devPrint(("[SpawnFunc] Attempting to spawn %s #%d"):format(animalType, i))
        local ped = spawnpedsroam(spawnCoords, model, roamDist)
        if ped then
            table.insert(config.peds, ped)
            devPrint(("[Spawned] %s #%d | Total: %d"):format(animalType, i, #config.peds))
        else
            devPrint(("[SpawnFunc] Failed to spawn %s #%d"):format(animalType, i))
        end
    end
end

function spawnpedsroam(coords, model, roamDist)
    if not coords or not coords.x or not coords.y or not coords.z then
        devPrint("[spawnpedsroam] Error: Invalid spawn coordinates.")
        return nil
    end

    devPrint(("[spawnpedsroam] Requesting model %s"):format(tostring(model)))
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
        devPrint("[spawnpedsroam] Waiting for model to load...")
    end

    local spawnCoords = {
        x = coords.x + math.random(1, 5),
        y = coords.y + math.random(1, 5),
        z = coords.z
    }

    local ped = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 20.0, false, false)
    if not DoesEntityExist(ped) then
        devPrint("[spawnpedsroam] Error: Failed to create ped.")
        return nil
    end

    devPrint("[spawnpedsroam] Ped created.")

    if not NetworkGetEntityIsNetworked(ped) then
        SetEntityAsMissionEntity(ped, true, true)
        NetworkRegisterEntityAsNetworked(ped)
        devPrint("[spawnpedsroam] Registered ped as networked.")
    end

    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityVisible(ped, true)
    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityCanBeDamaged(ped, false)
    SetPedCanRagdoll(ped, true)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanPlayAmbientBaseAnims(ped, true)

    SetRandomOutfitVariation(ped, true)
    PlaceEntityOnGroundProperly(ped, true)
    SetEntityHeading(ped, math.random(0, 360))
    SetModelAsNoLongerNeeded(model)

    ClearPedTasksImmediately(ped)
    TaskWanderInArea(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, roamDist + 0.1, 1.5, 1.5, 1)
    devPrint(("[spawnpedsroam] Wander task set for ped at %.2f %.2f %.2f"):format(spawnCoords.x, spawnCoords.y, spawnCoords.z))

    if Config.EnableAnimalBlip then
        Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1749618580, ped)
    end
    local pedGroup = GetPedRelationshipGroupHash(ped)
    local playerGroup = joaat("PLAYER")
    SetRelationshipBetweenGroups(1, playerGroup, pedGroup)
    SetRelationshipBetweenGroups(1, pedGroup, playerGroup)

    return ped
end

function safeDecode(data)
    if type(data) == "string" then
        local success, result = pcall(json.decode, data)
        if success then
            devPrint("[safeDecode] JSON decoded successfully.")
            return result
        end
    end
    devPrint("[safeDecode] Failed to decode JSON data.")
    return nil
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        devPrint("[Cleanup] Deleting all spawned animals...")
        for animalType, config in pairs(animalsConfig) do
            for _, ped in pairs(config.peds) do
                if DoesEntityExist(ped) then
                    DeletePed(ped)
                end
            end
            config.peds = {}
            config.spawned = false
            devPrint(("[Cleanup] Reset %s"):format(animalType))
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    devPrint("[Disconnect] Player dropped. Cleaning up ranch animals...")
    for animalType, config in pairs(animalsConfig) do
        for _, ped in pairs(config.peds) do
            if DoesEntityExist(ped) then
                DeletePed(ped)
            end
        end
        config.peds = {}
        config.spawned = false
        devPrint(("[Disconnect] Reset %s"):format(animalType))
    end
end)
