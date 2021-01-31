local nitro = true
local backfire = true
local dev = false
local time_after_finish_ms = 60000
local time_bef_start_s = 6
local car = 12



local plyvehs = {}
local checkpoints = {}

local finished = {}

local playerscheckpoints = {}

local lastclassement = {}

local notready = {}

local finishclassement = {}

local currace = {}

function createcheckpoints(mapname, idnb)
   local id = tostring(idnb)
   if checkpoints[id] then
       for i,v in ipairs(checkpoints[id]) do
          DestroyObject(v)
       end
   end
   checkpoints[id] = {}
   for i,v in ipairs(races[mapname]) do
         if i+1 == #races[mapname] then
               local obj = CreateObject(111111, races[mapname][i+1][1], races[mapname][i+1][2], races[mapname][i+1][3] , 0, races[mapname][i+1][4], 0, 1, 1, 1)
               AddObjectInDimension(obj, idnb)
               table.insert(checkpoints[id],obj)
         else
            if races[mapname][i+1] then
               local obj = CreateObject(336, races[mapname][i+1][1], races[mapname][i+1][2], races[mapname][i+1][3] , 0, 0, 0, 10, 10, 10)
               AddObjectInDimension(obj, idnb)
               table.insert(checkpoints[id],obj)
            end
         end
   end
end

function changerace(idnb, race_id)
   local id = tostring(idnb)
   finishclassement[id] = {}
   notready[id] = {}
   lastclassement[id] = {}
   playerscheckpoints[id] = {}
   plyvehs[id] = {}
   currace[id] = race_id
   createcheckpoints(racesnumbers[currace[id]], idnb)
   for i,v in ipairs(GetDimensionPlayers(idnb)) do
      if IsValidPlayer(v) then
         local tbl = {}
         tbl.ply = v
         tbl.number = 1
         table.insert(playerscheckpoints[id],tbl)
         table.insert(notready[id],v)
         SetPlayerSpawnLocation(v, spawns[racesnumbers[currace[id]]][i+1][1], spawns[racesnumbers[currace[id]]][i+1][2], spawns[racesnumbers[currace[id]]][i+1][3], spawns[racesnumbers[currace[id]]][1])
         SetPlayerHealth(v, 0)
         --CallRemoteEvent(v,"SpecRemoteEvent",false)
         CallRemoteEvent(v,"classement_update",i,table_count(GetDimensionPlayers(idnb)),true)
      end
   end
end


--AddEvent("OnPlayerJoin", function(ply)
      --SetPlayerSpawnLocation(ply, spawns[racesnumbers[currace]][2][1], spawns[racesnumbers[currace]][2][2], 0, spawns[racesnumbers[currace]][1])
      --SetPlayerRespawnTime(ply, 500)
      --if not checkpoints then
         --changerace()
      --end
--end)

function spawnveh(ply,id,first)
   local did = GetPlayerDimension(ply)
   local strid = tostring(did)
   for i,v in ipairs(plyvehs[strid]) do
      if v.ply == ply then
         DestroyVehicle(v.vid)
         table.remove(plyvehs[strid],i)
      end
   end
   local px,py,pz = GetPlayerLocation(ply)
   local h = GetPlayerHeading(ply)
   local veh = CreateVehicle(id, px, py, pz , h)
   SetVehicleLicensePlate(veh, "RACING")
   SetVehicleRespawnParams(veh, false)
   AttachVehicleNitro(veh, nitro)
   EnableVehicleBackfire(veh, backfire)
   AddVehicleInDimension(veh, did)
   local tbin = {}
   tbin.ply = ply
   tbin.vid = veh
   tbin.vhp = GetVehicleHealth(veh)
   table.insert(plyvehs[strid],tbin)
   if first == true then
      local ping = GetPlayerPing(ply)
      if ping == 0 then
          ping = 50
      else
         ping=ping*6
      end
      Delay(ping,function()
         SetPlayerInVehicle(ply, veh)
      end)
   else
      SetPlayerInVehicle(ply, veh)
   end
end

AddEvent("OnPlayerSpawnRacing", function(ply)
   local idnb = GetPlayerDimension(ply)
   local id = tostring(idnb)
   local found = false
   for i,v in ipairs(playerscheckpoints[id]) do
      if v.ply == ply then
         found=true
         spawnveh(ply,car,true)
      end
   end
   if not found then
      for i,v in ipairs(playerscheckpoints[id]) do
         local ping = GetPlayerPing(ply)
         if ping == 0 then
             ping = 50
         else
            ping=ping*6
         end
         for i,v in ipairs(playerscheckpoints[id]) do
            CallRemoteEvent(v.ply,"startlookingforafk")
         end
         Delay(ping,function()
            speclogic(ply,playerscheckpoints[id][i].ply)
         end)
         break
      end
   end
end)

