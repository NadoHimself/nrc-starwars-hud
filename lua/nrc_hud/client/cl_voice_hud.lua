-- NRC Star Wars HUD - Voice HUD Indicator

surface.CreateFont("NRC_Voice_Name", {font = "Orbitron", size = 14, weight = 600, antialias = true, extended = true})
surface.CreateFont("NRC_Voice_Rank", {font = "Share Tech Mono", size = 11, weight = 500, antialias = true, extended = true})

local function DrawVoiceHUD()
	if not NRCHUD.Voice or not NRCHUD.Voice.Speaking then return end
	
	local scrW, scrH = ScrW(), ScrH()
	local startX = scrW - 320
	local startY = scrH - 200
	
	local speakers = {}
	for ply, data in pairs(NRCHUD.Voice.Speaking) do
		if IsValid(ply) and ply ~= LocalPlayer() then
			table.insert(speakers, {ply = ply, data = data})
		end
	end
	
	-- Add local player if speaking
	if NRCHUD.Voice.LocalSpeaking and not NRCHUD.Voice.Muted then
		local lp = LocalPlayer()
		table.insert(speakers, {
			ply = lp,
			data = {
				name = lp:Nick(),
				rank = lp:getDarkRPVar("job") or "Unknown",
				startTime = CurTime(),
			}
		})
	end
	
	if #speakers == 0 then return end
	
	-- Container
	local boxW = 300
	local boxH = 40 + (#speakers * 32)
	
	draw.RoundedBox(18, startX, startY, boxW, boxH, Color(0, 0, 0, 61))
	surface.SetDrawColor(120, 210, 255, 36)
	surface.DrawOutlinedRect(startX, startY, boxW, boxH, 1)
	
	-- Header
	draw.SimpleText("COMMS • AKTIV", "NRC_Voice_Rank", startX + 12, startY + 12, Color(235, 248, 255, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	-- Speakers
	local yOff = 40
	for i, speaker in ipairs(speakers) do
		local y = startY + yOff + ((i - 1) * 32)
		
		-- Icon
		local iconX = startX + 12
		local iconY = y + 4
		NRCHUD.Voice.DrawIcon(iconX, iconY, 18, false, Color(90, 255, 190, 224))
		
		-- Animated wave
		local waveAlpha = math.abs(math.sin(CurTime() * 3)) * 100 + 50
		surface.SetDrawColor(90, 255, 190, waveAlpha)
		surface.DrawOutlinedRect(iconX - 2, iconY - 2, 22, 22, 1)
		
		-- Name
		local name = speaker.data.name or "Unknown"
		draw.SimpleText(name, "NRC_Voice_Name", startX + 42, y + 2, Color(235, 248, 255, 209), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Rank (get abbreviation)
		local rank = speaker.data.rank or "UNK"
		local rankAbbr = ""
		
		-- Try to extract abbreviation from rank name
		for word in string.gmatch(rank, "%S+") do
			rankAbbr = rankAbbr .. string.upper(string.sub(word, 1, 1))
		end
		
		if rankAbbr == "" then
			rankAbbr = "UNK"
		end
		
		draw.SimpleText("[" .. rankAbbr .. "]", "NRC_Voice_Rank", startX + 42, y + 18, Color(120, 210, 255, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Divider
		if i < #speakers then
			for dx = 0, boxW - 24 do
				local alpha = math.sin((dx / (boxW - 24)) * math.pi) * 36
				surface.SetDrawColor(120, 210, 255, alpha)
				surface.DrawLine(startX + 12 + dx, y + 28, startX + 12 + dx, y + 28)
			end
		end
	end
end

hook.Add("HUDPaint", "NRCHUD_VoiceHUD", function()
	DrawVoiceHUD()
end)

print("[NRC HUD] Voice HUD indicator loaded!")