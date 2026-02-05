# NRC Star Wars HUD

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![Garry's Mod](https://img.shields.io/badge/Garry's%20Mod-Required-orange.svg)
![DarkRP](https://img.shields.io/badge/DarkRP-Compatible-green.svg)

A cinematic Star Wars-themed HUD for Garry's Mod with full DarkRP integration, MRS Advanced Rank System support, Commander Objective System, and **Advanced Tactical Communications Network**.

## ✨ Features

### Core HUD Elements
- **Health & Armor Display** - Clean, readable bars with values (INCREASED SIZE)
- **Ammo Counter** - Large ammunition display with weapon name
- **Identity Card** - Shows player name, rank, and job/battalion (MRS integration)
- **Currency Display** - DarkRP money integration with Credits display (gold accent)
- **Minimap** - Circular tactical minimap with ally/enemy indicators
- **Objective System** - Dynamic mission objectives
- **Comms Display** - Shows active communication channel, frequency, location, time

### 🆕 Advanced Communications System (v1.1.0)

#### **F6 - Tactical Communications Menu**
Press **F6** to open the comprehensive communications interface featuring:

- **Standard Military Channels**
  - Command Net (445.700 MHz) - High priority command communications
  - Battalion Net (445.750 MHz) - Main unit communications
  
- **Air Traffic Control**
  - ATC Tower (121.500 MHz) - Tower control frequency
  - ATC Ground (121.900 MHz) - Ground operations
  - ATC Approach (119.100 MHz) - Approach control
  
- **Fleet Operations**
  - Fleet Command (446.000 MHz) - Fleet command channel
  - Fleet Tactical (446.100 MHz) - Fleet tactical operations
  
- **Emergency Channels**
  - Emergency (243.000 MHz) - Emergency frequency
  - Medevac (446.500 MHz) - Medical evacuation
  
- **Squad Channels**
  - Squad Alpha/Bravo/Charlie/Delta - Squad-specific communications
  
- **Support Channels**
  - Engineering (446.200 MHz)
  - Logistics (446.250 MHz)
  - Intelligence (446.300 MHz)

#### **Features**
- ✅ Job-based automatic channel assignment
- ✅ Create custom temporary channels
- ✅ Priority-based channel organization
- ✅ Locked/unlocked channel system
- ✅ Voice chat integration hooks (compatible with voice addons)
- ✅ Auto-switch voice channel with comms (configurable)
- ✅ Real-time frequency display
- ✅ Color-coded channel categories

### Commander Objective System
- **F4** - Open Commander Menu (if authorized)
- Assign objectives to specific jobs and ranks
- Priority system (1-5)
- Timeout management
- Real-time distribution to affected players

### Visual Feedback
- **Hit Markers** - Visual feedback on successful hits
- **Damage Indicators** - Directional damage visualization
- **Low Health Warning** - Screen vignette effect at low health

## 🎮 Controls

- **F4** - Commander Menu (Commanders only)
- **F6** - Communications Menu (All players)
- **B** - Quick cycle through favorite channels
- **TAB** - Show scoreboard (standard GMod)

## 📦 Installation

1. Download or clone this repository
2. Place the `nrc-starwars-hud` folder in your `garrysmod/addons/` directory
3. Restart your server or type `lua_refresh` in console
4. Configure channels and jobs in `lua/nrc_hud/shared/sh_comms_config.lua`

## ⚙️ Requirements

- **Garry's Mod** (latest version)
- **DarkRP** (recommended)
- **MRS Advanced Rank System** (optional) - [GmodStore Link](https://www.gmodstore.com/market/view/rankup-advanced-rank-system)
- **Voice Chat Addon** (optional, for full comms integration)

## 🔧 Configuration

All configuration can be found in:
- `lua/nrc_hud/shared/sh_config.lua` - Main HUD settings
- `lua/nrc_hud/shared/sh_comms_config.lua` - Communications settings

### Key Configuration Options

```lua
-- Enable/Disable HUD elements
NRCHUD.Config.ShowHealth = true
NRCHUD.Config.ShowArmor = true
NRCHUD.Config.ShowAmmo = true
NRCHUD.Config.ShowComms = true

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

### Comms Configuration

```lua
-- Add custom job-to-channel mappings
NRCHUD.JobChannels = {
    ["Clone Trooper"] = "Battalion Net",
    ["Clone Commander"] = "Command Net",
    ["Pilot"] = "ATC Tower",
    ["Navy Officer"] = "Fleet Command",
    ["Medic"] = "Medevac",
    ["Engineer"] = "Engineering"
}

-- Voice chat integration
NRCHUD.VoiceIntegration = {
    enabled = true,
    autoSwitch = true,
    proximityOverride = true
}
```

## 📡 Voice Chat Integration

The comms system includes hooks for voice chat addon integration:

```lua
-- Hook called when player switches channel
hook.Add("NRCHUD_PlayerChannelChanged", "YourAddon", function(ply, channelName, channelData)
    -- Your voice chat integration code here
    -- Example: VoiceAddon.SetChannel(ply, channelName)
end)
```

Compatible with:
- Simple Voice Chat
- vVoice
- Other 3D voice addons

## 🎨 Customization

### Font Sizes
All fonts are defined in `lua/nrc_hud/client/cl_hud.lua`. Sizes have been increased for better readability:
- Identity Name: 22px
- Rank/Job: 16px
- Health/Armor Labels: 16px
- Currency: 24px
- Ammo: 56px (current), 32px (reserve)

### Colors
Channel colors are customizable in `sh_comms_config.lua`:
```lua
NRCHUD.CommsFrequencies["Your Channel"] = {
    freq = "446.XXX MHz",
    color = Color(R, G, B),
    locked = false,
    priority = 5
}
```

## 📋 API

### Server-Side

```lua
-- Create an objective
NRCHUD.CreateObjective(text, targetJob, targetRank, priority, timeout, creator)

-- Remove an objective
NRCHUD.RemoveObjective(objectiveID)

-- Set player currency
NRCHUD.SetCurrency(ply, amount)

-- Switch player comms channel
NRCHUD.SetCommsChannel(ply, channelName)
```

### Client-Side

```lua
-- Get current objective
local objective = NRCHUD.GetCurrentObjective()

-- Get current comms channel
local channel = NRCHUD.CurrentChannel

-- Open comms menu
NRCHUD.OpenCommsMenu()

-- Switch channel
NRCHUD.SwitchChannel(channelName)
```

## 🐛 Troubleshooting

### HUD elements too small
- Font sizes have been increased in v1.1.0
- Borders made thicker and more visible
- If still too small, edit font sizes in `cl_hud.lua`

### "Unknown" showing in identity
- Wait 1-2 seconds after spawn for data to sync
- Check DarkRP/MRS integration is working
- Enable debug mode: `NRCHUD.Config.Debug = true`

### Minimap overlapping weapon display
- Fixed in v1.1.0 - Minimap now positioned above weapon display

### Comms not working
- Press **F6** (not F key) to open menu
- Check `sh_comms_config.lua` is loaded
- Verify network strings are registered

## 📝 Changelog

### Version 1.1.0 (Current)
- ✅ Advanced Communications System with F6 menu
- ✅ Standard military frequencies (Command, ATC, Fleet, Emergency)
- ✅ Custom channel creation
- ✅ Job-based automatic channel assignment
- ✅ Voice chat integration hooks
- ✅ Increased font sizes for better readability
- ✅ Fixed minimap position (no longer overlaps weapon display)
- ✅ Thicker borders and improved visibility
- ✅ Fixed data display with proper fallbacks
- ✅ B key removed from comms (use F6 menu instead)

### Version 1.0.1
- Fixed file path issues (backslashes to forward slashes)
- Added minimap system
- Improved HUD element positioning

### Version 1.0.0
- Initial release
- Core HUD functionality
- DarkRP integration
- MRS Advanced Rank System support
- Commander Objective System
- Basic Comms System
- Minimap functionality

## 🤝 Credits

- **Author**: NadoHimself
- **Version**: 1.1.0
- **License**: MIT

## 💬 Support

For issues, suggestions, or support:
- Create an issue on GitHub
- Check existing issues first
- Provide console logs and error messages

## 🌟 Features Roadmap

- [ ] 3D spatial audio for proximity voice
- [ ] Encrypted channel system
- [ ] Recording/playback of comms
- [ ] Channel access control lists
- [ ] Integration with specific Star Wars RP addons
- [ ] Advanced minimap with objectives

---

**May the Force be with you, soldier!** 🎖️

*Transmission ends.*