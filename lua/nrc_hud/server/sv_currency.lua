-- NRC Star Wars HUD - Currency System (Server)

-- Update player currency
function NRCHUD.UpdatePlayerCurrency(ply)
	if not IsValid(ply) then return end
	
	local amount = 0
	
	-- Get money from DarkRP if enabled
	if NRCHUD.Config.UseDarkRPMoney and DarkRP and ply.getDarkRPVar then
		amount = ply:getDarkRPVar("money") or 0
	else
		-- Fallback to stored value
		amount = ply:GetNWInt("NRCHUD_Credits", 0)
	end
	
	net.Start("NRCHUD_UpdateCurrency")
		net.WriteUInt(amount, 32)
	net.Send(ply)
end

-- Set player currency (if not using DarkRP)
function NRCHUD.SetCurrency(ply, amount)
	if not IsValid(ply) then return end
	
	if NRCHUD.Config.UseDarkRPMoney and DarkRP then
		-- Use DarkRP money system
		ply:setDarkRPVar("money", math.max(0, amount))
	else
		-- Use internal system
		ply:SetNWInt("NRCHUD_Credits", math.max(0, amount))
	end
	
	NRCHUD.UpdatePlayerCurrency(ply)
end

-- Add currency to player
function NRCHUD.AddCurrency(ply, amount)
	if not IsValid(ply) then return end
	
	local current = 0
	
	if NRCHUD.Config.UseDarkRPMoney and DarkRP and ply.getDarkRPVar then
		current = ply:getDarkRPVar("money") or 0
		ply:setDarkRPVar("money", current + amount)
	else
		current = ply:GetNWInt("NRCHUD_Credits", 0)
		ply:SetNWInt("NRCHUD_Credits", current + amount)
	end
	
	NRCHUD.UpdatePlayerCurrency(ply)
end

-- Hook into DarkRP money changes
if DarkRP then
	hook.Add("playerBoughtCustomVehicle", "NRCHUD_UpdateMoney", function(ply)
		timer.Simple(0.1, function()
			if IsValid(ply) then
				NRCHUD.UpdatePlayerCurrency(ply)
			end
		end)
	end)
	
	hook.Add("playerBoughtDoor", "NRCHUD_UpdateMoney", function(ply)
		timer.Simple(0.1, function()
			if IsValid(ply) then
				NRCHUD.UpdatePlayerCurrency(ply)
			end
		end)
	end)
	
	hook.Add("playerBoughtVehicle", "NRCHUD_UpdateMoney", function(ply)
		timer.Simple(0.1, function()
			if IsValid(ply) then
				NRCHUD.UpdatePlayerCurrency(ply)
			end
		end)
	end)
end

-- Update currency periodically
timer.Create("NRCHUD_UpdateCurrency", 5, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) then
			NRCHUD.UpdatePlayerCurrency(ply)
		end
	end
end)

print("[NRC HUD] Currency system loaded!")