
InHeistPhase = false
IsInStartHeistUI = false
local heist_waypoints = {}
local heist_objectives_textboxes = {}
local tbox_objectives
local gold_on_me = 0

IsInLeaveHeistUI = false

function LeaveStartHeistUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInStartHeistUI = false
end

function StartHeistUI(houseid, phase)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 400) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Heist")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveStartHeistUI()
    end)

    local heist_text = UIText()
    heist_text.setContent("Start an heist phase with all friends in the appartment")
    heist_text.appendTo(dialog)

    local StartButton = UIButton()
    if phase < table_count(heist_phases) then
        StartButton.setTitle("Start heist phase " .. tostring(phase + 1))
    else
        StartButton.setTitle("Start heist final phase")
    end
    StartButton.onClick(function(obj)
        dialog.destroy()
        LeaveStartHeistUI()
        CallRemoteEvent("StartHeistToServer", houseid)
    end)
    StartButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInStartHeistUI = true
end

AddRemoteEvent("StartHeistUI", function(houseid, phase)
    if not IsInStartHeistUI then
        StartHeistUI(houseid, phase)
    end
end)

AddRemoteEvent("HeistPhaseStarted", function(waypoints, textboxes)
    InHeistPhase = true
    SetPassive(false)
    LockPassive(true)
    if waypoints then
        for i, v in ipairs(waypoints) do
            local waypoint = CreateWaypoint(v[3], v[4], v[5], v[2])
            heist_waypoints[v[1]] = waypoint
        end
    end
    if textboxes then
        tbox_objectives = CreateTextBox(1, 500, "Objectives : ", "left")
        for i, v in ipairs(textboxes) do
            local textbox = CreateTextBox(1, 500 + 25 * i, v[2], "left")
            heist_objectives_textboxes[v[1]] = textbox
        end
    end
end)

AddRemoteEvent("ChangeHeistObjectives", function(waypoints, textboxes)
    if waypoints then
        for i, v in ipairs(waypoints) do
            if heist_waypoints[v[1]] then
                SetWaypointLocation(heist_waypoints[v[1]], v[3], v[4], v[5])
                SetWaypointText(heist_waypoints[v[1]], v[2])
            end
        end
    end
    if textboxes then
        for i, v in ipairs(textboxes) do
            if heist_objectives_textboxes[v[1]] then
                SetTextBoxText(heist_objectives_textboxes[v[1]], v[2])
            end
        end
    end
end)

AddRemoteEvent("HeistPhaseFinished", function(success)
    local text
    if success then
        text = "Heist phase finished"
    else
        text = "Heist phase failed"
    end
    CreateNotification("Heist", text, 10000)
    if tbox_objectives then
        DestroyTextBox(tbox_objectives)
    end
    for i, v in pairs(heist_waypoints) do
        DestroyWaypoint(v)
    end
    for i, v in pairs(heist_objectives_textboxes) do
        DestroyTextBox(v)
    end
    InHeistPhase = false
    heist_waypoints = {}
    heist_objectives_textboxes = {}
    tbox_objectives = nil
    gold_on_me = 0
    SetPassive(false)
    LockPassive(false)
end)

AddEvent("OnPlayerHeistFinalPhaseTakeMoney", function(hittype, hitid, impactX, impactY, impactZ)
    if InHeistPhase then
        if gold_on_me < heist_final_phase.money_taken_per_action then
            gold_on_me = heist_final_phase.money_taken_per_action
            CreateNotification("Heist", "Gold taken", 5000)
        else
            AddPlayerChat("You have already max gold on you, put it in the vehicle.")
        end
    end
end)

AddEvent("OnPlayerHeistFinalPhasePutMoney", function(hittype, hitid, impactX, impactY, impactZ) -- DON'T SELL THE FINAL PHASE HEIST VEHICLES.
    if InHeistPhase then
        if gold_on_me > 0 then
            CallRemoteEvent("HeistPutGold", gold_on_me)
            gold_on_me = 0
            CreateNotification("Heist", "Gold in the vehicle", 5000)
        else
            AddPlayerChat("You don't have gold on you")
        end
    end
end)

function LeaveLeaveHeistUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInLeaveHeistUI = false
end

function LeaveHeistUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 350) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Heist")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveLeaveHeistUI()
    end)

    local LeaveButton = UIButton()
    LeaveButton.setTitle("Leave Heist")
    LeaveButton.onClick(function(obj)
        dialog.destroy()
        LeaveLeaveHeistUI()
        CallRemoteEvent("LeaveHeist")
    end)
    LeaveButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInLeaveHeistUI = true
end

AddEvent("OnKeyPress", function(key)
    if (InHeistPhase and key == OnlineKeys.LEAVE_MENU_KEY and not IsInLeaveHeistUI) then
        LeaveHeistUI()
    end
end)

AddEvent("OnPlayerSpawn", function()
    if InHeistPhase then
        gold_on_me = 0
    end
end)
