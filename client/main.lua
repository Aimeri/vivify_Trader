local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds = {}

local function SpawnPeds()
    for i, location in ipairs(Config.PedLocation) do
        local pedModel = GetHashKey(Config.PedModel)

        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Citizen.Wait(0)
        end

        local ped = CreatePed(4, pedModel, location.x, location.y, location.z -1, location.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        spawnedPeds[i] = ped
    end
end

local function CreateTargetZones()
    for i, location in ipairs(Config.PedLocation) do
        exports['qb-target']:AddTargetModel(Config.PedModel, {
            options = {
                {
                    event = 'vivify_trader:client:trade',
                    icon = 'fas fa-play',
                    label = 'Trade',
                },
            },
            distance = 2.5
        })
    end
end

CreateThread(function()
    SpawnPeds()
end)

CreateThread(function()
    CreateTargetZones()
end)

local function OpenTradeMenu()
    local tradeMenu = {}

    for _, tradeItem in ipairs(Config.Items) do
        table.insert(tradeMenu, {
            header = tradeItem.label,
            txt = "Costs " .. tradeItem.cost .. " " .. Config.Currency,
            params = {
                event = "vivify_trader:client:openTradeInput",
                args = { item = tradeItem.item, cost = tradeItem.cost }
            }
        })
    end

    exports['qb-menu']:openMenu(tradeMenu)
end

local function HandleTrade(tradeData, amount)
    local player = QBCore.Functions.GetPlayerData()
    local currencyCount = 0
    local totalCost = amount * tradeData.cost

    for _, invItem in pairs(player.items) do
        if invItem.name == Config.Currency then
            currencyCount = currencyCount + invItem.amount
        end
    end

    if currencyCount >= totalCost then
        TriggerServerEvent('vivify_trader:server:tradeItem', tradeData.item, amount, totalCost)
    else
        TriggerEvent('QBCore:Notify', "You don't have enough currency!", "error")
    end
end

RegisterNetEvent('vivify_trader:client:openTradeInput', function(tradeData)
    local input = exports['qb-input']:ShowInput({
        header = "Enter Amount",
        submitText = "Trade",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = 'Amount'
            }
        }
    })

    if input then
        local amount = tonumber(input.amount)
        if amount and amount > 0 then
            HandleTrade(tradeData, amount)
        else
            TriggerEvent('QBCore:Notify', "Invalid amount entered!", "error")
        end
    end
end)

RegisterNetEvent('vivify_trader:client:trade', function()
    OpenTradeMenu()
end)