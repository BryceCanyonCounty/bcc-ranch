---@param ranchId integer
---@param choreType string
local choreCooldowns = {}
local choreDoneCount = {}
RegisterServerEvent('bcc-ranch:ChoreCheckRanchCond/Cooldown', function(ranchId, choreType)
    local _source = source
    local param = { ['ranchid'] = ranchId }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        if ranch[1].ranchCondition >= 100 then
            VORPcore.NotifyRightTip(_source, _U("conditionMax"), 4000)
        else
            if not choreCooldowns[ranchId] then
                choreCooldowns[ranchId] = os.time()
                choreDoneCount[ranchId] = 1
                TriggerClientEvent('bcc-ranch:StartChoreClient', _source, choreType)
            elseif choreCooldowns[ranchId] ~= nil and choreDoneCount[ranchId] < 4 then
                choreDoneCount[ranchId] = choreDoneCount[ranchId] + 1
                TriggerClientEvent('bcc-ranch:StartChoreClient', _source, choreType)
            elseif os.difftime(os.time(), choreCooldowns[ranchId]) >= Config.ranchSetup.choreSetup.choreCooldown then
                choreCooldowns[ranchId] = os.time()
                choreDoneCount[ranchId] = 1
                TriggerClientEvent('bcc-ranch:StartChoreClient', _source, choreType)
            else
                VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(Config.ranchSetup.choreSetup.choreCooldown - os.difftime(os.time(), choreCooldowns[ranchId])), 4000)
            end
        end
    end
end)

local herdingCooldown = {}
RegisterServerEvent('bcc-ranch:HerdingCooldown', function(ranchId, animalType)
    local _source = source
    local param = { ['ranchid'] = ranchId }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        if not herdingCooldown[ranchId] then
            herdingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HerdAnimalClientHandler', _source, animalType)
        elseif os.difftime(os.time(), herdingCooldown[ranchId]) >= Config.ranchSetup.herdingCooldown then
            herdingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HerdAnimalClientHandler', _source, animalType)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(Config.ranchSetup.herdingCooldown - os.difftime(os.time(), herdingCooldown[ranchId])), 4000)
        end
    end
end)

local feedingCooldown = {}
RegisterServerEvent('bcc-ranch:FeedingCooldown', function(ranchId, animalType)
    local _source = source
    local param = { ['ranchid'] = ranchId }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        if not feedingCooldown[ranchId] then
            feedingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:FeedAnimals', _source, animalType)
        elseif os.difftime(os.time(), feedingCooldown[ranchId]) >= Config.ranchSetup.feedingCooldown then
            feedingCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:FeedAnimals', _source, animalType)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(Config.ranchSetup.feedingCooldown - os.difftime(os.time(), feedingCooldown[ranchId])), 4000)
        end
    end
end)

local harvestingEggsCooldown = {}
RegisterServerEvent('bcc-ranch:HarvestEggsCooldown', function(ranchId)
    local _source = source
    local param = { ['ranchid'] = ranchId }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        if not harvestingEggsCooldown[ranchId] then
            harvestingEggsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HarvestEggs', _source)
        elseif os.difftime(os.time(), harvestingEggsCooldown[ranchId]) >= Config.animalSetup.chickens.harvestingCooldown then
            harvestingEggsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:HarvestEggs', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(Config.animalSetup.chickens.harvestingCooldown - os.difftime(os.time(), harvestingEggsCooldown[ranchId])), 4000)
        end
    end
end)

local milkingCowsCooldown = {}
RegisterServerEvent('bcc-ranch:MilkingCowsCooldown', function(ranchId)
    local _source = source
    local param = { ['ranchid'] = ranchId }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        if not milkingCowsCooldown[ranchId] then
            milkingCowsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:MilkCows', _source)
        elseif os.difftime(os.time(), milkingCowsCooldown[ranchId]) >= Config.animalSetup.cows.milkingCooldown then
            milkingCowsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:MilkCows', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(Config.animalSetup.cows.milkingCooldown - os.difftime(os.time(), milkingCowsCooldown[ranchId])), 4000)
        end
    end
end)

local shearingSheepsCooldown = {}
RegisterServerEvent('bcc-ranch:ShearingSheepsCooldown', function(ranchId)
    local _source = source
    local param = { ['ranchid'] = ranchId }
    local ranch = MySQL.query.await("SELECT * FROM ranch WHERE ranchid=@ranchid", param)
    if #ranch > 0 then
        if not shearingSheepsCooldown[ranchId] then
            shearingSheepsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:ShearSheeps', _source)
        elseif os.difftime(os.time(), shearingSheepsCooldown[ranchId]) >= Config.animalSetup.sheeps.shearingCooldown then
            shearingSheepsCooldown[ranchId] = os.time()
            TriggerClientEvent('bcc-ranch:ShearSheeps', _source)
        else
            VORPcore.NotifyRightTip(_source, _U("cooldown") .. tostring(Config.animalSetup.sheeps.shearingCooldown - os.difftime(os.time(), shearingSheepsCooldown[ranchId])), 4000)
        end
    end
end)