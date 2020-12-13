
local IsAdmin = false
IsInAdminUI = false
_Last_Server_Vehicle_ID_client = nil
_time_text_admin_ui = nil
_time_state_text = nil

function LeaveAdminUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    _time_text_admin_ui = nil
    _time_state_text = nil
    IsInAdminUI = false
end

function PlayersAdminUI(Players)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 450) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Admin Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAdminUI()
    end)

    local Players_text = UIText()
    Players_text.setContent("Please select a player")
    Players_text.appendTo(dialog)

    local PlayersList = UIOptionList()
    for i, v in ipairs(Players) do
        PlayersList.appendOption(i-1, v.name .. " (" .. tostring(v.ply) .. ")")
    end
    PlayersList.appendTo(dialog)
    local selected = nil
    PlayersList.onChange(function(obj)
       selected = Players[math.floor(obj.getValue()[1]+1)].ply
    end)

    local KickButton = UIButton()
    KickButton.setTitle("Kick Player")
    KickButton.onClick(function(obj)
        if selected then
           dialog.destroy()
           LeaveAdminUI()
           CallRemoteEvent("KickPlayer", selected)
        else
            AddPlayerChat("Select a player")
        end
    end)
    KickButton.appendTo(dialog)

    local BanButton = UIButton()
    BanButton.setTitle("Ban Player")
    BanButton.onClick(function(obj)
        if selected then
           dialog.destroy()
           LeaveAdminUI()
           CallRemoteEvent("BanPlayer", selected)
        else
            AddPlayerChat("Select a player")
        end
    end)
    BanButton.appendTo(dialog)

    local TeleportButton = UIButton()
    TeleportButton.setTitle("Teleport to Player")
    TeleportButton.onClick(function(obj)
        if selected then
           CallRemoteEvent("TeleportToPlayer", selected)
        else
            AddPlayerChat("Select a player")
        end
    end)
    TeleportButton.appendTo(dialog)

    local TeleportButton2 = UIButton()
    TeleportButton2.setTitle("Teleport Player To me")
    TeleportButton2.onClick(function(obj)
        if selected then
           CallRemoteEvent("TeleportPlayerToMe", selected)
        else
            AddPlayerChat("Select a player")
        end
    end)
    TeleportButton2.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        AdminUI()
    end)
    BackButton.appendTo(dialog)
end

function VehiclesAdminUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 450) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Admin Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAdminUI()
    end)

    local Buy_Vehicles_text = UIText()
    Buy_Vehicles_text.setContent("Please choose a vehicle to spawn : ")
    Buy_Vehicles_text.appendTo(dialog)

    local VehiclesList = UIOptionList()
    for i = 1, _Last_Server_Vehicle_ID_client do
        VehiclesList.appendOption(i - 1, "Vehicle " .. i)
    end
    VehiclesList.appendTo(dialog)
    local selected_veh
    VehiclesList.onChange(function(obj)
        selected_veh = obj.getValue()[1] + 1
    end)

    local colortext = UIText()
    colortext.setContent("Select a color : ")
    colortext.appendTo(dialog)

    local ColorPosition = UICSS()
    ColorPosition.left = "300px !important"

    local ColorPicker = UIColorPicker()
    ColorPicker.setCSS(ColorPosition)
    ColorPicker.appendTo(dialog)

    local spacertext = UIText()
    spacertext.setContent(" <br> ")
    spacertext.appendTo(dialog)

    local BackFireButton = UICheckBox()
    BackFireButton.setTitle("Backfire")
    BackFireButton.setValue(false)
    local backfire = false
    BackFireButton.onClick(function(obj)
        backfire = not backfire
    end)
    BackFireButton.appendTo(dialog)

    local NitroButton = UICheckBox()
    NitroButton.setTitle("Nitro")
    NitroButton.setValue(false)
    local nitro = false
    NitroButton.onClick(function(obj)
        nitro = not nitro
    end)
    NitroButton.appendTo(dialog)

    local SpawnAdminVehButton = UIButton()
    SpawnAdminVehButton.setTitle("Spawn Vehicle")
    SpawnAdminVehButton.onClick(function(obj)
        if selected_veh then
            dialog.destroy()
            LeaveAdminUI()
            local r, g, b, a = ColorPicker.getValueAsRGBA()
            CallRemoteEvent("SpawnAdminVehicle", selected_veh, r, g, b, a * 255, backfire, nitro)
            CreateNotification("Admin", "You spawned vehicle " .. tostring(selected_veh), 5000)
        else
            AddPlayerChat("Please select a vehicle")
        end
    end)
    SpawnAdminVehButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        AdminUI()
    end)
    BackButton.appendTo(dialog)
end

function TimeUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Admin Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAdminUI()
    end)

    local timetext = UIText()
    _time_text_admin_ui = timetext
    timetext.setContent("Current Time : " .. tostring(math.floor(curtime*10+0.5)/10))
    timetext.appendTo(dialog)

    local timestatetext = UIText()
    _time_state_text = timestatetext
    if time_timer_client then
       timestatetext.setContent("Time State : Working")
    else
       timestatetext.setContent("Time State : Locked")
    end
    timestatetext.appendTo(dialog)

    local ToggleTimeState = UIButton()
    ToggleTimeState.setTitle("Toggle time state")
    ToggleTimeState.onClick(function(obj)
        CallRemoteEvent("ToggleTimeStateServer")
        CreateNotification("Admin", "Time State Toggled", 5000)
    end)
    ToggleTimeState.appendTo(dialog)

    local TimeInput = UITextField()
    TimeInput.setPlaceholder("Time")
    TimeInput.appendTo(dialog)

    local SetTimeButton = UIButton()
    SetTimeButton.setTitle("Set Time")
    SetTimeButton.onClick(function(obj)
        local timeinput = tonumber(TimeInput.getValue())
        if timeinput then
            if (timeinput >= 0 and timeinput <= 24) then
                CallRemoteEvent("SetTimeServer", timeinput)
                CreateNotification("Admin", "Time Changed to " .. tostring(timeinput), 5000)
            else
                AddPlayerChat("Time must be between 0 and 24")
            end
        else
            AddPlayerChat("Invalid Time")
        end
    end)
    SetTimeButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        _time_text_admin_ui = nil
        _time_state_text = nil
        AdminUI()
    end)
    BackButton.appendTo(dialog)
