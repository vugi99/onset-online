local Training_npcs = {}

local CQB_players = {}

local CQB_Records = {}

function GetCQBPlayerIndex(ply)
    for i, v in ipairs(CQB_players) do
        if v.ply == ply then
            return i
        end
    end
end

function SortCQB_Records()
    if table_count(CQB_Records) > 0 then
        for i = 1, table_count(CQB_Records) do
            index = i
            mini = CQB_Records[i]
            for i2 = i, table_count(CQB_Records) do
                if CQB_Records[i2].record.time < mini.record.time then
                    index = i2
                    mini = CQB_Records[i2]
                end
            end
            CQB_Records[index] = CQB_Records[i]
            CQB_Records[i] = mini
        end
        --print(json_encode(CQB_Records))
        return true
    end
    return false
end

function CQBRecords()
    if mariadb_get_row_count() > 0 then
        for i = 1, mariadb_get_row_count() do
            local data = mariadb_get_assoc(i)
            local tbl = {
                recordid = tonumber(data["recordid"]),
                record = json_decode(data["record"]),
                steamid = data["steamid"],
                name = data["name"]
            }
            table.insert(CQB_Records, tbl)
        end
        SortCQB_Records()
    end
end

function Query_GetCQBRecords()
    local query = mariadb_prepare(db, "SELECT * FROM cqb_records LIMIT " .. tostring(_CQB_max_public_records) ..";")
    mariadb_query(db, query, CQBRecords)
end
AddEvent("DataBaseInit", Query_GetCQBRecords)

function PublicRecordAdded(record, steamid, name)
    local recordid = mariadb_get_insert_id()
    local tbl = {
        recordid = recordid,
        record = record,
        steamid = steamid,
        name = name
    }
    table.insert(CQB_Records, tbl)
    SortCQB_Records()
    local count = table_count(CQB_Records)
    if count > _CQB_max_public_records then
        local query = mariadb_prepare(db, "DELETE FROM " .. sql_db .. ".cqb_records WHERE  recordid = ?;",
                    CQB_Records[count].recordid
	    )
        mariadb_query(db, query)
        table.remove(CQB_Records, count)
    end
end

function Query_AddPublicRecord(ply, tbl)
    local query = mariadb_prepare(db, "INSERT INTO cqb_records (recordid, record, steamid, name) VALUES (NULL, '?', '?', '?');",
                      json_encode(tbl),
		              tostring(GetPlayerSteamId(ply)),
                      GetPlayerName(ply)
					)

    mariadb_async_query(db, query, PublicRecordAdded, tbl, tostring(GetPlayerSteamId(ply)), GetPlayerName(ply))
end

function CheckToAddPublicRecord(ply, tbl)
    if table_count(CQB_Records) > 0 then
        if table_count(CQB_Records) >= _CQB_max_public_records then
            for k, v in pairs(CQB_Records) do
                if v.record.time > tbl.time then
                    Query_AddPublicRecord(ply, tbl)
                    break
                end
            end
        else
            Query_AddPublicRecord(ply, tbl)
        end
    else
        Query_AddPublicRecord(ply, tbl)
    end
end

function NewCQBRecord(ply, new_time, index)
    local tbl = {
        time = new_time,
        weapon = CQB_players[index].weapon
    }
    PlayerData[ply].cqb_record = tbl
    local query = mariadb_prepare(db, "UPDATE accounts SET cqb_record = '?' WHERE accountid = ? LIMIT 1;",
					json_encode(PlayerData[ply].cqb_record),
					PlayerData[ply].accountid
	)

	mariadb_query(db, query)
    CheckToAddPublicRecord(ply, tbl)
end

function PlayerFinishedCQB(ply)
    if PlayerData[ply] then
        local index = GetCQBPlayerIndex(ply)
        if (index and CQB_players[index].finished_targets) then
            AddPlayerInDimension(ply, GetDimensionByName("base"))
            for i = 1, 3 do
                SetPlayerWeapon(ply, 1, 0, false, i, false)
            end
            LoadPlayerWeapons(ply)
            Delay(2000, function()
                for i=1, 3 do
                    SetPlayerWeapon(ply, 1, 0, false, i, false)
                end
                LoadPlayerWeapons(ply)
           end)
           local CQB_time = GetTickCount() - CQB_players[index].start_time
           if ((PlayerData[ply].cqb_record.time and PlayerData[ply].cqb_record.time > CQB_time) or (not PlayerData[ply].cqb_record.time)) then
               NewCQBRecord(ply, CQB_time, index)
               CallRemoteEvent(ply, "CQBFinishedTrigger", true, CQB_time)
           else
                local tbl = {
                    time = CQB_time,
                    weapon = CQB_players[index].weapon
                }
                CheckToAddPublicRecord(ply, tbl)
               CallRemoteEvent(ply, "CQBFinishedTrigger", false, CQB_time)
           end
           AwardXp(ply, _CQB_xp_earned)
           table.remove(CQB_players, index)
        end
    end
end

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(_Training) do
           local npc = CreateNPC(v.npc[1], v.npc[2], v.npc[3], v.npc[4])
           local tbl = {
               npc = npc,
               training_id = i,
           }
           table.insert(Training_npcs, tbl)
           SetNPCNetworkedClothingPreset(npc, 29)
           AddNPCInDimension(npc, id)
           table.insert(online_invincible_npcs, npc)
           local text = CreateText3D("Training", 16, v.npc[1], v.npc[2], v.npc[3] + 100, 0, 0, 0)
           AddText3DInDimension(text, id)
       end
    end
