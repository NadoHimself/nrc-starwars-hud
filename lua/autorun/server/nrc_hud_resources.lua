-- NRC HUD - Resource Loader (SERVER)

if CLIENT then return end

print("[NRC HUD] Loading font resources...")

-- Add font files to download
local fonts = {
	"resource/fonts/Orbitron-Bold.ttf",
	"resource/fonts/Orbitron-Black.ttf",
	"resource/fonts/Orbitron-Regular.ttf",
	"resource/fonts/ShareTechMono-Regular.ttf",
}

for _, fontPath in ipairs(fonts) do
	if file.Exists(fontPath, "GAME") then
		resource.AddFile(fontPath)
		print("[NRC HUD] Added font: " .. fontPath)
	else
		print("[NRC HUD] WARNING: Font not found: " .. fontPath)
	end
end

print("[NRC HUD] Font resources loaded!")