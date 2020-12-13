

AddRemoteEvent("AssignAnimation", function(ply, key, anim)
    local tbltoinsert = {
        keyid = key,
        animid = anim
    }
    for i, v in ipairs(PlayerData[ply].animations) do
       if v.keyid == key then
          table.remove(PlayerData[ply].animations, i)
          break
       end
    end
    table.insert(PlayerData[ply].animations, tbltoinsert)
    local query = mariadb_prepare(db, "UPDATE accounts SET animations = '?' WHERE accountid = ? LIMIT 1;",
                json_encode(PlayerData[ply].animations),
                PlayerData[ply].accountid
    )
    mariadb_query(db, query)
    --print("Saved Animations")
end)

AddRemoteEvent("PlayAnimationPMENU", function(ply, anim)
    SetPlayerAnimation(ply, anim)
end)

AddRemoteEvent("PlayAnimationKey", function(ply, keyid)
   if PlayerData[ply] then
      for i, v in ipairs(PlayerData[ply].animations) do
         if v.keyid == keyid then
            SetPlayerAnimation(ply, _Animations[v.animid])
            break
         end
      end
   end
end)