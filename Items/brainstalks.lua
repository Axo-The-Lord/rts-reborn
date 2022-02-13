-- Brainstalks

local item = Item("Brainstalks")
item.pickupText = "Skills have NO cooldowns for a short period after killing an elite."
item.sprite = Sprite.load("Items/resources/brainstalks.png", 1, 12, 16)
item:setTier("rare")

-- Buff
local brainBuff = Buff.new("No Cooldowns")
brainBuff.sprite = Sprite.load("Items/resources/brainstalksBuff", 1, 6, 7)

-- Vignette
callback.register("onDraw", function()
	local player = net.localPlayer or misc.players[1]
	if player:hasBuff(brainBuff) then
		--local vignette = Object.find("Vignette", "rts-reborn")
		--vignette.alpha = 0.7
		--vignette.color = Color.fromHex(0xF156FB)
		--vignette:getData().rate = 0.001
		--DrawVignette(vignette)
		DrawVignetteAlt(0.7,Color.fromHex(0xF156FB))
	end
end)

-- Sparks
local spark = ParticleType.new("Sparks")
spark:sprite(Sprite.load("Items/resources/sparks.png", 8, 6, 4), true, true, false)
spark:additive(true)
spark:life(15, 15)
spark:angle(0, 360, 0, 0, false)

brainBuff:addCallback("step", function(player)
	for i = 2, 5 do
		if player:getAlarm(i) > 30 then
			player:setAlarm(i, 30)
		end
		spark:burst("below", player.x, player.y, 1, Color.PURPLE)
	end
end)

callback.register("onNPCDeathProc", function(npc, player)
	local stack = player:countItem(item)
	if stack > 0 then
		if npc:get("prefix_type") > 0 then
			player:applyBuff(brainBuff, (4 * 60) * stack)
		end
	end
end)

-- Item Log
item:setLog{
	group = "rare_locked",
	description = "Upon killing an elite monster, &y&enter a frenzy&!& for &y&4s&!& where &b&skills have 0.5s cooldowns.&!&",
	story = "Contained in this shipment should be a variety of biopsy samples from our late Mr. Jefferson. As you know, he was an extraordinary man in almost any manner. He was athletic, brilliant, kind, funny, and an all-around great human specimen.\n\nHe donated his body to science, and as we began the operation we found a most terrifying discovery.\n\nA quick visual examination of the subject\'s brain shows a very… particular oddity. It seems to be housing a variety of… glowing brain \"stalks\", similar to tubeworms. Trying to biopsy the stalks is impossible - they seem to disintegrate into dust the moment we remove it from the brain. We cannot explain this oddity at all. As such, we have included the entire brain in this shipment.\n\nPlease let us know if you find any explanation.",
	destination = "Saura Cosmo,\nBeacon Post,\n???",
	date = "11/11/2056",
	priority = "&r&High Priority/Biological&!&"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, nil, "Skills have no cooldowns for 4 seconds after killing an elite.", "+4 seconds.")
end

-- Achievement
local unlock = Achievement.new("Deicide")
unlock.requirement = 1
unlock.deathReset = false
unlock.unlockText = "This item will now drop."
callback.register("postLoad", function()
	if modloader.checkMod("Starstorm") then
		unlock.description = "Kill an elite boss on Monsoon difficulty or harder."
	else
		unlock.description = "Kill an elite boss on Monsoon difficulty."
	end
end)
unlock.highscoreText = "\"Brainstalks\" Unlocked"
unlock:assignUnlockable(item)

callback.register("onNPCDeath", function(npc, player)
	if not unlock:isComplete() then
		if modloader.checkMod("Starstorm") then
			if Difficulty.getActive() == Difficulty.find("Typhoon", "Starstorm") or Difficulty.getActive() == Difficulty.find("Monsoon", "vanilla") then
				if npc:get("prefix_type") > 0 and npc:isBoss() then
					unlock:increment(1)
				end
			end
		else
			if Difficulty.getActive() == Difficulty.find("Monsoon", "vanilla") then
				if npc:get("prefix_type") > 0 and npc:isBoss() then
					unlock:increment(1)
				end
			end
		end
	end
end)
