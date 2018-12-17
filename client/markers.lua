Markers = {}
Markers.markerPositions = {}

function Markers.StartMarkers()
    Markers.ResetMarkers()

    Citizen.CreateThread(function ()
        while true do
            Citizen.Wait(10)
    
            for _, markerPosition in pairs(markerPositions) do
                drawCircle(table.unpack(markerPosition))
            end
        end
    end)
end

function Marker.SetMarker(coords, markerType)
    markerPositions = { {coords = coords, markerType = markerType} }
end

function Markers.ResetMarkers()
    for _, location in pairs(Config.Locations) do
        table.insert(markerPositions, {coords = location.Entrance, markerType = Config.Markers.Entrance})
    end
end

function Markers.DrawCircle(coords, markerType)
    DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, markerType.size, markerType.size, 
        markerType.size, markerType.r, markerType.g, markerType.b, 100, 0, 0, 2, 0, 0, 0, 0)
end