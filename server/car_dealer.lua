

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i,v in ipairs(car_dealer_npcs) do
          local npc = CreateNPC(v[1], v[2], v[3], v[4])
          SetNPCNetworkedClothingPreset(npc, 14)
          AddNPCInDimension(npc, id)
          table.insert(online_invincible_npcs, npc)
          local text = CreateText3D("Car Dealer", 16, v[1], v[2], v[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddRemoteEvent("LeaveCarDealer", function(ply)
    AddPlayerInDimension(ply, GetDimensionByName("base"))
end)

AddRemoteEvent("GetGarages", function(ply)
    if PlayerData[ply] then
       local tbl = {}
       for i,v in ipairs(PlayerData[ply].garages) do
          local tblinsert = {}
          tblinsert.id = v.id
          tblinsert.freeslots = table_count(garages[v.id].vehicles) - table_count(v.vehicles)
          if tblinsert.freeslots > 0 then
             table.insert(tbl, tblinsert)
          end
       end
       if table_count(tbl) > 0 then
           local id = CreateDimension("car_dealer", true)
           AddPlayerInDimension(ply, id)
           CallRemoteEvent(ply, "SendGarages", tbl)
       else
           CallRemoteEvent(ply, "CreateNotification", "Car Dealer", "You don't have any garage with free slots", 5000)
       end
    end
end)

AddRemoteEvent("ShowcaseCar", function(ply, car_dealer_id, model)
    local id = GetPlayerDimension(ply)
    for i,v in ipairs(GetDimensionVehicles(id)) do
       DestroyVehicle(v)
    end
    local veh = CreateVehicle(model, car_dealer_showcase[car_dealer_id][1], car_dealer_showcase[car_dealer_id][2], car_dealer_showcase[car_dealer_id][3]-50, car_dealer_showcase[car_dealer_id][4])
    AddVehicleInDimension(veh, id)
end)


AddRemoteEvent("BuyCar", function(ply, garage, model, r, g, b, a)
    local price
    for i,v in ipairs(car_dealer_vehicles) do
       if v[1] == model then
          price = v[2]
       end
    end
    if price then
       if Buy(ply, price) then
           for i,v in ipairs(PlayerData[ply].garages) do
              if v.id == garage then
                 local tbl = {}
                 tbl.model = model
                 tbl.color = {r,g,b,a}
                 tbl.nitro = false
                 tbl.armor = 0
                 table.insert(PlayerData[ply].garages[i].vehicles, tbl)
                 CallRemoteEvent(ply, "CreateNotification", "Car Dealer", "You bought car " .. tostring(model) .. ", the car is in garage " .. tostring(garage), 5000)
              end
           end
       else
          CallRemoteEvent(ply, "CreateNotification", "Car Dealer", "Purchase Failed", 5000)
       end
    else
        CallRemoteEvent(ply, "CreateNotification", "Car Dealer", "Purchase Failed", 5000)
    end
end)