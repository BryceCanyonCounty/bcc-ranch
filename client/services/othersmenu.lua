-- ensure these exist
activePeds = activePeds or {}
settingNpcPos = settingNpcPos or false

function OthersMenu()
    local othersPage = BCCRanchMenu:RegisterPage("bcc-ranch:othersPage")

    othersPage:RegisterElement("header", {
        value = _U("others"),
        slot = "header"
    })

    othersPage:RegisterElement("line", {
        slot = "header"
    })

    -- Inventory button
    othersPage:RegisterElement("button", {
        label = _U("inventoryName"),
        style = {}
    }, function()
        OpenRanchInventoryPage()
    end)

    -- NPC main button (goes to NPC menu)
    othersPage:RegisterElement("button", {
        label = _U("npcMenuTitle"),
        style = {}
    }, function()
        OpenNpcMenu()
    end)

    -- Footer
    othersPage:RegisterElement("line", {
        slot = "footer"
    })
    othersPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer"
    }, function()
        MainRanchMenu()
    end)
    othersPage:RegisterElement("bottomline", {
        slot = "footer"
    })

    BCCRanchMenu:Open({
        startupPage = othersPage
    })
end

function OpenNpcMenu()
    local npcPage = BCCRanchMenu:RegisterPage("bcc-ranch:npcPage")
    local npcEnabled = RanchData.ranch_npc_enabled == 1
    local label = npcEnabled and _U("npcDisable") or _U("npcEnable")

    -- Header
    npcPage:RegisterElement("header", {
        value = _U("npcMenuTitle"),
        slot = "header"
    })
    npcPage:RegisterElement("line", {
        slot = "header"
    })

    -- Enable/Disable NPC button
    npcPage:RegisterElement("button", {
        label = label
    }, function()
        local newState = not npcEnabled
        BccUtils.RPC:Call("bcc-ranch:SetNpcConfig", {
            ranchId = RanchData.ranchid,
            enabled = newState
        }, function(success)
            if success then
                RanchData.ranch_npc_enabled = newState and 1 or 0
                if newState then
                    -- ENABLE: Spawn NPC
                    local coords = RanchData.ranchcoordsVector3
                    local heading = RanchData.ranch_npc_heading or 0
                    local npc = BccUtils.Ped:Create(ConfigRanch.ranchSetup.npc.model, coords.x, coords.y, coords.z,
                        heading, 'world', true, nil, nil, false)
                    if npc then
                        npc:Freeze(true)
                        npc:SetHeading(heading)
                        npc:Invincible(true)
                        npc:SetBlockingOfNonTemporaryEvents(true)
                        table.insert(activePeds, npc)
                    end
                    Notify(_U("npcEnabledMsg"), "info", 3000)
                else
                    -- DISABLE: Remove NPC
                    for _, v in ipairs(activePeds) do
                        if v and v.Remove then
                            v:Remove()
                        else
                            local handle = v and v.GetPed and v:GetPed() or v
                            if type(handle) == "number" then
                                SetEntityAsMissionEntity(handle, true, true)
                                DeletePed(handle)
                            end
                        end
                    end
                    activePeds = {}
                    Notify(_U("npcDisabledMsg"), "info", 3000)
                end
            else
                Notify(_U("npcUpdateFailed"), "error", 3000)
            end
        end)
        BCCRanchMenu:Close()
    end)

    -- Set NPC position button
    npcPage:RegisterElement("button", {
        label = _U("npcSetPosition")
    }, function()
        BCCRanchMenu:Close()
        StartNpcPlacement()
    end)

    -- Footer
    npcPage:RegisterElement("line", {
        slot = "footer"
    })
    npcPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer"
    }, function()
        OthersMenu()
    end)
    npcPage:RegisterElement("bottomline", {
        slot = "footer"
    })

    BCCRanchMenu:Open({ startupPage = npcPage })
end

