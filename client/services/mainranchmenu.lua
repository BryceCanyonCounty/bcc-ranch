----- Main Ranch Menu -----
function MainRanchMenu()
    BCCRanchMenu:Close()
    local mainMenuPage = BCCRanchMenu:RegisterPage("bcc-ranch:mainMenuPage")

    mainMenuPage:RegisterElement("header", {
        value = _U("yourRanch"),
        slot = "header",
        style = {}
    })
    mainMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })
    TextDisplay = mainMenuPage:RegisterElement('textdisplay', {
        value = _U("checkRanchCondition") .. tostring(RanchData.ranchCondition) .. "/" .. ConfigRanch.ranchSetup.maxRanchCondition ,
        slot = "header",
        style = {}
    })
    mainMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })
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
        BccUtils.RPC:Call("bcc-ranch:openInventory", {
            ranchId = RanchData.ranchid,
            ranchName = RanchData.ranchname,
            limit = tonumber(RanchData.inv_limit),
            currentStage = tonumber(RanchData.inventory_current_stage or 0)
        }, function(success)
            if success then
                devPrint("[Client] Ranch inventory opened.")
            else
                Notify("Failed to open ranch inventory", "error", 4000)
            end
        end)
        Wait(100)
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
        mainMenuPage:RegisterElement("button", {
            label = "Others",
            style = {}
        }, function()
            OthersMenu()
        end)
    end

    BCCRanchMenu:Open({
        startupPage = mainMenuPage
    })
end
