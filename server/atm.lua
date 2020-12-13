

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i,v in ipairs(atms_objects) do
          local obj = CreateObject(494, v[1], v[2], v[3]-100, 0, v[4], 0)
          AddObjectInDimension(obj, id)
          local text = CreateText3D("ATM", 16, v[1], v[2], v[3]+100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddRemoteEvent("ATMWithdraw", function(ply, amount)
    local success = FromBankToCash(ply, amount)
    CallRemoteEvent(ply, "OnWithdrawCompleted", success, PlayerData[ply].bank_cash, PlayerData[ply].cash)
end)

AddRemoteEvent("ATMDeposit", function(ply, amount)
   local success = FromCashToBank(ply, amount)
   CallRemoteEvent(ply, "OnDepositCompleted", success, PlayerData[ply].bank_cash, PlayerData[ply].cash)
end)