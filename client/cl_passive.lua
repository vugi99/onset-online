
IsPassive = false
local passivetextbox = nil
local disabling_passive = false
local can_enable_passive = true
local locked = false

local function PassiveTextBoxUpdate()
   if IsPassive then
      if not passivetextbox then
         passivetextbox = CreateTextBox(0, 350, "Passive Mode")
      end
      CreateNotification("Passive", "Passive Mode Enabled", 5000)
      if IsPlayerAiming(GetPlayerId()) then
         CancelAimImmediately()
      end
   else
      CreateNotification("Passive", "Passive Mode Disabled", 5000)
      if passivetextbox then
         DestroyTextBox(passivetextbox)
         passivetextbox = nil
      end
   end
end


function SetPassive(enable)
   IsPassive = enable
   PassiveTextBoxUpdate()
   if not IsPassive then
      disabling_passive = false
   end
   CallRemoteEvent("SetPlayerPassive", enable, true)
end

function LockPassive(lock)
   locked = lock
end

AddRemoteEvent("SetPassiveClient",function(enable)
    IsPassive = enable
    PassiveTextBoxUpdate()
end)

function TogglePassive()
   if not locked then
      if IsPassive then
         if (not disabling_passive) then
            disabling_passive = true
            can_enable_passive = false
            AddPlayerChat("Passive Mode Disabled in " .. tostring(passive_time_to_disable_ms/1000) .. " seconds")
            Delay(passive_time_to_disable_ms, function()
                if disabling_passive then
                   if not locked then
                       SetPassive(false)
                       AddPlayerChat("You can re enable passive in " .. tostring(passive_delay_after_disable_to_enable_again_ms/1000) .. " seconds")
                       Delay(passive_delay_after_disable_to_enable_again_ms,function()
                             can_enable_passive = true
                             AddPlayerChat("You can re enable passive mode")
                       end)
                   end
               else
                   can_enable_passive = true
                   AddPlayerChat("You can re enable passive mode")
                end
            end)
         else
             AddPlayerChat("Already disabling Passive")
         end
      elseif can_enable_passive then
         SetPassive(true)
      else
          AddPlayerChat("You need to wait some time before re enabling passive mode")
      end
   end
end

AddEvent("OnPlayerToggleAim", function(toggle)
   if (toggle == true and IsPassive) then
       return false
   end
end)