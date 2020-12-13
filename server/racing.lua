
Racing_lobbies = {}

function IsInRacingLobby(ply)
   for i,v in ipairs(Racing_lobbies) do
      for i2,v2 in ipairs(v.players) do
         if v2.ply == ply then
            return true
         end
      end
   end
   return false
end

function CreateRacingLobby(race_id)
   local id = CreateDimension("racing", true)
   local tbl = {}
   tbl.id = id
   tbl.inrace = false
   tbl.host = nil
   tbl.players = {}
   tbl.raceid = race_id
   table.insert(Racing_lobbies, tbl)
   return id
end

function LaunchLobbyRace(id)
   for i,v in ipairs(Racing_lobbies) do
      if v.id == id then
         Racing_lobbies[i].inrace = true
         for i2,v2 in ipairs(v.players) do
            if v2.ply ~= v.host then
               CallRemoteEvent(v2.ply, "LobbyLeft", true)
            end
            SetPlayerRespawnTime(v2.ply, 500)
            changerace(id, v.raceid)
         end
      end
   end
end

function AddPlayerInLobby(ply, id)
    local good = false
    for i,v in ipairs(Racing_lobbies) do
        if v.id == id then
           if table_count(v.players) == 0 then
              Racing_lobbies[i].host = ply
           end
           if (table_count(v.players) < 16 and not v.inrace) then
               local tbl = {}
               tbl.ply = ply
               tbl.name = GetPlayerName(ply)
               table.insert(Racing_lobbies[i].players, tbl)
               AddPlayerInDimension(ply, id)
               local x, y, z = GetPlayerLocation(ply)
               SetPlayerPropertyValue(ply, "LastLocBeforeRacing", {x, y, z}, false)
               CallRemoteEvent(ply, "JoinLobbyResponse", Racing_lobbies[i])
               good = true
               for i2, v2 in ipairs(Racing_lobbies[i].players) do
                  if v2.ply ~= ply then
                     CallRemoteEvent(v2.ply, "PlayerJoinedLobby", Racing_lobbies[i].players[table_count(Racing_lobbies[i].players)])
                  end
               end
           end
        end
     end
     if not good then
        CallRemoteEvent(ply, "JoinLobbyResponse", false)
     end
end

function RemovePlayerFromRacingLobby(ply, leave)
    for i,v in ipairs(Racing_lobbies) do
        for i2,v2 in ipairs(v.players) do
           if v2.ply == ply then
              if not leave then
                  AddPlayerInDimension(ply, GetDimensionByName("base"))
                  local loc = GetPlayerPropertyValue(ply, "LastLocBeforeRacing")
                  if loc then
                     SetPlayerLocation(ply, loc[1], loc[2], loc[3])
                     SetPlayerPropertyValue(ply, "LastLocBeforeRacing", nil, false)
                  end
              end
              if v.inrace then
                 CallEvent("OnPlayerQuitRacing", ply, v.id, leave)
              end
              if v.host == ply then
                 if not v.inrace then
                    if IsValidDimension(v.id) then
                       DestroyDimension(v.id)
                        --[[for i,v in ipairs(Racing_lobbies[i].players) do
                           if v.ply ~= ply then
                              AddPlayerInDimension(v.ply, GetDimensionByName("base"))
                              CallRemoteEvent(v.ply, "LobbyLeft")
                              local loc = GetPlayerPropertyValue(v.ply, "LastLocBeforeRacing")
                              if loc then
                                 SetPlayerLocation(v.ply, loc[1], loc[2], loc[3])
                                 SetPlayerPropertyValue(v.ply, "LastLocBeforeRacing", nil, false)
                              end
                           end
                        end]]--
                    end
                    -- Dimension is already destroyed or will be destroyed so only set nil to the host if they are in a race
                 else
                    if IsValidDimension(v.id) then
                       Racing_lobbies[i].host = nil
                    end
                 end
              else
                 if not v.inrace then
                    for i,v in ipairs(Racing_lobbies[i].players) do
                        if v.ply ~= ply then
                           CallRemoteEvent(v.ply, "PlayerLeftLobby", ply)
                        end
                     end
                  end
              end
              if IsValidDimension(v.id) then
                 table.remove(Racing_lobbies[i].players, i2)
              end
           end
        end
     end
end

AddEvent("OnPlayerQuit", function(ply)
    RemovePlayerFromRacingLobby(ply, true)
end)

AddEvent("OnDimensionDestroyed", function(id, name)
    if name == "racing" then
       for i,v in ipairs(Racing_lobbies) do
          if v.id == id then
             for i2,v2 in ipairs(Racing_lobbies[i].players) do
                if IsValidPlayer(v2.ply) then
                     if v.inrace then
                        CallEvent("OnPlayerQuitRacing", v2.ply, id)
                     else
                        CallRemoteEvent(v2.ply, "LobbyLeft")
                     end
                     local loc = GetPlayerPropertyValue(v2.ply, "LastLocBeforeRacing")
                     if loc then
                        SetPlayerLocation(v2.ply, loc[1], loc[2], loc[3])
                        SetPlayerPropertyValue(v2.ply, "LastLocBeforeRacing", nil, false)
                     end
                   --AddPlayerInDimension(v2.ply, GetDimensionByName("base"))
                end
             end
             table.remove(Racing_lobbies, i)
          end
       end
    end
end)

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i,v in ipairs(racing_objects) do
            local pickup = CreatePickupTrigger(334, v[1], v[2], v[3], false)
            AddPickupInDimension(pickup, id)
            local text = CreateText3D("Racing race " .. tostring(i), 16, v[1], v[2], v[3]+100, 0, 0, 0)
            AddText3DInDimension(text, id)
       end
    end
