
--If developerModeEnabled is set to true, it will allow for teleporting when the map is open via right click.
developerModeEnabled = false

legendkeys = {}

legendkeys[1] = {}
legendkeys[1].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/atm_icon.png"
legendkeys[1].displayText = "ATM"
legendkeys[1].blips = {}

for i,v in ipairs(atms_objects) do
   table.insert(legendkeys[1].blips, {v[1], v[2]})
end

legendkeys[2] = {}
legendkeys[2].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/shield.png"
legendkeys[2].displayText = "Gun Store"
legendkeys[2].blips = {}

for i,v in ipairs(weapons_shops) do
    table.insert(legendkeys[2].blips, {v[1], v[2]})
end

legendkeys[3] = {}
legendkeys[3].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/clothing_store_icon.png"
legendkeys[3].displayText = "Clothing Store"
legendkeys[3].blips = {}

for i,v in ipairs(clothes_npcs) do
    table.insert(legendkeys[3].blips, {v[1], v[2]})
end

legendkeys[4] = {}
legendkeys[4].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/garage_icon.png"
legendkeys[4].displayText = "Garage"
legendkeys[4].blips = {}

for i,v in ipairs(garages) do
    table.insert(legendkeys[4].blips, {v.entrance[1], v.entrance[2]})
end

legendkeys[5] = {}
legendkeys[5].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/car_dealer_icon.png"
legendkeys[5].displayText = "Car Dealer"
legendkeys[5].blips = {}

for i,v in ipairs(car_dealer_npcs) do
    table.insert(legendkeys[5].blips, {v[1], v[2]})
end

legendkeys[6] = {}
legendkeys[6].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/police_icon.png"
legendkeys[6].displayText = "Police"
legendkeys[6].blips = {}

for i,v in ipairs(police_npcs) do
    table.insert(legendkeys[6].blips, {v[1], v[2]})
end

legendkeys[7] = {}
legendkeys[7].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/racing_icon.png"
legendkeys[7].displayText = "Racing"
legendkeys[7].blips = {}

for i,v in ipairs(racing_objects) do
    table.insert(legendkeys[7].blips, {v[1], v[2]})
end

legendkeys[8] = {}
legendkeys[8].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/grocery_icon.png" -- https://thenounproject.com/term/supermarket/209497/
legendkeys[8].displayText = "Grocery Store"
legendkeys[8].blips = {}

for i,v in ipairs(grocery_npcs) do
    table.insert(legendkeys[8].blips, {v[1], v[2]})
end

legendkeys[9] = {}
legendkeys[9].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/helicopter_icon.png" -- https://thenounproject.com/term/helicopter/386500/
legendkeys[9].displayText = "Special Vehicles"
legendkeys[9].blips = {}

for i,v in ipairs(specials_vehicles_stores) do
    table.insert(legendkeys[9].blips, {v.npc[1], v.npc[2]})
end

legendkeys[10] = {}
legendkeys[10].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/house_icon.png" -- House By Sherrinford, FR, Creative Commons
legendkeys[10].displayText = "Appartment"
legendkeys[10].blips = {}

for i,v in ipairs(Appartments) do
    table.insert(legendkeys[10].blips, {v.Entrance[1], v.Entrance[2]})
end

legendkeys[11] = {}
legendkeys[11].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/onset_customs_icon.png" -- https://www.needpix.com/photo/1624178/tool-wrench-screwdriver-spanner-craftsmen-work-repair-icon-symbol
legendkeys[11].displayText = "Onset Customs"
legendkeys[11].blips = {}

for i,v in ipairs(Onset_Customs) do
    table.insert(legendkeys[11].blips, {math.floor(v[1][1] + (v[1][3] - v[1][1])/2), math.floor(v[1][2] + (v[1][4] - v[1][2])/2)})
end

legendkeys[12] = {}
legendkeys[12].iconPath = "http://asset/" .. GetPackageName() .. "/pinmap/client/web/icons/hats_store_icon.png" -- https://thenounproject.com/term/gentlemans-hat/103255/
legendkeys[12].displayText = "Hats Store"
legendkeys[12].blips = {}

for i,v in ipairs(Hats_Stores) do
    table.insert(legendkeys[12].blips, {v[1][1], v[1][2]})
end

