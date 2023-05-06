----- Variabless -----
Cowcoords = nil
Chickencoords = nil
Goatcoords = nil
Pigcoords = nil
Herdlocation = nil

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
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'cows', 'bcc-ranch:ManageOwnedCowsMenu')
            elseif data.current.value == 'managechickens' then
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'chickens', 'bcc-ranch:ManageOwnedChickenMenu')
            elseif data.current.value == 'managegoats' then
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'goats', 'bcc-ranch:ManageOwnedGoatMenu')
            elseif data.current.value == 'managepigs' then
                TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'pigs', 'bcc-ranch:ManageOwnedPigMenu')
            end
        end)
end

--------- Manage Cows Menu ------
RegisterNetEvent('bcc-ranch:ManageOwnedCowsMenu', function(cow_cond, ranchcond)
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.CheckAnimalCond, value = 'checkcows', desc = Config.Language.CheckAnimalCond_desc },
        { label = Config.Language.SetCoords, value = 'setcowscoords', desc = Config.Language.SetCoords_desc },
        { label = Config.Language.HerdAnimal, value = 'herdcows', desc = Config.Language.HerdAnimal_desc },
        { label = Config.Language.SellCows, value = 'sellcows', desc = Config.Language.SellCows_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.ManageCows,
            align = 'top-left',
            elements = elements,
            lastmenu = 'ManageOwnedAnimalsMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'checkcows' then
                VORPcore.NotifyRightTip(tostring(cow_cond).. '/' .. tostring(Config.RanchSetup.RanchAnimalSetup.Cows.MaxCondition))
            elseif data.current.value == 'setcowscoords' then
                Cowcoords = GetEntityCoords(PlayerPedId())
                VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
            elseif data.current.value == 'herdcows' then
                if Herdlocation ~= nil then
                    MenuData.CloseAll()
                    herdanimals('cows', ranchcond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            elseif data.current.value == 'sellcows' then
                if Cowcoords then
                    MenuData.CloseAll()
                    SellAnimals('cows', cow_cond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            end
        end)
end)

--------- Manage Chickens Menu ------
RegisterNetEvent('bcc-ranch:ManageOwnedChickenMenu', function(cow_cond, ranchcond)
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.CheckAnimalCond, value = 'checkchickens', desc = Config.Language.CheckAnimalCond_desc },
        { label = Config.Language.SetCoords, value = 'setchickenscoords', desc = Config.Language.SetCoords_desc },
        { label = Config.Language.HerdAnimal, value = 'herdcows', desc = Config.Language.HerdAnimal_desc },
        { label = Config.Language.SellCows, value = 'sellchickens', desc = Config.Language.SellCows_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.ManageChickens,
            align = 'top-left',
            elements = elements,
            lastmenu = 'ManageOwnedAnimalsMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'checkchickens' then
                VORPcore.NotifyRightTip(tostring(cow_cond).. '/' .. tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.MaxCondition))
            elseif data.current.value == 'setchickenscoords' then
                Chickencoords = GetEntityCoords(PlayerPedId())
                VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
            elseif data.current.value == 'herdcows' then
                if Herdlocation ~= nil then
                    MenuData.CloseAll()
                    herdanimals('chickens', ranchcond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            elseif data.current.value == 'sellchickens' then
                if Chickencoords then
                    MenuData.CloseAll()
                    SellAnimals('chickens', cow_cond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            end
        end)
end)

--------- Manage Goats Menu ------
RegisterNetEvent('bcc-ranch:ManageOwnedGoatMenu', function(cow_cond, ranchcond)
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.CheckAnimalCond, value = 'checkgoats', desc = Config.Language.CheckAnimalCond_desc },
        { label = Config.Language.SetCoords, value = 'setgoatscoords', desc = Config.Language.SetCoords_desc },
        { label = Config.Language.HerdAnimal, value = 'herdcows', desc = Config.Language.HerdAnimal_desc },
        { label = Config.Language.SellCows, value = 'sellgoats', desc = Config.Language.SellCows_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.ManageGoats,
            align = 'top-left',
            elements = elements,
            lastmenu = 'ManageOwnedAnimalsMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'checkgoats' then
                VORPcore.NotifyRightTip(tostring(cow_cond).. '/' .. tostring(Config.RanchSetup.RanchAnimalSetup.Goats.MaxCondition))
            elseif data.current.value == 'setgoatscoords' then
                Goatcoords = GetEntityCoords(PlayerPedId())
                VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
            elseif data.current.value == 'herdcows' then
                if Herdlocation ~= nil then
                    MenuData.CloseAll()
                    herdanimals('goats', ranchcond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            elseif data.current.value == 'sellgoats' then
                if Goatcoords then
                    MenuData.CloseAll()
                    SellAnimals('goats', cow_cond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            end
        end)
end)

--------- Manage Pigs Menu ------
RegisterNetEvent('bcc-ranch:ManageOwnedPigMenu', function(cow_cond, ranchcond)
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.CheckAnimalCond, value = 'checkpigs', desc = Config.Language.CheckAnimalCond_desc },
        { label = Config.Language.SetCoords, value = 'setpigscoords', desc = Config.Language.SetCoords_desc },
        { label = Config.Language.HerdAnimal, value = 'herdcows', desc = Config.Language.HerdAnimal_desc },
        { label = Config.Language.SellCows, value = 'sellpigs', desc = Config.Language.SellCows_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.ManagePigs,
            align = 'top-left',
            elements = elements,
            lastmenu = 'ManageOwnedAnimalsMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'checkpigs' then
                VORPcore.NotifyRightTip(tostring(cow_cond).. '/' .. tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.MaxCondition))
            elseif data.current.value == 'setpigscoords' then
                Pigcoords = GetEntityCoords(PlayerPedId())
                VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
            elseif data.current.value == 'herdcows' then
                if Herdlocation ~= nil then
                    MenuData.CloseAll()
                    herdanimals('pigs', ranchcond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            elseif data.current.value == 'sellpigs' then
                if Pigcoords then
                    MenuData.CloseAll()
                    SellAnimals('pigs', cow_cond)
                else
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                end
            end
        end)
end)