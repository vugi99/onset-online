
IsInWeaponShopUI = false
_weaptext = nil
cur_weapon_shop_id = nil
WaitingBuyAmmoConfirmation = false

function HasInventoryWeapon(weapid)
    if (GetPlayerWeapon(1) == weapid or GetPlayerWeapon(2) == weapid or GetPlayerWeapon(3) == weapid) then
       return true
    end
    return false
end

function HasAWeaponInInventory()
    if (GetPlayerWeapon(1) == 1 and GetPlayerWeapon(2) == 1 and GetPlayerWeapon(3) == 1) then
        return false
     end
     return true
end

function HasInventoryWeaponFromObjectModel(model)
   for i,v in ipairs(weapons_shops_weapons) do
      if v[2] == model then
         if HasInventoryWeapon(v[1]) then
            return true
         end 
      end
   end
   return false
end

function HasInventoryWeaponFromObject(obj)
    if HasInventoryWeaponFromObjectModel(GetObjectModel(obj)) then
       return true
    end
    return false
end

AddEvent("OnPlayerWeaponShopAction",function(hittype, hitid, impactX, impactY, impactZ)
    if not IsInWeaponShopUI then
       CallRemoteEvent("ActivateWeaponShop", hitid)
    end
end)

function LeaveWeaponShopUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    CallRemoteEvent("LeaveWeaponShop")
    SetCameraLocation(0,0,0, false)
    SetCameraRotation(0,0,0, false)
    _weaptext = nil
    cur_weapon_shop_id = nil
    WaitingBuyAmmoConfirmation = false
    IsInWeaponShopUI = false
end

function UpdateWeapText()
   local weaponStreamed = GetStreamedObjects()
   if (_weaptext and weaponStreamed[1]) then
      local model = GetObjectModel(weaponStreamed[1])
      for i,v in ipairs(weapons_shops_weapons) do
         if v[2] == model then
            _weaptext.setContent("Weapon : " .. tostring(v[1]) .. " <br> Weapon Price : " .. tostring(v[3]) .. " <br> Price For 1 Bullet : " .. tostring(v[5]) .. " <br> Default Ammo : " .. tostring(v[4]))
            _weaptext.update()
         end
      end
   end
end

function BuyWeaponsUI(weapon_shop_id)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 750) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 1600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Gun Shop")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveWeaponShopUI()
    end)

    local text = UIText()
    text.setContent("Select a weapon : ")
    text.appendTo(dialog)

    local BuyButton = UIButton()

    local WeaponsList = UIOptionList()
    for i, v in ipairs(weapons_shops_weapons) do
        if not HasInventoryWeapon(v[1]) then
           WeaponsList.appendOption(i-1, "Weapon : " .. tostring(v[1]) .. " " .. tostring(v[3]) .. "$")
        end
    end
    WeaponsList.appendTo(dialog)
    local selected = nil
    local price = nil
    WeaponsList.onChange(function(obj)
       selected = weapons_shops_weapons[math.floor(obj.getValue()[1])+1][1]
       price = weapons_shops_weapons[math.floor(obj.getValue()[1])+1][3]
       BuyButton.setTitle("Buy Weapon (" .. tostring(price) .. "$)")
       BuyButton.update()
       CallRemoteEvent("ShowcaseWeapon", weapon_shop_id, selected)
    end)

    local text = UIText()
    text.setContent("Select a slot : ")
    text.appendTo(dialog)

    local SlotList = UIOptionList()
    for i=1,3 do
       if GetPlayerWeapon(i) == 1 then
          SlotList.appendOption(i-1, tostring(i) .. ", free slot")
       else
          SlotList.appendOption(i-1, tostring(i) .. ", weapon " .. tostring(GetPlayerWeapon(i)))
       end
    end
    SlotList.appendTo(dialog)
    local selectedslot = nil
    SlotList.onChange(function(obj)
       selectedslot = math.floor(obj.getValue()[1])+1
    end)

    local text = UIText()
    text.setContent("")
    _weaptext = text
    text.appendTo(dialog)
    --UpdateWeapText()

    BuyButton.setTitle("Select a weapon")
    BuyButton.onClick(function(obj)
        if selected then
            if selectedslot then
                if money >= price then
                    CallRemoteEvent("BuyWeapon", selected, selectedslot)
                    dialog.destroy()
                else
                    CreateNotification("Gun Store", "You don't have enough money", 5000)
                end
            else
                AddPlayerChat("Please select a slot")
            end
        else
            AddPlayerChat("Please select a weapon")
        end
    end)
    BuyButton.appendTo(dialog)

    SetCameraLocation(weapons_shops[weapon_shop_id][5], weapons_shops[weapon_shop_id][6], weapons_shops[weapon_shop_id][7], true)
    SetCameraRotation(-90, weapons_shops[weapon_shop_id][9], 0, true)
