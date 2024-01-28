local createdPed = nil

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
            TriggerServerEvent('bcc-ranch:CoopDBStorage', RanchId, coopCoords)
            break
        end
        VORPcore.NotifyRightTip(_U("PlaceCoop"), 0)
    end
    InMission = false
end)

------ Spawning Coop -------
RegisterNetEvent('bcc-ranch:ChickenCoopHarvest', function()
    InMission = true
    MenuData.CloseAll()
    local model = 'p_chickencoopcart01x'
    LoadModel(model)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')

    local chickenCoop = CreateObject(model, ChickenCoop_coords.x, ChickenCoop_coords.y, ChickenCoop_coords.z,
        true, true, false)
    Citizen.InvokeNative(0x9587913B9E772D29, chickenCoop) -- PlaceEntityOnGroundProperly
    VORPcore.NotifyRightTip(_U("HarvestEggs"), 4000)
    BccUtils.Misc.SetGps(ChickenCoop_coords.x, ChickenCoop_coords.y, ChickenCoop_coords.z)
    local blip = VORPutils.Blips:SetBlip(_U("HarvestEggs_blip"), 'blip_teamsters', 0.2, ChickenCoop_coords.x,
        ChickenCoop_coords.y, ChickenCoop_coords.z)
    local coopCoords = GetEntityCoords(chickenCoop)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("HarvestEggs_blip"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    while true do
        Wait(5)
        local distance = #(GetEntityCoords(PlayerPedId()) - coopCoords)
        if PlayerDead then break end
        if distance < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                if Config.ChoreMinigames then
                    MiniGame.Start('skillcheck', Config.ChoreMinigameConfig, function(result)
                        if result.passed then
                            TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem,
                                Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem_Amount)
                            VORPcore.NotifyRightTip(_U("HarvestedEggs"), 4000)
                            InMission = false
                            VORPutils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            return
                        else
                            InMission = false
                            VORPutils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            VORPcore.NotifyRightTip(_U("Failed"), 4000)
                            return
                        end
                    end)
                    break
                else
                    TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem,
                        Config.RanchSetup.RanchAnimalSetup.Chickens.EggItem_Amount)
                    VORPcore.NotifyRightTip(_U("HarvestedEggs"), 4000)
                    InMission = false
                    VORPutils.Blips:RemoveBlip(blip.rawblip)
                    DeleteObject(chickenCoop)
                    break
                end
            end
        end
    end
    if PlayerDead then
        InMission = false
        DeleteObject(chickenCoop)
        VORPcore.NotifyRightTip(_U("Failed"), 4000)
    end
end)

----------------- Milking Cows --------------------
RegisterNetEvent('bcc-ranch:MilkCows', function()
    MenuData.CloseAll()
    InMission = true
    local model = 'a_c_cow'
    LoadModel(model)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    VORPcore.NotifyRightTip(_U("goMilk"), 4000)

    createdPed = BccUtils.Ped.CreatePed(model, Cowcoords.x, Cowcoords.y, Cowcoords.z - 1, true, true, false)
    FreezeEntityPosition(createdPed, true)
    local pedCoords = GetEntityCoords(createdPed)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("milkCows"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local cowDead = false
    while true do
        Wait(5)
        if PlayerDead then break end
        if IsEntityDead(createdPed) then
            cowDead = true
            break
        end
        local distance = #(GetEntityCoords(PlayerPedId()) - pedCoords)
        if distance <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end

    if PlayerDead or cowDead then
        InMission = false
        DeletePed(createdPed)
        VORPcore.NotifyRightTip(_U("Failed"), 4000)
        return
    end

    if Config.ChoreMinigames then
        playAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', -1)
        VORPcore.NotifyRightTip(_U("milkingCow"), 4000)
        MiniGame.Start('cowmilker', Config.MilkingMinigameConfig, function(result)
            if result.collected >= Config.RanchSetup.RanchAnimalSetup.Cows.AmountToCollect then
                VORPcore.NotifyRightTip(_U("cowMilked"), 4000)
                TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Cows.MilkingItem,
                    Config.RanchSetup.RanchAnimalSetup.Cows.MilkingItemAmount)
                DeletePed(createdPed)
                InMission = false
            else
                InMission = false
                DeletePed(createdPed)
                VORPcore.NotifyRightTip(_U("Failed"), 4000)
            end
            ClearPedTasks(PlayerPedId())
        end)
    else
        VORPcore.NotifyRightTip(_U("milkingCow"), 4000)
        playAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', 15000)
        Wait(16500)
        VORPcore.NotifyRightTip(_U("cowMilked"), 4000)
        TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Cows.MilkingItem,
            Config.RanchSetup.RanchAnimalSetup.Cows.MilkingItemAmount)
        DeletePed(createdPed)
        InMission = false
    end
end)

----------------- Shearing Sheeps --------------------
RegisterNetEvent('bcc-ranch:ShearSheeps', function()
    InMission = true
    MenuData.CloseAll()
    local model = 'a_c_sheep_01'
    LoadModel(model)
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    VORPcore.NotifyRightTip(_U("goShear"), 4000)

    createdPed = BccUtils.Ped.CreatePed(model, Sheepcoords.x, Sheepcoords.y, Sheepcoords.z - 1, true, true, false)
    FreezeEntityPosition(createdPed, true)
    local pedCoords = GetEntityCoords(createdPed)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("shearSheeps"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local sheepDead = false
    while true do
        Wait(5)
        if PlayerDead then break end
        if IsEntityDead(createdPed) then
            sheepDead = true
            break
        end
        local distance = #(GetEntityCoords(PlayerPedId()) - pedCoords)
        if distance <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end

    if PlayerDead or sheepDead then
        InMission = false
        DeletePed(createdPed)
        VORPcore.NotifyRightTip(_U("Failed"), 4000)
        return
    end

    if Config.ChoreMinigames then
        playAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', -1)
        VORPcore.NotifyRightTip(_U("shearingSheep"), 4000)
        Citizen.Wait(5000)
        MiniGame.Start('skillcheck', Config.ChoreMinigameConfig, function(result)
            if result.passed then
                Citizen.Wait(5000)
                TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Sheeps.WoolItem,
                Config.RanchSetup.RanchAnimalSetup.Sheeps.WoolItem_Amount)
                VORPcore.NotifyRightTip(_U("HarvestedWool"), 4000)
                InMission = false
                DeletePed(createdPed)
                ClearPedTasks(PlayerPedId())
                return
            else
                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                InMission = false
                DeletePed(createdPed)
                VORPcore.NotifyRightTip(_U("Failed"), 4000)
                return
            end
        end)
    else
        VORPcore.NotifyRightTip(_U("shearingSheep"), 4000)
        playAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', 15000)
        Wait(16500)
        VORPcore.NotifyRightTip(_U("sheepSheared"), 4000)
        TriggerServerEvent('bcc-ranch:AddItem', Config.RanchSetup.RanchAnimalSetup.Sheeps.WoolItem,
            Config.RanchSetup.RanchAnimalSetup.Chickens.WoolItem_Amount)
        DeletePed(createdPed)
    end
end)

function LoadModel(model)
    local hash = joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeletePed(createdPed)
        createdPed = nil
    end
end)
