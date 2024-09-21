local function addTable(tableName, definition)
    local isExist = MySQL.single.await('SHOW TABLES LIKE ?', {tableName})
    if isExist then
        return false
    end
    
    local success, err = MySQL.update.await("CREATE TABLE IF NOT EXISTS ?? ("..definition..")", {tableName})
    if success then
        print('Database table created: ' .. tableName)
        return true
    else
        print('Error creating table: ' .. err)
        return false
    end
end

local function addColumn(tableName, name, definition)
    local isExist = MySQL.single.await("SHOW COLUMNS FROM ?? LIKE ?", {tableName, name})
    if isExist then
      return false
    end
    
    local success, err = MySQL.update.await("ALTER TABLE ?? ADD "..name.." "..definition, {tableName})
    
    if success then
      print('Database column ' .. name .. ' added to ' .. tableName)
      return true
    else
      print('Error adding column: ' .. err)
      return false
    end
end

MySQL.ready(function()

    addTable('ranch', [[
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
    ]])

    addColumn('characters', 'ranchid', 'INT(10) DEFAULT 0')
end)
