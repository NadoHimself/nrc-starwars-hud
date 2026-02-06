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
util.AddNetworkString("NRCHUD_SwitchChannel")

AddCSLuaFile("nrc_hud/client/cl_init.lua")
AddCSLuaFile("nrc_hud/client/cl_hud.lua")
AddCSLuaFile("nrc_hud/client/cl_objectives.lua")
AddCSLuaFile("nrc_hud/client/cl_commander_menu.lua")
AddCSLuaFile("nrc_hud/client/cl_comms_menu.lua")
AddCSLuaFile("nrc_hud/shared/sh_config.lua")
AddCSLuaFile("nrc_hud/shared/sh_language.lua")

include("nrc_hud/shared/sh_config.lua")
include("nrc_hud/shared/sh_language.lua")

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
	
	-- Get rank from MRS if available (FIXED: Use dot notation, not colon!)
	if NRCHUD.Config.MRSEnabled and MRS and MRS.GetRank then
		local success, mrsRank = pcall(function() return MRS.GetRank(ply) end)
		if success and mrsRank and mrsRank.name then
			rank = mrsRank.name
		end
	end
	
	-- Get job from DarkRP
	if DarkRP and ply.getDarkRPVar then
		job = ply:getDarkRPVar("job") or team.GetName(ply:Team())
	end
	
	net.Start("NRCHUD_UpdateIdentity")
		net.WriteString(name)
		net.WriteString(rank)
		net.WriteString(job)
	net.Send(ply)
end

-- Update player currency
function NRCHUD.UpdatePlayerCurrency(ply)
	if not IsValid(ply) then return end
	
	local money = 0
	if DarkRP and ply.getDarkRPVar then
		money = ply:getDarkRPVar("money") or 0
	elseif ply.GetMoney then
		money = ply:GetMoney() or 0
	end
	
	net.Start("NRCHUD_UpdateCurrency")
		net.WriteUInt(money, 32)
	net.Send(ply)
end

-- Update player comms
function NRCHUD.UpdatePlayerComms(ply)
	if not IsValid(ply) then return end
	
	local channel = ply.NRCHUDData and ply.NRCHUDData.commsChannel or NRCHUD.Config.DefaultCommsChannel
	local freq = ply.NRCHUDData and ply.NRCHUDData.frequency or NRCHUD.Config.DefaultFrequency
	
	net.Start("NRCHUD_UpdateComms")
		net.WriteUInt(channel, 8)
		net.WriteString(freq)
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

-- Channel switch network handler
net.Receive("NRCHUD_SwitchChannel", function(len, ply)
	if not IsValid(ply) then return end
	
	local channelName = net.ReadString()
	
	-- Update player data
	if not ply.NRCHUDData then
		ply.NRCHUDData = {}
	end
	
	ply.NRCHUDData.commsChannel = channelName
	
	-- Broadcast to other players on same channel (optional)
	print(string.format("[NRC HUD] %s switched to channel: %s", ply:Nick(), channelName))
end)

print("[NRC HUD] Server initialization complete!")