# Installation Guide - NRC Star Wars HUD

## Quick Install (Recommended)

1. **Download the addon**
   - Download the latest release from GitHub
   - Or clone the repository: `git clone https://github.com/NadoHimself/nrc-starwars-hud.git`

2. **Install to server**
   - Place the `nrc-starwars-hud` folder in `garrysmod/addons/`
   - Restart your server or run `lua_refresh` in console

3. **Verify installation**
   - Join your server
   - You should see the HUD automatically
   - Check console for: `[NRC HUD] Version 1.0.0 initialized`

## Configuration

### Basic Configuration

Edit `lua/nrc_hud/shared/sh_config.lua` to customize:

```lua
-- Enable/disable HUD elements
NRCHUD.Config.ShowHealth = true
NRCHUD.Config.ShowArmor = true
NRCHUD.Config.ShowAmmo = true
NRCHUD.Config.ShowIdentity = true
NRCHUD.Config.ShowCurrency = true
```

### DarkRP Integration

The HUD automatically detects DarkRP. To use DarkRP money:

```lua
NRCHUD.Config.UseDarkRPMoney = true
NRCHUD.Config.CurrencyName = "Credits"
```

### MRS Advanced Rank System Integration

If you have MRS installed:

```lua
NRCHUD.Config.UseMRS = true
```

The HUD will automatically detect MRS and display ranks.

### Commander Ranks

Set which ranks can create objectives:

```lua
NRCHUD.Config.CommanderRanks = {
    "Commander",
    "Captain",
    "Lieutenant",
    "Marshal Commander"
}
```

### Comms Channels

Customize communication channels:

```lua
NRCHUD.Config.CommsChannels = {
    [1] = {name = "Battalion", color = Color(76, 222, 128)},
    [2] = {name = "Squad", color = Color(96, 165, 250)},
    [3] = {name = "Command", color = Color(251, 191, 36)},
    [4] = {name = "Emergency", color = Color(239, 68, 68)}
}
```

## Testing

### Single Player Testing

1. Start Garry's Mod
2. Create a local server
3. The HUD should appear automatically
4. Press **B** to cycle comms channels
5. Press **F4** to test Commander menu (works in singleplayer)

### Server Testing

1. Join your DarkRP server
2. HUD should appear with your job and rank
3. Currency should sync with DarkRP money
4. Test with different jobs and ranks

## Troubleshooting

### HUD not showing

- Check console for errors
- Verify files are in correct location: `garrysmod/addons/nrc-starwars-hud/`
- Run `lua_refresh` in console
- Check `NRCHUD.Config.Enabled = true` in config

### Currency not updating

- Ensure DarkRP is installed and running
- Check `NRCHUD.Config.UseDarkRPMoney = true`
- Verify no conflicting HUD addons

### Ranks not showing

- For MRS: Ensure MRS is installed and loaded before HUD
- Check `NRCHUD.Config.UseMRS = true`
- Look for `[NRC HUD] MRS Advanced Rank System detected!` in console

### Commander menu not working

- Verify you have correct rank (check `CommanderRanks` in config)
- SuperAdmins always have access
- Press **F4** to open menu

### Console errors

- Enable debug mode: `NRCHUD.Config.Debug = true`
- Check server console for detailed error messages
- Ensure all files are present and not corrupted

## Advanced Configuration

### Custom Fonts

The HUD uses Google Fonts (Orbitron, Share Tech Mono). If you want to use custom fonts:

1. Add your font files to `resource/fonts/`
2. Edit font definitions in `lua/nrc_hud/client/cl_hud.lua`

### Custom Colors

Edit colors directly in the drawing functions in `cl_hud.lua`:

```lua
-- Example: Change currency color from gold to blue
draw.SimpleText(amountText, "NRCHUD_Currency", x + 45, y + 10, Color(96, 165, 250, 255), TEXT_ALIGN_LEFT)
```

### Minimap Settings

```lua
NRCHUD.Config.MinimapSize = 130
NRCHUD.Config.MinimapShowAllies = true
NRCHUD.Config.MinimapShowEnemies = true
NRCHUD.Config.MinimapUpdateRate = 1
```

## API Usage

### Server-Side Examples

```lua
-- Create an objective for all 501st troopers
NRCHUD.CreateObjective("Defend the Hangar Bay", "501st Trooper", "all", 3, 1800)

-- Give player credits
NRCHUD.AddCurrency(player, 500)

-- Set comms channel
NRCHUD.SetCommsChannel(player, 3)
```

### Client-Side Examples

```lua
-- Get current objective
local objective = NRCHUD.GetCurrentObjective()
if objective then
    print("Current objective: " .. objective.text)
end

-- Get comms channel
local channel = NRCHUD.PlayerData.commsChannel
```

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check existing issues first
- Provide console logs and error messages

---

**May the Force be with you!** 🎖️