function StartNpcPlacement()
    settingNpcPos = true
    local KEY_G = BccUtils.Keys[ConfigRanch.ranchSetup.npc.key]
    local KEY_BACK = BccUtils.Keys[ConfigRanch.ranchSetup.npc.keyBack]

    Notify(
        _U("placementModeActive") ..
        ConfigRanch.ranchSetup.npc.key ..
        _U("placementModeMid") .. ConfigRanch.ranchSetup.npc.keyBack .. _U("placementModeEnd"), "info", 5000)

    CreateThread(function()
        while settingNpcPos and RanchData and RanchData.ranchcoordsVector3 do
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)

            -- safer distance calc (no reliance on vector metamethods)
            local center = RanchData.ranchcoordsVector3
            local dx, dy, dz = playerCoords.x - center.x, playerCoords.y - center.y, playerCoords.z - center.z
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
            local maxRadius = math.max(5, math.min(tonumber(RanchData.ranch_radius_limit) or 50, 500))
            local meters = math.floor(dist + 0.5)

            if dist <= maxRadius then
                BccUtils.Misc.DrawText3D(
                    playerCoords.x,
                    playerCoords.y,
                    playerCoords.z + 1.0,
                    _U("setNPCPosition") ..
                    ConfigRanch.ranchSetup.npc.key ..
                    _U("setNPCPositionMid") ..
                    meters ..
                    _U("setNPCPositionSuffix") ..
                    ConfigRanch.ranchSetup.npc.keyBack ..
                    _U("setNPCPositionEnd")
                )

                if IsControlJustReleased(0, KEY_G) then
                    local heading = GetEntityHeading(ped)

                    -- snap to ground (server gets clean Z)
                    local gotGround, groundZ = GetGroundZAndNormalFor_3dCoord(playerCoords.x, playerCoords.y,
                        playerCoords.z)
                    local spawnZ = gotGround and groundZ or playerCoords.z

                    -- Save new ranchcoords & heading
                    BccUtils.RPC:Call("bcc-ranch:SetNpcConfig", {
                        ranchId = RanchData.ranchid,
                        coords = { x = playerCoords.x, y = playerCoords.y, z = spawnZ },
                        heading = heading
                    }, function(success)
                        if success then
                            -- Update local data
                            RanchData.ranchcoords = { x = playerCoords.x, y = playerCoords.y, z = spawnZ }
                            RanchData.ranchcoordsVector3 = vector3(playerCoords.x, playerCoords.y, spawnZ)
                            RanchData.ranch_npc_heading = heading
                            Notify(_U("npcLocationUpdated"), "success", 3000)

                            for _, v in ipairs(activePeds) do
                                if v and v.Remove then
                                    v:Remove()
                                else
                                    local handle = v and v.GetPed and v:GetPed() or v
                                    if type(handle) == "number" then
                                        SetEntityAsMissionEntity(handle, true, true)
                                        DeletePed(handle)
                                    end
                                end
                            end
                            activePeds = {}
                            local npc = BccUtils.Ped:Create(ConfigRanch.ranchSetup.npc.model, playerCoords.x, playerCoords.y, spawnZ, heading, 'world', true, nil, nil, true, nil)
                            if npc then
                                npc:Freeze(true)
                                npc:SetHeading(heading)
                                npc:Invincible(true)
                                npc:SetBlockingOfNonTemporaryEvents(true)
                                table.insert(activePeds, npc)
                            end
                        else
                            Notify(_U("npcPositionUpdateFailed"), "error", 3000)
                        end
                    end)

                    settingNpcPos = false
                    OthersMenu()
                end
            else
                BccUtils.Misc.DrawText3D(
                    playerCoords.x,
                    playerCoords.y,
                    playerCoords.z + 1.0,
                    _U("tooFarFromRanch") ..
                    meters ..
                    _U("tooFarSuffixStart") ..
                    ConfigRanch.ranchSetup.npc.keyBack ..
                    _U("tooFarSuffixEnd")
                )
            end

            -- allow cancel
            if IsControlJustReleased(0, KEY_BACK) then
                settingNpcPos = false
                Notify(_U("npcPlacementCanceled"), "info", 2000)
                OthersMenu()
            end

            Wait(0)
        end
    end)