end

function BuyAmmoUI(weapon_shop_id)
   _weaptext = nil
   local weapons_shop_tables = {}
   for i=1,3 do
      if GetPlayerWeapon(i) ~= 1 then
         for i2,v2 in ipairs(weapons_shops_weapons) do
            if v2[1] == GetPlayerWeapon(i) then
                local weapid, ammo, ammo_in = GetPlayerWeapon(i)
                if (ammo + ammo_in < max_weapon_ammo) then
                   table.insert(v2, i)
                   table.insert(weapons_shop_tables, v2)
                end
            end
         end
      end
   end
   if table_count(weapons_shop_tables) > 0 then
        local ScreenX, ScreenY = GetScreenSize()
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor((ScreenY - 500) / 2) .. "px"
        dialogPosition.left = math.floor((ScreenX - 1600) / 2) .. "px !important"
        dialogPosition.width = "600px"

        local dialog = UIDialog()
        dialog.setTitle("Gun Shop")
        dialog.appendTo(UIFramework)
        dialog.setCSS(dialogPosition)
        dialog.onClickClose(function(obj)
            obj.destroy()
            LeaveWeaponShopUI()
        end)

        local text = UIText()
        text.setContent("Select a weapon : ")
        text.appendTo(dialog)

        local BuyButton = UIButton()
        local BuyButton2 = UIButton()

        local WeaponsList = UIOptionList()
        for i, v in ipairs(weapons_shop_tables) do
            if i == 1 then
                CallRemoteEvent("ShowcaseWeapon", weapon_shop_id, v[1])
            end
            WeaponsList.appendOption(i-1, "Weapon : " .. tostring(v[1]))
        end
        WeaponsList.appendTo(dialog)
        local selected
        local ammo_sold
        local price_for_1_bullet
        local ammo2
        WeaponsList.onChange(function(obj)
            selected = weapons_shop_tables[math.floor(obj.getValue()[1])+1][1]
            ammo_sold = weapons_shop_tables[math.floor(obj.getValue()[1])+1][4]
            price_for_1_bullet = weapons_shop_tables[math.floor(obj.getValue()[1])+1][5]
            local slot = weapons_shop_tables[math.floor(obj.getValue()[1])+1][table_count(weapons_shop_tables[math.floor(obj.getValue()[1])+1])]
            local weapid, ammo, ammo_in = GetPlayerWeapon(slot)
            ammo2 = ammo+ammo_in
            if ammo2 + ammo_sold > max_weapon_ammo then
               ammo_sold = max_weapon_ammo - ammo2
            end
            BuyButton.setTitle("Buy " .. ammo_sold .. " Ammo (" .. tostring(ammo_sold*price_for_1_bullet) .. "$)")
            BuyButton.update()
            BuyButton2.setTitle("Buy " .. max_weapon_ammo - ammo2 .. " Ammo (" .. tostring((max_weapon_ammo - ammo2)*price_for_1_bullet) .. "$)")
            BuyButton2.update()
            CallRemoteEvent("ShowcaseWeapon", weapon_shop_id, selected)
        end)

        local text = UIText()
        text.setContent("Max weapon ammo : " .. tostring(max_weapon_ammo))
        text.appendTo(dialog)

        BuyButton.setTitle("Select a weapon")
        BuyButton.onClick(function(obj)
            if selected then
                if money >= ammo_sold*price_for_1_bullet then
                   if not WaitingBuyAmmoConfirmation then
                      WaitingBuyAmmoConfirmation = true
                      CallRemoteEvent("BuyAmmo", selected, ammo_sold)
                      ammo2 = ammo2 + ammo_sold
                      BuyButton2.setTitle("Buy " .. max_weapon_ammo - ammo2 .. " Ammo (" .. tostring((max_weapon_ammo - ammo2)*price_for_1_bullet) .. "$)")
                      BuyButton2.update()
                      if ammo2 + ammo_sold > max_weapon_ammo then
                            ammo_sold = max_weapon_ammo - ammo2
                            if ammo_sold > 0 then 
                                BuyButton.setTitle("Buy " .. ammo_sold .. " Ammo (" .. tostring(ammo_sold*price_for_1_bullet) .. "$)")
                                BuyButton.update()
                            else
                                dialog.destroy()
                                SetCameraLocation(0,0,0, false)
                                SetCameraRotation(0,0,0, false)
                                SelectWeaponShopUI(weapon_shop_id)
                            end
                      end
                   else
                       AddPlayerChat("Please wait")
                   end
                else
                    CreateNotification("Gun Store", "You don't have enough money", 5000)
                end
            else
                AddPlayerChat("Please select a weapon")
            end
        end)
        BuyButton.appendTo(dialog)

        BuyButton2.setTitle("Select a weapon")
        BuyButton2.onClick(function(obj)
            if selected then
                if money >= (max_weapon_ammo - ammo2)*price_for_1_bullet then
                    if not WaitingBuyAmmoConfirmation then
                       CallRemoteEvent("BuyAmmo", selected, max_weapon_ammo - ammo2, true)
                       dialog.destroy()
                       SetCameraLocation(0,0,0, false)
                       SetCameraRotation(0,0,0, false)
                       SelectWeaponShopUI(weapon_shop_id)
                    else
                        AddPlayerChat("Please wait")
                    end
                 else
                     CreateNotification("Gun Store", "You don't have enough money", 5000)
                 end
            else
                AddPlayerChat("Please select a weapon")
            end
        end)
        BuyButton2.appendTo(dialog)

        SetCameraLocation(weapons_shops[weapon_shop_id][5], weapons_shops[weapon_shop_id][6], weapons_shops[weapon_shop_id][7], true)
        SetCameraRotation(-90, weapons_shops[weapon_shop_id][9], 0, true)
   else
       CreateNotification("Gun Store", "You have max ammo in each weapon", 5000)
       LeaveWeaponShopUI()
   end
