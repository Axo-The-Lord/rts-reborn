-- Spinel Tonic
-- This was a nightmare

local item = Item("Spinel Tonic")
item.pickupText = "Gain a massive boost to ALL stats. Chance to gain an affliction that reduces ALL stats."
item.sprite = Sprite.load("Items/resources/spinelTonic.png", 2, 9, 14)
item.isUseItem = true
item.useCooldown = 60
Lunar.addItem(item)
item.color = LunarColor

-- Tonic Affliction

local affliction = Item("Tonic Affliction")
affliction.pickupText = "Reduce ALL stats when not under the effects of Spinel Tonic."
affliction.sprite = Sprite.load("Items/resources/spinelTonicAffliction.png", 1, 11, 13)
affliction.color = Color.BLACK

affliction:addCallback("pickup", function(player)
	local playerAc = player:getAccessor()
	local playerData = player:getData()
	local afflictionBonus = 1 - 0.95 ^ player:countItem(affliction)
	playerData.affliction_damage = playerAc.damage * afflictionBonus
	playerAc.damage = playerAc.damage - playerData.affliction_damage
	playerData.affliction_attack_speed = playerAc.attack_speed * afflictionBonus
	playerAc.attack_speed = playerAc.attack_speed - playerData.affliction_attack_speed
	playerData.affliction_armor = playerAc.armor * afflictionBonus
	playerAc.armor = playerAc.armor - playerData.affliction_armor
	playerData.affliction_hp = playerAc.percent_hp * (1 - 1 / (1 + 0.1 * player:countItem(affliction)))
	playerAc.percent_hp = playerAc.percent_hp - playerData.affliction_hp
	playerData.affliction_regen = playerAc.hp_regen * afflictionBonus
	playerAc.hp_regen = playerAc.hp_regen - playerData.affliction_regen
	playerData.affliction_pHmax = playerAc.pHmax * afflictionBonus
	playerAc.pHmax = playerAc.pHmax - playerData.affliction_pHmax
end)

-- Buff
local tonicBuff = Buff.new("Tonic Buff")
tonicBuff.sprite = Sprite.load("Items/resources/spinelTonicBuff.png", 1, 4, 6)

tonicBuff:addCallback("start", function(player)
	local playerAc = player:getAccessor()
	local playerData = player:getData()
	-- Remove the afflictions
	playerAc.damage = playerAc.damage + (playerData.affliction_damage or 0)
	playerAc.attack_speed = playerAc.attack_speed + (playerData.affliction_attack_speed or 0)
	playerAc.armor = playerAc.armor + (playerData.affliction_armor or 0)
	playerAc.percent_hp = playerAc.percent_hp + (playerData.affliction_hp or 0)
	playerAc.hp_regen = playerAc.hp_regen + (playerData.affliction_regen or 0)
	playerAc.pHmax = playerAc.pHmax + (playerData.affliction_pHmax or 0)
	-- Tonic modifiers
	playerData.tonic_damage = playerAc.damage
	playerData.tonic_attack_speed = playerAc.attack_speed * 0.7
	playerData.tonic_armor = 20
	playerData.tonic_hp = 0.5
	playerData.tonic_regen = playerAc.hp_regen * 2
	playerData.tonic_pHmax = playerAc.pHmax * 0.3
	-- Add modifier to stat
	playerAc.damage = playerAc.damage + playerData.tonic_damage
	playerAc.attack_speed = playerAc.attack_speed + playerData.tonic_attack_speed
	playerAc.armor = playerAc.armor + playerData.tonic_armor
	playerAc.percent_hp = playerAc.percent_hp + playerData.tonic_hp
	playerAc.hp_regen = playerAc.hp_regen + playerData.tonic_regen
	playerAc.pHmax = playerAc.pHmax + playerData.tonic_pHmax
end)
tonicBuff:addCallback("end", function(player)
	local playerAc = player:getAccessor()
	local playerData = player:getData()
	-- Remove the modifier
	playerAc.damage = playerAc.damage - playerData.tonic_damage
	playerAc.attack_speed = playerAc.attack_speed - playerData.tonic_attack_speed
	playerAc.armor = playerAc.armor - playerData.tonic_armor
	playerAc.percent_hp = playerAc.percent_hp - playerData.tonic_hp
	playerAc.hp_regen = playerAc.hp_regen - playerData.tonic_regen
	playerAc.pHmax = playerAc.pHmax - playerData.tonic_pHmax
	-- Add back the afflictions
	playerAc.damage = playerAc.damage - (playerData.affliction_damage or 0)
	playerAc.attack_speed = playerAc.attack_speed - (playerData.affliction_attack_speed or 0)
	playerAc.armor = playerAc.armor - (playerData.affliction_armor or 0)
	playerAc.percent_hp = playerAc.percent_hp - (playerData.affliction_hp or 0)
	playerAc.hp_regen = playerAc.hp_regen - (playerData.affliction_regen or 0)
	playerAc.pHmax = playerAc.pHmax - (playerData.affliction_pHmax or 0)
	-- Give afflictions
	if math.chance(20) then
		player:giveItem(affliction)
		local afflictionDisplay = affliction:create(player.x + (player:get("pHspeed") * player.xscale), player.y + player:get("pVspeed"))
		afflictionDisplay:set("item_dibs", player.id)
		afflictionDisplay:set("used", 1)
	end
end)

