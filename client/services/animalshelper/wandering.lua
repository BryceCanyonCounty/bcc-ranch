------------ Animals Wandering Setup --------------
local cows, pigs, sheeps, goats, chickens = {}, {}, {}, {}, {}
CreateThread(function()
    while true do
        Wait(10000)
        if RanchData then
            if RanchData.cow_coords ~= 'none' and #cows <= 0 then
                spawnWanderingAnimals('cows')
            end
            if RanchData.pig_coords ~= 'none' and #pigs <= 0 then
                spawnWanderingAnimals('pigs')
            end
            if RanchData.sheep_coords ~= 'none' and #sheeps <= 0 then
                spawnWanderingAnimals('sheeps')
            end
            if RanchData.goat_coords ~= 'none' and #goats <= 0 then
                spawnWanderingAnimals('goats')
            end
            if RanchData.chicken_coords ~= 'none' and #chickens <= 0 then
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
            spawnCoords = json.decode(RanchData.cow_coords)
            local model = joaat('a_c_cow')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, Config.animalSetup.cows.roamingRadius)
                table.insert(cows, createdPed)
            until repAmount == 5
        end,
        ['pigs'] = function()
            spawnCoords = json.decode(RanchData.pig_coords)
            local model = joaat('a_c_pig_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, Config.animalSetup.pigs.roamingRadius)
                table.insert(pigs, createdPed)
            until repAmount == 5
        end,
        ['sheeps'] = function()
            spawnCoords = json.decode(RanchData.sheep_coords)
            local model = joaat('a_c_sheep_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, Config.animalSetup.sheeps.roamingRadius)
                table.insert(sheeps, createdPed)
            until repAmount == 5
        end,
        ['goats'] = function()
            spawnCoords = json.decode(RanchData.goat_coords)
            local model = joaat('a_c_goat_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, Config.animalSetup.goats.roamingRadius)
                table.insert(goats, createdPed)
            until repAmount == 5
        end,
        ['chickens'] = function()
            spawnCoords = json.decode(RanchData.chicken_coords)
            local model = joaat('a_c_chicken_01')
            repeat
                repAmount = repAmount + 1
                local createdPed = spawnpedsroam(spawnCoords, model, Config.animalSetup.chickens.roamingRadius)
                table.insert(chickens, createdPed)
            until repAmount == 5
        end
    }

    if selectedAnimal[animalType] then
        selectedAnimal[animalType]()
    end

    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        return
    end

end

function spawnpedsroam(coords, model, roamDist)
    if coords == nil then
        coords = json.decode(RanchData.ranchcoords)
    end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    local spawnCoords = { x = coords.x + math.random(1, 5), y = coords.y + math.random(1, 5), z = coords.z } -- now spawning near their set location instead of the Ranch changed by Little Creek
    local createdPed = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 50, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, createdPed, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
    Citizen.InvokeNative(0xE054346CA3A0F315, createdPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, roamDist + 0.1, tonumber(1077936128), tonumber(1086324736), 1)
    relationshipsetup(createdPed, 1)
    return createdPed
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        local function delPedsForTable(table)
            for k, v in pairs(table) do
                DeletePed(v)
            end
        end
        delPedsForTable(cows)
        delPedsForTable(chickens)
        delPedsForTable(goats)
        delPedsForTable(pigs)
        delPedsForTable(sheeps)
    end
end)