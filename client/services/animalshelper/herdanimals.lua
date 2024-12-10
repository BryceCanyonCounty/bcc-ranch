RegisterNetEvent('bcc-ranch:HerdAnimalClientHandler', function(animalType)
    local scale, failed, spawnCoords = nil, false, nil
    local model, tables
    IsInMission = true
    BCCRanchMenu:Close()

    -- Select animal type and set properties
    local selectAnimalFuncts = {
        ['cows'] = function()
            tables = ConfigAnimals.animalSetup.cows
            spawnCoords = safeDecode(RanchData.cow_coords)
            model = 'a_c_cow'
            if tonumber(RanchData.cows_age) < ConfigAnimals.animalSetup.cows.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['pigs'] = function()
            tables = ConfigAnimals.animalSetup.pigs
            spawnCoords = safeDecode(RanchData.pig_coords)
            model = 'a_c_pig_01'
            if tonumber(RanchData.pigs_age) < ConfigAnimals.animalSetup.pigs.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['sheeps'] = function()
            tables = ConfigAnimals.animalSetup.sheeps
            spawnCoords = safeDecode(RanchData.sheep_coords)
            model = 'a_c_sheep_01'
            if tonumber(RanchData.sheeps_age) < ConfigAnimals.animalSetup.sheeps.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['goats'] = function()
            tables = ConfigAnimals.animalSetup.goats
            spawnCoords = safeDecode(RanchData.goat_coords)
            model = 'a_c_goat_01'
            if tonumber(RanchData.goats_age) < ConfigAnimals.animalSetup.goats.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['chickens'] = function()
            tables = ConfigAnimals.animalSetup.chickens
            spawnCoords = safeDecode(RanchData.chicken_coords)
            model = 'a_c_chicken_01'
            if tonumber(RanchData.chickens_age) < ConfigAnimals.animalSetup.chickens.AnimalGrownAge then
                scale = 0.5
            end
        end
    }

    if selectAnimalFuncts[animalType] then
        selectAnimalFuncts[animalType]()
    else
        devPrint("Error: Invalid animal type specified.")
        return
    end

    -- Validate spawnCoords
    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for animal type:", animalType)
        ManageOwnedAnimalsMenu()
        VORPcore.NotifyRightTip(_U("noCoordsSetForAnimalType") .. animalType, 4000)
        IsInMission = false
        return
    end

    local catch, peds = 0, {}
    repeat
        local createdPed = BccUtils.Ped.CreatePed(model, spawnCoords.x + math.random(1, 5), spawnCoords.y + math.random(1, 5), spawnCoords.z, true, true, false)
        if createdPed then
            SetBlockingOfNonTemporaryEvents(createdPed, true)
            Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
            if scale then
                SetPedScale(createdPed, scale)
            end
            table.insert(peds, createdPed)
            SetEntityHealth(createdPed, tables.animalHealth, 0)
            catch = catch + 1
        else
            devPrint("Error: Failed to create ped for", animalType)
        end
    until catch == tables.spawnAmount

    if #peds == 0 then
        devPrint("Error: Failed to spawn any animals.")
        VORPcore.NotifyRightTip(_U("spawnFailed"), 4000)
        IsInMission = false
        return
    end

    SetRelAndFollowPlayer(peds)
    local herdLocation = safeDecode(RanchData.herd_coords)
    if not herdLocation then
        devPrint("Error: Missing herd location coordinates.")
        VORPcore.NotifyRightTip(_U("noCoordsSetForHerd"), 4000)
        return
    end

    BccUtils.Misc.SetGps(herdLocation.x, herdLocation.y, herdLocation.z)
    local blip = BccUtils.Blip:SetBlip(_U("herdLocation"), ConfigRanch.ranchSetup.ranchBlip, 0.2, herdLocation.x, herdLocation.y, herdLocation.z)
    VORPcore.NotifyRightTip(_U("herdAnimalsToLocation"), 4000)

    local count, animalsNear = tables.spawnAmount, false
    local function checkforDeadAnimal(location)
        for k, v in pairs(peds) do
            if DoesEntityExist(v) then
                if #(GetEntityCoords(v) - location) <= 15 then
                    animalsNear = true
                else
                    animalsNear = false
                end
                if IsEntityDead(v) then
                    DeletePed(v)
                    count = count - 1
                end
            else
                count = count - 1
            end
        end
    end

    while true do
        Wait(5)
        checkforDeadAnimal(vector3(herdLocation.x, herdLocation.y, herdLocation.z))
        if animalsNear then
            ClearGpsMultiRoute()
            animalsNear = false
            blip:Remove()
            VORPcore.NotifyRightTip(_U("returnAnimalsToRanch"), 4000)
            break
        elseif not animalsNear and count == 0 then
            ClearGpsMultiRoute()
            failed = true
            VORPcore.NotifyRightTip(_U("failed"), 4000)
            break
        end
    end

    BccUtils.Misc.SetGps(RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z)
    while true do
        Wait(5)
        if failed then break end
        checkforDeadAnimal(RanchData.ranchcoordsVector3)
        if animalsNear then
            ClearGpsMultiRoute()
            if RanchData.ranchCondition ~= ConfigRanch.ranchSetup.maxRanchCondition or count ~= tables.spawnAmount then
                BccUtils.RPC:Call("bcc-ranch:IncreaseAnimalsCond", {
                    ranchId = RanchData.ranchid,
                    animalType = animalType,
                    incAmount = tables.condIncreasePerHerd
                }, function(success)
                    if success then
                        devPrint("Successfully increased animal condition for: " .. animalType .. " in ranch: " .. RanchData.ranchid)
                    else
                        devPrint("Failed to increase animal condition for: " .. animalType .. " in ranch: " .. RanchData.ranchid)
                    end
                end)
                
            else
                BccUtils.RPC:Call("bcc-ranch:IncreaseAnimalsCond", {
                    ranchId = RanchData.ranchid,
                    animalType = animalType,
                    incAmount = tables.condIncreasePerHerdMaxRanchCond
                }, function(success)
                    if success then
                        devPrint("Successfully increased animal condition for: " .. animalType .. " in ranch: " .. RanchData.ranchid)
                    else
                        devPrint("Failed to increase animal condition for: " .. animalType .. " in ranch: " .. RanchData.ranchid)
                    end
                end)
            end
            for k, v in pairs(peds) do
                DeletePed(v)
            end break
        elseif animalsNear == false and count == 0 then
            ClearGpsMultiRoute()
            failed = true
            VORPcore.NotifyRightTip(_U("failed"), 4000) break
        end
    end
    IsInMission = false
    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = false }, function(success)
        if success then
            devPrint("Animals out status updated successfully!")
        else
            devPrint("Failed to update animals out status!")
        end
    end)
end)

function safeDecode(data)
    if type(data) == "string" then
        local success, result = pcall(json.decode, data)
        if success then
            return result
        else
            devPrint("Error decoding JSON data:", data)
        end
    end
    return nil
end
