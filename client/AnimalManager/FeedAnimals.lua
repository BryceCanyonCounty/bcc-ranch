--Feed animals function
local animalsdead, feedpeds = false, {}
local amount
function FeedAnimals(animaltype)
    InMission = true
    local tables, model, spawncoords, eatanim
    if animaltype == 'cows' then
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = 'a_c_cow'
        eatanim = joaat("WORLD_ANIMAL_COW_EATING_GROUND")
        spawncoords = Cowcoords
    elseif animaltype == 'chickens' then
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = 'a_c_chicken_01'
        eatanim = joaat("WORLD_ANIMAL_CHICKEN_EATING")
        spawncoords = Chickencoords
    elseif animaltype == 'goats' then
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = 'a_c_goat_01'
        spawncoords = Goatcoords
        eatanim = joaat("PROP_ANIMAL_GOAT_EAT_TROUGH")
    elseif animaltype == 'pigs' then
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = 'a_c_pig_01'
        spawncoords = Pigcoords
        eatanim = joaat("WORLD_ANIMAL_PIG_EAT_CARCASS")
    end
    amount = tables.AmountSpawned

    local catch = 0
    repeat
        local createdped = BccUtils.Ped.CreatePed(model, spawncoords.x + math.random(1, 5), spawncoords.y + math.random(1, 5), spawncoords.z, true, true, false)
        SetBlockingOfNonTemporaryEvents(createdped, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
        table.insert(feedpeds, createdped)
        SetEntityHealth(createdped, tables.Health, 0)
        catch = catch + 1
    until catch == tables.AmountSpawned
    SetRelAndFollowPlayer(feedpeds)

    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    local car = joaat('cart06')
    RequestModel(car)
    while not HasModelLoaded(car) do
        Wait(100)
    end
    local vehicle = Citizen.InvokeNative(0x214651FB1DFEBA89, car, FeedWagonLocation.x, FeedWagonLocation.y, FeedWagonLocation.z, 100.0, false, false, 0, 1)
    while not DoesEntityExist(vehicle) do
        Wait(5)
    end
    SetVehicleOnGroundProperly(vehicle)
    local crate, crate2, crate3
    for i = 1, 3 do --credit to jannings for this amazing work here
        if i == 1 then
            crate = CreateObject('p_haybale01x', 0, 0, 0 + 1, false, false, false)
            Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate, vehicle, 0, 0.1, 0.5, 0.09, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, true)
        elseif i == 2 then
            crate2 = CreateObject('p_haybale01x', 0, 0, 0 + 1, false, false, false)
            Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate2, vehicle, 0, 0.1, -0.5, 0.09, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, true)
        elseif i == 3 then
            crate3 = CreateObject('p_haybale01x', 0, 0, 0 + 1, false, false, false)
            Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate3, vehicle, 0, 0.1, 0.2, 0.60, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, true)
        end
    end

    VORPcore.NotifyRightTip(_U("FeedAnimalLocation"), 4000)

    local animalsnear
    while true do
        Wait(200)
        local pl = GetEntityCoords(vehicle)
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, true)
        if dist > 50 then

            for k, v in pairs(feedpeds) do
                local cp = GetEntityCoords(v)
                if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, pl.x, pl.y, pl.z, true) < 35 then
                    animalsnear = true
                else
                    animalsnear = false
                end
                if IsEntityDead(v) then
                    catch = catch - 1
                end
            end
            if animalsnear then break end
        end

        if dist < 30 then Wait(200) end
        
        for k, v in pairs(feedpeds) do
            if IsEntityDead(v) then
                catch = catch - 1
                if catch == 0 then
                    animalsdead = true break
                end
            end
        end
        if PlayerDead then break end
    end
    if PlayerDead == true or animalsdead == true then
        if animalsdead then
            TriggerServerEvent('bcc-ranch:RemoveAnimalFromDB', RanchId, animaltype)
        end
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) return
    end
    FreezeEntityPosition(vehicle, true)
    TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)
    Wait(3000)

    VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000)

    local repamount = 0
    local PromptGroup2 = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("PickUpHay"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    repeat
        while true do
            Wait(5)
            local pl = GetEntityCoords(PlayerPedId())
            local cw = GetEntityCoords(vehicle)
            local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, cw.x, cw.y, cw.z, true)
            for k, v in pairs(feedpeds) do
                if IsEntityDead(v) then
                    catch = catch - 1
                    if catch == 0 then
                        animalsdead = true break
                    end
                end
            end
            if PlayerDead then break end
            if dist < 3 then
                PromptGroup2:ShowGroup('')
                if firstprompt2:HasCompleted() then
                    if repamount == 0 then
                        repamount = repamount + 1
                        VORPcore.NotifyRightTip(_U("WalkAwayAndPlacehay"), 4000)
                        PlayerCarryBox(crate)
                        PickUpAndDropHay(crate, vehicle)
                        VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000) break
                    elseif repamount == 1 then
                        repamount = repamount + 1
                        VORPcore.NotifyRightTip(_U("WalkAwayAndPlacehay"), 4000)
                        PlayerCarryBox(crate2)
                        PickUpAndDropHay(crate2, vehicle)
                        VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000) break
                    elseif repamount == 2 then
                        repamount = repamount + 1
                        VORPcore.NotifyRightTip(_U("WalkAwayAndPlacehay"), 4000)
                        PlayerCarryBox(crate3)
                        PickUpAndDropHay(crate3, vehicle)
                        VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000) break
                    end
                end
            end
        end
    until repamount == 3
    if PlayerDead or animalsdead then
        if animalsdead then
            TriggerServerEvent('bcc-ranch:RemoveAnimalFromDB', RanchId, animaltype)
        end
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) return
    end
    for k, v in pairs(feedpeds) do
        local cw = GetEntityCoords(crate)
        ClearPedTasksImmediately(v)
        TaskPedSlideToCoord(v, cw.x + math.random(1, 5), cw.y + math.random(1, 5), cw.z, 50, true)
        Wait(1500)
        TaskStartScenarioInPlace(v, eatanim, -1)
    end

    VORPcore.NotifyRightTip(_U("NowReturn"), 4000)
    FreezeEntityPosition(vehicle, false)
    BccUtils.Misc.SetGps(FeedWagonLocation.x, FeedWagonLocation.y, FeedWagonLocation.z)

    while true do
        Wait(200)
        local cw = GetEntityCoords(vehicle)
        if PlayerDead then break end
        if GetEntityHealth(vehicle) == 0 then break end
        if GetDistanceBetweenCoords(cw.x, cw.y, cw.z, FeedWagonLocation.x, FeedWagonLocation.y, FeedWagonLocation.z, true) < 15 then break end
    end
    if PlayerDead == true or GetEntityHealth(vehicle) == 0 then
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) return
    end
    ClearGpsMultiRoute()
    FreezeEntityPosition(vehicle, true)
    TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)
    Wait(3000)

    VORPcore.NotifyRightTip(_U("AnimalsFed"), 4000)
    DelPedsForTable(feedpeds)
    TriggerServerEvent('bcc-ranch:AnimalCondIncrease', animaltype, tables.FeedAnimalCondIncrease, RanchId)
    DeleteEntity(vehicle)
    DeleteEntity(crate)
    DeleteEntity(crate2)
    DeleteEntity(crate3)
    InMission = false
