local pedObj, peds = {}, {}
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
                Notify(_U("tooYoung"), "warning", 4000)
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
                Notify(_U("tooYoung"), "warning", 4000)
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
                Notify(_U("tooYoung"), "warning", 4000)
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
                Notify(_U("tooYoung"), "warning", 4000)
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
                Notify(_U("tooYoung"), "warning", 4000)
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
        Notify(_U("noCoordsSet"), "warning", 4000)
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
        local pedObj = BccUtils.Ped:Create(model, spawnCoords.x + math.random(1, 5), spawnCoords.y + math.random(1, 5), spawnCoords.z, 0.0, "world", true, nil, nil, true, false)
        local ped = pedObj:GetPed()
        ClearPedTasks(ped)
        pedObj:SetBlockingOfNonTemporaryEvents(true)
        SetEntityHealth(pedObj:GetPed(), tables.animalHealth, 0)
        if Config.EnableAnimalBlip then
            pedObj:SetBlip(54149631, "Your Animal")
        end
        table.insert(peds, pedObj)
    end

    -- Make animals follow player
    SetRelAndFollowPlayer(peds)

    -- Create GPS + Blip
    Notify(_U("leadAnimalsToSaleLocation"), "info", 4000)
    BccUtils.Misc.SetGps(finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z)
    saleBlip = BccUtils.Blip:SetBlip(_U("saleLocationBlip"), ConfigRanch.ranchSetup.ranchBlip, 0.2, finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z)

    local count = tables.spawnAmount
    local animalsNear = false
    local missionSuccess = false

    local function checkAnimalsAtSale()
        animalsNear = false
        for _, pedObj in ipairs(peds) do
            if pedObj and pedObj.GetPed then
                local ped = pedObj:GetPed()
                if ped and DoesEntityExist(ped) then
                    if #(GetEntityCoords(ped) - finalSaleCoords) <= 15.0 then
                        animalsNear = true
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
        Wait(250)
        checkAnimalsAtSale()
        if count <= 0 or IsEntityDead(PlayerPedId()) then
            break
        end
        if animalsNear then
            local playerDist = #(GetEntityCoords(PlayerPedId()) - finalSaleCoords)
            if playerDist < 5 then
                -- Calculate pay
                local pay
                if animalCond >= tables.maxCondition and count == tables.animalHealth then
                    pay = tables.maxConditionPay
                elseif animalCond ~= tables.maxCondition then
                    pay = tables.basePay
                elseif count ~= tables.spawnAmount then
                    pay = tables.lowPay
                end
                BccUtils.RPC:Call("bcc-ranch:AnimalSold", {
                    payAmount = pay,
                    ranchId = RanchData.ranchid,
                    animalType = animalType
                }, function(success)
                    devPrint(success and "Animal sold successfully." or "Failed to sell animal.")
                end)
                Notify(_U("animalSold"), "success", 4000)
                missionSuccess = true
                break
            end
        end
    end

    -- Only show "failed" if it wasn't already a success
    if not missionSuccess then
        Notify(_U("failed"), "error", 4000)
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

    if not missionSuccess and (IsEntityDead(PlayerPedId()) or spawnCount <= 0) then
        Notify(_U("failed"), "error", 4000)
    end

    IsInMission = false
    BccUtils.RPC:Call("bcc-ranch:UpdateAnimalsOut", { ranchId = RanchData.ranchid, isOut = false }, function(success)
        devPrint(success and "Animals out status updated after mission." or "Failed to update animals out after mission.")
    end)
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if type(peds) == "table" then
            for _, pedObj in ipairs(peds) do
                if pedObj and pedObj.Remove then
                    pedObj:Remove()
                end
            end
        end
        peds = {}
        if saleBlip and saleBlip.Remove then
            saleBlip:Remove()
            saleBlip = nil
        end
        ClearGpsMultiRoute()
    end
end)
