------ Command To Create Ranch ------
RegisterCommand('createranch', function()
    TriggerServerEvent('bcc-ranch:AdminCheck', 'bcc-ranch:CreateRanchmenu', false)
end)