end

function TeleportToASpawnUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 300) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Admin Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAdminUI()
    end)

    local spawntext = UIText()
    spawntext.setContent("Select a spawn : ")
    spawntext.appendTo(dialog)

    local spawnList = UIOptionList()
    local index_spawn = 0
    local list = {}
    for k,v in pairs(spawns) do
        spawnList.appendOption(index_spawn, k)
        list[index_spawn + 1] = k
        index_spawn = index_spawn + 1
    end
    spawnList.appendTo(dialog)
    local selectedSpawn
    spawnList.onChange(function(obj)
        selectedSpawn = spawns[list[obj.getValue()[1]+1]]
    end)

    local TeleportButton = UIButton()
    TeleportButton.setTitle("Teleport")
    TeleportButton.onClick(function(obj)
        if selectedSpawn then
            dialog.destroy()
            LeaveAdminUI()
            CallRemoteEvent("TeleportAdmin", selectedSpawn.x, selectedSpawn.y, selectedSpawn.z)
        else
            AddPlayerChat("Please select a spawn")
        end
    end)
    TeleportButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        TeleportUI()
    end)
    BackButton.appendTo(dialog)
end

function TeleportToAPreciseLocationUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 300) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Admin Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAdminUI()
    end)

    local XInput = UITextField()
    XInput.setPlaceholder("X")
    XInput.appendTo(dialog)

    local YInput = UITextField()
    YInput.setPlaceholder("Y")
    YInput.appendTo(dialog)

    local ZInput = UITextField()
    ZInput.setPlaceholder("Z")
    ZInput.appendTo(dialog)

    local TeleportButton = UIButton()
    TeleportButton.setTitle("Teleport")
    TeleportButton.onClick(function(obj)
        local x, y, z = tonumber(XInput.getValue()), tonumber(YInput.getValue()), tonumber(ZInput.getValue())
        if (x and y and z) then
            dialog.destroy()
            LeaveAdminUI()
            CallRemoteEvent("TeleportAdmin", x, y, z)
        else
            AddPlayerChat("Invalid Values")
        end
    end)
    TeleportButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        TeleportUI()
    end)
    BackButton.appendTo(dialog)
end

function TeleportUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 275) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Admin Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAdminUI()
    end)

    local TeleportSpawn = UIButton()
    TeleportSpawn.setTitle("Teleport to a spawn")
    TeleportSpawn.onClick(function(obj)
        dialog.destroy()
        TeleportToASpawnUI()
    end)
    TeleportSpawn.appendTo(dialog)

    local TeleportSpawn = UIButton()
    TeleportSpawn.setTitle("Teleport to a precise location")
    TeleportSpawn.onClick(function(obj)
        dialog.destroy()
        TeleportToAPreciseLocationUI()
    end)
    TeleportSpawn.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        AdminUI()
    end)
    BackButton.appendTo(dialog)
end

function AdminUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 300) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Admin Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAdminUI()
    end)

    local NoclipButton = UIButton()
    NoclipButton.setTitle("Toggle Noclip")
    NoclipButton.onClick(function(obj)
        ToggleNoclip()
        CreateNotification("Noclip", "Noclip Toggled", 5000)
    end)
    NoclipButton.appendTo(dialog)

    local PlayersButton = UIButton()
    PlayersButton.setTitle("Players Options")
    PlayersButton.onClick(function(obj)
        CallRemoteEvent("GetServerPlayersAdmin")
        dialog.destroy()
    end)
    PlayersButton.appendTo(dialog)

    if (GetPlayerVehicle(GetPlayerId()) == 0 and _Last_Server_Vehicle_ID_client) then
        local VehiclesButton = UIButton()
        VehiclesButton.setTitle("Spawn An Admin Vehicle")
        VehiclesButton.onClick(function(obj)
            dialog.destroy()
            VehiclesAdminUI()
        end)
        VehiclesButton.appendTo(dialog)
    end

    local TimeButton = UIButton()
    TimeButton.setTitle("Time")
    TimeButton.onClick(function(obj)
        dialog.destroy()
        TimeUI()
    end)
    TimeButton.appendTo(dialog)

    local TeleportButton = UIButton()
    TeleportButton.setTitle("Teleport")
    TeleportButton.onClick(function(obj)
        dialog.destroy()
        TeleportUI()
    end)
    TeleportButton.appendTo(dialog)

    if not IsInAdminUI then
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInAdminUI = true
    end
end

AddRemoteEvent("SendPlayersAdmin", function(tbl)
    PlayersAdminUI(tbl)
end)

AddRemoteEvent("SendLastServerVehicleID", function(last)
    _Last_Server_Vehicle_ID_client = last
end)


AddEvent("OnKeyPress",function(key)
    if (key == OnlineKeys.ADMIN_KEY and IsAdmin and not IsInAdminUI) then
       AdminUI()
    end
end)

AddRemoteEvent("YouAreAdmin", function()
    IsAdmin = true
end)