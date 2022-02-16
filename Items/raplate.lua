-- Repulsion Armor Plate

local item = Item("Repulsion Armor Plate")
item.pickupText = "Reduces all damage taken by five."
item.sprite = Sprite.load("Items/resources/armorPlate.png", 1, 12, 13)
item:setTier("common")

callback.register("onHit", function(damager,hit)
	if isa(hit, "PlayerInstance") then
		local player = hit -- This...
		local stack = player:countItem(item)
		local armorValue = 5 * stack
		damager:set("damage", math.clamp(damager:get("damage") -armorValue,1,99999999))
		damager:set("damage_fake", damager:get("damage") +math.random(-1,1))
		--return math.clamp(damage -armorValue,1,99999999)
	end
end,-1000)

-- Item Log
item:setLog{
	group = "common",
	description = "Reduce damage taken by 5 (+5 per stack).",
	story = "Luckily no one was hurt during the shootout. Just a few rough characters at the bar by the docks. Nothing we couldn’t handle. Jaime took a shot to his shoulder but his armor took all the impact. We’ll need to order him a replacement part before he can go back out in the field.\nThe segmented design is nice because I don’t have to shell out the cash for a whole new set. Frankly, the station’s coffers have seen better days. The next time a rookie damages their equipment they might be looking at a desk job for a while.",
	destination = "System Police Station 13\nPort of Marv\nGanymede",
	date = "08/15/2056"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, nil, "Reduces all damage taken by 5.", "+5 reduction.")
end
