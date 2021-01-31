
local trigger_pickups = {}


function CreatePickupTrigger(modelid, x, y, z, will_be_destroyed, overwrite_event)
   local pickup = CreatePickup(modelid, x, y, z)
   local tbl = {}
   tbl.id = pickup
   tbl.model = modelid
   tbl.destroy_next = will_be_destroyed
   tbl.overwrite_event = overwrite_event
   table.insert(trigger_pickups, tbl)
   return pickup
end

function DestroyPickupTrigger(pickup)
   for i, v in ipairs(trigger_pickups) do
      if v.id == pickup then
         DestroyPickup(pickup)
         table.remove(trigger_pickups, i)
      end
   end
end

AddEvent("OnPlayerPickupHit", function(ply, pickup)
    if GetPlayerVehicle(ply) == 0 then
        for i, v in ipairs(trigger_pickups) do
           if v.id == pickup then
              for i2, v2 in ipairs(pickups_triggers) do
                 if v2[1] == v.model then
                    if v.overwrite_event then
                        CallEvent(v.overwrite_event, ply, pickup)
                    else
                        CallEvent(v2[2], ply, pickup)
                    end
                    if v.destroy_next then
                        table.remove(trigger_pickups, i)
                        DestroyPickup(pickup)
                     end
                 end
              end
              break
           end
        end
    end
end)

AddEvent("OnDimensionDestroyed", function(id, name)
    for i,v in ipairs(GetDimensionPickups(id)) do
       for i2, v2 in ipairs(trigger_pickups) do
          if v2.id == v then
             table.remove(trigger_pickups, i2)
          end
       end
    end
end)
