

function HasInventoryWeapon(ply, weapid)
    if (GetPlayerWeapon(ply, 1) == weapid or GetPlayerWeapon(ply, 2) == weapid or GetPlayerWeapon(ply, 3) == weapid) then
       return true
    end
    return false
end

AddEvent("OnPlayerSpawn", function(ply)
    if PlayerData[ply] then
       for i,v in ipairs(PlayerData[ply].weapons) do
          SetPlayerWeapon(ply, v.weapid, v.ammo, false, v.slot, false)
       end
    end
end)

AddEvent("OnPlayerWeaponShot", function(ply, weap, hittype, hitid, hitX, hitY, hitZ, startX, startY, startZ, normalX, normalY, normalZ, BoneName)
    if weap > 1 then
       if (PlayerData[ply] and GetDimensionName(GetPlayerDimension(ply)) ~= "duel") then
          for i,v in ipairs(PlayerData[ply].weapons) do
             if v.weapid == weap then
                local newammo = clamp(v.ammo,0,v.ammo + 1,-1)
                PlayerData[ply].weapons[i].ammo = newammo
                break
             end
          end
       end
    end
end)