--Feed animals function
local animalsDead, feedPeds = false, {}
local amount
RegisterNetEvent('bcc-ranch:FeedAnimals', function(animalType)
    InMission = true
    local tables, model, spawnCoords, eatAnim
    local scale = nil
    feedPeds = {} --Feedpeds is set to nil when the mission is over or player dies to empty the table, this sets it from nil to table allowing this to work again (if it is not set nil when the mission is over or failed it will fail the mission the next time you do one)

    local selectAnimalFuncts = {
        ['cows'] = function()
            tables = Config.RanchSetup.RanchAnimalSetup.Cows
            model = 'a_c_cow'
            eatAnim = joaat("WORLD_ANIMAL_COW_EATING_GROUND")
            spawnCoords = Cowcoords
            if Cowsage < Config.RanchSetup.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['chickens'] = function()
            tables = Config.RanchSetup.RanchAnimalSetup.Chickens
            model = 'a_c_chicken_01'
            eatAnim = joaat("WORLD_ANIMAL_CHICKEN_EATING")
            spawnCoords = Chickencoords
            if Chickensage < Config.RanchSetup.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['goats'] = function()
            tables = Config.RanchSetup.RanchAnimalSetup.Goats
            model = 'a_c_goat_01'
            spawnCoords = Goatcoords
            eatAnim = joaat("PROP_ANIMAL_GOAT_EAT_TROUGH")
            if Goatsage < Config.RanchSetup.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['pigs'] = function()
            tables = Config.RanchSetup.RanchAnimalSetup.Pigs
            model = 'a_c_pig_01'
            spawnCoords = Pigcoords
            eatAnim = joaat("WORLD_ANIMAL_PIG_EAT_CARCASS")
            if Pigsage < Config.RanchSetup.AnimalGrownAge then
                scale = 0.5
            end
        end
    }
    if selectAnimalFuncts[animalType] then
        selectAnimalFuncts[animalType]()
    end

    amount = tables.AmountSpawned

    local catch = 0
    repeat
        local createdPed = BccUtils.Ped.CreatePed(model, spawnCoords.x + math.random(1, 5),
            spawnCoords.y + math.random(1, 5), spawnCoords.z, true, true, false)
        if scale ~= nil then
            SetPedScale(createdPed, scale)
        end
        SetBlockingOfNonTemporaryEvents(createdPed, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
        table.insert(feedPeds, createdPed)
        SetEntityHealth(createdPed, tables.Health, 0)
        catch = catch + 1
    until catch == tables.AmountSpawned
    SetRelAndFollowPlayer(feedPeds)

    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    local car = joaat('cart06')
    RequestModel(car)
    while not HasModelLoaded(car) do
        Wait(100)
    end
    local vehicle = Citizen.InvokeNative(0x214651FB1DFEBA89, car, FeedWagonLocation.x, FeedWagonLocation.y,
        FeedWagonLocation.z, 100.0, true, false, 0, 1)
    while not DoesEntityExist(vehicle) do
        Wait(5)
    end
    SetVehicleOnGroundProperly(vehicle)
    local crate, crate2, crate3
    for i = 1, 3 do --credit to jannings for this amazing work here
        if i == 1 then
            crate = CreateObject('p_haybale01x', 0, 0, 0 + 1, false, false, false)
            Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate, vehicle, 0, 0.1, 0.2, 0.60, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2,
                true)
        elseif i == 2 then
            crate2 = CreateObject('p_haybale01x', 0, 0, 0 + 1, false, false, false)
            Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate2, vehicle, 0, 0.1, -0.5, 0.09, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2,
                true)
        elseif i == 3 then
            crate3 = CreateObject('p_haybale01x', 0, 0, 0 + 1, false, false, false)
            Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate3, vehicle, 0, 0.1, 0.5, 0.09, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2,
                true)
        end
    end

    VORPcore.NotifyRightTip(_U("FeedAnimalLocation"), 4000)

    local animalsNear
    while true do
        Wait(200)
        local pl = GetEntityCoords(vehicle)
        local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, true)
        if dist > 50 then
            for k, v in pairs(feedPeds) do
                local cp = GetEntityCoords(v)
                if GetDistanceBetweenCoords(cp.x, cp.y, cp.z, pl.x, pl.y, pl.z, true) < 35 then
                    animalsNear = true
                else
                    animalsNear = false
                end
                if IsEntityDead(v) then
                    catch = catch - 1
                    if catch == 0 then
                        animalsDead = true
                        break
                    end
                end
            end
            if animalsNear then break end
        end

        if PlayerDead then break end
    end
    if PlayerDead or animalsDead then
        DelPedsForTable(feedPeds)
        DeleteVehicle(vehicle)
        DeleteEntity(crate)
        DeleteEntity(crate2)
        DeleteEntity(crate3)
        feedPeds = nil
        if animalsDead then
            TriggerServerEvent('bcc-ranch:RemoveAnimalFromDB', RanchId, animalType)
        end
        InMission = false
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
        return
    end
    FreezeEntityPosition(vehicle, true)
    TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)
    Wait(3000)

    VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000)

    local repAmount = 0
    local PromptGroup2 = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("PickUpHay"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    repeat
        while true do
            Wait(5)
            local pl = GetEntityCoords(PlayerPedId())
            local cw = GetEntityCoords(vehicle)
            local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, cw.x, cw.y, cw.z, true)
            for k, v in pairs(feedPeds) do
                if IsEntityDead(v) then
                    catch = catch - 1
                    if catch == 0 then
                        animalsDead = true
                        break
                    end
                end
            end
            if PlayerDead then break end
            if dist < 3 then
                PromptGroup2:ShowGroup('')
                if firstprompt2:HasCompleted() then
                    if repAmount == 0 then
                        repAmount = repAmount + 1
                        VORPcore.NotifyRightTip(_U("WalkAwayAndPlacehay"), 4000)
                        PlayerCarryBox(crate)
                        PickUpAndDropHay(crate, vehicle)
                        VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000)
                        break
                    elseif repAmount == 1 then
                        repAmount = repAmount + 1
                        VORPcore.NotifyRightTip(_U("WalkAwayAndPlacehay"), 4000)
                        PlayerCarryBox(crate2)
                        PickUpAndDropHay(crate2, vehicle)
                        VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000)
                        break
                    elseif repAmount == 2 then
                        repAmount = repAmount + 1
                        VORPcore.NotifyRightTip(_U("WalkAwayAndPlacehay"), 4000)
                        PlayerCarryBox(crate3)
                        PickUpAndDropHay(crate3, vehicle)
                        VORPcore.NotifyRightTip(_U("FeedAnimalsAfterLocation"), 4000)
                        break
                    end
                end
            end
        end
    until repAmount == 3
    if PlayerDead or animalsDead then
        DelPedsForTable(feedPeds)
        DeleteVehicle(vehicle)
        DeleteEntity(crate)
        DeleteEntity(crate2)
        DeleteEntity(crate3)
        feedPeds = nil
        if animalsDead then
            TriggerServerEvent('bcc-ranch:RemoveAnimalFromDB', RanchId, animalType)
        end
        InMission = false
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
        return
    end
    FreezeEntityPosition(vehicle, false)
    for k, v in pairs(feedPeds) do
        local cw = GetEntityCoords(crate)
        ClearPedTasksImmediately(v)
        TaskPedSlideToCoord(v, cw.x + math.random(1, 5), cw.y + math.random(1, 5), cw.z, 50, true)
        Wait(1500)
        TaskStartScenarioInPlace(v, eatAnim, -1)
    end

    VORPcore.NotifyRightTip(_U("NowReturn"), 4000)
    BccUtils.Misc.SetGps(FeedWagonLocation.x, FeedWagonLocation.y, FeedWagonLocation.z)

    while true do
        Wait(200)
        local cw = GetEntityCoords(vehicle)
        if PlayerDead then break end
        if GetEntityHealth(vehicle) == 0 then break end
        if GetDistanceBetweenCoords(cw.x, cw.y, cw.z, FeedWagonLocation.x, FeedWagonLocation.y, FeedWagonLocation.z, true) < 15 then break end
    end
    ClearGpsMultiRoute()
    if PlayerDead == true or GetEntityHealth(vehicle) == 0 then
        DelPedsForTable(feedPeds)
        DeleteVehicle(vehicle)
        DeleteEntity(crate)
        DeleteEntity(crate2)
        DeleteEntity(crate3)
        feedPeds = nil
        InMission = false
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
        return
    end
    FreezeEntityPosition(vehicle, true)
    TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)
    Wait(3000)

    VORPcore.NotifyRightTip(_U("AnimalsFed"), 4000)
    DelPedsForTable(feedPeds)
    TriggerServerEvent('bcc-ranch:AnimalCondIncrease', animalType, tables.FeedAnimalCondIncrease, RanchId)
    DeleteEntity(vehicle)
    DeleteEntity(crate)
    DeleteEntity(crate2)
    DeleteEntity(crate3)
    feedPeds = nil
    InMission = false
    TriggerServerEvent('bcc-ranch:PutAnimalsBack', RanchId)
