
local Police_players = {}

local Police_Waiting_Vehicles = {}
local Unique_waiting_id = 1

function IsPoliceman(ply)
   for i,v in ipairs(Police_players) do
      if v == ply then
         return true
      end
   end
   return false
end

function LeavePoliceman(ply)
    for i,v in ipairs(Police_players) do
        if v == ply then
           if PlayerData[ply] then
              OnlineSetClothes(ply, PlayerData[ply].clothes)
           end
           ResetPlayerStoredPoliceVehicle(ply)
           table.remove(Police_players, i)
           return true
        end
     end
     return false
end

function IsCriminal(ply)
   if (PlayerData[ply] and PlayerData[ply].criminal_bonus > 0) then
      return true
   end
   return false
end

function GetCriminalBonus(ply)
   return PlayerData[ply].criminal_bonus
end

function LeaveCriminal(ply)
    PlayerData[ply].criminal_bonus = 0
    return true
end

function AddCriminalBonus(ply)
   if IsCriminal(ply) then
         PlayerData[ply].criminal_bonus = PlayerData[ply].criminal_bonus + criminal_bonus_added
   else
       PlayerData[ply].criminal_bonus = criminal_bonus_base
       CallRemoteEvent(ply, "SetCriminalClient", true)
   end
end

function GetPolicePlayers()
    local tbl = {}
    for i, v in ipairs(Police_players) do
        table.insert(tbl, v)
    end
    return tbl
end

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(police_npcs) do
           local npc = CreateNPC(v[1], v[2], v[3], v[4])
           SetNPCNetworkedClothingPreset(npc, 13)
           AddNPCInDimension(npc, id)
           table.insert(online_invincible_npcs, npc)
           local text = CreateText3D("Police", 16, v[1], v[2], v[3] + 100, 0, 0, 0)
           AddText3DInDimension(text, id)
       end
       for i, v in ipairs(Police_cars_spawns) do
           local pickup = CreatePickupTrigger(2, v[1][1], v[1][2], v[1][3], false, "OnPlayerSpawnPoliceCar")
           AddPickupInDimension(pickup, id)
           local text = CreateText3D("Spawn police car", 16, v[1][1], v[1][2], v[1][3] + 100, 0, 0, 0)
           AddText3DInDimension(text, id)
       end
    end
end)

AddRemoteEvent("SetPoliceServer", function(ply, Policeman)
    if IsValidPlayer(ply) then
       if Policeman then
          if not IsPoliceman(ply) then
             table.insert(Police_players, ply)
             ResetPlayerBody(ply)
             SetPlayerNetworkedClothingPreset(ply, 13)
          else
              print("Warning : Trying to set police on server while already policeman")
          end
       else
           LeavePoliceman(ply)
       end
    end
end)

AddEvent("OnPlayerDeath", function(ply, killer)
    if (ply and killer) then
      if (IsValidPlayer(ply) and IsValidPlayer(killer)) then
         if GetPlayerDimension(killer) == GetDimensionByName("base") then
            if ply ~= killer then
               if not IsPoliceman(killer) then
                  AddCriminalBonus(killer)
               elseif IsCriminal(ply) then
                  if not IsHeistPlayer(ply) then
                     local bonus = GetCriminalBonus(ply)
                     Sell(killer, bonus)
                     LeaveCriminal(ply)
                     CallRemoteEvent(ply, "SetCriminalClient", false)
                     CallRemoteEvent(killer, "CreateNotification", "Police", "You won " .. tostring(bonus) .. "$", 5000)
                  else
                      if heist_robbers_deaths < no_kill_bonus_after_kills then
                           if heist_phase_in_progress < table_count(heist_phases) then
                              local tbl = GetPhaseTbl(heist_phase_in_progress)
                              Sell(killer, tbl.kill_bonus_robber)
                              CallRemoteEvent(killer, "CreateNotification", "Police", "You won " .. tostring(tbl.kill_bonus_robber) .. "$", 5000)
                           else
                              Sell(killer, heist_final_phase.kill_bonus_robber)
                              CallRemoteEvent(killer, "CreateNotification", "Police", "You won " .. tostring(heist_final_phase.kill_bonus_robber) .. "$", 5000)
                           end
                      end
                      heist_robbers_deaths = heist_robbers_deaths + 1
                  end
               else
                  LeavePoliceman(killer)
                  CallRemoteEvent(killer, "SetPolicemanClient", false)
                  AddCriminalBonus(killer)
               end
            end
         end
      end
   end
end)

