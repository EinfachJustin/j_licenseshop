Config = {}

-- Discord (Trage hier in deiner lokalen `config.lua` eine echte Webhook-URL ein)
Config.DiscordWebhook = "https://discord.com/api/webhooks/REPLACE_WITH_YOUR_WEBHOOK" -- Discord Webhook URL (platzhalter)
Config.ServerName = "Dein Server Name" -- Name deines Servers
Config.BotName = "Lizenz System" -- Name des Discord Bots
Config.BotAvatar = "https://i.imgur.com/example.png" -- Avatar URL des Bots (optional)

-- Position
Config.MenuPosition = vector3(181.1856, -339.2707, 44.0727) -- LSPD Position (anpassbar)
Config.MenuDistance = 2.0 -- Interaktionsdistanz
Config.MenuKey = 'E' -- Taste zum Öffnen des Menüs

-- Marker auf dem Boden
Config.Marker = {
    Enabled = true,
    Type = 27, -- Marker Typ
    Color = { r = 0, g = 123, b = 255, a = 100 }, -- Blau mit Transparenz
    Size = { x = 1.5, y = 1.5, z = 1.0 } -- Größe des Markers
}

-- Jobs
Config.PoliceJobs = {
    'police',
    'lspd'
}

-- Lizenzen
Config.Licenses = {
    { Type = "weapon", Label = "Waffenschein" },
    { Type = "drive", Label = "Führerschein" },
    { Type = "drive_bike", Label = "Motorradschein" },
    { Type = "drive_truck", Label = "LKW-Führerschein" }
}
