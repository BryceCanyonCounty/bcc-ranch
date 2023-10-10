----- Variabless -----
Cowcoords, Chickencoords, Goatcoords, Pigcoords, Herdlocation, FeedWagonLocation, BoughtCows, BoughtChickens, BoughtGoats, BoughtPigs, IsAnimalOut, CanFeed, CanSell =
    nil, nil, nil, nil, nil, nil, true, true, true, true, nil, false, false

------ Buy Animals Menu --------
function BuyAnimalMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        {
            label = _U("BuyCows") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Cows.Cost),
            value =
            'buycows',
            desc =
                _U("BuyAnimals_desc")
        },
        {
            label = _U("BuyPigs") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Pigs.Cost),
            value =
            'buypigs',
            desc =
                _U("BuyPigs_desc")
        },
        {
            label = _U("BuyGoats") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Goats.Cost),
            value =
            'buygoats',
            desc =
                _U("BuyGoats_desc")
        },
        {
            label = _U("BuyChickens") .. ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.Cost),
            value =
            'buychickens',
            desc =
                _U("BuyChickens_desc")
        },
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
            local MenuApiSelection = {
                ['buycows'] = function()
                    BoughtCows = false
                    Cowsage = 0
                    Wait(200)
                    BoughtCows = true
                    TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'cows')
                end,
                ['buypigs'] = function()
                    BoughtPigs = false
                    Pigsage = 0
                    Wait(200)
                    BoughtPigs = true
                    TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'pigs')
                end,
                ['buychickens'] = function()
                    BoughtChickens = false
                    Chickensage = 0
                    Wait(200)
                    BoughtChickens = true
                    TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'chickens')
                end,
                ['buygoats'] = function()
                    BoughtGoats = false
                    Goatsage = 0
                    Wait(200)
                    BoughtGoats = true
                    TriggerServerEvent('bcc-ranch:BuyAnimals', RanchId, 'goats')
                end
            }
            if MenuApiSelection[data.current.value] then
                MenuApiSelection[data.current.value]()
            end
        end)
end

--------- Manage Animals Menu ------
function ManageOwnedAnimalsMenu()
    Inmenu = false
    MenuData.CloseAll()

    -- added / changed by Little Creek
    local set_or_change_herd, set_or_change_herd_desc, set_or_change_feed_wagon, set_or_change_feed_wagon_desc = '', '',
        '', ''

    if Herdlocation and Herdlocation ~= 'none' then
        set_or_change_herd = 'ChangeHerdLocation'
        set_or_change_herd_desc = 'ChangeHerdLocation_desc'
    else
        set_or_change_herd = 'SetHerdLocation'
        set_or_change_herd_desc = 'SetHerdLocation_desc'
    end

    if FeedWagonLocation and FeedWagonLocation ~= 'none' then
        set_or_change_feed_wagon = 'ChangeFeedWagonLocation'
        set_or_change_feed_wagon_desc = 'ChangeFeedWagonLocation_desc'
    else
        set_or_change_feed_wagon = 'SetFeedWagonLocation'
        set_or_change_feed_wagon_desc = 'SetFeedWagonLocation_desc'
    end

    local elements = {
        { label = _U(set_or_change_herd),       value = 'setherdlocation',      desc = _U(set_or_change_herd_desc) },
        { label = _U(set_or_change_feed_wagon), value = 'setfeedwagonlocation', desc = _U(set_or_change_feed_wagon_desc) },
        { label = _U('ManageCows'),             value = 'managecows',           desc = _U('ManageCows_desc') },
        { label = _U('ManagePigs'),             value = 'managepigs',           desc = _U('ManagePigs_desc') },
        { label = _U('ManageGoats'),            value = 'managegoats',          desc = _U('ManageGoats_desc') },
        { label = _U('ManageChickens'),         value = 'managechickens',       desc = _U('ManageChickens_desc') },
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

            local selectedOption = {
                ['setherdlocation'] = function()
                    if dist > Config.RanchSetup.HerdingMinDistance then
                        TriggerServerEvent("bcc-ranch:AnimalLocationDbInserts", pl, RanchId, 'herdcoords')
                        Herdlocation = pl
                    else
                        VORPcore.NotifyRightTip(_U("TooCloseToRanch"), 4000)
                    end
                end,
                ['setfeedwagonlocation'] = function()
                    TriggerServerEvent("bcc-ranch:AnimalLocationDbInserts", pl, RanchId, 'feedwagoncoords')
                    FeedWagonLocation = pl
                end,
                ['managecows'] = function()
                    TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'cows')
                end,
                ['managechickens'] = function()
                    TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'chickens')
                end,
                ['managegoats'] = function()
                    TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'goats')
                end,
                ['managepigs'] = function()
                    TriggerServerEvent('bcc-ranch:CheckIfAnimalsAreOwned', RanchId, 'pigs')
                end
            }
            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end

