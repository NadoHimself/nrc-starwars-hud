-- NRC Star Wars HUD - Language System

NRCHUD = NRCHUD or {}
NRCHUD.Language = NRCHUD.Language or {}
NRCHUD.CurrentLanguage = "en"

-- English translations
NRCHUD.Language["en"] = {
	-- Currency
	["credits"] = "CREDITS",
	["galactic_credits"] = "Galactic Credits",
	
	-- Identity
	["name"] = "NAME",
	["rank"] = "RANK",
	["job"] = "ASSIGNMENT",
	
	-- Vitals
	["health"] = "HEALTH",
	["armor"] = "ARMOR",
	["shield"] = "SHIELD",
	
	-- Comms
	["comms_channel"] = "CHANNEL",
	["frequency"] = "FREQUENCY",
	["location"] = "LOCATION",
	["time"] = "TIME",
	
	-- Objectives
	["objective"] = "OBJECTIVE",
	["objectives"] = "OBJECTIVES",
	["primary_objective"] = "Primary Objective",
	["secondary_objective"] = "Secondary Objective",
	
	-- Comms Menu
	["comms_menu_title"] = "COMMUNICATIONS",
	["switch_channel"] = "Switch Channel",
	["battalion_net"] = "Battalion Net",
	["squad_net"] = "Squad Net",
	["command_net"] = "Command Net",
	["emergency_net"] = "Emergency Net",
	
	-- Commander Menu
	["commander_menu_title"] = "COMMAND INTERFACE",
	["set_objective"] = "Set Objective",
	["clear_objective"] = "Clear Objective",
	["broadcast_message"] = "Broadcast Message",
	
	-- General
	["close"] = "Close",
	["confirm"] = "Confirm",
	["cancel"] = "Cancel",
	["submit"] = "Submit",
	["back"] = "Back",
}

-- German translations (optional)
NRCHUD.Language["de"] = {
	["credits"] = "CREDITS",
	["galactic_credits"] = "Galaktische Credits",
	["health"] = "GESUNDHEIT",
	["armor"] = "RÜSTUNG",
	["comms_channel"] = "KANAL",
	["frequency"] = "FREQUENZ",
	["location"] = "POSITION",
	["time"] = "ZEIT",
	["objective"] = "ZIEL",
}

-- Get translated text
function NRCHUD.GetText(key)
	local lang = NRCHUD.Language[NRCHUD.CurrentLanguage]
	if lang and lang[key] then
		return lang[key]
	end
	
	-- Fallback to English
	if NRCHUD.Language["en"][key] then
		return NRCHUD.Language["en"][key]
	end
	
	-- Return key if not found
	return key:upper()
end

-- Set language
function NRCHUD.SetLanguage(lang)
	if NRCHUD.Language[lang] then
		NRCHUD.CurrentLanguage = lang
		print("[NRC HUD] Language set to: " .. lang)
		return true
	else
		print("[NRC HUD] Language not found: " .. lang)
		return false
	end
end

print("[NRC HUD] Language system loaded! Current: " .. NRCHUD.CurrentLanguage)