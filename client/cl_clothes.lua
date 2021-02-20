
local IsInClothesUI = false
local IsInClothesUIFIRST = false
local z_added_cam
local turnright = false
local turnleft = false

local Advanced_creation_parts = {}

function ResetAllBody()
   NSetClothes(GetPlayerId(), {type = "custom", clothes = {
      body = {"/Game/CharacterModels/SkeletalMesh/BodyMerged/HZN_CH3D_Normal01_LPR"},
      clothing0 = {nil},
      clothing1 = {nil},
      clothing2 = {nil},
      clothing3 = {nil},
      clothing4 = {nil},
      clothing5 = {nil},
      clothing6 = {nil},
      clothing7 = {nil},
      clothing8 = {nil},
      clothing9 = {nil}
   }})
end

function LeaveClothesUI()
   ShowMouseCursor(false)
   SetIgnoreMoveInput(false)
   SetIgnoreLookInput(false)
   SetInputMode(INPUT_GAME)
   IsInClothesUI = false
   IsInClothesUIFIRST = false
end

function FirstClothesSelected()
    --SpawnUI()
    GetPlayerActor(GetPlayerId()):SetActorRotation(FRotator(0, first_spawn_location[4], 0))
    CallRemoteEvent("TeleportSpawn", first_spawn_location[1], first_spawn_location[2], first_spawn_location[3])
    SetCameraLocation(0, 0, 0, false)
    SetCameraRotation(0, 0, 0, false)
    LeaveClothesUI()
    turnright = false
    turnleft = false
end

function ClothesUIPreset(first)
   local ScreenX, ScreenY = GetScreenSize()
   local dialogPosition = UICSS()
   dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
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
          ResetAllBody()
          NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
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
      ResetAllBody()
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
          CallRemoteEvent("ClothesSelected", {type = "preset", clothes = selected}, not first)
          dialog.destroy()
          if first then
              FirstClothesSelected()
          else
             LeaveClothesUI()
             CreateNotification("Clothes", "You selected preset " .. tostring(selected), 5000)
          end
       end
   end)
   okButton.appendTo(dialog)

   local BackButton = UIButton()
   BackButton.setTitle("Back")
   BackButton.onClick(function(obj)
        dialog.destroy()
        ResetAllBody()
        NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
        ClothesUI(first)
    end)
    BackButton.appendTo(dialog)
end

function PutRightBodyMaterial(gender, clothes)
    local mat_slot = Clothing_bodies[gender][clothes.ids.body].body_mask_slot
    if gender == "male" then
      if (not clothes.ids.torso and not clothes.ids.pants and not clothes.ids.shoes) then
         clothes.clothes.body[5] = {Body_materials[gender].full, mat_slot}
      elseif (clothes.ids.torso and clothes.ids.pants and clothes.ids.shoes and Clothing_pants[gender][clothes.ids.pants][2] and Clothing_torso[gender][clothes.ids.torso][2]) then
         clothes.clothes.body[5] = {Body_materials[gender].noshoeslegstorso, mat_slot}
      elseif (clothes.ids.pants and clothes.ids.shoes and Clothing_pants[gender][clothes.ids.pants][2]) then
         clothes.clothes.body[5] = {Body_materials[gender].noshoeslegs, mat_slot}
      elseif (clothes.ids.torso and Clothing_torso[gender][clothes.ids.torso][2] and clothes.ids.pants) then
         clothes.clothes.body[5] = {Body_materials[gender].notorso, mat_slot}
      elseif (clothes.ids.pants and Clothing_pants[gender][clothes.ids.pants][2]) then
         clothes.clothes.body[5] = {Body_materials[gender].nolegs, mat_slot}
      elseif (clothes.ids.shoes) then
         clothes.clothes.body[5] = {Body_materials[gender].noshoes, mat_slot}
      else
         clothes.clothes.body[5] = {Body_materials[gender].full, mat_slot}
      end
   elseif gender == "female" then
      if (not clothes.ids.torso and not clothes.ids.pants and not clothes.ids.shoes) then
         clothes.clothes.body[5] = {Body_materials[gender].full, mat_slot}
      elseif (clothes.ids.torso and clothes.ids.pants and clothes.ids.shoes and Clothing_pants[gender][clothes.ids.pants][2]) then
         clothes.clothes.body[5] = {Body_materials[gender].noshoeslegstorso, mat_slot}
      elseif (clothes.ids.pants and clothes.ids.shoes and Clothing_pants[gender][clothes.ids.pants][2]) then
         clothes.clothes.body[5] = {Body_materials[gender].noshoeslegs, mat_slot}
      elseif (clothes.ids.pants and Clothing_pants[gender][clothes.ids.pants][2] and clothes.ids.torso) then
         clothes.clothes.body[5] = {Body_materials[gender].nolegs, mat_slot}
      else
         clothes.clothes.body[5] = {Body_materials[gender].full, mat_slot}
      end
   end
   --AddPlayerChat(tostring(clothes.clothes.body[5][1]))
