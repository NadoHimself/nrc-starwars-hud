-- NRC Star Wars HUD - Keybinds (Client)

-- Register keybinds
hook.Add("PlayerBindPress", "NRCHUD_Keybinds", function(ply, bind, pressed)
	if not pressed then return end
	
	-- F5 - Comms Menu
	if string.find(bind, "gm_showhelp") then
		NRCHUD.OpenCommsMenu()
		return true
	end
	
	-- F6 - Commander Menu
	if string.find(bind, "gm_showteam") then
		NRCHUD.OpenCommanderMenu()
		return true
	end
end)

print("[NRC HUD] Keybinds loaded! F5 = Comms, F6 = Commander")