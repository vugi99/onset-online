
LoadPak("finish", "/Racing/", "../../../OnsetModding/Plugins/Racing/Content")

local curstartlinemodel = nil

local checkpoints_hide = {}

local checkpoints = nil

local compteur_state = nil
local compteur_time = nil

local waypoint = nil

local place = nil
local plycount = nil

local decompte = nil
local decompte_s = nil
local decompte_block_vel_timer

local curindex = 1

local time_until_restart = nil

local afk_timer = nil
local afk_posx = nil
local afk_posy = nil

local returncar_textbox = CreateTextBox(1, 525, "", "left")
local lastcheckpoint_textbox = CreateTextBox(1, 550, "", "left")
local changingrace_textbox = CreateTextBox(1, 575, "", "left")

AddEvent("OnRenderHUD",function()
    if IsInARace then
        --local veh = GetPlayerVehicle(GetPlayerId())
        DrawText(1, 500, "Ping " .. GetPing())
        --[[if veh ~= 0 then
            DrawText(0,525,"R = return your car")
            DrawText(0,550,"C = last checkpoint")
        end
        if time_until_restart then
            DrawText(0,575,"Changing race in " .. tostring(time_until_restart) .. " ms")
        end]]--
    end
end)

AddEvent("OnPlayerEnterVehicle", function(ply, veh, seat)
    if (ply == GetPlayerId() and seat == 1 and IsInARace) then
        SetTextBoxText(returncar_textbox, "R = return your car")
        SetTextBoxText(lastcheckpoint_textbox, "C = last checkpoint")
    end
end)

AddEvent("OnPlayerLeaveVehicle", function(ply, veh, seat)
    if ply == GetPlayerId() then
        SetTextBoxText(returncar_textbox, "")
        SetTextBoxText(lastcheckpoint_textbox, "")
    end
end)

AddEvent("OnObjectStreamIn",function(id) 
    if IsInARace then
        GetObjectActor(id):SetActorEnableCollision(false)
        for i,v in ipairs(checkpoints_hide) do
            if v == id then
                GetObjectActor(id):SetActorHiddenInGame(true)
            end
        end
    end
end)

function update_compteur()
   if (compteur_time and compteur_state) then
      compteur_time=compteur_time+100
      CallEvent("GUI:SetRaceTime", compteur_time)
   end
end

AddEvent("OnPackageStart", function()
    CreateTimer(update_compteur, 100)
end)

AddEvent("OnRacingUILoaded",function()
    ShowWeaponHUD(false)
    ShowHealthHUD(false)
end)

AddEvent("OnRacingUIDestroyed", function()
    ShowWeaponHUD(true)
    ShowHealthHUD(true)
end)

AddRemoteEvent("hidecheckpoint",function(id)
    curindex=curindex+1
    DestroyWaypoint(waypoint)

    if curindex+1==#checkpoints then
        GetObjectActor(id):SetActorHiddenInGame(true)
        table.insert(checkpoints_hide,id)
        local csound = CreateSound("racing/sounds/checkpoint.mp3")
        SetSoundVolume(csound, 0.6)
        waypoint=CreateWaypoint(checkpoints[curindex+1][1], checkpoints[curindex+1][2], checkpoints[curindex+1][3], "Finish Line")
        CallEvent("GUI:PlayerPassedCheckpoint", compteur_time, curindex-1)
    elseif curindex+1==#checkpoints+1 then
        compteur_state=false
        CreateSound("racing/sounds/race_end.mp3")
        if afk_timer then
            DestroyTimer(afk_timer)
            afk_timer=nil
        end
        CallEvent("GUI:PlayerFinished", compteur_time, place)
    elseif curindex+1<#checkpoints then
        GetObjectActor(id):SetActorHiddenInGame(true)
        table.insert(checkpoints_hide,id)
        local csound = CreateSound("racing/sounds/checkpoint.mp3")
        SetSoundVolume(csound, 0.6)
        waypoint=CreateWaypoint(checkpoints[curindex+1][1], checkpoints[curindex+1][2], checkpoints[curindex+1][3], "Checkpoint " .. curindex)
        CallEvent("GUI:PlayerPassedCheckpoint", compteur_time, curindex-1)
    end
end)

AddRemoteEvent("classement_update",function(placer,playercountr,start)
    place=placer
    plycount=playercountr
    CallEvent("GUI:UpdatePlayerPosition", placer, playercountr)
    if start then
        SetIgnoreMoveInput(true)
       Delay(2000,function()
            CallRemoteEvent("Readytostart")
       end)
    end
end)

function createstart(modelpath)
   if curstartlinemodel ~= nil then
       curstartlinemodel:Destroy()
       curstartlinemodel = nil
   end
   curstartlinemodel = GetWorld():SpawnActor(AStaticMeshActor.Class(), FVector(checkpoints[1][1], checkpoints[1][2], checkpoints[1][3]), FRotator(0, checkpoints[1][4], 0))
   curstartlinemodel:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
   curstartlinemodel:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset(modelpath))
   curstartlinemodel:SetActorScale3D(FVector(1, 1, 1))
   curstartlinemodel:GetStaticMeshComponent():SetMobility(EComponentMobility.Static)
   curstartlinemodel:GetStaticMeshComponent():SetCollisionEnabled(ECollisionEnabled.NoCollision)
