-- NRC Star Wars HUD - Comms Menu (Client)

surface.CreateFont("NRC_CommsTitle", {font = "Orbitron", size = 28, weight = 900})
surface.CreateFont("NRC_CommsHeader", {font = "Orbitron", size = 20, weight = 700})
surface.CreateFont("NRC_CommsSub", {font = "Rajdhani", size = 14, weight = 600})
surface.CreateFont("NRC_CommsText", {font = "Share Tech Mono", size = 13, weight = 400})
surface.CreateFont("NRC_CommsSmall", {font = "Orbitron", size = 12, weight = 600})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}

local currentLang = NRCHUD.Config.Language or "en"

local translations = {
	en = {
		title = "TACTICAL COMMS NETWORK",
		subtitle = "Secure Military Communications",
		activeChannel = "ACTIVE CHANNEL",
		standardChannels = "STANDARD CHANNELS",
		customChannels = "CUSTOM CHANNELS",
		settings = "SETTINGS",
		users = "users",
		createChannel = "CREATE CUSTOM CHANNEL",
		connected = "CONNECTED",
		close = "CLOSE",
		channelName = "Channel Name",
		frequency = "Frequency",
		create = "CREATE",
		cancel = "CANCEL",
		voiceSettings = "Voice Settings",
		autoSwitch = "Auto-switch voice channel",
		sound = "Sound Effects",
		soundVolume = "Sound Volume"
	},
	de = {
		title = "TAKTISCHES FUNKNETZWERK",
		subtitle = "Sichere Militärkommunikation",
		activeChannel = "AKTIVER KANAL",
		standardChannels = "STANDARD KANÄLE",
		customChannels = "EIGENE KANÄLE",
		settings = "EINSTELLUNGEN",
		users = "Nutzer",
		createChannel = "EIGENEN KANAL ERSTELLEN",
		connected = "VERBUNDEN",
		close = "SCHLIESSEN",
		channelName = "Kanalname",
		frequency = "Frequenz",
		create = "ERSTELLEN",
		cancel = "ABBRECHEN",
		voiceSettings = "Spracheinstellungen",
		autoSwitch = "Automatischer Kanalwechsel",
		sound = "Soundeffekte",
		soundVolume = "Lautstärke"
	}
}

function NRCHUD.GetTranslation(key)
	return translations[currentLang] and translations[currentLang][key] or translations["en"][key] or key
end

