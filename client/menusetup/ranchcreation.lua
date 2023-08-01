----- Close Menu When Backspaced Out -----
Inmenu = false
local charid = nil

AddEventHandler('bcc-ranch:MenuClose', function()
    while Inmenu do
        Wait(10)
        if IsControlJustReleased(0, 0x156F7119) then
            Inmenu = false
            VORPMenu.CloseAll() break
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
    VORPMenu.CloseAll()

    local elements = {
        { label = _U("StaticId"),         value = 'staticid',    desc = _U("StaticId_desc") },
        { label = _U("NameRanch"),        value = 'nameranch',   desc = _U("NameRanch_desc") },
        { label = _U("RanchRadiusLimit"), value = 'radiuslimit', desc = _U("RanchRadiusLimit_desc") },
        { label = _U("Confirm"),          value = 'confirm',     desc = _U("Confirm_desc") }
    }

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title = _U("CreateRanchTitle"),
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['staticid'] = function()
                    PlayerList()
                end,
                ['nameranch'] = function()
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
                            VORPcore.NotifyRightTip(_U("nameSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['radiuslimit'] = function()
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
                            VORPcore.NotifyRightTip(_U("radiusSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['confirm'] = function()
                    TriggerServerEvent('bcc-ranch:InsertCreatedRanchIntoDB', ranchName, ranchRadius, charid, coords)
                    charid = nil
                    VORPMenu.CloseAll()
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end

--------- Show the player list credit to vorp admin for this
function PlayerList()
    VORPMenu.CloseAll()
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

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
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