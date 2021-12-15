-- Jade Elephant

local item = Item("Jade Elephant")
item.pickupText = "Gain massive armor for 5 seconds."
item.sprite = Sprite.load("Items/resources/elephant.png", 2, 14, 13)
item.isUseItem = true
item.useCooldown = 45
item:setTier("use")

ItemPool.find("enigma", "vanilla"):add(item) -- Enigma

-- Buff
local armorBuff = Buff.new("Elephant Armor Boost")
armorBuff.sprite = Sprite.load("Items/resources/elephantBuff.png", 1, 5.5, 4)
local sound = Sound.load("Items/resources/elephant.ogg")

armorBuff:addCallback("start", function(player)
	player:set("armor", player:get("armor") + 500)
end)
armorBuff:addCallback("end", function(player)
	player:set("armor", player:get("armor") - 500)
end)

-- Use
item:addCallback("use", function(player, embryo)
	sound:play(0.9 + math.random() * 0.2, 1)
	misc.shakeScreen(60)
	if embryo then
		player:applyBuff(armorBuff, 7.5 * 60)
	else
		player:applyBuff(armorBuff, 5 * 60)
	end
end)

-- Item Log
item:setLog{
	group = "use",
	description = "Gain &y&500 armor&!& for &b&5 seconds&!&.",
	story = "Excerpt from the folk tale \"Clean as Jade\":\n\n\"... and while the peasants braced for the advancement of the Emperor’s army, the stone carver finished her last strike on the giant sculpture. The clang of the flat tool against the beautiful, translucent green sheen of the solid surface echoed through the trees and around all the villagers. Their souls were cleansed and made whole by the heavenly stone, now formed into the imposing presence of an elephant.\n\nDetermination and resolve had essentially been carved into the very spirit of the ones, who, just moments ago were clutching their farming implements and make-shift weapons with trembling hands. The attack was repelled that day. The Emperor’s army told stories about their metal weapons bouncing off the cloth of commoners. This inspiring encounter spread to other villages and...\"",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = "&y&Fragile&!&"
}
