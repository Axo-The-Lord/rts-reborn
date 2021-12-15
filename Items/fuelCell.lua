-- Fuel Cell

local item = Item("Fuel Cell")
item.pickupText = "Hold another Use Item charge. Reduce Use Item cooldown."
item.sprite = Sprite.load("Items/resources/fuelCell.png", 1, 10, 11)
item:setTier("uncommon")

-- I hate how the original RTS was organized it means I have no idea where anything is stored

-- Item Log
item:setLog{
	group = "uncommon",
	description = "Hold an &b&additional Use Item charge&!&&lt&(+1 per stack)&!&. &b&Reduce Use Item cooldown&!& by &b&15%&!&&lt&(+15% per stack)&!&.",
	story = "\"As humanity began to venture out into the depths of space, high-energy but low-volume fuel sources became critical for interplanetary travel. Stability came later.\"\n\n-Brief History of Interplanetary Advances, Vol.2",
	destination = "Some Place", -- Add Destination!
	date = "Some Date", -- add Date!
	priority = "&g&Standard&!&"
}

-- Tab Menu
callback.register("postLoad", function()
  if modloader.checkMod("Starstorm") then
    TabMenu.setItemInfo(item, nil, "Add 1 charge to your equipment and decrease cooldown by 15%.", "+1 charge, +15% cooldown reduction.")
  end
end)
