

AddEvent("OnPlayerEnterWater", function()
    if (GetPlayerVehicle(GetPlayerId()) == 0 and not IsInARace) then
       local x, y, z = GetPlayerLocation(GetPlayerId())
       local hittype, hitid, impactX, impactY, impactZ = LineTrace(x, y, 30000, x, y, z - 100)
       if (impactX ~= 0 and impactY ~= 0 and impactZ ~= 0) then
          if ((hittype == 2 and hitid ~= GetPlayerId()) or hittype == 6 or hittype == 5 or hittype == 4 or hittype == 3) then  -- it's not a good idea to put 3 but it's better to put it so the player won't be stuck under the map
             local plyactor = GetPlayerActor(GetPlayerId())
             plyactor:SetActorLocation(FVector(impactX, impactY, impactZ + 100))
          end
       end
    end
end)