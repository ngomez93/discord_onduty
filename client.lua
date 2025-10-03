-- Send duty status to server periodically
CreateThread(function()
    while true do
        local isLEO = exports['SEM_InteractionMenu']:IsOndutyLEO()
        local isFire = exports['SEM_InteractionMenu']:IsOndutyFire()
        TriggerServerEvent("dutySync:updateStatus", isLEO, isFire)
        Wait(5000) -- check every 5 seconds
    end
end)
