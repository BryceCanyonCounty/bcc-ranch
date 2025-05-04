local agingActive = false
RanchData = {}

CreateThread(function()
    while true do
        -- Check if aging is active and if we're not in a mission
        if not agingActive or IsInMission then
            Wait(2000)
        end

        -- Loop through all animal types (cows, pigs, sheep, goats, chickens)
        for animalType, config in pairs(ConfigAnimals.animalSetup) do
            if RanchData[animalType] == "true" then
                devPrint(animalType .. " aging thread: Waiting for ageTimer")
                Wait(config.ageTimer)  -- Wait for the specified timer for the current animal

                -- Trigger the RPC to increase the animal age
                BccUtils.RPC:Call("bcc-ranch:IncreaseAnimalAge", {
                    ranchId = RanchData.ranchid,
                    animalType = animalType,
                    incAmount = config.ageIncrease
                }, function(success)
                    --[[if success then
                        devPrint("Successfully increased age for " .. animalType .. " in ranch: " .. RanchData.ranchid)
                    else
                        devPrint("Failed to increase age for " .. animalType .. " in ranch: " .. RanchData.ranchid)
                    end]]
                end)
            end
        end

        -- Wait before checking again
        Wait(1000)  -- Check again every second for any changes
    end
end)