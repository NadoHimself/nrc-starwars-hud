-- NRC Star Wars HUD - Comms Menu (Cinematic Loading Screen Style)

-- Fonts (Orbitron + Share Tech Mono)
surface.CreateFont("NRC_Comms_Title", {font = "Orbitron", size = 28, weight = 900, antialias = true})
surface.CreateFont("NRC_Comms_Header", {font = "Orbitron", size = 20, weight = 700, antialias = true})
surface.CreateFont("NRC_Comms_Small", {font = "Orbitron", size = 12, weight = 600, antialias = true})
surface.CreateFont("NRC_Comms_Mono", {font = "Share Tech Mono", size = 13, weight = 400, antialias = true})
surface.CreateFont("NRC_Comms_Mono_Small", {font = "Share Tech Mono", size = 10, weight = 400, antialias = true})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}

-- Grain animation offset
local grainOffsetX, grainOffsetY = 0, 0
local scanlineOffset = 0

function NRCHUD.OpenCommsMenu()
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.CommsMenu.Frame:Remove()
		return
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Main Frame (fullscreen)
	local frame = vgui.Create("DFrame")
	frame:SetSize(scrW, scrH)
	frame:SetPos(0, 0)
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	local startTime = CurTime()
	
	frame.Paint = function(s, w, h)
		-- Background (dark)
		surface.SetDrawColor(5, 6, 11, 255)
		surface.DrawRect(0, 0, w, h)
		
		-- Background radial gradients
		surface.SetDrawColor(255, 190, 110, 31) -- rgba(255,190,110,0.12)
		draw.NoTexture()
		
		-- Vignette
		local cx, cy = w * 0.5, h * 0.48
		for i = 1, 15 do
			local alpha = math.Clamp(i * 4, 0, 153)
			surface.SetDrawColor(0, 0, 0, alpha)
			local radius = (w * 0.8) + (i * 40)
			draw.NoTexture()
			-- Simple rect fade from edges
		end
		
		-- Scanlines
		scanlineOffset = (scanlineOffset + 0.3) % 7
		surface.SetDrawColor(255, 255, 255, 8)
		for i = 0, h, 7 do
			local y = i + scanlineOffset
			if y >= 0 and y <= h then
				surface.DrawRect(0, y, w, 1)
			end
		end
		
		-- Grain (subtle)
		grainOffsetX = (grainOffsetX + 0.5) % 10
		grainOffsetY = (grainOffsetY + 0.3) % 10
		surface.SetDrawColor(255, 255, 255, 3)
		for x = 0, w, 4 do
			for y = 0, h, 4 do
				if math.random() > 0.7 then
					surface.DrawRect(x + grainOffsetX, y + grainOffsetY, 1, 1)
				end
			end
		end
		
		-- Cinematic bars (top/bottom)
		local barHeight = h * 0.10
		surface.SetDrawColor(0, 0, 0, 237) -- rgba(0,0,0,0.93)
		surface.DrawRect(0, 0, w, barHeight)
		surface.DrawRect(0, h - barHeight, w, barHeight)
		
		-- Light leaks (subtle)
		local leakAlpha = math.abs(math.sin(CurTime() * 0.3)) * 15 + 15
		surface.SetDrawColor(255, 200, 120, leakAlpha)
		-- Right side glow
		for i = 1, 20 do
			local x = w - (i * 30)
			local alpha = math.max(0, leakAlpha - i * 1)
			surface.SetDrawColor(255, 200, 120, alpha)
			surface.DrawRect(x, 0, 30, h)
		end
	end
	
	NRCHUD.CommsMenu.Frame = frame
	
	-- Content container (centered, below bars)
	local contentY = scrH * 0.10 + 30
	local contentH = scrH * 0.80 - 60
	local contentW = math.min(1400, scrW * 0.9)
	local contentX = (scrW - contentW) / 2
	
	local content = vgui.Create("DPanel", frame)
	content:SetPos(contentX, contentY)
	content:SetSize(contentW, contentH)
	content.Paint = function(s, w, h)
		-- Main panel background
		surface.SetDrawColor(0, 0, 0, 66) -- rgba(0,0,0,0.26)
		surface.DrawRect(0, 0, w, h)
		
		-- Cyan glowing border
		surface.SetDrawColor(120, 210, 255, 41) -- rgba(120,210,255,0.16)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Glow effect
		surface.SetDrawColor(120, 210, 255, 26)
		surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 2)
		surface.DrawOutlinedRect(-2, -2, w + 4, h + 4, 1)
	end
	
	-- Header
	local header = vgui.Create("DPanel", content)
	header:SetPos(0, 0)
	header:SetSize(content:GetWide(), 80)
	header.Paint = function(s, w, h)
		-- Gradient background
		surface.SetDrawColor(0, 100, 180, 38)
		surface.DrawRect(0, 0, w, h)
		
		-- Bottom border line
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawRect(0, h - 2, w, 2)
		
		-- Accent line (left)
		local lineW = 58
		for i = 1, lineW do
			local alpha = (i / lineW) * 217 -- 0 to 0.85
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(i, h / 2, i, h / 2 + 1)
		end
		
		-- Title
		draw.SimpleText(NRCHUD.GetText("comms_title"), "NRC_Comms_Title", 80, 20, Color(120, 210, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Subtitle
		draw.SimpleText(NRCHUD.GetText("comms_subtitle"), "NRC_Comms_Mono_Small", 80, 50, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Active channel indicator (right side)
		local activeX = w - 320
		draw.SimpleText(NRCHUD.GetText("active_channel"), "NRC_Comms_Mono_Small", activeX, 15, Color(255, 255, 255, 102), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local channel = NRCHUD.PlayerData.commsChannel or "Battalion Net"
		draw.SimpleText(channel, "NRC_Comms_Header", activeX, 32, Color(74, 222, 128, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local freq = "445.750 MHz"
		if NRCHUD.CommsFrequencies[channel] then
			freq = NRCHUD.CommsFrequencies[channel].freq
		end
		draw.SimpleText(freq, "NRC_Comms_Mono_Small", activeX, 58, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- Close button
	local closeBtn = vgui.Create("DButton", header)
	closeBtn:SetPos(header:GetWide() - 60, 20)
	closeBtn:SetSize(40, 40)
	closeBtn:SetText("×")
	closeBtn:SetFont("NRC_Comms_Header")
	closeBtn:SetTextColor(Color(239, 68, 68))
	closeBtn.Paint = function(s, w, h)
		if s:IsHovered() then
			surface.SetDrawColor(239, 68, 68, 102)
		else
			surface.SetDrawColor(239, 68, 68, 51)
		end
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(239, 68, 68, 179)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	closeBtn.DoClick = function()
		frame:Remove()
	end
	
	-- Scrollable channel list
	local scroll = vgui.Create("DScrollPanel", content)
	scroll:SetPos(20, 100)
	scroll:SetSize(content:GetWide() - 40, content:GetTall() - 120)
	scroll.Paint = function(s, w, h) end
	
	-- Custom scrollbar (cyan)
	local sbar = scroll:GetVBar()
	sbar:SetWide(8)
	sbar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 50, 100, 26)
		surface.DrawRect(0, 0, w, h)
	end
	sbar.btnGrip.Paint = function(s, w, h)
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawRect(0, 0, w, h)
	end
	sbar.btnUp:SetVisible(false)
	sbar.btnDown:SetVisible(false)
	
	NRCHUD.CommsMenu.Scroll = scroll
	
	-- Build channel cards
	NRCHUD.BuildChannelCards(scroll)
	
	-- Fade in animation
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

function NRCHUD.BuildChannelCards(parent)
	parent:Clear()
	
	local padding = 15
	local cardW = (parent:GetWide() - padding * 3) / 2
	local cardH = 100
	local x, y = 0, 0
	local count = 0
	
	-- Get all channels sorted by priority
	local channels = {}
	for name, data in pairs(NRCHUD.CommsFrequencies) do
		table.insert(channels, {name = name, data = data})
	end
	
	table.sort(channels, function(a, b)
		return (a.data.priority or 5) > (b.data.priority or 5)
	end)
	
	for _, ch in ipairs(channels) do
		local name = ch.name
		local data = ch.data
		
		local card = vgui.Create("DButton", parent)
		card:SetPos(x, y)
		card:SetSize(cardW, cardH)
		card:SetText("")
		
		local isActive = (NRCHUD.PlayerData.commsChannel == name)
		
		card.Paint = function(s, w, h)
			local active = (NRCHUD.PlayerData.commsChannel == name)
			
			-- Background
			if active then
				surface.SetDrawColor(0, 100, 180, 66)
			else
				surface.SetDrawColor(0, 30, 60, 51)
			end
			surface.DrawRect(0, 0, w, h)
			
			-- Border
			if active then
				surface.SetDrawColor(74, 222, 128, 179)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			else
				surface.SetDrawColor(120, 210, 255, 51)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
			
			if s:IsHovered() and not active then
				surface.SetDrawColor(120, 210, 255, 128)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
			
			-- Channel name
			draw.SimpleText(name, "NRC_Comms_Header", 15, 15, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Frequency
			draw.SimpleText(data.freq, "NRC_Comms_Mono_Small", 15, 42, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- User count
			local users = NRCHUD.ChannelUserCounts[name] or 0
			draw.SimpleText("👥 " .. users .. " " .. NRCHUD.GetText("users"), "NRC_Comms_Mono_Small", 15, h - 25, Color(120, 210, 255, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Connected badge
			if active then
				surface.SetDrawColor(74, 222, 128, 51)
				surface.DrawRect(w - 120, 10, 110, 22)
				
				surface.SetDrawColor(74, 222, 128, 179)
				surface.DrawOutlinedRect(w - 120, 10, 110, 22, 1)
				
				draw.SimpleText("✓ " .. NRCHUD.GetText("connected"), "NRC_Comms_Small", w - 65, 21, Color(74, 222, 128, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			-- Priority badge
			if data.priority and data.priority >= 8 then
				draw.SimpleText("P" .. data.priority, "NRC_Comms_Small", w - 25, 15, Color(239, 68, 68, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			end
		end
		
		card.DoClick = function()
			if NRCHUD.PlayerData.commsChannel ~= name then
				net.Start("NRCHUD_SwitchChannel")
					net.WriteString(name)
				net.SendToServer()
				
				NRCHUD.PlayerData.commsChannel = name
				
				-- Rebuild cards
				NRCHUD.BuildChannelCards(parent)
				
				surface.PlaySound("buttons/lightswitch2.wav")
			end
		end
		
		-- Position next card
		count = count + 1
		if count % 2 == 0 then
			x = 0
			y = y + cardH + padding
		else
			x = cardW + padding
		end
	end
	
	-- Add custom channel button
	if count % 2 == 1 then
		y = y + cardH + padding
	end
	
	local createBtn = vgui.Create("DButton", parent)
	createBtn:SetPos(0, y)
	createBtn:SetSize(parent:GetWide(), 70)
	createBtn:SetText("")
	createBtn.Paint = function(s, w, h)
		if s:IsHovered() then
			surface.SetDrawColor(74, 222, 128, 66)
		else
			surface.SetDrawColor(74, 222, 128, 38)
		end
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(74, 222, 128, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		
		draw.SimpleText("+", "NRC_Comms_Title", w / 2 - 80, h / 2, Color(74, 222, 128, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(NRCHUD.GetText("create_channel"), "NRC_Comms_Small", w / 2 + 20, h / 2, Color(74, 222, 128, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	createBtn.DoClick = function()
		NRCHUD.OpenCreateChannelDialog()
	end
end

function NRCHUD.OpenCreateChannelDialog()
	-- Simple dialog for now (same style as before but with cinematic bg)
	local dialog = vgui.Create("DFrame")
	dialog:SetSize(500, 250)
	dialog:Center()
	dialog:SetTitle("")
	dialog:SetDraggable(false)
	dialog:ShowCloseButton(false)
	dialog:MakePopup()
	dialog.Paint = function(s, w, h)
		surface.SetDrawColor(5, 10, 15, 242)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(120, 210, 255, 102)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end
	
	-- Title
	local title = vgui.Create("DLabel", dialog)
	title:SetPos(20, 20)
	title:SetText(NRCHUD.GetText("create_channel"))
	title:SetFont("NRC_Comms_Header")
	title:SetTextColor(Color(120, 210, 255))
	title:SizeToContents()
	
	-- Name entry
	local nameLabel = vgui.Create("DLabel", dialog)
	nameLabel:SetPos(20, 70)
	nameLabel:SetText(NRCHUD.GetText("channel_name"))
	nameLabel:SetFont("NRC_Comms_Mono_Small")
	nameLabel:SetTextColor(Color(255, 255, 255, 200))
	nameLabel:SizeToContents()
	
	local nameEntry = vgui.Create("DTextEntry", dialog)
	nameEntry:SetPos(20, 90)
	nameEntry:SetSize(460, 35)
	nameEntry:SetFont("NRC_Comms_Mono")
	nameEntry.Paint = function(s, w, h)
		surface.SetDrawColor(0, 30, 60, 128)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		s:DrawTextEntryText(Color(255, 255, 255), Color(120, 210, 255), Color(255, 255, 255))
	end
	
	-- Freq entry
	local freqLabel = vgui.Create("DLabel", dialog)
	freqLabel:SetPos(20, 135)
	freqLabel:SetText(NRCHUD.GetText("frequency"))
	freqLabel:SetFont("NRC_Comms_Mono_Small")
	freqLabel:SetTextColor(Color(255, 255, 255, 200))
	freqLabel:SizeToContents()
	
	local freqEntry = vgui.Create("DTextEntry", dialog)
	freqEntry:SetPos(20, 155)
	freqEntry:SetSize(220, 35)
	freqEntry:SetFont("NRC_Comms_Mono")
	freqEntry:SetPlaceholderText("212.000")
	freqEntry.Paint = function(s, w, h)
		surface.SetDrawColor(0, 30, 60, 128)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		s:DrawTextEntryText(Color(255, 255, 255), Color(120, 210, 255), Color(255, 255, 255))
	end
	
	-- Create button
	local createBtn = vgui.Create("DButton", dialog)
	createBtn:SetPos(260, 155)
	createBtn:SetSize(100, 35)
	createBtn:SetText(NRCHUD.GetText("create"))
	createBtn:SetFont("NRC_Comms_Small")
	createBtn:SetTextColor(Color(74, 222, 128))
	createBtn.Paint = function(s, w, h)
		if s:IsHovered() then
			surface.SetDrawColor(74, 222, 128, 77)
		else
			surface.SetDrawColor(74, 222, 128, 51)
		end
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(74, 222, 128, 179)
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
			
			timer.Simple(0.5, function()
				if IsValid(NRCHUD.CommsMenu.Frame) and IsValid(NRCHUD.CommsMenu.Scroll) then
					NRCHUD.BuildChannelCards(NRCHUD.CommsMenu.Scroll)
				end
			end)
			
			surface.PlaySound("buttons/button15.wav")
		end
	end
	
	-- Cancel button
	local cancelBtn = vgui.Create("DButton", dialog)
	cancelBtn:SetPos(370, 155)
	cancelBtn:SetSize(110, 35)
	cancelBtn:SetText(NRCHUD.GetText("cancel"))
	cancelBtn:SetFont("NRC_Comms_Small")
	cancelBtn:SetTextColor(Color(239, 68, 68))
	cancelBtn.Paint = function(s, w, h)
		if s:IsHovered() then
			surface.SetDrawColor(239, 68, 68, 77)
		else
			surface.SetDrawColor(239, 68, 68, 51)
		end
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(239, 68, 68, 179)
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
	
	if IsValid(NRCHUD.CommsMenu.Frame) and IsValid(NRCHUD.CommsMenu.Scroll) then
		NRCHUD.BuildChannelCards(NRCHUD.CommsMenu.Scroll)
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
	
	if IsValid(NRCHUD.CommsMenu.Frame) and IsValid(NRCHUD.CommsMenu.Scroll) then
		NRCHUD.BuildChannelCards(NRCHUD.CommsMenu.Scroll)
	end
end)

concommand.Add("nrc_comms", function()
	NRCHUD.OpenCommsMenu()
end)

print("[NRC HUD] Cinematic comms menu loaded!")