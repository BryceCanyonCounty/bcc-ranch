VORPcore = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()

if Config.devMode then
    -- Helper function for debugging
    function devPrint(message)
        print("^1[DEV MODE]^3 " .. message .. "^0")
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message)
    end
end

FeatherMenu = exports['feather-menu'].initiate()
BccUtils = exports['bcc-utils'].initiate()
MiniGame = exports['bcc-minigames'].initiate()

BCCRanchMenu = FeatherMenu:RegisterMenu('bcc-ranch:Menu', {
    top = '40%',
    left = '20%',
    ['720width'] = '400px',
    ['1080width'] = '500px',
    ['2kwidth'] = '600px',
    ['4kwidth'] = '800px',
    style = {},
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '500px',
            ['min-height'] = '500px'
        }
    },
    draggable = true
})

function GetPlayers()
    TriggerServerEvent("bcc-ranch:GetPlayers")
    local playersData = {}
    RegisterNetEvent("bcc-ranch:SendPlayers", function(result)
        playersData = result
    end)
    while next(playersData) == nil do
        Wait(10)
    end
    return playersData
end

function PlayAnim(animDict, animName, time) --function to play an animation
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end

    local flag = 16
    -- if time is -1 then play the animation in an infinite loop which is not possible with flag 16 but with 1
    -- if time is -1 the caller has to deal with ending the animation by themselve
    if time == -1 then
        flag = 1
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)
end

-- Set the relationship between ped and player
function relationshipsetup(ped, relInt)
    if not ped or not DoesEntityExist(ped) then
        return
    end

    relInt = tonumber(relInt) or 1 -- fallback to friendly if bad input

    local pedGroup = GetPedRelationshipGroupHash(ped)
    local playerGroup = joaat('PLAYER')

    -- Both directions
    SetRelationshipBetweenGroups(relInt, playerGroup, pedGroup)
    SetRelationshipBetweenGroups(relInt, pedGroup, playerGroup)
end

-- Make the animals follow the player
function SetRelAndFollowPlayer(pedObjs)
    local playerPed = PlayerPedId()

    for _, pedObj in ipairs(pedObjs) do
        if pedObj and pedObj.GetPed then
            local ped = pedObj:GetPed()
            if ped and DoesEntityExist(ped) then
                relationshipsetup(ped, 1)

                -- Apply follow behavior
                TaskFollowToOffsetOfEntity(
                    ped,
                    playerPed,
                    ConfigRanch.ranchSetup.animalFollowSettings.offsetX,
                    ConfigRanch.ranchSetup.animalFollowSettings.offsetY,
                    ConfigRanch.ranchSetup.animalFollowSettings.offsetZ,
                    1.0,                                  -- movement speed (you can make dynamic if wanted)
                    -1,                                   -- timeout (never timeout)
                    5.0,                                  -- stop within 5 meters
                    true, true,
                    ConfigRanch.ranchSetup.animalsWalkOnly, -- walk only or run
                    true, true, true
                )
            end
        end
    end
end

function Notify(message, typeOrDuration, maybeDuration)
    local notifyType = "info"
    local notifyDuration = 6000

    -- Detect which argument is which
    if type(typeOrDuration) == "string" then
        notifyType = typeOrDuration
        notifyDuration = tonumber(maybeDuration) or 6000
    elseif type(typeOrDuration) == "number" then
        notifyDuration = typeOrDuration
    end

    if Config.Notify == "feather-menu" then
        FeatherMenu:Notify({
            message = message,
            type = notifyType,
            autoClose = notifyDuration,
            position = "top-center",
            transition = "slide",
            icon = true,
            hideProgressBar = false,
            rtl = false,
            style = {},
            toastStyle = {},
            progressStyle = {}
        })
    elseif Config.Notify == "vorp-core" then
        -- Only message and duration supported
        VORPcore.NotifyRightTip(message, notifyDuration)
    else
        print("^1[Notify] Invalid Config.Notify: " .. tostring(Config.Notify))
    end
end
