-- NRC Star Wars HUD - Main HUD

-- Font registration
local function CreateHUDFont(name, fontName, size, weight)
	surface.CreateFont(name, {
		font = fontName,
		size = size,
		weight = weight,
		antialias = true,
		extended = true,
		shadow = true
	})
end

CreateHUDFont("NRC_HUD_Orbitron_Big", "Orbitron", 58, 900)
CreateHUDFont("NRC_HUD_Orbitron_Medium", "Orbitron", 28, 700)
CreateHUDFont("NRC_HUD_Orbitron_Small", "Orbitron", 20, 600)
CreateHUDFont("NRC_HUD_Orbitron_Tiny", "Orbitron", 16, 600)
CreateHUDFont("NRC_HUD_Mono", "Share Tech Mono", 16, 400)
CreateHUDFont("NRC_HUD_Mono_Small", "Share Tech Mono", 14, 400)
CreateHUDFont("NRC_HUD_Mono_Tiny", "Share Tech Mono", 12, 400)

NRCHUD = NRCHUD or {}
NRCHUD.Config = NRCHUD.Config or {}
NRCHUD.DamageIndicators = NRCHUD.DamageIndicators or {}

NRCHUD.Config.DamageIndicatorDuration = 0.4
NRCHUD.Config.HitMarkerDuration = 0.15

local scanlineOffset = 0

-- Hide HUD elements
local hideElements = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudDamageIndicator"] = true,
	["DarkRP_HUD"] = true,
	["DarkRP_EntityDisplay"] = true,
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_Hungermod"] = true,
	["DarkRP_Agenda"] = true,
	["DarkRP_LockdownHUD"] = true,
}

hook.Add("HUDShouldDraw", "NRCHUD_HideDefault", function(name)
	if hideElements[name] ~= nil then
		return not hideElements[name]
	end
end)

hook.Add("HUDPaint", "NRCHUD_HideDarkRP", function()
	if DarkRP then
		DarkRP.toggleStuff = DarkRP.toggleStuff or {}
		DarkRP.toggleStuff["DarkRP_HUD"] = false
		DarkRP.toggleStuff["DarkRP_EntityDisplay"] = false
		DarkRP.toggleStuff["DarkRP_LocalPlayerHUD"] = false
	end
end)

-- Get player rank from job
function NRCHUD.GetPlayerRank(ply)
	-- Try DarkRP
	if DarkRP and ply.getDarkRPVar then
		local job = ply:getDarkRPVar("job") or ply:Team()
		
		-- Extract rank from job name
		if isstring(job) then
			-- Examples: "Clone Trooper" → "CT", "Battalion Commander" → "Commander"
			if string.find(job, "Commander") then
				return "Commander"
			elseif string.find(job, "Captain") then
				return "Captain"
			elseif string.find(job, "Lieutenant") then
				return "Lieutenant"
			elseif string.find(job, "Sergeant") then
				return "Sergeant"
			elseif string.find(job, "Corporal") then
				return "Corporal"
			elseif string.find(job, "Trooper") then
				return "Trooper"
			else
				return job -- Return full job name
			end
		end
	end
	
	-- Fallback: Check team name
	local teamName = team.GetName(ply:Team())
	if teamName and teamName ~= "" then
		return teamName
	end
	
	return "Trooper" -- Default
end

-- Main HUD Draw
hook.Add("HUDPaint", "NRCHUD_Draw", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Scanlines
	scanlineOffset = (scanlineOffset + 0.2) % 7
	surface.SetDrawColor(255, 255, 255, 4)
	for i = 0, scrH, 7 do
		surface.DrawRect(0, i + scanlineOffset, scrW, 1)
	end
	
	NRCHUD.DrawCornerFrames(scrW, scrH)
	NRCHUD.DrawCurrency(ply, scrW, scrH)
	NRCHUD.DrawIdentity(ply, scrW, scrH)
	NRCHUD.DrawVitals(ply, scrW, scrH)
	NRCHUD.DrawAmmo(ply, scrW, scrH)
	NRCHUD.DrawMinimap(ply, scrW, scrH)
	NRCHUD.DrawObjective(scrW, scrH)
	NRCHUD.DrawCommsInfo(ply, scrW, scrH)
	NRCHUD.DrawHitMarker(scrW, scrH)
	NRCHUD.DrawDamageIndicators(scrW, scrH)
	NRCHUD.DrawLowHealthVignette(ply, scrW, scrH)
end)

