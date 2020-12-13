
local UIFrameworkReady = false

AddEvent("OnUIFrameworkReady",function()
    UIFrameworkReady = true
end)

IsInSpawnUI = false

function LeaveSpawnUI()
   ShowMouseCursor(false)
   SetIgnoreMoveInput(false)
   SetIgnoreLookInput(false)
   SetInputMode(INPUT_GAME)
   IsInSpawnUI = false
end

SetInputMode(INPUT_UI) -- stop player move when loading

function SpawnUI(garages, houses)
      local ScreenX, ScreenY = GetScreenSize()
      local dialogPosition = UICSS()
      local offset = 250
      if (garages and table_count(garages) > 0) then
          offset = offset + 250
      end
      if (houses and table_count(houses) > 0) then
         offset = offset + 250
      end
      dialogPosition.top = math.floor((ScreenY - offset) / 2) .. "px"
      dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
      dialogPosition.width = "600px"

      local dialog = UIDialog()
      dialog.setTitle("Spawn Selection")
      dialog.appendTo(UIFramework)
      dialog.setCSS(dialogPosition)
      dialog.setCanClose(false)
      --dialog.onClickClose(function(obj)
          --obj.hide()
      --end)

      local Spawn_text = UIText()
      Spawn_text.setContent("Please select a spawn")
      Spawn_text.appendTo(dialog)

      local spawnList = UIOptionList()
      local index_spawn = 0
      local list = {}
      for k,v in pairs(spawns) do
         spawnList.appendOption(index_spawn, k)
         list[index_spawn + 1] = k
         index_spawn = index_spawn + 1
      end
      spawnList.appendTo(dialog)
      spawnList.onChange(function(obj)
         local selectedSpawn = spawns[list[obj.getValue()[1]+1]]
         LeaveSpawnUI()
         GetPlayerActor(GetPlayerId()):SetActorRotation(FRotator(0,selectedSpawn.roty,0))
         CallRemoteEvent("TeleportSpawn",selectedSpawn.x,selectedSpawn.y,selectedSpawn.z)
         SetCameraLocation(0, 0, 0, false)
         SetCameraRotation(0, 0, 0, false)
         --ShowChat(false)
         dialog.destroy()
      end)
      
      if (garages and table_count(garages) > 0) then
         local garage_text = UIText()
         garage_text.setContent("Please select a garage")
         garage_text.appendTo(dialog)
         
         local garagesList = UIOptionList()
         local index_garages = 0
         for k,v in pairs(garages) do
            garagesList.appendOption(index_garages, "garage : " .. tostring(v))
            index_garages = index_garages + 1
         end
         garagesList.appendTo(dialog)
         garagesList.onChange(function(obj)
            local selectedSpawn = garages[obj.getValue()[1]+1]
            LeaveSpawnUI()
            CallRemoteEvent("Spawn_garage", selectedSpawn)
            SetCameraLocation(0, 0, 0, false)
            SetCameraRotation(0, 0, 0, false)
            --ShowChat(false)
            dialog.destroy()
         end)
      end

      if (houses and table_count(houses) > 0) then
         local houses_text = UIText()
         houses_text.setContent("Please select a house")
         houses_text.appendTo(dialog)
            
         local housesList = UIOptionList()
         local index_houses = 0
         for k, v in pairs(houses) do
            housesList.appendOption(index_houses, "house : " .. tostring(v.id))
            index_houses = index_houses + 1
         end
         housesList.appendTo(dialog)
         housesList.onChange(function(obj)
            local selectedSpawn = houses[obj.getValue()[1]+1].id
            LeaveSpawnUI()
            CallRemoteEvent("Spawn_house", selectedSpawn)
            SetCameraLocation(0, 0, 0, false)
            SetCameraRotation(0, 0, 0, false)
            --ShowChat(false)
            dialog.destroy()
         end)
      end

      SetCameraLocation(123666, 168021, 3255, true)
      SetCameraRotation(0, 76, 0, true)   

   ShowMouseCursor(true)
   SetIgnoreMoveInput(true)
   SetIgnoreLookInput(true)
   IsInSpawnUI = true
   SetInputMode(input_while_in_ui)
end

AddRemoteEvent("SpawnUI",function(nb, garages, houses)
    --local plyactor = GetPlayerActor(GetPlayerId())
    --plyactor:SetActorLocation(FVector(spawn_loc[1], spawn_loc[2], spawn_loc[3]))
    --plyactor:SetActorRotation(FRotator(0, spawn_loc[4], 0))
    if UIFrameworkReady then
       if nb == 0 then
          ClothesUI(true)
       else
           SpawnUI(garages, houses)
       end
    else
        AddEvent("OnUIFrameworkReady",function()
            if nb == 0 then
               ClothesUI(true)
            else
               SpawnUI(garages, houses)
            end
        end)
    end
end)