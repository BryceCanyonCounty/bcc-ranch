Config = {}

Config.Debug = true --false on live server

Config.TaxDay = 23 --This is the number day of each month that taxes will be collected on
Config.TaxResetDay = 24 --This MUST be the day after TaxDay set above!!! (do not change either of these dates if the current date is one of the 2 for ex if its the 22 or 23rd day do not change these dates it will break the code)

-- Set Language (Current Languages: "en_lang" English, "fr_lang" French, "de_lang" German, "pt_lang" Portuguese-Brazilian)
Config.defaultlang = "en_lang"

--Webhok Setup
Config.Webhooks = {
    RanchCreation = { --ranch creation webhook
        WebhookLink = '', --insert your webhook link here(leave blank for no webhooks)
        --- Dont Change Just Translate ----
        TitleText = 'Admin Character Static id ',
        Text = 'Has Created A Ranch and given it too Character Static ID '
    },
    AnimalBought = {
        WebhookLink = '', --insert your webhook link here(leave blank for no webhooks)
        ----- Dont Change just translate ----
        TitleText = 'Ranch Id ',
        DescText = 'Bought ',
        Cows = 'Cows',
        Pigs = 'Pigs',
        Goats = 'Goats',
        Chickens = 'Chickens',
    },
    AnimalSold = {
        WebhookLink = '', --insert your webhook link (leave blank for no webhook)
        ----- Dont Change Just Translate -----
        TitleText = 'Ranch ID ',
        Sold = 'Sold ',
        Cows = 'Cows for: ',
        Pigs = 'Pigs for: ',
        Goats = 'Goats for: ',
        Chickens = 'Chickens for: ',
    },
    Taxes = { --ranch creation webhook
    WebhookLink = '', --insert your webhook link here(leave blank for no webhooks)
    --- Dont Change Just Translate ----
    TitleText = 'Admin Character Static id ',
    Text = 'Has Created A Ranch and given it too Character Static ID '
    },
}

---- Thise is the chore config
Config.ChoreMinigames = true --if true a minigame will have to be completed to finish the chore!
--Minigame setup ONLY CHANGE DO NOT REMOVE ANYTHING!
Config.ChoreMinigameConfig = {
    focus = true, -- Should minigame take nui focus (required)
    cursor = false, -- Should minigame have cursor
    maxattempts = 2, -- How many fail attempts are allowed before game over
    type = 'bar', -- What should the bar look like. (bar, trailing)
    userandomkey = false, -- Should the minigame generate a random key to press?
    keytopress = 'E', -- userandomkey must be false for this to work. Static key to press
    keycode = 69, -- The JS keycode for the keytopress
    speed = 25, -- How fast the orbiter grows
    strict = true -- if true, letting the timer run out counts as a failed attempt
}

Config.MilkingMinigameConfig = {
    focus = true, -- Should minigame take nui focus (required)
    cursor = true, -- Should minigame have cursor  (required)
    timer = 30, -- The amount of seconds the game will run for
    minMilkPerSqueez = 100.0,
    maxMilkPerSqueez = 200.0
}

--Main Chore Setup
Config.ChoreConfig = {
    HayChore = {
        AnimTime = 15000, --time the animation will play for
        ConditionIncrease = 5, --amount the condition will increase by
    },
    WaterAnimals = {
        AnimTime = 10000,
        ConditionIncrease = 5,
    },
    RepairFeedTrough = {
        AnimTime = 15000,
        ConditionIncrease = 10,
    },
    ShovelPoop = {
        RecievedItem = 'Supply_Manure', --You will recieve this item upon completion of this chore(database name of the item)
        RecievedAmount = 5, --this is the amount of the item you will recieve (set 0 if you do not want this feature)
        AnimTime = 5000,
        ConditionIncrease = 5,
    },
}

