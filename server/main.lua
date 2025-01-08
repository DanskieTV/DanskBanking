local QBCore = exports['qb-core']:GetCoreObject()

-- Add a cooldown system for notifications
local playerCooldowns = {}

local transactionHistory = {}

-- Function to store transactions
local function storeTransaction(source, transaction)
    if not transactionHistory[source] then
        transactionHistory[source] = {}
    end
    -- Add new transaction at the beginning of the array
    table.insert(transactionHistory[source], 1, transaction)
    -- Keep only last 8 transactions
    while #transactionHistory[source] > 8 do
        table.remove(transactionHistory[source])
    end
end

-- Function to get player's transactions
local function getPlayerTransactions(source)
    return transactionHistory[source] or {}
end

local function canNotify(source)
    local lastNotify = playerCooldowns[source] or 0
    local currentTime = GetGameTimer()
    
    if currentTime - lastNotify > 1000 then -- 1 second cooldown
        playerCooldowns[source] = currentTime
        return true
    end
    return false
end

-- Update the deposit event
RegisterNetEvent('danskiebankingv2:server:deposit', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = tonumber(data.amount)
    
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid amount!', 'error')
        return
    end
    
    if Player.PlayerData.money.cash >= amount then
        Player.Functions.RemoveMoney('cash', amount, "bank-deposit")
        Player.Functions.AddMoney('bank', amount, "bank-deposit")
        
        local transaction = {
            type = 'deposit',
            amount = amount,
            description = data.description or 'Bank Deposit',
            date = os.date('%Y-%m-%d %H:%M:%S')
        }
        
        storeTransaction(src, transaction)
        TriggerClientEvent('danskiebankingv2:client:updateTransactions', src, transaction)
        TriggerClientEvent('danskiebankingv2:client:updateBalance', src, Player.PlayerData.money.bank)
        
        if canNotify(src) then
            TriggerClientEvent('QBCore:Notify', src, 'Successfully deposited $' .. amount, 'success')
        end
    else
        if canNotify(src) then
            TriggerClientEvent('QBCore:Notify', src, 'Not enough cash!', 'error')
        end
    end
end)

-- Update the withdraw event
RegisterNetEvent('danskiebankingv2:server:withdraw', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = tonumber(data.amount)
    
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid amount!', 'error')
        return
    end
    
    if Player.PlayerData.money.bank >= amount then
        Player.Functions.RemoveMoney('bank', amount, "bank-withdraw")
        Player.Functions.AddMoney('cash', amount, "bank-withdraw")
        
        local transaction = {
            type = 'withdraw',
            amount = -amount,
            description = data.description or 'Bank Withdrawal',
            date = os.date('%Y-%m-%d %H:%M:%S')
        }
        
        TriggerClientEvent('danskiebankingv2:client:updateTransactions', src, transaction)
        TriggerClientEvent('danskiebankingv2:client:updateBalance', src, Player.PlayerData.money.bank)
        
        if canNotify(src) then
            TriggerClientEvent('QBCore:Notify', src, 'Successfully withdrew $' .. amount, 'success')
        end
    else
        if canNotify(src) then
            TriggerClientEvent('QBCore:Notify', src, 'Not enough money in bank!', 'error')
        end
    end
end)

-- Handle Transfers
RegisterNetEvent('danskiebankingv2:server:transfer', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = tonumber(data.amount)
    local target = tonumber(data.target)
    
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid amount!', 'error')
        return
    end
    
    local TargetPlayer = QBCore.Functions.GetPlayer(target)
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid player ID!', 'error')
        return
    end
    
    if Player.PlayerData.money.bank >= amount then
        Player.Functions.RemoveMoney('bank', amount, "bank-transfer")
        TargetPlayer.Functions.AddMoney('bank', amount, "bank-transfer")
        
        local transaction = {
            type = 'transfer',
            amount = -amount,
            description = 'Transfer to ' .. TargetPlayer.PlayerData.charinfo.firstname,
            date = os.date('%Y-%m-%d %H:%M:%S')
        }
        
        TriggerClientEvent('danskiebankingv2:client:updateTransactions', src, transaction)
        TriggerClientEvent('danskiebankingv2:client:updateBalance', src, Player.PlayerData.money.bank)
        TriggerClientEvent('QBCore:Notify', src, 'Successfully transferred $' .. amount, 'success')
        
        TriggerClientEvent('QBCore:Notify', target, 'Received $' .. amount .. ' from ' .. Player.PlayerData.charinfo.firstname, 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money in bank!', 'error')
    end
end)

-- Add event to send transaction history when banking is opened
RegisterNetEvent('danskiebankingv2:server:requestTransactions', function()
    local src = source
    local transactions = getPlayerTransactions(src)
    TriggerClientEvent('danskiebankingv2:client:loadTransactions', src, transactions)
end)

-- Add at the top with your other server code
QBCore.Functions.CreateCallback('danskiebankingv2:server:getPlayerData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        cb({
            money = Player.PlayerData.money,
            charinfo = Player.PlayerData.charinfo
        })
    else
        cb(nil)
    end
end)

-- Add at the top of your existing server/main.lua
CreateThread(function()
    -- Wait for MySQL to be ready
    Wait(1000)
    
    -- Check if tables exist
    MySQL.query('SHOW TABLES LIKE "qbcoreframework_2be775.bank_accounts"', function(result)
        if not result or #result == 0 then
            print('^3[INFO] Banking tables not found. Installing...^7')
            InstallBankSystem()
        else
            print('^2[INFO] Banking system already installed!^7')
        end
    end)
end)

-- Add version checking
local currentVersion = '1.0.0'

-- Get database name from connection string
local function GetDatabaseName()
    local dbName = 'qbcoreframework_2be775' -- Default fallback
    local conStr = GetConvar('mysql_connection_string', '')
    
    -- Extract database name from connection string
    local dbMatch = conStr:match('database=([^;]+)')
    if dbMatch then
        dbName = dbMatch
    end
    
    return dbName
end

CreateThread(function()
    Wait(2000) -- Wait for tables to be created
    
    -- Version check
    print('^3[INFO] Current banking system version: ' .. currentVersion .. '^7')
    
    -- Verify database structure
    local requiredColumns = {
        bank_accounts = {'id', 'account_type', 'account_number', 'balance', 'interest_rate', 'last_interest_calc'},
        bank_account_members = {'id', 'account_id', 'citizen_id', 'access_level'},
        bank_loans = {'id', 'citizen_id', 'amount', 'interest_rate', 'remaining_amount', 'next_payment', 'status'}
    }
    
    for table, columns in pairs(requiredColumns) do
        local query = string.format('SHOW COLUMNS FROM `%s`', table)
        MySQL.query(query, function(result)
            if result then
                local existing = {}
                for _, col in ipairs(result) do
                    existing[col.Field] = true
                end
                
                for _, required in ipairs(columns) do
                    if not existing[required] then
                        print('^1[WARNING] Missing column: ' .. required .. ' in table: ' .. table .. '^7')
                    end
                end
            end
        end)
    end
end) 