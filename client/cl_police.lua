
IsPoliceman = false
IsCriminal = false
IsInJoinPoliceUI = false
IsInPoliceUI = false

function LeavePoliceUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInJoinPoliceUI = false
    IsInPoliceUI = false
end


function PoliceJoinUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Police")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePoliceUI()
    end)

    local Policetext = UIText()
    Policetext.setContent("As a Policeman you earn money by stopping criminals.")
    Policetext.appendTo(dialog)
    
    local JoinPoliceButton = UIButton()
    JoinPoliceButton.setTitle("Join Police")
    JoinPoliceButton.onClick(function(obj)
        IsPoliceman = true
        dialog.destroy()
        LeavePoliceUI()
        CallRemoteEvent("SetPoliceServer", true)
        CreateNotification("Police", "You are now a Policeman, press " .. OnlineKeys.POLICE_KEY .. " to open Police Menu", 5000)
    end)
    JoinPoliceButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInJoinPoliceUI = true
end

local function GetCriminalsTextFromTbl(criminals, index)
    local text = "Name <br> "
    local text2 = "Kill Bonus <br> "
    local text3 = "Level <br> "
    
    for i, v in ipairs(criminals[index]) do
        text = text .. v.name .. " <br> "
        text2 = text2 .. v.bonus .. " <br> "
        text3 = text3 .. v.level .. " <br> "
    end
    return text, text2, text3
end

function CriminalsUI(criminals)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = "50px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Police Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePoliceUI()
    end)

    local comboContainer = UIContainer()
    comboContainer.setSizes({100,300})
    comboContainer.setDirection("horizontal")
    comboContainer.appendTo(dialog)

    local text, text2, text3 = GetCriminalsTextFromTbl(criminals, 1)
    local Criminalstext = UIText()
    Criminalstext.setContent(text)
    Criminalstext.appendTo(comboContainer)

    local Criminalstext2 = UIText()
    Criminalstext2.setContent(text2)
    Criminalstext2.appendTo(comboContainer)

    local Criminalstext3 = UIText()
    Criminalstext3.setContent(text3)
    Criminalstext3.appendTo(comboContainer)

    local count = table_count(criminals)
    if count > 1 then
        local tbl_index = 1
        local OldButton = UIButton()
        local old_button_showed = false
        local next_button_showed = true
        local NextButton = UIButton()
        NextButton.setTitle("Next Page")
        NextButton.onClick(function(obj)
            if next_button_showed then
                tbl_index = tbl_index + 1
                local text, text2, text3 = GetCriminalsTextFromTbl(criminals, tbl_index)
                Criminalstext.setContent(text)
                Criminalstext.update()
                Criminalstext2.setContent(text2)
                Criminalstext2.update()
                Criminalstext3.setContent(text3)
                Criminalstext3.update()
                if count <= tbl_index then
                    next_button_showed = false
                    --obj.hide()
                end
                if not old_button_showed then
                    --OldButton.show()
                    old_button_showed = true
                end
            else
                AddPlayerChat("Can't go at the next page")
            end
        end)
        NextButton.appendTo(dialog)

        OldButton.setTitle("Old Page")
        OldButton.onClick(function(obj)
            if old_button_showed then
                tbl_index = tbl_index - 1
                local text, text2, text3 = GetCriminalsTextFromTbl(criminals, tbl_index)
                Criminalstext.setContent(text)
                Criminalstext.update()
                Criminalstext2.setContent(text2)
                Criminalstext2.update()
                Criminalstext3.setContent(text3)
                Criminalstext3.update()
                if tbl_index == 1 then
                    old_button_showed = false
                    --obj.hide()
                end
                if not next_button_showed then
                    --NextButton.show()
                    next_button_showed = true
                end
            else
                AddPlayerChat("Can't go at the old page")
            end
        end)
        OldButton.appendTo(dialog)
        OldButton.hide()
    end

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        PoliceUI()
    end)
    BackButton.appendTo(dialog)
end

