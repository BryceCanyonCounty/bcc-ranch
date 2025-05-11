local animalsDead, feedPeds = false, {}
local crate, crate2, crate3, vehicle, amount

--Function for making player carry hay
local function playerCarryHay(crateObj)
    RequestAnimDict("mech_carry_box")
    while not HasAnimDictLoaded("mech_carry_box") do Wait(100) end

    local pl = PlayerPedId()
    local obj = crateObj:GetObj()
    TaskPlayAnim(pl, "mech_carry_box", "idle", 1.0, 8.0, -1, 31, 0, 0, 0, 0)
    AttachEntityToEntity(obj, pl, GetEntityBoneIndexByName(pl, "SKEL_R_Finger12"), 0.20, 0.028, -0.55, 210.0, 170.0, 100.0, true, true, false, true, 1, true)    
end


local function delPedsForTable(feedPeds)
    if type(feedPeds) == "table" then
        for _, createdPed in ipairs(feedPeds) do
            if createdPed and createdPed.Remove then
                createdPed:Remove()
            end
        end
    end
    -- Reset anyway
    feedPeds = {}
end

local function cleanUpFeedMission()
    if vehicle and DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
        vehicle = nil
    end

    for _, obj in ipairs({ crate, crate2, crate3 }) do
        if obj and obj.Remove then
            obj:Remove()
        end
    end
    crate, crate2, crate3 = nil, nil, nil

    ClearGpsMultiRoute()
    IsInMission = false
end

-- function for getting the hay off the wagon and placing on the ground
local function pickUpAndDropHay(crate, vehicle)
    local PromptGroup2 = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("dropHay"), BccUtils.Keys[ConfigRanch.ranchSetup.dropHayKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    while true do
        Wait(5)
        if PlayerDead then break end

        for k, v in pairs(feedPeds) do
            if IsEntityDead(v:GetPed()) then
                amount = amount - 1
                if amount == 0 then
                    animalsDead = true
                    break
                end
            end
        end

        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle)) > 5 then
            PromptGroup2:ShowGroup('')

            if firstprompt2:HasCompleted() then
                local obj = crate:GetObj()
                DetachEntity(obj, true, true)
                ClearPedTasksImmediately(PlayerPedId())
                Citizen.InvokeNative(0x9587913B9E772D29, obj, true) -- Place object on ground
                break
            end
        end
    end
end


