----- ####### Menu Area ####### -----

-- Function for setting herd locations cant do in menu or will not work with :Close()
---@param type string
---@param minDist integer
local function setCoords(type, minDist, cost)
    BCCRanchMenu:Close()
    IsInMission = true
    VORPcore.NotifyRightTip(_U("setCoordsLoop"), 10000)
    VORPcore.NotifyRightTip(_U("cancelSetCoords"), 10000)
    while true do
        Wait(5)
        local pCoords = GetEntityCoords(PlayerPedId())
        local dist = #(RanchData.ranchcoordsVector3 - pCoords)
        if type == "herdCoords" then
            if IsControlJustReleased(0, 0x760A9C6F) then -- 0x760A9C6F = G
                if dist > minDist then
                    VORPcore.NotifyRightTip(_U("coordsSet"), 4000)
                    TriggerServerEvent('bcc-ranch:InsertAnimalRelatedCoords', RanchData.ranchid, pCoords, "herdCoords")
                    IsInMission = false
                    break
                else
                    VORPcore.NotifyRightTip(_U("tooCloseToRanch"), 4000)
                end
            end
            if IsControlJustReleased(0, 0x9959A6F0) then IsInMission = false break end -- 0x9959A6F0 = C
        else
            if IsControlJustReleased(0, 0x760A9C6F) then
                if dist < minDist then
                    VORPcore.NotifyRightTip(_U("coordsSet"), 4000)
                    TriggerServerEvent('bcc-ranch:InsertAnimalRelatedCoords', RanchData.ranchid, pCoords, type, cost)
                    IsInMission = false
                    break
                else
                    VORPcore.NotifyRightTip(_U("tooFarFromRanch"), 4000)
                end
            end
            if IsControlJustReleased(0, 0x9959A6F0) then IsInMission = false break end
        end
    end
end