end

function SelectWeaponShopUI(weapon_shop_id)
    cur_weapon_shop_id = weapon_shop_id
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Gun Shop")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveWeaponShopUI()
    end)

    local BuyWeaponsButton = UIButton()
    BuyWeaponsButton.setTitle("Buy Weapons")
    BuyWeaponsButton.onClick(function(obj)
        BuyWeaponsUI(weapon_shop_id)
        dialog.destroy()
    end)
    BuyWeaponsButton.appendTo(dialog)

    if HasAWeaponInInventory() then
        local BuyAmmoButton = UIButton()
        BuyAmmoButton.setTitle("Buy ammo for current weapons")
        BuyAmmoButton.onClick(function(obj)
            BuyAmmoUI(weapon_shop_id)
            dialog.destroy()
        end)
        BuyAmmoButton.appendTo(dialog)
    end

    if GetPlayerArmor() < 100 then
       local BuyArmorButton = UIButton()
       BuyArmorButton.setTitle("Buy Armor (" .. tostring(armor_cost) .. "$)")
       BuyArmorButton.onClick(function(obj)
           if money >= armor_cost then
              obj.destroy()
              CallRemoteEvent("BuyArmor")
           else
               AddPlayerChat("You don't have enough money")
           end
       end)
       BuyArmorButton.appendTo(dialog)
    end

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInWeaponShopUI = true
end

AddEvent("OnObjectStreamIn", function(obj)
    if IsInWeaponShopUI then
       UpdateWeapText()
    end
end)

AddRemoteEvent("AmmoBought", function()
    WaitingBuyAmmoConfirmation = false
end)

AddRemoteEvent("BuyWeaponResponse", function(success, weapid)
    if success then
       CreateNotification("Gun Store", "You bought weapon " .. tostring(weapid), 5000)
       SetCameraLocation(0,0,0, false)
       SetCameraRotation(0,0,0, false)
       SelectWeaponShopUI(cur_weapon_shop_id)
    else
        CreateNotification("Gun Store", "You don't have enough money to buy this weapon", 5000)
        LeaveWeaponShopUI()
    end
end)

AddRemoteEvent("WeaponShopActivated", function(weapon_shop_id)
    if not IsInWeaponShopUI then
       SelectWeaponShopUI(weapon_shop_id)
    end
end)



