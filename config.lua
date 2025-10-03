Config = {}

-- How often to update Discord (seconds)
Config.UpdateInterval = 60

-- Discord channel IDs
Config.Discord = {
    LEOChannelId  = "YOUR_LEO_CHANNEL_ID",   -- Channel for LEO duty count (I prefer voice channel)
    FireChannelId = "YOUR_FIRE_CHANNEL_ID",  -- Channel for Fire duty count (I prefer voice channel)
    BotToken      = "YOUR_BOT_TOKEN"         -- Bot must have Manage Channels permission
}

-- Channel name formats
Config.LEOChannelName  = "👮 LEO: %d"
Config.FireChannelName = "🚒 Fire: %d"
