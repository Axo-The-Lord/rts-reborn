-- Hardlight Afterburner

local item = Item("Hardlight Afterburner")
item.pickupText = "Add 2 extra charges of your 3rd skill. Reduce 3rd skill cooldown."
item.sprite = Sprite.load("Items/resources/afterburner.png", 1, 12, 15)
item:setTier("rare")

item:addCallback("pickup", function(player)
  Ability.addCharge(player, "c", 2)
  Ability.setCooldownReduction(player, "c", Ability.getCooldownReduction(player, "c") / 3)
end)

-- Item Log
item:setLog{
	group = "rare",
	description = "Add &b&2&!&&lt&(+2 per stack)&!& charges of your &b&third skill&!&. &b&Reduce third skill cooldown&!& by &b&33%&!&.",
	story = "Our \'hard light\' research has become even more refined since our last correspondence.\n\nThe initial purpose of the afterburner was to function as a primary heatsink for our bigger HL implementations - like our bridges and barriers. However, if attached to a rapidly degrading source, like those we typically dispose, we get a wonderful emission rate of semi-tachyonic particles. In other words... extremely high capacity fueling.\n\nIt should be obvious by its design, but to reiterate: stay away from the HL exhaust end when active. The emission method is violent by design, and so should be mounted to static, STABLE sources only.",
	destination = "Geshka Tower,\n33 Floor,\nMars",
	date = "12/29/2056",
	priority = "&r&High Priority/Volatile&!&"
}

-- Tab Menu
callback.register("postLoad", function()
  if modloader.checkMod("Starstorm") then
    TabMenu.setItemInfo(item, nil, "Add 2 charges of your third skill. Reduce third skill cooldown.", "+2 charges, further reduces cooldown.")
  end
end)
