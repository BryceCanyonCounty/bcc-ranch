----- ####### Menu Area ####### -----

-- Function for setting herd locations cant do in menu or will not work with :Close()
local function setAnimalsCoords(type, minDist, cost)
    BCCRanchMenu:Close()
    IsInMission = true
    VORPcore.NotifyRightTip(_U("setCoordsLoop"), 10000)
    VORPcore.NotifyRightTip(_U("cancelSetCoords"), 10000)
    
    while true do
        Wait(5)
        local pCoords = GetEntityCoords(PlayerPedId())
        local dist = #(RanchData.ranchcoordsVector3 - pCoords)

        if type == "herdCoords" then
            if IsControlJustReleased(0, 0x760A9C6F) then -- G
                if dist > minDist then
                    BccUtils.RPC:Call("bcc-ranch:InsertAnimalRelatedCoords", {
                        ranchId = RanchData.ranchid,
                        coords = pCoords,
                        type = "herdCoords"
                    }, function(success)
                        if success then
                            VORPcore.NotifyRightTip(_U("coordsSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("error"), 4000)
                        end
                    end)
                    IsInMission = false
                    break
                else
                    VORPcore.NotifyRightTip(_U("tooCloseToRanch"), 4000)
                end
            end
            if IsControlJustReleased(0, 0x9959A6F0) then -- C
                IsInMission = false
                break
            end
        else
            if IsControlJustReleased(0, 0x760A9C6F) then -- G
                if dist < minDist then
                    BccUtils.RPC:Call("bcc-ranch:InsertAnimalRelatedCoords", {
                        ranchId = RanchData.ranchid,
                        coords = pCoords,
                        type = type,
                        cost = cost
                    }, function(success)
                        if success then
                            VORPcore.NotifyRightTip(_U("coordsSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("notEnoughMoney"), 4000)
                        end
                    end)
                    IsInMission = false
                    break
                else
                    VORPcore.NotifyRightTip(_U("tooFarFromRanch"), 4000)
                end
            end
            if IsControlJustReleased(0, 0x9959A6F0) then -- C
                IsInMission = false
                break
            end
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
        setAnimalsCoords('herdCoords', ConfigAnimals.animalSetup.minHerdCoords)
    end)
    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U('setFeedWagon'),
        style = {}
    }, function()
        setAnimalsCoords('feedWagonCoords', tonumber(RanchData.ranch_radius_limit))
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
            manageCowsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })

            TextDisplay = manageCowsPage:RegisterElement('textdisplay', {
                value = _U("checkAnimalCond") .. tostring(RanchData.cows_cond) ,
                slot = "header",
                style = {}
            })
            TextDisplay = manageCowsPage:RegisterElement('textdisplay', {
                value = "Animal Age: " .. tostring(RanchData.cows_age) ,
                slot = "header",
                style = {}
            })
            manageCowsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            manageCowsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setAnimalsCoords('cowCoords', tonumber(RanchData.ranch_radius_limit))
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
                    BccUtils.RPC:Call("bcc-ranch:HandleFeedingCooldown", { ranchId = RanchData.ranchid, animalType = "cows" }, function(success)
                        if success then
                            TriggerEvent('bcc-ranch:FeedAnimals', 'cows')                            
                        else
                            VORPcore.NotifyRightTip("Error", 4000)
                        end
                    end)
                else
                    -- Check for missing specific coordinates
                    if RanchData.feed_wagon_coords == 'none' then
                        VORPcore.NotifyRightTip(_U("noCoordsSetForWagon"), 4000)
                    elseif RanchData.cow_coords == "none" then
                        manageOwnedAnimalsPage:RouteTo()
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    end
                end
            end)
            manageCowsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.cows_age) < ConfigAnimals.animalSetup.cows.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('cows')
                end
            end)
            manageCowsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function()
                if RanchData.cow_coords ~= "none" then
                    if tonumber(RanchData.cows_age) < ConfigAnimals.animalSetup.cows.AnimalGrownAge then
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
            }, function()
                if RanchData.cow_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:MilkingCowsCooldown', RanchData.ranchid)
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)

            manageCowsPage:RegisterElement('line', {
                slot = "footer",
                style = {}
            })

            manageCowsPage:RegisterElement('button', {
                label = _U("back"),
                slot = "footer",
                style = {}
            }, function()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageCowsPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

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
            managePigsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })

            TextDisplay = managePigsPage:RegisterElement('textdisplay', {
                value = _U("checkAnimalCond") .. tostring(RanchData.pigs_cond) ,
                slot = "header",
                style = {}
            })
            TextDisplay = managePigsPage:RegisterElement('textdisplay', {
                value = "Animal Age: " .. tostring(RanchData.pigs_age) ,
                slot = "header",
                style = {}
            })
            managePigsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            managePigsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setAnimalsCoords('pigCoords', tonumber(RanchData.ranch_radius_limit))
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
                    BccUtils.RPC:Call("bcc-ranch:HandleFeedingCooldown", { ranchId = RanchData.ranchid, animalType = "pigs" }, function(success)
                        if success then
                            TriggerEvent('bcc-ranch:FeedAnimals', 'pigs')                            
                        else
                            VORPcore.NotifyRightTip("Error", 4000)
                        end
                    end)
                else
                    -- Check for missing specific coordinates
                    if RanchData.feed_wagon_coords == 'none' then
                        VORPcore.NotifyRightTip(_U("noCoordsSetForWagon"), 4000)
                    elseif RanchData.pig_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    end
                end
            end)
            managePigsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.pigs_age) < ConfigAnimals.animalSetup.pigs.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('pigs')
                end
            end)
            managePigsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function()
                if RanchData.pig_coords ~= "none" then
                    if tonumber(RanchData.pigs_age) < ConfigAnimals.animalSetup.pigs.AnimalGrownAge then
                        VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                    else
                        SellAnimals('pigs', RanchData.pigs_cond)
                    end
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)

            managePigsPage:RegisterElement('line', {
                slot = "footer",
                style = {}
            })

            managePigsPage:RegisterElement('button', {
                label = _U("back"),
                slot = "footer",
                style = {}
            }, function()
                manageOwnedAnimalsPage:RouteTo()
            end)

            managePigsPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

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
            manageSheepsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            TextDisplay = manageSheepsPage:RegisterElement('textdisplay', {
                value = _U("checkAnimalCond") .. tostring(RanchData.sheeps_cond) ,
                slot = "header",
                style = {}
            })
            TextDisplay = manageSheepsPage:RegisterElement('textdisplay', {
                value = "Animal Age: " .. tostring(RanchData.sheeps_age) ,
                slot = "header",
                style = {}
            })
            manageSheepsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            manageSheepsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setAnimalsCoords('sheepCoords', tonumber(RanchData.ranch_radius_limit))
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
                    BccUtils.RPC:Call("bcc-ranch:HandleFeedingCooldown", { ranchId = RanchData.ranchid, animalType = "sheeps" }, function(success)
                        if success then
                            TriggerEvent('bcc-ranch:FeedAnimals', 'sheeps')                            
                        else
                            VORPcore.NotifyRightTip("Error", 4000)
                        end
                    end)
                else
                    -- Check for missing specific coordinates
                    if RanchData.feed_wagon_coords == 'none' then
                        VORPcore.NotifyRightTip(_U("noCoordsSetForWagon"), 4000)
                    elseif RanchData.sheep_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    end
                end
            end)
            manageSheepsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.sheeps_age) < ConfigAnimals.animalSetup.sheeps.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('sheeps')
                end
            end)
            manageSheepsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function()
                if RanchData.sheep_coords ~= "none" then
                    if tonumber(RanchData.sheeps_age) < ConfigAnimals.animalSetup.sheeps.AnimalGrownAge then
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
            }, function()
                if RanchData.sheep_coords ~= "none" then
                    TriggerServerEvent('bcc-ranch:ShearingSheepsCooldown', RanchData.ranchid)
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)

            manageSheepsPage:RegisterElement('line', {
                slot = "footer",
                style = {}
            })

            manageSheepsPage:RegisterElement('button', {
                label = _U("back"),
                slot = "footer",
                style = {}
            }, function()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageSheepsPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

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
            manageGoatsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            TextDisplay = manageGoatsPage:RegisterElement('textdisplay', {
                value = _U("checkAnimalCond") .. tostring(RanchData.goats_cond) ,
                slot = "header",
                style = {}
            })
            TextDisplay = manageGoatsPage:RegisterElement('textdisplay', {
                value = "Animal Age: " .. tostring(RanchData.goats_age) ,
                slot = "header",
                style = {}
            })
            manageGoatsPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            manageGoatsPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setAnimalsCoords('goatCoords', tonumber(RanchData.ranch_radius_limit))
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
                    BccUtils.RPC:Call("bcc-ranch:HandleFeedingCooldown", { ranchId = RanchData.ranchid, animalType = "goats" }, function(success)
                        if success then
                            TriggerEvent('bcc-ranch:FeedAnimals', 'goats')                            
                        else
                            VORPcore.NotifyRightTip("Error", 4000)
                        end
                    end)
                else
                    -- Check for missing specific coordinates
                    if RanchData.feed_wagon_coords == 'none' then
                        VORPcore.NotifyRightTip(_U("noCoordsSetForWagon"), 4000)
                    elseif RanchData.goat_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    end
                end
            end)
            manageGoatsPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.goats_age) < ConfigAnimals.animalSetup.goats.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('goats')
                end
            end)
            manageGoatsPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function()
                if RanchData.goat_coords ~= "none" then
                    if tonumber(RanchData.goats_age) < ConfigAnimals.animalSetup.goats.AnimalGrownAge then
                        VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                    else
                        SellAnimals('goats', RanchData.goats_cond)
                    end
                else
                    VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                end
            end)

            manageGoatsPage:RegisterElement('line', {
                slot = "footer",
                style = {}
            })

            manageGoatsPage:RegisterElement('button', {
                label = _U("back"),
                slot = "footer",
                style = {}
            }, function()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageGoatsPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

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
            manageChickensPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            TextDisplay = manageChickensPage:RegisterElement('textdisplay', {
                value = _U("checkAnimalCond") .. tostring(RanchData.chickens_cond) ,
                slot = "header",
                style = {}
            })
            TextDisplay = manageChickensPage:RegisterElement('textdisplay', {
                value = "Animal Age: " .. tostring(RanchData.chicken_age) ,
                slot = "header",
                style = {}
            })
            manageChickensPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })
            manageChickensPage:RegisterElement('button', {
                label = _U("setCoords"),
                style = {}
            }, function()
                setAnimalsCoords('chickenCoords', tonumber(RanchData.ranch_radius_limit))
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
                    BccUtils.RPC:Call("bcc-ranch:HandleFeedingCooldown", { ranchId = RanchData.ranchid, animalType = "chickens" }, function(success)
                        if success then
                            TriggerEvent('bcc-ranch:FeedAnimals', 'chickens')                            
                        else
                            VORPcore.NotifyRightTip("Error", 4000)
                        end
                    end)
                else
                    -- Check for missing specific coordinates
                    if RanchData.feed_wagon_coords == 'none' then
                        VORPcore.NotifyRightTip(_U("noCoordsSetForWagon"), 4000)
                    elseif RanchData.chicken_coords == "none" then
                        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
                    end
                end                
            end)
            manageChickensPage:RegisterElement("button", {
                label = _U("butcherAnimal"),
                style = {}
            }, function()
                if tonumber(RanchData.chickens_age) < ConfigAnimals.animalSetup.chickens.AnimalGrownAge then
                    VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                else
                    ButcherAnimals('chickens')
                end
            end)
            manageChickensPage:RegisterElement('button', {
                label = _U("sellAnimal"),
                style = {}
            }, function()
                if RanchData.chicken_coords ~= "none" then
                    if tonumber(RanchData.chickens_age) < ConfigAnimals.animalSetup.chickens.AnimalGrownAge then
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
                    label = _U("buyChickenCoop") .. ConfigAnimals.animalSetup.chickens.coopCost,
                    style = {}
                }, function()
                    setAnimalsCoords('coopCoords', tonumber(RanchData.ranch_radius_limit), ConfigAnimals.animalSetup.chickens.coopCost)
                end)
            else
                manageChickensPage:RegisterElement('button', {
                    label = _U("harvestEggs"),
                    style = {}
                }, function()
                    TriggerServerEvent('bcc-ranch:HarvestEggsCooldown', RanchData.ranchid)
                end)
            end

            manageChickensPage:RegisterElement('line', {
                slot = "footer",
                style = {}
            })

            manageChickensPage:RegisterElement('button', {
                label = _U("back"),
                slot = "footer",
                style = {}
            }, function()
                manageOwnedAnimalsPage:RouteTo()
            end)

            manageChickensPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

            manageChickensPage:RouteTo()
        else
            VORPcore.NotifyRightTip(_U("youDoNotOwnAnimal"), 4000)
        end
    end)

    manageOwnedAnimalsPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    manageOwnedAnimalsPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer",
        style = {}
    }, function()
        MainRanchMenu()
    end)

    manageOwnedAnimalsPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCRanchMenu:Open({
        startupPage = manageOwnedAnimalsPage
    })
end
