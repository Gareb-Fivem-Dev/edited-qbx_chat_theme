-- Resource: staffchat
-- Author: ChatGPT
-- Staff-only chat with console + Discord logging (Config support)

local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config or {}

-- Resolve character name from QBCore (DB-backed)
local function getCharacterName(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local ci = Player.PlayerData.charinfo
        local first = ci.firstname or ci.first
        local last  = ci.lastname or ci.last
        if first and last then
            return ("%s %s"):format(first, last)
        end
    end
    return GetPlayerName(src)
end

-- Check if player is staff
local function isStaff(src)
    -- Check ACE permissions for staff chat
    if IsPlayerAceAllowed(src, "qbx_chat_theme.staff") then
        return true
    end
    
    -- Check individual group permissions as fallback
    if type(Config.StaffGroups) == "table" then
        for _, group in ipairs(Config.StaffGroups) do
            if IsPlayerAceAllowed(src, group) then
                return true
            end
        end
    end
    
    return false
end

-- Send message to Discord webhook
local function sendToDiscord(name, srcId, cid, msg)
    if not Config.LogToDiscord or not Config.DiscordWebhook or Config.DiscordWebhook == "" then return end

    local embed = {
        {
            ["title"] = ("From %s | ID: %s | CID: %s"):format(name, srcId, cid),
            ["description"] = msg,
            ["color"] = Config.DiscordColor or 16711935,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, "POST", json.encode({
        username = "Staff Chat",
        embeds = embed
    }), {["Content-Type"] = "application/json"})
end


-- Track recent messages to prevent duplicates
local recentMessages = {}
local messageTimeout = 2000 -- 2 seconds

-- Function to handle sending messages
local function sendStaffMessage(source, args)
    if source == 0 then
        print("^5[STAFF CHAT]^7 This command cannot be used from console.")
        return
    end

    if not isStaff(source) then
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"StaffChat", "You do not have permission to use this command."}
        })
        return
    end

    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"StaffChat", "Usage: /staffchat <message>"}
        })
        return
    end

    -- Use character name instead of Rockstar name
    local name = getCharacterName(source)
    local srcId = tostring(source)
    local messageKey = srcId .. ":" .. msg
    local currentTime = GetGameTimer()
    -- Pull citizenid (CID) for Discord logging
    local Player = QBCore.Functions.GetPlayer(source)
    local cid = (Player and Player.PlayerData and Player.PlayerData.citizenid) and tostring(Player.PlayerData.citizenid) or "N/A"

    -- Check for duplicate message from same player
    if recentMessages[messageKey] and (currentTime - recentMessages[messageKey]) < messageTimeout then
        print("^3[STAFF CHAT]^7 Duplicate message blocked from " .. name)
        return
    end

    -- Store message timestamp
    recentMessages[messageKey] = currentTime

    -- Clean old messages (older than timeout)
    for key, timestamp in pairs(recentMessages) do
        if (currentTime - timestamp) > messageTimeout then
            recentMessages[key] = nil
        end
    end

    -- Send to all staff in-game with unique identifier
    for _, id in pairs(GetPlayers()) do
        local playerId = tonumber(id)
        if playerId and isStaff(playerId) then
            TriggerClientEvent("chat:addMessage", playerId, {
                color = {255, 100, 255},
                multiline = true,
                args = {"STAFF | " .. name, msg}
            })
        end
    end



    -- Send to Discord
    sendToDiscord(name, srcId, cid, msg)
end

-- Register only unique commands to avoid conflicts with other chat resources
RegisterCommand("staffchat", function(source, args, rawCommand)
    sendStaffMessage(source, args)
end, false)

RegisterCommand("sc", function(source, args, rawCommand)
    sendStaffMessage(source, args)
end, false)