end)

AddRemoteEvent("StartShootingRange", function(ply, npc, weapon)
    if PlayerData[ply] then
        local training_id
        for i, v in ipairs(Training_npcs) do
            if v.npc == npc then
                training_id = v.training_id
                break
            end
        end
        if training_id then
            if Buy(ply, _Shooting_range_price) then
                local dim = CreateDimension("shooting_range", true)
                AddPlayerInDimension(ply, dim)
                SetPlayerWeapon(ply, weapon, _Shooting_range_bullets, true, 1, true)
                SetPlayerWeapon(ply, 1, 0, false, 2, false)
                SetPlayerWeapon(ply, 1, 0, false, 3, false)
                SetPlayerLocation(ply, _Training[training_id].shooting_range_location[1], _Training[training_id].shooting_range_location[2], _Training[training_id].shooting_range_location[3])
                SetPlayerHeading(ply, _Training[training_id].shooting_range_location[4])
                CallRemoteEvent(ply, "SRTrainingStartSuccess")
            else
                print("Error : player don't have enough money to do SR")
                CallRemoteEvent(ply, "SRTrainingStartFailed")
            end
        else
            print("Error : can't get training_id")
            CallRemoteEvent(ply, "SRTrainingStartFailed")
        end
    end
end)

AddRemoteEvent("SRTrainingFinished", function(ply, TrainingBulletsSuccess)
    if PlayerData[ply] then
        if GetDimensionName(GetPlayerDimension(ply)) == "shooting_range" then
            AddPlayerInDimension(ply, GetDimensionByName("base"))
            for i = 1, 3 do
                SetPlayerWeapon(ply, 1, 0, false, i, false)
            end
            LoadPlayerWeapons(ply)
            Delay(2000, function()
                for i=1, 3 do
                    SetPlayerWeapon(ply, 1, 0, false, i, false)
                end
                LoadPlayerWeapons(ply)
           end)
           local xp_earned = math.floor((TrainingBulletsSuccess / _Shooting_range_bullets) * _Shooting_range_xp_earned)
           --print("xp_earned", xp_earned)
           AwardXp(ply, xp_earned)
        else
            print("Error : SRTrainingFinished called but ply not in shooting_range dimension")
        end
    end
end)

AddRemoteEvent("StartCQB", function(ply, npc, weapon)
    if PlayerData[ply] then
        local training_id
        for i, v in ipairs(Training_npcs) do
            if v.npc == npc then
                training_id = v.training_id
                break
            end
        end
        if training_id then
            if Buy(ply, _CQB_price) then
                local dim = CreateDimension("cqb", true)
                AddPlayerInDimension(ply, dim)
                local pickup = CreatePickupTrigger(2, _Training[training_id].CQB_end_trigger[1], _Training[training_id].CQB_end_trigger[2], _Training[training_id].CQB_end_trigger[3], false, "CQBEndTrigger")
                AddPickupInDimension(pickup, dim)
                local text = CreateText3D("Finish", 16, _Training[training_id].CQB_end_trigger[1], _Training[training_id].CQB_end_trigger[2], _Training[training_id].CQB_end_trigger[3] + 100, 0, 0, 0)
                AddText3DInDimension(text, dim)
                for i, v in ipairs(_Training[training_id].CQB_Objects) do
                    local obj = CreateObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10])
                    AddObjectInDimension(obj, dim)
                end
                SetPlayerWeapon(ply, weapon, 10000, true, 1, true)
                SetPlayerWeapon(ply, 1, 0, false, 2, false)
                SetPlayerWeapon(ply, 1, 0, false, 3, false)
                SetPlayerLocation(ply, _Training[training_id].CQB_spawn_location[1], _Training[training_id].CQB_spawn_location[2], _Training[training_id].CQB_spawn_location[3])
                SetPlayerHeading(ply, _Training[training_id].CQB_spawn_location[4])
                CallRemoteEvent(ply, "CQBTrainingStartSuccess", training_id)
                local tbl = {
                    ply = ply,
                    start_time = GetTickCount(),
                    finished_targets = false,
                    weapon = weapon,
                }
                table.insert(CQB_players, tbl)
            else
                print("Error : player don't have enough money to do CQB : StartCQB")
                CallRemoteEvent(ply, "SRTrainingStartFailed")
            end
        else
            print("Error : can't get training_id : StartCQB")
            CallRemoteEvent(ply, "SRTrainingStartFailed")
        end
    end
end)

AddRemoteEvent("CQBTrainingFinished", function(ply)
    if PlayerData[ply] then
        local index = GetCQBPlayerIndex(ply)
        if index then
            CQB_players[index].finished_targets = true
        end
    end
end)

AddEvent("CQBEndTrigger", function(ply, pickup)
    PlayerFinishedCQB(ply)
end)

AddEvent("OnPlayerQuit", function(ply)
    local i = GetCQBPlayerIndex(ply)
    if i then
        table.remove(CQB_players, i)
    end
end)

AddRemoteEvent("GetCQBRecords", function(ply)
    if PlayerData[ply] then
        CallRemoteEvent(ply, "SendCQBRecords", PlayerData[ply].cqb_record, CQB_Records)
    end
end)