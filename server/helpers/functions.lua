VORPcore = {} --Pulls vorp core
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = exports['bcc-utils'].initiate()