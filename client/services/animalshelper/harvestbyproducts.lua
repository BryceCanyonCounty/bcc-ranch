local createdPed = nil

------ Spawning Coop -------
RegisterNetEvent('bcc-ranch:HarvestEggs', function()
    BCCRanchMenu:Close()
    IsInMission = true
    local model = 'p_chickencoopcart01x'
    LoadModel(model)
    local coopCoords = json.decode(RanchData.chicken_coop_coords)
    if not coopCoords or not coopCoords.x or not coopCoords.y or not coopCoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for cows.")
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        ManageOwnedAnimalsMenu()
        IsInMission = false
        return
    end
    local chickenCoop = CreateObject(model, coopCoords.x, coopCoords.y, coopCoords.z, true, true, false)
    Citizen.InvokeNative(0x9587913B9E772D29, chickenCoop) -- PlaceEntityOnGroundProperly
    VORPcore.NotifyRightTip(_U("harvestEggs"), 4000)
    BccUtils.Misc.SetGps(coopCoords.x, coopCoords.y, coopCoords.z)
    local blip = BccUtils.Blips:SetBlip(_U("harvestEggs"), 'blip_teamsters', 0.2, coopCoords.x, coopCoords.y, coopCoords.z)
    coopCoords = GetEntityCoords(chickenCoop)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("harvestEggs"), BccUtils.Keys[ConfigRanch.ranchSetup.harvestEggsKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if #(GetEntityCoords(PlayerPedId()) - coopCoords) < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                if ConfigRanch.ranchSetup.choreSetup.choreMinigames then
                    MiniGame.Start('skillcheck', ConfigRanch.ranchSetup.choreSetup.choreMinigameSettings, function(result)
                        if result.passed then
                            BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.chickens.eggItem, amount = ConfigAnimals.animalSetup.chickens.eggItemAmount }, function(success)
                                if success then
                                    devPrint("Item added successfully.")
                                else
                                    devPrint("Failed to add the item.")
                                end
                            end)
                            VORPcore.NotifyRightTip(_U("eggsHarvested"), 4000)
                            IsInMission = false
                            BccUtils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            return
                        else
                            IsInMission = false
                            BccUtils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            VORPcore.NotifyRightTip(_U("failed"), 4000)
                            return
                        end
                    end)
                    break
                else
                    BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.chickens.eggItem, amount = ConfigAnimals.animalSetup.chickens.eggItemAmount }, function(success)
                        if success then
                            devPrint("Item added successfully.")
                        else
                            devPrint("Failed to add the item.")
                        end
                    end)
                    VORPcore.NotifyRightTip(_U("eggsHarvested"), 4000)
                    IsInMission = false
                    BccUtils.Blips:RemoveBlip(blip.rawblip)
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
    local cowCoords = json.decode(RanchData.cow_coords)
    if not cowCoords or not cowCoords.x or not cowCoords.y or not cowCoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for cows.")
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        ManageOwnedAnimalsMenu()
        IsInMission = false
        return
    end
    VORPcore.NotifyRightTip(_U("goMilk"), 4000)
    createdPed = BccUtils.Ped:Create(model, cowCoords.x, cowCoords.y, cowCoords.z - 1, 0.0, "world", false, nil, nil, true)
    BccUtils.Ped.SetStatic(createdPed)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("milkAnimal"), BccUtils.Keys[ConfigRanch.ranchSetup.milkAnimalKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local cowDead = false
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(createdPed:GetPed()) then
            cowDead = true
            break
        end
        if #(GetEntityCoords(createdPed:GetPed()) - GetEntityCoords(PlayerPedId())) <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end

    if IsEntityDead(PlayerPedId()) or cowDead then
        InMission = false
        createdPed:Remove()
        VORPcore.NotifyRightTip(_U("failed"), 4000)
        return
    end

    if not cowCoords or not cowCoords.x or not cowCoords.y or not cowCoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for animal type:", animalType)
        ManageOwnedAnimalsMenu()
        VORPcore.NotifyRightTip(_U("noCoordsSetForAnimalType") .. animalType, 4000)
        IsInMission = false
        return
    end

    if ConfigRanch.ranchSetup.choreSetup.choreMinigames then
        PlayAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', -1)
        VORPcore.NotifyRightTip(_U("milkingCow"), 4000)
        MiniGame.Start('cowmilker', ConfigRanch.ranchSetup.choreSetup.milkingMinigameConfig, function(result)
            if result.collected >= ConfigAnimals.animalSetup.cows.milkToCollect then
                VORPcore.NotifyRightTip(_U("animalMilked"), 4000)
                BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.cows.milkItem, amount = ConfigAnimals.animalSetup.cows.milkItemAmount }, function(success)
                    if success then
                        devPrint("Item added successfully.")
                    else
                        devPrint("Failed to add the item.")
                    end
                end)
                createdPed:Remove()
                IsInMission = false
            else
                IsInMission = false
                createdPed:Remove()
                VORPcore.NotifyRightTip(_U("failed"), 4000)
            end
            ClearPedTasks(PlayerPedId())
        end)
    else
        VORPcore.NotifyRightTip(_U("milkingCow"), 4000)
        PlayAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', 15000)
        Wait(16500)
        VORPcore.NotifyRightTip(_U("animalMilked"), 4000)
        BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.cows.milkItem, amount = ConfigAnimals.animalSetup.cows.milkItemAmount }, function(success)
            if success then
                devPrint("Item added successfully.")
            else
                devPrint("Failed to add the item.")
            end
        end)
        createdPed:Remove()
    end
