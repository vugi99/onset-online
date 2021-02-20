

db = nil
PlayerData = {}
cooldown_players = {}
timers_save = {}

AddEvent("OnPackageStart", function()
	local SQL_CHAR = "utf8mb4"
	local SQL_LOGL = "error"

	mariadb_log(SQL_LOGL)

	db = mariadb_connect(sql_host .. ':' .. sql_port, sql_user, sql_passwd, sql_db)

	if (db ~= false) then
		print("MariaDB: Connected to " .. sql_host)
		mariadb_set_charset(db, SQL_CHAR)
		CallEvent("DataBaseInit")
	else
		print("MariaDB: Connection failed to " .. sql_host .. ", see mariadb_log file")
		ServerExit()
	end
end)

AddEvent("OnPlayerSteamAuth", function(ply)
    local query = mariadb_prepare(db, "SELECT * FROM accounts WHERE steam_id = '?' LIMIT 1;",
                  tostring(GetPlayerSteamId(ply)))
    mariadb_async_query(db, query, OnAccountLoad, ply)
end)

function GetPlayerData(steamid, event_called, needed_value, value_to_pass)
	local query = mariadb_prepare(db, "SELECT * FROM accounts WHERE steam_id = '?' LIMIT 1;",
	tostring(steamid))
    mariadb_async_query(db, query, OnAccountLoadForGetPlayerData, event_called, needed_value, value_to_pass)
end

function OnAccountLoadForGetPlayerData(event_called, needed_value, value_to_pass)
	if (mariadb_get_row_count() == 0) then
	   print("Error : can't get player data")
	else
		local data = mariadb_get_assoc(1)
		CallEvent(event_called, data["accountid"], data[needed_value], value_to_pass)
	end
end

function OnAccountLoad(ply)
    if (mariadb_get_row_count() == 0) then
		local query = mariadb_prepare(db, "INSERT INTO accounts (accountid, steam_id, bank_cash, cash, create_chara, clothes, level, xp, is_banned, garages, weapons, animations, energy_bars, criminal_bonus, special_vehicles, playtime, friends, friends_settings, friends_requests, houses, hat, heist_phase, cqb_record, bunkers) VALUES (NULL, '?', ?, ?, ?, '?', ?, ?, ?, '?', '?', '?', ?, ?, '?', ?, '?', '?', '?', '?', ?, ?, '?', '?');",
		              tostring(GetPlayerSteamId(ply)),
		              start_money,
					  0,
					  1,
					  '[]',
					  1,
					  0,
					  0,
					  '[]',
					  '[]',
					  '[]',
					  0,
					  0,
					  '[]',
					  0,
					  '[]',
					  Default_friends_settings,
					  '[]',
					  '[]',
					  0,
					  0,
					  '[]',
					  '[]'
					)

		mariadb_query(db, query, OnAccountCreated, ply, tostring(GetPlayerSteamId(ply)), start_money, 0, 1, '[]', 1, 0, 0, '[]', '[]', '[]', 0, 0, '[]', 0, '[]', Default_friends_settings, '[]', '[]', 0, 0, '[]', '[]')
	else
		local data = mariadb_get_assoc(1)
		PlayerData[ply] = {}
	    PlayerData[ply].accountid = data["accountid"]
	    PlayerData[ply].steam_id = data["steam_id"]
	    PlayerData[ply].bank_cash = tonumber(data["bank_cash"])
	    PlayerData[ply].cash = tonumber(data["cash"])
	    PlayerData[ply].create_chara = tonumber(data["create_chara"])
		PlayerData[ply].clothes = json_decode(data["clothes"])
		PlayerData[ply].level = tonumber(data["level"])
		PlayerData[ply].xp = tonumber(data["xp"])
		PlayerData[ply].is_banned = tonumber(data["is_banned"])
		PlayerData[ply].garages = json_decode(data["garages"])
		PlayerData[ply].weapons = json_decode(data["weapons"])
		PlayerData[ply].animations = json_decode(data["animations"])
		PlayerData[ply].energy_bars = tonumber(data["energy_bars"])
		PlayerData[ply].criminal_bonus = tonumber(data["criminal_bonus"])
		PlayerData[ply].special_vehicles = json_decode(data["special_vehicles"])
		PlayerData[ply].playtime = tonumber(data["playtime"])
		PlayerData[ply].friends = json_decode(data["friends"])
		PlayerData[ply].friends_settings = json_decode(data["friends_settings"])
		PlayerData[ply].friends_requests = json_decode(data["friends_requests"])
		PlayerData[ply].houses = json_decode(data["houses"])
		PlayerData[ply].hat = tonumber(data["hat"])
		PlayerData[ply].heist_phase = tonumber(data["heist_phase"])
		PlayerData[ply].cqb_record = json_decode(data["cqb_record"])
		PlayerData[ply].bunkers = json_decode(data["bunkers"])
		if PlayerData[ply].is_banned == 1 then
            KickPlayer(ply, "You are banned")
		else
		   CallEvent("PlayerDataLoaded", ply)
	    end
	end
end

