
local LevelTextBox = nil
local XpTextBox = nil
local Xp = nil
local XpForNextLevel = nil

PlayerLevel = nil

function GetXpRequiredForNextLevel(Level)
   return (xp_base+xp_added_level*(Level-1))
end

AddRemoteEvent("UpdateLevel",function(level, xp)
    PlayerLevel = level
    Xp = xp
    XpForNextLevel = GetXpRequiredForNextLevel(level)
    if LevelTextBox then
       DestroyTextBox(LevelTextBox)
    end
    if XpTextBox then
       DestroyTextBox(XpTextBox)
    end
    local ScreenX, ScreenY = GetScreenSize()
    LevelTextBox = CreateTextBox(ScreenX/2-math.floor(string.len("Level " .. tostring(level))*9), 5, "Level " .. tostring(level))
    XpTextBox = CreateTextBox(ScreenX/2-math.floor(string.len(tostring(Xp) .. " / " .. tostring(XpForNextLevel))*9), 20,  tostring(Xp) .. " / " .. tostring(XpForNextLevel))
end)