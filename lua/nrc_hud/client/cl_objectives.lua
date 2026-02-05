-- NRC Star Wars HUD - Objectives Display (Client)

-- Receive objective
net.Receive("NRCHUD_SendObjective", function()
	local id = net.ReadUInt(32)
	local text = net.ReadString()
	local targetJob = net.ReadString()
	local targetRank = net.ReadString()
	local priority = net.ReadUInt(8)
	local createdTime = net.ReadFloat()
	local timeout = net.ReadFloat()
	local creator = net.ReadString()
	
	NRCHUD.PlayerData.objectives[id] = {
		id = id,
		text = text,
		targetJob = targetJob,
		targetRank = targetRank,
		priority = priority,
		createdTime = createdTime,
		timeout = timeout,
		creator = creator
	}
	
	-- Update current objective to highest priority
	NRCHUD.UpdateCurrentObjective()
	
	-- Play sound
	surface.PlaySound("buttons/button9.wav")
	
	-- Notification
	chat.AddText(Color(76, 222, 128), "[OBJECTIVE] ", Color(255, 255, 255), "New objective received: ", Color(255, 255, 255, 200), text)
end)

-- Remove objective
net.Receive("NRCHUD_RemoveObjective", function()
	local id = net.ReadUInt(32)
	
	if NRCHUD.PlayerData.objectives[id] then
		NRCHUD.PlayerData.objectives[id] = nil
		NRCHUD.UpdateCurrentObjective()
		
		-- Play sound
		surface.PlaySound("buttons/button10.wav")
	end
end)

-- Update current objective (highest priority)
function NRCHUD.UpdateCurrentObjective()
	local highest = nil
	local highestPriority = 0
	
	for id, objective in pairs(NRCHUD.PlayerData.objectives) do
		if objective.priority > highestPriority then
			highest = objective
			highestPriority = objective.priority
		end
	end
	
	NRCHUD.PlayerData.currentObjective = highest
end

-- Get current objective
function NRCHUD.GetCurrentObjective()
	return NRCHUD.PlayerData.currentObjective
end

-- Draw objective display
local function DrawObjective()
	if not NRCHUD.Config.ShowObjective then return end
	
	local objective = NRCHUD.GetCurrentObjective()
	if not objective then return end
	
	local x, y = 30, 25
	
	-- Pulsing indicator
	local pulse = math.abs(math.sin(CurTime() * 2))
	local indicatorAlpha = 128 + pulse * 127
	
	draw.SimpleText("●", "NRCHUD_Objective_Label", x, y + 3, Color(255, 255, 255, indicatorAlpha), TEXT_ALIGN_LEFT)
	
	-- Label
	draw.SimpleText("OBJECTIVE", "NRCHUD_Objective_Label", x + 16, y, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT)
	
	-- Objective text
	draw.SimpleText(objective.text, "NRCHUD_Objective_Text", x, y + 20, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	
	-- Priority indicator
	if objective.priority > 1 then
		local priorityText = string.rep("!", math.min(objective.priority, 3))
		draw.SimpleText(priorityText, "NRCHUD_Objective_Text", x + 8, y + 40, Color(239, 68, 68, 255), TEXT_ALIGN_LEFT)
	end
end

-- Draw comms display
local function DrawComms()
	if not NRCHUD.Config.ShowComms then return end
	
	local x, y = ScrW() - 30, 25
	
	local channel = NRCHUD.PlayerData.commsChannel
	local channelData = NRCHUD.Config.CommsChannels[channel]
	
	if not channelData then return end
	
	-- Channel indicator (blinking)
	local blink = math.abs(math.sin(CurTime() * 1.5))
	local indicatorAlpha = 128 + blink * 127
	
	draw.SimpleText("●", "NRCHUD_Comms_Value", x - 8, y + 3, Color(channelData.color.r, channelData.color.g, channelData.color.b, indicatorAlpha), TEXT_ALIGN_RIGHT)
	
	-- Channel name
	draw.SimpleText(channelData.name:upper(), "NRCHUD_Comms_Value", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.SimpleText("COMMS CHANNEL", "NRCHUD_Comms_Label", x, y + 18, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT)
	
	-- Frequency
	draw.SimpleText(NRCHUD.PlayerData.frequency, "NRCHUD_Comms_Value", x, y + 40, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.SimpleText("FREQUENCY", "NRCHUD_Comms_Label", x, y + 58, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT)
	
	-- Grid location
	local gridLoc = NRCHUD.GetGridLocation()
	draw.SimpleText(gridLoc, "NRCHUD_Comms_Value", x, y + 80, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.SimpleText("LOCATION", "NRCHUD_Comms_Label", x, y + 98, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT)
	
	-- Time
	local timeText = os.date("%H:%M")
	draw.SimpleText(timeText, "NRCHUD_Comms_Value", x, y + 120, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.SimpleText("TIME", "NRCHUD_Comms_Label", x, y + 138, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT)
end

-- Add to HUD paint
hook.Add("HUDPaint", "NRCHUD_DrawObjectives", function()
	if not NRCHUD.Config.Enabled then return end
	
	DrawObjective()
	DrawComms()
end)

print("[NRC HUD] Objectives display loaded!")