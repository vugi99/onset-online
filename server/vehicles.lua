
local playersvehicle = {}
_Last_Server_Vehicle_ID = 1

function GetPlayerStoredVehicle(ply)
   for i, v in ipairs(playersvehicle) do
      if v.ply == ply then
         return v.veh
      end
   end
   return false
end

function ResetPlayerStoredVehicle(ply)
    for i,v in ipairs(playersvehicle) do
        if v.ply == ply then
             if IsValidVehicle(v.veh) then
                 ResetVehicleDimension(v.veh)
                 DestroyVehicle(v.veh)
             end
             table.remove(playersvehicle, i)
             break
        end
     end
end

function GetVehicleStoredOwner(veh)
   for i, v in ipairs(playersvehicle) do
      if v.veh == veh then
         return v.ply
      end
   end
   return false
end

function SetPlayerStoredVehicle(ply, veh)
   for i,v in ipairs(playersvehicle) do
      if v.ply == ply then
         if IsValidVehicle(v.veh) then
            DestroyVehicle(v.veh)
         end
         table.remove(playersvehicle, i)
         break
      end
   end
   SetVehiclePropertyValue(veh, "VehOwner", ply, false)
   local tbl = {}
   tbl.veh = veh
   tbl.ply = ply
   table.insert(playersvehicle, tbl)
end

local players_special_vehicle = {}

function GetPlayerStoredSpecialVehicle(ply)
   for i, v in ipairs(players_special_vehicle) do
      if v.ply == ply then
         return v.veh
      end
   end
   return false
end

function ResetPlayerStoredSpecialVehicle(ply)
    for i,v in ipairs(players_special_vehicle) do
        if v.ply == ply then
             if IsValidVehicle(v.veh) then
                 ResetVehicleDimension(v.veh)
                 DestroyVehicle(v.veh)
             end
             table.remove(players_special_vehicle, i)
             break
        end
     end
end

function GetVehicleStoredSpecialOwner(veh)
   for i, v in ipairs(players_special_vehicle) do
      if v.veh == veh then
         return v.ply
      end
   end
   return false
end

function SetPlayerStoredSpecialVehicle(ply, veh)
   for i,v in ipairs(players_special_vehicle) do
      if v.ply == ply then
         if IsValidVehicle(v.veh) then
            DestroyVehicle(v.veh)
         end
         table.remove(players_special_vehicle, i)
         break
      end
   end
   SetVehiclePropertyValue(veh, "VehOwner", ply, false)
   local tbl = {}
   tbl.veh = veh
   tbl.ply = ply
   table.insert(players_special_vehicle, tbl)
end

local players_admin_vehicle = {}

function GetPlayerStoredAdminVehicle(ply)
   for i, v in ipairs(players_admin_vehicle) do
      if v.ply == ply then
         return v.veh
      end
   end
   return false
end

function ResetPlayerStoredAdminVehicle(ply)
    for i,v in ipairs(players_admin_vehicle) do
        if v.ply == ply then
             if IsValidVehicle(v.veh) then
                 ResetVehicleDimension(v.veh)
                 DestroyVehicle(v.veh)
             end
             table.remove(players_admin_vehicle, i)
             break
        end
     end
end

function GetVehicleStoredAdminOwner(veh)
   for i, v in ipairs(players_admin_vehicle) do
      if v.veh == veh then
         return v.ply
      end
   end
   return false
end

function SetPlayerStoredAdminVehicle(ply, veh)
   for i,v in ipairs(players_admin_vehicle) do
      if v.ply == ply then
         if IsValidVehicle(v.veh) then
            DestroyVehicle(v.veh)
         end
         table.remove(players_admin_vehicle, i)
         break
      end
   end
   SetVehiclePropertyValue(veh, "AdminVehOwner", ply, false)
   local tbl = {}
   tbl.veh = veh
   tbl.ply = ply
   table.insert(players_admin_vehicle, tbl)
end

local players_police_vehicle = {}

function GetPlayerStoredPoliceVehicle(ply)
   for i, v in ipairs(players_police_vehicle) do
      if v.ply == ply then
         return v.veh
      end
   end
   return false
end

function ResetPlayerStoredPoliceVehicle(ply)
    for i,v in ipairs(players_police_vehicle) do
        if v.ply == ply then
             if IsValidVehicle(v.veh) then
                 ResetVehicleDimension(v.veh)
                 DestroyVehicle(v.veh)
             end
             table.remove(players_police_vehicle, i)
             break
        end
     end
end

function GetVehicleStoredPoliceOwner(veh)
   for i, v in ipairs(players_police_vehicle) do
      if v.veh == veh then
         return v.ply
      end
   end
   return false
end

function SetPlayerStoredPoliceVehicle(ply, veh)
   for i,v in ipairs(players_police_vehicle) do
      if v.ply == ply then
         if IsValidVehicle(v.veh) then
            DestroyVehicle(v.veh)
         end
         table.remove(players_police_vehicle, i)
         break
      end
   end
   SetVehiclePropertyValue(veh, "PoliceVehOwner", ply, false)
   local tbl = {}
   tbl.veh = veh
   tbl.ply = ply
   table.insert(players_police_vehicle, tbl)
end

AddEvent("OnPlayerQuit", function(ply)
    ResetPlayerStoredVehicle(ply)
    ResetPlayerStoredSpecialVehicle(ply)
    ResetPlayerStoredAdminVehicle(ply)
    ResetPlayerStoredPoliceVehicle(ply)
end)

AddEvent("OnPackageStart", function()
    local cur_v_id = 0
    local veh = true
    while veh do
       cur_v_id = cur_v_id + 1
       veh = CreateVehicle(cur_v_id, 0, 0, 0)
       DestroyVehicle(veh)
    end
    _Last_Server_Vehicle_ID = cur_v_id - 1
end)

AddEvent("OnPlayerJoin", function(ply)
    CallRemoteEvent(ply, "SendLastServerVehicleID", _Last_Server_Vehicle_ID)
end)

AddEvent("OnPlayerEnterVehicle", function(ply, veh, seat)
      if seat == 1 then
         local veh_property = GetVehiclePropertyValue(veh, "VehOwner")
         if veh_property then
            if veh_property ~= ply then
               local access_setting = GetFriendSetting(veh_property, 1)
               if access_setting == 3 then
                  RemovePlayerFromVehicle(ply)
               elseif (access_setting == 2 and not IsPlayerFriendWithPlayer(ply, veh_property)) then
                  RemovePlayerFromVehicle(ply)
               end
            end
         end
         local admin_veh_property = GetVehiclePropertyValue(veh, "AdminVehOwner")
         if admin_veh_property then
            if admin_veh_property ~= ply then
               RemovePlayerFromVehicle(ply)
            end
         end
         local police_veh_property = GetVehiclePropertyValue(veh, "PoliceVehOwner")
         if police_veh_property then
            if police_veh_property ~= ply then
               RemovePlayerFromVehicle(ply)
            end
         end
      end
end)
