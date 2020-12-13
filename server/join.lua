

local function OnPlayerJoin(player)
	AddPlayerChatAll("server : " .. GetPlayerName(player)..' ('..tostring(player)..') joined the server')
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

local function OnPlayerQuit(player)
	AddPlayerChatAll("server : " .. GetPlayerName(player)..' ('..tostring(player)..') left the server')
end
AddEvent("OnPlayerQuit", OnPlayerQuit)