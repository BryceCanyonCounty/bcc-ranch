--------- Animals Ageing Setup ---------------
Cowsage, Chickensage, Goatsage, Pigsage = 0, 0, 0, 0
RegisterNetEvent('bcc-ranch:CowsAgeing', function(currage)
    while BoughtCows do
        Cowsage = currage
        if currage >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseTime)
        currage = currage + Config.RanchSetup.RanchAnimalSetup.Cows.AgeIncreaseTime
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'cows', RanchId)
    end
end)

RegisterNetEvent('bcc-ranch:ChickensAgeing', function(currage)
    while BoughtChickens do
        Chickensage = currage
        if currage >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseTime)
        currage = currage + Config.RanchSetup.RanchAnimalSetup.Chickens.AgeIncreaseTime
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'chickens', RanchId)
    end
end)

RegisterNetEvent('bcc-ranch:GoatsAgeing', function(currage)
    while BoughtGoats do
        Goatsage = currage
        if currage >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseTime)
        currage = currage + Config.RanchSetup.RanchAnimalSetup.Goats.AgeIncreaseTime
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'goats', RanchId)
    end
end)

RegisterNetEvent('bcc-ranch:PigsAgeing', function(currage)
    while BoughtPigs do
        Pigsage = currage
        if currage >= Config.RanchSetup.AnimalGrownAge then break end
        Wait(Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseTime)
        currage = currage + Config.RanchSetup.RanchAnimalSetup.Pigs.AgeIncreaseTime
        TriggerServerEvent('bcc-ranch:AgeIncrease', 'pigs', RanchId)
    end
end)