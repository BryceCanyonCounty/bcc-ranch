game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'BCC Team @Jake2k4'

shared_scripts {
    '/configs/*.lua',
    'locale.lua',
    'languages/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '/server/helpers/dbUpdater.lua',
    '/server/helpers/functions.lua',
    '/server/helpers/controllers.lua',
    '/server/main.lua',
    '/server/services/*.lua'
}

client_scripts {
    '/client/helpers/functions.lua',
    '/client/main.lua',
    '/client/services/animalshelper/*.lua',
    '/client/services/*.lua'
}

dependency {
    'vorp_core',
    'vorp_character',
    'vorp_inventory',
    'feather-menu',
    'bcc-utils',
    'bcc-minigames',
}

version '2.6.2'
