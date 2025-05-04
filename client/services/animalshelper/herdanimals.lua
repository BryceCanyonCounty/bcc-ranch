local herdPeds = {}
local herdBlip = nil

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
            if tonumber(RanchData.cows_age) < tables.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['pigs'] = function()
            tables = ConfigAnimals.animalSetup.pigs
            spawnCoords = safeDecode(RanchData.pig_coords)
            model = 'a_c_pig_01'
            if tonumber(RanchData.pigs_age) < tables.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['sheeps'] = function()
            tables = ConfigAnimals.animalSetup.sheeps
            spawnCoords = safeDecode(RanchData.sheep_coords)
            model = 'a_c_sheep_01'
            if tonumber(RanchData.sheeps_age) < tables.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['goats'] = function()
            tables = ConfigAnimals.animalSetup.goats
            spawnCoords = safeDecode(RanchData.goat_coords)
            model = 'a_c_goat_01'
            if tonumber(RanchData.goats_age) < tables.AnimalGrownAge then
                scale = 0.5
            end
        end,
        ['chickens'] = function()
            tables = ConfigAnimals.animalSetup.chickens
            spawnCoords = safeDecode(RanchData.chicken_coords)
            model = 'a_c_chicken_01'
            if tonumber(RanchData.chickens_age) < tables.AnimalGrownAge then
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

    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for animal type:", animalType)
        ManageOwnedAnimalsMenu()
        VORPcore.NotifyRightTip(_U("noCoordsSetForAnimalType") .. animalType, 4000)
        IsInMission = false
        return
    end

    local catch = 0
    repeat
        local pedObj = BccUtils.Ped:Create(model, spawnCoords.x + math.random(1, 5), spawnCoords.y + math.random(1, 5), spawnCoords.z, 0.0, "world", false, nil, nil, true)
        if pedObj then
            pedObj:SetBlockingOfNonTemporaryEvents(true)
            pedObj:CanBeDamaged(false)
            pedObj:SetBlip(54149631, "Your Animal")
            SetEntityHealth(pedObj:GetPed(), tables.animalHealth, 0)

            if scale then
                SetPedScale(pedObj:GetPed(), scale)
            end

            local netId = NetworkGetNetworkIdFromEntity(pedObj:GetPed())
            devPrint("[Client] Spawned animal NetID: " .. netId)

            
            table.insert(herdPeds, pedObj)
            catch = catch + 1
            
        else
            devPrint("Error: Failed to create ped for", animalType)
        end
    until catch == tables.spawnAmount

    if #herdPeds == 0 then
        devPrint("Error: Failed to spawn any animals.")
        VORPcore.NotifyRightTip(_U("spawnFailed"), 4000)
        IsInMission = false
        return
    end

    SetRelAndFollowPlayer(herdPeds)

    local herdLocation = safeDecode(RanchData.herd_coords)
    if not herdLocation then
        devPrint("Error: Missing herd location coordinates.")
        VORPcore.NotifyRightTip(_U("noCoordsSetForHerd"), 4000)
        IsInMission = false
        return
    end

    -- GPS + Blip setup
    BccUtils.Misc.SetGps(herdLocation.x, herdLocation.y, herdLocation.z)
    herdBlip = BccUtils.Blip:SetBlip(_U("herdLocation"), ConfigRanch.ranchSetup.ranchBlip, 0.2, herdLocation.x, herdLocation.y, herdLocation.z)
    VORPcore.NotifyRightTip(_U("herdAnimalsToLocation"), 4000)

    local count = tables.spawnAmount
    local animalsNear = false

    local function checkAnimalsAtLocation(location)
        for _, pedObj in ipairs(herdPeds) do
            if pedObj and pedObj.GetPed then
                local ped = pedObj:GetPed()
                if ped and DoesEntityExist(ped) then
                    if #(GetEntityCoords(ped) - location) <= 15 then
                        animalsNear = true
                    else
                        animalsNear = false
                    end
                    if IsEntityDead(ped) then
                        pedObj:Remove()
                        count = count - 1
                    end
                else
                    count = count - 1
                end
            end
        end
    end

    while true do
        Wait(5)
        checkAnimalsAtLocation(vector3(herdLocation.x, herdLocation.y, herdLocation.z))
        if animalsNear then
            ClearGpsMultiRoute()
            if herdBlip then
                herdBlip:Remove()
                herdBlip = nil
            end
            VORPcore.NotifyRightTip(_U("returnAnimalsToRanch"), 4000)
            break
        elseif not animalsNear and count == 0 then
            ClearGpsMultiRoute()
            VORPcore.NotifyRightTip(_U("failed"), 4000)
            failed = true
            break
        end
    end

    BccUtils.Misc.SetGps(RanchData.ranchcoords.x, RanchData.ranchcoords.y, RanchData.ranchcoords.z)

    while true do
        Wait(5)
        if failed then break end
        checkAnimalsAtLocation(RanchData.ranchcoordsVector3)
        if animalsNear then
            ClearGpsMultiRoute()

            if count ~= tables.spawnAmount then
                BccUtils.RPC:Call("bcc-ranch:IncreaseAnimalsCond", {
                    ranchId = RanchData.ranchid,
                    animalType = animalType,
                    incAmount = tables.condIncreasePerHerd
                }, function(success)
                    devPrint(success and "Increased animal condition (partial herd)." or "Failed to increase animal condition.")
                end)
            else
                BccUtils.RPC:Call("bcc-ranch:IncreaseAnimalsCond", {
                    ranchId = RanchData.ranchid,
                    animalType = animalType,
                    incAmount = tables.condIncreasePerHerdMaxRanchCond
                }, function(success)
                    devPrint(success and "Increased animal condition (full herd)." or "Failed to increase animal condition.")
                end)
            end

            break
        elseif not animalsNear and count == 0 then
            ClearGpsMultiRoute()
            VORPcore.NotifyRightTip(_U("failed"), 4000)
            break
        end
    end

    for _, pedObj in ipairs(herdPeds) do
        if pedObj then pedObj:Remove() end
    end
    herdPeds = {}

    IsInMission = false

    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = false }, function(success)
        devPrint(success and "Animals out status updated successfully!" or "Failed to update animals out status.")
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

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        -- Remove spawned peds
        if herdPeds then
            for _, pedObj in ipairs(herdPeds) do
                if pedObj and pedObj.Remove then
                    pedObj:Remove()
                end
            end
            herdPeds = {}
        end

        -- Remove herd blip
        if herdBlip then
            herdBlip:Remove()
            herdBlip = nil
        end

        -- Clear GPS route
        ClearGpsMultiRoute()
    end
end)
