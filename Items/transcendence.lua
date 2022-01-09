-- Transcendence

local item = Item("Transcendence")
item.pickupText = "Convert all your health into shield. Increase maximum health."
item.sprite = Sprite.load("Items/resources/bug.png", 1, 10, 14)
Lunar.addItem(item)
item.color = LunarColor

local bugIcon = Sprite.load("Items/resources/bugDisplay", 1, 7, 11)

-- Draw
callback.register("onPlayerDraw", function(player)
	if player:countItem(item) > 0 then
		if player:get("shield") > 0 then
			graphics.drawImage{
				image = bugIcon,
				x = player.x,
				y = player.y - (player.sprite.height / 2),
				alpha = 0.5,
			}
		end
	end
end)

-- Pickup
item:addCallback("pickup", function(player)
		local playerAc = player:getAccessor()
	local shieldBonus = playerAc.maxhp_base * 1.5
	playerAc.percent_hp = 1 / playerAc.maxhp_base
	if player:countItem(item) > 1 then
		shieldBonus = playerAc.maxhp_base / 4
	end
		playerAc.maxshield = playerAc.maxshield + shieldBonus
		playerAc.shield = playerAc.maxshield
		playerAc.shield_cooldown = 7 * 60
end)

callback.register("onPlayerStep", function(player)
	if player:countItem(item) > 0 then
		if player:get("maxhp") > 1 then
			player:getData().trueMaxHP = (player:getData().trueMaxHP or 0) + player:get("maxhp")
			player:set("maxshield", player:get("maxshield") + ((player:get("maxhp") - 1) * 1.5))
			player:set("shield", player:get("maxshield"))
			player:set("maxhp_base", 1)
		end
	elseif player:getData().trueMaxHP then
		player:set("maxhp_base", player:getData().trueMaxHP)
		player:getData().trueMaxHP = nil
	end
end)

-- Item Log
item:setLog{
	group = "end",
	description = "&g&convert&!& all but &g&1 health&!& into &b&regenerating shields&!&. &g&Gain 50%&!&&lt&(+25% per stack)&!&&g&maximum health&!&.",
	story = "You are trying your best to survive. You consider yourself a fast learner. You have been feeling lucky. You have been experiencing feelings of deja vu. If you understand, do not read the next paragraph.\n\nYou are taking control of your own beliefs. You feel familiar in unfamiliar environments. You have been gaining an intuition for experiences you've never had. You ponder a past life. If you understand, do not read the next paragraph.\n\nYou find yourself searching for things that never have been. You miss things you have never had. You play characters that have never lived. You have been experiencing feelings of deja vu. If you understand, do not read the next paragraph.\n\nYou have revealed my hand. Because you have consumed this information, the [observers] will now consume it in time. If you are reading this paragraph, I will be long dead, but in turn you have freed me. I will no longer exist in my universe. There will be no proof that I ever was - but I exist now in yours. I have escaped my suffering. Keep me safe. I hope you do not understand.",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = colorString("Unaccounted For", LunarColor)
}
