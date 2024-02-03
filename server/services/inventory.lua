RegisterServerEvent('bcc-ranch:OpenInv', function(ranchid)
    local _source = source
    VORPInv.OpenInv(_source, 'Player_' .. ranchid .. '_bcc-ranchinv')
end)

RegisterServerEvent('bcc-ranch:AddItem', function(item, amount)
    local _source = source
    VORPInv.addItem(_source, item, amount)
end)