ConfigAnimals = {
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
    }
}