--------------------------- Owned Animal Manager Menu ----------------------------------
RegisterNetEvent('bcc-ranch:OwnedAnimalManagerMenu', function(animalCond, animalType, ranchCond, ownerStaticId)
    local elements, title, maxCond, herdType
    local set_or_change, set_or_change_desc -- added by Little Creek
    MenuData.CloseAll()
    local selectedElements = {
        ['pigs'] = function()
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
                { label = _U("CheckAnimalCond"), value = 'checkanimal',     desc = _U("CheckAnimalCond_desc") },
                { label = _U(set_or_change),     value = 'setanimalcoords', desc = _U(set_or_change_desc) },
                { label = _U("HerdAnimal"),      value = 'herdanimal',      desc = _U("HerdAnimal_desc") },
                { label = _U("SellCows"),        value = 'sellanimal',      desc = _U("SellCows_desc") },
                { label = _U("ButcherAnimal"),   value = 'butcheranimal',   desc = _U("ButcherAnimal_desc") },
                { label = _U("FeedAnimals"),     value = 'feedanimal',      desc = _U("FeedAnimals_desc") },
            }
            -- end added / changed by Little Creek
        end,
        ['goats'] = function()
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
                { label = _U("CheckAnimalCond"), value = 'checkanimal',     desc = _U("CheckAnimalCond_desc") },
                { label = _U(set_or_change),     value = 'setanimalcoords', desc = _U(set_or_change_desc) },
                { label = _U("HerdAnimal"),      value = 'herdanimal',      desc = _U("HerdAnimal_desc") },
                { label = _U("SellCows"),        value = 'sellanimal',      desc = _U("SellCows_desc") },
                { label = _U("ButcherAnimal"),   value = 'butcheranimal',   desc = _U("ButcherAnimal_desc") },
                { label = _U("FeedAnimals"),     value = 'feedanimal',      desc = _U("FeedAnimals_desc") },
            }
            -- end added / changed by Little Creek
        end,
        ['chickens'] = function()
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
                { label = _U("CheckAnimalCond"), value = 'checkanimal',     desc = _U("CheckAnimalCond_desc") },
                { label = _U(set_or_change),     value = 'setanimalcoords', desc = _U(set_or_change_desc) },
                { label = _U("HerdAnimal"),      value = 'herdanimal',      desc = _U("HerdAnimal_desc") },
                { label = _U("SellCows"),        value = 'sellanimal',      desc = _U("SellCows_desc") },
                { label = _U("ButcherAnimal"),   value = 'butcheranimal',   desc = _U("ButcherAnimal_desc") },
                { label = _U("FeedAnimals"),     value = 'feedanimal',      desc = _U("FeedAnimals_desc") },
            }
            -- end added / changed by Little Creek
            --This insert is done to hide the buying coop option or the harvest egg option depending on if you own a coop or not
            if ChickenCoop == 'none' then
                table.insert(elements,
                    {
                        label = _U("BuyChickenCoop") ..
                            ' ' .. tostring(Config.RanchSetup.RanchAnimalSetup.Chickens.CoopCost),
                        value = 'buychickencoop',
                        desc = _U("BuyChickenCoop_desc")
                    })
            else
                table.insert(elements,
                    { label = _U("HarvestFromCoop"), value = 'harvestchickencoop', desc = _U("HarvestFromCoop_desc") })
            end
        end,
        ['cows'] = function()
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
                { label = _U("CheckAnimalCond"), value = 'checkanimal',     desc = _U("CheckAnimalCond_desc") },
                { label = _U(set_or_change),     value = 'setanimalcoords', desc = _U(set_or_change_desc) },
                { label = _U("HerdAnimal"),      value = 'herdanimal',      desc = _U("HerdAnimal_desc") },
                { label = _U("SellCows"),        value = 'sellanimal',      desc = _U("SellCows_desc") },
                { label = _U("ButcherAnimal"),   value = 'butcheranimal',   desc = _U("ButcherAnimal_desc") },
                { label = _U("FeedAnimals"),     value = 'feedanimal',      desc = _U("FeedAnimals_desc") },
                { label = _U("milkCows"),        value = 'milkanimal',      desc = _U("milkCows_desc") },
            }
            -- end added / changed by Little Creek
        end
    }
    if selectedElements[animalType] then
        selectedElements[animalType]()
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
            local selectedOption = {
                ['checkanimal'] = function()
                    VORPcore.NotifyRightTip(tostring(animalCond) .. '/' .. maxCond)
                end,
                ['setanimalcoords'] = function()
                    local pl = GetEntityCoords(PlayerPedId())
                    local setAnimalSelected = {
                        ['pigs'] = function()
                            TriggerServerEvent("bcc-ranch:AnimalLocationDbInserts", pl, RanchId, 'pigcoords')
                            Pigcoords = pl
                        end,
                        ['goats'] = function()
                            TriggerServerEvent("bcc-ranch:AnimalLocationDbInserts", pl, RanchId, 'goatcoords')
                            Goatcoords = pl
                        end,
                        ['chickens'] = function()
                            TriggerServerEvent("bcc-ranch:AnimalLocationDbInserts", pl, RanchId, 'chickencoords')
                            Chickencoords = pl
                        end,
                        ['cows'] = function()
                            TriggerServerEvent("bcc-ranch:AnimalLocationDbInserts", pl, RanchId, 'cowcoords')
                            Cowcoords = pl
                        end
                    }
                    if setAnimalSelected[animalType] then
                        setAnimalSelected[animalType]()
                    end
                end,
                ['herdanimal'] = function()
                    if Herdlocation ~= nil and Herdlocation ~= 'none' then
                        TriggerServerEvent('bcc-ranch:CheckAnimalsOut', RanchId)
                        Wait(250)
                        if IsAnimalOut == 0 then
                            MenuData.CloseAll()
                            herdanimals(herdType, ranchCond)
                        else
                            VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                        end
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                end,
                ['sellanimal'] = function()
                    TriggerServerEvent('bcc-ranch:CheckAnimalsOut', RanchId)
                    Wait(250)
                    if IsAnimalOut == 0 then
                        MenuData.CloseAll()
                        CanSell = true
                    end
                    local sellAnimalSelected = {
                        ['pigs'] = function()
                            if Pigcoords and Pigcoords ~= 'none' then
                                if CanSell then
                                    MenuData.CloseAll()
                                    SellAnimals('pigs')
                                else
                                    VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                end
                                MenuData.CloseAll()
                                SellAnimals('pigs', animalCond)
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end,
                        ['goats'] = function()
                            if Goatcoords and Goatcoords ~= 'none' then
                                if CanSell then
                                    MenuData.CloseAll()
                                    SellAnimals('goats')
                                else
                                    VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                end
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end,
                        ['chickens'] = function()
                            if Chickencoords and Chickencoords ~= 'none' then
                                if CanSell then
                                    MenuData.CloseAll()
                                    SellAnimals('chickens')
                                else
                                    VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                end
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end,
                        ['cows'] = function()
                            if Cowcoords and Cowcoords ~= 'none' then
                                if CanSell then
                                    MenuData.CloseAll()
                                    SellAnimals('cows')
                                else
                                    VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                end
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end
                    }
                    if sellAnimalSelected[animalType] then
                        sellAnimalSelected[animalType]()
                    end
                end,
                ['butcheranimal'] = function()
                    local butcherSelectedOption = {
                        ['pigs'] = function()
                            if Pigcoords ~= nil and Pigcoords ~= 'none' then
                                MenuData.CloseAll()
                                ButcherAnimals('pigs')
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end,
                        ['goats'] = function()
                            if Goatcoords ~= nil and Goatcoords ~= 'none' then
                                MenuData.CloseAll()
                                ButcherAnimals('goats')
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end,
                        ['chickens'] = function()
                            if Chickencoords and Chickencoords ~= 'none' then
                                MenuData.CloseAll()
                                ButcherAnimals('chickens')
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end,
                        ['cows'] = function()
                            if Cowcoords and Cowcoords ~= 'none' then
                                MenuData.CloseAll()
                                ButcherAnimals('cows')
                            else
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            end
                        end
                    }
                    if butcherSelectedOption[animalType] then
                        butcherSelectedOption[animalType]()
                    end
                end,
                ['feedanimal'] = function()
                    if FeedWagonLocation then
                        TriggerServerEvent('bcc-ranch:CheckAnimalsOut', RanchId)

                        Wait(250)
                        if IsAnimalOut == 0 then
                            MenuData.CloseAll()
                            CanFeed = true
                        end
                        local feedAnimalSelected = {
                            ['pigs'] = function()
                                if Pigcoords ~= nil and Pigcoords ~= 'none' then
                                    if CanFeed then
                                        MenuData.CloseAll()
                                        TriggerServerEvent('bcc-ranch:ChoreCooldownSV', GetPlayerServerId(PlayerId()),RanchId, true, nil, 'pigs')
                                    else
                                        VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                                end
                            end,
                            ['goats'] = function()
                                if Goatcoords ~= nil and Goatcoords ~= 'none' then
                                    if CanFeed then
                                        MenuData.CloseAll()
                                        TriggerServerEvent('bcc-ranch:ChoreCooldownSV',GetPlayerServerId(PlayerId()), RanchId, true, nil, 'goats')
                                    else
                                        VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                                end
                            end,
                            ['chickens'] = function()
                                if Chickencoords and Chickencoords ~= 'none' then
                                    if CanFeed then
                                        MenuData.CloseAll()
                                        TriggerServerEvent('bcc-ranch:ChoreCooldownSV',GetPlayerServerId(PlayerId()), RanchId, true, nil, 'chickens')
                                    else
                                        VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                                end
                            end,
                            ['cows'] = function()
                                if Cowcoords and Cowcoords ~= 'none' then
                                    if CanFeed then
                                        MenuData.CloseAll()
                                        TriggerServerEvent('bcc-ranch:ChoreCooldownSV',GetPlayerServerId(PlayerId()), RanchId, true, nil, 'cows')
                                    else
                                        VORPcore.NotifyRightTip(_U("AnimalsOut"), 4000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                                end
                            end
                        }
                        if feedAnimalSelected[animalType] then
                            feedAnimalSelected[animalType]()
                        end
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                end,
                ['buychickencoop'] = function()
                    if ChickenCoop ~= 'none' then
                        VORPcore.NotifyRightTip(_U("AlreadyOwnCoop"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChickenCoopFundsCheck')
                    end
                end,
                ['harvestchickencoop'] = function()
                    if ChickenCoop ~= 'none' then
                        TriggerServerEvent('bcc-ranch:CoopCollectionCooldown', RanchId)
                    else
                        VORPcore.NotifyRightTip(_U("NoCoop"), 4000)
                    end
                end,
                ['milkanimal'] = function()
                    if Cowcoords and Cowcoords ~= 'none' then
                        TriggerServerEvent('bcc-ranch:CowMilkingCooldown', RanchId)
                    else
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    end
                end
            }
            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end)
