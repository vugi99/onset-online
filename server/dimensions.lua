
local default_dimension = "base" -- don't change this
local dimensions = {}

function CreateDimension(dimname, destroyed_next)
   if destroyed_next == nil then
      destroyed_next = false
   end
   local count = table_last_count(dimensions)
   local tbl = {}
   tbl["name"] = dimname
   tbl["players"] = {}
   tbl["objects"] = {}
   tbl["vehicles"] = {}
   tbl["pickups"] = {}
   tbl["npcs"] = {}
   tbl["doors"] = {}
   tbl["texts3d"] = {}
   tbl["destroyed_next"] = destroyed_next
   dimensions[count + 1] = tbl
   --print("Create dim " .. tostring(count + 1) .. " " .. dimname)
   CallEvent("OnDimensionCreated", count + 1, dimname)
   return (count + 1)
end

function IsValidDimension(id)
   if id then
      if dimensions[id] then
         return true
      end
   end
   return false
end

function GetAllDimensions()
   return dimensions
end

function GetDimensionName(id)
    if dimensions[id] then
       return dimensions[id].name
    end
    return false
end

 function GetDimensionByName(dimname)
    for k, v in pairs(dimensions) do
       if v.name == dimname then
          return k
       end
    end
    return false
end

function DestroyDimension(id, leave)
    if dimensions[id] then
       local defaultdim = GetDimensionByName(default_dimension)
       if not leave then
         for i, v in ipairs(dimensions[id].players) do
            table.insert(dimensions[defaultdim].players, v)
            SetPlayerDimension(v, defaultdim)
         end
      end
       for i, v in ipairs(dimensions[id].objects) do
          if IsValidObject(v) then
             DestroyObject(v)
          end
       end
       --print("1")
       for i, v in ipairs(dimensions[id].vehicles) do
         if IsValidVehicle(v) then
            --print("2")
            DestroyVehicle(v)
            --print("3")
         end
       end
       --print("4")
       for i, v in ipairs(dimensions[id].pickups) do
         if IsValidPickup(v) then
            DestroyPickup(v)
         end
       end
       for i, v in ipairs(dimensions[id].npcs) do
         if IsValidNPC(v) then
            DestroyNPC(v)
         end
       end
       for i, v in ipairs(dimensions[id].doors) do
         if IsValidDoor(v) then
            DestroyDoor(v)
         end
       end
       for i, v in ipairs(dimensions[id].texts3d) do
         if IsValidText3D(v) then
            DestroyText3D(v)
         end
       end
       --print("Dimension " .. tostring(id) .. " destroyed")
       CallEvent("OnDimensionDestroyed", id, dimensions[id].name)
       dimensions[id] = nil
       return true
    end
    return false
end

 function ResetPlayerDimension(ply, leave, wanttoputindim)
    local id = GetPlayerDimension(ply)
    if id then
        if dimensions[id] then
            if dimensions[id].players then
               for i, v in ipairs(dimensions[id].players) do
                  if v == ply then
                     if (dimensions[id].destroyed_next == true and table_count(dimensions[id].players) == 1) then
                           if wanttoputindim == defaultdim then
                              DestroyDimension(id, leave)
                           else
                              DestroyDimension(id, true)
                           end
                           if wanttoputindim == defaultdim then
                              return true
                           end
                     else
                           table.remove(dimensions[id].players, i)
                           --[[if id == 1 then
                              for i, v in ipairs(dimensions[id].players) do
                                 print(tostring(i) .. " " .. tostring(v))
                              end
                           end]]--
                     end
                     break
                  end
               end
            end
       end
    end
end

function ResetObjectDimension(obj)
   local id = GetObjectDimension(obj)
   if id then
       if dimensions[id] then
          for i, v in ipairs(dimensions[id].objects) do
             if v == obj then
                table.remove(dimensions[id].objects, i)
                break
             end
         end
      end
   end
end

function ResetVehicleDimension(veh)
   local id = GetVehicleDimension(veh)
   if id then
       if dimensions[id] then
          for i, v in ipairs(dimensions[id].vehicles) do
             if v == veh then
                table.remove(dimensions[id].vehicles, i)
                break
             end
         end
      end
   end
end

function ResetPickupDimension(pid)
   local id = GetPickupDimension(pid)
   if id then
       if dimensions[id] then
          for i, v in ipairs(dimensions[id].pickups) do
             if v == pid then
                table.remove(dimensions[id].pickups, i)
                break
             end
         end
      end
   end
