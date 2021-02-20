
function ResetPlayerBody(ply)
    SetPlayerNetworkedCustomClothes(ply,{
        body = {"/Game/CharacterModels/SkeletalMesh/BodyMerged/HZN_CH3D_Normal01_LPR"},
        clothing0 = {nil},
        clothing1 = {nil},
        clothing2 = {nil},
        clothing3 = {nil},
        clothing4 = {nil},
        clothing5 = {nil},
        clothing6 = {nil},
        clothing7 = {nil},
        clothing8 = {nil},
        clothing9 = {nil}
     })
end

function OnlineSetClothes(ply, clothes)
    ResetPlayerBody(ply)
    if clothes.type == "preset" then
        SetPlayerNetworkedClothingPreset(ply, clothes.clothes)
    elseif clothes.type == "advanced_preset" then
        SetPlayerNetworkedCustomClothes(ply, clothes.clothes, nil, clothes.gender)
    elseif clothes.type == "custom" then
        SetPlayerNetworkedCustomClothes(ply, clothes.clothes, clothes.ids, clothes.gender)
    end
end



AddRemoteEvent("ClothesSelected",function(ply, clothes, store)
    local good
    if store then
        good = Buy(ply, clothing_store_price)
    else
        good = true
    end
    if good then
       OnlineSetClothes(ply, clothes)
       PlayerData[ply].clothes = clothes
       PlayerData[ply].create_chara = 0
       local query = mariadb_prepare(db, "UPDATE accounts SET clothes = '?', create_chara = ? WHERE accountid = ? LIMIT 1;",
                   json_encode(PlayerData[ply].clothes),
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