-- NRC Star Wars HUD - Commander Menu (F4)

NRCHUD.CommanderMenuOpen = false
NRCHUD.AvailableJobs = {}
NRCHUD.AvailableRanks = {}

-- Get available jobs
function NRCHUD.GetAvailableJobs()
	local jobs = {"all"}
	
	if RPExtraTeams then
		for k, v in pairs(RPExtraTeams) do
			if v.name then
				table.insert(jobs, v.name)
			end
		end
	else
		-- Fallback to team names
		for i = 0, team.NumTeams() - 1 do
			local name = team.GetName(i)
			if name and name ~= "" then
				table.insert(jobs, name)
			end
		end
	end
	
	return jobs
end

-- Get available ranks (from MRS if available) - FIXED
function NRCHUD.GetAvailableRanks()
	local ranks = {"all"}
	
	-- Check if MRS exists and is properly initialized
	if MRS and type(MRS) == "table" then
		-- Try different MRS API methods
		if MRS.GetRanks and type(MRS.GetRanks) == "function" then
			local success, mrsRanks = pcall(MRS.GetRanks, MRS)
			if success and mrsRanks and type(mrsRanks) == "table" then
				for _, rank in ipairs(mrsRanks) do
					if rank and type(rank) == "table" and rank.name then
						table.insert(ranks, rank.name)
					end
				end
				return ranks
			end
		end
		
		-- Try alternative MRS API
		if MRS.Ranks and type(MRS.Ranks) == "table" then
			for _, rank in pairs(MRS.Ranks) do
				if rank and type(rank) == "table" and rank.name then
					table.insert(ranks, rank.name)
				end
			end
			return ranks
		end
	end
	
	-- Fallback to default ranks if MRS not available
	ranks = {
		"all",
		"Trooper",
		"Corporal",
		"Sergeant",
		"Lieutenant",
		"Captain",
		"Major",
		"Commander",
		"Marshal Commander"
	}
	
	return ranks
end

