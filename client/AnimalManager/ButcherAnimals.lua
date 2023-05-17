function ButcherAnimals(animaltype)
    local model, tables, spawncoords
    TriggerEvent('bcc-ranch:ChoreDeadCheck')
    if animaltype == 'cows' then
        if Cowsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Cows
        model = 'a_c_cow'
        spawncoords = Cowcoords
    elseif animaltype == 'chickens' then
        if Chickensage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Chickens
        model = 'a_c_chicken_01'
        spawncoords = Chickencoords
    elseif animaltype == 'goats' then
        if Goatsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Goats
        model = 'a_c_goat_01'
        spawncoords = Goatcoords
    elseif animaltype == 'pigs' then
        if Pigsage < Config.RanchSetup.AnimalGrownAge then
            VORPcore.NotifyRightTip(_U("TooYoung"), 4000) return
        end
        tables = Config.RanchSetup.RanchAnimalSetup.Pigs
        model = 'a_c_pig_01'
        spawncoords = Pigcoords
    end
    InMission = true

    local createdped = BccUtils.Ped.CreatePed(model, spawncoords.x, spawncoords.y, spawncoords.z, true, true, false)
    SetBlockingOfNonTemporaryEvents(createdped, true)
    Citizen.InvokeNative(0x9587913B9E772D29, createdped, true)
    FreezeEntityPosition(createdped, true)
    VORPcore.NotifyRightTip(_U("KillAnimal"), 4000)
    while true do
        Wait(5)
        if PlayerDead then break end
        if IsEntityDead(createdped) then
            VORPcore.NotifyRightTip(_U("GoSkin"), 4000) break
        end
    end

    local  PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("Skin"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while true do
        Wait(5)
        local pl = GetEntityCoords(PlayerPedId())
        local cp = GetEntityCoords(createdped)
        if PlayerDead then break end
        if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, cp.x, cp.y, cp.z, true) < 3 then
            PromptGroup:ShowGroup('')
            if firstprompt:HasCompleted() then
                BccUtils.Ped.ScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CROUCH_INSPECT', 5000)
                DeletePed(createdped)
                TriggerServerEvent('bcc-ranch:ButcherAnimalHandler', animaltype, RanchId, tables) break
            end
        end
    end

    if PlayerDead then
        VORPcore.NotifyRightTip(_U("PlayerDead"), 4000)
    end
    InMission = false
end