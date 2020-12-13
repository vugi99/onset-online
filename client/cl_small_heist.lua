
local debuglinetrace = ImportPackage("debuglinetrace")

local function Check_aim_npc()
    if IsPlayerAiming() then
		local weap = GetPlayerWeapon(GetPlayerEquippedWeaponSlot())
        if GetWeaponType(weap) ~= 0 then
            local range = 2000
            local camX, camY, camZ = GetCameraLocation()
            local cfx, cfy, cfz = GetCameraForwardVector()
            local muzzleX, muzzleY, muzzleZ = GetPlayerWeaponMuzzleLocation()
            local hittype, hitid, impactX, impactY, impactZ
            if debuglinetrace then
                hittype, hitid, impactX, impactY, impactZ = debuglinetrace.Debug_LineTrace(muzzleX, muzzleY, muzzleZ, camX + cfx * range, camY + cfy * range, camZ + cfz * range)
            else
                hittype, hitid, impactX, impactY, impactZ = LineTrace(muzzleX, muzzleY, muzzleZ, camX + cfx * range, camY + cfy * range, camZ + cfz * range)
            end
            if hittype == 4 then
               local nclothes = GetNPCPropertyValue(hitid, "NetworkedClothes")
               if nclothes then
                  if nclothes.type == "preset" then
                     if (nclothes.clothes == 4 and not GetNPCPropertyValue(hitid, "InHeist")) then
                        CallRemoteEvent("StartSmallHeist", hitid)
                     end
                  end
               end
            end
        end
	end
end

AddEvent("OnPackageStart", function()
    CreateTimer(Check_aim_npc, 1000)
end)