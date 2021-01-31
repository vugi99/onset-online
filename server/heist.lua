
local heist_zones = {}
local heist_vehs = {}
local heist_players = {}
heist_trigger_pickups = {}
heist_robbers_deaths = 0
local heist_objects = {}
local heist_boat
local final_heist_money = 0
local heist_tp_back = nil
heist_phase_in_progress = false

function IsHeistPlayer(ply)
    for i, v in ipairs(heist_players) do
        if v.ply == ply then
            return true
        end
    end
    return false
end

function IsHeistHostPlayer(ply)
    for i, v in ipairs(heist_players) do
        if (v.ply == ply and v.host) then
            return true
        end
    end
    return false
end

function GetAllHeistPlayers()
    local tbl = {}
    for i, v in ipairs(heist_players) do
        table.insert(tbl, v.ply)
    end
    return tbl
end

function GetHeistHost()
    for i, v in ipairs(GetAllPlayers()) do
        if IsHeistHostPlayer(v) then
            return v
        end
    end
    return false
end

function HasAWeapon(ply)
    if (GetPlayerWeapon(ply, 1) ~= 1 or GetPlayerWeapon(ply, 2) ~= 1 or GetPlayerWeapon(ply, 3) ~= 1) then
        return true
    end
    return false
end

function GetPhaseTbl(phase)
    return heist_phases[phase + 1]
end

function GetFinalPhaseVehicle()
    for i, v in ipairs(heist_vehs) do
        if GetVehiclePropertyValue(v, "Final_HeistVeh") then
            return v
        end
    end
    return false
end

function TpBackPlayer(ply)
    if heist_tp_back then
        SetPlayerLocation(ply, heist_tp_back[1], heist_tp_back[2], heist_tp_back[3])
        SetPlayerHeading(ply, heist_tp_back[4])
    end
end

function Final_Phase_Enter_Bank(ply)
    SetPlayerLocation(ply, heist_final_phase.bank_exit_trigger[1], heist_final_phase.bank_exit_trigger[2], heist_final_phase.bank_exit_trigger[3])
    SetPlayerHeading(ply, heist_final_phase.bank_exit_trigger[4])
    SetPlayerPropertyValue(ply, "Pickup_Cooldown", true, false)
    Delay(2000, function()
        SetPlayerPropertyValue(ply, "Pickup_Cooldown", nil, false)
    end)
end

AddEvent("OnPlayerTriggerHeist", function(ply, pickup)
    local houseid
    local x, y, z = GetPickupLocation(pickup)
    for i, v in ipairs(Appartments) do
        if (v.Heist_Trigger[1] == x and v.Heist_Trigger[2] == y and v.Heist_Trigger[3] == z) then
            houseid = i
            break
        end
    end
    if houseid then
        if GetPlayerPropertyValue(ply, "HouseOwner") then
            if not heist_phase_in_progress then
                if HasAWeapon(ply) then
                    CallRemoteEvent(ply, "StartHeistUI", houseid, PlayerData[ply].heist_phase)
                else
                    CallRemoteEvent(ply, "CreateNotification", "Heist", "You need a weapon", 5000)
                end
            else
                CallRemoteEvent(ply, "CreateNotification", "Heist", "An heist phase was already started by another player", 5000)
            end
        else
            CallRemoteEvent(ply, "CreateNotification", "Heist", "You can't start an heist phase", 5000)
        end
    else
        print("Error : can't find houseid : OnPlayerTriggerHeist")
    end
end)

function UpdateHeistPhaseFor(ply)
    local query = mariadb_prepare(db, "UPDATE accounts SET heist_phase = ? WHERE accountid = ? LIMIT 1;",
					PlayerData[ply].heist_phase,
					PlayerData[ply].accountid
	    )

		mariadb_query(db, query)
end

