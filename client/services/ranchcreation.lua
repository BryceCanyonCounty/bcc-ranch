local charid, ownerSource

local function createRanchMenu()
    local ranchName, ranchRadius, taxes = "", "", ""
    BCCRanchMenu:Close()
    local createRanchMenupage = BCCRanchMenu:RegisterPage("bcc-ranch:createRanchMenupage")
    createRanchMenupage:RegisterElement("header", {
        value = _U("ranchCreation"),
        slot = "header",
        style = {}
    })

    createRanchMenupage:RegisterElement("button", {
        label = _U("setOwner")
    }, function()
        PlayerListMenu()
    end)
    createRanchMenupage:RegisterElement("input", {
        label = _U("nameRanch"),
        placeholder = _U("placeHolder"),
        style = {}
    }, function(data)
        ranchName = data.value
    end)
    createRanchMenupage:RegisterElement("input", {
        label = _U("ranchRadius"),
        placeholder = _U("placeHolder"),
        style = {}
    }, function(data)
        ranchRadius = data.value
    end)
    createRanchMenupage:RegisterElement("input", {
        label = _U("ranchTaxes"),
        placeholder = _U("placeHolder"),
        style = {}
    }, function(data)
        taxes = data.value
    end)
    createRanchMenupage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        TriggerServerEvent("bcc-ranch:RanchCreationInsert", charid, ranchName, ranchRadius, taxes, GetEntityCoords(PlayerPedId()), ownerSource)
        BCCRanchMenu:Close()
    end)

    BCCRanchMenu:Open({
        startupPage = createRanchMenupage
    })
end

function PlayerListMenu()
    BCCRanchMenu:Close()
    local players = GetPlayers()
    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    local playerListMenupage = BCCRanchMenu:RegisterPage("bcc-ranch:playerListMenupage")
    playerListMenupage:RegisterElement("header", {
        value = _U("playerList"),
        slot = "header",
        style = {}
    })
    for k, v in pairs(players) do
        playerListMenupage:RegisterElement("button", {
            label = v.PlayerName,
            style = {}
        }, function()
            charid = v.staticid
            ownerSource = v.serverId
            VORPcore.NotifyRightTip(_U("ownerSet"), 4000)
            createRanchMenu()
        end)
    end
    playerListMenupage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        createRanchMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = playerListMenupage
    })
end
-- Note both of these menus are called in local functions due to the fact that if I put the createRanchMenu() function in the RegisterCommand it will not work. As we would have no way of recalling it after we choose the owner from the playerListMenu() function.

RegisterCommand(Config.commands.createRanchCommand, function()
    if IsAdmin then
        createRanchMenu()
    else
        VORPcore.NotifyRightTip(_U("noPermission"), 4000)
    end
end)