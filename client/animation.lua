Animation = {}
Animation.jets = {}

function Animation.InitSpray()
    RequestNamedPtfxAsset(Config.ParticleDictionary)
    while not HasNamedPtfxAssetLoaded(Config.ParticleDictionary) do
        Citizen.Wait(0)
    end
end

function Animation.StartSpray(jetCoords, locationIndex)
    local effects = {}

    for index, jet in pairs(jetCoords) do
        UseParticleFxAssetNextCall(Config.ParticleDictionary)
        effects[index] = StartParticleFxLoopedAtCoord(Config.Particle, jet.x, jet.y, jet.z, jet.xRot, jet.yRot, jet.zRot, 1.0, false, false, false, false)
    end

    Animation.jets[locationIndex] = effects
end

function Animation.StopSpray(locationIndex)
    for _, jet in pairs(Animation.jets[locationIndex]) do
        StopParticleFxLooped(jet, 0)
    end
end