function FinishHeistPhase(success)
    if heist_phase_in_progress then
        for i, v in ipairs(heist_vehs) do
            DestroyVehicle(v)
        end
        for i, v in ipairs(heist_zones) do
            DestroyZone(v)
        end
        for i, v in ipairs(heist_trigger_pickups) do
            DestroyPickupTrigger(v)
        end
        for i, v in ipairs(heist_objects) do
            DestroyObject(v)
        end
        if success then
            local host = GetHeistHost()
            if host then
               if PlayerData[host] then
                  if PlayerData[host].heist_phase < table_count(heist_phases) then
                      PlayerData[host].heist_phase = heist_phase_in_progress + 1
                  else
                      PlayerData[host].heist_phase = 0
                  end
                  UpdateHeistPhaseFor(host)
               end
            end
            if heist_boat then
                local heist_players_count = table_count(GetAllHeistPlayers())
                if final_heist_money > heist_final_phase.money_won_max_per_player * heist_players_count then
                    final_heist_money = heist_final_phase.money_won_max_per_player * heist_players_count
                end
                for i, v in ipairs(GetAllHeistPlayers()) do
                    Sell(v, math.floor(final_heist_money / heist_players_count))
                    CallRemoteEvent(v, "CreateNotification", "Heist", "You won " .. tostring(final_heist_money / heist_players_count) .. "$", 10000)
                end
                local _heist_boat = heist_boat
                SetVehicleLinearVelocity(_heist_boat, heist_final_phase.vector_push_boat[1], heist_final_phase.vector_push_boat[2], heist_final_phase.vector_push_boat[3], true)
                Delay(7500, function()
                    DestroyVehicle(_heist_boat)
                end)
            end
        elseif heist_boat then
            DestroyVehicle(heist_boat)
        end
        for i, v in ipairs(GetAllHeistPlayers()) do
            TpBackPlayer(v)
            CallRemoteEvent(v, "HeistPhaseFinished", success)
        end
        heist_zones = {}
        heist_vehs = {}
        heist_players = {}
        heist_trigger_pickups = {}
        heist_objects = {}
        heist_boat = nil
        heist_phase_in_progress = false
        final_heist_money = 0
        heist_tp_back = nil
        heist_robbers_deaths = 0
    end
end

function StartHeistPhase()
    if heist_phase_in_progress < table_count(heist_phases) then
        local phase_tbl = GetPhaseTbl(heist_phase_in_progress)
        if phase_tbl.type == "GET_VEHICLE" then
            local veh = CreateVehicle(phase_tbl.vehicle, phase_tbl.vehpos[1], phase_tbl.vehpos[2], phase_tbl.vehpos[3], phase_tbl.vehpos[4])
            SetVehiclePropertyValue(veh, "HeistVeh", true, false)
            SetVehiclePropertyValue(veh, "VehArmor_Heist", phase_tbl.veh_armor_percentage, false)
            AddVehicleInDimension(veh, GetDimensionByName("base"))
            local zoneid = CreateZone(phase_tbl.vehpos_after[1] - 250, phase_tbl.vehpos_after[2] - 250, phase_tbl.vehpos_after[1] + 250, phase_tbl.vehpos_after[2] + 250, phase_tbl.vehpos_after[3], "OnEnterHeistVeh_End_Zone", "OnLeaveHeistVeh_End_Zone")
            table.insert(heist_zones, zoneid)
            table.insert(heist_vehs, veh)
            for i, v in ipairs(GetAllHeistPlayers()) do
                CallRemoteEvent(v, "HeistPhaseStarted", {{1, "Vehicle", phase_tbl.vehpos[1], phase_tbl.vehpos[2], phase_tbl.vehpos[3]}}, {{1, "Steal the vehicle"}})
            end
        end -- TODO : Add more phases types
    else
        local xafter, yafter, zafter
        if heist_phases[heist_final_phase.use_vehicle_of_phase] then
            if heist_phases[heist_final_phase.use_vehicle_of_phase].type == "GET_VEHICLE" then
                local phase_tbl = heist_phases[heist_final_phase.use_vehicle_of_phase]
                xafter, yafter, zafter = phase_tbl.vehpos_after[1], phase_tbl.vehpos_after[2], phase_tbl.vehpos_after[3]
                local veh = CreateVehicle(phase_tbl.vehicle, phase_tbl.vehpos_after[1], phase_tbl.vehpos_after[2], phase_tbl.vehpos_after[3], phase_tbl.vehpos_after[4])
                SetVehiclePropertyValue(veh, "HeistVeh", true, false)
                SetVehiclePropertyValue(veh, "Final_HeistVeh", true, false)
                SetVehiclePropertyValue(veh, "VehArmor_Heist", phase_tbl.veh_armor_percentage, false)
                AddVehicleInDimension(veh, GetDimensionByName("base"))
                table.insert(heist_vehs, veh)
            else
                print("Error : heist_phases[heist_final_phase.use_vehicle_of_phase].type ~= GET_VEHICLE")
            end
        else
            print("Error : no heist_final_phase.use_vehicle_of_phase")
        end

        local pickup = CreatePickupTrigger(2, heist_final_phase.bank_enter_trigger[1], heist_final_phase.bank_enter_trigger[2], heist_final_phase.bank_enter_trigger[3], false, "EnterBank")
        AddPickupInDimension(pickup, GetDimensionByName("base"))
        table.insert(heist_trigger_pickups, pickup)

        local pickup2 = CreatePickupTrigger(2, heist_final_phase.bank_exit_trigger[1], heist_final_phase.bank_exit_trigger[2], heist_final_phase.bank_exit_trigger[3], false, "LeaveBank")
        AddPickupInDimension(pickup2, GetDimensionByName("base"))
        table.insert(heist_trigger_pickups, pickup2)

        local dim = GetDimensionByName("base")
        for i, v in ipairs(heist_final_phase.objects) do
            local obj = CreateObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10])
            AddObjectInDimension(obj, dim)
            table.insert(heist_objects, obj)
        end

        local boat = CreateVehicle(34, heist_final_phase.boat[1], heist_final_phase.boat[2], heist_final_phase.boat[3], heist_final_phase.boat[4])
        AddVehicleInDimension(boat, dim)
        heist_boat = boat
        SetVehiclePropertyValue(boat, "IsHeistBOAT", true, false)

        local zoneid = CreateZone(heist_final_phase.boat_zone[1], heist_final_phase.boat_zone[2], heist_final_phase.boat_zone[3], heist_final_phase.boat_zone[4], heist_final_phase.boat_zone[5], "OnEnterBoatZone", "OnLeaveBoatZone")
        table.insert(heist_zones, zoneid)

        for i, v in ipairs(GetAllHeistPlayers()) do
            CallRemoteEvent(v, "HeistPhaseStarted", {{1, "Vehicle", xafter, yafter, zafter}}, {{1, "Take the vehicle"}, {2, ""}})
        end
    end
