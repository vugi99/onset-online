
local PickupsToBunkersIds = {}
local PlayersInBunker = {}

local UpdateBunkersTimers = {}

local IsPlayerStealing_RawMats = false
local Stealing_RawMats_data

local IsPlayerSellingWeapons = false
local Selling_weapons_data

function GetBunkerIdFromPickup(pickup)
    for i, v in ipairs(PickupsToBunkersIds) do
        if v.pickup == pickup then
            return v.bunkerid
        end
    end
    return false
end

function GetPlayerInBunker(ply)
    for i, v in ipairs(PlayersInBunker) do
        if v.ply == ply then
            return i, v
        end
    end
    return false
end

function GetPlayerBunkerDataFromBunkerid(ply, bunkerid)
    for i, v in ipairs(PlayerData[ply].bunkers) do
        if v.id == bunkerid then
            return i, v
        end
    end
    return false
end

function OwnsBunker(ply, bunkerid)
    for i, v in ipairs(PlayerData[ply].bunkers) do
        if v.id == bunkerid then
            return true
        end
    end
    return false
end

function UpdateBunker(ply, bunkerid, no_add)
    if PlayerData[ply] then
        local updated_b = no_add
        local bindex, b_data = GetPlayerBunkerDataFromBunkerid(ply, bunkerid)
        if (b_data.raw_mats > 0 and b_data.storage < 100 and not no_add) then
            PlayerData[ply].bunkers[bindex].raw_mats = PlayerData[ply].bunkers[bindex].raw_mats - 1
            PlayerData[ply].bunkers[bindex].storage = PlayerData[ply].bunkers[bindex].storage + 1
            updated_b = true
        end
        local i, data = GetPlayerInBunker(ply)
        if i then
            local dim = data.dim
            if (data.npc_data_text == "Waiting" and b_data.raw_mats > 0 and b_data.storage < 100) then
                PlayersInBunker[i].npc_data_text = "Working"
                for i2, v in ipairs(_Bunkers[bunkerid].Bunker_Working_Objects) do
                    local obj = CreateObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10])
                    AddObjectInDimension(obj, dim)
                    table.insert(PlayersInBunker[i].w_objects, obj)
                end
                SetNPCLocation(data.npc, _Bunkers[bunkerid].Bunker_NPC_Working[2], _Bunkers[bunkerid].Bunker_NPC_Working[3], _Bunkers[bunkerid].Bunker_NPC_Working[4])
                SetNPCHeading(data.npc, _Bunkers[bunkerid].Bunker_NPC_Working[5])
                SetNPCAnimation(data.npc, _Bunkers[bunkerid].Bunker_NPC_Working[1], true)
            elseif (data.npc_data_text == "Working" and not (b_data.raw_mats > 0 and b_data.storage < 100)) then
                PlayersInBunker[i].npc_data_text = "Waiting"
                for i2, v in ipairs(data.w_objects) do
                    DestroyObject(v)
                end
                PlayersInBunker[i].w_objects = {}
                SetNPCLocation(data.npc, _Bunkers[bunkerid].Bunker_NPC_Waiting[2], _Bunkers[bunkerid].Bunker_NPC_Waiting[3], _Bunkers[bunkerid].Bunker_NPC_Waiting[4])
                SetNPCHeading(data.npc, _Bunkers[bunkerid].Bunker_NPC_Waiting[5])
                SetNPCAnimation(data.npc, _Bunkers[bunkerid].Bunker_NPC_Waiting[1], true)
            end
            if updated_b then
                SetNPCPropertyValue(data.npc, "BunkerData", b_data, true)
                SetText3DText(data.b_text3d, "Storage : " .. tostring(b_data.storage) .. "%, Raw Materials : " .. tostring(b_data.raw_mats) .. "%")
                for i2, v in ipairs(_Bunkers[bunkerid].Bunker_Percentage_Objects) do
                    if v.p == b_data.storage then
                        for i3, v3 in ipairs(v.objects) do
                            local obj = CreateObject(v3[1], v3[2], v3[3], v3[4], v3[5], v3[6], v3[7], v3[8], v3[9], v3[10])
                            AddObjectInDimension(obj, dim)
                        end
                    end
                end
            end
        end
    end
end

