local choreCooldowns, choreDoneCount, herdingCooldown, feedingCooldown,harvestingEggsCooldown, milkingCowsCooldown, shearingSheepsCooldown = {}, {}, {}, {}, {}, {}, {}

BccUtils.RPC:Register("bcc-ranch:ChoreCheckRanchCond", function(params, cb, source)
    local ranchId = params.ranchId
    local choreType = params.choreType

    -- Fetch the ranch data
    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })

    -- Validate if ranch exists
    if #ranch > 0 then
        local ranchData = ranch[1]
        local coordsKey = nil

        -- Determine the coordinates key based on chore type
        local validChoreTypes = {
            shovelhay = "shovel_hay_coords",
            wateranimal = "water_animal_coords",
            repairfeedtrough = "repair_trough_coords",
            scooppoop = "scoop_poop_coords"
        }

        coordsKey = validChoreTypes[choreType]

        -- Validate if chore type is valid and coordinates exist
        if not coordsKey or not ranchData[coordsKey] or ranchData[coordsKey] == "" then
            devPrint("Invalid choreType or missing coordinates for choreType: " .. tostring(choreType))
            NotifyClient(source, _U("invalidChoreOrCoords"), "error", 4000)
            cb(false)
            return
        end

        -- Check if ranch condition is maxed out
        if ranchData.ranchCondition >= 100 then
            NotifyClient(source, _U("conditionMax"), "error", 4000)
            cb(false)
            return
        end

        -- Handle cooldown logic
        if not choreCooldowns[ranchId] then
            choreCooldowns[ranchId] = os.time()
            choreDoneCount[ranchId] = 1
        elseif choreDoneCount[ranchId] < 4 then
            choreDoneCount[ranchId] = choreDoneCount[ranchId] + 1
        elseif os.difftime(os.time(), choreCooldowns[ranchId]) >= ConfigRanch.ranchSetup.choreSetup.choreCooldown then
            choreCooldowns[ranchId] = os.time()
            choreDoneCount[ranchId] = 1
        else
            NotifyClient(source, _U("cooldown") .. tostring(ConfigRanch.ranchSetup.choreSetup.choreCooldown - os.difftime(os.time(), choreCooldowns[ranchId])), "error", 4000)
            cb(false)
            return
        end

        -- Call the client-side procedure to start the chore
        BccUtils.RPC:Call("bcc-ranch:StartChoreClient", { choreType = choreType }, function(success)
            if success then
                cb(true)
            else
                cb(false)
            end
        end, source)
    else
        -- Ranch does not exist
        NotifyClient(source, "Invalid Ranch Id", "error", 4000)
        cb(false)
    end
end)

BccUtils.RPC:Register("bcc-ranch:HerdingCooldown", function(params, cb, source)
    local _source = source
    local ranchId = params.ranchId
    local animalType = params.animalType

    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if not ranch or #ranch == 0 then
        NotifyClient(_source, _U("ranchNotFound"), "error", 4000)
        cb(false)
        return
    end

    local cooldown = ConfigRanch.ranchSetup.herdingCooldown
    local now = os.time()

    if not herdingCooldown[ranchId] then
        herdingCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:HerdAnimalClientHandler", _source, animalType)
        cb(true)
    elseif os.difftime(now, herdingCooldown[ranchId]) >= cooldown then
        herdingCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:HerdAnimalClientHandler", _source, animalType)
        cb(true)
    else
        local remaining = cooldown - os.difftime(now, herdingCooldown[ranchId])
        NotifyClient(_source, _U("cooldown") .. tostring(remaining), "error", 4000)
        cb(false)
    end
end)

RegisterServerEvent('bcc-ranch:FeedingCooldown', function(ranchId, animalType)
    local _source = source
    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })

    if #ranch > 0 then
        if not feedingCooldown[ranchId] then
            feedingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:FeedAnimals', _source, animalType)
        elseif os.difftime(os.time(), feedingCooldown[ranchId]) >= ConfigRanch.ranchSetup.feedingCooldown then
            feedingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:FeedAnimals', _source, animalType)
        else
            NotifyClient(_source, _U("cooldown") .. tostring(ConfigRanch.ranchSetup.feedingCooldown - os.difftime(os.time(), feedingCooldown[ranchId])), "error", 4000)
        end
    end
