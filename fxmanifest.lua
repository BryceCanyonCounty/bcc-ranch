game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'Jake2k4'

shared_scripts {
    'config.lua',
}

server_scripts {
    'server/server.lua',
    'server/dbarea.lua',
}

client_scripts {
    'client/functions.lua',
    'client/menusetup/*.lua',
    'client/commands.lua',
    'client/MainRanch.lua',
    '/client/chores.lua',
    '/client/AnimalManager.lua',
}

dependency {
    'vorp_core',
    'vorp_inventory',
    'vorp_utils',
    'bcc-utils',
    'menuapi',
}


version '1.0.0'