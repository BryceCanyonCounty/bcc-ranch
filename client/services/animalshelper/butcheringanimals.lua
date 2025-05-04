local createdPed = nil
local createdPedBlip = nil

function ButcherAnimals(animalType)
    local model, tables, spawnCoords
    BCCRanchMenu:Close()

    local selectAnimalFuncts = {
        ['cows'] = function()
            if tonumber(RanchData.cows_age) < ConfigAnimals.animalSetup.cows.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.cows
            model = 'a_c_cow'
            spawnCoords = json.decode(RanchData.cow_coords)
            return true
        end,
        ['pigs'] = function()
            if tonumber(RanchData.pigs_age) < ConfigAnimals.animalSetup.pigs.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.pigs
            model = 'a_c_pig_01'
            spawnCoords = json.decode(RanchData.pig_coords)
            return true
        end,
        ['sheeps'] = function()
            if tonumber(RanchData.sheeps_age) < ConfigAnimals.animalSetup.sheeps.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.sheeps
            model = 'a_c_sheep_01'
            spawnCoords = json.decode(RanchData.sheep_coords)
            return true
        end,
        ['goats'] = function()
            if tonumber(RanchData.goats_age) < ConfigAnimals.animalSetup.goats.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
                return false
            end
            tables = ConfigAnimals.animalSetup.goats
            model = 'a_c_goat_01'
            spawnCoords = json.decode(RanchData.goat_coords)
            return true
        end,
        ['chickens'] = function()
            if tonumber(RanchData.chickens_age) < ConfigAnimals.animalSetup.chickens.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000)
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

    -- Check spawn coords
    if not spawnCoords or not spawnCoords.x or not spawnCoords.y or not spawnCoords.z then
        VORPcore.NotifyRightTip(_U("noCoordsSet"), 4000)
        return
    end

    -- Clean previous ped/blip if any
    if createdPed then
        createdPed:Remove()
        createdPed = nil
    end
    if createdPedBlip then
        createdPedBlip:Remove()
        createdPedBlip = nil
    end

    -- Start Butchering Mission
    IsInMission = true
    createdPed = BccUtils.Ped:Create(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, "world", false, nil, nil, true)
    createdPed:SetBlockingOfNonTemporaryEvents(true)
    createdPed:Freeze()

    createdPedBlip = BccUtils.Blip:SetBlip(_U("choreLocation"), 960467426, 0.2, spawnCoords.x, spawnCoords.y, spawnCoords.z)

    VORPcore.NotifyRightTip(_U("killAnimal"), 4000)

    -- Wait until player kills the animal
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then
            break
        end
        if IsEntityDead(createdPed:GetPed()) then
            VORPcore.NotifyRightTip(_U("skinAnimal"), 4000)
            break
        end
    end

    -- Player needs to skin animal
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("skinAnimal"), BccUtils.Keys[ConfigRanch.ranchSetup.skinKey], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then
            break
        end
        if #(GetEntityCoords(PlayerPedId()) - createdPed:GetCoords()) < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                BccUtils.Ped.ScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CROUCH_INSPECT', 5000)

                createdPed:Remove()
                createdPed = nil

                if createdPedBlip then
                    createdPedBlip:Remove()
                    createdPedBlip = nil
                end

                VORPcore.NotifyRightTip(_U("animalKilled"), 4000)

                local params = {
                    animalType = animalType,
                    ranchId = RanchData.ranchid,
                    table = tables
                }

                BccUtils.RPC:Call("bcc-ranch:ButcherAnimalHandler", params, function(success)
                    if success then
                        devPrint("Animal butchered successfully and items added.")
                    else
                        devPrint("Failed to butcher the animal.")
                    end
                end)
                break
            end
        end
    end

    if IsEntityDead(PlayerPedId()) then
        VORPcore.NotifyRightTip(_U("failed"), 4000)
    end

    IsInMission = false
end

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
