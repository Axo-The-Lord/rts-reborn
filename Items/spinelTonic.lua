-- Spinel Tonic

local item = Item("Spinel Tonic")
item.pickupText = "Gain a massive boost to ALL stats. Chance to gain an affliction that reduces ALL stats."
item.sprite = Sprite.load("Items/resources/tonic.png", 2, 9, 14)
item.isUseItem = true
item.useCooldown = 60
Lunar.addItem(item)
item.color = LunarColor

-- Tonic Affliction

local affliction = Item("Tonic Affliction")
affliction.pickupText = "Reduce ALL stats when not under the effects of Spinel Tonic."
affliction.sprite = Sprite.load("Items/resources/tonicAffliction.png", 1, 11, 13)
affliction.color = Color.BLACK

affliction:addCallback("pickup", function(player)
  local playerAc = player:getAccessor() -- Thanks Marks!!
  local afflictionStack = player:countItem(affliction)
  local afflictionBonus = 1 - 0.95 ^ afflictionStack
  player:getData().afflictionMod = -- ???
  playerAc.damage = playerAc.damage - (playerAc.damage * afflictionBonus)
  playerAc.attack_speed = playerAc.attack_speed - (playerAc.attack_speed * afflictionBonus)
  playerAc.armor = playerAc.armor - (playerAc.armor * afflictionBonus)
  playerAc.percent_hp = playerAc.percent_hp - (playerAc.percent_hp * (1 - 1 / (1 + 0.1 * afflictionStack)))
  playerAc.hp_regen = playerAc.hp_regen - (playerAc.hp_regen * afflictionBonus)
  playerAc.pHmax = playerAc.pHmax - (playerAc.pHmax * afflictionBonus)
end)

-- Buff
local tonicBuff = Buff.new("Tonic Buff")
tonicBuff.sprite = Sprite.load("Items/resources/tonicBuff.png", 1, 4, 6)

tonicBuff:addCallback("start", function(player)
  local playerAc = player:getAccessor()
  local afflictionStack = player:countItem(affliction)
  local afflictionBonus = player:getData().afflictionMod
  playerAc.damage = (playerAc.damage + (playerAc.damage * afflictionBonus)) * 2
  playerAc.attack_speed = (playerAc.attack_speed + (playerAc.attack_speed * afflictionBonus)) * 1.7
  playerAc.armor = (playerAc.armor + (playerAc.armor * afflictionBonus)) + 20
  playerAc.percent_hp = (playerAc.percent_hp + (playerAc.percent_hp * (1 - 1 / (1 + 0.1 * afflictionStack)))) + 0.5
  playerAc.hp_regen = (playerAc.hp_regen + (playerAc.hp_regen * afflictionBonus)) * 3
  playerAc.pHmax = (playerAc.pHmax + (playerAc.pHmax * afflictionBonus)) * 1.3
end)
tonicBuff:addCallback("end", function(player)
  local playerAc = player:getAccessor()
  local afflictionStack = player:countItem(affliction)
  -- write removals here
  if math.chance(20) then
    player:giveItem(affliction)
    local afflictionDisplay = affliction:create(player.x + (player:get("pHspeed") * player.xscale), player.y + player:get("pVspeed"))
    afflictionDisplay:set("item_dibs", player.id)
    afflictionDisplay:set("used", 1)
  end
end)

callback.register("onDraw", function()
  local player = net.localPlayer or misc.players[1]
  if player:hasBuff(tonicBuff) then
    graphics.alpha(0.2)
    graphics.color(Color.BLUE)
    local x, y, w, h = camera.x, camera.y, camera.width, camera.height
    graphics.rectangle(x, y, x + w, y + h, false)
  end
end)

item:addCallback("use", function(player, embryo)
  if embryo then
    player:applyBuff(tonicBuff, 30 * 60)
  else
    player:applyBuff(tonicBuff, 20 * 60)
  end
end)

-- Item Log
item:setLog{
  group = "end",
	description = "Drink the Tonic, gaining a boost for 20 seconds. Increases &y&damage&!& by &y&+100%&!&. Increases &y&attack speed&!& by &y&+70%&!&. Increases &y&armor&!& by &y&+20&!&. Increases &g&maximum health&!& by &g&+50%&!&. Increases &y&passive health regeneration&!& by &y&+300%&!&. Increases &b&movespeed&!& by &b&+30%&!&.\n\nWhen the Tonic wears off, you have a &r&20%&!& chance to gain a &r&Tonic Affliction, reducing all of your stats&!& by &r&-5%&!&&lt&(-5% per stack)&!&.",
	story = "\"Reality is whatever the mind decides it to be. Take a sip of the drink, and the mind becomes malleable. From there, you can shape it into whatever form you please... and the world around you follows your example.\"\n\n- Sigibold the Drunken",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = "&b&Unaccounted For&!&"
}
