Config = {}
RollDice = {}

RollDice.UseCommand = true --Use command or not.
RollDice.ChatCommand = "roll" --Command name.
RollDice.ChatPrefix = "SYSTEM" --This is the chat prefix. If they type a wrong number or invalid one then it will say that SYSTEM has messaged them, just try it.
RollDice.ChatTemplate = "error" --YOU SHOULD CHANGE THIS HERE. I don't really know what chat themes you got so change it. We made our own ones, like error, warning, etc. You can find out what themes you got by checking inside the chat resource in index.css

RollDice.MaxDices = 2 -- Max amount of dices you can roll at one instance. Default is 2.
RollDice.MaxSides = 20 -- Max amount of sides on a dice. Default is 6.
RollDice.MaxDistance = 7.0 -- Distance players can see the rolldice in 3d text.
RollDice.ShowTime = 7 -- Time in seconds on how long the players can see the RollDice.
RollDice.Offset = 1.2 --Changes the z axis of the 3d text displayed.



Config.CoordsX = 0
Config.CoordsY = 0
Config.CoordsZ = 1.1 -- to up and down text
Config.MaxLength = 112 -- max characters in a /me
Config.Duration = 6400  -- 6.4 second


-- Enable OOC Chat, if false all options below won't take effect
Config.EnableChatOOC = true -- Default: true

-- Prefix and color
Config.Prefix = 'OOC | ' -- Default: 'OOC | '
-- Prefix for anonymous OOC (/ooca)
Config.PrefixOOCA = 'OOCA | ' -- Default: 'OOCA | '
Config.PrefixColor = { 0, 0, 255} -- Default: { 0, 0, 255}

-- Change chat distance or make it global
Config.ChatDistance = 20.0 -- Default: 20.0
Config.EnableGlobalOOC = false -- Default: false

-- Staff groups allowed to use staff chat (ACE permissions from permissions.cfg)
Config.StaffGroups = {
    "group.admin",
    "group.mod",
    "group.support"
}

-- Logging options
Config.LogToDiscord = true    -- true = log staff chat to Discord webhook

-- Discord webhook for staff chat logging
Config.DiscordWebhook = "Change ME"

-- Discord embed color (decimal, not hex)
Config.DiscordColor = 16711935 -- purple