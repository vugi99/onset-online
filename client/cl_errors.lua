

AddEvent("OnScriptError",function(message)
    AddPlayerChat("Error : " .. message .. " sent to the server.")
    CallRemoteEvent("ReceiveClientError", message)
end)