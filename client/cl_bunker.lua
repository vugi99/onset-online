
IsInBuyBunkerUI = false
IsInBunkerUI = false

_B_dialog = nil
_B_text = nil
_RawMats_BuyButton = nil
_RawMats_StealButton = nil
_Storage_SellButton = nil

InBunkerMission = false
Bunker_Objectives_Waypoints = {}
Bunker_Objectives_TextBoxes = {}
tbox_bunker_objectives = nil

function LeaveBuyBunkerUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInBuyBunkerUI = false
end

function LeaveBunkerUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInBunkerUI = false
    _B_dialog = nil
    _B_text = nil
    _RawMats_BuyButton = nil
    _RawMats_StealButton = nil
    _Storage_SellButton = nil
end

function BuyBunkerUI(bunkerid)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Buy Bunker Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveBuyBunkerUI()
    end)

    local BuyBunkerButton = UIButton()
    BuyBunkerButton.setTitle("Buy bunker " .. tostring(bunkerid) .. " (" .. tostring(_Bunkers[bunkerid].Bunker_price) .. "$)")
    BuyBunkerButton.onClick(function(obj)
        dialog.destroy()
        LeaveBuyBunkerUI()
        CallRemoteEvent("BuyBunker", bunkerid)
    end)
    BuyBunkerButton.appendTo(dialog)

    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
    IsInBuyBunkerUI = true
end

function CreateRawMatsBuyButton(b_data)
    if _B_dialog then
        local BuyRawMatsButton = UIButton()
        BuyRawMatsButton.setTitle("Buy full raw mats for " .. tostring(_Bunkers[b_data.id].Full_Raw_Materials_price) .. "$")
        BuyRawMatsButton.onClick(function(obj)
            if money >= _Bunkers[b_data.id].Full_Raw_Materials_price then
                _B_dialog.destroy()
                LeaveBunkerUI()
                CallRemoteEvent("BuyRawMats")
            end
        end)
        BuyRawMatsButton.appendTo(_B_dialog)
        return BuyRawMatsButton
    end
end

function CreateStealRawMatsButton(b_data)
    if _B_dialog then
        local StealRawMatsButton = UIButton()
        StealRawMatsButton.setTitle("Steal " .. tostring(_Bunkers[b_data.id].Raw_materials_steal_add_percent) .. " of raw materials for this bunker")
        StealRawMatsButton.onClick(function(obj)
            _B_dialog.destroy()
            LeaveBunkerUI()
            CallRemoteEvent("StealRawMats")
        end)
        StealRawMatsButton.appendTo(_B_dialog)
        return StealRawMatsButton
    end
end

function CreateSellStorageButton(b_data)
    if _B_dialog then
        local SellStorageButton = UIButton()
        SellStorageButton.setTitle("Deliver weapons for " .. tostring(_Bunkers[b_data.id].Bunker_Full_Sell_Money) .. "$")
        SellStorageButton.onClick(function(obj)
            _B_dialog.destroy()
            LeaveBunkerUI()
            CallRemoteEvent("SellBunkerStorage")
        end)
        SellStorageButton.appendTo(_B_dialog)
        return SellStorageButton
    end
end

function BunkerUI(npc)
    local b_data = GetNPCPropertyValue(npc, "BunkerData")

    if b_data then
        local ScreenX, ScreenY = GetScreenSize()
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
        dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
        dialogPosition.width = "600px"

        local dialog = UIDialog()
        _B_dialog = dialog
        dialog.setTitle("Bunker Menu")
        dialog.appendTo(UIFramework)
        dialog.setCSS(dialogPosition)
        dialog.onClickClose(function(obj)
            obj.destroy()
            LeaveBunkerUI()
        end)

        local B_text = UIText()
        B_text.setContent("Storage : " .. tostring(b_data.storage) .. "% <br> Raw Materials : " .. tostring(b_data.raw_mats) .. "%")
        B_text.appendTo(dialog)
        _B_text = B_text

        if b_data.storage == 100 then
            _Storage_SellButton = CreateSellStorageButton(b_data)
        end

        if b_data.raw_mats < 100 then
            if b_data.raw_mats == 0 then
                _RawMats_BuyButton = CreateRawMatsBuyButton(b_data)
            end
            _RawMats_StealButton = CreateStealRawMatsButton(b_data)
        end

        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInBunkerUI = true
    else
        AddPlayerChat("Error : No b_data : BunkerUI")
        CallRemoteEvent("ReceiveClientError", "No b_data : BunkerUI")
    end
