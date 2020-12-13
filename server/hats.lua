
function LoadPlayerHat(ply)
    if PlayerData[ply] then
        if PlayerData[ply].hat > 0 then
            local hat_obj = GetPlayerPropertyValue(ply, "HatObject")
            if hat_obj then
                ResetObjectDimension(hat_obj)
                DestroyObject(hat_obj)
            end
            local x, y, z = GetPlayerLocation(ply)
            local obj = CreateObject(PlayerData[ply].hat, x, y, z)
            AddObjectInDimension(obj, GetDimensionByName("base"))
            SetObjectAttached(obj, ATTACH_PLAYER, ply, 14.0, 0.0, 0.0, 0.0, 90.0, -90.0, "head")
            SetPlayerPropertyValue(ply, "HatObject", obj, false)
        end
    end
end

AddEvent("PlayerDataLoaded", function(ply)
    LoadPlayerHat(ply)
end)

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(Hats_Stores) do
          local npc = CreateNPC(v[1][1], v[1][2], v[1][3], v[1][4])
          SetNPCNetworkedClothingPreset(npc, 10)
          AddNPCInDimension(npc, id)
          table.insert(online_invincible_npcs, npc)
          local text = CreateText3D("Hats Store", 16, v[1][1], v[1][2], v[1][3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddRemoteEvent("EnterHatsStore", function(ply, storeid)
    if PlayerData[ply] then
        local store = Hats_Stores[storeid]
        local hat_property = GetPlayerPropertyValue(ply, "HatObject")
        if hat_property then
            ResetObjectDimension(hat_property)
            DestroyObject(hat_property)
            SetPlayerPropertyValue(ply, "HatObject", nil, false)
        end
        SetPlayerLocation(ply, store[2][1], store[2][2], store[2][3])
        SetPlayerHeading(ply, store[2][4])
        local dim = CreateDimension("hats_store", true)
        AddPlayerInDimension(ply, dim)
    end
end)

AddRemoteEvent("LeaveHatsStore", function(ply)
    AddPlayerInDimension(ply, GetDimensionByName("base"))
    LoadPlayerHat(ply)
end)

AddRemoteEvent("PreviewHat", function(ply, hatid)
    local dim = GetPlayerDimension(ply)
    if GetDimensionName(dim) == "hats_store" then
        for i, v in ipairs(GetDimensionObjects(dim)) do
            ResetObjectDimension(v)
            DestroyObject(v)
        end
        local x, y, z = GetPlayerLocation(ply)
        local obj = CreateObject(hatid, x, y, z)
        AddObjectInDimension(obj, dim)

        SetObjectAttached(obj, ATTACH_PLAYER, ply, 14.0, 0.0, 0.0, 0.0, 90.0, -90.0, "head")
    end
end)

AddRemoteEvent("BuyHat", function(ply, hatid)
    if PlayerData[ply] then
        if Buy(ply, Hats_Price) then
            PlayerData[ply].hat = hatid
            local query = mariadb_prepare(db, "UPDATE accounts SET hat = ? WHERE accountid = ? LIMIT 1;",
                        PlayerData[ply].hat,
                        PlayerData[ply].accountid
            )

            mariadb_query(db, query)
            CallRemoteEvent(ply, "CreateNotification", "Hats Store", "Hat bought", 5000)
        end
    end
end)

AddEvent("OnPlayerSpawn", function(ply)
    LoadPlayerHat(ply)
end)