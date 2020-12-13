

AddRemoteEvent("ClothesPresetSelected",function(ply, id, store)
    local good
    if store then
        good = Buy(ply, clothing_store_price)
    else
        good = true
    end
    if good then
       SetPlayerNetworkedClothingPreset(ply,id)
       PlayerData[ply].clothes = id
       PlayerData[ply].create_chara = 0
       local query = mariadb_prepare(db, "UPDATE accounts SET clothes = ?, create_chara = ? WHERE accountid = ? LIMIT 1;",
                   PlayerData[ply].clothes,
                   PlayerData[ply].create_chara,
				   PlayerData[ply].accountid
       )
       mariadb_query(db, query)
       --print("Saved clothes")
    end
end)

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i,v in ipairs(clothes_npcs) do
          local npc = CreateNPC(v[1], v[2], v[3], v[4])
          SetNPCNetworkedClothingPreset(npc, 3)
          AddNPCInDimension(npc, id)
          table.insert(online_invincible_npcs, npc)
          local text = CreateText3D("Clothing Store", 16, v[1], v[2], v[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)