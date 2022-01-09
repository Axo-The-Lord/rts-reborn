-- Armor-Piercing Rounds

local item = Item("Armor-Piercing Rounds")
item.pickupText = "Deal extra damage to bosses."
item.sprite = Sprite.load("Items/resources/aprounds.png", 1, 12, 13)
item:setTier("common")

callback.register("onHit", function(damager, actor, x, y)
	local parent = damager:getParent()
	if isa(parent, "PlayerInstance") then
		local stack = parent:countItem(item)
		if stack > 0 and actor:isBoss() then
			local damageBonus = parent:get("damage") * 0.2 * stack
			damager:set("damage", parent:get("damage") + damageBonus)
			if misc.getOption("video.show_damage") == true then
				misc.damage(damageBonus, actor.x, actor.y, false, Color.ORANGE)
			end
		end
	end
end)

-- Item Log
item:setLog{
	group = "common",
	description = "Deal an additional &y&20%&!& damage to bosses.",
	story = "Alright, just to clarify, these rounds aren’t faulty. Heck, I\'d say they\'re better than the standard, but... that\'s kind of the problem. I don\'t know if it was a new shipment of materials, or a problem with the assembly line, but these rounds are supposed to pierce armor. Not pierce through the armor, five feet of reinforced concrete, a few warehouses, and an armored truck.\n\nCould you guys look into this so we don\'t like, violate any Geneva Conventions or anything?",
	destination = "Fort Margaret,\nJonesworth System",
	date = "3/07/2056",
	priority = "Standard"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, nil, "Deal 20% extra damage to bosses.", "+20% damage.")
end