RegisterNetEvent('bcc-ranch:FeedAnimals', function(animalType)
    IsInMission = true
    BCCRanchMenu:Close()

    local tables, model, spawnCoords, eatAnim
    local scale, isDead = nil, false
    local feedWagonLocation = json.decode(RanchData.feed_wagon_coords)
    feedPeds = {}
    local selectAnimalFuncts = {
        ['cows'] = function()
            tables = ConfigAnimals.animalSetup.cows
            model = 'a_c_cow'
            eatAnim = joaat("WORLD_ANIMAL_COW_EATING_GROUND")
            spawnCoords = json.decode(RanchData.cow_coords)
            if tonumber(RanchData.cows_age) < tables.AnimalGrownAge then scale = 0.5 end
        end,
        ['pigs'] = function()
            tables = ConfigAnimals.animalSetup.pigs
            model = 'a_c_pig_01'
            spawnCoords = json.decode(RanchData.pig_coords)
            eatAnim = joaat("WORLD_ANIMAL_PIG_EAT_CARCASS")
            if tonumber(RanchData.pigs_age) < tables.AnimalGrownAge then scale = 0.5 end
        end,
        ['sheeps'] = function()
            tables = ConfigAnimals.animalSetup.sheeps
            model = 'a_c_sheep_01'
            spawnCoords = json.decode(RanchData.sheep_coords)
            eatAnim = joaat("WORLD_ANIMAL_SHEEP_EATING_GROUND")
            if tonumber(RanchData.sheeps_age) < tables.AnimalGrownAge then scale = 0.5 end
        end,
        ['goats'] = function()
            tables = ConfigAnimals.animalSetup.goats
            model = 'a_c_goat_01'
            spawnCoords = json.decode(RanchData.goat_coords)
            eatAnim = joaat("PROP_ANIMAL_GOAT_EAT_TROUGH")
            if tonumber(RanchData.goats_age) < tables.AnimalGrownAge then scale = 0.5 end
        end,
        ['chickens'] = function()
            tables = ConfigAnimals.animalSetup.chickens
            model = 'a_c_chicken_01'
            eatAnim = joaat("WORLD_ANIMAL_CHICKEN_EATING")
            spawnCoords = json.decode(RanchData.chicken_coords)
            if tonumber(RanchData.chickens_age) < tables.AnimalGrownAge then scale = 0.5 end
        end
    }
    if selectAnimalFuncts[animalType] then
        selectAnimalFuncts[animalType]()
    end
    -- Check if spawnCoords is nil, notify the player if true
    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        ManageOwnedAnimalsMenu()
        IsInMission = false
        return
    end

    -- Spawn Feed Animals
    local catch = 0
    repeat
        local createdPed = BccUtils.Ped:Create(model, spawnCoords.x + math.random(1, 5), spawnCoords.y + math.random(1, 5), spawnCoords.z, 0.0, "world", false, nil, nil, true)
        if createdPed then
            if scale then
                SetPedScale(createdPed:GetPed(), scale)
            end
            createdPed:SetBlip(54149631, "Your Animal")
            BccUtils.Ped.SetPedHealth(createdPed:GetPed(), tables.animalHealth)
            table.insert(feedPeds, createdPed)
            catch = catch + 1
        end
    until catch == tables.spawnAmount

    amount = tables.spawnAmount
    SetRelAndFollowPlayer(feedPeds)
    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = true }, function(success)
        if success then
            devPrint("Animals out status updated successfully!")
        else
            devPrint("Failed to update animals out status!")
        end
    end)

    -- Create Feed Wagon
    RequestModel(joaat('cart06'))
    while not HasModelLoaded(joaat('cart06')) do Wait(10) end
    vehicle = CreateVehicle(joaat('cart06'), feedWagonLocation.x, feedWagonLocation.y, feedWagonLocation.z, 0.0, true, false)
    while not DoesEntityExist(vehicle) do Wait(10) end
    SetVehicleOnGroundProperly(vehicle)
    Wait(100)

    -- Create Hay Crates
    crate = BccUtils.Object:Create("p_haybale01x", 0, 0, 0, 0.0, false)
    Wait(0)
    crate2 = BccUtils.Object:Create("p_haybale01x", 0, 0, 0, 0.0, false)
    Wait(0)
    crate3 = BccUtils.Object:Create("p_haybale01x", 0, 0, 0, 0.0, false)
    Wait(0)

    Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate:GetObj(), vehicle, 0, 0.1, 0.2, 0.60, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, true)
    Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate2:GetObj(), vehicle, 0, 0.1, -0.5, 0.09, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, true)
    Citizen.InvokeNative(0x6B9BBD38AB0796DF, crate3:GetObj(), vehicle, 0, 0.1, 0.5, 0.09, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, true)


    VORPcore.NotifyRightTip(_U("goFeedYourAnimals"), 4000)

    local animalsNear = false
    while true do
        Wait(200)
        local pl = GetEntityCoords(vehicle)

        if #(pl - RanchData.ranchcoordsVector3) > 50 then
            devPrint("Wagon is outside ranch area.")
            FreezeEntityPosition(vehicle, true)
            TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)

            animalsNear = true
            local deadAnimals = 0
    
            for k, v in pairs(feedPeds) do
                if v and v.GetPed and DoesEntityExist(v:GetPed()) then
                    local ped = v:GetPed()
                    local animalCoords = GetEntityCoords(ped)
                    local distance = #(pl - animalCoords)
    
                    devPrint(("Animal %s distance to wagon: %.2f"):format(k, distance))
    
                    if distance >= 35 then
                        animalsNear = false
                        devPrint(("Animal %s is too far from wagon."):format(k))
                        break -- no need to check others
                    end
    
                    if IsEntityDead(ped) then
                        deadAnimals = deadAnimals + 1
                        devPrint(("Animal %s is dead. Dead count: %s"):format(k, deadAnimals))
                    end
                end
            end
    
            if deadAnimals == #feedPeds then
                animalsDead = true
                devPrint("All animals are dead. Failing mission.")
                break
            end
    
            if animalsNear then
                devPrint("All animals are near the wagon. Proceeding...")
                break
            end
        end
    
        if IsEntityDead(PlayerPedId()) then
            isDead = true
            devPrint("Player is dead. Cancelling feeding mission.")
            break
        end
    end
    

    local function cleanVehicleAndCrates()
        devPrint("Cleaning up vehicle and hay crates.")
        if DoesEntityExist(vehicle) then
            DeleteVehicle(vehicle)
            devPrint("Vehicle deleted.")
        end
        if crate then
            crate:Remove()
            devPrint("Crate 1 removed.")
        end
        if crate2 then
            crate2:Remove()
            devPrint("Crate 2 removed.")
        end
        if crate3 then
            crate3:Remove()
            devPrint("Crate 3 removed.")
        end
    end

    if isDead or animalsDead then
        delPedsForTable(feedPeds)
        cleanVehicleAndCrates()
        feedPeds = nil
        IsInMission = false
        VORPcore.NotifyRightTip(_U("failed"), 4000)
        return
    end
    FreezeEntityPosition(vehicle, true)
    TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)
    Wait(3000)

    VORPcore.NotifyRightTip(_U("unloadHay"), 4000)

    local repAmount = 0
    local PromptGroup2 = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("pickupHay"), BccUtils.Keys[ConfigRanch.ranchSetup.pickupHayKey],
        1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    repeat
        while true do
            local sleep = true
            for k, v in pairs(feedPeds) do
                if IsEntityDead(v:GetPed()) then
                    catch = catch - 1
                    if catch == 0 then
                        animalsDead = true
                        break
                    end
                end
            end
            if IsEntityDead(PlayerPedId()) then
                isDead = true
                break
            end
            if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle)) < 2 then
                sleep = false
                PromptGroup2:ShowGroup('')
                if firstprompt2:HasCompleted() then
                    local function carryhayToPlace(crateToUse)
                        repAmount = repAmount + 1
                        VORPcore.NotifyRightTip(_U("walkAwayAndPlacehay"), 4000)
                        playerCarryHay(crateToUse)
                        pickUpAndDropHay(crateToUse, vehicle)
                    end
                    if repAmount == 0 then
                        carryhayToPlace(crate)
                        break
                    elseif repAmount == 1 then
                        carryhayToPlace(crate2)
                        break
                    elseif repAmount == 2 then
                        carryhayToPlace(crate3)
                        break
                    end
                end
            end
            if sleep then
                Wait(500)
            else
                Wait(5)
            end
        end
    until repAmount == 3

    if IsEntityDead(PlayerPedId()) or animalsDead then
        delPedsForTable(feedPeds)
        cleanVehicleAndCrates()
        feedPeds = nil
        isDead = true
        IsInMission = false
        VORPcore.NotifyRightTip(_U("failed"), 4000)
        return
    end
    FreezeEntityPosition(vehicle, false)
    for k, v in pairs(feedPeds) do
        local cw = GetEntityCoords(crate:GetObj())
        ClearPedTasksImmediately(v:GetPed())
        TaskPedSlideToCoord(v:GetPed(), cw.x + math.random(1, 5), cw.y + math.random(1, 5), cw.z, 50, true)
        Wait(1500)
        TaskStartScenarioInPlace(v, eatAnim, -1)
    end

    VORPcore.NotifyRightTip(_U("returnFromFeeding"), 4000)
    BccUtils.Misc.SetGps(feedWagonLocation.x, feedWagonLocation.y, feedWagonLocation.z)

    while true do
        Wait(200)
        local cw = GetEntityCoords(vehicle)
        if IsEntityDead(PlayerPedId()) then
            isDead = true
            break
        end
        if GetEntityHealth(vehicle) == 0 then break end
        if GetDistanceBetweenCoords(cw.x, cw.y, cw.z, feedWagonLocation.x, feedWagonLocation.y, feedWagonLocation.z, true) < 15 then break end
    end
    ClearGpsMultiRoute()
    if IsEntityDead(PlayerPedId()) == true or GetEntityHealth(vehicle) == 0 then
        delPedsForTable(feedPeds)
        cleanVehicleAndCrates()
        feedPeds = nil
        IsInMission = false
        VORPcore.NotifyRightTip(_U("failed"), 4000)
        return
    end
    FreezeEntityPosition(vehicle, true)
    TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)
    Wait(3000)

    VORPcore.NotifyRightTip(_U("animalsFed"), 4000)
    delPedsForTable(feedPeds)
    BccUtils.RPC:Call("bcc-ranch:IncreaseAnimalsCond", {
        ranchId = RanchData.ranchid,
        animalType = animalType,
        incAmount = tables.feedAnimalCondIncrease
    }, function(success)
        if success then
            devPrint("Successfully increased animal condition for: " .. animalType .. " in ranch: " .. RanchData.ranchid)
        else
            devPrint("Failed to increase animal condition for: " .. animalType .. " in ranch: " .. RanchData.ranchid)
        end
    end)
    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = false }, function(success)
        if success then
            devPrint("Animals out status updated successfully!")
        else
            devPrint("Failed to update animals out status!")
        end
    end)
    cleanVehicleAndCrates()
    feedPeds = nil
    IsInMission = false
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        cleanUpFeedMission()
        delPedsForTable(feedPeds)
    end
end)
