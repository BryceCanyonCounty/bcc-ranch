Config = {
    defaultlang = "en_lang", -- set your language
    devMode = false,
    adminGroup = "admin", --Name of the group to set admin (in order to be an admin you must have the group admin on the characters table)
    commands = {
        createRanchCommand = "createRanch",
        manageRanches = "manageRanches",
        devModeCommand = "startRanch",
        manageMyRanchCommand = false, -- Set to false to disable, allows to manage ranch through command not prompt
        manageMyRanchCommandName = "manageMyRanch",
    },
    ranchSetup = {
        ranchConditionDecreaseInterval = 60, -- 1 minute (Time that must pass before ranch condition decreases)
        ranchConditionDecreaseAmount = 10, -- Amount to decrease ranch condition by
        taxDay = 23, -- Day of the month that taxes are collected
        taxResetDay = 1, -- Day of the month that taxes are reset
        ranchBlip = "blip_mp_roundup", --Main ranch blip
        ranchInvLimit = 200, -- Inventory limit for ranch
        manageRanchKey = 0x4CC0E2FE, -- Key to press to manage ranch (B by default)
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
            shovelPoopRewardItem = "poop",
            shovelPoopRewardAmount = 1
        }
    },
    animalSetup = {
        minHerdCoords = 100, -- Minimum distance from ranch to set herd coords
        cows = {
            cost = 10, -- Cost to buy animal
            feedAnimalCondIncrease = 10, -- Condition increase per feed
            animalHealth = 100, -- Health of animal
            condIncreasePerHerd = 10, -- Condition increase per herd
            condIncreasePerHerdMaxRanchCond = 20, -- Condition increase per herd if ranch condition is at max
            spawnAmount = 5, -- Amount to spawn when herding or feeding
            maxCondition = 200, -- Max condition of animal
            ageTimer = 60000, -- 1 minute (Time that must pass before an animal ages up)
            ageIncrease = 1, -- How much to increase the age by
            AnimalGrownAge = 3, -- Age that the animal is considered grown
            maxAge = 5, -- Max age of animal
            lowPay = 75, --This is the amount that will be payed if any animals die along the way
            basePay = 100,--This is the base pay(what will be paid when selling the animal if animal condition is not max)
            maxConditionPay = 150,--This is the amount that will be payed if the animal condition is at max
            roamingRadius = 100, -- Radius that the animals will roam around the ranch
            milkItem = "milk", -- Item to give when milking cows
            milkItemAmount = 1, -- Amount of item to give when milking cows
            milkingCooldown = 60, -- 1 minute (Time that must pass before you can milk cows again)
            milkToCollect = 0.10, -- Amount of milk to collect when milking cows in the minigame
            butcherItems = { --items you will get when you butcher this animal
                {
                    name = 'acid', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'alcohol', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            }
        },
        pigs = {
            cost = 10,
            feedAnimalCondIncrease = 10, -- Condition increase per feed
            animalHealth = 100, -- Health of animal
            condIncreasePerHerd = 10, -- Condition increase per herd
            condIncreasePerHerdMaxRanchCond = 20, -- Condition increase per herd if ranch condition is at max
            spawnAmount = 5, -- Amount to spawn when herding or feeding
            maxCondition = 200, -- Max condition of animal
            ageTimer = 60000, -- 1 minute (Time that must pass before an animal ages up)
            ageIncrease = 1, -- How much to increase the age by
            AnimalGrownAge = 3, -- Age that the animal is considered grown
            maxAge = 5, -- Max age of animal
            lowPay = 75, --This is the amount that will be payed if any animals die along the way
            basePay = 100,--This is the base pay(what will be paid when selling the animal if animal condition is not max)
            maxConditionPay = 150,--This is the amount that will be payed if the animal condition is at max
            roamingRadius = 100, -- Radius that the animals will roam around the ranch
            butcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Beef_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Beef_Organs', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            }
        },
        sheeps = {
            cost = 10,
            feedAnimalCondIncrease = 10, -- Condition increase per feed
            animalHealth = 100, -- Health of animal
            condIncreasePerHerd = 10, -- Condition increase per herd
            condIncreasePerHerdMaxRanchCond = 20, -- Condition increase per herd if ranch condition is at max
            spawnAmount = 5, -- Amount to spawn when herding or feeding
            ageTimer = 60000, -- 1 minute (Time that must pass before an animal ages up)
            ageIncrease = 1, -- How much to increase the age by
            AnimalGrownAge = 3, -- Age that the animal is considered grown
            maxAge = 5, -- Max age of animal
            maxCondition = 200, -- Max condition of animal
            lowPay = 75, --This is the amount that will be payed if any animals die along the way
            basePay = 100,--This is the base pay(what will be paid when selling the animal if animal condition is not max)
            maxConditionPay = 150,--This is the amount that will be payed if the animal condition is at max
            roamingRadius = 100, -- Radius that the animals will roam around the ranch
            sheepItem = "wool", -- Item to give when shearing sheep
            sheepItemAmount = 1, -- Amount of item to give when shearing sheep
            shearingCooldown = 60, -- 1 minute (Time that must pass before you can shear sheep again)
            butcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Beef_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Beef_Organs', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            }
        },
        goats = {
            cost = 10,
            feedAnimalCondIncrease = 10, -- Condition increase per feed
            animalHealth = 100, -- Health of animal
            condIncreasePerHerd = 10, -- Condition increase per herd
            condIncreasePerHerdMaxRanchCond = 20, -- Condition increase per herd if ranch condition is at max
            spawnAmount = 5, -- Amount to spawn when herding or feeding
            maxCondition = 200, -- Max condition of animal
            ageTimer = 60000, -- 1 minute (Time that must pass before an animal ages up)
            ageIncrease = 1, -- How much to increase the age by
            AnimalGrownAge = 3, -- Age that the animal is considered grown
            maxAge = 5, -- Max age of animal
            lowPay = 75, --This is the amount that will be payed if any animals die along the way
            basePay = 100,--This is the base pay(what will be paid when selling the animal if animal condition is not max)
            maxConditionPay = 150,--This is the amount that will be payed if the animal condition is at max
            roamingRadius = 100, -- Radius that the animals will roam around the ranch
            butcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Beef_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Beef_Organs', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            }
        },
        chickens = {
            cost = 10,
            feedAnimalCondIncrease = 10, -- Condition increase per feed
            animalHealth = 100, -- Health of animal
            condIncreasePerHerd = 10, -- Condition increase per herd
            condIncreasePerHerdMaxRanchCond = 20, -- Condition increase per herd if ranch condition is at max
            spawnAmount = 5, -- Amount to spawn when herding or feeding
            maxCondition = 200, -- Max condition of animal
            ageTimer = 60000, -- 1 minute (Time that must pass before an animal ages up)
            ageIncrease = 1, -- How much to increase the age by
            AnimalGrownAge = 3, -- Age that the animal is considered grown
            maxAge = 5, -- Max age of animal
            lowPay = 75, --This is the amount that will be payed if any animals die along the way
            basePay = 100,--This is the base pay(what will be paid when selling the animal if animal condition is not max)
            maxConditionPay = 150,--This is the amount that will be payed if the animal condition is at max
            roamingRadius = 100, -- Radius that the animals will roam around the ranch
            coopCost = 200, -- Cost to buy a chicken coop
            eggItem = "egg", -- Item to give when harvesting eggs
            eggItemAmount = 1, -- Amount of item to give when harvesting eggs
            harvestingCooldown = 60, -- 1 minute (Time that must pass before you can harvest eggs again)
            butcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Beef_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Beef_Organs', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            }
        }
    },
    saleLocations = {
        --These are the locations players will be able to sell thier cattle/animals at
        {
            LocationName = 'Valentine Cattle Auction', --this will be the name of the blip
            Coords = {x=-217.18, y=634.94, z=113.20}, --the coords the player will have to go to
        }, --to add more just copy this table paste and change what you want
        {
            LocationName = 'Rhodes Cattle Auction',
            Coords = {x=1332.0, y=-1271.8, z=76.8},
        },
        {
            LocationName = 'Blackwater Cattle Auction',
            Coords = {x=-853.13, y=-1337.95, z=43.48},
        },
        {
            LocationName = 'Strawberry Cattle Auction',
            Coords = {x=-1837.10, y=-438.56, z=159.53},
        },
        {
            LocationName = 'Armadillo Cattle Auction',
            Coords = {x=-3660.93, y=-2564.88, z=-13.75},
        },
        {
            LocationName = 'St-Denis Cattle Auction',
            Coords = {x=2393.30, y=-1416.46, z=45.76},
        },
        {
            LocationName = 'Annesburg Cattle Auction',
            Coords = {x=2936.83, y=1312.21, z=44.53},
        },
        {
            LocationName = 'Emerald Ranch Cattle Auction',
            Coords = {x = 1420.13, y = 295.07, z = 88.96},
        },
        {
            LocationName = 'Tumbleweed Cattle Auction',
            Coords = {x=-5410.35, y=-2934.25, z=0.92},
        }
    }
}