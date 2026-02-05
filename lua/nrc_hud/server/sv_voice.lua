-- NRC Star Wars HUD - Voice System (Server)

util.AddNetworkString("NRCHUD_VoiceMute")
util.AddNetworkString("NRCHUD_VoiceSpeakers")

NRCHUD.Voice = NRCHUD.Voice or {}
NRCHUD.Voice.Muted = NRCHUD.Voice.Muted or {}
NRCHUD.Voice.ChannelSpeakers = NRCHUD.Voice.ChannelSpeakers or {}

-- Player mute toggle
net.Receive("NRCHUD_VoiceMute", function(len, ply)
	local muted = net.ReadBool()
	NRCHUD.Voice.Muted[ply] = muted
	
	if muted then
		ply:SetNWBool("NRCHUD_Muted", true)
	else
		ply:SetNWBool("NRCHUD_Muted", false)
	end
end)

-- Voice start hook
hook.Add("PlayerStartVoice", "NRCHUD_VoiceStartSV", function(ply)
	if not IsValid(ply) then return end
	
	-- Check if muted
	if NRCHUD.Voice.Muted[ply] then
		return false -- Block voice
	end
	
	-- Get player channel
	local channel = ply.NRCHUDCommsChannel or "Battalion Net"
	
	-- Add to channel speakers
	NRCHUD.Voice.ChannelSpeakers[ply] = {
		name = ply:Nick(),
		rank = ply:getDarkRPVar("job") or "Unknown",
		channel = channel,
		startTime = CurTime(),
	}
	
	-- Broadcast to players in same channel
	BroadcastChannelSpeakers(channel)
end)

-- Voice end hook
hook.Add("PlayerEndVoice", "NRCHUD_VoiceEndSV", function(ply)
	if not IsValid(ply) then return end
	
	local channel = ply.NRCHUDCommsChannel or "Battalion Net"
	NRCHUD.Voice.ChannelSpeakers[ply] = nil
	
	-- Broadcast to players in same channel
	BroadcastChannelSpeakers(channel)
end)

-- Cleanup on disconnect
hook.Add("PlayerDisconnected", "NRCHUD_VoiceCleanupSV", function(ply)
	NRCHUD.Voice.Muted[ply] = nil
	NRCHUD.Voice.ChannelSpeakers[ply] = nil
end)

-- Broadcast channel speakers
function BroadcastChannelSpeakers(channel)
	local speakers = {}
	
	for ply, data in pairs(NRCHUD.Voice.ChannelSpeakers) do
		if IsValid(ply) and data.channel == channel then
			table.insert(speakers, {ply = ply, data = data})
		end
	end
	
	-- Send to all players in channel
	for _, target in ipairs(player.GetAll()) do
		if target.NRCHUDCommsChannel == channel then
			net.Start("NRCHUD_VoiceSpeakers")
				net.WriteUInt(#speakers, 8)
				
				for _, speaker in ipairs(speakers) do
					net.WriteEntity(speaker.ply)
					net.WriteString(speaker.data.name)
					net.WriteString(speaker.data.rank)
					net.WriteString(speaker.data.channel)
				end
				
			net.Send(target)
		end
	end
end

-- Voice hearing control (DarkRP range-based)
hook.Add("PlayerCanHearPlayersVoice", "NRCHUD_VoiceRange", function(listener, speaker)
	if not IsValid(listener) or not IsValid(speaker) then return end
	
	-- Check if muted
	if NRCHUD.Voice.Muted[speaker] then
		return false
	end
	
	-- Check if in same channel
	local listenerChannel = listener.NRCHUDCommsChannel or "Battalion Net"
	local speakerChannel = speaker.NRCHUDCommsChannel or "Battalion Net"
	
	if listenerChannel == speakerChannel then
		return true -- Same channel = can hear
	end
	
	-- Emergency channel can be heard by all
	if speakerChannel == "Emergency" then
		return true
	end
	
	-- Otherwise, use proximity (default GMod behavior)
	-- Return nil to let GMod decide based on distance
	return nil
end)

print("[NRC HUD] Voice system (Server) loaded!")