function OnAccountCreated(ply, steamid, bank_cash, cash, create_chara, clothes, level, xp, is_banned, garages, weapons, animations, energy_bars, criminal_bonus, special_vehicles, playtime, friends, friends_settings, friends_requests, houses, hat, heist_phase, cqb_record, bunkers)
	local new_id = mariadb_get_insert_id()

	if new_id == false then
		KickPlayer(ply, "Error when creating")
	else
	   PlayerData[ply] = {}
	   PlayerData[ply].accountid = new_id
	   PlayerData[ply].steam_id = steamid
	   PlayerData[ply].bank_cash = bank_cash
	   PlayerData[ply].cash = cash
	   PlayerData[ply].create_chara = create_chara
	   PlayerData[ply].clothes = json_decode(clothes)
	   PlayerData[ply].level = level
	   PlayerData[ply].xp = xp
	   PlayerData[ply].is_banned = is_banned
	   PlayerData[ply].garages = json_decode(garages)
	   PlayerData[ply].weapons = json_decode(weapons)
	   PlayerData[ply].animations = json_decode(animations)
	   PlayerData[ply].energy_bars = energy_bars
	   PlayerData[ply].criminal_bonus = criminal_bonus
	   PlayerData[ply].special_vehicles = json_decode(special_vehicles)
	   PlayerData[ply].playtime = playtime
	   PlayerData[ply].friends = json_decode(friends)
	   PlayerData[ply].friends_settings = json_decode(friends_settings)
	   PlayerData[ply].friends_requests = json_decode(friends_requests)
	   PlayerData[ply].houses = json_decode(houses)
	   PlayerData[ply].hat = hat
	   PlayerData[ply].heist_phase = heist_phase
	   PlayerData[ply].cqb_record = json_decode(cqb_record)
	   PlayerData[ply].bunkers = json_decode(bunkers)
	   print("Account Created " .. ply)
	   CallEvent("PlayerDataLoaded", ply)
	end
end

function IsInCoolDown(ply)
	for i,v in ipairs(cooldown_players) do
	   if v == ply then
		  return i, true
	   end
	end
	return false
 end

function SaveData(ply, command, allcommand)
	if (PlayerData[ply]) then
		local query = mariadb_prepare(db, "UPDATE accounts SET bank_cash = ?, cash = ?, level = ?, xp = ?, garages = '?', weapons = '?', energy_bars = ?, criminal_bonus = ?, playtime = ?, friends = '?', friends_requests = '?', bunkers = '?' WHERE accountid = ? LIMIT 1;",
					PlayerData[ply].bank_cash,
					PlayerData[ply].cash,
					PlayerData[ply].level,
					PlayerData[ply].xp,
					json_encode(PlayerData[ply].garages),
					json_encode(PlayerData[ply].weapons),
					PlayerData[ply].energy_bars,
					PlayerData[ply].criminal_bonus,
					PlayerData[ply].playtime,
					json_encode(PlayerData[ply].friends),
					json_encode(PlayerData[ply].friends_requests),
					json_encode(PlayerData[ply].bunkers),
					PlayerData[ply].accountid
	    )

		mariadb_query(db, query)
		if not command then
		   PlayerData[ply] = nil
		   local i, is = IsInCoolDown(ply)
		   if is then
              table.remove(cooldown_players, i)
		   end
		   for i, v in ipairs(timers_save) do
			  if v.ply == ply then
				 DestroyTimer(v.timer)
				 table.remove(timers_save, i)
				 break
			  end
		   end
		else
			AddPlayerChat(ply, "Data Saved")
			if not allcommand then
			   table.insert(cooldown_players, ply)
			   Delay(save_command_cooldown_s * 1000, function()
				   if IsValidPlayer(ply) then
					  local i, is = IsInCoolDown(ply)
					  if is then
                         table.remove(cooldown_players, i)
					  end
				   end
			   end)
			end
		end
		if GetPlayerName(ply) then
		   print("Data saved for " .. tostring(ply) .. " " .. GetPlayerName(ply))
		else
			print("Data saved for " .. tostring(ply))
		end
	end
end

AddEvent("PlayerDataLoaded", function(ply)
    local timer = CreateTimer(function()
	   SaveData(ply, true, true)
	end
	,save_interval_s * 1000)
	local tbl = {}
	tbl.timer = timer
	tbl.ply = ply
	table.insert(timers_save, tbl)
end)

AddCommand("save", function(ply)
	local i, is = IsInCoolDown(ply)
	if not is then
	   SaveData(ply, true)
	else
		AddPlayerChat(ply, "Wait to save again")
	end
end)

AddCommand("saveall", function(ply)
	if IsAdmin(ply) then
       for k,v in ipairs(PlayerData) do
		  SaveData(k, true, true)
	   end
	end
end)

AddEvent("OnPlayerQuit",function(ply)
	SaveData(ply)
end)

AddEvent("OnPackageStop",function()
	for k,v in ipairs(PlayerData) do
	   SaveData(k)
	end
	mariadb_close(db)
end)

AddRemoteEvent("OnlineResetPlayerData", function(ply)
	local query = mariadb_prepare(db, "DELETE FROM " .. sql_db .. ".accounts WHERE  accountid = ?;",
					PlayerData[ply].accountid
	    )
	mariadb_query(db, query)
	PlayerData[ply] = nil
	KickPlayer(ply, "Data reset")
end)