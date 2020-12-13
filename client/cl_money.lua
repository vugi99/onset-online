
money_text_box = nil
bank_text_box = nil
money = nil
bank = nil
local hidden = false

local function UpdateMoneyTextBoxesAndMoney(cash, bank_cash)
    if money_text_box then
        DestroyTextBox(money_text_box)
        money_text_box = nil
    end
    if bank_text_box then
        DestroyTextBox(bank_text_box)
        bank_text_box = nil
    end
    if not hidden then
       money_text_box = CreateTextBox(0, 300, "Money " .. tostring(cash))
       bank_text_box = CreateTextBox(0, 275, "Bank Money " .. tostring(bank_cash))
    end
    money = cash
    bank = bank_cash
end

function HideMoneyTextBoxes(hide)
   hidden = hide
   if money_text_box then
      DestroyTextBox(money_text_box)
      money_text_box = nil
   end
   if bank_text_box then
      DestroyTextBox(bank_text_box)
      bank_text_box = nil
   end
   if not hide then
      money_text_box = CreateTextBox(0, 300, "Money " .. tostring(money))
      bank_text_box = CreateTextBox(0, 275, "Bank Money " .. tostring(bank))
   end
end

AddRemoteEvent("UpdateMoney",function(cash, bank_cash)
    UpdateMoneyTextBoxesAndMoney(cash, bank_cash)
end)

AddRemoteEvent("SalaryReceived", function(cash)
    UpdateMoneyTextBoxesAndMoney(cash, bank)
    CreateNotification("Money", "You won " .. tostring(salary_money) .. "$", 7500)
end)