end

--Function for making player carry hay
function PlayerCarryBox(props) --catches var from wherever it is called
    RequestAnimDict("mech_carry_box") --loads the anim
    while not HasAnimDictLoaded("mech_carry_box") do --while the anim hasnt loaded do
        Wait(100)
    end
    local pl = PlayerPedId()
    Citizen.InvokeNative(0xEA47FE3719165B94, pl ,"mech_carry_box", "idle", 1.0, 8.0, -1, 31, 0, 0, 0, 0) --plays animation
    Citizen.InvokeNative(0x6B9BBD38AB0796DF, props, pl ,GetEntityBoneIndexByName(pl,"SKEL_R_Finger12"), 0.20, 0.028, -0.55, 210.0, 170.0, 100.0, true, true, false, true, 1, true) --puts object in your hand
end

-- function for getting the hay off the wagon and placing on the ground
function PickUpAndDropHay(crate, vehicle)
    local PromptGroup2 = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("DropHay"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while true do
        Wait(5)
        local pl2 = GetEntityCoords(PlayerPedId())
        local cw2 = GetEntityCoords(vehicle)
        if PlayerDead then break end
        for k, v in pairs(feedpeds) do
            if IsEntityDead(v) then
                amount = amount - 1
                if amount == 0 then
                    animalsdead = true break
                end
            end
        end
        if GetDistanceBetweenCoords(pl2.x, pl2.y, pl2.z, cw2.x, cw2.y, cw2.z, true) > 5 then
            PromptGroup2:ShowGroup('')
            if firstprompt2:HasCompleted() then
                DetachEntity(crate, true, true)
                ClearPedTasksImmediately(PlayerPedId())
                Citizen.InvokeNative(0x9587913B9E772D29, crate, true) break
            end
        end
    end
end