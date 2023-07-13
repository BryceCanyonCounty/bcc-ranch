------ This is the herding function to increase animal cond -----
function herdanimals(animalType, ranchCond)
    local pl, scale = PlayerPedId(), nil
    local model, tables
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

    -- added / changed by Little Creek
    -- this was requested to add a chance to get attacked by wolves
    -- while herding the animals
    -- TODO: change some of these to config.lua
    local totalDist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, Herdlocation.x, Herdlocation.y, Herdlocation.z, true)
    local halfDist = totalDist / 2
    local animalsNear, wolvesAttackedHerd, maxWolvesPerAttack = false, false, 3

    while true do
        if Config.RanchSetup.WolfAttacks and not wolvesAttackedHerd then
            -- check if the current distance of the player to the herd location is within 20% of the halfDist
            local plcw = GetEntityCoords(pl)
            local curDist = GetDistanceBetweenCoords(plcw.x, plcw.y, plcw.z, Herdlocation.x, Herdlocation.y, Herdlocation.z, true)
            Wait(500)
            if curDist >= (halfDist - (halfDist * 0.2)) and curDist <= (halfDist + (halfDist * 0.2)) then
                -- now this will check every Wait(50) so very often and even with very low chances most likely trigger guaranteed
                if math.random(1, 4) == 1 then
                    local spawnCount = math.random(1, maxWolvesPerAttack)
                    if 1 <= spawnCount then
                        local createdPed1 = BccUtils.Ped.CreatePed('A_C_Wolf', plcw.x + math.random(1, 10), plcw.y + math.random(1, 10), plcw.z, true, true, false)
                        Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdPed1)
                        TaskCombatPed(createdPed1, PlayerPedId())
                    end
                    if 2 <= spawnCount then
                        local createdPed2 = BccUtils.Ped.CreatePed('A_C_Wolf', plcw.x + math.random(1, 10), plcw.y + math.random(1, 10), plcw.z, true, true, false)
                        Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdPed2)
                        TaskCombatPed(createdPed2, PlayerPedId())
                    end
                    if 3 <= spawnCount then
                        local createdPed3 = BccUtils.Ped.CreatePed('A_C_Wolf', plcw.x + math.random(1, 10), plcw.y + math.random(1, 10), plcw.z, true, true, false)
                        Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdPed3)
                        TaskCombatPed(createdPed3, PlayerPedId())
                    end
                    wolvesAttackedHerd = true
                end
            end
        end
        -- end added / changed by Little Creek
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