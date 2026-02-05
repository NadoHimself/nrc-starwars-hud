-- NRC Star Wars HUD - Comms Menu (EPIC REDESIGN)

surface.CreateFont("NRC_Comms_Sci_Big", {font = "Orbitron", size = 24, weight = 700, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Sci", {font = "Orbitron", size = 14, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Sci_Small", {font = "Orbitron", size = 12, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono", {font = "Share Tech Mono", size = 14, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono_Small", {font = "Share Tech Mono", size = 13, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono_Tiny", {font = "Share Tech Mono", size = 12, weight = 400, antialias = true, extended = true})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}

local grainTime = 0
local scanlineTime = 0
local leakTime = 0
local waveTime = 0
local bootProgress = 0
local bootStage = 1
local showingBoot = true
local encryption = true
local pttActive = false
local logLines = {}

local function AddLogLine(text, color)
	table.insert(logLines, {text = text, color = color or Color(235, 248, 255, 179), time = CurTime()})
	if #logLines > 15 then
		table.remove(logLines, 1)
	end
end

function NRCHUD.OpenCommsMenu()
	if IsValid(NRCHUD.CommsMenu.Frame) then
		NRCHUD.CommsMenu.Frame:Remove()
		return
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Reset state
	bootProgress = 0
	bootStage = 1
	showingBoot = true
	logLines = {}
	waveTime = 0
	
	-- FULLSCREEN FRAME (transparent)
	local frame = vgui.Create("DFrame")
	frame:SetSize(scrW, scrH)
	frame:SetPos(0, 0)
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	frame.Paint = function(s, w, h)
		-- BACKGROUND (dark gradient)
		surface.SetDrawColor(5, 6, 11, 255)
		surface.DrawRect(0, 0, w, h)
		
		-- Radial gradients
		local steps = 30
		for i = 1, steps do
			local alpha = math.max(0, 25 - i * 0.8)
			local radius = i * 30
			surface.SetDrawColor(255, 195, 105, alpha)
			draw.NoTexture()
			local cx, cy = w * 0.72, h * 0.50
			local circle = {}
			for j = 0, 360, 10 do
				local rad = math.rad(j)
				table.insert(circle, {x = cx + math.cos(rad) * radius, y = cy + math.sin(rad) * radius})
			end
			surface.DrawPoly(circle)
		end
		
		-- Second radial
		for i = 1, steps do
			local alpha = math.max(0, 30 - i * 1.0)
			local radius = i * 30
			surface.SetDrawColor(120, 210, 255, alpha)
			draw.NoTexture()
			local cx, cy = w * 0.25, h * 0.25
			local circle = {}
			for j = 0, 360, 10 do
				local rad = math.rad(j)
				table.insert(circle, {x = cx + math.cos(rad) * radius, y = cy + math.sin(rad) * radius})
			end
			surface.DrawPoly(circle)
		end
		
		-- VIGNETTE
		for i = 1, 35 do
			local dist = i * 30
			local alpha = math.Clamp((i / 35) * 153, 0, 235)
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawRect(0, h - dist, w, dist)
			surface.DrawRect(0, 0, w, dist)
			surface.DrawRect(0, 0, dist, h)
			surface.DrawRect(w - dist, 0, dist, h)
		end
		
		-- GRAIN (subtle)
		grainTime = grainTime + 0.005
		surface.SetDrawColor(255, 255, 255, 31)
		for x = 0, w, 6 do
			for y = 0, h, 6 do
				if (math.random() + grainTime * 0.1) % 1 > 0.75 then
					surface.DrawRect(x, y, 1, 1)
				end
			end
		end
		
		-- SCANLINES
		scanlineTime = (scanlineTime + 0.15) % 7
		surface.SetDrawColor(255, 255, 255, 41)
		for i = 0, h, 7 do
			surface.DrawRect(0, i + scanlineTime, w, 1)
		end
		
		-- LIGHT LEAKS (animated)
		leakTime = leakTime + 0.002
		local leakAlpha = math.abs(math.sin(leakTime)) * 20 + 15
		for i = 1, 20 do
			local x = w * 0.80 - (i * 30)
			local alpha = math.max(0, leakAlpha - i * 0.8)
			surface.SetDrawColor(255, 200, 120, alpha)
			surface.DrawRect(x, 0, 30, h)
		end
	end
	
	NRCHUD.CommsMenu.Frame = frame
	
	-- DEVICE CONTAINER (center, 1100x720)
	local deviceW = math.min(1100, scrW * 0.92)
	local deviceH = math.min(720, scrH * 0.92)
	local deviceX = (scrW - deviceW) / 2
	local deviceY = (scrH - deviceH) / 2 + scrH * 0.04
	
	local device = vgui.Create("DPanel", frame)
	device:SetPos(deviceX, deviceY)
	device:SetSize(deviceW, deviceH)
	device.Paint = function(s, w, h)
		-- Device background (glass morphism)
		draw.RoundedBox(22, 0, 0, w, h, Color(0, 0, 0, 46))
		
		-- Border
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Outer glow
		for i = 1, 4 do
			surface.SetDrawColor(120, 210, 255, 15 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		-- Shadow
		for i = 1, 15 do
			local offset = i * 3
			local alpha = math.max(0, 115 - i * 7)
			surface.SetDrawColor(0, 0, 0, alpha)
			draw.RoundedBox(22, -offset, -offset, w + offset * 2, h + offset * 2, Color(0, 0, 0, 0))
		end
	end
	
	-- HEADER (top, 60px)
	local header = vgui.Create("DPanel", device)
	header:SetPos(16, 16)
	header:SetSize(deviceW - 32, 50)
	header.Paint = function(s, w, h)
		-- Signature line
		local lineW = 52
		for i = 0, lineW do
			local alpha = (i / lineW) * 217
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(i, h / 2 - 1, i, h / 2 + 1)
		end
		
		-- Glow
		for i = 1, 3 do
			surface.SetDrawColor(120, 210, 255, 64 / i)
			surface.DrawRect(0, h / 2 - 1 - i, lineW, 2 + i * 2)
		end
		
		-- Brand text
		draw.SimpleText("REPUBLIK • COMMS UPLINK", "NRC_Comms_Sci_Small", lineW + 10, 10, Color(235, 248, 255, 173), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("PHASE II • SECURE TRANSCEIVER", "NRC_Comms_Mono_Tiny", lineW + 10, 27, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Pills (right side)
		local pillX = w - 10
		
		-- ENC pill
		local encW = 72
		local encX = pillX - encW
		draw.RoundedBox(999, encX, h / 2 - 16, encW, 32, Color(0, 0, 0, 46))
		surface.SetDrawColor(255, 195, 105, 41)
		surface.DrawOutlinedRect(encX, h / 2 - 16, encW, 32, 1)
		draw.SimpleText("ENC", "NRC_Comms_Mono_Tiny", encX + 10, h / 2 - 9, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(encryption and "AN" or "AUS", "NRC_Comms_Mono_Tiny", encX + 36, h / 2 - 9, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- BAT pill
		local batW = 72
		local batX = encX - batW - 8
		draw.RoundedBox(999, batX, h / 2 - 16, batW, 32, Color(0, 0, 0, 46))
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(batX, h / 2 - 16, batW, 32, 1)
		local bat = math.floor(58 + math.random() * 35)
		draw.SimpleText("BAT", "NRC_Comms_Mono_Tiny", batX + 10, h / 2 - 9, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(bat .. "%", "NRC_Comms_Mono_Tiny", batX + 36, h / 2 - 9, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- SIG pill
		local sigW = 72
		local sigX = batX - sigW - 8
		draw.RoundedBox(999, sigX, h / 2 - 16, sigW, 32, Color(0, 0, 0, 46))
		surface.SetDrawColor(120, 210, 255, 41)
		surface.DrawOutlinedRect(sigX, h / 2 - 16, sigW, 32, 1)
		local sig = math.floor(62 + math.random() * 34)
		draw.SimpleText("SIG", "NRC_Comms_Mono_Tiny", sigX + 10, h / 2 - 9, Color(235, 248, 255, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(sig .. "%", "NRC_Comms_Mono_Tiny", sigX + 36, h / 2 - 9, Color(235, 248, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- SCREEN CONTAINER (3-column grid)
	local screenY = 16 + 50 + 12
	local screenH = deviceH - screenY - 16 - 50 - 12
	local screenW = deviceW - 32
	
	NRCHUD.BuildChannelsPanel(device, 16, screenY, screenW * 0.25, screenH)
	NRCHUD.BuildCorePanel(device, 16 + screenW * 0.25 + 12, screenY, screenW * 0.45, screenH)
	NRCHUD.BuildLogPanel(device, 16 + screenW * 0.25 + 12 + screenW * 0.45 + 12, screenY, screenW * 0.28, screenH)
	
	-- FOOTER (bottom chips)
	local footer = vgui.Create("DPanel", device)
	footer:SetPos(16, deviceH - 16 - 42)
	footer:SetSize(deviceW - 32, 42)
	footer.Paint = function(s, w, h)
		-- Chips
		local chipX = 0
		local chips = {"REPUBLIK", "PHASE II", NRCHUD.PlayerData.commsChannel or "PLATOON"}
		
		for i, chip in ipairs(chips) do
			local isActive = (i == 3)
			local chipW = surface.GetTextSize(chip) + 20
			
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
	
	-- BOOT SEQUENCE
	timer.Simple(0.1, function()
		AddLogLine("[BOOT] Transceiver wird gestartet…", Color(120, 210, 255, 230))
	end)
	
	local bootSteps = {
		{sub = "Initialisiere Transceiver…", hint = "Kalibriere Frequenzen…", progress = 18},
		{sub = "Lade Verschlüsselungsmodul…", hint = "Schlüssel werden gesetzt…", progress = 42},
		{sub = "Verbinde Holonet-Router…", hint = "Routing wird bestätigt…", progress = 66},
		{sub = "Prüfe Signalstärke…", hint = "Antenne ausgerichtet…", progress = 84},
		{sub = "Handshake abgeschlossen.", hint = "Bereit.", progress = 100},
	}
	
	local function RunBootStep(step)
		if step > #bootSteps then
			timer.Simple(0.3, function()
				showingBoot = false
				AddLogLine("[OK] Uplink steht. Standby.", Color(120, 210, 255, 230))
			end)
			return
		end
		
		bootStage = step
		timer.Simple(0.5, function()
			bootProgress = bootSteps[step].progress
			-- Glitch effect would go here
			RunBootStep(step + 1)
		end)
	end
	
	timer.Simple(0.3, function() RunBootStep(1) end)
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

-- Build panels (separate functions for organization)
function NRCHUD.BuildChannelsPanel(parent, x, y, w, h)
	local panel = vgui.Create("DPanel", parent)
	panel:SetPos(x, y)
	panel:SetSize(w, h)
	panel.Paint = function(s, pw, ph)
		-- Panel background
		draw.RoundedBox(18, 0, 0, pw, ph, Color(0, 0, 0, 61))
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, pw, ph, 1)
		
		-- Title
		draw.SimpleText("KANÄLE", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Channel buttons
		local channels = {
			{name = "PLATOON", desc = "Trupp / Squad Funk", y = 40, danger = false},
			{name = "COMPANY", desc = "Kompanie", y = 130, danger = false},
			{name = "COMMAND", desc = "Führung / HQ", y = 220, danger = false},
			{name = "EMERGENCY", desc = "Notfall / Priorität", y = 310, danger = true},
		}
		
		for _, chan in ipairs(channels) do
			local isActive = (NRCHUD.PlayerData.commsChannel == chan.name)
			local bx, by, bw, bh = 12, chan.y, pw - 24, 75
			
			-- Button
			draw.RoundedBox(14, bx, by, bw, bh, Color(0, 0, 0, 41))
			
			if isActive then
				surface.SetDrawColor(255, 195, 105, 51)
			else
				surface.SetDrawColor(120, 210, 255, chan.danger and 36 or 31)
			end
			surface.DrawOutlinedRect(bx, by, bw, bh, 1)
			
			draw.SimpleText(chan.name, "NRC_Comms_Sci_Small", bx + 10, by + 12, Color(235, 248, 255, 209), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(chan.desc, "NRC_Comms_Mono_Tiny", bx + 10, by + 32, Color(235, 248, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			if isActive then
				draw.SimpleText("✓ AKTIV", "NRC_Comms_Mono_Tiny", bx + 10, by + 52, Color(255, 195, 105, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
		
		-- Divider
		local divY = 410
		for i = 0, pw - 24 do
			local alpha = math.sin((i / (pw - 24)) * math.pi) * 56
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(12 + i, divY, 12 + i, divY)
		end
		
		-- Meta info
		local metaY = divY + 12
		local metas = {
			{k = "FREQUENZ", v = "133.70 MHz"},
			{k = "CODE", v = "AURORA-7"},
			{k = "ROUTE", v = "HOLONET"},
		}
		
		for i, meta in ipairs(metas) do
			local my = metaY + (i - 1) * 24
			draw.SimpleText(meta.k, "NRC_Comms_Mono_Tiny", 12, my, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(meta.v, "NRC_Comms_Mono_Tiny", pw - 12, my, Color(235, 248, 255, 214), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end
	end
end

function NRCHUD.BuildCorePanel(parent, x, y, w, h)
	local panel = vgui.Create("DPanel", parent)
	panel:SetPos(x, y)
	panel:SetSize(w, h)
	panel.Paint = function(s, pw, ph)
		-- Panel background
		draw.RoundedBox(18, 0, 0, pw, ph, Color(0, 0, 0, 61))
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, pw, ph, 1)
		
		-- Title row
		draw.SimpleText("TRANSMISSION", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(pttActive and "SENDEN" or "STANDBY", "NRC_Comms_Sci_Small", pw - 12, 12, Color(255, 195, 105, 209), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		
		-- Waveform box
		local waveX, waveY = 12, 40
		local waveW, waveH = pw - 24, 210
		
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
		
		-- Waveform animation
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
		
		-- Waveform glow
		for i = 1, 15 do
			local alpha = math.max(0, 25 - i * 1.5)
			local radius = i * 15
			surface.SetDrawColor(pttActive and 255 or 120, pttActive and 195 or 210, pttActive and 105 or 255, alpha)
			draw.NoTexture()
			local cx, cy = waveX + waveW / 2, waveY + waveH / 2
			local circle = {}
			for j = 0, 360, 15 do
				local rad = math.rad(j)
				table.insert(circle, {x = cx + math.cos(rad) * radius, y = cy + math.sin(rad) * radius})
			end
			surface.DrawPoly(circle)
		end
		
		-- Wave label
		draw.SimpleText("CHANNEL:", "NRC_Comms_Mono_Tiny", waveX + 14, waveY + waveH - 20, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(NRCHUD.PlayerData.commsChannel or "PLATOON", "NRC_Comms_Mono_Tiny", waveX + 90, waveY + waveH - 20, Color(235, 248, 255, 219), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Dot indicator
		local dotX = waveX + 185
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
		
		-- Controls (3 buttons)
		local ctrlY = waveY + waveH + 12
		local btnW = (pw - 24 - 20) / 3
		local buttons = {
			{label = "ENC", sub = "Verschlüsselung", x = 12},
			{label = "PING", sub = "Signaltest", x = 12 + btnW + 10},
			{label = "PTT", sub = "Sprechen", x = 12 + btnW * 2 + 20, ptt = true},
		}
		
		for _, btn in ipairs(buttons) do
			local isActive = btn.ptt and pttActive
			
			draw.RoundedBox(16, btn.x, ctrlY, btnW, 58, Color(0, 0, 0, 46))
			
			if btn.ptt then
				surface.SetDrawColor(255, 195, 105, isActive and 77 or 46)
			else
				surface.SetDrawColor(120, 210, 255, 36)
			end
			surface.DrawOutlinedRect(btn.x, ctrlY, btnW, 58, 1)
			
			draw.SimpleText(btn.label, "NRC_Comms_Sci_Small", btn.x + 10, ctrlY + 12, Color(120, 210, 255, 224), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(btn.sub, "NRC_Comms_Mono_Tiny", btn.x + 10, ctrlY + 32, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		
		-- Hint
		local hintY = ctrlY + 68
		local hint = pttActive and "Übertragung läuft… (PTT gehalten)" or "Tip: Halte PTT gedrückt (UI), Hook später auf Voice/Radio."
		draw.SimpleText(hint, "NRC_Comms_Mono_Tiny", 12, hintY, Color(235, 248, 255, 143), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
end

function NRCHUD.BuildLogPanel(parent, x, y, w, h)
	local panel = vgui.Create("DPanel", parent)
	panel:SetPos(x, y)
	panel:SetSize(w, h)
	panel.Paint = function(s, pw, ph)
		-- Panel background
		draw.RoundedBox(18, 0, 0, pw, ph, Color(0, 0, 0, 61))
		surface.SetDrawColor(120, 210, 255, 36)
		surface.DrawOutlinedRect(0, 0, pw, ph, 1)
		
		-- Title
		draw.SimpleText("LOG", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Log lines
		local logY = 40
		for i, line in ipairs(logLines) do
			local lineY = logY + (i - 1) * 18
			draw.SimpleText(line.text, "NRC_Comms_Mono_Small", 12, lineY, line.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		
		-- Divider
		local divY = ph - 120
		for i = 0, pw - 24 do
			local alpha = math.sin((i / (pw - 24)) * math.pi) * 56
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(12 + i, divY, 12 + i, divY)
		end
		
		-- Mini boxes
		local miniY = divY + 12
		local miniW = (pw - 24 - 10) / 2
		
		-- UPLINK
		draw.RoundedBox(14, 12, miniY, miniW, 55, Color(0, 0, 0, 36))
		surface.SetDrawColor(120, 210, 255, 26)
		surface.DrawOutlinedRect(12, miniY, miniW, 55, 1)
		draw.SimpleText("UPLINK", "NRC_Comms_Sci_Small", 22, miniY + 12, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("STABIL", "NRC_Comms_Mono_Tiny", 22, miniY + 32, Color(90, 255, 190, 224), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- LATENZ
		local latX = 12 + miniW + 10
		draw.RoundedBox(14, latX, miniY, miniW, 55, Color(0, 0, 0, 36))
		surface.SetDrawColor(120, 210, 255, 26)
		surface.DrawOutlinedRect(latX, miniY, miniW, 55, 1)
		draw.SimpleText("LATENZ", "NRC_Comms_Sci_Small", latX + 10, miniY + 12, Color(235, 248, 255, 158), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		local lat = math.floor(24 + math.random() * 8)
		draw.SimpleText(lat .. " ms", "NRC_Comms_Mono_Tiny", latX + 10, miniY + 32, Color(235, 248, 255, 209), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
end

-- Boot overlay (drawn over everything)
function NRCHUD.DrawBootOverlay(device, w, h)
	if not showingBoot then return end
	
	local bootSteps = {
		{sub = "Initialisiere Transceiver…", hint = "Kalibriere Frequenzen…"},
		{sub = "Lade Verschlüsselungsmodul…", hint = "Schlüssel werden gesetzt…"},
		{sub = "Verbinde Holonet-Router…", hint = "Routing wird bestätigt…"},
		{sub = "Prüfe Signalstärke…", hint = "Antenne ausgerichtet…"},
		{sub = "Handshake abgeschlossen.", hint = "Bereit."},
	}
	
	local bx, by = 14, 70
	local bw, bh = w - 28, h - 140
	
	-- Overlay
	draw.RoundedBox(16, bx, by, bw, bh, Color(0, 0, 0, 140))
	surface.SetDrawColor(120, 210, 255, 36)
	surface.DrawOutlinedRect(bx, by, bw, bh, 1)
	
	-- Title
	draw.SimpleText("HANDSHAKE", "NRC_Comms_Sci", bx + bw / 2, by + bh / 2 - 50, Color(120, 210, 255, 217), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	
	if bootStage <= #bootSteps then
		local step = bootSteps[bootStage]
		draw.SimpleText(step.sub, "NRC_Comms_Mono", bx + bw / 2, by + bh / 2 - 20, Color(235, 248, 255, 184), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	
	-- Progress bar
	local barW = bw * 0.7
	local barX = bx + (bw - barW) / 2
	local barY = by + bh / 2 + 10
	
	draw.RoundedBox(999, barX, barY, barW, 12, Color(0, 0, 0, 56))
	surface.SetDrawColor(120, 210, 255, 41)
	surface.DrawOutlinedRect(barX, barY, barW, 12, 1)
	
	local fillW = (bootProgress / 100) * barW
	draw.RoundedBox(999, barX, barY, fillW, 12, Color(120, 210, 255, 140))
	
	if bootStage <= #bootSteps then
		local step = bootSteps[bootStage]
		draw.SimpleText(step.hint, "NRC_Comms_Mono_Tiny", bx + bw / 2, barY + 25, Color(235, 248, 255, 148), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

concommand.Add("nrc_comms", function()
	NRCHUD.OpenCommsMenu()
end)

print("[NRC HUD] Comms menu (EPIC REDESIGN) loaded!")