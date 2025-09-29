# qbx_chat_theme 
QBox Core may work on Qb-core
> Note: This is an edited version of the original qbx_chat_theme resource.

<img src="https://files.fivemerr.com/images/cf1f399e-14af-45de-8701-220408f384a3.png">


## Requirements
- The default FiveM chat resource (chat) from the CitizenFX cfx-server-data repository must be installed and started before this resource.
  - Repository: https://github.com/citizenfx/cfx-server-data (see resources/[gameplay]/chat)
  - Start order in server.cfg:
    - ensure chat
    - ensure qbx_chat_theme
- TODO (QBX Core): Command toggles (qbx_core/config/shared.lua, around line 6). Set to false if you want this resource to fully handle /me and /ooc.
  ```lua
  -- qbx_core/config/shared.lua (around line 6)
  -- Command toggles
  commands = {
      me = false,  -- Enable/disable the /me commandd
      ooc = false  -- Enable/disable the /ooc command
  }
  ```
- TODO (QBX Core): Wrap the built-in /ooc and /me commands (qbx_core/server/commands.lua) so they only register when enabled:
  ```lua
  -- filepath: qbx_core/server/commands.lua
  if sharedConfig.commands.ooc then
      lib.addCommand('ooc', {
          help = locale('command.ooc.help')
      }, function(source, args)
          local message = table.concat(args, ' ')
          local players = GetPlayers()
          local player = GetPlayer(source)
          if not player then return end

          local playerCoords = GetEntityCoords(GetPlayerPed(source))
          for _, v in pairs(players) do
              if v == source then
                  exports.chat:addMessage(v --[[@as Source]], {
                      color = { 0, 0, 255},
                      multiline = true,
                      args = {('OOC | %s'):format(GetPlayerName(source)), message}
                  })
              elseif #(playerCoords - GetEntityCoords(GetPlayerPed(v))) < 20.0 then
                  exports.chat:addMessage(v --[[@as Source]], {
                      color = { 0, 0, 255},
                      multiline = true,
                      args = {('OOC | %s'):format(GetPlayerName(source)), message}
                  })
              elseif IsPlayerAceAllowed(v --[[@as string]], 'admin') then
                  if IsOptin(v --[[@as Source]]) then
                      exports.chat:addMessage(v--[[@as Source]], {
                          color = { 0, 0, 255},
                          multiline = true,
                          args = {('Proximity OOC | %s'):format(GetPlayerName(source)), message}
                      })
                      logger.log({
                          source = 'qbx_core',
                          webhook  = 'ooc',
                          event = 'OOC',
                          color = 'white',
                          tags = config.logging.role,
                          message = ('**%s** (CitizenID: %s | ID: %s) **Message:** %s'):format(GetPlayerName(source), player.PlayerData.citizenid, source, message)
                      })
                  end
              end
          end
      end)
  end

  if sharedConfig.commands.me then
      lib.addCommand('me', {
          help = locale('command.me.help'),
          params = {
              { name = locale('command.me.params.message.name'), help = locale('command.me.params.message.help'), type = 'string' }
          }
      }, function(source, args)
          args[1] = args[locale('command.me.params.message.name')]
          args[locale('command.me.params.message.name')] = nil
          if #args < 1 then Notify(source, locale('error.missing_args2'), 'error') return end
          local msg = table.concat(args, ' '):gsub('[~<].-[>~]', '')
          local playerState = Player(source).state
          playerState:set('me', msg, true)

          -- We have to reset the playerState since the state does not get replicated on StateBagHandler if the value is the same as the previous one --
          playerState:set('me', nil, true)
      end)
  end
  ```


## What this script does
- Disables global chat messages so normal chat isn’t broadcast server-wide.
- Preserves command usage; messages starting with “/” go to their respective command handlers unchanged.
- Adds automatic OOC chat when you type without a leading “/”.
- Formats OOC with a custom prefix and RGB color.
- Sends OOC locally within a configurable proximity (meters), or globally if enabled.
- Adds a staff-only chat channel (/staff or /sc) visible only to staff.
- Adds local RP chat helpers: /me, /do, and /med[^3dme]. These display styled roleplay/emergency messages to players within ChatDistance.
- Adds a dice roll command (default: /roll)[^dice] that displays 3D text above the roller; syntax: /<ChatCommand> <dices> <sides>. Visibility is controlled by RollDice.MaxDistance and duration by RollDice.ShowTime.
- Lightweight and plug-and-play; designed to coexist with other frameworks/resources.

## Installation
1. Place the resource in: resources/[qbx]/qbx_chat_theme
2. In server.cfg, ensure order (start after the default chat so hooks take effect):
   - ensure chat
   - ensure qbx_chat_theme

## Usage
- Type without “/” to send OOC within range:
  - Example: Hello there → OOC | YourName: Hello there (seen by players within ChatDistance)
- Use commands as normal:
  - Example: /me waves → runs the /me command (not converted to OOC)
- Toggle global OOC if you want all OOC messages to be seen server-wide.
- Use /ooc <message> to explicitly send an OOC message.
- Use /ooca <message> to force a local-area OOC message even when global OOC is enabled.
- Use /me <action> for character actions (local). Example: /me checks pulse
- Use /do <context> for scene/third-person context (local). Example: /do There would be a faint pulse
- Use /med <message> for medical roleplay messages (local). Example: /med Applying bandage
- Roll dice (3D text above the player; visible within RollDice.MaxDistance):
  - Command: /<ChatCommand> <dices> <sides> (default: /roll)
  - Examples:
    - /roll 1 6 → one six-sided die
    - /roll 2 20 → two twenty-sided dice
  - Notes:
    - dices: 1..RollDice.MaxDices (default 2)
    - sides: 2..RollDice.MaxSides (default 20)

