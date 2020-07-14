ESX = nil

local E_KEY = 38
local PURCHASE_MESSAGE = ''
local MARKER_DRAW_DISTANCE = Config.Markers.DrawDistance or 50

local isPurchased = {}

local playerPed = nil
local playerCoords = nil
local playerVehicle = nil
local entranceDistances = {}
local exitDistance = 100

Citizen.CreateThread(function ()
    startGatherInformationLoop()
end)

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    determinePurchaseMessage()
    Markers.StartMarkers()
    Blips.InitBlips()
    Animation.InitSpray()
    startMainLoop()
end)

function startGatherInformationLoop()
    while true do
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)

        if IsPedInAnyVehicle(playerPed, true) then
            playerVehicle = GetVehiclePedIsUsing(playerPed)

            for i = 1, #Config.Locations do
                local washCoords = Config.Locations[i].Entrance
                entranceDistances[i] = GetDistanceBetweenCoords(playerCoords, washCoords.x, washCoords.y, washCoords.z, true)

                if isPurchased[i] then
                    local exitCoords = Config.Locations[i].Exit
                    exitDistance = GetDistanceBetweenCoords(playerCoords, exitCoords.x, exitCoords.y, exitCoords.z, true)
                end
            end
        else
            playerVehicle = nil
        end

        Citizen.Wait(100)
    end
end

function determinePurchaseMessage()
    if Config.Price > 0 then
        PURCHASE_MESSAGE = _U('hint_fee', Config.Price)
    else
        PURCHASE_MESSAGE = _U('hint_free')
    end
end

function startMainLoop()
    while true do
        if playerVehicle ~= nil then
            Markers.ClearMarkers()
            for i = 1, #Config.Locations do
                handleLocation(i)
            end
            Citizen.Wait(15)
        else
            Markers.ClearMarkers()
            Citizen.Wait(1000)
        end
    end
end

function handleLocation(locationIndex)
    if not isPurchased[locationIndex] then
        handleUnpurchasedLocation(locationIndex)
    else
        handlePurchasedLocation(locationIndex)
    end
end

function handleUnpurchasedLocation(locationIndex)
    if entranceDistances[locationIndex] < MARKER_DRAW_DISTANCE then
        Markers.AddMarker(Config.Locations[locationIndex].Entrance, Config.Markers.Entrance)
    end

    if entranceDistances[locationIndex] < Config.Markers.Entrance.size then
        displayPurchaseMessage()
        if IsControlJustPressed(1, E_KEY) then
            purchaseWash(locationIndex)
        end
    end
end

function displayPurchaseMessage()
    SetTextComponentFormat("STRING")
    AddTextComponentString(PURCHASE_MESSAGE)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function purchaseWash(locationIndex)
    ESX.TriggerServerCallback('blarglewash:purchaseWash', function(isPurchaseSuccessful)
        if isPurchaseSuccessful then
            isPurchased[locationIndex] = true

            if Config.Price > 0 then
                ESX.ShowNotification(_U('pull_ahead_fee', Config.Price))
            else
                ESX.ShowNotification(_U('pull_ahead_free'))
            end

            makeCarReadyForWash(playerVehicle)
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

function handlePurchasedLocation(locationIndex)
    local coords = Config.Locations[locationIndex].Exit;
    
    Markers.AddMarker(coords, Config.Markers.Exit)

    if exitDistance < Config.Markers.Exit.size then
        isPurchased[locationIndex] = false

        WashDecalsFromVehicle(playerVehicle, 1.0)
        SetVehicleDirtLevel(playerVehicle)

        ESX.ShowNotification(_U('wash_complete'))
        Markers.ClearMarkers()
        Citizen.Wait(5000)
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