--Main Ranch Setup
Config.RanchSetup = {
    manageRanchCommand = {
        enabled = true, --if enabled players will be able to use command
        commandName = 'manageMyRanch', --name of the command (this command will allow players to open thier ranch menu using the command aslong as they are within thier ranch's set radius)
    },
    animalFollowSettings = { --set the offset that the ranch animals will follow the player around while herding or selling test around to find whatt you like
        offsetX = 5,
        offsetY = 5,
        offsetZ = 0 --Recommended to leave at 0 this is the height variable
    },
    AnimalGrownAge = 100, -- the age the animals will have to be reach before they are grown(animals below this age will be considered babies, and you can not sell or butcher them the age increase while the player is online)
    AnimalsRoamRanch = true, --if you want your animals to roam your ranch set this true
    WolfAttacks = true, --if true there is a chance 2 wolves will spawn while herding or selling animals and attack you!(50 50 chance)
    AnimalsWalkOnly = false, --If true animals that you herd or sell will only be able to walk, if false they can run. (Cows will not run no matter what)
    RanchCondDecrease = 1800000, --This is how often the ranches condition will decrease over time
    InvLimit = 200, --Maximum inventory space the ranch will have
    InvName = 'Ranch Inventory', --Name of the inventory
    RanchCondDecreaseAmount = 10, --how much it will decrease
    MaxRanchCondition = 100, --This is the maximum ranch condition possible. This can only be set upto 999
    BlipHash = 'blip_mp_roundup', --ranch blip hash
    HerdingMinDistance = 300, --this is the minimum distance a player will have to be from there ranch to set thier herd location
    ChoreCooldown = 900, --seconds in between being able to do chores
    FeedCooldown = 900 -- seconds in between being able to feed animals
    RanchAnimalSetup = { --ranch animal setup
        Cows = {
            Health = 200, --How much health the cows will have while being herded or sold 
            AgeIncreaseTime = 60000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            MilkingCooldown = 900, --time in seconds you have to  wait before being able to milk them again
            MilkingItem = 'Ingredient_Milk', --item recieved after milking
            MilkingItemAmount = 5, --the amount of the item you get
            AmountToCollect = 0.70, --The minimum amount of milk you need to collect from the minigame to successfully milk the cow!
            RoamingRadius = 4.0, --this is the radius the cows will be able to roam around the ranch in(Make sure this is a decimal number ie 0.2, 5.0, 3.9 not a whole number ie 1, 2, 3 will break them wandering if its a whole number)
            MaxCondition = 200, --the maximum condition the animal can reach
            --
            Cost = 500, --cost to buy animal
            LowPay = 600, --This is the amount that will be payed if any animals die along the way
            BasePay = 800, --This is the base pay(what will be paid when selling the animal if animal condition is not max)
            MaxConditionPay = 1000, --amount to pay when selling the animal if the animals condition is maxed
            --
            AmountSpawned = 9, --Amount of animals that will spawn when herding or selling them
            FeedAnimalCondIncrease = 10, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 15, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Beef_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Beef_Organs', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
        Pigs = {
            Health = 200, --How much health the pigs will have while being herded or sold
            AgeIncreaseTime = 60000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            RoamingRadius = 2.0,
            MaxCondition = 200,
            --
            Cost = 200,
            LowPay = 225, --This is the amount that will be payed if any animals die along the way
            BasePay = 300,
            MaxConditionPay = 400,
            --
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            FeedAnimalCondIncrease = 10, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 15, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Pig_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Pig_Organs', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
        Goats = {
            Health = 200, --How much health the goats will have while being herded or sold
            AgeIncreaseTime = 60000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            RoamingRadius = 3.0,
            MaxCondition = 200,
            --
            Cost = 100,
            LowPay = 125, --This is the amount that will be payed if any animals die along the way
            BasePay = 175,--This is the base pay(what will be paid when selling the animal if animal condition is not max)
            MaxConditionPay = 250,
            --
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            FeedAnimalCondIncrease = 10, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 15, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Goat_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Goat_Organs', --item db name
                    count = 2, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
        Chickens = {
            Health = 200, --How much health the chickens will have while being herded or sold
            AgeIncreaseTime = 30000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            CoopCost = 400, --cost to buy a chicken coop
            CoopCollectionCooldownTime = 900, --Time in ms that must pass before you can harvest eggs from the coop again
            EggItem = 'Ingredient_Egg', --The item you will get from harvesting eggs from the coop
            EggItem_Amount = 6, --the amount of the item you will get
            --
            Cost = 50,
            LowPay = 75, --This is the amount that will be payed if any animals die along the way
            BasePay = 100,--This is the base pay(what will be paid when selling the animal if animal condition is not max)
            MaxConditionPay = 150,
            --
            RoamingRadius = 0.5,
            MaxCondition = 200,
            AmountSpawned = 9, --Amount of animals that will spawn when herding or selling them
            FeedAnimalCondIncrease = 10, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 15, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = 'Ingredient_Chicken_Meat', --item db name
                    count = 4, --amount you will get
                }, --you can add more by copy pasting this table
                {
                    name = 'Ingredient_Chicken_Organs', --item db name
                    count = 1, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
    }
}

Config.SaleLocationBlipHash = 'blip_ambient_herd' --hash of the blip to show
Config.SaleLocations = {
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

---------- Admin Configuration (Anyone listed here will be able to create and delete ranches!) -----------
Config.AdminSteamIds = {
    {
        steamid = 'steam:11000013707db22', --insert players steam id
    } --to add more just copy this table paste and change id
}
Config.CreateRanchCommand = 'createranch' --name of the command used to create ranches!
Config.ManageRanchsCommand = 'manageranches' --name of the command used to manage ranches!
