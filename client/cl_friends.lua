

-- Should be in cl_player_menu.lua but i decided to split the files

function FriendsListUI(Online_friends, friends, friends_settings, friends_requests)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Friends Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePlayerMenuUI()
    end)

    local FriendsList = UIOptionList()
    for i, v in ipairs(friends) do
        FriendsList.appendOption(i-1, "Friend " .. v.name .. ", SteamId : " .. tostring(v.steamid))
    end
    local selected = nil
    FriendsList.onChange(function(obj)
        selected = obj.getValue()[1] + 1
    end)
    FriendsList.appendTo(dialog)

    local RemoveFromFriendListButton = UIButton()
    RemoveFromFriendListButton.setTitle("Remove Friend")
    RemoveFromFriendListButton.onClick(function(obj)
        if selected then
            CallRemoteEvent("RemoveFriend", friends[selected].steamid)
            dialog.destroy()
            PlayerMenuUI()
        end
    end)
    RemoveFromFriendListButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        FriendsUI(Online_friends, friends, friends_settings, friends_requests)
    end)
    BackButton.appendTo(dialog)
end

function FriendsOnlineUI(Online_friends, friends, friends_settings, friends_requests)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 500) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Friends Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePlayerMenuUI()
    end)

    local comboContainer = UIContainer()
    comboContainer.setSizes({100,300})
    comboContainer.setDirection("horizontal")
    comboContainer.appendTo(dialog)

    local FriendsName = UIText()
    FriendsName.setContent("Name <br> ")
    FriendsName.appendTo(comboContainer)

    local FriendsSteamId = UIText()
    FriendsSteamId.setContent("SteamId <br> ")
    FriendsSteamId.appendTo(comboContainer)

    for i, v in ipairs(Online_friends) do
        FriendsName.setContent(FriendsName.getContent() .. tostring(v.name) .. " <br> ")
        FriendsSteamId.setContent(FriendsSteamId.getContent() .. tostring(v.steamid) .. " <br> ")
    end

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        FriendsUI(Online_friends, friends, friends_settings, friends_requests)
    end)
    BackButton.appendTo(dialog)
end

function FriendsSettingsUI(Online_friends, friends, friends_settings, friends_requests)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Friends Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePlayerMenuUI()
    end)

    for i, v in ipairs(friends_settings) do
        local nextsetting = v.setting + 1
        if nextsetting > table_count(Friend_Settings[v.settingid][2]) then
           nextsetting = 1
        end
        local SettingText = UIText()
        SettingText.setContent("Setting : " .. Friend_Settings[v.settingid][1])
        SettingText.appendTo(dialog)

        local SettingStateText = UIText()
        SettingStateText.setContent("State : " .. Friend_Settings[v.settingid][2][v.setting])
        SettingStateText.appendTo(dialog)

        local ChangeSettingButton = UIButton()
        ChangeSettingButton.setTitle("Change setting state to : " .. Friend_Settings[v.settingid][2][nextsetting])
        ChangeSettingButton.onClick(function(obj)
            CallRemoteEvent("ChangeFriendSetting", v.settingid, nextsetting)
            dialog.destroy()
            PlayerMenuUI()
        end)
        ChangeSettingButton.appendTo(dialog)
    end

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        FriendsUI(Online_friends, friends, friends_settings, friends_requests)
    end)
    BackButton.appendTo(dialog)
end

function FriendsRequestsUI(Online_friends, friends, friends_settings, friends_requests)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Friends Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePlayerMenuUI()
    end)

    local FriendsRequestsList = UIOptionList()
    for i, v in ipairs(friends_requests) do
        FriendsRequestsList.appendOption(i-1, "Name " .. v.name .. ", SteamId : " .. tostring(v.steamid))
    end
    local selected = nil
    FriendsRequestsList.onChange(function(obj)
        selected = obj.getValue()[1] + 1
    end)
    FriendsRequestsList.appendTo(dialog)

    local DenyFriendRequestButton = UIButton()
    DenyFriendRequestButton.setTitle("Deny Friend Request")
    DenyFriendRequestButton.onClick(function(obj)
        if selected then
            CallRemoteEvent("DenyFriendRequest", friends_requests[selected].steamid)
            dialog.destroy()
            PlayerMenuUI()
        end
    end)
    DenyFriendRequestButton.appendTo(dialog)

    local AcceptFriendRequestButton = UIButton()
    AcceptFriendRequestButton.setTitle("Accept Friend Request (the other player need to be connected on the player)")
    AcceptFriendRequestButton.onClick(function(obj)
        if selected then
            CallRemoteEvent("AcceptFriendRequest", friends_requests[selected].steamid)
            dialog.destroy()
            PlayerMenuUI()
        end
    end)
    AcceptFriendRequestButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        FriendsUI(Online_friends, friends, friends_settings, friends_requests)
    end)
    BackButton.appendTo(dialog)
end

function FriendsUI(Online_friends, friends, friends_settings, friends_requests)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Friends Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePlayerMenuUI()
    end)

    local friendscount = table_count(friends)

    local FriendsOnFriendsMax = UIText()
    FriendsOnFriendsMax.setContent(tostring(friendscount) .. " / " .. tostring(max_friends) .. " friends.")
    FriendsOnFriendsMax.appendTo(dialog)

    if friendscount > 0 then
        local FriendsListButton = UIButton()
        FriendsListButton.setTitle("Friends List")
        FriendsListButton.onClick(function(obj)
            dialog.destroy()
            FriendsListUI(Online_friends, friends, friends_settings, friends_requests)
        end)
        FriendsListButton.appendTo(dialog)

        if table_count(Online_friends) > 0 then
            local FriendsOnlineButton = UIButton()
            FriendsOnlineButton.setTitle("Friends Online")
            FriendsOnlineButton.onClick(function(obj)
                dialog.destroy()
                FriendsOnlineUI(Online_friends, friends, friends_settings, friends_requests)
            end)
            FriendsOnlineButton.appendTo(dialog)
        else
            local NoOnlineFriendsText = UIText()
            NoOnlineFriendsText.setContent("No friends are online")
            NoOnlineFriendsText.appendTo(dialog)
        end
    else
        local NoFriendsText = UIText()
        NoFriendsText.setContent("No friends, you can add friends by pressing " .. OnlineKeys.ACTION_KEY .. " on them.")
        NoFriendsText.appendTo(dialog)
    end

    local FriendsSettingsButton = UIButton()
    FriendsSettingsButton.setTitle("Friends Settings")
    FriendsSettingsButton.onClick(function(obj)
        dialog.destroy()
        FriendsSettingsUI(Online_friends, friends, friends_settings, friends_requests)
    end)
    FriendsSettingsButton.appendTo(dialog)

    if table_count(friends_requests) > 0 then
        if friendscount < max_friends then
            local FriendsRequestsButton = UIButton()
            FriendsRequestsButton.setTitle("Friends Requests")
            FriendsRequestsButton.onClick(function(obj)
                dialog.destroy()
                FriendsRequestsUI(Online_friends, friends, friends_settings, friends_requests)
            end)
            FriendsRequestsButton.appendTo(dialog)
        end
    else
        local NoFriendsRequestsText = UIText()
        NoFriendsRequestsText.setContent("No friends requests")
        NoFriendsRequestsText.appendTo(dialog)
    end

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        PlayerMenuUI()
    end)
    BackButton.appendTo(dialog)
end