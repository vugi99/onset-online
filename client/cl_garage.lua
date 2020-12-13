
IsInGarageUI = false
IsInManageVehiclesUI = false
local WaitingGarages = false

--[[AddEvent("OnObjectStreamIn", function(obj)
    if GetObjectModel(obj) == 2 then
        GetObjectActor(obj):SetActorEnableCollision(false)
    end
end)]]--

function LeaveGarageUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInGarageUI = false
end

AddRemoteEvent("BuyGarageUI", function(garageid)
    if not IsInGarageUI then
        local ScreenX, ScreenY = GetScreenSize()
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
        dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
        dialogPosition.width = "600px"

        local dialog = UIDialog()
        dialog.setTitle("Garage")
        dialog.appendTo(UIFramework)
        dialog.setCSS(dialogPosition)
        dialog.onClickClose(function(obj)
            obj.destroy()
            LeaveGarageUI()
        end)

        local text = UIText()
        text.setContent("Garage Price : " .. tostring(garages[garageid].price) .. "$ <br> Garage Slots : " .. tostring(table_count(garages[garageid].vehicles)))
        text.appendTo(dialog)

        local BuyButton = UIButton()
        BuyButton.setTitle("Buy Garage")
        BuyButton.onClick(function(obj)
            LeaveGarageUI()
            CallRemoteEvent("BuyGarage", garageid)
            dialog.destroy()
        end)
        BuyButton.appendTo(dialog)

        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInGarageUI = true
    end
end)

function LeaveManageVehiclesUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    SetCameraLocation(0,0,0, false)
    SetCameraRotation(0,0,0, false)
    IsInManageVehiclesUI = false
end

function SellVehiclesUI(garage_vehicles)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Sell a Vehicle")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveManageVehiclesUI()
    end)

    local SellButton = UIButton()

    local SellList = UIOptionList()
    for i, v in ipairs(garage_vehicles) do
        for i2, v2 in ipairs(car_dealer_vehicles) do 
           if GetVehicleModel(v) == v2[1] then
              SellList.appendOption(i-1, "Vehicle " .. tostring(v2[1]) .. ", value : " .. tostring(math.floor(v2[2]*sell_vehicle_percentage/100)) .. "$")
           end
        end
    end
    SellList.appendTo(dialog)
    local selected = nil
    SellList.onChange(function(obj)
        selected = garage_vehicles[math.floor(obj.getValue()[1])+1]
        local x, y, z = GetVehicleLocation(selected)
        local rx, ry, rz = GetVehicleRotation(selected)
        SetCameraLocation(x, y, z + 300)
        SetCameraRotation(-90, ry, rz)
        for i2, v2 in ipairs(car_dealer_vehicles) do 
            if GetVehicleModel(selected) == v2[1] then
               SellButton.setTitle("Sell Vehicle (" .. tostring(math.floor(v2[2]*sell_vehicle_percentage/100)) .. "$)")
               SellButton.update()
               break
            end
         end
    end)

    SellButton.setTitle("Select a vehicle")
    SellButton.onClick(function(obj)
        if selected then
            CallRemoteEvent("SellVehicle", selected)
            dialog.destroy()
            LeaveManageVehiclesUI()
        else
            AddPlayerChat("Please select a vehicle")
        end
    end)
    SellButton.appendTo(dialog)
end

function MoveVehiclesUI(mygarages)
    local garage_vehicles = GetStreamedVehicles()
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Move a Vehicle")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveManageVehiclesUI()
    end)

    local comboContainerTexts = UIContainer()
    comboContainerTexts.setSizes({300,50})
    comboContainerTexts.setDirection("horizontal")
    comboContainerTexts.appendTo(dialog)

    local vehtext = UIText()
    vehtext.setContent("Select a vehicle : ")
    vehtext.appendTo(comboContainerTexts)

    local garagetext = UIText()
    garagetext.setContent("Select a garage : ")
    garagetext.appendTo(comboContainerTexts)

    local comboContainer = UIContainer()
    comboContainer.setSizes({300,100})
    comboContainer.setDirection("horizontal")
    comboContainer.appendTo(dialog)

    local CarsList = UIOptionList()
    for i, v in ipairs(garage_vehicles) do
        CarsList.appendOption(i-1, tostring(v) .. " model " .. tostring(GetVehicleModel(v)))
    end
    CarsList.appendTo(comboContainer)
    local selected = nil
    CarsList.onChange(function(obj)
       selected = garage_vehicles[math.floor(obj.getValue()[1])+1]
       local x, y, z = GetVehicleLocation(selected)
       local rx, ry, rz = GetVehicleRotation(selected)
       SetCameraLocation(x, y, z + 300)
       SetCameraRotation(-90, ry, rz)
    end)

    local GarageList = UIOptionList()
    for i, v in ipairs(mygarages) do
        GarageList.appendOption(i-1, "Garage " .. tostring(v.id) .. ", " .. tostring(v.freeslots) .. " free slots")
    end
    local selectedgarage = nil
    GarageList.onChange(function(obj)
       selectedgarage = mygarages[math.floor(obj.getValue()[1]) + 1].id
    end)
    GarageList.appendTo(comboContainer)

    local MoveButton = UIButton()
    MoveButton.setTitle("Move vehicle")
    MoveButton.onClick(function(obj)
        if selected then
            if selectedgarage then
                CallRemoteEvent("MoveGarageVehicle", selected, selectedgarage)
                dialog.destroy()
                LeaveManageVehiclesUI()
            else
                AddPlayerChat("Please select a garage")
            end
        else
            AddPlayerChat("Please select a vehicle")
        end
    end)
    MoveButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInManageVehiclesUI = true
    WaitingGarages = false
end

function SelectManageVehiclesUI()
   local garage_vehicles = GetStreamedVehicles()
   if table_count(garage_vehicles) > 0 then
        local ScreenX, ScreenY = GetScreenSize()
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
        dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
        dialogPosition.width = "600px"

        local dialog = UIDialog()
        dialog.setTitle("Manage Vehicles")
        dialog.appendTo(UIFramework)
        dialog.setCSS(dialogPosition)
        dialog.onClickClose(function(obj)
            obj.destroy()
            LeaveManageVehiclesUI()
        end)
        
        local SellButton = UIButton()
        SellButton.setTitle("Sell a vehicle")
        SellButton.onClick(function(obj)
            SellVehiclesUI(garage_vehicles)
            dialog.destroy()
        end)
        SellButton.appendTo(dialog)

        local MoveButton = UIButton()
        MoveButton.setTitle("Move a vehicle to another garage")
        MoveButton.onClick(function(obj)
            CallRemoteEvent("GetGaragesMove")
            dialog.destroy()
            WaitingGarages = true
            LeaveManageVehiclesUI()
        end)
        MoveButton.appendTo(dialog)

        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInManageVehiclesUI = true
   else
      CreateNotification("Garage", "You don't have any vehicles in this garage", 5000)
   end
end

AddRemoteEvent("SendGaragesMove", function(tbl)
    if tbl then
        MoveVehiclesUI(tbl)
    else
        WaitingGarages = false
        CreateNotification("Garage", "You can't move a vehicle to another garage", 5000)
    end
end)


AddEvent("OnPlayerManageVehiclesAction",function(hittype, hitid, impactX, impactY, impactZ)
    if (not IsInManageVehiclesUI and not WaitingGarages) then
       SelectManageVehiclesUI()
    end
end)