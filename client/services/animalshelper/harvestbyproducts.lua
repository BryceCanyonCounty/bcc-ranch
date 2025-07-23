harvestPed = nil

------ Spawning Coop -------
RegisterNetEvent('bcc-ranch:HarvestEggs', function()
    BCCRanchMenu:Close()
    IsInMission = true
    local model = 'p_chickencoopcart01x'
    LoadModel(model)
    local coopCoords = json.decode(RanchData.chicken_coop_coords)
    if not coopCoords or not coopCoords.x or not coopCoords.y or not coopCoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for cows.")
        Notify(_U("noCoordsSet"), "warning", 4000)
        ManageOwnedAnimalsMenu()
        IsInMission = false
        return
    end
    local chickenCoop = CreateObject(model, coopCoords.x, coopCoords.y, coopCoords.z, true, true, false)
    Citizen.InvokeNative(0x9587913B9E772D29, chickenCoop) -- PlaceEntityOnGroundProperly
    Notify(_U("harvestEggs"), "success", 4000)
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
                            Notify(_U("eggsHarvested"), "success", 4000)
                            IsInMission = false
                            BccUtils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            return
                        else
                            IsInMission = false
                            BccUtils.Blips:RemoveBlip(blip.rawblip)
                            DeleteObject(chickenCoop)
                            Notify(_U("failed"), "error", 4000)
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
                    Notify(_U("eggsHarvested"), "success", 4000)
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
        Notify(_U("failed"), "error", 4000)
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
        Notify(_U("noCoordsSet"), "warning", 4000)
        ManageOwnedAnimalsMenu()
        IsInMission = false
        return
    end
    Notify(_U("goMilk"), "success", 4000)
    harvestPed = BccUtils.Ped:Create(model, cowCoords.x, cowCoords.y, cowCoords.z - 1, 0.0, "world", false, nil, nil, true)
    BccUtils.Ped.SetStatic(harvestPed)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("milkAnimal"), BccUtils.Keys[ConfigRanch.ranchSetup.milkAnimalKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local cowDead = false
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(harvestPed:GetPed()) then
            cowDead = true
            break
        end
        if #(GetEntityCoords(harvestPed:GetPed()) - GetEntityCoords(PlayerPedId())) <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end
    if IsEntityDead(PlayerPedId()) or cowDead then
        IsInMission = false
        harvestPed:Remove()
        Notify(_U("failed"), "error", 4000)
        return
    end
    if not cowCoords or not cowCoords.x or not cowCoords.y or not cowCoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for animal type:", animalType)
        ManageOwnedAnimalsMenu()
        Notify(_U("noCoordsSetForAnimalType") .. animalType, "error", 4000)
        IsInMission = false
        return
    end
    if ConfigRanch.ranchSetup.choreSetup.choreMinigames then
        PlayAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', -1)
        Notify(_U("milkingCow"), "success", 4000)
        MiniGame.Start('cowmilker', ConfigRanch.ranchSetup.choreSetup.milkingMinigameConfig, function(result)
            if result.collected >= ConfigAnimals.animalSetup.cows.milkToCollect then
                Notify(_U("animalMilked"), "success", 4000)
                BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.cows.milkItem, amount = ConfigAnimals.animalSetup.cows.milkItemAmount }, function(success)
                    if success then
                        devPrint("Item added successfully.")
                    else
                        devPrint("Failed to add the item.")
                    end
                end)
                harvestPed:Remove()
                IsInMission = false
            else
                IsInMission = false
                harvestPed:Remove()
                Notify(_U("failed"), "error", 4000)
            end
            ClearPedTasks(PlayerPedId())
        end)
    else
        Notify(_U("milkingCow"), "success", 4000)
        PlayAnim('script_rc@rch1@ig@ig_1_milkingthecow', 'milkingloop_john', 15000)
        Wait(16500)
        Notify(_U("animalMilked"), "success", 4000)
        BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.cows.milkItem, amount = ConfigAnimals.animalSetup.cows.milkItemAmount }, function(success)
            if success then
                devPrint("Item added successfully.")
            else
                devPrint("Failed to add the item.")
            end
        end)
        harvestPed:Remove()
    end
end)

----------------- Shearing Sheeps --------------------
RegisterNetEvent('bcc-ranch:ShearSheeps', function()
    IsInMission = true
    BCCRanchMenu:Close()
    local model = 'a_c_sheep_01'
    LoadModel(model)
    local Sheepcoords = json.decode(RanchData.sheep_coords)
    if not Sheepcoords or not Sheepcoords.x or not Sheepcoords.y or not Sheepcoords.z then
        devPrint("Error: Missing or invalid spawn coordinates for cows.")
        Notify(_U("noCoordsSet"), "error", 4000)
        ManageOwnedAnimalsMenu()
        IsInMission = false
        return
    end
    Notify(_U("shearAnimal"), "success", 4000)
    harvestPed = BccUtils.Ped:Create(model, Sheepcoords.x, Sheepcoords.y, Sheepcoords.z - 1, 0.0, "world", false, nil, nil, true)
    FreezeEntityPosition(harvestPed:GetPed(), true)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("shearAnimal"), BccUtils.Keys[ConfigRanch.ranchSetup.shearAnimalKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local sheepDead = false
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(harvestPed:GetPed()) then
            sheepDead = true
            break
        end
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(harvestPed:GetPed())) <= 1 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then break end
        end
    end
    if IsEntityDead(PlayerPedId()) or sheepDead then
        IsInMission = false
        harvestPed:Remove()
        Notify(_U("failed"), "error", 4000)
        return
    end
    if ConfigRanch.ranchSetup.choreSetup.choreMinigames then
        PlayAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', -1)
        Notify(_U("shearingAnimal"), "success", 4000)
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
                Notify(_U("animalSheared"), "success", 4000)
                IsInMission = false
                harvestPed:Remove()
                ClearPedTasks(PlayerPedId())
                return
            else
                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                IsInMission = false
                harvestPed:Remove()
                Notify(_U("failed"), "error", 4000)
                return
            end
        end)
    else
        Notify(_U("shearingAnimal"), "success", 4000)
        PlayAnim('mech_inventory@crafting@fallbacks@in_hand@male_a', 'craft_trans_hold', 15000)
        Wait(16500)
        Notify(_U("animalSheared"), "success", 4000)
        BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigAnimals.animalSetup.sheeps.sheepItem, amount = ConfigAnimals.animalSetup.sheeps.sheepItemAmount }, function(success)
            if success then
                devPrint("Item added successfully.")
            else
                devPrint("Failed to add the item.")
            end
        end)
        harvestPed:Remove()
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
        if harvestPed and type(harvestPed.Remove) == "function" then
            harvestPed:Remove()
        end
    end
end)
