Config = {}

-- Framework: "SEM" | "ESX" | "QBCore"
Config.Framework = "SEM"

-- How often to update Discord (seconds)
Config.UpdateInterval = 60

-- Discord channel IDs
Config.Discord = {
    LEOChannelId  = "YOUR_LEO_CHANNEL_ID",   -- Voice or Text channel for LEO count
    FireChannelId = "YOUR_FIRE_CHANNEL_ID",  -- Voice or Text channel for Fire count
    BotToken      = "YOUR_BOT_TOKEN"         -- Bot must have Manage Channels permission
}

-- Channel name formats
Config.LEOChannelName  = "👮 LEO: %d"
Config.FireChannelName = "🚒 Fire: %d"

-- ESX job names for LEO / Fire
Config.ESXJobs = {
    LEO  = { "police", "sheriff", "state" },
    Fire = { "fire", "ambulance", "ems" }
}

-- QBCore job names for LEO / Fire
Config.QBJobs = {
    LEO  = { "police", "bcso", "sast" },
    Fire = { "ambulance", "fire" }
}