callback.register("onDraw", function()
	local player = net.localPlayer or misc.players[1]
	if player:hasBuff(tonicBuff) then
		graphics.alpha(0.2)
		graphics.color(Color.BLUE)
		local x, y, w, h = camera.x, camera.y, camera.width, camera.height
		graphics.rectangle(x, y, x + w, y + h, false)
	end
end)

item:addCallback("use", function(player, embryo)
	if embryo then
		player:applyBuff(tonicBuff, 30 * 60)
	else
		player:applyBuff(tonicBuff, 20 * 60)
	end
end)

-- Item Log
item:setLog{
	group = "end",
	--description = "Drink the Tonic, gaining a boost for 20 seconds. Increases &y&damage&!& by &y&+100%.&!& Increases &y&attack speed&!& by &y&+70%.&!& Increases &y&armor&!& by &y&+20.&!& Increases &g&maximum health&!& by &g&+50%.&!& Increases &y&passive health regeneration&!& by &y&+300%.&!& Increases &b&movespeed&!& by &b&+30%.&!& When the Tonic wears off, you have a &r&20%&!& chance to gain a &r&Tonic Affliction, reducing all of your stats&!& by &r&-5%.&!&",
	--description = "Drink the Tonic, gaining a boost for 20 seconds. See &lt&Order Details&!& for details. When the Tonic wears off, you have a &r&20%&!& chance to gain a &r&Tonic Affliction, reducing all of your stats&!& by &r&-5%.&!&",
	--description = "For 20s, increases &y&damage&!& by &y&+100%; attack speed&!& by &y&+70%; armor&!& by &y&+20;&!& &g&maxhp&!& by &g&+50%;&!& &y&passive hp regen&!& by &y&+300%;&!& &b&movespeed&!& by &b&+30%.&!& When the Tonic wears off, you have a &r&20%&!& chance to gain a &r&Tonic Affliction, reducing all of your stats&!& by &r&-5%.&!&",
	description = "For 20s, increases: damage &y&+100%;&!& attack speed &y&+70%;&!& armor &y&+20;&!& maxhp &g&+50%;&!& passive hp regen &y&+300%;&!& movespeed &b&+30%.&!",
	story = "\"Reality is whatever the mind decides it to be. Take a sip of the drink, and the mind becomes malleable. From there, you can shape it into whatever form you please... and the world around you follows your example.\"\n\n- Sigibold the Drunken\n\n\n\n\n\n[IMPORTANT] When the Tonic wears off, you have a 20% chance to gain a Tonic Affliction, reducing all of your stats by -5%.",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = colorString("Unaccounted For", LunarColor)
}
