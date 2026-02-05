-- NRC Star Wars HUD - Commander Menu (Client)

surface.CreateFont("NRC_CommanderTitle", {font = "Orbitron", size = 28, weight = 900})
surface.CreateFont("NRC_CommanderHeader", {font = "Orbitron", size = 20, weight = 700})
surface.CreateFont("NRC_CommanderSub", {font = "Rajdhani", size = 14, weight = 600})
surface.CreateFont("NRC_CommanderText", {font = "Share Tech Mono", size = 13, weight = 400})
surface.CreateFont("NRC_CommanderSmall", {font = "Orbitron", size = 12, weight = 600})

NRCHUD.CommanderMenu = NRCHUD.CommanderMenu or {}

local currentLang = NRCHUD.Config.Language or "en"

local translations = {
	en = {
		title = "COMMAND CENTER",
		subtitle = "Tactical Command Interface",
		objectives = "OBJECTIVES",
		squadManagement = "SQUAD MANAGEMENT",
		tacticalMap = "TACTICAL MAP",
		close = "CLOSE",
		currentObjectives = "Current Objectives",
		noObjectives = "No active objectives",
		squadMembers = "Squad Members",
		rank = "Rank",
		name = "Name",
		status = "Status"
	},
	de = {
		title = "KOMMANDOZENTRALE",
		subtitle = "Taktisches Kommandointerface",
		objectives = "AUFTRÄGE",
		squadManagement = "SQUAD VERWALTUNG",
		tacticalMap = "TAKTISCHE KARTE",
		close = "SCHLIESSEN",
		currentObjectives = "Aktuelle Aufträge",
		noObjectives = "Keine aktiven Aufträge",
		squadMembers = "Squad Mitglieder",
		rank = "Rang",
		name = "Name",
		status = "Status"
	}
}

function NRCHUD.GetCommanderTranslation(key)
	return translations[currentLang] and translations[currentLang][key] or translations["en"][key] or key
end

function NRCHUD.GetAvailableRanks()
	local ranks = {"all"}
	
	-- Check if MRS exists and is properly initialized
	if MRS and type(MRS) == "table" then
		-- Try MRS.GetRanks with pcall (safe call)
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
		
		-- Try alternative MRS.Ranks table
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
		"all", "Trooper", "Corporal", "Sergeant",
		"Lieutenant", "Captain", "Major",
		"Commander", "Marshal Commander"
	}
	
	return ranks
end

function NRCHUD.OpenCommanderMenu()
	if IsValid(NRCHUD.CommanderMenu.Frame) then
		NRCHUD.CommanderMenu.Frame:Remove()
		return
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
	
	NRCHUD.CommanderMenu.Frame = frame
	
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
	title:SetText(NRCHUD.GetCommanderTranslation("title"))
	title:SetFont("NRC_CommanderTitle")
	title:SetTextColor(Color(0, 212, 255))
	title:SizeToContents()
	
	-- Subtitle
	local subtitle = vgui.Create("DLabel", header)
	subtitle:SetPos(40, 58)
	subtitle:SetText(NRCHUD.GetCommanderTranslation("subtitle"))
	subtitle:SetFont("NRC_CommanderSub")
	subtitle:SetTextColor(Color(235, 248, 255, 158))
	subtitle:SizeToContents()
	
	-- Language Switcher
	local langX = frame:GetWide() - 145
	local langEN = vgui.Create("DButton", header)
	langEN:SetPos(langX, 20)
	langEN:SetSize(60, 30)
	langEN:SetText("EN")
	langEN:SetFont("NRC_CommanderSmall")
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
		NRCHUD.CommanderMenu.Frame:Remove()
		NRCHUD.OpenCommanderMenu()
	end
	
	local langDE = vgui.Create("DButton", header)
	langDE:SetPos(langX + 70, 20)
	langDE:SetSize(60, 30)
	langDE:SetText("DE")
	langDE:SetFont("NRC_CommanderSmall")
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
		NRCHUD.CommanderMenu.Frame:Remove()
		NRCHUD.OpenCommanderMenu()
	end
	
	-- Close Button
	local closeBtn = vgui.Create("DButton", header)
	closeBtn:SetPos(frame:GetWide() - 55, 15)
	closeBtn:SetSize(40, 40)
	closeBtn:SetText("✕")
	closeBtn:SetFont("NRC_CommanderHeader")
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
	
	-- Content placeholder
	local content = vgui.Create("DPanel", frame)
	content:SetPos(30, 120)
	content:SetSize(frame:GetWide() - 60, frame:GetTall() - 150)
	content.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 30, 60, 102))
		surface.SetDrawColor(0, 150, 255, 51)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText(NRCHUD.GetCommanderTranslation("currentObjectives"), "NRC_CommanderHeader", 20, 20, Color(0, 212, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(NRCHUD.GetCommanderTranslation("noObjectives"), "NRC_CommanderSub", 20, 60, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
end

-- Keybind
concommand.Add("nrc_commander", function()
	NRCHUD.OpenCommanderMenu()
end)

print("[NRC HUD] Commander menu loaded!")