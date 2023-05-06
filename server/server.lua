---------- Pulling Essentials -------------
VORPcore = {} --Pulls vorp core
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = {}
TriggerEvent('bcc:getUtils', function(bccutils)
    BccUtils = bccutils
end)

------ Commands Admin Check --------
RegisterServerEvent('bcc-ranch:AdminCheck', function(nextevent, servevent)
    local _source = source
    local User = VORPcore.getUser(_source)
    if User.getGroup == Config.AdminGroupName then
        if servevent then
            TriggerEvent(nextevent)
        else
            TriggerClientEvent(nextevent, _source)
        end
    end
end)