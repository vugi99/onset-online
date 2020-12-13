
online_invincible_npcs = {}


AddEvent("OnPlayerWeaponShot", function(ply, weapon, hittype, hitid, hitX, hitY, hitZ, startX, startY, startZ, normalX, normalY, normalZ, BoneName)
    if hittype == 4 then
      for i, v in ipairs(online_invincible_npcs) do
         if hitid == v then
            return false
         end
      end
   end
end)