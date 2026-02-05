-- NRC Star Wars HUD - Commander Menu (EXACT Loading Screen Styles)

surface.CreateFont("NRC_Cmd_Title", {font = "Orbitron", size = 28, weight = 900, antialias = true, extended = true})
surface.CreateFont("NRC_Cmd_Header", {font = "Orbitron", size = 20, weight = 700, antialias = true, extended = true})
surface.CreateFont("NRC_Cmd_Small", {font = "Orbitron", size = 14, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Cmd_Tiny", {font = "Orbitron", size = 12, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Cmd_Mono", {font = "Share Tech Mono", size = 13, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Cmd_Mono_Small", {font = "Share Tech Mono", size = 11, weight = 400, antialias = true, extended = true})

NRCHUD.CommanderMenu = NRCHUD.CommanderMenu or {}

local grainTime = 0
local scanlineTime = 0

function NRCHUD.OpenCommanderMenu()
	if IsValid(NRCHUD.CommanderMenu.Frame) then
		NRCHUD.CommanderMenu.Frame:Remove()
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
		-- BG
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
	
	NRCHUD.CommanderMenu.Frame = frame
	
	-- CONTENT (3-column layout from loading screen)
	local contentY = scrH * 0.10 + 30
	local contentH = scrH * 0.80 - 60
	local contentW = math.min(1600, scrW * 0.92)
	local contentX = (scrW - contentW) / 2
	
	local mainPanel = vgui.Create("DPanel", frame)
	mainPanel:SetPos(contentX, contentY)
	mainPanel:SetSize(contentW, contentH)
	mainPanel.Paint = nil
	
	-- LAYOUT GRID (like loading screen)
	local col1W = contentW * 0.30
	local col2W = contentW * 0.42
	local col3W = contentW * 0.26
	local gap = 16
	
	-- LEFT PANEL (panel left style)
	local leftPanel = vgui.Create("DPanel", mainPanel)
	leftPanel:SetPos(0, 0)
	leftPanel:SetSize(col1W, contentH)
	leftPanel.Paint = function(s, w, h)
		-- PANEL STYLE
		surface.SetDrawColor(0, 0, 0, 66)
		draw.RoundedBox(18, 0, 0, w, h, Color(0, 0, 0, 66))
		
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Glow
		surface.SetDrawColor(120, 210, 255, 20)
		surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 2)
		
		-- Shadow
		for i = 1, 8 do
			local offset = i * 2
			local alpha = math.max(0, 92 - i * 10)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(18, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
		
		-- panelHeader
		draw.SimpleText(NRCHUD.GetText("objectives"), "NRC_Cmd_Tiny", 14, 14, Color(235, 248, 255, 173), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(NRCHUD.GetText("no_active"), "NRC_Cmd_Mono_Small", w - 14, 14, Color(255, 195, 105, 219), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		
		-- Divider (like loading screen)
		local divY = 40
		for i = 0, w do
			local alpha
			if i < w * 0.2 or i > w * 0.8 then
				alpha = 0
			else
				alpha = 56
			end
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(i, divY, i + 1, divY)
		end
		
		-- Content
		draw.SimpleText(NRCHUD.GetText("no_objectives_desc"), "NRC_Cmd_Mono_Small", 14, 60, Color(235, 248, 255, 184), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- CENTER PANEL (crawlWrap style with holoGrid)
	local centerPanel = vgui.Create("DPanel", mainPanel)
	centerPanel:SetPos(col1W + gap, 0)
	centerPanel:SetSize(col2W, contentH)
	centerPanel.Paint = function(s, w, h)
		-- CRAWLWRAP STYLE
		-- background: rgba(0,0,0,0.12)
		surface.SetDrawColor(0, 0, 0, 31)
		draw.RoundedBox(22, 0, 0, w, h, Color(0, 0, 0, 31))
		
		-- border: 1px solid rgba(120,210,255,0.14)
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Shadow
		for i = 1, 8 do
			local offset = i * 2
			local alpha = math.max(0, 77 - i * 8)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(22, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
		
		-- HOLO GRID
		local gridSize = 42
		surface.SetDrawColor(120, 210, 255, 20)
		for x = 0, w, gridSize do
			surface.DrawLine(x, 0, x, h)
		end
		for y = 0, h, gridSize do
			surface.DrawLine(0, y, w, y)
		end
		
		-- HOLO PULSE (center glow)
		local pulseAlpha = math.abs(math.sin(CurTime() * 0.4)) * 20 + 15
		for i = 1, 15 do
			local radius = i * 30
			local alpha = math.max(0, pulseAlpha - i * 1.5)
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawRect(w / 2 - radius, h / 2 - radius, radius * 2, radius * 2)
		end
		
		-- crawlTitle
		draw.SimpleText(NRCHUD.GetText("mission_briefing"), "NRC_Cmd_Tiny", 18, 14, Color(255, 195, 105, 219), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Content
		draw.SimpleText(NRCHUD.GetText("briefing_placeholder"), "NRC_Cmd_Mono_Small", w / 2, h / 2, Color(235, 248, 255, 153), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	-- RIGHT PANEL (panel right style)
	local rightPanel = vgui.Create("DPanel", mainPanel)
	rightPanel:SetPos(col1W + col2W + gap * 2, 0)
	rightPanel:SetSize(col3W, contentH)
	rightPanel.Paint = function(s, w, h)
		-- background: rgba(0,0,0,0.18)
		surface.SetDrawColor(0, 0, 0, 46)
		draw.RoundedBox(18, 0, 0, w, h, Color(0, 0, 0, 46))
		
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Shadow
		for i = 1, 8 do
			local offset = i * 2
			local alpha = math.max(0, 92 - i * 10)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(18, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
	end
	
	-- RIGHT PANEL CONTENT (callout + miniCards)
	local scroll = vgui.Create("DScrollPanel", rightPanel)
	scroll:SetPos(12, 12)
	scroll:SetSize(rightPanel:GetWide() - 24, rightPanel:GetTall() - 24)
	scroll.Paint = nil
	
	local sbar = scroll:GetVBar()
	sbar:SetWide(8)
	sbar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 56)
		surface.DrawRect(0, 0, w, h)
	end
	sbar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(999, 0, 0, w, h, Color(120, 210, 255, 36))
		surface.SetDrawColor(120, 210, 255, 46)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	sbar.btnUp:SetVisible(false)
	sbar.btnDown:SetVisible(false)
	
	-- CALLOUT (warm accent)
	local callout = vgui.Create("DPanel", scroll)
	callout:SetPos(0, 0)
	callout:SetSize(scroll:GetWide() - 10, 85)
	callout.Paint = function(s, w, h)
		-- background: rgba(0,0,0,0.16)
		surface.SetDrawColor(0, 0, 0, 41)
		draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 41))
		
		-- border: 1px solid rgba(255,195,105,0.16)
		surface.SetDrawColor(255, 195, 105, 41)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- calloutK
		draw.SimpleText(NRCHUD.GetText("server_status"), "NRC_Cmd_Tiny", 10, 10, Color(255, 195, 105, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- calloutV
		draw.SimpleText(NRCHUD.GetText("online"), "NRC_Cmd_Small", 10, 30, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- calloutS
		local players = #player.GetAll()
		local maxPlayers = game.MaxPlayers()
		draw.SimpleText(players .. "/" .. maxPlayers .. " " .. NRCHUD.GetText("players"), "NRC_Cmd_Mono_Small", 10, 56, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- MINICARD 1
	local miniCard1 = vgui.Create("DPanel", scroll)
	miniCard1:SetPos(0, 97)
	miniCard1:SetSize(scroll:GetWide() - 10, 120)
	miniCard1.Paint = function(s, w, h)
		-- background: rgba(0,0,0,0.14)
		surface.SetDrawColor(0, 0, 0, 36)
		draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 36))
		
		-- border: 1px solid rgba(120,210,255,0.12)
		surface.SetDrawColor(120, 210, 255, 31)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- miniTitle
		draw.SimpleText(NRCHUD.GetText("quick_actions"), "NRC_Cmd_Tiny", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- miniList items
		draw.SimpleText("• " .. NRCHUD.GetText("action_1"), "NRC_Cmd_Mono_Small", 12, 38, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("• " .. NRCHUD.GetText("action_2"), "NRC_Cmd_Mono_Small", 12, 60, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("• " .. NRCHUD.GetText("action_3"), "NRC_Cmd_Mono_Small", 12, 82, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- MINICARD 2
	local miniCard2 = vgui.Create("DPanel", scroll)
	miniCard2:SetPos(0, 229)
	miniCard2:SetSize(scroll:GetWide() - 10, 100)
	miniCard2.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 36)
		draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 36))
		
		surface.SetDrawColor(120, 210, 255, 31)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText(NRCHUD.GetText("info"), "NRC_Cmd_Tiny", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		draw.SimpleText("• " .. NRCHUD.GetText("info_1"), "NRC_Cmd_Mono_Small", 12, 38, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("• " .. NRCHUD.GetText("info_2"), "NRC_Cmd_Mono_Small", 12, 60, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- CLOSE BUTTON (in top bar area)
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetPos(contentX + contentW - 100, contentY - 50)
	closeBtn:SetSize(80, 34)
	closeBtn:SetText("")
	closeBtn.Paint = function(s, w, h)
		local col = s:IsHovered() and Color(239, 68, 68, 77) or Color(239, 68, 68, 51)
		draw.RoundedBox(999, 0, 0, w, h, col)
		
		surface.SetDrawColor(239, 68, 68, 179)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText("SCHLIEßEN", "NRC_Cmd_Mono_Small", w / 2, h / 2, Color(239, 68, 68, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Remove()
	end
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

concommand.Add("nrc_commander", function()
	NRCHUD.OpenCommanderMenu()
end)

print("[NRC HUD] Commander menu (exact loading screen style) loaded!")