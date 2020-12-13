
function IsPlayerFriendWithPlayer(ply, otherply)
   if PlayerData[ply] then
      for i, v in ipairs(PlayerData[ply].friends) do
         if v.steamid == tostring(GetPlayerSteamId(otherply)) then
            return true
         end
      end
   end
   return false
end

function PlayerAlreadySentFriendRequestTo(ply, otherply)
    if PlayerData[otherply] then
       for i, v in ipairs(PlayerData[otherply].friends_requests) do
          if v.steamid == tostring(GetPlayerSteamId(ply)) then
             return true
          end
       end
    end
    return false
 end

function GetFriendSetting(ply, settingid)
   if PlayerData[ply] then
      for i, v in ipairs(PlayerData[ply].friends_settings) do
         if v.settingid == settingid then
            return v.setting
         end
      end
   end
end

AddRemoteEvent("GetFriendsForPlayerMenu", function(ply)
    if PlayerData[ply] then
        local Online_friends = {}
        for i, v in ipairs(PlayerData[ply].friends) do
           for i2, v2 in ipairs(GetAllPlayers()) do
              if v.steamid == tostring(GetPlayerSteamId(v2)) then
                 table.insert(Online_friends, v)
              end
           end
        end
        CallRemoteEvent(ply, "GetFriendsResponse", Online_friends, PlayerData[ply].friends, PlayerData[ply].friends_settings, PlayerData[ply].friends_requests)
    end
end)

AddRemoteEvent("ChangeFriendSetting", function(ply, settingid, setting)
    if PlayerData[ply] then
       for i, v in ipairs(PlayerData[ply].friends_settings) do
          if v.settingid == settingid then
             PlayerData[ply].friends_settings[i].setting = setting
             local query = mariadb_prepare(db, "UPDATE accounts SET friends_settings = '?' WHERE accountid = ? LIMIT 1;",
                    json_encode(PlayerData[ply].friends_settings),
                    PlayerData[ply].accountid
	         )
             mariadb_query(db, query)
             CallRemoteEvent(ply, "CreateNotification", "Friends Settings", "Setting changed", 5000)
             break
          end
       end
    end
end)

function AcceptFriendRequest(ply, otherply)
    for i, v in ipairs(PlayerData[ply].friends_requests) do
        if v.steamid == tostring(GetPlayerSteamId(otherply)) then
            table.insert(PlayerData[ply].friends, v)
            table.remove(PlayerData[ply].friends_requests, i)
            break
        end
    end
    local tbl = {
        name = GetPlayerName(ply),
        steamid = tostring(GetPlayerSteamId(ply))
    }
    table.insert(PlayerData[otherply].friends, tbl)
    CallRemoteEvent(ply, "CreateNotification", "Friends", GetPlayerName(otherply) .. " is now your friend.", 5000)
    CallRemoteEvent(otherply, "CreateNotification", "Friends", GetPlayerName(ply) .. " is now your friend.", 5000)
end

AddRemoteEvent("SendFriendRequest", function(ply, otherply)
    if (IsValidPlayer(otherply) and PlayerData[otherply] and PlayerData[ply]) then
        if not IsPlayerFriendWithPlayer(ply, otherply) then
            if not PlayerAlreadySentFriendRequestTo(ply, otherply) then
                if not PlayerAlreadySentFriendRequestTo(otherply, ply) then
                    local tbl = {
                        name = GetPlayerName(ply),
                        steamid = tostring(GetPlayerSteamId(ply))
                    }
                    table.insert(PlayerData[otherply].friends_requests, tbl)
                    CallRemoteEvent(ply, "CreateNotification", "Friend Request", "You sent a friend request to " .. GetPlayerName(otherply), 5000)
                    CallRemoteEvent(otherply, "CreateNotification", "Friend Request", "You received a friend request from " .. GetPlayerName(ply), 5000)
                else
                    if table_count(PlayerData[ply].friends) < max_friends then
                        if table_count(PlayerData[otherply].friends) < max_friends then
                           AcceptFriendRequest(ply, otherply)
                        else
                            CallRemoteEvent(ply, "CreateNotification", "Friend Request", "He has too many friends", 5000)
                        end
                    else
                        CallRemoteEvent(ply, "CreateNotification", "Friend Request", "You have too many friends", 5000)
                    end
                end
            else
                CallRemoteEvent(ply, "CreateNotification", "Friend Request", "You already sent a friend request to " .. GetPlayerName(otherply), 5000)
            end
        else
            CallRemoteEvent(ply, "CreateNotification", "Friend Request", GetPlayerName(otherply) .. " is already your friend", 5000)
        end
    else
        CallRemoteEvent(ply, "CreateNotification", "Friend Request", "Friend request failed", 5000)
    end
end)

AddRemoteEvent("RemoveFriend", function(ply, otherplysteamid)
    if (IsValidPlayer(ply) and PlayerData[ply]) then
       local otherply
       for i, v in ipairs(GetAllPlayers()) do
          if (tostring(GetPlayerSteamId(v)) == otherplysteamid and PlayerData[v]) then
             otherply = v
             break
          end
       end
       for i, v in ipairs(PlayerData[ply].friends) do
          if v.steamid == otherplysteamid then
             if not otherply then
                GetPlayerData(otherplysteamid, "RemoveFriendPart2", "friends", tostring(GetPlayerSteamId(ply)))
             else
                 local plysteamid = tostring(GetPlayerSteamId(ply))
                 for i2, v2 in ipairs(PlayerData[otherply].friends) do
                    if v2.steamid == plysteamid then
                        table.remove(PlayerData[otherply].friends, i2)
                        break
                    end
                 end
             end
             table.remove(PlayerData[ply].friends, i)
             break
          end
       end
    end
end)

AddEvent("RemoveFriendPart2", function(accountid, friends, steamid)
    friends = json_decode(friends)
    for i, v in ipairs(friends) do
        if v.steamid == steamid then
            table.remove(friends, i)
            local query = mariadb_prepare(db, "UPDATE accounts SET friends = '?' WHERE accountid = ? LIMIT 1;",
                    json_encode(friends),
                    accountid
	        )
            mariadb_query(db, query)
            --print("RemoveFriendPart2, updated value")
            break
        end
     end
end)

AddRemoteEvent("DenyFriendRequest", function(ply, otherplysteamid)
    if (IsValidPlayer(ply) and PlayerData[ply]) then
       for i, v in ipairs(PlayerData[ply].friends_requests) do
          if v.steamid == otherplysteamid then
             table.remove(PlayerData[ply].friends_requests, i)
             break
          end
       end
    end
end)

AddRemoteEvent("AcceptFriendRequest", function(ply, otherplysteamid)
    if (IsValidPlayer(ply) and PlayerData[ply]) then
       local otherply
       for i, v in ipairs(GetAllPlayers()) do
          if tostring(GetPlayerSteamId(v)) == otherplysteamid then
             otherply = v
             break
          end
       end
       if (otherply and IsValidPlayer(otherply) and PlayerData[otherply]) then
           if table_count(PlayerData[otherply].friends) < max_friends then
               AcceptFriendRequest(ply, otherply)
           else
               CallRemoteEvent(ply, "CreateNotification", "Friends Requests", "He has too much friends.", 5000)
           end
       else
           CallRemoteEvent(ply, "CreateNotification", "Friends Requests", "Can't accept the friend request, he is not connected on the server.", 5000)
       end
    end
end)