end)

----------------- Shearing Sheeps --------------------
RegisterNetEvent('bcc-ranch:ShearSheeps', function()
    InMission = true
    BCCRanchMenu:Close()
    local model = 'a_c_sheep_01'
    LoadModel(model)
    local Sheepcoords = json.decode(RanchData.sheep_coords)
    if not Sheepcoords or not Sheepcoords.x or not Sheepcoords.y or not Sheepcoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for cows.")
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        ManageOwnedAnimalsMenu()
        IsInMission = false
        return
    end
    VORPcore.NotifyRightTip(_U("shearAnimal"), 4000)
    createdPed = BccUtils.Ped:Create(model, Sheepcoords.x, Sheepcoords.y, Sheepcoords.z - 1, 0.0, "world", false, nil, nil, true)
    FreezeEntityPosition(createdPed:GetPed(), true)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("shearAnimal"), BccUtils.Keys[ConfigRanch.ranchSetup.shearAnimalKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local sheepDead = false
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(createdPed:GetPed()) then
            sheepDead = true
            break
        end
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(createdPed:GetPed())) <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end

    if IsEntityDead(PlayerPedId()) or sheepDead then
        InMission = false
        createdPed:Remove()
        VORPcore.NotifyRightTip(_U("failed"), 4000)
        return
    end

    if ConfigRanch.ranchSetup.choreSetup.choreMinigames then
        PlayAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', -1)
        VORPcore.NotifyRightTip(_U("shearingAnimal"), 4000)
        Wait(5000)
        MiniGame.Start('skillcheck', ConfigRanch.ranchSetup.choreSetup.choreMinigameSettings, function(result)
            if result.passed then
                Wait(5000)
                BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.sheeps.sheepItem, amount = ConfigAnimals.animalSetup.sheeps.sheepItemAmount }, function(success)
                    if success then
                        devPrint("Item added successfully.")
                    else
                        devPrint("Failed to add the item.")
                    end
                end)
                VORPcore.NotifyRightTip(_U("animalSheared"), 4000)
                IsInMission = false
                createdPed:Remove()
                ClearPedTasks(PlayerPedId())
                return
            else
                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                IsInMission = false
                createdPed:Remove()
                VORPcore.NotifyRightTip(_U("failed"), 4000)
                return
            end
        end)
    else
        VORPcore.NotifyRightTip(_U("shearingAnimal"), 4000)
        PlayAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', 15000)
        Wait(16500)
        VORPcore.NotifyRightTip(_U("animalSheared"), 4000)
        BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.sheeps.sheepItem, amount = ConfigAnimals.animalSetup.sheeps.sheepItemAmount }, function(success)
            if success then
                devPrint("Item added successfully.")
            else
                devPrint("Failed to add the item.")
            end
        end)
        createdPed:Remove()
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
        if createdPed and type(createdPed.Remove) == "function" then
            createdPed:Remove()
        end
    end
end)