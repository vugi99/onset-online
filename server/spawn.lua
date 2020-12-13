
_ONLINE_SPAWNS_TBL = nil

local file = io.open("packages/" .. GetPackageName() .. "/spawns.json")
if file then
   local contents = file:read("*a")
   _ONLINE_SPAWNS_TBL = json_decode(contents)
   io.close(file)
end


AddRemoteEvent("TeleportSpawn",function(ply, x, y, z)
    if PlayerData[ply] then
        for i,v in ipairs(PlayerData[ply].weapons) do
           SetPlayerWeapon(ply, v.weapid, v.ammo, false, v.slot, false)
        end
     end
    SetPlayerLocation(ply, x, y, z)
    AddPlayerInDimension(ply, GetDimensionByName("base"))
end)

AddRemoteEvent("Spawn_garage", function(ply, garageid)
    if PlayerData[ply] then
       for i,v in ipairs(PlayerData[ply].weapons) do
          SetPlayerWeapon(ply, v.weapid, v.ammo, false, v.slot, false)
       end
       --print(garageid)
       for i, v in ipairs(PlayerData[ply].garages) do
          if v.id == garageid then
             for i2, v2 in ipairs(GetAllPickups()) do
                local x, y, z = GetPickupLocation(v2)
                if (garages[v.id].entrance[1] == x and garages[v.id].entrance[2] == y and garages[v.id].entrance[3] == z) then -- not very good but ...
                   CallEvent("OnPlayerGarageAction", ply, v2)
                   break
                end
             end
             break
          end
       end
    end
end)

AddRemoteEvent("Spawn_house", function(ply, houseid)
   if PlayerData[ply] then
      for i, v in ipairs(PlayerData[ply].weapons) do
         SetPlayerWeapon(ply, v.weapid, v.ammo, false, v.slot, false)
      end
      for i, v in ipairs(PlayerData[ply].houses) do
         if v.id == houseid then
            for i2, v2 in ipairs(GetAllPickups()) do
               local x, y, z = GetPickupLocation(v2)
               if (Appartments[v.id].Entrance[1] == x and Appartments[v.id].Entrance[2] == y and Appartments[v.id].Entrance[3] == z) then -- not very good but ...
                  CallEvent("OnPlayerHouseEntrance", ply, v2, true)
                  break
               end
            end
            break
         end
      end
   end
end)

AddEvent("OnPlayerJoin",function(ply)
    SetPlayerSpawnLocation(ply, spawn_loc[1], spawn_loc[2], spawn_loc[3], spawn_loc[4])
end)

AddEvent("PlayerDataLoaded",function(ply)
    local dimid = CreateDimension("spawndim", true)
    AddPlayerInDimension(ply, dimid)
    if PlayerData[ply].create_chara == 1 then
       CallRemoteEvent(ply,"SpawnUI",0)
    else
       SetPlayerNetworkedClothingPreset(ply, PlayerData[ply].clothes)
       local tbl = {}
       for i, v in ipairs(PlayerData[ply].garages) do
          table.insert(tbl, v.id)
       end
       CallRemoteEvent(ply,"SpawnUI", 1, tbl, PlayerData[ply].houses)
    end
end)

AddEvent("OnPlayerDeath", function(ply, killer)
    if GetDimensionName(GetPlayerDimension(ply)) == "base" then
       local x, y, z = GetPlayerLocation(ply)
       if not _ONLINE_SPAWNS_TBL then
          SetPlayerSpawnLocation(ply, x, y, z + 100, 0.0)
          print("spawns.json not found")
       else
          local nearloc = nil
          local neardist = nil
          for i, v in ipairs(_ONLINE_SPAWNS_TBL) do
             local dist = O_GetDistanceSquared3D(x, y, z, v[1], v[2], v[3])
             if not neardist then
                neardist = dist
                nearloc = {v[1], v[2], v[3], v[4]}
             elseif dist < neardist then
                neardist = dist
                nearloc = {v[1], v[2], v[3], v[4]}
             end
          end
          if neardist then
              SetPlayerSpawnLocation(ply, nearloc[1], nearloc[2], nearloc[3] + 100, nearloc[4])
          else
              print("Error : no neardist")
          end
       end
       CallRemoteEvent(ply, "CreateNotification", "You died", "You lost a bag of money, Press P to enable Passive mode", 5000)
    end
end)

AddCommand("kill", function(ply)
    SetPlayerHealth(ply, 0)
end)