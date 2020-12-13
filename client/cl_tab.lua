

local _dialog = nil
IsInTabUI = false

AddEvent("OnKeyPress",function(key)
    if (key == OnlineKeys.TAB_KEY and not IsInTabUI) then
       CallRemoteEvent("AskTab")
    end
end)

function LeaveTabUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    HideMoneyTextBoxes(false)
    if not IsInARace then
       SetWebVisibility(miniMapGui, WEB_HITINVISIBLE)
    end
    IsInTabUI = false
end

AddEvent("OnKeyRelease",function(key)
    if (key == OnlineKeys.TAB_KEY and _dialog) then
       _dialog.destroy()
       _dialog = nil
       LeaveTabUI()
    end
end)

local function UpdateTexts(tbl, tblid, namestext, pingstext, moneytext, bankmoneytext, levelstext, xptext, dimstext)
   namestext.setContent("Name <br> ")
   pingstext.setContent("Ping <br> ")
   moneytext.setContent("Money <br> ")
   bankmoneytext.setContent("Bank Money <br> ")
   levelstext.setContent("Level <br> ")
   xptext.setContent("Xp <br> ")
   dimstext.setContent("Dimension <br> ")

   for i,v in ipairs(tbl[tblid]) do
      namestext.setContent(namestext.getContent() .. tostring(v.name) .. " <br> ")
      pingstext.setContent(pingstext.getContent() .. tostring(v.ping) .. " <br> ")
      moneytext.setContent(moneytext.getContent() .. tostring(v.cash) .. " <br> ")
      bankmoneytext.setContent(bankmoneytext.getContent() .. tostring(v.bank_cash) .. " <br> ")
      levelstext.setContent(levelstext.getContent() .. tostring(v.level) .. " <br> ")
      xptext.setContent(xptext.getContent() .. tostring(v.xp) .. " <br> ")
      dimstext.setContent(dimstext.getContent() .. tostring(v.dimension) .. " <br> ")
   end
   _dialog.update()
end

AddRemoteEvent("TabResponse",function(tbl)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = "50px"
    dialogPosition.left = math.floor(ScreenX - (ScreenX - 50)) .. "px !important"
    dialogPosition.width = ScreenX - 100 .. "px"

    local dialog = UIDialog()
    dialog.setTitle("Tab")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)
    _dialog = dialog

    local comboContainer = UIContainer()
    comboContainer.setSizes({100,1000})
    comboContainer.setDirection("horizontal")
    comboContainer.appendTo(dialog)

    local namestext = UIText()
    namestext.appendTo(comboContainer)

    local pingstext = UIText()
    pingstext.appendTo(comboContainer)

    local moneytext = UIText()
    moneytext.appendTo(comboContainer)

    local bankmoneytext = UIText()
    bankmoneytext.appendTo(comboContainer)

    local levelstext = UIText()
    levelstext.appendTo(comboContainer)

    local xptext = UIText()
    xptext.appendTo(comboContainer)

    local dimstext = UIText()
    dimstext.appendTo(comboContainer)

    UpdateTexts(tbl, 1, namestext, pingstext, moneytext, bankmoneytext, levelstext, xptext, dimstext)

    local count = table_count(tbl)
    if count > 1 then
        local tbl_index = 1
        local OldButton = UIButton()
        local old_button_showed = false
        local next_button_showed = true
        local NextButton = UIButton()
        NextButton.setTitle("Next Page")
        NextButton.onClick(function(obj)
            tbl_index = tbl_index + 1
            UpdateTexts(tbl, tbl_index, namestext, pingstext, moneytext, bankmoneytext, levelstext, xptext, dimstext)
            if count <= tbl_index then
               next_button_showed = false
               obj.hide()
            end
            if not old_button_showed then
               OldButton.show()
               old_button_showed = true
            end
        end)
        NextButton.appendTo(dialog)

        OldButton.setTitle("Old Page")
        OldButton.onClick(function(obj)
            tbl_index = tbl_index - 1
            UpdateTexts(tbl, tbl_index, namestext, pingstext, moneytext, bankmoneytext, levelstext, xptext, dimstext)
            if tbl_index == 1 then
               old_button_showed = false
               obj.hide()
            end
            if not next_button_showed then
               NextButton.show()
               next_button_showed = true
            end
        end)
        OldButton.appendTo(dialog)
        OldButton.hide()
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(INPUT_GAMEANDUI)
    end
    HideMoneyTextBoxes(true)
    SetWebVisibility(miniMapGui, WEB_HIDDEN)
    IsInTabUI = true
end)