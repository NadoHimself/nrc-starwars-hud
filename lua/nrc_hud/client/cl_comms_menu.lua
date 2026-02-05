-- NRC Star Wars HUD - Comms Menu (F6)

NRCHUD.CommsMenuOpen = false
NRCHUD.CurrentChannel = nil
NRCHUD.FavoriteChannels = NRCHUD.FavoriteChannels or {}

-- Open comms menu
function NRCHUD.OpenCommsMenu()
	if NRCHUD.CommsMenuOpen then return end
	
	NRCHUD.CommsMenuOpen = true
	
	-- Create main frame
	local frame = vgui.Create("DFrame")
	frame:SetSize(800, 600)
	frame:Center()
	frame:SetTitle("Tactical Communications Network")
	frame:SetVisible(true)
	frame:SetDraggable(true)
	frame:ShowCloseButton(true)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 15, 250))
		draw.RoundedBox(0, 0, 0, w, 30, Color(35, 35, 35, 255))
		
		-- Header line
		surface.SetDrawColor(76, 222, 128, 180)
		surface.DrawLine(0, 30, w, 30)
	end
	frame.OnClose = function()
		NRCHUD.CommsMenuOpen = false
	end
	
	-- Current channel display
	local currentPanel = vgui.Create("DPanel", frame)
	currentPanel:SetPos(10, 40)
	currentPanel:SetSize(780, 80)
	currentPanel.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 25, 255))
		surface.SetDrawColor(76, 222, 128, 100)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		
		-- Current channel info
		local channelName = NRCHUD.CurrentChannel or "No Channel"
		local channelData = NRCHUD.CommsFrequencies[channelName]
		
		if channelData then
			draw.SimpleText("ACTIVE CHANNEL", "DermaDefault", 15, 10, Color(150, 150, 150), TEXT_ALIGN_LEFT)
			draw.SimpleText(channelName, "DermaLarge", 15, 28, channelData.color, TEXT_ALIGN_LEFT)
			draw.SimpleText(channelData.freq, "DermaDefaultBold", 15, 55, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT)
			
			-- Status indicator
			local pulse = math.abs(math.sin(CurTime() * 2)) * 100 + 155
			draw.RoundedBox(8, w - 30, 30, 16, 16, Color(76, 222, 128, pulse))
			draw.SimpleText("ONLINE", "DermaDefaultBold", w - 45, 32, Color(76, 222, 128), TEXT_ALIGN_RIGHT)
		else
			draw.SimpleText("NO ACTIVE CHANNEL", "DermaLarge", w/2, h/2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	-- Tabs
	local tabs = vgui.Create("DPropertySheet", frame)
	tabs:SetPos(10, 130)
	tabs:SetSize(780, 430)
	
	-- Tab 1: Standard Channels
	local standardPanel = vgui.Create("DPanel", tabs)
	standardPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	
	local channelList = vgui.Create("DScrollPanel", standardPanel)
	channelList:Dock(FILL)
	channelList:DockMargin(5, 5, 5, 5)
	
	-- Sort channels by priority
	local sortedChannels = {}
	for name, data in pairs(NRCHUD.CommsFrequencies) do
		table.insert(sortedChannels, {name = name, data = data})
	end
	table.sort(sortedChannels, function(a, b) return a.data.priority > b.data.priority end)
	
	-- Add channel buttons
	for _, channel in ipairs(sortedChannels) do
		local channelBtn = vgui.Create("DButton", channelList)
		channelBtn:Dock(TOP)
		channelBtn:DockMargin(5, 5, 5, 0)
		channelBtn:SetTall(50)
		channelBtn:SetText("")
		
		channelBtn.Paint = function(self, w, h)
			local bgCol = Color(30, 30, 30, 255)
			if self:IsHovered() then
				bgCol = Color(40, 40, 40, 255)
			end
			if NRCHUD.CurrentChannel == channel.name then
				bgCol = Color(50, 50, 50, 255)
				surface.SetDrawColor(channel.data.color.r, channel.data.color.g, channel.data.color.b, 150)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			
			draw.RoundedBox(4, 0, 0, w, h, bgCol)
			
			-- Channel name
			draw.SimpleText(channel.name, "DermaDefaultBold", 15, 12, channel.data.color, TEXT_ALIGN_LEFT)
			
			-- Frequency
			draw.SimpleText(channel.data.freq, "DermaDefault", 15, 30, Color(200, 200, 200), TEXT_ALIGN_LEFT)
			
			-- Lock indicator
			if channel.data.locked then
				draw.SimpleText("🔒 LOCKED", "DermaDefault", w - 15, h/2, Color(200, 200, 200, 150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
			
			-- Priority badge
			local priorityCol = Color(100, 100, 100)
			if channel.data.priority >= 9 then
				priorityCol = Color(239, 68, 68)
			elseif channel.data.priority >= 7 then
				priorityCol = Color(251, 191, 36)
			end
			draw.RoundedBox(4, w - 90, 15, 60, 20, priorityCol)
			draw.SimpleText("P" .. channel.data.priority, "DermaDefaultBold", w - 60, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		channelBtn.DoClick = function()
			NRCHUD.SwitchChannel(channel.name)
			surface.PlaySound("buttons/button14.wav")
		end
	end
	
	tabs:AddSheet("Standard Channels", standardPanel, "icon16/transmit.png")
	
	-- Tab 2: Custom Channels
	local customPanel = vgui.Create("DPanel", tabs)
	customPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	
	local createBtn = vgui.Create("DButton", customPanel)
	createBtn:SetPos(10, 10)
	createBtn:SetSize(200, 40)
	createBtn:SetText("Create Custom Channel")
	createBtn:SetTextColor(Color(255, 255, 255))
	createBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and Color(76, 222, 128, 255) or Color(76, 222, 128, 200)
		draw.RoundedBox(4, 0, 0, w, h, col)
	end
	createBtn.DoClick = function()
		NRCHUD.CreateCustomChannel()
	end
	
	local infoLabel = vgui.Create("DLabel", customPanel)
	infoLabel:SetPos(10, 60)
	infoLabel:SetSize(760, 300)
	infoLabel:SetText("Custom channels allow you to create temporary communication channels for specific operations.\n\nFeatures:\n• Set custom frequency and name\n• Password protection\n• Temporary (session-based)\n• Invite specific players\n\nNote: Only non-locked channels can be customized.")
	infoLabel:SetTextColor(Color(180, 180, 180))
	infoLabel:SetWrap(true)
	infoLabel:SetAutoStretchVertical(true)
	
	tabs:AddSheet("Custom Channels", customPanel, "icon16/add.png")
	
	-- Tab 3: Voice Settings
	local voicePanel = vgui.Create("DPanel", tabs)
	voicePanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	
	local voiceLabel = vgui.Create("DLabel", voicePanel)
	voiceLabel:SetPos(10, 10)
	voiceLabel:SetSize(760, 30)
	voiceLabel:SetText("Voice Integration Settings")
	voiceLabel:SetFont("DermaLarge")
	voiceLabel:SetTextColor(Color(255, 255, 255))
	
	local autoSwitch = vgui.Create("DCheckBoxLabel", voicePanel)
	autoSwitch:SetPos(10, 50)
	autoSwitch:SetText("Auto-switch voice channel with comms")
	autoSwitch:SetValue(NRCHUD.VoiceIntegration.autoSwitch)
	autoSwitch:SetTextColor(Color(200, 200, 200))
	autoSwitch.OnChange = function(self, val)
		NRCHUD.VoiceIntegration.autoSwitch = val
		net.Start("NRCHUD_VoiceSettings")
			net.WriteBool(val)
		net.SendToServer()
	end
	
	tabs:AddSheet("Voice Settings", voicePanel, "icon16/sound.png")
end

-- Switch to channel
function NRCHUD.SwitchChannel(channelName)
	local channelData = NRCHUD.CommsFrequencies[channelName]
	if not channelData then return end
	
	NRCHUD.CurrentChannel = channelName
	NRCHUD.PlayerData.commsChannel = channelName
	NRCHUD.PlayerData.frequency = channelData.freq
	
	-- Send to server
	net.Start("NRCHUD_SwitchChannel")
		net.WriteString(channelName)
	net.SendToServer()
	
	-- Notification
	chat.AddText(channelData.color, "[COMMS] ", Color(255, 255, 255), "Switched to: ", channelData.color, channelName, Color(200, 200, 200), " (" .. channelData.freq .. ")")
	surface.PlaySound("buttons/button9.wav")
end

-- Create custom channel
function NRCHUD.CreateCustomChannel()
	Derma_StringRequest(
		"Create Custom Channel",
		"Enter channel name:",
		"",
		function(text)
			if text == "" then return end
			
			Derma_StringRequest(
				"Set Frequency",
				"Enter frequency (e.g., 446.600 MHz):",
				"446.600 MHz",
				function(freq)
					-- Send to server
					net.Start("NRCHUD_CreateCustomChannel")
						net.WriteString(text)
						net.WriteString(freq)
					net.SendToServer()
					
					chat.AddText(Color(76, 222, 128), "[COMMS] ", Color(255, 255, 255), "Custom channel created: ", Color(76, 222, 128), text)
				end
			)
		end
	)
end

-- Bind F6 key
hook.Add("PlayerBindPress", "NRCHUD_CommsMenu", function(ply, bind, pressed)
	if string.find(bind, "gm_showhelp") and pressed then -- F6 key (changed from F3/gm_showspare1)
		if NRCHUD.CommsMenuOpen then return end
		
		NRCHUD.OpenCommsMenu()
		return true
	end
end)

-- Console command
concommand.Add("nrc_comms_menu", function()
	NRCHUD.OpenCommsMenu()
end)

-- Network receivers
net.Receive("NRCHUD_ChannelUpdate", function()
	local channelName = net.ReadString()
	local freq = net.ReadString()
	local r = net.ReadUInt(8)
	local g = net.ReadUInt(8)
	local b = net.ReadUInt(8)
	local locked = net.ReadBool()
	local priority = net.ReadUInt(8)
	
	NRCHUD.CommsFrequencies[channelName] = {
		freq = freq,
		color = Color(r, g, b),
		locked = locked,
		priority = priority
	}
end)

print("[NRC HUD] Comms menu loaded!")