local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false

-- Initialize player data
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    InitializeBanks()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
end)

-- Create Blips and Initialize Banks
function InitializeBanks()
    -- Create blips for each bank
    for k, v in pairs(Config.Banks) do
        if v.blipEnabled then
            local blip = AddBlipForCoord(v.markerCoords.x, v.markerCoords.y, v.markerCoords.z)
            SetBlipSprite(blip, Config.BankBlips.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.BankBlips.size)
            SetBlipColour(blip, Config.BankBlips.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.bankName)
            EndTextCommandSetBlipName(blip)
        end

        -- Create bank peds if enabled
        if v.pedEnabled then
            CreateBankPed(v)
        end
    end

    -- Initialize ATMs
    InitializeATMs()
end

-- Create Bank Ped
function CreateBankPed(bankData)
    RequestModel(bankData.assistantModel)
    while not HasModelLoaded(bankData.assistantModel) do
        Wait(0)
    end

    local ped = CreatePed(4, bankData.assistantModel, 
        bankData.assistantCoords.x, 
        bankData.assistantCoords.y, 
        bankData.assistantCoords.z - 1, 
        bankData.assistantCoords.w, 
        false, 
        true
    )

    SetEntityHeading(ped, bankData.assistantCoords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Add target to ped
    local targetSystem = Config.GetTargetSystem()
    exports[targetSystem]:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "danskiebankingv2:client:OpenBankingUI",
                icon = "fas fa-building-columns",
                label = "Open Bank",
            }
        },
        distance = 2.0
    })
end

-- Initialize ATMs
function InitializeATMs()
    local targetSystem = Config.GetTargetSystem()
    
    -- Add target to ATMs
    exports[targetSystem]:AddTargetModel(Config.ATMModels, {
        options = {
            {
                type = "client",
                event = "danskiebankingv2:client:OpenBankingUI",
                icon = "fas fa-money-bill",
                label = "Use ATM",
            }
        },
        distance = 2.0
    })
end

-- Events for opening menus
RegisterNetEvent('danskiebankingv2:client:OpenBankingUI', function()
    if IsPedInAnyVehicle(PlayerPedId()) then
        QBCore.Functions.Notify(Config.Notify[17][2], Config.Notify[17][4])
        return
    end
    OpenBankingUI()
end)

-- Initialize on resource start
CreateThread(function()
    if LocalPlayer.state.isLoggedIn then
        InitializeBanks()
    end
end)

-- Add these debug prints
RegisterNUICallback('deposit', function(data, cb)
    print('Deposit callback received:', json.encode(data))
    TriggerServerEvent('danskiebankingv2:server:deposit', data)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    print('Withdraw callback received:', json.encode(data))
    TriggerServerEvent('danskiebankingv2:server:withdraw', data)
    cb('ok')
end)

RegisterNUICallback('transfer', function(data, cb)
    print('Transfer callback received:', json.encode(data))
    TriggerServerEvent('danskiebankingv2:server:transfer', data)
    cb('ok')
end)

-- Add event handler for balance updates
RegisterNetEvent('danskiebankingv2:client:updateBalance', function(newBalance)
    SendNUIMessage({
        action = 'updateBalance',
        data = newBalance
    })
end) 