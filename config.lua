Config = {}

Config.Debug = true --false on live server

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
        AnimTime = 5000,
        ConditionIncrease = 5,
    },
}

Config.RanchSetup = {
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
            Cost = 500, --cost to buy animal
            MaxCondition = 200, --the maximum condition the animal can reach
            BasePay = 300, --This is the base pay(what will be paid when selling the animal if animal condition is not max)
            MaxConditionPay = 1000, --amount to pay when selling the animal if the animals condition is maxed
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
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
            Cost = 200,
            MaxCondition = 100,
            BasePay = 200,
            MaxConditionPay = 500,
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
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
            Cost = 100,
            MaxCondition = 50,
            BasePay = 100,
            MaxConditionPay = 200,
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
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
            Cost = 50,
            MaxCondition = 20,
            BasePay = 50,
            MaxConditionPay = 100,
            AmountSpawned = 4, --Amount of animals that will spawn when herding or selling them
            LowPay = 150, --This is the amount that will be payed if any animals die along the way
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
        Coords = {x = -239.39, y = 710.95, z = 113.29},
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

------------- Translate Here ------------------------
Config.Language = {
    NameRanch = 'Name Ranch',
    NameRanch_desc = 'Name The Ranch',
    Confirm = 'Confirm',
    Confirm_desc = 'This will create a ranch at your coordinates, with the entered data. Are you sure?',
    RanchRadiusLimit = 'Set the ranches radius limit',
    RanchRadiusLimit_desc = 'Will limit how far away the owner can set things like chore locations',
    CreateRanchTitle = 'Create a Ranch!',
    InvalidInput = 'Invalid Input',
    StaticId = 'Set Owner',
    StaticId_desc = 'Assign The Ranch Owner',
    OpenRanchMenu = 'Manage Your Ranch!',
    OpenRanchMenu_desc = 'Your Ranch',
    Caretaking = 'Caretaking',
    Caretaking_desc = 'Work To keep up the ranch!',
    RanchMenuName = 'Your Ranch!',
    ShovelHay = 'Gather Hay',
    ShovelHay_desc = 'Gather Hay for the Animals',
    SetCoords = 'Set Location',
    SetCoords_desc = 'Go to the location you want this to be at, then select this option!',
    Coordsset = 'Location Set!',
    TooFarFromRanch = 'You Are Too Far Away From Your Ranch!',
    ConditionMax = 'Your Ranch is already in perfect condition!',
    NoLocationSet = 'You Have not set a location yet',
    GoToChoreLocation = 'Go To The Chore Location!',
    StartChore = 'Press "G" to start chore!',
    inmission = 'You Are In a mission, and must finish it',
    ChoreComplete = 'Chore Completed! Ranch Condition increased!',
    PlayerDead = 'Mission failed',
    CheckRanchCond = 'Check Ranch Condition',
    CheckRanchCond_desc = 'Check Your Ranches Condition, You Want This High So Your Animals Are Higher Quality! The Max is 100!',
    WaterAnimalChore = 'Water Animals',
    WaterAnimalChore_desc = 'Watering your animals will increase your ranch condition and make your animals healthier',
    BuyAnimals = 'Buy Animals',
    BuyAnimals_desc = 'Buy Animals for your ranch',
    BuyCows = 'Buy Cows for',
    BuyCows_desc = 'Buy cows for your ranch',
    Notenoughmoney = 'You do not have enough money',
    AlreadyOwnAnimal = 'You Already Own Some Of These animals',
    BuyPigs = 'Buy Pigs for',
    BuyPigs_desc = 'Buy Pigs for your ranch',
    BuyGoats = 'Buy goats for',
    BuyGoats_desc = 'Buy Goats for your ranch',
    BuyChickens = 'Buy Chickens for',
    BuyChickens_desc = 'Buy Chickens for your ranch',
    AnimalBought = 'Purchase Complete!',
    RanchMade = 'Ranch Created Succesfully',
    ManageAnimals = 'Manage Owned Animals',
    ManageAnimals_desc = 'Manage the animals your ranch owns',
    ManageCows = 'Manage Owned Cows',
    ManageGoats = 'Manage Owned Goats',
    ManageChickens = 'Manage Owned Chickens',
    ManagePigs = 'Manage Owned Pigs',
    ManageCows_desc = 'Manage your owned cows!',
    ManageGoats_desc = 'Manage your owned goats',
    ManageChickens_desc = 'Manage your owned chickens',
    ManagePigs_desc = 'Mange your owned pigs',
    SellCows = 'Sell Animals',
    SellCows_desc = 'Sell Your Animals? The higher thier condition the more profit you make!',
    AnimalNotOwned = 'You do not own any of these animals',
    CheckAnimalCond = 'Check Animals Condition',
    CheckAnimalCond_desc = 'Check your animals condition, the higher this is the more profit you can make when you sell them!',
    LeadAnimalsToSale = 'Lead Your Animals to the sale area safely!',
    AnimalsSold = 'You Sold The Animals!',
    SetHerdLocation = 'Set Herd Location',
    SetHerdLocation_desc = 'Set the location you will herd your animals to!',
    TooCloseToRanch = 'Too close to ranch!',
    HerdAnimal = 'Herd Animal',
    HerdAnimal_desc = 'Herd Animal? Doing so will increase the animals condition, which will improve its sell price!',
    HerdToLocation = 'Herd Your Animals to the location!',
    ReturnAnimals = 'Herd Them Back to the ranch!',
    HerdingSuccess = 'You herded the animals successfully! Thier condition has increased!',
    ButcherAnimal = 'Butcher Animal',
    ButcherAnimal_desc = 'Butcher Animal? Doing this while kill your animals, but will give you supplies.',
    KillAnimal = 'Kill The Animal!',
    GoSkin = 'Animal Killed go butcher it to get rewards!',
    Skin = 'Butcher Animal',
    AnimalKilled = 'You Butchered The Animal!',
    Inventory = 'Ranch Inventory',
    Inventory_desc = 'Your ranchs inventory, anything you store here will be safe!',
    SteamName = "Steam Name",
    ServId = 'Server ID',
    PGroup = 'Player Group',
    OwnerSet = 'Owner Set',
    ManageRanches = 'Manage Ranches',
    ManageRanches_desc = 'Manage Player ranches',
    Ranchid = 'Ranch ID ',
    Failed = 'Failed!',
    RepairTroughChore = "Repair Feed Trough",
    RepairFeedTrough_desc = 'Repair Feeding Trouhgs? This will increase your ranches condition.',
    ScoopPoopChore = 'Shovel Poop',
    ScoopPoopChore_desc = 'Shovel Poop? This will increase your ranches condition.',
    
    ------- Admin ranch Managment -----
    NoRanches = 'There Are no existing ranches in database',
    DeleteRanch = 'Delete Ranch',
    DeleteRanch_desc = 'Delete this ranch? This action can not be undone!',
    RanchDeleted = 'Ranch Deleted!',

    ChangeRanchRadius = "Change Ranch Radius",
    ChangeRanchRadius_desc = 'Change the ranches radius?',
    RadiusChanged = 'Radius Changed!',

    ChangeRanchName = 'Change Ranch Name',
    ChangeRanchName_desc = 'Change the ranches name?',
    NameChanged = 'Name Changed!',

    ChangeRanchCond = 'Change Ranch Condition',
    ChangeRanchCond_desc = 'Change the ranches condition?',
    CondChanged = 'Condition Changed!',
    InsertRanchCond = 'Insert Condition'
}