-----------------------------------------------------------------------------------------------------
-------------------------------------| QB ADVANCED BANKING |------------------------------------------
-----------------------------------------------------------------------------------------------------

Config = Config or {}

-- Core Settings
Config.Core = 'QBCORE'  -- Only QB supported for now
Config.BankLabel = {'QB', 'BANKING'}
Config.Target = 'qb-target' -- 'qb-target' / 'ox_target' / 'qtarget'
Config.TextUI = false -- We'll implement this later if needed
Config.SteamName = false -- true = Steam name | false = character name

-- Banking Settings
Config.IBAN = {
    prefix = 'QB',
    numbers = 6
}
Config.PINChangeCost = 1000
Config.IBANChangeCost = 5000
Config.DailyLimit = 9999999
Config.DateFormat = '%d/%m/%Y'
Config.MenuOpenKey = 38 -- E key

-- Distance Settings
Config.Distances = {
    marker = 10.0,
    open = 2.0
}

-- ATM Settings
Config.ATMModels = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm"
}

-- Bank Blip Settings
Config.BankBlips = {
    color = 69,
    sprite = 108,
    size = 0.7
}

-- Bank Locations
Config.Banks = {
    [1] = {
        bankName = 'Pacific Standard',
        blipEnabled = true,
        pedEnabled = true,
        assistantModel = 'ig_bankman',
        assistantCoords = vector4(149.5513, -1042.1570, 29.3680, 341.6520),
        markerCoords = vector3(149.91, -1040.74, 29.374)
    },
    [2] = {
        bankName = 'Legion Square Bank',
        blipEnabled = true,
        pedEnabled = true,
        assistantModel = 'ig_bankman',
        assistantCoords = vector4(313.8176, -280.5338, 54.1647, 339.1609),
        markerCoords = vector3(314.16, -279.09, 53.97)
    }
    -- Add more banks as needed
}

-- Transaction Types
Config.Transactions = {
    Deposit = 'Deposit',
    Withdraw = 'Withdraw',
    Transfer = 'Transfer',
    Correction = 'Correction',
    NewSubAccount = 'New Sub Account',
    ChangePincode = 'Change Pincode',
    ChangeIban = 'Change Iban'
}

-- Notification Messages
Config.Notify = {
    [1] = {"BANKING", "This IBAN is already in use!", 6000, "error"},
    [2] = {"BANKING", "IBAN changed successfully!", 6000, "success"},
    [3] = {"BANKING", "PIN changed successfully!", 6000, "success"},
    [4] = {"BANKING", "Account name updated!", 6000, "success"},
    [5] = {"BANKING", "Changes saved successfully!", 6000, "success"},
    [6] = {"BANKING", "Insufficient funds!", 6000, "error"},
    [7] = {"BANKING", "Invalid player ID!", 6000, "error"},
    [8] = {"BANKING", "Transaction successful!", 6000, "success"},
    [9] = {"BANKING", "Insufficient funds!", 6000, "error"},
    [10] = {"BANKING", "Invalid IBAN!", 6000, "error"},
    [11] = {"BANKING", "Cannot transfer to yourself!", 6000, "error"}
}

-- Framework Detection Functions (from previous version)
function Config.GetTargetSystem()
    if Config.Target then return Config.Target end
    
    for system, enabled in pairs({
        ['qb-target'] = true,
        ['ox_target'] = false,
        ['qtarget'] = false
    }) do
        if enabled and GetResourceState(system) ~= 'missing' then
            return system
        end
    end
    return 'qb-target'
end

-- Phone System Detection (from previous version)
function Config.GetPhoneSystem()
    for system, enabled in pairs({
        ['qb-phone'] = true,
        ['gks-phone'] = false,
        ['qs-smartphone'] = false
    }) do
        if enabled and GetResourceState(system) ~= 'missing' then
            return system
        end
    end
    return 'qb-phone'
end

-- Config.BankLogo = "https://your-logo-url.com/logo.png" -- Add your logo URL here 