AddEvent("PlayerDataLoaded", function(ply)
    local tbl = {
        ply = ply,
        timers = {}
    }
    for i, v in ipairs(PlayerData[ply].bunkers) do
        table.insert(tbl.timers, CreateTimer(UpdateBunker, _Bunkers[v.id].Bunker_Interval_To_Add_1_percent_s * 1000, ply, v.id))
    end
    table.insert(UpdateBunkersTimers, tbl)
end)

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(_Bunkers) do
          local obj = CreatePickupTrigger(2, v.Bunker_enter_location[1], v.Bunker_enter_location[2], v.Bunker_enter_location[3], false, "OnPlayerEnterBunker")
          AddPickupInDimension(obj, id)
          local tbl = {
              bunkerid = i,
              pickup = obj
          }
          table.insert(PickupsToBunkersIds, tbl)
          local text = CreateText3D("Bunker " .. tostring(i), 16, v.Bunker_enter_location[1], v.Bunker_enter_location[2], v.Bunker_enter_location[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddEvent("OnPlayerEnterBunker", function(ply, pickup)
    if PlayerData[ply] then
        local bunkerid = GetBunkerIdFromPickup(pickup)
        if (bunkerid and _Bunkers[bunkerid]) then
            if OwnsBunker(ply, bunkerid) then
                if IsPlayerStealing_RawMats then
                    if Stealing_RawMats_data.ply == ply then
                        if not Stealing_RawMats_data.pickup then
                            local bindex, b_data = GetPlayerBunkerDataFromBunkerid(ply, bunkerid)
                            PlayerData[ply].bunkers[bindex].raw_mats = clamp(PlayerData[ply].bunkers[bindex].raw_mats, 0, 100, _Bunkers[bunkerid].Raw_materials_steal_add_percent)
                            CallRemoteEvent(ply, "BunkerMissionFinished", true, "Raw Materials steal")
                            AwardXp(ply, _Bunkers_raw_materials_steal_xp_earned)
                            IsPlayerStealing_RawMats = false
                            Stealing_RawMats_data = nil
                        end
                    end
                end
                local dim = CreateDimension("bunker", true)
                AddPlayerInDimension(ply, dim)
                SetPlayerLocation(ply, _Bunkers[bunkerid].Bunker_spawn_after_enter[1], _Bunkers[bunkerid].Bunker_spawn_after_enter[2], _Bunkers[bunkerid].Bunker_spawn_after_enter[3])
                SetPlayerHeading(ply, _Bunkers[bunkerid].Bunker_spawn_after_enter[4])
                local exit_pickup = CreatePickupTrigger(2, _Bunkers[bunkerid].Bunker_exit_location[1], _Bunkers[bunkerid].Bunker_exit_location[2], _Bunkers[bunkerid].Bunker_exit_location[3], false, "OnPlayerExitBunker")
                AddPickupInDimension(exit_pickup, dim)
                local text = CreateText3D("Exit", 16, _Bunkers[bunkerid].Bunker_exit_location[1], _Bunkers[bunkerid].Bunker_exit_location[2], _Bunkers[bunkerid].Bunker_exit_location[3] + 100, 0, 0, 0)
                AddText3DInDimension(text, dim)
                local npc_data_text
                local npc_data
                local working_objects = {}
                local index, b_data = GetPlayerBunkerDataFromBunkerid(ply, bunkerid)
                if (b_data.raw_mats > 0 and b_data.storage < 100) then
                    npc_data = _Bunkers[bunkerid].Bunker_NPC_Working
                    npc_data_text = "Working"
                    for i, v in ipairs(_Bunkers[bunkerid].Bunker_Working_Objects) do
                        local obj = CreateObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10])
                        AddObjectInDimension(obj, dim)
                        table.insert(working_objects, obj)
                    end
                else
                    npc_data = _Bunkers[bunkerid].Bunker_NPC_Waiting
                    npc_data_text = "Waiting"
                end
                local npc = CreateNPC(npc_data[2], npc_data[3], npc_data[4], npc_data[5])
                AddNPCInDimension(npc, dim)
                SetNPCNetworkedClothingPreset(npc, 12)
                SetNPCAnimation(npc, npc_data[1], true)
                SetNPCPropertyValue(npc, "BunkerData", b_data, true)
                table.insert(online_invincible_npcs, npc)
                local bunker_text3d = CreateText3D("Storage : " .. tostring(b_data.storage) .. "%, Raw Materials : " .. tostring(b_data.raw_mats) .. "%", 16, _Bunkers[bunkerid].Bunker_progress_text3d_location[1], _Bunkers[bunkerid].Bunker_progress_text3d_location[2], _Bunkers[bunkerid].Bunker_progress_text3d_location[3] + 100, 0, 0, 0)
                AddText3DInDimension(bunker_text3d, dim)
                for i, v in ipairs(_Bunkers[bunkerid].Bunker_Objects) do
                    local obj = CreateObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10])
                    AddObjectInDimension(obj, dim)
                end
                for i, v in ipairs(_Bunkers[bunkerid].Bunker_Percentage_Objects) do
                    if b_data.storage >= v.p then
                        for i3, v3 in ipairs(v.objects) do
                            local obj = CreateObject(v3[1], v3[2], v3[3], v3[4], v3[5], v3[6], v3[7], v3[8], v3[9], v3[10])
                            AddObjectInDimension(obj, dim)
                        end
                    end
                end
                local tbl = {
                    ply = ply,
                    bunkerid = bunkerid,
                    npc = npc,
                    b_text3d = bunker_text3d,
                    npc_data_text = npc_data_text,
                    w_objects = working_objects,
                    dim = dim,
                }
                table.insert(PlayersInBunker, tbl)
            elseif HasEnoughMoney(ply, _Bunkers[bunkerid].Bunker_price) then
                CallRemoteEvent(ply, "ShowBuyBunkerUI", bunkerid)
            else
                CallRemoteEvent(ply, "CreateNotification", "Bunker", "You don't have enough money to buy this bunker", 5000)
            end
        else
            print("Error : can't get bunkerid : OnPlayerEnterBunker")
        end
    end
