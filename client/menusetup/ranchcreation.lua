----- Close Menu When Backspaced Out -----
Inmenu = false
AddEventHandler('bcc-ranch:MenuClose', function()
    while true do
        Wait(10)
        if IsControlJustReleased(0, 0x156F7119) then
            if Inmenu then
                Inmenu = false
                MenuData.CloseAll()
            end
        end
    end
end)

------ Creating Ranch Menu ------
RegisterNetEvent('bcc-ranch:CreateRanchmenu', function()
    CreateRanchMen()
end)

local charid
function CreateRanchMen()
    local ranchname, ranchradius
    local coords = GetEntityCoords(PlayerPedId())
    Inmenu = true
    TriggerEvent('bcc-ranch:MenuClose')
    MenuData.CloseAll()
    
    local elements = {
        { label = Config.Language.StaticId, value = 'staticid', desc = Config.Language.StaticId_desc },
        { label = Config.Language.NameRanch, value = 'nameranch', desc = Config.Language.NameRanch_desc },
        { label = Config.Language.RanchRadiusLimit, value = 'radiuslimit', desc = Config.Language.RanchRadiusLimit_desc },
        { label = Config.Language.Confirm, value = 'confirm', desc = Config.Language.Confirm_desc }
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.CreateRanchTitle,
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end

            if data.current.value == 'staticid' then
                PlayerList()
            elseif data.current.value == 'nameranch' then
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
                        ranchname = result
                    else
                        VORPcore.NotifyRightTip(Config.Language.InvalidInput, 4000)
                    end
                end)

            elseif data.current.value == 'radiuslimit' then
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
                        ranchradius = tonumber(result)
                    else
                        VORPcore.NotifyRightTip(Config.Language.InvalidInput, 4000)
                    end
                end)

            elseif data.current.value == 'confirm' then
                TriggerServerEvent('bcc-ranch:InsertCreatedRanchIntoDB', ranchname, ranchradius, charid, coords)
                charid = nil
                MenuData.CloseAll()
            end
        end)
end

--------- Show the player list credit to vorp admin for this
function PlayerList()
    MenuData.CloseAll()
    local elements = {}
    local players = GetPlayers()

    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    for k, playersInfo in pairs(players) do
        elements[#elements + 1] = {
            label = playersInfo.PlayerName .. "<br> Character Static ID: " .. playersInfo.staticid,
            value = "players" .. k,
            desc = "Give Player the Ranch? " .. "<span style=color:MediumSeaGreen;> ",
            info = playersInfo
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = Config.Language.StaticId,
            subtext    = Config.Language.StaticId_desc,
            align      = 'top-left',
            elements   = elements,
            lastmenu   = 'CreateRanchMen',
            itemHeight = "4vh",
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                charid = data.current.info.staticid
                VORPcore.NotifyRightTip(Config.Language.OwnerSet, 4000)
                CreateRanchMen()
            end
        end)
end