end)

BccUtils.RPC:Register("bcc-ranch:HandleFeedingCooldown", function(params, cb, source)
    local ranchId = params.ranchId
    local animalType = params.animalType

    -- Fetch ranch data
    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })

    if #ranch > 0 then
        local currentTime = os.time()

        -- Check if the ranch is on cooldown
        if not feedingCooldown[ranchId] then
            feedingCooldown[ranchId] = currentTime
            cb(true) -- Allow feeding
        elseif os.difftime(currentTime, feedingCooldown[ranchId]) >= ConfigRanch.ranchSetup.feedingCooldown then
            feedingCooldown[ranchId] = currentTime
            cb(true) -- Allow feeding after cooldown
        else
            local remainingCooldown = ConfigRanch.ranchSetup.feedingCooldown - os.difftime(currentTime, feedingCooldown[ranchId])
            cb(false)
            NotifyClient(source, _U("cooldown") .. tostring(remainingCooldown), "error", 4000)
        end
    else
        cb(false)
        NotifyClient(source, "Ranch not found", "error", 4000)
    end
end)

BccUtils.RPC:Register("bcc-ranch:HarvestEggsCooldown", function(params, cb, source)
    local _source = source
    local ranchId = params.ranchId

    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if not ranch or #ranch == 0 then
        NotifyClient(_source, _U("ranchNotFound"), "error", 4000)
        cb(false)
        return
    end

    local cooldown = ConfigAnimals.animalSetup.chickens.harvestingCooldown
    local now = os.time()

    if not harvestingEggsCooldown[ranchId] then
        harvestingEggsCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:HarvestEggs", _source)
        cb(true)
    elseif os.difftime(now, harvestingEggsCooldown[ranchId]) >= cooldown then
        harvestingEggsCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:HarvestEggs", _source)
        cb(true)
    else
        local remaining = cooldown - os.difftime(now, harvestingEggsCooldown[ranchId])
        NotifyClient(_source, _U("cooldown") .. tostring(remaining), "error", 4000)
        cb(false)
    end
end)

BccUtils.RPC:Register("bcc-ranch:MilkingCowsCooldown", function(params, cb, source)
    local _source = source
    local ranchId = params.ranchId

    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if not ranch or #ranch == 0 then
        NotifyClient(_source, _U("ranchNotFound"), "error", 4000)
        cb(false)
        return
    end

    local cooldown = ConfigAnimals.animalSetup.cows.milkingCooldown
    local now = os.time()

    if not milkingCowsCooldown[ranchId] then
        milkingCowsCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:MilkCows", _source)
        cb(true)
    elseif os.difftime(now, milkingCowsCooldown[ranchId]) >= cooldown then
        milkingCowsCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:MilkCows", _source)
        cb(true)
    else
        local remaining = cooldown - os.difftime(now, milkingCowsCooldown[ranchId])
        NotifyClient(_source, _U("cooldown") .. tostring(remaining), "error", 4000)
        cb(false)
    end
end)

BccUtils.RPC:Register("bcc-ranch:ShearingSheepsCooldown", function(params, cb, source)
    local _source = source
    local ranchId = params.ranchId

    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if not ranch or #ranch == 0 then
        NotifyClient(_source, _U("ranchNotFound"), "error", 4000)
        cb(false)
        return
    end

    local cooldown = ConfigAnimals.animalSetup.sheeps.shearingCooldown
    local now = os.time()

    if not shearingSheepsCooldown[ranchId] then
        shearingSheepsCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:ShearSheeps", _source)
        cb(true)
    elseif os.difftime(now, shearingSheepsCooldown[ranchId]) >= cooldown then
        shearingSheepsCooldown[ranchId] = now
        TriggerClientEvent("bcc-ranch:ShearSheeps", _source)
        cb(true)
    else
        local remaining = cooldown - os.difftime(now, shearingSheepsCooldown[ranchId])
        NotifyClient(_source, _U("cooldown") .. tostring(remaining), "error", 4000)
        cb(false)
    end
end)

