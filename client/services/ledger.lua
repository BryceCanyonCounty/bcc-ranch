function LedgerMenu()
    BCCRanchMenu:Close()

    local mainLedgerPage = BCCRanchMenu:RegisterPage("bcc-ranch:mainLedgerMenuPage")
    mainLedgerPage:RegisterElement("header", {
        value = _U("ledger"),
        slot = "header",
        style = {}
    })
    mainLedgerPage:RegisterElement("button", {
        label = _U("ledgerAmount") .. " " .. RanchData.ledger,
        style = {}
    }, function()
        --Leave empty as this is just to dispaly the ledger amount
    end)
    local depositAmount = ''
    mainLedgerPage:RegisterElement("input", {
        label = _U("deposit"),
        placeholder = _U("amount"),
        style = {}
    }, function(data)
        if string.find(data.value, "-") or string.find(data.value, "'") or string.find(data.value, '"') then -- checking for ' or " to prevent sql injection and - to prevent negative numbers
            VORPcore.NotifyRightTip(_U("inputProtectionError"), 4000)
            depositAmount = ''
        else
            depositAmount = data.value
        end
    end)
    mainLedgerPage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        if depositAmount ~= "" and depositAmount then -- make sure its not empty or nil
            TriggerServerEvent('bcc-ranch:AffectLedger', RanchData.ranchid, 'deposit', depositAmount)
            MainRanchMenu()
        end
    end)
    local withdrawAmount = ''
    mainLedgerPage:RegisterElement("input", {
        label = _U("withdraw"),
        placeholder = _U("amount"),
        style = {}
    }, function(data)
        if string.find(data.value, "-") or string.find(data.value, "'") or string.find(data.value, '"') then -- checking for ' or " to prevent sql injection and - to prevent negative numbers
            VORPcore.NotifyRightTip(_U("inputProtectionError"), 4000)
            withdrawAmount = ''
        else
            withdrawAmount = data.value
        end
    end)
    mainLedgerPage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        if withdrawAmount ~= "" and withdrawAmount then -- make sure its not empty or nil
            TriggerServerEvent('bcc-ranch:AffectLedger', RanchData.ranchid, "withdraw", withdrawAmount)
            MainRanchMenu()
        end
    end)
    mainLedgerPage:RegisterElement("button", {
        label = _U("back"),
        style = {}
    }, function()
        MainRanchMenu()
    end)

    BCCRanchMenu:Open({
        startupPage = mainLedgerPage
    })
end