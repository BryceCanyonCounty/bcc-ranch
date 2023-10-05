exports('initiate', function()
    local MinigameAPI = {}

    MinigameAPI.Start = MiniGame.start
    MinigameAPI.Stop = MiniGame.stop
    
    return MinigameAPI
end)