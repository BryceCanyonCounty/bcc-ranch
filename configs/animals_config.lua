ConfigAnimals = {
    animalSetup = {
        minHerdCoords = 100, -- Minimum distance from ranch to set herd coords

        cows = {
            model = "a_c_cow",
            cost = 10,
            feedAnimalCondIncrease = 10,
            animalHealth = 100,
            condIncreasePerHerd = 10,
            condIncreasePerHerdMaxRanchCond = 20,
            spawnAmount = 5,
            maxCondition = 200,
            ageTimer = 60000,
            ageIncrease = 1,
            AnimalGrownAge = 5,
            maxAge = 10,
            lowPay = 75,
            basePay = 100,
            maxConditionPay = 10,
            roamingRadius = 100,
            milkItem = "milk",
            milkItemAmount = 5,
            milkingCooldown = 120,
            milkToCollect = 0.50,
            butcherItems = {
                { name = 'beef', count = 4 },
            }
        },

        pigs = {
            model = "a_c_pig_01",
            cost = 10,
            feedAnimalCondIncrease = 10,
            animalHealth = 100,
            condIncreasePerHerd = 10,
            spawnAmount = 5,
            maxCondition = 200,
            ageTimer = 60000,
            ageIncrease = 1,
            AnimalGrownAge = 3,
            maxAge = 10,
            lowPay = 75,
            basePay = 100,
            maxConditionPay = 150,
            roamingRadius = 100,
            butcherItems = {
                { name = 'pork', count = 4 },
                { name = 'porkfat', count = 2 },
            }
        },

        sheeps = {
            model = "a_c_sheep_01",
            cost = 10,
            feedAnimalCondIncrease = 10,
            animalHealth = 100,
            condIncreasePerHerd = 10,
            spawnAmount = 5,
            maxCondition = 200,
            ageTimer = 60000,
            ageIncrease = 1,
            AnimalGrownAge = 3,
            maxAge = 5,
            lowPay = 75,
            basePay = 100,
            maxConditionPay = 150,
            roamingRadius = 100,
            sheepItem = "wool",
            sheepItemAmount = 5,
            shearingCooldown = 120,
            butcherItems = {
                { name = 'Mutton', count = 4 },
            }
        },

        goats = {
            model = "a_c_goat_01",
            cost = 10,
            feedAnimalCondIncrease = 10,
            animalHealth = 100,
            condIncreasePerHerd = 10,
            spawnAmount = 5,
            maxCondition = 200,
            ageTimer = 60000,
            ageIncrease = 1,
            AnimalGrownAge = 3,
            maxAge = 5,
            lowPay = 75,
            basePay = 100,
            maxConditionPay = 150,
            roamingRadius = 100,
            butcherItems = {
                { name = 'Mutton', count = 4 },
            }
        },

        chickens = {
            model = "a_c_chicken_01",
            coopModel = "p_chickencoopcart01x",
            cost = 10,
            feedAnimalCondIncrease = 10,
            animalHealth = 100,
            condIncreasePerHerd = 10,
            spawnAmount = 5,
            maxCondition = 200,
            ageTimer = 60000,
            ageIncrease = 1,
            AnimalGrownAge = 3,
            maxAge = 5,
            lowPay = 75,
            basePay = 100,
            maxConditionPay = 150,
            roamingRadius = 100,
            coopCost = 200,
            eggItem = "egg",
            eggItemAmount = 5,
            harvestingCooldown = 60,
            butcherItems = {
                { name = 'bird', count = 10 },
                { name = 'chickenheart', count = 2 },
            }
        }
    }
}
