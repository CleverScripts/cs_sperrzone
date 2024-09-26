fx_version 'cerulean'
game 'gta5'

author 'Clever Scripts'
description 'Skript zur Verwaltung von Sperzonen'
version '1.0.1'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'index_menu.html'

files {
    'index_menu.html'
}

dependencies {
    'oxmysql',
    'es_extended'
}
