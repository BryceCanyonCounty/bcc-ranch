----- Variables -----
Haycoords, WaterAnimalCoords, RepairTroughCoords, ScoopPoopCoords = nil, nil, nil, nil

function CareTakingMenu()
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = _U("ShovelHay"), value = 'shovelhay', desc = _U("ShovelHay_desc") },
        { label = _U("WaterAnimalChore"), value = 'wateranimal', desc = _U("WaterAnimalChore_desc") },
        { label = _U("RepairTroughChore"), value = 'repairfeedtrough', desc = _U("RepairFeedTrough_desc") },
        { label = _U("ScoopPoopChore"), value = 'scooppoop', desc = _U("ScoopPoopChore_desc") }
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

function ChoreMenu(choreType)
    MenuData.CloseAll()
    local elements, title
    if choreType == 'shovelhay' then
        title = _U("ShovelHay")
        elements = {
            { label = _U("ShovelHay"), value = 'start', desc = _U("ShovelHay_desc") },
            { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
        }
    elseif choreType == 'wateranimal' then
        title = _U("WaterAnimalChore")
        elements = {
            { label = _U("WaterAnimalChore"), value = 'start', desc = _U("WaterAnimalChore_desc") },
            { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
        }
    elseif choreType == 'repairfeedtrough' then
        title = _U("RepairTroughChore")
        elements = {
            { label = _U("RepairTroughChore"), value = 'start', desc = _U("RepairFeedTrough_desc") },
            { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
        }
    elseif choreType == 'scooppoop' then
        title = _U("ScoopPoopChore")
        elements = {
            { label = _U("ScoopPoopChore"), value = 'start', desc = _U("ScoopPoopChore_desc") },
            { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
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
                if choreType == 'shovelhay' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        TriggerServerEvent('bcc-ranch:InsertShoveHayCdsIntoDB', GetEntityCoords(PlayerPedId()), RanchId)
                    else
                        VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                    end
                elseif choreType == 'wateranimal' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        TriggerServerEvent('bcc-ranch:InsertWaterAnimalCdsIntoDB', GetEntityCoords(PlayerPedId()), RanchId)
                    else
                        VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                    end
                elseif choreType == 'repairfeedtrough' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        TriggerServerEvent('bcc-ranch:InsertRepairTroughCdsIntoDB', GetEntityCoords(PlayerPedId()), RanchId)
                    else
                        VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                    end
                elseif choreType == 'scooppoop' then
                    if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                        TriggerServerEvent('bcc-ranch:InsertScoopPoopCdsIntoDB', GetEntityCoords(PlayerPedId()), RanchId)
                    else
                        VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                    end
                end
            elseif data.current.value == 'start' then
                if choreType == 'shovelhay' then
                    if not Haycoords then
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'shovelhay')
                        MenuData.CloseAll()
                    end
                elseif choreType == 'wateranimal' then
                    if not WaterAnimalCoords then
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'wateranimals')
                        MenuData.CloseAll()
                    end
                elseif choreType == 'repairfeedtrough' then
                    if not RepairTroughCoords then
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'repairfeedtrough')
                        MenuData.CloseAll()
                    end
                elseif choreType == 'scooppoop' then
                    if not ScoopPoopCoords then
                        VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                    else
                        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'scooppoop')
                        MenuData.CloseAll()
                    end
                end
            end
        end)
end

RegisterNetEvent('bcc_ranch:getHayCoords')
AddEventHandler('bcc_ranch:getHayCoords', function (cds)
    Haycoords = json.decode(cds)
end)

RegisterNetEvent('bcc_ranch:getWaterAnimalCoords')
AddEventHandler('bcc_ranch:getWaterAnimalCoords', function (cds)
    WaterAnimalCoords = json.decode(cds)
end)

RegisterNetEvent('bcc_ranch:getRepairTroughCoords')
AddEventHandler('bcc_ranch:getRepairTroughCoords', function (cds)
    RepairTroughCoords = json.decode(cds)
end)

RegisterNetEvent('bcc_ranch:getScoopPoopCoords')
AddEventHandler('bcc_ranch:getScoopPoopCoords', function (cds)
    ScoopPoopCoords = json.decode(cds)
end)
