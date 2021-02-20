IsInTrainingUI = false
WaitingTrainingStart = false
IsTraining = false
local TrainingBulletsShot = 0
local TrainingBulletsSuccess = 0
local TrainingTextBox
local TrainingSuccessTextBox
local TAimLocked
local Hidden_targets = {}
local Created_targets = {}

local cur_CQB_Targets_locations = {}
CQB_Training_id = nil
local CQB_Remaining_TargetsTextBox
local CQB_Time = 0
local CQB_Time_Timer
local CQB_Time_TextBox

local Target_letters = {
    "B",
    "P",
    "_",
    "T",
    "a",
    "r",
    "g",
    "e",
    "t"
}

local Target_letters_count = table_count(Target_letters)

function LeaveTrainingUI()
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    IsInTrainingUI = false
end

function CQBSTARTUI(npc)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Close quarters combat start Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveTrainingUI()
    end)

    local weapontext = UIText()
    weapontext.setContent("Please select a weapon : ")
    weapontext.appendTo(dialog)

    local WeaponsList = UIOptionList()
    for i, v in ipairs(weapons_shops_weapons) do
        WeaponsList.appendOption(i-1, "Weapon : " .. tostring(v[1]))
    end
    WeaponsList.appendTo(dialog)
    local selected = nil
    WeaponsList.onChange(function(obj)
       selected = weapons_shops_weapons[math.floor(obj.getValue()[1])+1][1]
    end)

    local StartButton = UIButton()
    StartButton.setTitle("Start (" .. tostring(_CQB_price) .. "$)")
    StartButton.onClick(function(obj)
        if selected then
            if money >= _CQB_price then
                WaitingTrainingStart = true
                dialog.destroy()
                CallRemoteEvent("StartCQB", npc, selected)
                LeaveTrainingUI()
            end
        else
            AddPlayerChat("Please select a weapon")
        end
    end)
    StartButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        CQBUI(npc)
    end)
    BackButton.appendTo(dialog)
end

function CQBRecordsUI(npc, personnal_record, public_records)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Close quarters combat records Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveTrainingUI()
    end)

    if personnal_record.time then
        local personnaltext = UIText()
        personnaltext.setContent("Your personal record : <br> Time : " .. tostring(personnal_record.time) .. " ms <br> Weapon : " .. tostring(personnal_record.weapon))
        personnaltext.appendTo(dialog)
    end

    if table_count(public_records) > 0 then
        local SteamidText = UIText()

        local RecordsList = UIOptionList()
        for i, v in ipairs(public_records) do
            RecordsList.appendOption(i-1, "(" .. tostring(i) .. "), Name : " .. v.name .. ", Time : " .. tostring(v.record.time) .. " ms")
        end
        RecordsList.appendTo(dialog)
        RecordsList.onChange(function(obj)
            local selected = public_records[obj.getValue()[1]+1]
            SteamidText.setContent("SteamId : " .. selected.steamid .. " <br> Weapon : " .. tostring(selected.record.weapon))
            SteamidText.update()
        end)

        SteamidText.appendTo(dialog)
    else
        local notext = UIText()
        notext.setContent("There is no CQB records")
        notext.appendTo(dialog)
    end

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        CQBUI(npc)
    end)
    BackButton.appendTo(dialog)
end

function CQBUI(npc)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Close quarters combat Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveTrainingUI()
    end)

    local RecordsButton = UIButton()
    RecordsButton.setTitle("Records")
    RecordsButton.onClick(function(obj)
        dialog.destroy()
        WaitingTrainingStart = npc
        CallRemoteEvent("GetCQBRecords")
    end)
    RecordsButton.appendTo(dialog)

    local TryButton = UIButton()
    TryButton.setTitle("Close quarters combat (" .. tostring(_CQB_price) .. "$)")
    TryButton.onClick(function(obj)
        if money >= _CQB_price then
            dialog.destroy()
            CQBSTARTUI(npc)
        else
            AddPlayerChat("You don't have enough money")
        end
    end)
    TryButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        MainTrainingUI(npc)
    end)
    BackButton.appendTo(dialog)
end

function ShootingRangeUI(npc)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Shooting Range Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveTrainingUI()
    end)

    local weapontext = UIText()
    weapontext.setContent("Please select a weapon : ")
    weapontext.appendTo(dialog)

    local WeaponsList = UIOptionList()
    for i, v in ipairs(weapons_shops_weapons) do
        WeaponsList.appendOption(i-1, "Weapon : " .. tostring(v[1]))
    end
    WeaponsList.appendTo(dialog)
    local selected = nil
    WeaponsList.onChange(function(obj)
       selected = weapons_shops_weapons[math.floor(obj.getValue()[1])+1][1]
    end)

    local StartButton = UIButton()
    StartButton.setTitle("Start (" .. tostring(_Shooting_range_price) .. "$)")
    StartButton.onClick(function(obj)
        if selected then
            WaitingTrainingStart = true
            dialog.destroy()
            CallRemoteEvent("StartShootingRange", npc, selected)
            LeaveTrainingUI()
            SetIgnoreMoveInput(true)
        else
            AddPlayerChat("Please select a weapon")
        end
    end)
    StartButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        dialog.destroy()
        MainTrainingUI(npc)
    end)
    BackButton.appendTo(dialog)
