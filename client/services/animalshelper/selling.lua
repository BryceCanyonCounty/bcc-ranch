local peds = {}
local saleBlip = nil

---@param animalType string
---@param animalCond integer
function SellAnimals(animalType, animalCond)
    BCCRanchMenu:Close()
    local tables, model
    local spawnCoords = nil

    local selectAnimalFuncts = {
        ['cows'] = function()
            if tonumber(RanchData.cows_age) < ConfigAnimals.animalSetup.cows.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            else
                tables = ConfigAnimals.animalSetup.cows
                model = 'a_c_cow'
                spawnCoords = json.decode(RanchData.cow_coords)
                return true
            end
        end,
        ['pigs'] = function()
            if tonumber(RanchData.pigs_age) < ConfigAnimals.animalSetup.pigs.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            else
                tables = ConfigAnimals.animalSetup.pigs
                model = 'a_c_pig_01'
                spawnCoords = json.decode(RanchData.pig_coords)
                return true
            end
        end,
        ['sheeps'] = function()
            if tonumber(RanchData.sheeps_age) < ConfigAnimals.animalSetup.sheeps.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            else
                tables = ConfigAnimals.animalSetup.sheeps
                model = 'a_c_sheep_01'
                spawnCoords = json.decode(RanchData.sheep_coords)
                return true
            end
        end,
        ['goats'] = function()
            if tonumber(RanchData.goats_age) < ConfigAnimals.animalSetup.goats.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            else
                tables = ConfigAnimals.animalSetup.goats
                model = 'a_c_goat_01'
                spawnCoords = json.decode(RanchData.goat_coords)
                return true
            end
        end,
        ['chickens'] = function()
            if tonumber(RanchData.chickens_age) < ConfigAnimals.animalSetup.chickens.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            else
                tables = ConfigAnimals.animalSetup.chickens
                model = 'a_c_chicken_01'
                spawnCoords = json.decode(RanchData.chicken_coords)
                return true
            end
        end,
    }

    if not selectAnimalFuncts[animalType] or not selectAnimalFuncts[animalType]() then
        return
    end

    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        return
    end

    IsInMission = true

    -- Update animals out
    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = true }, function(success)
        devPrint(success and "Animals out status updated successfully!" or "Failed to update animals out status!")
    end)

    -- Find nearest sale location
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestDistance = math.huge
    local finalSaleCoords = nil

    for _, saleLoc in pairs(Config.saleLocations) do
        local dist = #(vector3(saleLoc.Coords.x, saleLoc.Coords.y, saleLoc.Coords.z) - playerCoords)
        if dist < closestDistance then
            closestDistance = dist
            finalSaleCoords = vector3(saleLoc.Coords.x, saleLoc.Coords.y, saleLoc.Coords.z)
        end
    end

    -- Spawn animals
    local spawnCount = 0
    for i = 1, tables.spawnAmount do
        local pedObj = BccUtils.Ped:Create(model, spawnCoords.x + math.random(1, 5), spawnCoords.y + math.random(1, 5), spawnCoords.z, 0.0, "world", false, true)

        pedObj:SetBlockingOfNonTemporaryEvents(true)
        SetEntityHealth(pedObj:GetPed(), tables.animalHealth, 0)

        -- ADD THIS LINE TO SET BLIP
        pedObj:SetBlip(54149631, "Your Animal") 

        local netId = NetworkGetNetworkIdFromEntity(pedObj:GetPed())
        table.insert(peds, { pedObj = pedObj, netId = netId })
        spawnCount = spawnCount + 1
    end

    -- Make animals follow player
    SetRelAndFollowPlayer(peds)

    -- Create GPS + Blip
    VORPcore.NotifyRightTip(_U("leadAnimalsToSaleLocation"), 4000)
    BccUtils.Misc.SetGps(finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z)
    saleBlip = BccUtils.Blip:SetBlip(_U("saleLocationBlip"), ConfigRanch.ranchSetup.ranchBlip, 0.2, finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z)

    -- Waiting for animals to reach the sale
    local animalsNear = false

    while true do
        Wait(250)
        animalsNear = true

        for _, pedObj in ipairs(peds) do
            if pedObj and pedObj.GetPed then
                local ped = pedObj:GetPed()
                if ped and DoesEntityExist(ped) then
                    if #(GetEntityCoords(ped) - finalSaleCoords) >= 15.0 then
                        animalsNear = false
                    end
                    if IsEntityDead(ped) then
                        spawnCount = spawnCount - 1
                    end
                end
            end
        end

        if spawnCount <= 0 or IsEntityDead(PlayerPedId()) then
            break
        end

        if animalsNear then
            local playerDist = #(GetEntityCoords(PlayerPedId()) - finalSaleCoords)
            if playerDist < 5 then
                -- Calculate pay
                local pay
                if animalCond >= tables.maxCondition and spawnCount == tables.animalHealth then
                    pay = tables.maxConditionPay
                elseif animalCond ~= tables.maxCondition then
                    pay = tables.basePay
                elseif spawnCount ~= tables.spawnAmount then
                    pay = tables.lowPay
                end

                -- Sell
                BccUtils.RPC:Call("bcc-ranch:AnimalSold", {
                    payAmount = pay,
                    ranchId = RanchData.ranchid,
                    animalType = animalType
                }, function(success)
                    devPrint(success and "Animal sold successfully." or "Failed to sell animal.")
                end)

                VORPcore.NotifyRightTip(_U("animalSold"), 4000)
                break
            end
        end
    end

    -- Cleanup
    ClearGpsMultiRoute()

    if saleBlip then
        saleBlip:Remove()
        saleBlip = nil
    end

    for _, pedObj in ipairs(peds) do
        if pedObj then
            pedObj:Remove()
        end
    end
    peds = {}

    if IsEntityDead(PlayerPedId()) or spawnCount <= 0 then
        VORPcore.NotifyRightTip(_U("failed"), 4000)
    end

    IsInMission = false

    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = false }, function(success)
        devPrint(success and "Animals out status updated after mission." or "Failed to update animals out after mission.")
    end)
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, pedObj in ipairs(peds) do
            if pedObj then
                pedObj:Remove()
            end
        end
        peds = {}

        if saleBlip then
            saleBlip:Remove()
            saleBlip = nil
        end
        ClearGpsMultiRoute()
    end
end)
