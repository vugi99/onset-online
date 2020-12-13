
local online_version = nil

AddEvent("OnPackageStart", function()
    local file = io.open("packages/" .. GetPackageName() .. "/package.json", 'r') 
    if file then
        local contents = file:read("*a")
        local PackageTable = json_decode(contents)
        io.close(file)
        online_version = PackageTable.version
        print("Online Gamemode " .. online_version .. " loaded.")
    end
end)

AddEvent("OnPlayerJoin", function(ply)
    CallRemoteEvent(ply, "SendOnlineVersion", online_version)
end)