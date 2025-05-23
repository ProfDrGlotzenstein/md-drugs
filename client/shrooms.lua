local shrooms = {}

local function LoadModels(hash)
    hash = GetHashKey(hash)
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000  -- 5-second timeout
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(10)
    end
    if HasModelLoaded(hash) then return true end
end

local function pick(loc)
    if not progressbar(Lang.Shrooms.pick, 4000, 'uncuff') then return end  
    TriggerServerEvent("shrooms:pickupCane", loc)
end

RegisterNetEvent('shrooms:respawnCane', function(loc)
    local v = GlobalState.shrooms[loc]
    local hash = GetHashKey(v.model)
    if not shrooms[loc] then
        shrooms[loc] = CreateObject(hash, v.location, false, true, true)
        Freeze(shrooms[loc], true, v.heading)
        AddSingleModel(shrooms[loc],{ icon = "fas fa-hand", label = Lang.targets.shrooms.pick, action = function() pick(loc) end }, loc )
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetModelAsNoLongerNeeded(GetHashKey('mushroom'))
        for k, v in pairs(shrooms) do
            if DoesEntityExist(v) then
                DeleteEntity(v) SetEntityAsNoLongerNeeded(v)
            end
        end
    end
end)

RegisterNetEvent('shrooms:removeCane', function(loc)
    if DoesEntityExist(shrooms[loc]) then DeleteEntity(shrooms[loc]) end
    shrooms[loc] = nil
end)

RegisterNetEvent("shrooms:init", function()
    for k, v in pairs (GlobalState.shrooms) do
        local hash = GetHashKey(v.model)
        if not HasModelLoaded(hash) then LoadModels(hash) end
        if not v.taken then
            shrooms[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z, false, true, true)
            Freeze(shrooms[k], true, v.heading)
            AddSingleModel(shrooms[k],{ icon = "fas fa-hand", label = Lang.targets.shrooms.pick, action = function() pick(k) end }, k )
        end
    end
end)

RegisterNetEvent('md-drugs:client:takeshrooms', function()
    if not progressbar(Lang.Shrooms.eat, 500, 'eat')  then return end              
    TriggerEvent("evidence:client:SetStatus", "widepupils", 300)
    EcstasyEffect()
end)
