ESX = nil

local E_KEY = 38
local isPurchased = {}

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    initBlips()
end)

function initBlips()
    for i = 1, #Config.Locations do
        local coords = Config.Locations[i].Entrance
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 100)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(_U('carwash_name'))
        EndTextCommandSetBlipName(blip)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2)

        if IsPedInAnyVehicle(PlayerPedId(), true) then
            for i = 1, #Config.Locations do
                handleLocation(i)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

function handleLocation(locationIndex)
    if isPurchased[locationIndex] then
        handlePurchasedLocation(locationIndex)
    else
        handleUnpurchasedLocation(locationIndex)
    end
end

function handleUnpurchasedLocation(locationIndex)
    local coords = Config.Locations[locationIndex].Entrance;
    
    drawCircle(coords, Config.Markers.Entrance)

    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true) < 5 then
        if Config.Price > 0 then
            ESX.ShowHelpNotification(_U('hint_fee', Config.Price))
        else
            ESX.ShowHelpNotification(_U('hint_free'))
        end

        if IsControlJustPressed(1, E_KEY) then
            purchaseWash(locationIndex)
        end
    end
end

function purchaseWash(locationIndex)
    ESX.TriggerServerCallback('blarglewash:purchaseWash', function(isPurchaseSuccessful)
        local message = ""

        if isPurchaseSuccessful then
            isPurchased[locationIndex] = true

            if Config.Price > 0 then
                message = _U('pull_ahead_fee', Config.Price)
            else
                message = _U('pull_ahead_free')
            end
        else
            isPurchased[locationIndex] = false
            message = _U('not_enough_money')
        end

        ESX.ShowNotification(message)
        Citizen.Wait(5000)
    end)
end

function handlePurchasedLocation(locationIndex)
    local coords = Config.Locations[locationIndex].Exit;
    
    drawCircle(coords, Config.Markers.Exit)

    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true) < 5 then
        isPurchased[locationIndex] = false

        local vehicle = GetVehiclePedIsUsing(PlayerPedId())
	WashDecalsFromVehicle(vehicle)
        SetVehicleDirtLevel(vehicle)

        ESX.ShowNotification(_U('wash_complete'))
        Citizen.Wait(5000)
    end
end

function drawCircle(coords, marker)
    DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, marker.size, marker.size, marker.size, marker.r, marker.g, marker.b, 100, 0, 0, 2, 0, 0, 0, 0)
end
