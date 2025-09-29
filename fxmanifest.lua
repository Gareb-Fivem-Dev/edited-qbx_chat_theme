fx_version 'cerulean'
game 'common'

name 'qbx_chat_theme'
description 'Edited For Torrid RP mantine-styled theme for the chat resource.'
version '1.0.1'
author 'Gareb Torrid RP'
repository 'https://github.com/Gareb-Fivem-Dev/edited-qbx_chat_theme'

files {
    'theme/*',
    'theme/img/*',
    
}

ui_page "theme/index.html"


chat_theme 'qbox_chat' {
    styleSheet = 'theme/app.css',
    script = 'theme/app.js',
    msgTemplates = {
        default = '<div class="alert"><b class="type">{0}</b><span>{1}</span></div>'
    }
}

client_scripts {
	'client/dice.lua',
    'client/client.lua',
    'config/config.lua',
	}

server_scripts {
    'server/server.lua',
    'server/staffchat.lua',
    'config/config.lua',
}

lua54 'yes'
