-- NRC Star Wars HUD - Minimap System (Client)

NRCHUD.Minimap = NRCHUD.Minimap or {
	players = {},
	lastUpdate = 0
}

-- Receive minimap data from server
net.Receive("NRCHUD_MinimapData", function()
	local count = net.ReadUInt(8)
	NRCHUD.Minimap.players = {}
	
	for i = 1, count do
		local id = net.ReadUInt(16)
		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local isAlly = net.ReadBool()
		
		table.insert(NRCHUD.Minimap.players, {
			id = id,
			x = x,
			y = y,
			isAlly = isAlly
		})
	end
end)

-- Draw minimap
local function DrawMinimap()
	if not NRCHUD.Config.ShowMinimap then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local size = NRCHUD.Config.MinimapSize or 150
	-- Position: Bottom right, ABOVE weapon display
	local x = ScrW() - 40 - size
	local y = ScrH() - 200 - size
	
	-- Background circle
	draw.NoTexture()
	surface.SetDrawColor(0, 0, 0, 160)
	draw.Circle(x + size/2, y + size/2, size/2, 64)
	
	-- Border circle (thicker and more visible)
	surface.SetDrawColor(255, 255, 255, 120)
	draw.Circle(x + size/2, y + size/2, size/2, 64)
	surface.SetDrawColor(255, 255, 255, 80)
	draw.Circle(x + size/2, y + size/2, size/2 - 2, 64)
	
	-- Center crosshair
	local cx, cy = x + size/2, y + size/2
	surface.SetDrawColor(255, 255, 255, 40)
	surface.DrawLine(cx - size/2, cy, cx + size/2, cy)
	surface.DrawLine(cx, cy - size/2, cx, cy + size/2)
	
	-- Player indicator (center) - bigger triangle
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255, 255)
	
	-- Draw triangle pointing up (larger)
	local triangleSize = 8
	local poly = {
		{x = cx, y = cy - triangleSize},
		{x = cx - triangleSize/1.5, y = cy + triangleSize/1.5},
		{x = cx + triangleSize/1.5, y = cy + triangleSize/1.5}
	}
	surface.DrawPoly(poly)
	
	-- Draw other players (if available)
	local scale = size / 2000
	local playerPos = ply:GetPos()
	
	for _, playerData in ipairs(NRCHUD.Minimap.players) do
		local dotColor = playerData.isAlly and Color(68, 255, 68, 255) or Color(255, 68, 68, 255)
		
		local dotX = cx + (playerData.x - playerPos.x) * scale
		local dotY = cy + (playerData.y - playerPos.y) * scale
		
		-- Check if dot is within circle
		local dist = math.sqrt((dotX - cx)^2 + (dotY - cy)^2)
		if dist < size/2 - 8 then
			draw.NoTexture()
			surface.SetDrawColor(dotColor.r, dotColor.g, dotColor.b, dotColor.a)
			draw.Circle(dotX, dotY, 4, 16)
		end
	end
end

-- Helper function to draw circles
function draw.Circle(x, y, radius, segments)
	local circle = {}
	for i = 0, segments do
		local angle = math.rad((i / segments) * 360)
		table.insert(circle, {
			x = x + math.cos(angle) * radius,
			y = y + math.sin(angle) * radius
		})
	end
	
	if #circle < 3 then return end
	
	draw.NoTexture()
	surface.DrawPoly(circle)
end

-- Add to HUD paint
hook.Add("HUDPaint", "NRCHUD_DrawMinimap", function()
	if not NRCHUD.Config.Enabled then return end
	DrawMinimap()
end)

print("[NRC HUD] Minimap system loaded!")