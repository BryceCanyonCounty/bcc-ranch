Config = {}

Config.Debug = true --false on live server

-- Set Language (Current Languages: "en_lang" English, "fr_lang" French, "de_lang" German)
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
        Cows = 'Cows',
        Pigs = 'Pigs',
        Goats = 'Goats',
        Chickens = 'Chickens',
    }
}

---- Thise is the chore config
Config.ChoreMinigames = true --if true a minigame will have to be completed to finish the chore!
--Minigame setup ONLY CHANGE DO NOT REMOVE ANYTHING!
Config.ChoreMinigameConfig = {
    focus = true, -- Should minigame take nui focus (required)
    cursor = false, -- Should minigame have cursor
    maxattempts = 3, -- How many fail attempts are allowed before game over
    type = 'bar', -- What should the bar look like. (bar, trailing)
    userandomkey = true, -- Should the minigame generate a random key to press?
    keytopress = 'B', -- userandomkey must be false for this to work. Static key to press
    keycode = 66, -- The JS keycode for the keytopress
    speed = 20, -- How fast the orbiter grows
    strict = false -- if true, letting the timer run out counts as a failed attempt
}
--Main Chore Setup
Config.ChoreConfig = {
    HayChore = {
        AnimTime = 15000, --time the animation will play for
        ConditionIncrease = 10, --amount the condition will increase by
    },
    WaterAnimals = {
        AnimTime = 10000,
        ConditionIncrease = 5,
    },
    RepairFeedTrough = {
        AnimTime = 15000,
        ConditionIncrease = 20,
    },
    ShovelPoop = {
        RecievedItem = 'poop', --You will recieve this item upon completion of this chore(database name of the item)
        RecievedAmount = 2, --this is the amount of the item you will recieve (set 0 if you do not want this feature)
        AnimTime = 5000,
        ConditionIncrease = 5,
    },
}

--Main Ranch Setup
Config.RanchSetup = {
    AnimalGrownAge = 100, -- the age the animals will have to be reach before they are grown(animals below this age will be considered babies, and you can not sell or butcher them the age increase while the player is online)
    AnimalsRoamRanch = true, --if you want your animals to roam your ranch set this true
    WolfAttacks = true, --if true there is a chance 2 wolves will spawn while herding or selling animals and attack you!(50 50 chance)
    AnimalsWalkOnly = false, --If true animals that you herd or sell will only be able to walk, if false they can run. (Cows will not run no matter what)
    RanchCondDecrease = 1800000, --This is how often the ranches condition will decrease over time
    InvLimit = 200, --Maximum inventory space the ranch will have
    InvName = 'Ranch Inventory', --Name of the inventory
    RanchCondDecreaseAmount = 10, --how much it will decrease
    MaxRanchCondition = 100, --This is the maximum ranch condition possible. This can only be set upto 999
    BlipHash = 'blip_mp_predator_hunt_mask', --ranch blip hash
    HerdingMinDistance = 70, --this is the minimum distance a player will have to be from there ranch to set thier herd location
    RanchAnimalSetup = { --ranch animal setup
        Cows = {
            Health = 200, --How much health the cows will have while being herded or sold
            AgeIncreaseTime = 30000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            Cost = 500, --cost to buy animal
            RoamingRadius = 6.0, --this is the radius the cows will be able to roam around the ranch in(Make sure this is a decimal number ie 0.2, 5.0, 3.9 not a whole number ie 1, 2, 3 will break them wandering if its a whole number)
            MaxCondition = 200, --the maximum condition the animal can reach
            BasePay = 300, --This is the base pay(what will be paid when selling the animal if animal condition is not max)
            MaxConditionPay = 1000, --amount to pay when selling the animal if the animals condition is maxed
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
            FeedAnimalCondIncrease = 50, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 10, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = 'water', --item db name
                    count = 1, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
        Pigs = {
            Health = 200, --How much health the pigs will have while being herded or sold
            AgeIncreaseTime = 30000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            Cost = 200,
            RoamingRadius = 6.0,
            MaxCondition = 100,
            BasePay = 200,
            MaxConditionPay = 500,
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
            FeedAnimalCondIncrease = 50, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 10, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = '', --item db name
                    count = 1, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
        Goats = {
            Health = 200, --How much health the goats will have while being herded or sold
            AgeIncreaseTime = 30000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            Cost = 100,
            RoamingRadius = 6.0,
            MaxCondition = 50,
            BasePay = 100,
            MaxConditionPay = 200,
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
            FeedAnimalCondIncrease = 50, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 10, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = '', --item db name
                    count = 1, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
        Chickens = {
            Health = 200, --How much health the chickens will have while being herded or sold
            AgeIncreaseTime = 30000, --The time that has to pass before the animals age increases
            AgeIncreaseAmount = 5, --the amount the age will increase
            Cost = 50,
            RoamingRadius = 6.0,
            MaxCondition = 20,
            BasePay = 50,
            MaxConditionPay = 100,
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
            FeedAnimalCondIncrease = 50, --how much the animal condition will go up after feeding them!
            CondIncreasePerHerd = 10, --this is the amount the animals condition will increase when successfully herded!
            CondIncreasePerHerdNotMaxRanchCond = 5, --this is the amount the animals condition will go up per herd if the ranchs condition is not max
            ButcherItems = { --items you will get when you butcher this animal
                {
                    name = '', --item db name
                    count = 1, --amount you will get
                }, --you can add more by copy pasting this table
            },
        },
    }
}

Config.SaleLocationBlipHash = 'blip_ambient_vip' --hash of the blip to show
Config.SaleLocations = {
    --These are the locations players will be able to sell thier cattle/animals at
    {
        LocationName = 'Sale Area 1', --this will be the name of the blip
        Coords = {x = -281.72, y = 697.67, z = 113.49}, --the coords the player will have to go to
    }, --to add more just copy this table paste and change what you want
    {
        LocationName = 'Sale Area 2',
        Coords = {x = -767.63, y = -1389.87, z = 43.27},
    },
}

---------- Admin Configuration (Anyone listed here will be able to create and delete ranches!) -----------
Config.AdminSteamIds = {
    {
        steamid = 'steam:11000013707db22', --insert players steam id
    }, --to add more just copy this table paste and change id
    {
        steamid = 'id2'
    }
}
Config.CreateRanchCommand = 'createranch' --name of the command used to create ranches!
Config.ManageRanchsCommand = 'manageranches' --name of the command used to manage ranches!