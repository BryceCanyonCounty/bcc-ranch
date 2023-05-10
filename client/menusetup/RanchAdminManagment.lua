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
            label = Config.Language.Ranchid .. ' ' .. v.ranchid,
            value = 'ranch' .. k,
            desc = 'Manage Ranch',
            info = v
        }
    end
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = Config.Language.ManageRanches,
            subtext    = Config.Language.ManageRanches_desc,
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
        { label = Config.Language.DeleteRanch, value = 'delranch', desc = Config.Language.DeleteRanch_desc },
        { label = Config.Language.ChangeRanchRadius, value = 'changeradius', desc = Config.Language.ChangeRanchRadius_desc },
        { label = Config.Language.ChangeRanchName, value = 'changename', desc = Config.Language.ChangeRanchName_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.ManageRanches,
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
                VORPcore.NotifyRightTip(Config.Language.RanchDeleted, 4000)
                MenuData.CloseAll()
            elseif data.current.value == 'changeradius' then
                local myInput = {
                    type = "enableinput", -- don't touch
                    inputType = "input", -- input type
                    button = Config.Language.Confirm, -- button name
                    placeholder = Config.Language.RanchRadiusLimit, -- placeholder name
                    style = "block", -- don't touch
                    attributes = {
                        inputHeader = "", -- header
                        type = "number", -- inputype text, number,date,textarea ETC
                        pattern = "[0-9]", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                        title = Config.Language.InvalidInput, -- if input doesnt match show this message
                        style = "border-radius: 10px; background-color: ; border:none;"-- style 
                    }
                }
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if tonumber(result) > 0 then
                        TriggerServerEvent('bcc-ranch:ChangeRanchRadius', ranchtable.ranchid, tonumber(result))
                        VORPcore.NotifyRightTip(Config.Language.RadiusChanged, 4000)
                    else
                        VORPcore.NotifyRightTip(Config.Language.InvalidInput, 4000)
                    end
                end)
            elseif data.current.value == 'changename' then
                local myInput = {
                    type = "enableinput", -- don't touch
                    inputType = "input", -- input type
                    button = Config.Language.Confirm, -- button name
                    placeholder = Config.Language.NameRanch, -- placeholder name
                    style = "block", -- don't touch
                    attributes = {
                        inputHeader = "", -- header
                        type = "text", -- inputype text, number,date,textarea ETC
                        pattern = "[A-Za-z]+", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                        title = Config.Language.InvalidInput, -- if input doesnt match show this message
                        style = "border-radius: 10px; background-color: ; border:none;"-- style 
                    }
                }
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if result ~= '' and result then
                        TriggerServerEvent('bcc-ranch:ChangeRanchname', ranchtable.ranchid, result)
                        VORPcore.NotifyRightTip(Config.Language.NameChanged, 4000)
                    else
                        VORPcore.NotifyRightTip(Config.Language.InvalidInput, 4000)
                    end
                end)
            end
        end)
end