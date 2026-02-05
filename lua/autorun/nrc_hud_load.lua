-- NRC Star Wars HUD - Autorun Loader

if SERVER then
	AddCSLuaFile("nrc_hud/shared/sh_config.lua")
	AddCSLuaFile("nrc_hud/client/cl_init.lua")
	AddCSLuaFile("nrc_hud/client/cl_hud.lua")
	AddCSLuaFile("nrc_hud/client/cl_comms_menu.lua")
	AddCSLuaFile("nrc_hud/client/cl_voice.lua")
	AddCSLuaFile("nrc_hud/client/cl_voice_hud.lua")
	
	include("nrc_hud/shared/sh_config.lua")
	include("nrc_hud/server/sv_init.lua")
	include("nrc_hud/server/sv_comms.lua")
	include("nrc_hud/server/sv_voice.lua")
	
	print("[NRC HUD] Server files loaded!")
else
	include("nrc_hud/shared/sh_config.lua")
	include("nrc_hud/client/cl_init.lua")
	include("nrc_hud/client/cl_hud.lua")
	include("nrc_hud/client/cl_comms_menu.lua")
	include("nrc_hud/client/cl_voice.lua")
	include("nrc_hud/client/cl_voice_hud.lua")
	
	print("[NRC HUD] Client files loaded!")
end