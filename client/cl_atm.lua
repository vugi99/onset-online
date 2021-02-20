local IsInAtmUI = false
local NeedToDesactivatePassive = false
local WaitingForConfirmation = false

local _text = nil

function LeaveAtm()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    _text = nil
    if NeedToDesactivatePassive then
       NeedToDesactivatePassive = false
       SetPassive(false)
    end
    LockPassive(false)
    IsInAtmUI = false
end

function ATMUI()
    IsInAtmUI = true
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("ATM")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveAtm()
    end)

    local text = UIText()
    _text = text
    text.setContent("Bank Money : " .. tostring(bank) .. " <br> Money : " .. tostring(money))
    text.appendTo(dialog)

    local AmountInput = UITextField()
    AmountInput.setPlaceholder("Amount")
    AmountInput.appendTo(dialog)

    local WithdrawButton = UIButton()
    WithdrawButton.setTitle("Withdraw")
    WithdrawButton.onClick(function(obj)
        local amount = tonumber(AmountInput.getValue())
        if amount then
            if amount > 0 then
                if math.floor(amount) == amount then
                    if bank - amount >= 0 then
                        if not WaitingForConfirmation then
                            CallRemoteEvent("ATMWithdraw", amount)
                            text.setContent("Bank Money : " .. tostring(bank - amount) .. " <br> Money : " .. tostring(money + amount))
                            text.update()
                            WaitingForConfirmation = true
                        end
                    end
                else
                    AddPlayerChat("Invalid Amount")
                end
            else
                AddPlayerChat("Invalid Amount")
            end
        else
            AddPlayerChat("Invalid Amount")
        end
    end)
    WithdrawButton.appendTo(dialog)

    local DepositButton = UIButton()
    DepositButton.setTitle("Deposit")
    DepositButton.onClick(function(obj)
        local amount = tonumber(AmountInput.getValue())
        if amount then
            if amount > 0 then
                if math.floor(amount) == amount then
                    if money - amount >= 0 then
                        if not WaitingForConfirmation then
                        CallRemoteEvent("ATMDeposit", amount)
                        text.setContent("Bank Money : " .. tostring(bank + amount) .. " <br> Money : " .. tostring(money - amount))
                        text.update()
                        WaitingForConfirmation = true
                        end
                    end
                else
                    AddPlayerChat("Invalid Amount")
                end
            else
                AddPlayerChat("Invalid Amount")
            end
        else
            AddPlayerChat("Invalid Amount")
        end
    end)
    DepositButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    if not IsPassive then
       SetPassive(true)
       NeedToDesactivatePassive = true
    end
    LockPassive(true)
end



AddEvent("OnATMAction",function(hittype, hitid, impactX, impactY, impactZ)
    if not IsInAtmUI then
       if not InHeistPhase then
            if not InBunkerMission then
                ATMUI()
            else
                CreateNotification("Bunker", "You can't do that", 5000)
            end
       else
           CreateNotification("Heist", "You can't do that", 5000)
       end
    end
end)

local function Confirmation(success, bank_cash, cash)
   WaitingForConfirmation = false
   if not success then
      if _text then
         _text.setContent("Bank Money : " .. tostring(bank_cash) .. " <br> Money : " .. tostring(cash))
         _text.update()
      end
   end
end

AddRemoteEvent("OnWithdrawCompleted",function(success, bank_cash, cash)
    if success then
       CreateNotification("ATM", "Withdraw Completed", 5000)
    else
        CreateNotification("ATM", "Withdraw Failed", 5000)
    end
    Confirmation(success, bank_cash, cash)
end)

AddRemoteEvent("OnDepositCompleted",function(success, bank_cash, cash)
    if success then
       CreateNotification("ATM", "Deposit Completed", 5000)
    else
        CreateNotification("ATM", "Deposit Failed", 5000)
    end
    Confirmation(success, bank_cash, cash)
end)