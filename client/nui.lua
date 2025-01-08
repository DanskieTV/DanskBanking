local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen = false

-- Function to open banking UI
function OpenBankingUI()
    QBCore.Functions.TriggerCallback('danskiebankingv2:server:getPlayerData', function(playerData)
        if playerData then
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openBank',
                data = {
                    balance = playerData.money.bank,
                    playerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
                }
            })
            -- Request transaction history
            TriggerServerEvent('danskiebankingv2:server:requestTransactions')
        end
    end)
end

-- Close UI callback
RegisterNUICallback('closeBank', function(data, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Event to receive transaction history
RegisterNetEvent('qb-banking:client:ReceiveTransactions', function(transactions)
    if isUIOpen then
        SendNUIMessage({
            action = "updateTransactions",
            data = transactions
        })
    end
end)

-- Make the OpenBankingUI function available to other resources
exports('OpenBankingUI', OpenBankingUI)

-- Event handler for opening banking UI
RegisterNetEvent('qb-banking:client:OpenBankingUI', function()
    OpenBankingUI()
end)

-- Add these RegisterNUICallback events

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('danskiebankingv2:server:deposit', data)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('danskiebankingv2:server:withdraw', data)
    cb('ok')
end)

RegisterNUICallback('transfer', function(data, cb)
    TriggerServerEvent('danskiebankingv2:server:transfer', data)
    cb('ok')
end)

-- Add this event handler for updating transactions
RegisterNetEvent('danskiebankingv2:client:updateTransactions', function(transaction)
    SendNUIMessage({
        action = 'updateTransactions',
        data = transaction
    })
end)

-- Add or update these event handlers
RegisterNetEvent('danskiebankingv2:client:updateBalance', function(newBalance)
    SendNUIMessage({
        action = 'updateBalance',
        data = newBalance
    })
end)

RegisterNetEvent('danskiebankingv2:client:updateTransactions', function(transaction)
    SendNUIMessage({
        action = 'updateTransactions',
        data = transaction
    })
end)

-- Add new event handler for loading transactions
RegisterNetEvent('danskiebankingv2:client:loadTransactions', function(transactions)
    SendNUIMessage({
        action = 'loadTransactions',
        data = transactions
    })
end) 