Config.Banking = {
    InterestRates = {
        Savings = 0.05,  -- 5% interest
        Loans = {
            Good = 0.08,    -- 8% interest for good credit
            Average = 0.12,  -- 12% for average credit
            Poor = 0.15     -- 15% for poor credit
        }
    },
    
    LoanLimits = {
        Good = 100000,    -- $100,000 max loan
        Average = 50000,  -- $50,000 max loan
        Poor = 25000,     -- $25,000 max loan
        MinimumPayment = 500, -- Minimum payment per cycle
        PaymentCycle = 168,   -- Payment due every 168 hours (1 week)
        MaxActiveLoans = 1    -- Maximum number of active loans per player
    },
    
    JointAccounts = {
        MaxMembers = 4,
        CreationFee = 500,
        AllowedTypes = {'savings', 'checking'}, -- Account types that can be joint
        RequiredLevel = 0,    -- Required player level/job grade to create joint account
        TransferLimit = 50000 -- Maximum transfer amount between joint members
    },
    
    SavingsAccount = {
        MinimumBalance = 1000,
        InterestInterval = 24, -- hours
        MaxAccounts = 2,      -- Maximum savings accounts per player
        InterestThresholds = { -- Different interest rates based on balance
            { amount = 10000, rate = 0.02 },   -- 2% up to $10,000
            { amount = 50000, rate = 0.04 },   -- 4% up to $50,000
            { amount = 100000, rate = 0.05 },  -- 5% up to $100,000
            { amount = 999999999, rate = 0.06 } -- 6% for anything above
        }
    },

    Fees = {
        Transfer = 25,        -- Fee for transfers between players
        International = 50,   -- Fee for international transfers
        JointCreation = 500, -- Fee to create joint account
        LoanOrigin = 100,    -- Loan origination fee
        AccountMaintenance = 10, -- Monthly maintenance fee
        OverdraftFee = 35    -- Fee for overdrafting account
    },

    Limits = {
        DailyWithdraw = 5000,    -- Maximum daily withdrawal
        DailyTransfer = 10000,   -- Maximum daily transfer
        MinTransfer = 1,         -- Minimum transfer amount
        MaxTransfer = 100000,    -- Maximum transfer amount
        OverdraftLimit = -1000   -- Maximum allowed overdraft
    }
}

Config.Installation = {
    AutoRunSQL = true,        -- Set to false to disable automatic SQL installation
    CheckMissingColumns = true, -- Set to false to disable missing column checks
    Debug = false             -- Set to true for additional installation logging
}

Config.DefaultSettings = {
    Theme = "dark",
    NotificationsEnabled = true,
    Language = "en",
    DefaultCurrency = "$",
    DateFormat = "%Y-%m-%d %H:%M:%S",
    ShowCents = true,         -- Show decimal places
    AutoLogout = 300,         -- Auto logout after 5 minutes
    RequirePin = true,        -- Require PIN for transactions
    AllowMobile = true       -- Allow mobile banking
}

Config.Themes = {
    default = {
        name = "Default",
        main = "#1E1E2E",      -- Main background
        accent = "#89B4FA",    -- Accent color
        text = "#CDD6F4",      -- Primary text
        textSecondary = "#A6ADC8", -- Secondary text
        success = "#A6E3A1",   -- Success messages
        error = "#F38BA8",     -- Error messages
        warning = "#FAB387",   -- Warning messages
        card = "#313244",      -- Card background
        border = "#45475A",    -- Borders
        hover = "#45475A",     -- Hover states
        backgroundImage = nil   -- No background image by default
    },
    
    dark = {
        name = "Dark Mode",
        main = "#000000",
        accent = "#2196F3",
        text = "#FFFFFF",
        textSecondary = "#B0BEC5",
        success = "#4CAF50",
        error = "#F44336",
        warning = "#FFA726",
        card = "#121212",
        border = "#1F1F1F",
        hover = "#1F1F1F",
        backgroundImage = nil
    },
    
    light = {
        name = "Light Mode",
        main = "#FFFFFF",
        accent = "#2196F3",
        text = "#000000",
        textSecondary = "#757575",
        success = "#4CAF50",
        error = "#F44336",
        warning = "#FFA726",
        card = "#F5F5F5",
        border = "#E0E0E0",
        hover = "#EEEEEE",
        backgroundImage = nil
    }
}

Config.CustomTheme = {
    enabled = true,            -- Allow custom themes
    allowBackgroundImage = true, -- Allow custom background images
    maxImageSize = 2048,      -- Max image size in KB
    allowedImageTypes = {      -- Allowed image types
        "image/jpeg",
        "image/png",
        "image/webp"
    },
    defaultTheme = "default"   -- Default theme key
} 