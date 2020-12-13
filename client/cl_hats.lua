
IsInHatsUI = false
Loading_Cam = false

function LeaveHatsUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    CallRemoteEvent("LeaveHatsStore")
    SetCameraLocation(0,0,0, false)
    SetCameraRotation(0,0,0, false)
    IsInHatsUI = false
    Loading_Cam = false
end

function HatsUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 400) / 2) .. "px"
    dialogPosition.left = ScreenX - 700 .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Hats Store")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveHatsUI()
    end)

    local hats_text = UIText()
    hats_text.setContent("Select a hat : ")
    hats_text.appendTo(dialog)

    local HatsList = UIOptionList()
    for i = Hats_Objects[1], Hats_Objects[2] do
        HatsList.appendOption(i-Hats_Objects[1], tostring(i-Hats_Objects[1]+1))
    end
    HatsList.appendTo(dialog)
    local selected = nil
    HatsList.onChange(function(obj)
        selected = obj.getValue()[1] + Hats_Objects[1]
        CallRemoteEvent("PreviewHat", selected)
    end)

    local BuyButton = UIButton()
    BuyButton.setTitle("Buy Hat (" .. tostring(Hats_Price) .. "$)")
    BuyButton.onClick(function(obj)
        if selected then
            if money >= Hats_Price then
                CallRemoteEvent("BuyHat", selected)
                dialog.destroy()
                LeaveHatsUI()
            end
        else
            AddPlayerChat("Please select a hat")
        end
    end)

    BuyButton.appendTo(dialog)

    Loading_Cam = true
    Delay(1500, function()
        if Loading_Cam then
            local x, y, z = GetPlayerBoneLocation(GetPlayerId(), "head")
            local fx, fy, fz = GetPlayerForwardVector(GetPlayerId())
            local h = GetPlayerHeading(GetPlayerId())
            local reversed_rotator = FRotator(0, h, 0) + FRotator(0, 180, 0)
            local reversed_h = reversed_rotator.Yaw

            local mult = 75
            SetCameraLocation(x + fx * mult, y + fy * mult, z + fz * mult, true)
            SetCameraRotation(0, reversed_h, 0, true)
        end
    end)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInHatsUI = true
end

AddEvent("OnPlayerHatsStoreAction",function(hittype, hitid, impactX, impactY, impactZ)
    if not IsInHatsUI then
        if money >= Hats_Price then
            local x, y, z = GetNPCLocation(hitid)
            local storeid
            for i, v in ipairs(Hats_Stores) do
                --AddPlayerChat(O_GetDistanceSquared2D(x, y, v[1][1], v[1][2]))
                if O_GetDistanceSquared2D(x, y, v[1][1], v[1][2]) < 100 then
                    storeid = i
                    break
                end
            end
            if storeid then
                CallRemoteEvent("EnterHatsStore", storeid)
                HatsUI()
            else
                CallRemoteEvent("ReceiveClientError", "Error : can't determine hats store id")
            end
        else
            CreateNotification("Hats Store", "You don't have enough money to buy a hat", 5000)
        end
    end
end)