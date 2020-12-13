

AddRemoteEvent("ReceiveClientError",function(ply, message)
    if IsValidPlayer(ply) then
        print("Error for " .. GetPlayerName(ply) .. " (id " .. ply .. ") " .. message)
    else
        print("Error from client " .. message)
    end
end)