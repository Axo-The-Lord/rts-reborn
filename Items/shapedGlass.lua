-- Shaped Glass

local item = Item("Shaped Glass")
item.pickupText = "Double your damage... BUT halve your health."
item.sprite = Sprite.load("Items/resources/shapedGlass.png", 1, 12, 13)
Lunar.addItem(item)
item.color = LunarColor
local c = tostring(LunarColor)

item:addCallback("pickup", function(player)
  local playerAc = player:getAccessor()
  playerAc.maxhp_base = playerAc.percent_hp / 2
  playerAc.damage = playerAc.damage * 2
  playerAc.hud_health_color = Color.fromHex(0xAF74C9).gml
end)

-- Item Log
item:setLog{
	group = "end",
	description = "Increase base damage by &y&100%&!&&lt&(+100% per stack)&!&. &g&Reduce maximum health by 50%&!&&lt&(+50% per stack)&!&.",
	story = "Pairings\n\nUnstructured glass, from the heart of the [Moon]. Sung out, in ethereal wisps, over the course of 3 cycles. Pause.\n\nWe fold time into its material - twice. Our time and <his>. A cost <he> was willing us to pay. Folded and shaped, with a god\'s designs.\n\n<He> wields it, in one of many great hands. The time we injected is unfolded in <his> grasp. Outputs quicken - muscles compress twice. Twice as many intentions. Twice the ordered complexities, folded upon themselves. Loops loop back onto [?] in pairs. Time dependent functions. Pause.\n\n<He> sunders a construct into a thousand pieces.\n\nBut time is fair. Microtears begin to uncoil in pairs. Muscles begin to snap, twice as fast.  The cost of folded time. But <he> has plenty of time.",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = "&"..c.."&Unaccounted For&!&"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
  TabMenu.setItemInfo(item, 1075, "Double base damage, halve maximum health.", "+100% base damage, -50% maximum health.")
end