end

AddEvent("OnEnterHeistVeh_End_Zone", function(ply, zoneid)
    if IsHeistPlayer(ply) then
        local veh = GetPlayerVehicle(ply)
        if veh ~= 0 then
            if GetVehiclePropertyValue(veh, "HeistVeh") then
                FinishHeistPhase(true)
            end
        end
    end
end)

AddRemoteEvent("StartHeistToServer", function(ply, houseid)
    if not heist_phase_in_progress then
        if HasAWeapon(ply) then
            local good = true
            if PlayerData[ply].heist_phase >= table_count(heist_phases) then
                if table_count(GetPolicePlayers()) < heist_final_phase.police_players_required then
                    good = false
                    CallRemoteEvent(ply, "CreateNotification", "Heist", "Not enough policemans", 5000)
                end
            end
            if good then
                local dim = GetPlayerDimension(ply)
                ExitHouse(ply, houseid)
                LeavePoliceman(ply)
                for i, v in ipairs(GetAllPlayers()) do
                    if (v ~= ply and GetPlayerDimension(v) == dim) then
                        ExitHouse(v, houseid)
                        table.insert(heist_players, {ply = v})
                        LeavePoliceman(v)
                    end
                end
                SetPlayerPropertyValue(ply, "HouseOwner", nil, false)
                table.insert(heist_players, {ply = ply, host = true})
                heist_phase_in_progress = PlayerData[ply].heist_phase
                heist_tp_back = {Appartments[houseid].Appartment_exit_tp[1], Appartments[houseid].Appartment_exit_tp[2], Appartments[houseid].Appartment_exit_tp[3], Appartments[houseid].Appartment_exit_tp[4]}
                StartHeistPhase()
            end
        else
            CallRemoteEvent(ply, "CreateNotification", "Heist", "You need a weapon", 5000)
        end
    else
        CallRemoteEvent(ply, "CreateNotification", "Heist", "An heist phase was already started by another player", 5000)
    end
end)

AddEvent("OnPlayerQuit", function(ply)
    if IsHeistPlayer(ply) then
        if IsHeistHostPlayer(ply) then
            FinishHeistPhase(false)
        else
            for i, v in ipairs(heist_players) do
                if v.ply == ply then
                    table.remove(heist_players, i)
                    break
                end
            end
        end
    end
end)

