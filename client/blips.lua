Blips = {}

function Blips.InitBlips()
    for _, coords in pairs(Config.Locations) do
        if coords.ShowBlip then
            local coords = coords.Entrance
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 100)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(_U('carwash_name'))
            EndTextCommandSetBlipName(blip)
        end
    end
end
