if Config.Framework == "SEM" then
    -- SEM uses client exports, so clients must report status
    CreateThread(function()
        while true do
            local isLEO = exports['SEM_InteractionMenu']:IsOndutyLEO()
            local isFire = exports['SEM_InteractionMenu']:IsOndutyFire()
            TriggerServerEvent("dutySync:updateStatus", isLEO, isFire)
            Wait(5000) -- send every 5 seconds
        end
    end)
end