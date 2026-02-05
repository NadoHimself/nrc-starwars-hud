-- NRC Star Wars HUD - Comms Menu (Transparent Background)

surface.CreateFont("NRC_Comms_Sci_Big", {font = "Orbitron", size = 24, weight = 700, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Sci", {font = "Orbitron", size = 14, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Sci_Small", {font = "Orbitron", size = 12, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono", {font = "Share Tech Mono", size = 14, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono_Small", {font = "Share Tech Mono", size = 13, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono_Tiny", {font = "Share Tech Mono", size = 12, weight = 400, antialias = true, extended = true})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}

local waveTime = 0
local bootProgress = 0
local bootStage = 1
local showingBoot = true
local encryption = true
local pttActive = false
local logLines = {}
local currentChannel = "Battalion Net"

local channelData = {
	["Battalion Net"] = {freq = "133.70 MHz", route = "SQUADNET"},
	["Command Net"] = {freq = "201.12 MHz", route = "COMPANY"},
	["Command HQ"] = {freq = "330.55 MHz", route = "HQ-LINK"},
	["Emergency"] = {freq = "000.00 MHz", route = "PRIORITY"},
}

local function AddLogLine(text, col)
	table.insert(logLines, {text = text, color = col or Color(235, 248, 255, 179), time = CurTime()})
	if #logLines > 12 then
		table.remove(logLines, 1)
	end
end

function NRCHUD.OpenCommsMenu()
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.CommsMenu.Frame:Remove()
		return
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Reset
	bootProgress = 0
	bootStage = 1
	showingBoot = true
	logLines = {}
	waveTime = 0
	currentChannel = NRCHUD.PlayerData.commsChannel or "Battalion Net"
	
	-- FULLSCREEN FRAME (TRANSPARENT - no background paint!)
	local frame = vgui.Create("DFrame")
	frame:SetSize(scrW, scrH)
	frame:SetPos(0, 0)
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame.Paint = nil -- NO BACKGROUND = transparent!
	
	NRCHUD.CommsMenu.Frame = frame
	
	-- DEVICE CONTAINER
	local deviceW = math.min(1100, scrW * 0.92)
	local deviceH = math.min(720, scrH * 0.92)
	local deviceX = (scrW - deviceW) / 2
	local deviceY = (scrH - deviceH) / 2
	
	local device = vgui.Create("DPanel", frame)
	device:SetPos(deviceX, deviceY)
	device:SetSize(deviceW, deviceH)
	device.Paint = function(s, w, h)
		-- Semi-transparent device background
		draw.RoundedBox(22, 0, 0, w, h, Color(0, 0, 0, 46))
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	
	NRCHUD.CommsMenu.Device = device
	
	-- HEADER
	local header = vgui.Create("DPanel", device)
	header:SetPos(16, 16)
	header:SetSize(deviceW - 32, 50)
	header.Paint = function(s, w, h)
		-- Signature line
		for i = 0, 52 do
			local alpha = (i / 52) * 217
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(i, h / 2 - 1, i, h / 2 + 1)
		end
		
		-- Brand text
		draw.SimpleText("REPUBLIK • COMMS UPLINK", "NRC_Comms_Sci_Small", 62, 10, Color(235, 248, 255, 173), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("PHASE II • SECURE TRANSCEIVER", "NRC_Comms_Mono_Tiny", 62, 27, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Pills
		local pillX = w - 10
		
		-- ENC
		local encW = 72
		local encX = pillX - encW
		draw.RoundedBox(999, encX, h / 2 - 16, encW, 32, Color(0, 0, 0, 46))
		surface.SetDrawColor(255, 195, 105, 41)
		surface.DrawOutlinedRect(encX, h / 2 - 16, encW, 32, 1)
		draw.SimpleText("ENC", "NRC_Comms_Mono_Tiny", encX + 10, h / 2 - 9, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(encryption and "AN" or "AUS", "NRC_Comms_Mono_Tiny", encX + 36, h / 2 - 9, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- BAT
		local batW = 72
		local batX = encX - batW - 8
		draw.RoundedBox(999, batX, h / 2 - 16, batW, 32, Color(0, 0, 0, 46))
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(batX, h / 2 - 16, batW, 32, 1)
		local bat = math.floor(58 + math.random() * 35)
		draw.SimpleText("BAT", "NRC_Comms_Mono_Tiny", batX + 10, h / 2 - 9, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(bat .. "%", "NRC_Comms_Mono_Tiny", batX + 36, h / 2 - 9, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- SIG
		local sigW = 72
		local sigX = batX - sigW - 8
		draw.RoundedBox(999, sigX, h / 2 - 16, sigW, 32, Color(0, 0, 0, 46))
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(sigX, h / 2 - 16, sigW, 32, 1)
		local sig = math.floor(62 + math.random() * 34)
		draw.SimpleText("SIG", "NRC_Comms_Mono_Tiny", sigX + 10, h / 2 - 9, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(sig .. "%", "NRC_Comms_Mono_Tiny", sigX + 36, h / 2 - 9, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- SCREEN (3 columns)
	local screenY = 16 + 50 + 12
	local screenH = deviceH - screenY - 16 - 50 - 12
	local screenW = deviceW - 32
	
	local col1W = screenW * 0.25
	local col2W = screenW * 0.45
	local col3W = screenW * 0.28
	
	-- LEFT: Channels
	local leftPanel = vgui.Create("DPanel", device)
	leftPanel:SetPos(16, screenY)
	leftPanel:SetSize(col1W, screenH)
	leftPanel.Paint = function(s, w, h)
		draw.RoundedBox(18, 0, 0, w, h, Color(0, 0, 0, 61))
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText("KANÄLE", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- Channel buttons
	local channels = {
		{name = "Battalion Net", desc = "Trupp / Squad Funk", y = 40},
		{name = "Command Net", desc = "Kompanie", y = 130},
		{name = "Command HQ", desc = "Führung / HQ", y = 220},
		{name = "Emergency", desc = "Notfall / Priorität", y = 310, danger = true},
	}
	
	for _, chan in ipairs(channels) do
		local btn = vgui.Create("DButton", leftPanel)
		btn:SetPos(12, chan.y)
		btn:SetSize(col1W - 24, 75)
		btn:SetText("")
		
		btn.Paint = function(s, w, h)
			local isActive = (currentChannel == chan.name)
			
			draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 41))
			
			if isActive then
				surface.SetDrawColor(255, 195, 105, 51)
			else
				surface.SetDrawColor(120, 210, 255, chan.danger and 36 or 31)
			end
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			
			if s:IsHovered() then
				surface.SetDrawColor(120, 210, 255, 77)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			
			draw.SimpleText(chan.name, "NRC_Comms_Sci_Small", 10, 12, Color(235, 248, 255, 209), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(chan.desc, "NRC_Comms_Mono_Tiny", 10, 32, Color(235, 248, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			if isActive then
				draw.SimpleText("✓ AKTIV", "NRC_Comms_Mono_Tiny", 10, 52, Color(255, 195, 105, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
		
		btn.DoClick = function()
			if currentChannel ~= chan.name then
				currentChannel = chan.name
				NRCHUD.PlayerData.commsChannel = chan.name
				
				-- Network
				net.Start("NRCHUD_SwitchChannel")
					net.WriteString(chan.name)
				net.SendToServer()
				
				AddLogLine("[CH] Kanal gewechselt: " .. chan.name, Color(120, 210, 255, 230))
				
				if chan.danger then
					AddLogLine("[PRIO] Notfallkanal aktiv.", Color(255, 195, 105, 230))
				end
				
				surface.PlaySound("buttons/lightswitch2.wav")
			end
		end
	end
	
	-- Channel info (bottom)
	local infoY = 410
	local infoPanel = vgui.Create("DPanel", leftPanel)
	infoPanel:SetPos(0, infoY)
	infoPanel:SetSize(col1W, screenH - infoY)
	infoPanel.Paint = function(s, w, h)
		-- Divider
		for i = 0, w - 24 do
			local alpha = math.sin((i / (w - 24)) * math.pi) * 56
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(12 + i, 12, 12 + i, 12)
		end
		
		-- Meta
		local data = channelData[currentChannel] or {freq = "---", route = "---"}
		
		local metas = {
			{k = "FREQUENZ", v = data.freq},
			{k = "CODE", v = "AURORA-7"},
			{k = "ROUTE", v = data.route},
		}
		
		for i, meta in ipairs(metas) do
			local my = 24 + (i - 1) * 24
			draw.SimpleText(meta.k, "NRC_Comms_Mono_Tiny", 12, my, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(meta.v, "NRC_Comms_Mono_Tiny", w - 12, my, Color(235, 248, 255, 214), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end
	end
	
	-- CENTER: Core
	local corePanel = vgui.Create("DPanel", device)
	corePanel:SetPos(16 + col1W + 12, screenY)
	corePanel:SetSize(col2W, screenH)
	corePanel.Paint = function(s, w, h)
		draw.RoundedBox(18, 0, 0, w, h, Color(0, 0, 0, 61))
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Title
		draw.SimpleText("TRANSMISSION", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(pttActive and "SENDEN" or "STANDBY", "NRC_Comms_Sci_Small", w - 12, 12, Color(255, 195, 105, 209), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		
		-- Waveform
		local waveX, waveY = 12, 40
		local waveW, waveH = w - 24, 210
		
		draw.RoundedBox(16, waveX, waveY, waveW, waveH, Color(0, 0, 0, 46))
		surface.SetDrawColor(120, 210, 255, 31)
		surface.DrawOutlinedRect(waveX, waveY, waveW, waveH, 1)
		
		-- Grid
		surface.SetDrawColor(120, 210, 255, 46)
		for gx = waveX, waveX + waveW, 42 do
			surface.DrawLine(gx, waveY, gx, waveY + waveH)
		end
		for gy = waveY, waveY + waveH, 32 do
			surface.DrawLine(waveX, gy, waveX + waveW, gy)
		end
		
		-- Wave
		waveTime = waveTime + 0.035
		local amp = pttActive and 26 or 10
		local noise = pttActive and 0.85 or 0.45
		local mid = waveY + waveH / 2
		
		surface.SetDrawColor(pttActive and 255 or 120, pttActive and 195 or 210, pttActive and 105 or 255, 217)
		
		local lastX, lastY = waveX, mid
		for wx = waveX, waveX + waveW, 2 do
			local n = math.sin((wx * 0.02) + waveTime) * amp
			local n2 = math.sin((wx * 0.06) + waveTime * 1.6) * amp * 0.35
			local r = (math.random() - 0.5) * amp * noise
			local wy = mid + n + n2 + r
			
			surface.DrawLine(lastX, lastY, wx, wy)
			lastX, lastY = wx, wy
		end
		
		-- Wave label
		draw.SimpleText("CHANNEL:", "NRC_Comms_Mono_Tiny", waveX + 14, waveY + waveH - 20, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(currentChannel, "NRC_Comms_Mono_Tiny", waveX + 90, waveY + waveH - 20, Color(235, 248, 255, 219), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Dot
		local dotX = waveX + 250
		surface.SetDrawColor(255, 195, 105, 217)
		draw.NoTexture()
		local dot = {}
		for j = 0, 360, 30 do
			local rad = math.rad(j)
			table.insert(dot, {x = dotX + math.cos(rad) * 3, y = waveY + waveH - 14 + math.sin(rad) * 3})
		end
		surface.DrawPoly(dot)
		
		draw.SimpleText("ENCRYPTION:", "NRC_Comms_Mono_Tiny", dotX + 12, waveY + waveH - 20, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(encryption and "AN" or "AUS", "NRC_Comms_Mono_Tiny", dotX + 105, waveY + waveH - 20, Color(235, 248, 255, 219), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- Control buttons
	local ctrlY = screenY + 40 + 210 + 12
	local btnW = (col2W - 24 - 20) / 3
	
	local buttons = {
		{label = "ENC", sub = "Verschlüsselung", x = 12, action = "enc"},
		{label = "PING", sub = "Signaltest", x = 12 + btnW + 10, action = "ping"},
		{label = "PTT", sub = "Sprechen", x = 12 + btnW * 2 + 20, action = "ptt"},
	}
	
	for _, btnData in ipairs(buttons) do
		local btn = vgui.Create("DButton", corePanel)
		btn:SetPos(btnData.x, ctrlY - screenY)
		btn:SetSize(btnW, 58)
		btn:SetText("")
		
		btn.Paint = function(s, w, h)
			local isActive = (btnData.action == "ptt" and pttActive)
			
			draw.RoundedBox(16, 0, 0, w, h, Color(0, 0, 0, 46))
			
			if btnData.action == "ptt" then
				surface.SetDrawColor(255, 195, 105, isActive and 77 or 46)
			else
				surface.SetDrawColor(120, 210, 255, 36)
			end
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			
			if s:IsHovered() then
				surface.SetDrawColor(120, 210, 255, 77)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			
			draw.SimpleText(btnData.label, "NRC_Comms_Sci_Small", 10, 12, Color(120, 210, 255, 224), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(btnData.sub, "NRC_Comms_Mono_Tiny", 10, 32, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		
		if btnData.action == "enc" then
			btn.DoClick = function()
				encryption = not encryption
				AddLogLine(encryption and "[ENC] Verschlüsselung: AN" or "[ENC] Verschlüsselung: AUS", encryption and Color(120, 210, 255, 230) or Color(255, 195, 105, 230))
				surface.PlaySound("buttons/button15.wav")
			end
		elseif btnData.action == "ping" then
			btn.DoClick = function()
				AddLogLine("[PING] Sende Signaltest…", Color(120, 210, 255, 230))
				timer.Simple(0.4, function()
					local ms = math.floor(24 + math.random() * 8)
					AddLogLine("[PING] Antwort erhalten • " .. ms .. " ms", Color(120, 210, 255, 230))
				end)
				surface.PlaySound("buttons/button14.wav")
			end
		elseif btnData.action == "ptt" then
			btn.OnMousePressed = function(s, code)
				if code == MOUSE_LEFT then
					pttActive = true
					AddLogLine("[TX] Übertragung gestartet…", Color(255, 195, 105, 230))
				end
			end
			
			btn.OnMouseReleased = function(s, code)
				if code == MOUSE_LEFT then
					pttActive = false
					AddLogLine("[TX] Übertragung beendet.", Color(120, 210, 255, 230))
				end
			end
		end
	end
	
	-- Hint
	local hintPanel = vgui.Create("DPanel", corePanel)
	hintPanel:SetPos(12, ctrlY - screenY + 68)
	hintPanel:SetSize(col2W - 24, 20)
	hintPanel.Paint = function(s, w, h)
		local hint = pttActive and "Übertragung läuft… (PTT gehalten)" or "Tip: Halte PTT gedrückt (UI), Hook später auf Voice/Radio."
		draw.SimpleText(hint, "NRC_Comms_Mono_Tiny", 0, 0, Color(235, 248, 255, 143), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- RIGHT: Log
	local logPanel = vgui.Create("DPanel", device)
	logPanel:SetPos(16 + col1W + 12 + col2W + 12, screenY)
	logPanel:SetSize(col3W, screenH)
	logPanel.Paint = function(s, w, h)
		draw.RoundedBox(18, 0, 0, w, h, Color(0, 0, 0, 61))
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText("LOG", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Log lines
		local logY = 40
		for i = math.max(1, #logLines - 11), #logLines do
			local line = logLines[i]
			local lineY = logY + (i - math.max(1, #logLines - 11)) * 18
			draw.SimpleText(line.text, "NRC_Comms_Mono_Tiny", 12, lineY, line.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		
		-- Divider
		local divY = h - 120
		for i = 0, w - 24 do
			local alpha = math.sin((i / (w - 24)) * math.pi) * 56
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(12 + i, divY, 12 + i, divY)
		end
		
		-- Mini boxes
		local miniY = divY + 12
		local miniW = (w - 24 - 10) / 2
		
		-- UPLINK
		draw.RoundedBox(14, 12, miniY, miniW, 55, Color(0, 0, 0, 36))
		surface.SetDrawColor(120, 210, 255, 26)
		surface.DrawOutlinedRect(12, miniY, miniW, 55, 1)
		draw.SimpleText("UPLINK", "NRC_Comms_Mono_Tiny", 22, miniY + 12, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("STABIL", "NRC_Comms_Mono_Tiny", 22, miniY + 32, Color(90, 255, 190, 224), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- LATENZ
		local latX = 12 + miniW + 10
		draw.RoundedBox(14, latX, miniY, miniW, 55, Color(0, 0, 0, 36))
		surface.SetDrawColor(120, 210, 255, 26)
		surface.DrawOutlinedRect(latX, miniY, miniW, 55, 1)
		draw.SimpleText("LATENZ", "NRC_Comms_Mono_Tiny", latX + 10, miniY + 12, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		local lat = math.floor(24 + math.random() * 8)
		draw.SimpleText(lat .. " ms", "NRC_Comms_Mono_Tiny", latX + 10, miniY + 32, Color(235, 248, 255, 209), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- FOOTER
	local footer = vgui.Create("DPanel", device)
	footer:SetPos(16, deviceH - 16 - 42)
	footer:SetSize(deviceW - 32, 42)
	footer.Paint = function(s, w, h)
		local chipX = 0
		local chips = {"REPUBLIK", "PHASE II", currentChannel}
		
		for i, chip in ipairs(chips) do
			local isActive = (i == 3)
			surface.SetFont("NRC_Comms_Mono_Tiny")
			local tw = surface.GetTextSize(chip)
			local chipW = tw + 20
			
			draw.RoundedBox(999, chipX, h / 2 - 16, chipW, 32, Color(0, 0, 0, 46))
			surface.SetDrawColor(isActive and 255 or 120, isActive and 195 or 210, isActive and 105 or 255, isActive and 51 or 36)
			surface.DrawOutlinedRect(chipX, h / 2 - 16, chipW, 32, 1)
			
			draw.SimpleText(chip, "NRC_Comms_Mono_Tiny", chipX + chipW / 2, h / 2, isActive and Color(255, 195, 105, 230) or Color(235, 248, 255, 158), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			chipX = chipX + chipW + 10
		end
		
		-- Time
		local time = os.date("LOCAL %H:%M • ENCRYPTION ACTIVE")
		draw.SimpleText(time, "NRC_Comms_Mono_Tiny", w, h / 2, Color(235, 248, 255, 148), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	
	-- BOOT OVERLAY
	local bootOverlay = vgui.Create("DPanel", device)
	bootOverlay:SetPos(14, 70)
	bootOverlay:SetSize(deviceW - 28, deviceH - 140)
	bootOverlay.Paint = function(s, w, h)
		if not showingBoot then
			s:SetVisible(false)
			return
		end
		
		-- Overlay
		draw.RoundedBox(16, 0, 0, w, h, Color(0, 0, 0, 140))
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Title
		draw.SimpleText("HANDSHAKE", "NRC_Comms_Sci", w / 2, h / 2 - 50, Color(120, 210, 255, 217), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		
		local bootSteps = {
			{sub = "Initialisiere Transceiver…", hint = "Kalibriere Frequenzen…"},
			{sub = "Lade Verschlüsselungsmodul…", hint = "Schlüssel werden gesetzt…"},
			{sub = "Verbinde Holonet-Router…", hint = "Routing wird bestätigt…"},
			{sub = "Prüfe Signalstärke…", hint = "Antenne ausgerichtet…"},
			{sub = "Handshake abgeschlossen.", hint = "Bereit."},
		}
		
		if bootStage <= #bootSteps then
			local step = bootSteps[bootStage]
			draw.SimpleText(step.sub, "NRC_Comms_Mono", w / 2, h / 2 - 20, Color(235, 248, 255, 184), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
		
		-- Progress bar
		local barW = w * 0.7
		local barX = (w - barW) / 2
		local barY = h / 2 + 10
		
		draw.RoundedBox(999, barX, barY, barW, 12, Color(0, 0, 0, 56))
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(barX, barY, barW, 12, 1)
		
		local fillW = (bootProgress / 100) * barW
		draw.RoundedBox(999, barX, barY, fillW, 12, Color(120, 210, 255, 140))
		
		if bootStage <= #bootSteps then
			local step = bootSteps[bootStage]
			draw.SimpleText(step.hint, "NRC_Comms_Mono_Tiny", w / 2, barY + 25, Color(235, 248, 255, 148), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end
	
	-- BOOT SEQUENCE
	timer.Simple(0.1, function()
		AddLogLine("[BOOT] Transceiver wird gestartet…", Color(120, 210, 255, 230))
	end)
	
	local bootSteps = {
		{progress = 18},
		{progress = 42},
		{progress = 66},
		{progress = 84},
		{progress = 100},
	}
	
	local function RunBootStep(step)
		if step > #bootSteps then
			timer.Simple(0.3, function()
				if IsValid(bootOverlay) then
					showingBoot = false
					bootOverlay:SetVisible(false)
				end
				AddLogLine("[OK] Uplink steht. Standby.", Color(120, 210, 255, 230))
			end)
			return
		end
		
		bootStage = step
		bootProgress = bootSteps[step].progress
		timer.Simple(0.5, function()
			RunBootStep(step + 1)
		end)
	end
	
	timer.Simple(0.3, function() RunBootStep(1) end)
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

-- Network
net.Receive("NRCHUD_ChannelUserCount", function()
	local counts = net.ReadTable()
	NRCHUD.ChannelUserCounts = counts
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
end)

concommand.Add("nrc_comms", function()
	NRCHUD.OpenCommsMenu()
end)

print("[NRC HUD] Comms menu (Transparent Background) loaded!")