game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'BCC @ Jake2k4'

shared_scripts {
    'config.lua',
    'locale.lua',
    'languages/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
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
    'feather-menu',
    'bcc-utils',
    'vorp_character',
    'vorp_inventory',
    'bcc-minigames',
    'vorp_utils'
}

version '2.1.2'