end

function CreateAdvancedCreationPart(dialog, gender, part, table_part, clothes, dialog2, first, c_path)
   local append_dialog = dialog
   if (part == "Jacket" or part == "Pants" or part == "Shoes") then
       append_dialog = dialog2
   end

   local Part_text = UIText()
   Part_text.setContent(part .. " : ")
   Part_text.appendTo(append_dialog)

   local PartList = UIOptionList()
   for i, v in ipairs(table_part[gender]) do
      PartList.appendOption(i-1, i)
   end
   PartList.appendTo(append_dialog)
   local selected = nil
   PartList.onChange(function(obj)
      if not c_path then
         selected = table_part[gender][obj.getValue()[1]+1]
      else
         selected = table_part[gender][obj.getValue()[1]+1][c_path]
      end
      if part == "Body" then
         clothes.clothes.body = {selected, false, false, false, false}
         clothes.ids.body = obj.getValue()[1]+1
         if table_part[gender][obj.getValue()[1]+1].hair then
             if type(Advanced_creation_parts["Hair"]) == "table" then
                 Advanced_creation_parts["Hair"].text.destroy()
                 Advanced_creation_parts["Hair"].list.destroy()
                 Advanced_creation_parts["Hair"].r_button.destroy()
                 Advanced_creation_parts["Hair"] = nil
                 if clothes.clothes.clothing0 then
                     clothes.clothes.clothing0 = {nil}
                     clothes.ids.hair = nil
                 end
             end
         elseif type(Advanced_creation_parts["Hair"]) ~= "table" then
             CreateAllAdvancedCreationParts(dialog, gender, clothes, first, dialog2)
         end
         if first then
            SetCameraLocation(123222, 168257, 3164, true)
            SetCameraRotation(0, 168, 0, true)
            z_added_cam = 50
         end
      elseif part == "Hair" then
         clothes.clothes.clothing0 = {selected}
         clothes.ids.hair = obj.getValue()[1]+1
         if first then
            SetCameraLocation(123222, 168257, 3194, true)
            SetCameraRotation(0, 168, 0, true)
            z_added_cam = 80
         end
      elseif part == "Torso" then
         clothes.clothes.clothing1 = {selected}
         clothes.ids.torso = obj.getValue()[1]+1
         if table_part[gender][obj.getValue()[1]+1][2] then
            if type(Advanced_creation_parts["Jacket"]) == "table" then
                Advanced_creation_parts["Jacket"].text.destroy()
                Advanced_creation_parts["Jacket"].list.destroy()
                Advanced_creation_parts["Jacket"].r_button.destroy()
                Advanced_creation_parts["Jacket"] = nil
                if clothes.clothes.clothing2 then
                    clothes.clothes.clothing2 = {nil}
                    clothes.ids.jacket = nil
                end
            end
         elseif type(Advanced_creation_parts["Jacket"]) ~= "table" then
             CreateAllAdvancedCreationParts(dialog, gender, clothes, first, dialog2)
         end
         if first then
            SetCameraLocation(123222, 168257, 3164, true)
            SetCameraRotation(0, 168, 0, true)
            z_added_cam = 50
         end
      elseif part == "Jacket" then
         clothes.clothes.clothing2 = {selected}
         clothes.ids.jacket = obj.getValue()[1]+1
         if first then
            SetCameraLocation(123222, 168257, 3164, true)
            SetCameraRotation(0, 168, 0, true)
            z_added_cam = 50
         end
      elseif part == "Pants" then
         clothes.clothes.clothing3 = {selected}
         clothes.ids.pants = obj.getValue()[1]+1
         if first then
            SetCameraLocation(123222, 168257, 3124, true)
            SetCameraRotation(0, 168, 0, true)
            z_added_cam = 10
         end
      elseif part == "Shoes" then
         clothes.clothes.clothing4 = {selected}
         clothes.ids.shoes = obj.getValue()[1]+1
         if first then
            SetCameraLocation(123222, 168257, 3074, true)
            SetCameraRotation(0, 168, 0, true)
            z_added_cam = -40
         end
      end
      PutRightBodyMaterial(gender, clothes)
      NSetClothes(GetPlayerId(), clothes)
   end)

   local RemoveButton
   if part ~= "Body" then
      RemoveButton = UIButton()
      RemoveButton.setTitle("Remove " .. part)
      RemoveButton.onClick(function(obj)
         local changed
         if part == "Hair" then
            if clothes.ids.hair then
               clothes.clothes.clothing0 = {nil}
               clothes.ids.hair = nil
               changed = true
            end
         elseif part == "Torso" then
            if clothes.ids.torso then
               if table_part[gender][clothes.ids.torso][2] then
                  if type(Advanced_creation_parts["Jacket"]) ~= "table" then
                     CreateAllAdvancedCreationParts(dialog, gender, clothes, first, dialog2)
                  end
               end
               clothes.clothes.clothing1 = {nil}
               clothes.ids.torso = nil
               changed = true
            end
         elseif part == "Jacket" then
            if clothes.ids.jacket then
               clothes.clothes.clothing2 = {nil}
               clothes.ids.jacket = nil
               changed = true
            end
         elseif part == "Pants" then
            if clothes.ids.pants then
               clothes.clothes.clothing3 = {nil}
               clothes.ids.pants = nil
               changed = true
            end
         elseif part == "Shoes" then
            if clothes.ids.shoes then
               clothes.clothes.clothing4 = {nil}
               clothes.ids.shoes = nil
               changed = true
            end
         end
         if changed then
            PutRightBodyMaterial(gender, clothes)
            NSetClothes(GetPlayerId(), clothes)
         end
      end)
      RemoveButton.appendTo(append_dialog)
   end

   Advanced_creation_parts[part] = {text = Part_text, list = PartList, r_button = RemoveButton}
   return Part_text, PartList
