fx_version 'cerulean'
game 'rdr3'

author 'MrMoen'
description 'mrmoen_afterdark - Graveyard, hauntings & pest system (RSGCore)'
version '1.1.1'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependencies {
    'rsg-core',
    'ox_lib',
    'interact-sound'
}
shared_script '@ox_lib/init.lua'

shared_scripts {
    'config/config_general.lua',
    'shared/locale_init.lua',   
    'locales/*.lua',            
    'config/config_haunt.lua',
    'config/config_pest.lua'
}
client_scripts {
    'client/client.lua',
    'client/client_pest.lua'
}
server_scripts {
    '@rsg-core/shared/locale.lua',
    'server/server.lua'
}

lua54 'yes'