end)

AddRemoteEvent("BuyBunker", function(ply, bunkerid)
    if PlayerData[ply] then
        if _Bunkers[bunkerid] then
            if not OwnsBunker(ply, bunkerid) then
                if Buy(ply, _Bunkers[bunkerid].Bunker_price) then
                    local tbl = {
                        id = bunkerid,
                        raw_mats = 0,
                        storage = 0,
                    }
                    table.insert(PlayerData[ply].bunkers, tbl)
                    --[[local query = mariadb_prepare(db, "UPDATE accounts SET bunkers = '?' WHERE accountid = ? LIMIT 1;",
                        json_encode(PlayerData[ply].bunkers),
                        PlayerData[ply].accountid
                    )

                    mariadb_query(db, query)]]--
                    CallRemoteEvent(ply, "CreateNotification", "Bunker", "You bought the bunker " .. tostring(bunkerid), 10000)
                else
                    CallRemoteEvent(ply, "CreateNotification", "Bunker", "Purchase failed", 5000)
                    print("Bunker purchase failed : RemoteEvent : BuyBunker")
                end
            else
                print("Error : player wants to buy bunker while already owning it : RemoteEvent : BuyBunker")
            end
        else
            print("Error : Invalid bunkerid : RemoteEvent : BuyBunker")
        end
    end
end)

function PlayerExitBunker(ply, pickup)
    local i, data = GetPlayerInBunker(ply)
    if i then
        local bunkerid = data.bunkerid
        for i2, v in ipairs(online_invincible_npcs) do
            if data.npc == v then
                table.remove(online_invincible_npcs, i2)
                break
            end
        end
        AddPlayerInDimension(ply, GetDimensionByName("base"))
        SetPlayerLocation(ply, _Bunkers[bunkerid].Bunker_spawn_after_exit[1], _Bunkers[bunkerid].Bunker_spawn_after_exit[2], _Bunkers[bunkerid].Bunker_spawn_after_exit[3])
        SetPlayerHeading(ply, _Bunkers[bunkerid].Bunker_spawn_after_exit[4])
        table.remove(PlayersInBunker, i)
    else
        print("Error : no bunkerid : OnPlayerExitBunker")
    end
end
AddEvent("OnPlayerExitBunker", PlayerExitBunker)

AddRemoteEvent("BuyRawMats", function(ply)
    if PlayerData[ply] then
        local i, data = GetPlayerInBunker(ply)
        if i then
            local bunkerid = data.bunkerid
            local bindex, b_data = GetPlayerBunkerDataFromBunkerid(ply, bunkerid)
            if b_data.raw_mats == 0 then
                if Buy(ply, _Bunkers[bunkerid].Full_Raw_Materials_price) then
                    PlayerData[ply].bunkers[bindex].raw_mats = 100
                    UpdateBunker(ply, bunkerid, true)
                    CallRemoteEvent(ply, "Bunker", "You bought raw materials", 5000)
                end
            end
        else
            print("Error : no bunkerid : BuyRawMats")
        end
    end
end)

