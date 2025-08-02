BccUtils.RPC:Register("bcc-ranch:OpenInv", function(params, cb, recSource)
    local ranchId = tonumber(params.ranchId)
    if not ranchId then
        devPrint("[OpenInv] Invalid or missing ranchId")
        return cb(false)
    end

    devPrint("[OpenInv] Opening inventory for Player_" .. ranchId .. "_bcc-ranchinv (source: " .. tostring(recSource) .. ")")
    exports.vorp_inventory:openInventory(recSource, "Player_" .. ranchId .. "_bcc-ranchinv")

    cb(true)
end)

BccUtils.RPC:Register("bcc-ranch:AddItem", function(params, cb, recSource)
    local item = params.item
    local amount = params.amount

    devPrint("Adding item: " .. item .. " with amount: " .. amount .. " for source: " .. recSource)
    exports.vorp_inventory:addItem(recSource, item, amount, {})

    cb(true)
end)
