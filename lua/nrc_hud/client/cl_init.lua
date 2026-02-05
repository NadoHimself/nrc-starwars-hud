-- NRC Star Wars HUD - Client Initialization

include("nrc_hud/shared/sh_config.lua")

NRCHUD.PlayerData = NRCHUD.PlayerData or {
	name = "Unknown",
	rank = "Trooper",
	job = "Unknown",
	currency = 0,
	commsChannel = 1,
	frequency = "445.7 MHz",
	objectives = {},
	currentObjective = nil
}

-- Receive identity update
net.Receive("NRCHUD_UpdateIdentity", function()
	NRCHUD.PlayerData.name = net.ReadString()
	NRCHUD.PlayerData.rank = net.ReadString()
	NRCHUD.PlayerData.job = net.ReadString()
	
	NRCHUD.Debug("Identity updated: " .. NRCHUD.PlayerData.name)
end)

-- Receive currency update
net.Receive("NRCHUD_UpdateCurrency", function()
	NRCHUD.PlayerData.currency = net.ReadUInt(32)
end)

-- Receive comms update
net.Receive("NRCHUD_UpdateComms", function()
	NRCHUD.PlayerData.commsChannel = net.ReadUInt(8)
	NRCHUD.PlayerData.frequency = net.ReadString()
end)

-- Hit marker
NRCHUD.ShowingHitMarker = false
net.Receive("NRCHUD_HitMarker", function()
	NRCHUD.ShowingHitMarker = true
	surface.PlaySound("buttons/lightswitch2.wav")
	
	timer.Simple(NRCHUD.Config.HitMarkerDuration, function()
		NRCHUD.ShowingHitMarker = false
	end)
end)

-- Damage indicator
NRCHUD.DamageIndicators = NRCHUD.DamageIndicators or {}
net.Receive("NRCHUD_DamageIndicator", function()
	local direction = net.ReadString()
	
	NRCHUD.DamageIndicators[direction] = CurTime() + NRCHUD.Config.DamageIndicatorDuration
	surface.PlaySound("player/pl_pain" .. math.random(5, 7) .. ".wav")
end)

-- Get grid coordinates for location display
function NRCHUD.GetGridLocation()
	local ply = LocalPlayer()
	if not IsValid(ply) then return "GRID 000-A" end
	
	local pos = ply:GetPos()
	local gridX = math.floor(pos.x / 1000) + 500
	local gridY = math.floor(pos.y / 1000) + 500
	local gridLetter = string.char(65 + (math.abs(gridY) % 26))
	
	return string.format("GRID %03d-%s", math.abs(gridX) % 1000, gridLetter)
end

-- Cycle comms channel
function NRCHUD.CycleCommsChannel()
	local current = NRCHUD.PlayerData.commsChannel
	local next = current + 1
	
	if next > #NRCHUD.Config.CommsChannels then
		next = 1
	end
	
	NRCHUD.PlayerData.commsChannel = next
	
	-- Play sound
	surface.PlaySound("buttons/button14.wav")
	
	-- Notify
	local channelData = NRCHUD.Config.CommsChannels[next]
	if channelData then
		chat.AddText(Color(255, 255, 255), "[COMMS] Switched to channel: ", channelData.color, channelData.name)
	end
end

-- Bind comms key
concommand.Add("nrc_comms_cycle", function()
	NRCHUD.CycleCommsChannel()
end)

-- Auto-bind B key on first load
hook.Add("PlayerBindPress", "NRCHUD_CommsBinding", function(ply, bind, pressed)
	if bind == "impulse 100" and pressed then -- B key
		NRCHUD.CycleCommsChannel()
		return true
	end
end)

print("[NRC HUD] Client initialization complete!")