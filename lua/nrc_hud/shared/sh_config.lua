-- NRC Star Wars HUD - Shared Configuration

-- Initialize NRCHUD table first!
NRCHUD = NRCHUD or {}
NRCHUD.Config = NRCHUD.Config or {}

-- General Settings
NRCHUD.Config.Enabled = true
NRCHUD.Config.Debug = false

-- HUD Display Settings
NRCHUD.Config.ShowHealth = true
NRCHUD.Config.ShowArmor = true
NRCHUD.Config.ShowAmmo = true
NRCHUD.Config.ShowIdentity = true
NRCHUD.Config.ShowCurrency = true
NRCHUD.Config.ShowMinimap = true
NRCHUD.Config.ShowObjective = true
NRCHUD.Config.ShowComms = true

-- Currency Settings
NRCHUD.Config.CurrencyName = "Credits"
NRCHUD.Config.UseDarkRPMoney = true -- Use DarkRP money system

-- MRS Integration
NRCHUD.Config.UseMRS = true -- Use MRS Advanced Rank System
NRCHUD.Config.MRSEnabled = false -- Will be set to true if MRS is detected

-- Commander Permissions
NRCHUD.Config.CommanderRanks = {
	"Commander",
	"Captain",
	"Lieutenant",
	"Marshal Commander"
}

-- Objective System
NRCHUD.Config.MaxObjectives = 5
NRCHUD.Config.ObjectiveTimeout = 3600 -- 1 hour in seconds

-- Comms Channels
NRCHUD.Config.CommsChannels = {
	[1] = {name = "Battalion", color = Color(76, 222, 128)},
	[2] = {name = "Squad", color = Color(96, 165, 250)},
	[3] = {name = "Command", color = Color(251, 191, 36)},
	[4] = {name = "Emergency", color = Color(239, 68, 68)}
}

-- Default Comms Settings
NRCHUD.Config.DefaultCommsChannel = 1
NRCHUD.Config.DefaultFrequency = "445.7 MHz"

-- Hit Marker Settings
NRCHUD.Config.ShowHitMarker = true
NRCHUD.Config.HitMarkerDuration = 0.15

-- Damage Indicator Settings
NRCHUD.Config.ShowDamageIndicator = true
NRCHUD.Config.DamageIndicatorDuration = 0.4

-- Low Health Warning
NRCHUD.Config.LowHealthThreshold = 35
NRCHUD.Config.LowHealthEffect = true

-- Minimap Settings
NRCHUD.Config.MinimapSize = 130
NRCHUD.Config.MinimapShowAllies = true
NRCHUD.Config.MinimapShowEnemies = true
NRCHUD.Config.MinimapUpdateRate = 1 -- seconds

-- UI Positioning (CLIENT-ONLY, initialized in cl_init.lua)
-- NOTE: Cannot use ScrH()/ScrW() in shared files!
NRCHUD.Config.Positions = {}

-- Debug function
function NRCHUD.Debug(msg)
	if NRCHUD.Config.Debug then
		print("[NRC HUD DEBUG] " .. tostring(msg))
	end
end