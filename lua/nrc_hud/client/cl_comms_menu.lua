-- NRC Star Wars HUD - Comms Menu

surface.CreateFont("NRC_Comms_Sci_Big", {font = "Orbitron", size = 24, weight = 700, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Sci", {font = "Orbitron", size = 14, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Sci_Small", {font = "Orbitron", size = 12, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono", {font = "Share Tech Mono", size = 14, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono_Small", {font = "Share Tech Mono", size = 13, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_Comms_Mono_Tiny", {font = "Share Tech Mono", size = 12, weight = 400, antialias = true, extended = true})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}
NRCHUD.PlayerData = NRCHUD.PlayerData or {}

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
	currentChannel = (NRCHUD.PlayerData and NRCHUD.PlayerData.commsChannel) or "Battalion Net"
	
	-- FULLSCREEN FRAME
	local frame = vgui.Create("DFrame")
	frame:SetSize(scrW, scrH)
	frame:SetPos(0, 0)
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame.Paint = nil
	
	-- ESC Handler
	frame.OnKeyCodePressed = function(self, key)
		if key == KEY_ESCAPE then
			self:Remove()
			return true
		end
	end
	
	frame.OnRemove = function()
		timer.Remove("NRCHUD_CommsBootSequence")
		pttActive = false
	end
	
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
		draw.RoundedBox(22, 0, 0, w, h, Color(5, 8, 15, 235))
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end
	
	NRCHUD.CommsMenu.Device = device
	
	-- CLOSE BUTTON (X)
	local closeBtn = vgui.Create("DButton", device)
	closeBtn:SetPos(deviceW - 60, 28)
	closeBtn:SetSize(32, 32)
	closeBtn:SetText("")
	closeBtn.Paint = function(sb, bw, bh)
		draw.RoundedBox(999, 0, 0, bw, bh, Color(10, 12, 20, 200))
		
		if sb:IsHovered() then
			surface.SetDrawColor(255, 100, 100, 128)
		else
			surface.SetDrawColor(120, 210, 255, 77)
		end
		surface.DrawOutlinedRect(0, 0, bw, bh, 1)
		
		local pad = 8
		surface.SetDrawColor(sb:IsHovered() and Color(255, 100, 100, 255) or Color(120, 210, 255, 255))
		surface.DrawLine(pad, pad, bw - pad, bh - pad)
		surface.DrawLine(bw - pad, pad, pad, bh - pad)
	end
	closeBtn.DoClick = function()
		frame:Remove()
		surface.PlaySound("buttons/button14.wav")
	end
	
	-- HEADER
	local header = vgui.Create("DPanel", device)
	header:SetPos(16, 16)
	header:SetSize(deviceW - 32, 50)
	header.Paint = function(s, w, h)
		for i = 0, 52 do
			local alpha = (i / 52) * 217
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawLine(i, h / 2 - 1, i, h / 2 + 1)
		end
		
		draw.SimpleText("REPUBLIK • COMMS UPLINK", "NRC_Comms_Sci_Small", 62, 10, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("PHASE II • SECURE TRANSCEIVER", "NRC_Comms_Mono_Tiny", 62, 27, Color(235, 248, 255, 217), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local pillX = w - 60
		
		-- ENC
		local encW = 72
		local encX = pillX - encW
		draw.RoundedBox(999, encX, h / 2 - 16, encW, 32, Color(10, 12, 20, 200))
		surface.SetDrawColor(255, 195, 105, 77)
		surface.DrawOutlinedRect(encX, h / 2 - 16, encW, 32, 1)
		draw.SimpleText("ENC", "NRC_Comms_Mono_Tiny", encX + 10, h / 2 - 9, Color(235, 248, 255, 217), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(encryption and "AN" or "AUS", "NRC_Comms_Mono_Tiny", encX + 36, h / 2 - 9, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- BAT
		local batW = 72
		local batX = encX - batW - 8
		draw.RoundedBox(999, batX, h / 2 - 16, batW, 32, Color(10, 12, 20, 200))
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(batX, h / 2 - 16, batW, 32, 1)
		local bat = math.floor(58 + math.random() * 35)
		draw.SimpleText("BAT", "NRC_Comms_Mono_Tiny", batX + 10, h / 2 - 9, Color(235, 248, 255, 217), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(bat .. "%", "NRC_Comms_Mono_Tiny", batX + 36, h / 2 - 9, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- SIG
		local sigW = 72
		local sigX = batX - sigW - 8
		draw.RoundedBox(999, sigX, h / 2 - 16, sigW, 32, Color(10, 12, 20, 200))
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(sigX, h / 2 - 16, sigW, 32, 1)
		local sig = math.floor(62 + math.random() * 34)
		draw.SimpleText("SIG", "NRC_Comms_Mono_Tiny", sigX + 10, h / 2 - 9, Color(235, 248, 255, 217), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(sig .. "%", "NRC_Comms_Mono_Tiny", sigX + 36, h / 2 - 9, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	-- SCREEN
	local screenY = 16 + 50 + 12
	local screenH = deviceH - screenY - 16 - 50 - 12
	local screenW = deviceW - 32
	
	local col1W = screenW * 0.25
	local col2W = screenW * 0.45
	local col3W = screenW * 0.28
	
	-- CHANNELS COLUMN
	local channelsPanel = vgui.Create("DPanel", device)
	channelsPanel:SetPos(16, screenY)
	channelsPanel:SetSize(col1W, screenH)
	channelsPanel.Paint = function(s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(10, 12, 20, 200))
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText("CHANNELS", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 255))
	end
	
	local channelY = 40
	for name, data in pairs(channelData) do
		local btn = vgui.Create("DButton", channelsPanel)
		btn:SetPos(12, channelY)
		btn:SetSize(col1W - 24, 60)
		btn:SetText("")
		btn.Paint = function(b, w, h)
			local isActive = (currentChannel == name)
			local bgColor = isActive and Color(20, 40, 80, 230) or Color(15, 18, 25, 180)
			
			draw.RoundedBox(6, 0, 0, w, h, bgColor)
			
			if isActive then
				surface.SetDrawColor(120, 210, 255, 179)
			else
				surface.SetDrawColor(120, 210, 255, b:IsHovered() and 128 or 77)
			end
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			
			draw.SimpleText(name, "NRC_Comms_Sci", 10, 8, Color(235, 248, 255, 255))
			draw.SimpleText(data.freq, "NRC_Comms_Mono_Small", 10, 28, Color(120, 210, 255, 255))
			
			local userCount = NRCHUD.ChannelUserCounts[name] or math.random(3, 12)
			draw.SimpleText(userCount .. " USERS", "NRC_Comms_Mono_Tiny", 10, 44, Color(235, 248, 255, 179))
		end
		
		btn.DoClick = function()
			currentChannel = name
			AddLogLine("[SWITCH] Channel: " .. name, Color(120, 210, 255, 255))
			net.Start("NRCHUD_SetCommsChannel")
			net.WriteString(name)
			net.SendToServer()
			surface.PlaySound("buttons/button14.wav")
		end
		
		channelY = channelY + 68
	end
	
	-- WAVEFORM COLUMN
	local wavePanel = vgui.Create("DPanel", device)
	wavePanel:SetPos(16 + col1W + 12, screenY)
	wavePanel:SetSize(col2W, screenH)
	wavePanel.Paint = function(s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(10, 12, 20, 200))
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText("SIGNAL ANALYZER", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 255))
		
		-- Waveform
		local waveY = h / 2
		local waveH = 80
		local samples = 120
		
		waveTime = waveTime + FrameTime() * 4
		
		surface.SetDrawColor(120, 210, 255, 128)
		surface.DrawLine(20, waveY, w - 20, waveY)
		
		for i = 0, samples - 1 do
			local x = 20 + (i / samples) * (w - 40)
			local freq = (pttActive and 2.5 or 0.8)
			local amp = (pttActive and waveH * 0.7 or waveH * 0.15)
			local y = waveY + math.sin(waveTime + i * 0.3) * amp
			
			local nextX = 20 + ((i + 1) / samples) * (w - 40)
			local nextY = waveY + math.sin(waveTime + (i + 1) * 0.3) * amp
			
			surface.SetDrawColor(120, 210, 255, 255)
			surface.DrawLine(x, y, nextX, nextY)
			
			surface.SetDrawColor(120, 210, 255, 64)
			surface.DrawLine(x, y + 1, nextX, nextY + 1)
		end
		
		-- Info display
		local infoY = h - 120
		local cData = channelData[currentChannel]
		if cData then
			draw.SimpleText("ACTIVE: " .. currentChannel, "NRC_Comms_Mono", 12, infoY, Color(120, 210, 255, 255))
			draw.SimpleText("FREQ: " .. cData.freq, "NRC_Comms_Mono_Small", 12, infoY + 20, Color(235, 248, 255, 179))
			draw.SimpleText("ROUTE: " .. cData.route, "NRC_Comms_Mono_Small", 12, infoY + 38, Color(235, 248, 255, 179))
			
			if pttActive then
				draw.SimpleText("⬤ TRANSMITTING", "NRC_Comms_Sci_Small", w - 12, infoY, Color(255, 100, 100, 255), TEXT_ALIGN_RIGHT)
			end
		end
	end
	
	-- LOG COLUMN
	local logPanel = vgui.Create("DPanel", device)
	logPanel:SetPos(16 + col1W + col2W + 24, screenY)
	logPanel:SetSize(col3W, screenH)
	logPanel.Paint = function(s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(10, 12, 20, 200))
		surface.SetDrawColor(120, 210, 255, 77)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		draw.SimpleText("EVENT LOG", "NRC_Comms_Sci_Small", 12, 12, Color(235, 248, 255, 255))
		
		local logY = 40
		for _, line in ipairs(logLines) do
			local age = CurTime() - line.time
			local alpha = math.Clamp(255 - age * 50, 50, 255)
			local col = ColorAlpha(line.color, alpha)
			
			draw.SimpleText(line.text, "NRC_Comms_Mono_Tiny", 12, logY, col)
			logY = logY + 18
		end
	end
	
	-- BOOT SEQUENCE
	timer.Create("NRCHUD_CommsBootSequence", 0.05, 0, function()
		if not IsValid(frame) then
			timer.Remove("NRCHUD_CommsBootSequence")
			return
		end
		
		if showingBoot then
			bootProgress = bootProgress + 3
			
			if bootProgress >= 100 and bootStage == 1 then
				bootStage = 2
				bootProgress = 0
				AddLogLine("[BOOT] Initializing comms array...")
			elseif bootProgress >= 100 and bootStage == 2 then
				bootStage = 3
				bootProgress = 0
				AddLogLine("[AUTH] Credentials verified")
			elseif bootProgress >= 100 and bootStage == 3 then
				showingBoot = false
				AddLogLine("[READY] Transceiver online", Color(74, 222, 128, 255))
			end
		end
	end)
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

if not NRCHUD.CommsNetworkInit then
	NRCHUD.CommsNetworkInit = true
	
	net.Receive("NRCHUD_UpdateCommsChannel", function()
		local channel = net.ReadString()
		NRCHUD.PlayerData.commsChannel = channel
	end)
	
	net.Receive("NRCHUD_UpdateChannelUsers", function()
		local count = net.ReadUInt(8)
		for i = 1, count do
			local channel = net.ReadString()
			local users = net.ReadUInt(8)
			NRCHUD.ChannelUserCounts[channel] = users
		end
	end)
end

concommand.Add("nrc_comms", function()
	NRCHUD.OpenCommsMenu()
end)

print("[NRC HUD] Comms menu loaded!")