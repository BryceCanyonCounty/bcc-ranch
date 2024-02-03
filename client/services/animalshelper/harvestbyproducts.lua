local createdPed = nil

------ Spawning Coop -------
RegisterNetEvent('bcc-ranch:HarvestEggs', function()
    BCCRanchMenu:Close()
    IsInMission = true
    local model = 'p_chickencoopcart01x'
    LoadModel(model)
    local coopCoords = json.decode(RanchData.chicken_coop_coords)

    local chickenCoop = CreateObject(model, coopCoords.x, coopCoords.y, coopCoords.z, true, true, false)
    Citizen.InvokeNative(0x9587913B9E772D29, chickenCoop) -- PlaceEntityOnGroundProperly
    VORPcore.NotifyRightTip(_U("harvestEggs"), 4000)
    BccUtils.Misc.SetGps(coopCoords.x, coopCoords.y, coopCoords.z)
    local blip = VORPutils.Blips:SetBlip(_U("harvestEggs"), 'blip_teamsters', 0.2, coopCoords.x, coopCoords.y, coopCoords.z)
    coopCoords = GetEntityCoords(chickenCoop)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("harvestEggs"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if #(GetEntityCoords(PlayerPedId()) - coopCoords) < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                if Config.ranchSetup.choreSetup.choreMinigames then
                    MiniGame.Start('skillcheck', Config.ranchSetup.choreSetup.choreMinigameSettings, function(result)
                        if result.passed then
                            TriggerServerEvent('bcc-ranch:AddItem', Config.animalSetup.chickens.eggItem, Config.animalSetup.chickens.eggItemAmount)
                            VORPcore.NotifyRightTip(_U("eggsHarvested"), 4000)
                            IsInMission = false
                            VORPutils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            return
                        else
                            IsInMission = false
                            VORPutils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            VORPcore.NotifyRightTip(_U("failed"), 4000)
                            return
                        end
                    end)
                    break
                else
                    TriggerServerEvent('bcc-ranch:AddItem', Config.animalSetup.chickens.eggItem, Config.animalSetup.chickens.eggItemAmount)
                    VORPcore.NotifyRightTip(_U("eggsHarvested"), 4000)
                    IsInMission = false
                    VORPutils.Blips:RemoveBlip(blip.rawblip)
                    DeleteObject(chickenCoop)
                    break
                end
            end
        end
    end
    if IsEntityDead(PlayerPedId()) then
        IsInMission = false
        DeleteObject(chickenCoop)
        VORPcore.NotifyRightTip(_U("failed"), 4000)
    end
end)

----------------- Milking Cows --------------------
RegisterNetEvent('bcc-ranch:MilkCows', function()
    BCCRanchMenu:Close()
    IsInMission = true
    local model = 'a_c_cow'
    LoadModel(model)
    VORPcore.NotifyRightTip(_U("goMilk"), 4000)

    local cowCoords = json.decode(RanchData.cow_coords)
    createdPed = BccUtils.Ped.CreatePed(model, cowCoords.x, cowCoords.y, cowCoords.z - 1, true, true, false)
    BccUtils.Ped.SetStatic(createdPed)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("milkAnimal"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local cowDead = false
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(createdPed) then
            cowDead = true
            break
        end
        if #(GetEntityCoords(createdPed) - GetEntityCoords(PlayerPedId())) <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end

    if IsEntityDead(PlayerPedId()) or cowDead then
        InMission = false
        DeletePed(createdPed)
        VORPcore.NotifyRightTip(_U("failed"), 4000)
        return
    end

    if Config.ranchSetup.choreSetup.choreMinigames then
        PlayAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', -1)
        VORPcore.NotifyRightTip(_U("milkingCow"), 4000)
        MiniGame.Start('cowmilker', Config.ranchSetup.choreSetup.milkingMinigameConfig, function(result)
            if result.collected >= Config.animalSetup.cows.milkToCollect then
                VORPcore.NotifyRightTip(_U("animalMilked"), 4000)
                TriggerServerEvent('bcc-ranch:AddItem', Config.animalSetup.cows.milkItem, Config.animalSetup.cows.milkItemAmount)
                DeletePed(createdPed)
                IsInMission = false
            else
                IsInMission = false
                DeletePed(createdPed)
                VORPcore.NotifyRightTip(_U("failed"), 4000)
            end
            ClearPedTasks(PlayerPedId())
        end)
    else
        VORPcore.NotifyRightTip(_U("milkingCow"), 4000)
        playAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', 15000)
        Wait(16500)
        VORPcore.NotifyRightTip(_U("animalMilked"), 4000)
        TriggerServerEvent('bcc-ranch:AddItem', Config.animalSetup.cows.milkItem, Config.animalSetup.cows.milkItemAmount)
        DeletePed(createdPed)
    end
end)

----------------- Shearing Sheeps --------------------
RegisterNetEvent('bcc-ranch:ShearSheeps', function()
    InMission = true
    BCCRanchMenu:Close()
    local model = 'a_c_sheep_01'
    LoadModel(model)
    VORPcore.NotifyRightTip(_U("shearAnimal"), 4000)

    local Sheepcoords = json.decode(RanchData.sheep_coords)
    createdPed = BccUtils.Ped.CreatePed(model, Sheepcoords.x, Sheepcoords.y, Sheepcoords.z - 1, true, true, false)
    FreezeEntityPosition(createdPed, true)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("shearAnimal"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local sheepDead = false
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(createdPed) then
            sheepDead = true
            break
        end
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(createdPed)) <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end

    if IsEntityDead(PlayerPedId()) or sheepDead then
        InMission = false
        DeletePed(createdPed)
        VORPcore.NotifyRightTip(_U("failed"), 4000)
        return
    end

    if Config.ranchSetup.choreSetup.choreMinigames then
        PlayAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', -1)
        VORPcore.NotifyRightTip(_U("shearingAnimal"), 4000)
        Wait(5000)
        MiniGame.Start('skillcheck', Config.ranchSetup.choreSetup.choreMinigameSettings, function(result)
            if result.passed then
                Wait(5000)
                TriggerServerEvent('bcc-ranch:AddItem', Config.animalSetup.sheeps.sheepItem, Config.animalSetup.sheeps.sheepItemAmount)
                VORPcore.NotifyRightTip(_U("animalSheared"), 4000)
                IsInMission = false
                DeletePed(createdPed)
                ClearPedTasks(PlayerPedId())
                return
            else
                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                IsInMission = false
                DeletePed(createdPed)
                VORPcore.NotifyRightTip(_U("failed"), 4000)
                return
            end
        end)
    else
        VORPcore.NotifyRightTip(_U("shearingAnimal"), 4000)
        playAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', 15000)
        Wait(16500)
        VORPcore.NotifyRightTip(_U("animalSheared"), 4000)
        TriggerServerEvent('bcc-ranch:AddItem', Config.animalSetup.sheeps.sheepItem, Config.animalSetup.sheeps.sheepItemAmount)
        DeletePed(createdPed)
    end
end)

function LoadModel(model)
    local hash = joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(100)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeletePed(createdPed)
        createdPed = nil
    end
end)