----- Hammertime Minigame Config ------------
local hammertimecfg = {
    focus = true, -- Should minigame take nui focus (required)
    cursor = true, -- Should minigame have cursor  (required)
    nails = 7, -- How many nails to be hammered
    type = 'dark-wood' -- What color wood to display (light-wood, medium-wood, dark-wood)
}

---- Chore Setup ----
RegisterNetEvent('bcc-ranch:ShovelHay', function(chore)
    local chorecoords,choreanim,incamount,animtime,minigame,minigamecfg

    if chore == 'shovelhay' then
        chorecoords = Haycoords
        choreanim = joaat("WORLD_HUMAN_FARMER_RAKE")
        incamount = Config.ChoreConfig.HayChore.ConditionIncrease
        animtime = Config.ChoreConfig.HayChore.AnimTime
        minigame = 'skillcheck'
        minigamecfg = Config.ChoreMinigameConfig
    elseif chore == 'wateranimals' then
        chorecoords = WaterAnimalCoords
        choreanim = joaat('WORLD_HUMAN_BUCKET_POUR_LOW')
        incamount = Config.ChoreConfig.WaterAnimals.ConditionIncrease
        animtime = Config.ChoreConfig.WaterAnimals.AnimTime
        minigame = 'skillcheck'
        minigamecfg = Config.ChoreMinigameConfig
    elseif chore == 'repairfeedtrough' then
        chorecoords = RepairTroughCoords
        choreanim = joaat('PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL') --credit syn_construction for anim(just where I found it at lol)
        incamount = Config.ChoreConfig.RepairFeedTrough.ConditionIncrease
        animtime = Config.ChoreConfig.RepairFeedTrough.AnimTime
        minigame = 'hammertime'
        minigamecfg = hammertimecfg
    elseif chore == 'scooppoop' then
        chorecoords = ScoopPoopCoords
        choreanim = joaat('WORLD_HUMAN_PITCH_HAY_SCOOP')
        incamount = Config.ChoreConfig.ShovelPoop.ConditionIncrease
        animtime = Config.ChoreConfig.ShovelPoop.AnimTime
        minigame = 'skillcheck'
        minigamecfg = Config.ChoreMinigameConfig
    end

    InMission = true
    VORPcore.NotifyRightTip(_U("GoToChoreLocation"), 4000)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    
    BccUtils.Misc.SetGps(chorecoords.x, chorecoords.y, chorecoords.z)
    while true do
        Wait(5)
        if PlayerDead then break end
        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, chorecoords.x, chorecoords.y, chorecoords.z, true)
        if dist < 15 then
            BccUtils.Misc.DrawText3D(chorecoords.x, chorecoords.y, chorecoords.z, _U("StartChore"))
        end
        if dist < 5 then
            if IsControlJustReleased(0, 0x760A9C6F) then
                ClearGpsMultiRoute()
                if Config.ChoreMinigames then
                    MiniGame.Start(minigame, minigamecfg, function(result)
                        if minigame == 'hammertime' then
                            if result.result then
                                ChoreComplete(choreanim, animtime, incamount)
                            else
                                InMission = false
                                VORPcore.NotifyRightTip(_U("Failed"), 4000) return
                            end
                        else
                            if result.passed then
                                if chore == 'scooppoop' then
                                    TriggerServerEvent('bcc-ranch:AddItem', Config.ChoreConfig.ShovelPoop.RecievedItem, Config.ChoreConfig.ShovelPoop.RecievedAmount)
                                end
                                ChoreComplete(choreanim, animtime, incamount)
                            else
                                InMission = false
                                VORPcore.NotifyRightTip(_U("Failed"), 4000) return
                            end
                        end
                    end) break
                else
                    BccUtils.Ped.ScenarioInPlace(PlayerPedId(), choreanim, animtime)
                    if PlayerDead then
                        InMission = false
                        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) break
                    end
                    VORPcore.NotifyRightTip(_U("ChoreComplete"), 4000)
                    TriggerServerEvent('bcc-ranch:RanchConditionIncrease', incamount, RanchId)
                    InMission = false break
                end
            end
        end
        if dist > 200 then
            Wait(2000)
        end
    end

    if PlayerDead then
        InMission = false
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) return
    end
    InMission = false
end)

---- Dead Check Event -----
AddEventHandler('bcc-ranch:ChoreDeadCheck', function()
    while InMission do
        Wait(1000)
        if IsEntityDead(PlayerPedId()) then
            PlayerDead = true break
        end
    end
end)

--[[
    8========================D
    Sacred Comment Penis
]]

function ChoreComplete(choreanim, animtime, incamount) --what to do if chore is success
    BccUtils.Ped.ScenarioInPlace(PlayerPedId(), choreanim, animtime)
    if PlayerDead then
        InMission = false
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) return
    end
    VORPcore.NotifyRightTip(_U("ChoreComplete"), 4000)
    TriggerServerEvent('bcc-ranch:RanchConditionIncrease', incamount, RanchId)
    InMission = false
end