function RobbersUI(robbers)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 350) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Police Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePoliceUI()
    end)

    if robbers then

        local Heisttext = UIText()
        Heisttext.setContent("A heist phase has started, stop it ! Destroy their vehicle !")
        Heisttext.appendTo(dialog)

        local comboContainer = UIContainer()
        comboContainer.setSizes({100,300})
        comboContainer.setDirection("horizontal")
        comboContainer.appendTo(dialog)

        local text, text2, text3 = "Name <br> ", "Kill Bonus <br> ", "Level <br> "
        for i, v in ipairs(robbers) do
            text = text .. v.name .. " <br> "
            text2 = text2 .. tostring(v.bonus) .. " <br> "
            text3 = text3 .. tostring(v.level) .. " <br> "
        end
        local Robberstext = UIText()
        Robberstext.setContent(text)
        Robberstext.appendTo(comboContainer)

        local Robberstext2 = UIText()
        Robberstext2.setContent(text2)
        Robberstext2.appendTo(comboContainer)

        local Robberstext3 = UIText()
        Robberstext3.setContent(text3)
        Robberstext3.appendTo(comboContainer)

    else
        local Heisttext = UIText()
        Heisttext.setContent("No heist")
        Heisttext.appendTo(dialog)
    end

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        PoliceUI()
    end)
    BackButton.appendTo(dialog)
end

function PoliceUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Police Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeavePoliceUI()
    end)

    local CriminalsButton = UIButton()
    CriminalsButton.setTitle("Show criminals")
    CriminalsButton.onClick(function(obj)
        CallRemoteEvent("GetCriminalsForPoliceMenu")
        dialog.destroy()
    end)
    CriminalsButton.appendTo(dialog)

    local RobbersButton = UIButton()
    RobbersButton.setTitle("Show robbers")
    RobbersButton.onClick(function(obj)
        CallRemoteEvent("GetRobbersForPoliceMenu")
        dialog.destroy()
    end)
    RobbersButton.appendTo(dialog)

    local LeavePoliceButton = UIButton()
    LeavePoliceButton.setTitle("Leave Police")
    LeavePoliceButton.onClick(function(obj)
        IsPoliceman = false
        dialog.destroy()
        LeavePoliceUI()
        CallRemoteEvent("SetPoliceServer", false)
    end)
    LeavePoliceButton.appendTo(dialog)

    if not IsInPoliceUI then
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInPoliceUI = true
    end
end

AddEvent("OnKeyPress", function(key)
    if (key == OnlineKeys.POLICE_KEY and not IsInPoliceUI and IsPoliceman) then
       PoliceUI()
    end
end)


AddEvent("OnPlayerPoliceAction",function(hittype, hitid, impactX, impactY, impactZ)
    if (not IsPoliceman and not IsInJoinPoliceUI) then
        if not InHeistPhase then
            if not IsCriminal then
                if HasAWeaponInInventory() then
                    PoliceJoinUI()
                else
                    AddPlayerChat("You need to have a weapon to join police")
                end
            else
                CreateNotification("Police", "You lost your weapons", 5000)
                CallRemoteEvent("ArrestCriminal", hitid)
                SetPostEffect("Chromatic", "Intensity", 5.0)
                SetPostEffect("Chromatic", "StartOffset", 0.1)
                SetPostEffect("MotionBlur", "Amount", 0.5)
                SetPostEffect("Bloom", "Intensity", 1.0)
                Delay(5000, function()
                    SetPostEffect("Chromatic", "Intensity", 0.0)
                    SetPostEffect("Chromatic", "StartOffset", 0.0)
                    SetPostEffect("MotionBlur", "Amount", 0.0)
                    SetPostEffect("Bloom", "Intensity", 0.0)
                end)
            end
        else
            AddPlayerChat("You can't join Police (heist)")
        end
    else
        AddPlayerChat("You can't join Police")
    end
end)

AddRemoteEvent("SetCriminalClient", function(criminal)
    IsCriminal = criminal
    if IsCriminal then
       CreateNotification("Police", "You are now a criminal", 10000)
    else
        CreateNotification("Police", "You are no longer a criminal", 10000)
    end
end)

AddRemoteEvent("SetPolicemanClient", function(policeman)
    IsPoliceman = policeman
    if IsPoliceman then
        CreateNotification("Police", "You are now a policeman", 10000)
     else
         CreateNotification("Police", "You are no longer a policeman", 10000)
     end
end)

AddRemoteEvent("CriminalsResponseForPoliceMenu", function(criminals)
    CriminalsUI(criminals)
end)

AddRemoteEvent("HeistAlert", function()
    CreateNotification("Police", "Heist started at the bank now ! Stop it ! Destroy their vehicle ! (Open the police menu to see the robbers)", 10000)
    -- TODO : CreateSound siren sound
end)

AddRemoteEvent("HeistStealVehAlert", function(steal_pos_str)
    CreateNotification("Police", "Vehicle Stolen at " .. steal_pos_str ..  ", stop it ! Kill the robbers to earn money !", 10000)
    -- TODO : CreateSound siren sound
end)

AddRemoteEvent("RobbersResponseForPoliceMenu", function(robbers)
    RobbersUI(robbers)
end)