-- Rose Buckler

local item = Item("Rose Buckler")
item.pickupText = "Reduce incoming damage after moving for some time."
item.sprite = Sprite.load("Items/resources/roseBuckler.png", 1, 16, 16) -- 11, 12 (I DIDN'T CHANGE THE CANVAS SIZE AAAAAA)
item:setTier("uncommon")

local armorBuff = Buff.new("shield2")
local sound = Sound.find("Crit", "vanilla")
armorBuff.sprite = Sprite.find("Buffs", "vanilla")
armorBuff.subimage = 9
armorBuff.frameSpeed = 0

armorBuff:addCallback("start", function(player)
  sound:play(0.6, 1)
  player:set("armor", player:get("armor") + (30 * player:countItem(item)))
end)
armorBuff:addCallback("end", function(player)
  player:set("armor", player:get("armor") - (30 * player:countItem(item)))
end)

-- A timer
callback.register("onPlayerInit", function(player)
  player:set("bucklerTimer", 0)
end)

callback.register("onPlayerStep", function(player)
  if player:countItem(item) > 0 then
    if (player:get("moveLeft") == 1 or player:get("moveRight") == 1) and math.abs(player:get("pHspeed")) > 0 then
      player:set("bucklerTimer", player:get("bucklerTimer") + 1)
    else
      player:set("bucklerTimer", 0)
    end
    if player:get("bucklerTimer") >= 90 then
      player:applyBuff(armorBuff, 5)
    end
  end
end)

-- Item Log
item:setLog{
  group = "uncommon",
	description = "&g&Increase armor&!& by &g&30&!&&lt&(+30 per stack)&!&&b&after moving&!& for &b&1.5 seconds&!&.",
	story = "BTW Mama should have sent over another package as well. Let me know when you get it.\n\nPapa",
	destination = "Research Center,\nPolarity Zone,\nNeptune",
	date = "05/22/2056",
	priority = "&g&Priority&!&"
}