end

AddRemoteEvent("ShowBuyBunkerUI", function(bunkerid)
    if not IsInBuyBunkerUI then
        BuyBunkerUI(bunkerid)
    end
end)

AddEvent("OnPlayerBunker", function(hittype, hitid, impactX, impactY, impactZ)
    if not IsInBunkerUI then
        BunkerUI(hitid)
    end
end)

AddEvent("OnNPCNetworkUpdatePropertyValue", function(npc, pname, pval)
    if pname == "BunkerData" then
        if (_B_text and _B_dialog) then
            _B_text.setContent("Storage : " .. tostring(pval.storage) .. "% <br> Raw Materials : " .. tostring(pval.raw_mats) .. "%")
            _B_text.update()
            if (pval.storage == 100 and not _Storage_SellButton) then
                _Storage_SellButton = CreateSellStorageButton(pval)
            end
    
            if pval.raw_mats < 100 then
                if (pval.raw_mats == 0 and not _RawMats_BuyButton) then
                    _RawMats_BuyButton = CreateRawMatsBuyButton(pval)
                end
                if not _RawMats_StealButton then
                    _RawMats_StealButton = CreateStealRawMatsButton(pval)
                end
            end
        end
    end
end)

AddRemoteEvent("BunkerObjectivesStart", function(waypoints, textboxes)
    InBunkerMission = true
    SetPassive(false)
    LockPassive(true)
    if waypoints then
        for i, v in ipairs(waypoints) do
            local waypoint = CreateWaypoint(v[3], v[4], v[5], v[2])
            Bunker_Objectives_Waypoints[v[1]] = waypoint
        end
    end
    if textboxes then
        tbox_bunker_objectives = CreateTextBox(1, 500, "Objectives : ", "left")
        for i, v in ipairs(textboxes) do
            local textbox = CreateTextBox(1, 500 + 25 * i, v[2], "left")
            Bunker_Objectives_TextBoxes[v[1]] = textbox
        end
    end
end)

AddRemoteEvent("ChangeBunkerObjectives", function(waypoints, textboxes)
    if waypoints then
        for i, v in ipairs(waypoints) do
            if Bunker_Objectives_Waypoints[v[1]] then
                SetWaypointLocation(Bunker_Objectives_Waypoints[v[1]], v[3], v[4], v[5])
                SetWaypointText(Bunker_Objectives_Waypoints[v[1]], v[2])
            end
        end
    end
    if textboxes then
        for i, v in ipairs(textboxes) do
            if Bunker_Objectives_TextBoxes[v[1]] then
                SetTextBoxText(Bunker_Objectives_TextBoxes[v[1]], v[2])
            end
        end
    end
end)

AddRemoteEvent("BunkerMissionFinished", function(success, ftext)
    local text
    if success then
        text = ftext .. " finished"
    else
        text = ftext .. " failed"
    end
    CreateNotification("Bunker", text, 10000)
    if tbox_bunker_objectives then
        DestroyTextBox(tbox_bunker_objectives)
    end
    for i, v in pairs(Bunker_Objectives_Waypoints) do
        DestroyWaypoint(v)
    end
    for i, v in pairs(Bunker_Objectives_TextBoxes) do
        DestroyTextBox(v)
    end
    InBunkerMission = false
    Bunker_Objectives_Waypoints = {}
    Bunker_Objectives_TextBoxes = {}
    tbox_bunker_objectives = nil
    SetPassive(false)
    LockPassive(false)
end)