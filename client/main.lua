ESX = nil

local E_KEY = 38
local isPurchased = {}

Citizen.CreateThread(function init()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    initBlips()
end)

function initBlips()
    for i = 1, #Config.Locations do
        local coords = Config.Locations[i]
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

        if isPedSittingInAnyVehicle(PlayerPedId()) then
            for i = 1, #Config.Locations do
                handleLocation(Config.Locations[i])
            end
        else
            Citizen.Wait(500)
        end
    end
end)

function handleLocation(locationIndex)
    if isPurchased(locationIndex) then
        handlePurchasedLocation(locationIndex)
    else
        handleUnpurchasedLocation(locationIndex)
    end
end

function handleUnpurchasedLocation(locationIndex)
    local coords = Config.Locations[i].Entrance;
    
    drawCircle(coords, Config.Markers.Entrance)

    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true) < 5 then
        if Config.Price > 0 then
            ESX.ShowHelpNotificiation(_U('hint_fee', Config.Price))
        else
            ESX.ShowHelpNotificiation(_U('hint_free'))
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
                message = _U('pull_ahead_fee')
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
    local coords = Config.Locations[i].Exit;
    
    drawCircle(coordsm, Config.Markers.Exit)

    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true) < 5 then
        isPurchased[locationIndex] = false

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        SetVehicleDirtLevel(vehicle, 0.0000000001)
        SetVehicleUndriveable(vehicle, false)
        ESX.ShowNotification(_U('wash_complete'))
        Citizen.Wait(5000)
    end
end

function drawCircle(coords, marker)
    DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, marker.size, marker.size, marker.size, marker.r, marker.g, marker.b, 100, false, true, 2, false, false, false, false)
end



-- for each location
--      if not paid, show the green circle
--      if paid, show the red circle

--      if in red circle
--          set paid to nil 
--          clean car
--          show message

--      if in green cirlce
--          if 0 price, 
--              show free buy message
--          else 
--              show fee buy message

--          if purchase button pressed
--              call server to see if user can afford
--              if can afford, 
--                  show appropriate pull ahead message
--                  set paid (loop should pick up the circle change)
--              else, show can't afford message