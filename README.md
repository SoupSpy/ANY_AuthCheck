# VXAuthControl Plugin

## Description
Are you unable to mute, ban, or perform any actions on players based on their Steam IDs because they lack a Steam connection? Use this plugin! 

As you may know, many plugins rely on players' Steam ID information to function properly. However, there are instances where servers cannot access a player's Steam ID due to Steam-related issues or because the player appears offline on Steam. This leads to many plugins not working as intended.

The VXAuthControl plugin resolves this issue by continuously attempting to retrieve a player's Steam ID information at regular intervals when they join the server. If the maximum number of attempts is reached without success, the player will be kicked from the game. If the player has a Steam connection when they join the server but loses it mid-game, this plugin will not take any action as Steam will handle the disconnection and kick the player automatically.

## Requirements
- **SteamWorks**: This plugin requires [SteamWorks](https://users.alliedmods.net/~kyles/builds/SteamWorks/) to function correctly.
- **Multicolors**: If you plan to customize and recompile the plugin yourself, the `multicolors` library is required.

## Available ConVars
The following ConVars are available for configuring the plugin:

| ConVar                | Default Value | Description                                                                                           |
|-----------------------|---------------|-------------------------------------------------------------------------------------------------------|
| `sm_vxauthcontrol_enabled`  | `1`           | Enables or disables the plugin. `0` for disabled, `1` for enabled.                                   |
| `sm_vxauthcontrol_retrytime` | `20`          | How many seconds should the server wait before retrying if the Steam auth information is unavailable? |
| `sm_vxauthcontrol_maxattempts` | `3`          | Number of failed attempts after which the player will be kicked from the server.                     |

## How It Works
1. When a player joins the server, the plugin checks their Steam ID.
2. If the Steam ID cannot be retrieved, the plugin retries at the specified interval (`sm_vxauthcontrol_retrytime`).
3. Each unsuccessful attempt is recorded as a failed attempt.
4. If the number of failed attempts reaches the maximum allowed (`sm_vxauthcontrol_maxattempts`), the player is kicked from the game.
5. If a player's Steam connection is lost mid-game, the plugin takes no action, as Steam automatically handles such scenarios.

## Installation
1. Download and install [SteamWorks](https://users.alliedmods.net/~kyles/builds/SteamWorks/).
2. Place the VXAuthControl plugin files into the appropriate folders on your server.
3. Restart your server.
4. Configure the ConVars as needed in your server's configuration file.

## Notes
- Ensure that the required dependencies are installed before using the plugin.
- Customize the ConVars to suit your server's requirements.

---
Thank you for using VXAuthControl! If you encounter any issues or have suggestions, feel free to contribute or report them.