local testcriminals = false

AddRemoteEvent("GetCriminalsForPoliceMenu", function(ply)
    if not testcriminals then
         local Criminals = {}
         local tblin = 1
         Criminals[tblin] = {}
         for i, v in ipairs(GetAllPlayers()) do
            if IsCriminal(v) then
               local tbl = {}
               tbl.name = GetPlayerName(v)
               tbl.bonus = PlayerData[v].criminal_bonus
               tbl.level = PlayerData[v].level
               table.insert(Criminals[tblin], tbl)
               if table_count(Criminals[tblin]) > 29 then
                  tblin = tblin + 1
                  Criminals[tblin] = {}
               end
            end
         end
         CallRemoteEvent(ply, "CriminalsResponseForPoliceMenu", Criminals)
    else
        local Criminals = {}
        local tblin = 1
        Criminals[tblin] = {}
        for i = 1, 299 do
           local tbl = {}
           tbl.name = "test"
           tbl.bonus = i
           tbl.level = i
           table.insert(Criminals[tblin], tbl)
           if table_count(Criminals[tblin]) > 29 then
              tblin = tblin + 1
              Criminals[tblin] = {}
           end
        end
        CallRemoteEvent(ply, "CriminalsResponseForPoliceMenu", Criminals)
    end
end)

AddEvent("OnPlayerQuit", function(ply)
    LeavePoliceman(ply)
end)

AddEvent("PlayerDataLoaded", function(ply)
    if IsCriminal(ply) then
       CallRemoteEvent(ply, "SetCriminalClient", true)
    end
end)

AddRemoteEvent("ArrestCriminal", function(ply, npc)
   if IsCriminal(ply) then
      for i = 1, 3 do
         SetPlayerWeapon(ply, 1, 0, false, i)
      end
      PlayerData[ply].weapons = {}
      LeaveCriminal(ply)
      CallRemoteEvent(ply, "SetCriminalClient", false)
      SetPlayerAnimation(ply, "HANDSHEAD_KNEEL")
      SetNPCAnimation(npc, "CARRY_SHOULDER_SETDOWN", false)
      Delay(5000, function()
          SetPlayerAnimation(ply, "STOP")
      end)
   end
end)

local function CanSpawnPoliceCar(ply, spawn_id)
    local veh = GetPlayerStoredPoliceVehicle(ply)
    for i, v in ipairs(GetDimensionVehicles(GetDimensionByName("base"))) do
        if IsValidVehicle(v) then
            local x, y, z = GetVehicleLocation(v)
            if (O_GetDistanceSquared3D(Police_cars_spawns[spawn_id][2][1], Police_cars_spawns[spawn_id][2][2], Police_cars_spawns[spawn_id][2][3], x, y, z) <= special_vehicles_spawn_higher_distance3d_considered_as_same_loc^2 and veh ~= v) then
                  return false
            end
        end
    end
    return true
end

