-- NRC HUD - Font Resource Loader (CLIENT)

-- This file ensures fonts are requested from server
if SERVER then return end

print("[NRC HUD] Requesting custom fonts from server...")

-- Wait for resources to be ready
timer.Simple(0.5, function()
	-- Check if fonts exist
	local fontsExist = file.Exists("resource/fonts/Orbitron-Bold.ttf", "GAME") or 
	                   file.Exists("resource/fonts/Orbitron-Black.ttf", "GAME")
	
	if fontsExist then
		print("[NRC HUD] Custom fonts found!")
	else
		print("[NRC HUD] WARNING: Custom fonts not found in resource/fonts/")
		print("[NRC HUD] Fonts should be downloaded from server...")
	end
end)

-- Force font reload on resource download
hook.Add("OnCacheDownloaded", "NRCHUD_FontReload", function()
	print("[NRC HUD] Resources downloaded, reloading fonts...")
	
	-- Reload HUD
	if NRCHUD then
		include("nrc_hud/client/cl_hud.lua")
	end
end)