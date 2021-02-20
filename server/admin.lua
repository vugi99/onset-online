


function IsAdmin(ply)
   local steamid = GetPlayerSteamId(ply)
   for i,v in ipairs(admins) do
      if v == tostring(steamid) then
         return true
      end
   end
   return false
end

AddEvent("OnPlayerSteamAuth", function(ply)
    if IsAdmin(ply) then
       CallRemoteEvent(ply, "YouAreAdmin")
    end
end)

AddRemoteEvent("KickPlayer", function(ply, plyselected)
    if (IsAdmin(ply) and IsValidPlayer(plyselected)) then
        KickPlayer(plyselected, "You have been kicked by " .. GetPlayerName(ply))
        if IsValidPlayer(ply) then
            CallRemoteEvent(ply, "CreateNotification", "Admin", "Player Kicked", 5000)
        end
    else
        if IsValidPlayer(ply) then
            CallRemoteEvent(ply, "CreateNotification", "Admin", "Kick Failed", 5000)
         end
    end
end)

AddRemoteEvent("BanPlayer", function(ply, plyselected)
    if (IsValidPlayer(plyselected) and IsAdmin(ply)) then
        local good = false
        if not IsAdmin(plyselected) then
            local query = mariadb_prepare(db, "UPDATE accounts SET is_banned = ? WHERE accountid = ? LIMIT 1;",
                        1,
                        PlayerData[plyselected].accountid
            )
            mariadb_query(db, query)
            KickPlayer(plyselected, "You have been banned by " .. GetPlayerName(ply))
            if IsValidPlayer(ply) then
                CallRemoteEvent(ply, "CreateNotification", "Admin", "Player Banned", 5000)
                good = true
            end
        end
        if (IsValidPlayer(ply) and not good) then
           CallRemoteEvent(ply, "CreateNotification", "Admin", "Ban Failed", 5000)
        end
    end
end)

AddRemoteEvent("GetServerPlayersAdmin", function(ply)
    local tbl = {}
    for i,v in ipairs(GetAllPlayers()) do
       local tblinsert = {}
       tblinsert.ply = v
       tblinsert.name = GetPlayerName(v)
       table.insert(tbl, tblinsert)
    end
    CallRemoteEvent(ply, "SendPlayersAdmin", tbl)
end)

AddRemoteEvent("TeleportToPlayer", function(ply, plyselected)
    if (IsAdmin(ply) and IsValidPlayer(plyselected)) then
        local x, y, z = GetPlayerLocation(plyselected)
        SetPlayerLocation(ply, x, y, z + 100)
    else
        if IsValidPlayer(ply) then
            CallRemoteEvent(ply, "CreateNotification", "Admin", "Teleport Failed", 5000)
        end
    end
end)

AddRemoteEvent("TeleportPlayerToMe", function(ply, plyselected)
    if (IsAdmin(ply) and IsValidPlayer(plyselected)) then
        local x, y, z = GetPlayerLocation(ply)
        SetPlayerLocation(plyselected, x, y, z + 100)
    else
        if IsValidPlayer(ply) then
            CallRemoteEvent(ply, "CreateNotification", "Admin", "Teleport Failed", 5000)
        end
    end
end)

AddRemoteEvent("SpawnAdminVehicle", function(ply, vehid, r, g, b, a, backfire, nitro)
    if (IsAdmin(ply) and GetDimensionName(GetPlayerDimension(ply)) == "base") then
        local x, y, z = GetPlayerLocation(ply)
        local h = GetPlayerHeading(ply)
        local veh = CreateVehicle(vehid, x, y, z + 25, h)
        AddVehicleInDimension(veh, GetDimensionByName("base"))
        SetPlayerStoredAdminVehicle(ply, veh)
        SetPlayerInVehicle(ply, veh)
        SetVehicleColor(veh, RGBA(r, g, b, a))
        EnableVehicleBackfire(veh, backfire)
        AttachVehicleNitro(veh, nitro)
        SetVehicleLicensePlate(veh, "ADMIN")
    end
end)

AddRemoteEvent("TeleportAdmin", function(ply, x, y, z)
    if IsAdmin(ply) then
       local veh = GetPlayerVehicle(ply)
       if veh == 0 then
            SetPlayerLocation(ply, x, y, z)
       else
           SetVehicleLocation(veh, x, y, z)
       end
    end
end)