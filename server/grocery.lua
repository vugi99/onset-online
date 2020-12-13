

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i,v in ipairs(grocery_npcs) do
          local npc = CreateNPC(v[1], v[2], v[3], v[4])
          SetNPCNetworkedClothingPreset(npc, 4)
          AddNPCInDimension(npc, id)
          table.insert(online_invincible_npcs, npc)
          SetNPCPropertyValue(npc, "InHeist", false, true)
          SetNPCPropertyValue(npc, "GroceryID", i, false)
          local text = CreateText3D("Grocery Store", 16, v[1], v[2], v[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddEvent("PlayerDataLoaded", function(ply)
   CallRemoteEvent(ply, "InitEnergyBarsValue", PlayerData[ply].energy_bars)
end)

AddRemoteEvent("BuyEnergyBar", function(ply)
    if (PlayerData[ply].energy_bars < max_energy_bars and Buy(ply, grocery_energy_bar_price)) then
       PlayerData[ply].energy_bars = PlayerData[ply].energy_bars + 1
       CallRemoteEvent(ply, "EnergyBarPurchased", true)
    else
       CallRemoteEvent(ply, "EnergyBarPurchased", false)
    end
end)

AddRemoteEvent("EatEnergyBar", function(ply)
   if PlayerData[ply] then
      PlayerData[ply].energy_bars = PlayerData[ply].energy_bars - 1
      SetPlayerHealth(ply, GetPlayerHealth(ply) + grocery_energy_bar_health_given)
   end
end)