
local appartment_actor
IsInBuyHouseUI = false

IsInStartEnterHouseUI = false

function LeaveBuyHouseUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInBuyHouseUI = false
end

function BuyHouseUI(id)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Appartment")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveBuyHouseUI()
    end)

    local text = UIText()
    text.setContent("Appartment Price : " .. tostring(Appartments[id].Price) .. "$")
    text.appendTo(dialog)

    local BuyButton = UIButton()
    BuyButton.setTitle("Buy Appartment")
    BuyButton.onClick(function(obj)
        LeaveBuyHouseUI()
        CallRemoteEvent("BuyHouse", id)
        dialog.destroy()
    end)
    BuyButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInBuyHouseUI = true
end

function LeaveStartEnterHouseUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInStartEnterHouseUI = false
end

function StartEnterHouseUI(has_enough_money, id, friends)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 350) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Appartment")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveStartEnterHouseUI()
    end)

    if has_enough_money == nil then
        local EnterButton = UIButton()
        EnterButton.setTitle("Enter Appartment")
        EnterButton.onClick(function(obj)
            LeaveStartEnterHouseUI()
            appartment_actor = GetWorld():SpawnActor(UClass.LoadFromAsset(Appartments[id].Appartment_path), FVector(Appartments[id].Appartment_loc[1], Appartments[id].Appartment_loc[2], Appartments[id].Appartment_loc[3]), FRotator(Appartments[id].Appartment_rot[1], Appartments[id].Appartment_rot[2], Appartments[id].Appartment_rot[3]))
            SetPassive(true)
            LockPassive(true)
            CallRemoteEvent("EnterHouse", id)
            dialog.destroy()
        end)
        EnterButton.appendTo(dialog)
    elseif has_enough_money then
        local BuyUIButton = UIButton()
        BuyUIButton.setTitle("Buy Appartment")
        BuyUIButton.onClick(function(obj)
            LeaveStartEnterHouseUI()
            BuyHouseUI(id)
            dialog.destroy()
        end)
        BuyUIButton.appendTo(dialog)
    end

    if table_count(friends) > 0 then
        local text = UIText()
        text.setContent("Friends in appartments : ")
        text.appendTo(dialog)

        local Friends_in_house_List = UIOptionList()
        for i, v in ipairs(friends) do
            Friends_in_house_List.appendOption(i-1, v[2])
        end
        Friends_in_house_List.appendTo(dialog)
        local selected = nil
        Friends_in_house_List.onChange(function(obj)
            selected = friends[obj.getValue()[1]+1]
        end)

        local EnterFriendAppartmentButton = UIButton()
        EnterFriendAppartmentButton.setTitle("Enter in friend appartment")
        EnterFriendAppartmentButton.onClick(function(obj)
            if selected then
                LeaveStartEnterHouseUI()
                dialog.destroy()
                CallRemoteEvent("EnterFriendAppartment", selected, id)
            else
                AddPlayerChat("Please select a friend")
            end
        end)
        EnterFriendAppartmentButton.appendTo(dialog)
    end

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInStartEnterHouseUI = true
end

AddRemoteEvent("BuyHouseUI", function(id)
    if not IsInBuyHouseUI then
        BuyHouseUI(id)
    end
end)

AddRemoteEvent("OnStartEnterHouse", function(has_enough_money, id, friends)
    if not IsInStartEnterHouseUI then
        StartEnterHouseUI(has_enough_money, id, friends)
    end
end)

AddRemoteEvent("CreateHouseActor", function(id)
    SetPassive(true)
    LockPassive(true)
    appartment_actor = GetWorld():SpawnActor(UClass.LoadFromAsset(Appartments[id].Appartment_path), FVector(Appartments[id].Appartment_loc[1], Appartments[id].Appartment_loc[2], Appartments[id].Appartment_loc[3]), FRotator(Appartments[id].Appartment_rot[1], Appartments[id].Appartment_rot[2], Appartments[id].Appartment_rot[3]))
end)

AddRemoteEvent("DestroyHouseActor", function(owner_leaved)
    SetPassive(false)
    LockPassive(false)
    if appartment_actor then
        appartment_actor:Destroy()
        appartment_actor = nil
    end
    if owner_leaved then
        CreateNotification("Appartment", "Appartment owner leaved", 10000)
    end
end)