end

function ResetNPCDimension(npc)
   local id = GetNPCDimension(npc)
   if id then
       if dimensions[id] then
          for i, v in ipairs(dimensions[id].npcs) do
             if v == npc then
                table.remove(dimensions[id].npcs, i)
                break
             end
         end
      end
   end
end

function ResetDoorDimension(door)
   local id = GetDoorDimension(door)
   if id then
       if dimensions[id] then
          for i, v in ipairs(dimensions[id].doors) do
             if v == door then
                table.remove(dimensions[id].doors, i)
                break
             end
         end
      end
   end
end
 
function ResetText3DDimension(text)
   local id = GetText3DDimension(text)
   if id then
       if dimensions[id] then
          for i, v in ipairs(dimensions[id].texts3d) do
             if v == text then
                table.remove(dimensions[id].texts3d, i)
                break
             end
         end
      end
   end
end

function AddPlayerInDimension(ply, id)
    if dimensions[id] then
       local hat_obj = GetPlayerPropertyValue(ply, "HatObject")
       if hat_obj then
          AddObjectInDimension(hat_obj, id)
       end
       local no_needtoinsert = ResetPlayerDimension(ply, false, id)
       if not no_needtoinsert then
          table.insert(dimensions[id].players, ply)
       end
       --print(GetPlayerName(ply) .. " in dimension " .. tostring(id))
       SetPlayerDimension(ply, id)
    end
    return false
end

function AddObjectInDimension(obj, id)
   if dimensions[id] then
      ResetObjectDimension(obj)
      table.insert(dimensions[id].objects, obj)
      SetObjectDimension(obj, id)
   end
   return false
end

function AddVehicleInDimension(veh, id)
   if dimensions[id] then
      ResetVehicleDimension(veh)
      table.insert(dimensions[id].vehicles, veh)
      SetVehicleDimension(veh, id)
   end
   return false
end

function AddPickupInDimension(pid, id)
   if dimensions[id] then
      ResetPickupDimension(pid)
      table.insert(dimensions[id].pickups, pid)
      SetPickupDimension(pid, id)
   end
   return false
end

function AddNPCInDimension(npc, id)
   if dimensions[id] then
      ResetNPCDimension(npc)
      table.insert(dimensions[id].npcs, npc)
      SetNPCDimension(npc, id)
   end
   return false
end

function AddDoorInDimension(door, id)
   if dimensions[id] then
      ResetDoorDimension(door)
      table.insert(dimensions[id].doors, door)
      SetDoorDimension(door, id)
   end
   return false
end

function AddText3DInDimension(text, id)
   if dimensions[id] then
      ResetText3DDimension(text)
      table.insert(dimensions[id].texts3d, text)
      SetText3DDimension(text, id)
   end
   return false
end

function GetDimensionPlayers(id)
    if dimensions[id] then
        return dimensions[id].players
    end
    return false
end

function GetDimensionObjects(id)
   if dimensions[id] then
       return dimensions[id].objects
   end
   return false
end

function GetDimensionVehicles(id)
   if dimensions[id] then
       return dimensions[id].vehicles
   end
   return false
end

function GetDimensionPickups(id)
   if dimensions[id] then
       return dimensions[id].pickups
   end
   return false
end

function GetDimensionNPCS(id)
   if dimensions[id] then
       return dimensions[id].npcs
   end
   return false
end

function GetDimensionDoors(id)
   if dimensions[id] then
       return dimensions[id].doors
   end
   return false
end

function GetDimensionTexts3D(id)
   if dimensions[id] then
       return dimensions[id].texts3d
   end
   return false
end

function IsDimension(id)
   if dimensions[id] then
      return true
   end
   return false
end

AddEvent("OnPackageStart",function()
    local default_dim_id = CreateDimension(default_dimension)
    local IsDefault = false
    for i,v in ipairs(GetAllPackages()) do
       if v == "default" then
          IsDefault = true
          break
       end
    end
    if not IsDefault then
       ServerExit("Default package needed, need to be loaded before online")
    else
        for i,v in ipairs(GetAllDoors()) do
           AddDoorInDimension(v, default_dim_id)
        end
    end
end)

AddEvent("OnPlayerQuit",function(ply)
    local hat_obj = GetPlayerPropertyValue(ply, "HatObject")
    if hat_obj then
       ResetObjectDimension(hat_obj)
       DestroyObject(hat_obj)
    end
    ResetPlayerDimension(ply, true)
end)