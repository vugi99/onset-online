

local PlayersInGarage = {}


AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(garages) do
          local obj = CreatePickupTrigger(2, v.entrance[1], v.entrance[2], v.entrance[3], false)
          AddPickupInDimension(obj, id)
          local text = CreateText3D("Garage " .. tostring(i), 16, v.entrance[1], v.entrance[2], v.entrance[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

function GetPlayerGarageId(ply)
   for i,v in ipairs(PlayersInGarage) do
      if v.ply == ply then
         return i, v.garageid
      end
   end
   return false
end

AddEvent("OnPlayerQuit", function(ply)
    local i, garageid = GetPlayerGarageId(ply)
    if i then
       table.remove(PlayersInGarage, i)
    end
end)

AddEvent("OnPlayerGarageAction", function(ply, pickup)
    local garageid
    local x, y, z = GetPickupLocation(pickup)
    for i,v in ipairs(garages) do
       if (v.entrance[1] == x and v.entrance[2] == y and v.entrance[3] == z) then
          garageid = i
       end
    end
    if garageid then
       local owngarage
       for i,v in ipairs(PlayerData[ply].garages) do
          if v.id == garageid then
             owngarage = true
             SetPlayerLocation(ply, garages[garageid].exit[1], garages[garageid].exit[2], garages[garageid].exit[3])
             local id = CreateDimension("garage", true)
             AddPlayerInDimension(ply, id)
             local tbl = {}
             tbl.ply = ply
             tbl.garageid = garageid
             table.insert(PlayersInGarage, tbl)
             local pickup = CreatePickupTrigger(2, garages[garageid].exit[1], garages[garageid].exit[2], garages[garageid].exit[3], false)
             AddPickupInDimension(pickup, id)
             local etext = CreateText3D("Exit", 16, garages[garageid].exit[1], garages[garageid].exit[2], garages[garageid].exit[3] + 100, 0, 0, 0)
             AddText3DInDimension(etext, id)
             local mobj = CreateObject(340, garages[garageid].manage[1], garages[garageid].manage[2], garages[garageid].manage[3] - 50, 0, 0, 0, 1, 1, 2)
             AddObjectInDimension(mobj, id)
             local text = CreateText3D("Manage Vehicles [E]", 16, garages[garageid].manage[1], garages[garageid].manage[2], garages[garageid].manage[3] + 100, 0, 0, 0)
             AddText3DInDimension(text, id)
             for k, v in pairs(v.vehicles) do
                local veh = CreateVehicle(v.model, garages[garageid].vehicles[k][1], garages[garageid].vehicles[k][2], garages[garageid].vehicles[k][3]-50, garages[garageid].vehicles[k][4])
                SetVehicleColor(veh, RGB(v.color[1], v.color[2], v.color[3], v.color[4]))
                EnableVehicleBackfire(veh, true)
                AttachVehicleNitro(veh, v.nitro)
                SetVehiclePropertyValue(veh, "HasNitro", v.nitro, false)
                SetVehiclePropertyValue(veh, "VehArmor", v.armor, false)
                SetVehicleRespawnParams(veh, false)
                --print(HexToRGBA(GetVehicleColor(veh)))
                AddVehicleInDimension(veh, id)
             end
          end
       end
       if not owngarage then
          if HasEnoughMoney(ply, garages[garageid].price) then
             CallRemoteEvent(ply, "BuyGarageUI", garageid)
          else
             CallRemoteEvent(ply, "CreateNotification", "Garage", "You need " .. tostring(garages[garageid].price) .. "$ to buy this garage", 5000)
          end
       end
    else
        for i,v in ipairs(garages) do
            if (v.exit[1] == x and v.exit[2] == y and v.exit[3] == z) then
               garageid = i
            end
         end
         if garageid then
             SetPlayerLocation(ply, garages[garageid].entrance[1], garages[garageid].entrance[2], garages[garageid].entrance[3])
             AddPlayerInDimension(ply, GetDimensionByName("base"))
             table.remove(PlayersInGarage, GetPlayerGarageId(ply))
         else
             print("Error : Can't determine GarageAction Garage")
         end
    end
end)

AddRemoteEvent("BuyGarage", function(ply, garageid)
   if Buy(ply, garages[garageid].price) then
       local tbl = {}
       tbl.id = garageid
       tbl.vehicles = {}
       table.insert(PlayerData[ply].garages, tbl)
       CallRemoteEvent(ply, "CreateNotification", "Garage", "You bought this garage", 5000)
   else
      CallRemoteEvent(ply, "CreateNotification", "Garage", "You can't buy this garage", 5000)
   end
end)

AddEvent("OnPlayerEnterVehicle", function(ply, veh, seat)
    if GetDimensionName(GetPlayerDimension(ply)) == "garage" then
       local i, garageid = GetPlayerGarageId(ply)
       AddVehicleInDimension(veh, GetDimensionByName("base"))
       SetVehiclePropertyValue(veh, "FromGarage", garageid, false)
       SetVehicleLocation(veh, garages[garageid].vexit[1], garages[garageid].vexit[2], garages[garageid].vexit[3])
       SetVehicleRotation(veh, 0, garages[garageid].vexit[4], 0)
       AddPlayerInDimension(ply, GetDimensionByName("base"))
       SetPlayerInVehicle(ply, veh, 1)
       SetPlayerStoredVehicle(ply, veh)
       table.remove(PlayersInGarage, i)
    end
end)

AddRemoteEvent("SellVehicle", function(ply, veh)
    if (IsValidPlayer(ply) and IsValidVehicle(veh)) then
       local index, garageid = GetPlayerGarageId(ply)
       if index then
          if PlayerData[ply] then
             if PlayerData[ply].garages[garageid] then
                local price
                for i, v in ipairs(car_dealer_vehicles) do
                   if v[1] == GetVehicleModel(veh) then
                      price = math.floor(v[2]*sell_vehicle_percentage/100)
                   end
                end
                if price then
                   for i, v in ipairs(PlayerData[ply].garages[garageid].vehicles) do
                      if v.model == GetVehicleModel(veh) then
                         local r, g, b, a = HexToRGBA(GetVehicleColor(veh))
                         if (v.color[1] == r and v.color[2] == g and v.color[3] == b and v.color[4] == a and v.nitro == GetVehiclePropertyValue(veh, "HasNitro") and v.armor == GetVehiclePropertyValue(veh, "VehArmor")) then
                            DestroyVehicle(veh)
                            table.remove(PlayerData[ply].garages[garageid].vehicles, i)
                            Sell(ply, price)
                            CallRemoteEvent(ply, "CreateNotification", "Garage", "You sold the vehicle for " .. tostring(price) .. "$", 5000)
                            break
                         end
                      end
                   end
                end
             end
          end
       end
    end
end)

AddRemoteEvent("GetGaragesMove", function(ply)
   if IsValidPlayer(ply) then
      local index, garageid = GetPlayerGarageId(ply)
      if (index and PlayerData[ply]) then
          local tbl = {}
          for i,v in ipairs(PlayerData[ply].garages) do
             if v.id ~= garageid then
                local tblinsert = {}
                tblinsert.id = v.id
                tblinsert.freeslots = table_count(garages[v.id].vehicles) - table_count(v.vehicles)
                if tblinsert.freeslots > 0 then
                   table.insert(tbl, tblinsert)
                end
             end
          end
          if table_count(tbl) > 0 then
             CallRemoteEvent(ply,"SendGaragesMove", tbl)
          else
             CallRemoteEvent(ply,"SendGaragesMove", false)
          end
      else
          CallRemoteEvent(ply,"SendGaragesMove", false)
      end
   end
end)

AddRemoteEvent("MoveGarageVehicle", function(ply, veh, movegarageid)
   if (IsValidPlayer(ply) and IsValidVehicle(veh)) then
      local index, garageid = GetPlayerGarageId(ply)
      if index then
         if PlayerData[ply] then
            local movegarageid2
            for i,v in ipairs(PlayerData[ply].garages) do 
               if v.id == movegarageid then
                  movegarageid2 = i
               end
            end
            if (PlayerData[ply].garages[garageid] and movegarageid2) then
               local vehicletbl
               for i, v in ipairs(PlayerData[ply].garages[garageid].vehicles) do
                  if v.model == GetVehicleModel(veh) then
                     local r, g, b, a = HexToRGBA(GetVehicleColor(veh))
                     if (v.color[1] == r and v.color[2] == g and v.color[3] == b and v.color[4] == a and v.nitro == GetVehiclePropertyValue(veh, "HasNitro") and v.armor == GetVehiclePropertyValue(veh, "VehArmor")) then
                        vehicletbl = v
                        DestroyVehicle(veh)
                        table.remove(PlayerData[ply].garages[garageid].vehicles, i)
                        break
                     end
                  end
               end
               if vehicletbl then
                   table.insert(PlayerData[ply].garages[movegarageid2].vehicles, vehicletbl)
                   CallRemoteEvent(ply, "CreateNotification", "Garage", "Moved vehicle " .. tostring(vehicletbl.model) .. " to garage " .. tostring(movegarageid), 5000)
               else
                   print("Error : Can't find vehicle to move")
               end
            end
         end
      end
   end
end)