end)

--Function for making player carry hay
function PlayerCarryBox(props)                       --catches var from wherever it is called
    RequestAnimDict("mech_carry_box")                --loads the anim
    while not HasAnimDictLoaded("mech_carry_box") do --while the anim hasnt loaded do
        Wait(100)
    end
    local pl = PlayerPedId()
    Citizen.InvokeNative(0xEA47FE3719165B94, pl, "mech_carry_box", "idle", 1.0, 8.0, -1, 31, 0, 0, 0, 0)                                                                           --plays animation
    Citizen.InvokeNative(0x6B9BBD38AB0796DF, props, pl, GetEntityBoneIndexByName(pl, "SKEL_R_Finger12"), 0.20, 0.028,
        -0.55, 210.0, 170.0, 100.0, true, true, false, true, 1, true)                                                                                                              --puts object in your hand
end

-- function for getting the hay off the wagon and placing on the ground
function PickUpAndDropHay(crate, vehicle)
    local PromptGroup2 = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("DropHay"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    while true do
        Wait(5)
        local pl2 = GetEntityCoords(PlayerPedId())
        local cw2 = GetEntityCoords(vehicle)
        if PlayerDead then break end
        for k, v in pairs(feedPeds) do
            if IsEntityDead(v) then
                amount = amount - 1
                if amount == 0 then
                    animalsDead = true
                    break
                end
            end
        end
        if GetDistanceBetweenCoords(pl2.x, pl2.y, pl2.z, cw2.x, cw2.y, cw2.z, true) > 5 then
            PromptGroup2:ShowGroup('')
            if firstprompt2:HasCompleted() then
                DetachEntity(crate, true, true)
                ClearPedTasksImmediately(PlayerPedId())
                Citizen.InvokeNative(0x9587913B9E772D29, crate, true)
                break
            end
        end
    end
end
