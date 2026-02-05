-- NRC Star Wars HUD - Main HUD Rendering

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
	["DarkRP_Agenda"] = true
}

hook.Add("HUDShouldDraw", "NRCHUD_HideDefault", function(name)
	if hideHUD[name] then return false end
end)

-- Fonts
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

-- Draw glass box
local function DrawGlassBox(x, y, w, h)
	-- Background
	surface.SetDrawColor(0, 0, 0, 102)
	surface.DrawRect(x, y, w, h)
	
	-- Border
	surface.SetDrawColor(255, 255, 255, 64)
	draw.NoTexture()
	surface.DrawOutlinedRect(x, y, w, h, 1)
	
	-- Left accent
	surface.SetDrawColor(255, 255, 255, 153)
	surface.DrawRect(x, y, 2, h)
end

-- Draw identity card
local function DrawIdentity()
	if not NRCHUD.Config.ShowIdentity then return end
	
	local x, y = 30, ScrH() - 165
	local w, h = 280, 45
	
	DrawGlassBox(x, y, w, h)
	
	-- Name
	draw.SimpleText(NRCHUD.PlayerData.name, "NRCHUD_Identity_Name", x + 14, y + 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	
	-- Rank and Job
	local rankText = NRCHUD.PlayerData.job .. " • " .. NRCHUD.PlayerData.rank
	draw.SimpleText(rankText, "NRCHUD_Identity_Rank", x + 14, y + 28, Color(255, 255, 255, 165), TEXT_ALIGN_LEFT)
end

-- Draw health and armor
local function DrawVitals()
	if not NRCHUD.Config.ShowHealth then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local health = math.max(0, ply:Health())
	local maxHealth = ply:GetMaxHealth()
	local healthPercent = health / maxHealth
	
	local armor = math.max(0, ply:Armor())
	local maxArmor = 100
	local armorPercent = armor / maxArmor
	
	local x, y = 30, ScrH() - 110
	
	-- Health row
	local healthW = 280
	local healthH = 28
	
	DrawGlassBox(x, y, healthW, healthH)
	
	draw.SimpleText("HEALTH", "NRCHUD_Vital_Label", x + 12, y + 9, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT)
	
	-- Health bar
	local barX = x + 67
	local barY = y + 11
	local barW = 150
	local barH = 5
	
	surface.SetDrawColor(255, 255, 255, 25)
	surface.DrawRect(barX, barY, barW, barH)
	
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(barX, barY, barW * healthPercent, barH)
	
	-- Health value
	draw.SimpleText(tostring(math.floor(health)), "NRCHUD_Vital_Value", x + healthW - 12, y + 8, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	
	-- Armor row
	if NRCHUD.Config.ShowArmor then
		local armorY = y + 36
		
		DrawGlassBox(x, armorY, healthW, healthH)
		
		draw.SimpleText("ARMOR", "NRCHUD_Vital_Label", x + 12, armorY + 9, Color(255, 255, 255, 153), TEXT_ALIGN_LEFT)
		
		-- Armor bar
		surface.SetDrawColor(255, 255, 255, 25)
		surface.DrawRect(barX, armorY + 11, barW, barH)
		
		surface.SetDrawColor(255, 255, 255, 191)
		surface.DrawRect(barX, armorY + 11, barW * armorPercent, barH)
		
		-- Armor value
		draw.SimpleText(tostring(math.floor(armor)), "NRCHUD_Vital_Value", x + healthW - 12, armorY + 8, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	end
end

-- Draw currency
local function DrawCurrency()
	if not NRCHUD.Config.ShowCurrency then return end
	
	local x, y = 30, ScrH() - 165 - 48
	local w, h = 180, 38
	
	-- Gold border for currency
	DrawGlassBox(x, y, w, h)
	surface.SetDrawColor(255, 215, 0, 204)
	surface.DrawRect(x, y, 2, h)
	
	-- Icon
	draw.SimpleText("◈", "NRCHUD_Currency", x + 20, y + 11, Color(255, 215, 0, 255), TEXT_ALIGN_CENTER)
	
	-- Amount
	local amountText = string.Comma(NRCHUD.PlayerData.currency)
	draw.SimpleText(amountText, "NRCHUD_Currency", x + 45, y + 10, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT)
	
	-- Label
	draw.SimpleText(NRCHUD.Config.CurrencyName:upper(), "NRCHUD_Currency_Label", x + 45, y + 26, Color(255, 215, 0, 178), TEXT_ALIGN_LEFT)
end

-- Draw ammo
local function DrawAmmo()
	if not NRCHUD.Config.ShowAmmo then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) then return end
	
	local clip = weapon:Clip1()
	local reserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
	
	if clip < 0 then return end
	
	local x, y = ScrW() - 30, ScrH() - 80
	
	-- Current ammo
	draw.SimpleText(tostring(clip), "NRCHUD_Ammo_Current", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	
	-- Separator
	draw.SimpleText("/", "NRCHUD_Ammo_Reserve", x, y + 5, Color(255, 255, 255, 102), TEXT_ALIGN_RIGHT)
	
	-- Reserve ammo
	draw.SimpleText(tostring(reserve), "NRCHUD_Ammo_Reserve", x + 10, y + 5, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT)
	
	-- Weapon name
	local weaponName = weapon:GetPrintName():upper()
	draw.SimpleText(weaponName, "NRCHUD_Weapon_Label", x, y + 35, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT)
end

-- Draw hit marker
local function DrawHitMarker()
	if not NRCHUD.Config.ShowHitMarker or not NRCHUD.ShowingHitMarker then return end
	
	local cx, cy = ScrW() / 2, ScrH() / 2
	local size = 10
	local gap = 5
	
	surface.SetDrawColor(255, 255, 255, 255)
	
	-- Top-left
	surface.DrawLine(cx - gap - size, cy - gap - size, cx - gap, cy - gap)
	-- Top-right  
	surface.DrawLine(cx + gap + size, cy - gap - size, cx + gap, cy - gap)
	-- Bottom-left
	surface.DrawLine(cx - gap - size, cy + gap + size, cx - gap, cy + gap)
	-- Bottom-right
	surface.DrawLine(cx + gap + size, cy + gap + size, cx + gap, cy + gap)
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
			
			if direction == "Top" then
				surface.DrawLine(cx - size/2, cy - offset, cx + size/2, cy - offset)
			elseif direction == "Bottom" then
				surface.DrawLine(cx - size/2, cy + offset, cx + size/2, cy + offset)
			elseif direction == "Left" then
				surface.DrawLine(cx - offset, cy - size/2, cx - offset, cy + size/2)
			elseif direction == "Right" then
				surface.DrawLine(cx + offset, cy - size/2, cx + offset, cy + size/2)
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
	local maxHealth = ply:GetMaxHealth()
	
	if health < NRCHUD.Config.LowHealthThreshold then
		local intensity = 1 - (health / NRCHUD.Config.LowHealthThreshold)
		local pulse = math.abs(math.sin(CurTime() * 2)) * 0.3 + 0.3
		local alpha = intensity * pulse * 76
		
		surface.SetDrawColor(255, 0, 0, alpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end
end

-- Main HUD draw hook
hook.Add("HUDPaint", "NRCHUD_Draw", function()
	if not NRCHUD.Config.Enabled then return end
	
	DrawLowHealthVignette()
	DrawIdentity()
	DrawVitals()
	DrawCurrency()
	DrawAmmo()
	DrawHitMarker()
	DrawDamageIndicators()
end)

print("[NRC HUD] HUD rendering loaded!")