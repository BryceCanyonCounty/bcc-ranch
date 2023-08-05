Employees = {}
----- Employee Menu Setup -----
function EmployeeMenu()
    Inmenu = false
    VORPMenu.CloseAll()
    local elements = {
        { label = _U("FireMembers"), value = 'firemembers', desc = _U("FireMembers_desc") },
        { label = _U("Hire"),        value = 'hire',        desc = _U("Hire_desc") },
    }

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title = _U("RanchMenuName"),
            align = 'top-left',
            elements = elements,
            lastmenu = 'MainMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'firemembers' then
                TriggerServerEvent('bcc-ranch:GetEmployeeList', RanchId)
            elseif data.current.value == 'hire' then
                HireEmployees()
            end
        end)
end

RegisterNetEvent('bcc-ranch:ViewEmployeeMenu', function(result)
    VORPMenu.CloseAll()
    local elements, elementIndex = {}, 1
    for k, v in pairs(result) do
        elements[elementIndex] = {
            label = v.firstname,
            value = "players",
            lastmenu = 'EmployeeMenu',
            desc = _U('FireMembers_desc2'),
            info = v

        }
        elementIndex = elementIndex + 1
    end

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title    = _U("RanchMenuName"),
            align    = 'left',
            elements = elements,
            lastmenu = "MainMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            end
            if data.current.value then
                Inmenu = false
                VORPMenu.CloseAll()
                TriggerServerEvent('bcc-ranch:FireEmployee', data.current.info.charidentifier)
                EmployeeMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)

function HireEmployees()
    VORPMenu.CloseAll()
    local elements = {}
    local players = GetPlayers()

    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    for k, playersInfo in pairs(players) do
        elements[#elements + 1] = {
            label = playersInfo.PlayerName,
            value = "players" .. k,
            lastmenu = 'EmployeeMenu',
            info = playersInfo

        }
    end

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title    = _U("ManageEmployee"),
            subtext  = _U("ManageEmployee_desc"),
            align    = 'top-left',
            elements = elements,
            lastmenu = 'EmployeeMenu',
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                TriggerServerEvent('bcc-ranch:HireEmployee', RanchId, data.current.info.staticid, data.current.info.serverId)
                VORPcore.NotifyRightTip(_U("Hired"), 4000)
            end
        end)
end