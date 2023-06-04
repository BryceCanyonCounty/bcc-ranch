-------- Function to sell animals -----------
function SellAnimals(animalType, animalCond)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    local tables, model
    local spawnCoords = nil
    if animalType == 'cows' then
        if Cowsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = 'a_c_cow'
        spawnCoords = Cowcoords
    elseif animalType == 'chickens' then
        if Chickensage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = 'a_c_chicken_01'
        spawnCoords = Chickencoords
    elseif animalType == 'goats' then
        if Goatsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = 'a_c_goat_01'
        spawnCoords = Goatcoords
    elseif animalType == 'pigs' then
        if Pigsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = 'a_c_pig_01'
        spawnCoords = Pigcoords
    end
    InMission = true

    --Detecting Closest Sale Barn Setup Credit to vorp_core for this bit of code, and jannings for pointing this out to me
    local finalSaleCoords
    local pl2 = GetEntityCoords(PlayerPedId())
    local closestDistance = math.huge
    for k, v in pairs(Config.SaleLocations) do
        local currentDistance = GetDistanceBetweenCoords(pl2.x, pl2.y, pl2.z, v.Coords.x, v.Coords.y, v.Coords.z, true)

        if currentDistance < closestDistance then
            closestDistance = currentDistance
            finalSaleCoords = v.Coords
        end
    end


    local catch, peds = 0, {}
    repeat
        local createdPed = BccUtils.Ped.CreatePed(model, spawnCoords.x + math.random(1, 5), spawnCoords.y + math.random(1, 5), spawnCoords.z, true, true, false)
        SetBlockingOfNonTemporaryEvents(createdPed, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
        SetEntityHealth(createdPed, tables.Health, 0)
        table.insert(peds, createdPed)
        catch = catch + 1
    until catch == tables.AmountSpawned
    SetRelAndFollowPlayer(peds)
    VORPcore.NotifyRightTip(_U("LeadAnimalsToSale"), 4000)
    BccUtils.Misc.SetGps(finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z)

    local animalsNear, doOnce = false, false
    local createdPed, createdPed2
    while true do
        Wait(50)
        for k, v in pairs(peds) do
            local cp = GetEntityCoords(v)
            if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z, true) < 15 then
                animalsNear = true
            else
                animalsNear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or PlayerDead == true then break end

        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z, true)
        if dist < 5 and animalsNear == true then
            local pay
            if animalCond >= tables.MaxCondition and catch == tables.AmountSpawned then
                pay = tables.MaxConditionPay
            end
            if animalCond ~= tables.MaxCondition then
                pay = tables.BasePay
            end
            if catch ~= tables.AmountSpawned then
                pay = tables.LowPay
            end
            TriggerServerEvent('bcc-ranch:AnimalsSoldHandler', pay, animalType, RanchId)
            VORPcore.NotifyRightTip(_U("AnimalsSold"), 4000) break
        elseif dist < 400 and doOnce == false then
            doOnce = true
            if Config.RanchSetup.WolfAttacks then
                if math.random(1, 4) == 1 or 2 then
                    createdPed = BccUtils.Ped.CreatePed('A_C_Wolf', plc.x + math.random(1, 10), plc.y + math.random(1, 10), plc.z, true, true, false)
                    createdPed2 = BccUtils.Ped.CreatePed('A_C_Wolf', plc.x + math.random(1, 10), plc.y + math.random(1, 10), plc.z, true, true, false)
                    Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdPed)
                    Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdPed2)
                    TaskCombatPed(createdPed, PlayerPedId())
                    TaskCombatPed(createdPed2, PlayerPedId())
                end
            end
        end
    end
    ClearGpsMultiRoute()
    if PlayerDead == true or catch == 0 then
        if doonce then
            DeletePed(createdPed)
            DeletePed(createdPed2)
        end
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
    end

    DelPedsForTable(peds)
    InMission = false
end