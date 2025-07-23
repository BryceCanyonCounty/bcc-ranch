local function setCareTakingCoords(choreType)
     devPrint("📍 Entered setCareTakingCoords for chore: " .. tostring(choreType))
    BCCRanchMenu:Close()
    local finished = false
    -- Define required minimum distance (for example: must be at least X units from the ranch center)
    local minDist = 10.0 -- adjust this per chore type if needed
    while not finished do
        Wait(5)
        if IsControlJustReleased(0, 0x760A9C6F) then -- G
            local coordSetOptions = {
                ['shovelhay'] = 'shovehaycoords',
                ['wateranimal'] = 'wateranimalcoords',
                ['repairfeedtrough'] = 'repairtroughcoords',
                ['scooppoop'] = 'scooppoopcoords'
            }
            local selectedOption = coordSetOptions[choreType]
            if not selectedOption then
                devPrint("Invalid choreType for setting coords: " .. choreType)
                finished = true
            else
                local pCoords = GetEntityCoords(PlayerPedId())
                local dist = #(RanchData.ranchcoordsVector3 - pCoords)
                if RanchData.ranchcoordsVector3 and RanchData.ranch_radius_limit then
                    if dist < minDist then
                        Notify(_U("tooCloseToRanch"), "warning", 4000)
                    elseif dist > tonumber(RanchData.ranch_radius_limit) then
                        Notify(_U("tooFarFromRanch"), "warning", 4000)
                    else
                        BccUtils.RPC:Call("bcc-ranch:InsertChoreCoordsIntoDB", {
                            ranchId = RanchData.ranchid,
                            choreType = selectedOption,
                            choreCoords = pCoords
                        }, function(success)
                            if success then
                                devPrint("Chore coordinates successfully inserted.")
                                Notify(_U("coordsSet"), "success", 4000)
                                finished = true
                            else
                                devPrint("Failed to insert chore coordinates.")
                                Notify(_U("error"), "error", 4000)
                            end
                        end)
                    end
                else
                    Notify(_U("tooFarFromRanch"), "warning", 4000)
                end
            end
        end
        if IsControlJustReleased(0, 0x9959A6F0) then -- C
            finished = true
        end
    end
end

local function choreMenu(choreType, menuTitle)
    BCCRanchMenu:Close()
    local choreMenuPage = BCCRanchMenu:RegisterPage("bcc-ranch:choreMenuPage")
    choreMenuPage:RegisterElement("header", {
        value = menuTitle,
        slot = "header",
        style = {}
    })
    choreMenuPage:RegisterElement("button", {
        label = _U("setCoords"),
        style = {}
    }, function()
        Notify(_U("setCoordsLoop"), "info", 10000)
        Notify(_U("cancelSetCoords"), "info", 10000)
        Wait(200)
        setCareTakingCoords(choreType)
    end)
    choreMenuPage:RegisterElement("button", {
        label = _U("startChore"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:ChoreCheckRanchCond", { ranchId = RanchData.ranchid, choreType = choreType },
            function(success)
                if success then
                    devPrint("Chore condition check successful.")
                else
                    devPrint("Failed to check chore condition.")
                end
            end)
    end)
    choreMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    choreMenuPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer",
        style = {}
    }, function()
        CaretakingMenu()
    end)
    choreMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    BCCRanchMenu:Open({
        startupPage = choreMenuPage
    })
end

