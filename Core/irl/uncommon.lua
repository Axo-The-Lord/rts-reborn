removal("56 Leaf Clover", function(player)
	adjust(player, "clover", -1)
end)

removal("Arms Race", function(player)
	adjust(player, "armsrace", -1)
end)

local targeting = Object.find("EfTargeting")
local target_color = Color.fromRGB(92, 152, 78)
removal("Atg Missile Mk. 1", function(player, count)
	if count == 0 then
		for _, v in ipairs(targeting:findMatching("parent", player.id)) do
			if Color.equals(target_color, v.blendColor) then v:destroy() end
		end
	end
	adjust(player, "missile", -1)
end)

removal("Boxing Gloves", function(player)
	player:set("knockback", (player:get("knockback") - 0.06) / 0.94)
end)

removal("Chargefield Generator", function(player)
	adjust(player, "lightning_ring", -1)
end)

removal("Concussion Grenade", function(player)
	player:set("stun", (player:get("stun") - 0.06) / 0.94)
end)

removal("Dead Man's Foot", function(player)
	adjust(player, "poison_mine", -1)
end)

removal("Energy Cell", function(player)
	adjust(player, "cell", -1)
end)

local suck = Object.find("Sucker")
removal("Filial Imprinting", function(player)
	for _, v in ipairs(suck:findMatching("master", player.id)) do
		v:destroy()
		break
	end
end)

removal("Frost Relic", function(player)
	adjust(player, "icerelic", -1)
end)

removal("Golden Gun", function(player)
	adjust(player, "gold_gun", -1)
end)

removal("Guardian's Heart", function(player)
	adjust(player, "maxshield", -60)
	-- player:set("shield", math.min(player:get("shield"), player:get("maxshield"), 0))
end)

removal("Harvester's Scythe", function(player)
	adjust(player, "scythe", -1)
	adjust(player, "critical_chance", -5)
end)

removal("Hopoo Feather", function(player)
	adjust(player, "feather", -1)
end)

removal("Infusion", function(player, count)
	adjust(player, "hp_after_kill", -1)
	if (count) == 0 then
		player:set("hud_health_color", Color.fromHex(0x88D367).gml)
	end
end)

removal("Leeching Seed", function(player)
	adjust(player, "lifesteal", -1)
end)

removal("Panic Mines", function(player)
	adjust(player, "mine", -1)
end)

removal("Predatory Instincts", function(player)
	adjust(player, "critical_chance", -5)
	adjust(player, "wolfblood", -1)
end)

removal("Prison Shackles", function(player)
	adjust(player, "slow_on_hit", -1)
end)

removal("Red Whip", function(player)
	adjust(player, "redwhip", -1)
end)

-- Not an optimal solution, but the base game is fucked so
removal("Rusty Jetpack", function(player, count)
	player:set("pVmax", math.min(3 + count * 0.2, 6))
	player:set("pGravity2", math.max(0.22 - count * 0.05, 0.1))
end)

removal("Smart Shopper", function(player)
	adjust(player, "purse", -1)
end)

removal("Time Keeper's Secret", function(player)
	adjust(player, "hourglass", -1)
	-- Picking up the item does more than this, but this will do
end)

removal("Tough Times", function(player)
	adjust(player, "armor", -14)
end)

local poison = Object.find("EfPoison", "vanilla")
removal("Toxic Centipede", function(player, count)
	for _, v in ipairs(poison:findMatching("parent", player.id)) do
		if count == 0 then v:destroy() else v:set("coeff", v:get("coeff") - 0.5) end
	end
end)

removal("Ukulele", function(player)
	adjust(player, "lightning", -1)
end)

removal("Will-O'-the-Wisp", function(player)
	adjust(player, "lava_pillar", -1)
end)
