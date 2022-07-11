-- Bezerker's Pauldron

local item = Item("Bezerker\'s Pauldron")
item.pickupText = "Enter a frenzy after killing 3 enemies in quick succession."
item.sprite = Sprite.load("Items/resources/pauldron.png", 1, 13, 15)
item:setTier("uncommon")

-- Buff
local frenzy = Buff.new("War Cry")
frenzy.sprite = Sprite.load("Items/resources/frenzyBuff.png", 1, 8, 8)
local sound = Sound.load("frenzySound", "Items/resources/frenzyProc.ogg")

local frenzyFX = ParticleType.new("frenzyParticles")
frenzyFX:shape("Square")
frenzyFX:color(Color.RED)
frenzyFX:alpha(1,0)
frenzyFX:additive(true)
frenzyFX:size(0.01, 0.01, 0, 0)
frenzyFX:life(5, 15)
frenzyFX:speed(0.3, 0.5, 0, 0)
frenzyFX:direction(0, 360, 0, 1)

frenzy:addCallback("start", function(player)
	player:set("pHmax", player:get("pHmax") + 0.5)
	player:set("attack_speed", player:get("attack_speed") + 1)
end)
frenzy:addCallback("step", function(player)
	frenzyFX:burst("middle", player.x, player.y, 15)
end)
frenzy:addCallback("end", function(player)
	player:set("pHmax", player:get("pHmax") - 0.5)
	player:set("attack_speed", player:get("attack_speed") - 1)
end)

-- Timer
callback.register("onActorInit", function(actor)
	if isa(actor, "PlayerInstance") then
		actor:getData().killstreak = 0
		actor:getData().pauldron_timer = 60
	end
end)

callback.register("onNPCDeathProc", function(npc, player)
	if player:isValid() then
		player:getData().killstreak = player:getData().killstreak + 1
	end
end)

callback.register("onPlayerStep", function(player)
	local playerData = player:getData()
	local stack = player:countItem(item)
	if playerData.killstreak > 0 then
		if playerData.killstreak >= 3 and stack > 0 then
			if not sound:isPlaying() then
				sound:play(0.9 + math.random() * 0.4, 0.8)
			end
			player:applyBuff(frenzy, 6 * 60 + ((4 * 60) * (stack - 1)))
		end
		if playerData.pauldron_timer <= 0 then
			playerData.killstreak = 0
			playerData.pauldron_timer = 60
		else
			playerData.pauldron_timer = playerData.pauldron_timer - 1
		end
	end
end)

-- Item Log
item:setLog{
	group = "uncommon",
	description = "&y&Killing 3 enemies&!& within &y&1&!& second sends you into a &y&frenzy&!& for &y&6s.&!& Increases &b&movement speed&!& by &b&50%&!& and &y&attack speed&!& by &y&100%.&!&",
	story = "Another antique for the collection. This bad boy was found on the battlefield where much of the War was fought. The excavation site was littered with bones, all surrounding the remains of one rebel soldier, who was carrying this artifact. According to hearsay and rumors, rebel soldiers wearing pauldrons much like this one would enter trances on the battlefield. Time would slow down, and all they could see was the enemy.\n\nOf course, it\'s just speculation, but… There were a lot of bodies surrounding this thing’s old owner. Be careful, OK?",
	destination = "Jungle VII,\nMuseum of 2019,\nEarth",
	date = "04/05/2056",
	priority = "&g&Priority&!&"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, nil, "Killing 3 enemies within 1 second incrases movement and attack speed for 6 seconds.", "+4 seconds.")
end

-- Achievement
local unlock = Achievement.new("pauldron")
unlock.requirement = 1
unlock.deathReset = false
unlock.unlockText = "This item will now drop."
unlock.description = "Charge the teleporter with less than 10% health."
unlock.highscoreText = "\"Armor-Piercing Rounds\" Unlocked"
unlock:assignUnlockable(item)

callback.register("onPlayerStep", function(player)
	local tele = Object.find("Teleporter", "vanilla")
	if #tele:findMatchingOp("active", ">=", 2) > 0 then
		if player:get("hp") < player:get("maxhp") * 0.1 then
			unlock:increment(1)
		end
	end
end)
