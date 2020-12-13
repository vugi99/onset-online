

online_playtime = nil
playtime_textbox = nil

function ConvertPlayTimeToString()
   local days = math.floor(online_playtime / 86400)
   local hours = math.floor((online_playtime - (days * 86400)) / 3600)
   local minutes = math.floor((online_playtime - (days * 86400) - (hours * 3600)) / 60)
   local seconds = online_playtime - (days * 86400) - (hours * 3600) - (minutes * 60)
   return "Playtime : " .. tostring(days) .. " days, " .. tostring(hours) .. " hours, " .. tostring(minutes) .. " mins, " .. tostring(seconds) .. " s."
end

function update_playtime()
   online_playtime = online_playtime + 1
   if _playtime_text then
      _playtime_text.setContent(ConvertPlayTimeToString())
      _playtime_text.update()
   end
end

AddRemoteEvent("InitPlaytime", function(plt)
   online_playtime = plt
   CreateTimer(update_playtime, 1000)
end)