end

function CreateAllAdvancedCreationParts(dialog, gender, clothes, first, dialog2)
   for k, v in pairs(Advanced_creation_parts) do
       if v.text then
         v.text.destroy()
         v.list.destroy()
         if v.r_button then
            v.r_button.destroy()
         end
      end
   end
   if Advanced_creation_parts.ok_b then
      Advanced_creation_parts.ok_b.destroy()
   end
   if Advanced_creation_parts.back_b then
      Advanced_creation_parts.back_b.destroy()
   end
   Advanced_creation_parts = {}
   local BodyText, BodyList = CreateAdvancedCreationPart(dialog, gender, "Body", Clothing_bodies, clothes, dialog2, first, "path")
   local good_hair = true
   if clothes.ids.body then
      if Clothing_bodies[gender][clothes.ids.body].hair then
          good_hair = false
      end
   end
   if good_hair then
      local HairText, HairList = CreateAdvancedCreationPart(dialog, gender, "Hair", Clothing_hairs, clothes, dialog2, first)
   end
   local TorsoText, TorsoList = CreateAdvancedCreationPart(dialog, gender, "Torso", Clothing_torso, clothes, dialog2, first, 1)
   local good_jacket = true
   if clothes.ids.torso then
       if Clothing_torso[gender][clothes.ids.torso][2] then
           good_jacket = false
       end
   end
   if good_jacket then
      local JacketText, JacketList = CreateAdvancedCreationPart(dialog, gender, "Jacket", Clothing_jackets, clothes, dialog2, first)
   end
   local PantsText, PantsText = CreateAdvancedCreationPart(dialog, gender, "Pants", Clothing_pants, clothes, dialog2, first, 1)
   local ShoesText, ShoesText = CreateAdvancedCreationPart(dialog, gender, "Shoes", Clothing_shoes, clothes, dialog2, first)

   local okButton = UIButton()
   if first then
      okButton.setTitle("Select")
   else
      okButton.setTitle("Select (" .. tostring(clothing_store_price) .. "$)")
   end
   okButton.onClick(function(obj)
      --AddPlayerChat(json_encode(clothes))
      CallRemoteEvent("ClothesSelected", clothes, not first)
      dialog.destroy()
      dialog2.destroy()
      if first then
          FirstClothesSelected()
      else
          LeaveClothesUI()
          CreateNotification("Clothes", "You selected your clothes", 5000)
      end
   end)
   okButton.appendTo(dialog2)
   Advanced_creation_parts.ok_b = okButton

   local BackButton = UIButton()
   BackButton.setTitle("Back")
   BackButton.onClick(function(obj)
        dialog.destroy()
        dialog2.destroy()
        ResetAllBody()
        NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
        if gender == "male" then
            AdvancedMaleUI(first)
        else
            AdvancedFemaleUI(first)
        end
    end)
    BackButton.appendTo(dialog2)
    Advanced_creation_parts.back_b = BackButton
