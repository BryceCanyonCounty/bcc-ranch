---@param choreType string
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
            end

            local pCoords = GetEntityCoords(PlayerPedId())
            if #(RanchData.ranchcoordsVector3 - pCoords) <= tonumber(RanchData.ranch_radius_limit) then
                TriggerServerEvent('bcc-ranch:InsertChoreCoordsIntoDB', pCoords, RanchData.ranchid, selectedOption) break
            else
                VORPcore.NotifyRightTip(_U("tooFarFromRanch"), 4000)
            end
        end
        if IsControlJustReleased(0, 0x9959A6F0) then break end
    end
end

-- Menu Area --
---@param choreType string
---@param menuTitle string
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
        TriggerServerEvent('bcc-ranch:ChoreCheckRanchCond/Cooldown', RanchData.ranchid, choreType)
    end)

    choreMenuPage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        CaretakingMenu()
    end)

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
    caretakingPage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        MainRanchMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = caretakingPage
    })
end

-- Chore Logic Area --
local blip = nil
RegisterNetEvent("bcc-ranch:StartChoreClient", function(choreType)
    local choreCoords,choreAnim,incAmount,animTime,miniGame,miniGameCfg

    ----- Hammertime Minigame Config ------------
    local hammerTimeCfg = {
        focus = true, -- Should minigame take nui focus (required)
        cursor = true, -- Should minigame have cursor  (required)
        nails = 7, -- How many nails to be hammered
        type = 'dark-wood' -- What color wood to display (light-wood, medium-wood, dark-wood)
    }

    IsInMission = true
    BCCRanchMenu:Close()

    local selectedChoreFunc = {
        ['shovelhay'] = function()
            choreCoords = json.decode(RanchData.shovel_hay_coords)
            incAmount = Config.ranchSetup.choreSetup.shovelHayCondInc
            animTime = Config.ranchSetup.choreSetup.shovelHayAnimTime
            miniGame = 'skillcheck'
            miniGameCfg = Config.ranchSetup.choreSetup.choreMinigameSettings
        end,
        ['wateranimal'] = function()
            choreCoords = json.decode(RanchData.water_animal_coords)
            choreAnim = joaat('WORLD_HUMAN_BUCKET_POUR_LOW')
            incAmount = Config.ranchSetup.choreSetup.waterAnimalsCondInc
            animTime = Config.ranchSetup.choreSetup.waterAnimalsAnimTime
            miniGame = 'skillcheck'
            miniGameCfg = Config.ranchSetup.choreSetup.choreMinigameSettings
        end,
        ['repairfeedtrough'] = function()
            choreCoords = json.decode(RanchData.repair_trough_coords)
            choreAnim = joaat('PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL') --credit syn_construction for anim(just where I found it at lol)
            incAmount = Config.ranchSetup.choreSetup.repairFeedTroughCondInc
            animTime = Config.ranchSetup.choreSetup.repairFeedTroughAnimTime
            miniGame = 'hammertime'
            miniGameCfg = hammerTimeCfg
        end,
        ['scooppoop'] = function()
            choreCoords = json.decode(RanchData.scoop_poop_coords)
            incAmount = Config.ranchSetup.choreSetup.shovelPoopCondInc
            animTime = Config.ranchSetup.choreSetup.shovelPoopAnimTime
            miniGame = 'skillcheck'
            miniGameCfg = Config.ranchSetup.choreSetup.choreMinigameSettings
        end
    }
    if selectedChoreFunc[choreType] then
        selectedChoreFunc[choreType]()
    end

    VORPcore.NotifyRightTip(_U("gotoChoreLocation"), 4000)
    local blip = BccUtils.Blip:SetBlip(_U("choreLocation"), 960467426, 0.2, choreCoords.x, choreCoords.y, choreCoords.z)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("startChore"), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) then
            blip:Remove()
            IsInMission = false
            VORPcore.NotifyRightTip(_U("failed"), 4000) break
        end
        local pCoords = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(choreCoords.x, choreCoords.y, choreCoords.z, pCoords.x, pCoords.y, pCoords.z, true)
        if dist < 5 then
            PromptGroup:ShowGroup("Chore")
            if firstprompt:HasCompleted() then

                local function playChore() --function used to limit amount of redundant code
                    local function deadOrSuccessCheck()
                        if IsEntityDead(PlayerPedId()) then
                            VORPcore.NotifyRightTip(_U("failed"), 4000)
                            blip:Remove()
                            IsInMission = false
                        else
                            if choreType == 'scooppoop' then
                                TriggerServerEvent('bcc-ranch:AddItem', Config.ranchSetup.choreSetup.shovelPoopRewardItem, Config.ranchSetup.choreSetup.shovelPoopRewardAmount)
                            end
                            TriggerServerEvent('bcc-ranch:IncreaseRanchCond', RanchData.ranchid, incAmount)
                            VORPcore.NotifyRightTip(_U("choreComplete"), 4000)
                            blip:Remove()
                            IsInMission = false
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

                if Config.ranchSetup.choreSetup.choreMinigames then
                    MiniGame.Start(miniGame, miniGameCfg, function(result)
                        if result.result or result.passed then
                            playChore()
                        else
                            IsInMission = false
                            VORPcore.NotifyRightTip(_U("failed"), 4000)
                            SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                        end
                    end) break
                else
                    playChore() break
                end
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