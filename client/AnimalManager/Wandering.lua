------------ Animals Wandering Setup --------------
local cows, chickens, goats, pigs = {}, {}, {}, {}
RegisterNetEvent('bcc-ranch:CowsWander', function()
    local deleted = false
    spawnWanderingAnimals('cows')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, false)
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
    spawnWanderingAnimals('chickens')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, false)
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
    spawnWanderingAnimals('goats')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, false)
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
    spawnWanderingAnimals('pigs')
    while true do
        Wait(2000)
        local pl = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, false)
        if dist > 400 and deleted == false then
            deleted = true
            DelPedsForTable(pigs)
        elseif dist < 400 and deleted == true then
            deleted = false
            spawnWanderingAnimals('pigs')
        end
    end
end)

function spawnWanderingAnimals(animaltype)
    local repamount = 0
    if animaltype == 'cows' then
        local model = joaat('a_c_cow')
        repeat
            repamount = repamount + 1
            local createdped = spawnpedsroam(model, Config.RanchSetup.RanchAnimalSetup.Cows.RoamingRadius)
            table.insert(cows, createdped)
        until repamount == 5
    elseif animaltype == 'chickens' then
        local model = joaat('a_c_chicken_01')
        repeat
            repamount = repamount + 1
            local createdped = spawnpedsroam(model, Config.RanchSetup.RanchAnimalSetup.Chickens.RoamingRadius)
            table.insert(chickens, createdped)
        until repamount == 5
    elseif animaltype == 'goats' then
        local model = joaat('a_c_goat_01')
        repeat
            repamount = repamount + 1
            local createdped = spawnpedsroam(model, Config.RanchSetup.RanchAnimalSetup.Goats.RoamingRadius)
            table.insert(goats, createdped)
        until repamount == 5
    elseif animaltype == 'pigs' then
        local model = joaat('a_c_pig_01')
        repeat
            repamount = repamount + 1
            local createdped = spawnpedsroam(model, Config.RanchSetup.RanchAnimalSetup.Pigs.RoamingRadius)
            table.insert(pigs, createdped)
        until repamount == 5
    end
end

function spawnpedsroam(model, roamdist)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    local spawncoords = { x = RanchCoords.x + math.random(10, 20), y = RanchCoords.y + math.random(10, 30), z = RanchCoords.z }
    local createdped = CreatePed(model, spawncoords.x, spawncoords.y, spawncoords.z, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, createdped, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
    Citizen.InvokeNative(0xE054346CA3A0F315, createdped, spawncoords.x, spawncoords.y, spawncoords.z, roamdist, tonumber(1077936128), tonumber(1086324736), 1)
    relationshipsetup(createdped, 3)
    return createdped
end