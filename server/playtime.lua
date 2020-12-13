

AddEvent("PlayerDataLoaded", function(ply)
    CallRemoteEvent(ply, "InitPlaytime", PlayerData[ply].playtime)
end)

function UpdatePlayTimeOfPlayers()
   for i, v in ipairs(GetAllPlayers()) do
      if PlayerData[v] then
         PlayerData[v].playtime = PlayerData[v].playtime + 10
      end
   end
end

AddEvent("OnPackageStart", function()
    CreateTimer(UpdatePlayTimeOfPlayers, 10000)
end)