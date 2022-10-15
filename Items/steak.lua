local item = Item.new("Bison Steak")
item.pickupText = "Gain 25 max health."
item.sprite = Sprite.load("Items/resources/steak.png", 1, 13, 10)
item:setTier("common")

item:addCallback("pickup", function(player)
	player:set("maxhp_base", player:get("maxhp_base") + 25)
end)


item:setLog{
	group = "common",
	description = "Increases &g&maximum health&!& by &g&25.&!&",
	story = "FOR: JOSEPH ******\nCC#: **** **** * ***\nACCT#: 102215\nQuality Saturnian Bison Meat [10lbs]\nTreated with special antibiotics to ensure exceptional growth, shelf life, and texture.",
	destination = "Sloppy Joe's Deli and Catering",
	date = "11/02/2056",
	priority = "Standard"
}
