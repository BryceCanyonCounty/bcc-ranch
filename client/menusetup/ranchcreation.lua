----- Close Menu When Backspaced Out -----
Inmenu = false
local charid = nil

AddEventHandler('bcc-ranch:MenuClose', function()
    while true do
        Wait(10)
        if IsControlJustReleased(0, 0x156F7119) then
            if Inmenu then
                Inmenu = false
                MenuData.CloseAll()
                break
            end
        end
    end
end)

------ Creating Ranch Menu ------
RegisterNetEvent('bcc-ranch:CreateRanchmenu', function()
    CreateRanchMen()
end)

function CreateRanchMen()
    local ranchName, ranchRadius
    local coords = GetEntityCoords(PlayerPedId())
    Inmenu = true
    TriggerEvent('bcc-ranch:MenuClose')
    MenuData.CloseAll()

    local elements = {
        { label = _U("StaticId"),         value = 'staticid',    desc = _U("StaticId_desc") },
        { label = _U("NameRanch"),        value = 'nameranch',   desc = _U("NameRanch_desc") },
        { label = _U("RanchRadiusLimit"), value = 'radiuslimit', desc = _U("RanchRadiusLimit_desc") },
        { label = _U("Confirm"),          value = 'confirm',     desc = _U("Confirm_desc") }
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("CreateRanchTitle"),
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
                    type = "enableinput",                                               -- don't touch
                    inputType = "textarea",                                             -- input type
                    button = _U("Confirm"),                                             -- button name
                    placeholder = _U("NameRanch"),                                      -- placeholder name
                    style = "block",                                                    -- don't touch
                    attributes = {
                        inputHeader = "",                                               -- header
                        type = "text",                                                  -- inputype text, number,date,textarea ETC
                        pattern = "[A-Za-z]+",                                          --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
                        title = _U("InvalidInput"),                                     -- if input doesnt match show this message
                        style = "border-radius: 10px; background-color: ; border:none;" -- style
                    }
                }
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if result ~= '' and result then
                        ranchName = result
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'radiuslimit' then
                local myInput = {
                    type = "enableinput",                                               -- don't touch
                    inputType = "input",                                                -- input type
                    button = _U("Confirm"),                                             -- button name
                    placeholder = _U("RanchRadiusLimit"),                               -- placeholder name
                    style = "block",                                                    -- don't touch
                    attributes = {
                        inputHeader = "",                                               -- header
                        type = "number",                                                -- inputype text, number,date,textarea ETC
                        pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
                        title = _U("InvalidInput"),                                     -- if input doesnt match show this message
                        style = "border-radius: 10px; background-color: ; border:none;" -- style
                    }
                }
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if tonumber(result) > 0 then
                        ranchRadius = tonumber(result)
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'confirm' then
                TriggerServerEvent('bcc-ranch:InsertCreatedRanchIntoDB', ranchName, ranchRadius, charid, coords)
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
            label = playersInfo.PlayerName .. "<br> " .. _U("CharacterStaticId") .. ' ' .. playersInfo.staticid,
            value = "players" .. k,
            desc = _U("StaticId") .. "<span style=color:MediumSeaGreen;> ",
            info = playersInfo
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("StaticId"),
            subtext    = _U("StaticId_desc"),
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
                VORPcore.NotifyRightTip(_U("OwnerSet"), 4000)
                CreateRanchMen()
            end
        end)
end