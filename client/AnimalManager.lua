-------- Function to sell animals -----------
function SellAnimals(animaltype, animal_cond)
    InMission = true
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    local tables, model
    local spawncoords, pl = nil, PlayerPedId()
    if animaltype == 'cows' then
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = joaat('a_c_cow')
        spawncoords = Cowcoords
    elseif animaltype == 'chickens' then
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = joaat('a_c_chicken_01')
        spawncoords = Chickencoords
    elseif animaltype == 'goats' then
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = joaat('a_c_goat_01')
        spawncoords = Goatcoords
    elseif animaltype == 'pigs' then
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = joaat('a_c_pig_01')
        spawncoords = Pigcoords
    end
    modelload(model)

    local salecoords = math.random(1, #Config.SaleLocations)
    local finalsalecoords = Config.SaleLocations[salecoords]

    local catch, peds = 0, {}
    repeat
        local createdped = CreatePed(model, spawncoords.x + math.random(1, 5), spawncoords.y + math.random(1, 5), spawncoords.z, true, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, createdped, true)
        SetBlockingOfNonTemporaryEvents(createdped, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
        table.insert(peds, createdped)
        catch = catch + 1
    until catch == tables.AmountSpawned
    for k, v in pairs(peds) do
        relationshipsetup(v, 1)
        TaskFollowToOffsetOfEntity(v, pl, 5, 5, 0, 1, -1, 5, true, true, true, true, true, true)
    end
    VORPcore.NotifyRightTip(Config.Language.LeadAnimalsToSale, 4000)
    VORPutils.Gps:SetGps(finalsalecoords.Coords.x, finalsalecoords.Coords.y, finalsalecoords.Coords.z)

    local animalsnear = false
    while true do
        Citizen.Wait(50)
        for k, v in pairs(peds) do
            local cp = GetEntityCoords(v)
            if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, finalsalecoords.Coords.x, finalsalecoords.Coords.y, finalsalecoords.Coords.z, true) < 15 then
                animalsnear = true
            else
                animalsnear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or PlayerDead == true then break end

        local plc = GetEntityCoords(pl)
        if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, finalsalecoords.Coords.x, finalsalecoords.Coords.y, finalsalecoords.Coords.z, true) < 5 and animalsnear == true then
            local pay
            if animal_cond == tables.MaxCondition and catch == tables.AmountSpawned then
                pay = tables.MaxConditionPay
            end
            if animal_cond ~= tables.MaxCondition then
                pay = tables.BasePay
            end
            if catch ~= tables.AmountSpawned then
                pay = tables.LowPay
            end
            TriggerServerEvent('bcc-ranch:AnimalsSoldHandler', pay, animaltype, RanchId)
            VORPcore.NotifyRightTip(Config.Language.AnimalsSold, 4000) break
        end
    end
    ClearGpsMultiRoute()
    if PlayerDead == true or catch == 0 then
        VORPcore.NotifyRightTip(Config.Language.PlayerDead, 4000)
    end

    for k, v in pairs(peds) do
        DeletePed(v)
    end
    InMission = false
end