function CaretakingMenu()
    BCCRanchMenu:Close()
    local caretakingPage = BCCRanchMenu:RegisterPage("bcc-ranch:caretakingPage")
    caretakingPage:RegisterElement("header", {
        value = _U("caretaking"),
        slot = "header",
        style = {}
    })
    caretakingPage:RegisterElement("button", {
        label = _U("shovelHay"),
        style = {}
    }, function()
        choreMenu('shovelhay', _U("shovelHay"))
    end)
    caretakingPage:RegisterElement("button", {
        label = _U("waterAnimal"),
        style = {}
    }, function()
        choreMenu('wateranimal', _U("waterAnimal"))
    end)
    caretakingPage:RegisterElement("button", {
        label = _U("repairTrough"),
        style = {}
    }, function()
        choreMenu('repairfeedtrough', _U("repairTrough"))
    end)
    caretakingPage:RegisterElement("button", {
        label = _U("scooopPoop"),
        style = {}
    }, function()
        choreMenu('scooppoop', _U("scooopPoop"))
    end)
    caretakingPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    caretakingPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer",
        style = {}
    }, function()
        MainRanchMenu()
    end)
    caretakingPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    BCCRanchMenu:Open({
        startupPage = caretakingPage
    })
end

-- Chore Logic Area --
local choreBlip = nil
BccUtils.RPC:Register("bcc-ranch:StartChoreClient", function(params)
    local choreType = params.choreType
    -- Validate RanchData availability
    if not RanchData or not choreType then
        devPrint("[ERROR] RanchData or choreType is missing.")
        Notify(_U("invalidRanchDataOrChoreType"), "error", 4000)
        return
    end
    local choreCoords, choreAnim, incAmount, animTime, miniGame, miniGameCfg
    -- Hammertime Minigame Config
    local hammerTimeCfg = {
        focus = true,      -- Should minigame take NUI focus (required)
        cursor = true,     -- Should minigame have a cursor (required)
        nails = 7,         -- How many nails to hammer
        type = 'dark-wood' -- Wood color to display (light-wood, medium-wood, dark-wood)
    }
    IsInMission = true
    BCCRanchMenu:Close()
    local selectedChoreFunc = {
        ['shovelhay'] = function()
            choreCoords = json.decode(RanchData.shovel_hay_coords)
            incAmount = ConfigRanch.ranchSetup.choreSetup.shovelHayCondInc
            animTime = ConfigRanch.ranchSetup.choreSetup.shovelHayAnimTime
            miniGame = 'skillcheck'
            miniGameCfg = ConfigRanch.ranchSetup.choreSetup.choreMinigameSettings
        end,
        ['wateranimal'] = function()
            choreCoords = json.decode(RanchData.water_animal_coords)
            choreAnim = joaat('WORLD_HUMAN_BUCKET_POUR_LOW')
            incAmount = ConfigRanch.ranchSetup.choreSetup.waterAnimalsCondInc
            animTime = ConfigRanch.ranchSetup.choreSetup.waterAnimalsAnimTime
            miniGame = 'skillcheck'
            miniGameCfg = ConfigRanch.ranchSetup.choreSetup.choreMinigameSettings
        end,

        ['repairfeedtrough'] = function()
            choreCoords = json.decode(RanchData.repair_trough_coords)
            choreAnim = joaat('PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL')
            incAmount = ConfigRanch.ranchSetup.choreSetup.repairFeedTroughCondInc
            animTime = ConfigRanch.ranchSetup.choreSetup.repairFeedTroughAnimTime
            miniGame = 'hammertime'
            miniGameCfg = hammerTimeCfg
        end,

        ['scooppoop'] = function()
            choreCoords = json.decode(RanchData.scoop_poop_coords)
            incAmount = ConfigRanch.ranchSetup.choreSetup.shovelPoopCondInc
            animTime = ConfigRanch.ranchSetup.choreSetup.shovelPoopAnimTime
            miniGame = 'skillcheck'
            miniGameCfg = ConfigRanch.ranchSetup.choreSetup.choreMinigameSettings
        end,
    }
    -- Configure based on chore type
    if selectedChoreFunc[choreType] then
        selectedChoreFunc[choreType]()
    else
        devPrint("[ERROR] Invalid choreType: " .. tostring(choreType))
        Notify(_U("invalidChoreType"), "error", 4000)
        IsInMission = false
        return
    end
    -- Validate chore coordinates
    if not choreCoords or not choreCoords.x or not choreCoords.y or not choreCoords.z then
        devPrint("[ERROR] Missing or invalid chore coordinates for choreType: " .. choreType)
        Notify(_U("invalidChoreCoords"), "error", 4000)
        CaretakingMenu()
        IsInMission = false
        return
    end
    -- Notify and set up choreBlip
    Notify(_U("gotoChoreLocation"), "info", 4000)
    choreBlip = BccUtils.Blip:SetBlip(_U("choreLocation"), 960467426, 0.2, choreCoords.x, choreCoords.y, choreCoords.z)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("startChore"), BccUtils.Keys[ConfigRanch.ranchSetup.choreKey], 1, 1,
        true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    -- Monitor player interaction with the chore
    while true do
        Wait(5)
        -- Handle player death
        if IsEntityDead(PlayerPedId()) then
            choreBlip:Remove()
            IsInMission = false
            Notify(_U("failed"), "error", 4000)
            break
        end
        -- Check player proximity to chore location
        local pCoords = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(choreCoords.x, choreCoords.y, choreCoords.z, pCoords.x, pCoords.y, pCoords.z, true)
        if dist < 5 and not IsEntityDead(PlayerPedId()) then
            PromptGroup:ShowGroup(_U('chore'))
            if firstprompt:HasCompleted() then
                -- Play the chore
                local function playChore()
                    local function deadOrSuccessCheck()
                        if IsEntityDead(PlayerPedId()) then
                            Notify(_U("failed"), "error", 4000)
                            choreBlip:Remove()
                            IsInMission = false
                        else
                            if choreType == 'scooppoop' then
                                BccUtils.RPC:Call("bcc-ranch:AddItem",
                                    { item = ConfigRanch.ranchSetup.choreSetup.shovelPoopRewardItem, amount = ConfigRanch
                                    .ranchSetup.choreSetup.shovelPoopRewardAmount }, function(success)
                                    if success then
                                        devPrint("Item added successfully.")
                                    else
                                        devPrint("Failed to add the item.")
                                    end
                                end)
                            end
                            devPrint("[DEBUG] Sending IncreaseRanchCond RPC. RanchId:", RanchData.ranchid, "Amount:",
                                incAmount)
                            BccUtils.RPC:Call('bcc-ranch:IncreaseRanchCond',
                                { ranchId = RanchData.ranchid, amount = incAmount }, function(success, message)
                                if success then
                                    devPrint("[DEBUG] Successfully increased ranch condition.")
                                else
                                    devPrint("[ERROR] Failed to increase ranch condition. Reason: " .. (message or "unknown"))
                                end

                            end)
                            Notify(_U("choreComplete"), "success", 4000)
                            choreBlip:Remove()
                            IsInMission = false
                        end
                    end
                    --checking if choreType is scooppoop or shovel hay to see if we need to attach the rake or not
                    if choreType == "scooppoop" or choreType == "shovelhay" then
                        PlayAnim('amb_work@world_human_farmer_rake@male_a@idle_a', 'idle_a', animTime)
                        local rakeObj = CreateObject('p_rake02x', 0, 0, 0, true, true, false)
                        AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"),
                            0.0, 0.0, 0.19, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
                        Wait(animTime)
                        DeleteObject(rakeObj)
                        deadOrSuccessCheck()
                    else
                        BccUtils.Ped.ScenarioInPlace(PlayerPedId(), choreAnim, animTime)
                        deadOrSuccessCheck()
                    end
                end
                -- Handle minigame or direct execution
                if ConfigRanch.ranchSetup.choreSetup.choreMinigames then
                    MiniGame.Start(miniGame, miniGameCfg, function(result)
                        if result.result or result.passed then
                            playChore()
                        else
                            IsInMission = false
                            Notify(_U("failed"), "error", 4000)
                            choreBlip:Remove()
                            SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                        end
                    end)
                else
                    playChore()
                end
                break
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if choreBlip then
            choreBlip:Remove()
        end
    end
end)
