local createdPed = nil
local createdPedBlip = nil

function ButcherAnimals(animalType)
    local model, tables, spawnCoords
    BCCRanchMenu:Close()

    local selectAnimalFuncts = {
        cows = function()
            if tonumber(RanchData.cows_age) < ConfigAnimals.animalSetup.cows.AnimalGrownAge then
                Notify(_U("tooYoung"), "warning", 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.cows
            model = 'a_c_cow'
            spawnCoords = json.decode(RanchData.cow_coords)
            return true
        end,
        pigs = function()
            if tonumber(RanchData.pigs_age) < ConfigAnimals.animalSetup.pigs.AnimalGrownAge then
                Notify(_U("tooYoung"), "warning", 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.pigs
            model = 'a_c_pig_01'
            spawnCoords = json.decode(RanchData.pig_coords)
            return true
        end,
        sheeps = function()
            if tonumber(RanchData.sheeps_age) < ConfigAnimals.animalSetup.sheeps.AnimalGrownAge then
                Notify(_U("tooYoung"), "warning", 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.sheeps
            model = 'a_c_sheep_01'
            spawnCoords = json.decode(RanchData.sheep_coords)
            return true
        end,
        goats = function()
            if tonumber(RanchData.goats_age) < ConfigAnimals.animalSetup.goats.AnimalGrownAge then
                Notify(_U("tooYoung"), "warning", 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.goats
            model = 'a_c_goat_01'
            spawnCoords = json.decode(RanchData.goat_coords)
            return true
        end,
        chickens = function()
            if tonumber(RanchData.chickens_age) < ConfigAnimals.animalSetup.chickens.AnimalGrownAge then
                Notify(_U("tooYoung"), "warning", 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.chickens
            model = 'a_c_chicken_01'
            spawnCoords = json.decode(RanchData.chicken_coords)
            return true
        end
    }

    if not selectAnimalFuncts[animalType] or not selectAnimalFuncts[animalType]() then
        return
    end

    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        Notify(_U("noCoordsSet"), "error", 4000)
        return
    end

    -- Clean previous ped/blip
    if createdPed then
        createdPed:Remove()
        createdPed = nil
    end
    if createdPedBlip then
        createdPedBlip:Remove()
        createdPedBlip = nil
    end

    -- Spawn animal
    IsInMission = true
    createdPed = BccUtils.Ped:Create(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, "world", false, nil, nil,
        true)
    createdPed:SetBlockingOfNonTemporaryEvents(true)
    createdPed:Freeze()

    createdPedBlip = BccUtils.Blip:SetBlip(_U("choreLocation"), 960467426, 0.2, spawnCoords.x, spawnCoords.y,
        spawnCoords.z)

    Notify(_U("killAnimal"), "info", 4000)

    -- Wait until player kills animal
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(createdPed:GetPed()) then
            Notify(_U("skinAnimal"), "info", 4000)
            break
        end
    end

    -- Prompt for skinning
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstPrompt = PromptGroup:RegisterPrompt(_U("skinAnimal"), BccUtils.Keys[ConfigRanch.ranchSetup.skinKey], 1, 1,
        true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if #(GetEntityCoords(PlayerPedId()) - createdPed:GetCoords()) < 3 then
            PromptGroup:ShowGroup('')
            if firstPrompt:HasCompleted() then
                BccUtils.Ped.ScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CROUCH_INSPECT', 5000)

                createdPed:Remove()
                createdPed = nil

                if createdPedBlip then
                    createdPedBlip:Remove()
                    createdPedBlip = nil
                end

                Notify(_U("animalSkinned"), "success", 4000)

                local params = {
                    animalType = animalType,
                    ranchId = RanchData.ranchid,
                    table = tables
                }

                BccUtils.RPC:Call("bcc-ranch:ButcherAnimalHandler", params, function(success)
                    devPrint(success and "Animal butchered successfully and items added." or
                    "Failed to butcher the animal.")
                end)

                break
            end
        end
    end

    if IsEntityDead(PlayerPedId()) then
        Notify(_U("failed"), "error", 4000)
    end

    IsInMission = false
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if createdPed then
            createdPed:Remove()
            createdPed = nil
        end
        if createdPedBlip then
            createdPedBlip:Remove()
            createdPedBlip = nil
        end
    end
end)
