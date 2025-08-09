local inventoriesRegistered = inventoriesRegistered or {}

-- Helper: Calculate slot limit
local function CalculateFinalLimit(baseLimit, currentStage)
    local finalLimit = baseLimit
    for _, stage in ipairs(ConfigInventory.stages) do
        if stage.stage <= currentStage then
            finalLimit = finalLimit + (stage.slotIncrease or 0)
        end
    end
    return finalLimit
end

-- Open Inventory
BccUtils.RPC:Register("bcc-ranch:openInventory", function(params, cb, recSource)
    local ok, err = pcall(function()
        local ranchId   = tonumber(params.ranchId)
        local ranchName = tostring(params.ranchName)
        local baseLimit = tonumber(params.limit)

        if not ranchId or ranchId <= 0 then
            devPrint("[OpenInv] Invalid ranchId")
            cb(false)
            return
        end

        -- Always get the latest stage from DB
        local ranchData = MySQL.query.await(
            "SELECT inventory_current_stage FROM bcc_ranch WHERE ranchid = ?",
            { ranchId }
        )
        if not ranchData or #ranchData == 0 then
            devPrint("[OpenInv] No ranch row for id " .. ranchId)
            cb(false)
            return
        end

        local currentStage = tonumber(ranchData[1].inventory_current_stage) or 0
        local inventoryId  = "Player_" .. ranchId .. "_bcc-ranchinv"

        -- Register if not already
        if not inventoriesRegistered[ranchId] then
            if not exports.vorp_inventory:isCustomInventoryRegistered(inventoryId) then
                local finalLimit = CalculateFinalLimit(baseLimit, currentStage)
                devPrint("[OpenInv] Registering custom inventory " .. inventoryId .. " (limit " .. finalLimit .. ")")
                exports.vorp_inventory:registerInventory({
                    id = inventoryId,
                    name = ranchName,
                    limit = finalLimit,
                    acceptWeapons = false,
                    shared = true,
                    ignoreItemStackLimit = true,
                    whitelistItems = false,
                    UsePermissions = false,
                    UseBlackList = false,
                    whitelistWeapons = false
                })
            end
            inventoriesRegistered[ranchId] = inventoryId
        end

        -- Always update slot count before opening
        local finalLimit = CalculateFinalLimit(baseLimit, currentStage)
        pcall(function()
            exports.vorp_inventory:updateCustomInventorySlots(inventoryId, finalLimit)
        end)

        devPrint("[OpenInv] Opening " .. inventoryId .. " (finalLimit " .. finalLimit .. ") for src " .. tostring(recSource))
        exports.vorp_inventory:openInventory(recSource, inventoryId)
        cb(true)
    end)

    if not ok then
        devPrint("[OpenInv] RPC handler error: " .. tostring(err))
        cb(false)
    end
end)

-- Upgrade Inventory
BccUtils.RPC:Register("bcc-ranch:UpgradeInventory", function(params, cb, recSource)
    local user = VORPcore.getUser(recSource)
    if not user then return cb(false) end

    local char = user.getUsedCharacter
    if not char then return cb(false) end
    local charFullName = (char.firstname or "") .. " " .. (char.lastname or "")

    local currentStageData = MySQL.query.await(
        "SELECT inventory_current_stage FROM bcc_ranch WHERE ranchid = ?",
        { params.ranchId }
    )
    if not currentStageData or #currentStageData == 0 then return cb(false) end

    local currentStage = tonumber(currentStageData[1].inventory_current_stage) or 0
    if tonumber(params.nextStage) ~= currentStage + 1 then
        devPrint("[Upgrade] Stage skip attempt blocked for ranch " .. params.ranchId)
        return cb(false)
    end

    if char.money < tonumber(params.cost) then
        return cb(false)
    end

    MySQL.query.await(
        "UPDATE bcc_ranch SET inventory_current_stage = ? WHERE ranchid = ?",
        { tonumber(params.nextStage), params.ranchId }
    )
    char.removeCurrency(0, tonumber(params.cost))

    devPrint("[Upgrade] " .. charFullName .. " upgraded ranch " .. params.ranchId .. " to stage " .. params.nextStage)
    cb(true)
end)

-- Get Inventory Stages
BccUtils.RPC:Register("bcc-ranch:GetInventoryStages", function(params, cb, recSource)
    local retval = MySQL.query.await(
        "SELECT inventory_current_stage FROM bcc_ranch WHERE ranchid = ?",
        { params.ranchId }
    )
    if not retval or #retval == 0 then return cb(false) end

    local currentStage = tonumber(retval[1].inventory_current_stage) or 0
    local nextStage = nil
    for _, stage in ipairs(ConfigInventory.stages) do
        if stage.stage > currentStage then
            nextStage = stage
            break
        end
    end

    cb({
        nextStage = nextStage or false,
        inventory_current_stage = currentStage
    })
end)

-- Add Item
BccUtils.RPC:Register("bcc-ranch:AddItem", function(params, cb, recSource)
    devPrint("Adding item: " .. params.item .. " x" .. params.amount .. " for source: " .. recSource)
    exports.vorp_inventory:addItem(recSource, params.item, params.amount, {})
    cb(true)
end)
