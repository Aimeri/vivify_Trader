local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('vivify_trader:server:tradeItem', function(item, amount, totalCost)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem(Config.Currency, totalCost) then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('QBCore:Notify', src, "Trade successful!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Trade failed. Not enough currency.", "error")
    end
end)
