-- server.lua
local ESX, QBCore = nil, nil

-- Framework setup
if Config.Framework == "ESX" then
    -- ESX Legacy uses export
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Function to count duty players
local function GetDutyCounts()
    local leoCount, fireCount = 0, 0

    if Config.Framework == "SEM" then
        -- SEM relies on clients sending their onduty status
        for _, playerId in ipairs(GetPlayers()) do
            local isLEO = Player(playerId).state.isOndutyLEO
            local isFire = Player(playerId).state.isOndutyFire
            if isLEO then leoCount = leoCount + 1 end
            if isFire then fireCount = fireCount + 1 end
        end

    elseif Config.Framework == "ESX" then
        -- ESX Legacy job check
        local xPlayers = ESX.GetPlayers()
        for _, playerId in ipairs(xPlayers) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer and xPlayer.job then
                for _, job in ipairs(Config.ESXJobs.LEO) do
                    if xPlayer.job.name == job then
                        leoCount = leoCount + 1
                        break
                    end
                end
                for _, job in ipairs(Config.ESXJobs.Fire) do
                    if xPlayer.job.name == job then
                        fireCount = fireCount + 1
                        break
                    end
                end
            end
        end

    elseif Config.Framework == "QBCore" then
        -- QBCore job check
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData and Player.PlayerData.job then
                local jobName = Player.PlayerData.job.name
                for _, job in ipairs(Config.QBJobs.LEO) do
                    if jobName == job then
                        leoCount = leoCount + 1
                        break
                    end
                end
                for _, job in ipairs(Config.QBJobs.Fire) do
                    if jobName == job then
                        fireCount = fireCount + 1
                        break
                    end
                end
            end
        end
    end

    return leoCount, fireCount
end

-- Update Discord channel names
local function UpdateDiscord()
    local leoCount, fireCount = GetDutyCounts()

    PerformHttpRequest(
        ("https://discord.com/api/v10/channels/%s"):format(Config.Discord.LEOChannelId),
        function(err, text, headers) end,
        "PATCH",
        json.encode({ name = Config.LEOChannelName:format(leoCount) }),
        { ["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. Config.Discord.BotToken }
    )

    PerformHttpRequest(
        ("https://discord.com/api/v10/channels/%s"):format(Config.Discord.FireChannelId),
        function(err, text, headers) end,
        "PATCH",
        json.encode({ name = Config.FireChannelName:format(fireCount) }),
        { ["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. Config.Discord.BotToken }
    )
end

-- Run updater
CreateThread(function()
    while true do
        UpdateDiscord()
        Wait(Config.UpdateInterval * 1000)
    end
end)

-- SEM client sync
RegisterNetEvent("duty-discordsync:updateSEMStatus", function(isLEO, isFire)
    local src = source
    Player(src).state.isOndutyLEO = isLEO
    Player(src).state.isOndutyFire = isFire
end)