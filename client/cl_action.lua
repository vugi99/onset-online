

local dlt = ImportPackage("debuglinetrace")

AddEvent("OnKeyPress",function(key)
    if (key == OnlineKeys.ACTION_KEY and GetPlayerVehicle(GetPlayerId()) == 0) then
        local x, y, z = GetPlayerLocation(GetPlayerId())
        local fx, fy, fz = GetCameraForwardVector()
        local mult = 30
        --local hittype, hitid, impactX, impactY, impactZ = dlt.Debug_LineTrace(x+fx*mult, y+fy*mult, z+fz*mult,x+fx*mult+fx*action_distance, y+fy*mult+fy*action_distance, z+fz*mult+fz*action_distance, 10)
        local hittype, hitid, impactX, impactY, impactZ = LineTrace(x+fx*mult, y+fy*mult, z+fz*mult,x+fx*mult+fx*action_distance, y+fy*mult+fy*action_distance, z+fz*mult+fz*action_distance)
        --AddPlayerChat(tostring(hittype) .. " " .. tostring(hitid))
        for i,v in ipairs(actions) do
           if hittype == 5 then
              if (hittype == v[1] and GetObjectModel(hitid) == v[2]) then
                 CallEvent(v[3], hittype, hitid, impactX, impactY, impactZ)
              end
            elseif hittype == 4 then
                if (hittype == v[1] and GetNPCPropertyValue(hitid, "NetworkedClothes").clothes == v[2]) then
                    CallEvent(v[3], hittype, hitid, impactX, impactY, impactZ)
                end
            elseif hittype == 3 then
                if (hittype == v[1] and GetVehicleModel(hitid) == v[2]) then
                    CallEvent(v[3], hittype, hitid, impactX, impactY, impactZ)
                end
            end
        end
        if (hittype == 2 and not IsInDuel and hitid ~= GetPlayerId()) then
           CallEvent("OnPlayerActionOnAnotherPlayer", hittype, hitid, impactX, impactY, impactZ)
        end
    end
end)