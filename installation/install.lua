local QBCore = exports['qb-core']:GetCoreObject()

-- Create tables function
local function CreateTables()
    print('^3[INFO] Creating banking tables...^7')
    
    local queries = {
        'CREATE TABLE IF NOT EXISTS bank_accounts ('..
            '`id` int(11) NOT NULL AUTO_INCREMENT,'..
            '`account_type` varchar(50) NOT NULL,'..
            '`account_number` varchar(50) NOT NULL,'..
            '`balance` decimal(10,2) DEFAULT 0.00,'..
            '`interest_rate` decimal(5,2) DEFAULT 0.00,'..
            '`last_interest_calc` timestamp NULL DEFAULT NULL,'..
            'PRIMARY KEY (`id`)'..
        ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;',

        'CREATE TABLE IF NOT EXISTS bank_account_members ('..
            '`id` int(11) NOT NULL AUTO_INCREMENT,'..
            '`account_id` int(11) NOT NULL,'..
            '`citizen_id` varchar(50) NOT NULL,'..
            '`access_level` varchar(20) NOT NULL,'..
            'PRIMARY KEY (`id`),'..
            'FOREIGN KEY (`account_id`) REFERENCES bank_accounts(`id`) ON DELETE CASCADE'..
        ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;',

        'CREATE TABLE IF NOT EXISTS bank_loans ('..
            '`id` int(11) NOT NULL AUTO_INCREMENT,'..
            '`citizen_id` varchar(50) NOT NULL,'..
            '`amount` decimal(10,2) NOT NULL,'..
            '`interest_rate` decimal(5,2) NOT NULL,'..
            '`remaining_amount` decimal(10,2) NOT NULL,'..
            '`next_payment` timestamp NOT NULL,'..
            '`status` varchar(20) NOT NULL,'..
            'PRIMARY KEY (`id`)'..
        ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
    }

    for _, query in ipairs(queries) do
        MySQL.query(query, function(result)
            if not result and Config.Installation.Debug then
                print('^1[ERROR] Failed to execute SQL query^7')
                print(query)
            end
        end)
        Wait(100) -- Add small delay between queries
    end
end

-- Initialize the banking system
CreateThread(function()
    Wait(1000) -- Wait for MySQL to be ready
    
    if not Config.Installation.AutoRunSQL then
        print('^3[INFO] Automatic SQL installation is disabled in config^7')
        return
    end
    
    print('^3[INFO] Checking banking tables...^7')
    
    MySQL.query('SHOW TABLES LIKE "bank_accounts"', function(result)
        if not result or #result == 0 then
            print('^3[INFO] Banking tables not found. Installing...^7')
            CreateTables()
            Wait(500) -- Wait for tables to be created
            print('^2[SUCCESS] Banking tables installed!^7')
        else
            if Config.Installation.Debug then
                print('^2[DEBUG] Banking tables already exist!^7')
            end
        end
    end)
end)

-- Update the column verification in server/main.lua to respect config
CreateThread(function()
    Wait(2000)
    
    if not Config.Installation.CheckMissingColumns then
        return
    end
    
    -- Rest of your column verification code...
end) 