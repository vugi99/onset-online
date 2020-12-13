


AddEvent("OnVehicleDamage", function(veh, damage)
    local armor = GetVehiclePropertyValue(veh, "VehArmor")
    if (armor and armor > 0) then
        local armor_percentage = Vehicle_armors[armor][3]
        if GetVehicleHealth(veh) > 0 then
            SetVehicleHealth(veh, GetVehicleHealth(veh) + (damage * ((armor_percentage / 100) / 2)))
        end
        --print("Damage : " .. tostring(damage) .. " Damage_After : " .. tostring(damage / (armor_percentage * 2 / 100)))
    end
end)