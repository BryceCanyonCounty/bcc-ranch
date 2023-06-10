----- Event to place the coop -----
RegisterNetEvent('bcc-ranch:PlaceChickenCoop', function()
    MenuData.CloseAll()
    InMission = true
    while true do
        Wait(5)
        if IsControlJustReleased(0, 0x760A9C6F) then
            local coopCoords = GetEntityCoords(PlayerPedId())
            ChickenCoop = 'true' --Setting these 2 vars here so you dont have too disconnect and rejoin just to buy a coop
            ChickenCoop_coords = coopCoords
            TriggerServerEvent('bcc-ranch:CoopDBStorage', RanchId, coopCoords) break
        end
        VORPcore.NotifyRightTip(_U("PlaceCoop"), 0)
    end
    InMission = false
end)

------ Spawning Coop -------
RegisterNetEvent('bcc-ranch:ChickenCoopHarvest', function()
    InMission = true
    MenuData.CloseAll()
    local chickenCoopModel = joaat('p_chickencoopcart01x')
    RequestModel(chickenCoopModel)
    while not HasModelLoaded(chickenCoopModel) do
        Wait(100)
    end

    local chickenCoop = CreateObject(chickenCoopModel, ChickenCoop_coords.x, ChickenCoop_coords.y, ChickenCoop_coords.z, true, true, false)
    Citizen.InvokeNative(0x9587913B9E772D29, chickenCoop)
    VORPcore.NotifyRightTip(_U("HarvestEggs"), 4000)
    BccUtils.Misc.SetGps(ChickenCoop_coords.x, ChickenCoop_coords.y, ChickenCoop_coords.z)
    local  blip = VORPutils.Blips:SetBlip(_U("HarvestEggs_blip"), 'blip_teamsters', 0.2, ChickenCoop_coords.x, ChickenCoop_coords.y, ChickenCoop_coords.z)
    

    local  PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("HarvestEggs_blip"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while true do
        Wait(5)
        local plc = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, ChickenCoop_coords.x, ChickenCoop_coords.y, ChickenCoop_coords.z, true) < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                if Config.ChoreMinigames then
                    MiniGame.Start('skillcheck', Config.ChoreMinigameConfig, function(result)
                        if result.passed then
                            TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem, Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem_Amount)
                            VORPcore.NotifyRightTip(_U("HarvestedEggs"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("Failed"), 4000) return
                        end
                    end)
                else
                    TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem, Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem_Amount)
                    VORPcore.NotifyRightTip(_U("HarvestedEggs"), 4000)
                end
                InMission = false
                VORPutils.Blips:RemoveBlip(blip.rawblip)
                DeleteObject(chickenCoop) break
            end
        end
    end
end)