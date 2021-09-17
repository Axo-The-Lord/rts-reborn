local distortion = Artifact.find("Distortion", "vanilla")
removal("Alien Head", function(player, count)
	player:set("cdr", math.min(1 - ((distortion.active and 0.75 or 1) * math.pow(0.7, count)), 0.6))
end)

require "Core/irl/scepter"
removal("Ancient Scepter", function(player, count)
	adjust(player, "scepter", -1)
	if count == 0 then
		scepterRemoval[player:getSurvivor()](player)
	end
end)

local targeting = Object.find("EfTargeting")
local target_color = Color.fromRGB(255, 160, 64)
removal("Atg Missile Mk. 2", function(player, count)
	if count == 0 then
		for _, v in ipairs(targeting:findMatching("parent", player.id)) do
			if Color.equals(target_color, v.blendColor) then v:destroy() end
		end
	end
	adjust(player, "missile_tri", -1)
end)

removal("Beating Embryo", function(player)
	adjust(player, "embryo", -1)
end)

removal("Brilliant Behemoth", function(player)
	adjust(player, "explosive_shot", -1)
end)

removal("Ceremonial Dagger", function(player)
	adjust(player, "dagger", -1)
end)

removal("Dio's Friend", function(player, count)
	if count == 0 then player:set("hippo", 0) end
end)

removal("Fireman's Boots", function(player)
	adjust(player, "fire_trail", -1)
end)

removal("Happiest Mask", function(player)
	adjust(player, "mask", -1)
end)

removal("Heaven Cracker", function(player)
	adjust(player, "drill", -1)
	player:set("z_count", 0)
end)

removal("Hyper-Threader", function(player)
	adjust(player, "blaster", -1)
end)

removal("Interstellar Desk Plant", function(player)
	adjust(player, "deskplant", -1)
end)

removal("Laser Turbine", function(player)
	adjust(player, "laserturbine", -1)
end)

removal("Old Box", function(player)
	adjust(player, "jackbox", -1)
end)

removal("Permafrost", function(player)
	player:set("freeze", (player:get("freeze") - 0.06) / 0.94)
end)

removal("Photon Jetpack", function(player)
	adjust(player, "jetpack", -1)
end)

removal("Plasma Chain", function(player)
	adjust(player, "plasma", -1)
end)

removal("Rapid Mitosis", function(player)
	player:set("use_cooldown", player:get("use_cooldown") / 0.75)
end)

removal("Repulsion Armor", function(player)
	adjust(player, "reflector", -1)
end)

removal("Shattering Justice", function(player)
	adjust(player, "sunder", -1)
end)

removal("Telescopic Sight", function(player)
	adjust(player, "scope", -1)
end)

removal("Tesla Coil", function(player)
	adjust(player, "tesla", -1)
end)

removal("Thallium", function(player)
	adjust(player, "thallium", -1)
end)

removal("The Hit List", function(player)
	adjust(player, "mark", -1)
end)

removal("The Ol' Lopper", function(player)
	adjust(player, "axe", -1)
end)

removal("Wicked Ring", function(player)
	adjust(player, "skull_ring", -1)
	adjust(player, "critical_chance", -6)
end)
