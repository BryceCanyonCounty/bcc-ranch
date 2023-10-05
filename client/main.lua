MiniGame = {}

MiniGame.start = function(minigame, config, callback)
    MiniGame.callback = callback
    MiniGame.config = config
    MiniGame.game = minigame

    SendNUIMessage({
        action = 'start',
        game = minigame,
        config = config
    })

    if config.focus ~= nil or config.cursor ~= nil then
        local cursor = false
        local focus = true

        if config.cursor then
            cursor = true
        end

        if config.focus == false then
            focus = false
        end
        SetNuiFocus(focus, cursor)
    end
end

MiniGame.stop = function()
    SendNUIMessage({
        action = 'stop'
    })
end


RegisterNUICallback('result', function(data, cb)
    cb('ok')

    if MiniGame.config.focus ~= nil or MiniGame.config.cursor ~= nil then
        SetNuiFocus(false, false)
    end

    if MiniGame.callback then
        MiniGame.callback(data)
    end
end)