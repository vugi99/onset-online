
local was_input_1 = false

AddEvent("OnKeyPress", function(key)
    if key == OnlineKeys.SHOWMOUSE_KEY then
        if not IsMouseCursorEnabled() then
            ShowMouseCursor(true)
            SetIgnoreMoveInput(true)
            SetIgnoreLookInput(true)
            SetInputMode(INPUT_GAMEANDUI)
        else
            if not IsInSpawnUI then
              ShowMouseCursor(false)
              if (not IsInARace and not IsTraining) then
                 SetIgnoreMoveInput(false)
              end
              SetIgnoreLookInput(false)
              SetInputMode(INPUT_GAME)
           end
        end
    end
end)

AddEvent("OnShowMainMenu", function()
    if GetInputMode() == 1 then
       was_input_1 = true
    end
end)

AddEvent("OnHideMainMenu", function()
    if was_input_1 then
        was_input_1 = false
        if not IsInSpawnUI then
            ShowMouseCursor(false)
            if (not IsInARace and not IsTraining) then
                SetIgnoreMoveInput(false)
            end
            SetIgnoreLookInput(false)
            SetInputMode(INPUT_GAME)
        end
    end
end)

function IsInAnUI()
   if GetInputMode() == input_while_in_ui then
      return true
   end
   return false
end