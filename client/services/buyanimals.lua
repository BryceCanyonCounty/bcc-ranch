function BuyAnimalsMenu()
    BCCRanchMenu:Close()
    local buyAnimalsPage = BCCRanchMenu:RegisterPage("bcc-ranch:buyAnimalsPage")

    buyAnimalsPage:RegisterElement("header", {
        value = _U("buyAnimals"),
        slot = "header",
        style = {}
    })

    buyAnimalsPage:RegisterElement("button", {
        label = _U("buyCows"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:AnimalBought", { ranchId = RanchData.ranchid, animalType = 'cows' },
            function(success)
                if success then
                    devPrint("Successfully bought cows for ranchId: " .. RanchData.ranchid)
                    -- Handle success (for example, update the UI or notify the user)
                else
                    devPrint("Failed to buy cows for ranchId: " .. RanchData.ranchid)
                    -- Handle failure (for example, show an error message)
                end
            end)
            BuyAnimalsMenu()
    end)

    buyAnimalsPage:RegisterElement("button", {
        label = _U("buyPigs"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:AnimalBought", { ranchId = RanchData.ranchid, animalType = 'pigs' },
            function(success)
                if success then
                    devPrint("Successfully bought pigs for ranchId: " .. RanchData.ranchid)
                    -- Handle success (for example, update the UI or notify the user)
                else
                    devPrint("Failed to buy pigs for ranchId: " .. RanchData.ranchid)
                    -- Handle failure (for example, show an error message)
                end
            end)
            BuyAnimalsMenu()
    end)

    buyAnimalsPage:RegisterElement("button", {
        label = _U("buySheeps"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:AnimalBought", { ranchId = RanchData.ranchid, animalType = 'sheeps' },
            function(success)
                if success then
                    devPrint("Successfully bought sheeps for ranchId: " .. RanchData.ranchid)
                    -- Handle success (for example, update the UI or notify the user)
                else
                    devPrint("Failed to buy sheeps for ranchId: " .. RanchData.ranchid)
                    -- Handle failure (for example, show an error message)
                end
            end)
            BuyAnimalsMenu()
    end)

    buyAnimalsPage:RegisterElement("button", {
        label = _U("buyGoats"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:AnimalBought", { ranchId = RanchData.ranchid, animalType = 'goats' },
            function(success)
                if success then
                    devPrint("Successfully bought goats for ranchId: " .. RanchData.ranchid)
                    -- Handle success (for example, update the UI or notify the user)
                else
                    devPrint("Failed to buy goats for ranchId: " .. RanchData.ranchid)
                    -- Handle failure (for example, show an error message)
                end
            end)
            BuyAnimalsMenu()
    end)

    buyAnimalsPage:RegisterElement("button", {
        label = _U("buyChickens"),
        style = {}
    }, function()
        BccUtils.RPC:Call("bcc-ranch:AnimalBought", { ranchId = RanchData.ranchid, animalType = 'chickens' },
            function(success)
                if success then
                    devPrint("Successfully bought chickens for ranchId: " .. RanchData.ranchid)
                    -- Handle success (for example, update the UI or notify the user)
                else
                    devPrint("Failed to buy chickens for ranchId: " .. RanchData.ranchid)
                    -- Handle failure (for example, show an error message)
                end
            end)
            BuyAnimalsMenu()
    end)

    buyAnimalsPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    buyAnimalsPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer",
        style = {}
    }, function()
        MainRanchMenu()
    end)

    buyAnimalsPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCRanchMenu:Open({
        startupPage = buyAnimalsPage
    })
end