AddRemoteEvent("StealRawMats", function(ply)
    if PlayerData[ply] then
        if not IsPlayerStealing_RawMats then
            local good = true
            if IsPlayerSellingWeapons then
                 if Selling_weapons_data.ply == ply then
                     good = false
                 end
            end
            if good then
                local i, data = GetPlayerInBunker(ply)
                if i then
                    local bunkerid = data.bunkerid
                    local bindex, b_data = GetPlayerBunkerDataFromBunkerid(ply, bunkerid)
                    if b_data.raw_mats < 100 then
                        IsPlayerStealing_RawMats = true
                        local random_steal = math.random(table_count(_Bunkers_raw_materials_steal_locations))
                        local pickup = CreatePickupTrigger(_Bunkers_raw_materials_steal_locations[random_steal][1], _Bunkers_raw_materials_steal_locations[random_steal][2], _Bunkers_raw_materials_steal_locations[random_steal][3], _Bunkers_raw_materials_steal_locations[random_steal][4], false, "OnPlayerPickupRawMaterials")
                        AddPickupInDimension(pickup, GetDimensionByName("base"))
                        Stealing_RawMats_data = {
                            ply = ply,
                            bunkerid = bunkerid,
                            pickup = pickup,
                            steal_pos_str = _Bunkers_raw_materials_steal_locations[random_steal][5]
                        }
                        PlayerExitBunker(ply)
                        CallRemoteEvent(ply, "BunkerObjectivesStart", {{1, "Raw Materials", _Bunkers_raw_materials_steal_locations[random_steal][2], _Bunkers_raw_materials_steal_locations[random_steal][3], _Bunkers_raw_materials_steal_locations[random_steal][4]}}, {{1, "Steal Raw Materials"}})
                    end
                else
                    print("Error : no bunkerid : StealRawMats")
                end
            else
                CallRemoteEvent(ply, "CreateNotification", "Bunker", "You can't steal raw materials now", 10000)
            end
        else
            CallRemoteEvent(ply, "CreateNotification", "Bunker", "You can't steal raw materials now", 10000)
        end
    end
end)

AddRemoteEvent("SellBunkerStorage", function(ply)
    if PlayerData[ply] then
        if not IsPlayerSellingWeapons then
            local good = true
            if IsPlayerStealing_RawMats then
                 if Stealing_RawMats_data.ply == ply then
                     good = false
                 end
            end
            if good then
                local i, data = GetPlayerInBunker(ply)
                if i then
                    local bunkerid = data.bunkerid
                    local bindex, b_data = GetPlayerBunkerDataFromBunkerid(ply, bunkerid)
                    if b_data.storage == 100 then
                        PlayerData[ply].bunkers[bindex].storage = 0
                        IsPlayerSellingWeapons = true
                        local zone = CreateZone(_Bunker_SellWeapons.final_zone[1], _Bunker_SellWeapons.final_zone[2], _Bunker_SellWeapons.final_zone[3], _Bunker_SellWeapons.final_zone[4], _Bunker_SellWeapons.final_zone[5], "OnPlayerEnterSellWeaponsZone", "OnPlayerLeaveSellWeaponsZone")
                        Selling_weapons_data = {
                            ply = ply,
                            bunkerid = bunkerid,
                            zone = zone
                        }
                        PlayerExitBunker(ply)
                        LeavePoliceman(ply)
                        AddCriminalBonus(ply)
                        CallRemoteEvent(ply, "BunkerObjectivesStart", {{1, "Sell zone", _Bunker_SellWeapons.final_zone[1], _Bunker_SellWeapons.final_zone[2], _Bunker_SellWeapons.final_zone[5]}}, {{1, "Sell Weapons at the Sell zone"}})
                        for i2, v in ipairs(GetPolicePlayers()) do
                            CallRemoteEvent(v, "BunkerSellWeaponsAlert", GetPlayerName(ply))
                        end
                    end
                else
                    print("Error : no bunkerid : SellBunkerStorage")
                end
            else
                CallRemoteEvent(ply, "CreateNotification", "Bunker", "You can't sell weapons now", 10000)
            end
        else
            CallRemoteEvent(ply, "CreateNotification", "Bunker", "You can't sell weapons now", 10000)
        end
    end
end)

AddEvent("OnPlayerEnterSellWeaponsZone", function(ply, zone)
    if IsPlayerSellingWeapons then
        if Selling_weapons_data.ply == ply then
            Sell(ply, _Bunkers[Selling_weapons_data.bunkerid].Bunker_Full_Sell_Money)
            IsPlayerSellingWeapons = false
            Selling_weapons_data = nil
            DestroyZone(zone)
            CallRemoteEvent(ply, "BunkerMissionFinished", true, "Weapons sell")
        end
    end
end)

