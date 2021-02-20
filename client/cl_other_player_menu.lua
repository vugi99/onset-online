
IsInOtherPlayerUI = false
IsInDuel = false
IsInDuelMenuUI = false
_d_menu_dialog = nil
DuelEnemyWaypoint = nil

function LeaveOtherPlayerUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInOtherPlayerUI = false
end

function LeaveDuelMenuUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInDuelMenuUI = false
    _d_menu_dialog = nil
end

function OtherPlayerUI(ply)
    local plyname = GetPlayerName(ply)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle(plyname .. " Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveOtherPlayerUI()
    end)

    local RequestButton = UIButton()
    RequestButton.setTitle("Send Friend Request to " .. plyname)
    RequestButton.onClick(function(obj)
        if (IsValidPlayer(ply) and GetPlayerName(ply) == plyname) then -- the player is maybe a new player ... , this won't work if they have the same name
            dialog.destroy()
            LeaveOtherPlayerUI()
            CallRemoteEvent("SendFriendRequest", ply)
        end
    end)
    RequestButton.appendTo(dialog)

    local DuelButton = UIButton()
    DuelButton.setTitle("Ask " .. plyname .. " for a duel")
    DuelButton.onClick(function(obj)
        if not InHeistPhase then
            if not InBunkerMission then
                if (IsValidPlayer(ply) and GetPlayerName(ply) == plyname) then -- the player is maybe a new player ... , this won't work if they have the same name
                    dialog.destroy()
                    LeaveOtherPlayerUI()
                    CallRemoteEvent("AskForDuel", ply)
                else
                    AddPlayerChat("Player invalid")
                    dialog.destroy()
                    LeaveOtherPlayerUI()
                end
            else
                CreateNotification("Bunker", "You can't do a duel while doing a bunker mission", 5000)
            end
        else
            CreateNotification("Heist", "You can't do a duel while being in a heist", 5000)
        end
    end)
    DuelButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInOtherPlayerUI = true
end

function DuelMenuUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    _d_menu_dialog = dialog
    dialog.setTitle("Duel Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveDuelMenuUI()
    end)

    local LeaveDuelButton = UIButton()
    LeaveDuelButton.setTitle("Leave Duel")
    LeaveDuelButton.onClick(function(obj)
        if IsInDuel then
           dialog.destroy()
           LeaveDuelMenuUI()
           CallRemoteEvent("PlayerLeaveDuel")
        end
    end)
    LeaveDuelButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInDuelMenuUI = true
end

AddEvent("OnPlayerActionOnAnotherPlayer", function(hittype, hitid, impactX, impactY, impactZ)
    if (not IsInOtherPlayerUI and not IsInPlayerMenuUI and not IsInDuel) then
       OtherPlayerUI(hitid)
    end
end)

AddEvent("OnDuelAccept", function(plyduel)
    CallRemoteEvent("OnPlayerAcceptDuel", plyduel[1], plyduel[2])
end)

AddRemoteEvent("DuelStarted", function(index, myspawnindex)
    IsInDuel = true
    local e_spawn_i
    SetPassive(false)
    LockPassive(true)
    if myspawnindex == 1 then
       e_spawn_i = 2
    else
        e_spawn_i = 1
    end
    DuelEnemyWaypoint = CreateWaypoint(duels_locations[index][e_spawn_i][1], duels_locations[index][e_spawn_i][2], duels_locations[index][e_spawn_i][3], "Enemy Spawn")
    CreateNotification("Duel", "Duel Started", 5000)
end)

AddRemoteEvent("DuelFinished", function(left, money_won)
    IsInDuel = false
    LockPassive(false)
    CancelAimImmediately()
    SetIgnoreMoveInput(true)
    Delay(4000, function()
        SetIgnoreMoveInput(false)
    end)
    if _d_menu_dialog then
       _d_menu_dialog.destroy()
       LeaveDuelMenuUI()
    end
    if DuelEnemyWaypoint then
       DestroyWaypoint(DuelEnemyWaypoint)
       DuelEnemyWaypoint = nil
    end
    if not left then
        if money_won then
            CreateNotification("Duel", "You won the duel and won " .. tostring(money_won) .. "$", 15000)
        else
            CreateNotification("Duel", "You lost the duel", 10000)
        end
    else
        CreateNotification("Duel", "Duel Left", 10000)
    end
end)

AddEvent("OnKeyPress", function(key)
    if (key == OnlineKeys.LEAVE_MENU_KEY and IsInDuel and not IsInDuelMenuUI) then
       DuelMenuUI()
    end
end)

AddEvent("OnRenderHUD", function()
    if IsInDuel then
       DrawText(1, 350, "Press " .. OnlineKeys.LEAVE_MENU_KEY .. " to open duel menu")
    end
end)