AddEvent("OnPlayerLeaveVehicleRacing",function(ply,veh,seat)
   local idnb = GetPlayerDimension(ply)
   local id = tostring(idnb)
   if GetPlayerPropertyValue(ply,"leaving")==nil then
      if GetPlayerPropertyValue(ply,"leavingtospec")==nil then
          spawnveh(ply,car)
      else
         for i,v in ipairs(plyvehs[id]) do
            if v.ply == ply then
               DestroyVehicle(v.vid)
               table.remove(plyvehs[id],i)
               local ping = GetPlayerPing(ply)
               if ping == 0 then
                   ping = 50
                else
                ping=ping*6
               end
               Delay(ping,function()
                  for i,v in ipairs(playerscheckpoints[id]) do
                     speclogic(ply,playerscheckpoints[id][i].ply)
                     break
                  end
               end)
            end
         end
         SetPlayerPropertyValue(ply,"leavingtospec",nil,false)
      end
   end
end)

AddEvent("OnPlayerQuitRacing",function(ply, idnb, leave)
   --local idnb = GetPlayerDimension(ply)
   --print(idnb)
   if not leave then
      CallRemoteEvent(ply,"SpecRemoteEvent",false)
   end
   local id = tostring(idnb)
   for i,v in ipairs(plyvehs[id]) do
      if v.ply == ply then
         SetPlayerPropertyValue(ply,"leaving",true,false)
         DestroyVehicle(v.vid)
         table.remove(plyvehs[id],i)
      end
   end
   for i,v in ipairs(playerscheckpoints[id]) do
       if v.ply == ply then
         table.remove(playerscheckpoints[id],i)
       end
   end
   for i,v in ipairs(finishclassement[id]) do
      if v == ply then
        table.remove(finishclassement[id],i)
      end
  end
  for ilc,vlc in ipairs(lastclassement[id]) do
      if vlc.ply == ply then
         table.remove(lastclassement[id],ilc)
      end
   end
  if #playerscheckpoints[id]>0 then
      for i,v in ipairs(notready[id]) do
         if v==ply then
            if #notready[id]<=1 then
               for i,v in ipairs(playerscheckpoints[id]) do
                  CallRemoteEvent(v.ply,"checkpointstbl",races[racesnumbers[currace[id]]],time_bef_start_s)
               end
            end
            table.remove(notready[id],i)
         end
      end
   end
   if (IsValidDimension(idnb) and table_count(GetDimensionPlayers(idnb))>1) then
      if #playerscheckpoints[id] == 0 then
         Delay(250,function()  -- wait some time so GetAllPlayers and GetPlayerCount won't return this player
            checktorestart(idnb)
         end)
      end
   --elseif checkpoints[id] then
      --for i,v in ipairs(checkpoints[id]) do
         --DestroyObject(v)
      --end
      --checkpoints[id] = nil
   end
end)



function checktorestart(idnb)
   local id = tostring(idnb)
   if #playerscheckpoints[id] == 0 then
      -- finish race
      --print("race finished")
      --print(tostring(idnb) .. " " .. type(idnb))
      for i,v in ipairs(GetDimensionPlayers(idnb)) do
         if IsValidPlayer(v) then
            CallRemoteEvent(v,"Start_finish_timer",time_after_finish_ms,true)
            CallRemoteEvent(v,"SpecRemoteEvent",false)
         end
      end
      if checkpoints[id] then
         for i,v in ipairs(checkpoints[id]) do
            DestroyObject(v)
         end
      end
      for i,v in ipairs(plyvehs[id]) do
         if IsValidVehicle(v.vid) then
            SetPlayerPropertyValue(v.ply, "leaving", true, false)
            RemovePlayerFromVehicle(v.ply)
            Delay(600, function()
                DestroyVehicle(v.vid)
                SetPlayerPropertyValue(v.ply, "leaving", nil, false)
            end)
         end
      end
      finished[id] = true
      CallEvent("OnRaceFinished", idnb, finishclassement[id], lastclassement[id])
      finishclassement[id] = {}
      notready[id] = {}
      lastclassement[id] = {}
      playerscheckpoints[id] = {}
      plyvehs[id] = {}
      checkpoints[id] = {}
      
      --[[
      if #racesnumbers==currace then
         currace=1
         changerace()
      else
         currace=currace+1
         changerace()
      end]]--
   else
      if #finishclassement[id]==1 then
         for i,v in ipairs(GetDimensionPlayers(idnb)) do
            CallRemoteEvent(v,"Start_finish_timer",time_after_finish_ms,false)
         end
         finished[id] = false
         Delay(time_after_finish_ms,function()
            if finished[id] == false then
               playerscheckpoints[id]={}
               checktorestart(idnb)
            end
         end)
      end
   end
end



