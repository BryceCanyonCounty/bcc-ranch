-- Server-side handler for checking if a player is an employee at a ranch
BccUtils.RPC:Register("bcc-ranch:CheckIfPlayerIsEmployee", function(params, cb, recSource)
    local _source = recSource
    devPrint("Checking if player is an employee for source: " .. _source)

    -- Get the user's character data
    local character = VORPcore.getUser(_source).getUsedCharacter
    if not character then
        devPrint("No character found for source: " .. _source)
        return cb(false)
    end

    devPrint("Character ID: " .. character.charIdentifier)

    -- Query to check if the player is an employee at a ranch
    local result = MySQL.query.await("SELECT ranch_id FROM bcc_ranch_employees WHERE character_id = ?", { character.charIdentifier })

    -- If the player is an employee at a ranch, proceed
    if #result > 0 and result[1].ranch_id then
        -- Fetch all ranch data for the ranch the player is employed at
        local ranchEmployedAt = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { result[1].ranch_id })

        -- If ranch data is found, proceed
        if #ranchEmployedAt > 0 then
            devPrint("Player is an employee at ranch: " .. ranchEmployedAt[1].ranchname)

            -- Prepare ranch inventory data
            local data = {
                id = 'Player_' .. result[1].ranch_id .. '_bcc-ranchinv',
                name = _U("inventoryName"),
                limit = ConfigRanch.ranchSetup.ranchInvLimit,
                acceptWeapons = true,
                shared = true,
                ignoreItemStackLimit = true,
                whitelistItems = false,
                UsePermissions = false,
                UseBlackList = false,
                whitelistWeapons = false
            }

            -- Register the ranch inventory
            exports.vorp_inventory:registerInventory(data)

            -- Update online ranchers list
            if not RanchersOnline[result[1].ranch_id] then
                RanchersOnline[result[1].ranch_id] = {}
            end

            -- Add the player to the online rancher list if not already there
            if not table.contains(RanchersOnline[result[1].ranch_id], _source) then
                newRancherOnline(_source, result[1].ranch_id)
            end

            -- Send full ranch data to the client
            cb(true, ranchEmployedAt[1])
        else
            devPrint("No ranch found for ranch_id: " .. result[1].ranch_id)
            cb(false)  -- No ranch data found
        end
    else
        devPrint("Player is not an employee at any ranch.")
        cb(false)  -- Player is not an employee
    end
end)

