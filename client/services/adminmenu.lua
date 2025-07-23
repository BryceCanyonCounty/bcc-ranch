function manageRanchesMain()
    local mainManageRanch = BCCRanchMenu:RegisterPage("bcc-ranch:Main:Ranch:Manage:Page")
    mainManageRanch:RegisterElement("header", {
        value = "Manage Ranches",
        slot = "header",
        style = {}
    })
    mainManageRanch:RegisterElement("button", {
        label = "Create Ranch",
        style = {}
    }, function()
        createRanchMenu()
    end)

    mainManageRanch:RegisterElement("button", {
        label = _U("manageRanch"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:GetAllRanches", {}, function(success, ranches)
            if success then
                local showAllRanchesMenuPage = BCCRanchMenu:RegisterPage("bcc-ranch:ShowAllRanchesMenuPage")
                showAllRanchesMenuPage:RegisterElement("header", {
                    value = _U("manageRanch"),
                    slot = "header",
                    style = {}
                })

                for _, v in pairs(ranches) do
                    local label = _U("ranchId") .. ": " .. v.ranchid ..
                        " | " .. _U("farmName") .. ": " .. (v.ranchname or "N/A") ..
                        " | " .. _U("owner") .. ": " .. (v.firstname or "-") .. " " .. (v.lastname or "-")

                    showAllRanchesMenuPage:RegisterElement("button", {
                        label = label,
                        style = {}
                    }, function()
                        RanchSelected(v)
                    end)
                end

                showAllRanchesMenuPage:RegisterElement("bottomline", {
                    slot = "footer",
                    style = {}
                })

                showAllRanchesMenuPage:RegisterElement("button", {
                    label = _U("backButton"),
                    slot = "footer",
                    style = {}
                }, function()
                    mainManageRanch:RouteTo()
                end)

                showAllRanchesMenuPage:RegisterElement("bottomline", {
                    slot = "footer",
                    style = {}
                })

                BCCRanchMenu:Open({
                    startupPage = showAllRanchesMenuPage
                })
            else
                Notify(_U("FailedToFetchRanches"), "error", 4000)
            end
        end)
    end)

    mainManageRanch:RegisterElement("line", {
        slot = "footer",
        style = {}
    })

    mainManageRanch:RegisterElement("button", {
        label = "Close",
        slot = "footer",
        style = {}
    }, function()
        BCCRanchMenu:Close()
    end)

    mainManageRanch:RegisterElement("bottomline", {
        slot = "footer",
        style = {}
    })
    BCCRanchMenu:Open({
        startupPage = mainManageRanch
    })
end

------------ Ranch Selected Menu --------------
function RanchSelected(ranchTable)
    Inmenu = false
    BCCRanchMenu:Close()
    local ranchSelectedPage = BCCRanchMenu:RegisterPage("bcc-ranch:RanchSelectedPage")
    ranchSelectedPage:RegisterElement("header", {
        value = _U("manageRanch"),
        slot = "header",
        style = {}
    })

    ranchSelectedPage:RegisterElement("button", {
        label = _U("deleteRanch"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:DeleteRanchFromDB", {
            ranchId = ranchTable.ranchid
        }, function(success)
            if success then
                Notify(_U("ranchDeleted"), "success", 4000)
                ClearAllRanchBlips()
                ClearAllRanchEntities()
                BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerOwnsARanch", {}, function(success, ranchData)
                    if success then
                        devPrint("Player owns a ranch: " .. ranchData.ranchname)
                        -- Handle ranch ownership logic
                        handleRanchData(ranchData, true) -- true indicates the player owns the ranch
                    else
                        devPrint("Player does not own a ranch.")
                    end
                end)

                BccUtils.RPC:Call("bcc-ranch:CheckIfPlayerIsEmployee", {}, function(success, ranchData)
                    if success then
                        devPrint("Player is an employee at ranch: " .. ranchData.ranchname)
                        -- Handle employee ranch logic
                        handleRanchData(ranchData, false) -- false indicates the player is an employee, not the owner
                    else
                        devPrint("Player is not an employee at any ranch.")
                    end
                end)
                BCCRanchMenu:Close()
            else
                Notify(_U("deletionFailed"), "error", 4000)
            end
        end)
    end)

    local newRadius = ""
    ranchSelectedPage:RegisterElement("input", {
        label = _U("changeRanchRadius"),
        placeholder = _U("placeHolder"),
        style = {}
    }, function(data)
        newRadius = data.value
    end)

    ranchSelectedPage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        local radius = tonumber(newRadius)
        if radius and radius > 0 then
            BccUtils.RPC:Call("bcc-ranch:ChangeRanchRadius", {
                ranchId = ranchTable.ranchid,
                radius = radius
            }, function(success)
                if success then
                    Notify(_U("radiusChanged"), "success", 4000)
                else
                    Notify(_U("deletionFailed"), "error", 4000)
                end
            end)
        else
            Notify(_U("invalidInput"), "error", 4000)
        end
    end)

    local newRanchName = ""
    ranchSelectedPage:RegisterElement("input", {
        label = _U("changeRanchName"),
        placeholder = _U("placeHolder"),
        style = {}
    }, function(data)
        newRanchName = data.value
    end)

    ranchSelectedPage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        if newRanchName and newRanchName ~= '' then
            BccUtils.RPC:Call("bcc-ranch:ChangeRanchName", {
                ranchId = ranchTable.ranchid,
                name = newRanchName
            }, function(success)
                if success then
                    Notify(_U("ranchNameChanged"), "success", 4000)
                else
                    Notify(_U("deletionFailed"), "error", 4000)
                end
            end)
        else
            Notify(_U("invalidInput"), "error", 4000)
        end
    end)

    local newRanchCond = ""
    ranchSelectedPage:RegisterElement("input", {
        label = _U("changeRanchCond"),
        placeholder = _U("placeHolder"),
        style = {}
    }, function(data)
        newRanchCond = data.value
    end)

    ranchSelectedPage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        local ranchCond = tonumber(newRanchCond)
        if ranchCond and ranchCond > 0 then
            BccUtils.RPC:Call("bcc-ranch:ChangeRanchCondAdminMenu", {
                ranchId = ranchTable.ranchid,
                cond = ranchCond
            }, function(success)
                if success then
                    Notify(_U("ranchCondChanged"), "success", 4000)
                else
                    Notify(_U("deletionFailed"), "error", 4000)
                end
            end)
        else
            Notify(_U("invalidInput"), "error", 4000)
        end
    end)

    ranchSelectedPage:RegisterElement("button", {
        label = _U("openRanchInv"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:OpenInv', ranchTable.ranchid)
        BCCRanchMenu:Close()
    end)

    BCCRanchMenu:Open({
        startupPage = ranchSelectedPage
    })
end

if Config.commands.manageRanches then
    RegisterCommand(Config.commands.manageRanches, function()
        if IsAdmin then
            manageRanchesMain()
        else
            Notify(_U("NoPermission"), "error", 4000)
        end
    end)
end
