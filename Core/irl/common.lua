local thorns = Object.find("EfThorns", "vanilla")
removal("Barbed Wire", function(player, count)
	for _, v in ipairs(thorns:findMatching("parent", player.id)) do
		if count == 0 then v:destroy() else v:set("coeff", v:get("coeff") - 0.2) end
	end
end)

-- Probably shouldnt use the math.min and instead use an item count
-- Though this version is more accurate i guess
removal("Bitter Root", function(player, count)
	local p = player:getAccessor()
	p.percent_hp = math.min(1 + count * 0.08, 4)
	p.maxhp = math.min(math.ceil(p.maxhp_base * p.percent_hp), p.maxhpcap)
	if p.hp > p.maxhp then
		p.hp = p.maxhp
		p.lastHp = p.hp
	end
end)

removal("Bundle of Fireworks", function(player)
	adjust(player, "fireworks", -1)
end)

removal("Bustling Fungus", function(player)
	adjust(player, "mushroom", -1)
end)

removal("Crowbar", function(player)
	adjust(player, "crowbar", -1)
end)

removal("Fire Shield", function(player)
	adjust(player, "fireshield", -1)
end)

removal("First Aid Kit", function(player)
	adjust(player, "medkit", -1)
end)

removal("Gasoline", function(player)
	adjust(player, "gas", -1)
end)

removal("Headstompers", function(player)
	adjust(player, "stompers", -1)
end)

removal("Hermit's Scarf", function(player)
	adjust(player, "scarf", -1)
end)

removal("Lens Maker's Glasses", function(player)
	adjust(player, "critical_chance", -7)
end)

removal("Life Savings", function(player)
	adjust(player, "gp5", -0.005)
end)

removal("Meat Nugget", function(player)
	adjust(player, "nugget", -1)
end)

removal("Monster Tooth", function(player)
	adjust(player, "heal_after_kill", -1)
end)

removal("Mortar Tube", function(player)
	adjust(player, "mortar", -1)
end)

removal("Mysterious Vial", function(player)
	adjust(player, "hp_regen", -0.014)
end)

removal("Paul's Goat Hoof", function(player, count)
	if count < 25 then
		adjust(player, "pHmax", -0.15)
	end
end)

removal("Rusty Blade", function(player)
	adjust(player, "bleed", -1)
end)

removal("Snake Eyes", function(player)
	adjust(player, "dice", -1)
end)

removal("Soldier's Syringe", function(player, count)
	if count < 13 then
		adjust(player, "attack_speed", -0.15)
	end
end)

removal("Spikestrip", function(player)
	adjust(player, "spikestrip", -1)
end)

removal("Sprouting Egg", function(player)
	adjust(player, "egg_regen", -0.04)
end)

removal("Sticky Bomb", function(player)
	adjust(player, "sticky", -1)
end)

removal("Taser", function(player)
	adjust(player, "taser", -1)
end)

removal("Warbanner", function(player)
	adjust(player, "warbanner", -1)
end)
