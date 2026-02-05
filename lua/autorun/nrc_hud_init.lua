-- NRC Star Wars HUD - Initialization
-- Author: NadoHimself
-- Description: Main initialization file for the Star Wars RP HUD

NRCHUD = NRCHUD or {}
NRCHUD.Version = "1.1.0"
NRCHUD.Author = "NadoHimself"

-- Load shared config first
include("nrc_hud/shared/sh_config.lua")
include("nrc_hud/shared/sh_comms_config.lua")
AddCSLuaFile("nrc_hud/shared/sh_config.lua")
AddCSLuaFile("nrc_hud/shared/sh_comms_config.lua")

if SERVER then
	-- Add client files to download
	AddCSLuaFile("nrc_hud/client/cl_init.lua")
	AddCSLuaFile("nrc_hud/client/cl_hud.lua")
	AddCSLuaFile("nrc_hud/client/cl_objectives.lua")
	AddCSLuaFile("nrc_hud/client/cl_commander_menu.lua")
	AddCSLuaFile("nrc_hud/client/cl_minimap.lua")
	AddCSLuaFile("nrc_hud/client/cl_comms_menu.lua")
	
	-- Load server files
	include("nrc_hud/server/sv_init.lua")
	include("nrc_hud/server/sv_objectives.lua")
	include("nrc_hud/server/sv_currency.lua")
	include("nrc_hud/server/sv_comms.lua")
	include("nrc_hud/server/sv_comms_advanced.lua")
	
	print("[NRC HUD] Server files loaded successfully!")
else
	-- Load client files
	include("nrc_hud/client/cl_init.lua")
	include("nrc_hud/client/cl_hud.lua")
	include("nrc_hud/client/cl_objectives.lua")
	include("nrc_hud/client/cl_commander_menu.lua")
	include("nrc_hud/client/cl_minimap.lua")
	include("nrc_hud/client/cl_comms_menu.lua")
	
	print("[NRC HUD] Client files loaded successfully!")
end

print("[NRC HUD] Version " .. NRCHUD.Version .. " initialized by " .. NRCHUD.Author)
