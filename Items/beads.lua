-- Beads of Fealty

local item = Item("Beads of Fealty")
item.pickupText = "Seems to do nothing... but..."
item.sprite = Sprite.load("Items/resources/beads.png", 1, 12, 13)
Lunar.addItem(item)
item.color = LunarColor
local c = tostring(LunarColor)

-- Item Log
item:setLog{
	group = "end",
	description = "Seems to do nothing... &r&but...&!&",
	story = "The master of this world is a benevolent protector. Our savior. Despite the natures of its various inhabitants, he has made a peaceful place here.\n\nPeace comes at a cost, of course. Some things are strictly forbidden. Above all, there is one item that cannot be tolerated – to possess it is to surely perish: a strange, heavy, and deeply entrancing set of beads that seem to speak with whoever holds them.\n\nTo discover them among one’s community is to create a dark, rippling panic. It is not long after they are found that Providence, the mighty protector, appears in a thunderous instant to pursue their owner and solemnly take a life he swore to defend.\n\nIt is no physical property of the beads themselves which provoke such a drastic response - but instead, what they represent. They are a symbol, and to carry them is a dark promise to undo the world – to cast to oblivion all people who find their final place here, all in exchange for a doomed return to ruinous way. The elusive, sinister intelligence with whom these beads represent a pact seems known only to the bearer - and to Providence himself.\n\nOne thing, however, is known to anyone who has borne witness to these beads: a cruel, cackling laughter that erupts as blood and coins of favor are spilled, abruptly silenced as the beads are destroyed. Where they come from isn’t known, but should you encounter these beads you must leave them far, far behind.\n\nNever look back.",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = "&"..c.."&Unaccounted For&!&"
}

-- Tab Menu
callback.register("postLoad", function()
  if modloader.checkMod("Starstorm") then
    TabMenu.setItemInfo(item, 1, "Seems to do nothing... but...", nil)
  end
end)
