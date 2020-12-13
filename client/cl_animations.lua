

AddEvent("OnKeyPress", function(key)
   if (GetPlayerVehicle(GetPlayerId()) == 0 and not IsInPlayerMenuUI and not IsInSpawnUI) then
      if (key == "Ampersand" or key == OnlineKeys.RESET_ANIMATION_KEY) then
         CallRemoteEvent("PlayAnimationPMENU", "STOP")
      else
          local keyid
          for i, v in ipairs(AnimationsKeys) do
             if (v[1] == key or v[2] == key) then
                keyid = i
                break
             end
          end
          if keyid then
             CallRemoteEvent("PlayAnimationKey", keyid)
          end
      end
   end
end)