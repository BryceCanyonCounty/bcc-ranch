----- Main Ranch Menu -----
function MainMenu()
    Inmenu = true
    TriggerEvent('bcc-ranch:MenuClose')
    MenuData.CloseAll()
    local elements = {
        { label = Config.Language.CheckRanchCond, value = 'checkranchcond', desc = Config.Language.CheckRanchCond_desc },
        { label = Config.Language.Caretaking, value = 'caretaking', desc = Config.Language.Caretaking_desc },
        { label = Config.Language.BuyAnimals, value = 'buyanimals', desc = Config.Language.BuyAnimals_desc },
        { label = Config.Language.ManageAnimals, value = 'manageanimals', desc = Config.Language.ManageAnimals_desc },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = Config.Language.RanchMenuName,
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
            end
        end)

end