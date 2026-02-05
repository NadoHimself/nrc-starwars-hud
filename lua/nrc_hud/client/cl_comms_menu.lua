-- NRC Star Wars HUD - Comms Menu (EXACT Loading Screen Styles)

surface.CreateFont("NRC_Orbitron_Title", {font = "Orbitron", size = 28, weight = 900, antialias = true, extended = true})
surface.CreateFont("NRC_Orbitron_Header", {font = "Orbitron", size = 20, weight = 700, antialias = true, extended = true})
surface.CreateFont("NRC_Orbitron_Small", {font = "Orbitron", size = 14, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Orbitron_Tiny", {font = "Orbitron", size = 12, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Mono", {font = "Share Tech Mono", size = 13, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Mono_Small", {font = "Share Tech Mono", size = 11, weight = 400, antialias = true, extended = true})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}

local grainTime = 0
local scanlineTime = 0

function NRCHUD.OpenCommsMenu()
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.CommsMenu.Frame:Remove()
		return
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- FULLSCREEN FRAME
	local frame = vgui.Create("DFrame")
	frame:SetSize(scrW, scrH)
	frame:SetPos(0, 0)
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	local startAnim = CurTime()
	
	frame.Paint = function(s, w, h)
		-- BG Dark
		surface.SetDrawColor(5, 6, 11, 255)
		surface.DrawRect(0, 0, w, h)
		
		-- Vignette
		local cx, cy = w * 0.5, h * 0.48
		for i = 1, 30 do
			local dist = i * 25
			local alpha = math.Clamp((i / 30) * 235, 0, 235)
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawRect(0, h - dist, w, dist)
			surface.DrawRect(0, 0, w, dist)
		end
		
		-- Grain (subtle)
		grainTime = grainTime + 0.01
		surface.SetDrawColor(255, 255, 255, 3)
		local gx = (math.sin(grainTime) * 5) % 10
		local gy = (math.cos(grainTime * 0.7) * 3) % 10
		for x = 0, w, 5 do
			for y = 0, h, 5 do
				if math.random() > 0.8 then
					surface.DrawRect(x + gx, y + gy, 1, 1)
				end
			end
		end
		
		-- Scanlines
		scanlineTime = (scanlineTime + 0.2) % 7
		surface.SetDrawColor(255, 255, 255, 8)
		for i = 0, h, 7 do
			surface.DrawRect(0, i + scanlineTime, w, 1)
		end
		
		-- Light leaks (warm glow)
		local leakAlpha = math.abs(math.sin(CurTime() * 0.3)) * 20 + 10
		for i = 1, 25 do
			local x = w - (i * 35)
			local alpha = math.max(0, leakAlpha - i * 0.8)
			surface.SetDrawColor(255, 200, 120, alpha)
			surface.DrawRect(x, 0, 35, h)
		end
		
		-- Cinematic bars
		local barH = h * 0.10
		surface.SetDrawColor(0, 0, 0, 237)
		surface.DrawRect(0, 0, w, barH)
		surface.DrawRect(0, h - barH, w, barH)
	end
	
	NRCHUD.CommsMenu.Frame = frame
	
	-- CONTENT PANEL (centered, with padding from bars)
	local contentY = scrH * 0.10 + 30
	local contentH = scrH * 0.80 - 60
	local contentW = math.min(1600, scrW * 0.92)
	local contentX = (scrW - contentW) / 2
	
	local mainPanel = vgui.Create("DPanel", frame)
	mainPanel:SetPos(contentX, contentY)
	mainPanel:SetSize(contentW, contentH)
	mainPanel.Paint = function(s, w, h)
		-- PANEL STYLE (from loading screen)
		-- background: rgba(0,0,0,0.26)
		surface.SetDrawColor(0, 0, 0, 66)
		surface.DrawRect(0, 0, w, h)
		
		-- border: 1px solid rgba(120,210,255,0.16)
		surface.SetDrawColor(120, 210, 255, 41)
		draw.RoundedBox(18, 0, 0, w, h, Color(0, 0, 0, 0))
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Glow layers
		surface.SetDrawColor(120, 210, 255, 20)
		surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 2)
		surface.SetDrawColor(120, 210, 255, 10)
		surface.DrawOutlinedRect(-2, -2, w + 4, h + 4, 1)
		
		-- Box shadow simulation
		for i = 1, 10 do
			local offset = i * 2
			local alpha = math.max(0, 92 - i * 8)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(18 + i, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
	end
	
	-- HEADER (hudTop style)
	local header = vgui.Create("DPanel", mainPanel)
	header:SetPos(0, 0)
	header:SetSize(mainPanel:GetWide(), 70)
	header.Paint = function(s, w, h)
		-- Sig line (left accent)
		local lineW = 58
		for i = 1, lineW do
			local alpha = (i / lineW) * 217 -- 0 to 0.85 * 255
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(20 + i, h / 2, 20 + i, h / 2 + 1)
		end
		
		-- Glow for line
		for i = 1, 5 do
			surface.SetDrawColor(120, 210, 255, 64 / i)
			surface.DrawRect(20, h / 2 - i, lineW, 2 + i * 2)
		end
		
		-- Brand title
		draw.SimpleText(NRCHUD.GetText("comms_title"), "NRC_Orbitron_Title", 90, 15, Color(235, 248, 255, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(NRCHUD.GetText("comms_subtitle"), "NRC_Mono_Small", 90, 45, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Active channel (right)
		local activeX = w - 300
		draw.SimpleText(NRCHUD.GetText("active_channel"), "NRC_Orbitron_Tiny", activeX, 12, Color(235, 248, 255, 173), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local channel = NRCHUD.PlayerData.commsChannel or "Battalion Net"
		draw.SimpleText(channel, "NRC_Orbitron_Small", activeX, 32, Color(74, 222, 128, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Frequency
		local freq = "445.750 MHz"
		if NRCHUD.CommsFrequencies[channel] then
			freq = NRCHUD.CommsFrequencies[channel].freq
		end
		draw.SimpleText(freq, "NRC_Mono_Small", activeX, 52, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- Close button (audioBtn style)
	local closeBtn = vgui.Create("DButton", header)
	closeBtn:SetPos(header:GetWide() - 100, 18)
	closeBtn:SetSize(80, 34)
	closeBtn:SetText("")
	closeBtn.Paint = function(s, w, h)
		local col = s:IsHovered() and Color(239, 68, 68, 77) or Color(239, 68, 68, 51)
		
		draw.RoundedBox(999, 0, 0, w, h, col)
		
		surface.SetDrawColor(239, 68, 68, 179)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText("SCHLIEßEN", "NRC_Mono_Small", w / 2, h / 2, Color(239, 68, 68, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Remove()
	end
	
	-- SCROLL PANEL for channels
	local scroll = vgui.Create("DScrollPanel", mainPanel)
	scroll:SetPos(20, 90)
	scroll:SetSize(mainPanel:GetWide() - 40, mainPanel:GetTall() - 110)
	scroll.Paint = nil
	
	-- Custom scrollbar
	local sbar = scroll:GetVBar()
	sbar:SetWide(10)
	sbar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 56)
		surface.DrawRect(0, 0, w, h)
	end
	sbar.btnGrip.Paint = function(s, w, h)
		surface.SetDrawColor(120, 210, 255, 36)
		draw.RoundedBox(999, 0, 0, w, h, Color(120, 210, 255, 36))
		
		surface.SetDrawColor(120, 210, 255, 46)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	sbar.btnUp:SetVisible(false)
	sbar.btnDown:SetVisible(false)
	
	NRCHUD.CommsMenu.Scroll = scroll
	NRCHUD.BuildChannelList(scroll)
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

function NRCHUD.BuildChannelList(parent)
	parent:Clear()
	
	local yOffset = 0
	local padding = 16
	local panelW = parent:GetWide() - 20
	
	-- Get sorted channels
	local channels = {}
	for name, data in pairs(NRCHUD.CommsFrequencies) do
		table.insert(channels, {name = name, data = data})
	end
	
	table.sort(channels, function(a, b)
		return (a.data.priority or 5) > (b.data.priority or 5)
	end)
	
	-- Build channel cards (miniCard style)
	for _, ch in ipairs(channels) do
		local name = ch.name
		local data = ch.data
		local isActive = (NRCHUD.PlayerData.commsChannel == name)
		
		local card = vgui.Create("DButton", parent)
		card:SetPos(0, yOffset)
		card:SetSize(panelW, 90)
		card:SetText("")
		
		card.Paint = function(s, w, h)
			local active = (NRCHUD.PlayerData.commsChannel == name)
			
			-- MINICRD STYLE
			-- background: rgba(0,0,0,0.14)
			if active then
				surface.SetDrawColor(0, 80, 140, 51) -- Slightly blue when active
			else
				surface.SetDrawColor(0, 0, 0, 36)
			end
			draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 0))
			surface.DrawRect(0, 0, w, h)
			
			-- border: 1px solid rgba(120,210,255,0.12)
			if active then
				surface.SetDrawColor(74, 222, 128, 230) -- Green when active
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			else
				surface.SetDrawColor(120, 210, 255, 31)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
			
			if s:IsHovered() and not active then
				surface.SetDrawColor(120, 210, 255, 102)
				surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)
			end
			
			-- miniTitle style
			draw.SimpleText(name, "NRC_Orbitron_Small", 15, 12, Color(235, 248, 255, active and 255 or 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Frequency + user count
			draw.SimpleText(data.freq, "NRC_Mono_Small", 15, 38, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			local users = NRCHUD.ChannelUserCounts[name] or 0
			draw.SimpleText(users .. " " .. NRCHUD.GetText("users"), "NRC_Mono_Small", 15, 60, Color(120, 210, 255, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- ACTIVE BADGE (chip style)
			if active then
				local chipW = 100
				local chipX = w - chipW - 15
				
				-- chip background
				surface.SetDrawColor(74, 222, 128, 51)
				draw.RoundedBox(999, chipX, 12, chipW, 24, Color(0, 0, 0, 46))
				
				-- chip border
				surface.SetDrawColor(74, 222, 128, 128)
				draw.RoundedBoxOutline(999, chipX, 12, chipW, 24, 1, Color(74, 222, 128, 128))
				
				draw.SimpleText("✓ " .. NRCHUD.GetText("connected"), "NRC_Mono_Small", chipX + chipW / 2, 24, Color(74, 222, 128, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			-- Priority badge
			if data.priority and data.priority >= 8 then
				draw.SimpleText("[P" .. data.priority .. "]", "NRC_Orbitron_Tiny", w - 15, 58, Color(255, 195, 105, 235), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			end
		end
		
		card.DoClick = function()
			if NRCHUD.PlayerData.commsChannel ~= name then
				net.Start("NRCHUD_SwitchChannel")
					net.WriteString(name)
				net.SendToServer()
				
				NRCHUD.PlayerData.commsChannel = name
				NRCHUD.BuildChannelList(parent)
				
				surface.PlaySound("buttons/lightswitch2.wav")
			end
		end
		
		yOffset = yOffset + 90 + padding
	end
	
	-- CALLOUT STYLE for create new channel
	local createBtn = vgui.Create("DButton", parent)
	createBtn:SetPos(0, yOffset)
	createBtn:SetSize(panelW, 70)
	createBtn:SetText("")
	
	createBtn.Paint = function(s, w, h)
		-- callout style
		-- background: rgba(0,0,0,0.16)
		surface.SetDrawColor(0, 0, 0, 41)
		draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 41))
		
		-- border: 1px solid rgba(255,195,105,0.16)
		if s:IsHovered() then
			surface.SetDrawColor(255, 195, 105, 77)
		else
			surface.SetDrawColor(255, 195, 105, 41)
		end
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- calloutK style text
		draw.SimpleText("+", "NRC_Orbitron_Title", 30, h / 2, Color(255, 195, 105, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(NRCHUD.GetText("create_channel"), "NRC_Orbitron_Small", 70, h / 2, Color(255, 195, 105, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	createBtn.DoClick = function()
		NRCHUD.OpenCreateChannelDialog()
	end
end

function NRCHUD.OpenCreateChannelDialog()
	local dialog = vgui.Create("DFrame")
	dialog:SetSize(500, 280)
	dialog:Center()
	dialog:SetTitle("")
	dialog:SetDraggable(false)
	dialog:ShowCloseButton(false)
	dialog:MakePopup()
	
	dialog.Paint = function(s, w, h)
		-- PANEL STYLE
		surface.SetDrawColor(5, 6, 11, 242)
		draw.RoundedBox(18, 0, 0, w, h, Color(5, 6, 11, 242))
		
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 1)
	end
	
	local title = vgui.Create("DLabel", dialog)
	title:SetPos(20, 20)
	title:SetText(NRCHUD.GetText("create_channel"))
	title:SetFont("NRC_Orbitron_Header")
	title:SetTextColor(Color(120, 210, 255))
	title:SizeToContents()
	
	-- Name entry
	local nameLabel = vgui.Create("DLabel", dialog)
	nameLabel:SetPos(20, 70)
	nameLabel:SetText(NRCHUD.GetText("channel_name"))
	nameLabel:SetFont("NRC_Orbitron_Tiny")
	nameLabel:SetTextColor(Color(235, 248, 255, 163))
	nameLabel:SizeToContents()
	
	local nameEntry = vgui.Create("DTextEntry", dialog)
	nameEntry:SetPos(20, 92)
	nameEntry:SetSize(460, 38)
	nameEntry:SetFont("NRC_Mono")
	nameEntry.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 102)
		draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 102))
		
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		s:DrawTextEntryText(Color(255, 255, 255), Color(120, 210, 255), Color(255, 255, 255))
	end
	
	-- Freq entry
	local freqLabel = vgui.Create("DLabel", dialog)
	freqLabel:SetPos(20, 145)
	freqLabel:SetText(NRCHUD.GetText("frequency"))
	freqLabel:SetFont("NRC_Orbitron_Tiny")
	freqLabel:SetTextColor(Color(235, 248, 255, 163))
	freqLabel:SizeToContents()
	
	local freqEntry = vgui.Create("DTextEntry", dialog)
	freqEntry:SetPos(20, 167)
	freqEntry:SetSize(200, 38)
	freqEntry:SetFont("NRC_Mono")
	freqEntry:SetPlaceholderText("212.000")
	freqEntry.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 102)
		draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 102))
		
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		s:DrawTextEntryText(Color(255, 255, 255), Color(120, 210, 255), Color(255, 255, 255))
	end
	
	-- Buttons (chip style)
	local createBtn = vgui.Create("DButton", dialog)
	createBtn:SetPos(240, 167)
	createBtn:SetSize(120, 38)
	createBtn:SetText("")
	createBtn.Paint = function(s, w, h)
		local col = s:IsHovered() and Color(74, 222, 128, 77) or Color(74, 222, 128, 51)
		draw.RoundedBox(999, 0, 0, w, h, col)
		
		surface.SetDrawColor(74, 222, 128, 179)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText(NRCHUD.GetText("create"), "NRC_Mono_Small", w / 2, h / 2, Color(74, 222, 128, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
			
			timer.Simple(0.5, function()
				if IsValid(NRCHUD.CommsMenu.Scroll) then
					NRCHUD.BuildChannelList(NRCHUD.CommsMenu.Scroll)
				end
			end)
			
			surface.PlaySound("buttons/button15.wav")
		end
	end
	
	local cancelBtn = vgui.Create("DButton", dialog)
	cancelBtn:SetPos(370, 167)
	cancelBtn:SetSize(110, 38)
	cancelBtn:SetText("")
	cancelBtn.Paint = function(s, w, h)
		local col = s:IsHovered() and Color(239, 68, 68, 77) or Color(239, 68, 68, 51)
		draw.RoundedBox(999, 0, 0, w, h, col)
		
		surface.SetDrawColor(239, 68, 68, 179)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText(NRCHUD.GetText("cancel"), "NRC_Mono_Small", w / 2, h / 2, Color(239, 68, 68, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	cancelBtn.DoClick = function()
		dialog:Remove()
	end
end

-- Helper for rounded outline
function draw.RoundedBoxOutline(radius, x, y, w, h, thickness, col)
	surface.SetDrawColor(col)
	for i = 0, thickness - 1 do
		surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2, 1)
	end
end

-- Network
net.Receive("NRCHUD_ChannelUserCount", function()
	local counts = net.ReadTable()
	NRCHUD.ChannelUserCounts = counts
	
	if IsValid(NRCHUD.CommsMenu.Scroll) then
		NRCHUD.BuildChannelList(NRCHUD.CommsMenu.Scroll)
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
	
	if IsValid(NRCHUD.CommsMenu.Scroll) then
		NRCHUD.BuildChannelList(NRCHUD.CommsMenu.Scroll)
	end
end)

concommand.Add("nrc_comms", function()
	NRCHUD.OpenCommsMenu()
end)

print("[NRC HUD] Comms menu (exact loading screen style) loaded!")