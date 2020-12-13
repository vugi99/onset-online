

AddEvent("OnKeyPress", function(key)
    local veh = GetPlayerVehicle(GetPlayerId())
    if veh ~= 0 then
        if GetVehicleDriver(veh) == GetPlayerId() then
           if key == OnlineKeys.OPEN_VEHICLE_HOOD_KEY then
              local hood_ratio = GetVehicleHoodRatio(veh)
              if hood_ratio < 90 then
                 CallRemoteEvent("OnlineHoodRemoteEvent", hood_ratio + 30)
              else
                 AddPlayerChat("Already opened")
              end
           elseif key == OnlineKeys.CLOSE_VEHICLE_HOOD_KEY then
              local hood_ratio = GetVehicleHoodRatio(veh)
              if hood_ratio > 0 then
                 CallRemoteEvent("OnlineHoodRemoteEvent", hood_ratio - 30)
              else
                 AddPlayerChat("Already closed")
              end
            elseif key == OnlineKeys.OPEN_VEHICLE_TRUNK_KEY then
                local trunk_ratio = GetVehicleTrunkRatio(veh)
                if trunk_ratio < 90 then
                   CallRemoteEvent("OnlineTrunkRemoteEvent", trunk_ratio + 30)
                else
                   AddPlayerChat("Already opened")
                end
            elseif key == OnlineKeys.CLOSE_VEHICLE_TRUNK_KEY then
                local trunk_ratio = GetVehicleTrunkRatio(veh)
                if trunk_ratio > 0 then
                   CallRemoteEvent("OnlineTrunkRemoteEvent", trunk_ratio - 30)
                else
                   AddPlayerChat("Already closed")
                end
           end
        end
    end
end)