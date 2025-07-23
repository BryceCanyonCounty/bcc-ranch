local spawningInProgress = {} -- [playerId][animalType] = true

local animalsConfig = {
    cows = { coordsKey = "cow_coords" },
    pigs = { coordsKey = "pig_coords" },
    sheeps = { coordsKey = "sheep_coords" },
    goats = { coordsKey = "goat_coords" },
    chickens = { coordsKey = "chicken_coords" },
}

local spawnedPeds = {} -- Tracks spawned peds by player and type: { [playerId] = { cows = {netId1, ...} } }

-- Safely decode JSON
local function safeDecode(data)
    if type(data) == "string" then
        local success, result = pcall(json.decode, data)
        if success then
            devPrint("[Server] Successfully decoded JSON data.")
            return result
        else
            devPrint("[Server] Failed to decode JSON data.")
        end
    end
    return nil
end

-- Get ranch owner from database
local function GetRanchOwnerId(ranchId)
    local result = MySQL.query.await("SELECT charidentifier FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if result and #result > 0 then
        devPrint("[GetRanchOwnerId] Found ranch owner for ranchId: " .. ranchId)
        return tostring(result[1].charidentifier)
    else
        devPrint("[GetRanchOwnerId] No ranch found for ranchId: " .. tostring(ranchId))
        return nil
    end
end

-- Check if player is ranch owner
local function isRanchOwner(playerId, ranchId)
    local ranchOwnerId = GetRanchOwnerId(ranchId)
    if not ranchOwnerId then return false end

    local user = VORPcore.getUser(playerId)
    if not user then return false end

    local character = user.getUsedCharacter
    if not character then return false end

    local isOwner = tostring(character.charIdentifier) == ranchOwnerId
    devPrint(("[isRanchOwner] Player %d is%s the ranch owner of %s."):format(playerId, isOwner and "" or " not", ranchId))
    return isOwner
end

-- Check if player is employee at ranch
local function isRanchEmployee(playerId, ranchId)
    local user = VORPcore.getUser(playerId)
    if not user then return false end

    local character = user.getUsedCharacter
    if not character then return false end

    local charId = character.charIdentifier
    local result = MySQL.query.await("SELECT 1 FROM bcc_ranch_employees WHERE charidentifier = ? AND ranchid = ?", { charId, ranchId })

    local isEmployee = result and #result > 0
    devPrint(("[isRanchEmployee] Player %d is%s an employee at ranch %s."):format(playerId, isEmployee and "" or " not", ranchId))
    return isEmployee
end

-- Unified check
local function isOwnerOrEmployee(playerId, ranchId)
    return isRanchOwner(playerId, ranchId) or isRanchEmployee(playerId, ranchId)
end

RegisterNetEvent("bcc-ranch:RequestAnimalSpawnCycle", function(ranchData)
    local src = source
    local ranchId = ranchData.ranchid

    if not isOwnerOrEmployee(src, ranchId) then
        devPrint("[Server] Player " .. src .. " is not authorized (not owner or employee). Denying spawn request.")
        return
    end

    devPrint("[Server] Player " .. src .. " is authorized. Proceeding with spawn.")
    spawningInProgress[src] = spawningInProgress[src] or {}

    for animalType, config in pairs(animalsConfig) do
        local coordString = ranchData[config.coordsKey]
        local coords = coordString and coordString ~= "none" and safeDecode(coordString) or nil

        local alreadySpawning = spawningInProgress[src][animalType]
        local alreadySpawned = spawnedPeds[src] and spawnedPeds[src][animalType] and #spawnedPeds[src][animalType] > 0

        if coords and not alreadySpawned and not alreadySpawning then
            devPrint(("[Server] Attempting to spawn %s at %.2f %.2f %.2f"):format(animalType, coords.x, coords.y, coords.z))
            spawningInProgress[src][animalType] = true
            SpawnAnimals(animalType, coords, src, function()
                spawningInProgress[src][animalType] = nil
            end)
        else
            devPrint(("[Server] Skipping %s for player %d (already spawned or spawning in progress or missing coords)"):format(animalType, src))
        end
    end
end)

-- Despawn handler
BccUtils.RPC:Register("bcc-ranch:DespawnAnimalType", function(data, cb, source)
    local animalType = data.animalType
    DespawnAnimals(animalType, source)
    if cb then cb(true) end
end)

function SpawnAnimals(animalType, coords, playerId, onComplete)
    local setup = ConfigAnimals.animalSetup[animalType]
    if not setup then return end

    local model = setup.model
    local roamDist = setup.roamingRadius
    local count = setup.spawnAmount or 5

    devPrint(("[Server] Spawning %d x %s using model %s (player: %d)"):format(count, animalType, model, playerId))

    spawnedPeds[playerId] = spawnedPeds[playerId] or {}
    spawnedPeds[playerId][animalType] = {}

    CreateThread(function()
        for i = 1, count do
            local netId = BccUtils.RPC:CallAsync("bcc-ranch:SpawnWanderingAnimal", {
                coords = coords,
                model = model,
                roamDist = roamDist
            }, playerId)

            if netId then
                table.insert(spawnedPeds[playerId][animalType], netId)
                devPrint(("[Server] Spawned %s #%d (netId: %d)"):format(animalType, i, netId))
            else
                devPrint(("[Server] Failed to spawn %s #%d"):format(animalType, i))
            end

            Wait(250)
        end
        if onComplete then onComplete() end
    end)
end


-- Despawn logic
function DespawnAnimals(animalType, playerId)
    local animalList = spawnedPeds[playerId] and spawnedPeds[playerId][animalType]
    if not animalList or #animalList == 0 then
        devPrint(("[Server] No spawned peds to despawn for %s for player %d"):format(animalType, playerId))
        return
    end

    devPrint(("[Server] Despawning %d %s for player %d"):format(#animalList, animalType, playerId))
    for _, netId in ipairs(animalList) do
        TriggerClientEvent("bcc-ranch:DeleteAnimalByNetId", playerId, netId)
    end

    spawnedPeds[playerId][animalType] = nil
    if next(spawnedPeds[playerId]) == nil then
        spawnedPeds[playerId] = nil
    end

    devPrint(("[Server] %s despawned and cleaned for player %d."):format(animalType, playerId))
end
