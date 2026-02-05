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
	["DarkRP_Agenda"] = true,
	["DarkRP_ChatReceivers"] = true
}

hook.Add("HUDShouldDraw", "NRCHUD_HideDefault", function(name)
	if hideHUD[name] then return false end
end)

-- Hide DarkRP HUD completely
hook.Add("HUDDrawTargetID", "NRCHUD_HideDarkRP", function()
	return false
end)

hook.Add("HUDDrawPickupHistory", "NRCHUD_HideDarkRP", function()
	return false
end)

-- Fonts
surface.CreateFont("NRCHUD_Identity_Name", {
	font = "Trebuchet MS",
	size = 15,
	weight = 600,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Identity_Rank", {
	font = "Trebuchet MS",
	size = 10,
	weight = 400,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Vital_Label", {
	font = "Trebuchet MS",
	size = 10,
	weight = 400,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Vital_Value", {
	font = "Trebuchet MS",
	size = 12,
	weight = 600,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Currency", {
	font = "Trebuchet MS",
	size = 16,
	weight = 600,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Currency_Label", {
	font = "Trebuchet MS",
	size = 9,
	weight = 400,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Ammo_Current", {
	font = "Trebuchet MS",
	size = 48,
	weight = 600,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Ammo_Reserve", {
	font = "Trebuchet MS",
	size = 24,
	weight = 400,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Weapon_Label", {
	font = "Trebuchet MS",
	size = 10,
	weight = 400,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Objective_Label", {
	font = "Trebuchet MS",
	size = 10,
	weight = 400,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Objective_Text", {
	font = "Trebuchet MS",
	size = 14,
	weight = 400,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Comms_Value", {
	font = "Trebuchet MS",
	size = 16,
	weight = 600,
	antialias = true,
	shadow = false
})

surface.CreateFont("NRCHUD_Comms_Label", {
	font = "Trebuchet MS",
	size = 9,
	weight = 400,
	antialias = true,
	shadow = false
})

-- Draw glass box
local function DrawGlassBox(x, y, w, h)
	-- Background with blur effect
	draw.RoundedBox(0, x, y, w, h, Color(0, 0, 0, 102))
	
	-- Border
	surface.SetDrawColor(255, 255, 255, 64)
	surface.DrawOutlinedRect(x, y, w, h)
	
	-- Left accent
	surface.SetDrawColor(255, 255, 255, 153)
	surface.DrawRect(x, y, 2, h)
end

-- Draw identity card
local function DrawIdentity()
	if not NRCHUD.Config.ShowIdentity then return end
	
	local x = 30
	local y = ScrH() - 165
	local w = 280
	local h = 45
	
	DrawGlassBox(x, y, w, h)
	
	-- Name
	local displayName = NRCHUD.PlayerData.name or "Unknown"
	draw.SimpleText(displayName, "NRCHUD_Identity_Name", x + 14, y + 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	
	-- Rank and Job
	local job = NRCHUD.PlayerData.job or "Unknown"
	local rank = NRCHUD.PlayerData.rank or "Trooper"
	local rankText = job .. " • " .. rank
	draw.SimpleText(rankText, "NRCHUD_Identity_Rank", x + 14, y + 28, Color(255, 255, 255, 165), TEXT_ALIGN_LEFT)
end

-- Draw health and armor
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
	local y = ScrH() - 110
	
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
	
	local x = 30
	local y = ScrH() - 220
	local w = 180
	local h = 38
	
	-- Gold border for currency
	DrawGlassBox(x, y, w, h)
	surface.SetDrawColor(255, 215, 0, 204)
	surface.DrawRect(x, y, 2, h)
	
	-- Icon
	draw.SimpleText("◈", "NRCHUD_Currency", x + 20, y + 11, Color(255, 215, 0, 255), TEXT_ALIGN_CENTER)
	
	-- Amount
	local amountText = string.Comma(NRCHUD.PlayerData.currency or 0)
	draw.SimpleText(amountText, "NRCHUD_Currency", x + 45, y + 10, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT)
	
	-- Label
	local currencyLabel = NRCHUD.Config.CurrencyName or "CREDITS"
	draw.SimpleText(currencyLabel:upper(), "NRCHUD_Currency_Label", x + 45, y + 26, Color(255, 215, 0, 178), TEXT_ALIGN_LEFT)
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
	
	local x = ScrW() - 30
	local y = ScrH() - 80
	
	-- Current ammo
	draw.SimpleText(tostring(clip), "NRCHUD_Ammo_Current", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	
	-- Separator
	local sepX = x + 5
	draw.SimpleText("/", "NRCHUD_Ammo_Reserve", sepX, y + 5, Color(255, 255, 255, 102), TEXT_ALIGN_LEFT)
	
	-- Reserve ammo  
	local reserveX = sepX + 15
	draw.SimpleText(tostring(reserve), "NRCHUD_Ammo_Reserve", reserveX, y + 5, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT)
	
	-- Weapon name
	local weaponName = weapon:GetPrintName()
	if weaponName == "" or weaponName == "Scripted Weapon" then
		weaponName = weapon:GetClass()
	end
	weaponName = string.upper(weaponName)
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
	local maxHealth = ply:GetMaxHealth() or 100
	
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
	DrawCurrency()
	DrawIdentity()
	DrawVitals()
	DrawAmmo()
	DrawHitMarker()
	DrawDamageIndicators()
end)

print("[NRC HUD] HUD rendering loaded!")