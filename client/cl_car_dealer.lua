
IsInCarDealerUI = false
car_dealer_id = nil
local _colorpicker = nil

function LeaveCarDealerUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    CallRemoteEvent("LeaveCarDealer")
    SetCameraLocation(0,0,0, false)
    SetCameraRotation(0,0,0, false)
    car_dealer_id = nil
    _colorpicker = nil
    IsInCarDealerUI = false
end

function CarDealerUI(mygarages)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 500) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 1200) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Car Dealer")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveCarDealerUI()
    end)

    --[[local comboContainerTexts = UIContainer()
    comboContainerTexts.setSizes({200,50})
    comboContainerTexts.setDirection("horizontal")
    comboContainerTexts.appendTo(dialog)]]--

    local vehtext = UIText()
    vehtext.setContent("Select a vehicle : ")
    vehtext.appendTo(dialog)

    local colortext = UIText()
    colortext.setContent("Select a color : ")

    local garagetext = UIText()
    garagetext.setContent("Select a garage : ")

    --[[local comboContainer = UIContainer()
    comboContainer.setSizes({200,100})
    comboContainer.setDirection("horizontal")
    comboContainer.appendTo(dialog)]]--

    local ColorPosition = UICSS()
    ColorPosition.left = "300px !important"

    local ColorPicker = UIColorPicker()
    _colorpicker = ColorPicker
    ColorPicker.onChange(function(obj, value)
        local r, g, b, a = obj.getValueAsRGBA()
        local car
        for i,v in ipairs(GetStreamedVehicles()) do
           car = v
           break
        end
        if car then
           --[[local sk = GetVehicleSkeletalMeshComponent(car)
           sk:SetColorParameterOnMaterials("Base Color", FLinearColor(r/255, g/255, b/255, a))
           sk:SetColorParameterOnMaterials("Base Color 2", FLinearColor(r/255, g/255, b/255, a))
           sk:SetColorParameterOnMaterials("BaseColor", FLinearColor(r/255, g/255, b/255, a))]]--
           SetVehicleColor(car, RGB(r, g, b, a*255))
           --AddPlayerChat(tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a))
        end
    end)
    ColorPicker.setCSS(ColorPosition)
    local BuyButton = UIButton()
    BuyButton.setTitle("Select a car")

    local CarsList = UIOptionList()
    for i, v in ipairs(car_dealer_vehicles) do
        CarsList.appendOption(i-1, tostring(v[1]) .. " " .. tostring(v[2]) .. "$")
    end
    CarsList.appendTo(dialog)
    local selected = nil
    local price = nil
    CarsList.onChange(function(obj)
       selected = car_dealer_vehicles[math.floor(obj.getValue()[1])+1][1]
       price = car_dealer_vehicles[math.floor(obj.getValue()[1])+1][2]
       BuyButton.setTitle("Buy Car (" .. tostring(price) .. "$)")
       BuyButton.update()
       CallRemoteEvent("ShowcaseCar", car_dealer_id, selected)
    end)

    local GarageList = UIOptionList()
    for i, v in ipairs(mygarages) do
        GarageList.appendOption(i-1, "Garage " .. tostring(v.id) .. ", " .. tostring(v.freeslots) .. " free slots")
    end
    local selectedgarage = nil
    GarageList.onChange(function(obj)
       selectedgarage = mygarages[math.floor(obj.getValue()[1]) + 1].id
       --AddPlayerChat(tostring(selectedgarage))
    end)
    colortext.appendTo(dialog)
    ColorPicker.appendTo(dialog)

    garagetext.appendTo(dialog)
    GarageList.appendTo(dialog)

    BuyButton.onClick(function(obj)
        if selected then
            if selectedgarage then
                if money >= price then
                    local r, g, b, a = ColorPicker.getValueAsRGBA()
                    CallRemoteEvent("BuyCar", selectedgarage, selected, r, g, b, a)
                    dialog.destroy()
                    LeaveCarDealerUI()
                else
                    AddPlayerChat("You don't have enough money to buy this car")
                end
            else
                AddPlayerChat("Please Select a garage")
            end
        else
            AddPlayerChat("Please Select a vehicle")
        end
    end)

    BuyButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    for i,v in ipairs(car_dealer_npcs) do
       for i2,v2 in ipairs(GetStreamedNPC()) do
          local x, y, z = GetNPCLocation(v2)
          if GetDistance2D(v[1], v[2], x, y)<50 then
             car_dealer_id = i
          end
       end
    end
    SetCameraLocation(car_dealer_showcase[car_dealer_id][5], car_dealer_showcase[car_dealer_id][6], car_dealer_showcase[car_dealer_id][7], true)
    SetCameraRotation(car_dealer_showcase[car_dealer_id][8], car_dealer_showcase[car_dealer_id][9], car_dealer_showcase[car_dealer_id][10], true)
    IsInCarDealerUI = true
end


AddEvent("OnVehicleStreamIn", function(veh)
    if (IsInCarDealerUI and _colorpicker) then
        local r, g, b, a = _colorpicker.getValueAsRGBA()
        --[[local sk = GetVehicleSkeletalMeshComponent(veh)
        sk:SetColorParameterOnMaterials("Base Color", FLinearColor(r/255, g/255, b/255, a))
        sk:SetColorParameterOnMaterials("Base Color 2", FLinearColor(r/255, g/255, b/255, a))
        sk:SetColorParameterOnMaterials("BaseColor", FLinearColor(r/255, g/255, b/255, a))]]--
        SetVehicleColor(veh, RGB(r, g, b, a*255))
    end
end)

AddEvent("OnPlayerCarDealerAction",function(hittype, hitid, impactX, impactY, impactZ)
    if not IsInCarDealerUI then
       CallRemoteEvent("GetGarages")
    end
end)

AddRemoteEvent("SendGarages", function(tbl)
    if not IsInCarDealerUI then
        CarDealerUI(tbl)
     end
end)