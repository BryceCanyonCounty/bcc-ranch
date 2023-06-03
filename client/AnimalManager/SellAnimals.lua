-------- Function to sell animals -----------
function SellAnimals(animaltype, animal_cond)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    local tables, model
    local spawncoords = nil
    if animaltype == 'cows' then
        if Cowsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = 'a_c_cow'
        spawncoords = Cowcoords
    elseif animaltype == 'chickens' then
        if Chickensage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = 'a_c_chicken_01'
        spawncoords = Chickencoords
    elseif animaltype == 'goats' then
        if Goatsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = 'a_c_goat_01'
        spawncoords = Goatcoords
    elseif animaltype == 'pigs' then
        if Pigsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = 'a_c_pig_01'
        spawncoords = Pigcoords
    end
    InMission = true

    --Detecting Closest Sale Barn Setup Credit to vorp_core for this bit of code, and jannings for pointing this out to me
    local finalsalecoords
    local pl2 = GetEntityCoords(PlayerPedId())
    local closestDistance = math.huge
    for k, v in pairs(Config.SaleLocations) do
        local currentDistance = GetDistanceBetweenCoords(pl2.x, pl2.y, pl2.z, v.Coords.x, v.Coords.y, v.Coords.z, true)

        if currentDistance < closestDistance then
            closestDistance = currentDistance
            finalsalecoords = v.Coords
        end
    end


    local catch, peds = 0, {}
    repeat
        local createdped = BccUtils.Ped.CreatePed(model, spawncoords.x + math.random(1, 5), spawncoords.y + math.random(1, 5), spawncoords.z, true, true, false)
        SetBlockingOfNonTemporaryEvents(createdped, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
        SetEntityHealth(createdped, tables.Health, 0)
        table.insert(peds, createdped)
        catch = catch + 1
    until catch == tables.AmountSpawned
    SetRelAndFollowPlayer(peds)
    VORPcore.NotifyRightTip(_U("LeadAnimalsToSale"), 4000)
    BccUtils.Misc.SetGps(finalsalecoords.x, finalsalecoords.y, finalsalecoords.z)

    local animalsnear, doonce = false, false
    local createdped, createdped2
    while true do
        Wait(50)
        for k, v in pairs(peds) do
            local cp = GetEntityCoords(v)
            if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, finalsalecoords.x, finalsalecoords.y, finalsalecoords.z, true) < 15 then
                animalsnear = true
            else
                animalsnear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or PlayerDead == true then break end

        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, finalsalecoords.x, finalsalecoords.y, finalsalecoords.z, true)
        if dist < 5 and animalsnear == true then
            local pay
            if animal_cond >= tables.MaxCondition and catch == tables.AmountSpawned then
                pay = tables.MaxConditionPay
            end
            if animal_cond ~= tables.MaxCondition then
                pay = tables.BasePay
            end
            if catch ~= tables.AmountSpawned then
                pay = tables.LowPay
            end
            TriggerServerEvent('bcc-ranch:AnimalsSoldHandler', pay, animaltype, RanchId)
            VORPcore.NotifyRightTip(_U("AnimalsSold"), 4000) break
        elseif dist < 400 and doonce == false then
            doonce = true
            if Config.RanchSetup.WolfAttacks then
                if math.random(1, 4) == 1 or 2 then
                    createdped = BccUtils.Ped.CreatePed('A_C_Wolf', plc.x + math.random(1, 10), plc.y + math.random(1, 10), plc.z, true, true, false)
                    createdped2 = BccUtils.Ped.CreatePed('A_C_Wolf', plc.x + math.random(1, 10), plc.y + math.random(1, 10), plc.z, true, true, false)
                    Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdped)
                    Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdped2)
                    TaskCombatPed(createdped, PlayerPedId())
                    TaskCombatPed(createdped2, PlayerPedId())
                end
            end
        end
    end
    ClearGpsMultiRoute()
    if PlayerDead == true or catch == 0 then
        if doonce then
            DeletePed(createdped)
            DeletePed(createdped2)
        end
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
    end

    DelPedsForTable(peds)
    InMission = false
end