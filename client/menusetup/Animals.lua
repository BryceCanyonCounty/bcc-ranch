----- Variabless -----
Cowcoords, Chickencoords, Goatcoords, Pigcoords, Herdlocation, FeedWagonLocation, BoughtCows, BoughtChickens, BoughtGoats, BoughtPigs = nil, nil, nil, nil, nil, nil, true, true, true, true

------ Buy Animals Menu --------
function BuyAnimalMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = _U("BuyCows") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Cows.Cost), value = 'buycows', desc = _U("BuyAnimals_desc") },
        { label = _U("BuyPigs") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.Cost), value = 'buypigs', desc = _U("BuyPigs_desc") },
        { label = _U("BuyGoats") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Goats.Cost), value = 'buygoats', desc = _U("BuyGoats_desc") },
        { label = _U("BuyChickens") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.Cost), value = 'buychickens', desc = _U("BuyChickens_desc") },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("Caretaking"),
            align = 'top-left',
            elements = elements,
            lastmenu = 'MainMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'buycows' then
                BoughtCows = false
                Cowsage = 0
                Wait(200)
                BoughtCows = true
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'cows')
            elseif data.current.value == 'buypigs' then
                BoughtPigs = false
                Pigsage = 0
                Wait(200)
                BoughtPigs = true
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'pigs')
            elseif data.current.value == 'buychickens' then
                BoughtChickens = false
                Chickensage = 0
                Wait(200)
                BoughtChickens = true
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'chickens')
            elseif data.current.value == 'buygoats' then
                BoughtGoats = false
                Goatsage = 0
                Wait(200)
                BoughtGoats = true
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'goats')
            end
        end)
end

--------- Manage Animals Menu ------
function ManageOwnedAnimalsMenu()
    Inmenu = false
    MenuData.CloseAll()

    -- added / changed by Little Creek
    local set_or_change_herd = ''
    local set_or_change_herd_desc = ''
    local set_or_change_feed_wagon = ''
    local set_or_change_feed_wagon_desc = ''

    if Herdlocation then
        set_or_change_herd = 'ChangeHerdLocation'
        set_or_change_herd_desc = 'ChangeHerdLocation_desc'
    else
        set_or_change_herd = 'SetHerdLocation'
        set_or_change_desc_herd = 'SetHerdLocation_desc'
    end

    if FeedWagonLocation then
        set_or_change_feed_wagon = 'ChangeFeedWagonLocation'
        set_or_change_feed_wagon_desc = 'ChangeFeedWagonLocation_desc'
    else
        set_or_change_feed_wagon = 'SetFeedWagonLocation'
        set_or_change_feed_wagon_desc = 'SetFeedWagonLocation_desc'
    end

    local elements = {
        { label = _U(set_or_change_herd), value = 'setherdlocation', desc = _U(set_or_change_herd_desc) },
        { label = _U(set_or_change_feed_wagon), value = 'setfeedwagonlocation', desc = _U(set_or_change_feed_wagon_desc) },
        { label = _U('ManageCows'), value = 'managecows', desc = _U('ManageCows_desc') },
        { label = _U('ManagePigs'), value = 'managepigs', desc = _U('ManagePigs_desc') },
        { label = _U('ManageGoats'), value = 'managegoats', desc = _U('ManageGoats_desc') },
        { label = _U('ManageChickens'), value = 'managechickens', desc = _U('ManageChickens_desc') },
    }
    -- end added / changed by Little Creek

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("ManageAnimals"),
            align = 'top-left',
            elements = elements,
            lastmenu = 'MainMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local pl = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, true)
            if data.current.value == 'setherdlocation' then
                if dist > Config.RanchSetup.HerdingMinDistance then
                    TriggerServerEvent("bcc-ranch:InserHerdLocation", pl, RanchId)
                    MenuData.CloseAll()
                    Wait(2000)
                    TriggerServerEvent("bcc-ranch:getHerdlocation", RanchId)
                else
                    VORPcore.NotifyRightTip(_U("TooCloseToRanch"), 4000)
                end
            elseif data.current.value == 'setfeedwagonlocation' then
                TriggerServerEvent("bcc-ranch:InsertWagonFeedCoords", pl, RanchId)
                Wait(2000)
                TriggerServerEvent("bcc-ranch:getWagonFeedCoords", RanchId)
            elseif data.current.value == 'managecows' then
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'cows')
            elseif data.current.value == 'managechickens' then
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'chickens')
            elseif data.current.value == 'managegoats' then
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'goats')
            elseif data.current.value == 'managepigs' then
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'pigs')
            end
        end)
