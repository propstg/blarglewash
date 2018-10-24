ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterServerCallback('blarglewash:purchaseWash', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)

    if Config.Price > 0 then
        if xPlayer.getMoney() < Config.Price then
            return callback(false)
        end
        
        xPlayer.removeMoney(Config.Price)
    end

    return callback(true)
end)