end

function decompte_update()
   if IsInARace then
      if decompte_s-1 > 0 then
         decompte_s=decompte_s-1
         if decompte_s == 3 then
            local sound = CreateSound("racing/sounds/race_start.mp3")
            SetSoundVolume(sound, 0.5)
         elseif decompte_s == 2 then
            local sound = CreateSound("racing/sounds/race_start.mp3")
            SetSoundVolume(sound, 0.75)
         elseif decompte_s == 1 then
            local sound = CreateSound("racing/sounds/race_start.mp3")
            SetSoundVolume(sound, 1)
         end
         CallEvent("GUI:NotifyCountValue", decompte_s)
      else
         local sound = CreateSound("racing/sounds/race_start.mp3")
         SetSoundVolume(sound, 1.5)
         SetIgnoreMoveInput(false)
         decompte_s=nil
         DestroyTimer(decompte)
         decompte=nil
         compteur_time=0
         compteur_state=true
         createstart("/Racing/finishlinesignvert")
         CallEvent("GUI:NotifyCountValue", -1)
         if decompte_block_vel_timer then
            DestroyTimer(decompte_block_vel_timer)
            decompte_block_vel_timer = nil
         end
      end
   end
end

function block_vehicle_velocity()
    local veh = GetPlayerVehicle(GetPlayerId())
    if (veh and veh ~= 0) then
        local vehsk = GetVehicleSkeletalMeshComponent(veh)
        vehsk:SetPhysicsLinearVelocity(FVector(0, 0, 0), false)
    end
end

AddRemoteEvent("checkpointstbl",function(tbl,temps)
    checkpoints=tbl
    curindex = 1
    decompte_s = temps
    SetIgnoreMoveInput(true)
    checkpoints_hide = {}
    decompte = CreateTimer(decompte_update,temps*1000/temps)
    createstart("/Racing/finishlinesignrouge")
    if afk_timer then
        DestroyTimer(afk_timer)
        afk_timer=nil
      end
    if waypoint==nil then
       waypoint=CreateWaypoint(tbl[curindex+1][1], tbl[curindex+1][2], tbl[curindex+1][3], "Checkpoint " .. curindex)
    else
        DestroyWaypoint(waypoint)
        waypoint=CreateWaypoint(tbl[curindex+1][1], tbl[curindex+1][2], tbl[curindex+1][3], "Checkpoint " .. curindex)
    end
    decompte_block_vel_timer = CreateTimer(block_vehicle_velocity, 40)
end)

AddEvent("OnKeyPress",function(key)
    if IsInARace then
        local veh = GetPlayerVehicle(GetPlayerId())
        if (veh~=0 and veh) then
            if key == "R" then
                CallRemoteEvent("returncar_racing")
            end
            if key == "C" then
                CallRemoteEvent("last_checkpoint")
            end
        end
    end
end)

local showed_timer = nil

function update_time()
    if time_until_restart-100 > 0 then
       time_until_restart=time_until_restart-100
       SetTextBoxText(changingrace_textbox, "Changing race in " .. tostring(time_until_restart) .. " ms")
   else
       if showed_timer then
          DestroyTimer(showed_timer)
          showed_timer=nil
       end
       time_until_restart=nil
       SetTextBoxText(changingrace_textbox, "")
    end
end

function EndOfRace()
    IsInARace = false
    if IsInRacingMenuUI then
       _Racing_menu_dialog.destroy()
       _Racing_menu_dialog = nil
    end
    if curstartlinemodel ~= nil then
        curstartlinemodel:Destroy()
        curstartlinemodel = nil
    end
    checkpoints_hide = {}
    if showed_timer then
        DestroyTimer(showed_timer)
        showed_timer=nil
     end
     time_until_restart=nil
     if waypoint then
        DestroyWaypoint(waypoint)
        waypoint = nil
     end
     if decompte then
        SetIgnoreMoveInput(false)
        decompte_s=nil
        DestroyTimer(decompte)
        decompte=nil
        compteur_time=0
        CallEvent("GUI:NotifyCountValue", -1)
        if decompte_block_vel_timer then
            DestroyTimer(decompte_block_vel_timer)
            decompte_block_vel_timer = nil
        end
     end
     SetTextBoxText(returncar_textbox, "")
     SetTextBoxText(lastcheckpoint_textbox, "")
     SetTextBoxText(changingrace_textbox, "")
end

AddRemoteEvent("Start_finish_timer", function(time_ms,isdestroy)
    if isdestroy then
        EndOfRace()
    else
       time_until_restart=time_ms
       showed_timer = CreateTimer(update_time,100)
       SetTextBoxText(changingrace_textbox, "Changing race in " .. tostring(time_until_restart) .. " ms")
    end
end)

function check_afk()
   local x,y,z = GetPlayerLocation(GetPlayerId())
   if (x~=afk_posx or y ~= afk_posy) then
       afk_posx=x
       afk_posy=y
   else
      CallRemoteEvent("imafk")
   end
end

AddRemoteEvent("startlookingforafk",function()
    local x,y,z = GetPlayerLocation(GetPlayerId())
    afk_posx=x
    afk_posy=y
    local afk_timer = CreateTimer(check_afk,120000)
end)