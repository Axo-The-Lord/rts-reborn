-- Wake of Vultures

local item = Item("Wake of Vultures")
item.pickupText = "Temporarily steal the power of slain elites."
item.sprite = Sprite.load("Items/resources/wakeOfVultures.png", 1, 16, 12)
item:setTier("rare")

-- Buffs
local eliteIcons = Sprite.load("Items/resources/vultureIcons.png", 5, 6, 7) -- Ooo neato numbers

local blazingBuff = Buff.new("Blazing")
blazingBuff.sprite = eliteIcons
blazingBuff.subimage = 1
blazingBuff.frameSpeed = 0
blazingBuff:addCallback("start", function(player)
	player.blendColor = Color.fromHex(0xBA3D1D)
	player:set("fire_trail", player:get("fire_trail") + 1)
end)
blazingBuff:addCallback("end", function(player)
	player.blendColor = Color.WHITE
	player:set("fire_trail", player:get("fire_trail") - 1)
end)

local frenziedBuff = Buff.new("Frenzied")
frenziedBuff.sprite = eliteIcons
frenziedBuff.subimage = 2
frenziedBuff.frameSpeed = 0
frenziedBuff:addCallback("start", function(player)
	player.blendColor = Color.fromHex(0xE7F125)
	player:set("attack_speed", player:get("attack_speed") + 0.25)
	player:set("pHmax", player:get("pHmax") + 0.3)
end)
frenziedBuff:addCallback("end", function(player)
	player.blendColor = Color.WHITE
	player:set("attack_speed", player:get("attack_speed") - 0.25)
	player:set("pHmax", player:get("pHmax") - 0.3)
end)

local leechingBuff = Buff.new("Leeching")
leechingBuff.sprite = eliteIcons
leechingBuff.subimage = 3
leechingBuff.frameSpeed = 0
leechingBuff:addCallback("start", function(player)
	player.blendColor = Color.fromHex(0x46D123)
	player:set("lifesteal", player:get("lifesteal") + 50)
end)
leechingBuff:addCallback("end", function(player)
	player.blendColor = Color.WHITE
	player:set("lifesteal", player:get("lifesteal") - 50)
end)

local overloadingBuff = Buff.new("Overloading")
overloadingBuff.sprite = eliteIcons
overloadingBuff.subimage = 4
overloadingBuff.frameSpeed = 0
overloadingBuff:addCallback("start", function(player)
	player.blendColor = Color.fromHex(0x287CAE)
	player:set("lightning", player:get("lightning") + 1)
end)
overloadingBuff:addCallback("end", function(player)
	player.blendColor = Color.WHITE
	player:set("lightning", player:get("lightning") - 1)
end)

local volatileBuff = Buff.new("Volatile")
volatileBuff.sprite = eliteIcons
volatileBuff.subimage = 5
volatileBuff.frameSpeed = 0
volatileBuff:addCallback("start", function(player)
	player.blendColor = Color.fromHex(0xC25614)
	player:set("explosive_shot", player:get("explosive_shot") + 1)
end)
volatileBuff:addCallback("end", function(player)
	player.blendColor = Color.WHITE
	player:set("explosive_shot", player:get("explosive_shot") - 1)
end) -- It's a lot, I know

-- A neat little table
eliteAffixes = {
	[EliteType.find("Blazing", "vanilla")] = blazingBuff,
	[EliteType.find("Frenzied", "vanilla")] = frenziedBuff,
	[EliteType.find("Leeching", "vanilla")] = leechingBuff,
	[EliteType.find("Overloading", "vanilla")] = overloadingBuff,
	[EliteType.find("Volatile", "vanilla")] = volatileBuff
}

callback.register("onNPCDeathProc", function(npc, player)
	local stack = player:countItem(item)
	if stack > 0 then
		if npc:get("prefix_type") == 1 then
			if eliteAffixes[npc:getElite()] then
				player:applyBuff(eliteAffixes[npc:getElite()], (8 * 60) + (5 * (stack - 1)))
			end
		end
	end
end)

-- Item Log
item:setLog{
	group = "rare",
	description = "Gain the &y&power&!& of any killed elite monster for &y&8s.&!&",
	story = "\"The mind rules over its body from a fortress of bone, learning of the world around it through fleshy portals. The heart is just an extension of the body, which finds its root in your head.\"\n\nSomebody said this, I can’t remember who. Anyway, make sure to take great care of it. It’s incredibly rare.",
	destination = "Auckland,\nNew Zealand,\nEarth",
	date = "10/23/2056",
	priority = "&r&High Priority/Biological&!&"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, nil, "Gain the power of slained elites for 8 seconds.", "+5 second duration.")
end
