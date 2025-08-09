local wanderingPeds = {}
local netIdToAnimalType = {}
local spawnedLocally = {}
local despawnDistance = 50.0

local animalsConfig = {
    cows = { coordsKey = "cow_coords" },
    pigs = { coordsKey = "pig_coords" },
    sheeps = { coordsKey = "sheep_coords" },
    goats = { coordsKey = "goat_coords" },
    chickens = { coordsKey = "chicken_coords" },
}

CreateThread(function()
    while true do
        Wait(10000)
        if not RanchData then goto continue end

        for animalType, config in pairs(animalsConfig) do
            local coordString = RanchData[config.coordsKey]
            local coords = coordString and coordString ~= "none" and safeDecode(coordString) or nil
            if coords then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local dist = #(vector3(coords.x, coords.y, coords.z) - playerCoords)

                if dist > despawnDistance then
                    if spawnedLocally[animalType] then
                        BccUtils.RPC:Call("bcc-ranch:DespawnAnimalType", { animalType = animalType })
                        spawnedLocally[animalType] = false
                        devPrint(("[Client] Despawned %s due to distance."):format(animalType))
                    end
                else
                    if not spawnedLocally[animalType] then
                        TriggerServerEvent("bcc-ranch:RequestAnimalSpawnCycle", RanchData)
                        spawnedLocally[animalType] = true
                        devPrint(("[Client] Requested spawn for %s."):format(animalType))
                    end
                end
            end
        end

        ::continue::
    end
end)

function safeDecode(data)
    if type(data) == "string" then
        local success, result = pcall(json.decode, data)
        if success then return result end
    end
    return nil
end

function getAnimalTypeFromNetId(netId)
    return netIdToAnimalType[netId]
end

BccUtils.RPC:Register("bcc-ranch:SpawnWanderingAnimal", function(params, cb)
    if not params or not params.coords or not params.model then
        devPrint("[Client] Invalid spawn parameters.")
        return cb(nil)
    end

    local spawnCoords = {
        x = params.coords.x + math.random(1, 15),
        y = params.coords.y + math.random(1, 25),
        z = params.coords.z
    }

    local pedObj = BccUtils.Ped:Create(params.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, math.random(0, 360), "world", true, nil, nil, true, nil)
    pedObj:Invincible(true)
    pedObj:SetBlockingOfNonTemporaryEvents(true)
    local ped = pedObj:GetPed()
    if not ped or not DoesEntityExist(ped) then
        devPrint("[Client] Failed to create animal ped.")
        return cb(nil)
    end

    local netId = NetworkGetNetworkIdFromEntity(ped)
    local animalType = GetAnimalTypeFromModel(params.model)
    netIdToAnimalType[netId] = animalType

    wanderingPeds[animalType] = wanderingPeds[animalType] or {}
    table.insert(wanderingPeds[animalType], ped)

    TaskWanderInArea(ped, params.coords.x, params.coords.y, params.coords.z, params.roamDist + 0.1, 1.5, 1.5, 1)
    SetNetworkIdExistsOnAllMachines(netId, true)

    if Config.EnableAnimalBlip then
        Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1749618580, ped)
    end

    devPrint(("[Client] Spawned %s with netId: %d"):format(animalType, netId))
    cb(netId)
end)

RegisterNetEvent("bcc-ranch:DeleteAnimalByNetId", function(netId)
    if not netId then return end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or not DoesEntityExist(entity) then return end

    local animalType = getAnimalTypeFromNetId(netId)
    if animalType and wanderingPeds[animalType] then
        for i, ped in ipairs(wanderingPeds[animalType]) do
            if ped == entity then
                table.remove(wanderingPeds[animalType], i)
                break
            end
        end
    end

    SetEntityAsMissionEntity(entity, true, true)
    DeletePed(entity)
    spawnedLocally[animalType] = false
    devPrint(("[Client] Deleted %s ped with netId: %d"):format(animalType, netId))
end)

function CleanupAllAnimals(reason)
    devPrint(reason .. " Deleting all spawned animals...")

    for animalType, peds in pairs(wanderingPeds) do
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                DeletePed(ped)
                devPrint(reason .. (" Deleted %s"):format(animalType))
            end
        end
        wanderingPeds[animalType] = {}
        spawnedLocally[animalType] = false
    end
end

function GetAnimalTypeFromModel(model)
    for animalType, v in pairs(ConfigAnimals.animalSetup) do
        if type(v) == "table" and v.model == model then
            return animalType
        end
    end
    return model -- fallback
end