AddEvent("OnPlayerEnterVehicle", function(ply, veh, seat)
    if heist_phase_in_progress then
        if GetVehiclePropertyValue(veh, "IsHeistBOAT") then
            RemovePlayerFromVehicle(ply)
        end
        if GetVehiclePropertyValue(veh, "HeistVeh") then
            if not IsHeistPlayer(ply) then
                RemovePlayerFromVehicle(ply)
            else
                if not GetVehiclePropertyValue(veh, "HeistVeh_Objective_Done") then
                    if heist_phase_in_progress < table_count(heist_phases) then
                        local phase_tbl = heist_phases[heist_phase_in_progress + 1]
                        if phase_tbl.type == "GET_VEHICLE" then
                            SetVehiclePropertyValue(veh, "HeistVeh_Objective_Done", true, false)
                            for i, v in ipairs(GetAllHeistPlayers()) do
                                CallRemoteEvent(v, "ChangeHeistObjectives", {{1, "Park here", phase_tbl.vehpos_after[1], phase_tbl.vehpos_after[2], phase_tbl.vehpos_after[3]}}, {{1, "Park the vehicle"}})
                                LeavePoliceman(v)
                                AddCriminalBonus(v)
                            end
                            for i, v in ipairs(GetPolicePlayers()) do
                                CallRemoteEvent(v, "HeistStealVehAlert", phase_tbl.veh_pos_str)
                            end
                        end
                    elseif heist_boat then
                        SetVehiclePropertyValue(veh, "HeistVeh_Objective_Done", true, false)
                        for i, v in ipairs(GetAllHeistPlayers()) do
                            CallRemoteEvent(v, "ChangeHeistObjectives", {{1, "Bank", heist_final_phase.bank_enter_trigger[1], heist_final_phase.bank_enter_trigger[2], heist_final_phase.bank_enter_trigger[3]}}, {{1, "Enter the bank"}})
                            LeavePoliceman(v)
                        end
                    end
                end
            end
        end
    end
end)

AddEvent("OnPlayerWeaponShot", function(ply, weap, hittype, hitid, hitX, hitY, hitZ, startX, startY, startZ, normalX, normalY, normalZ, BoneName)
    if heist_phase_in_progress then
        if robbers_invincible_from_no_police_players then
            if hittype == HIT_PLAYER then
                if IsHeistPlayer(hitid) then
                    if not IsPoliceman(ply) then
                        AddPlayerChat(ply, "You can't shoot on him")
                        return false
                    end
                end
            elseif hittype == HIT_VEHICLE then
                if GetVehiclePropertyValue(hitid, "IsHeistBOAT") then
                    AddPlayerChat(ply, "You can't shoot on this")
                    return false
                end
                if GetVehiclePropertyValue(hitid, "HeistVeh") then
                    if (not IsPoliceman(ply) and not IsHeistPlayer(ply)) then
                        AddPlayerChat(ply, "You can't shoot on this")
                        return false
                    end
                end
            end
        end
    end
end)

AddEvent("EnterBank", function(ply, pickup)
    if (IsHeistPlayer(ply) or IsPoliceman(ply)) then
        local veh = GetFinalPhaseVehicle()
        if veh then
            if GetVehiclePropertyValue(veh, "HeistVeh_Objective_Done") then
                if not GetPlayerPropertyValue(ply, "Pickup_Cooldown") then
                    if not GetPickupPropertyValue(pickup, "Entered_Bank_Objective_Done") then
                        if not IsPoliceman(ply) then
                            SetPickupPropertyValue(pickup, "Entered_Bank_Objective_Done", true, false)
                            for i, v in ipairs(GetAllHeistPlayers()) do
                                CallRemoteEvent(v, "ChangeHeistObjectives", {{1, "Gold", heist_final_phase.waypoint_loc[1], heist_final_phase.waypoint_loc[2], heist_final_phase.waypoint_loc[3]}}, {{1, "Rob the gold"}, {2, "Heist : " .. tostring(final_heist_money) .. " / " .. tostring(heist_final_phase.money_won_max_per_player * table_count(GetAllHeistPlayers())) .. "$"}})
                                LeavePoliceman(v)
                            end
                            for i, v in ipairs(GetPolicePlayers()) do
                                CallRemoteEvent(v, "HeistAlert")
                            end
                            Final_Phase_Enter_Bank(ply)
                        end
                    else
                        if not GetVehiclePropertyValue(veh, "GoldFull") then
                            CallRemoteEvent(ply, "ChangeHeistObjectives", {{1, "Gold", heist_final_phase.waypoint_loc[1], heist_final_phase.waypoint_loc[2], heist_final_phase.waypoint_loc[3]}}, {{1, "Rob the gold"}})
                        end
                        Final_Phase_Enter_Bank(ply)
                    end
                end
            else
                if IsHeistPlayer(ply) then
                    CallRemoteEvent(ply, "CreateNotification", "Bank", "Take the vehicle first", 5000)
                end
            end
        else
            print("Error : can't find FinalPhaseVehicle : EnterBank Event")
        end
    else
        CallRemoteEvent(ply, "CreateNotification", "Bank", "You can't enter the bank", 5000)
    end
end)

