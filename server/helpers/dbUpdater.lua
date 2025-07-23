CreateThread(function()
    -- Create the `bcc_ranch` table
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcc_ranch` (
            `charidentifier` VARCHAR(50) NOT NULL,
            `ranchcoords` LONGTEXT NOT NULL,
            `ranchname` VARCHAR(100) NOT NULL,
            `ranch_radius_limit` VARCHAR(100) NOT NULL,
            `ranchid` INT NOT NULL AUTO_INCREMENT,
            `ranchCondition` INT(10) NOT NULL DEFAULT 0,

            `cows` VARCHAR(50) NOT NULL DEFAULT 'false',
            `cows_cond` INT(10) NOT NULL DEFAULT 0,
            `cows_age` INT(10) NOT NULL DEFAULT 0,
            `cow_coords` LONGTEXT NOT NULL DEFAULT 'none',

            `pigs` VARCHAR(50) NOT NULL DEFAULT 'false',
            `pigs_cond` INT(10) NOT NULL DEFAULT 0,
            `pigs_age` INT(10) NOT NULL DEFAULT 0,
            `pig_coords` LONGTEXT NOT NULL DEFAULT 'none',

            `chickens` VARCHAR(50) NOT NULL DEFAULT 'false',
            `chickens_cond` INT(10) NOT NULL DEFAULT 0,
            `chickens_age` INT(10) NOT NULL DEFAULT 0,
            `chicken_coords` LONGTEXT NOT NULL DEFAULT 'none',
            `chicken_coop` VARCHAR(50) NOT NULL DEFAULT 'false',
            `chicken_coop_coords` LONGTEXT NOT NULL DEFAULT 'none',

            `goats` VARCHAR(50) NOT NULL DEFAULT 'false',
            `goats_cond` INT(10) NOT NULL DEFAULT 0,
            `goats_age` INT(10) NOT NULL DEFAULT 0,
            `goat_coords` LONGTEXT NOT NULL DEFAULT 'none',

            `sheeps` VARCHAR(50) NOT NULL DEFAULT 'false',
            `sheeps_cond` INT(10) NOT NULL DEFAULT 0,
            `sheeps_age` INT(10) NOT NULL DEFAULT 0,
            `sheep_coords` LONGTEXT NOT NULL DEFAULT 'none',

            `herd_coords` LONGTEXT NOT NULL DEFAULT 'none',
            `feed_wagon_coords` LONGTEXT NOT NULL DEFAULT 'none',
            `shovel_hay_coords` LONGTEXT NOT NULL DEFAULT 'none',
            `water_animal_coords` LONGTEXT NOT NULL DEFAULT 'none',
            `repair_trough_coords` LONGTEXT NOT NULL DEFAULT 'none',
            `scoop_poop_coords` LONGTEXT NOT NULL DEFAULT 'none',

            `ledger` INT(10) NOT NULL DEFAULT 0,
            `taxamount` INT(10) NOT NULL DEFAULT 0,
            `taxes_collected` VARCHAR(50) DEFAULT 'false',
            `is_any_animals_out` VARCHAR(50) DEFAULT 'false',

            PRIMARY KEY (`ranchid`),
            UNIQUE KEY `charidentifier` (`charidentifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Create the `bcc_ranch_employees` table
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcc_ranch_employees` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `ranch_id` INT NOT NULL,
            `character_id` VARCHAR(50) NOT NULL,
            PRIMARY KEY (`id`),
            KEY `ranch_id` (`ranch_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Console confirmation
    print("^5[Database]^0 Tables for ^3bcc_ranch^0 ^2created or verified successfully^0.")
end)
