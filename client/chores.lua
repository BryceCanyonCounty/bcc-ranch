---- Chore Setup ----
RegisterNetEvent('bcc-ranch:ShovelHay', function(chore)
    local chorecoords,choreanim,incamount,animtime

    if chore == 'shovelhay' then
        chorecoords = Haycoords
        choreanim = joaat("WORLD_HUMAN_FARMER_RAKE")
        incamount = Config.ChoreConfig.HayChore.ConditionIncrease
        animtime = Config.ChoreConfig.HayChore.AnimTime
    elseif chore == 'wateranimals' then
        chorecoords = WaterAnimalCoords
        choreanim = joaat('WORLD_HUMAN_BUCKET_POUR_LOW')
        incamount = Config.ChoreConfig.WaterAnimals.ConditionIncrease
        animtime = Config.ChoreConfig.WaterAnimals.AnimTime
    end

    InMission = true
    VORPcore.NotifyRightTip(Config.Language.GoToChoreLocation, 4000)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    
    while true do
        Wait(10)
        if PlayerDead then break end
        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, chorecoords.x, chorecoords.y, chorecoords.z, true)
        if dist < 15 then
            BccUtils.Misc.DrawText3D(chorecoords.x, chorecoords.y, chorecoords.z, Config.Language.StartChore)
        end
        if dist < 5 then
            if IsControlJustReleased(0, 0x760A9C6F) then break end
        end
        if dist > 200 then
            Wait(2000)
        end
    end

    if PlayerDead then
        InMission = false
        VORPcore.NotifyRightTip(Config.Language.PlayerDead, 4000) return
    end

    TaskStartScenarioInPlace(PlayerPedId(), choreanim, animtime, true, false, false, false)
    Wait(animtime)
    ClearPedTasksImmediately(PlayerPedId())
    if PlayerDead then
        InMission = false
        VORPcore.NotifyRightTip(Config.Language.PlayerDead, 4000) return
    end

    VORPcore.NotifyRightTip(Config.Language.ChoreComplete, 4000)
    TriggerServerEvent('bcc-ranch:RanchConditionIncrease', incamount, RanchId)
    InMission = false
end)

---- Dead Check Event -----
AddEventHandler('bcc-ranch:ChoreDeadCheck', function()
    local pl = PlayerPedId()
    while InMission do
        Wait(1000)
        if IsEntityDead(pl) then
            PlayerDead = true break
        end
    end
end)