function NRCHUD.DrawCornerFrames(w, h)
	local size = 70
	local offset = 15
	local col = Color(255, 255, 255, 51)
	
	surface.SetDrawColor(col)
	surface.DrawLine(offset, offset, offset + size, offset)
	surface.DrawLine(offset, offset, offset, offset + size)
	surface.DrawLine(w - offset - size, offset, w - offset, offset)
	surface.DrawLine(w - offset, offset, w - offset, offset + size)
	surface.DrawLine(offset, h - offset - size, offset, h - offset)
	surface.DrawLine(offset, h - offset, offset + size, h - offset)
	surface.DrawLine(w - offset, h - offset - size, w - offset, h - offset)
	surface.DrawLine(w - offset - size, h - offset, w - offset, h - offset)
end

function NRCHUD.DrawCurrency(ply, w, h)
	local x = 35
	local y = h - 280
	local boxW = 280
	local boxH = 65
	
	local money = 0
	if DarkRP and ply.getDarkRPVar then
		money = ply:getDarkRPVar("money") or 0
	elseif ply.GetMoney then
		money = ply:GetMoney() or 0
	end
	
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(x, y, boxW, boxH)
	
	surface.SetDrawColor(255, 215, 0, 230)
	surface.DrawRect(x, y, 3, boxH)
	
	for i = 1, 3 do
		surface.SetDrawColor(255, 215, 0, 128 / i)
		surface.DrawRect(x - i, y, 3 + i, boxH)
	end
	
	draw.SimpleText("◈", "NRC_HUD_Orbitron_Medium", x + 20, y + boxH / 2, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	local amountStr = string.Comma(money)
	draw.SimpleText(amountStr, "NRC_HUD_Orbitron_Medium", x + 65, y + 18, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(NRCHUD.GetText("credits"), "NRC_HUD_Mono_Small", x + 65, y + 43, Color(255, 215, 0, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function NRCHUD.DrawIdentity(ply, w, h)
	local x = 35
	local y = h - 200
	local boxW = 340
	local boxH = 75
	
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(x, y, boxW, boxH)
	
	surface.SetDrawColor(255, 255, 255, 200)
	surface.DrawRect(x, y, 3, boxH)
	
	for i = 1, 3 do
		surface.SetDrawColor(255, 255, 255, 128 / i)
		surface.DrawRect(x - i, y, 3 + i, boxH)
	end
	
	local name = NRCHUD.PlayerData.name or ply:Nick()
	local rank = NRCHUD.GetPlayerRank(ply)
	
	draw.SimpleText(name, "NRC_HUD_Orbitron_Small", x + 18, y + 16, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(rank, "NRC_HUD_Mono", x + 18, y + 46, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function NRCHUD.DrawVitals(ply, w, h)
	local x = 35
	local y = h - 110
	local spacing = 14
	local boxW = 340
	local boxH = 45
	
	local health = math.max(0, ply:Health())
	-- FIXED: Correct Lua syntax for conditional function call
	local maxHealth = (ply.GetMaxHealth and ply:GetMaxHealth()) or 100
	local armor = math.max(0, ply:Armor())
	local maxArmor = 100
	
	-- HEALTH BAR
	do
		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawRect(x, y, boxW, boxH)
		
		surface.SetDrawColor(255, 255, 255, 200)
		surface.DrawRect(x, y, 3, boxH)
		
		for i = 1, 3 do
			surface.SetDrawColor(255, 255, 255, 128 / i)
			surface.DrawRect(x - i, y, 3 + i, boxH)
		end
		
		draw.SimpleText("HEALTH", "NRC_HUD_Mono_Small", x + 18, y + 10, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Bar
		local barX = x + 18
		local barY = y + 28
		local barW = 220
		local barH = 8
		
		surface.SetDrawColor(255, 255, 255, 38)
		surface.DrawRect(barX, barY, barW, barH)
		
		local fillW = math.Clamp((health / maxHealth) * barW, 0, barW)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(barX, barY, fillW, barH)
		
		for i = 1, 4 do
			surface.SetDrawColor(255, 255, 255, 128 / i)
			surface.DrawRect(barX, barY - i, fillW, barH + i * 2)
		end
		
		draw.SimpleText(tostring(health), "NRC_HUD_Orbitron_Small", barX + barW + 30, y + boxH / 2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	
	-- ARMOR BAR
	do
		local armorY = y + boxH + spacing
		
		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawRect(x, armorY, boxW, boxH)
		
		surface.SetDrawColor(255, 255, 255, 200)
		surface.DrawRect(x, armorY, 3, boxH)
		
		for i = 1, 3 do
			surface.SetDrawColor(255, 255, 255, 128 / i)
			surface.DrawRect(x - i, armorY, 3 + i, boxH)
		end
		
		draw.SimpleText("ARMOR", "NRC_HUD_Mono_Small", x + 18, armorY + 10, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local barX = x + 18
		local barY = armorY + 28
		local barW = 220
		local barH = 8
		
		surface.SetDrawColor(255, 255, 255, 38)
		surface.DrawRect(barX, barY, barW, barH)
		
		local fillW = math.Clamp((armor / maxArmor) * barW, 0, barW)
		surface.SetDrawColor(255, 255, 255, 204)
		surface.DrawRect(barX, barY, fillW, barH)
		
		for i = 1, 4 do
			surface.SetDrawColor(255, 255, 255, 102 / i)
			surface.DrawRect(barX, barY - i, fillW, barH + i * 2)
		end
		
		draw.SimpleText(tostring(armor), "NRC_HUD_Orbitron_Small", barX + barW + 30, armorY + boxH / 2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

function NRCHUD.DrawAmmo(ply, w, h)
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end
	
	local clip = wep:Clip1()
	local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
	
	if clip < 0 and reserve <= 0 then return end
	
	local x = w - 280
	local y = h - 140
	
	if clip >= 0 then
		draw.SimpleText(tostring(clip), "NRC_HUD_Orbitron_Big", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	
	local sepX = x + 20
	draw.SimpleText("/", "NRC_HUD_Orbitron_Medium", sepX, y, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	local resX = sepX + 40
	draw.SimpleText(tostring(reserve), "NRC_HUD_Orbitron_Medium", resX, y, Color(255, 255, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	local weaponName = wep:GetPrintName() or wep:GetClass()
	weaponName = string.upper(weaponName)
	
	draw.SimpleText(weaponName, "NRC_HUD_Mono", x + 15, y + 50, Color(255, 255, 255, 179), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

function NRCHUD.DrawMinimap(ply, w, h)
	local x = w - 40 - 140
	local y = h - 160 - 140
	local size = 140
	local radius = size / 2
	
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilFailOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255)
	local circle = {}
	for i = 0, 360, 6 do
		local rad = math.rad(i)
		table.insert(circle, {x = x + radius + math.cos(rad) * radius, y = y + radius + math.sin(rad) * radius})
	end
	surface.DrawPoly(circle)
	
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilFailOperation(STENCIL_KEEP)
	
	surface.SetDrawColor(0, 0, 0, 153)
	surface.DrawRect(x, y, size, size)
	
	surface.SetDrawColor(255, 255, 255, 18)
	surface.DrawLine(x + radius, y, x + radius, y + size)
	surface.DrawLine(x, y + radius, x + size, y + radius)
	
	local ringRadius = radius * 0.48
	surface.SetDrawColor(255, 255, 255, 102)
	draw.NoTexture()
	local ringCircle = {}
	for i = 0, 360, 6 do
		local rad = math.rad(i)
		table.insert(ringCircle, {x = x + radius + math.cos(rad) * ringRadius, y = y + radius + math.sin(rad) * ringRadius})
	end
	surface.DrawPoly(ringCircle)
	
	local angle = ply:EyeAngles().y
	local triSize = 10
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
	
	render.SetStencilEnable(false)
	
	surface.SetDrawColor(255, 255, 255, 102)
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

function NRCHUD.DrawObjective(w, h)
	local x = 35
	local y = 30
	
	local alpha = math.abs(math.sin(CurTime() * 2)) * 128 + 127
	surface.SetDrawColor(255, 255, 255, alpha)
	draw.NoTexture()
	local dot = {}
	for i = 0, 360, 30 do
		local rad = math.rad(i)
		table.insert(dot, {x = x + math.cos(rad) * 5, y = y + 10 + math.sin(rad) * 5})
	end
	surface.DrawPoly(dot)
	
	draw.SimpleText("OBJECTIVE", "NRC_HUD_Mono_Small", x + 18, y, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	local objective = NRCHUD.PlayerData.objective or "Secure Command Post - Hangar Bay"
	draw.SimpleText(objective, "NRC_HUD_Mono", x, y + 28, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function NRCHUD.DrawCommsInfo(ply, w, h)
	local x = w - 35
	local y = 30
	local lineH = 40
	
	local info = {
		{label = NRCHUD.GetText("comms_channel"), value = NRCHUD.PlayerData.commsChannel or "BATTALION NET", hasIndicator = true},
		{label = NRCHUD.GetText("frequency"), value = "445.750 MHz"},
		{label = NRCHUD.GetText("location"), value = NRCHUD.PlayerData.location or "GRID 447-B"},
		{label = NRCHUD.GetText("time"), value = os.date("%H:%M")},
	}
	
	for i, item in ipairs(info) do
		local yPos = y + (i - 1) * lineH
		
		local valueX = x
		if item.hasIndicator then
			local dotAlpha = math.abs(math.sin(CurTime() * 1.5)) * 128 + 127
			surface.SetDrawColor(74, 222, 128, dotAlpha)
			draw.NoTexture()
			local dotCircle = {}
			for j = 0, 360, 30 do
				local rad = math.rad(j)
				table.insert(dotCircle, {x = valueX - 18 + math.cos(rad) * 4, y = yPos + 10 + math.sin(rad) * 4})
			end
			surface.DrawPoly(dotCircle)
			
			surface.SetDrawColor(74, 222, 128, dotAlpha / 2)
			for k = 1, 2 do
				local glowCircle = {}
				for j = 0, 360, 30 do
					local rad = math.rad(j)
					table.insert(glowCircle, {x = valueX - 18 + math.cos(rad) * (4 + k), y = yPos + 10 + math.sin(rad) * (4 + k)})
				end
				surface.DrawPoly(glowCircle)
			end
		end
		
		draw.SimpleText(item.value, "NRC_HUD_Orbitron_Small", valueX, yPos, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText(item.label, "NRC_HUD_Mono_Tiny", valueX, yPos + 22, Color(255, 255, 255, 153), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end
end

function NRCHUD.DrawHitMarker(w, h)
	if not NRCHUD.ShowingHitMarker then return end
	
	local cx, cy = w / 2, h / 2
	local lineLen = 12
	local lineThick = 2
	local offset = 6
	
	surface.SetDrawColor(255, 255, 255, 255)
	
	for i = 0, lineThick do
		surface.DrawLine(cx - offset - lineLen + i, cy - offset - i, cx - offset + i, cy - offset - lineLen + i)
		surface.DrawLine(cx + offset + i, cy - offset - lineLen + i, cx + offset + lineLen - i, cy - offset - i)
		surface.DrawLine(cx - offset - lineLen + i, cy + offset + i, cx - offset + i, cy + offset + lineLen - i)
		surface.DrawLine(cx + offset + i, cy + offset + lineLen - i, cx + offset + lineLen - i, cy + offset + i)
	end
end

function NRCHUD.DrawDamageIndicators(w, h)
	local cx, cy = w / 2, h / 2
	local curTime = CurTime()
	
	for direction, endTime in pairs(NRCHUD.DamageIndicators) do
		if curTime < endTime then
			local alpha = ((endTime - curTime) / NRCHUD.Config.DamageIndicatorDuration) * 179
			surface.SetDrawColor(255, 255, 255, alpha)
			
			if direction == "Top" then
				surface.DrawRect(cx - 30, cy * 0.25, 60, 4)
			elseif direction == "Bottom" then
				surface.DrawRect(cx - 30, cy * 1.75, 60, 4)
			elseif direction == "Left" then
				surface.DrawRect(cx * 0.25, cy - 30, 4, 60)
			elseif direction == "Right" then
				surface.DrawRect(cx * 1.75, cy - 30, 4, 60)
			end
		else
			NRCHUD.DamageIndicators[direction] = nil
		end
	end
end

function NRCHUD.DrawLowHealthVignette(ply, w, h)
	local health = ply:Health()
	if health >= 35 then return end
	
	local alpha = math.Clamp((35 - health) / 35, 0, 1)
	alpha = alpha * (math.abs(math.sin(CurTime() * 1.5)) * 0.3 + 0.3)
	alpha = alpha * 179
	
	for i = 1, 25 do
		local dist = i * 40
		local edgeAlpha = (i / 25) * alpha
		surface.SetDrawColor(255, 0, 0, edgeAlpha)
		surface.DrawRect(0, h - dist, w, dist)
		surface.DrawRect(0, 0, w, dist)
		surface.DrawRect(0, 0, dist, h)
		surface.DrawRect(w - dist, 0, dist, h)
	end
end

print("[NRC HUD] Main HUD loaded!")