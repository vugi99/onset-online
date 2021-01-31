
local zones = {}

function CreateZone(minx, miny, maxx, maxy, z, enter_event, leave_event)
    local x_diff = maxx - minx
    local y_diff = maxy - miny
    local obj = CreateObject(335, minx + (x_diff) / 2, miny + (y_diff) / 2, z + 50, 0, 0, 0, x_diff / 100, y_diff / 100, 3)
    AddObjectInDimension(obj, GetDimensionByName("base"))
    SetObjectPropertyValue(obj, "_Zone", true, true)
    local zone = {
        minx = minx,
        miny = miny,
        maxx = maxx,
        maxy = maxy,
        enter_event = enter_event,
        leave_event = leave_event,
        obj = obj,
    }
    local last = table_last_count(zones)
    zones[last + 1] = zone
    return last + 1
end

function DestroyZone(zoneid)
    if zones[zoneid] then
        local obj = zones[zoneid].obj
        DestroyObject(obj)
        zones[zoneid] = nil
    end
end

local function CheckZones()
    for i, v in ipairs(GetAllPlayers()) do
        if PlayerData[v] then
            if GetPlayerDimension(v) == GetDimensionByName("base") then
                local x, y, z = GetPlayerLocation(v)
                local property = GetPlayerPropertyValue(v, "InZone")
                for i2, v2 in pairs(zones) do
                    if (x > v2.minx and y > v2.miny and x < v2.maxx and y < v2.maxy) then
                        if not property then
                            --print("Entered in zone")
                            SetPlayerPropertyValue(v, "InZone", i2, false)
                            CallEvent(v2.enter_event, v, i2)
                        end
                    elseif property == i2 then
                        --print("Leaved zone")
                        SetPlayerPropertyValue(v, "InZone", nil, false)
                        CallEvent(v2.leave_event, v, i2)
                    end
                end
            end
        end
    end
end

AddEvent("OnPackageStart", function()
    CreateTimer(CheckZones, 500)
end)
