local dutyStatus = {} -- stores client duty reports (for SEM framework)

-- Framework bootstraps
local ESX, QBCore = nil, nil

if Config.Framework == "ESX" then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.Framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- When SEM framework: receive client updates
RegisterNetEvent("dutySync:updateStatus", function(isLEO, isFire)
    if Config.Framework ~= "SEM" then return end
    local src = source
    dutyStatus[src] = { LEO = isLEO, Fire = isFire }
end)

-- Cleanup on disconnect
AddEventHandler("playerDropped", function()
    dutyStatus[source] = nil
end)

-- Count who’s on duty depending on framework
local function CountDuty()
    local leo, fire = 0, 0

    if Config.Framework == "SEM" then
        -- use client-reported states
        for _, status in pairs(dutyStatus) do
            if status.LEO then leo = leo + 1 end
            if status.Fire then fire = fire + 1 end
        end

    elseif Config.Framework == "ESX" and ESX then
        for _, playerId in ipairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                local job = xPlayer.job.name
                for _, name in ipairs(Config.ESXJobs.LEO) do
                    if job == name then leo = leo + 1 end
                end
                for _, name in ipairs(Config.ESXJobs.Fire) do
                    if job == name then fire = fire + 1 end
                end
            end
        end

    elseif Config.Framework == "QBCore" and QBCore then
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local player = QBCore.Functions.GetPlayer(playerId)
            if player then
                local job = player.PlayerData.job.name
                for _, name in ipairs(Config.QBJobs.LEO) do
                    if job == name then leo = leo + 1 end
                end
                for _, name in ipairs(Config.QBJobs.Fire) do
                    if job == name then fire = fire + 1 end
                end
            end
        end
    end

    return leo, fire
end

-- Update a Discord channel’s name
local function UpdateChannel(channelId, newName)
    PerformHttpRequest(
        ("https://discord.com/api/v10/channels/%s"):format(channelId),
        function(err, text, headers)
            if err == 200 then
                print(("[DutySync] ✅ Updated %s → %s"):format(channelId, newName))
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

-- Main update loop
CreateThread(function()
    while true do
        local leo, fire = CountDuty()
        UpdateChannel(Config.Discord.LEOChannelId,  string.format(Config.LEOChannelName, leo))
        UpdateChannel(Config.Discord.FireChannelId, string.format(Config.FireChannelName, fire))
        Wait(Config.UpdateInterval * 1000)
    end
end)