end

--------------------------- Owned Animal Manager Menu ----------------------------------
RegisterNetEvent('bcc-ranch:OwnedAnimalManagerMenu', function(animalCond, animalType, ranchCond)
    local elements, title, maxCond, herdType
    local set_or_change, set_or_change_desc -- added by Little Creek
    MenuData.CloseAll()
    if animalType == 'pigs' then
        herdType = 'pigs'
        title = _U("ManagePigs")
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.MaxCondition)

        -- added / changed by Little Creek
        if Pigcoords and Pigcoords ~= 'none' then
            set_or_change = 'ChangeCoords'
            set_or_change_desc = 'ChangeCoords_desc'
        else
            set_or_change = 'SetCoords'
            set_or_change_desc = 'SetCoords_desc'
        end

        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U(set_or_change), value = 'setanimalcoords', desc = _U(set_or_change_desc) },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
        }
        -- end added / changed by Little Creek
    elseif animalType == 'goats' then
        herdType = 'goats'
        title = _U("ManageGoats")
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Goats.MaxCondition)

        -- added / changed by Little Creek
        if Goatcoords and Goatcoords ~= 'none' then
            set_or_change = 'ChangeCoords'
            set_or_change_desc = 'ChangeCoords_desc'
        else
            set_or_change = 'SetCoords'
            set_or_change_desc = 'SetCoords_desc'
        end

        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U(set_or_change), value = 'setanimalcoords', desc = _U(set_or_change_desc) },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
        }
        -- end added / changed by Little Creek
    elseif animalType == 'chickens' then
        herdType = 'chickens'
        title = _U('ManageChickens')
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.MaxCondition)

        -- added / changed by Little Creek
        if Chickencoords and ChickenCoop ~= 'none' then
            set_or_change = 'ChangeCoords'
            set_or_change_desc = 'ChangeCoords_desc'
        else
            set_or_change = 'SetCoords'
            set_or_change_desc = 'SetCoords_desc'
        end

        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U(set_or_change), value = 'setanimalcoords', desc = _U(set_or_change_desc) },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
        }
        -- end added / changed by Little Creek
        --This insert is done to hide the buying coop option or the harvest egg option depending on if you own a coop or not
        if ChickenCoop == 'none' then
            table.insert(elements,             { label = _U("BuyChickenCoop") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.CoopCost), value = 'buychickencoop', desc = _U("BuyChickenCoop_desc") })
        else
            table.insert(elements,             { label = _U("HarvestFromCoop"), value = 'harvestchickencoop', desc = _U("HarvestFromCoop_desc") })
        end

    elseif animalType == 'cows' then
        herdType = 'cows'
        title = _U("ManageCows")
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Cows.MaxCondition)

        -- added / changed by Little Creek
        if Cowcoords and Cowcoords ~= 'none' then
            set_or_change = 'ChangeCoords'
            set_or_change_desc = 'ChangeCoords_desc'
        else
            set_or_change = 'SetCoords'
            set_or_change_desc = 'SetCoords_desc'
        end

        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U(set_or_change), value = 'setanimalcoords', desc = _U(set_or_change_desc) },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
            { label = _U("milkCows"), value = 'milkanimal', desc = _U("milkCows_desc") },
        }
        -- end added / changed by Little Creek
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = title,
            align = 'top-left',
            elements = elements,
            lastmenu = 'ManageOwnedAnimalsMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'checkanimal' then
                VORPcore.NotifyRightTip(tostring(animalCond).. '/' .. maxCond)
            elseif data.current.value == 'setanimalcoords' then
                local pl = GetEntityCoords(PlayerPedId())
                if animalType == 'pigs' then
                    TriggerServerEvent("bcc-ranch:InserPigCoord", pl, RanchId)
                    Wait(500)
                    TriggerServerEvent("bcc-ranch:getPigCoords", RanchId)
                elseif animalType == 'goats' then
                    TriggerServerEvent("bcc-ranch:InserGoatCoord", pl, RanchId)
                    Wait(500)
                    TriggerServerEvent("bcc-ranch:getGoatCoords", RanchId)
                elseif animalType == 'chickens' then
                    TriggerServerEvent("bcc-ranch:InserChickenCoord", pl, RanchId)
                    Wait(500)
                    TriggerServerEvent("bcc-ranch:getChickenCoords", RanchId)
                elseif animalType == 'cows' then
                    TriggerServerEvent("bcc-ranch:InserCowCoord", pl, RanchId)
                    Wait(500)
                    TriggerServerEvent("bcc-ranch:getCowCoords", RanchId)
                end
            elseif data.current.value == 'herdanimal' then
                if Herdlocation ~= nil and Herdlocation ~= 'none' then
                    MenuData.CloseAll()
                    herdanimals(herdType, ranchCond)
                else
                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                end
            elseif data.current.value == 'sellanimal' then
                if animalType == 'pigs' then
                    if Pigcoords and Pigcoords ~= 'none' then
                        MenuData.CloseAll()
                        SellAnimals('pigs', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'goats' then
                    if Goatcoords and Goatcoords ~= 'none' then
                        MenuData.CloseAll()
                        SellAnimals('goats', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'chickens' then
                    if Chickencoords and Chickencoords ~= 'none' then
                        MenuData.CloseAll()
                        SellAnimals('chickens', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'cows' then
                    if Cowcoords and Cowcoords ~= 'none' then
                        MenuData.CloseAll()
                        SellAnimals('cows', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                end
            elseif data.current.value == 'butcheranimal' then
                if animalType == 'pigs' then
                    if Pigcoords ~= nil and Pigcoords ~= 'none' then
                        MenuData.CloseAll()
                        ButcherAnimals('pigs')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'goats' then
                    if Goatcoords ~= nil and Goatcoords ~= 'none' then
                        MenuData.CloseAll()
                        ButcherAnimals('goats')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'chickens' then
                    if Chickencoords and Chickencoords ~= 'none' then
                        MenuData.CloseAll()
                        ButcherAnimals('chickens')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'cows' then
                    if Cowcoords and Cowcoords ~= 'none' then
                        MenuData.CloseAll()
                        ButcherAnimals('cows')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                end
            elseif data.current.value == 'feedanimal' then
                if FeedWagonLocation then
                    if animalType == 'pigs' then
                        if Pigcoords ~= nil and Pigcoords ~= 'none' then
                            MenuData.CloseAll()
                            FeedAnimals('pigs')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    elseif animalType == 'goats' then
                        if Goatcoords ~= nil and Goatcoords ~= 'none' then
                            MenuData.CloseAll()
                            FeedAnimals('goats')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    elseif animalType == 'chickens' then
                        if Chickencoords and Chickencoords ~= 'none' then
                            MenuData.CloseAll()
                            FeedAnimals('chickens')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    elseif animalType == 'cows' then
                        if Cowcoords and Cowcoords ~= 'none' then
                            MenuData.CloseAll()
                            FeedAnimals('cows')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    end
                else
                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                end
            elseif data.current.value == 'buychickencoop' then
                if ChickenCoop ~= 'none' then
                    VORPcore.NotifyRightTip(_U("AlreadyOwnCoop"), 4000)
                else
                    TriggerServerEvent('bcc-ranch:ChickenCoopFundsCheck')
                end
            elseif data.current.value == 'harvestchickencoop' then
                if ChickenCoop ~= 'none' then
                    TriggerServerEvent('bcc-ranch:CoopCollectionCooldown', RanchId)
                else
                    VORPcore.NotifyRightTip(_U("NoCoop"), 4000)
                end
            elseif data.current.value == 'milkanimal' then
                if Cowcoords and Cowcoords ~= 'none' then
                    TriggerServerEvent('bcc-ranch:CowMilkingCooldown', RanchId)
                else
                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                end
            end
        end)
end)