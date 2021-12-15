-- ==== --
-- Boss --
-- ==== --

removal("Burning Witness", function(player)
	adjust(player, "worm_eye", -1)
end)

removal("Colossal Knurl", function(player)
	adjust(player, "maxhp_base", -40)
	local p = player:getAccessor()
	p.maxhp = math.min(p.maxhp_base * p.percent_hp)
	if p.hp > p.maxhp then
		p.hp = p.maxhp
		p.lastHp = p.hp
	end
	adjust(player, "hp_regen", -0.02)
	adjust(player, "armor", -5)
end)

removal("Ifrit's Horn", function(player)
	adjust(player, "horn", -1)
end)

removal("Imp Overlord's Tentacle", function(player, count)
	adjust(player, "tentacle", -1)
	if count == 0 then
		local tid = player:get("tentacle_id")
		if tid then imp = Object.findInstance(tid) end
		if imp and imp:isValid() then imp:destroy() end
	end
end)

removal("Legendary Spark", function(player)
	adjust(player, "spark", -1)
end)

-- ==== --
-- Misc --
-- ==== --

removal("Small Enigma", function(player)
	player:set("use_cooldown", player:get("use_cooldown") / 0.95)
end)

-- "White Undershirt (M) has been moved to example.lua to act as an example.

removal("Keycard", function(player)
	adjust(player, "keycard", -1)
end)
