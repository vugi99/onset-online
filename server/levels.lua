



function GetXpRequiredForNextLevel(Level)
   return (xp_base+xp_added_level*(Level-1))
end

function CanLevelUp(Level, Xp)
   if (GetXpRequiredForNextLevel(Level) <= Xp and Level < max_level) then
      return true
   end
   return false
end

function LevelUp(ply)
   PlayerData[ply].xp = PlayerData[ply].xp - GetXpRequiredForNextLevel(PlayerData[ply].level)
   if PlayerData[ply].xp < 0 then
      PlayerData[ply].xp = 0
   end
   if PlayerData[ply].level < max_level then
      PlayerData[ply].level = PlayerData[ply].level + 1
   else
       PlayerData[ply].level = max_level
   end
   if CanLevelUp(PlayerData[ply].level, PlayerData[ply].xp) then
      LevelUp(ply)
   else
      CallRemoteEvent(ply,"UpdateLevel", PlayerData[ply].level, PlayerData[ply].xp)
   end
end

function AwardXp(ply,Xp)
   PlayerData[ply].xp = PlayerData[ply].xp + Xp
   if CanLevelUp(PlayerData[ply].level, PlayerData[ply].xp) then
      LevelUp(ply)
   else
       CallRemoteEvent(ply,"UpdateLevel", PlayerData[ply].level, PlayerData[ply].xp)
   end
end

AddEvent("PlayerDataLoaded", function(ply)
    if CanLevelUp(PlayerData[ply].level, PlayerData[ply].xp) then
       LevelUp(ply)
    else
       CallRemoteEvent(ply,"UpdateLevel", PlayerData[ply].level, PlayerData[ply].xp)
    end
end)