

local zones_ids_to_onset_customs_zones = {}

AddEvent("OnDimensionCreated", function(id, name)
    if name == "base" then
       for i, v in ipairs(Onset_Customs) do
           local zone_id = CreateZone(v[1][1], v[1][2], v[1][3], v[1][4], v[1][5], "OnPlayerEnterOnsetCustoms", "OnPlayerLeaveOnsetCustoms")
           table.insert(zones_ids_to_onset_customs_zones, {zone_id, i})
       end
    end
end)

local function GetOnsetCustomFromZoneId(zone_id)
    for i, v in ipairs(zones_ids_to_onset_customs_zones) do
        if v[1] == zone_id then
            return v[2]
        end
    end
    return false
end

local function GetVehicleIndexFromVehAndGarage(ply, veh, garageid)
    local r, g, b, a = HexToRGBA(GetVehicleColor(veh))
    local model = GetVehicleModel(veh)
    for i, v in ipairs(PlayerData[ply].garages[garageid].vehicles) do
        if (v.color[1] == r and v.color[2] == g and v.color[3] == b and v.color[4] == a and v.nitro == GetVehiclePropertyValue(veh, "HasNitro") and v.armor == GetVehiclePropertyValue(veh, "VehArmor")) then
            return i
        end
    end
    return false
end

AddEvent("OnPlayerEnterOnsetCustoms", function(ply, zone_id)
    local veh = GetPlayerVehicle(ply)
    if veh ~= 0 then
        if (PlayerData[ply] and veh == GetPlayerStoredVehicle(ply) and GetVehicleDriver(veh) == ply) then
            for i = 2, 4 do
                local passenger = GetVehiclePassenger(veh, i)
                if (passenger and passenger ~= 0) then
                    RemovePlayerFromVehicle(passenger)
                    CallRemoteEvent(passenger, "CreateNotification", "Onset Customs", "The vehicle entered Onset Customs", 5000)
                end
            end
            local o_customs_id = GetOnsetCustomFromZoneId(zone_id)
            if o_customs_id then
                local from_garage = GetVehiclePropertyValue(veh, "FromGarage")
                if from_garage then
                    local o_customs_dim = CreateDimension("onset_customs", true)
                    AddVehicleInDimension(veh, o_customs_dim)
                    AddPlayerInDimension(ply, o_customs_dim)
                    SetPlayerInVehicle(ply, veh)
                    SetVehicleHealth(veh, 5000)
                    CallRemoteEvent(ply, "EnteredOnsetCustoms", o_customs_id, GetVehiclePropertyValue(veh, "HasNitro"), GetVehiclePropertyValue(veh, "VehArmor"))
                    SetVehicleLocation(veh, Onset_Customs[o_customs_id][2][1], Onset_Customs[o_customs_id][2][2], Onset_Customs[o_customs_id][2][3])
                    SetVehicleRotation(veh, 0, Onset_Customs[o_customs_id][2][4], 0)
                else
                    print("Error : no FromGarage property value")
                end
            else
                print("Error : can't find o_customs_id")
            end
        end
    else
        CallRemoteEvent(ply, "CreateNotification", "Onset Customs", "You need to be in a vehicle", 5000)
    end
end)

AddRemoteEvent("LeaveOnsetCustoms", function(ply, o_customs_id)
    if PlayerData[ply] then
        local veh = GetPlayerVehicle(ply)
        if (veh and veh ~= 0 and o_customs_id) then
            local base = GetDimensionByName("base")
            AddVehicleInDimension(veh, base)
            AddPlayerInDimension(ply, base)
            SetPlayerInVehicle(ply, veh)
            SetVehicleHealth(veh, 5000)
            SetVehicleLocation(veh, Onset_Customs[o_customs_id][4][1], Onset_Customs[o_customs_id][4][2], Onset_Customs[o_customs_id][4][3])
            SetVehicleRotation(veh, 0, Onset_Customs[o_customs_id][4][4], 0)
        end
    end
end)

AddRemoteEvent("BuyNitro", function(ply, veh)
    local model = GetVehicleModel(veh)
    local garageid = GetVehiclePropertyValue(veh, "FromGarage")
    local index = GetVehicleIndexFromVehAndGarage(ply, veh, garageid)
    if index then
        local veh_price
        for i, v in ipairs(car_dealer_vehicles) do
            if v[1] == model then
                veh_price = v[2]
                break
            end
        end
        if veh_price then
            if Buy(ply, math.floor(nitro_price_percentage * veh_price / 100)) then
                PlayerData[ply].garages[garageid].vehicles[index].nitro = true
                SetVehiclePropertyValue(veh, "HasNitro", true, false)
                AttachVehicleNitro(veh, true)
                CallRemoteEvent(ply, "CreateNotification", "Onset Customs", "Nitro bought", 5000)
            end
        else
            print("Error : can't find veh_price")
        end
    else
        print("Error : can't find index of the vehicle in the garage")
    end
end)

AddRemoteEvent("ChangeVehicleColor", function(ply, veh, r, g, b, a)
    local garageid = GetVehiclePropertyValue(veh, "FromGarage")
    local index = GetVehicleIndexFromVehAndGarage(ply, veh, garageid)
    if index then
        if Buy(ply, car_paint_cost) then
            PlayerData[ply].garages[garageid].vehicles[index].color = {r, g, b, a}
            SetVehicleColor(veh, RGB(r, g, b, a))
            CallRemoteEvent(ply, "CreateNotification", "Onset Customs", "Vehicle color changed", 5000)
        end
    else
        print("Error : can't find index of the vehicle in the garage")
    end
end)

AddRemoteEvent("BuyVehicleArmor", function(ply, veh)
    local garageid = GetVehiclePropertyValue(veh, "FromGarage")
    local index = GetVehicleIndexFromVehAndGarage(ply, veh, garageid)
    if index then
        local armor_id = PlayerData[ply].garages[garageid].vehicles[index].armor + 1
        if armor_id <= table_count(Vehicle_armors) then
            if (PlayerData[ply].level >= Vehicle_armors[armor_id][1] and Buy(ply, Vehicle_armors[armor_id][2])) then
                PlayerData[ply].garages[garageid].vehicles[index].armor = armor_id
                SetVehiclePropertyValue(veh, "VehArmor", armor_id, false)
                CallRemoteEvent(ply, "CreateNotification", "Onset Customs", "Vehicle armor bought", 5000)
            end
        else
            print("Error : higher armor_id value than Vehicles_armors")
        end
    else
        print("Error : can't find index of the vehicle in the garage")
    end
end)