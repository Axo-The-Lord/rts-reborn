-- Brittle Crown

local item = Item("Brittle Crown")
item.pickupText = "Gain gold on hit... BUT lose gold on getting hit."
item.sprite = Sprite.load("Items/resources/crown.png", 1, 12, 13)
Lunar.addItem(item)
item.color = LunarColor
local c = tostring(LunarColor)

local sound = Sound.find("Coin", "vanilla")

-- Lose Gold
callback.register("onDamage", function(hit, damage)
  if isa(hit, "PlayerInstance") and damage > 0 then
    local stack = hit:countItem(item)
    if stack > 0 then
      local player = hit -- Not this again!
      local goldLoss = math.ceil(damage * stack)
      if not net.online or net.localPlayer == player then
        misc.setGold(math.max(misc.getGold() - goldLoss, 0))
      end
      sound:play(0.8 * math.random() * 0.4)
      if misc.getOption("video.show_damage") then
        CreateDamageText("-"..math.round(goldLoss), player.x, player.y - 6, Color.ROR_YELLOW)
      end
    end
  end
end)

-- Gain Gold
callback.register("onHit", function(damager, actor, x, y)
  local parent = damager:getParent()
  if isa(parent, "PlayerInstance") then
    local stack = parent:countItem(item)
    if stack > 0 then
      local goldGain = 2 * stack * Difficulty.getScaling(cost)
      if math.chance(30) then
        misc.setGold(misc.getGold() + math.clamp(math.random(goldGain), 2, math.huge))
        sound:play(0.8 * math.random() * 0.4)
        if misc.getOption("video.show_damage") == true then
          CreateDamageText("+"..math.round(goldGain), parent.x, parent.y - 6, Color.ROR_YELLOW)
        end
      end
    end
  end
end)

-- Item Log
item:setLog{
	group = "end",
	description = "&b&30% chance on hit&!& to gain &b&2&!&&lt&(+2 per stack)&!&&b&gold&!&.\n&b&Scales over time.&!&\n\n&r&Lose gold&!& on taking damage equal to &r&100%&!&&lt&(+100% per stack)&!&of the &r&maximum health percentage you lost&!&.",
	story = "A wretched carnival.\n\nThey were doomed for good reason. Dunepeople of Aphelia: lost, in fanatic worship of parasitic influences. Lemurians: destined to a dead planet, picked clean. Chitin beasts. Automations of death. Why do you bring them home? They were not meant to survive.\n\nI have watched you for ages, from my dead rock - and every century, you disgust me with vanity. You invite vermin into your home. Wretches. Rats. Monsters. Creatures without restraint. Each and every one, planet killers. And yet, you entertain them as guests. Like children, requiring saving and protection.\n\nShe should have died for me. Her gift was wasted on you.\n\nAnd when will we open discussion - dear brother - of all your thin lies? Why do you forbid your guests to leave? To pilot? Why do you fashion great walls and gates? Why do you weave constructs of destruction, if your role is protection? They are entries in your collection. You slaver. Gatekeeper. Hoarder.\n\nYour death is fated. When you die - and you WILL die - I will be ready. I have been patient for millennia. That planet... is mine.",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = "&"..c.."&Unaccounted For&!&"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
  TabMenu.setItemInfo(item, nil, "30% chance to gain 2 gold on hit, but lose gold when you are hit.", "+2 gold gain, +100% gold loss.")
end
