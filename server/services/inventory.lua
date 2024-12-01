---@param ranchid integer
RegisterServerEvent('bcc-ranch:OpenInv', function(ranchid)
    local _source = source
    exports.vorp_inventory:openInventory(source, 'Player_' .. ranchid .. '_bcc-ranchinv')
end)

BccUtils.RPC:Register("bcc-ranch:AddItem", function(params, cb, recSource)
    local item = params.item
    local amount = params.amount

    devPrint("Adding item: " .. item .. " with amount: " .. amount .. " for source: " .. recSource)
    exports.vorp_inventory:addItem(recSource, item, amount, {})

    cb(true)
end)
