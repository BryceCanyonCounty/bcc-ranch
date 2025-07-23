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
            end
        end)
    end)
    createRanchMenupage:RegisterElement("button", {
        label = _U("back"),
        slot = 'footer',
        style = {}
    }, function()
        manageRanchesMain()
    end)

    createRanchMenupage:RegisterElement("bottomline", {
        slot = "footer",
        style = {}
    })
    BCCRanchMenu:Open({ startupPage = createRanchMenupage })
end

function PlayerListMenu()
    BccUtils.RPC:Call("bcc-ranch:GetPlayers", {}, function(players)
        if not players or #players == 0 then
            Notify(_U("noOnlinePlayersFound"), "warning")
            return
        end

        local playerListMenupage = BCCRanchMenu:RegisterPage("bcc-ranch:playerListMenupage")
        playerListMenupage:RegisterElement("header", {
            value = _U("playerList"),
            slot = "header",
            style = {}
        })

        for _, p in ipairs(players) do
            local label = "ID: " .. p.charId .. " - " .. p.firstname .. " " .. p.lastname
            playerListMenupage:RegisterElement("button", {
                label = label,
                style = {}
            }, function()
                charid = p.charId
                ownerSource = p.source
                Notify(_U("ownerSet"), "success", 4000)
                createRanchMenu()
            end)
        end

        playerListMenupage:RegisterElement("line", { slot = "footer", style = {} })
        playerListMenupage:RegisterElement("button", {
            label = _U("back"),
            slot = 'footer',
            style = {}
        }, function()
            createRanchMenu()
        end)
        playerListMenupage:RegisterElement("bottomline", { slot = "footer", style = {} })

        BCCRanchMenu:Open({ startupPage = playerListMenupage })
    end)
end
