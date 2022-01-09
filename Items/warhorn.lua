-- War Horn

local item = Item("War Horn")
item.pickupText = "Activating your Use Item gives you a burst of attack speed."
item.sprite = Sprite.load("Items/resources/warhorn.png", 1, 15, 11)
item:setTier("uncommon")
local procSound = Sound.load("Items/resources/warhorn.ogg")

-- Buff
local hornBuff = Buff.new("Energized")
hornBuff.sprite = Sprite.load("Items/resources/warhornBuff.png", 1, 7, 5)
local circle = Object.find("EfCircle", "vanilla")
local procAnim = {}

hornBuff:addCallback("start", function(player)
	player:set("attack_speed", player:get("attack_speed") + 0.7)
end)
hornBuff:addCallback("step", function(player)
	if procSound:isPlaying() and procAnim[player] > -1 then
		procAnim[player] = procAnim[player] - 1
		if procAnim[player] % 10 == 0 then
			circle:create(player.x, player.y)
		end
		misc.shakeScreen(1)
	end
end)
hornBuff:addCallback("end", function(player)
	player:set("attack_speed", player:get("attack_speed") - 0.7)
end)

callback.register("onUseItemUse", function(player)
	local stack = player:countItem(item)
	if stack > 0 then
		if player:getAlarm(0) > -1 then
			if not procSound:isPlaying() then
				procSound:play(0.9 + math.random() * 0.2)
				procAnim[player] = 30
			end
			player:applyBuff(hornBuff, (8 * 60) + ((4 * 60) * (stack - 1)))
		end
	end
end)

-- Item Log
item:setLog{
	group = "uncommon",
	description = "Activating your Use Item gives you &y&70% attack speed&!& for &y&8s.&!&",
	story = "\"The War of 2019, while lasting only a brief year, was the bloodiest conflict in human history. As the war got deadlier throughout the year, many rebel groups began to rely on tradition and history for inspiration.\n\nThe War Horn, pictured above was a favorite of the Northern Fist Rebellion for both its inspirational and tactical uses.\"",
	destination = "National WW19 Museum,\nJungle VII,\nEarth",
	date = "4/12/2056",
	priority = "&g&Standard&!&"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, nil, "+70% attack speed for 8 seconds when activating Use Items.", "+4 seconds.")
end
