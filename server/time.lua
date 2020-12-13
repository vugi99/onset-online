
local curtime = start_time
local time_timer = nil

function UpdateTime()
   curtime = curtime + time_update_value
   if curtime > 24 then
      curtime = curtime - 24
   end
   --print(curtime)
end

AddEvent("OnPackageStart",function()
    if (start_time >= 0 and start_time <= 24 and time_update_value < 24 and time_update_value > 0 and not time_locked) then
       time_timer = CreateTimer(UpdateTime, time_update_ms)
    end
end)

AddEvent("OnPlayerJoin",function(ply)
    if time_timer then
       CallRemoteEvent(ply, "SetTime", curtime, false)
    else
       CallRemoteEvent(ply, "SetTime", curtime, true)
    end
end)

AddRemoteEvent("ToggleTimeStateServer", function(ply)
    if IsAdmin(ply) then
       if time_timer then
           DestroyTimer(time_timer)
           time_timer = nil
           for i, v in ipairs(GetAllPlayers()) do
              CallRemoteEvent(v, "SetTimeStateClient", curtime, false)
           end
       else
          time_timer = CreateTimer(UpdateTime, time_update_ms)
          for i, v in ipairs(GetAllPlayers()) do
             CallRemoteEvent(v, "SetTimeStateClient", curtime, true)
          end
       end
    end
end)

AddRemoteEvent("SetTimeServer", function(ply, time)
    if IsAdmin(ply) then
       curtime = time
       for i, v in ipairs(GetAllPlayers()) do
          CallRemoteEvent(v, "SetTimeClient", curtime)
       end
    end
end)