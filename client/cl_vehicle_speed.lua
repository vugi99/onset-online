veh_speed_textbox = nil

AddEvent("OnPlayerLeaveVehicle", function(ply, veh, seat)
    if ply == GetPlayerId() then
        SetTextBoxText(veh_speed_textbox, "")
    end
end)

local function update_veh_speed()
   local veh = GetPlayerVehicle(GetPlayerId())
   if (veh ~= 0 and veh and not IsInARace) then
      SetTextBoxText(veh_speed_textbox, tostring(math.floor(GetVehicleForwardSpeed(veh) + 0.5)) .. " km/h")
   end
end

AddEvent("OnPackageStart", function()
    local ScreenX, ScreenY = GetScreenSize()
    veh_speed_textbox = CreateTextBox(ScreenX - 75, ScreenY - 35, "", "left")
    CreateTimer(update_veh_speed, vehicle_speed_update_ms)
end)