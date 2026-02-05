-- NRC Star Wars HUD - Communications System (Server)

-- Update player comms channel
function NRCHUD.SetCommsChannel(ply, channel)
	if not IsValid(ply) then return end
	if not NRCHUD.Config.CommsChannels[channel] then return end
	
	if not ply.NRCHUDData then
		ply.NRCHUDData = {}
	end
	
	ply.NRCHUDData.commsChannel = channel
	
	NRCHUD.UpdatePlayerComms(ply)
end

-- Set custom frequency
function NRCHUD.SetFrequency(ply, frequency)
	if not IsValid(ply) then return end
	
	if not ply.NRCHUDData then
		ply.NRCHUDData = {}
	end
	
	ply.NRCHUDData.frequency = frequency
	
	NRCHUD.UpdatePlayerComms(ply)
end

-- Update player comms display
function NRCHUD.UpdatePlayerComms(ply)
	if not IsValid(ply) then return end
	
	if not ply.NRCHUDData then
		ply.NRCHUDData = {
			commsChannel = NRCHUD.Config.DefaultCommsChannel,
			frequency = NRCHUD.Config.DefaultFrequency
		}
	end
	
	local channel = ply.NRCHUDData.commsChannel or NRCHUD.Config.DefaultCommsChannel
	local frequency = ply.NRCHUDData.frequency or NRCHUD.Config.DefaultFrequency
	
	net.Start("NRCHUD_UpdateComms")
		net.WriteUInt(channel, 8)
		net.WriteString(frequency)
	net.Send(ply)
end

-- Get players on same comms channel
function NRCHUD.GetPlayersOnChannel(channel)
	local players = {}
	
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply.NRCHUDData and ply.NRCHUDData.commsChannel == channel then
			table.insert(players, ply)
		end
	end
	
	return players
end

print("[NRC HUD] Communications system loaded!")