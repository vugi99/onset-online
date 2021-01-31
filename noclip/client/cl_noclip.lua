local speed = 80
local mouse_change_speed = true


local noclipping = false
local spacepressed = false
local pressing = {
  F=false,
  B=false,
  L=false,
  R=false,
  U=false,
  below=false
}

local map = GetWorld():GetMapName()

function SpacePressed_Teleport(x, y, impactZ)
   spacepressed=true
   SetIgnoreMoveInput(true)
   GetPlayerActor(GetPlayerId()):SetActorEnableCollision(true)
   local tim = 1050
   if (GetPing()~=0) then
     tim=GetPing()*6+1000
   end
   actor = GetPlayerActor(GetPlayerId())
   actor:SetActorLocation(FVector(x, y, impactZ+100))
   Delay(tim,function()
      SetIgnoreMoveInput(false)
      GetPlayerActor(GetPlayerId()):SetActorEnableCollision(false)
      spacepressed=false
   end)
end

function Save_Speed()
   SetStorageValue("noclip_speed", speed)
end

AddEvent("OnPackageStart", function()
      local speed_stored = GetStorageValue("noclip_speed")
      if speed_stored then
           if speed_stored > 0 then
               speed = speed_stored
           end
      else
          Save_Speed()
      end
end)

function ToggleNoclip()
      if (not noclipping == true) then
         if (GetPlayerMovementMode()~=0) then
            if (GetPlayerMovementMode()~=8) then
               if (GetPlayerMovementMode()~=6 and GetPlayerMovementMode()~=5) then
                  SetIgnoreMoveInput(true)
                  local tim = 50
                  if (GetPing()~=0) then
                     tim=GetPing()*6
                  end
                  Delay(tim,function()
                     noclipping = true
                     GetPlayerActor(GetPlayerId()):SetActorEnableCollision(not noclipping)
                     SetIgnoreMoveInput(false)
                  end)
               else
                  AddPlayerChat("Can't activate noclip while falling")
               end
            else
               local x,y,z = GetPlayerLocation()
               local hittype, hitid, impactX, impactY, impactZ = LineTrace(x, y, z + 25000, x, y, z - 25000)
               if hittype ~= 7 then
                   noclipping = true
                   SpacePressed_Teleport(x, y, impactZ)
               else
                  AddPlayerChat("You can't enable noclip while in water")
               end
            end
         else
            noclipping = not noclipping
            GetPlayerActor(GetPlayerId()):SetActorEnableCollision(not noclipping)
         end
      else
         noclipping = not noclipping
         GetPlayerActor(GetPlayerId()):SetActorEnableCollision(not noclipping)
      end
end

AddEvent("OnKeyPress", function(key)
   if key == "Space Bar" then
      if noclipping then
         if spacepressed==false then
            local x,y,z = GetPlayerLocation()
            local hittype, hitid, impactX, impactY, impactZ = LineTrace(x, y, z + 25000, x, y, z - 25000)
            if (hittype~=7) then
               AddPlayerChat("Don't Press SpaceBar while in noclip mode please")
               SpacePressed_Teleport(x, y, impactZ)
            else
               AddPlayerChat("Noclip disabled")
               noclipping = false
               GetPlayerActor(GetPlayerId()):SetActorEnableCollision(true)
            end
         end
      end
   end
end)

AddEvent("OnGameTick",function()
    if GetInputAxisValue("MoveForward") == 1.0 then
       pressing["F"] = true
       pressing["B"] = false
    elseif GetInputAxisValue("MoveForward") == -1.0 then
       pressing["F"] = false
       pressing["B"] = true
    else
       pressing["F"] = false
       pressing["B"] = false
    end
    if GetInputAxisValue("MoveRight") == 1.0 then
       pressing["R"] = true
       pressing["L"] = false
    elseif GetInputAxisValue("MoveRight") == -1.0 then
       pressing["R"] = false
       pressing["L"] = true
    else
       pressing["R"] = false
       pressing["L"] = false
    end
    if GetInputAxisValue("MoveVertical") == 1.0 then
       pressing["U"] = true
       pressing["below"] = false
    elseif GetInputAxisValue("MoveVertical") == -1.0 then
       pressing["U"] = false
       pressing["below"] = true
    else
       pressing["U"] = false
       pressing["below"] = false
    end
end)

AddEvent("OnGameTick", function(DeltaS)
   if noclipping then
      if spacepressed==false then
          local fx, fy, fz = GetCameraForwardVector()
          local rx, ry, rz = GetCameraRightVector()
          local ux, uy, uz = GetCameraUpVector()
          local x, y, z = GetPlayerLocation()
        
          fx = fx*speed
          fy = fy*speed
          fz = fz*speed
          rx = rx*speed
          ry = ry*speed
          rz = rz*speed
          ux = ux*speed
          uy = uy*speed
          uz = uz*speed
          actor = GetPlayerActor(GetPlayerId())
          if pressing['F'] then
             if (z+fz>100 or map ~= "Island") then
                actor:SetActorLocation(FVector(x+fx, y+fy, z+fz))
             end
          elseif pressing['B'] then
             if (z+fz*-1>100 or map ~= "Island") then
                actor:SetActorLocation(FVector( x+fx*-1, y+fy*-1, z+fz*-1))
             end
          elseif pressing['L'] then
             if (z+rz*-1>100 or map ~= "Island") then
                actor:SetActorLocation(FVector( x+rx*-1, y+ry*-1, z+rz*-1))
             end
          elseif pressing['R'] then
             if (z+rz>100 or map ~= "Island") then
                actor:SetActorLocation(FVector( x+rx, y+ry, z+rz))
             end
          elseif pressing['U'] then
             if (z+uz>100 or map ~= "Island") then
                actor:SetActorLocation(FVector( x+ux, y+uy, z+uz))
             end
          elseif pressing['below'] then
             if (z+uz*-1>100 or map ~= "Island") then
                actor:SetActorLocation(FVector( x+ux*-1, y+uy*-1, z+uz*-1))
             end
          end
      end
   end
end)

AddEvent("OnPlayerSpawn", function()
    if noclipping then
        noclipping = false
        GetPlayerActor(GetPlayerId()):SetActorEnableCollision(not noclipping)
    end
end)

AddEvent("OnKeyPress", function(key)
    if (mouse_change_speed and noclipping) then
         if key == "Mouse Wheel Up" then
             speed = speed + 1
             Save_Speed()
         elseif key == "Mouse Wheel Down" then
             if speed > 1 then
                 speed = speed - 1
                 Save_Speed()
             end
         end
    end
end)

AddEvent("OnRenderHUD", function()
    if (mouse_change_speed and noclipping) then
        DrawText(2, 350, "Noclip speed : " .. tostring(speed))
        DrawText(2, 365, "Use Mouse Wheel to change noclip speed")
    end
end)