local choreCooldowns = {}
local choreDoneCount = {}

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
            VORPcore.NotifyRightTip(source, _U("invalidChoreOrCoords"), 4000)
            cb(false)
            return
        end

        -- Check if ranch condition is maxed out
        if ranchData.ranchCondition >= 100 then
            VORPcore.NotifyRightTip(source, _U("conditionMax"), 4000)
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
            VORPcore.NotifyRightTip(source, _U("cooldown") .. tostring(ConfigRanch.ranchSetup.choreSetup.choreCooldown - os.difftime(os.time(), choreCooldowns[ranchId])), 4000)
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
        VORPcore.NotifyRightTip(source, _U("invalidRanchId"), 4000)
        cb(false)
    end
end)

local herdingCooldown = {}

RegisterServerEvent('bcc-ranch:HerdingCooldown', function(ranchId, animalType)
    local _source = source
    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if #ranch > 0 then
        if not herdingCooldown[ranchId] then
            herdingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HerdAnimalClientHandler', _source, animalType)
        elseif os.difftime(os.time(), herdingCooldown[ranchId]) >= ConfigRanch.ranchSetup.herdingCooldown then
            herdingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HerdAnimalClientHandler', _source, animalType)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(ConfigRanch.ranchSetup.herdingCooldown - os.difftime(os.time(), herdingCooldown[ranchId])), 4000)
        end
    end
end)

local feedingCooldown = {}
---@param ranchId integer
---@param animalType string
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
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(ConfigRanch.ranchSetup.feedingCooldown - os.difftime(os.time(), feedingCooldown[ranchId])), 4000)
        end
    end
end)

local harvestingEggsCooldown = {}
---@param ranchId  integer
RegisterServerEvent('bcc-ranch:HarvestEggsCooldown', function(ranchId)
    local _source = source
    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if #ranch > 0 then
        if not harvestingEggsCooldown[ranchId] then
            harvestingEggsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HarvestEggs', _source)
        elseif os.difftime(os.time(), harvestingEggsCooldown[ranchId]) >= ConfigAnimals.animalSetup.chickens.harvestingCooldown then
            harvestingEggsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HarvestEggs', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(ConfigAnimals.animalSetup.chickens.harvestingCooldown - os.difftime(os.time(), harvestingEggsCooldown[ranchId])), 4000)
        end
    end
end)

local milkingCowsCooldown = {}
---@param ranchId  integer
RegisterServerEvent('bcc-ranch:MilkingCowsCooldown', function(ranchId)
    local _source = source
    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if #ranch > 0 then
        if not milkingCowsCooldown[ranchId] then
            milkingCowsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:MilkCows', _source)
        elseif os.difftime(os.time(), milkingCowsCooldown[ranchId]) >= ConfigAnimals.animalSetup.cows.milkingCooldown then
            milkingCowsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:MilkCows', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(ConfigAnimals.animalSetup.cows.milkingCooldown - os.difftime(os.time(), milkingCowsCooldown[ranchId])), 4000)
        end
    end
end)

local shearingSheepsCooldown = {}
---@param ranchId  integer
RegisterServerEvent('bcc-ranch:ShearingSheepsCooldown', function(ranchId)
    local _source = source
    local ranch = MySQL.query.await("SELECT * FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if #ranch > 0 then
        if not shearingSheepsCooldown[ranchId] then
            shearingSheepsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:ShearSheeps', _source)
        elseif os.difftime(os.time(), shearingSheepsCooldown[ranchId]) >= ConfigAnimals.animalSetup.sheeps.shearingCooldown then
            shearingSheepsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:ShearSheeps', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(ConfigAnimals.animalSetup.sheeps.shearingCooldown - os.difftime(os.time(), shearingSheepsCooldown[ranchId])), 4000)
        end
    end
end)