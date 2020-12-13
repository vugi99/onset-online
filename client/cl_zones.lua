

AddEvent("OnObjectStreamIn", function(obj)
    if GetObjectPropertyValue(obj, "_Zone") then
        GetObjectActor(obj):SetActorEnableCollision(false)
    end
end)