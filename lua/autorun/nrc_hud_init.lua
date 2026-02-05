-- NRC Star Wars HUD - Autorun Init

if SERVER then
	-- Server files
	include("nrc_hud/shared/sh_comms_config.lua")
	include("nrc_hud/server/sv_comms.lua")
	include("nrc_hud/server/sv_comms_advanced.lua")
	
	-- Client files to send
	AddCSLuaFile("nrc_hud/shared/sh_comms_config.lua")
	AddCSLuaFile("nrc_hud/client/cl_init.lua")
	AddCSLuaFile("nrc_hud/client/cl_hud.lua")
	AddCSLuaFile("nrc_hud/client/cl_objectives.lua")
	AddCSLuaFile("nrc_hud/client/cl_comms_menu.lua")
	AddCSLuaFile("nrc_hud/client/cl_commander_menu.lua")
	AddCSLuaFile("nrc_hud/client/cl_keybinds.lua")
	
	print("[NRC HUD] Server initialized!")
else
	-- Client files (in correct order)
	include("nrc_hud/shared/sh_comms_config.lua")
	include("nrc_hud/client/cl_init.lua") -- FIRST! Initializes PlayerData
	include("nrc_hud/client/cl_hud.lua")
	include("nrc_hud/client/cl_objectives.lua")
	include("nrc_hud/client/cl_comms_menu.lua")
	include("nrc_hud/client/cl_commander_menu.lua")
	include("nrc_hud/client/cl_keybinds.lua")
	
	print("[NRC HUD] Client initialized!")
end