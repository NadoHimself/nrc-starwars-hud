-- NRC Star Wars HUD - Voice System

NRCHUD.Voice = NRCHUD.Voice or {}
NRCHUD.Voice.Muted = false
NRCHUD.Voice.Speaking = {}
NRCHUD.Voice.LocalSpeaking = false

-- Lucide Icons (SVG paths)
local micIcon = {
	-- Microphone body
	{type = "rect", x = 10, y = 2, w = 4, h = 10, rx = 2},
	-- Stand
	{type = "path", d = "M12 18v4M8 22h8"},
	-- Arc
	{type = "path", d = "M19 10v2a7 7 0 0 1-14 0v-2"},
}

local micOffIcon = {
	-- Microphone body (partial)
	{type = "path", d = "M12 2a3 3 0 0 0-3 3v3"},
	{type = "path", d = "M15 9v2a3 3 0 0 1-.628 1.874"},
	-- Stand
	{type = "path", d = "M12 18v4M8 22h8"},
	-- Arc left
	{type = "path", d = "M5 10v2a7 7 0 0 0 5.93 6.92"},
	-- Arc right
	{type = "path", d = "M18.89 13.23A7 7 0 0 0 19 12v-2"},
	-- Slash
	{type = "path", d = "M2 2l20 20"},
}

-- Draw SVG path
local function DrawSVGPath(x, y, scale, path, color)
	surface.SetDrawColor(color)
	
	if path.type == "rect" then
		local rx = (path.x or 0) * scale + x
		local ry = (path.y or 0) * scale + y
		local rw = (path.w or 0) * scale
		local rh = (path.h or 0) * scale
		draw.RoundedBox((path.rx or 0) * scale, rx, ry, rw, rh, color)
		return
	end
	
	if not path.d then return end
	
	-- Simple path parser for lines (M, L, H, V, v)
	local commands = {}
	for cmd in string.gmatch(path.d, "[MmLlHhVv][^MmLlHhVv]*") do
		table.insert(commands, cmd)
	end
	
	local lastX, lastY = 0, 0
	
	for _, cmd in ipairs(commands) do
		local letter = string.sub(cmd, 1, 1)
		local nums = {}
		
		for num in string.gmatch(string.sub(cmd, 2), "%-?[0-9%.]+") do
			table.insert(nums, tonumber(num))
		end
		
		if letter == "M" and #nums >= 2 then
			lastX = nums[1] * scale + x
			lastY = nums[2] * scale + y
		elseif letter == "m" and #nums >= 2 then
			lastX = lastX + nums[1] * scale
			lastY = lastY + nums[2] * scale
		elseif letter == "L" and #nums >= 2 then
			local newX = nums[1] * scale + x
			local newY = nums[2] * scale + y
			surface.DrawLine(lastX, lastY, newX, newY)
			lastX, lastY = newX, newY
		elseif letter == "l" and #nums >= 2 then
			local newX = lastX + nums[1] * scale
			local newY = lastY + nums[2] * scale
			surface.DrawLine(lastX, lastY, newX, newY)
			lastX, lastY = newX, newY
		elseif letter == "H" and #nums >= 1 then
			local newX = nums[1] * scale + x
			surface.DrawLine(lastX, lastY, newX, lastY)
			lastX = newX
		elseif letter == "h" and #nums >= 1 then
			local newX = lastX + nums[1] * scale
			surface.DrawLine(lastX, lastY, newX, lastY)
			lastX = newX
		elseif letter == "V" and #nums >= 1 then
			local newY = nums[1] * scale + y
			surface.DrawLine(lastX, lastY, lastX, newY)
			lastY = newY
		elseif letter == "v" and #nums >= 1 then
			local newY = lastY + nums[1] * scale
			surface.DrawLine(lastX, lastY, lastX, newY)
			lastY = newY
		elseif (letter == "a" or letter == "A") and #nums >= 7 then
			-- Arc - simplified to line
			local newX, newY
			if letter == "A" then
				newX = nums[6] * scale + x
				newY = nums[7] * scale + y
			else
				newX = lastX + nums[6] * scale
				newY = lastY + nums[7] * scale
			end
			surface.DrawLine(lastX, lastY, newX, newY)
			lastX, lastY = newX, newY
		end
	end
end

-- Draw icon
function NRCHUD.Voice.DrawIcon(x, y, size, muted, color)
	local icon = muted and micOffIcon or micIcon
	local scale = size / 24
	
	for _, path in ipairs(icon) do
		DrawSVGPath(x, y, scale, path, color or Color(255, 255, 255))
	end
end

-- Toggle mute
function NRCHUD.Voice.ToggleMute()
	NRCHUD.Voice.Muted = not NRCHUD.Voice.Muted
	
	if NRCHUD.Voice.Muted then
		RunConsoleCommand("voice_loopback", "0")
		surface.PlaySound("buttons/button14.wav")
	else
		RunConsoleCommand("voice_loopback", "1")
		surface.PlaySound("buttons/button15.wav")
	end
	
	-- Network
	net.Start("NRCHUD_VoiceMute")
		net.WriteBool(NRCHUD.Voice.Muted)
	net.SendToServer()
end

-- Voice hooks
hook.Add("PlayerStartVoice", "NRCHUD_VoiceStart", function(ply)
	if not IsValid(ply) then return end
	
	if ply == LocalPlayer() then
		NRCHUD.Voice.LocalSpeaking = true
		
		-- Muted check
		if NRCHUD.Voice.Muted then
			return false -- Block voice
		end
	else
		NRCHUD.Voice.Speaking[ply] = {
			name = ply:Nick(),
			rank = ply:getDarkRPVar("job") or "Unknown",
			startTime = CurTime(),
		}
	end
end)

hook.Add("PlayerEndVoice", "NRCHUD_VoiceEnd", function(ply)
	if not IsValid(ply) then return end
	
	if ply == LocalPlayer() then
		NRCHUD.Voice.LocalSpeaking = false
	else
		NRCHUD.Voice.Speaking[ply] = nil
	end
end)

-- Cleanup disconnected players
hook.Add("PlayerDisconnected", "NRCHUD_VoiceCleanup", function(ply)
	NRCHUD.Voice.Speaking[ply] = nil
end)

-- Network
net.Receive("NRCHUD_VoiceSpeakers", function()
	local count = net.ReadUInt(8)
	local speakers = {}
	
	for i = 1, count do
		local ply = net.ReadEntity()
		if IsValid(ply) then
			speakers[ply] = {
				name = net.ReadString(),
				rank = net.ReadString(),
				channel = net.ReadString(),
			}
		end
	end
	
	NRCHUD.Voice.ChannelSpeakers = speakers
end)

print("[NRC HUD] Voice system loaded!")