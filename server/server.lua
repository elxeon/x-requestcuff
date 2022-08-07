ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


request_data = {}

RegisterServerEvent("sendrequest")
AddEventHandler("sendrequest", function(id)
    local src = source

    if request_data[id] ~= nil then return end 

    request_data[id] = {
        target = id,
        sender = src
    }
    TriggerClientEvent("getrequest", id, src)
end)


ESX.RegisterServerCallback("hoertje:checkinv", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hoeveel = xPlayer.getInventoryItem(item)

    if hoeveel == nil then
        cb(0)
    else
        cb(hoeveel.count)
    end
end)


RegisterServerEvent("acceptrequest")
AddEventHandler("acceptrequest", function(targed)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    local target = ESX.GetPlayerFromId(targed)
    if request_data[source] then 
        TriggerClientEvent('x-requestcuff:client:handcuffanim', src)
        TriggerClientEvent('x-requestcuff:client:GetCuffed', targed, src)
        request_data[source] = nil
    else
        print("er is iets misgegaan...")
    end
end)

RegisterServerEvent("revokerequest")
AddEventHandler("revokerequest", function()
    local xPlayer = ESX.GetPlayerFromId(src)
    TriggerClientEvent('esx:showNotification', src, "Uw verzoek voor het fouilleren van " .. GetPlayerName(source) .." is afgewezen...")
    request_data[source] = nil
end)