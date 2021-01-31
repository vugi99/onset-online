
local Waiting_All_spe_vehs = {}

function IsWaitingSpecialVehicle(veh)
   for i, v in ipairs(Waiting_All_spe_vehs) do
      if veh == v then
         return i
      end
   end
   return false
end

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(specials_vehicles_stores) do
          local npc = CreateNPC(v.npc[1], v.npc[2], v.npc[3], v.npc[4])
          SetNPCNetworkedClothingPreset(npc, 26)
          AddNPCInDimension(npc, id)
          table.insert(online_invincible_npcs, npc)
          local text = CreateText3D("Special Vehicles", 16, v.npc[1], v.npc[2], v.npc[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddRemoteEvent("GetSpecialVehicles", function(ply, npc)
    if (PlayerData[ply] and IsValidNPC(npc)) then
       local stid
       local x, y, z = GetNPCLocation(npc)
       for i, v in ipairs(specials_vehicles_stores) do
          if (v.npc[1] == x and v.npc[2] == y) then
             stid = i
             break
          end
       end
       if stid then
          local dim = CreateDimension("special_store", true)
          AddPlayerInDimension(ply, dim)
          CallRemoteEvent(ply, "ReceiveSpecialVehicles", PlayerData[ply].special_vehicles, stid)
       else
          print("Error : can't find stid")
       end
    end
end)

AddRemoteEvent("LeaveSpecialUI", function(ply)
    AddPlayerInDimension(ply, GetDimensionByName("base"))
end)

AddRemoteEvent("ShowSpecialVehicle", function(ply, model, stid)
    local dim = GetPlayerDimension(ply)
    for i, v in ipairs(GetDimensionVehicles(dim)) do
       DestroyVehicle(v)
    end
    local veh = CreateVehicle(model, specials_vehicles_stores[stid].vehicle_show_pos[1], specials_vehicles_stores[stid].vehicle_show_pos[2], specials_vehicles_stores[stid].vehicle_show_pos[3] - 50, specials_vehicles_stores[stid].vehicle_show_rot)
    SetVehicleRespawnParams(veh, false)
    AddVehicleInDimension(veh, dim)
end)

AddRemoteEvent("ShowSpecialVehicleSpawn", function(ply, index, stid)
    if PlayerData[ply] then
        local dim = GetPlayerDimension(ply)
        for i, v in ipairs(GetDimensionVehicles(dim)) do
            DestroyVehicle(v)
        end
        local veh = CreateVehicle(PlayerData[ply].special_vehicles[index].model, specials_vehicles_stores[stid].vehicle_show_pos[1], specials_vehicles_stores[stid].vehicle_show_pos[2], specials_vehicles_stores[stid].vehicle_show_pos[3] - 50, specials_vehicles_stores[stid].vehicle_show_rot)
        SetVehicleColor(veh, RGB(PlayerData[ply].special_vehicles[index].color[1], PlayerData[ply].special_vehicles[index].color[2], PlayerData[ply].special_vehicles[index].color[3], PlayerData[ply].special_vehicles[index].color[4]))
        SetVehicleRespawnParams(veh, false)
        AddVehicleInDimension(veh, dim)
    end
end)

AddRemoteEvent("BuySpecialVehicle", function(ply, vehselected, r, g, b, a)
    local spe_veh_id
    for i, v in ipairs(special_vehicles) do
       if vehselected == v[1] then
          spe_veh_id = i
       end
    end
    if spe_veh_id then
        if Buy(ply, special_vehicles[spe_veh_id][2]) then
           local tbl = {
              model = vehselected,
              color = {r, g, b, a}
           }
           table.insert(PlayerData[ply].special_vehicles, tbl)
           local query = mariadb_prepare(db, "UPDATE accounts SET special_vehicles = '?' WHERE accountid = ? LIMIT 1;",
                json_encode(PlayerData[ply].special_vehicles),
                PlayerData[ply].accountid
            )
            mariadb_query(db, query)
            print("Saved Special Vehicles")
            AddPlayerInDimension(ply, GetDimensionByName("base"))
            CallRemoteEvent(ply, "CreateNotification", "Special Vehicles", "You bought vehicle " .. tostring(vehselected) .. " for " .. tostring(special_vehicles[spe_veh_id][2]) .. "$", 5000)
        end
    else
        print("Error : Can't find spe_veh_id")
    end
end)

AddRemoteEvent("SpawnSpecialVehicle", function(ply, stid)
    if PlayerData[ply] then
       local good_to_spawn = true
       local veh = GetDimensionVehicles(GetPlayerDimension(ply))[1]
       --[[print("vv " .. tostring(veh))
       print(IsValidVehicle(veh))
       for i, v in ipairs(GetDimensionVehicles(GetPlayerDimension(ply))) do
          print("gdv " .. tostring(v))
       end]]--
       if (not veh or not IsValidVehicle(veh)) then
          good_to_spawn = false
       else
           local stx, sty, stz = specials_vehicles_stores[stid].vehicle_show_pos[1], specials_vehicles_stores[stid].vehicle_show_pos[2], specials_vehicles_stores[stid].vehicle_show_pos[3]
           for i, v in ipairs(GetAllVehicles()) do
              if GetVehicleDimension(v) == GetDimensionByName("base") then
                 local x, y, z = GetVehicleLocation(v)
                 --print(tostring(v) .. " " .. tostring(O_GetDistanceSquared3D(stx, sty, stz, x, y, z)))
                 if O_GetDistanceSquared3D(stx, sty, stz, x, y, z) <= special_vehicles_spawn_higher_distance3d_considered_as_same_loc^2 then
                    if v ~= GetPlayerStoredSpecialVehicle(ply) then
                       good_to_spawn = false
                       break
                    end
                 end
              end
           end
       end
       if good_to_spawn then
           SetPlayerStoredSpecialVehicle(ply, veh)
           AddVehicleInDimension(veh, GetDimensionByName("base"))
           AddPlayerInDimension(ply, GetDimensionByName("base"))
           table.insert(Waiting_All_spe_vehs, veh)
           CallRemoteEvent(ply, "SpecialVehicleSpawnConfirmation", true)
           Delay(special_vehicles_spawn_destroy_after_s_if_is_on_the_same_loc * 1000, function()
               local windex = IsWaitingSpecialVehicle(veh)
               if windex then
                  local stx, sty, stz = specials_vehicles_stores[stid].vehicle_show_pos[1], specials_vehicles_stores[stid].vehicle_show_pos[2], specials_vehicles_stores[stid].vehicle_show_pos[3]
                  local x, y, z = GetVehicleLocation(veh)
                  if (O_GetDistanceSquared3D(stx, sty, stz, x, y, z) <= special_vehicles_spawn_higher_distance3d_considered_as_same_loc^2) then
                     --print("ResetPlayerStoredSpecialVehicle, after delay")
                     ResetPlayerStoredSpecialVehicle(ply)
                  else
                     table.remove(Waiting_All_spe_vehs, windex)
                  end
               end
           end)
       else
           CallRemoteEvent(ply, "SpecialVehicleSpawnConfirmation", false)
       end
    end
end)

AddEvent("OnVehicleDestroyed", function(veh)
    local windex = IsWaitingSpecialVehicle(veh)
    if windex then
       table.remove(Waiting_All_spe_vehs, windex)
    end
end)