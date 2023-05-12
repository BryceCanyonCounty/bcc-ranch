----------- Catching Ranches ------------
local ranches
RegisterNetEvent('bcc-ranch:CatchAllRanches', function(allranches)
    ranches = allranches
    ShowAllRanchesMenu()
end)

------ RanchAdminManagment Menu Setup --------------
function ShowAllRanchesMenu()
    local elements = {}
    MenuData.CloseAll()
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
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
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
function RanchSelected(ranchtable)
    Inmenu = false
    MenuData.CloseAll()
    local elements = {
        { label = _U("DeleteRanch"), value = 'delranch', desc = _U('DeleteRanch_desc') },
        { label = _U("ChangeRanchRadius"), value = 'changeradius', desc = _U("ChangeRanchRadius_desc") },
        { label = _U("ChangeRanchName"), value = 'changename', desc = _U("ChangeRanchName_desc") },
        { label = _U("ChangeRanchCond"), value = 'changecond', desc = _U("ChangeRanchCond_desc") },
        { label = _U("OpenRanchInventory"), value = 'openinv', desc = _U("OpenRanchInventory_desc") },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("ManageRanches"),
            align = 'top-left',
            lastmenu = 'ShowAllRanchesMenu',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'delranch' then
                TriggerServerEvent('bcc-ranch:DeleteRanchFromDB', ranchtable.ranchid)
                VORPcore.NotifyRightTip(_U('RanchDeleted'), 4000)
                MenuData.CloseAll()
            elseif data.current.value == 'changeradius' then
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
                        TriggerServerEvent('bcc-ranch:ChangeRanchRadius', ranchtable.ranchid, tonumber(result))
                        VORPcore.NotifyRightTip(_U("RadiusChanged"), 4000)
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'changename' then
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
                        TriggerServerEvent('bcc-ranch:ChangeRanchname', ranchtable.ranchid, result)
                        VORPcore.NotifyRightTip(_U("NameChanged"), 4000)
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'changecond' then
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
                        TriggerServerEvent('bcc-ranch:ChangeRanchCondAdminMenu', ranchtable.ranchid, tonumber(result))
                        VORPcore.NotifyRightTip(_U("CondChanged"), 4000)
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'openinv' then
                TriggerServerEvent('bcc-ranch:OpenInv', ranchtable.ranchid)
                MenuData.CloseAll()
            end
        end)
end