--------- Manage Animals Menu ------
function ManageOwnedAnimalsMenu()
    BCCRanchMenu:Close()

    local manageOwnedAnimalsPage = BCCRanchMenu:RegisterPage("bcc-ranch:manageOwnedAnimalsMenuPage")
    manageOwnedAnimalsPage:RegisterElement("header", {
        value = _U("manageAnimals"),
        slot = "header",
        style = {}
    })
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("setHerd"),
        style = {}
    }, function()
        setCoords('herdCoords', Config.animalSetup.minHerdCoords)
    end)
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U('setFeedWagon'),
        style = {}
    }, function()
        setCoords('feedWagonCoords', tonumber(RanchData.ranch_radius_limit))
    end)
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("manageCows"),
        style = {}
    }, function()
        if RanchData.cows == "true" then
            local manageCowsPage = BCCRanchMenu:RegisterPage("bcc-ranch:manageCowsPage")
            manageCowsPage:RegisterElement("header", {
                value = _U("manageCows"),
                slot = "header",
                style = {}
            })
            manageCowsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setCoords('cowCoords', tonumber(RanchData.ranch_radius_limit))
            end)
            manageCowsPage:RegisterElement('button', {
                label = _U("checkAnimalCond"),
                style = {}
            }, function()
                VORPcore.NotifyRightTip(tostring(RanchData.cows_cond), 4000)
            end)
            manageCowsPage:RegisterElement('button', {
                label = _U("herdAnimal"),
                style = {}
            }, function()
                if RanchData.is_any_animals_out == "false" then
                    if RanchData.herd_coords == "none" or RanchData.cow_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:HerdingCooldown', RanchData.ranchid, 'cows')
                    end
                else
                    VORPcore.NotifyRightTip(_U("animalsAlreadyOut"), 4000)
                end
            end)
            manageCowsPage:RegisterElement("button", {
                label = _U("feedAnimals"),
                style = {}
            }, function()
                if RanchData.feed_wagon_coords ~= 'none' and RanchData.cow_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:FeedingCooldown', RanchData.ranchid, 'cows')
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageCowsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.cows_age) < Config.animalSetup.cows.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('cows')
                end
            end)
            manageCowsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function ()
                if RanchData.cow_coords ~= "none" then
                    if tonumber(RanchData.cows_age) < Config.animalSetup.cows.AnimalGrownAge then
                        VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                    else
                        SellAnimals('cows', RanchData.cows_cond)
                    end
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageCowsPage:RegisterElement('button', {
                label = _U("milkAnimal"),
                style = {}
            }, function ()
                if RanchData.cow_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:MilkingCowsCooldown', RanchData.ranchid)
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageCowsPage:RegisterElement('button', {
                label = _U("back"),
                style = {}
            }, function ()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageCowsPage:RouteTo()
        else
            VORPcore.NotifyRightTip(_U("youDoNotOwnAnimal"), 4000)
        end
    end)
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("managePigs"),
        style = {}
    }, function()
        if RanchData.pigs == "true" then
            local managePigsPage = BCCRanchMenu:RegisterPage("bcc-ranch:managePigsPage")
            managePigsPage:RegisterElement("header", {
                value = _U("managePigs"),
                slot = "header",
                style = {}
            })
            managePigsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setCoords('pigCoords', tonumber(RanchData.ranch_radius_limit))
            end)
            managePigsPage:RegisterElement("button", {
                label = _U("checkAnimalCond"),
                style = {}
            }, function()
                VORPcore.NotifyRightTip(tostring(RanchData.pigs_cond), 4000)
            end)
            managePigsPage:RegisterElement('button', {
                label = _U("herdAnimal"),
                style = {}
            }, function()
                if RanchData.is_any_animals_out == "false" then
                    if RanchData.herd_coords == "none" or RanchData.pig_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:HerdingCooldown', RanchData.ranchid, 'pigs')
                    end
                else
                    VORPcore.NotifyRightTip(_U("animalsAlreadyOut"), 4000)
                end
            end)
            managePigsPage:RegisterElement("button", {
                label = _U("feedAnimals"),
                style = {}
            }, function()
                if RanchData.feed_wagon_coords ~= 'none' and RanchData.pig_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:FeedingCooldown', RanchData.ranchid, 'pigs')
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            managePigsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.pigs_age) < Config.animalSetup.pigs.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('pigs')
                end
            end)
            managePigsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function ()
                if RanchData.pig_coords ~= "none" then
                    if tonumber(RanchData.pigs_age) < Config.animalSetup.pigs.AnimalGrownAge then
                        VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                    else
                        SellAnimals('pigs', RanchData.pigs_cond)
                    end
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            managePigsPage:RegisterElement('button', {
                label = _U("back"),
                style = {}
            }, function ()
                manageOwnedAnimalsPage:RouteTo()
            end)

            managePigsPage:RouteTo()
        else
            VORPcore.NotifyRightTip(_U("youDoNotOwnAnimal"), 4000)
        end
    end)
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("manageSheeps"),
        style = {}
    }, function()
        if RanchData.sheeps == "true" then
            local manageSheepsPage = BCCRanchMenu:RegisterPage("bcc-ranch:manageSheepsPage")
            manageSheepsPage:RegisterElement("header", {
                value = _U("manageSheeps"),
                slot = "header",
                style = {}
            })
            manageSheepsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setCoords('sheepCoords', tonumber(RanchData.ranch_radius_limit))
            end)
            manageSheepsPage:RegisterElement('button', {
                label = _U("checkAnimalCond"),
                style = {}
            }, function()
                VORPcore.NotifyRightTip(tostring(RanchData.sheeps_cond), 4000)
            end)
            manageSheepsPage:RegisterElement('button', {
                label = _U("herdAnimal"),
                style = {}
            }, function()
                if RanchData.is_any_animals_out == "false" then
                    if RanchData.herd_coords == "none" or RanchData.sheep_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:HerdingCooldown', RanchData.ranchid, 'sheeps')
                    end
                else
                    VORPcore.NotifyRightTip(_U("animalsAlreadyOut"), 4000)
                end
            end)
            manageSheepsPage:RegisterElement("button", {
                label = _U("feedAnimals"),
                style = {}
            }, function()
                if RanchData.feed_wagon_coords ~= 'none' and RanchData.sheep_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:FeedingCooldown', RanchData.ranchid, 'sheeps')
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageSheepsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.sheeps_age) < Config.animalSetup.sheeps.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('sheeps')
                end
            end)
            manageSheepsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function ()
                if RanchData.sheep_coords ~= "none" then
                    if tonumber(RanchData.sheeps_age) < Config.animalSetup.sheeps.AnimalGrownAge then
                        VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                    else
                        SellAnimals('sheeps', RanchData.sheeps_cond)
                    end
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageSheepsPage:RegisterElement('button', {
                label = _U("shearAnimal"),
                style = {}
            }, function ()
                if RanchData.sheep_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:ShearingSheepsCooldown', RanchData.ranchid)
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageSheepsPage:RegisterElement('button', {
                label = _U("back"),
                style = {}
            }, function ()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageSheepsPage:RouteTo()
        else
            VORPcore.NotifyRightTip(_U("youDoNotOwnAnimal"), 4000)
        end
    end)
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("manageGoats"),
        style = {}
    }, function()
        if RanchData.goats == "true" then
            local manageGoatsPage = BCCRanchMenu:RegisterPage("bcc-ranch:manageGoatsPage")
            manageGoatsPage:RegisterElement("header", {
                value = _U("manageGoats"),
                slot = "header",
                style = {}
            })
            manageGoatsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setCoords('goatCoords', tonumber(RanchData.ranch_radius_limit))
            end)
            manageGoatsPage:RegisterElement('button', {
                label = _U("checkAnimalCond"),
                style = {}
            }, function()
                VORPcore.NotifyRightTip(tostring(RanchData.goats_cond), 4000)
            end)
            manageGoatsPage:RegisterElement('button', {
                label = _U("herdAnimal"),
                style = {}
            }, function()
                if RanchData.is_any_animals_out == "false" then
                    if RanchData.herd_coords == "none" or RanchData.goat_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:HerdingCooldown', RanchData.ranchid, 'goats')
                    end
                else
                    VORPcore.NotifyRightTip(_U("animalsAlreadyOut"), 4000)
                end
            end)
            manageGoatsPage:RegisterElement("button", {
                label = _U("feedAnimals"),
                style = {}
            }, function()
                if RanchData.feed_wagon_coords ~= 'none' and RanchData.goat_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:FeedingCooldown', RanchData.ranchid, 'goats')
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageGoatsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.goats_age) < Config.animalSetup.goats.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('goats')
                end
            end)
            manageGoatsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function ()
                if RanchData.goat_coords ~= "none" then
                    if  tonumber(RanchData.goats_age) < Config.animalSetup.goats.AnimalGrownAge then
                        VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                    else
                        SellAnimals('goats', RanchData.goats_cond)
                    end
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageGoatsPage:RegisterElement('button', {
                label = _U("back"),
                style = {}
            }, function ()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageGoatsPage:RouteTo()
        else
            VORPcore.NotifyRightTip(_U("youDoNotOwnAnimal"), 4000)
        end
    end)
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("manageChickens"),
        style = {}
    }, function()
        if RanchData.chickens == "true" then
            local manageChickensPage = BCCRanchMenu:RegisterPage("bcc-ranch:manageChickensPage")
            manageChickensPage:RegisterElement("header", {
                value = _U("manageChickens"),
                slot = "header",
                style = {}
            })
            manageChickensPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setCoords('chickenCoords', tonumber(RanchData.ranch_radius_limit))
            end)
            manageChickensPage:RegisterElement('button', {
                label = _U("checkAnimalCond"),
                style = {}
            }, function()
                VORPcore.NotifyRightTip(tostring(RanchData.chickens_cond), 4000)
            end)
            manageChickensPage:RegisterElement('button', {
                label = _U("herdAnimal"),
                style = {}
            }, function()
                if RanchData.is_any_animals_out == "false" then
                    if RanchData.herd_coords == "none" or RanchData.chicken_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:HerdingCooldown', RanchData.ranchid, 'chickens')
                    end
                else
                    VORPcore.NotifyRightTip(_U("animalsAlreadyOut"), 4000)
                end
            end)
            manageChickensPage:RegisterElement("button", {
                label = _U("feedAnimals"),
                style = {}
            }, function()
                if RanchData.feed_wagon_coords ~= 'none' and RanchData.chicken_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:FeedingCooldown', RanchData.ranchid, 'chickens')
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            manageChickensPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.chickens_age) < Config.animalSetup.chickens.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('chickens')
                end
            end)
            manageChickensPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function ()
                if RanchData.chicken_coords ~= "none" then
                    if tonumber(RanchData.chickens_age) < Config.animalSetup.chickens.AnimalGrownAge then
                        VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                    else
                        SellAnimals('chickens', RanchData.chickens_cond)
                    end
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)
            if RanchData.chicken_coop == "false" then
                manageChickensPage:RegisterElement("button", {
                    label = _U("buyChickenCoop") .. Config.animalSetup.chickens.coopCost,
                    style = {}
                }, function()
                    setCoords('coopCoords', tonumber(RanchData.ranch_radius_limit), Config.animalSetup.chickens.coopCost)
                end)
            else
                manageChickensPage:RegisterElement('button', {
                    label = _U("harvestEggs"),
                    style = {}
                }, function ()
                    TriggerServerEvent('bcc-ranch:HarvestEggsCooldown', RanchData.ranchid)
                end)
            end
            manageChickensPage:RegisterElement('button', {
                label = _U("back"),
                style = {}
            }, function ()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageChickensPage:RouteTo()
        else
            VORPcore.NotifyRightTip(_U("youDoNotOwnAnimal"), 4000)
        end
    end)

    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        MainRanchMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = manageOwnedAnimalsPage
    })
end