function EmployeesMenu()
    BCCRanchMenu:Close()
    local employeesPage = BCCRanchMenu:RegisterPage("bcc-ranch:employeesPage")
    employeesPage:RegisterElement("header", {
        value = _U("employees"),
        slot = "header",
        style = {}
    })
    employeesPage:RegisterElement("button", {
        label = _U("hire"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:GetEmployeeList', RanchData.ranchid, "hire")
    end)
    employeesPage:RegisterElement("button", {
        label = _U("fire"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:GetEmployeeList', RanchData.ranchid, "fire")
    end)
    employeesPage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        MainRanchMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = employeesPage
    })
end

--Firing employee menu --
RegisterNetEvent('bcc-ranch:FireEmployeesMenu', function(employees)
    BCCRanchMenu:Close()
    local fireEmployeePage = BCCRanchMenu:RegisterPage("bcc-ranch:fireEmployeePage")
    fireEmployeePage:RegisterElement("header", {
        value = _U("fire"),
        slot = "header",
        style = {}
    })
    for k, v in pairs(employees) do
        fireEmployeePage:RegisterElement("button", {
            label = v.firstname .. " " .. v.lastname,
            style = {}
        }, function()
            VORPcore.NotifyRightTip(_U("fired"), 4000)
            TriggerServerEvent('bcc-ranch:FireEmployee', v.charidentifier)
        end)
    end
    fireEmployeePage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        EmployeesMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = fireEmployeePage
    })
end)

---@param currentEmployees table
RegisterNetEvent('bcc-ranch:HireEmployeeMenu', function(currentEmployees)
    print("Called")
    local hireEmployeePage = BCCRanchMenu:RegisterPage("bcc-ranch:hireEmployeePage")
    hireEmployeePage:RegisterElement("header", {
        value = _U("hire"),
        slot = "header",
        style = {}
    })
    local players = GetPlayers()
    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)
    for k, v in pairs(players) do
        if #currentEmployees > 0 then
            for e, a in pairs(currentEmployees) do
                if a.serverId == v.serverId then
                    table.remove(players, k)
                end
            end
        end
        if GetPlayerServerId(PlayerId()) ~= v.serverId then
            hireEmployeePage:RegisterElement("button", {
                label = v.PlayerName,
                style = {}
            }, function()
                VORPcore.NotifyRightTip(_U("hired"), 4000)
                TriggerServerEvent('bcc-ranch:EmployeeHired', RanchData.ranchid, v.serverId, v.staticid)
            end)
        end
    end
    hireEmployeePage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        EmployeesMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = hireEmployeePage
    })
end)