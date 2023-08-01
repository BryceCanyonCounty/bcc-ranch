----------- Catching Ranches ------------
local ranches
RegisterNetEvent('bcc-ranch:CatchAllRanches', function(allRanches)
    ranches = allRanches
    ShowAllRanchesMenu()
end)

------ RanchAdminManagment Menu Setup --------------
function ShowAllRanchesMenu()
    local elements = {}
    VORPMenu.CloseAll()
    Inmenu = true
    TriggerEvent('bcc-ranch:MenuClose')
    for k, v in pairs(ranches) do
        elements[#elements+1] = {
            label = _U('Ranchid') .. ' ' .. v.ranchid,
            value = 'ranch' .. k,
            desc = _U("ManageRanches"),
            info = v
        }
    end
    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title      = _U("ManageRanches"),
            subtext    = _U("ManageRanches_desc"),
            align      = 'top-left',
            elements   = elements,
            lastmenu   = '',
            itemHeight = "4vh",
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                RanchSelected(data.current.info)
            end
        end)
end

------------ Ranch Selected Menu --------------
function RanchSelected(ranchTable)
    Inmenu = false
    VORPMenu.CloseAll()
    local elements = {
        { label = _U("DeleteRanch"), value = 'delranch', desc = _U('DeleteRanch_desc') },
        { label = _U("ChangeRanchRadius"), value = 'changeradius', desc = _U("ChangeRanchRadius_desc") },
        { label = _U("ChangeRanchName"), value = 'changename', desc = _U("ChangeRanchName_desc") },
        { label = _U("ChangeRanchCond"), value = 'changecond', desc = _U("ChangeRanchCond_desc") },
        { label = _U("OpenRanchInventory"), value = 'openinv', desc = _U("OpenRanchInventory_desc") },
    }

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title = _U("ManageRanches"),
            align = 'top-left',
            lastmenu = 'ShowAllRanchesMenu',
            elements = elements
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['delranch'] = function()
                    TriggerServerEvent('bcc-ranch:DeleteRanchFromDB', ranchTable.ranchid)
                    VORPcore.NotifyRightTip(_U('RanchDeleted'), 4000)
                    VORPMenu.CloseAll()
                end,
                ['changeradius'] = function()
                    local myInput = {
                        type = "enableinput", -- don't touch
                        inputType = "input", -- input type
                        button = _U("Confirm"), -- button name
                        placeholder = _U("RanchRadiusLimit"), -- placeholder name
                        style = "block", -- don't touch
                        attributes = {
                            inputHeader = "", -- header
                            type = "number", -- inputype text, number,date,textarea ETC
                            pattern = "[0-9]", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                            title = _U("InvalidInput"), -- if input doesnt match show this message
                            style = "border-radius: 10px; background-color: ; border:none;"-- style 
                        }
                    }
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            TriggerServerEvent('bcc-ranch:ChangeRanchRadius', ranchTable.ranchid, tonumber(result))
                            VORPcore.NotifyRightTip(_U("RadiusChanged"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['changename'] = function()
                    local myInput = {
                        type = "enableinput", -- don't touch
                        inputType = "input", -- input type
                        button = _U("Confirm"), -- button name
                        placeholder = _U("NameRanch"), -- placeholder name
                        style = "block", -- don't touch
                        attributes = {
                            inputHeader = "", -- header
                            type = "text", -- inputype text, number,date,textarea ETC
                            pattern = "[A-Za-z]+", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                            title = _U("InvalidInput"), -- if input doesnt match show this message
                            style = "border-radius: 10px; background-color: ; border:none;"-- style 
                        }
                    }
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if result ~= '' and result then
                            TriggerServerEvent('bcc-ranch:ChangeRanchname', ranchTable.ranchid, result)
                            VORPcore.NotifyRightTip(_U("NameChanged"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['changecond'] = function()
                    local myInput = {
                        type = "enableinput", -- don't touch
                        inputType = "input", -- input type
                        button = _U("Confirm"), -- button name
                        placeholder = _U("InsertRanchCond"), -- placeholder name
                        style = "block", -- don't touch
                        attributes = {
                            inputHeader = "", -- header
                            type = "number", -- inputype text, number,date,textarea ETC
                            pattern = "[0-9]", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                            title = _U("InvalidInput"), -- if input doesnt match show this message
                            style = "border-radius: 10px; background-color: ; border:none;"-- style 
                        }
                    }
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            TriggerServerEvent('bcc-ranch:ChangeRanchCondAdminMenu', ranchTable.ranchid, tonumber(result))
                            VORPcore.NotifyRightTip(_U("CondChanged"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['openinv'] = function()
                    TriggerServerEvent('bcc-ranch:OpenInv', ranchTable.ranchid)
                    VORPMenu.CloseAll()
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end