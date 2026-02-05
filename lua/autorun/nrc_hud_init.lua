-- NRC Star Wars HUD - Initialization
-- Author: NadoHimself
-- Description: Main initialization file for the Star Wars RP HUD

NRCHUD = NRCHUD or {}
NRCHUD.Version = "1.0.0"
NRCHUD.Author = "NadoHimself"

if SERVER then
	AddCSLuaFile()
	
	-- Load server files
	include("nrc_hud/server/sv_init.lua")
	include("nrc_hud/server/sv_objectives.lua")
	include("nrc_hud/server/sv_currency.lua")
	include("nrc_hud/server/sv_comms.lua")
	
	print("[NRC HUD] Server files loaded successfully!")
else
	-- Load client files
	include("nrc_hud/client/cl_init.lua")
	include("nrc_hud/client/cl_hud.lua")
	include("nrc_hud/client/cl_objectives.lua")
	include("nrc_hud/client/cl_commander_menu.lua")
	
	print("[NRC HUD] Client files loaded successfully!")
end

print("[NRC HUD] Version " .. NRCHUD.Version .. " initialized by " .. NRCHUD.Author)