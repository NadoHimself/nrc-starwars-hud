-- NRC Star Wars HUD - Comms Configuration

NRCHUD = NRCHUD or {}
NRCHUD.Config = NRCHUD.Config or {}

-- ========================================
-- GENERAL CONFIGURATION
-- ========================================

-- Language: "en" or "de"
NRCHUD.Config.Language = "en"

-- Debug mode
NRCHUD.Config.Debug = false

-- Voice integration settings
NRCHUD.VoiceIntegration = {
	enabled = false, -- Enable auto voice channel switching
	addon = "none" -- "tokovoip", "saltychat", "pma-voice", "none"
}

-- ========================================
-- TRANSLATIONS
-- ========================================

NRCHUD.Translations = {
	en = {
		-- Comms Menu
		comms_title = "TACTICAL COMMS NETWORK",
		comms_subtitle = "Secure Military Communications",
		active_channel = "ACTIVE CHANNEL",
		standard_channels = "STANDARD CHANNELS",
		custom_channels = "CUSTOM CHANNELS",
		settings = "SETTINGS",
		users = "users",
		create_channel = "CREATE CUSTOM CHANNEL",
		connected = "CONNECTED",
		close = "CLOSE",
		channel_name = "Channel Name",
		frequency = "Frequency",
		create = "CREATE",
		cancel = "CANCEL",
		voice_settings = "Voice Settings",
		auto_switch = "Auto-switch voice channel",
		sound = "Sound Effects",
		sound_volume = "Sound Volume",
		
		-- Commander Menu
		commander_title = "COMMAND CENTER",
		commander_subtitle = "Tactical Command Interface",
		objectives = "OBJECTIVES",
		squad_management = "SQUAD MANAGEMENT",
		tactical_map = "TACTICAL MAP",
		current_objectives = "Current Objectives",
		no_objectives = "No active objectives",
		squad_members = "Squad Members",
		rank = "Rank",
		name = "Name",
		status = "Status",
		
		-- HUD
		health = "HEALTH",
		armor = "ARMOR",
		ammo = "AMMO",
		online = "ONLINE",
		offline = "OFFLINE",
		
		-- Objectives
		mission_objectives = "MISSION OBJECTIVES",
		no_active_missions = "No active missions",
		complete = "COMPLETE",
		in_progress = "IN PROGRESS",
		failed = "FAILED",
		
		-- Notifications
		channel_switched = "Switched to channel:",
		channel_created = "Custom channel created:",
		channel_exists = "Channel name already exists!",
		invalid_input = "Invalid input!"
	},
	
	de = {
		-- Comms Menu
		comms_title = "TAKTISCHES FUNKNETZWERK",
		comms_subtitle = "Sichere Militärkommunikation",
		active_channel = "AKTIVER KANAL",
		standard_channels = "STANDARD KANÄLE",
		custom_channels = "EIGENE KANÄLE",
		settings = "EINSTELLUNGEN",
		users = "Nutzer",
		create_channel = "EIGENEN KANAL ERSTELLEN",
		connected = "VERBUNDEN",
		close = "SCHLIESSEN",
		channel_name = "Kanalname",
		frequency = "Frequenz",
		create = "ERSTELLEN",
		cancel = "ABBRECHEN",
		voice_settings = "Spracheinstellungen",
		auto_switch = "Automatischer Kanalwechsel",
		sound = "Soundeffekte",
		sound_volume = "Lautstärke",
		
		-- Commander Menu
		commander_title = "KOMMANDOZENTRALE",
		commander_subtitle = "Taktisches Kommandointerface",
		objectives = "AUFTRÄGE",
		squad_management = "SQUAD VERWALTUNG",
		tactical_map = "TAKTISCHE KARTE",
		current_objectives = "Aktuelle Aufträge",
		no_objectives = "Keine aktiven Aufträge",
		squad_members = "Squad Mitglieder",
		rank = "Rang",
		name = "Name",
		status = "Status",
		
		-- HUD
		health = "LEBEN",
		armor = "RÜSTUNG",
		ammo = "MUNITION",
		online = "ONLINE",
		offline = "OFFLINE",
		
		-- Objectives
		mission_objectives = "MISSIONSAUFTRÄGE",
		no_active_missions = "Keine aktiven Missionen",
		complete = "ABGESCHLOSSEN",
		in_progress = "IN BEARBEITUNG",
		failed = "FEHLGESCHLAGEN",
		
		-- Notifications
		channel_switched = "Gewechselt zu Kanal:",
		channel_created = "Eigener Kanal erstellt:",
		channel_exists = "Kanalname existiert bereits!",
		invalid_input = "Ungültige Eingabe!"
	}
}

-- Helper function to get translation
function NRCHUD.GetText(key)
	local lang = NRCHUD.Config.Language or "en"
	local translations = NRCHUD.Translations[lang] or NRCHUD.Translations["en"]
	return translations[key] or key
end

-- ========================================
-- COMMS FREQUENCIES
-- ========================================

NRCHUD.CommsFrequencies = {
	["Emergency"] = {
		freq = "243.000 MHz",
		color = Color(239, 68, 68),
		locked = true,
		priority = 10,
		category = "Emergency"
	},
	["Command Net"] = {
		freq = "445.700 MHz",
		color = Color(251, 191, 36),
		locked = true,
		priority = 10,
		category = "Command"
	},
	["Medevac"] = {
		freq = "446.500 MHz",
		color = Color(239, 68, 68),
		locked = false,
		priority = 9,
		category = "Medical"
	},
	["Battalion Net"] = {
		freq = "445.750 MHz",
		color = Color(74, 222, 128),
		locked = false,
		priority = 9,
		category = "Battalion"
	},
	["Fleet Command"] = {
		freq = "446.000 MHz",
		color = Color(96, 165, 250),
		locked = true,
		priority = 9,
		category = "Fleet"
	},
	["Fleet Tactical"] = {
		freq = "446.100 MHz",
		color = Color(251, 191, 36),
		locked = false,
		priority = 8,
		category = "Fleet"
	},
	["ATC Tower"] = {
		freq = "121.500 MHz",
		color = Color(251, 191, 36),
		locked = true,
		priority = 8,
		category = "Air Traffic"
	},
	["Squad Alpha"] = {
		freq = "445.800 MHz",
		color = Color(96, 165, 250),
		locked = false,
		priority = 5,
		category = "Squad"
	},
	["Squad Bravo"] = {
		freq = "445.850 MHz",
		color = Color(96, 165, 250),
		locked = false,
		priority = 5,
		category = "Squad"
	},
	["Engineering"] = {
		freq = "446.200 MHz",
		color = Color(251, 191, 36),
		locked = false,
		priority = 6,
		category = "Support"
	}
}

-- ========================================
-- JOB TO CHANNEL MAPPING
-- ========================================

NRCHUD.JobChannels = {
	["commander"] = "Command Net",
	["marshal"] = "Command Net",
	["captain"] = "Battalion Net",
	["lieutenant"] = "Battalion Net",
	["sergeant"] = "Battalion Net",
	["medic"] = "Medevac",
	["pilot"] = "ATC Tower",
	["engineer"] = "Engineering",
	["trooper"] = "Battalion Net"
}

print("[NRC HUD] Configuration loaded! Language: " .. NRCHUD.Config.Language)