AddEvent("LeaveBank", function(ply, pickup)
    if not GetPlayerPropertyValue(ply, "Pickup_Cooldown") then
        local veh = GetFinalPhaseVehicle()
        if veh then
            local x, y, z = GetVehicleLocation(veh)
            if IsHeistPlayer(ply) then
                if not GetVehiclePropertyValue(veh, "GoldFull") then
                    CallRemoteEvent(ply, "ChangeHeistObjectives", {{1, "Vehicle", x, y, z}}, {{1, "Put the gold in the vehicle"}})
                    LeavePoliceman(ply)
                end
            end
            SetPlayerLocation(ply, heist_final_phase.bank_enter_trigger[1], heist_final_phase.bank_enter_trigger[2], heist_final_phase.bank_enter_trigger[3])
            SetPlayerHeading(ply, heist_final_phase.bank_enter_trigger[4])
            SetPlayerPropertyValue(ply, "Pickup_Cooldown", true, false)
            Delay(2000, function()
                SetPlayerPropertyValue(ply, "Pickup_Cooldown", nil, false)
            end)
        else
            print("Error : can't find heist veh : LeaveBank Event")
        end
    end
end)

AddRemoteEvent("HeistPutGold", function(ply, gold)
    if IsHeistPlayer(ply) then
        if final_heist_money + gold <= heist_final_phase.money_won_max_per_player * table_count(GetAllHeistPlayers()) then
            final_heist_money = final_heist_money + gold
            if final_heist_money + heist_final_phase.money_taken_per_action <= heist_final_phase.money_won_max_per_player * table_count(GetAllHeistPlayers()) then
                for i, v in ipairs(GetAllHeistPlayers()) do
                    CallRemoteEvent(v, "ChangeHeistObjectives", false, {{2, "Heist : " .. tostring(final_heist_money) .. " / " .. tostring(heist_final_phase.money_won_max_per_player * table_count(GetAllHeistPlayers())) .. "$"}})
                end
            else
                for i, v in ipairs(GetAllHeistPlayers()) do
                    CallRemoteEvent(v, "ChangeHeistObjectives", {{1, "Escape", heist_final_phase.boat[1], heist_final_phase.boat[2], heist_final_phase.boat[3]}}, {{1, "Escape with the vehicle !"}, {2, "Heist : " .. tostring(final_heist_money) .. " / " .. tostring(heist_final_phase.money_won_max_per_player * table_count(GetAllHeistPlayers())) .. "$"}})
                end
                local veh = GetFinalPhaseVehicle()
                if veh then
                    SetVehiclePropertyValue(veh, "GoldFull", true, false)
                else
                    print("Error : can't find final phase veh : HeistPutGold")
                end
            end
        else
            CallRemoteEvent(ply, "CreateNotification", "Heist", "Gold full in the vehicle", 5000)
        end
    end
end)

AddEvent("OnEnterBoatZone", function(ply, zoneid)
    if IsHeistPlayer(ply) then
        local veh = GetPlayerVehicle(ply)
        if veh ~= 0 then
            if GetVehiclePropertyValue(veh, "Final_HeistVeh") then
                FinishHeistPhase(true)
            end
        end
    end
end)

AddEvent("OnVehicleDamage", function(veh, damage, damageIndex, damageAmount)
    if heist_phase_in_progress then
        --print(veh, damage, damageIndex, damageAmount)
        local armor_percentage = GetVehiclePropertyValue(veh, "VehArmor_Heist")
        if armor_percentage then
            if GetVehicleHealth(veh) > 0 then
                --print(armor_percentage * 2 / 100)
                SetVehicleHealth(veh, GetVehicleHealth(veh) + (damage * ((armor_percentage / 100) / 2)))
            end
        end
        --print(damage, GetVehicleHealth(veh))
        if GetVehicleHealth(veh) == 0 then
            if GetVehiclePropertyValue(veh, "Final_HeistVeh") then
                FinishHeistPhase(false)
            elseif heist_phase_in_progress < table_count(heist_phases) then
                local phase_tbl = GetPhaseTbl(heist_phase_in_progress)
                if phase_tbl.type == "GET_VEHICLE" then
                    if GetVehiclePropertyValue(veh, "HeistVeh") then
                        FinishHeistPhase(false)
                    end
                end
            end
        end
    end
end)

function LeaveHeist(ply)
    if heist_phase_in_progress then
        if IsHeistPlayer(ply) then
            if IsHeistHostPlayer(ply) then
                FinishHeistPhase(false)
            else
                for i, v in ipairs(heist_players) do
                    if v.ply == ply then
                        table.remove(heist_players, i)
                        break
                    end
                end
                TpBackPlayer(ply)
                CallRemoteEvent(ply, "HeistPhaseFinished", false)
            end
        end
    end
end

AddRemoteEvent("LeaveHeist", function(ply)
    LeaveHeist(ply)
end)