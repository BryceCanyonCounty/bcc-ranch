--------- Animals Ageing Setup ---------------
Cowsage, Chickensage, Goatsage, Pigsage = 0, 0, 0, 0
RegisterNetEvent('bcc-ranch:CowsAgeing', function(currAge)
    while BoughtCows do
        Cowsage = currAge
        if currAge >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseTime)
        currAge = currAge + Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseAmount
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'cows', RanchId)
    end
end)

RegisterNetEvent('bcc-ranch:ChickensAgeing', function(currAge)
    while BoughtChickens do
        Chickensage = currAge
        if currAge >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseTime)
        currAge = currAge + Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseAmount
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'chickens', RanchId)
    end
end)

RegisterNetEvent('bcc-ranch:GoatsAgeing', function(currAge)
    while BoughtGoats do
        Goatsage = currAge
        if currAge >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseTime)
        currAge = currAge + Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseAmount
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'goats', RanchId)
    end
end)

RegisterNetEvent('bcc-ranch:PigsAgeing', function(currAge)
    while BoughtPigs do
        Pigsage = currAge
        if currAge >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseTime)
        currAge = currAge + Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseAmount
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'pigs', RanchId)
    end
end)