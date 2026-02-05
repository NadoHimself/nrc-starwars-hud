-- NRC Star Wars HUD - Commander Menu (Cinematic Loading Screen Style)

-- Fonts
surface.CreateFont("NRC_Commander_Title", {font = "Orbitron", size = 28, weight = 900, antialias = true})
surface.CreateFont("NRC_Commander_Header", {font = "Orbitron", size = 20, weight = 700, antialias = true})
surface.CreateFont("NRC_Commander_Small", {font = "Orbitron", size = 12, weight = 600, antialias = true})
surface.CreateFont("NRC_Commander_Mono", {font = "Share Tech Mono", size = 13, weight = 400, antialias = true})
surface.CreateFont("NRC_Commander_Mono_Small", {font = "Share Tech Mono", size = 10, weight = 400, antialias = true})

NRCHUD.CommanderMenu = NRCHUD.CommanderMenu or {}

local grainOffsetX, grainOffsetY = 0, 0
local scanlineOffset = 0

function NRCHUD.OpenCommanderMenu()
	if IsValid(NRCHUD.CommanderMenu.Frame) then
		NRCHUD.CommanderMenu.Frame:Remove()
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
	
	frame.Paint = function(s, w, h)
		-- Background (dark)
		surface.SetDrawColor(5, 6, 11, 255)
		surface.DrawRect(0, 0, w, h)
		
		-- Scanlines
		scanlineOffset = (scanlineOffset + 0.3) % 7
		surface.SetDrawColor(255, 255, 255, 8)
		for i = 0, h, 7 do
			local y = i + scanlineOffset
			if y >= 0 and y <= h then
				surface.DrawRect(0, y, w, 1)
			end
		end
		
		-- Grain
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
		
		-- Cinematic bars
		local barHeight = h * 0.10
		surface.SetDrawColor(0, 0, 0, 237)
		surface.DrawRect(0, 0, w, barHeight)
		surface.DrawRect(0, h - barHeight, w, barHeight)
		
		-- Light leaks
		local leakAlpha = math.abs(math.sin(CurTime() * 0.3)) * 15 + 15
		surface.SetDrawColor(255, 200, 120, leakAlpha)
		for i = 1, 20 do
			local x = w - (i * 30)
			local alpha = math.max(0, leakAlpha - i * 1)
			surface.SetDrawColor(255, 200, 120, alpha)
			surface.DrawRect(x, 0, 30, h)
		end
	end
	
	NRCHUD.CommanderMenu.Frame = frame
	
	-- Content container
	local contentY = scrH * 0.10 + 30
	local contentH = scrH * 0.80 - 60
	local contentW = math.min(1400, scrW * 0.9)
	local contentX = (scrW - contentW) / 2
	
	local content = vgui.Create("DPanel", frame)
	content:SetPos(contentX, contentY)
	content:SetSize(contentW, contentH)
	content.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 66)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		surface.SetDrawColor(120, 210, 255, 26)
		surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 2)
		surface.DrawOutlinedRect(-2, -2, w + 4, h + 4, 1)
	end
	
	-- Header
	local header = vgui.Create("DPanel", content)
	header:SetPos(0, 0)
	header:SetSize(content:GetWide(), 80)
	header.Paint = function(s, w, h)
		surface.SetDrawColor(0, 100, 180, 38)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawRect(0, h - 2, w, 2)
		
		-- Accent line
		local lineW = 58
		for i = 1, lineW do
			local alpha = (i / lineW) * 217
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(i, h / 2, i, h / 2 + 1)
		end
		
		draw.SimpleText(NRCHUD.GetText("commander_title"), "NRC_Commander_Title", 80, 20, Color(120, 210, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(NRCHUD.GetText("commander_subtitle"), "NRC_Commander_Mono_Small", 80, 50, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- Close button
	local closeBtn = vgui.Create("DButton", header)
	closeBtn:SetPos(header:GetWide() - 60, 20)
	closeBtn:SetSize(40, 40)
	closeBtn:SetText("×")
	closeBtn:SetFont("NRC_Commander_Header")
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
	
	-- Main content area
	local mainContent = vgui.Create("DPanel", content)
	mainContent:SetPos(30, 100)
	mainContent:SetSize(content:GetWide() - 60, content:GetTall() - 120)
	mainContent.Paint = function(s, w, h)
		surface.SetDrawColor(0, 30, 60, 51)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(120, 210, 255, 51)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Title
		draw.SimpleText(NRCHUD.GetText("current_objectives"), "NRC_Commander_Header", 20, 20, Color(120, 210, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Placeholder text
		draw.SimpleText(NRCHUD.GetText("no_objectives"), "NRC_Commander_Mono", 20, 60, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

concommand.Add("nrc_commander", function()
	NRCHUD.OpenCommanderMenu()
end)

print("[NRC HUD] Cinematic commander menu loaded!")