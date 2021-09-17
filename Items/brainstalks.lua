-- Brainstalks

local item = Item("Brainstalks")
item.pickupText = "Skills have NO cooldowns for a short period after killing an elite."
item.sprite = Sprite.load("Items/resources/brainstalks.png", 1, 12, 16)
item:setTier("rare")

-- Buff
local brainBuff = Buff.new("No Cooldowns")
brainBuff.sprite = Sprite.load("Items/resources/brainstalksBuff", 1, 6, 7)

brainBuff:addCallback("step", function(player)
  for i = 2, 5 do
    if player:getAlarm(i) > 30 then
      player:setAlarm(i, 30)
    end
  end
end)

-- Thanks again Neik
callback.register("onDraw", function()
  local player = net.localPlayer or misc.players[1]
  if player:hasBuff(brainBuff) then
    graphics.alpha(0.2)
    graphics.color(Color.fromHex(0xE041FF))
    local x, y, w, h = camera.x, camera.y, camera.width, camera.height
    graphics.rectangle(x, y, x + w, y + h, false)
  end
end)

callback.register("onNPCDeathProc", function(npc, player)
  local stack = player:countItem(item)
  if stack > 0 then
    if npc:get("prefix_type") > 0 then
      player:applyBuff(brainBuff, (4 * 60) * stack)
    end
  end
end)

-- Item Log
item:setLog{
  group = "rare",
	description = "Upon killing an elite monster, &y&enter a frenzy&!& for &y&4s&!&&lt&(+4s per stack)&!&where &b&skills have 0.5s cooldowns&!&.",
	story = "Contained in this shipment should be a variety of biopsy samples from our late Mr. Jefferson. As you know, he was an extraordinary man in almost any manner. He was athletic, brilliant, kind, funny, and an all-around great human specimen.\n\nHe donated his body to science, and as we began the operation we found a most terrifying discovery.\n\nA quick visual examination of the subject\'s brain shows a very… particular oddity. It seems to be housing a variety of… glowing brain \"stalks\", similar to tubeworms. Trying to biopsy the stalks is impossible - they seem to disintegrate into dust the moment we remove it from the brain. We cannot explain this oddity at all. As such, we have included the entire brain in this shipment.\n\nPlease let us know if you find any explanation.",
	destination = "Saura Cosmo,\nBeacon Post,\n???",
	date = "11/11/2056",
	priority = "&r&High Priority/Biological&!&"
}
