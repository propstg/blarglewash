fx_version 'adamant'

game 'gta5'

description 'Blarglebottoms Car Wash'

server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'client/animation.lua',
    'client/blips.lua',
    'client/markers.lua',
    'client/main.lua'
}

dependencies {
    'es_extended'
}