end

function AdvancedCreationUI(first, gender)
   local ScreenX, ScreenY = GetScreenSize()
   local dialogPosition = UICSS()
   dialogPosition.top = "10px"
   dialogPosition.left = math.floor((ScreenX - 1800) / 2) .. "px !important"
   dialogPosition.width = "600px"

   local dialog = UIDialog()
   local dialog2 = UIDialog()
   dialog.setTitle("Clothes Selection")
   dialog.appendTo(UIFramework)
   dialog.setCSS(dialogPosition)
   dialog2.setTitle("Clothes Selection")
   dialog2.appendTo(UIFramework)

   dialogPosition.left = math.floor((ScreenX + 600) / 2) .. "px !important"

   dialog2.setCSS(dialogPosition)
   if first then
      dialog.setCanClose(false)
      dialog2.setCanClose(false)
   else
       dialog.onClickClose(function(obj)
          dialog.destroy()
          dialog2.destroy()
          LeaveClothesUI()
          ResetAllBody()
          NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
       end)
       dialog2.onClickClose(function(obj)
         dialog.destroy()
         dialog2.destroy()
         LeaveClothesUI()
         ResetAllBody()
         NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
      end)
   end
   local c_text = UIText()
   c_text.setContent("Use right and left keys to rotate")
   c_text.appendTo(dialog)

   Advanced_creation_parts = {}
   local clothes = {
         type = "custom",
         clothes = {
            body = {Clothing_bodies[gender][1].path, false, false, false, false},
            clothing0 = false,
            clothing1 = false,
            clothing2 = false,
            clothing3 = false,
            clothing4 = false,
            clothing5 = false,
            clothing6 = false,
            clothing7 = false,
            clothing8 = false,
            clothing9 = false,
         },
         ids = {
            body = 1
         },
         gender = gender
      }
   ResetAllBody()
   NSetClothes(GetPlayerId(), clothes)
   
   CreateAllAdvancedCreationParts(dialog, gender, clothes, first, dialog2)
end

function AdvancedClothingPresetsUI(first, gender)
   local ScreenX, ScreenY = GetScreenSize()
   local dialogPosition = UICSS()
   dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
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
          ResetAllBody()
          NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
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
   for i, v in ipairs(Advanced_clothing_presets[gender]) do
      ClothesList.appendOption(i-1, tostring(i))
   end
   ClothesList.appendTo(dialog)
   local selected = nil
   ClothesList.onChange(function(obj)
      selected = Advanced_clothing_presets[gender][obj.getValue()[1]+1]
      selected.type = "custom"
      ResetAllBody()
      NSetClothes(GetPlayerId(), selected)
   end)

   local okButton = UIButton()
   if first then
      okButton.setTitle("Select")
   else
      okButton.setTitle("Select (" .. tostring(clothing_store_price) .. "$)")
   end
   okButton.onClick(function(obj)
       if selected then
          CallRemoteEvent("ClothesSelected", {type = "advanced_preset", clothes = selected.clothes, gender = gender}, not first)
          dialog.destroy()
          if first then
              FirstClothesSelected()
          else
             LeaveClothesUI()
             CreateNotification("Clothes", "You selected an advanced preset", 5000)
          end
       end
   end)
   okButton.appendTo(dialog)

   local BackButton = UIButton()
   BackButton.setTitle("Back")
   BackButton.onClick(function(obj)
        dialog.destroy()
        ResetAllBody()
        NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
        AdvancedMaleUI(first)
   end)
   BackButton.appendTo(dialog)
