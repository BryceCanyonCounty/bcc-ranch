------ This is the herding function to increase animal cond -----
function herdanimals(animalType, ranchCond)
    local pl = PlayerPedId()
    local model, tables
    local scale = nil
    InMission = true
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    if animalType == 'cows' then
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = 'a_c_cow'
        if Cowsage < Config.RanchSetup.AnimalGrownAge then
            scale = 0.5
        end
    elseif animalType == 'chickens' then
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = 'a_c_chicken_01'
        if Chickensage < Config.RanchSetup.AnimalGrownAge then
            scale = 0.5
        end
    elseif animalType == 'goats' then
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = 'a_c_goat_01'
        if Goatsage < Config.RanchSetup.AnimalGrownAge then
            scale = 0.5
        end
    elseif animalType == 'pigs' then
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = 'a_c_pig_01'
        if Pigsage < Config.RanchSetup.AnimalGrownAge then
            scale = 0.5
        end
    end

    local catch, peds, plc = 0, {}, GetEntityCoords(pl)
    repeat
        local createdPed = BccUtils.Ped.CreatePed(model, plc.x + math.random(1, 5), plc.y + math.random(1, 5), plc.z, true, true, false)
        SetBlockingOfNonTemporaryEvents(createdPed, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
        if scale ~= nil then
            SetPedScale(createdPed, scale)
        end
        table.insert(peds, createdPed)
        SetEntityHealth(createdPed, tables.Health, 0)
        catch = catch + 1
    until catch == tables.AmountSpawned
    SetRelAndFollowPlayer(peds)
    BccUtils.Misc.SetGps(Herdlocation.x, Herdlocation.y, Herdlocation.z)
    VORPcore.NotifyRightTip(_U("HerdToLocation"), 4000)

    local animalsNear = false
    while true do
        Wait(50)
        for k, v in pairs(peds) do
            local cp = GetEntityCoords(v)
            if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, Herdlocation.x, Herdlocation.y, Herdlocation.z, true) < 15 then
                animalsNear = true
            else
                animalsNear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or PlayerDead == true then break end

        local plc2 = GetEntityCoords(pl)
        if GetDistanceBetweenCoords(plc2.x, plc2.y, plc2.z, Herdlocation.x, Herdlocation.y, Herdlocation.z, true) < 5 and animalsNear == true then
            animalsNear = false
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
                animalsNear = true
            else
                animalsNear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or PlayerDead == true then break end

        local plc2 = GetEntityCoords(pl)
        if GetDistanceBetweenCoords(plc2.x, plc2.y, plc2.z, plc.x, plc.y, plc.z, true) < 5 and animalsNear == true then
            if ranchCond ~= Config.RanchSetup.MaxRanchCondition and catch == tables.AmountSpawned then
                TriggerServerEvent('bcc-ranch:AnimalCondIncrease', animalType, tables.CondIncreasePerHerdNotMaxRanchCond, RanchId)
            else
                TriggerServerEvent('bcc-ranch:AnimalCondIncrease', animalType, tables.CondIncreasePerHerd, RanchId)
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