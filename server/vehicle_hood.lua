


AddRemoteEvent("OnlineHoodRemoteEvent", function(ply, ratio)
   if IsValidPlayer(ply) then
      local veh = GetPlayerVehicle(ply)
      if veh ~= 0 then
         SetVehicleHoodRatio(veh, ratio)
      end
   end
end)

AddRemoteEvent("OnlineTrunkRemoteEvent", function(ply, ratio)
    if IsValidPlayer(ply) then
       local veh = GetPlayerVehicle(ply)
       if veh ~= 0 then
          SetVehicleTrunkRatio(veh, ratio)
       end
    end
 end)