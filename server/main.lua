AllPlayersTable = {}

RegisterServerEvent("bcc-ranch:AdminCheck", function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    if character.group == "admin" then
        TriggerClientEvent("bcc-ranch:IsAdminClientReceiver", _source, true)
    end
end)

---@param source integer
RegisterServerEvent("bcc-ranch:StoreAllPlayers", function(source)
    local _source = source
    AllPlayersTable[#AllPlayersTable + 1] = _source -- add all players
end)

------------- Get Players Function Credit to vorp admin for this ------------------
RegisterServerEvent('bcc-ranch:GetPlayers')
AddEventHandler('bcc-ranch:GetPlayers', function()
    local _source = source
    local data = {}

    for _, player in ipairs(AllPlayersTable) do
        local User = VORPcore.getUser(player)
        if User then
            local Character = User.getUsedCharacter                             --get player info

            local playername = Character.firstname .. ' ' .. Character.lastname --player char name

            data[tostring(player)] = {
                serverId = player,
                PlayerName = playername,
                staticid = Character.charIdentifier,
            }
        end
    end
    TriggerClientEvent("bcc-ranch:SendPlayers", _source, data)
end)

BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-ranch')