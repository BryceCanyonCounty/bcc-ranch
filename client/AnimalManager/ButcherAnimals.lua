function ButcherAnimals(animalType)
    local model, tables, spawnCoords
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    local selectAnimalFuncts = {
        ['cows'] = function()
            if Cowsage < Config.RanchSetup.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
            end
            tables = Config.RanchSetup.RanchAnimalSetup.Cows
            model = 'a_c_cow'
            spawnCoords = Cowcoords
        end,
        ['chickens'] = function()
            if Chickensage < Config.RanchSetup.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
            end
            tables = Config.RanchSetup.RanchAnimalSetup.Chickens
            model = 'a_c_chicken_01'
            spawnCoords = Chickencoords
        end,
        ['goats'] = function()
            if Goatsage < Config.RanchSetup.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
            end
            tables = Config.RanchSetup.RanchAnimalSetup.Goats
            model = 'a_c_goat_01'
            spawnCoords = Goatcoords
        end,
        ['pigs'] = function()
            if Pigsage < Config.RanchSetup.AnimalGrownAge then
                VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
            end
            tables = Config.RanchSetup.RanchAnimalSetup.Pigs
            model = 'a_c_pig_01'
            spawnCoords = Pigcoords
        end
    }
    if selectAnimalFuncts[animalType] then
        selectAnimalFuncts[animalType]()
    end

    InMission = true

    local createdPed = BccUtils.Ped.CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
    SetBlockingOfNonTemporaryEvents(createdPed, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdPed, true)
    FreezeEntityPosition(createdPed, true)
    VORPcore.NotifyRightTip(_U("KillAnimal"), 4000)
    while true do
        Wait(5)
        if PlayerDead then break end
        if IsEntityDead(createdPed) then
            VORPcore.NotifyRightTip(_U("GoSkin"), 4000) break
        end
    end

    local  PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("Skin"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while true do
        Wait(5)
        local pl = GetEntityCoords(PlayerPedId())
        local cp = GetEntityCoords(createdPed)
        if PlayerDead then break end
        if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, cp.x, cp.y, cp.z, true) < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                BccUtils.Ped.ScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CROUCH_INSPECT', 5000)
                DeletePed(createdped)
                VORPcore.NotifyRightTip(_U("AnimalKilled"), 4000)
                TriggerServerEvent('bcc-ranch:ButcherAnimalHandler', animalType, RanchId, tables) break
            end
        end
    end

    if PlayerDead then
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
    end
    InMission = false
end