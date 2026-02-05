# Font Installation Guide

## Required Fonts

This HUD requires two custom fonts:
1. **Orbitron** (Bold/Black weights)
2. **Share Tech Mono**

## Installation

### Method 1: Resource Pack (Recommended for servers)

1. Download the fonts:
   - Orbitron: https://fonts.google.com/specimen/Orbitron
   - Share Tech Mono: https://fonts.google.com/specimen/Share+Tech+Mono

2. Place the `.ttf` files in:
   ```
   garrysmod/resource/fonts/
   ```

3. Add to `lua/autorun/client/` or your loading screen:
   ```lua
   resource.AddFile("resource/fonts/Orbitron-Bold.ttf")
   resource.AddFile("resource/fonts/Orbitron-Black.ttf")
   resource.AddFile("resource/fonts/ShareTechMono-Regular.ttf")
   ```

### Method 2: FastDL/Workshop

Add the font files to your FastDL or Workshop content:

```lua
-- In server config
resource.AddWorkshop("your_workshop_id")
```

### Method 3: Manual Installation (Client-side)

Players can manually install fonts:

1. Download fonts from Google Fonts
2. Double-click `.ttf` files
3. Click "Install"
4. Restart Garry's Mod

## Testing

After installation, you should see in console:
```
[NRC HUD] Custom fonts loaded successfully!
```

If not working:
```
[NRC HUD] WARNING: Custom fonts (Orbitron/Share Tech Mono) not found!
```

## Troubleshooting

### Fonts not loading:
- Ensure `.ttf` files are in `garrysmod/resource/fonts/`
- Restart GMod completely
- Check console for errors
- Verify file names match exactly

### Fallback Behavior

If fonts are missing, GMod will use system defaults:
- Orbitron → Arial Bold
- Share Tech Mono → Courier New

## Font File Names

Expected files:
- `Orbitron-Bold.ttf`
- `Orbitron-Black.ttf`
- `ShareTechMono-Regular.ttf`

## Server Operators

Add to your `server.cfg` or startup:

```lua
-- Force download fonts
resource.AddFile("resource/fonts/Orbitron-Bold.ttf")
resource.AddFile("resource/fonts/Orbitron-Black.ttf")
resource.AddFile("resource/fonts/ShareTechMono-Regular.ttf")
```

## Direct Download Links

**Orbitron:**
https://github.com/theleagueof/orbitron/releases

**Share Tech Mono:**
https://github.com/googlefonts/RobotoMono/releases

---

**Need Help?**
Check console output after HUD loads for font status.