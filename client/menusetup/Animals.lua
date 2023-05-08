----- Variabless -----
Cowcoords, Chickencoords, Goatcoords, Pigcoords, Herdlocation = nil, nil, nil, nil, nil

------ Buy Animals Menu --------
function BuyAnimalMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.BuyCows .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Cows.Cost), value = 'buycows', desc = Config.Language.BuyAnimals_desc },
        { label = Config.Language.BuyPigs .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.Cost), value = 'buypigs', desc = Config.Language.BuyPigs_desc },
        { label = Config.Language.BuyChickens .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.Cost), value = 'buychickens', desc = Config.Language.BuyChickens_desc },
        { label = Config.Language.BuyGoats .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Goats.Cost), value = 'buygoats', desc = Config.Language.BuyGoats_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.Caretaking,
            align = 'top-left',
            elements = elements,
            lastmenu = 'MainMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'buycows' then
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'cows')
            elseif data.current.value == 'buypigs' then
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'pigs')
            elseif data.current.value == 'buychickens' then
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'chickens')
            elseif data.current.value == 'buygoats' then
                TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'goats')
            end
        end)
end

--------- Manage Animals Menu ------
function ManageOwnedAnimalsMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.SetHerdLocation, value = 'setherdlocation', desc = Config.Language.SetHerdLocation_desc },
        { label = Config.Language.ManageCows, value = 'managecows', desc = Config.Language.ManageCows_desc },
        { label = Config.Language.ManageChickens, value = 'managechickens', desc = Config.Language.ManageChickens_desc },
        { label = Config.Language.ManageGoats, value = 'managegoats', desc = Config.Language.ManageGoats_desc },
        { label = Config.Language.ManagePigs, value = 'managepigs', desc = Config.Language.ManagePigs_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.ManageAnimals,
            align = 'top-left',
            elements = elements,
            lastmenu = 'MainMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'setherdlocation' then
                local pl = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, RanchCoords.x, RanchCoords.y, RanchCoords.z, true) > Config.RanchSetup.HerdingMinDistance then
                    Herdlocation = pl
                    VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
                    MenuData.CloseAll()
                else
                    VORPcore.NotifyRightTip(Config.Language.TooCloseToRanch, 4000)
                end
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
RegisterNetEvent('bcc-ranch:OwnedAnimalManagerMenu', function(animal_cond, animaltype, ranchcond)
    local elements, title, maxcond, herdtype
    MenuData.CloseAll()
    if animaltype == 'pigs' then
        herdtype = 'pigs'
        title = Config.Language.ManagePigs
        maxcond = tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.MaxCondition)
        elements = {
            { label = Config.Language.CheckAnimalCond, value = 'checkanimal', desc = Config.Language.CheckAnimalCond_desc },
            { label = Config.Language.SetCoords, value = 'setanimalcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.HerdAnimal, value = 'herdanimal', desc = Config.Language.HerdAnimal_desc },
            { label = Config.Language.SellCows, value = 'sellanimal', desc = Config.Language.SellCows_desc },
            { label = Config.Language.ButcherAnimal, value = 'butcheranimal', desc = Config.Language.ButcherAnimal_desc },
        }
    elseif animaltype == 'goats' then
        herdtype = 'goats'
        title = Config.Language.ManageGoats
        maxcond = tostring(Config.RanchSetup.RanchAnimalSetup.Goats.MaxCondition)
        elements = {
            { label = Config.Language.CheckAnimalCond, value = 'checkanimal', desc = Config.Language.CheckAnimalCond_desc },
            { label = Config.Language.SetCoords, value = 'setanimalcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.HerdAnimal, value = 'herdanimal', desc = Config.Language.HerdAnimal_desc },
            { label = Config.Language.SellCows, value = 'sellanimal', desc = Config.Language.SellCows_desc },
            { label = Config.Language.ButcherAnimal, value = 'butcheranimal', desc = Config.Language.ButcherAnimal_desc },
        }
    elseif animaltype == 'chickens' then
        herdtype = 'chickens'
        title = Config.Language.ManageChickens
        maxcond = tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.MaxCondition)
        elements = {
            { label = Config.Language.CheckAnimalCond, value = 'checkanimal', desc = Config.Language.CheckAnimalCond_desc },
            { label = Config.Language.SetCoords, value = 'setanimalcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.HerdAnimal, value = 'herdanimal', desc = Config.Language.HerdAnimal_desc },
            { label = Config.Language.SellCows, value = 'sellanimal', desc = Config.Language.SellCows_desc },
            { label = Config.Language.ButcherAnimal, value = 'butcheranimal', desc = Config.Language.ButcherAnimal_desc },
        }
    elseif animaltype == 'cows' then
        herdtype = 'cows'
        title = Config.Language.ManageCows
        maxcond = tostring(Config.RanchSetup.RanchAnimalSetup.Cows.MaxCondition)
        elements = {
            { label = Config.Language.CheckAnimalCond, value = 'checkanimal', desc = Config.Language.CheckAnimalCond_desc },
            { label = Config.Language.SetCoords, value = 'setanimalcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.HerdAnimal, value = 'herdanimal', desc = Config.Language.HerdAnimal_desc },
            { label = Config.Language.SellCows, value = 'sellanimal', desc = Config.Language.SellCows_desc },
            { label = Config.Language.ButcherAnimal, value = 'butcheranimal', desc = Config.Language.ButcherAnimal_desc },
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
                VORPcore.NotifyRightTip(tostring(animal_cond).. '/' .. maxcond)
            elseif data.current.value == 'setanimalcoords' then
                local pl = GetEntityCoords(PlayerPedId())
                if animaltype == 'pigs' then
                    Pigcoords = pl
                elseif animaltype == 'goats' then
                    Goatcoords = pl
                elseif animaltype == 'chickens' then
                    Chickencoords = pl
                elseif animaltype == 'cows' then
                    Cowcoords = pl
                end
                VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
            elseif data.current.value == 'herdanimal' then
                if Herdlocation ~= nil then
                    MenuData.CloseAll()
                    herdanimals(herdtype, ranchcond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            elseif data.current.value == 'sellanimal' then
                if animaltype == 'pigs' then
                    if Pigcoords then
                        MenuData.CloseAll()
                        SellAnimals('pigs', animal_cond)
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                elseif animaltype == 'goats' then
                    if Goatcoords then
                        MenuData.CloseAll()
                        SellAnimals('goats', animal_cond)
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                elseif animaltype == 'chickens' then
                    if Chickencoords then
                        MenuData.CloseAll()
                        SellAnimals('chickens', animal_cond)
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                elseif animaltype == 'cows' then
                    if Cowcoords then
                        MenuData.CloseAll()
                        SellAnimals('cows', animal_cond)
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                end
            elseif data.current.value == 'butcheranimal' then
                if animaltype == 'pigs' then
                    if Pigcoords ~= nil then
                        MenuData.CloseAll()
                        ButcherAnimals('pigs')
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                elseif animaltype == 'goats' then
                    if Goatcoords ~= nil then
                        MenuData.CloseAll()
                        ButcherAnimals('goats')
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                elseif animaltype == 'chickens' then
                    if Chickencoords then
                        MenuData.CloseAll()
                        ButcherAnimals('chickens')
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                elseif animaltype == 'cows' then
                    if Cowcoords then
                        MenuData.CloseAll()
                        ButcherAnimals('cows')
                    else
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    end
                end
            end
        end)
end)