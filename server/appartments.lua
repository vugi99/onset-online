

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(Appartments) do
          local obj = CreatePickupTrigger(2, v.Entrance[1], v.Entrance[2], v.Entrance[3], false, "OnPlayerHouseEntrance")
          AddPickupInDimension(obj, id)
          local text = CreateText3D("Appartment " .. tostring(i), 16, v.Entrance[1], v.Entrance[2], v.Entrance[3] + 100, 0, 0, 0)
          AddText3DInDimension(text, id)
       end
    end
end)

AddEvent("OnPlayerHouseEntrance", function(ply, pickup, spawn)
    if PlayerData[ply] then
        local houseid
        local x, y, z = GetPickupLocation(pickup)
        for i, v in ipairs(Appartments) do
            if (v.Entrance[1] == x and v.Entrance[2] == y and v.Entrance[3] == z) then
                houseid = i
                break
            end
        end
        if (spawn and houseid) then
            CallRemoteEvent(ply, "CreateHouseActor", houseid)
            local dim = CreateDimension("house", true)
            AddPlayerInDimension(ply, dim)
            SetPlayerPropertyValue(ply, "HouseOwner", true, false)
            SetPlayerLocation(ply, Appartments[houseid].Appartment_tp[1], Appartments[houseid].Appartment_tp[2], Appartments[houseid].Appartment_tp[3])
            SetPlayerHeading(ply, Appartments[houseid].Appartment_tp[4])
            SetPlayerSpawnLocation(ply, Appartments[houseid].Appartment_tp[1], Appartments[houseid].Appartment_tp[2], Appartments[houseid].Appartment_tp[3], Appartments[houseid].Appartment_tp[4])
            local exit_pickup = CreatePickupTrigger(2, Appartments[houseid].Appartment_exit[1], Appartments[houseid].Appartment_exit[2], Appartments[houseid].Appartment_exit[3], false, "OnPlayerExitHouse")
            AddPickupInDimension(exit_pickup, dim)
            local text = CreateText3D("Exit", 16, Appartments[houseid].Appartment_exit[1], Appartments[houseid].Appartment_exit[2], Appartments[houseid].Appartment_exit[3] + 100, 0, 0, 0)
            AddText3DInDimension(text, dim)
            if Appartments[houseid].Heist_Trigger then
                local heist_pickup = CreatePickupTrigger(2, Appartments[houseid].Heist_Trigger[1], Appartments[houseid].Heist_Trigger[2], Appartments[houseid].Heist_Trigger[3], false, "OnPlayerTriggerHeist")
                AddPickupInDimension(heist_pickup, dim)
                local heist_text = CreateText3D("Heist", 16, Appartments[houseid].Heist_Trigger[1], Appartments[houseid].Heist_Trigger[2], Appartments[houseid].Heist_Trigger[3] + 100, 0, 0, 0)
                AddText3DInDimension(heist_text, dim)
            end
            return
        end
        if houseid then
            local has_house
            for i, v in ipairs(PlayerData[ply].houses) do
                if v.id == houseid then
                    has_house = true
                    break
                end
            end
            local friends_in_house = {}
            for i, v in ipairs(GetAllPlayers()) do
                if (IsPlayerFriendWithPlayer(ply, v) and GetDimensionName(GetPlayerDimension(v)) == "house" and GetPlayerPropertyValue(v, "HouseOwner")) then
                    table.insert(friends_in_house, {tostring(GetPlayerSteamId(v)), GetPlayerName(v)})
                end
            end
            if has_house then
                CallRemoteEvent(ply, "OnStartEnterHouse", nil, houseid, friends_in_house)
            else
                if table_count(friends_in_house) > 0 then
                    CallRemoteEvent(ply, "OnStartEnterHouse", HasEnoughMoney(ply, Appartments[houseid].Price), houseid, friends_in_house)
                elseif HasEnoughMoney(ply, Appartments[houseid].Price) then
                    CallRemoteEvent(ply, "BuyHouseUI", houseid)
                else
                    CallRemoteEvent(ply, "CreateNotification", "Appartment", "You need " .. tostring(Appartments[houseid].Price) .. "$ to buy this appartment", 5000)
                end
            end
        else
            print("Error : can't find houseid")
        end
    end
end)

AddRemoteEvent("BuyHouse", function(ply, id)
    if Buy(ply, Appartments[id].Price) then
        local tbl = {}
        tbl.id = id
        table.insert(PlayerData[ply].houses, tbl)
        local query = mariadb_prepare(db, "UPDATE accounts SET houses = '?' WHERE accountid = ? LIMIT 1;",
					json_encode(PlayerData[ply].houses),
					PlayerData[ply].accountid
	    )

		mariadb_query(db, query)
        CallRemoteEvent(ply, "CreateNotification", "Appartment", "You bought this appartment", 5000)
    else
       CallRemoteEvent(ply, "CreateNotification", "Appartment", "You can't buy this appartment", 5000)
    end
end)

function ExitHouse(ply, houseid)
    AddPlayerInDimension(ply, GetDimensionByName("base"))
    SetPlayerLocation(ply, Appartments[houseid].Appartment_exit_tp[1], Appartments[houseid].Appartment_exit_tp[2], Appartments[houseid].Appartment_exit_tp[3])
    SetPlayerHeading(ply, Appartments[houseid].Appartment_exit_tp[4])
    CallRemoteEvent(ply, "DestroyHouseActor")
    SetPlayerPropertyValue(ply, "InHouseId", nil, false)
