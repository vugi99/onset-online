
local notifications = {}
activity_notifications = {}

local y_dist = 130
local y_dist_activity = 180

function UpdateNotificationsPos(deleted_notif_posy)
   local ScreenX, ScreenY = GetScreenSize()
   for i,v in ipairs(notifications) do
      if v[2] < deleted_notif_posy then
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor(v[2] + y_dist) .. "px"
        dialogPosition.left = math.floor(ScreenX - 280) .. "px !important"
        dialogPosition.width = "250px"
        v[1].setCSS(dialogPosition)
        v[1].update()
        v[2] = v[2] + y_dist
      end
   end
end

function CreateNotification(title, content, timeout)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor(ScreenY - y_dist*(#notifications+1)) .. "px"
    dialogPosition.left = math.floor(ScreenX - 280) .. "px !important"
    dialogPosition.width = "250px"

    local dialog = UIDialog()
    dialog.setTitle(title)
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)

    local text = UIText()
    text.setContent(content)
    text.appendTo(dialog)
    table.insert(notifications, {dialog, ScreenY - y_dist*(#notifications+1)})
    Delay(timeout,function()
        for i,v in ipairs(notifications) do
           if v[1] == dialog then
              table.remove(notifications, i)
              UpdateNotificationsPos(v[2])
              break
           end
        end
        dialog.destroy()
    end)
end
AddRemoteEvent("CreateNotification", CreateNotification)

function UpdateActivityNotificationsPos(deleted_notif_posy)
    local ScreenX, ScreenY = GetScreenSize()
    for i,v in ipairs(activity_notifications) do
       if v[2] < deleted_notif_posy then
         local dialogPosition = UICSS()
         dialogPosition.top = math.floor(v[2] + y_dist_activity) .. "px"
         dialogPosition.left = math.floor(ScreenX - 580) .. "px !important"
         dialogPosition.width = "250px"
         v[1].setCSS(dialogPosition)
         v[1].update()
         v[2] = v[2] + y_dist_activity
       end
    end
 end

function CreateActivityNotification(title, content, eventname, lobbyid, timeout)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor(ScreenY - y_dist_activity*(#activity_notifications+1)) .. "px"
    dialogPosition.left = math.floor(ScreenX - 580) .. "px !important"
    dialogPosition.width = "250px"

    local dialog = UIDialog()
    dialog.setTitle(title)
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)

    local text = UIText()
    text.setContent(content)
    text.appendTo(dialog)

    local JoinActivityButton = UIButton()
    JoinActivityButton.setTitle("Join")
    JoinActivityButton.onClick(function(obj)
        if (GetPlayerVehicle(GetPlayerId()) == 0 and not IsInRacingUI and not IsInARace and not IsInDuel and not InHeistPhase and not IsTraining and not InBunkerMission) then
            for i,v in ipairs(activity_notifications) do
                v[1].destroy()
            end
            activity_notifications = {}
            CallEvent(eventname, lobbyid)
        else
            AddPlayerChat("You can't join this activity (in a car maybe?)")
        end
    end)
    JoinActivityButton.appendTo(dialog)

    table.insert(activity_notifications, {dialog, ScreenY - y_dist_activity*(#activity_notifications+1)})
    Delay(timeout,function()
        for i,v in ipairs(activity_notifications) do
           if v[1] == dialog then
              table.remove(activity_notifications, i)
              UpdateActivityNotificationsPos(v[2])
              dialog.destroy()
              break
           end
        end
    end)
end
AddRemoteEvent("CreateActivityNotification", CreateActivityNotification)

--[[AddEvent("OnKeyPress",function(key)
    if key == "G" then
        CreateNotification("1", "1", 5000)
        CreateNotification("2", "2", 10000)
        CreateNotification("3", "3", 7500)
        CreateNotification("4", "4", 15000)
    end
end)

AddEvent("OnKeyPress",function(key)
    if key == "G" then
        CreateActivityNotification("1", "1", "testt", 1, 5000)
        CreateActivityNotification("2", "2", "testt", 1, 10000)
        CreateActivityNotification("3", "3", "testt", 1, 7500)
        CreateActivityNotification("4", "4", "testt", 1, 15000)
    end
end)]]--