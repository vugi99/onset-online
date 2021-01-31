
local z_removed_for_weap = 75

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i,v in ipairs(weapons_shops) do
          local npc = CreateNPC(v[1], v[2], v[3], v[4])
          SetNPCNetworkedClothingPreset(npc, 25)
          AddNPCInDimension(npc, id)
          table.insert(online_invincible_npcs, npc)
          local text = CreateText3D("Gun Store", 16, v[1], v[2], v[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddRemoteEvent("ActivateWeaponShop", function(ply, npc)
    local x, y, z = GetNPCLocation(npc)
    local weapon_shop_id
    for i,v in ipairs(weapons_shops) do
       if (v[1] == x and v[2] == y and v[3] == z) then
          weapon_shop_id = i
       end
    end
    if weapon_shop_id then
       local id = CreateDimension("weapon_shop", true)
       AddPlayerInDimension(ply, id)
       --[[local shop_weapons_index
       if HasInventoryWeapon(ply, weapons_shops_weapons[1][1]) then
           if HasInventoryWeapon(ply, weapons_shops_weapons[2][1]) then
                if HasInventoryWeapon(ply, weapons_shops_weapons[3][1]) then
                    print("Error : Can't determine what weapon to spawn for weapon_shop")
                else
                   shop_weapons_index = 3
                end
           else
              shop_weapons_index = 2
           end
       else
          shop_weapons_index = 1
       end
       local obj = CreateObject(weapons_shops_weapons[shop_weapons_index][2], weapons_shops[weapon_shop_id][5], weapons_shops[weapon_shop_id][6], weapons_shops[weapon_shop_id][7] - z_removed_for_weap, weapons_shops[weapon_shop_id][8], weapons_shops[weapon_shop_id][9], weapons_shops[weapon_shop_id][10])
       AddObjectInDimension(obj, id)]]--
       CallRemoteEvent(ply, "WeaponShopActivated", weapon_shop_id)
    else
        print("Error : Can't find weapon shop id")
    end
end)

AddRemoteEvent("LeaveWeaponShop", function(ply)
    AddPlayerInDimension(ply, GetDimensionByName("base"))
end)

AddRemoteEvent("ShowcaseWeapon", function(ply, weapon_shop_id, weapid)
    local id = GetPlayerDimension(ply)
    for i,v in ipairs(GetDimensionObjects(id)) do
       DestroyObject(v)
    end

    for i,v in ipairs(weapons_shops_weapons) do
       if v[1] == weapid then
          local obj = CreateObject(v[2], weapons_shops[weapon_shop_id][5], weapons_shops[weapon_shop_id][6], weapons_shops[weapon_shop_id][7] - z_removed_for_weap, weapons_shops[weapon_shop_id][8], weapons_shops[weapon_shop_id][9], weapons_shops[weapon_shop_id][10])
          AddObjectInDimension(obj, id)
       end
    end
end)

AddRemoteEvent("BuyWeapon", function(ply, weapid, slot)
    if PlayerData[ply] then
       local price
       local ammo
       for i, v in ipairs(weapons_shops_weapons) do
          if v[1] == weapid then
             price = v[3]
             ammo = v[4]
             break
          end
       end
       if price then
            if Buy(ply, price) then
                for i, v in ipairs(PlayerData[ply].weapons) do
                    if v.slot == slot then
                        table.remove(PlayerData[ply].weapons, i)
                        break
                    end
                end
                local tbl = {}
                tbl.slot = slot
                tbl.weapid = weapid
                tbl.ammo = ammo
                table.insert(PlayerData[ply].weapons, tbl)
                local id = GetPlayerDimension(ply)
                for i,v in ipairs(GetDimensionObjects(id)) do
                   DestroyObject(v)
                end
                SetPlayerWeapon(ply, weapid, ammo, false, slot, false)
                CallRemoteEvent(ply, "BuyWeaponResponse", true, weapid)
                --CallRemoteEvent(ply, "CreateNotification", "Gun Store", "You bought weapon " .. tostring(weapid), 5000)
            else
                CallRemoteEvent(ply, "BuyWeaponResponse", false)
                --CallRemoteEvent(ply, "CreateNotification", "Gun Store", "You don't have enough money to buy this weapon", 5000)
            end
       else
          CallRemoteEvent(ply, "BuyWeaponResponse", false)
          print("Error : can't get the price of the weapon")
       end
    end
end)

AddRemoteEvent("BuyAmmo", function(ply, weapid, ammo, destroyShowcase)
    if PlayerData[ply] then
       local index
       for i,v in ipairs(PlayerData[ply].weapons) do
          if v.weapid == weapid then
             index = i
          end
       end
       if index then
           local price_for_1_bullet
           for i,v in ipairs(weapons_shops_weapons) do
              if v[1] == weapid then
                 price_for_1_bullet = v[5]
              end
           end
           if price_for_1_bullet then
              if Buy(ply, ammo * price_for_1_bullet) then
                 if destroyShowcase then
                     local id = GetPlayerDimension(ply)
                     for i,v in ipairs(GetDimensionObjects(id)) do
                        DestroyObject(v)
                     end
                 end
                 PlayerData[ply].weapons[index].ammo = clamp(PlayerData[ply].weapons[index].ammo,0,max_weapon_ammo,ammo)
                 SetPlayerWeapon(ply, weapid, PlayerData[ply].weapons[index].ammo, false, PlayerData[ply].weapons[index].slot, false)
                 CallRemoteEvent(ply, "AmmoBought")
              else
                  print("Error : player don't have enough money to buy ammo ? But he should have enough money...")
              end
           else
              print("Error : Can't find price_for_1_bullet to buy ammo")
           end
       else
           print("Error : Can't find player weapon to buy ammo")
       end
    end
end)

AddRemoteEvent("BuyArmor", function(ply)
    if Buy(ply, armor_cost) then
       SetPlayerArmor(ply, 100)
       CallRemoteEvent(ply, "CreateNotification", "Gun Store", "You bought Armor", 5000)
    end
end)