## Configuration details
- Config.EnableChatOOC: true to enable the OOC system. If false, only the global chat removal applies.
- Config.Prefix: text placed before OOC messages.
- Config.PrefixOOCA: text placed before local-only anonymous OOC (/ooca) messages.
- Config.PrefixColor: RGB array for the OOC prefix color.
- Config.ChatDistance: radius in meters for OOC visibility when not global.
- Config.EnableGlobalOOC: true to broadcast OOC to everyone (ignores ChatDistance).

- Dice configuration (RollDice.*):
  - UseCommand: enable/disable the chat command trigger.
  - ChatCommand: command name (default in this config: roll).
  - ChatPrefix: prefix used in chat feedback/errors for invalid inputs.
  - ChatTemplate: message template class used for feedback/errors (matches your chat theme).
  - MaxDices: maximum dice per roll (current default: 2).
  - MaxSides: maximum sides per die (current default: 20).
  - MaxDistance: 3D text visibility radius in meters (current default: 7.0).
  - ShowTime: seconds the 3D text is displayed (current default: 7).
  - Offset: Z offset for the 3D text above the player (current default: 1.2).

- 3D emote text (/me, /do, /med) display:
  - Config.CoordsX / Config.CoordsY / Config.CoordsZ: positional offsets for the 3D text (Z controls up/down).
  - Config.MaxLength: maximum characters in a /me (and related).
  - Config.Duration: how long the 3D text is shown (milliseconds).

- Staff chat and logging:
  - Config.StaffGroups: ACE groups allowed to use staff chat (e.g., group.admin, group.mod, group.support).
  - Config.LogToDiscord: enable/disable staff chat logging to Discord.
  - Config.DiscordWebhook: Discord webhook URL used when logging is enabled.
  - Config.DiscordColor: decimal embed color for Discord logs.

## Compatibility and order
- Must start after your chat resource to properly intercept default chat behavior.
- If another resource also handles chatMessage/player text events, disable their OOC/global handling to avoid duplicates.
- Framework-agnostic; works alongside common RP frameworks as long as command handling remains intact.

## Troubleshooting
- Messages are not visible:
  - Verify the resource is started after chat.
  - Check Config.EnableChatOOC and ChatDistance.
  - Ensure no other resource cancels the same chat events first.
- Duplicate OOC messages:
  - Another resource is also formatting/sending OOC. Disable one side’s OOC handling.
- Everyone sees local OOC:
  - Set Config.EnableGlobalOOC = false.

## Commands
- /ooc <message>
  - Sends an OOC message explicitly (same formatting as automatic OOC). Example: /ooc Looking for a mechanic
- /ooca <message>
  - Forces a local-area OOC message even if global OOC is enabled. Example: /ooca Anyone nearby?
- /staffchat <message> or /sc <message>
  - Staff-only chat; only visible to players with staff permissions.
- /me <action>
  - Local roleplay action message shown within ChatDistance. Example: /me kneels down
- /do <context>
  - Local scene/description message shown within ChatDistance. Example: /do The wallet is on the ground
- /med <message>
  - Local medical RP message shown within ChatDistance (optionally restrictable to EMS). Example: /med Starting CPR
- /<ChatCommand> <dices> <sides> (default: /roll)
  - Rolls dice and shows the result as 3D text above the player. Visible within RollDice.MaxDistance for RollDice.ShowTime seconds. Limits: dices ≤ MaxDices, sides ≤ MaxSides. Invalid inputs are rejected with a chat message using ChatPrefix/ChatTemplate.

## Permissions (ACE/Groups)
- If using ACE permissions, allow staff access to staff chat:
  ```
  add_ace group.admin qbx_chat_theme.staff allow
  add_ace group.moderator qbx_chat_theme.staff allow
  add_ace group.support qbx_chat_theme.staff allow
  ```
- Or rely on Config.StaffGroups (group.admin, group.mod, group.support by default) and ensure your admins/mods belong to those groups.
- Optionally restrict /med to EMS (if your /med handler supports it):
  ```
  add_ace group.ems command.med allow
  ```
  Ensure your EMS members are added to group.ems (or adjust group name as needed).

## Examples
- Automatic OOC (local): OOC | John Doe: Anyone at Legion? (visible within ChatDistance)
- Explicit OOC (global on): OOC | Jane Doe: Server restart soon
- Forced local OOC with /ooca (even if global on): OOC | Alex: Need help here!
- Staff: [STAFF] Jane: Handle ticket #123
- ME: John Doe: checks pulse
- DO: There would be a faint pulse
- MED: Jane Doe: Starting CPR
- Dice (1 die): Roll: 4/6 | (Total: 4)
- Dice (2 dice d20): Roll: 3/20 | 17/20 | (Total: 20)

## Notes
- Staff chat visibility
  - Restricted to staff; ensure your permission/group setup grants access to your staff members (e.g., admin/mod groups).
- Security
  - Replace Config.DiscordWebhook with your own webhook and avoid committing secrets to version control.

[^dice]: Dice rolling feature made by SpecialStos/RollDice — https://github.com/SpecialStos/RollDice/tree/main
[^3dme]: /me, /do, and /med commands provided by Nicetyone/3dme-w--html — https://github.com/Nicetyone/3dme-w--html