end

function AdvancedMaleUI(first)
   local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
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
            ResetAllBody()
            NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
        end)
    end

    if table_count(Advanced_clothing_presets.male) > 0 then
      local AdvancedClothingPresetButton = UIButton()
      AdvancedClothingPresetButton.setTitle("Advanced Male Clothing Presets")
      AdvancedClothingPresetButton.onClick(function(obj)
         dialog.destroy()
         AdvancedClothingPresetsUI(first, "male")
      end)
      AdvancedClothingPresetButton.appendTo(dialog)
   end

   local AdvancedClothingPresetButton = UIButton()
   AdvancedClothingPresetButton.setTitle("Advanced Male Creation")
   AdvancedClothingPresetButton.onClick(function(obj)
       dialog.destroy()
       AdvancedCreationUI(first, "male")
   end)
   AdvancedClothingPresetButton.appendTo(dialog)

   local BackButton = UIButton()
   BackButton.setTitle("Back")
   BackButton.onClick(function(obj)
        dialog.destroy()
        ClothesUI(first)
   end)
   BackButton.appendTo(dialog)
end

function AdvancedFemaleUI(first)
   local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
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
            ResetAllBody()
            NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
        end)
    end

    if table_count(Advanced_clothing_presets.female) > 0 then
      local AdvancedClothingPresetButton = UIButton()
      AdvancedClothingPresetButton.setTitle("Advanced Female Clothing Presets")
      AdvancedClothingPresetButton.onClick(function(obj)
         dialog.destroy()
         AdvancedClothingPresetsUI(first, "female")
      end)
      AdvancedClothingPresetButton.appendTo(dialog)
   end

   local AdvancedClothingPresetButton = UIButton()
   AdvancedClothingPresetButton.setTitle("Advanced Female Creation")
   AdvancedClothingPresetButton.onClick(function(obj)
       dialog.destroy()
       AdvancedCreationUI(first, "female")
   end)
   AdvancedClothingPresetButton.appendTo(dialog)

   local BackButton = UIButton()
   BackButton.setTitle("Back")
   BackButton.onClick(function(obj)
        dialog.destroy()
        ClothesUI(first)
   end)
   BackButton.appendTo(dialog)
end

function ClothesUI(first)
   local ScreenX, ScreenY = GetScreenSize()
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
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
            ResetAllBody()
            NSetClothes(GetPlayerId(), GetPlayerPropertyValue(GetPlayerId(),"NetworkedClothes"))
        end)
    end

    local ClothingPresetButton = UIButton()
    ClothingPresetButton.setTitle("Clothing Presets")
    ClothingPresetButton.onClick(function(obj)
        dialog.destroy()
        ClothesUIPreset(first)
    end)
    ClothingPresetButton.appendTo(dialog)

    local AdvancedMaleButton = UIButton()
    AdvancedMaleButton.setTitle("Advanced (male)")
    AdvancedMaleButton.onClick(function(obj)
        dialog.destroy()
        AdvancedMaleUI(first)
    end)
    AdvancedMaleButton.appendTo(dialog)

    local AdvancedMaleButton = UIButton()
    AdvancedMaleButton.setTitle("Advanced (female)")
    AdvancedMaleButton.onClick(function(obj)
        dialog.destroy()
        AdvancedFemaleUI(first)
    end)
    AdvancedMaleButton.appendTo(dialog)
    
    if first then
       SetCameraLocation(123222, 168257, 3164, true)
       SetCameraRotation(0, 168, 0, true)
       IsInClothesUIFIRST = true
       z_added_cam = 50
    end
    if not IsInClothesUI then
      IsInClothesUI = true
      ShowMouseCursor(true)
      SetIgnoreMoveInput(true)
      SetIgnoreLookInput(true)
      SetInputMode(input_while_in_ui)
    end
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
   SetCameraLocation(x + fx * mult, y + fy * mult, z + z_added_cam + fz * mult, true)
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

