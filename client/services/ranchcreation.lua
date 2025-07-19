local ranchName, ranchRadius, ranchTaxAmount, charid, ownerSource = "", "", "", nil, nil

function createRanchMenu()
    BCCRanchMenu:Close()
    local createRanchMenupage = BCCRanchMenu:RegisterPage("bcc-ranch:createRanchMenupage")
    createRanchMenupage:RegisterElement("header", {
        value = _U("ranchCreation"),
        slot = "header",
        style = {}
    })
    createRanchMenupage:RegisterElement("button", {
        label = _U("setOwner"),
        style = {}
    }, function()
        PlayerListMenu(false, function(data)
            charid = data.charId
            ownerSource = data.source
            Notify(_U("ownerSet"), "success", 4000)
            createRanchMenupage:RouteTo()
        end, function()
            createRanchMenupage:RouteTo()
        end)
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
    createRanchMenupage:RegisterElement("line", {
        slot = "footer",
        style = {}
    })
    createRanchMenupage:RegisterElement("button", {
        label = _U("confirm"),
        slot = 'footer',
        style = {}
    }, function()
        -- Validate fields locally
        if ranchName == "" then
            Notify(_U("ranchNameRequired"), "error", 4000)
            return
        end
        if ranchRadius == "" or tonumber(ranchRadius) == nil or tonumber(ranchRadius) <= 0 then
            Notify(_U("validRanchRadiusRequired"), "error", 4000)
            return
        end
        if taxes == "" or tonumber(taxes) == nil or tonumber(taxes) < 0 then
            Notify(_U("validTaxAmountRequired"), "error", 4000)
            return
        end
        if not charid or not ownerSource then
            Notify(_U("ownerSelectionRequired"), "error", 4000)
            return
        end
        -- RPC call to server to create ranch
        BccUtils.RPC:Call("bcc-ranch:CreateRanch", {
            ranchName = ranchName,
            ranchRadius = ranchRadius,
            ranchTaxAmount = taxes,
            ownerCharId = charid,
            ownerSource = ownerSource,
            coords = GetEntityCoords(PlayerPedId())
        }, function(success)
            if success then
                -- Notify success and close the menu
                Notify(_U("ranchCreated"), "success", 4000)
                BCCRanchMenu:Close()
            end
        end)
    end)
    createRanchMenupage:RegisterElement("bottomline", {
        slot = "footer",
        style = {}
    })
    BCCRanchMenu:Open({ startupPage = createRanchMenupage })
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
            charid = v.staticid -- Assign to `charid`
            ownerSource = v.serverId
            Notify(_U("ownerSet"), "success", 4000)
            createRanchMenu()
        end)
    end
    playerListMenupage:RegisterElement("line", {
        slot = "footer",
        style = {}
    })
    playerListMenupage:RegisterElement("button", {
        label = _U("back"),
        slot = 'footer',
        style = {}
    }, function()
        createRanchMenu()
    end)
    playerListMenupage:RegisterElement("bottomline", {
        slot = "footer",
        style = {}
    })
    BCCRanchMenu:Open({
        startupPage = playerListMenupage
    })
end

RegisterCommand(Config.commands.createRanchCommand, function()
    if IsAdmin then
        createRanchMenu()
    else
        Notify(_U("noPermission"), "error", 4000)
    end
end)
