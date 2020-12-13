
IsInOnsetCustomsUI = false

function LeaveOnsetCustomsUI()
   ShowMouseCursor(false)
   SetIgnoreMoveInput(false)
   SetIgnoreLookInput(false)
   SetInputMode(INPUT_GAME)
   IsInOnsetCustomsUI = false
   SetCameraLocation(0, 0, 0, false)
   SetCameraRotation(0, 0, 0, false)
end

local function GetVehiclePriceFromModel(model)
    for i, v in ipairs(car_dealer_vehicles) do
        if v[1] == model then
            return v[2]
        end
    end
    return false
end

function OnsetCustoms_Color_UI(o_customs_id, nitro, armor, veh)
    local veh_color_before = GetVehicleColor(veh)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 275) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 1600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Onset Customs")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveOnsetCustomsUI()
        SetVehicleColor(veh, veh_color_before)
        CallRemoteEvent("LeaveOnsetCustoms", o_customs_id)
    end)

    local ColorPosition = UICSS()
    ColorPosition.left = "300px !important"

    local ColorPicker = UIColorPicker()
    ColorPicker.onChange(function(obj, value)
        local r, g, b, a = obj.getValueAsRGBA()
        SetVehicleColor(veh, RGB(r, g, b, a*255))
    end)
    ColorPicker.setCSS(ColorPosition)
    ColorPicker.appendTo(dialog)

    local Color_Text = UIText()
    Color_Text.setContent("Please select a color : <br> ")
    Color_Text.appendTo(dialog)

    local SelectColorButton = UIButton()
    SelectColorButton.setTitle("Change vehicle color " .. tostring(car_paint_cost) .. "$")
    SelectColorButton.onClick(function(obj)
        if money >= car_paint_cost then
            dialog.destroy()
            local r, g, b, a = ColorPicker.getValueAsRGBA()
            CallRemoteEvent("ChangeVehicleColor", veh, r, g, b, a)
            OnsetCustomsUI(o_customs_id, nitro, armor, true)
        else
            AddPlayerChat("You don't have enough money")
        end
    end)
    SelectColorButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        SetVehicleColor(veh, veh_color_before)
        OnsetCustomsUI(o_customs_id, nitro, armor, true)
    end)
    BackButton.appendTo(dialog)
end

function OnsetCustomsUI(o_customs_id, nitro, armor, from_back)
    local nitro = nitro
    local armor = armor
    local veh = GetPlayerVehicle(GetPlayerId())
    local model = GetVehicleModel(veh)
    if (veh and veh ~= 0) then
        local ScreenX, ScreenY = GetScreenSize()
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor((ScreenY - 275) / 2) .. "px"
        dialogPosition.left = math.floor((ScreenX - 1600) / 2) .. "px !important"
        dialogPosition.width = "600px"

        local dialog = UIDialog()
        dialog.setTitle("Onset Customs")
        dialog.appendTo(UIFramework)
        dialog.setCSS(dialogPosition)
        dialog.onClickClose(function(obj)
            obj.destroy()
            LeaveOnsetCustomsUI()
            CallRemoteEvent("LeaveOnsetCustoms", o_customs_id)
        end)

        local ColorButton = UIButton()
        ColorButton.setTitle("Change vehicle color " .. tostring(car_paint_cost) .. "$")
        ColorButton.onClick(function(obj)
            if money >= car_paint_cost then
                dialog.destroy()
                OnsetCustoms_Color_UI(o_customs_id, nitro, armor, veh)
            else
                AddPlayerChat("You don't have enough money")
            end
        end)
        ColorButton.appendTo(dialog)

        if not nitro then
            local price = GetVehiclePriceFromModel(model)
            local nitro_price = math.floor(nitro_price_percentage * price / 100)
            if price then
                local NitroButton = UIButton()
                NitroButton.setTitle("Buy nitro " .. tostring(nitro_price) .. "$")
                NitroButton.onClick(function(obj)
                    if money >= nitro_price then
                        obj.destroy()
                        CallRemoteEvent("BuyNitro", veh)
                        nitro = true
                    else
                        AddPlayerChat("You don't have enough money")
                    end
                end)
                NitroButton.appendTo(dialog)
            end
        end

        local total_armors = table_count(Vehicle_armors)
        if armor < total_armors then
            local ArmorButton = UIButton()
            ArmorButton.setTitle("Buy " .. tostring(Vehicle_armors[armor + 1][3]) .."% vehicle armor " .. tostring(Vehicle_armors[armor + 1][2]) .. "$, level required : " .. tostring(Vehicle_armors[armor + 1][1]))
            ArmorButton.onClick(function(obj)
                if (money >= Vehicle_armors[armor + 1][2] and PlayerLevel >= Vehicle_armors[armor + 1][1]) then
                    CallRemoteEvent("BuyVehicleArmor", veh)
                    armor = armor + 1
                    if armor >= total_armors then
                        obj.destroy()
                    else
                        ArmorButton.setTitle("Buy " .. tostring(Vehicle_armors[armor + 1][3]) .."% vehicle armor " .. tostring(Vehicle_armors[armor + 1][2]) .. "$, level required : " .. tostring(Vehicle_armors[armor + 1][1]))
                        ArmorButton.update()
                    end
                else
                    AddPlayerChat("You don't have enough money or levels")
                end
            end)
            ArmorButton.appendTo(dialog)
        end

        local LeaveButton = UIButton()
        LeaveButton.setTitle("Leave Onset Customs")
        LeaveButton.onClick(function(obj)
            dialog.destroy()
            LeaveOnsetCustomsUI()
            CallRemoteEvent("LeaveOnsetCustoms", o_customs_id)
        end)
        LeaveButton.appendTo(dialog)

        if not from_back then
            IsInOnsetCustomsUI = true
            ShowMouseCursor(true)
            SetIgnoreMoveInput(true)
            SetIgnoreLookInput(true)
            SetInputMode(input_while_in_ui)

            local vehsk = GetVehicleSkeletalMeshComponent(veh)
            vehsk:SetPhysicsLinearVelocity(FVector(0, 0, 0, false))
            vehsk:SetPhysicsAngularVelocityInDegrees(FVector(0, 0, 0, false))

            Delay(1000, function()
                SetCameraLocation(Onset_Customs[o_customs_id][3][1], Onset_Customs[o_customs_id][3][2], Onset_Customs[o_customs_id][3][3], true)
                SetCameraRotation(0, Onset_Customs[o_customs_id][3][4], 0, true)
            end)
        end
    else
        CallRemoteEvent("ReceiveClientError", "Can't find veh in Onset Customs")
    end
end

AddRemoteEvent("EnteredOnsetCustoms", function(o_customs_id, nitro, armor)
    if not IsInOnsetCustomsUI then
        OnsetCustomsUI(o_customs_id, nitro, armor)
        CreateNotification("Onset Customs", "Car repaired", 10000)
    end
end)