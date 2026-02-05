-- NRC Star Wars HUD - Advanced Comms System (Server)

util.AddNetworkString("NRCHUD_SwitchChannel")
util.AddNetworkString("NRCHUD_CreateCustomChannel")
util.AddNetworkString("NRCHUD_ChannelUpdate")
util.AddNetworkString("NRCHUD_VoiceSettings")

include("nrc_hud/shared/sh_comms_config.lua")
AddCSLuaFile("nrc_hud/shared/sh_comms_config.lua")
AddCSLuaFile("nrc_hud/client/cl_comms_menu.lua")

-- Custom channels storage
NRCHUD.CustomChannels = NRCHUD.CustomChannels or {}

-- Switch player channel
net.Receive("NRCHUD_SwitchChannel", function(len, ply)
	local channelName = net.ReadString()
	local channelData = NRCHUD.CommsFrequencies[channelName]
	
	if not channelData then return end
	
	if not ply.NRCHUDData then
		ply.NRCHUDData = {}
	end
	
	ply.NRCHUDData.commsChannel = channelName
	ply.NRCHUDData.frequency = channelData.freq
	
	-- Update comms display
	NRCHUD.UpdatePlayerComms(ply)
	
	-- Voice chat integration (if supported)
	if NRCHUD.VoiceIntegration.enabled then
		hook.Run("NRCHUD_PlayerChannelChanged", ply, channelName, channelData)
	end
	
	NRCHUD.Debug(ply:Nick() .. " switched to channel: " .. channelName)
end)

-- Create custom channel
net.Receive("NRCHUD_CreateCustomChannel", function(len, ply)
	local channelName = net.ReadString()
	local frequency = net.ReadString()
	
	-- Validate
	if channelName == "" or frequency == "" then return end
	if NRCHUD.CommsFrequencies[channelName] then
		if DarkRP then
			DarkRP.notify(ply, 1, 4, "Channel name already exists!")
		end
		return
	end
	
	-- Create channel
	local newChannel = {
		freq = frequency,
		color = Color(96, 165, 250),
		locked = false,
		priority = 4,
		creator = ply:SteamID(),
		created = os.time(),
		custom = true
	}
	
	NRCHUD.CommsFrequencies[channelName] = newChannel
	NRCHUD.CustomChannels[channelName] = newChannel
	
	-- Broadcast to all players
	for _, pl in ipairs(player.GetAll()) do
		net.Start("NRCHUD_ChannelUpdate")
			net.WriteString(channelName)
			net.WriteString(newChannel.freq)
			net.WriteUInt(newChannel.color.r, 8)
			net.WriteUInt(newChannel.color.g, 8)
			net.WriteUInt(newChannel.color.b, 8)
			net.WriteBool(newChannel.locked)
			net.WriteUInt(newChannel.priority, 8)
		net.Send(pl)
	end
	
	if DarkRP then
		DarkRP.notify(ply, 0, 4, "Custom channel created: " .. channelName)
	end
	
	NRCHUD.Debug("Custom channel created: " .. channelName .. " by " .. ply:Nick())
end)

-- Voice settings update
net.Receive("NRCHUD_VoiceSettings", function(len, ply)
	local autoSwitch = net.ReadBool()
	
	if not ply.NRCHUDData then
		ply.NRCHUDData = {}
	end
	
	ply.NRCHUDData.voiceAutoSwitch = autoSwitch
end)

-- Assign job-based channel on spawn
hook.Add("PlayerSpawn", "NRCHUD_AssignJobChannel", function(ply)
	timer.Simple(1, function()
		if not IsValid(ply) then return end
		
		local job = "Unknown"
		if DarkRP and ply.getDarkRPVar then
			job = ply:getDarkRPVar("job") or team.GetName(ply:Team())
		else
			job = team.GetName(ply:Team())
		end
		
		-- Find matching channel
		local assignedChannel = nil
		for jobPattern, channelName in pairs(NRCHUD.JobChannels) do
			if string.find(string.lower(job), string.lower(jobPattern)) then
				assignedChannel = channelName
				break
			end
		end
		
		-- Default to Battalion Net
		if not assignedChannel then
			assignedChannel = "Battalion Net"
		end
		
		local channelData = NRCHUD.CommsFrequencies[assignedChannel]
		if channelData then
			if not ply.NRCHUDData then
				ply.NRCHUDData = {}
			end
			
			ply.NRCHUDData.commsChannel = assignedChannel
			ply.NRCHUDData.frequency = channelData.freq
			
			NRCHUD.UpdatePlayerComms(ply)
			
			NRCHUD.Debug("Assigned " .. ply:Nick() .. " to channel: " .. assignedChannel)
		end
	end)
end)

-- Hook for voice chat addons (e.g., vVoice, Simple Voice Chat, etc.)
hook.Add("NRCHUD_PlayerChannelChanged", "NRCHUD_VoiceIntegration", function(ply, channelName, channelData)
	-- Example integration with vVoice or other voice addons
	-- Customize based on your voice chat addon
	
	if ply.NRCHUDData and ply.NRCHUDData.voiceAutoSwitch then
		-- Example: Switch voice channel
		-- VoiceAddon.SetChannel(ply, channelName)
		
		NRCHUD.Debug("Voice channel switch for " .. ply:Nick() .. ": " .. channelName)
	end
end)

-- Cleanup old custom channels (older than 24 hours)
timer.Create("NRCHUD_CleanupCustomChannels", 3600, 0, function()
	local currentTime = os.time()
	for channelName, channelData in pairs(NRCHUD.CustomChannels) do
		if channelData.created and (currentTime - channelData.created) > 86400 then
			NRCHUD.CommsFrequencies[channelName] = nil
			NRCHUD.CustomChannels[channelName] = nil
			NRCHUD.Debug("Cleaned up old custom channel: " .. channelName)
		end
	end
end)

print("[NRC HUD] Advanced comms system loaded!")