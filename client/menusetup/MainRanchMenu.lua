----- Main Ranch Menu -----
function MainMenu()
    Inmenu = true
    TriggerEvent('bcc-ranch:MenuClose')
    MenuData.CloseAll()
    local elements = {
        { label = _U("CheckRanchCond"), value = 'checkranchcond', desc = _U("CheckRanchCond_desc") },
        { label = _U("Caretaking"), value = 'caretaking', desc = _U("Caretaking_desc") },
        { label = _U("BuyAnimals"), value = 'buyanimals', desc = _U("BuyAnimals_desc") },
        { label = _U("ManageAnimals"), value = 'manageanimals', desc = _U("ManageAnimals_desc") },
        { label = _U("Inventory"), value = 'openinv', desc = _U("Inventory_desc") },
    }

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
            elseif data.current.value == 'openinv' then
                TriggerServerEvent('bcc-ranch:OpenInv', RanchId)
            end
        end)
end