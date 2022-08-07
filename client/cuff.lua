ESX = nil

isHandcuffed = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)    

RegisterCommand("request_cuff", function(source, args)
    ESX.TriggerServerCallback("hoertje:checkinv", function(heeftboeien)
        if heeftboeien then 
            local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5)
            local data = {}
            local own_id = GetPlayerServerId(PlayerId())
            for k,v in pairs(players) do 
                if GetPlayerServerId(v) ~= own_id then 
                    table.insert(data, {
                        label = GetPlayerServerId(v),
                        id = GetPlayerServerId(v)
                    })
                end
            end
            if #data < 1 then return end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'request_cuff', {
                title = "Handboei verzoek",
                align = "top-right",
                elements = data
            }, function(data, menu)
                TriggerServerEvent("sendrequest", data.current.id)
                menu.close()
            end, function(data, menu)
                menu.close()
            end)
        else
            ESX.ShowNotification("Je moet handboeien hebben om iemand te boeien!")
        end
    end, 'handcuff')
end)

RegisterCommand("rc", function(source ,args)
    ESX.TriggerServerCallback("hoertje:checkinv", function(heeftboeien)
        if heeftboeien then 
            local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5)
            local data = {}
            local own_id = GetPlayerServerId(PlayerId())
            for k,v in pairs(players) do 
                if GetPlayerServerId(v) ~= own_id then 
                    table.insert(data, {
                        label = GetPlayerServerId(v),
                        id = GetPlayerServerId(v)
                    })
                end
            end
            if #data < 1 then return end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'request_cuff', {
                title = "Handboei verzoek",
                align = "top-right",
                elements = data
            }, function(data, menu)
                TriggerServerEvent("sendrequest", data.current.id)
                menu.close()
            end, function(data, menu)
                menu.close()
            end)
        else
            ESX.ShowNotification("Je moet handboeien hebben om iemand te boeien!")
        end
    end, 'handcuff')
end)

RegisterCommand("afboeien", function(source ,args)
    ESX.TriggerServerCallback("hoertje:checkinv", function(heeftboeien)
        if heeftboeien then 
            local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5)
            local data = {}
            local own_id = GetPlayerServerId(PlayerId())
            for k,v in pairs(players) do 
                if GetPlayerServerId(v) ~= own_id then 
                    table.insert(data, {
                        label = GetPlayerServerId(v),
                        id = GetPlayerServerId(v)
                    })
                end
            end
            if #data < 1 then return end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'request_cuff', {
                title = "Handboei verzoek",
                align = "top-right",
                elements = data
            }, function(data, menu)
                TriggerServerEvent("sendrequest", data.current.id)
                menu.close()
            end, function(data, menu)
                menu.close()
            end)
        else
            ESX.ShowNotification("Je moet handboeien hebben om iemand te boeien!")
        end
    end, 'handcuff')
end)


RegisterNetEvent("getrequest")
AddEventHandler("getrequest", function(sender)
    being_asked()
    ESX.ShowNotification("ID ~b~" .. sender .. "~w~ wilt je afboeien, druk ~g~K~w~ om het te accepteren...  ~r~H~w~ om het te weigeren...")
end)


RegisterNetEvent("requestaccepted")
AddEventHandler("requestaccepted", function()
    TriggerServerEvent('x-requestcuff:handcuff', GetPlayerServerId(closestPlayer))
end)


being_asked = function()
    Citizen.CreateThread(function()
        while true do 
            Wait(0)
            if IsControlJustReleased(0,311) then 
                TriggerServerEvent("acceptrequest")
                return
            end


            if IsControlJustReleased(0, 304) then 
                TriggerServerEvent("revokerequest")
                return
            end
        end
    end)
end

RegisterNetEvent('x-requestcuff:handcuff')
AddEventHandler('x-requestcuff:handcuff', function()
    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestPlayerDistance > 3.0 then
        ESX.ShowNotification("Er staat niemand bij je in de buurt")
    else
        if not isHandcuffed then
            local ply = GetPlayerServerId(closestPlayer)
            TriggerServerEvent("x-requestcuff:client:CuffPlayer", ply)
        else
            ESX.ShowNotification("Je bent zelf geboeit...")
        end
    end
end)

RegisterNetEvent("x-requestcuff:client:handcuffanim")
AddEventHandler("x-requestcuff:client:handcuffanim", function()
    HandCuffAnimation()
end)

RegisterNetEvent('x-requestcuff:client:GetCuffed')
AddEventHandler('x-requestcuff:client:GetCuffed', function(playerId)
    if not isHandcuffed then
        isHandcuffed = true
        TriggerServerEvent("x-requestcuff:server:SetHandcuffStatus", true)
        ClearPedTasksImmediately(GetPlayerPed(-1))
        cuffType = 16
        GetCuffedAnimation(playerId)
        ESX.ShowNotification("Je bent geboeid...")
        Cuffed()
    else
        isHandcuffed = false
        isEscorted = false
        TriggerEvent('hospital:client:isEscorted', isEscorted)
        DetachEntity(GetPlayerPed(-1), true, false)
        TriggerServerEvent("x-requestcuff:server:SetHandcuffStatus", false)
        ClearPedTasksImmediately(GetPlayerPed(-1))
        ESX.ShowNotification("Je bent ontboeid...")
    end
end)


function HandCuffAnimation()
    RequestAnimDict("mp_arrest_paired")
	Citizen.Wait(100)
    TaskPlayAnim(GetPlayerPed(-1), "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
	Citizen.Wait(3500)
    TaskPlayAnim(GetPlayerPed(-1), "mp_arrest_paired", "exit", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
end


function GetCuffedAnimation(playerId)
    local cuffer = GetPlayerPed(GetPlayerFromServerId(playerId))
    local heading = GetEntityHeading(cuffer)
    RequestAnimDict("mp_arrest_paired")
    SetEntityCoords(GetPlayerPed(-1), GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))
	Citizen.Wait(100)
	SetEntityHeading(GetPlayerPed(-1), heading)
	TaskPlayAnim(GetPlayerPed(-1), "mp_arrest_paired", "crook_p2_back_right", 3.0, 3.0, -1, 32, 0, 0, 0, 0)
	Citizen.Wait(2500)
end