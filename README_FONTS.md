# Font Installation - CRITICAL

## The fonts MUST be in these exact locations:

```
gmod/garrysmod/resource/fonts/Orbitron-Bold.ttf
gmod/garrysmod/resource/fonts/Orbitron-Black.ttf
gmod/garrysmod/resource/fonts/Orbitron-Regular.ttf
gmod/garrysmod/resource/fonts/ShareTechMono-Regular.ttf
```

## How to Install:

### 1. Download Fonts

**Orbitron:**
- Go to: https://fonts.google.com/specimen/Orbitron
- Click "Download family"
- Extract the ZIP
- Find: `Orbitron-Bold.ttf`, `Orbitron-Black.ttf`, `Orbitron-Regular.ttf`

**Share Tech Mono:**
- Go to: https://fonts.google.com/specimen/Share+Tech+Mono
- Click "Download family"
- Extract the ZIP
- Find: `ShareTechMono-Regular.ttf`

### 2. Place Files

Copy the `.ttf` files to:
```
your_server/garrysmod/resource/fonts/
```

Create the `fonts/` folder if it doesn't exist!

### 3. Server Config

The addon automatically adds these files to FastDL via:
```lua
resource.AddFile("resource/fonts/Orbitron-Bold.ttf")
// etc.
```

Check `lua/autorun/server/nrc_hud_resources.lua`

### 4. Test

Restart server, then check console:
```
[NRC HUD] Added font: resource/fonts/Orbitron-Bold.ttf
[NRC HUD] Added font: resource/fonts/Orbitron-Black.ttf
...
```

## Troubleshooting

### Fonts not loading?

1. Check file paths are EXACT (case-sensitive on Linux!)
2. Restart GMod completely
3. Check console for warnings
4. Try installing fonts system-wide (Windows: double-click .ttf → Install)

### Still using fallback fonts?

The HUD will use Arial/Courier New if custom fonts fail. This is normal behavior.

---

**Current Status:**
- ✅ Fonts in `resource/fonts/`
- ✅ Server adds them to FastDL
- ✅ HUD uses them with fallback support
