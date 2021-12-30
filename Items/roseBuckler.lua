-- Rose Buckler

local item = Item("Rose Buckler")
item.pickupText = "Reduce incoming damage after moving for some time."
item.sprite = Sprite.load("Items/resources/roseBuckler.png", 1, 11, 12)
item:setTier("uncommon")

local armorBuff = Buff.new("Rose Buckler")
local sound = Sound.find("Crit", "vanilla")
armorBuff.sprite = Sprite.find("Buffs", "vanilla")
armorBuff.subimage = 9
armorBuff.frameSpeed = 0

armorBuff:addCallback("start", function(player)
  Object.find("EfOutline", "vanilla"):create(0, 0):set("persistent", 1):set("parent", player.id):set("rate", 0.025).blendColor = Color.fromHex(0xC7C1AF)
  player:getData().buckler_bonus = 30 * player:countItem(item)
  sound:play(0.6, 1)
  player:set("armor", player:get("armor") + player:getData().buckler_bonus)
end)
armorBuff:addCallback("end", function(player)
  player:set("armor", player:get("armor") - player:getData().buckler_bonus)
end)

-- A timer
callback.register("onPlayerInit", function(player)
  player:getData().buckler_timer = 0
end)

callback.register("onPlayerStep", function(player)
  local playerData = player:getData()
  if player:countItem(item) > 0 then
    if (player:get("moveLeft") == 1 or player:get("moveRight") == 1) and math.abs(player:get("pHspeed")) > 0 then
      playerData.buckler_timer = playerData.buckler_timer + 1
    else
      playerData.buckler_timer = 0
    end
    if playerData.buckler_timer >= 90 then
      player:applyBuff(armorBuff, 60)
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

-- Tab Menu
if modloader.checkMod("Starstorm") then
  TabMenu.setItemInfo(item, nil, "Increase armor by 30 after moving for 1.5 seconds.", "+30 armor.")
end
