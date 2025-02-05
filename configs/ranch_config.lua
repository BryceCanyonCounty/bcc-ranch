ConfigRanch = {
    ranchSetup = {
        ranchConditionDecreaseInterval = 300000, -- 5 minute (Time that must pass before ranch condition decreases. this has to be in ms)
        ranchConditionDecreaseAmount = 5, -- Amount to decrease ranch condition by
        taxDay = 23, -- Day of the month that taxes are collected
        taxResetDay = 1, -- Day of the month that taxes are reset
        ranchBlip = "blip_mp_roundup", --Main ranch blip
        ranchInvLimit = 200, -- Inventory limit for ranch
        manageRanchKey = "B", -- Key to press to manage ranch (B by default)
        ChoreKey = "G",
        skinKey = "G",
        dropHayKey = "G",
        pickupHayKey = "G",
        harvestEggsKey = "G",
        milkAnimalKey = "G",
        shearAnimalKey = "G",
        maxRanchCondition = 100, -- Max ranch condition
        herdingCooldown = 60, -- 1 minute (Time that must pass before you can herd again)
        feedingCooldown = 60, -- 1 minute (Time that must pass before you can feed again)
        animalFollowSettings = {
            offsetX = 1.0, -- Offset X for animals to follow player
            offsetY = 1.0, -- Offset Y for animals to follow player
            offsetZ = 1.0 -- Offset Z for animals to follow player
        },
        animalsWalkOnly = false, -- Should animals only walk
        choreSetup = {
            choreMinigameSettings = {
                focus = true, -- Should minigame take nui focus (required)
                cursor = false, -- Should minigame have cursor
                maxattempts = 2, -- How many fail attempts are allowed before game over
                type = 'bar', -- What should the bar look like. (bar, trailing)
                userandomkey = false, -- Should the minigame generate a random key to press?
                keytopress = 'E', -- userandomkey must be false for this to work. Static key to press
                keycode = 69, -- The JS keycode for the keytopress
                speed = 25, -- How fast the orbiter grows
                strict = true -- if true, letting the timer run out counts as a failed attempt
            },
            milkingMinigameConfig = {
                focus = true, -- Should minigame take nui focus (required)
                cursor = true, -- Should minigame have cursor  (required)
                timer = 30, -- The amount of seconds the game will run for
                minMilkPerSqueez = 100.0,
                maxMilkPerSqueez = 200.0
            },
            choreCooldown = 120, -- 1 minute (Time that must pass before you can complete another chore after doing one)
            choreMinigames = true,
            shovelHayCondInc = 10,
            shovelHayAnimTime = 5000,
            waterAnimalsCondInc = 10,
            waterAnimalsAnimTime = 5000,
            repairFeedTroughCondInc = 10,
            repairFeedTroughAnimTime = 5000,
            shovelPoopCondInc = 10,
            shovelPoopAnimTime = 5000,
            shovelPoopRewardItem = "fertilizer",
            shovelPoopRewardAmount = 5
        }
    }
}