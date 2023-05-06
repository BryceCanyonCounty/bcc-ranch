----- Variables -----
Haycoords = nil
WaterAnimalCoords = nil

function CareTakingMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.ShovelHay, value = 'shovelhay', desc = Config.Language.ShovelHay_desc },
        { label = Config.Language.WaterAnimalChore, value = 'wateranimal', desc = Config.Language.WaterAnimalChore_desc },
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
            if data.current.value == 'shovelhay' then
                ShovelhayMenu()
            elseif data.current.value == 'wateranimal' then
                WaterAnimalMenu()
            end
        end)
end

function ShovelhayMenu()
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.SetCoords, value = 'setcoords', desc = Config.Language.SetCoords_desc },
        { label = Config.Language.ShovelHay, value = 'start', desc = Config.Language.ShovelHay_desc }
    }
    
    
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.ShovelHay,
            align = 'top-left',
            elements = elements,
            lastmenu = 'CareTakingMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'setcoords' then
                local plc = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                    Haycoords = GetEntityCoords(PlayerPedId())
                    VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
                else
                    VORPcore.NotifyRightTip(Config.Language.TooFarFromRanch, 4000)
                end
            elseif data.current.value == 'start' then
                if not Haycoords then
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                else
                    TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'shovelhay')
                    MenuData.CloseAll()
                end
            end
        end)
end

function WaterAnimalMenu()
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.SetCoords, value = 'setcoords', desc = Config.Language.SetCoords_desc },
        { label = Config.Language.WaterAnimalChore, value = 'start', desc = Config.Language.WaterAnimalChore_desc }
    }
    
    
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.WaterAnimalChore,
            align = 'top-left',
            elements = elements,
            lastmenu = 'CareTakingMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'setcoords' then
                local plc = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                    WaterAnimalCoords = GetEntityCoords(PlayerPedId())
                    VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
                else
                    VORPcore.NotifyRightTip(Config.Language.TooFarFromRanch, 4000)
                end

            elseif data.current.value == 'start' then
                if not WaterAnimalCoords then
                    VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                else
                    TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'wateranimals')
                    MenuData.CloseAll()
                end
            end
        end)
end