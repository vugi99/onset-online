

start_money = 50000
map_update_ms = 80

first_spawn_location = {212225.000000, 192940.000000, 1400.000000, -180.0} -- x, y, z, h

vehicle_health_update_ms = 200
vehicle_speed_update_ms = 20

start_time = 10.0 -- 0 to 24
time_locked = true -- does the time is locked
time_update_ms = 25000
time_update_value = 0.1

max_level = 300
xp_base = 1000 -- xp needed to pass 1 level
xp_added_level = 500 -- xp added to xp needed to pass next level

criminal_bonus_base = 1000 -- criminal kill bonus at start
criminal_bonus_added = 500 -- criminal kill bonus added at each offence

passive_time_to_disable_ms = 30000
passive_delay_after_disable_to_enable_again_ms = 60000

clothing_store_price = 100

sell_vehicle_percentage = 75

max_weapon_ammo = 9999
armor_cost = 250

race_money_won_mult_for_each_player = 1.5
race_money_won = 500 -- money won (race_money_won*(race_money_won_mult_for_each_player*number_of_players_in_race))/place_in_race
race_xp_won_mult_for_each_player = 1.5
race_xp_won = 250 -- xp won (race_xp_won*(race_xp_won_mult_for_each_player*number_of_players_in_race))/place_in_race

save_command_cooldown_s = 120
save_interval_s = 900

grocery_heist_cooldown_s = 300
grocery_heist_money_min = 200
grocery_heist_money_max = 2000
grocery_energy_bar_price = 2
grocery_energy_bar_health_given = 10
max_energy_bars = 100

duels_win_reward_min = 250
duels_win_reward_max = 1000
duels_weapon = 11

max_friends = 30

salary_interval_s = 900
salary_money = 2500

police_car_id = 3

nitro_price_percentage = 10 -- Price of the nitro in percentage of the vehicle price
car_paint_cost = 500

Hats_Price = 50

admins = {
    "",
}

noclip_speed = 100

OnlineKeys = {
    ACTION_KEY = "E",
    ADMIN_KEY = "F10",
    PLAYER_MENU_KEY = "P",
    POLICE_KEY = "O",
    SHOWMOUSE_KEY = "I",
    TAB_KEY = "Tab",
    MAP_KEY = "M",
    LEAVE_MENU_KEY = "Y", -- the key to open the duel menu, heist menu and racing menu to leave
    OPEN_VEHICLE_HOOD_KEY = "F2",
    CLOSE_VEHICLE_HOOD_KEY = "F3",
    OPEN_VEHICLE_TRUNK_KEY = "F4",
    CLOSE_VEHICLE_TRUNK_KEY = "F5",
    HELP_KEY = "F1",
    RESET_ANIMATION_KEY = "1", -- you'll need to modify things to change the script because it's 1 and &
}

spawns = {}
spawns["gas"] = {
    x = 125773.000000,
    y = 80246.000000,
    z = 1645.000000,
    roty = 90.0,
}
spawns["town"] = {
    x = 172955.000000,
    y = 183155.000000,
    z = 2142.000000,
    roty = 0.0,
}
spawns["harbor"] = {
    x = 60934.000000,
    y = 183517.000000,
    z = 756.000000,
    roty = 0.0,
}
spawns["smalltown"] = {
    x = 41456.000000,
    y = 134472.000000,
    z = 1726.000000,
    roty = 0.0,
}
spawns["smalltown2"] = {
    x = -17583.000000,
    y = -234.000000,
    z = 2283.000000,
    roty = 0.0,
}
spawns["military"] = {
    x = 153582.000000,
    y = -148690.000000,
    z = 1435.000000,
    roty = 0.0,
}
spawns["town2"] = {
    x = -170537.000000,
    y = -38049.000000,
    z = 1243.000000,
    roty = 0.0,
}

Clothing_presets_clothes = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    25,
    26,
    27,
    28,
    29,
}

atms_objects = {
    {-20544,-15466,2060,107}, -- x,y,z,roty
    {43904,132866,1566,93},
    {136728,192593,1288,-90},
    {212682,190483,1306,-180},
    {-75655,86857,2192,-103},
    {-180478,-67312,1146,-87},
    {129241,78087,1573,93},
}

clothes_npcs = {
    {178325,186782,1299,-52}, -- x,y,z,roty
}

car_dealer_vehicles = {
    {1, 10000}, -- model, price
    {4, 20000},
    {5, 15000},
    {6, 75000},
    {7, 25000},
    {11, 15000},
    {12, 50000},
    {13, 40000},
    {25, 2500},
    {27, 15000},
    {29, 10000},
    {35, 15000},
    {37, 100000},
    {40, 50000},
    {43, 10000},
    {50, 15000},
}

