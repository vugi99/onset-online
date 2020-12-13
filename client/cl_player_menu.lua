

IsInPlayerMenuUI = false
local WaitingForFriendsResponse = false
_playtime_text = nil

function LeavePlayerMenuUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInPlayerMenuUI = false
    _playtime_text = nil
end

function AnimationKeysMenuUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 550) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX + 400) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local selected_anim

    local dialog = UIDialog()
    dialog.setTitle("Animations Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        if selected_anim then
           CallRemoteEvent("PlayAnimationPMENU", "STOP")
        end
        LeavePlayerMenuUI()
    end)

    local Key_text = UIText()
    Key_text.setContent("Please select a key to assign")
    Key_text.appendTo(dialog)

    local KeysList = UIOptionList()
    for i, v in pairs(AnimationsKeys) do
        KeysList.appendOption(i - 1, v[1])
    end
    KeysList.appendTo(dialog)
    local selected_key
    KeysList.onChange(function(obj)
        selected_key = obj.getValue()[1] + 1
    end)

    local Anim_text = UIText()
    Anim_text.setContent("Please select an animation")
    Anim_text.appendTo(dialog)

    local AnimationsList = UIOptionList()
    for i, v in pairs(_Animations) do
        AnimationsList.appendOption(i - 1, v)
    end
    AnimationsList.appendTo(dialog)
    AnimationsList.onChange(function(obj)
        selected_anim = obj.getValue()[1] + 1
        CallRemoteEvent("PlayAnimationPMENU", _Animations[selected_anim])
    end)

    local AssignButton = UIButton()
    AssignButton.setTitle("Assign")
    AssignButton.onClick(function(obj)
        if selected_key then
            if selected_anim then
               CallRemoteEvent("AssignAnimation", selected_key, selected_anim)
               CallRemoteEvent("PlayAnimationPMENU", "STOP")
               dialog.destroy()
               AnimationKeysMenuUI()
            else
                AddPlayerChat("Please select an animation")
            end
        else
            AddPlayerChat("Please Select a key")
        end
    end)
    AssignButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        if selected_anim then
           CallRemoteEvent("PlayAnimationPMENU", "STOP")
        end
        PlayerMenuUI()
    end)
    BackButton.appendTo(dialog)
end

function ResetDataUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Player Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePlayerMenuUI()
    end)

    local Anim_text = UIText()
    Anim_text.setContent('<p style="color:#FF0000";>WARNING : PRESSING THE BUTTON BELOW WILL RESET YOUR DATA ON THE SERVER</p>')
    Anim_text.appendTo(dialog)

    local ResetButton = UIButton()
    ResetButton.setTitle("RESET DATA")
    ResetButton.onClick(function(obj)
        LeavePlayerMenuUI()
        CallRemoteEvent("OnlineResetPlayerData")
    end)
    ResetButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        PlayerMenuUI()
    end)
    BackButton.appendTo(dialog)
end

function PlayerMenuUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Player Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        _playtime_text = nil
        LeavePlayerMenuUI()
    end)

    local PassiveButton = UIButton()
    PassiveButton.setTitle("Toggle Passive")
    PassiveButton.onClick(function(obj)
        TogglePassive()
    end)
    PassiveButton.appendTo(dialog)

    local FriendsButton = UIButton()
    FriendsButton.setTitle("Friends")
    FriendsButton.onClick(function(obj)
        WaitingForFriendsResponse = true
        dialog.destroy()
        CallRemoteEvent("GetFriendsForPlayerMenu")
    end)
    FriendsButton.appendTo(dialog)

    local AnimationsButton = UIButton()
    AnimationsButton.setTitle("Animations Menu")
    AnimationsButton.onClick(function(obj)
        dialog.destroy()
        _playtime_text = nil
        AnimationKeysMenuUI()
    end)
    AnimationsButton.appendTo(dialog)

    local Eat_Energy_barButton = UIButton()
    Eat_Energy_barButton.setTitle("Eat an energy bar (" .. tostring(_nb_energy_bars) .. " in inventory, will restore " .. tostring(grocery_energy_bar_health_given) .. " HP)")
    Eat_Energy_barButton.onClick(function(obj)
        if (_nb_energy_bars and _nb_energy_bars > 0) then
            if (GetPlayerHealth() < 100 and GetPlayerHealth() > 0) then
                _nb_energy_bars = _nb_energy_bars - 1
                CreateNotification("Grocery Store", "You ate an energy bar", 5000)
                CallRemoteEvent("EatEnergyBar")
                Eat_Energy_barButton.setTitle("Eat an energy bar (" .. tostring(_nb_energy_bars) .. " in inventory, will restore " .. tostring(grocery_energy_bar_health_given) .. " HP)")
                Eat_Energy_barButton.update()
            else
                AddPlayerChat("You can't eat energy bars when your have 100 HP or 0 HP")
            end
        else
            AddPlayerChat("You don't have energy bars")
        end
    end)
    Eat_Energy_barButton.appendTo(dialog)

    local ResetDataButton = UIButton()
    ResetDataButton.setTitle("Reset Data")
    ResetDataButton.onClick(function(obj)
        dialog.destroy()
        _playtime_text = nil
        ResetDataUI()
    end)
    ResetDataButton.appendTo(dialog)

    local Play_text = UIText()
    Play_text.setContent(ConvertPlayTimeToString())
    Play_text.appendTo(dialog)
    _playtime_text = Play_text

    if not IsInPlayerMenuUI then
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInPlayerMenuUI = true
    end
end

AddEvent("OnKeyPress", function(key)
   if (key == OnlineKeys.PLAYER_MENU_KEY and not IsInPlayerMenuUI and not IsInSpawnUI and not IsInGroceryUI and not WaitingForFriendsResponse) then
      PlayerMenuUI()
   end
end)

AddRemoteEvent("GetFriendsResponse", function(Online_friends, friends, friends_settings, friends_requests)
    if WaitingForFriendsResponse then
        WaitingForFriendsResponse = false
        FriendsUI(Online_friends, friends, friends_settings, friends_requests)
    end
end)