end

function MainTrainingUI(npc)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Training Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        obj.destroy()
        LeaveTrainingUI()
    end)

    local SRButton = UIButton()
    SRButton.setTitle("Shooting Range")
    SRButton.onClick(function(obj)
        if money >= _Shooting_range_price then
            dialog.destroy()
            ShootingRangeUI(npc)
        else
            AddPlayerChat("You don't have enough money")
        end
    end)
    SRButton.appendTo(dialog)

    local TrainingButton = UIButton()
    TrainingButton.setTitle("Close quarters combat")
    TrainingButton.onClick(function(obj)
        dialog.destroy()
        CQBUI(npc)
    end)
    TrainingButton.appendTo(dialog)

    if not IsInTrainingUI then
        ShowMouseCursor(true)
        SetIgnoreMoveInput(true)
        SetIgnoreLookInput(true)
        SetInputMode(input_while_in_ui)
        IsInTrainingUI = true
    end
end

function ClearCreatedTargets()
    for i, v in ipairs(Created_targets) do
        v:Destroy()
    end
    Created_targets = {}
    for i, v in ipairs(Hidden_targets) do
        v:SetActorHiddenInGame(false)
        v:SetActorEnableCollision(true)
    end
    Hidden_targets = {}
end

function SRTrainingFinished()
    local xp_earned = math.floor((TrainingBulletsSuccess / _Shooting_range_bullets) * _Shooting_range_xp_earned)
    CreateNotification("Training", "You finished and got " .. tostring(TrainingBulletsSuccess) .. "/" .. tostring(_Shooting_range_bullets) .. " good hits, you won " .. tostring(xp_earned) .. " xp", 10000)
    TAimLocked = true
    CancelAimImmediately()
    if TrainingTextBox then
        DestroyTextBox(TrainingTextBox)
        TrainingTextBox = nil
    end
    if TrainingSuccessTextBox then
        DestroyTextBox(TrainingSuccessTextBox)
        TrainingSuccessTextBox = nil
    end
    IsTraining = false
    Delay(3000, function()
        TAimLocked = false
        SetIgnoreMoveInput(false)
    end)
    ClearCreatedTargets()
    CallRemoteEvent("SRTrainingFinished", TrainingBulletsSuccess)
end

function CQBTrainingFinished()
    CallRemoteEvent("CQBTrainingFinished")
end

function RecreateTargets()
    for k, v in pairs(GetWorld():GetActorsByClass(AActor.Class())) do
        local name = v:GetName()
        for i, v2 in ipairs(Target_letters) do
            if v2 == name:sub(i,i) then
                if i == Target_letters_count then
                    --AddPlayerChat("FOUND " .. name)
                    local loc = v:GetActorLocation()
                    local rot = v:GetActorRotation()
                    v:SetActorHiddenInGame(true)
                    v:SetActorEnableCollision(false)
                    table.insert(Hidden_targets, v)
                    local target = GetWorld():SpawnActor(UClass.LoadFromAsset("/Game/Geometry/Prefabs/Shooting/BP_Target1"), loc, rot)
                    table.insert(Created_targets, target)
                    --[[for i3, v3 in pairs(v:GetComponents()) do
                        if v3:GetName() == "SM_target1" then
                            AddPlayerChat(v3:GetPathName())
                        end
                    end]]--
                end
            else
                break
            end
        end
    end
end

function GetCQBTargetCurIndex(actor)
    local loc = actor:GetActorLocation()
    for i, v in ipairs(cur_CQB_Targets_locations) do
        if O_GetDistanceSquared2D(loc.X, loc.Y, v[1], v[2]) <= 2500 then
            return i
        end
    end
end

function CQB_TIMER()
    CQB_Time = CQB_Time + 100
    SetTextBoxText(CQB_Time_TextBox, "Time : " .. tostring(CQB_Time) .. " ms")
end

AddEvent("OnPlayerToggleAim", function(toggle)
    if (toggle == true and TAimLocked) then
        return false
    end
end)

AddEvent("OnPlayerTraining", function(hittype, hitid, impactX, impactY, impactZ)
    if (not IsInTrainingUI and not WaitingTrainingStart and not IsTraining and not TAimLocked) then
        MainTrainingUI(hitid)
    end
end)

AddRemoteEvent("SRTrainingStartSuccess", function()
    if WaitingTrainingStart then
        TrainingBulletsShot = 0
        TrainingBulletsSuccess = 0
        local ScreenX, ScreenY = GetScreenSize()
        TrainingTextBox = CreateTextBox((ScreenX / 2) - 25, 50, "Training : 0/" .. tostring(_Shooting_range_bullets), "left")
        TrainingSuccessTextBox = CreateTextBox((ScreenX / 2) - 25, 75, "Good hits : 0/0", "left")
        IsTraining = true
        WaitingTrainingStart = false
        RecreateTargets()
    end
end)

