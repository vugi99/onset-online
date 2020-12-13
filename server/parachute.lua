

local function Check_Movement_Mode()
    for i, v in ipairs(GetAllPlayers()) do
        local mov_mode = GetPlayerMovementMode(v)
        if (mov_mode == 6 and not GetPlayerPropertyValue(v, "ParachuteAttached")) then
            AttachPlayerParachute(v, true)
            SetPlayerPropertyValue(v, "ParachuteAttached", true, false)
            --AddPlayerChat(v, "Attached_Para")
        elseif ((mov_mode == 0 or mov_mode == 1 or mov_mode == 2 or mov_mode == 3 or mov_mode == 4 or mov_mode == 8) and GetPlayerPropertyValue(v, "ParachuteAttached")) then
            AttachPlayerParachute(v, false)
            SetPlayerPropertyValue(v, "ParachuteAttached", nil, false)
            --AddPlayerChat(v, "Detached_Para")
        end
    end
end

AddEvent("OnPackageStart", function()
    CreateTimer(Check_Movement_Mode, 500)
end)