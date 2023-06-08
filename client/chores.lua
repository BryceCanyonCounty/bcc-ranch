----- Hammertime Minigame Config ------------
local hammerTimeCfg = {
    focus = true, -- Should minigame take nui focus (required)
    cursor = true, -- Should minigame have cursor  (required)
    nails = 7, -- How many nails to be hammered
    type = 'dark-wood' -- What color wood to display (light-wood, medium-wood, dark-wood)
}

---- Chore Setup ----
RegisterNetEvent('bcc-ranch:ShovelHay', function(chore)
    local choreCoords,choreAnim,incAmount,animTime,miniGame,miniGameCfg

    if chore == 'shovelhay' then
        choreCoords = Haycoords
        incAmount = Config.ChoreConfig.HayChore.ConditionIncrease
        animTime = Config.ChoreConfig.HayChore.AnimTime
        miniGame = 'skillcheck'
        miniGameCfg = Config.ChoreMinigameConfig
    elseif chore == 'wateranimals' then
        choreCoords = WaterAnimalCoords
        choreAnim = joaat('WORLD_HUMAN_BUCKET_POUR_LOW')
        incAmount = Config.ChoreConfig.WaterAnimals.ConditionIncrease
        animTime = Config.ChoreConfig.WaterAnimals.AnimTime
        miniGame = 'skillcheck'
        miniGameCfg = Config.ChoreMinigameConfig
    elseif chore == 'repairfeedtrough' then
        choreCoords = RepairTroughCoords
        choreAnim = joaat('PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL') --credit syn_construction for anim(just where I found it at lol)
        incAmount = Config.ChoreConfig.RepairFeedTrough.ConditionIncrease
        animTime = Config.ChoreConfig.RepairFeedTrough.AnimTime
        miniGame = 'hammertime'
        miniGameCfg = hammerTimeCfg
    elseif chore == 'scooppoop' then
        choreCoords = ScoopPoopCoords
        incAmount = Config.ChoreConfig.ShovelPoop.ConditionIncrease
        animTime = Config.ChoreConfig.ShovelPoop.AnimTime
        miniGame = 'skillcheck'
        miniGameCfg = Config.ChoreMinigameConfig
    end

    InMission = true
    VORPcore.NotifyRightTip(_U("GoToChoreLocation"), 4000)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    
    BccUtils.Misc.SetGps(choreCoords.x, choreCoords.y, choreCoords.z)
    while true do
        Wait(5)
        if PlayerDead then break end
        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, choreCoords.x, choreCoords.y, choreCoords.z, true)
        if dist < 15 then
            BccUtils.Misc.DrawText3D(choreCoords.x, choreCoords.y, choreCoords.z, _U("StartChore"))
        end
        if dist < 5 then
            if IsControlJustReleased(0, 0x760A9C6F) then
                ClearGpsMultiRoute()
                if Config.ChoreMinigames then
                    MiniGame.Start(miniGame, miniGameCfg, function(result)
                        if result.passed then
                            if chore == 'scooppoop' then
                                TriggerServerEvent('bcc-ranch:AddItem', Config.ChoreConfig.ShovelPoop.RecievedItem, Config.ChoreConfig.ShovelPoop.RecievedAmount)
                            end
                            if chore == 'shovelhay' or 'scooppoop' then
                                playAnim('amb_work@world_human_farmer_rake@male_a@idle_a', 'idle_a', animTime)
                                local rakeObj = CreateObject("p_rake02x", 0, 0, 0, true, true, false)
                                AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.19, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
                                Wait(animTime)
                                DeleteObject(rakeObj)
                            else
                                ChoreComplete(choreAnim, animTime, incAmount)
                            end
                        else
                            InMission = false
                            VORPcore.NotifyRightTip(_U("Failed"), 4000) return
                        end
                    end) break
                else
                    if chore == 'shovelhay' or 'scooppoop' then
                        playAnim('amb_work@world_human_farmer_rake@male_a@idle_a', 'idle_a', animTime)
                        local rakeObj = CreateObject("p_rake02x", 0, 0, 0, true, true, false)
                        AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.19, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
                        Wait(animTime)
                        DeleteObject(rakeObj)
                    else
                        BccUtils.Ped.ScenarioInPlace(PlayerPedId(), choreAnim, animTime)
                    end
                    if PlayerDead then
                        InMission = false
                        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) break
                    end
                    VORPcore.NotifyRightTip(_U("ChoreComplete"), 4000)
                    TriggerServerEvent('bcc-ranch:RanchConditionIncrease', incAmount, RanchId)
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

function ChoreComplete(choreAnim, animTime, incAmount) --what to do if chore is success
    BccUtils.Ped.ScenarioInPlace(PlayerPedId(), choreAnim, animTime)
    if PlayerDead then
        InMission = false
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000) return
    end
    VORPcore.NotifyRightTip(_U("ChoreComplete"), 4000)
    TriggerServerEvent('bcc-ranch:RanchConditionIncrease', incAmount, RanchId)
    InMission = false
end