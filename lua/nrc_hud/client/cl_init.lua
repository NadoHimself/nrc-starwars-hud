-- NRC Star Wars HUD - Client Initialization

-- Initialize NRCHUD namespace
NRCHUD = NRCHUD or {}

-- Initialize PlayerData table
NRCHUD.PlayerData = NRCHUD.PlayerData or {
	name = "Unknown",
	job = "Unknown",
	rank = "Trooper",
	commsChannel = "Battalion Net",
	currency = 0,
	objective = "",
	location = "GRID 447-B",
	voiceAutoSwitch = false,
	objectives = {}
}

-- Initialize other tables
NRCHUD.DamageIndicators = NRCHUD.DamageIndicators or {}
NRCHUD.ShowingHitMarker = false
NRCHUD.Objectives = NRCHUD.Objectives or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}

-- Create fonts for objectives display
surface.CreateFont("NRCHUD_Objective_Label", {
	font = "Orbitron",
	size = 14,
	weight = 600,
	antialias = true,
	extended = true
})

surface.CreateFont("NRCHUD_Objective_Text", {
	font = "Orbitron",
	size = 16,
	weight = 700,
	antialias = true,
	extended = true
})

-- Create fonts for comms display
surface.CreateFont("NRCHUD_Comms_Label", {
	font = "Share Tech Mono",
	size = 11,
	weight = 400,
	antialias = true,
	extended = true
})

surface.CreateFont("NRCHUD_Comms_Value", {
	font = "Share Tech Mono",
	size = 14,
	weight = 600,
	antialias = true,
	extended = true
})

-- Update player data from DarkRP
local function UpdatePlayerData()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	-- Update name
	NRCHUD.PlayerData.name = ply:Nick()
	
	-- Update job
	if DarkRP and ply.getDarkRPVar then
		NRCHUD.PlayerData.job = ply:getDarkRPVar("job") or team.GetName(ply:Team()) or "Civilian"
	else
		NRCHUD.PlayerData.job = team.GetName(ply:Team()) or "Civilian"
	end
	
	-- Update currency
	if DarkRP and ply.getDarkRPVar then
		NRCHUD.PlayerData.currency = ply:getDarkRPVar("money") or 0
	elseif ply.GetMoney then
		NRCHUD.PlayerData.currency = ply:GetMoney() or 0
	end
end

-- Update on spawn
hook.Add("InitPostEntity", "NRCHUD_InitPlayerData", function()
	timer.Simple(1, function()
		UpdatePlayerData()
	end)
end)

-- Update periodically
timer.Create("NRCHUD_UpdatePlayerData", 5, 0, function()
	UpdatePlayerData()
end)

-- Hit marker system
function NRCHUD.ShowHitMarker()
	NRCHUD.ShowingHitMarker = true
	timer.Simple(0.15, function()
		NRCHUD.ShowingHitMarker = false
	end)
end

-- Damage indicator system
function NRCHUD.ShowDamageIndicator(direction)
	NRCHUD.DamageIndicators[direction] = CurTime() + (NRCHUD.Config.DamageIndicatorDuration or 0.4)
end

-- Detect hit
hook.Add("OnEntityCreated", "NRCHUD_DetectHit", function(ent)
	if not IsValid(ent) then return end
	
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		
		if ent:GetClass() == "entityflame" then
			local owner = ent:GetOwner()
			if IsValid(owner) and owner == LocalPlayer() then
				NRCHUD.ShowHitMarker()
			end
		end
	end)
end)

-- Detect damage taken
hook.Add("EntityTakeDamage", "NRCHUD_DetectDamage", function(target, dmg)
	if target ~= LocalPlayer() then return end
	
	local attacker = dmg:GetAttacker()
	if not IsValid(attacker) then return end
	
	-- Calculate direction
	local ply = LocalPlayer()
	local attackerPos = attacker:GetPos()
	local playerPos = ply:GetPos()
	local playerAng = ply:EyeAngles().y
	
	local dirToAttacker = (attackerPos - playerPos):Angle().y
	local relativeAngle = math.NormalizeAngle(dirToAttacker - playerAng)
	
	local direction
	if math.abs(relativeAngle) < 45 then
		direction = "Top"
	elseif math.abs(relativeAngle) > 135 then
		direction = "Bottom"
	elseif relativeAngle < 0 then
		direction = "Left"
	else
		direction = "Right"
	end
	
	NRCHUD.ShowDamageIndicator(direction)
end)

print("[NRC HUD] Client initialization complete!")