function timercheck()
   for k,uh in pairs(playerscheckpoints) do
      for i,v in ipairs(uh) do
      if GetPlayerVehicle(v.ply)~=0 then
         local veh = GetPlayerVehicle(v.ply)
         if IsValidVehicle(veh) then
        for i2,vc in ipairs(checkpoints[k]) do
           if i2+1==v.number+1 then
            local x,y,z = GetVehicleLocation(veh)
            if z>0 then
            if GetDistance2D(x, y, races[racesnumbers[currace[k]]][i2+1][1], races[racesnumbers[currace[k]]][i2+1][2])<750 then
               v.number=i2+1
               local vh = GetVehicleHeading(GetPlayerVehicle(v.ply))
               SetPlayerSpawnLocation(v.ply, x, y, z+200, vh)
               CallRemoteEvent(v.ply,"hidecheckpoint",vc)
               local place = 0
 
               if i2 == #checkpoints[k] then
                  table.insert(finishclassement[k],v.ply)
                  place = #finishclassement[k]
                  CallRemoteEvent(v.ply,"classement_update",place,table_count(GetDimensionPlayers(tonumber(k))))
                  table.remove(playerscheckpoints[k],i)
                  for ilc,vlc in ipairs(lastclassement[k]) do
                     if vlc.ply == v.ply then
                        table.remove(lastclassement[k],ilc)
                     end
                  end
                  if #playerscheckpoints[k]>0 then
                           SetPlayerPropertyValue(v.ply,"leavingtospec",true,false)
                           RemovePlayerFromVehicle(v.ply)
                  end
                  checktorestart(tonumber(k))
               end
               
            end
         else
            SetPlayerHealth(v.ply, 0)
         end
           end
        end
      end
   end
   end
   end
      for k,uh in pairs(plyvehs) do
         for i,v in ipairs(uh) do
            if IsValidVehicle(v.vid) then
               if v.vhp > GetVehicleHealth(v.vid) then
                  SetVehicleHealth(v.vid, v.vhp)
                  SetVehicleDamage(v.vid, 1, 0.0)
                  SetVehicleDamage(v.vid, 2, 0.0)
                  SetVehicleDamage(v.vid, 3, 0.0)
                  SetVehicleDamage(v.vid, 4, 0.0)
                  SetVehicleDamage(v.vid, 5, 0.0)
                  SetVehicleDamage(v.vid, 6, 0.0)
                  SetVehicleDamage(v.vid, 7, 0.0)
                  SetVehicleDamage(v.vid, 8, 0.0)
               end
            end
         end
       end
   for k, v in pairs(GetAllDimensions()) do
      if v.name == "racing" then
         for i,v in ipairs(GetDimensionPlayers(k)) do
            if GetPlayerVehicle(v)~=0 then
               local veh = GetPlayerVehicle(v)
               if (IsValidVehicle(veh) and finishclassement[tostring(k)]) then
                  local place = #finishclassement[tostring(k)]+1
                  local pnumber = nil
                  local pindex = nil
                  for ic,vc in ipairs(playerscheckpoints[tostring(k)]) do
                     if vc.ply == v then
                        pnumber = vc.number
                        pindex = ic
                     end
                  end
                  if pnumber~=nil then
                     for ic,vc in ipairs(playerscheckpoints[tostring(k)]) do
                        if vc.ply ~= v then
                           if GetPlayerVehicle(vc.ply)~=0 then
                           local pveh = GetPlayerVehicle(vc.ply)
                           if IsValidVehicle(pveh) then
                           if vc.number > pnumber then
                              place = place+1
                           elseif vc.number == pnumber then
                              local x1,y1,z1 = GetVehicleLocation(veh)
                              local dist1 = GetDistance2D(x1, y1, races[racesnumbers[currace[tostring(k)]]][pnumber+1][1], races[racesnumbers[currace[tostring(k)]]][pnumber+1][2])
                              local x2,y2,z2 = GetVehicleLocation(pveh)
                              local dist2 = GetDistance2D(x2, y2, races[racesnumbers[currace[tostring(k)]]][pnumber+1][1], races[racesnumbers[currace[tostring(k)]]][pnumber+1][2])
                              if dist1>dist2 then
                                 place=place+1
                              end
                           end
                           end
                        end
                        end
                     end
                     local lastpl = 0
                     for ilc,vlc in ipairs(lastclassement[tostring(k)]) do
                        if vlc.ply == v then
                           lastpl = vlc.lplace
                           table.remove(lastclassement[tostring(k)],ilc)
                        end
                     end
                     if place ~= lastpl then
                        local lc = {}
                        lc.ply = v
                        lc.lplace = place
                        table.insert(lastclassement[tostring(k)],lc)
                        CallRemoteEvent(v,"classement_update",place,table_count(GetDimensionPlayers(k)))
                     end
                  end
               end
            end
         end
      end
   end
