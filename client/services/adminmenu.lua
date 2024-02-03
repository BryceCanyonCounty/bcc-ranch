------ RanchAdminManagment Menu Setup --------------
RegisterNetEvent('bcc-ranch:ShowAllRanchesMenu', function(ranches)
    BCCRanchMenu:Close()
    local showAllRanchesMenuPage = BCCRanchMenu:RegisterPage("bcc-ranch:ShowAllRanchesMenuPage")

    showAllRanchesMenuPage:RegisterElement("header", {
        value = _U("manageRanch"),
        slot = "header",
        style = {}
    })
    for k, v in pairs(ranches) do
        showAllRanchesMenuPage:RegisterElement("button", {
            label = _U('ranchId') .. ' ' .. v.ranchid,
            style = {}
        }, function()
            RanchSelected(v)
        end)
    end

    BCCRanchMenu:Open({
        startupPage = showAllRanchesMenuPage
    })
end)

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
        TriggerServerEvent('bcc-ranch:DeleteRanchFromDB', ranchTable.ranchid)
        VORPcore.NotifyRightTip(_U('ranchDeleted'), 4000)
        BCCRanchMenu:Close()
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
        if tonumber(newRadius) > 0 then
            TriggerServerEvent('bcc-ranch:ChangeRanchRadius', ranchTable.ranchid, tonumber(newRadius))
            VORPcore.NotifyRightTip(_U("radiusChanged"), 4000)
        else
            VORPcore.NotifyRightTip(_U("invalidInput"), 4000)
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
        if newRanchName ~= '' and newRanchName then
            TriggerServerEvent('bcc-ranch:ChangeRanchname', ranchTable.ranchid, newRanchName)
            VORPcore.NotifyRightTip(_U("ranchNameChanged"), 4000)
        else
            VORPcore.NotifyRightTip(_U("invalidInput"), 4000)
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
        if tonumber(newRanchCond) > 0 then
            TriggerServerEvent('bcc-ranch:ChangeRanchCondAdminMenu', ranchTable.ranchid, tonumber(newRanchCond))
            VORPcore.NotifyRightTip(_U("ranchCondChanged"), 4000)
        else
            VORPcore.NotifyRightTip(_U("invalidInput"), 4000)
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

CreateThread(function ()
    if Config.commands.manageRanches then
        RegisterCommand(Config.commands.manageRanches, function(source, args, rawCommand)
            if IsAdmin then
                TriggerServerEvent('bcc-ranch:GetAllRanches')
            end
        end)
    end
end)