local cows, pigs, sheeps, goats, chickens = {}, {}, {}, {}, {}

CreateThread(function()
    while true do
        Wait(10000)
        if RanchData then
            if RanchData.cow_coords and RanchData.cow_coords ~= 'none' and #cows <= 0 then
                spawnWanderingAnimals('cows')
            end
            if RanchData.pig_coords and RanchData.pig_coords ~= 'none' and #pigs <= 0 then
                spawnWanderingAnimals('pigs')
            end
            if RanchData.sheep_coords and RanchData.sheep_coords ~= 'none' and #sheeps <= 0 then
                spawnWanderingAnimals('sheeps')
            end
            if RanchData.goat_coords and RanchData.goat_coords ~= 'none' and #goats <= 0 then
                spawnWanderingAnimals('goats')
            end
            if RanchData.chicken_coords and RanchData.chicken_coords ~= 'none' and #chickens <= 0 then
                spawnWanderingAnimals('chickens')
            end
        end
    end
end)

function spawnWanderingAnimals(animalType)
    local repAmount = 0
    local spawnCoords
    local selectedAnimal = {
        ['cows'] = function()
            spawnCoords = safeDecode(RanchData.cow_coords)
            if not spawnCoords then 
                devPrint("Error: Missing or invalid cow coordinates.")
                return 
            end
            local model = joaat('a_c_cow')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, ConfigAnimals.animalSetup.cows.roamingRadius)
                if createdPed then
                    table.insert(cows, createdPed)
                end
            until repAmount == 5
        end,
        ['pigs'] = function()
            spawnCoords = safeDecode(RanchData.pig_coords)
            if not spawnCoords then 
                devPrint("Error: Missing or invalid pig coordinates.")
                return 
            end
            local model = joaat('a_c_pig_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, ConfigAnimals.animalSetup.pigs.roamingRadius)
                if createdPed then
                    table.insert(pigs, createdPed)
                end
            until repAmount == 5
        end,
        ['sheeps'] = function()
            spawnCoords = safeDecode(RanchData.sheep_coords)
            if not spawnCoords then 
                devPrint("Error: Missing or invalid sheep coordinates.")
                return 
            end
            local model = joaat('a_c_sheep_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, ConfigAnimals.animalSetup.sheeps.roamingRadius)
                if createdPed then
                    table.insert(sheeps, createdPed)
                end
            until repAmount == 5
        end,
        ['goats'] = function()
            spawnCoords = safeDecode(RanchData.goat_coords)
            if not spawnCoords then 
                devPrint("Error: Missing or invalid goat coordinates.")
                return 
            end
            local model = joaat('a_c_goat_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, ConfigAnimals.animalSetup.goats.roamingRadius)
                if createdPed then
                    table.insert(goats, createdPed)
                end
            until repAmount == 5
        end,
        ['chickens'] = function()
            spawnCoords = safeDecode(RanchData.chicken_coords)
            if not spawnCoords then 
                devPrint("Error: Missing or invalid chicken coordinates.")
                return 
            end
            local model = joaat('a_c_chicken_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, ConfigAnimals.animalSetup.chickens.roamingRadius)
                if createdPed then
                    table.insert(chickens, createdPed)
                end
            until repAmount == 5
        end
    }

    if selectedAnimal[animalType] then
        selectedAnimal[animalType]()
    else
        devPrint("Error: Invalid animal type: " .. tostring(animalType))
    end
end

function spawnpedsroam(coords, model, roamDist)
    if not coords or not coords.x or not coords.y or not coords.z then
        devPrint("Error: Invalid spawn coordinates.")
        return nil
    end

    -- Request the model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    -- Generate random spawn coordinates near the provided location
    local spawnCoords = {
        x = coords.x + math.random(1, 5),
        y = coords.y + math.random(1, 5),
        z = coords.z
    }

    -- Create the ped at the specified coordinates
    local createdPed = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 50, false, false)
    if not DoesEntityExist(createdPed) then
        devPrint("Error: Failed to create ped.")
        return nil
    end

    -- Mark the ped as a mission entity
    SetEntityAsMissionEntity(createdPed, true, true)

    -- Configure ped roaming
    Citizen.InvokeNative(0x283978A15512B2FE, createdPed, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
    Citizen.InvokeNative(0xE054346CA3A0F315, createdPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, roamDist + 0.1, tonumber(1077936128), tonumber(1086324736), 1)

    -- Setup relationship
    relationshipsetup(createdPed, 1)

    return createdPed
end

function safeDecode(data)
    if type(data) == "string" then
        local success, result = pcall(json.decode, data)
        if success then
            return result
        end
    end
    devPrint("Error: Failed to decode JSON data.")
    return nil
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        local function delPedsForTable(tbl)
            for _, ped in pairs(tbl) do
                if DoesEntityExist(ped) then
                    DeletePed(ped)
                end
            end
        end
        delPedsForTable(cows)
        delPedsForTable(chickens)
        delPedsForTable(goats)
        delPedsForTable(pigs)
        delPedsForTable(sheeps)
    end
end)
