-- NRC Star Wars HUD - Comms Menu (Transparent + Member Tracking)

surface.CreateFont("NRC_Comms_Title", {font = "Orbitron", size = 32, weight = 900, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Header", {font = "Orbitron", size = 22, weight = 700, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Small", {font = "Orbitron", size = 16, weight = 600, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Tiny", {font = "Orbitron", size = 13, weight = 600, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Mono", {font = "Share Tech Mono", size = 15, weight = 400, antialias = true, extended = true, shadow = true})
surface.CreateFont("NRC_Comms_Mono_Small", {font = "Share Tech Mono", size = 12, weight = 400, antialias = true, extended = true, shadow = true})

NRCHUD.CommsMenu = NRCHUD.CommsMenu or {}
NRCHUD.ChannelUserCounts = NRCHUD.ChannelUserCounts or {}
NRCHUD.ChannelMembers = NRCHUD.ChannelMembers or {} -- NEW: Member list with positions

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
	
	-- LEFT PANEL (Channel List) - FULLY TRANSPARENT
	local leftPanel = vgui.Create("DPanel", frame)
	leftPanel:SetPos(contentX, contentY)
	leftPanel:SetSize(contentW * 0.45, contentH)
	leftPanel.Paint = function(s, w, h)
		-- FULLY TRANSPARENT BACKGROUND (no effects!)
		-- Just a subtle border
		surface.SetDrawColor(120, 210, 255, 77) -- Cyan border only
		for i = 0, 1 do
			surface.DrawOutlinedRect(i, i, w - i * 2, h - i * 2, 1)
		end
		
		-- Subtle glow
		for i = 1, 3 do
			local alpha = 30 / i
			surface.SetDrawColor(120, 210, 255, alpha)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
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
		
		-- Title
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
		
		for i = 1, 2 do
			surface.SetDrawColor(120, 210, 255, 64 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
	end
	sbar.btnUp:SetVisible(false)
	sbar.btnDown:SetVisible(false)
	
	NRCHUD.CommsMenu.Scroll = scroll
	NRCHUD.BuildChannelList(scroll)
	
	-- RIGHT PANEL (Member Location Tracking) - FULLY TRANSPARENT
	local rightPanel = vgui.Create("DPanel", frame)
	rightPanel:SetPos(contentX + leftPanel:GetWide() + 20, contentY)
	rightPanel:SetSize(contentW * 0.53, contentH)
	rightPanel.Paint = function(s, w, h)
		-- FULLY TRANSPARENT (no background effects!)
		-- Just border
		surface.SetDrawColor(120, 210, 255, 51)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		
		-- Subtle glow
		for i = 1, 3 do
			surface.SetDrawColor(120, 210, 255, 20 / i)
			surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
		end
		
		-- Header
		local activeChannel = NRCHUD.PlayerData.commsChannel or "Command Net"
		draw.SimpleText("ACTIVE CHANNEL", "NRC_Comms_Tiny", w / 2, 18, Color(235, 248, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(activeChannel, "NRC_Comms_Small", w / 2, 38, Color(74, 222, 128, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("445.750 MHz", "NRC_Comms_Mono_Small", w / 2, 62, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		
		-- Separator line
		surface.SetDrawColor(120, 210, 255, 51)
		surface.DrawRect(20, 90, w - 40, 1)
		
		-- Member tracking header
		draw.SimpleText("MEMBER LOCATIONS", "NRC_Comms_Tiny", w / 2, 100, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	
	-- MEMBER SCROLL (Location Tracking)
	local memberScroll = vgui.Create("DScrollPanel", rightPanel)
	memberScroll:SetPos(14, 130)
	memberScroll:SetSize(rightPanel:GetWide() - 28, rightPanel:GetTall() - 190)
	memberScroll.Paint = nil
	
	local msbar = memberScroll:GetVBar()
	msbar:SetWide(10)
	msbar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 102)
		draw.RoundedBox(999, 0, 0, w, h, Color(0, 0, 0, 102))
	end
	msbar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(999, 0, 0, w, h, Color(120, 210, 255, 77))
		surface.SetDrawColor(120, 210, 255, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	msbar.btnUp:SetVisible(false)
	msbar.btnDown:SetVisible(false)
	
	NRCHUD.CommsMenu.MemberScroll = memberScroll
	NRCHUD.BuildMemberList(memberScroll)
	
	-- Auto-refresh member list every 2 seconds
	timer.Create("NRCHUD_MemberRefresh", 2, 0, function()
		if IsValid(NRCHUD.CommsMenu.MemberScroll) then
			NRCHUD.BuildMemberList(NRCHUD.CommsMenu.MemberScroll)
		end
	end)
	
	-- Close button
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
		timer.Remove("NRCHUD_MemberRefresh")
		frame:Remove()
	end
	
	-- Fade in
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

-- Build Channel List (left panel)
function NRCHUD.BuildChannelList(parent)
	parent:Clear()
	
	local yOffset = 0
	local padding = 14
	local panelW = parent:GetWide() - 10
	
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
		card:SetPos(0, yOffset)
		card:SetSize(panelW, 85)
		card:SetText("")
		
		card.Paint = function(s, w, h)
			local active = (NRCHUD.PlayerData.commsChannel == name)
			
			if active then
				draw.RoundedBox(14, 0, 0, w, h, Color(0, 60, 50, 150))
			else
				draw.RoundedBox(14, 0, 0, w, h, Color(0, 0, 0, 92))
			end
			
			if active then
				surface.SetDrawColor(74, 222, 128, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				
				for i = 1, 4 do
					surface.SetDrawColor(74, 222, 128, 128 / i)
					surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
				end
			else
				surface.SetDrawColor(120, 210, 255, 51)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
			
			if s:IsHovered() and not active then
				for i = 1, 3 do
					surface.SetDrawColor(120, 210, 255, 102 / i)
					surface.DrawOutlinedRect(-i, -i, w + i * 2, h + i * 2, 1)
				end
			end
			
			draw.SimpleText(name, "NRC_Comms_Small", 15, 14, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(data.freq, "NRC_Comms_Mono_Small", 15, 42, Color(235, 248, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			local users = NRCHUD.ChannelUserCounts[name] or 0
			draw.SimpleText(users .. " users", "NRC_Comms_Mono_Small", 15, 62, Color(120, 210, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			if data.priority and data.priority >= 8 then
				local badgeX = w - 55
				local badgeY = 12
				
				draw.RoundedBox(999, badgeX, badgeY, 45, 20, Color(255, 195, 105, 77))
				surface.SetDrawColor(255, 195, 105, 179)
				surface.DrawOutlinedRect(badgeX, badgeY, 45, 20, 1)
				
				draw.SimpleText("[P" .. data.priority .. "]", "NRC_Comms_Mono_Small", badgeX + 22, badgeY + 10, Color(255, 195, 105, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			if active then
				local chipW = 110
				local chipX = w - chipW - 12
				local chipY = h - 28
				
				draw.RoundedBox(999, chipX, chipY, chipW, 22, Color(74, 222, 128, 77))
				surface.SetDrawColor(74, 222, 128, 230)
				surface.DrawOutlinedRect(chipX, chipY, chipW, 22, 1)
				
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
				
				-- Refresh member list for new channel
				if IsValid(NRCHUD.CommsMenu.MemberScroll) then
					NRCHUD.BuildMemberList(NRCHUD.CommsMenu.MemberScroll)
				end
				
				surface.PlaySound("buttons/lightswitch2.wav")
			end
		end
		
		yOffset = yOffset + 85 + padding
	end
end

-- NEW: Build Member List with Live Location Tracking (right panel)
function NRCHUD.BuildMemberList(parent)
	parent:Clear()
	
	local activeChannel = NRCHUD.PlayerData.commsChannel or "Command Net"
	local members = {}
	
	-- Get all players on this channel
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) then
			-- Check if on same channel (you can customize this check)
			local plyChannel = ply:GetNWString("NRCHUD_Channel", "Command Net")
			
			if plyChannel == activeChannel then
				table.insert(members, {
					ply = ply,
					name = ply:Nick(),
					pos = ply:GetPos(),
					dist = LocalPlayer():GetPos():Distance(ply:GetPos()),
					health = ply:Health(),
					armor = ply:Armor(),
				})
			end
		end
	end
	
	-- Sort by distance
	table.sort(members, function(a, b) return a.dist < b.dist end)
	
	-- Build member cards
	local yOffset = 0
	local padding = 10
	local panelW = parent:GetWide() - 10
	
	if #members == 0 then
		-- No members
		local noMembers = vgui.Create("DLabel", parent)
		noMembers:SetPos(0, 0)
		noMembers:SetSize(panelW, 50)
		noMembers:SetFont("NRC_Comms_Mono_Small")
		noMembers:SetText("No members in this channel")
		noMembers:SetTextColor(Color(255, 255, 255, 153))
		noMembers:SetContentAlignment(5)
		return
	end
	
	for _, member in ipairs(members) do
		local card = vgui.Create("DPanel", parent)
		card:SetPos(0, yOffset)
		card:SetSize(panelW, 70)
		
		card.Paint = function(s, w, h)
			local isLocalPlayer = (member.ply == LocalPlayer())
			
			-- Background
			if isLocalPlayer then
				draw.RoundedBox(10, 0, 0, w, h, Color(120, 210, 255, 51)) -- You = cyan
			else
				draw.RoundedBox(10, 0, 0, w, h, Color(0, 0, 0, 77))
			end
			
			-- Border
			if isLocalPlayer then
				surface.SetDrawColor(120, 210, 255, 179)
			else
				surface.SetDrawColor(120, 210, 255, 51)
			end
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			
			-- Player name
			local nameStr = member.name
			if isLocalPlayer then nameStr = nameStr .. " (You)" end
			
			draw.SimpleText(nameStr, "NRC_Comms_Small", 12, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Distance + Direction
			local distStr = string.format("%.0fm", member.dist / 39.37) -- units to meters
			local dir = (member.pos - LocalPlayer():GetPos()):GetNormalized()
			local angle = math.deg(math.atan2(dir.y, dir.x))
			local compass = NRCHUD.GetCompassDirection(angle)
			
			draw.SimpleText(distStr .. " " .. compass, "NRC_Comms_Mono_Small", 12, 36, Color(120, 210, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Health/Armor indicators (right side)
			local healthPercent = math.Clamp(member.health / 100, 0, 1)
			local healthColor = Color(
				Lerp(healthPercent, 255, 74),
				Lerp(healthPercent, 68, 222),
				Lerp(healthPercent, 68, 128)
			)
			
			-- Health bar (mini)
			local barX = w - 80
			local barY = 20
			local barW = 65
			local barH = 6
			
			surface.SetDrawColor(0, 0, 0, 128)
			surface.DrawRect(barX, barY, barW, barH)
			
			local fillW = barW * healthPercent
			surface.SetDrawColor(healthColor)
			surface.DrawRect(barX, barY, fillW, barH)
			
			draw.SimpleText("HP", "NRC_Comms_Mono_Small", barX - 22, barY, Color(255, 255, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			
			-- Armor bar (mini)
			if member.armor > 0 then
				local armorY = barY + 12
				local armorPercent = math.Clamp(member.armor / 100, 0, 1)
				
				surface.SetDrawColor(0, 0, 0, 128)
				surface.DrawRect(barX, armorY, barW, barH)
				
				local armorFill = barW * armorPercent
				surface.SetDrawColor(255, 255, 255, 179)
				surface.DrawRect(barX, armorY, armorFill, barH)
				
				draw.SimpleText("AR", "NRC_Comms_Mono_Small", barX - 22, armorY, Color(255, 255, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
			
			-- Status indicator (alive/dead)
			local statusCol = member.ply:Alive() and Color(74, 222, 128, 255) or Color(239, 68, 68, 255)
			local statusText = member.ply:Alive() and "● ALIVE" or "● KIA"
			
			draw.SimpleText(statusText, "NRC_Comms_Mono_Small", 12, 52, statusCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		
		yOffset = yOffset + 70 + padding
	end
end

-- Helper: Convert angle to compass direction
function NRCHUD.GetCompassDirection(angle)
	angle = (angle + 360) % 360
	
	if angle >= 337.5 or angle < 22.5 then return "E"
	elseif angle >= 22.5 and angle < 67.5 then return "NE"
	elseif angle >= 67.5 and angle < 112.5 then return "N"
	elseif angle >= 112.5 and angle < 157.5 then return "NW"
	elseif angle >= 157.5 and angle < 202.5 then return "W"
	elseif angle >= 202.5 and angle < 247.5 then return "SW"
	elseif angle >= 247.5 and angle < 292.5 then return "S"
	else return "SE"
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

print("[NRC HUD] Comms menu (Transparent + Member Tracking) loaded!")