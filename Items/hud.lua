-- Ocular HUD

local item = Item("Ocular HUD")
item.pickupText = "Gain 100% Critical Strike Chance for 8 seconds."
item.sprite = Sprite.load("Items/resources/hud.png", 2, 14, 13)
item.isUseItem = true
item.useCooldown = 60
item:setTier("use")

ItemPool.find("enigma", "vanilla"):add(item) -- Enigma

-- Buff
local critBuff = Buff.new("Full Crit")
critBuff.sprite = Sprite.load("Items/resources/hudBuff.png", 1, 6, 4)
local sndStart = Sound.load("Items/resources/hudStart.ogg")
local sndLoop = Sound.load("Items/resources/hudLoop.ogg")
local sndEnd = Sound.load("Items/resources/hudEnd.ogg")

local hudFX = ParticleType.new("HUDParticles")
hudFX:life(5, 5)
hudFX:alpha(0.25)
hudFX:additive(true)

critBuff:addCallback("start", function(player)
	player:set("critical_chance", player:get("critical_chance") + 100)
	sndStart:play(0.9 + math.random() * 0.2)
end)
critBuff:addCallback("step", function(player)
	if not sndLoop:isPlaying() then
		sndLoop:play(0.9 + math.random() * 0.3, 0.5)
	end
	hudFX:sprite(player.sprite, false, false, true)
	hudFX:scale(math.random(0.8, 1.2) * player.xscale, math.random(0.8, 1.2) * player.yscale)
	hudFX:burst("above", player.x, player.y, 1, Color.RED)
end)
critBuff:addCallback("end", function(player)
	sndLoop:stop()
	player:set("critical_chance", player:get("critical_chance") - 100)
	sndEnd:play(0.9 + math.random() * 0.2)
end)

-- Use
item:addCallback("use", function(player, embryo)
	if embryo then
		player:applyBuff(critBuff, 8 * 60 * 2)
	else
		player:applyBuff(critBuff, 8 * 60)
	end
end)

-- Item Log
item:setLog{
	group = "use",
	description = "Gain &y&+100% Critical Strike Chance&!& for 8 seconds.",
	story = "I wish you hadn't asked me for help. I was contacted by [REDACTED] and they explained... well, some things. Using their instructions, I was able to design this interface for prolonged exactness. The beauty of it all is that it will compound with any previous precision enhancing tools. Digital plus optical is the way to go.\n\nWhile I still don't know everything, I feel like I'm already in too deep. You won't hear from me anymore after this.",
	destination = "Greivenkamp,\n5th Houston St,\nPrism Tower,\nEarth",
	date = "9/06/2056",
	priority = "&y&MILITARY&!&"
}
