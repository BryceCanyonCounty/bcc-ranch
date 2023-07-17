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
            local selectedOption = {
                ['shovelhay'] = function()
                    ChoreMenu('shovelhay')
                end,
                ['wateranimal'] = function()
                    ChoreMenu('wateranimal')
                end,
                ['repairfeedtrough'] = function()
                    ChoreMenu('repairfeedtrough')
                end,
                ['scooppoop'] = function()
                    ChoreMenu('scooppoop')
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end

function ChoreMenu(choreType)
    MenuData.CloseAll()
    local elements, title
    local selectedElements = {
        ['shovelhay'] = function()
            title = _U("ShovelHay")
            elements = {
                { label = _U("ShovelHay"), value = 'start', desc = _U("ShovelHay_desc") },
                { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
            }
        end,
        ['wateranimal'] = function()
            title = _U("WaterAnimalChore")
            elements = {
                { label = _U("WaterAnimalChore"), value = 'start', desc = _U("WaterAnimalChore_desc") },
                { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
            }
        end,
        ['repairfeedtrough'] = function()
            title = _U("RepairTroughChore")
            elements = {
                { label = _U("RepairTroughChore"), value = 'start', desc = _U("RepairFeedTrough_desc") },
                { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
            }
        end,
        ['scooppoop'] = function()
            title = _U("ScoopPoopChore")
            elements = {
                { label = _U("ScoopPoopChore"), value = 'start', desc = _U("ScoopPoopChore_desc") },
                { label = _U("SetCoords"), value = 'setcoords', desc = _U("SetCoords_desc") }
            }
        end
    }

    if selectedElements[choreType] then
        selectedElements[choreType]()
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
            local selectedOption = {
                ['setcoords'] = function()
                    local plc = GetEntityCoords(PlayerPedId())
                    local setCoordsOption = {
                        ['shovelhay'] = function()
                            if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                                TriggerServerEvent('bcc-ranch:ChoreInsertIntoDB', GetEntityCoords(PlayerPedId()), RanchId, 'shovehaycoords')
                            else
                                VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                            end
                        end,
                        ['wateranimal'] = function()
                            if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                                TriggerServerEvent('bcc-ranch:ChoreInsertIntoDB', GetEntityCoords(PlayerPedId()), RanchId, 'wateranimalcoords')
                            else
                                VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                            end
                        end,
                        ['repairfeedtrough'] = function()
                            if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                                TriggerServerEvent('bcc-ranch:ChoreInsertIntoDB', GetEntityCoords(PlayerPedId()), RanchId, 'repairtroughcoords')
                            else
                                VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                            end
                        end,
                        ['scooppoop'] = function()
                            if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, tonumber(RanchCoords.x), tonumber(RanchCoords.y), tonumber(RanchCoords.z), true) < tonumber(RanchRadius) then
                                TriggerServerEvent('bcc-ranch:ChoreInsertIntoDB', GetEntityCoords(PlayerPedId()), RanchId, 'scooppoopcoords')
                            else
                                VORPcore.NotifyRightTip(_U("TooFarFromRanch"), 4000)
                            end
                        end
                    }
                    if setCoordsOption[choreType] then
                        setCoordsOption[choreType]()
                    end
                end,
                ['start'] = function()
                    local startOption = {
                        ['shovelhay'] = function()
                            if not Haycoords and Haycoords ~= 'none' then
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            else
                                TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'shovelhay')
                                MenuData.CloseAll()
                            end
                        end,
                        ['wateranimal'] = function()
                            if not WaterAnimalCoords and WaterAnimalCoords ~= 'none' then
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            else
                                TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'wateranimals')
                                MenuData.CloseAll()
                            end
                        end,
                        ['repairfeedtrough'] = function()
                            if not RepairTroughCoords and RepairTroughCoords ~= 'none' then
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            else
                                TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'repairfeedtrough')
                                MenuData.CloseAll()
                            end
                        end,
                        ['scooppoop'] = function()
                            if not ScoopPoopCoords and ScoopPoopCoords ~= 'none' then
                                VORPcore.NotifyRightTip(_U("NoLocationSet"), 4000)
                            else
                                TriggerServerEvent('bcc-ranch:ChoreCheckRanchCondition', RanchId, 'scooppoop')
                                MenuData.CloseAll()
                            end
                        end
                    }

                    if startOption[choreType] then
                        startOption[choreType]()
                    end
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end