------ This is the herding function to increase animal cond -----
function herdanimals(animaltype, ranchcond)
    local pl = PlayerPedId()
    local model, tables
    InMission = true
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    if animaltype == 'cows' then
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = joaat('a_c_cow')
    elseif animaltype == 'chickens' then
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = joaat('a_c_chicken_01')
    elseif animaltype == 'goats' then
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = joaat('a_c_goat_01')
    elseif animaltype == 'pigs' then
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = joaat('a_c_pig_01')
    end
    modelload(model)

    local catch, peds, plc = 0, {}, GetEntityCoords(pl)
    repeat
        local createdped = CreatePed(model, plc.x + math.random(1, 5), plc.y + math.random(1, 5), plc.z, true, true, true, true)
        SetBlockingOfNonTemporaryEvents(createdped, true)
        Citizen.InvokeNative(0x283978A15512B2FE, createdped, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
        table.insert(peds, createdped)
        catch = catch + 1
    until catch == tables.AmountSpawned
    for k, v in pairs(peds) do
        relationshipsetup(v, 1)
        TaskFollowToOffsetOfEntity(v, pl, 5, 5, 0, 1, -1, 5, true, true, true, true, true, true)
    end
    VORPutils.Gps:SetGps(Herdlocation.x, Herdlocation.y, Herdlocation.z)
    VORPcore.NotifyRightTip(Config.Language.HerdToLocation, 4000)

    local animalsnear = false
    while true do
        Citizen.Wait(50)
        for k, v in pairs(peds) do
            local cp = GetEntityCoords(v)
            if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, Herdlocation.x, Herdlocation.y, Herdlocation.z, true) < 15 then
                animalsnear = true
            else
                animalsnear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or PlayerDead == true then break end

        local plc2 = GetEntityCoords(pl)
        if GetDistanceBetweenCoords(plc2.x, plc2.y, plc2.z, Herdlocation.x, Herdlocation.y, Herdlocation.z, true) < 5 and animalsnear == true then
            animalsnear = false
            ClearGpsMultiRoute()
            VORPcore.NotifyRightTip(Config.Language.ReturnAnimals, 4000) break
        end
    end

    VORPutils.Gps:SetGps(plc.x, plc.y, plc.z)
    while true do
        Citizen.Wait(50)
        for k, v in pairs(peds) do
            local cp = GetEntityCoords(v)
            if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, plc.x, plc.y, plc.z, true) < 15 then
                animalsnear = true
            else
                animalsnear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or PlayerDead == true then break end

        local plc2 = GetEntityCoords(pl)
        if GetDistanceBetweenCoords(plc2.x, plc2.y, plc2.z, plc.x, plc.y, plc.z, true) < 5 and animalsnear == true then
            if ranchcond ~= Config.RanchSetup.MaxRanchCondition and catch == tables.AmountSpawned then
                TriggerServerEvent('bcc-ranch:AnimalCondIncrease', animaltype, tables.CondIncreasePerHerdNotMaxRanchCond, RanchId)
            else
                TriggerServerEvent('bcc-ranch:AnimalCondIncrease', animaltype, tables.CondIncreasePerHerd, RanchId)
            end
            VORPcore.NotifyRightTip(Config.Language.HerdingSuccess, 4000) break
        end
    end
    if catch == 0 or PlayerDead == true then
        VORPcore.NotifyRightTip(Config.Language.PlayerDead, 4000)
    end

    for k, v in pairs(peds) do
        DeletePed(v)
    end
    InMission = false
end

function ButcherAnimals(animaltype)
    InMission = true
    local model, tables, spawncoords
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    InMission = true
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    if animaltype == 'cows' then
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = joaat('a_c_cow')
        spawncoords = Cowcoords
    elseif animaltype == 'chickens' then
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = joaat('a_c_chicken_01')
        spawncoords = Chickencoords
    elseif animaltype == 'goats' then
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = joaat('a_c_goat_01')
        spawncoords = Goatcoords
    elseif animaltype == 'pigs' then
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = joaat('a_c_pig_01')
        spawncoords = Pigcoords
    end
    modelload(model)

    local createdped = CreatePed(model, spawncoords.x, spawncoords.y, spawncoords.z, true, true, true, true)
    SetBlockingOfNonTemporaryEvents(createdped, true)
    Citizen.InvokeNative(0x283978A15512B2FE, createdped, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
    FreezeEntityPosition(createdped, true)
    VORPcore.NotifyRightTip(Config.Language.KillAnimal, 4000)
    while true do
        Citizen.Wait(5)
        if PlayerDead then break end
        if IsEntityDead(createdped) then
            VORPcore.NotifyRightTip(Config.Language.GoSkin, 4000) break
        end
    end

    while true do
        Citizen.Wait(5)
        local pl = GetEntityCoords(PlayerPedId())
        local cp = GetEntityCoords(createdped)
        if PlayerDead then break end
        if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, cp.x, cp.y, cp.z, true) < 5 then
            BccUtils.Misc.DrawText3D(cp.x, cp.y, cp.z, Config.Language.Skin)
            if IsControlJustReleased(0, 0x760A9C6F) then
                BccUtils.Ped.ScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CROUCH_INSPECT', 5000)
                DeletePed(createdped)
                TriggerServerEvent('bcc-ranch:ButcherAnimalHandler', animaltype, RanchId, tables) break
            end
        end
    end

    if PlayerDead then
        VORPcore.NotifyRightTip(Config.Language.PlayerDead, 4000)
    end
    InMission = false
end
