local QBCore = exports['qb-core']:GetCoreObject()

-- Account Management
local function CreateBankAccount(accountType, citizenId, initialDeposit)
    local accountNumber = GenerateAccountNumber()
    local interestRate = Config.Banking.InterestRates.Savings
    
    MySQL.insert('INSERT INTO bank_accounts (account_type, account_number, balance, interest_rate) VALUES (?, ?, ?, ?)',
        {accountType, accountNumber, initialDeposit, interestRate}, function(accountId)
        if accountId then
            MySQL.insert('INSERT INTO bank_account_members (account_id, citizen_id, access_level) VALUES (?, ?, ?)',
                {accountId, citizenId, 'owner'})
        end
    end)
end

-- Joint Accounts
QBCore.Functions.CreateCallback('danskiebankingv2:server:createJointAccount', function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.money.bank >= Config.Banking.JointAccounts.CreationFee then
        Player.Functions.RemoveMoney('bank', Config.Banking.JointAccounts.CreationFee)
        CreateBankAccount('joint', Player.PlayerData.citizenid, 0)
        cb(true)
    else
        cb(false)
    end
end)

-- Loan Management
QBCore.Functions.CreateCallback('danskiebankingv2:server:requestLoan', function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local creditScore = CalculateCreditScore(Player.PlayerData.citizenid)
    local loanTier = GetLoanTier(creditScore)
    
    if data.amount <= Config.Banking.LoanLimits[loanTier] then
        local interestRate = Config.Banking.InterestRates.Loans[loanTier]
        CreateLoan(Player.PlayerData.citizenid, data.amount, interestRate)
        Player.Functions.AddMoney('bank', data.amount)
        cb(true)
    else
        cb(false)
    end
end)

-- Interest Calculation (run this on a timer)
function CalculateSavingsInterest()
    MySQL.query('SELECT * FROM bank_accounts WHERE account_type = ?', {'savings'}, function(accounts)
        for _, account in ipairs(accounts) do
            local interest = account.balance * (account.interest_rate / 365) -- daily interest
            MySQL.update('UPDATE bank_accounts SET balance = balance + ? WHERE id = ?',
                {interest, account.id})
        end
    end)
end 