AddRemoteEvent("SRTrainingStartFailed", function()
    SetIgnoreMoveInput(false)
    CreateNotification("Training", "Failed to start the training", 5000)
    WaitingTrainingStart = false
end)

AddRemoteEvent("CQBTrainingStartSuccess", function(t_id)
    if WaitingTrainingStart then
        CQB_Training_id = t_id
        for i, v in ipairs(_Training[t_id].CQB_targets_locations) do
            table.insert(cur_CQB_Targets_locations, v)
        end
        local ScreenX, ScreenY = GetScreenSize()
        CQB_Remaining_TargetsTextBox = CreateTextBox((ScreenX / 2) - 25, 50, "Remaining : " .. tostring(table_count(cur_CQB_Targets_locations)), "left")
        IsTraining = true
        WaitingTrainingStart = false
        CQB_Time_TextBox = CreateTextBox((ScreenX / 2) - 25, 75, "Time : 0 ms", "left")
        CQB_Time = 0
        CQB_Time_Timer = CreateTimer(CQB_TIMER, 100)
        RecreateTargets()
    end
end)

AddEvent("OnPlayWeaponHitEffects", function(ply, Weapon, HitType, HitId, StartLocation, HitLocation, HitLocationRelative, HitNormal, HitResult)
    if IsTraining then
        if ply == GetPlayerId() then
            if not CQB_Training_id then
                TrainingBulletsShot = TrainingBulletsShot + 1
                SetTextBoxText(TrainingTextBox, "Training : " .. tostring(TrainingBulletsShot) .. "/" .. tostring(_Shooting_range_bullets))
                if HitType == HIT_OBJECT then
                    --local loc = HitResult:GetActor():GetActorLocation()
                    --AddPlayerChat(tostring(loc.X) .. " " .. tostring(loc.Y) .. " " .. tostring(loc.Z))
                    if HitResult:GetComponent():GetName() == "SM_target1" then
                        TrainingBulletsSuccess = TrainingBulletsSuccess + 1
                    end
                end
                SetTextBoxText(TrainingSuccessTextBox, "Good hits : " .. tostring(TrainingBulletsSuccess) .. "/" .. tostring(TrainingBulletsShot))
                if TrainingBulletsShot == _Shooting_range_bullets then
                    SRTrainingFinished()
                end
            else
                if HitType == HIT_OBJECT then
                    --local loc = HitResult:GetActor():GetActorLocation()
                    --AddPlayerChat(tostring(loc.X) .. " " .. tostring(loc.Y) .. " " .. tostring(loc.Z))
                    if HitResult:GetComponent():GetName() == "SM_target1" then
                        local index = GetCQBTargetCurIndex(HitResult:GetActor())
                        if index then
                            table.remove(cur_CQB_Targets_locations, index)
                            local count = table_count(cur_CQB_Targets_locations)
                            SetTextBoxText(CQB_Remaining_TargetsTextBox, "Remaining : " .. tostring(count))
                            local t_sound = CreateSound("sounds/training_sound.mp3")
                            if count == 0 then
                                CQBTrainingFinished()
                            end
                        end
                    end
                end
            end
        end
    end
end)

AddRemoteEvent("CQBFinishedTrigger", function(new_record, time)
    if new_record then
        CreateNotification("Training", "You have set a new record with " .. tostring(time) .. " ms, you won " .. tostring(_CQB_xp_earned) .. " xp", 10000)
    else
        CreateNotification("Training", "You did " .. tostring(time) .. " ms, you won " .. tostring(_CQB_xp_earned) .. " xp", 7000)
    end
    SetIgnoreMoveInput(true)
    TAimLocked = true
    CancelAimImmediately()
    if CQB_Remaining_TargetsTextBox then
        DestroyTextBox(CQB_Remaining_TargetsTextBox)
        CQB_Remaining_TargetsTextBox = nil
    end
    IsTraining = false
    Delay(3000, function()
        TAimLocked = false
        SetIgnoreMoveInput(false)
    end)
    cur_CQB_Targets_locations = {}
    CQB_Training_id = nil
    if CQB_Time_Timer then
        DestroyTimer(CQB_Time_Timer)
        CQB_Time_Timer = nil
    end
    if CQB_Time_TextBox then
        DestroyTextBox(CQB_Time_TextBox)
        CQB_Time_TextBox = nil
    end
    CQB_Time = 0
    ClearCreatedTargets()
end)

AddRemoteEvent("SendCQBRecords", function(personnal_record, public_records)
    if WaitingTrainingStart then
        CQBRecordsUI(WaitingTrainingStart, personnal_record, public_records)
        WaitingTrainingStart = false
    end
end)