BccUtils.RPC:Register("bcc-ranch:GetEmployeeList", function(params, cb, source)
    local ranchId = params.ranchId
    if not ranchId then return cb(nil) end

    -- Fetch the ranch from the database to check if it exists
    local ranchResult = MySQL.query.await("SELECT ranchname FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if not ranchResult or not ranchResult[1] then
        return cb(nil)
    end

    local ranchName = ranchResult[1].ranch_name

    -- Fetch the list of employees for the ranch
    local employeeList = MySQL.query.await("SELECT character_id FROM bcc_ranch_employees WHERE ranch_id = ?", { ranchId })

    local results = {}

    -- Iterate over the employee list to get their information
    for _, entry in pairs(employeeList) do
        -- Iterate through players to find matching characters
        for _, playerSrc in ipairs(GetPlayers()) do
            local user = VORPcore.getUser(tonumber(playerSrc))
            if user then
                local character = user.getUsedCharacter
                if character and tostring(character.charIdentifier) == tostring(entry.character_id) then
                    -- Add the employee to the results list
                    table.insert(results, {
                        character_id = character.charIdentifier,
                        firstname = character.firstname,
                        lastname = character.lastname
                    })
                end
            end
        end
    end

    -- Return the list of employees to the client
    cb(results)
end)

BccUtils.RPC:Register("bcc-ranch:HireEmployee", function(params, cb, source)
    local ranchId = params.ranchId
    local characterId = tostring(params.characterId)

    -- Check if ranchId or characterId is missing
    if not ranchId or not characterId then
        devPrint("Error: Missing ranchId or characterId.")
        return cb(false)
    end

    -- Debug: Output the ranchId and characterId
    devPrint("Attempting to hire employee: Ranch ID = " .. ranchId .. ", Character ID = " .. characterId)

    -- Check if the employee already exists in the ranch
    local existingEmployee = MySQL.query.await(
        'SELECT 1 FROM bcc_ranch_employees WHERE ranch_id = ? AND character_id = ? LIMIT 1',
        { ranchId, characterId }
    )
    
    -- Debug: Log the result of the check
    devPrint("Checking for existing employee: " .. tostring(#existingEmployee) .. " existing records found.")

    if existingEmployee and #existingEmployee > 0 then
        devPrint("Error: Character ID " .. characterId .. " is already an employee of ranch ID " .. ranchId)
        return cb(false) -- Employee already exists, early return with failure
    end

    -- Insert the new employee into the bcc_ranch_employees table
    local result = MySQL.insert.await(
        'INSERT INTO bcc_ranch_employees (ranch_id, character_id) VALUES (?, ?)',
        { ranchId, characterId }
    )
    
    -- Debug: Log the result of the insert query
    if result then
        devPrint("Employee insertion successful for character ID " .. characterId .. " at ranch ID " .. ranchId)
    else
        devPrint("Error: Employee insertion failed for character ID " .. characterId .. " at ranch ID " .. ranchId)
        return cb(false) -- If insertion fails, return false
    end

    -- Fetch ranch and character info for webhook
    local ranchResult = MySQL.query.await('SELECT ranchname FROM bcc_ranch WHERE ranchid = ?', { ranchId })
    local ranchName = ranchResult and ranchResult[1] and ranchResult[1].ranch_name or "Unknown"
    
    -- Fetch character info (firstname, lastname)
    local charResult = MySQL.query.await('SELECT firstname, lastname FROM characters WHERE charidentifier = ?', { characterId })
    local character = charResult and charResult[1] or { firstname = "Unknown", lastname = "Unknown" }

    -- Debug: Log fetched ranch and character details
    devPrint("Fetched ranch name: " .. ranchName)
    devPrint("Fetched character name: " .. character.firstname .. " " .. character.lastname)

    -- Send to webhook (Employee Hired)
    if ranchName then
        devPrint("Sending Employee Hired notification to Discord webhook.")
        BccUtils.Discord.sendMessage(Config.Webhook,
            Config.WebhookTitle,
            Config.WebhookAvatar,
            "🔐 Employee Hired",
            nil,
            {
                {
                    color = 3145631,
                    title = "🔓 New Employee Hired",
                    description = table.concat({
                        "**Character ID:** `" .. characterId .. "`",
                        "**Character Name:** `" .. character.firstname .. " " .. character.lastname .. "`",
                        "**Ranch Name:** `" .. ranchName .. "`",
                        "**Ranch ID:** `" .. ranchId .. "`"
                    }, "\n")
                }
            }
        )
    end

    -- Return success
    cb(true)
end)

BccUtils.RPC:Register("bcc-ranch:FireEmployee", function(params, cb, source)
    local ranchId = params.ranchId
    local characterId = tostring(params.characterId)

    if not ranchId or not characterId then
        devPrint("Missing ranchId or characterId")
        return cb(false)
    end

    -- Get employee info for webhook
    local charResult = MySQL.query.await('SELECT firstname, lastname FROM characters WHERE charidentifier = ?',
        { characterId })
    local firstname = "Unknown"
    local lastname = ""

    if charResult and charResult[1] then
        firstname = charResult[1].firstname
        lastname = charResult[1].lastname
    else
        devPrint("Character not found for ID: " .. characterId)
    end

    -- Get ranch info for webhook (correct column name: ranchname)
    local ranchResult = MySQL.query.await('SELECT ranchname FROM bcc_ranch WHERE ranchid = ?', { ranchId })
    local ranchName = ranchResult and ranchResult[1] and ranchResult[1].ranchname or "Unknown"

    -- Perform deletion (fire the employee)
    local rowsChanged = MySQL.update.await('DELETE FROM bcc_ranch_employees WHERE ranch_id = ? AND character_id = ?', {
        ranchId, characterId
    })

    local success = rowsChanged and rowsChanged > 0
    devPrint("Employee fired: " .. characterId .. " from ranch ID " .. ranchId .. ": " .. tostring(success))

    -- Send to webhook
    if success and ranchName then
        local embed = {
            {
                color = 16711680,
                title = "🚫 Employee Fired",
                description = table.concat({
                    "**Character ID:** `" .. characterId .. "`",
                    "**Character Name:** `" .. firstname .. " " .. lastname .. "`",
                    "**Ranch Name:** `" .. ranchName .. "`",
                    "**Ranch ID:** `" .. ranchId .. "`"
                }, "\n")
            }
        }

        -- Send to webhook
        BccUtils.Discord.sendMessage(Config.Webhook, Config.WebhookTitle, Config.WebhookAvatar, "Access Revoked", nil, embed)
    end

    cb(success)
end)
