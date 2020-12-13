
online_version = nil

AddRemoteEvent("SendOnlineVersion", function(ver)
    AddPlayerChat("Online Gamemode " .. tostring(ver))
    online_version = ver
end)