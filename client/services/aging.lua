local agingActive = false
---@param firstIteration boolean
RegisterNetEvent('bcc-ranch:AgingTriggered', function(firstIteration, resetAging)
    if not firstIteration then
        if not agingActive then
            agingActive = true
        else
            agingActive = false
        end
    else --done as on first iteration it will always stop aging and restart it so we make a dif if for it
        if not agingActive then
            agingActive = true
        end
    end
    if resetAging then --done so we can allow the RanchData time to update before we start aging again (Used to sync when we buy new animals)
        agingActive = false
        Wait(1000)
        agingActive = true
    end
end)

-- Cow Thread
CreateThread(function()
    while true do
        if not agingActive or RanchData.cows ~= "true" or IsInMission then
            Wait(2000)
        else
            Wait(Config.animalSetup.cows.ageTimer)
            TriggerServerEvent('bcc-ranch:IncreaseAnimalAge', RanchData.ranchid, 'cows', Config.animalSetup.cows.ageIncrease)
        end
    end
end)

-- Pig Thread
CreateThread(function()
    while true do
        if not agingActive or RanchData.pigs ~= 'true' or IsInMission then
            Wait(2000)
        else
            Wait(Config.animalSetup.pigs.ageTimer)
            TriggerServerEvent('bcc-ranch:IncreaseAnimalAge', RanchData.ranchid, 'pigs', Config.animalSetup.pigs.ageIncrease)
        end
    end
end)

-- Sheep Thread
CreateThread(function()
    while true do
        if not agingActive or RanchData.sheeps ~= "true" or IsInMission then
            Wait(2000)
        else
            Wait(Config.animalSetup.sheeps.ageTimer)
            TriggerServerEvent('bcc-ranch:IncreaseAnimalAge', RanchData.ranchid, 'sheeps', Config.animalSetup.sheeps.ageIncrease)
        end
    end
end)

-- Goat Thread
CreateThread(function()
    while true do
        if not agingActive or RanchData.goats ~= "true" or IsInMission then
            Wait(2000)
        else
            Wait(Config.animalSetup.goats.ageTimer)
            TriggerServerEvent('bcc-ranch:IncreaseAnimalAge', RanchData.ranchid, 'goats', Config.animalSetup.goats.ageIncrease)
        end
    end
end)

-- Chicken Thread
CreateThread(function()
    while true do
        if not agingActive or RanchData.chickens ~= "true" or IsInMission then
            Wait(2000)
        else
            Wait(Config.animalSetup.chickens.ageTimer)
            TriggerServerEvent('bcc-ranch:IncreaseAnimalAge', RanchData.ranchid, 'chickens', Config.animalSetup.chickens.ageIncrease)
        end
    end
end)