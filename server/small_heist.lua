



AddRemoteEvent("StartSmallHeist", function(ply, npc)
   if IsValidNPC(npc) then
      if not GetNPCPropertyValue(npc, "InHeist") then
         SetNPCPropertyValue(npc, "InHeist", true, true)
         SetNPCAnimation(npc, "PICKUP_MIDDLE", false)
         Delay(2000, function()
            SetNPCAnimation(npc, "CARRY_SHOULDER_SETDOWN", false)
            Delay(1000, function()
                local gnpc_id = GetNPCPropertyValue(npc, "GroceryID")
                local pickup = CreatePickupTrigger(615, grocery_npcs[gnpc_id][5], grocery_npcs[gnpc_id][6], grocery_npcs[gnpc_id][7] - 90, true)
                AddPickupInDimension(pickup, GetDimensionByName("base"))
                SetPickupPropertyValue(pickup, "MoneyInIt", math.random(grocery_heist_money_min, grocery_heist_money_max), false)
                SetNPCAnimation(npc, "HANDSHEAD_KNEEL", true)
                Delay(grocery_heist_cooldown_s * 1000, function()
                   SetNPCAnimation(npc, "STOP", false)
                   SetNPCPropertyValue(npc, "InHeist", false, true)
                   if IsValidPickup(pickup) then
                      local x, y, z = GetPickupLocation(pickup)
                      if (x == grocery_npcs[gnpc_id][5] and y == grocery_npcs[gnpc_id][6] and z == grocery_npcs[gnpc_id][7] - 90) then
                         DestroyPickupTrigger(pickup)
                      end
                   end
                end)
            end)
         end)
      end
   end
end)

AddEvent("OnPlayerGroceryHeistMoneyAction", function(ply, pickup)
    if (IsValidPickup(pickup) and IsValidPlayer(ply)) then
        if GetPickupPropertyValue(pickup, "MoneyInIt") then
           Sell(ply, GetPickupPropertyValue(pickup, "MoneyInIt"))
           CallRemoteEvent(ply, "CreateNotification", "Money", "You won " .. tostring(GetPickupPropertyValue(pickup, "MoneyInIt")) .. "$", 10000)
           if IsPoliceman(ply) then
               LeavePoliceman(ply)
               CallRemoteEvent(ply, "SetPolicemanClient", false)
           end
           AddCriminalBonus(ply)
        end
    end
end)