end

function OpenRanchInventoryPage()
    local inventoryPage = BCCRanchMenu:RegisterPage("bcc-ranch:inventoryPage")

    inventoryPage:RegisterElement("header", {
        value = _U("inventoryName"),
        slot = "header",
        style = {}
    })

    -- Fetch stage data
    local stageData = BccUtils.RPC:CallAsync("bcc-ranch:GetInventoryStages", { ranchId = RanchData.ranchid })
    local currentStage = (stageData and tonumber(stageData.inventory_current_stage)) or 0
    local nextStage = stageData and stageData.nextStage or false

    -- Calculate current slot limit
    local finalSlots = RanchData.inv_limit
    if ConfigInventory and ConfigInventory.stages then
        for _, stage in ipairs(ConfigInventory.stages) do
            if stage.stage <= currentStage then
                finalSlots = finalSlots + stage.slotIncrease
            end
        end
    end

    -- If there is a next stage, get cost, else show "N/A"
    local stageCost = (stageData and stageData.nextStage and stageData.nextStage.cost) or "N/A"

    -- Build HTML info block
    local htmlContent = [[
    <div style="margin: auto; padding: 20px;">
        <table style="width: 100%; border-collapse: collapse; font-size: 16px;">
            <tr style="border-bottom: 1px solid #ddd;">
                <td style="padding: 6px 10px;">]] .. _U("currentStage") .. [[</td>
                <td style="padding: 6px 10px; color: #2a9d8f;">]] .. tostring(currentStage) .. [[</td>
            </tr>
            <tr style="border-bottom: 1px solid #ddd;">
                <td style="padding: 6px 10px;">]] .. _U("currentSlots") .. [[</td>
                <td style="padding: 6px 10px; color: #f4a261;">]] .. tostring(finalSlots) .. [[</td>
            </tr>
            <tr>
                <td style="padding: 6px 10px;">]] .. _U("stageCost") .. [[</td>
                <td style="padding: 6px 10px; color: #e76f51;">$]] .. tostring(stageCost) .. [[</td>
            </tr>
        </table>
    </div>
    ]]

    inventoryPage:RegisterElement("html", {
        value = { htmlContent },
        slot = "content",
        style = {}
    })

    inventoryPage:RegisterElement("line", {
        slot = "header",
        style = {}
    })

    if nextStage then
        local nextStageLabel = _U("upgradeStage") ..
            tostring(nextStage.stage) ..
            _U("upgradeFor") .. tostring(nextStage.cost) .. _U("upgradeGainSlots") .. tostring(nextStage.slotIncrease)

        inventoryPage:RegisterElement("button", {
            label = nextStageLabel,
            style = {}
        }, function()
            local ok = BccUtils.RPC:CallAsync("bcc-ranch:UpgradeInventory", {
                ranchId = RanchData.ranchid,
                cost = nextStage.cost,
                nextStage = nextStage.stage
            })
            if ok then
                Notify(_U("inventoryUpgraded"), "success", 4000)
                OpenRanchInventoryPage()
            else
                Notify(_U("notEnoughCash"), "error", 4000)
            end
        end)
    else
        inventoryPage:RegisterElement("subheader", {
            value = _U("maxStageReached"),
            slot = "content",
            style = {}
        })
    end

    -- Footer
    inventoryPage:RegisterElement("line", {
        slot = "footer",
        style = {}
    })
    inventoryPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer",
        style = {}
    }, function()
        MainRanchMenu()
    end)
    inventoryPage:RegisterElement("bottomline", {
        slot = "footer",
        style = {}
    })

    inventoryPage:RouteTo()
end
