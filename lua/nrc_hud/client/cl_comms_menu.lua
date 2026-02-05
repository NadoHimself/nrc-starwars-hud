-- NRC Star Wars HUD - Comms Menu (TRUE Glassmorphism)

surface.CreateFont("NRC_Comms_Title", {font = "Orbitron", size = 32, weight = 900, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Header", {font = "Orbitron", size = 22, weight = 700, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Small", {font = "Orbitron", size = 16, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Tiny", {font = "Orbitron", size = 13, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono", {font = "Share Tech Mono", size = 15, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono_Small", {font = "Share Tech Mono", size = 12, weight = 400, antialias = true, extended = true})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}

local grainTime = 0
local scanlineTime = 0
local blurRT = nil

function NRCHUD.OpenCommsMenu()
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.CommsMenu.Frame:Remove()
		return
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Create blur render target for glassmorphism
	if not blurRT then
		blurRT = GetRenderTarget("nrc_comms_blur", scrW, scrH)
	end
	
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
	
	-- LEFT PANEL (Channel List)
	local leftPanel = vgui.Create("DPanel", frame)
	leftPanel:SetPos(contentX, contentY)
	leftPanel:SetSize(contentW * 0.45, contentH)
	leftPanel.Paint = function(s, w, h)
		-- GLASSMORPHISM EFFECT
		-- Capture background
		render.PushRenderTarget(blurRT)
			render.Clear(0, 0, 0, 0)
			render.CopyRenderTargetToTexture(blurRT)
		render.PopRenderTarget()
		
		-- Draw blurred background
		local oldRT = render.GetRenderTarget()
		render.SetRenderTarget(blurRT)
			render.BlurRenderTarget(blurRT, 4, 4, 2)
		render.SetRenderTarget(oldRT)
		
		-- Blurred background clipped to panel
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("!nrc_comms_blur"))
		surface.DrawTexturedRect(0, 0, w, h)
		
		-- Frosted glass overlay - rgba(0,0,0,0.26)
		draw.RoundedBox(18, 0, 0, w, h, Color(0, 0, 0, 66))
		
		-- Border - rgba(120,210,255,0.16)
		surface.SetDrawColor(120, 210, 255, 41)
		for i = 0, 2 do
			surface.DrawOutlinedRect(i, i, w - i * 2, h - i * 2, 1)
		end
		
		-- Subtle glow
		for i = 1, 4 do
			local alpha = 20 / i
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		-- Box shadow (simulated)
		for i = 1, 10 do
			local offset = i * 2
			local alpha = math.max(0, 92 - i * 8)
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
			surface.SetDrawColor(120, 210, 255, 64 / i)
			surface.DrawRect(20, 30 - i, lineW, 2 + i * 2)
		end
		
		-- Title (HIGH CONTRAST)
		draw.SimpleText("TACTICAL COMMS", "NRC_Comms_Header", 90, 20, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Secure Military Communications", "NRC_Comms_Mono_Small", 90, 45, Color(235, 248, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- SCROLL for channels
	local scroll = vgui.Create("DScrollPanel", leftPanel)
	scroll:SetPos(14, 80)
	scroll:SetSize(leftPanel:GetWide() - 28, leftPanel:GetTall() - 95)
	scroll.Paint = nil
	
	local sbar = scroll:GetVBar()
	sbar:SetWide(10)
	sbar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 56)
		draw.RoundedBox(999, 0, 0, w, h, Color(0, 0, 0, 56))
	end
	sbar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(999, 0, 0, w, h, Color(120, 210, 255, 51))
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	sbar.btnUp:SetVisible(false)
	sbar.btnDown:SetVisible(false)
	
	NRCHUD.CommsMenu.Scroll = scroll
	NRCHUD.BuildChannelList(scroll)
	
	-- RIGHT PANEL (Chat Display)
	local rightPanel = vgui.Create("DPanel", frame)
	rightPanel:SetPos(contentX + leftPanel:GetWide() + 20, contentY)
	rightPanel:SetSize(contentW * 0.53, contentH)
	rightPanel.Paint = function(s, w, h)
		-- GLASSMORPHISM (darker center panel)
		draw.RoundedBox(22, 0, 0, w, h, Color(0, 0, 0, 77))
		
		-- Border
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Subtle glow
		for i = 1, 3 do
			surface.SetDrawColor(120, 210, 255, 15 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		-- Shadow
		for i = 1, 8 do
			local offset = i * 2
			local alpha = math.max(0, 77 - i * 8)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(22, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
		
		-- Header
		local activeChannel = NRCHUD.PlayerData.commsChannel or "Command Net"
		draw.SimpleText("ACTIVE CHANNEL", "NRC_Comms_Tiny", w - 20, 18, Color(235, 248, 255, 179), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText(activeChannel, "NRC_Comms_Small", w - 20, 38, Color(74, 222, 128, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText("445.750 MHz", "NRC_Comms_Mono_Small", w - 20, 62, Color(255, 255, 255, 153), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		
		-- Close button (top right)
		local btnW, btnH = 100, 36
		local btnX, btnY = w - btnW - 15, h - btnH - 15
		
		-- Draw in Paint so it's part of panel
		-- (Will be replaced with actual button below)
	end
	
	-- Close button
	local closeBtn = vgui.Create("DButton", rightPanel)
	closeBtn:SetPos(rightPanel:GetWide() - 115, rightPanel:GetTall() - 50)
	closeBtn:SetSize(100, 36)
	closeBtn:SetText("")
	closeBtn.Paint = function(s, w, h)
		local col = s:IsHovered() and Color(239, 68, 68, 102) or Color(239, 68, 68, 51)
		draw.RoundedBox(999, 0, 0, w, h, col)
		
		surface.SetDrawColor(239, 68, 68, 179)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		
		for i = 1, 2 do
			surface.SetDrawColor(239, 68, 68, 102 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		draw.SimpleText("CLOSE", "NRC_Comms_Mono", w / 2, h / 2, Color(239, 68, 68, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
	
	-- Build channel cards
	for _, ch in ipairs(channels) do
		local name = ch.name
		local data = ch.data
		local isActive = (NRCHUD.PlayerData.commsChannel == name)
		
		local card = vgui.Create("DButton", parent)
		card:SetPos(0, yOffset)
		card:SetSize(panelW, 85)
		card:SetText("")
		
		card.Paint = function(s, w, h)
			local active = (NRCHUD.PlayerData.commsChannel == name)
			
			-- MINICARD GLASSMORPHISM
			if active then
				-- Active: Green glow
				draw.RoundedBox(14, 0, 0, w, h, Color(0, 80, 60, 77))
			else
				-- Normal: Dark transparent
				draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 51))
			end
			
			-- Border
			if active then
				surface.SetDrawColor(74, 222, 128, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				
				-- Active glow
				for i = 1, 3 do
					surface.SetDrawColor(74, 222, 128, 128 / i)
					surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
				end
			else
				surface.SetDrawColor(120, 210, 255, 31)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
			
			if s:IsHovered() and not active then
				-- Hover glow
				for i = 1, 2 do
					surface.SetDrawColor(120, 210, 255, 77 / i)
					surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
				end
			end
			
			-- Channel name (HIGH CONTRAST WHITE)
			draw.SimpleText(name, "NRC_Comms_Small", 15, 14, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Frequency (BRIGHT)
			draw.SimpleText(data.freq, "NRC_Comms_Mono_Small", 15, 42, Color(235, 248, 255, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- User count (CYAN)
			local users = NRCHUD.ChannelUserCounts[name] or 0
			draw.SimpleText(users .. " users", "NRC_Comms_Mono_Small", 15, 62, Color(120, 210, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Priority badge (if high priority)
			if data.priority and data.priority >= 8 then
				local badgeX = w - 55
				local badgeY = 12
				
				-- Badge background
				draw.RoundedBox(999, badgeX, badgeY, 45, 20, Color(255, 195, 105, 51))
				surface.SetDrawColor(255, 195, 105, 128)
				surface.DrawOutlinedRect(badgeX, badgeY, 45, 20, 1)
				
				draw.SimpleText("[P" .. data.priority .. "]", "NRC_Comms_Mono_Small", badgeX + 22, badgeY + 10, Color(255, 195, 105, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			-- CONNECTED badge (if active)
			if active then
				local chipW = 110
				local chipX = w - chipW - 12
				local chipY = h - 28
				
				-- Chip background
				draw.RoundedBox(999, chipX, chipY, chipW, 22, Color(74, 222, 128, 51))
				surface.SetDrawColor(74, 222, 128, 179)
				surface.DrawOutlinedRect(chipX, chipY, chipW, 22, 1)
				
				draw.SimpleText("✓ CONNECTED", "NRC_Comms_Mono_Small", chipX + chipW / 2, chipY + 11, Color(74, 222, 128, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

print("[NRC HUD] Comms menu (TRUE glassmorphism) loaded!")