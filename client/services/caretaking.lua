local function setCoords(choreType) --done inside of a function as you cannot as you can not close feather menu as the code will stop
    BCCRanchMenu:Close()
    VORPcore.NotifyRightTip(_U("setCoordsLoop"), 10000)
    VORPcore.NotifyRightTip(_U("cancelSetCoords"), 10000)
    while true do
        Wait(5)
        if IsControlJustReleased(0, 0x760A9C6F) then
            local selectedOption = nil
            local coordSetOptions = {
                ['shovelhay'] = function()
                    selectedOption = 'shovehaycoords'
                end,
                ['wateranimal'] = function()
                    selectedOption = 'wateranimalcoords'
                end,
                ['repairfeedtrough'] = function()
                    selectedOption = 'repairtroughcoords'
                end,
                ['scooppoop'] = function()
                    selectedOption = 'scooppoopcoords'
                end
            }
            if coordSetOptions[choreType] then
                coordSetOptions[choreType]()
            else
                devPrint("Invalid choreType for setting coords: " .. choreType)
                break
            end

            local pCoords = GetEntityCoords(PlayerPedId())
            devPrint("Player coords: " .. json.encode(pCoords))
            devPrint("Ranch coords: " .. json.encode(RanchData.ranchcoordsVector3))
            devPrint("Ranch radius limit: " .. RanchData.ranch_radius_limit)

            if RanchData.ranchcoordsVector3 and RanchData.ranch_radius_limit and #(RanchData.ranchcoordsVector3 - pCoords) <= tonumber(RanchData.ranch_radius_limit) then
                TriggerServerEvent('bcc-ranch:InsertChoreCoordsIntoDB', pCoords, RanchData.ranchid, selectedOption)
                break
            else
                VORPcore.NotifyRightTip(_U("tooFarFromRanch"), 4000)
            end
        end
        if IsControlJustReleased(0, 0x9959A6F0) then
            break
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
        setCoords(choreType)
    end)

    choreMenuPage:RegisterElement("button", {
        label = _U("startChore"),
        style = {}
    }, function()
        -- Use RPC:Call to communicate with the server
        BccUtils.RPC:Notify("bcc-ranch:ChoreCheckRanchCond", { ranchId = RanchData.ranchid, choreType = choreType })
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
local blip = nil
BccUtils.RPC:Register("bcc-ranch:StartChoreClient", function(params)
    local choreType = params.choreType

    -- Validate RanchData availability
    if not RanchData or not choreType then
        devPrint("[ERROR] RanchData or choreType is missing.")
        VORPcore.NotifyRightTip(_U("invalidRanchDataOrChoreType"), 4000)
        cb(false)
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
        end
    }

    -- Configure based on chore type
    if selectedChoreFunc[choreType] then
        selectedChoreFunc[choreType]()
    else
        devPrint("[ERROR] Invalid choreType: " .. tostring(choreType))
        VORPcore.NotifyRightTip(_U("invalidChoreType"), 4000)
        cb(false)
        IsInMission = false
        return
    end

    -- Validate chore coordinates
    if not choreCoords or not choreCoords.x or not choreCoords.y or not choreCoords.z then
        devPrint("[ERROR] Missing or invalid chore coordinates for choreType: " .. choreType)
        VORPcore.NotifyRightTip("Invalid Coordinates", 4000)
        IsInMission = false
        cb(false)
        return
    end

    -- Notify and set up blip
    VORPcore.NotifyRightTip(_U("gotoChoreLocation"), 4000)
    blip = BccUtils.Blip:SetBlip(_U("choreLocation"), 960467426, 0.2, choreCoords.x, choreCoords.y, choreCoords.z)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("startChore"), BccUtils.Keys[ConfigRanch.ranchSetup.choreKey], 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    -- Monitor player interaction with the chore
    while true do
        Wait(5)

        -- Handle player death
        if IsEntityDead(PlayerPedId()) then
            blip:Remove()
            IsInMission = false
            VORPcore.NotifyRightTip(_U("failed"), 4000)
            cb(false)
            break
        end

        -- Check player proximity to chore location
        local pCoords = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(choreCoords.x, choreCoords.y, choreCoords.z, pCoords.x, pCoords.y, pCoords.z, true)

        if dist < 5 then
            PromptGroup:ShowGroup(_U('chore'))
            if firstprompt:HasCompleted() then
                -- Play the chore
                local function playChore()
                    local function deadOrSuccessCheck()
                        if IsEntityDead(PlayerPedId()) then
                            VORPcore.NotifyRightTip(_U("failed"), 4000)
                            blip:Remove()
                            IsInMission = false
                            cb(false)
                        else
                            if choreType == 'scooppoop' then
                                BccUtils.RPC:Call("bcc-ranch:AddItem", { item = ConfigRanch.ranchSetup.choreSetup.shovelPoopRewardItem, amount = ConfigRanch.ranchSetup.choreSetup.shovelPoopRewardAmount }, function(success)
                                    if success then
                                        devPrint("Item added successfully.")
                                    else
                                        devPrint("Failed to add the item.")
                                    end
                                end)
                            end
                            devPrint("Sending IncreaseRanchCond RPC. RanchId:", RanchData.ranchid, "Amount:", incAmount)
                            --[[BccUtils.RPC:Call("bcc-ranch:IncreaseRanchCond", { ranchId = RanchData.ranchid, amount = incAmount }, function(success)
                                devPrint("IncreaseRanchCond RPC Response: success =", success)
                                if success then
                                    VORPcore.NotifyRightTip(_U("choreComplete"), 4000)
                                else
                                    VORPcore.NotifyRightTip(_U("updateFailed"), 4000)
                                end
                            end)  ]]-- 
                            TriggerServerEvent('bcc-ranch:IncreaseRanchCond', RanchData.ranchid, incAmount)
                            VORPcore.NotifyRightTip(_U("choreComplete"), 4000)
                            blip:Remove()
                            IsInMission = false
                            cb(true)
                        end
                    end

                    --checking if choreType is scooppoop or shovel hay to see if we need to attach the rake or not
                    if choreType == "scooppoop" or choreType == "shovelhay" then
                        PlayAnim('amb_work@world_human_farmer_rake@male_a@idle_a', 'idle_a', animTime)
                        local rakeObj = CreateObject('p_rake02x', 0, 0, 0, true, true, false)
                        AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.19, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
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
                            VORPcore.NotifyRightTip(_U("failed"), 4000)
                            SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                            cb(false)
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
        if blip then
            blip:Remove()
        end
    end
end)
