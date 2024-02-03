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
        TriggerServerEvent('bcc-ranch:AnimalBought', RanchData.ranchid, 'cows')
    end)
    buyAnimalsPage:RegisterElement("button", {
        label = _U("buyPigs"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:AnimalBought', RanchData.ranchid, 'pigs')
    end)
    buyAnimalsPage:RegisterElement("button", {
        label = _U("buySheeps"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:AnimalBought', RanchData.ranchid, 'sheeps')
    end)
    buyAnimalsPage:RegisterElement("button", {
        label = _U("buyGoats"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:AnimalBought', RanchData.ranchid, 'goats')
    end)
    buyAnimalsPage:RegisterElement("button", {
        label = _U("bigChickens"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-ranch:AnimalBought', RanchData.ranchid, 'chickens')
    end)
    buyAnimalsPage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        MainRanchMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = buyAnimalsPage
    })
end