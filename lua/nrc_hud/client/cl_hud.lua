-- NRC Star Wars HUD - Main HUD (Fixed Sizing)

-- Fonts with fallback to system fonts
surface.CreateFont("NRC_HUD_Orbitron_Big", {font = "Orbitron", size = 52, weight = 900, antialias = true, extended = true})
surface.CreateFont("NRC_HUD_Orbitron_Medium", {font = "Orbitron", size = 24, weight = 700, antialias = true, extended = true})
surface.CreateFont("NRC_HUD_Orbitron_Small", {font = "Orbitron", size = 16, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_HUD_Orbitron_Tiny", {font = "Orbitron", size = 14, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_HUD_Mono", {font = "Share Tech Mono", size = 14, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_HUD_Mono_Small", {font = "Share Tech Mono", size = 12, weight = 400, antialias = true, extended = true})
surface.CreateFont("NRC_HUD_Mono_Tiny", {font = "Share Tech Mono", size = 10, weight = 400, antialias = true, extended = true})

-- Check if custom fonts are loaded
timer.Simple(1, function()
	local testFont = surface.GetTextSize("ORBITRON TEST")
	if testFont == 0 then
		print("[NRC HUD] WARNING: Custom fonts (Orbitron/Share Tech Mono) not found!")
		print("[NRC HUD] Please install fonts from resource/fonts/ folder")
	else
		print("[NRC HUD] Custom fonts loaded successfully!")
	end
end)

NRCHUD = NRCHUD or {}
NRCHUD.Config = NRCHUD.Config or {}
NRCHUD.DamageIndicators = NRCHUD.DamageIndicators or {}

-- Config
NRCHUD.Config.DamageIndicatorDuration = 0.4
NRCHUD.Config.HitMarkerDuration = 0.15

local scanlineOffset = 0

-- Hide default HUD
local hideElements = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudDamageIndicator"] = true,
}

hook.Add("HUDShouldDraw", "NRCHUD_HideDefault", function(name)
	if hideElements[name] then return false end
end)

-- Main HUD Draw
hook.Add("HUDPaint", "NRCHUD_Draw", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Scanlines (subtle)
	scanlineOffset = (scanlineOffset + 0.2) % 7
	surface.SetDrawColor(255, 255, 255, 4)
	for i = 0, scrH, 7 do
		surface.DrawRect(0, i + scanlineOffset, scrW, 1)
	end
	
	-- Corner frames
	NRCHUD.DrawCornerFrames(scrW, scrH)
	
	-- Currency display (ABOVE identity)
	NRCHUD.DrawCurrency(ply, scrW, scrH)
	
	-- Identity card
	NRCHUD.DrawIdentity(ply, scrW, scrH)
	
	-- Health & Armor
	NRCHUD.DrawVitals(ply, scrW, scrH)
	
	-- Ammo display
	NRCHUD.DrawAmmo(ply, scrW, scrH)
	
	-- Minimap
	NRCHUD.DrawMinimap(ply, scrW, scrH)
	
	-- Objective (top left)
	NRCHUD.DrawObjective(scrW, scrH)
	
	-- Comms info (top right)
	NRCHUD.DrawCommsInfo(ply, scrW, scrH)
	
	-- Hit marker
	NRCHUD.DrawHitMarker(scrW, scrH)
	
	-- Damage indicators
	NRCHUD.DrawDamageIndicators(scrW, scrH)
	
	-- Low health vignette
	NRCHUD.DrawLowHealthVignette(ply, scrW, scrH)
end)

-- Corner Frames (60px each corner)
function NRCHUD.DrawCornerFrames(w, h)
	local size = 60
	local offset = 15
	local col = Color(255, 255, 255, 38) -- rgba(255,255,255,0.15)
	
	-- Top-left
	surface.SetDrawColor(col)
	surface.DrawLine(offset, offset, offset + size, offset) -- Top line
	surface.DrawLine(offset, offset, offset, offset + size) -- Left line
	
	-- Top-right
	surface.DrawLine(w - offset - size, offset, w - offset, offset) -- Top line
	surface.DrawLine(w - offset, offset, w - offset, offset + size) -- Right line
	
	-- Bottom-left
	surface.DrawLine(offset, h - offset - size, offset, h - offset) -- Left line
	surface.DrawLine(offset, h - offset, offset + size, h - offset) -- Bottom line
	
	-- Bottom-right
	surface.DrawLine(w - offset, h - offset - size, w - offset, h - offset) -- Right line
	surface.DrawLine(w - offset - size, h - offset, w - offset, h - offset) -- Bottom line
end

-- Currency Display (FIXED: Above Identity, larger)
function NRCHUD.DrawCurrency(ply, w, h)
	local x = 30
	local y = h - 240 -- ABOVE identity (was 165)
	local boxW = 220 -- WIDER
	local boxH = 50 -- TALLER
	
	-- Get money from DarkRP
	local money = 0
	if DarkRP and ply.getDarkRPVar then
		money = ply:getDarkRPVar("money") or 0
	elseif ply.GetMoney then
		money = ply:GetMoney() or 0
	end
	
	-- Background box (rgba(0,0,0,0.4))
	surface.SetDrawColor(0, 0, 0, 102)
	surface.DrawRect(x, y, boxW, boxH)
	
	-- Gold left border
	surface.SetDrawColor(255, 215, 0, 204) -- rgba(255,215,0,0.8)
	surface.DrawRect(x, y, 2, boxH)
	
	-- Icon
	draw.SimpleText("◈", "NRC_HUD_Orbitron_Medium", x + 15, y + boxH / 2, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Amount (BIGGER FONT)
	local amountStr = string.Comma(money)
	draw.SimpleText(amountStr, "NRC_HUD_Orbitron_Medium", x + 50, y + 15, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Label (BIGGER)
	draw.SimpleText(NRCHUD.GetText("credits"), "NRC_HUD_Mono_Tiny", x + 50, y + 35, Color(255, 215, 0, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Identity Card (FIXED: Larger)
function NRCHUD.DrawIdentity(ply, w, h)
	local x = 30
	local y = h - 170 -- Below currency
	local boxW = 280 -- WIDER
	local boxH = 60 -- TALLER
	
	-- Background
	surface.SetDrawColor(0, 0, 0, 102)
	surface.DrawRect(x, y, boxW, boxH)
	
	-- White left border
	surface.SetDrawColor(255, 255, 255, 153)
	surface.DrawRect(x, y, 2, boxH)
	
	local name = NRCHUD.PlayerData.name or ply:Nick()
	local job = NRCHUD.PlayerData.job or "Trooper"
	
	-- Name (BIGGER FONT)
	draw.SimpleText(name, "NRC_HUD_Orbitron_Small", x + 14, y + 12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Job/Rank (BIGGER)
	draw.SimpleText(job, "NRC_HUD_Mono_Small", x + 14, y + 38, Color(255, 255, 255, 166), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Health & Armor (FIXED: Larger bars)
function NRCHUD.DrawVitals(ply, w, h)
	local x = 30
	local y = h - 95 -- Below identity
	local spacing = 12 -- More space between bars
	local boxW = 280 -- WIDER
	local boxH = 38 -- TALLER
	
	local health = math.max(0, ply:Health())
	local armor = math.max(0, ply:Armor())
	
	-- HEALTH BAR
	do
		-- Background
		surface.SetDrawColor(0, 0, 0, 102)
		surface.DrawRect(x, y, boxW, boxH)
		
		-- White left border
		surface.SetDrawColor(255, 255, 255, 153)
		surface.DrawRect(x, y, 2, boxH)
		
		-- Label (BIGGER)
		draw.SimpleText("HEALTH", "NRC_HUD_Mono_Tiny", x + 14, y + 8, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Bar background
		local barX = x + 14
		local barY = y + 22
		local barW = 180 -- WIDER BAR
		local barH = 6 -- Slightly taller
		
		surface.SetDrawColor(255, 255, 255, 26)
		surface.DrawRect(barX, barY, barW, barH)
		
		-- Bar fill
		local fillW = (health / 100) * barW
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(barX, barY, fillW, barH)
		
		-- Glow
		for i = 1, 3 do
			surface.SetDrawColor(255, 255, 255, 128 / i)
			surface.DrawRect(barX, barY - i, fillW, barH + i * 2)
		end
		
		-- Value (BIGGER)
		draw.SimpleText(tostring(health), "NRC_HUD_Orbitron_Tiny", barX + barW + 20, y + boxH / 2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	
	-- ARMOR BAR
	do
		local armorY = y + boxH + spacing
		
		-- Background
		surface.SetDrawColor(0, 0, 0, 102)
		surface.DrawRect(x, armorY, boxW, boxH)
		
		-- White left border
		surface.SetDrawColor(255, 255, 255, 153)
		surface.DrawRect(x, armorY, 2, boxH)
		
		-- Label
		draw.SimpleText("ARMOR", "NRC_HUD_Mono_Tiny", x + 14, armorY + 8, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Bar background
		local barX = x + 14
		local barY = armorY + 22
		local barW = 180
		local barH = 6
		
		surface.SetDrawColor(255, 255, 255, 26)
		surface.DrawRect(barX, barY, barW, barH)
		
		-- Bar fill (slightly transparent)
		local fillW = (armor / 100) * barW
		surface.SetDrawColor(255, 255, 255, 191)
		surface.DrawRect(barX, barY, fillW, barH)
		
		-- Glow
		for i = 1, 3 do
			surface.SetDrawColor(255, 255, 255, 102 / i)
			surface.DrawRect(barX, barY - i, fillW, barH + i * 2)
		end
		
		-- Value
		draw.SimpleText(tostring(armor), "NRC_HUD_Orbitron_Tiny", barX + barW + 20, armorY + boxH / 2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

-- Ammo Display (FIXED: Inside screen, MUCH BIGGER)
function NRCHUD.DrawAmmo(ply, w, h)
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end
	
	local clip = wep:Clip1()
	local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
	
	if clip < 0 and reserve <= 0 then return end
	
	-- FIXED POSITION: Inside screen, bottom-right
	local x = w - 250 -- Much more left (was w - 30)
	local y = h - 120 -- Much higher up (was h - 70)
	
	-- Current ammo (HUGE)
	if clip >= 0 then
		draw.SimpleText(tostring(clip), "NRC_HUD_Orbitron_Big", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	
	-- Separator
	local sepX = x + 15
	draw.SimpleText("/", "NRC_HUD_Orbitron_Medium", sepX, y, Color(255, 255, 255, 102), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Reserve (BIGGER)
	local resX = sepX + 35
	draw.SimpleText(tostring(reserve), "NRC_HUD_Orbitron_Medium", resX, y, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Weapon name (MUCH BIGGER AND READABLE)
	local weaponName = wep:GetPrintName() or wep:GetClass()
	weaponName = string.upper(weaponName)
	
	draw.SimpleText(weaponName, "NRC_HUD_Mono_Small", x + 10, y + 40, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

-- Minimap (Perfect circle with stencil)
function NRCHUD.DrawMinimap(ply, w, h)
	local x = w - 30 - 130 -- 30px from right edge
	local y = h - 120 - 130 -- Above ammo
	local size = 130
	local radius = size / 2
	
	-- Start stencil (circle mask)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilFailOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	
	-- Draw circle mask
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255)
	local circle = {}
	for i = 0, 360, 6 do
		local rad = math.rad(i)
		table.insert(circle, {x = x + radius + math.cos(rad) * radius, y = y + radius + math.sin(rad) * radius})
	end
	surface.DrawPoly(circle)
	
	-- Now draw only inside circle
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilFailOperation(STENCIL_KEEP)
	
	-- Background (rgba(0,0,0,0.5))
	surface.SetDrawColor(0, 0, 0, 128)
	surface.DrawRect(x, y, size, size)
	
	-- Crosshair lines (vertical + horizontal)
	surface.SetDrawColor(255, 255, 255, 13)
	surface.DrawLine(x + radius, y, x + radius, y + size) -- Vertical
	surface.DrawLine(x, y + radius, x + size, y + radius) -- Horizontal
	
	-- Center ring (at 48% radius)
	local ringRadius = radius * 0.48
	surface.SetDrawColor(255, 255, 255, 77)
	draw.NoTexture()
	local ringCircle = {}
	for i = 0, 360, 6 do
		local rad = math.rad(i)
		table.insert(ringCircle, {x = x + radius + math.cos(rad) * ringRadius, y = y + radius + math.sin(rad) * ringRadius})
	end
	surface.DrawPoly(ringCircle)
	
	-- Player triangle (white, pointing forward)
	local angle = ply:EyeAngles().y
	local triSize = 9
	local cx, cy = x + radius, y + radius
	
	local function rotatePoint(px, py, cx, cy, angle)
		local s = math.sin(math.rad(-angle + 90))
		local c = math.cos(math.rad(-angle + 90))
		local dx, dy = px - cx, py - cy
		return cx + dx * c - dy * s, cy + dx * s + dy * c
	end
	
	local p1x, p1y = rotatePoint(cx, cy - triSize, cx, cy, angle)
	local p2x, p2y = rotatePoint(cx - triSize * 0.6, cy + triSize * 0.6, cx, cy, angle)
	local p3x, p3y = rotatePoint(cx + triSize * 0.6, cy + triSize * 0.6, cx, cy, angle)
	
	surface.SetDrawColor(255, 255, 255, 255)
	draw.NoTexture()
	surface.DrawPoly({{x = p1x, y = p1y}, {x = p2x, y = p2y}, {x = p3x, y = p3y}})
	
	-- Example dots (red = enemies, green = allies)
	-- TODO: Replace with actual entity positions
	local dots = {
		{x = 0.3, y = 0.6, enemy = true},
		{x = 0.7, y = 0.35, enemy = true},
		{x = 0.55, y = 0.75, enemy = false},
		{x = 0.4, y = 0.25, enemy = false},
	}
	
	for _, dot in ipairs(dots) do
		local dx = x + dot.x * size
		local dy = y + dot.y * size
		
		if dot.enemy then
			surface.SetDrawColor(255, 68, 68, 255)
		else
			surface.SetDrawColor(68, 255, 68, 255)
		end
		
		draw.NoTexture()
		local dotCircle = {}
		for i = 0, 360, 30 do
			local rad = math.rad(i)
			table.insert(dotCircle, {x = dx + math.cos(rad) * 2.5, y = dy + math.sin(rad) * 2.5})
		end
		surface.DrawPoly(dotCircle)
		
		-- Glow
		for i = 1, 2 do
			if dot.enemy then
				surface.SetDrawColor(255, 68, 68, 154 / i)
			else
				surface.SetDrawColor(68, 255, 68, 154 / i)
			end
			local glowCircle = {}
			for j = 0, 360, 30 do
				local rad = math.rad(j)
				table.insert(glowCircle, {x = dx + math.cos(rad) * (2.5 + i), y = dy + math.sin(rad) * (2.5 + i)})
			end
			surface.DrawPoly(glowCircle)
		end
	end
	
	-- End stencil
	render.SetStencilEnable(false)
	
	-- Border (outside stencil)
	surface.SetDrawColor(255, 255, 255, 77)
	for i = 0, 360, 2 do
		local rad1 = math.rad(i)
		local rad2 = math.rad(i + 2)
		local x1 = x + radius + math.cos(rad1) * radius
		local y1 = y + radius + math.sin(rad1) * radius
		local x2 = x + radius + math.cos(rad2) * radius
		local y2 = y + radius + math.sin(rad2) * radius
		surface.DrawLine(x1, y1, x2, y2)
	end
end

-- Objective (top left)
function NRCHUD.DrawObjective(w, h)
	local x = 30
	local y = 25
	
	-- Pulsing dot
	local alpha = math.abs(math.sin(CurTime() * 2)) * 128 + 127
	surface.SetDrawColor(255, 255, 255, alpha)
	draw.NoTexture()
	local dot = {}
	for i = 0, 360, 30 do
		local rad = math.rad(i)
		table.insert(dot, {x = x + math.cos(rad) * 4, y = y + 8 + math.sin(rad) * 4})
	end
	surface.DrawPoly(dot)
	
	-- Label (BIGGER)
	draw.SimpleText("OBJECTIVE", "NRC_HUD_Mono_Tiny", x + 15, y, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Objective text (BIGGER)
	local objective = NRCHUD.PlayerData.objective or "Secure Command Post - Hangar Bay"
	draw.SimpleText(objective, "NRC_HUD_Mono_Small", x, y + 22, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Comms Info (top right) (BIGGER FONTS)
function NRCHUD.DrawCommsInfo(ply, w, h)
	local x = w - 30
	local y = 25
	local lineH = 35 -- More spacing
	
	-- 4 lines of info
	local info = {
		{label = NRCHUD.GetText("comms_channel"), value = NRCHUD.PlayerData.commsChannel or "BATTALION", hasIndicator = true},
		{label = NRCHUD.GetText("frequency"), value = "445.750 MHz"},
		{label = NRCHUD.GetText("location"), value = NRCHUD.PlayerData.location or "GRID 447-B"},
		{label = NRCHUD.GetText("time"), value = os.date("%H:%M")},
	}
	
	for i, item in ipairs(info) do
		local yPos = y + (i - 1) * lineH
		
		-- Value (BIGGER)
		local valueX = x
		if item.hasIndicator then
			-- Blinking green dot
			local dotAlpha = math.abs(math.sin(CurTime() * 1.5)) * 128 + 127
			surface.SetDrawColor(74, 222, 128, dotAlpha)
			draw.NoTexture()
			local dotCircle = {}
			for j = 0, 360, 30 do
				local rad = math.rad(j)
				table.insert(dotCircle, {x = valueX - 15 + math.cos(rad) * 3, y = yPos + 8 + math.sin(rad) * 3})
			end
			surface.DrawPoly(dotCircle)
			
			-- Glow
			surface.SetDrawColor(74, 222, 128, dotAlpha / 2)
			for k = 1, 2 do
				local glowCircle = {}
				for j = 0, 360, 30 do
					local rad = math.rad(j)
					table.insert(glowCircle, {x = valueX - 15 + math.cos(rad) * (3 + k), y = yPos + 8 + math.sin(rad) * (3 + k)})
				end
				surface.DrawPoly(glowCircle)
			end
		end
		
		draw.SimpleText(item.value, "NRC_HUD_Orbitron_Small", valueX, yPos, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		
		-- Label (BIGGER)
		draw.SimpleText(item.label, "NRC_HUD_Mono_Tiny", valueX, yPos + 18, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end
end

-- Hit Marker
function NRCHUD.DrawHitMarker(w, h)
	if not NRCHUD.ShowingHitMarker then return end
	
	local cx, cy = w / 2, h / 2
	local size = 30
	local lineLen = 10
	local lineThick = 1.5
	local offset = 5
	
	surface.SetDrawColor(255, 255, 255, 255)
	
	-- Top-left
	for i = 0, lineThick do
		surface.DrawLine(cx - offset - lineLen + i, cy - offset - i, cx - offset + i, cy - offset - lineLen + i)
	end
	
	-- Top-right
	for i = 0, lineThick do
		surface.DrawLine(cx + offset + i, cy - offset - lineLen + i, cx + offset + lineLen - i, cy - offset - i)
	end
	
	-- Bottom-left
	for i = 0, lineThick do
		surface.DrawLine(cx - offset - lineLen + i, cy + offset + i, cx - offset + i, cy + offset + lineLen - i)
	end
	
	-- Bottom-right
	for i = 0, lineThick do
		surface.DrawLine(cx + offset + i, cy + offset + lineLen - i, cx + offset + lineLen - i, cy + offset + i)
	end
end

-- Damage Indicators
function NRCHUD.DrawDamageIndicators(w, h)
	local cx, cy = w / 2, h / 2
	local curTime = CurTime()
	
	for direction, endTime in pairs(NRCHUD.DamageIndicators) do
		if curTime < endTime then
			local alpha = ((endTime - curTime) / NRCHUD.Config.DamageIndicatorDuration) * 153
			surface.SetDrawColor(255, 255, 255, alpha)
			
			if direction == "Top" then
				surface.DrawRect(cx - 25, cy * 0.25, 50, 3)
			elseif direction == "Bottom" then
				surface.DrawRect(cx - 25, cy * 1.75, 50, 3)
			elseif direction == "Left" then
				surface.DrawRect(cx * 0.25, cy - 25, 3, 50)
			elseif direction == "Right" then
				surface.DrawRect(cx * 1.75, cy - 25, 3, 50)
			end
		else
			NRCHUD.DamageIndicators[direction] = nil
		end
	end
end

-- Low Health Vignette
function NRCHUD.DrawLowHealthVignette(ply, w, h)
	local health = ply:Health()
	if health >= 35 then return end
	
	local alpha = math.Clamp((35 - health) / 35, 0, 1)
	alpha = alpha * (math.abs(math.sin(CurTime() * 1.5)) * 0.3 + 0.3)
	alpha = alpha * 153 -- 0.6 max
	
	-- Red vignette from edges
	for i = 1, 20 do
		local dist = i * 40
		local edgeAlpha = (i / 20) * alpha
		surface.SetDrawColor(255, 0, 0, edgeAlpha)
		surface.DrawRect(0, h - dist, w, dist)
		surface.DrawRect(0, 0, w, dist)
		surface.DrawRect(0, 0, dist, h)
		surface.DrawRect(w - dist, 0, dist, h)
	end
end

print("[NRC HUD] Main HUD (FIXED sizing) loaded!")