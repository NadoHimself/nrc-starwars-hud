-- NRC Star Wars HUD - Advanced Comms System (Server)

util.AddNetworkString("NRCHUD_SwitchChannel")
util.AddNetworkString("NRCHUD_CreateCustomChannel")
util.AddNetworkString("NRCHUD_ChannelUpdate")
util.AddNetworkString("NRCHUD_VoiceSettings")
util.AddNetworkString("NRCHUD_ChannelUserCount")
util.AddNetworkString("NRCHUD_RefreshChannels")

include("nrc_hud/shared/sh_comms_config.lua")
AddCSLuaFile("nrc_hud/shared/sh_comms_config.lua")
AddCSLuaFile("nrc_hud/client/cl_comms_menu.lua")

-- Custom channels storage
NRCHUD.CustomChannels = NRCHUD.CustomChannels or {}
NRCHUD.ChannelUsers = NRCHUD.ChannelUsers or {}

-- Helper for debug
function NRCHUD.Debug(msg)
	if NRCHUD.Config and NRCHUD.Config.Debug then
		print("[NRC HUD DEBUG] " .. tostring(msg))
	end
end

-- Get user count for channel
function NRCHUD.GetChannelUserCount(channelName)
	local count = 0
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply.NRCHUDData and ply.NRCHUDData.commsChannel == channelName then
			count = count + 1
		end
	end
	return count
end

-- Broadcast user counts to all players
function NRCHUD.BroadcastUserCounts()
	local counts = {}
	for channelName, _ in pairs(NRCHUD.CommsFrequencies) do
		counts[channelName] = NRCHUD.GetChannelUserCount(channelName)
	end
	
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) then
			net.Start("NRCHUD_ChannelUserCount")
				net.WriteTable(counts)
			net.Send(ply)
		end
	end
end

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
	
	-- Broadcast new user counts
	NRCHUD.BroadcastUserCounts()
	
	-- Voice chat integration (if supported)
	if NRCHUD.VoiceIntegration and NRCHUD.VoiceIntegration.enabled then
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
	
	-- Auto-add MHz if not present
	if not string.find(frequency:lower(), "mhz") and not string.find(frequency:lower(), "ghz") then
		frequency = frequency .. " MHz"
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
			
			-- Broadcast user counts
			timer.Simple(0.5, function()
				NRCHUD.BroadcastUserCounts()
			end)
			
			NRCHUD.Debug("Assigned " .. ply:Nick() .. " to channel: " .. assignedChannel)
		end
	end)
end)

-- Hook for voice chat addons
hook.Add("NRCHUD_PlayerChannelChanged", "NRCHUD_VoiceIntegration", function(ply, channelName, channelData)
	if ply.NRCHUDData and ply.NRCHUDData.voiceAutoSwitch then
		NRCHUD.Debug("Voice channel switch for " .. ply:Nick() .. ": " .. channelName)
	end
end)

-- Broadcast user counts every 5 seconds
timer.Create("NRCHUD_BroadcastUserCounts", 5, 0, function()
	NRCHUD.BroadcastUserCounts()
end)

-- Cleanup old custom channels
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