AddEvent("OnPlayerSpawnPoliceCar", function(ply, pickup)
    if IsPoliceman(ply) then
        if not GetPickupPropertyValue(pickup, "PoliceCooldown") then
            local x, y, z = GetPickupLocation(pickup)
            local Policespawnid
            for i, v in ipairs(Police_cars_spawns) do
                  if (v[1][1] == x and v[1][2] == y and v[1][3] == z) then
                     Policespawnid = i
                     break
                  end
            end
            if Policespawnid then
                  if CanSpawnPoliceCar(ply, Policespawnid) then
                     local veh = CreateVehicle(police_car_id, Police_cars_spawns[Policespawnid][2][1], Police_cars_spawns[Policespawnid][2][2], Police_cars_spawns[Policespawnid][2][3], Police_cars_spawns[Policespawnid][2][4])
                     AddVehicleInDimension(veh, GetDimensionByName("base"))
                     SetPlayerStoredPoliceVehicle(ply, veh)
                     EnableVehicleBackfire(veh, true)
                     SetVehicleRespawnParams(veh, false)
                     table.insert(Police_Waiting_Vehicles, veh)
                     SetVehiclePropertyValue(veh, "PoliceWaitingUniqueId", Unique_waiting_id, false)
                     SetPickupPropertyValue(pickup, "PoliceCooldown", true, false)
                     Delay(police_spawn_cooldown_ms, function()
                        SetPickupPropertyValue(pickup, "PoliceCooldown", nil, false)
                     end)
                     local cur_id = Unique_waiting_id
                     Unique_waiting_id = Unique_waiting_id + 1
                     Delay(police_vehicles_spawn_destroy_after_s_if_is_on_the_same_loc * 1000, function()
                        for i, v in pairs(Police_Waiting_Vehicles) do
                              if (v == veh and GetVehiclePropertyValue(veh, "PoliceWaitingUniqueId") == cur_id) then
                                 local vx, vy, vz = GetVehicleLocation(veh)
                                 if (O_GetDistanceSquared3D(Police_cars_spawns[Policespawnid][2][1], Police_cars_spawns[Policespawnid][2][2], Police_cars_spawns[Policespawnid][2][3], vx, vy, vz) <= police_vehicles_spawn_higher_distance3d_considered_as_same_loc^2) then
                                    --print("ResetPlayerStoredPoliceVehicle, after delay")
                                    ResetPlayerStoredPoliceVehicle(ply)
                                 else
                                    SetVehiclePropertyValue(veh, "PoliceWaitingUniqueId", nil, false)
                                    table.remove(Police_Waiting_Vehicles, i)
                                 end
                                 break
                              end
                        end
                     end)
                  else
                     CallRemoteEvent(ply, "CreateNotification", "Police", "A vehicle is blocking the car spawn", 5000)
                  end
            else
                  print("Error : can't find Policespawnid : OnPlayerSpawnPoliceCar")
            end
        else
            CallRemoteEvent(ply, "CreateNotification", "Police", "Please wait", 5000)
        end
    else
        CallRemoteEvent(ply, "CreateNotification", "Police", "You are not policeman", 5000)
    end
end)

AddEvent("OnVehicleDestroyed", function(veh)
    for i, v in ipairs(Police_Waiting_Vehicles) do
        if v == veh then
            table.remove(Police_Waiting_Vehicles, i)
            break
        end
    end
end)

AddRemoteEvent("GetRobbersForPoliceMenu", function(ply)
    if IsPoliceman(ply) then
         if (heist_phase_in_progress and heist_phase_in_progress >= table_count(heist_phases)) then
            local enter_bank_objective_done
            for i, v in ipairs(heist_trigger_pickups) do
                  if GetPickupPropertyValue(v, "Entered_Bank_Objective_Done") then
                     enter_bank_objective_done = true
                     break
                  end
            end
            if enter_bank_objective_done then
                  local tbl = {}
                  for i, v in ipairs(GetAllHeistPlayers()) do
                     local tblinsert = {
                        name = GetPlayerName(v),
                        bonus = heist_final_phase.kill_bonus_robber,
                        level = PlayerData[ply].level
                     }
                     table.insert(tbl, tblinsert)
                  end
                  CallRemoteEvent(ply, "RobbersResponseForPoliceMenu", tbl)
            else
                CallRemoteEvent(ply, "RobbersResponseForPoliceMenu")
            end
         else
             CallRemoteEvent(ply, "RobbersResponseForPoliceMenu")
         end
    end
end)