function NRCHUD.OpenCommsMenu()
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.CommsMenu.Frame:Remove()
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Main Frame
	local frame = vgui.Create("DFrame")
	frame:SetSize(math.min(1100, scrW * 0.9), math.min(700, scrH * 0.85))
	frame:Center()
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame.Paint = function(s, w, h)
		-- Background
		draw.RoundedBox(0, 0, 0, w, h, Color(5, 10, 15, 242))
		
		-- Border glow
		surface.SetDrawColor(0, 150, 255, 102)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		
		-- Inner glow
		surface.SetDrawColor(0, 100, 180, 26)
		for i = 1, 3 do
			surface.DrawOutlinedRect(i * 2, i * 2, w - i * 4, h - i * 4, 1)
		end
		
		-- Corner decorations
		local cornerSize = 30
		surface.SetDrawColor(0, 200, 255, 204)
		-- Top left
		surface.DrawLine(0, 0, cornerSize, 0)
		surface.DrawLine(0, 0, 0, cornerSize)
		-- Top right
		surface.DrawLine(w - cornerSize, 0, w, 0)
		surface.DrawLine(w - 1, 0, w - 1, cornerSize)
		-- Bottom left
		surface.DrawLine(0, h - cornerSize, 0, h)
		surface.DrawLine(0, h - 1, cornerSize, h - 1)
		-- Bottom right
		surface.DrawLine(w - cornerSize, h - 1, w, h - 1)
		surface.DrawLine(w - 1, h - cornerSize, w - 1, h)
		
		-- Scanlines
		surface.SetDrawColor(0, 100, 180, 8)
		for i = 0, h, 4 do
			surface.DrawLine(0, i, w, i)
		end
	end
	
	NRCHUD.CommsMenu.Frame = frame
	NRCHUD.CommsMenu.CurrentTab = "standard"
	
	-- Header
	local header = vgui.Create("DPanel", frame)
	header:SetPos(0, 0)
	header:SetSize(frame:GetWide(), 100)
	header.Paint = function(s, w, h)
		-- Gradient background
		surface.SetDrawColor(0, 100, 180, 38)
		surface.DrawRect(0, 0, w, h)
		
		-- Bottom border
		surface.SetDrawColor(0, 150, 255, 77)
		surface.DrawLine(0, h - 1, w, h - 1)
		surface.DrawLine(0, h - 2, w, h - 2)
	end
	
	-- Title
	local title = vgui.Create("DLabel", header)
	title:SetPos(40, 25)
	title:SetText(NRCHUD.GetTranslation("title"))
	title:SetFont("NRC_CommsTitle")
	title:SetTextColor(Color(0, 212, 255))
	title:SizeToContents()
	
	-- Subtitle
	local subtitle = vgui.Create("DLabel", header)
	subtitle:SetPos(40, 58)
	subtitle:SetText(NRCHUD.GetTranslation("subtitle"))
	subtitle:SetFont("NRC_CommsSub")
	subtitle:SetTextColor(Color(235, 248, 255, 158))
	subtitle:SizeToContents()
	
	-- Active channel display
	local activeLabel = vgui.Create("DLabel", header)
	activeLabel:SetPos(frame:GetWide() - 320, 18)
	activeLabel:SetText(NRCHUD.GetTranslation("activeChannel"))
	activeLabel:SetFont("NRC_CommsSmall")
	activeLabel:SetTextColor(Color(255, 255, 255, 102))
	activeLabel:SizeToContents()
	
	local activeChannel = vgui.Create("DLabel", header)
	activeChannel:SetPos(frame:GetWide() - 320, 38)
	activeChannel:SetText(NRCHUD.PlayerData.commsChannel or "Battalion Net")
	activeChannel:SetFont("NRC_CommsHeader")
	activeChannel:SetTextColor(Color(74, 222, 128))
	activeChannel:SizeToContents()
	
	local activeFreq = vgui.Create("DLabel", header)
	activeFreq:SetPos(frame:GetWide() - 320, 68)
	activeFreq:SetText((NRCHUD.CommsFrequencies[NRCHUD.PlayerData.commsChannel] or {freq = "445.750 MHz"}).freq)
	activeFreq:SetFont("NRC_CommsSub")
	activeFreq:SetTextColor(Color(255, 255, 255, 153))
	activeFreq:SizeToContents()
	
	NRCHUD.CommsMenu.ActiveChannel = activeChannel
	NRCHUD.CommsMenu.ActiveFreq = activeFreq
	
	-- Language Switcher
	local langX = frame:GetWide() - 145
	local langEN = vgui.Create("DButton", header)
	langEN:SetPos(langX, 20)
	langEN:SetSize(60, 30)
	langEN:SetText("EN")
	langEN:SetFont("NRC_CommsSmall")
	langEN:SetTextColor(currentLang == "en" and Color(0, 212, 255) or Color(255, 255, 255, 128))
	langEN.Paint = function(s, w, h)
		if currentLang == "en" then
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 150, 255, 77))
			surface.SetDrawColor(0, 212, 255)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		else
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 100, 180, 51))
			surface.SetDrawColor(0, 150, 255, 77)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	end
	langEN.DoClick = function()
		currentLang = "en"
		NRCHUD.CommsMenu.Frame:Remove()
		NRCHUD.OpenCommsMenu()
	end
	
	local langDE = vgui.Create("DButton", header)
	langDE:SetPos(langX + 70, 20)
	langDE:SetSize(60, 30)
	langDE:SetText("DE")
	langDE:SetFont("NRC_CommsSmall")
	langDE:SetTextColor(currentLang == "de" and Color(0, 212, 255) or Color(255, 255, 255, 128))
	langDE.Paint = function(s, w, h)
		if currentLang == "de" then
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 150, 255, 77))
			surface.SetDrawColor(0, 212, 255)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		else
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 100, 180, 51))
			surface.SetDrawColor(0, 150, 255, 77)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	end
	langDE.DoClick = function()
		currentLang = "de"
		NRCHUD.CommsMenu.Frame:Remove()
		NRCHUD.OpenCommsMenu()
	end
	
	-- Close Button
	local closeBtn = vgui.Create("DButton", header)
	closeBtn:SetPos(frame:GetWide() - 55, 15)
	closeBtn:SetSize(40, 40)
	closeBtn:SetText("✕")
	closeBtn:SetFont("NRC_CommsHeader")
	closeBtn:SetTextColor(Color(239, 68, 68))
	closeBtn.Paint = function(s, w, h)
		if s:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(239, 68, 68, 102))
		else
			draw.RoundedBox(0, 0, 0, w, h, Color(239, 68, 68, 51))
		end
		surface.SetDrawColor(239, 68, 68, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	closeBtn.DoClick = function()
		frame:Remove()
	end
	
	-- Tabs
	local tabs = vgui.Create("DPanel", frame)
	tabs:SetPos(0, 100)
	tabs:SetSize(frame:GetWide(), 50)
	tabs.Paint = function(s, w, h)
		surface.SetDrawColor(0, 50, 100, 26)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(0, 150, 255, 51)
		surface.DrawLine(0, h - 1, w, h - 1)
	end
	
	local tabButtons = {}
	local tabWidth = frame:GetWide() / 3
	
	local function CreateTab(name, icon, key)
		local btn = vgui.Create("DButton", tabs)
		btn:SetPos((key - 1) * tabWidth, 0)
		btn:SetSize(tabWidth, 50)
		btn:SetText("")
		btn.Paint = function(s, w, h)
			local active = NRCHUD.CommsMenu.CurrentTab == name
			
			if active then
				surface.SetDrawColor(0, 150, 255, 26)
				surface.DrawRect(0, 0, w, h)
				
				-- Active indicator line
				surface.SetDrawColor(0, 212, 255)
				surface.DrawRect(w * 0.2, h - 3, w * 0.6, 3)
			elseif s:IsHovered() then
				surface.SetDrawColor(0, 100, 180, 13)
				surface.DrawRect(0, 0, w, h)
			end
			
			-- Icon
			draw.SimpleText(icon, "NRC_CommsHeader", w / 2 - 60, h / 2, active and Color(0, 212, 255) or Color(255, 255, 255, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			-- Text
			draw.SimpleText(NRCHUD.GetTranslation(name .. "Channels"), "NRC_CommsSmall", w / 2 + 20, h / 2, active and Color(0, 212, 255) or Color(255, 255, 255, 128), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			-- Right border
			if key < 3 then
				surface.SetDrawColor(0, 150, 255, 26)
				surface.DrawLine(w - 1, 0, w - 1, h)
			end
		end
		
		btn.DoClick = function()
			NRCHUD.CommsMenu.CurrentTab = name
			NRCHUD.RefreshChannelView()
		end
		
		tabButtons[name] = btn
	end
	
	CreateTab("standard", "📡", 1)
	CreateTab("custom", "➕", 2)
	CreateTab("settings", "⚙", 3)
	
	-- Content Area
	local content = vgui.Create("DScrollPanel", frame)
	content:SetPos(0, 150)
	content:SetSize(frame:GetWide(), frame:GetTall() - 150)
	content.Paint = function(s, w, h)
		-- Transparent
	end
	
	-- Custom scrollbar
	local sbar = content:GetVBar()
	sbar:SetWide(8)
	sbar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 50, 100, 26)
		surface.DrawRect(0, 0, w, h)
	end
	sbar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(0, 150, 255, 77))
	end
	sbar.btnUp:SetVisible(false)
	sbar.btnDown:SetVisible(false)
	
	NRCHUD.CommsMenu.Content = content
	
	-- Initial view
	NRCHUD.RefreshChannelView()
end

function NRCHUD.RefreshChannelView()
	local content = NRCHUD.CommsMenu.Content
	if not IsValid(content) then return end
	
	content:Clear()
	
	local currentTab = NRCHUD.CommsMenu.CurrentTab
	
	if currentTab == "standard" or currentTab == "custom" then
		NRCHUD.CreateChannelGrid(content, currentTab)
	elseif currentTab == "settings" then
		NRCHUD.CreateSettingsPanel(content)
	end
end

function NRCHUD.CreateChannelGrid(parent, tab)
	local padding = 30
	local gap = 15
	local cardWidth = (parent:GetWide() - padding * 2 - gap) / 2
	local cardHeight = 120
	
	local x, y = padding, padding
	local count = 0
	
	local channels = {}
	for name, data in pairs(NRCHUD.CommsFrequencies) do
		if (tab == "standard" and not data.custom) or (tab == "custom" and data.custom) then
			table.insert(channels, {name = name, data = data})
		end
	end
	
	-- Sort by priority
	table.sort(channels, function(a, b)
		return (a.data.priority or 5) > (b.data.priority or 5)
	end)
	
	for _, ch in ipairs(channels) do
		local channelName = ch.name
		local channelData = ch.data
		
		local card = vgui.Create("DButton", parent)
		card:SetPos(x, y)
		card:SetSize(cardWidth, cardHeight)
		card:SetText("")
		
		local isActive = (NRCHUD.PlayerData.commsChannel == channelName)
		
		card.Paint = function(s, w, h)
			local active = (NRCHUD.PlayerData.commsChannel == channelName)
			
			if active then
				draw.RoundedBox(0, 0, 0, w, h, Color(0, 100, 180, 51))
				surface.SetDrawColor(74, 222, 128)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				
				-- Connected badge
				draw.RoundedBox(0, w - 120, 10, 110, 20, Color(74, 222, 128, 51))
				surface.SetDrawColor(74, 222, 128)
				surface.DrawOutlinedRect(w - 120, 10, 110, 20, 1)
				draw.SimpleText("✓ " .. NRCHUD.GetTranslation("connected"), "NRC_CommsSmall", w - 65, 20, Color(74, 222, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.RoundedBox(0, 0, 0, w, h, Color(0, 30, 60, 102))
				surface.SetDrawColor(0, 150, 255, 51)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
			
			if s:IsHovered() and not active then
				surface.SetDrawColor(0, 200, 255, 128)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
		end
		
		-- Channel name
		local nameLabel = vgui.Create("DLabel", card)
		nameLabel:SetPos(20, 15)
		nameLabel:SetText(channelName)
		nameLabel:SetFont("NRC_CommsHeader")
		nameLabel:SetTextColor(Color(255, 255, 255))
		nameLabel:SizeToContents()
		
		-- Frequency
		local freqLabel = vgui.Create("DLabel", card)
		freqLabel:SetPos(20, 45)
		freqLabel:SetText(channelData.freq)
		freqLabel:SetFont("NRC_CommsSub")
		freqLabel:SetTextColor(Color(255, 255, 255, 128))
		freqLabel:SizeToContents()
		
		-- User count
		local userCount = NRCHUD.ChannelUserCounts[channelName] or 0
		local userLabel = vgui.Create("DLabel", card)
		userLabel:SetPos(20, cardHeight - 35)
		userLabel:SetText("👥 " .. userCount .. " " .. NRCHUD.GetTranslation("users"))
		userLabel:SetFont("NRC_CommsSub")
		userLabel:SetTextColor(Color(0, 212, 255))
		userLabel:SizeToContents()
		
		-- Priority badge
		if channelData.priority and channelData.priority >= 8 then
			local badge = vgui.Create("DLabel", card)
			badge:SetPos(cardWidth - 80, 15)
			badge:SetText("P" .. channelData.priority)
			badge:SetFont("NRC_CommsSmall")
			badge:SetTextColor(Color(239, 68, 68))
			badge:SizeToContents()
		end
		
		card.DoClick = function()
			if NRCHUD.PlayerData.commsChannel ~= channelName then
				net.Start("NRCHUD_SwitchChannel")
					net.WriteString(channelName)
				net.SendToServer()
				
				NRCHUD.PlayerData.commsChannel = channelName
				
				-- Update active display
				if IsValid(NRCHUD.CommsMenu.ActiveChannel) then
					NRCHUD.CommsMenu.ActiveChannel:SetText(channelName)
					NRCHUD.CommsMenu.ActiveChannel:SizeToContents()
				end
				
				if IsValid(NRCHUD.CommsMenu.ActiveFreq) then
					NRCHUD.CommsMenu.ActiveFreq:SetText(channelData.freq)
					NRCHUD.CommsMenu.ActiveFreq:SizeToContents()
				end
				
				-- Refresh view
				NRCHUD.RefreshChannelView()
				
				surface.PlaySound("buttons/lightswitch2.wav")
			end
		end
		
		-- Position for next card
		count = count + 1
		if count % 2 == 0 then
			x = padding
			y = y + cardHeight + gap
		else
			x = padding + cardWidth + gap
		end
	end
	
	-- Create custom channel button (only on custom tab)
	if tab == "custom" then
		if count % 2 == 1 then
			y = y + cardHeight + gap
		end
		
		local createBtn = vgui.Create("DButton", parent)
		createBtn:SetPos(padding, y)
		createBtn:SetSize(parent:GetWide() - padding * 2, 80)
		createBtn:SetText("")
		createBtn.Paint = function(s, w, h)
			if s:IsHovered() then
				draw.RoundedBox(0, 0, 0, w, h, Color(74, 222, 128, 51))
				surface.SetDrawColor(74, 222, 128)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			else
				draw.RoundedBox(0, 0, 0, w, h, Color(74, 222, 128, 26))
				surface.SetDrawColor(74, 222, 128, 77)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			
			draw.SimpleText("+", "NRC_CommsTitle", w / 2 - 120, h / 2, Color(74, 222, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(NRCHUD.GetTranslation("createChannel"), "NRC_CommsSmall", w / 2 + 20, h / 2, Color(74, 222, 128), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		
		createBtn.DoClick = function()
			NRCHUD.OpenCreateChannelDialog()
		end
	end
end

function NRCHUD.CreateSettingsPanel(parent)
	local padding = 30
	
	-- Voice Settings
	local voicePanel = vgui.Create("DPanel", parent)
	voicePanel:SetPos(padding, padding)
	voicePanel:SetSize(parent:GetWide() - padding * 2, 150)
	voicePanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 30, 60, 102))
		surface.SetDrawColor(0, 150, 255, 51)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText(NRCHUD.GetTranslation("voiceSettings"), "NRC_CommsHeader", 20, 15, Color(0, 212, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	local autoSwitch = vgui.Create("DCheckBoxLabel", voicePanel)
	autoSwitch:SetPos(20, 60)
	autoSwitch:SetText(NRCHUD.GetTranslation("autoSwitch"))
	autoSwitch:SetFont("NRC_CommsSub")
	autoSwitch:SetTextColor(Color(255, 255, 255, 200))
	autoSwitch:SizeToContents()
	autoSwitch:SetValue(NRCHUD.PlayerData.voiceAutoSwitch or false)
	autoSwitch.OnChange = function(s, val)
		NRCHUD.PlayerData.voiceAutoSwitch = val
		net.Start("NRCHUD_VoiceSettings")
			net.WriteBool(val)
		net.SendToServer()
	end
end

function NRCHUD.OpenCreateChannelDialog()
	if IsValid(NRCHUD.CreateChannelDialog) then
		NRCHUD.CreateChannelDialog:Remove()
	end
	
	local dialog = vgui.Create("DFrame")
	dialog:SetSize(500, 250)
	dialog:Center()
	dialog:SetTitle("")
	dialog:SetDraggable(false)
	dialog:ShowCloseButton(false)
	dialog:MakePopup()
	dialog.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(5, 10, 15, 242))
		surface.SetDrawColor(0, 150, 255, 102)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end
	
	NRCHUD.CreateChannelDialog = dialog
	
	-- Title
	local title = vgui.Create("DLabel", dialog)
	title:SetPos(20, 20)
	title:SetText(NRCHUD.GetTranslation("createChannel"))
	title:SetFont("NRC_CommsHeader")
	title:SetTextColor(Color(0, 212, 255))
	title:SizeToContents()
	
	-- Channel Name
	local nameLabel = vgui.Create("DLabel", dialog)
	nameLabel:SetPos(20, 70)
	nameLabel:SetText(NRCHUD.GetTranslation("channelName"))
	nameLabel:SetFont("NRC_CommsSub")
	nameLabel:SetTextColor(Color(255, 255, 255, 200))
	nameLabel:SizeToContents()
	
	local nameEntry = vgui.Create("DTextEntry", dialog)
	nameEntry:SetPos(20, 95)
	nameEntry:SetSize(460, 35)
	nameEntry:SetFont("NRC_CommsText")
	nameEntry.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 30, 60, 128))
		surface.SetDrawColor(0, 150, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		s:DrawTextEntryText(Color(255, 255, 255), Color(0, 150, 255), Color(255, 255, 255))
	end
	
	-- Frequency
	local freqLabel = vgui.Create("DLabel", dialog)
	freqLabel:SetPos(20, 140)
	freqLabel:SetText(NRCHUD.GetTranslation("frequency"))
	freqLabel:SetFont("NRC_CommsSub")
	freqLabel:SetTextColor(Color(255, 255, 255, 200))
	freqLabel:SizeToContents()
	
	local freqEntry = vgui.Create("DTextEntry", dialog)
	freqEntry:SetPos(20, 165)
	freqEntry:SetSize(220, 35)
	freqEntry:SetFont("NRC_CommsText")
	freqEntry:SetPlaceholderText("212.000")
	freqEntry.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 30, 60, 128))
		surface.SetDrawColor(0, 150, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		s:DrawTextEntryText(Color(255, 255, 255), Color(0, 150, 255), Color(255, 255, 255))
	end
	
	-- Create Button
	local createBtn = vgui.Create("DButton", dialog)
	createBtn:SetPos(260, 165)
	createBtn:SetSize(100, 35)
	createBtn:SetText(NRCHUD.GetTranslation("create"))
	createBtn:SetFont("NRC_CommsSmall")
	createBtn:SetTextColor(Color(74, 222, 128))
	createBtn.Paint = function(s, w, h)
		if s:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(74, 222, 128, 77))
		else
			draw.RoundedBox(0, 0, 0, w, h, Color(74, 222, 128, 51))
		end
		surface.SetDrawColor(74, 222, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	
	createBtn.DoClick = function()
		local name = nameEntry:GetValue()
		local freq = freqEntry:GetValue()
		
		if name ~= "" and freq ~= "" then
			net.Start("NRCHUD_CreateCustomChannel")
				net.WriteString(name)
				net.WriteString(freq)
			net.SendToServer()
			
			dialog:Remove()
			
			-- Refresh after 0.5s
			timer.Simple(0.5, function()
				if IsValid(NRCHUD.CommsMenu.Frame) then
					NRCHUD.CommsMenu.CurrentTab = "custom"
					NRCHUD.RefreshChannelView()
				end
			end)
			
			surface.PlaySound("buttons/button15.wav")
		end
	end
	
	-- Cancel Button
	local cancelBtn = vgui.Create("DButton", dialog)
	cancelBtn:SetPos(370, 165)
	cancelBtn:SetSize(110, 35)
	cancelBtn:SetText(NRCHUD.GetTranslation("cancel"))
	cancelBtn:SetFont("NRC_CommsSmall")
	cancelBtn:SetTextColor(Color(239, 68, 68))
	cancelBtn.Paint = function(s, w, h)
		if s:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(239, 68, 68, 77))
		else
			draw.RoundedBox(0, 0, 0, w, h, Color(239, 68, 68, 51))
		end
		surface.SetDrawColor(239, 68, 68)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	
	cancelBtn.DoClick = function()
		dialog:Remove()
	end
end

-- Network receivers
net.Receive("NRCHUD_ChannelUserCount", function()
	local counts = net.ReadTable()
	NRCHUD.ChannelUserCounts = counts
	
	-- Refresh if menu is open
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.RefreshChannelView()
	end
end)

net.Receive("NRCHUD_ChannelUpdate", function()
	local name = net.ReadString()
	local freq = net.ReadString()
	local r = net.ReadUInt(8)
	local g = net.ReadUInt(8)
	local b = net.ReadUInt(8)
	local locked = net.ReadBool()
	local priority = net.ReadUInt(8)
	
	NRCHUD.CommsFrequencies[name] = {
		freq = freq,
		color = Color(r, g, b),
		locked = locked,
		priority = priority,
		custom = true
	}
	
	-- Refresh if menu is open
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.RefreshChannelView()
	end
end)

-- Keybind
concommand.Add("nrc_comms", function()
	NRCHUD.OpenCommsMenu()
end)

print("[NRC HUD] Comms menu loaded!")