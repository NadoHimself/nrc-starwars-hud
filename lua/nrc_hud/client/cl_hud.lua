-- NRC Star Wars HUD - Main HUD Rendering (Battlefront II Style)

-- Disable default HUD elements
local hideHUD = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudDamageIndicator"] = true,
	["DarkRP_HUD"] = true,
	["DarkRP_EntityDisplay"] = true,
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_Agenda"] = true,
	["DarkRP_ChatReceivers"] = true
}

hook.Add("HUDShouldDraw", "NRCHUD_HideDefault", function(name)
	if hideHUD[name] then return false end
end)

hook.Add("HUDDrawTargetID", "NRCHUD_HideDarkRP", function()
	return false
end)

hook.Add("HUDDrawPickupHistory", "NRCHUD_HideDarkRP", function()
	return false
end)

-- Fonts - Battlefront II Style
surface.CreateFont("NRCHUD_Identity_Name", {
	font = "Orbitron",
	size = 15,
	weight = 600,
	antialias = true
})

surface.CreateFont("NRCHUD_Identity_Rank", {
	font = "Share Tech Mono",
	size = 10,
	weight = 400,
	antialias = true
})

surface.CreateFont("NRCHUD_Vital_Label", {
	font = "Share Tech Mono",
	size = 10,
	weight = 400,
	antialias = true
})

surface.CreateFont("NRCHUD_Vital_Value", {
	font = "Orbitron",
	size = 12,
	weight = 600,
	antialias = true
})

surface.CreateFont("NRCHUD_Currency", {
	font = "Orbitron",
	size = 16,
	weight = 600,
	antialias = true
})

surface.CreateFont("NRCHUD_Currency_Label", {
	font = "Share Tech Mono",
	size = 9,
	weight = 400,
	antialias = true
})

surface.CreateFont("NRCHUD_Ammo_Current", {
	font = "Orbitron",
	size = 48,
	weight = 600,
	antialias = true
})

surface.CreateFont("NRCHUD_Ammo_Reserve", {
	font = "Orbitron",
	size = 24,
	weight = 400,
	antialias = true
})

surface.CreateFont("NRCHUD_Weapon_Label", {
	font = "Share Tech Mono",
	size = 10,
	weight = 400,
	antialias = true
})

surface.CreateFont("NRCHUD_Objective_Label", {
	font = "Share Tech Mono",
	size = 10,
	weight = 400,
	antialias = true
})

surface.CreateFont("NRCHUD_Objective_Text", {
	font = "Share Tech Mono",
	size = 14,
	weight = 400,
	antialias = true
})

surface.CreateFont("NRCHUD_Comms_Value", {
	font = "Orbitron",
	size = 16,
	weight = 600,
	antialias = true
})

surface.CreateFont("NRCHUD_Comms_Label", {
	font = "Share Tech Mono",
	size = 9,
	weight = 400,
	antialias = true
})

-- Draw glass box with visible border (EXACT PREVIEW STYLE)
local function DrawGlassBox(x, y, w, h, accentColor)
	-- Background with blur effect
	surface.SetDrawColor(0, 0, 0, 102)
	surface.DrawRect(x, y, w, h)
	
	-- Left accent bar (colored)
	local accent = accentColor or Color(255, 255, 255, 153)
	surface.SetDrawColor(accent.r, accent.g, accent.b, accent.a)
	surface.DrawRect(x, y, 2, h)
end

-- Draw corner frames (EXACT PREVIEW STYLE)
local function DrawCornerFrames()
	local cornerSize = 60
	local offset = 15
	
	surface.SetDrawColor(255, 255, 255, 38) -- rgba(255, 255, 255, 0.15)
	
	-- Top-left
	surface.DrawLine(offset, offset, offset + cornerSize, offset)
	surface.DrawLine(offset, offset, offset, offset + cornerSize)
	
	-- Top-right
	surface.DrawLine(ScrW() - offset - cornerSize, offset, ScrW() - offset, offset)
	surface.DrawLine(ScrW() - offset, offset, ScrW() - offset, offset + cornerSize)
	
	-- Bottom-left
	surface.DrawLine(offset, ScrH() - offset, offset, ScrH() - offset - cornerSize)
	surface.DrawLine(offset, ScrH() - offset, offset + cornerSize, ScrH() - offset)
	
	-- Bottom-right
	surface.DrawLine(ScrW() - offset - cornerSize, ScrH() - offset, ScrW() - offset, ScrH() - offset)
	surface.DrawLine(ScrW() - offset, ScrH() - offset - cornerSize, ScrW() - offset, ScrH() - offset)