-- Open commander menu
function NRCHUD.OpenCommanderMenu()
	if NRCHUD.CommanderMenuOpen then return end
	
	NRCHUD.CommanderMenuOpen = true
	
	-- Get available options
	NRCHUD.AvailableJobs = NRCHUD.GetAvailableJobs()
	NRCHUD.AvailableRanks = NRCHUD.GetAvailableRanks()
	
	-- Create frame
	local frame = vgui.Create("DFrame")
	frame:SetSize(600, 500)
	frame:Center()
	frame:SetTitle("Commander Control Panel")
	frame:SetVisible(true)
	frame:SetDraggable(true)
	frame:ShowCloseButton(true)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 250))
		draw.RoundedBox(0, 0, 0, w, 25, Color(40, 40, 40, 255))
	end
	frame.OnClose = function()
		NRCHUD.CommanderMenuOpen = false
	end
	
	-- Title label
	local titleLabel = vgui.Create("DLabel", frame)
	titleLabel:SetPos(10, 35)
	titleLabel:SetSize(580, 20)
	titleLabel:SetText("Create New Objective")
	titleLabel:SetFont("DermaLarge")
	titleLabel:SetTextColor(Color(255, 255, 255))
	
	-- Objective text
	local textLabel = vgui.Create("DLabel", frame)
	textLabel:SetPos(10, 70)
	textLabel:SetSize(580, 20)
	textLabel:SetText("Objective Description:")
	textLabel:SetTextColor(Color(200, 200, 200))
	
	local textEntry = vgui.Create("DTextEntry", frame)
	textEntry:SetPos(10, 95)
	textEntry:SetSize(580, 30)
	textEntry:SetPlaceholderText("Enter objective description...")
	
	-- Target job
	local jobLabel = vgui.Create("DLabel", frame)
	jobLabel:SetPos(10, 135)
	jobLabel:SetSize(280, 20)
	jobLabel:SetText("Target Job:")
	jobLabel:SetTextColor(Color(200, 200, 200))
	
	local jobCombo = vgui.Create("DComboBox", frame)
	jobCombo:SetPos(10, 160)
	jobCombo:SetSize(280, 30)
	jobCombo:SetValue("All Jobs")
	for _, job in ipairs(NRCHUD.AvailableJobs) do
		jobCombo:AddChoice(job)
	end
	
	-- Target rank
	local rankLabel = vgui.Create("DLabel", frame)
	rankLabel:SetPos(310, 135)
	rankLabel:SetSize(280, 20)
	rankLabel:SetText("Target Rank:")
	rankLabel:SetTextColor(Color(200, 200, 200))
	
	local rankCombo = vgui.Create("DComboBox", frame)
	rankCombo:SetPos(310, 160)
	rankCombo:SetSize(280, 30)
	rankCombo:SetValue("All Ranks")
	for _, rank in ipairs(NRCHUD.AvailableRanks) do
		rankCombo:AddChoice(rank)
	end
	
	-- Priority
	local priorityLabel = vgui.Create("DLabel", frame)
	priorityLabel:SetPos(10, 200)
	priorityLabel:SetSize(280, 20)
	priorityLabel:SetText("Priority (1-5):")
	priorityLabel:SetTextColor(Color(200, 200, 200))
	
	local prioritySlider = vgui.Create("DNumSlider", frame)
	prioritySlider:SetPos(10, 220)
	prioritySlider:SetSize(280, 30)
	prioritySlider:SetMin(1)
	prioritySlider:SetMax(5)
	prioritySlider:SetDecimals(0)
	prioritySlider:SetValue(1)
	prioritySlider:SetDark(true)
	
	-- Timeout
	local timeoutLabel = vgui.Create("DLabel", frame)
	timeoutLabel:SetPos(310, 200)
	timeoutLabel:SetSize(280, 20)
	timeoutLabel:SetText("Timeout (minutes):")
	timeoutLabel:SetTextColor(Color(200, 200, 200))
	
	local timeoutSlider = vgui.Create("DNumSlider", frame)
	timeoutSlider:SetPos(310, 220)
	timeoutSlider:SetSize(280, 30)
	timeoutSlider:SetMin(5)
	timeoutSlider:SetMax(120)
	timeoutSlider:SetDecimals(0)
	timeoutSlider:SetValue(60)
	timeoutSlider:SetDark(true)
	
	-- Create button
	local createBtn = vgui.Create("DButton", frame)
	createBtn:SetPos(10, 270)
	createBtn:SetSize(280, 40)
	createBtn:SetText("Create Objective")
	createBtn:SetTextColor(Color(255, 255, 255))
	createBtn.Paint = function(self, w, h)
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(76, 222, 128, 255))
		else
			draw.RoundedBox(0, 0, 0, w, h, Color(76, 222, 128, 200))
		end
	end
	createBtn.DoClick = function()
		local text = textEntry:GetValue()
		
		if text == "" then
			Notification("Please enter an objective description!", NOTIFY_ERROR, 3)
			return
		end
		
		local targetJob = jobCombo:GetValue()
		local targetRank = rankCombo:GetValue()
		local priority = math.floor(prioritySlider:GetValue())
		local timeout = math.floor(timeoutSlider:GetValue() * 60)
		
		-- Send to server
		net.Start("NRCHUD_RequestObjectiveCreate")
			net.WriteString(text)
			net.WriteString(targetJob)
			net.WriteString(targetRank)
			net.WriteUInt(priority, 8)
			net.WriteFloat(timeout)
		net.SendToServer()
		
		Notification("Objective created!", NOTIFY_GENERIC, 3)
		frame:Close()
	end
	
	-- Active objectives list
	local activeLabel = vgui.Create("DLabel", frame)
	activeLabel:SetPos(10, 320)
	activeLabel:SetSize(580, 20)
	activeLabel:SetText("Active Objectives:")
	activeLabel:SetFont("DermaLarge")
	activeLabel:SetTextColor(Color(255, 255, 255))
	
	local objectiveList = vgui.Create("DListView", frame)
	objectiveList:SetPos(10, 350)
	objectiveList:SetSize(580, 110)
	objectiveList:SetMultiSelect(false)
	objectiveList:AddColumn("ID")
	objectiveList:AddColumn("Description")
	objectiveList:AddColumn("Job")
	objectiveList:AddColumn("Rank")
	objectiveList:AddColumn("Priority")
	
	-- Populate with current objectives
	for id, objective in pairs(NRCHUD.PlayerData.objectives) do
		objectiveList:AddLine(id, objective.text, objective.targetJob, objective.targetRank, objective.priority)
	end
	
	-- Remove button
	local removeBtn = vgui.Create("DButton", frame)
	removeBtn:SetPos(310, 465)
	removeBtn:SetSize(280, 30)
	removeBtn:SetText("Remove Selected Objective")
	removeBtn:SetTextColor(Color(255, 255, 255))
	removeBtn.Paint = function(self, w, h)
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(239, 68, 68, 255))
		else
			draw.RoundedBox(0, 0, 0, w, h, Color(239, 68, 68, 200))
		end
	end
	removeBtn.DoClick = function()
		local selected = objectiveList:GetSelectedLine()
		
		if not selected then
			Notification("Please select an objective to remove!", NOTIFY_ERROR, 3)
			return
		end
		
		local line = objectiveList:GetLine(selected)
		local objectiveID = tonumber(line:GetValue(1))
		
		-- Send to server
		net.Start("NRCHUD_RequestObjectiveRemove")
			net.WriteUInt(objectiveID, 32)
		net.SendToServer()
		
		Notification("Objective removed!", NOTIFY_GENERIC, 3)
		objectiveList:RemoveLine(selected)
	end
end

-- Bind F4 key for commanders
hook.Add("PlayerBindPress", "NRCHUD_CommanderMenu", function(ply, bind, pressed)
	if bind == "gm_showspare2" and pressed then -- F4 key
		if NRCHUD.CommanderMenuOpen then return end
		
		-- Check if player is commander (will be validated server-side)
		NRCHUD.OpenCommanderMenu()
		return true
	end
end)

-- Console command
concommand.Add("nrc_commander_menu", function()
	NRCHUD.OpenCommanderMenu()
end)

print("[NRC HUD] Commander menu loaded!")