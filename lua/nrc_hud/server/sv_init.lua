-- NRC Star Wars HUD - Server Initialization

util.AddNetworkString("NRCHUD_SendObjective")
util.AddNetworkString("NRCHUD_RemoveObjective")
util.AddNetworkString("NRCHUD_UpdateCurrency")
util.AddNetworkString("NRCHUD_UpdateComms")
util.AddNetworkString("NRCHUD_UpdateIdentity")
util.AddNetworkString("NRCHUD_HitMarker")
util.AddNetworkString("NRCHUD_DamageIndicator")
util.AddNetworkString("NRCHUD_RequestObjectiveCreate")
util.AddNetworkString("NRCHUD_RequestObjectiveRemove")
util.AddNetworkString("NRCHUD_MinimapData")

AddCSLuaFile("nrc_hud/client/cl_init.lua")
AddCSLuaFile("nrc_hud/client/cl_hud.lua")
AddCSLuaFile("nrc_hud/client/cl_objectives.lua")
AddCSLuaFile("nrc_hud/client/cl_commander_menu.lua")
AddCSLuaFile("nrc_hud/shared/sh_config.lua")

include("nrc_hud/shared/sh_config.lua")

-- Check for MRS
if MRS then
	NRCHUD.Config.MRSEnabled = true
	print("[NRC HUD] MRS Advanced Rank System detected!")
end

-- Check for DarkRP
if DarkRP then
	print("[NRC HUD] DarkRP detected!")
end

-- Initialize player data
function NRCHUD.InitPlayer(ply)
	if not IsValid(ply) then return end
	
	ply.NRCHUDData = {
		commsChannel = NRCHUD.Config.DefaultCommsChannel,
		frequency = NRCHUD.Config.DefaultFrequency,
		objectives = {}
	}
	
	-- Send initial data
	timer.Simple(1, function()
		if not IsValid(ply) then return end
		NRCHUD.UpdatePlayerIdentity(ply)
		NRCHUD.UpdatePlayerCurrency(ply)
		NRCHUD.UpdatePlayerComms(ply)
	end)
end

hook.Add("PlayerInitialSpawn", "NRCHUD_InitPlayer", function(ply)
	NRCHUD.InitPlayer(ply)
end)

-- Update player identity (name, rank, job)
function NRCHUD.UpdatePlayerIdentity(ply)
	if not IsValid(ply) then return end
	
	local name = ply:Nick()
	local rank = "Trooper"
	local job = "Unknown"
	
	-- Get rank from MRS if available
	if NRCHUD.Config.MRSEnabled and MRS then
		local mrsRank = MRS:GetRank(ply)
		if mrsRank then
			rank = mrsRank.name or rank
		end
	end
	
	-- Get job from DarkRP
	if DarkRP and ply:getDarkRPVar then
		job = ply:getDarkRPVar("job") or team.GetName(ply:Team())
	end
	
	net.Start("NRCHUD_UpdateIdentity")
		net.WriteString(name)
		net.WriteString(rank)
		net.WriteString(job)
	net.Send(ply)
end

-- Update on job change
hook.Add("OnPlayerChangedTeam", "NRCHUD_UpdateIdentity", function(ply, old, new)
	timer.Simple(0.1, function()
		if IsValid(ply) then
			NRCHUD.UpdatePlayerIdentity(ply)
		end
	end)
end)

-- Hit marker
hook.Add("PlayerHurt", "NRCHUD_HitMarker", function(victim, attacker)
	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
		net.Start("NRCHUD_HitMarker")
		net.Send(attacker)
	end
end)

-- Damage indicator
hook.Add("EntityTakeDamage", "NRCHUD_DamageIndicator", function(target, dmg)
	if not IsValid(target) or not target:IsPlayer() then return end
	
	local attacker = dmg:GetAttacker()
	if not IsValid(attacker) then return end
	
	local direction = (attacker:GetPos() - target:GetPos()):GetNormalized()
	local forward = target:GetForward()
	local right = target:GetRight()
	
	local dotForward = direction:Dot(forward)
	local dotRight = direction:Dot(right)
	
	local dir = "Front"
	if math.abs(dotForward) > math.abs(dotRight) then
		dir = dotForward > 0 and "Top" or "Bottom"
	else
		dir = dotRight > 0 and "Right" or "Left"
	end
	
	net.Start("NRCHUD_DamageIndicator")
		net.WriteString(dir)
	net.Send(target)
end)

print("[NRC HUD] Server initialization complete!")