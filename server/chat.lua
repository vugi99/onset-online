

AddEvent("OnPlayerChat", function(ply, text)
    local dim = GetPlayerDimension(ply)
    for i, v in ipairs(GetDimensionPlayers(dim)) do
       AddPlayerChat(v, GetPlayerName(ply) .. " [" .. tostring(ply) .. "] (Dimension " .. tostring(dim) .. ") : " .. text)
    end
	return false
end)