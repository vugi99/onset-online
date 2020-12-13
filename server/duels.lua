
local duels = {}

function IsPlayerInADuel(ply)
   for i, v in ipairs(duels) do
      if (v[1] == ply or v[2] == ply) then
         return true
      end
   end
   return false
end

function PlayerLeaveDuel(ply, left_duel, win)
    AddPlayerInDimension(ply, GetDimensionByName("base"))
    if left_duel then
       CallRemoteEvent(ply, "DuelFinished", true)
    end
    for i=1, 3 do
        SetPlayerWeapon(ply, 1, 0, false, i, false)
    end
    for i, v in ipairs(PlayerData[ply].weapons) do
        SetPlayerWeapon(ply, v.weapid, v.ammo, false, v.slot, false)
    end
    if (left_duel or win) then
       Delay(2000, function()
            for i=1, 3 do
                SetPlayerWeapon(ply, 1, 0, false, i, false)
            end
            for i, v in ipairs(PlayerData[ply].weapons) do
                SetPlayerWeapon(ply, v.weapid, v.ammo, false, v.slot, false)
            end
       end)
    end
    local locbef = GetPlayerPropertyValue(ply, "LocBeforeDuel")
    if (left_duel or win) then
        SetPlayerLocation(ply, locbef[1], locbef[2], locbef[3])
        SetPlayerHeading(ply, locbef[4])
    else
        SetPlayerSpawnLocation(ply, locbef[1], locbef[2], locbef[3], locbef[4])
    end
end

function DuelStart(ply, ply2)
   local dim = CreateDimension("duel", true)
   local plys = {ply, ply2}
   table.insert(duels, plys)
   local duelmap_index = math.random(table_count(duels_locations))
   local duelmap = duels_locations[duelmap_index]
   for i = 1, 2 do
      SetPlayerWeapon(plys[i], 1, 0, false, 2)
      SetPlayerWeapon(plys[i], 1, 0, false, 3)
      SetPlayerWeapon(plys[i], duels_weapon, 10000, true, 3, true)
      SetPlayerHealth(plys[i], 100)
      local x, y, z = GetPlayerLocation(plys[i])
      local h = GetPlayerHeading(plys[i])
      SetPlayerPropertyValue(plys[i], "LocBeforeDuel", {x, y, z, h}, false)
      AddPlayerInDimension(plys[i], dim)
      SetPlayerLocation(plys[i], duelmap[i][1], duelmap[i][2], duelmap[i][3])
      SetPlayerHeading(plys[i], duelmap[i][4])
      CallRemoteEvent(plys[i], "DuelStarted", duelmap_index, i)
   end
end

function RemovePlayerFromADuel(ply, leave_server)
   for i, v in ipairs(duels) do
      if v[1] == ply then
         if not leave_server then
            PlayerLeaveDuel(ply, true)
         end
         PlayerLeaveDuel(v[2], true)
         table.remove(duels, i)
         return true
      elseif v[2] == ply then
         if not leave_server then
            PlayerLeaveDuel(ply, true)
         end
         PlayerLeaveDuel(v[1], true)
         table.remove(duels, i)
         return true
      end
   end
   return false
end

AddRemoteEvent("AskForDuel", function(ply, otherply)
    if (IsValidPlayer(ply) and IsValidPlayer(otherply) and GetPlayerDimension(ply) == GetDimensionByName("base") and GetPlayerDimension(otherply) == GetDimensionByName("base")) then
        if (not IsPlayerInADuel(ply) and not IsPlayerInADuel(otherply)) then
            CallRemoteEvent(otherply, "CreateActivityNotification", "Duel", GetPlayerName(ply) .. " is asking for a duel", "OnDuelAccept", {ply, GetPlayerName(ply)}, 15000)
        end
    end
end)

AddRemoteEvent("OnPlayerAcceptDuel", function(ply, instigator, insti_name)
    if (IsValidPlayer(ply) and IsValidPlayer(instigator) and GetPlayerName(instigator) == insti_name and GetPlayerDimension(ply) == GetDimensionByName("base") and GetPlayerDimension(instigator) == GetDimensionByName("base")) then
        if (not IsPlayerInADuel(ply) and not IsPlayerInADuel(instigator)) then
            DuelStart(instigator, ply)
        else
            CallRemoteEvent(ply, "CreateNotification", "Duel", "The player is in another duel", 5000)
        end
    else
        CallRemoteEvent(ply, "CreateNotification", "Duel", "Duel failed to start", 5000)
    end
end)

AddEvent("OnPlayerDeath", function(ply, instigator)
    --if ply ~= instigator then
        for i, v in ipairs(duels) do
            if v[1] == ply then
                CallRemoteEvent(ply, "DuelFinished")
                PlayerLeaveDuel(ply)
                local money_won = math.random(duels_win_reward_min, duels_win_reward_max)
                Sell(v[2], money_won)
                CallRemoteEvent(v[2], "DuelFinished", false, money_won)
                PlayerLeaveDuel(v[2], false, true)
                table.remove(duels, i)
                break
            elseif v[2] == ply then
                CallRemoteEvent(ply, "DuelFinished")
                PlayerLeaveDuel(ply)
                local money_won = math.random(duels_win_reward_min, duels_win_reward_max)
                Sell(v[1], money_won)
                CallRemoteEvent(v[1], "DuelFinished", false, money_won)
                PlayerLeaveDuel(v[1], false, true)
                table.remove(duels, i)
                break
            end
        end
    --end
end)

AddRemoteEvent("PlayerLeaveDuel", function(ply)
    RemovePlayerFromADuel(ply)
end)

AddEvent("OnPlayerQuit", function(ply)
    RemovePlayerFromADuel(ply, true)
end)