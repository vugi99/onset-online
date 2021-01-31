

local passive_players = {}

function IsPlayerPassive(ply)
   for i,v in ipairs(passive_players) do
      if v.ply == ply then
         return true
      end
   end  
   return false
end

function SetPlayerPassive(ply, enable, from_client)
   if enable then
      if not IsPlayerPassive(ply) then
         local x,y,z = GetPlayerLocation(ply)
         local text = CreateText3D("Passive", 14, x, y, z, 0, 0, 0)
         AddText3DInDimension(text, GetPlayerDimension(ply))
         SetText3DAttached(text, 1, ply, 0, 0, 200)
         local tbl = {}
         tbl.ply = ply
         tbl.text = text
         table.insert(passive_players, tbl)
         if not from_client then
            CallRemoteEvent(ply, "SetPassiveClient", true)
         end
      end
    else
        for i,v in ipairs(passive_players) do
            if v.ply == ply then
               DestroyText3D(v.text)
               table.remove(passive_players,i)
               if not from_client then
                  CallRemoteEvent(ply, "SetPassiveClient", false)
               end
            end
        end  
   end
end
AddRemoteEvent("SetPlayerPassive",SetPlayerPassive)

AddEvent("OnPlayerQuit", function(ply)
    SetPlayerPassive(ply, false, true)
end)

AddEvent("OnPlayerWeaponShot",function(ply, weap, hittype, hitid, hitX, hitY, hitZ, startX, startY, startZ, normalX, normalY, normalZ, BoneName)
    if hittype == 2 then
       if IsPlayerPassive(hitid) then
          AddPlayerChat(ply, "This Player is in Passive Mode")
          return false
       end
    end
end)