weapons_shops_weapons = {
    {2, 4, 1500, 30, 1}, -- weapon model id, weapon object id, price, ammo_sold, price_for_1_bullet
    {3, 5, 800, 30, 1},
    {4, 6, 800, 30, 1},
    {5, 7, 1000, 30, 1},
    {6, 8, 3000, 30, 3},
    {7, 9, 3000, 30, 3},
    {8, 10, 6000, 30, 1},
    {9, 11, 3000, 30, 1},
    {10, 12, 6000, 30, 1},
    {11, 13, 10000, 30, 2},
    {12, 14, 8000, 30, 2},
    {13, 15, 30000, 30, 2},
    {14, 16, 10000, 30, 2},
    {15, 17, 15000, 30, 4},
    {16, 18, 6000, 30, 2},
    {17, 19, 10000, 30, 2},
    {18, 20, 10000, 30, 2},
    {19, 21, 12000, 30, 2},
    {20, 22, 20000, 30, 5},
}

police_npcs = { -- npcs to join police
    {173558,192275,1321, 0} -- x, y, z, heading
}

special_vehicles = {
    {10, 500000}, -- model, price
    {26, 1200000},
    {30, 2500000},
}

Vehicle_armors = {
    {1, 3000, 20}, -- level required, price, armor in percentage (100 = vehicle damage / 2)
    {2, 6000, 40},
    {3, 9000, 60},
    {5, 12000, 80},
    {8, 20000, 100},
}

