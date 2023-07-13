----- Main Ranch Menu -----
function MainMenu()
    Inmenu = true
    TriggerEvent('bcc-ranch:MenuClose')
    MenuData.CloseAll()
    TriggerEvent('bcc-ranch:loadAll')
    local elements = {
        { label = _U("CheckRanchCond"), value = 'checkranchcond', desc = _U("CheckRanchCond_desc") },
        { label = _U("Caretaking"),     value = 'caretaking',     desc = _U("Caretaking_desc") },
        { label = _U("ManageAnimals"),  value = 'manageanimals',  desc = _U("ManageAnimals_desc") },
        { label = _U("Inventory"),      value = 'openinv',        desc = _U("Inventory_desc") },
    }
    if IsOwner then
        table.insert(elements, { label = _U("BuyAnimals"),     value = 'buyanimals',      desc = _U("BuyAnimals_desc") })
        table.insert(elements, { label = _U("ManageEmployee"), value = 'manageemployees', desc = _U("ManageEmployee_desc") })
        table.insert(elements, { label = _U("Ledger"),         value = 'ledger',          desc = _U("Ledger") })

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
            if data.current.value == 'caretaking' then
                CareTakingMenu()
            elseif data.current.value == 'checkranchcond' then
                TriggerServerEvent('bcc-ranch:DisplayRanchCondition', RanchId)
            elseif data.current.value == 'buyanimals' then
                BuyAnimalMenu()
            elseif data.current.value == 'manageanimals' then
                ManageOwnedAnimalsMenu()
            elseif data.current.value == 'manageemployees' then
                EmployeeMenu()
            elseif data.current.value == 'ledger' then
                Inmenu = false
                MenuData.CloseAll()
                TriggerServerEvent('bcc-ranch:GetLedger', RanchId)

                Wait(100)
            elseif data.current.value == 'openinv' then
                TriggerServerEvent('bcc-ranch:OpenInv', RanchId)
            end
        end)
end