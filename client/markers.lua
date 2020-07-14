Markers = {}
Markers.markerPositions = {}

function Markers.StartMarkers()
    Citizen.CreateThread(function ()
        while true do
            if Markers.isPaused then
                Citizen.Wait(1000)
            else
                Citizen.Wait(10)
        
                for _, markerPosition in pairs(Markers.markerPositions) do
                    Markers.DrawCircle(markerPosition.coords, markerPosition.markerType)
                end
            end
        end
    end)
end

function Markers.ClearMarkers()
    Markers.markerPositions = {}
end

function Markers.AddMarker(coords, markerType)
    table.insert(Markers.markerPositions, {coords = coords, markerType = markerType})
end

function Markers.DrawCircle(coords, markerType)
    DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, markerType.size, markerType.size, 
        markerType.size, markerType.r, markerType.g, markerType.b, 100, 0, 0, 2, 0, 0, 0, 0)
end
