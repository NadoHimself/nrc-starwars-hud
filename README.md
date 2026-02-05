# NRC Star Wars HUD

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Garry's Mod](https://img.shields.io/badge/Garry's%20Mod-Required-orange.svg)
![DarkRP](https://img.shields.io/badge/DarkRP-Compatible-green.svg)

A cinematic Star Wars-themed HUD for Garry's Mod with full DarkRP integration, MRS Advanced Rank System support, and Commander Objective System.

## Features

### Core HUD Elements
- **Health & Armor Display** - Sleek, transparent bars with real-time updates
- **Ammo Counter** - Large, readable ammunition display
- **Identity Card** - Shows player name, rank, and battalion (MRS integration)
- **Currency Display** - DarkRP money integration with Credits display
- **Minimap** - Circular tactical minimap with ally/enemy indicators
- **Objective System** - Dynamic mission objectives
- **Comms Display** - Shows active communication channel and frequency

### Advanced Features
- **Commander Objective Menu** - Assign objectives to specific jobs and ranks
- **MRS Rank System Integration** - Automatic rank and battalion detection
- **DarkRP Money System** - Seamless currency integration
- **Hit Markers** - Visual feedback on successful hits
- **Damage Indicators** - Directional damage visualization
- **Low Health Warning** - Screen vignette effect at low health

## Installation

1. Download or clone this repository
2. Place the `nrc-starwars-hud` folder in your `garrysmod/addons/` directory
3. Restart your server or type `lua_refresh` in console

## Requirements

- **Garry's Mod** (latest version)
- **DarkRP** (recommended)
- **MRS Advanced Rank System** (optional) - [GmodStore Link](https://www.gmodstore.com/market/view/rankup-advanced-rank-system)

## Configuration

All configuration can be found in `lua/nrc_hud/shared/sh_config.lua`

### Key Configuration Options

```lua
-- Enable/Disable HUD elements
NRCHUD.Config.ShowHealth = true
NRCHUD.Config.ShowArmor = true
NRCHUD.Config.ShowAmmo = true

-- Currency settings
NRCHUD.Config.UseDarkRPMoney = true
NRCHUD.Config.CurrencyName = "Credits"

-- Commander ranks (can assign objectives)
NRCHUD.Config.CommanderRanks = {
    "Commander",
    "Captain",
    "Lieutenant"
}
```

## Commander Objective System

Commanders with appropriate ranks can:
1. Press **F4** to open the Commander Menu
2. Create new objectives
3. Assign objectives to specific:
   - DarkRP Jobs
   - MRS Ranks
   - Individual players
4. Set objective priorities and timeouts

## Comms Channels

The HUD includes 4 communication channels:
- **Battalion** (Green) - Main communications
- **Squad** (Blue) - Squad-level comms
- **Command** (Yellow) - Command channel
- **Emergency** (Red) - Emergency frequency

Press **B** to cycle through channels.

## Controls

- **F4** - Open Commander Menu (if authorized)
- **B** - Cycle Comms Channels
- **TAB** - Toggle Minimap

## API

### Server-Side

```lua
-- Create an objective
NRCHUD.CreateObjective(text, targetJob, targetRank, priority, timeout)

-- Remove an objective
NRCHUD.RemoveObjective(objectiveID)

-- Set player currency
NRCHUD.SetCurrency(ply, amount)
```

### Client-Side

```lua
-- Get local player's objective
local objective = NRCHUD.GetCurrentObjective()

-- Get current comms channel
local channel = NRCHUD.GetCommsChannel()
```

## Credits

- **Author**: NadoHimself
- **Version**: 1.0.0
- **License**: MIT

## Support

For issues, suggestions, or support, please create an issue on GitHub.

## Changelog

### Version 1.0.0
- Initial release
- Core HUD functionality
- DarkRP integration
- MRS Advanced Rank System support
- Commander Objective System
- Comms System
- Minimap functionality

---

*May the Force be with you, soldier.* 🎖️