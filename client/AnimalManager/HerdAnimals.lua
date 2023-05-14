------ This is the herding function to increase animal cond -----
function herdanimals(animaltype, ranchcond)
    local pl = PlayerPedId()
    local model, tables
    InMission = true
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    if animaltype == 'cows' then
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = 'a_c_cow'
    elseif animaltype == 'chickens' then
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = 'a_c_chicken_01'
    elseif animaltype == 'goats' then
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = 'a_c_goat_01'
    elseif animaltype == 'pigs' then
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = 'a_c_pig_01'
    end

    local catch, peds, plc = 0, {}, GetEntityCoords(pl)
    repeat
        local createdped = BccUtils.Ped.CreatePed(model, plc.x + math.random(1, 5), plc.y + math.random(1, 5), plc.z, true, true, false)
        SetBlockingOfNonTemporaryEvents(createdped, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
        table.insert(peds, createdped)
        SetEntityHealth(createdped, tables.Health, 0)
        catch = catch + 1
    until catch == tables.AmountSpawned
    SetRelAndFollowPlayer(peds)
    BccUtils.Misc.SetGps(Herdlocation.x, Herdlocation.y, Herdlocation.z)
    VORPcore.NotifyRightTip(_U("HerdToLocation"), 4000)

    local animalsnear = false
    while true do
        Wait(50)
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
            VORPcore.NotifyRightTip(_U("ReturnAnimals"), 4000) break
        end
    end

    BccUtils.Misc.SetGps(plc.x, plc.y, plc.z)
    while true do
        Wait(50)
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
            VORPcore.NotifyRightTip(_U("HerdingSuccess"), 4000) break
        end
    end
    if catch == 0 or PlayerDead == true then
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
    end

    DelPedsForTable(peds)
    InMission = false
end