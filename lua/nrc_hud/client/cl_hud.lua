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

-- Fonts - INCREASED SIZES
surface.CreateFont("NRCHUD_Identity_Name", {
	font = "Trebuchet MS",
	size = 22, -- Was 15
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Identity_Rank", {
	font = "Trebuchet MS",
	size = 16, -- Was 10
	weight = 500,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Vital_Label", {
	font = "Trebuchet MS",
	size = 16, -- Was 10
	weight = 600,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Vital_Value", {
	font = "Trebuchet MS",
	size = 18, -- Was 12
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Currency", {
	font = "Trebuchet MS",
	size = 24, -- Was 16
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Currency_Label", {
	font = "Trebuchet MS",
	size = 14, -- Was 9
	weight = 500,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Ammo_Current", {
	font = "Trebuchet MS",
	size = 56, -- Was 48
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Ammo_Reserve", {
	font = "Trebuchet MS",
	size = 32, -- Was 24
	weight = 500,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Weapon_Label", {
	font = "Trebuchet MS",
	size = 14, -- Was 10
	weight = 600,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Objective_Label", {
	font = "Trebuchet MS",
	size = 14, -- Was 10
	weight = 600,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Objective_Text", {
	font = "Trebuchet MS",
	size = 18, -- Was 14
	weight = 500,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Comms_Value", {
	font = "Trebuchet MS",
	size = 20, -- Was 16
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("NRCHUD_Comms_Label", {
	font = "Trebuchet MS",
	size = 12, -- Was 9
	weight = 500,
	antialias = true,
	shadow = true
})

-- Draw glass box with visible border
local function DrawGlassBox(x, y, w, h)
	-- Background
	draw.RoundedBox(0, x, y, w, h, Color(0, 0, 0, 150))
	
	-- White border (more visible)
	surface.SetDrawColor(255, 255, 255, 100)
	surface.DrawOutlinedRect(x, y, w, h, 2)
	
	-- Left accent (thicker)
	surface.SetDrawColor(255, 255, 255, 200)
	surface.DrawRect(x, y, 3, h)
end

-- Draw identity card
local function DrawIdentity()
	if not NRCHUD.Config.ShowIdentity then return end
	
	local x = 30
	local y = ScrH() - 200
	local w = 350
	local h = 60
	
	DrawGlassBox(x, y, w, h)
	
	-- Get player data
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
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
	draw.SimpleText(displayName, "NRCHUD_Identity_Name", x + 18, y + 12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	
	-- Rank and Job
	local rankText = job .. " • " .. rank
	draw.SimpleText(rankText, "NRCHUD_Identity_Rank", x + 18, y + 36, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT)
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
	local y = ScrH() - 130
	
	-- Health row
	local healthW = 350
	local healthH = 38
	
	DrawGlassBox(x, y, healthW, healthH)
	
	draw.SimpleText("HEALTH", "NRCHUD_Vital_Label", x + 18, y + 11, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT)
	
	-- Health bar
	local barX = x + 95
	local barY = y + 15
	local barW = 180
	local barH = 8
	
	surface.SetDrawColor(255, 255, 255, 40)
	surface.DrawRect(barX, barY, barW, barH)
	
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(barX, barY, barW * healthPercent, barH)
	
	-- Health value
	draw.SimpleText(tostring(math.floor(health)), "NRCHUD_Vital_Value", x + healthW - 18, y + 10, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	
	-- Armor row
	if NRCHUD.Config.ShowArmor then
		local armorY = y + 48
		
		DrawGlassBox(x, armorY, healthW, healthH)
		
		draw.SimpleText("ARMOR", "NRCHUD_Vital_Label", x + 18, armorY + 11, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT)
		
		-- Armor bar
		surface.SetDrawColor(255, 255, 255, 40)
		surface.DrawRect(barX, armorY + 15, barW, barH)
		
		surface.SetDrawColor(255, 255, 255, 220)
		surface.DrawRect(barX, armorY + 15, barW * armorPercent, barH)
		
		-- Armor value
		draw.SimpleText(tostring(math.floor(armor)), "NRCHUD_Vital_Value", x + healthW - 18, armorY + 10, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	end
end

-- Draw currency
local function DrawCurrency()
	if not NRCHUD.Config.ShowCurrency then return end
	
	local x = 30
	local y = ScrH() - 270
	local w = 220
	local h = 50
	
	-- Gold border for currency
	DrawGlassBox(x, y, w, h)
	surface.SetDrawColor(255, 215, 0, 220)
	surface.DrawRect(x, y, 3, h)
	
	-- Icon
	draw.SimpleText("◈", "NRCHUD_Currency", x + 28, y + 13, Color(255, 215, 0, 255), TEXT_ALIGN_CENTER)
	
	-- Amount
	local amountText = string.Comma(NRCHUD.PlayerData.currency or 0)
	draw.SimpleText(amountText, "NRCHUD_Currency", x + 55, y + 12, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT)
	
	-- Label
	local currencyLabel = NRCHUD.Config.CurrencyName or "CREDITS"
	draw.SimpleText(currencyLabel:upper(), "NRCHUD_Currency_Label", x + 55, y + 32, Color(255, 215, 0, 200), TEXT_ALIGN_LEFT)
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
	
	local x = ScrW() - 40
	local y = ScrH() - 100
	
	-- Current ammo
	draw.SimpleText(tostring(clip), "NRCHUD_Ammo_Current", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	
	-- Separator
	local sepX = x + 10
	draw.SimpleText("/", "NRCHUD_Ammo_Reserve", sepX, y + 8, Color(255, 255, 255, 120), TEXT_ALIGN_LEFT)
	
	-- Reserve ammo  
	local reserveX = sepX + 25
	draw.SimpleText(tostring(reserve), "NRCHUD_Ammo_Reserve", reserveX, y + 8, Color(255, 255, 255, 180), TEXT_ALIGN_LEFT)
	
	-- Weapon name
	local weaponName = weapon:GetPrintName()
	if weaponName == "" or weaponName == "Scripted Weapon" then
		weaponName = weapon:GetClass()
	end
	weaponName = string.upper(weaponName)
	draw.SimpleText(weaponName, "NRCHUD_Weapon_Label", x, y + 45, Color(255, 255, 255, 180), TEXT_ALIGN_RIGHT)
end

-- Draw hit marker
local function DrawHitMarker()
	if not NRCHUD.Config.ShowHitMarker or not NRCHUD.ShowingHitMarker then return end
	
	local cx, cy = ScrW() / 2, ScrH() / 2
	local size = 12
	local gap = 8
	
	surface.SetDrawColor(255, 255, 255, 255)
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
			local alpha = math.Clamp((endTime - currentTime) / NRCHUD.Config.DamageIndicatorDuration * 180, 0, 180)
			
			surface.SetDrawColor(255, 255, 255, alpha)
			
			local cx, cy = ScrW() / 2, ScrH() / 2
			local offset = 220
			local size = 60
			
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