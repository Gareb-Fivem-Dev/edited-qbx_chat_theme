-- Get QBCore/QBX core
local QBCore = (exports['qb-core'] and exports['qb-core']:GetCoreObject()) or (exports['qbx-core'] and exports['qbx-core']:GetCoreObject()) or nil

-- Helper to get character full name, fallback to Rockstar name
local function getPlayerFullName(src)
	-- Try QBCore
	if QBCore and QBCore.Functions and QBCore.Functions.GetPlayer then
		local Player = QBCore.Functions.GetPlayer(src)
		if Player and Player.PlayerData then
			local ci = Player.PlayerData.charinfo
			if ci and ((ci.firstname and ci.lastname) or (ci.first and ci.last)) then
				local first = ci.firstname or ci.first
				local last = ci.lastname or ci.last
				return string.format("%s %s", first, last)
			end
		end
	end
	-- Fallback
	return GetPlayerName(src)
end

-- Helper to send OOC message to Discord
local function sendToDiscord(name, message, srcId, cid)
    if not Config.LogToDiscord or not Config.DiscordWebhook or Config.DiscordWebhook == "" then return end

    local embed = {
        {
            ["title"] = ("OOC From %s | ID: %s | CID: %s"):format(name, srcId, cid),
            ["description"] = message,
            ["color"] = Config.DiscordColor or 16711935,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, "POST", json.encode({
        username = "OOC",
        embeds = embed
    }), {["Content-Type"] = "application/json"})
end

local function sendToDiscordooca(name, message, srcId, cid)
    if not Config.LogToDiscord or not Config.DiscordWebhook or Config.DiscordWebhook == "" then return end

    local embed = {
        {
            ["title"] = ("OOCA From %s | ID: %s | CID: %s"):format(name, srcId, cid),
            ["description"] = message,
            ["color"] = Config.DiscordColor or 16711935,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, "POST", json.encode({
        username = "OOCA",
        embeds = embed
    }), {["Content-Type"] = "application/json"})
end

AddEventHandler('chatMessage', function(source, name, message)
	if string.sub(message,1,string.len("/"))=="/" then
		-- Do nothing because this is a command
	else
		-- Add here what you want to do when user type in chat
		if Config.EnableChatOOC then
			local src = source
			local srcId = tostring(source)
			-- Get cid from QBCore player (fixes CID: N/A)
			local Player = (QBCore and QBCore.Functions and QBCore.Functions.GetPlayer) and QBCore.Functions.GetPlayer(src) or nil
			local cid = (Player and Player.PlayerData and Player.PlayerData.citizenid) and tostring(Player.PlayerData.citizenid) or "N/A"
			local displayName = getPlayerFullName(src)
			local Players = GetPlayers()
			for k, v in pairs(Players) do
				if Config.EnableGlobalOOC then
					TriggerClientEvent('chat:addMessage', v, {
						color = Config.PrefixColor,
						multiline = true,
						args = {Config.Prefix .. displayName, message}
					})
				elseif v == src then
					TriggerClientEvent('chat:addMessage', v, {
						color = Config.PrefixColor,
						multiline = true,
						args = {Config.Prefix .. displayName, message}
					})
				elseif #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(v))) < Config.ChatDistance then
					TriggerClientEvent('chat:addMessage', v, {
						color = Config.PrefixColor,
						multiline = true,
						args = {Config.Prefix .. displayName, message}
					})
				end
			end
			-- Log once to Discord
			sendToDiscord(displayName, message, srcId, cid)
		end
	end
	CancelEvent()
end)

-- Anonymous OOC (proximity) command
RegisterCommand('ooca', function(source, args, raw)
	local src = source
	if src == 0 then return end

	local msg = table.concat(args or {}, " ")
	if not msg or msg == "" then
		TriggerClientEvent('chat:addMessage', src, {
			color = {255, 0, 0},
			multiline = true,
			args = {"System", "Usage: /ooca <message>"}
		})
		return
	end

	local anonName = "Anonymous"
	-- Choose prefix: OOCA-specific or general OOC
	local prefix = (type(Config.PrefixOOCA) == "string" and Config.PrefixOOCA ~= "" and Config.PrefixOOCA) or (Config.Prefix or "OOC | ")

	local srcPed = GetPlayerPed(src)
	local srcCoords = GetEntityCoords(srcPed)
	local Players = GetPlayers()

	for _, v in pairs(Players) do
		local vNum = tonumber(v) or v
		if vNum == src then
			TriggerClientEvent('chat:addMessage', v, {
				color = Config.PrefixColor,
				multiline = true,
				args = {prefix .. anonName, msg}
			})
		else
			local vPed = GetPlayerPed(v)
			if vPed ~= 0 then
				local vCoords = GetEntityCoords(vPed)
				if #(srcCoords - vCoords) <= (Config.ChatDistance or 20.0) then
					TriggerClientEvent('chat:addMessage', v, {
						color = Config.PrefixColor,
						multiline = true,
						args = {prefix .. anonName, msg}
					})
				end
			end
		end
	end

	-- Discord log (keeps anonymity in display name)
	local Player = (QBCore and QBCore.Functions and QBCore.Functions.GetPlayer) and QBCore.Functions.GetPlayer(src) or nil
	local cid = (Player and Player.PlayerData and Player.PlayerData.citizenid) and tostring(Player.PlayerData.citizenid) or "N/A"
	-- Send full name to Discord
	local realName = getPlayerFullName(src)
	sendToDiscordooca(realName, msg, tostring(src), cid)
end, false)



Citizen.CreateThread(function() --We are using a citizen create thread that will run only 1 time. 
                                --If RollDice.UseCommand is enabled then it will create the command and a sugggestion box for it.
    if(RollDice.UseCommand)then
        RegisterCommand(RollDice.ChatCommand, function(source, args, rawCommand) --Creates the roll command.
            if(args[1] ~= nil and args[2] ~= nil)then --Makes sure you do have both arguments in place.
                local dices = tonumber(args[1]) 
                local sides = tonumber(args[2]) --Converts chat string to number.
                if (sides > 0 and sides <= RollDice.MaxSides) and (dices > 0 and dices <= RollDice.MaxDices) then --Checks if sides and dices are bigger than 0 and smaller than the config values.
                    TriggerEvent("RollDice:Server:Event", source, dices, sides)
                else
                    TriggerClientEvent('chatMessage', source, RollDice.ChatPrefix, RollDice.ChatTemplate, "Invalid amount. Max Dices: " .. RollDice.MaxDices .. ", Max Sides: " .. RollDice.MaxSides)
                end

            else
                TriggerClientEvent('chatMessage', source, RollDice.ChatPrefix, RollDice.ChatTemplate, "Please fill out both arguments, example: /" .. RollDice.ChatCommand .. " <dices> <sides>")
            end

        end, false)
    end

end)

RegisterServerEvent('RollDice:Server:Event')
AddEventHandler('RollDice:Server:Event', function(source, dices, sides) --We are using a trigger event just so you can use this event in other places as well.
                                                                        --I mean if you do want to use the event for a Registerable item. Just call the event and send the source, dices and sides.
                                                                        --Like this: TriggerServerEvent(GetPlayerServerId(PlayerId()), dices, sides)
    local tabler = {}
    for i=1, dices do 
        table.insert(tabler, math.random(1, sides)) --Creates a table with the amount of dices. Randomises the sides eventually.
    end

    TriggerClientEvent("RollDice:Client:Roll", -1, source, RollDice.MaxDistance, tabler, sides, GetEntityCoords(GetPlayerPed(source))) --Does the roll to everyone. It checks client sided if you are within the distance.
end)

RegisterCommand("me", function(source , args, rawCommand)
    local text = table.concat(args, ' ')
    local icon = 'icons' -- Set this to whatever fontawesome icon you like
    text = string.sub(text,1,Config.MaxLength)
    TriggerClientEvent('3dme:me', -1, text, source, icon)
end, false)

RegisterCommand("do", function(source , args, rawCommand)
    local text = table.concat(args, ' ')
    local icon = 'icons' -- Set this to whatever fontawesome icon you like
    text = string.sub(text,1,Config.MaxLength)
    TriggerClientEvent('3dme:do', -1, text, source, icon)
end, false)

RegisterCommand("med", function(source , args, rawCommand)
    local text = table.concat(args, ' ')
    local icon = 'icons' -- Set this to whatever fontawesome icon you like
    text = string.sub(text,1,Config.MaxLength)
    TriggerClientEvent('3dme:med', -1, text, source, icon)
end, false)

RegisterCommand("iconme", function(source , args, rawCommand)
    local icon = args[1] -- Set this to whatever fontawesome icon you like
    table.remove(args,1)
    local text = table.concat(args, ' ')
    print(text)
    text = string.sub(text,1,Config.MaxLength)
    print(text)
    TriggerClientEvent('3dme:me', -1, text, source, icon)
end, false)