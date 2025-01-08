fx_version 'cerulean'
game 'gta5'

description 'QB Banking System with Theme Support'
version '2.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*'
}

lua54 'yes'

dependencies {
    'qb-core',
    'oxmysql'
}

escrow_ignore {
    'shared/*.lua',
    'locales/*.lua',
    'README.md',
    'INSTALL.md'
} 