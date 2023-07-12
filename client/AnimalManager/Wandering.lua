------------ Animals Wandering Setup --------------
local cows, chickens, goats, pigs = {}, {}, {}, {}
RegisterNetEvent('bcc-ranch:CowsWander', function()
    local deleted = false
	local spawnCoords -- added by Little Creek
	spawnCoords = Cowcoords -- added by Little Creek
    spawnWanderingAnimals('cows')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, spawnCoords.x, spawnCoords.y, spawnCoords.z, false)
        if dist > 400 and deleted == false then
            deleted = true
            DelPedsForTable(cows)
        elseif dist < 400 and deleted == true then
            deleted = false
            spawnWanderingAnimals('cows')
        end
    end
end)

RegisterNetEvent('bcc-ranch:ChickensWander', function()
    local deleted = false
	local spawnCoords -- added by Little Creek
	spawnCoords = Chickencoords -- added by Little Creek
    spawnWanderingAnimals('chickens')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, spawnCoords.x, spawnCoords.y, spawnCoords.z, false)
        if dist > 400 and deleted == false then
            deleted = true
            DelPedsForTable(chickens)
        elseif dist < 400 and deleted == true then
            deleted = false
            spawnWanderingAnimals('chickens')
        end
    end
end)

RegisterNetEvent('bcc-ranch:GoatsWander', function()
    local deleted = false
	local spawnCoords -- added by Little Creek
	spawnCoords = Goatcoords -- added by Little Creek
    spawnWanderingAnimals('goats')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, spawnCoords.x, spawnCoords.y, spawnCoords.z, false)
        if dist > 400 and deleted == false then
            deleted = true
            DelPedsForTable(goats)
        elseif dist < 400 and deleted == true then
            deleted = false
            spawnWanderingAnimals('goats')
        end
    end
end)

RegisterNetEvent('bcc-ranch:PigsWander', function()
    local deleted = false
	local spawnCoords -- added by Little Creek
	spawnCoords = Pigcoords -- added by Little Creek
    spawnWanderingAnimals('pigs')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, spawnCoords.x, spawnCoords.y, spawnCoords.z, false)
        if dist > 400 and deleted == false then
            deleted = true
            DelPedsForTable(pigs)
        elseif dist < 400 and deleted == true then
            deleted = false
            spawnWanderingAnimals('pigs')
        end
    end
end)

function spawnWanderingAnimals(animalType)
    local repAmount = 0
	local spawnCoords
    if animalType == 'cows' then
		spawnCoords = Cowcoords -- added by Little Creek
        local model = joaat('a_c_cow')
        repeat
            repAmount = repAmount + 1
            local createdPed = spawnpedsroam(spawnCoords, model, Config.RanchSetup.RanchAnimalSetup.Cows.RoamingRadius)
            table.insert(cows, createdPed)
        until repAmount == 5
    elseif animalType == 'chickens' then
		spawnCoords = Chickencoords -- added by Little Creek
        local model = joaat('a_c_chicken_01')
        repeat
            repAmount = repAmount + 1
            local createdPed = spawnpedsroam(spawnCoords, model, Config.RanchSetup.RanchAnimalSetup.Chickens.RoamingRadius)
            table.insert(chickens, createdPed)
        until repAmount == 5
    elseif animalType == 'goats' then
		spawnCoords = Goatcoords -- added by Little Creek
        local model = joaat('a_c_goat_01')
        repeat
            repAmount = repAmount + 1
            local createdPed = spawnpedsroam(spawnCoords, model, Config.RanchSetup.RanchAnimalSetup.Goats.RoamingRadius)
            table.insert(goats, createdPed)
        until repAmount == 5
    elseif animalType == 'pigs' then
		spawnCoords = Pigcoords -- added by Little Creek
        local model = joaat('a_c_pig_01')
        repeat
            repAmount = repAmount + 1
            local createdPed = spawnpedsroam(spawnCoords, model, Config.RanchSetup.RanchAnimalSetup.Pigs.RoamingRadius)
            table.insert(pigs, createdPed)
        until repAmount == 5
    end
end

function spawnpedsroam(coords, model, roamDist)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    -- local spawnCoords = { x = RanchCoords.x + math.random(10, 20), y = RanchCoords.y + math.random(10, 30), z = RanchCoords.z }
    local spawnCoords = { x = coords.x + math.random(1, 5), y = coords.y + math.random(1, 5), z = coords.z } -- now spawning near their set location instead of the Ranch changed by Little Creek
    local createdPed = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 50, true, false)
    Citizen.InvokeNative(0x283978A15512B2FE, createdPed, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
    Citizen.InvokeNative(0xE054346CA3A0F315, createdPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, roamDist, tonumber(1077936128), tonumber(1086324736), 1)
    relationshipsetup(createdPed, 1)
    SetBlockingOfNonTemporaryEvents(createdPed, true)
    return createdPed
end