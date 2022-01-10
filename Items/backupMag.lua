-- Backup Magazine

local item = Item("Backup Magazine")
item.pickupText = "Add another charge of your 2nd skill."
item.sprite = Sprite.load("Items/resources/backupMag.png", 1, 11, 12)
item:setTier("common")

item:addCallback("pickup", function(player)
    Ability.addCharge(player, "x", 1)
end)

-- Item Log
item:setLog{
	group = "common",
	description = "Add &b&1&!&&lt&(+1 per stack)&!& charge of your &b&second skill&!&.",
	story = "- Billed to: Captain [REDACTED]\n\n- Note from Sender: You going on a hunting trip or something? I\'ve never seen anyone order this much ammo before...",
	destination = "Cargo Bay 10-C,\nTerminal 504-B,\nUES Port Trailing Comet",
	date = "10/05/2056",
	priority = "Priority"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
    TabMenu.setItemInfo(item, nil, "Add 1 charge to your second skill.", "+1 charge.")
end
