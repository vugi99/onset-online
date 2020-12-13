
IsInHelpUI = false

function LeaveHelpUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInHelpUI = false
end

function ShowKeysUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 400) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveHelpUI()
    end)

    local Keystext = UIText()
    local text = "Keys : <br> "

    for k, v in pairs(OnlineKeys) do
       text = text .. k .. " : " .. v .. " <br> "
    end

    Keystext.setContent(text)
    Keystext.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        SelectHelpUI()
    end)
    BackButton.appendTo(dialog)
end

function WhatYouCanDoUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 350) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveHelpUI()
    end)

    local WYCDtext1 = UIText()

    WYCDtext1.setContent(wycd_text)

    WYCDtext1.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        SelectHelpUI()
    end)
    BackButton.appendTo(dialog)
end

function WinMoneyUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 350) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveHelpUI()
    end)

    local WTEMtext1 = UIText()

    WTEMtext1.setContent(wtem_text)

    WTEMtext1.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        SelectHelpUI()
    end)
    BackButton.appendTo(dialog)
end

function ChangelogUI()
    local changelog_i = table_count(online_changelogs)
    local changelog = online_changelogs[changelog_i]
    local mult = 5

    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor(((ScreenY - 400) / 2) - (table_count(split(changelog[2], "<")) * mult)) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveHelpUI()
    end)

    local ChangelogHeader = UIText()
    ChangelogHeader.setContent("Version " .. changelog[1] .. " changelog")
    ChangelogHeader.appendTo(dialog)

    local ChangelogBodyText = UIText()
    ChangelogBodyText.setContent(changelog[2])
    ChangelogBodyText.appendTo(dialog)

    local comboContainerButtons = UIContainer()
    comboContainerButtons.setSizes({300,100})
    comboContainerButtons.setDirection("horizontal")
    comboContainerButtons.appendTo(dialog)

    local OldButtonPosition = UICSS()
    OldButtonPosition.left = "20px !important"
    OldButtonPosition.width = "290px"

    local NextButtonPosition = UICSS()
    NextButtonPosition.left = "310px !important"
    NextButtonPosition.width = "290px"

    local NextButton = UIButton()
    local nextbuttonhidden = true
    local oldbuttonhidden = false

    local OldButton = UIButton()
    OldButton.setTitle("Older Changelog")
    OldButton.onClick(function(obj)
        changelog_i = changelog_i - 1
        changelog = online_changelogs[changelog_i]

        dialogPosition.top = math.floor(((ScreenY - 400) / 2) - (table_count(split(changelog[2], "<")) * mult)) .. "px"
        dialog.setCSS(dialogPosition)
        dialog.update()
        ChangelogHeader.setContent("Version " .. changelog[1] .. " changelog")
        ChangelogHeader.update()
        ChangelogBodyText.setContent(changelog[2])
        ChangelogBodyText.update()

        if changelog_i == 1 then
            oldbuttonhidden = true
            obj.hide()
         end
         if nextbuttonhidden then
            nextbuttonhidden = false
            NextButton.show()
         end
    end)
    OldButton.appendTo(comboContainerButtons)
    OldButton.setCSS(OldButtonPosition)


    NextButton.setTitle("Next Changelog")
    NextButton.onClick(function(obj)
        changelog_i = changelog_i + 1
        changelog = online_changelogs[changelog_i]

        dialogPosition.top = math.floor(((ScreenY - 400) / 2) - (table_count(split(changelog[2], "<")) * mult)) .. "px"
        dialog.setCSS(dialogPosition)
        dialog.update()
        ChangelogHeader.setContent("Version " .. changelog[1] .. " changelog")
        ChangelogHeader.update()
        ChangelogBodyText.setContent(changelog[2])
        ChangelogBodyText.update()

        if changelog_i == table_count(online_changelogs) then
            nextbuttonhidden = true
            obj.hide()
         end
         if oldbuttonhidden then
            oldbuttonhidden = false
            OldButton.show()
         end
    end)
    NextButton.appendTo(comboContainerButtons)
    NextButton.setCSS(NextButtonPosition)
    Delay(1, function()
        NextButton.hide()
    end)

    local ChangelogEmptyText = UIText()
    ChangelogEmptyText.setContent([[
         <br> 
         ]])
    ChangelogEmptyText.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        SelectHelpUI()
    end)
    BackButton.appendTo(dialog)
end

function SelectHelpUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveHelpUI()
    end)

    local KeysButton = UIButton()
    KeysButton.setTitle("Show Keys")
    KeysButton.onClick(function(obj)
        dialog.destroy()
        ShowKeysUI()
    end)
    KeysButton.appendTo(dialog)

    local WhatYouCanDoButton = UIButton()
    WhatYouCanDoButton.setTitle("What you can do in Onset Online")
    WhatYouCanDoButton.onClick(function(obj)
        dialog.destroy()
        WhatYouCanDoUI()
    end)
    WhatYouCanDoButton.appendTo(dialog)

    local WinMoneyButton = UIButton()
    WinMoneyButton.setTitle("Ways to earn money")
        WinMoneyButton.onClick(function(obj)
        dialog.destroy()
        WinMoneyUI()
    end)
    WinMoneyButton.appendTo(dialog)

    local ChangelogButton = UIButton()
    ChangelogButton.setTitle("Online Changelog")
        ChangelogButton.onClick(function(obj)
        dialog.destroy()
        ChangelogUI()
    end)
    ChangelogButton.appendTo(dialog)

    local versiontext = UIText()
    versiontext.setContent("Onset Online " .. tostring(online_version))
    versiontext.appendTo(dialog)

    if not IsInHelpUI then
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInHelpUI = true
    end
end

AddEvent("OnKeyPress", function(key)
    if (key == OnlineKeys.HELP_KEY and not IsInHelpUI) then
       SelectHelpUI()
    end
end)

AddEvent("OnPackageStart", function()
    AddPlayerChat("Press " .. OnlineKeys.HELP_KEY .. " to open help menu.")
end)