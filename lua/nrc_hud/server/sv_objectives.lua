-- NRC Star Wars HUD - Objectives System (Server)

NRCHUD.Objectives = NRCHUD.Objectives or {}
NRCHUD.ObjectiveCounter = NRCHUD.ObjectiveCounter or 0

-- Create a new objective
function NRCHUD.CreateObjective(text, targetJob, targetRank, priority, timeout, creator)
	NRCHUD.ObjectiveCounter = NRCHUD.ObjectiveCounter + 1
	
	local objective = {
		id = NRCHUD.ObjectiveCounter,
		text = text or "No objective set",
		targetJob = targetJob or "all",
		targetRank = targetRank or "all",
		priority = priority or 1,
		createdTime = CurTime(),
		timeout = timeout or NRCHUD.Config.ObjectiveTimeout,
		creator = IsValid(creator) and creator:Nick() or "Command"
	}
	
	NRCHUD.Objectives[objective.id] = objective
	
	-- Send to all affected players
	for _, ply in ipairs(player.GetAll()) do
		if NRCHUD.IsObjectiveForPlayer(ply, objective) then
			NRCHUD.SendObjective(ply, objective)
		end
	end
	
	NRCHUD.Debug("Objective created: " .. text)
	return objective.id
end

-- Remove an objective
function NRCHUD.RemoveObjective(objectiveID)
	if not NRCHUD.Objectives[objectiveID] then return false end
	
	NRCHUD.Objectives[objectiveID] = nil
	
	-- Notify all players
	for _, ply in ipairs(player.GetAll()) do
		net.Start("NRCHUD_RemoveObjective")
			net.WriteUInt(objectiveID, 32)
		net.Send(ply)
	end
	
	NRCHUD.Debug("Objective removed: " .. objectiveID)
	return true
end

-- Check if objective is for player
function NRCHUD.IsObjectiveForPlayer(ply, objective)
	if not IsValid(ply) or not objective then return false end
	
	-- Check if objective is for all
	if objective.targetJob == "all" and objective.targetRank == "all" then
		return true
	end
	
	-- Check job
	local playerJob = "Unknown"
	if DarkRP and ply.getDarkRPVar then
		playerJob = ply:getDarkRPVar("job") or team.GetName(ply:Team())
	end
	
	if objective.targetJob ~= "all" and objective.targetJob ~= playerJob then
		return false
	end
	
	-- Check rank (MRS)
	if NRCHUD.Config.MRSEnabled and MRS and objective.targetRank ~= "all" then
		local mrsRank = MRS:GetRank(ply)
		if not mrsRank or mrsRank.name ~= objective.targetRank then
			return false
		end
	end
	
	return true
end

-- Send objective to player
function NRCHUD.SendObjective(ply, objective)
	if not IsValid(ply) or not objective then return end
	
	net.Start("NRCHUD_SendObjective")
		net.WriteUInt(objective.id, 32)
		net.WriteString(objective.text)
		net.WriteString(objective.targetJob)
		net.WriteString(objective.targetRank)
		net.WriteUInt(objective.priority, 8)
		net.WriteFloat(objective.createdTime)
		net.WriteFloat(objective.timeout)
		net.WriteString(objective.creator)
	net.Send(ply)
end

-- Update objectives for player (on spawn, job change, etc.)
function NRCHUD.UpdatePlayerObjectives(ply)
	if not IsValid(ply) then return end
	
	-- Clear old objectives first
	for id, _ in pairs(NRCHUD.Objectives) do
		net.Start("NRCHUD_RemoveObjective")
			net.WriteUInt(id, 32)
		net.Send(ply)
	end
	
	-- Send relevant objectives
	for _, objective in pairs(NRCHUD.Objectives) do
		if NRCHUD.IsObjectiveForPlayer(ply, objective) then
			NRCHUD.SendObjective(ply, objective)
		end
	end
end

-- Check if player can create objectives (Commander)
function NRCHUD.IsCommander(ply)
	if not IsValid(ply) then return false end
	
	-- Check if superadmin
	if ply:IsSuperAdmin() then return true end
	
	-- Check MRS rank
	if NRCHUD.Config.MRSEnabled and MRS then
		local rank = MRS:GetRank(ply)
		if rank then
			for _, cmdRank in ipairs(NRCHUD.Config.CommanderRanks) do
				if rank.name == cmdRank then
					return true
				end
			end
		end
	end
	
	-- Check job name
	if DarkRP and ply.getDarkRPVar then
		local job = ply:getDarkRPVar("job") or team.GetName(ply:Team())
		for _, cmdRank in ipairs(NRCHUD.Config.CommanderRanks) do
			if string.find(string.lower(job), string.lower(cmdRank)) then
				return true
			end
		end
	end
	
	return false
end

-- Network receiver for objective creation
net.Receive("NRCHUD_RequestObjectiveCreate", function(len, ply)
	if not NRCHUD.IsCommander(ply) then
		DarkRP.notify(ply, 1, 4, "You don't have permission to create objectives!")
		return
	end
	
	local text = net.ReadString()
	local targetJob = net.ReadString()
	local targetRank = net.ReadString()
	local priority = net.ReadUInt(8)
	local timeout = net.ReadFloat()
	
	local id = NRCHUD.CreateObjective(text, targetJob, targetRank, priority, timeout, ply)
	
	if DarkRP then
		DarkRP.notify(ply, 0, 4, "Objective created successfully!")
	end
end)

-- Network receiver for objective removal
net.Receive("NRCHUD_RequestObjectiveRemove", function(len, ply)
	if not NRCHUD.IsCommander(ply) then
		DarkRP.notify(ply, 1, 4, "You don't have permission to remove objectives!")
		return
	end
	
	local objectiveID = net.ReadUInt(32)
	
	if NRCHUD.RemoveObjective(objectiveID) then
		if DarkRP then
			DarkRP.notify(ply, 0, 4, "Objective removed successfully!")
		end
	else
		if DarkRP then
			DarkRP.notify(ply, 1, 4, "Objective not found!")
		end
	end
end)

-- Update objectives on player spawn
hook.Add("PlayerSpawn", "NRCHUD_UpdateObjectives", function(ply)
	timer.Simple(0.5, function()
		if IsValid(ply) then
			NRCHUD.UpdatePlayerObjectives(ply)
		end
	end)
end)

-- Update objectives on job change
hook.Add("OnPlayerChangedTeam", "NRCHUD_UpdateObjectives", function(ply)
	timer.Simple(0.5, function()
		if IsValid(ply) then
			NRCHUD.UpdatePlayerObjectives(ply)
		end
	end)
end)

-- Cleanup expired objectives
timer.Create("NRCHUD_CleanupObjectives", 60, 0, function()
	local currentTime = CurTime()
	for id, objective in pairs(NRCHUD.Objectives) do
		if (currentTime - objective.createdTime) > objective.timeout then
			NRCHUD.RemoveObjective(id)
			NRCHUD.Debug("Objective expired: " .. id)
		end
	end
end)

print("[NRC HUD] Objectives system loaded!")