end

AddEvent("OnPackageStart",function()
   CreateTimer(timercheck, 50)
   if dev then
      print("DEV MODE ACTIVATED FOR " .. GetPackageName())
   end
end)

AddRemoteEvent("returncar_racing",function(ply)
   local veh = GetPlayerVehicle(ply)
   if IsValidVehicle(veh) then
   local rx,ry,rz = GetVehicleRotation(veh)
   SetVehicleRotation(veh, 0,ry,0)
   end
end)

AddCommand("race",function(ply,id)
    if dev then
        if id ~= nil then
           currace=tonumber(id)
           playerscheckpoints={}
           changerace()
        end
    end
end)

AddRemoteEvent("changespec",function(ply,spectated)
   local idnb = GetPlayerDimension(ply)
   local id = tostring(idnb)
   if #playerscheckpoints[id]>0 then
      local lookindex = false
      local found = false
      local compt = 0
    for i,v in ipairs(playerscheckpoints[id]) do
      if lookindex then
        speclogic(ply,v.ply)
        break
      end
      compt=compt+1
       if v.ply==spectated then
         found = true
          if compt==#playerscheckpoints[id] then
            for i,v in ipairs(playerscheckpoints[id]) do
               speclogic(ply,playerscheckpoints[id][i].ply)
               break
            end
          else
               lookindex=true
          end
       end
    end
    if not found then
      for i,v in ipairs(playerscheckpoints[id]) do
         speclogic(ply,playerscheckpoints[id][i].ply)
         break
      end
    end
    
   end
end)

function speclogic(cmdply,ply)
       AddPlayerChat(cmdply,"You are spectating " .. GetPlayerName(ply))
       local x, y, z = GetPlayerLocation(ply)
       CallRemoteEvent(cmdply,"SpecRemoteEvent",true,ply,x,y,z)
end

AddRemoteEvent("last_checkpoint",function(ply)
     local idnb = GetPlayerDimension(ply)
     local id = tostring(idnb)
     for i,v in ipairs(playerscheckpoints[id]) do
         if v.ply == ply then
            if v.number == 1 then
               SetPlayerHealth(ply,0)
            else 
               local veh = GetPlayerVehicle(ply)
               local rx,ry,rz = GetVehicleRotation(veh)
               SetVehicleRotation(veh, 0,ry,0)
               SetVehicleLinearVelocity(veh, 0, 0, 0 ,true)
               SetVehicleAngularVelocity(veh, 0, 0, 0 ,true)
               SetVehicleLocation(veh,races[racesnumbers[currace[id]]][v.number][1], races[racesnumbers[currace[id]]][v.number][2], races[racesnumbers[currace[id]]][v.number][3] + 200)
            end
         end
     end
end)

AddCommand("showspawns",function(ply)
   if dev then
    for i,v in ipairs(spawns[racesnumbers[currace]]) do
        if i > 1 then
         CreateObject(1363, v[1], v[2], v[3] , 0, spawns[racesnumbers[currace]][1], 0, 1, 1, 1)
        end
    end
   end
end)

AddRemoteEvent("imafk",function(ply)
    KickPlayer(ply,"Afk")
end)

local locktimer = nil
local lockyaw = nil

function refreshyaw(ply)
   if IsValidPlayer(ply) then
   local veh = GetPlayerVehicle(ply)
   local rx,ry,rz = GetVehicleRotation(veh)
   if veh~=0 then
      SetVehicleRotation(veh,rx,lockyaw,rz)
   end
else
   DestroyTimer(locktimer)
   locktimer = nil
   localyaw = nil
end
end

AddCommand("lockyaw",function(ply,yaw)
    if dev then
       if yaw then
         yaw = tonumber(yaw)
           lockyaw=yaw
           if locktimer then
              DestroyTimer(locktimer)
           end
           locktimer = CreateTimer(refreshyaw,1000,ply)
            local veh = GetPlayerVehicle(ply)
            local rx,ry,rz = GetVehicleRotation(veh)
            if veh~=0 then
               SetVehicleRotation(veh,rx,lockyaw,rz)
            end
         else
            if locktimer then
               DestroyTimer(locktimer)
               locktimer = nil
               localyaw = nil
            end
       end
    end
end)

AddRemoteEvent("Readytostart",function(ply)
   local idnb = GetPlayerDimension(ply)
   local id = tostring(idnb)
   for i,v in ipairs(notready[id]) do
      if v==ply then
         if table_count(notready[id])<=1 then
            for i,v in ipairs(playerscheckpoints[id]) do
               CallRemoteEvent(v.ply,"checkpointstbl",races[racesnumbers[currace[id]]],time_bef_start_s)
            end
         end
         table.remove(notready[id],i)
      end
   end
end)