end)

AddEvent("OnPlayerRacingAction", function(ply, pickup)
    local x, y, z = GetPickupLocation(pickup)
    local race_id
    for i,v in ipairs(racing_objects) do
       if (x == v[1] and y == v[2] and z == v[3]) then
          race_id = i
       end
    end
    if race_id then
        if not IsHeistPlayer(ply) then
            local lobbies_to_send = {}
            for i,v in ipairs(Racing_lobbies) do
               if (table_count(v.players) < 16 and not v.inrace) then -- check if the lobby is full or in race
                  table.insert(lobbies_to_send, v)
               end
            end
            CallRemoteEvent(ply, "SendRacingLobbies", race_id, lobbies_to_send)
        else
            CallRemoteEvent(ply, "CreateNotification", "Racing", "You can't because your are in a heist phase", 5000)
        end
    else
        print("Error : Can't find race_id")
    end
end)

AddRemoteEvent("JoinLobby", function(ply, selected)
    AddPlayerInLobby(ply, selected)
end)

AddRemoteEvent("LeaveLobby", function(ply)
    RemovePlayerFromRacingLobby(ply)
end)

AddRemoteEvent("CreateLobby", function(ply, race_id)
    local id = CreateRacingLobby(race_id)
    AddPlayerInLobby(ply, id)
    for i, v in ipairs(GetAllPlayers()) do
       if v ~= ply then
          if GetDimensionName(GetPlayerDimension(v)) == "base" then
             CallRemoteEvent(v, "CreateActivityNotification", "Activity", "Racing Lobby " .. tostring(id), "OnJoinActivityRacingLobby", id, 20000)
          end
       end
    end
end)

AddRemoteEvent("StartLobbyRace", function(ply)
    LaunchLobbyRace(GetPlayerDimension(ply))
end)



AddEvent("OnRaceFinished", function(id, tbl_finish, tbl_classement)
    if tbl_finish and tbl_classement then
      local players_in_race = table_count(tbl_finish) + table_count(tbl_classement)
      local players_finish = table_count(tbl_finish)
      local lobby
      for i,v in ipairs(Racing_lobbies) do
         if v.id == id then
            if not v.host then
               if v.players[1] then
                  Racing_lobbies[i].host = v.players[1].ply
               end
            end
            Racing_lobbies[i].inrace = false
            if table_count(racesnumbers) == v.raceid then
               Racing_lobbies[i].raceid = 1
            else
               Racing_lobbies[i].raceid = v.raceid + 1
            end
            lobby = Racing_lobbies[i]
            break 
         end
      end
      if lobby then
         for i, v in ipairs(tbl_finish) do
            SetPlayerRespawnTime(v, 30000)
            local ply_won_m = math.floor((race_money_won*(race_money_won_mult_for_each_player*players_in_race))/i)
            Sell(v, ply_won_m)
            local ply_won_xp = math.floor((race_xp_won*(race_xp_won_mult_for_each_player*players_in_race))/i)
            AwardXp(v, ply_won_xp)
            CallRemoteEvent(v, "RaceFinished", i, ply_won_m, ply_won_xp, lobby)
         end
         for i, v in ipairs(tbl_classement) do
            SetPlayerRespawnTime(v.ply, 30000)
            local ply_won_m = math.floor((race_money_won*(race_money_won_mult_for_each_player*players_in_race))/v.lplace + players_finish)
            Sell(v.ply, ply_won_m)
            local ply_won_xp = math.floor((race_xp_won*(race_xp_won_mult_for_each_player*players_in_race))/v.lplace + players_finish)
            AwardXp(v.ply, ply_won_xp)
            CallRemoteEvent(v.ply, "RaceFinished", v.lplace + players_finish, ply_won_m, ply_won_xp, lobby)
         end
         for i, v in ipairs(GetDimensionPlayers(GetDimensionByName("base"))) do
            CallRemoteEvent(v, "CreateActivityNotification", "Activity", "Racing Lobby " .. tostring(lobby.id), "OnJoinActivityRacingLobby", lobby.id, 20000)
         end
      end
   end
end)






AddEvent("OnPlayerSpawn", function(ply)
    for i,v in ipairs(Racing_lobbies) do
       if v.inrace then
            for i2,v2 in ipairs(v.players) do
               if v2.ply == ply then
                  CallEvent("OnPlayerSpawnRacing", ply)
               end
            end 
       end
    end
end)

AddEvent("OnPlayerLeaveVehicle", function(ply,veh,seat)
   for i,v in ipairs(Racing_lobbies) do
      if v.inrace then
           for i2,v2 in ipairs(v.players) do
              if v2.ply == ply then
                 CallEvent("OnPlayerLeaveVehicleRacing", ply, veh, seat)
              end
           end 
      end
   end
end)

