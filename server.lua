local dutyStatus = {} -- stores status per playerId

-- Receive updates from clients
RegisterNetEvent("dutySync:updateStatus", function(isLEO, isFire)
    local src = source
    dutyStatus[src] = { LEO = isLEO, Fire = isFire }
end)

-- Cleanup on disconnect
AddEventHandler("playerDropped", function()
    dutyStatus[source] = nil
end)

-- Count who’s on duty
local function CountDuty()
    local leo, fire = 0, 0
    for _, status in pairs(dutyStatus) do
        if status.LEO then leo = leo + 1 end
        if status.Fire then fire = fire + 1 end
    end
    return leo, fire
end

-- Update Discord channel name
local function UpdateChannel(channelId, newName)
    PerformHttpRequest(
        ("https://discord.com/api/v10/channels/%s"):format(channelId),
        function(err, text, headers)
            if err == 200 then
                print(("[DutySync] ✅ Updated %s to: %s"):format(channelId, newName))
            else
                print(("[DutySync] ❌ Failed to update %s (%s): %s"):format(channelId, err, text))
            end
        end,
        "PATCH",
        json.encode({ name = newName }),
        {
            ["Authorization"] = "Bot " .. Config.Discord.BotToken,
            ["Content-Type"] = "application/json"
        }
    )
end

-- Main loop
CreateThread(function()
    while true do
        local leo, fire = CountDuty()
        UpdateChannel(Config.Discord.LEOChannelId,  string.format(Config.LEOChannelName, leo))
        UpdateChannel(Config.Discord.FireChannelId, string.format(Config.FireChannelName, fire))
        Wait(Config.UpdateInterval * 1000)
    end
end)
