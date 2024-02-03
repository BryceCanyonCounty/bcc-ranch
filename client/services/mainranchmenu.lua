----- Main Ranch Menu -----
function MainRanchMenu()
    BCCRanchMenu:Close()
    local mainMenuPage = BCCRanchMenu:RegisterPage("bcc-ranch:mainMenuPage")

    mainMenuPage:RegisterElement("header", {
        value = _U("yourRanch"),
        slot = "header",
        style = {}
    })
    mainMenuPage:RegisterElement("button", {
        label = _U("checkRanchCondition"),
        style = {}
    }, function()
        VORPcore.NotifyRightTip(tostring(RanchData.ranchCondition) .. "/" .. Config.ranchSetup.maxRanchCondition, 4000)
    end)
    mainMenuPage:RegisterElement("button", {
        label = _U("caretaking"),
        style = {}
    }, function()
        CaretakingMenu()
    end)
    mainMenuPage:RegisterElement("button", {
        label = _U("manageOwnedAnimals"),
        style = {}
    }, function()
        ManageOwnedAnimalsMenu()
    end)
    mainMenuPage:RegisterElement("button", {
        label = _U("inventoryName"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:OpenInv', RanchData.ranchid)
        Wait(100) --Wait or else it wont work due to weirdness of feather menu
        BCCRanchMenu:Close()
    end)
    if IsOwnerOfRanch then
        mainMenuPage:RegisterElement("button", {
            label = _U("buyAnimals"),
            style = {}
        }, function()
            BuyAnimalsMenu()
        end)
        mainMenuPage:RegisterElement("button", {
            label = _U("manageEmployees"),
            style = {}
        }, function()
            EmployeesMenu()
        end)
        mainMenuPage:RegisterElement("button", {
            label = _U("ledger"),
            style = {}
        }, function()
            LedgerMenu()
        end)
    end

    BCCRanchMenu:Open({
        startupPage = mainMenuPage
    })
end