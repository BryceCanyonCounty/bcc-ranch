VORPcore = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()
discord = BccUtils.Discord.setup(Config.Webhook, Config.WebhookTitle, Config.WebhookAvatar)

if Config.devMode then
    -- Helper function for debugging
    function devPrint(message)
        print("^1[DEV MODE] ^4" .. message .. "^1")
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message) end
end

function NotifyClient(src, message, type, duration)
    BccUtils.RPC:Notify("bcc-ranch:NotifyClient", {
        message = message,
        type = type or "info",
        duration = duration or 6000
    }, src)
end
