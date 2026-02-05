-- NRC Star Wars HUD - Comms Configuration

-- Standard Military Frequencies
NRCHUD.CommsFrequencies = NRCHUD.CommsFrequencies or {
	-- Command Structure
	["Command Net"] = {freq = "445.700 MHz", color = Color(251, 191, 36), locked = true, priority = 10},
	["Battalion Net"] = {freq = "445.750 MHz", color = Color(76, 222, 128), locked = false, priority = 9},
	
	-- Air Traffic Control
	["ATC Tower"] = {freq = "121.500 MHz", color = Color(96, 165, 250), locked = true, priority = 8},
	["ATC Ground"] = {freq = "121.900 MHz", color = Color(96, 165, 250), locked = true, priority = 7},
	["ATC Approach"] = {freq = "119.100 MHz", color = Color(96, 165, 250), locked = true, priority = 7},
	
	-- Fleet Operations
	["Fleet Command"] = {freq = "446.000 MHz", color = Color(139, 92, 246), locked = true, priority = 9},
	["Fleet Tactical"] = {freq = "446.100 MHz", color = Color(139, 92, 246), locked = false, priority = 8},
	
	-- Emergency Channels
	["Emergency"] = {freq = "243.000 MHz", color = Color(239, 68, 68), locked = true, priority = 10},
	["Medevac"] = {freq = "446.500 MHz", color = Color(239, 68, 68), locked = true, priority = 9},
	
	-- Squad Channels (unlocked, can be customized)
	["Squad Alpha"] = {freq = "445.800 MHz", color = Color(34, 197, 94), locked = false, priority = 5},
	["Squad Bravo"] = {freq = "445.850 MHz", color = Color(34, 197, 94), locked = false, priority = 5},
	["Squad Charlie"] = {freq = "445.900 MHz", color = Color(34, 197, 94), locked = false, priority = 5},
	["Squad Delta"] = {freq = "445.950 MHz", color = Color(34, 197, 94), locked = false, priority = 5},
	
	-- Support Channels
	["Engineering"] = {freq = "446.200 MHz", color = Color(234, 179, 8), locked = false, priority = 6},
	["Logistics"] = {freq = "446.250 MHz", color = Color(234, 179, 8), locked = false, priority = 6},
	["Intelligence"] = {freq = "446.300 MHz", color = Color(168, 85, 247), locked = false, priority = 7}
}

-- Job-specific default channels
NRCHUD.JobChannels = NRCHUD.JobChannels or {
	-- Example mappings (customize per server)
	["Clone Trooper"] = "Battalion Net",
	["Clone Commander"] = "Command Net",
	["Pilot"] = "ATC Tower",
	["Navy Officer"] = "Fleet Command",
	["Medic"] = "Medevac",
	["Engineer"] = "Engineering"
}

-- Voice chat integration settings
NRCHUD.VoiceIntegration = {
	enabled = true,
	autoSwitch = true, -- Auto switch voice channel when changing comms
	proximityOverride = true -- Proximity voice overrides channel selection
}