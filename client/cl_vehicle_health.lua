

--[[ UIProgressBar() Is not finished ...
local v_health_dialog
local _p_bar


AddEvent("OnPlayerEnterVehicle", function(ply, veh, seat)
    if ply == GetPlayerId() then
       if v_health_dialog then
          v_health_dialog.destroy()
          v_health_dialog = nil
          _p_bar = nil
       end
       local ScreenX, ScreenY = GetScreenSize()
       local dialogPosition = UICSS()
       dialogPosition.top = "100px"
       dialogPosition.left = math.floor(ScreenX - 250) .. "px !important"
       dialogPosition.width = "250px"
       dialogPosition.height = "50px"

       local dialog = UIDialog()
       dialog.appendTo(UIFramework)
       dialog.setCSS(dialogPosition)
       dialog.setCanClose(false)

       local v_health = GetVehicleHealth(veh)
       local p_bar = UIProgressBar()
       _p_bar = p_bar
       p_bar.setValue((v_health*100)/5000)
       p_bar.setTitle(tostring(v_health) .. " / 5000")
       p_bar.appendTo(dialog)
    end
end)

AddEvent("OnPlayerLeaveVehicle", function(ply, veh, seat)
    if ply == GetPlayerId() then
        if v_health_dialog then
            v_health_dialog.destroy()
            v_health_dialog = nil
            _p_bar = nil
        end
    end
end)

function update_p_bar()
   local veh = GetPlayerVehicle(GetPlayerId())
   if veh ~= 0 then
      if _p_bar then
         local v_health = GetVehicleHealth(veh)
         _p_bar.setValue((v_health*100)/5000)
         _p_bar.update()
      end
   end
end

AddEvent("OnPackageStart", function()
    CreateTimer(update_p_bar, vehicle_health_update_ms)
end)]]--

veh_health_textbox = nil

AddEvent("OnPlayerLeaveVehicle", function(ply, veh, seat)
    if ply == GetPlayerId() then
        SetTextBoxText(veh_health_textbox, "")
    end
end)

local function update_veh_health()
   local veh = GetPlayerVehicle(GetPlayerId())
   if (veh ~= 0 and veh and not IsInARace) then
      SetTextBoxText(veh_health_textbox, "Vehicle Health : " .. tostring(math.floor(GetVehicleHealth(veh) + 0.5)))
   end
end

AddEvent("OnPackageStart", function()
    local ScreenX, ScreenY = GetScreenSize()
    veh_health_textbox = CreateTextBox(ScreenX - 200, 90, "", "left")
    CreateTimer(update_veh_health, vehicle_health_update_ms)
end)