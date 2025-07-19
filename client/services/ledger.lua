function LedgerMenu()
    BCCRanchMenu:Close()
    local mainLedgerPage = BCCRanchMenu:RegisterPage("bcc-ranch:mainLedgerMenuPage")
    mainLedgerPage:RegisterElement("header", {
        value = _U("ledger"),
        slot = "header",
        style = {}
    })
    mainLedgerPage:RegisterElement('subheader', {
        value = _U("ledgerAmount") .. " " .. RanchData.ledger,
        slot = "header",
        style = {}
    })
    mainLedgerPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    local depositAmount = ''
    mainLedgerPage:RegisterElement("input", {
        label = _U("deposit"),
        placeholder = _U("amount"),
        style = {}
    }, function(data)
        depositAmount = data.value -- Save the input for later validation
    end)
    mainLedgerPage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        -- Validate deposit amount on confirmation
        local sanitizedDeposit = tonumber(depositAmount)
        if sanitizedDeposit and sanitizedDeposit > 0 then
            BccUtils.RPC:Call('bcc-ranch:AffectLedger', { ranchId = RanchData.ranchid, type = 'deposit', amount = sanitizedDeposit }, function(success)
                if success then
                    devPrint("Successfully deposited to ledger.")
                    MainRanchMenu()
                else
                    devPrint("Failed to deposit to ledger.")
                end
            end)
        else
            Notify(_U("invalidAmount"), "error", 4000)
        end
    end)
    mainLedgerPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    local withdrawAmount = ''
    mainLedgerPage:RegisterElement("input", {
        label = _U("withdraw"),
        placeholder = _U("amount"),
        style = {}
    }, function(data)
        withdrawAmount = data.value -- Save the input for later validation
    end)
    mainLedgerPage:RegisterElement("button", {
        label = _U("confirm"),
        style = {}
    }, function()
        -- Validate withdraw amount on confirmation
        local sanitizedWithdraw = tonumber(withdrawAmount)
        if sanitizedWithdraw and sanitizedWithdraw > 0 then
            BccUtils.RPC:Call('bcc-ranch:AffectLedger', { ranchId = RanchData.ranchid, type = 'withdraw', amount = sanitizedWithdraw }, function(success)
                if success then
                    devPrint("Successfully withdrew from ledger.")
                    MainRanchMenu()
                else
                    devPrint("Failed to withdraw from ledger.")
                end
            end)
        else
            Notify(_U("invalidAmount"), "error", 4000)
        end
    end)
    mainLedgerPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    mainLedgerPage:RegisterElement("button", {
        label = _U("back"),
        slot = "footer",
        style = {}
    }, function()
        MainRanchMenu()
    end)
    mainLedgerPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    BCCRanchMenu:Open({
        startupPage = mainLedgerPage
    })
end
