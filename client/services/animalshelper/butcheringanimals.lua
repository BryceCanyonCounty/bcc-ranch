local createdPed = nil
function ButcherAnimals(animalType)
    local model, tables, spawnCoords
    BCCRanchMenu:Close()
    local selectAnimalFuncts = {
        ['cows'] = function()
            if tonumber(RanchData.cows_age) < Config.animalSetup.cows.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000) return
            end
            tables = Config.animalSetup.cows
            model = 'a_c_cow'
            spawnCoords = json.decode(RanchData.cow_coords)
        end,
        ['pigs'] = function()
            if tonumber(RanchData.pigs_age) < Config.animalSetup.pigs.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000) return
            end
            tables = Config.animalSetup.pigs
            model = 'a_c_pig_01'
            spawnCoords = json.decode(RanchData.pig_coords)
        end,
        ['sheeps'] = function()
            if tonumber(RanchData.sheeps_age) < Config.animalSetup.sheeps.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000) return
            end
            tables = Config.animalSetup.sheeps
            model = 'a_c_sheep_01'
            spawnCoords = json.decode(RanchData.sheep_coords)
        end,
        ['goats'] = function()
            if tonumber(RanchData.goats_age) < Config.animalSetup.goats.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000) return
            end
            tables = Config.animalSetup.goats
            model = 'a_c_goat_01'
            spawnCoords = json.decode(RanchData.goat_coords)
        end,
        ['chickens'] = function()
            if tonumber(RanchData.chickens_age) < Config.animalSetup.chickens.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("tooYoung"), 4000) return
            end
            tables = Config.animalSetup.chickens
            model = 'a_c_chicken_01'
            spawnCoords = json.decode(RanchData.chicken_coords)
        end
    }
    if selectAnimalFuncts[animalType] then
        selectAnimalFuncts[animalType]()
    end

    IsInMission = true

    createdPed = BccUtils.Ped.CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
    SetBlockingOfNonTemporaryEvents(createdPed, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
    FreezeEntityPosition(createdPed, true)
    VORPcore.NotifyRightTip(_U("killAnimal"), 4000)
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if IsEntityDead(createdPed) then
            VORPcore.NotifyRightTip(_U("skinAnimal"), 4000) break
        end
    end

    local  PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("skinAnimal"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then break end
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(createdPed)) < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                BccUtils.Ped.ScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CROUCH_INSPECT', 5000)
                DeletePed(createdPed)
                VORPcore.NotifyRightTip(_U("animalKilled"), 4000)
                TriggerServerEvent('bcc-ranch:ButcherAnimalHandler', animalType, RanchData.ranchid, tables) break
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
        DeletePed(createdPed)
        createdPed = nil
    end
end)