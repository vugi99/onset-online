
IsInSpecialVehiclesUI = false
_special_colorpicker = nil
_special_spawn_dialog = nil
local WaitingForSpawnConfirmation = false

function LeaveSpecialVehiclesUI(just_bought)
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    if not just_bought then
       CallRemoteEvent("LeaveSpecialUI")
    end
    IsInSpecialVehiclesUI = false
    _special_colorpicker = nil
    _special_spawn_dialog = nil
    SetCameraLocation(0, 0, 0, false)
    SetCameraRotation(0, 0, 0, false)
end

local function CalculateCameraLocationAndRotation(stid)
   local fx, fy, fz = RotationToVector(0, specials_vehicles_stores[stid].vehicle_show_rot, 0)
   local x, y, z = specials_vehicles_stores[stid].vehicle_show_pos[1], specials_vehicles_stores[stid].vehicle_show_pos[2], specials_vehicles_stores[stid].vehicle_show_pos[3]
   local camx, camy, camz = x + fx * special_spawn_camera_distance, y + fy * special_spawn_camera_distance, z + 250
   local camrotx, camroty, camrotz = VectorToRotation(fx * -1, fy * -1, fz * -1)
   return camx, camy, camz, -15, camroty
end

--[[local function GetStoreId()
   local x, y, z = GetPlayerLocation()
   local nearnpc
   local neardist
   for i, v in ipairs(GetStreamedNPC()) do
      local x2, y2, z2 = GetNPCLocation(v)
      local dist = GetDistanceSquared3D(x, y, z, x2, y2, z2)
      if not neardist then
         neardist = dist
         nearnpc = v
      elseif neardist > dist then
         neardist = dist
         nearnpc = v
      end
   end
   if nearnpc then
      local x, y, z = GetNPCLocation(nearnpc)
      local nearstore
      local neardistt
      for i, v in ipairs(specials_vehicles_stores) do
         local dist = GetDistanceSquared3D(x, y, z, v.npc[1], v.npc[2], v.npc[3])
         if not neardistt then
            neardistt = dist
            nearstore = i
         elseif neardistt > dist then
            neardistt = dist
            nearstore = i
         end
      end
      return nearstore
   end
end]]--

function BuySpecialVehiclesUI(vehicles, storeid)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 400) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX + 450) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Special Vehicles")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveSpecialVehiclesUI()
    end)

    local Buy_Vehicles_text = UIText()
    Buy_Vehicles_text.setContent("Please choose a vehicle to buy : ")
    Buy_Vehicles_text.appendTo(dialog)

    local VehiclesList = UIOptionList()
    local list = {}
    for i, v in ipairs(special_vehicles) do
        local good = true
        for i2, v2 in ipairs(vehicles) do
           if v2.model == v[1] then
              good = false
           end
        end
        if good then
           table.insert(list, v)
           VehiclesList.appendOption(table_count(list) - 1, tostring(v[1]) .. ", price : " .. tostring(v[2]))
        end
    end
    VehiclesList.appendTo(dialog)
    local selected_veh
    VehiclesList.onChange(function(obj)
        selected_veh = list[obj.getValue()[1] + 1]
        CallRemoteEvent("ShowSpecialVehicle", selected_veh[1], storeid)
    end)

    local colortext = UIText()
    colortext.setContent("Select a color : ")
    colortext.appendTo(dialog)

    local ColorPosition = UICSS()
    ColorPosition.left = "300px !important"

    local ColorPicker = UIColorPicker()
    _special_colorpicker = ColorPicker
    ColorPicker.onChange(function(obj, value)
        local r, g, b, a = obj.getValueAsRGBA()
        local veh
        for i, v in ipairs(GetStreamedVehicles()) do
            veh = v
           break
        end
        if veh then
           SetVehicleColor(veh, RGB(r, g, b, a * 255))
        end
    end)
    ColorPicker.setCSS(ColorPosition)
    ColorPicker.appendTo(dialog)

    local spacertext = UIText()
    spacertext.setContent(" <br> ")
    spacertext.appendTo(dialog)

    local BuySpeButton = UIButton()
    BuySpeButton.setTitle("Buy")
    BuySpeButton.onClick(function(obj)
        if selected_veh then
            if money >= selected_veh[2] then
                dialog.destroy()
                LeaveSpecialVehiclesUI(true)
                local r, g, b, a = ColorPicker.getValueAsRGBA()
                CallRemoteEvent("BuySpecialVehicle", selected_veh[1], r, g, b, a * 255)
            else
                AddPlayerChat("Not enough money")
            end
        else
            AddPlayerChat("Please select a vehicle")
        end
    end)
    BuySpeButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        _special_colorpicker = nil
        SetCameraLocation(0, 0, 0, false)
        SetCameraRotation(0, 0, 0, false)
        dialog.destroy()
        SpecialVehiclesUI(vehicles, storeid, true)
    end)
    BackButton.appendTo(dialog)

    local camx, camy, camz, camrotx, camroty = CalculateCameraLocationAndRotation(storeid)
    SetCameraLocation(camx, camy, camz, true)
    SetCameraRotation(camrotx, camroty, 0, true)
