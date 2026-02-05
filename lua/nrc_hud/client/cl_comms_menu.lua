-- NRC Star Wars HUD - Comms Menu (TRUE Glassmorphism with Blur)

surface.CreateFont("NRC_Comms_Title", {font = "Orbitron", size = 32, weight = 900, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Header", {font = "Orbitron", size = 22, weight = 700, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Small", {font = "Orbitron", size = 16, weight = 600, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Tiny", {font = "Orbitron", size = 13, weight = 600, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Mono", {font = "Share Tech Mono", size = 15, weight = 400, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Mono_Small", {font = "Share Tech Mono", size = 12, weight = 400, antialias = true, extended = true, shadow = true})

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
	
	frame.Paint = function(s, w, h)
		-- BG Dark
		surface.SetDrawColor(5, 6, 11, 255)
		surface.DrawRect(0, 0, w, h)
		
		-- Vignette
		for i = 1, 30 do
			local dist = i * 25
			local alpha = math.Clamp((i / 30) * 235, 0, 235)
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawRect(0, h - dist, w, dist)
			surface.DrawRect(0, 0, w, dist)
		end
		
		-- Grain
		grainTime = grainTime + 0.01
		surface.SetDrawColor(255, 255, 255, 3)
		for x = 0, w, 5 do
			for y = 0, h, 5 do
				if math.random() > 0.8 then
					surface.DrawRect(x, y, 1, 1)
				end
			end
		end
		
		-- Scanlines
		scanlineTime = (scanlineTime + 0.2) % 7
		surface.SetDrawColor(255, 255, 255, 8)
		for i = 0, h, 7 do
			surface.DrawRect(0, i + scanlineTime, w, 1)
		end
		
		-- Light leaks
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
	
	-- CONTENT CONTAINER
	local contentY = scrH * 0.10 + 30
	local contentH = scrH * 0.80 - 60
	local contentW = math.min(1400, scrW * 0.85)
	local contentX = (scrW - contentW) / 2
	
	-- LEFT PANEL (Channel List) - GLASSMORPHISM
	local leftPanel = vgui.Create("DPanel", frame)
	leftPanel:SetPos(contentX, contentY)
	leftPanel:SetSize(contentW * 0.45, contentH)
	leftPanel.Paint = function(s, w, h)
		-- GLASSMORPHISM EFFECT
		-- Dark frosted background - rgba(0,0,0,0.26) ABER DUNKLER für bessere Lesbarkeit
		draw.RoundedBox(18, 0, 0, w, h, Color(10, 12, 18, 200)) -- Dunkleres BG!
		
		-- Border - rgba(120,210,255,0.16) ABER HELLER
		surface.SetDrawColor(120, 210, 255, 102) -- Hellere Border!
		for i = 0, 2 do
			surface.DrawOutlinedRect(i, i, w - i * 2, h - i * 2, 1)
		end
		
		-- Outer glow (hellblau)
		for i = 1, 5 do
			local alpha = 40 / i
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		-- Box shadow (simulated) - 0 18px 40px rgba(0,0,0,0.36)
		for i = 1, 12 do
			local offset = i * 2
			local alpha = math.max(0, 92 - i * 6)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(18 + i, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
		
		-- Header with sig line
		local lineW = 58
		for i = 1, lineW do
			local alpha = (i / lineW) * 217
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(20 + i, 30, 20 + i, 32)
		end
		
		-- Sig line glow
		for i = 1, 3 do
			surface.SetDrawColor(120, 210, 255, 90 / i)
			surface.DrawRect(20, 30 - i, lineW, 2 + i * 2)
		end
		
		-- Title (HIGH CONTRAST - FULL WHITE)
		draw.SimpleText("TACTICAL COMMS NETWORK", "NRC_Comms_Header", 90, 18, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Secure Military Communications", "NRC_Comms_Mono_Small", 90, 45, Color(235, 248, 255, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- SCROLL for channels
	local scroll = vgui.Create("DScrollPanel", leftPanel)
	scroll:SetPos(14, 80)
	scroll:SetSize(leftPanel:GetWide() - 28, leftPanel:GetTall() - 95)
	scroll.Paint = nil
	
	local sbar = scroll:GetVBar()
	sbar:SetWide(10)
	sbar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 102)
		draw.RoundedBox(999, 0, 0, w, h, Color(0, 0, 0, 102))
	end
	sbar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(999, 0, 0, w, h, Color(120, 210, 255, 77))
		surface.SetDrawColor(120, 210, 255, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Glow
		for i = 1, 2 do
			surface.SetDrawColor(120, 210, 255, 64 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
	end
	sbar.btnUp:SetVisible(false)
	sbar.btnDown:SetVisible(false)
	
	NRCHUD.CommsMenu.Scroll = scroll
	NRCHUD.BuildChannelList(scroll)
	
	-- RIGHT PANEL (Chat Display) - DARKER GLASSMORPHISM
	local rightPanel = vgui.Create("DPanel", frame)
	rightPanel:SetPos(contentX + leftPanel:GetWide() + 20, contentY)
	rightPanel:SetSize(contentW * 0.53, contentH)
	rightPanel.Paint = function(s, w, h)
		-- DARKER glassmorphism - rgba(0,0,0,0.12) ABER DUNKLER
		draw.RoundedBox(22, 0, 0, w, h, Color(8, 10, 15, 180))
		
		-- Border - rgba(120,210,255,0.14)
		surface.SetDrawColor(120, 210, 255, 51)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Subtle glow
		for i = 1, 4 do
			surface.SetDrawColor(120, 210, 255, 20 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		-- Shadow
		for i = 1, 10 do
			local offset = i * 2
			local alpha = math.max(0, 77 - i * 6)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(22, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
		
		-- HOLO GRID (from loading screen)
		local gridSize = 42
		surface.SetDrawColor(120, 210, 255, 35) -- Etwas heller
		for x = 0, w, gridSize do
			surface.DrawLine(x, 0, x, h)
		end
		for y = 0, h, gridSize do
			surface.DrawLine(0, y, w, y)
		end
		
		-- HOLO PULSE (center glow)
		local pulseAlpha = math.abs(math.sin(CurTime() * 0.4)) * 25 + 15
		for i = 1, 18 do
			local radius = i * 35
			local alpha = math.max(0, pulseAlpha - i * 1.5)
			surface.SetDrawColor(120, 210, 255, alpha)
			local cx, cy = w / 2, h / 2
			draw.NoTexture()
			local circle = {}
			for j = 0, 360, 10 do
				local rad = math.rad(j)
				table.insert(circle, {x = cx + math.cos(rad) * radius, y = cy + math.sin(rad) * radius})
			end
			surface.DrawPoly(circle)
		end
		
		-- Header (TOP RIGHT)
		local activeChannel = NRCHUD.PlayerData.commsChannel or "Command Net"
		draw.SimpleText("ACTIVE CHANNEL", "NRC_Comms_Tiny", w - 20, 18, Color(235, 248, 255, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText(activeChannel, "NRC_Comms_Small", w - 20, 38, Color(74, 222, 128, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText("445.750 MHz", "NRC_Comms_Mono_Small", w - 20, 62, Color(255, 255, 255, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end
	
	-- Close button (CHIP STYLE)
	local closeBtn = vgui.Create("DButton", rightPanel)
	closeBtn:SetPos(rightPanel:GetWide() - 115, rightPanel:GetTall() - 50)
	closeBtn:SetSize(100, 36)
	closeBtn:SetText("")
	closeBtn.Paint = function(s, w, h)
		local col = s:IsHovered() and Color(239, 68, 68, 128) or Color(239, 68, 68, 77)
		draw.RoundedBox(999, 0, 0, w, h, col)
		
		surface.SetDrawColor(239, 68, 68, 230)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		
		for i = 1, 3 do
			surface.SetDrawColor(239, 68, 68, 128 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		draw.SimpleText("CLOSE", "NRC_Comms_Mono", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Remove()
	end
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

function NRCHUD.BuildChannelList(parent)
	parent:Clear()
	
	local yOffset = 0
	local padding = 14
	local panelW = parent:GetWide() - 10
	
	-- Get sorted channels
	local channels = {}
	for name, data in pairs(NRCHUD.CommsFrequencies) do
		table.insert(channels, {name = name, data = data})
	end
	
	table.sort(channels, function(a, b)
		return (a.data.priority or 5) > (b.data.priority or 5)
	end)
	
	-- Build channel cards (MINICARD STYLE)
	for _, ch in ipairs(channels) do
		local name = ch.name
		local data = ch.data
		
		local card = vgui.Create("DButton", parent)
		card:SetPos(0, yOffset)
		card:SetSize(panelW, 85)
		card:SetText("")
		
		card.Paint = function(s, w, h)
			local active = (NRCHUD.PlayerData.commsChannel == name)
			
			-- MINICARD GLASSMORPHISM - background: rgba(0,0,0,0.14)
			if active then
				-- Active: Green tint + glow
				draw.RoundedBox(14, 0, 0, w, h, Color(0, 60, 50, 150))
			else
				-- Normal: Dark transparent
				draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 92))
			end
			
			-- Border - rgba(120,210,255,0.12)
			if active then
				surface.SetDrawColor(74, 222, 128, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				
				-- Active glow (GREEN)
				for i = 1, 4 do
					surface.SetDrawColor(74, 222, 128, 128 / i)
					surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
				end
			else
				surface.SetDrawColor(120, 210, 255, 51)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
			
			if s:IsHovered() and not active then
				-- Hover glow (CYAN)
				for i = 1, 3 do
					surface.SetDrawColor(120, 210, 255, 102 / i)
					surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
				end
			end
			
			-- Channel name (FULL WHITE - HIGH CONTRAST)
			draw.SimpleText(name, "NRC_Comms_Small", 15, 14, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Frequency (BRIGHT)
			draw.SimpleText(data.freq, "NRC_Comms_Mono_Small", 15, 42, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- User count (CYAN BRIGHT)
			local users = NRCHUD.ChannelUserCounts[name] or 0
			draw.SimpleText(users .. " users", "NRC_Comms_Mono_Small", 15, 62, Color(120, 210, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Priority badge (if high priority)
			if data.priority and data.priority >= 8 then
				local badgeX = w - 55
				local badgeY = 12
				
				-- Badge background
				draw.RoundedBox(999, badgeX, badgeY, 45, 20, Color(255, 195, 105, 77))
				surface.SetDrawColor(255, 195, 105, 179)
				surface.DrawOutlinedRect(badgeX, badgeY, 45, 20, 1)
				
				draw.SimpleText("[P" .. data.priority .. "]", "NRC_Comms_Mono_Small", badgeX + 22, badgeY + 10, Color(255, 195, 105, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			-- CONNECTED badge (CHIP STYLE)
			if active then
				local chipW = 110
				local chipX = w - chipW - 12
				local chipY = h - 28
				
				-- Chip background
				draw.RoundedBox(999, chipX, chipY, chipW, 22, Color(74, 222, 128, 77))
				surface.SetDrawColor(74, 222, 128, 230)
				surface.DrawOutlinedRect(chipX, chipY, chipW, 22, 1)
				
				-- Chip glow
				for i = 1, 2 do
					surface.SetDrawColor(74, 222, 128, 102 / i)
					surface.DrawOutlinedRect(chipX - i, chipY - i, chipW + i * 2, 22 + i * 2, 1)
				end
				
				draw.SimpleText("✓ CONNECTED", "NRC_Comms_Mono_Small", chipX + chipW / 2, chipY + 11, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
		
		yOffset = yOffset + 85 + padding
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

print("[NRC HUD] Comms menu (READABLE glassmorphism) loaded!")