end

-- Draw scanlines (EXACT PREVIEW STYLE)
local scanlineOffset = 0
local function DrawScanlines()
	scanlineOffset = (scanlineOffset + 0.5) % 4
	
	surface.SetDrawColor(255, 255, 255, 5) -- Very subtle
	for i = 0, ScrH(), 2 do
		local y = i + scanlineOffset
		surface.DrawLine(0, y, ScrW(), y)
	end
end

-- Draw currency (ABOVE IDENTITY - EXACT PREVIEW POSITION)
local function DrawCurrency()
	if not NRCHUD.Config.ShowCurrency then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	-- Get money from DarkRP
	local money = 0
	if DarkRP and ply.getDarkRPVar then
		money = ply:getDarkRPVar("money") or 0
	elseif ply.GetMoney then
		money = ply:GetMoney() or 0
	else
		money = NRCHUD.PlayerData.currency or 0
	end
	
	local x = 30
	local y = ScrH() - 165 -- Above identity card
	local w = 200
	local h = 40
	
	-- Gold accent for currency
	DrawGlassBox(x, y, w, h, Color(255, 215, 0, 204))
	
	-- Icon
	draw.SimpleText("◈", "NRCHUD_Currency", x + 20, y + 10, Color(255, 215, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	
	-- Amount
	local amountText = string.Comma(money)
	draw.SimpleText(amountText, "NRCHUD_Currency", x + 40, y + 8, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Label
	local currencyLabel = NRCHUD.GetText("credits") or "CREDITS"
	draw.SimpleText(currencyLabel:upper(), "NRCHUD_Currency_Label", x + 40, y + 26, Color(255, 215, 0, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Draw identity card (SLIM VERSION - EXACT PREVIEW STYLE)
local function DrawIdentity()
	if not NRCHUD.Config.ShowIdentity then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local x = 30
	local y = ScrH() - 110 -- Below currency
	local w = 300
	local h = 50
	
	DrawGlassBox(x, y, w, h)
	
	-- Get player data
	local displayName = NRCHUD.PlayerData.name
	if not displayName or displayName == "" or displayName == "Unknown" then
		displayName = ply:Nick()
	end
	
	local job = NRCHUD.PlayerData.job
	if not job or job == "" or job == "Unknown" then
		if DarkRP and ply.getDarkRPVar then
			job = ply:getDarkRPVar("job") or team.GetName(ply:Team()) or "Civilian"
		else
			job = team.GetName(ply:Team()) or "Civilian"
		end
	end
	
	local rank = NRCHUD.PlayerData.rank
	if not rank or rank == "" or rank == "Unknown" then
		rank = "Trooper"
	end
	
	-- Name
	draw.SimpleText(displayName, "NRCHUD_Identity_Name", x + 14, y + 8, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Rank and Job (single line with bullet separator)
	local rankText = rank .. " • " .. job
	draw.SimpleText(rankText, "NRCHUD_Identity_Rank", x + 14, y + 28, Color(255, 255, 255, 166), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Draw health and armor (SLIM VERSION - EXACT PREVIEW STYLE)
local function DrawVitals()
	if not NRCHUD.Config.ShowHealth then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local health = math.max(0, ply:Health())
	local maxHealth = ply:GetMaxHealth() or 100
	local healthPercent = math.Clamp(health / maxHealth, 0, 1)
	
	local armor = math.max(0, ply:Armor())
	local maxArmor = 100
	local armorPercent = math.Clamp(armor / maxArmor, 0, 1)
	
	local x = 30
	local y = ScrH() - 30 -- Bottom
	local w = 270
	local h = 28
	
	-- Health row
	DrawGlassBox(x, y, w, h)
	
	draw.SimpleText("HEALTH", "NRCHUD_Vital_Label", x + 12, y + 6, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Health bar
	local barX = x + 70
	local barY = y + 12
	local barW = 150
	local barH = 5
	
	-- Bar background
	surface.SetDrawColor(255, 255, 255, 26)
	surface.DrawRect(barX, barY, barW, barH)
	
	-- Bar fill with glow
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(barX, barY, barW * healthPercent, barH)
	
	-- Health value
	draw.SimpleText(tostring(math.floor(health)), "NRCHUD_Vital_Value", x + w - 12, y + 8, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	
	-- Armor row
	if NRCHUD.Config.ShowArmor then
		local armorY = y - 36
		
		DrawGlassBox(x, armorY, w, h)
		
		draw.SimpleText("ARMOR", "NRCHUD_Vital_Label", x + 12, armorY + 6, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Armor bar
		surface.SetDrawColor(255, 255, 255, 26)
		surface.DrawRect(barX, armorY + 12, barW, barH)
		
		-- Armor fill (slightly transparent)
		surface.SetDrawColor(255, 255, 255, 191)
		surface.DrawRect(barX, armorY + 12, barW * armorPercent, barH)
		
		-- Armor value
		draw.SimpleText(tostring(math.floor(armor)), "NRCHUD_Vital_Value", x + w - 12, armorY + 8, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end
end

-- Draw ammo (BOTTOM RIGHT - EXACT PREVIEW STYLE)
local function DrawAmmo()
	if not NRCHUD.Config.ShowAmmo then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) then return end
	
	local clip = weapon:Clip1()
	local reserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
	
	if clip < 0 then return end
	
	local x = ScrW() - 30
	local y = ScrH() - 70 -- Moved up slightly
	
	-- Current ammo (large)
	draw.SimpleText(tostring(clip), "NRCHUD_Ammo_Current", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	
	-- Separator
	surface.SetFont("NRCHUD_Ammo_Reserve")
	local sepW = surface.GetTextSize("/")
	draw.SimpleText("/", "NRCHUD_Ammo_Reserve", x + 8, y + 10, Color(255, 255, 255, 102), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Reserve ammo (smaller)
	draw.SimpleText(tostring(reserve), "NRCHUD_Ammo_Reserve", x + 8 + sepW + 8, y + 10, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Weapon name
	local weaponName = weapon:GetPrintName()
	if weaponName == "" or weaponName == "Scripted Weapon" then
		weaponName = weapon:GetClass()
	end
	weaponName = string.upper(weaponName)
	draw.SimpleText(weaponName, "NRCHUD_Weapon_Label", x, y + 52, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

-- Draw minimap (CIRCULAR - EXACT PREVIEW STYLE)
local function DrawMinimap()
	if not NRCHUD.Config.ShowMinimap then return end
	
	local size = 130
	local x = ScrW() - 30 - size
	local y = ScrH() - 120 - size
	
	local centerX = x + size / 2
	local centerY = y + size / 2
	local radius = size / 2
	
	-- Stencil for circular clipping
	render.ClearStencil()
	render.SetStencilEnable(true)
	
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	
	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_ZERO)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(1)
	
	-- Draw circle mask
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255, 255)
	local circle = {}
	for i = 0, 360, 6 do
		local rad = math.rad(i)
		table.insert(circle, {x = centerX + math.cos(rad) * radius, y = centerY + math.sin(rad) * radius})
	end
	surface.DrawPoly(circle)
	
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	
	-- Background
	surface.SetDrawColor(0, 0, 0, 128)
	surface.DrawRect(x, y, size, size)
	
	-- Grid lines (crosshair style)
	surface.SetDrawColor(255, 255, 255, 13)
	-- Vertical
	surface.DrawLine(centerX, y, centerX, y + size)
	-- Horizontal
	surface.DrawLine(x, centerY, x + size, centerY)
	
	-- Center ring
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255, 26)
	local ringRadius = radius * 0.48
	local ringCircle = {}
	for i = 0, 360, 6 do
		local rad = math.rad(i)
		table.insert(ringCircle, {x = centerX + math.cos(rad) * ringRadius, y = centerY + math.sin(rad) * ringRadius})
	end
	surface.DrawPoly(ringCircle)
	
	-- Player indicator (white triangle)
	local ply = LocalPlayer()
	if IsValid(ply) then
		local ang = ply:EyeAngles().y
		local rad = math.rad(-ang + 90)
		
		local triSize = 6
		local tri = {
			{x = centerX + math.cos(rad) * triSize, y = centerY + math.sin(rad) * triSize},
			{x = centerX + math.cos(rad + math.rad(140)) * triSize, y = centerY + math.sin(rad + math.rad(140)) * triSize},
			{x = centerX + math.cos(rad - math.rad(140)) * triSize, y = centerY + math.sin(rad - math.rad(140)) * triSize}
		}
		
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawPoly(tri)
	end
	
	-- Example dots (enemies and allies)
	-- Red enemies
	surface.SetDrawColor(255, 68, 68, 255)
	draw.NoTexture()
	local function DrawDot(dx, dy, color)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		local dotSize = 2.5
		local dotCircle = {}
		for i = 0, 360, 30 do
			local rad = math.rad(i)
			table.insert(dotCircle, {x = dx + math.cos(rad) * dotSize, y = dy + math.sin(rad) * dotSize})
		end
		surface.DrawPoly(dotCircle)
	end
	
	-- Example positions
	DrawDot(centerX + 20, centerY - 30, Color(255, 68, 68, 255))
	DrawDot(centerX - 25, centerY + 20, Color(255, 68, 68, 255))
	DrawDot(centerX + 35, centerY + 15, Color(68, 255, 68, 255))
	DrawDot(centerX - 20, centerY - 25, Color(68, 255, 68, 255))
	
	render.SetStencilEnable(false)
	
	-- Border (outside stencil)
	surface.SetDrawColor(255, 255, 255, 77) -- rgba(255, 255, 255, 0.3)
	draw.NoTexture()
	for i = 0, 360, 3 do
		local rad1 = math.rad(i)
		local rad2 = math.rad(i + 3)
		
		local x1 = centerX + math.cos(rad1) * (radius - 1)
		local y1 = centerY + math.sin(rad1) * (radius - 1)
		local x2 = centerX + math.cos(rad2) * (radius - 1)
		local y2 = centerY + math.sin(rad2) * (radius - 1)
		
		surface.DrawLine(x1, y1, x2, y2)
	end
end

-- Draw objective (TOP LEFT - EXACT PREVIEW STYLE)
local function DrawObjective()
	if not NRCHUD.PlayerData.objective or NRCHUD.PlayerData.objective == "" then return end
	
	local x = 30
	local y = 25
	
	-- Pulsing dot indicator
	local pulse = math.abs(math.sin(CurTime() * 2)) * 0.5 + 0.5
	surface.SetDrawColor(255, 255, 255, 128 * pulse)
	draw.NoTexture()
	local dotSize = 4
	local dotCircle = {}
	for i = 0, 360, 30 do
		local rad = math.rad(i)
		table.insert(dotCircle, {x = x + 4 + math.cos(rad) * dotSize, y = y + 4 + math.sin(rad) * dotSize})
	end
	surface.DrawPoly(dotCircle)
	
	-- Label
	draw.SimpleText("OBJECTIVE", "NRCHUD_Objective_Label", x + 18, y, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Text
	draw.SimpleText(NRCHUD.PlayerData.objective, "NRCHUD_Objective_Text", x, y + 16, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Draw comms info (TOP RIGHT - EXACT PREVIEW STYLE)
local function DrawCommsInfo()
	local x = ScrW() - 30
	local y = 25
	local lineHeight = 32
	
	-- Comms channel
	local channel = NRCHUD.PlayerData.commsChannel or "Battalion Net"
	local freq = "445.7 MHz"
	if NRCHUD.CommsFrequencies[channel] then
		freq = NRCHUD.CommsFrequencies[channel].freq
	end
	
	-- Blinking indicator
	local blink = math.abs(math.sin(CurTime() * 1.5))
	surface.SetDrawColor(74, 222, 128, 255 * blink)
	draw.NoTexture()
	local indSize = 3
	local indCircle = {}
	for i = 0, 360, 30 do
		local rad = math.rad(i)
		table.insert(indCircle, {x = x - 10 + math.cos(rad) * indSize, y = y + 8 + math.sin(rad) * indSize})
	end
	surface.DrawPoly(indCircle)
	
	draw.SimpleText(channel:upper(), "NRCHUD_Comms_Value", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText(NRCHUD.GetText("comms_channel") or "COMMS CHANNEL", "NRCHUD_Comms_Label", x, y + 18, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	
	y = y + lineHeight
	
	-- Frequency
	draw.SimpleText(freq, "NRCHUD_Comms_Value", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText(NRCHUD.GetText("frequency") or "FREQUENCY", "NRCHUD_Comms_Label", x, y + 18, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	
	y = y + lineHeight
	
	-- Location
	local location = NRCHUD.PlayerData.location or "GRID 447-B"
	draw.SimpleText(location, "NRCHUD_Comms_Value", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText(NRCHUD.GetText("location") or "LOCATION", "NRCHUD_Comms_Label", x, y + 18, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	
	y = y + lineHeight
	
	-- Time
	local time = os.date("%H:%M")
	draw.SimpleText(time, "NRCHUD_Comms_Value", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText(NRCHUD.GetText("time") or "TIME", "NRCHUD_Comms_Label", x, y + 18, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

-- Draw hit marker
local function DrawHitMarker()
	if not NRCHUD.Config.ShowHitMarker or not NRCHUD.ShowingHitMarker then return end
	
	local cx, cy = ScrW() / 2, ScrH() / 2
	local size = 10
	local gap = 8
	local thickness = 1.5
	
	surface.SetDrawColor(255, 255, 255, 255)
	
	-- Top-left
	for i = 0, thickness do
		surface.DrawLine(cx - gap - size, cy - gap - size + i, cx - gap, cy - gap + i)
	end
	
	-- Top-right
	for i = 0, thickness do
		surface.DrawLine(cx + gap + size, cy - gap - size + i, cx + gap, cy - gap + i)
	end
	
	-- Bottom-left
	for i = 0, thickness do
		surface.DrawLine(cx - gap - size, cy + gap + size - i, cx - gap, cy + gap - i)
	end
	
	-- Bottom-right
	for i = 0, thickness do
		surface.DrawLine(cx + gap + size, cy + gap + size - i, cx + gap, cy + gap - i)
	end
end

-- Draw damage indicators
local function DrawDamageIndicators()
	if not NRCHUD.Config.ShowDamageIndicator then return end
	
	local currentTime = CurTime()
	
	for direction, endTime in pairs(NRCHUD.DamageIndicators) do
		if currentTime < endTime then
			local alpha = math.Clamp((endTime - currentTime) / NRCHUD.Config.DamageIndicatorDuration * 153, 0, 153)
			
			surface.SetDrawColor(255, 255, 255, alpha)
			
			local cx, cy = ScrW() / 2, ScrH() / 2
			local offset = 200
			local size = 50
			local thickness = 3
			
			if direction == "Top" then
				for i = 0, thickness do
					surface.DrawLine(cx - size/2, cy - offset + i, cx + size/2, cy - offset + i)
				end
			elseif direction == "Bottom" then
				for i = 0, thickness do
					surface.DrawLine(cx - size/2, cy + offset - i, cx + size/2, cy + offset - i)
				end
			elseif direction == "Left" then
				for i = 0, thickness do
					surface.DrawLine(cx - offset + i, cy - size/2, cx - offset + i, cy + size/2)
				end
			elseif direction == "Right" then
				for i = 0, thickness do
					surface.DrawLine(cx + offset - i, cy - size/2, cx + offset - i, cy + size/2)
				end
			end
		else
			NRCHUD.DamageIndicators[direction] = nil
		end
	end
end

-- Draw low health vignette
local function DrawLowHealthVignette()
	if not NRCHUD.Config.LowHealthEffect then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local health = ply:Health()
	local maxHealth = ply:GetMaxHealth() or 100
	
	if health < NRCHUD.Config.LowHealthThreshold then
		local intensity = 1 - (health / NRCHUD.Config.LowHealthThreshold)
		local pulse = math.abs(math.sin(CurTime() * 1.5)) * 0.3 + 0.3
		local alpha = intensity * pulse * 76
		
		surface.SetDrawColor(255, 0, 0, alpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end
end

-- Main HUD draw hook
hook.Add("HUDPaint", "NRCHUD_Draw", function()
	if not NRCHUD.Config.Enabled then return end
	
	-- Draw in correct order
	DrawScanlines()
	DrawLowHealthVignette()
	DrawCornerFrames()
	DrawCurrency()
	DrawIdentity()
	DrawVitals()
	DrawAmmo()
	DrawMinimap()
	DrawObjective()
	DrawCommsInfo()
	DrawHitMarker()
	DrawDamageIndicators()
end)

print("[NRC HUD] HUD rendering loaded! (Battlefront II Style)")