wtem_text = [[
    Ways to earn money : <br> 
    You can play racing with players <br> 
    You can kill players to steal a part of the money the have on them (You'll become a criminal and you'll have a kill bonus on you if you do that) <br> 
    You can be a Policeman and kill criminals to earn their kill bonus (You'll become a criminal if you kill someone that is not/no longer a criminal) <br> 
    You can rob grocery stores <br>
    You can do a heist (appartment needed) <br> 
    You earn money while playing on the server <br> 
    You can do duels with players (press E on them) <br>
]]

wycd_text = [[
    In Onset Online the first thing that you should do is withdraw money at an ATM (Press M to open the map). <br> 
    Then you should buy a garage to store vehicles <br> 
    You can now buy a vehicle at a car dealer <br> 
    You should also buy a weapon and ammo at a Gun Store <br> 
    Open the map to see what you can do <br> 
]]



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ADVANCED


action_distance = 275

spawn_loc = {123051.28125, 168244.5625, 3114.56494, 0.0} -- x, y, z, ry

input_while_in_ui = INPUT_GAMEANDUI

special_spawn_camera_distance = 1000
special_vehicles_spawn_destroy_after_s_if_is_on_the_same_loc = 60
special_vehicles_spawn_higher_distance3d_considered_as_same_loc = 1200
special_vehicles_spawn_cooldown_if_spawn_failed_ms = 3000

police_vehicles_spawn_destroy_after_s_if_is_on_the_same_loc = 60
police_vehicles_spawn_higher_distance3d_considered_as_same_loc = 1200
police_spawn_cooldown_ms = 5000

AnimationsKeys = {
    {"2", "é"},
    {"3", 'Quote'},
    {"4", "Apostrophe"},
    {"5", "Left Parantheses"},
    {"6", "Hyphen"},
    {"7", "è"},
    {"8", "Underscore"},
    {"9", "ç"},
    {"0", "à"},
}

pickups_triggers = {
    {1443, "OnPlayerCashAction"}, -- model id, server event
    {2, "OnPlayerGarageAction"},
    {334, "OnPlayerRacingAction"},
    {615, "OnPlayerGroceryHeistMoneyAction"}
}

actions = {
    {5, 494, "OnATMAction"}, -- hittype, model id, client event
    {4, 3, "OnPlayerClothingAction"},
    {4, 14, "OnPlayerCarDealerAction"},
    {5, 340, "OnPlayerManageVehiclesAction"},
    {4, 25, "OnPlayerWeaponShopAction"},
    {4, 13, "OnPlayerPoliceAction"},
    {4, 4, "OnPlayerGroceryAction"},
    {4, 26, "OnPlayerSpecialVehiclesAction"},
    {4, 10, "OnPlayerHatsStoreAction"},
    {5, 1475, "OnPlayerHeistFinalPhaseTakeMoney"},
    {3, 14, "OnPlayerHeistFinalPhasePutMoney"},
}

garages = {}

garages[1] = {}
garages[1].price = 25000
garages[1].entrance = {172610, 207304, 1408} -- x, y, z
garages[1].manage = {173676, 207122, 1408}
garages[1].exit = {173805, 207448, 1408}
garages[1].vexit = {172099, 206838, 1408, 180}
garages[1].vehicles = { -- where vehicles are in the garage
    {173266, 207321, 1408, -180}, -- x, y, z, roty
    {173266, 206855, 1408, -180},
    {173266, 206312, 1408, -180},
    {173266, 205859, 1408, -180},
}

garages[2] = {}
garages[2].price = 25000
garages[2].entrance = {128998, 75212, 1563} -- x, y, z
garages[2].manage = {128850, 74113, 1563}
garages[2].exit = {129160, 74009, 1563}
garages[2].vexit = {128533, 75460, 1563, 90}
garages[2].vehicles = { -- where vehicles are in the garage
    {129005, 74636, 1563, 90}, -- x, y, z, roty
    {128545, 74636, 1563, 90},
    {128018, 74636, 1563, 90},
    {127544, 74636, 1563, 90},
}

garages[3] = {}
garages[3].price = 20000
garages[3].entrance = {-185733, -51400, 1143} -- x, y, z
garages[3].manage = {-186493, -50271, 1143}
garages[3].exit = {-185969, -50880, 1143}
garages[3].vexit = {-184533, -51573, 1143, -90}
garages[3].vehicles = { -- where vehicles are in the garage
    {-186271, -51392, 1143, 0}, -- x, y, z, roty
    {-185374, -50518, 1143, -90},
    {-184592, -50518, 1143, -90},
}

garages[4] = {}
garages[4].price = 20000
garages[4].entrance = {175578, 204015, 1305} -- x, y, z
garages[4].manage = {174487, 204817, 1305}
garages[4].exit = {175092, 204305, 1305}
garages[4].vexit = {175714, 202905, 1305, 0}
garages[4].vehicles = { -- where vehicles are in the garage
    {175569, 204636, 1305, -90}, -- x, y, z, roty
    {174686, 203728, 1305, 0},
    {174686, 202919, 1305, 0},
}

car_dealer_npcs = {
    {203059,184339,1304,-39}, -- x,y,z,roty
    {-182398,-32513,1145,-82},
}

car_dealer_showcase = {
    {204686, 182836, 1304, 90, 204900, 183400, 1304, 0, -135, 0},  -- it will be for the first car dealer here vehicle x, y, z, roty camera x, y, z, rotx, roty, rotz
    {-182003, -33028, 1145, 0, -181156, -33304, 1145, 0, 135, 0},
}

weapons_shops = {
    {206125,193455,1354,180,205961,193065,1462, -90, 0, 0}, -- npc x, y, z, heading weapon_showcase x, y, z, rotx, roty, rotz
    {-181997,-41340,1160,0,-181865,-40977,1268, -90, 180, 0},
}

racing_objects = {
    {122498, 108730, 2422}, -- this will be to start race 1, x, y, z
    {-90958, 39844, 4701},
    {196249, 179529, 1304},
    {123925, 82024, 1564},
    {214192, 99924, 1469},
    {-73275, 82465, 2192},
    {175904, 157777, 4814},
    {195924, 8647, 5678},
    {180693, -52970, 1586},
    {68536, 184122, 615},
    {152094, 218657, 357},
    {100200, -13244, 1247},
    {100800, -35249, 1301},
    {141254, -110083, 1239},
}

grocery_npcs = {
    {171343, 203854, 1410, 180, 171092, 203854, 1410}, -- x, y, z, h, heist money loc x, y, z
    {42696, 137887, 1578, 0, 42901, 137887, 1578},
    {-15370, -2762, 2062, 110, -15448, -2571, 2062},
    {128775, 77621, 1573, 90, 128775, 77839, 1574},
    {-169052, -39452, 1146, 50, -168900, -39285, 1146},
}

specials_vehicles_stores = {
    {
        npc = {146579, 179977, 1441, 180}, -- x, y, z, h
        vehicle_show_pos = {148264, 178912, 1529},
        vehicle_show_rot = 180,
    },
    {
        npc = {34247, 209164, 545, -90},
        vehicle_show_pos = {32140, 209637, 545},
        vehicle_show_rot = -90,
    },
    {
        npc = {147656, -135895, 1246, -20},
        vehicle_show_pos = {144875, -135689, 1251},
        vehicle_show_rot = -20,
    },
    {
        npc = {169149, -150632, 1247, 70},
        vehicle_show_pos = {168528, -152166, 1313},
        vehicle_show_rot = 160,
    },
}

duels_locations = {
    {{174801, 182972, 1960, -180}, {168772, 185192, 1950, -90}}, -- player 1 loc, player 2 loc
    {{172588, 195556, 1356, 0}, {173427, 190317, 1354, 0}},
    {{164396, 198961, 410, 180}, {147883, 198961, 410, 0}},
    {{158881, 226845, 850, 10}, {171093, 227171, 800, -175}},
    {{191546, 194566, 13400, -90}, {191546, 191063, 13400, 90}},
    {{135733, 190753, 1340, 180}, {133227, 193779, 1340, 0}},
    {{130104, 203778, 1330, 0}, {143825, 206676, 1340, 180}},
    {{59047, 199851, 580, 0}, {58978, 187903, 600, 0}},
    {{45863, 145111, 1450, 0}, {37673, 144256, 1450, 90}},
    {{-20350, -30557, 2250, -25}, {-15562, -31957, 2250, 155}},
    {{-71481, 23526, 4750, 65}, {-92495, 37439, 4750, -115}},
    {{-170798, 84210, 1575, 90}, {-181151, 83682, 1575, 90}},
}

Default_friends_settings = '[{"settingid": 1, "setting": 2}]'

Friend_Settings = {
    {
        "Vehicle Access",
        {
            "Access of your vehicles to everyone",
            "Access of your vehicles to you and your friends",
            "Access of your vehicles to you"
        }
    },
}

Appartments = {
    {
        Entrance = {200746, 198356, 1295},
        Appartment_path = "/Game/Geometry/Prefabs/PF_Apartment_01b",
        Appartment_loc = {200755, 200150, 7100},
        Appartment_rot = {0, 180, 0},
        Appartment_tp = {200918, 200779, 7196, 90},
        Appartment_exit = {200789, 200278, 7195},
        Appartment_exit_tp = {201657, 197531, 1380, -90},
        Price = 100000,
        Heist_Trigger = {200915, 201040, 7195},
    },
}

Police_cars_spawns = {
    {
        {173088, 191359, 1322}, -- trigger x, y, z
        {172501, 190751, 1322, 0} -- car spawn x, y, z, h
    },
    {
        {172592, 193905, 1322},
        {173165, 193711, 1322, 90}
    },
}

Onset_Customs = {
    {
        {139763, 207134, 140144, 208229, 1289}, -- zone minx, miny, maxx, maxy, z
        {140314, 208350, 1289, -90}, -- vehicle x, y, z, h
        {139934, 207563, 1330, 60}, -- cam x, y, z, h
        {141519, 206303, 1289, 0}, -- exit x, y, z, h
    },
}

Hats_Objects = {
    398, -- from
    477 -- to
}

Hats_Stores = {
    {
        {181339, 186803, 1299, -130}, -- npc x, y, z, h
        {180906, 186492, 1299, 90}, -- player teleport x, y, z, h
    },
}

_Animations = {
    "STOP",
    "COMBINE",
    "PICKUP_LOWER",
    "PICKUP_MIDDLE",
    "PICKUP_UPPER",
    "HANDSHEAD_KNEEL",
    "HANDSHEAD_STAND",
    "HANDSUP_KNEEL",
    "HANDSUP_STAND",
    "ENTERCODE",
    "VOMIT",
    "CROSSARMS",
    "DABSAREGAY",
    "DONTKNOW",
    "DUSTOFF",
    "FACEPALM",
    "IDONTLISTEN",
    "FLEXX",
    "HALTSTOP",
    "INEAR_COMM",
    "ITSJUSTRIGHT",
    "FALLONKNEES",
    "KUNGFU",
    "CALLME",
    "SALUTE",
    "SHOOSH",
    "SLAPOWNASS",
    "SLAPOWNASS2",
    "THROATSLIT",
    "THUMBSUP",
    "WAVE3",
    "WIPEOFFSWEAT",
    "KICKDOOR",
    "LOCKDOOR",
    "CRAZYMAN",
    "DARKSOULS",
    "SMOKING",
    "CLAP",
    "SIT01",
    "SIT02",
    "SIT03",
    "SIT04",
    "SIT05",
    "SIT06",
    "SIT07",
    "LAY01",
    "LAY02",
    "LAY03",
    "LAY04",
    "LAY05",
    "LAY06",
    "LAY07",
    "LAY08",
    "LAY09",
    "LAY10",
    "LAY11",
    "LAY12",
    "LAY13",
    "LAY14",
    "LAY15",
    "LAY16",
    "LAY17",
    "LAY18",
    "WAVE",
    "WAVE2",
    "STRETCH",
    "BOW",
    "CALL_GUARDS",
    "CALL_SOMEONE",
    "CALL_SOMEONE2",
    "CHECK_EQUIPMENT",
    "CHECK_EQUIPMENT2",
    "CHECK_EQUIPMENT3",
    "CLAP2",
    "CLAP3",
    "CHEER",
    "DRUNK",
    "FIX_STUFF",
    "GET_HERE",
    "GET_HERE2",
    "GOAWAY",
    "LAUGH",
    "SALUTE2",
    "THINKING",
    "THROW",
    "TRIUMPH",
    "WASH_WINDOWS",
    "WATCHING",
    "DANCE01",
    "DANCE02",
    "DANCE03",
    "DANCE04",
    "DANCE05",
    "DANCE06",
    "DANCE07",
    "DANCE08",
    "DANCE09",
    "DANCE10",
    "DANCE11",
    "DANCE12",
    "DANCE13",
    "DANCE14",
    "DANCE15",
    "DANCE16",
    "DANCE17",
    "DANCE18",
    "DANCE19",
    "DANCE20",
    "CUFF",
    "CUFF2",
    "REVIVE",
    "PICKAXE_SWING",
    "CROSSARMS2",
    "BARCLEAN01",
    "BARCLEAN02",
    "PHONE_PUTAWAY",
    "PHONE_TAKEOUT",
    "PHONE_TALKING01",
    "PHONE_TALKING02",
    "PHONE_TALKING03",
    "DRINKING",
    "SHRUG",
    "SMOKING01",
    "SMOKING02",
    "SMOKING03",
    "THINKING01",
    "WALLLEAN01",
    "WALLLEAN02",
    "WALLLEAN03",
    "WALLLEAN04",
    "YAWN",
    "FISHING",
    "PHONE_TAKEOUT_HOLD",
    "PHONE_HOLD",
    "SHOUT01",
    "CART_IDLE",
    "CARRY_IDLE",
    "CARRY_SETDOWN",
    "CARRY_SHOULDER_IDLE",
    "CARRY_SHOULDER_SETDOWN",
    "HANDSHAKE",
    "PUSHUP_START",
    "PUSHUP_IDLE",
    "PUSHUP_END",
    "SLAP01",
    "SLAP01_REACT",
    "DANCE21",
    "DANCE22",
    "DANCE23",
    "DANCE24",
    "DANCE25",
    "DANCE26",
    "DANCE27",
    "DANCE28",
    "DANCE29",
    "DANCE30",
    "DANCE31",
    "DANCE32",
    "DANCE33",
    "DANCE34",
    "DANCE35",
    "DANCE36",
    "DANCE37",
    "DANCE38",
    "DANCE39",
    "DANCE40",
}


--------------------------------------------------------------------------------------------------

-- HEIST CONFIG

robbers_invincible_from_no_police_players = true

no_kill_bonus_after_kills = 20 -- Kill bonus won't be given if there is too much police kills

heist_phases = {
    {
        type = "GET_VEHICLE",
        vehicle = 14,
        vehpos = {162785, -161888, 1243, 70}, -- veh x, y, z, h
        vehpos_after = {204235, 200428, 1304, -90}, -- where to put vehicle and spawn for final phase
        veh_armor_percentage = 50, -- damage of 75 % here
        kill_bonus_robber = 1000,
        veh_pos_str = "military", -- used for the police alert
    },
}

heist_final_phase = {
    use_vehicle_of_phase = 1,
    bank_enter_trigger = {191330, 198219, 1306, -90},
    bank_exit_trigger = {189857, 201556, 810, 180},
    objects = {
        {1475, 184692, 202579, 55, 0, 90, 0, 1, 1, 1},
        {1475, 184392, 202579, 55, 0, 90, 0, 1, 1, 1},
        {1475, 184092, 202579, 55, 0, 90, 0, 1, 1, 1},
        {1475, 183873, 202901, 55, 0, 0, 0, 1, 1, 1},
        {1475, 184092, 203167, 55, 0, -90, 0, 1, 1, 1},
        {1475, 184392, 203167, 55, 0, -90, 0, 1, 1, 1},
        {1475, 184692, 203167, 55, 0, -90, 0, 1, 1, 1},
    },
    boat = {-229580, 24338, 5, 180}, -- x, y, z, heading
    boat_zone = {-228968, 22582, -227975, 23746, 150}, -- minx, miny, maxx, maxy, z
    police_players_required = 2,
    money_won_max_per_player = 100000,
    money_taken_per_action = 25000,
    waypoint_loc = {184392, 202901, 155},
    vector_push_boat = {-30000, 0, 0},
    kill_bonus_robber = 2000,
}