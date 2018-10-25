ESX = nil

local E_KEY = 38
local DICT = "core"

local isPurchased = {}

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    initBlips()
    initSpray()
end)

function initBlips()
    for i = 1, #Config.Locations do
        if Config.Locations[i].ShowBlip then
            local coords = Config.Locations[i].Entrance
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 100)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(_U('carwash_name'))
            EndTextCommandSetBlipName(blip)
        end
    end
end

function initSpray()
    RequestNamedPtfxAsset(DICT)
    while not HasNamedPtfxAssetLoaded(DICT) do
        Citizen.Wait(0)
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

    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true) < Config.Markers.Entrance.size then
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
        if isPurchaseSuccessful then
            isPurchased[locationIndex] = true

            if Config.Price > 0 then
                ESX.ShowNotification(_U('pull_ahead_fee', Config.Price))
            else
                ESX.ShowNotification(_U('pull_ahead_free'))
            end

            playEffects(locationIndex)
        else
            isPurchased[locationIndex] = false
            ESX.ShowNotification(_U('not_enough_money'))
        end

        Citizen.Wait(5000)
    end)
end

function handlePurchasedLocation(locationIndex)
    local coords = Config.Locations[locationIndex].Exit;
    
    drawCircle(coords, Config.Markers.Exit)

    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true) < Config.Markers.Exit.size then
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

function playEffects(locationIndex)
    Citizen.CreateThread(function()
        local jets = Config.Locations[locationIndex].Jets

        local effects = {}
        for i = 1, #jets do
            local jet = jets[i]
            UseParticleFxAssetNextCall(DICT)
            effects[i] = StartParticleFxLoopedAtCoord(Config.Particle, jet.x, jet.y, jet.z, jet.xRot, jet.yRot, jet.zRot, 1.0, false, false, false, false)
        end

        while isPurchased[locationIndex] do
            Citizen.Wait(100)
        end

        for i = 1, #jets do
            StopParticleFxLooped(effects[i], 0)
        end
    end)
end

RegisterCommand('jet', function(source, args, raw)
    Citizen.CreateThread(function()
        UseParticleFxAssetNextCall(DICT)
        local pfx = StartParticleFxLoopedAtCoord(Config.Particle, tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), tonumber(args[5]), tonumber(args[6]), 1.0, false, false, false, false)
        Citizen.Wait(5000)
        StopParticleFxLooped(pfx, 0)
    end)
end, false)
