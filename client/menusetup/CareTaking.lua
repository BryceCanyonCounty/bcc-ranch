----- Variables -----
Haycoords, WaterAnimalCoords, RepairTroughCoords, ScoopPoopCoords = nil, nil, nil, nil

function CareTakingMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.ShovelHay, value = 'shovelhay', desc = Config.Language.ShovelHay_desc },
        { label = Config.Language.WaterAnimalChore, value = 'wateranimal', desc = Config.Language.WaterAnimalChore_desc },
        { label = Config.Language.RepairTroughChore, value = 'repairfeedtrough', desc = Config.Language.RepairFeedTrough_desc },
        { label = Config.Language.ScoopPoopChore, value = 'scooppoop', desc = Config.Language.ScoopPoopChore_desc }
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
                ChoreMenu('shovelhay')
            elseif data.current.value == 'wateranimal' then
                ChoreMenu('wateranimal')
            elseif data.current.value == 'repairfeedtrough' then
                ChoreMenu('repairfeedtrough')
            elseif data.current.value == 'scooppoop' then
                ChoreMenu('scooppoop')
            end
        end)
end

function ChoreMenu(choretype)
    MenuData.CloseAll()
    local elements, title
    if choretype == 'shovelhay' then
        title = Config.Language.ShovelHay
        elements = {
            { label = Config.Language.SetCoords, value = 'setcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.ShovelHay, value = 'start', desc = Config.Language.ShovelHay_desc }
        }
    elseif choretype == 'wateranimal' then
        title = Config.Language.WaterAnimalChore
        elements = {
            { label = Config.Language.SetCoords, value = 'setcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.WaterAnimalChore, value = 'start', desc = Config.Language.WaterAnimalChore_desc }
        }
    elseif choretype == 'repairfeedtrough' then
        title = Config.Language.RepairTroughChore
        elements = {
            { label = Config.Language.SetCoords, value = 'setcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.RepairTroughChore, value = 'start', desc = Config.Language.RepairFeedTrough_desc }
        }
    elseif choretype == 'scooppoop' then
        title = Config.Language.ScoopPoopChore
        elements = {
            { label = Config.Language.SetCoords, value = 'setcoords', desc = Config.Language.SetCoords_desc },
            { label = Config.Language.ScoopPoopChore, value = 'start', desc = Config.Language.ScoopPoopChore_desc }
        }
    end
    
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = title,
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
                if choretype == 'shovelhay' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        Haycoords = GetEntityCoords(PlayerPedId())
                        VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
                    else
                        VORPcore.NotifyRightTip(Config.Language.TooFarFromRanch, 4000)
                    end
                elseif choretype == 'wateranimal' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        WaterAnimalCoords = GetEntityCoords(PlayerPedId())
                        VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
                    else
                        VORPcore.NotifyRightTip(Config.Language.TooFarFromRanch, 4000)
                    end
                elseif choretype == 'repairfeedtrough' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        RepairTroughCoords = GetEntityCoords(PlayerPedId())
                        VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
                    else
                        VORPcore.NotifyRightTip(Config.Language.TooFarFromRanch, 4000)
                    end
                elseif choretype == 'scooppoop' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        ScoopPoopCoords = GetEntityCoords(PlayerPedId())
                        VORPcore.NotifyRightTip(Config.Language.Coordsset, 4000)
                    else
                        VORPcore.NotifyRightTip(Config.Language.TooFarFromRanch, 4000)
                    end
                end
            elseif data.current.value == 'start' then
                if choretype == 'shovelhay' then
                    if not Haycoords then
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'shovelhay')
                        MenuData.CloseAll()
                    end
                elseif choretype == 'wateranimal' then
                    if not WaterAnimalCoords then
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'wateranimals')
                        MenuData.CloseAll()
                    end
                elseif choretype == 'repairfeedtrough' then
                    if not RepairTroughCoords then
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'repairfeedtrough')
                        MenuData.CloseAll()
                    end
                elseif choretype == 'scooppoop' then
                    if not ScoopPoopCoords then
                        VORPcore.NotifyRightTip(Config.Language.NoLocationSet, 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'scooppoop')
                        MenuData.CloseAll()
                    end
                end
            end
        end)
end