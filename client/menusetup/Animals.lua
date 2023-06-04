----- Variabless -----
Cowcoords, Chickencoords, Goatcoords, Pigcoords, Herdlocation, FeedWagonLocation, BoughtCows, BoughtChickens, BoughtGoats, BoughtPigs = nil, nil, nil, nil, nil, nil, true, true, true, true

------ Buy Animals Menu --------
function BuyAnimalMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = _U("BuyCows") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Cows.Cost), value = 'buycows', desc = _U("BuyAnimals_desc") },
        { label = _U("BuyPigs") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.Cost), value = 'buypigs', desc = _U("BuyPigs_desc") },
        { label = _U("BuyChickens") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.Cost), value = 'buychickens', desc = _U("BuyChickens_desc") },
        { label = _U("BuyGoats") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Goats.Cost), value = 'buygoats', desc = _U("BuyGoats_desc") },
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
    local elements = {
        { label = _U('SetHerdLocation'), value = 'setherdlocation', desc = _U("SetHerdLocation_desc") },
        { label = _U('SetFeedWagonLocation'), value = 'setfeedwagonlocation', desc = _U("SetFeedWagonLocation_desc") },
        { label = _U("ManageCows"), value = 'managecows', desc = _U("ManageCows_desc") },
        { label = _U("ManageChickens"), value = 'managechickens', desc = _U("ManageChickens_desc") },
        { label = _U("ManageGoats"), value = 'managegoats', desc = _U("ManageGoats_desc") },
        { label = _U("ManagePigs"), value = 'managepigs', desc = _U("ManagePigs_desc") },
    }

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
                    Herdlocation = pl
                    VORPcore.NotifyRightTip(_U('Coordsset'), 4000)
                    MenuData.CloseAll()
                else
                    VORPcore.NotifyRightTip(_U("TooCloseToRanch"), 4000)
                end
            elseif data.current.value == 'setfeedwagonlocation' then
                FeedWagonLocation = pl
                VORPcore.NotifyRightTip(_U('Coordsset'), 4000)
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
    MenuData.CloseAll()
    if animalType == 'pigs' then
        herdType = 'pigs'
        title = _U("ManagePigs")
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.MaxCondition)
        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U("SetCoords"), value = 'setanimalcoords', desc = _U("SetCoords_desc") },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
        }
    elseif animalType == 'goats' then
        herdType = 'goats'
        title = _U("ManageGoats")
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Goats.MaxCondition)
        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U("SetCoords"), value = 'setanimalcoords', desc = _U("SetCoords_desc") },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
        }
    elseif animalType == 'chickens' then
        herdType = 'chickens'
        title = _U('ManageChickens')
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.MaxCondition)
        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U("SetCoords"), value = 'setanimalcoords', desc = _U("SetCoords_desc") },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
        }
    elseif animalType == 'cows' then
        herdType = 'cows'
        title = _U("ManageCows")
        maxCond = tostring(Config.RanchSetup.RanchAnimalSetup.Cows.MaxCondition)
        elements = {
            { label = _U("CheckAnimalCond"), value = 'checkanimal', desc = _U("CheckAnimalCond_desc") },
            { label = _U("SetCoords"), value = 'setanimalcoords', desc = _U("SetCoords_desc") },
            { label = _U("HerdAnimal"), value = 'herdanimal', desc = _U("HerdAnimal_desc") },
            { label = _U("SellCows"), value = 'sellanimal', desc = _U("SellCows_desc") },
            { label = _U("ButcherAnimal"), value = 'butcheranimal', desc = _U("ButcherAnimal_desc") },
            { label = _U("FeedAnimals"), value = 'feedanimal', desc = _U("FeedAnimals_desc") },
        }
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
                    Pigcoords = pl
                elseif animalType == 'goats' then
                    Goatcoords = pl
                elseif animalType == 'chickens' then
                    Chickencoords = pl
                elseif animalType == 'cows' then
                    Cowcoords = pl
                end
                VORPcore.NotifyRightTip(_U("Coordsset"), 4000)
            elseif data.current.value == 'herdanimal' then
                if Herdlocation ~= nil then
                    MenuData.CloseAll()
                    herdanimals(herdType, ranchCond)
                else
                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                end
            elseif data.current.value == 'sellanimal' then
                if animalType == 'pigs' then
                    if Pigcoords then
                        MenuData.CloseAll()
                        SellAnimals('pigs', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'goats' then
                    if Goatcoords then
                        MenuData.CloseAll()
                        SellAnimals('goats', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'chickens' then
                    if Chickencoords then
                        MenuData.CloseAll()
                        SellAnimals('chickens', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'cows' then
                    if Cowcoords then
                        MenuData.CloseAll()
                        SellAnimals('cows', animalCond)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                end
            elseif data.current.value == 'butcheranimal' then
                if animalType == 'pigs' then
                    if Pigcoords ~= nil then
                        MenuData.CloseAll()
                        ButcherAnimals('pigs')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'goats' then
                    if Goatcoords ~= nil then
                        MenuData.CloseAll()
                        ButcherAnimals('goats')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'chickens' then
                    if Chickencoords then
                        MenuData.CloseAll()
                        ButcherAnimals('chickens')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                elseif animalType == 'cows' then
                    if Cowcoords then
                        MenuData.CloseAll()
                        ButcherAnimals('cows')
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                end
            elseif data.current.value == 'feedanimal' then
                if FeedWagonLocation then
                    if animalType == 'pigs' then
                        if Pigcoords ~= nil then
                            MenuData.CloseAll()
                            FeedAnimals('pigs')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    elseif animalType == 'goats' then
                        if Goatcoords ~= nil then
                            MenuData.CloseAll()
                            FeedAnimals('goats')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    elseif animalType == 'chickens' then
                        if Chickencoords then
                            MenuData.CloseAll()
                            FeedAnimals('chickens')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    elseif animalType == 'cows' then
                        if Cowcoords then
                            MenuData.CloseAll()
                            FeedAnimals('cows')
                        else
                            VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                        end
                    end
                else
                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                end
            end
        end)
end)