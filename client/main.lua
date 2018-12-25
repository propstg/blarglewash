ESX = nil

local E_KEY = 38
local isPurchased = {}

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    Markers.StartMarkers()
    Blips.InitBlips()
    Animation.InitSpray()
    startMainLoop()
end)

function startMainLoop()
    while true do
        Citizen.Wait(10)

        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, true) then
            for i = 1, #Config.Locations do
                handleLocation(i, playerPed)
            end
        else
            Citizen.Wait(1000)
        end
    end
end

function handleLocation(locationIndex, playerPed)
    local vehicle = GetVehiclePedIsUsing(playerPed)

    if not isPurchased[locationIndex] then
        handleUnpurchasedLocation(locationIndex, playerPed, vehicle)
    else
        handlePurchasedLocation(locationIndex, playerPed, vehicle)
    end
end

function handleUnpurchasedLocation(locationIndex, playerPed, vehicle)
    local coords = Config.Locations[locationIndex].Entrance;

    if GetDistanceBetweenCoords(GetEntityCoords(playerPed), coords.x, coords.y, coords.z, true) < Config.Markers.Entrance.size then
        if Config.Price > 0 then
            ESX.ShowHelpNotification(_U('hint_fee', Config.Price))
        else
            ESX.ShowHelpNotification(_U('hint_free'))
        end

        if IsControlJustPressed(1, E_KEY) then
            purchaseWash(locationIndex, vehicle)
        end
    end
end

function purchaseWash(locationIndex, vehicle)
    ESX.TriggerServerCallback('blarglewash:purchaseWash', function(isPurchaseSuccessful)
        if isPurchaseSuccessful then
            isPurchased[locationIndex] = true

            if Config.Price > 0 then
                ESX.ShowNotification(_U('pull_ahead_fee', Config.Price))
            else
                ESX.ShowNotification(_U('pull_ahead_free'))
            end

            makeCarReadyForWash(vehicle)
            playEffectsAsync(locationIndex)
        else
            isPurchased[locationIndex] = false
            ESX.ShowNotification(_U('not_enough_money'))
        end

        Citizen.Wait(5000)
    end)
end

function makeCarReadyForWash(vehicle)
    rollWindowsUp(vehicle)
    putConvertibleTopUpIfNeeded(vehicle)
end

function rollWindowsUp(vehicle)
    for i = 0, 3 do
        RollUpWindow(vehicle, i)
    end
end

function putConvertibleTopUpIfNeeded(vehicle)
    if IsVehicleAConvertible(vehicle, true) then
        RaiseConvertibleRoof(vehicle, false)
    end
end

function handlePurchasedLocation(locationIndex, playerPed, vehicle)
    local coords = Config.Locations[locationIndex].Exit;
    
    Markers.SetMarker(coords, Config.Markers.Exit)

    if GetDistanceBetweenCoords(GetEntityCoords(playerPed), coords.x, coords.y, coords.z, true) < Config.Markers.Exit.size then
        isPurchased[locationIndex] = false

        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleDirtLevel(vehicle)

        ESX.ShowNotification(_U('wash_complete'))
        Citizen.Wait(5000)
        Markers.ResetMarkers()
    end
end

function playEffectsAsync(locationIndex)
    Citizen.CreateThread(function()
        Animation.StartSpray(Config.Locations[locationIndex].Jets, locationIndex)

        while isPurchased[locationIndex] do
            Citizen.Wait(100)
        end

        Animation.StopSpray(locationIndex)
    end)
end