AddEvent("OnPlayerPickupRawMaterials", function(ply, pickup)
    if IsPlayerStealing_RawMats then
         if Stealing_RawMats_data.ply == ply then
             DestroyPickupTrigger(pickup)
             Stealing_RawMats_data.pickup = nil
             LeavePoliceman(ply)
             AddCriminalBonus(ply)
             CallRemoteEvent(ply, "ChangeBunkerObjectives", {{1, "Bunker", _Bunkers[Stealing_RawMats_data.bunkerid].Bunker_enter_location[1], _Bunkers[Stealing_RawMats_data.bunkerid].Bunker_enter_location[2], _Bunkers[Stealing_RawMats_data.bunkerid].Bunker_enter_location[3]}}, {{1, "Go to the bunker"}})
             for i, v in ipairs(GetPolicePlayers()) do
                 CallRemoteEvent(v, "BunkerRawStealAlert", Stealing_RawMats_data.steal_pos_str, GetPlayerName(Stealing_RawMats_data.ply))
             end
         else
             CallRemoteEvent(ply, "CreateNotification", "Bunker", "You can't steal these raw materials", 5000)
         end
    end
end)

AddEvent("OnPlayerWeaponShot", function(ply, weapon, hittype, hitid, hitX, hitY, hitZ, startX, startY, startZ, normalX, normalY, normalZ, BoneName)
    if IsPlayerStealing_RawMats then
        if hittype == HIT_PLAYER then
            if Stealing_RawMats_data.ply == hitid then
                if not Stealing_RawMats_data.pickup then
                    if not IsPoliceman(ply) then
                        AddPlayerChat(ply, "You can't shoot him")
                        return false
                    end
                end
            end
        end
    end
    if IsPlayerSellingWeapons then
        if hittype == HIT_PLAYER then
            if Selling_weapons_data.ply == hitid then
                if not IsPoliceman(ply) then
                    AddPlayerChat(ply, "You can't shoot him")
                    return false
                end
            end
        end
    end
end)

AddEvent("OnPlayerDeath", function(ply, killer)
    if IsPlayerStealing_RawMats then
        if Stealing_RawMats_data.ply == ply then
            if killer then
                if (IsValidPlayer(ply) and IsValidPlayer(killer)) then
                    if not Stealing_RawMats_data.pickup then
                        --print("OnPlayerDeath", ply, killer)
                        if ply ~= killer then
                            Sell(killer, _Bunkers_raw_materials_steal_kill_bonus)
                            CallRemoteEvent(killer, "CreateNotification", "Police", "You stopped the raw materials stealing, you won " .. tostring(_Bunkers_raw_materials_steal_kill_bonus) .. "$", 10000)
                        end
                        IsPlayerStealing_RawMats = false
                        Stealing_RawMats_data = nil
                        CallRemoteEvent(ply, "BunkerMissionFinished", false, "Raw Materials steal")
                    end
                end
            end
        end
    end
    if IsPlayerSellingWeapons then
        if Selling_weapons_data.ply == ply then
            if killer then
                if (IsValidPlayer(ply) and IsValidPlayer(killer)) then
                    --print("OnPlayerDeath", ply, killer)
                    if ply ~= killer then
                        Sell(killer, _Bunkers_weapons_sell_kill_bonus)
                        CallRemoteEvent(killer, "CreateNotification", "Police", "You stopped the weapons sell, you won " .. tostring(_Bunkers_weapons_sell_kill_bonus) .. "$", 10000)
                    end
                    IsPlayerSellingWeapons = false
                    DestroyZone(Selling_weapons_data.zone)
                    Selling_weapons_data = nil
                    CallRemoteEvent(ply, "BunkerMissionFinished", false, "Weapons sell")
                end
            end
        end
    end
end)

AddEvent("OnPlayerQuit", function(ply)
    for i, v in ipairs(PlayersInBunker) do
        if v.ply == ply then
            table.remove(PlayersInBunker, i)
            break
        end
    end

    for i, v in ipairs(UpdateBunkersTimers) do
        if v.ply == ply then
            table.remove(UpdateBunkersTimers, i)
            break
        end
    end

    if IsPlayerStealing_RawMats then
        if Stealing_RawMats_data.ply == ply then
            if Stealing_RawMats_data.pickup then
                DestroyPickupTrigger(Stealing_RawMats_data.pickup)
            end
            IsPlayerStealing_RawMats = false
            Stealing_RawMats_data = nil
        end
    end

    if IsPlayerSellingWeapons then
        if Selling_weapons_data.ply == ply then
            DestroyZone(Selling_weapons_data.zone)
            IsPlayerSellingWeapons = false
            Selling_weapons_data = nil
        end
    end
end)