CreateThread(function()
    -- Check if the `ranch` table exists before renaming
    local result = MySQL.query.await([[
        SELECT COUNT(*) as count
        FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = 'ranch';
    ]])

    if result[1] and result[1].count > 0 then
        -- Rename the `ranch` table to `bcc_ranch`
        MySQL.query.await([[
            RENAME TABLE `ranch` TO `bcc_ranch`;
        ]])
        print("\x1b[33mTable `ranch` renamed to `bcc_ranch`.\x1b[0m")
    else
        print("\x1b[33mTable `ranch` does not exist. Skipping rename.\x1b[0m")
    end

    -- Create the `bcc_ranch` table if it doesn't exist (failsafe for future migrations)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcc_ranch` (
            `charidentifier` varchar(50) NOT NULL,
            `ranchcoords` LONGTEXT NOT NULL,
            `ranchname` varchar(100) NOT NULL,
            `ranch_radius_limit` varchar(100) NOT NULL,
            `ranchid` int NOT NULL AUTO_INCREMENT,
            `ranchCondition` int(10) NOT NULL DEFAULT 0,
            `cows` varchar(50) NOT NULL DEFAULT 'false',
            `cows_cond` int(10) NOT NULL DEFAULT 0,
            `cows_age` int(10) NOT NULL DEFAULT 0,
            `cow_coords` LONGTEXT NOT NULL DEFAULT "none",
            `pigs` varchar(50) NOT NULL DEFAULT 'false',
            `pigs_cond` int(10) NOT NULL DEFAULT 0,
            `pigs_age` int(10) NOT NULL DEFAULT 0,
            `pig_coords` LONGTEXT NOT NULL DEFAULT "none",
            `chickens` varchar(50) NOT NULL DEFAULT 'false',
            `chickens_cond` int(10) NOT NULL DEFAULT 0,
            `chickens_age` int(10) NOT NULL DEFAULT 0,
            `chicken_coords` LONGTEXT NOT NULL DEFAULT "none",
            `chicken_coop` varchar(50) NOT NULL DEFAULT 'false',
            `chicken_coop_coords` LONGTEXT NOT NULL DEFAULT "none",
            `goats` varchar(50) NOT NULL DEFAULT 'false',
            `goats_cond` int(10) NOT NULL DEFAULT 0,
            `goats_age` int(10) NOT NULL DEFAULT 0,
            `goat_coords` LONGTEXT NOT NULL DEFAULT "none",
            `sheeps` varchar(50) NOT NULL DEFAULT "false",
            `sheeps_cond` int(10) NOT NULL DEFAULT 0,
            `sheeps_age` int(10) NOT NULL DEFAULT 0,
            `sheep_coords` LONGTEXT NOT NULL DEFAULT "none",
            `herd_coords` LONGTEXT NOT NULL DEFAULT "none",
            `feed_wagon_coords` LONGTEXT NOT NULL DEFAULT "none",
            `shovel_hay_coords` LONGTEXT NOT NULL DEFAULT "none",
            `water_animal_coords` LONGTEXT NOT NULL DEFAULT "none",
            `repair_trough_coords` LONGTEXT NOT NULL DEFAULT "none",
            `scoop_poop_coords` LONGTEXT NOT NULL DEFAULT "none",
            `ledger` int(10) NOT NULL DEFAULT 0,
            `taxamount` int(10) NOT NULL DEFAULT 0,
            `taxes_collected` varchar(50) DEFAULT 'false',
            `is_any_animals_out` varchar(50) DEFAULT 'false',
            PRIMARY KEY (`ranchid`),
            UNIQUE KEY `charidentifier` (`charidentifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Add `ranchid` to the `characters` table if it doesn't exist
    MySQL.query.await([[
        ALTER TABLE `characters` ADD COLUMN IF NOT EXISTS `ranchid` INT(10) DEFAULT 0;
    ]])

    -- Print a success message to the console
    print("Database tables for \x1b[35m\x1b[1m*bcc_ranch*\x1b[0m updated \x1b[32msuccessfully\x1b[0m.")
end)
