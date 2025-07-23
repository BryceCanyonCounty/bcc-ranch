-- Employees Menu
function EmployeesMenu()
    BCCRanchMenu:Close()
    local employeesPage = BCCRanchMenu:RegisterPage("bcc-ranch:employeesPage")
    employeesPage:RegisterElement("header", {
        value = _U("employees"),
        slot = "header",
        style = {}
    })

    -- Button to hire employees
    employeesPage:RegisterElement("button", {
        label = _U("hire"),
        style = {}
    }, function()
        -- Fetch Online Players
        BccUtils.RPC:Call("bcc-ranch:GetPlayers", {}, function(players)
            if not players or #players == 0 then
                Notify(_U("noOnlinePlayersFound"), "warning")
                return
            end

            local hireEmployeePage = BCCRanchMenu:RegisterPage('bcc-ranch:hireEmployeeMenu')
            hireEmployeePage:RegisterElement('header', {
                value = _U("hire"),
                slot = "header"
            })
            hireEmployeePage:RegisterElement('line', { slot = "header" })

            -- Loop through players to display them as hireable candidates
            for _, p in ipairs(players) do
                -- Construct the label with ID, first name, and last name
                local label = "ID: " .. p.charId .. " - " .. p.firstname .. " " .. p.lastname

                hireEmployeePage:RegisterElement('button', {
                    label = label,
                    slot = "content"
                }, function()
                    -- Call the server RPC to hire the employee
                    BccUtils.RPC:Call("bcc-ranch:HireEmployee", {
                        ranchId = RanchData.ranchid,
                        characterId = p.charId
                    }, function(success)
                        if success then
                            -- Hire successful, notify the client
                            Notify(_U("hired"), "success")
                            BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee")
                            employeesPage:RouteTo()
                        else
                            -- Employee already exists, no action needed
                            Notify(_U("employeeAlreadyExists"), "warning")
                        end
                    end)
                end)
            end

            hireEmployeePage:RegisterElement('line', { slot = "footer" })
            hireEmployeePage:RegisterElement("button", {
                label = _U('back'),
                slot = "footer"
            }, function()
                employeesPage:RouteTo()
            end)
            hireEmployeePage:RegisterElement('bottomline', { slot = "footer" })

            -- Open the hire employee menu
            BCCRanchMenu:Open({ startupPage = hireEmployeePage })
        end)
    end)

    -- Button to fire employees
    employeesPage:RegisterElement("button", {
        label = _U("fire"),
        style = {}
    }, function()
        -- Requesting employee list
        BccUtils.RPC:Call("bcc-ranch:GetEmployeeList", { ranchId = RanchData.ranchid }, function(employees)
            if not employees or #employees == 0 then
                Notify(_U("noPlayersWithAccess"), "warning")
                return
            end

            local fireEmployeePage = BCCRanchMenu:RegisterPage("bcc-ranch:fireEmployeePage")
            fireEmployeePage:RegisterElement("header", {
                value = _U("fire"),
                slot = "header",
                style = {}
            })

            -- Loop through employees to display them as buttons
            for _, employee in ipairs(employees) do
                fireEmployeePage:RegisterElement("button", {
                    label = employee.firstname .. " " .. employee.lastname,
                    slot = "content"
                }, function()
                    -- Call the server RPC to fire the employee
                    BccUtils.RPC:Call("bcc-ranch:FireEmployee", {
                        ranchId = RanchData.ranchid,
                        characterId = employee.character_id
                    }, function(success)
                        if success then
                            -- Fire employee action
                            Notify(_U("fired") .. " " .. employee.firstname .. " " .. employee.lastname, "success", 4000)
                            employeesPage:RouteTo()
                        else
                            Notify(_U("employeeFireFailed"), "error")
                        end
                    end)
                end)
            end

            -- Footer buttons for back navigation
            fireEmployeePage:RegisterElement('line', { slot = "footer", style = {} })
            fireEmployeePage:RegisterElement("button", {
                label = _U("back"),
                slot = "footer",
                style = {}
            }, function()
                EmployeesMenu()
            end)
            fireEmployeePage:RegisterElement('bottomline', { slot = "footer", style = {} })

            -- Open the fire employee menu
            BCCRanchMenu:Open({ startupPage = fireEmployeePage })
        end)
    end)

    -- Footer buttons for back navigation
    employeesPage:RegisterElement('line', { slot = "footer", style = {} })
    employeesPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer",
        style = {}
    }, function()
        MainRanchMenu()
    end)
    employeesPage:RegisterElement('bottomline', { slot = "footer", style = {} })

    -- Open the employees menu
    BCCRanchMenu:Open({ startupPage = employeesPage })
end
