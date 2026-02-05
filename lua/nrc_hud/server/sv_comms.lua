-- NRC Star Wars HUD - Communications System (Server)

-- Network strings
util.AddNetworkString("NRCHUD_UpdateComms")
util.AddNetworkString("NRCHUD_UpdatePlayerData")

NRCHUD.PlayerComms = NRCHUD.PlayerComms or {}

-- Update player comms data
function NRCHUD.UpdatePlayerComms(ply)
	if not IsValid(ply) then return end
	if not ply.NRCHUDData then ply.NRCHUDData = {} end
	
	local data = ply.NRCHUDData
	
	-- Send to client
	net.Start("NRCHUD_UpdateComms")
		net.WriteString(data.commsChannel or "Battalion Net")
		net.WriteString(data.frequency or "445.750 MHz")
	net.Send(ply)
end

-- Get player comms channel
function NRCHUD.GetPlayerChannel(ply)
	if not IsValid(ply) then return "Battalion Net" end
	if not ply.NRCHUDData then return "Battalion Net" end
	return ply.NRCHUDData.commsChannel or "Battalion Net"
end

-- Get player frequency
function NRCHUD.GetPlayerFrequency(ply)
	if not IsValid(ply) then return "445.750 MHz" end
	if not ply.NRCHUDData then return "445.750 MHz" end
	return ply.NRCHUDData.frequency or "445.750 MHz"
end

print("[NRC HUD] Comms system loaded!")