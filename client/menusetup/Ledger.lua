----- Variabless -----
RegisterNetEvent('bcc-ranch:LedgerMenu', function(ledger)
    Inmenu = false
    TriggerEvent('bcc-ranch:MenuClose')
    MenuData.CloseAll()
    local elements = {
        { label = _U("LedgerAmount") .. ledger },
        { label = _U("Deposit"),               value = 'deposit' },
        { label = _U("Withdraw"),              value = 'withdraw' },

    }
    local myInput = {
        type = "enableinput",                                               -- don't touch
        inputType = "input",                                                -- input type
        button = "Confirm",                                                 -- button name
        placeholder = "Amount",                                             -- placeholder name
        style = "block",                                                    -- don't touch
        attributes = {
            inputHeader = "Amount to withdraw",                             -- header
            type = "text",                                                  -- inputype text, number,date,textarea ETC
            pattern = "[0-9]{1,}",                                          --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
            title = "numbers only",                                         -- if input doesnt match show this message
            style = "border-radius: 10px; background-color: ; border:none;" -- style
        }
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("RanchMenuName"),
            align = 'top-left',
            elements = elements,
            lastmenu = 'MainMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'withdraw' then
                local withdraw = 'withdraw'
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if result ~= "" and result then -- make sure its not empty or nil
                        TriggerServerEvent('bcc-ranch:AffectLedger', RanchId, withdraw, result)
                        MainMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            elseif data.current.value == 'deposit' then
                local deposit = 'deposit'

                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if result ~= "" and result then -- make sure its not empty or nil
                        TriggerServerEvent('bcc-ranch:AffectLedger', RanchId, deposit, result)
                        MainMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            end
        end)
end)
