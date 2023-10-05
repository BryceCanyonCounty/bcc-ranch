----- Main Ranch Menu -----
function MainMenu()
    Inmenu = true
    MenuData.CloseAll()
    TriggerEvent('bcc-ranch:loadAll')
    local elements = {
        { label = _U("CheckRanchCond"), value = 'checkranchcond', desc = _U("CheckRanchCond_desc") },
        { label = _U("Caretaking"),     value = 'caretaking',     desc = _U("Caretaking_desc") },
        { label = _U("ManageAnimals"),  value = 'manageanimals',  desc = _U("ManageAnimals_desc") },
        { label = _U("Inventory"),      value = 'openinv',        desc = _U("Inventory_desc") },
    }
    if IsOwner then
        table.insert(elements, { label = _U("BuyAnimals"), value = 'buyanimals', desc = _U("BuyAnimals_desc") })
        table.insert(elements,
            { label = _U("ManageEmployee"), value = 'manageemployees', desc = _U("ManageEmployee_desc") })
        table.insert(elements, { label = _U("Ledger"), value = 'ledger', desc = _U("Ledger") })
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("RanchMenuName"),
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['caretaking'] = function()
                    CareTakingMenu()
                end,
                ['checkranchcond'] = function()
                    TriggerServerEvent('bcc-ranch:DisplayRanchCondition', RanchId)
                end,
                ['buyanimals'] = function()
                    BuyAnimalMenu()
                end,
                ['manageanimals'] = function()
                    ManageOwnedAnimalsMenu()
                end,
                ['manageemployees'] = function()
                    EmployeeMenu()
                end,
                ['ledger'] = function()
                    Inmenu = false
                    MenuData.CloseAll()
                    TriggerServerEvent('bcc-ranch:GetLedger', RanchId)
                    Wait(100)
                end,
                ['openinv'] = function()
                    TriggerServerEvent('bcc-ranch:OpenInv', RanchId)
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end,
        function(data, menu)
            Inmenu = false
            MenuData.CloseAll()
        end)
end
