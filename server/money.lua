
local salary_timers = {}

local function player_salary(ply)
    if PlayerData[ply] then
        PlayerData[ply].cash = PlayerData[ply].cash + salary_money
        CallRemoteEvent(ply, "SalaryReceived", PlayerData[ply].cash)
    end
end

AddEvent("PlayerDataLoaded", function(ply)
    CallRemoteEvent(ply, "UpdateMoney", PlayerData[ply].cash, PlayerData[ply].bank_cash)
    local timer = CreateTimer(player_salary, salary_interval_s * 1000, ply)
    table.insert(salary_timers, {ply, timer})
end)

AddEvent("OnPlayerQuit", function(ply)
    for i, v in ipairs(salary_timers) do
        if v[1] == ply then
            DestroyTimer(v[2])
            table.remove(salary_timers, i)
            break
        end
    end
end)

function HasEnoughMoney(ply, price)
   if PlayerData[ply] then
      if (PlayerData[ply].cash - price >= 0) then
         return true
      end
   end
   return false
end

function Buy(ply, price)
   if HasEnoughMoney(ply, price) then
      PlayerData[ply].cash = PlayerData[ply].cash - price
      CallRemoteEvent(ply,"UpdateMoney",PlayerData[ply].cash,PlayerData[ply].bank_cash)
      return true
   end
   return false
end

function Sell(ply, price)
   if PlayerData[ply] then
      PlayerData[ply].cash = PlayerData[ply].cash + price
      CallRemoteEvent(ply,"UpdateMoney",PlayerData[ply].cash,PlayerData[ply].bank_cash)
      return true
   end
   return false
end

function FromBankToCash(ply, amount)
   if PlayerData[ply] then
      if (PlayerData[ply].bank_cash - amount >= 0) then
         PlayerData[ply].bank_cash = PlayerData[ply].bank_cash - amount
         PlayerData[ply].cash = PlayerData[ply].cash + amount
         CallRemoteEvent(ply,"UpdateMoney",PlayerData[ply].cash,PlayerData[ply].bank_cash)
         return true
      end
   end
   return false
end

function FromCashToBank(ply, amount)
   if HasEnoughMoney(ply, amount) then
      PlayerData[ply].cash = PlayerData[ply].cash - amount
      PlayerData[ply].bank_cash = PlayerData[ply].bank_cash + amount
      CallRemoteEvent(ply,"UpdateMoney",PlayerData[ply].cash,PlayerData[ply].bank_cash)
      return true
   end
   return false
end

AddEvent("OnPlayerDeath", function(ply, killer)
    if (GetPlayerDimension(ply) == GetDimensionByName("base") and PlayerData[ply]) then
       if PlayerData[ply].cash > 0 then
          local x, y, z = GetPlayerLocation(ply)
          local pickup = CreatePickupTrigger(1443, x, y, z - 100, true)
          local val
          if PlayerData[ply].cash >= 5000 then
             val = 500
          else
              val = math.ceil(PlayerData[ply].cash / 10)
          end
          if val then
             PlayerData[ply].cash = PlayerData[ply].cash - val
             SetPickupPropertyValue(pickup, "cash", val, false)
             CallRemoteEvent(ply,"UpdateMoney",PlayerData[ply].cash,PlayerData[ply].bank_cash)
          end
          local id = GetPlayerDimension(ply)
          AddPickupInDimension(pickup, id)
       end
    end
end)

AddEvent("OnPlayerCashAction", function(ply, pickup)
    if (IsValidPickup(pickup) and IsValidPlayer(ply)) then
       if GetPickupPropertyValue(pickup, "cash") then
          PlayerData[ply].cash = PlayerData[ply].cash + GetPickupPropertyValue(pickup, "cash")
          CallRemoteEvent(ply,"UpdateMoney",PlayerData[ply].cash,PlayerData[ply].bank_cash)
       end
    end
end)

--AddCommand("kill", function(ply)
   --SetPlayerHealth(ply, 0)
--end)