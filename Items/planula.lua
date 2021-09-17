-- Planula

local item = Item("Planula")
item.pickupText = "Receive flat healing when attacked."
item.sprite = Sprite.load("Items/resources/planula.png", 1, 12, 15)
--[[ if modloader.checkMod("Starstorm") then
  ItemPool.find("legendary", "Starstorm"):add(item)
end ]]--

callback.register("onDamage", function(hit)
  if isa(hit, "PlayerInstance") then
    local player = hit -- This...
    local stack = player:countItem(item)
    local healValue = 15 * stack
    player:set("hp", player:get("hp") + healValue)
    if misc.getOption("video.show_damage") == true then -- Damage numbers
      misc.damage(healValue, player.x, player.y - 4, false, Color.DAMAGE_HEAL)
    end
  end
end)

-- Item Log
item:setLog{
  group = "boss",
	description = "Heal from &y&incoming damage&!& for &g&15&!&&lt&(+15 per stack)&!&.",
	story = "\"Yes - the egg. The grandparent incubates the eggs.\"\n\n\"And the child?\"\n\n\"The child lays the egg.\"\n\n\"And the egg becomes the...?\"\n\n\"The parent.\"\n\n\"Okay. And the parent does what?\"\n\n\"Takes care of the children - and the grandparent.\"\n\n\"And the grandparent is the youngest?\"\n\n\"Younger than the child, yes. But not the youngest.\"\n\n\"Who is the youngest?\"\n\n\"The parent.\"\n\n\"...\"",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = "&b&Field-Found&!&"
}
