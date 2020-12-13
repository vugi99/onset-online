
_nb_energy_bars = nil
IsInGroceryUI = false
local WaitingEnergyBuyConfirmation = false
local _e_text

function LeaveGroceryUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInGroceryUI = false
    _e_text = nil
end

function GroceryUI()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Grocery Store")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveGroceryUI()
    end)

    local Energy_info_text = UIText()
    Energy_info_text.setContent("An energy bar can restore health (" .. tostring(grocery_energy_bar_health_given) .. " HP)")
    Energy_info_text.appendTo(dialog)

    local Energy_text = UIText()
    Energy_text.setContent("Number of energy bars : " .. tostring(_nb_energy_bars) .. " <br> Max energy bars : " .. tostring(max_energy_bars))
    Energy_text.appendTo(dialog)
    _e_text = Energy_text

    local BuyEnergyBarButton = UIButton()
    BuyEnergyBarButton.setTitle("Buy Energy Bar (" .. tostring(grocery_energy_bar_price) .. "$)")
    BuyEnergyBarButton.onClick(function(obj)
        if money - grocery_energy_bar_price >= 0 then
            if _nb_energy_bars < max_energy_bars then
                if not WaitingEnergyBuyConfirmation then
                    CallRemoteEvent("BuyEnergyBar")
                    WaitingEnergyBuyConfirmation = true
                else
                    AddPlayerChat("Please wait")
                end
            else
                AddPlayerChat("Inventory Full")
            end
        else
            AddPlayerChat("You don't have enough money")
        end
    end)
    BuyEnergyBarButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInGroceryUI = true
end

AddEvent("OnPlayerGroceryAction", function(hittype, hitid, impactX, impactY, impactZ)
    if (not IsInGroceryUI and not GetNPCPropertyValue(hitid, "InHeist") and not IsInPlayerMenuUI) then
       GroceryUI()
    end
end)

AddRemoteEvent("EnergyBarPurchased", function(success)
   if success then
      _nb_energy_bars = _nb_energy_bars + 1
      _e_text.setContent("Number of energy bars : " .. tostring(_nb_energy_bars) .. " <br> Max energy bars : " .. tostring(max_energy_bars))
      _e_text.update()
      CreateNotification("Grocery Store", "You bought an energy bar", 1000)
   end
   WaitingEnergyBuyConfirmation = false
end)

AddRemoteEvent("InitEnergyBarsValue", function(nb)
   _nb_energy_bars = nb
end)