end

AddEvent("OnPlayerExitHouse", function(ply, pickup)
    local houseid
    local x, y, z = GetPickupLocation(pickup)
    for i, v in ipairs(Appartments) do
        if (v.Appartment_exit[1] == x and v.Appartment_exit[2] == y and v.Appartment_exit[3] == z) then
            houseid = i
            break
        end
    end
    if houseid then
        local dim = GetPlayerDimension(ply)
        ExitHouse(ply, houseid)
        if GetPlayerPropertyValue(ply, "HouseOwner") then
            for i, v in ipairs(GetAllPlayers()) do
                if (v ~= ply and GetPlayerDimension(v) == dim) then
                    ExitHouse(v, houseid)
                end
            end
            SetPlayerPropertyValue(ply, "HouseOwner", nil, false)
        end
    else
        print("Error : can't find houseid : OnPlayerExitHouse")
    end
end)

AddRemoteEvent("EnterHouse", function(ply, houseid)
    if PlayerData[ply].houses then
        local has_house
        for i, v in ipairs(PlayerData[ply].houses) do
            if v.id == houseid then
                has_house = true
                break
            end
        end
        if has_house then
            local dim = CreateDimension("house", true)
            AddPlayerInDimension(ply, dim)
            SetPlayerPropertyValue(ply, "HouseOwner", true, false)
            SetPlayerLocation(ply, Appartments[houseid].Appartment_tp[1], Appartments[houseid].Appartment_tp[2], Appartments[houseid].Appartment_tp[3])
            SetPlayerHeading(ply, Appartments[houseid].Appartment_tp[4])
            SetPlayerSpawnLocation(ply, Appartments[houseid].Appartment_tp[1], Appartments[houseid].Appartment_tp[2], Appartments[houseid].Appartment_tp[3], Appartments[houseid].Appartment_tp[4])
            local exit_pickup = CreatePickupTrigger(2, Appartments[houseid].Appartment_exit[1], Appartments[houseid].Appartment_exit[2], Appartments[houseid].Appartment_exit[3], false, "OnPlayerExitHouse")
            AddPickupInDimension(exit_pickup, dim)
            local text = CreateText3D("Exit", 16, Appartments[houseid].Appartment_exit[1], Appartments[houseid].Appartment_exit[2], Appartments[houseid].Appartment_exit[3] + 100, 0, 0, 0)
            AddText3DInDimension(text, dim)
            if Appartments[houseid].Heist_Trigger then
                local heist_pickup = CreatePickupTrigger(2, Appartments[houseid].Heist_Trigger[1], Appartments[houseid].Heist_Trigger[2], Appartments[houseid].Heist_Trigger[3], false, "OnPlayerTriggerHeist")
                AddPickupInDimension(heist_pickup, dim)
                local heist_text = CreateText3D("Heist", 16, Appartments[houseid].Heist_Trigger[1], Appartments[houseid].Heist_Trigger[2], Appartments[houseid].Heist_Trigger[3] + 100, 0, 0, 0)
                AddText3DInDimension(heist_text, dim)
            end
        else
            print("Error : has_house false : EnterHouse")
        end
    end
end)

AddRemoteEvent("EnterFriendAppartment", function(ply, friend, houseid)
    local friend_ply
    for i, v in ipairs(GetAllPlayers()) do
        if tostring(GetPlayerSteamId(v)) == friend[1] then
            friend_ply = v
            break
        end
    end
    if friend_ply then
        local dim = GetPlayerDimension(friend_ply)
        if (GetDimensionName(dim) == "house" and GetPlayerPropertyValue(friend_ply, "HouseOwner")) then
            CallRemoteEvent(ply, "CreateHouseActor", houseid)
            AddPlayerInDimension(ply, dim)
            SetPlayerLocation(ply, Appartments[houseid].Appartment_tp[1], Appartments[houseid].Appartment_tp[2], Appartments[houseid].Appartment_tp[3])
            SetPlayerHeading(ply, Appartments[houseid].Appartment_tp[4])
            SetPlayerSpawnLocation(ply, Appartments[houseid].Appartment_tp[1], Appartments[houseid].Appartment_tp[2], Appartments[houseid].Appartment_tp[3], Appartments[houseid].Appartment_tp[4])
            SetPlayerPropertyValue(ply, "InHouseId", houseid, false)
        else
            CallRemoteEvent(ply, "CreateNotification", "Appartment", "Player no longer in his appartment", 5000)
        end
    else
        CallRemoteEvent(ply, "CreateNotification", "Appartment", "Player leaved", 5000)
    end
end)

AddEvent("OnPlayerQuit", function(ply)
    if GetPlayerPropertyValue(ply, "HouseOwner") then
        local dim = GetPlayerDimension(ply)
        for i, v in ipairs(GetAllPlayers()) do
            if (v ~= ply and GetPlayerDimension(v) == dim) then
                ExitHouse(v, GetPlayerPropertyValue(v, "InHouseId"))
            end
        end
    end
end)