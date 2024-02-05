local peds = {}

-------- Function to sell animals -----------
---@param animalType string
---@param animalCond integer
function SellAnimals(animalType, animalCond)
    BCCRanchMenu:Close()
    local tables, model
    local spawnCoords = nil

    local selectAnimalFuncts = {
        ['cows'] = function()
            if tonumber(RanchData.cows_age) < Config.animalSetup.cows.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
            else
                tables = Config.animalSetup.cows
                model = 'a_c_cow'
                spawnCoords = json.decode(RanchData.cow_coords)
            end
        end,
        ['pigs'] = function()
            if tonumber(RanchData.pigs_age) < Config.animalSetup.pigs.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
            else
                tables = Config.animalSetup.pigs
                model = 'a_c_pig_01'
                spawnCoords = json.decode(RanchData.pig_coords)
            end
        end,
        ['sheeps'] = function()
            if tonumber(RanchData.sheeps_age) < Config.animalSetup.sheeps.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
            else
                tables = Config.animalSetup.sheeps
                model = 'a_c_sheep_01'
                spawnCoords = json.decode(RanchData.sheep_coords)
            end
        end,
        ['goats'] = function()
            if tonumber(RanchData.goats_age) < Config.animalSetup.goats.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
            else
                tables = Config.animalSetup.goats
                model = 'a_c_goat_01'
                spawnCoords = json.decode(RanchData.goat_coords)
            end
        end,
        ['chickens'] = function()
            if tonumber(RanchData.chickens_age) < Config.animalSetup.chickens.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
            else
                tables = Config.animalSetup.chickens
                model = 'a_c_chicken_01'
                spawnCoords = json.decode(RanchData.chicken_coords)
            end
        end
    }

    if selectAnimalFuncts[animalType] then
        selectAnimalFuncts[animalType]()
    end
    IsInMission = true

    --Detecting Closest Sale Barn Setup Credit to vorp_core for this bit of code, and jannings for pointing this out to me
    TriggerServerEvent('bcc-ranch:UpdateAnimalsOut', RanchData.ranchid, true)
    local finalSaleCoords
    local closestDistance = math.huge
    for k, v in pairs(Config.saleLocations) do
        local pCoords = GetEntityCoords(PlayerPedId())
        local currentDistance = GetDistanceBetweenCoords(v.Coords.x, v.Coords.y, v.Coords.z, pCoords.x, pCoords.y, pCoords.z, true)

        if currentDistance < closestDistance then
            closestDistance = currentDistance
            finalSaleCoords = vector3(v.Coords.x, v.Coords.y, v.Coords.z)
        end
    end

    local catch = 0
    repeat
        local createdPed = BccUtils.Ped.CreatePed(model, spawnCoords.x + math.random(1, 5), spawnCoords.y + math.random(1, 5), spawnCoords.z, true, true, false)
        SetBlockingOfNonTemporaryEvents(createdPed, true)
        Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
        SetEntityHealth(createdPed, tables.animalHealth, 0)
        table.insert(peds, createdPed)
        catch = catch + 1
    until catch == tables.spawnAmount
    SetRelAndFollowPlayer(peds)
    VORPcore.NotifyRightTip(_U("leadAnimalsToSaleLocation"), 4000)
    BccUtils.Misc.SetGps(finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z)
    local blip = BccUtils.Blip:SetBlip(_U("saleLocationBlip"), Config.ranchSetup.ranchBlip, 0.2, finalSaleCoords.x, finalSaleCoords.y, finalSaleCoords.z)

    local animalsNear = false
    while true do
        Wait(50)
        for k, v in pairs(peds) do
            if #(GetEntityCoords(v) - finalSaleCoords) < 15 then
                animalsNear = true
            else
                animalsNear = false
            end
            if IsEntityDead(v) then
                catch = catch - 1
            end
        end
        if catch == 0 or IsEntityDead(PlayerPedId()) == true then break end

        local plc = GetEntityCoords(PlayerPedId())
        local dist = #(plc - finalSaleCoords)
        if dist < 5 and animalsNear == true then
            local pay
            if animalCond >= tables.maxCondition and catch == tables.animalHealth then
                pay = tables.maxConditionPay
            end
            if animalCond ~= tables.maxCondition then
                pay = tables.basePay
            end
            if catch ~= tables.spawnAmount then
                pay = tables.lowPay
            end
            TriggerServerEvent('bcc-ranch:AnimalSold', pay, RanchData.ranchid, animalType)
            VORPcore.NotifyRightTip(_U("animalSold"), 4000) break
        end
    end
    ClearGpsMultiRoute()
    if IsEntityDead(PlayerPedId()) or catch == 0 then
        blip:Remove()
        VORPcore.NotifyRightTip(_U("failed"), 4000)
    end
    for k, v in pairs(peds) do
        DeletePed(v)
    end
    blip:Remove()
    IsInMission = false
    TriggerServerEvent('bcc-ranch:UpdateAnimalsOut', RanchData.ranchid, false)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(peds) do
            v:Remove()
        end
        peds = {}
    end
end)