local animalsDead, feedPeds = false, {}
local crate, crate2, crate3, vehicle, amount

--Function for making player carry hay
local function playerCarryBox(props)                 --catches var from wherever it is called
    RequestAnimDict("mech_carry_box")                --loads the anim
    while not HasAnimDictLoaded("mech_carry_box") do --while the anim hasnt loaded do
        Wait(100)
    end
    local pl = PlayerPedId()
    Citizen.InvokeNative(0xEA47FE3719165B94, pl, "mech_carry_box", "idle", 1.0, 8.0, -1, 31, 0, 0, 0, 0)                                                                            --plays animation
    Citizen.InvokeNative(0x6B9BBD38AB0796DF, props, pl, GetEntityBoneIndexByName(pl, "SKEL_R_Finger12"), 0.20, 0.028,
        -0.55, 210.0, 170.0, 100.0, true, true, false, true, 1, true)                                                                                                               --puts object in your hand
end

local function delPedsForTable(table)
    for k, v in pairs(table) do
        DeleteEntity(v)
    end
end

-- function for getting the hay off the wagon and placing on the ground
local function pickUpAndDropHay(crate, vehicle)
    local PromptGroup2 = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("dropHay"), BccUtils.Keys[ConfigRanch.ranchSetup.dropHayKey], 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    while true do
        Wait(5)
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
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle)) > 5 then
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

RegisterNetEvent('bcc-ranch:FeedAnimals', function(animalType)
    IsInMission = true
    BCCRanchMenu:Close()
    local tables, model, spawnCoords, eatAnim
    local scale, isDead = nil, false
    local feedWagonLocation = json.decode(RanchData.feed_wagon_coords)
    feedPeds = {} --Feedpeds is set to nil when the mission is over or player dies to empty the table, this sets it from nil to table allowing this to work again (if it is not set nil when the mission is over or failed it will fail the mission the next time you do one)

    local selectAnimalFuncts = {
        ['cows'] = function()
            tables = ConfigAnimals.animalSetup.cows
            model = 'a_c_cow'
            eatAnim = joaat("WORLD_ANIMAL_COW_EATING_GROUND")
            spawnCoords = json.decode(RanchData.cow_coords)
            if tonumber(RanchData.cows_age) < ConfigAnimals.animalSetup.cows.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['pigs'] = function()
            tables = ConfigAnimals.animalSetup.pigs
            model = 'a_c_pig_01'
            spawnCoords = json.decode(RanchData.pig_coords)
            eatAnim = joaat("WORLD_ANIMAL_PIG_EAT_CARCASS")
            if tonumber(RanchData.pigs_age) < ConfigAnimals.animalSetup.pigs.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['sheeps'] = function()
            tables = ConfigAnimals.animalSetup.sheeps
            model = 'a_c_sheep_01'
            spawnCoords = json.decode(RanchData.sheep_coords)
            eatAnim = joaat("WORLD_ANIMAL_SHEEP_EATING_GROUND")
            if tonumber(RanchData.sheeps_age) < ConfigAnimals.animalSetup.sheeps.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['goats'] = function()
            tables = ConfigAnimals.animalSetup.goats
            model = 'a_c_goat_01'
            spawnCoords = json.decode(RanchData.goat_coords)
            eatAnim = joaat("PROP_ANIMAL_GOAT_EAT_TROUGH")
            if tonumber(RanchData.goats_age) < ConfigAnimals.animalSetup.goats.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['chickens'] = function()
            tables = ConfigAnimals.animalSetup.chickens
            model = 'a_c_chicken_01'
            eatAnim = joaat("WORLD_ANIMAL_CHICKEN_EATING")
            spawnCoords = json.decode(RanchData.chicken_coords)
            if tonumber(RanchData.chickens_age) < ConfigAnimals.animalSetup.chickens.AnimalGrownAge then
                scale = 0.5
            end
        end
    }
    if selectAnimalFuncts[animalType] then
        selectAnimalFuncts[animalType]()
    end
    -- Check if spawnCoords is nil, notify the player if true
    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        return
    end


    local catch = 0
    repeat
        local createdPed = BccUtils.Ped.CreatePed(model, spawnCoords.x + math.random(1, 5),
            spawnCoords.y + math.random(1, 5), spawnCoords.z, true, true, false)
        if scale ~= nil then
            SetPedScale(createdPed, scale)
        end
        Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
        table.insert(feedPeds, createdPed)
        SetEntityHealth(createdPed, tables.animalHealth, 0)
        catch = catch + 1
    until catch == tables.spawnAmount
    amount = tables.spawnAmount
    SetRelAndFollowPlayer(feedPeds)
    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = true }, function(success)
        if success then
            print("Animals out status updated successfully!")
        else
            print("Failed to update animals out status!")
        end
    end)

    local car = joaat('cart06')
    RequestModel(car)
    while not HasModelLoaded(car) do
        Wait(100)
    end
    vehicle = CreateVehicle(car, feedWagonLocation.x, feedWagonLocation.y, feedWagonLocation.z, 100.0, true, false)
    while not DoesEntityExist(vehicle) do
        Wait(5)
    end
    SetVehicleOnGroundProperly(vehicle)
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

    VORPcore.NotifyRightTip(_U("goFeedYourAnimals"), 4000)

    local animalsNear
    while true do
        Wait(200)
        local pl = GetEntityCoords(vehicle)
        if #(pl - RanchData.ranchcoordsVector3) > 50 then
            for k, v in pairs(feedPeds) do
                if #(pl - GetEntityCoords(v)) < 35 then
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

        if IsEntityDead(PlayerPedId()) then
            isDead = true
            break
        end
    end
    local function cleanVehicleAndCrates()
        DeleteVehicle(vehicle)
        DeleteEntity(crate)
        DeleteEntity(crate2)
        DeleteEntity(crate3)
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
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("pickupHay"), BccUtils.Keys[ConfigRanch.ranchSetup.pickupHayKey], 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    repeat
        while true do
            local sleep = true
            for k, v in pairs(feedPeds) do
                if IsEntityDead(v) then
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
                        playerCarryBox(crateToUse)
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
        local cw = GetEntityCoords(crate)
        ClearPedTasksImmediately(v)
        TaskPedSlideToCoord(v, cw.x + math.random(1, 5), cw.y + math.random(1, 5), cw.z, 50, true)
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
            print("Animals out status updated successfully!")
        else
            print("Failed to update animals out status!")
        end
    end)
    cleanVehicleAndCrates()
    feedPeds = nil
    IsInMission = false
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        delPedsForTable(feedPeds)
        feedPeds = nil

        if DoesEntityExist(vehicle) then
            DeleteVehicle(vehicle)
        end
        if DoesEntityExist(crate) then
            DeleteEntity(crate)
        end
        if DoesEntityExist(crate2) then
            DeleteEntity(crate2)
        end
        if DoesEntityExist(crate3) then
            DeleteEntity(crate3)
        end
    end
end)
