

local spec = false
local specply = nil
local checktimer = nil
local needtorefirst = false

local comptcheck = 0

function checkuntilvalid()
   for i,ply in pairs(GetStreamedPlayers()) do
      if ply==specply then
         spec=true
         DestroyTimer(checktimer)
         checktimer=nil
         if IsFirstPersonCamera() then
            needtorefirst=true
            EnableFirstPersonCamera(false)
         end
      end
   end
   if not spec then
       if comptcheck<=300 then
          comptcheck=comptcheck+1
       else
        DestroyTimer(checktimer)
        checktimer=nil
        CallRemoteEvent("changespec",specply)
       end
   end
end

AddRemoteEvent("SpecRemoteEvent",function(bool,plyid,x,y,z)
    if bool == false then
       stopspec(false)
    else
        specply=plyid
        actor = GetPlayerActor(GetPlayerId())
        actor:SetActorLocation(FVector( x,y,0))
        comptcheck=0
        if checktimer then
            DestroyTimer(checktimer)
            checktimer=nil
        end
        checktimer = CreateTimer(checkuntilvalid,10)
    end
end)

function stopspec(needtoreask)
    if needtorefirst then
        EnableFirstPersonCamera(true)
    end
    if checktimer then
        DestroyTimer(checktimer)
        checktimer=nil
    end
    if spec then
        if needtoreask then
            CallRemoteEvent("changespec",specply)
         end
    needtorefirst=false
    spec=false
    specply=nil
    SetCameraLocation(0,0,0,false)
    SetCameraRotation(0,0,0,false)
    end
end

AddEvent("OnGameTick",function(ds)
    if spec then
       if not IsPlayerInVehicle() then
        if IsValidPlayer(specply) then
            local x, y, z = GetPlayerLocation(specply)
            local x2, y2, z2 = GetPlayerLocation(GetPlayerId())
            local heading = GetPlayerHeading(specply)
            if z > 0 then -- if the player is under 0 or == 0 it looks like he is spectating
            if GetDistance2D(x, y, x2, y2)>3000 then
            actor = GetPlayerActor(GetPlayerId())
            actor:SetActorLocation(FVector( x,y,0))
            end
            if GetPlayerVehicle(specply) == 0 then
            local fx,fy,fz = GetPlayerForwardVector(specply)
            local hittype, hitid, impactX, impactY, impactZ = LineTrace(x-fx*40,y-fy*40,z,x-fx*300, y-fy*300, z+150)
            if (hittype~=2 and impactX==0 and impactY==0 and impactZ==0) then
            SetCameraLocation(x-fx*300, y-fy*300, z+150 , true)
            SetCameraRotation(-25,heading,0)
            else
                SetCameraLocation(impactX, impactY, impactZ , true)
                SetCameraRotation(-25,heading,0)
            end
        else
            local veh = GetPlayerVehicle(specply)
            local x, y, z = GetVehicleLocation(veh)
            local rx, ry, rz = GetVehicleRotation(veh)
            local fx,fy,fz = GetVehicleForwardVector(veh)
            SetCameraLocation(x-fx*600, y-fy*600, z+275 , true)
            SetCameraRotation(-15,ry,rz)
        end
    else
        AddPlayerChat("This player is spectating")
        stopspec(true)
    end
        else
            AddPlayerChat("Player invalid")
            stopspec(true)
        end
    else
        stopspec(false)
    end
    end
end)

AddEvent("OnKeyPress",function(key)
    if (spec and key=="E") then
        stopspec(true)
    end
end)

AddEvent("OnRenderHUD", function()
    if spec then
        DrawText(5, 350, "Press E to change the spectated player")
    end
end)
