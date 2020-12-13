
IsInRacingUI = false
IsInRacingMenuUI = false
_Racing_menu_dialog = nil
_dialogLobby = nil
_tbl_players_in_lobby = nil
_optionlistLobby = nil

function LeaveRacingUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInRacingUI = false
    _dialogLobby = nil
    _optionlistLobby = nil
    _tbl_players_in_lobby = nil
end

function RacingUI(create_lobby_race_id, lobbies)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Racing")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveRacingUI()
    end)

    if table_count(lobbies) > 0 then
        local Selectlobbytext = UIText()
        Selectlobbytext.setContent("Select a racing lobby : ")
        Selectlobbytext.appendTo(dialog)

        local LobbiesList = UIOptionList()
        for i, v in ipairs(lobbies) do
            LobbiesList.appendOption(i-1, "Lobby " .. tostring(v.id) .. ", Race " .. tostring(v.raceid) .. ", " .. tostring(table_count(v.players)) .. " / 16 players")
        end
        LobbiesList.appendTo(dialog)
        local selected
        LobbiesList.onChange(function(obj)
            selected = lobbies[math.floor(obj.getValue()[1])+1].id
        end)

        local JoinLobbyButton = UIButton()
        JoinLobbyButton.setTitle("Join Lobby")
        JoinLobbyButton.onClick(function(obj)
            if selected then
                dialog.destroy()
                CallRemoteEvent("JoinLobby", selected)
                for i,v in ipairs(activity_notifications) do
                    v[1].destroy()
                end
                activity_notifications = {}
            else
                AddPlayerChat("Please select a lobby")
            end
        end)
        JoinLobbyButton.appendTo(dialog)
    else
        local nolobbytext = UIText()
        nolobbytext.setContent("No racing Lobby or racing lobbies are full.")
        nolobbytext.appendTo(dialog)
    end

    local CreateLobbyButton = UIButton()
    CreateLobbyButton.setTitle("Create Lobby")
    CreateLobbyButton.onClick(function(obj)
        dialog.destroy()
        CallRemoteEvent("CreateLobby", create_lobby_race_id)
        for i,v in ipairs(activity_notifications) do
            v[1].destroy()
        end
        activity_notifications = {}
    end)
    CreateLobbyButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInRacingUI = true
end

function LobbyUI(lobby)
    _tbl_players_in_lobby = lobby.players
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 350) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Racing Lobby")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)
    _dialogLobby = dialog

    local LobbyIdText = UIText()
    LobbyIdText.setContent("Lobby " .. lobby.id)
    LobbyIdText.appendTo(dialog)

    local LobbyPlayers = UIOptionList()
    _optionlistLobby = LobbyPlayers
    for i,v in ipairs(lobby.players) do
       if v.ply == lobby.host then
          LobbyPlayers.appendOption(i-1, v.name .. " (host)")
       else
          LobbyPlayers.appendOption(i-1, v.name)
       end
    end
    LobbyPlayers.appendTo(dialog)



    if lobby.host == GetPlayerId() then
        local StartRaceButton = UIButton()
        StartRaceButton.setTitle("Start race " .. tostring(lobby.raceid))
        StartRaceButton.onClick(function(obj)
            dialog.destroy()
            LeaveRacingUI()
            LoadRacingGUI()
            CallRemoteEvent("StartLobbyRace")
        end)
        StartRaceButton.appendTo(dialog)
    end

    local LeaveLobbyButton = UIButton()
    LeaveLobbyButton.setTitle("Leave Lobby")
    LeaveLobbyButton.onClick(function(obj)
        dialog.destroy()
        LeaveRacingUI()
        CallRemoteEvent("LeaveLobby")
    end)
    LeaveLobbyButton.appendTo(dialog)
    
    if not IsInRacingUI then
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInRacingUI = true
    end
end

AddRemoteEvent("RaceFinished", function(place, money_won, xp_won, lobbytbl)
    DestroyRacingGUI()
    CreateNotification("Race", "You finished " .. tostring(place) .. ", you won " .. tostring(money_won) .. "$ and " .. tostring(xp_won) .. " xp", 10000)
    LobbyUI(lobbytbl)
end)

AddRemoteEvent("PlayerLeftLobby", function(ply)
    if _tbl_players_in_lobby then
       for i,v in ipairs(_tbl_players_in_lobby) do
          if v.ply == ply then
             _optionlistLobby.removeOption(i-1)
             table.remove(_tbl_players_in_lobby, i)
          end
       end
    end
end)

AddRemoteEvent("PlayerJoinedLobby", function(playertbl)
    if _tbl_players_in_lobby then
       table.insert(_tbl_players_in_lobby, playertbl)
       _optionlistLobby.appendOption(table_count(_tbl_players_in_lobby) - 1, playertbl.name)
       _optionlistLobby.update()
    end
end)

AddRemoteEvent("LobbyLeft", function(loadrgui)
    if _dialogLobby then
       _dialogLobby.destroy()
       LeaveRacingUI()
    end
    if loadrgui then
       LoadRacingGUI()
    end
end)

AddRemoteEvent("JoinLobbyResponse", function(lobbytbl)
    if lobbytbl then
        LobbyUI(lobbytbl)
    else
        CreateNotification("Racing", "You can't join this lobby (No longer opened or full of players)", 5000)
        LeaveRacingUI()
    end
end)

AddRemoteEvent("SendRacingLobbies", function(race_id, lobbies)
    if (not IsInARace and not IsInRacingUI) then
       RacingUI(race_id, lobbies)
    end
end)

AddEvent("OnJoinActivityRacingLobby", function(id)
    if (not IsInARace and not IsInRacingUI) then
        CallRemoteEvent("JoinLobby", id)
    end
end)

function LeaveRacingMenuUI()
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    IsInRacingMenuUI = false
    _Racing_menu_dialog = nil
end

function RacingMenuUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Racing Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    _Racing_menu_dialog = dialog
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveRacingMenuUI()
    end)
    
    local LeaveLobbyButton2 = UIButton()
    LeaveLobbyButton2.setTitle("Leave Lobby")
    LeaveLobbyButton2.onClick(function(obj)
        dialog.destroy()
        LeaveRacingMenuUI()
        CallRemoteEvent("LeaveLobby")
        DestroyRacingGUI()
        EndOfRace()
    end)
    LeaveLobbyButton2.appendTo(dialog)

    ShowMouseCursor(true)
    SetInputMode(input_while_in_ui)
    IsInRacingMenuUI = true
end

AddEvent("OnKeyPress", function(key)
    if key == OnlineKeys.LEAVE_MENU_KEY then
       if (IsInARace and not IsInRacingMenuUI) then
          RacingMenuUI()
       end
    end
end)