end

function SpawnSpecialVehicleUI(vehicles, storeid)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX + 450) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    _special_spawn_dialog = dialog
    dialog.setTitle("Special Vehicles")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveSpecialVehiclesUI()
    end)

    local Spawn_Vehicles_text = UIText()
    Spawn_Vehicles_text.setContent("Please choose a vehicle to spawn : ")
    Spawn_Vehicles_text.appendTo(dialog)

    local VehiclesList = UIOptionList()
    for i, v in ipairs(vehicles) do
        VehiclesList.appendOption(i - 1, tostring(v.model))
    end
    VehiclesList.appendTo(dialog)
    local selected_veh
    VehiclesList.onChange(function(obj)
        selected_veh = obj.getValue()[1] + 1
        CallRemoteEvent("ShowSpecialVehicleSpawn", selected_veh, storeid)
    end)

    local SpawnSpeVehButton = UIButton()
    SpawnSpeVehButton.setTitle("Spawn Special Vehicle")
    SpawnSpeVehButton.onClick(function(obj)
        if selected_veh then
            if not WaitingForSpawnConfirmation then
                WaitingForSpawnConfirmation = true
                CallRemoteEvent("SpawnSpecialVehicle", storeid)
            else
                AddPlayerChat("Please wait, spawning vehicle")
            end
        else
            AddPlayerChat("Please select a special vehicle to spawn")
        end
    end)
    SpawnSpeVehButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        _special_spawn_dialog = nil
        dialog.destroy()
        SetCameraLocation(0, 0, 0, false)
        SetCameraRotation(0, 0, 0, false)
        SpecialVehiclesUI(vehicles, storeid, true)
    end)
    BackButton.appendTo(dialog)

    local camx, camy, camz, camrotx, camroty = CalculateCameraLocationAndRotation(storeid)
    SetCameraLocation(camx, camy, camz, true)
    SetCameraRotation(camrotx, camroty, 0, true)
end

function SpecialVehiclesUI(vehicles, storeid, from_back)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Special Vehicles")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveSpecialVehiclesUI()
    end)

    if table_count(vehicles) < table_count(special_vehicles) then
        local BuyVehiclesButton = UIButton()
        BuyVehiclesButton.setTitle("Buy Special vehicles")
        BuyVehiclesButton.onClick(function(obj)
            dialog.destroy()
            BuySpecialVehiclesUI(vehicles, storeid)
        end)
        BuyVehiclesButton.appendTo(dialog)
    end

    if table_count(vehicles) > 0 then
        local SpawnVehiclesButton = UIButton()
        SpawnVehiclesButton.setTitle("Spawn Special vehicles")
        SpawnVehiclesButton.onClick(function(obj)
            dialog.destroy()
            SpawnSpecialVehicleUI(vehicles, storeid)
        end)
        SpawnVehiclesButton.appendTo(dialog)
    end

    if not from_back then
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
    end
end

AddEvent("OnVehicleStreamIn", function(veh)
    if (IsInSpecialVehiclesUI and _special_colorpicker) then
        local r, g, b, a = _special_colorpicker.getValueAsRGBA()
        SetVehicleColor(veh, RGB(r, g, b, a*255))
    end
end)

AddRemoteEvent("ReceiveSpecialVehicles", function(vehicles, storeid)
    SpecialVehiclesUI(vehicles, storeid)
end)

AddRemoteEvent("SpecialVehicleSpawnConfirmation", function(success)
    if success then
        WaitingForSpawnConfirmation = false
        _special_spawn_dialog.destroy()
        LeaveSpecialVehiclesUI(true)
    else
        Delay(special_vehicles_spawn_cooldown_if_spawn_failed_ms, function()
            WaitingForSpawnConfirmation = false
            CreateNotification("Special Vehicles", "Failed to spawn the special vehicle", 5000)
        end)
    end
end)

AddEvent("OnPlayerSpecialVehiclesAction", function(hittype, hitid, impactX, impactY, impactZ)
    if not IsInSpecialVehiclesUI then
       IsInSpecialVehiclesUI = true
       CallRemoteEvent("GetSpecialVehicles", hitid)
    end
end)