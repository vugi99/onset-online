
curtime = nil
local time_textbox = nil
time_timer_client = nil
local time_initialized = false

function CreateTimeTextBox()
   if time_textbox then
      DestroyTextBox(time_textbox)
   end
   time_textbox = CreateTextBox(0, 325, "Time : " .. tostring(math.floor(curtime*10+0.5)/10))
end

function UpdateClientTime()
    curtime = curtime + time_update_value
    if curtime > 24 then 
       curtime = curtime - 24
    end
    SetTime(curtime)
    if _time_text_admin_ui then
       _time_text_admin_ui.setContent("Current Time : " .. tostring(math.floor(curtime*10+0.5)/10))
       _time_text_admin_ui.update()
    end
    CreateTimeTextBox()
end

AddRemoteEvent("SetTime",function(time, time_locked_server)
    time_initialized = true
    curtime = time
    SetTime(curtime)
    CreateTimeTextBox()
    if not time_locked_server then
       time_timer_client = CreateTimer(UpdateClientTime, time_update_ms)
    end
end)

AddRemoteEvent("SetTimeStateClient", function(time, state)
   if time_initialized then
      curtime = time
      SetTime(curtime)
      CreateTimeTextBox()
      if (not state and time_timer_client) then
         DestroyTimer(time_timer_client)
         time_timer_client = nil
      end
      if (state and not time_timer_client) then
         time_timer_client = CreateTimer(UpdateClientTime, time_update_ms)
      end
      if (not state and _time_state_text) then
         _time_state_text.setContent("Time State : Locked")
         _time_state_text.update()
      end
      if (state and _time_state_text) then
         _time_state_text.setContent("Time State : Working")
         _time_state_text.update()
      end
   end
end)

AddRemoteEvent("SetTimeClient", function(time)
    curtime = time
    SetTime(curtime)
    CreateTimeTextBox()
    if _time_text_admin_ui then
       _time_text_admin_ui.setContent("Current Time : " .. tostring(math.floor(curtime*10+0.5)/10))
       _time_text_admin_ui.update()
    end
end)