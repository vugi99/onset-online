
local IsInClothesUI = false
local IsInClothesUIFIRST = false
local turnright = false
local turnleft = false

function LeaveClothesUI()
   ShowMouseCursor(false)
   SetIgnoreMoveInput(false)
   SetIgnoreLookInput(false)
   SetInputMode(INPUT_GAME)
   IsInClothesUI = false
   IsInClothesUIFIRST = false
end

function ClothesUI(first)
    local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    if first then
       dialogPosition.left = math.floor((ScreenX - 1600) / 2) .. "px !important"
    else
       dialogPosition.left = math.floor((ScreenX - 1500) / 2) .. "px !important"
    end
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Clothes Selection")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    if first then
       dialog.setCanClose(false)
    else
        dialog.onClickClose(function(obj)
           obj.destroy()
           LeaveClothesUI()
           SetPlayerClothingPreset(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes").clothes)
        end)
    end

    local Clothes_text = UIText()
    if first then
       Clothes_text.setContent("Please select your clothing preset (Use right and left keys to rotate)")
    else
       Clothes_text.setContent("Please select your clothing preset")
    end
    Clothes_text.appendTo(dialog)

    local ClothesList = UIOptionList()
    for i, v in ipairs(Clothing_presets_clothes) do
       ClothesList.appendOption(i-1, v)
    end
    ClothesList.appendTo(dialog)
    local selected = nil
    ClothesList.onChange(function(obj)
       selected = Clothing_presets_clothes[math.floor(obj.getValue()[1]+1)]
       SetPlayerClothingPreset(GetPlayerId(), selected)
    end)

    local okButton = UIButton()
    if first then
       okButton.setTitle("Select")
    else
       okButton.setTitle("Select (" .. tostring(clothing_store_price) .. "$)")
    end
    okButton.onClick(function(obj)
        if selected then
           CallRemoteEvent("ClothesPresetSelected",selected, not first)
           dialog.destroy()
           if first then
              --SpawnUI()
              GetPlayerActor(GetPlayerId()):SetActorRotation(FRotator(0, first_spawn_location[4], 0))
              CallRemoteEvent("TeleportSpawn", first_spawn_location[1], first_spawn_location[2], first_spawn_location[3])
              SetCameraLocation(0, 0, 0, false)
              SetCameraRotation(0, 0, 0, false)
              LeaveClothesUI()
              turnright = false
              turnleft = false
           else
              LeaveClothesUI()
              CreateNotification("Clothes", "You selected preset " .. tostring(selected), 5000)
           end
        end
    end)
    okButton.appendTo(dialog)
    if first then
       SetCameraLocation(123222, 168257, 3164, true)
       SetCameraRotation(0, 168, 0, true)
       IsInClothesUIFIRST = true
    end
    IsInClothesUI = true
    ShowMouseCursor(true)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetInputMode(input_while_in_ui)
end

---@param ry integer
local function inverse_rotation(ry)
   ry = ry + 180
   if ry > 180 then
      ry = -180 + (ry - 180)
   end
   return ry
end

---@param ry integer
---@param r2 integer
local function add_rotation(ry, r2)
   ry = ry + r2
   if ry > 180 then
      ry = -180 + (ry - 180)
   elseif ry < -180 then
      ry = 180 + (ry + 180)
   end
   return ry
end


---@param right boolean
function MoveCamFirst(right)
   local x, y, z = GetPlayerLocation(GetPlayerId())
   local rx, ry, rz = GetCameraRotation(false)
   local reversed = inverse_rotation(ry)
   if right then
      reversed = add_rotation(reversed, 1)
      SetCameraRotation(0, add_rotation(ry, -1), 0, true)
   else
      reversed = add_rotation(reversed, -1)
      SetCameraRotation(0, add_rotation(ry, 1), 0, true)
   end
   local fx, fy, fz = RotationToVector(0, reversed, 0)
   local mult = 150
   SetCameraLocation(x + fx * mult, y + fy * mult, z + 50 + fz * mult, true)
end


AddEvent("OnKeyPress", function(key)
   if (IsInClothesUI and IsInClothesUIFIRST) then
      if key == "D" then
         turnright = true
      elseif (key == "A" or key == "Q") then
         turnleft = true
      end
   end
end)

AddEvent("OnKeyRelease", function(key)
   if (IsInClothesUI and IsInClothesUIFIRST) then
      if key == "D" then
         turnright = false
      elseif (key == "A" or key == "Q") then
         turnleft = false
      end
   end
end)


AddEvent("OnGameTick", function(ds)
    if turnleft then
       MoveCamFirst(false)
    elseif turnright then
       MoveCamFirst(true)
    end
end)

AddEvent("OnPlayerClothingAction", function(hittype, hitid, impactX, impactY, impactZ)
    if money >= clothing_store_price then
       if not IsPoliceman then
          ClothesUI()
       else
          AddPlayerChat("You can't change your clothes as a Policeman")
       end
    else
        AddPlayerChat("You need " .. tostring(clothing_store_price) .. "$ to change your clothes")
    end
end)

