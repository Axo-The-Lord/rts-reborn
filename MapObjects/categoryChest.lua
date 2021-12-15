-- Category Chests

local itemPools = {
  damage = ItemPool.new("SpecialtyDamage"),
  healing = ItemPool.new("SpecialtyHealing"),
  util = ItemPool.new("SpecialtyUtil")
}

local sprites = {
  mask = Sprite.load("MapObjects/resources/categoryChestMask", 1, 20, 16),
  damage = Sprite.load("specialtyChest1", "MapObjects/resources/categoryChestDamage", 8, 20, 16),
  healing = Sprite.load("specialtyChest2", "MapObjects/resources/categoryChestHealing", 8, 20, 16),
  utility = Sprite.load("specialtyChest3", "MapObjects/resources/categoryChestUtility", 8, 20, 16)
}

local SyncChest = net.Packet.new("Sync Category Chest", function(player, x, y, item)
  local i = Item.find(item)
  if i then
    i:create(x, y)
  end
end)

local openSnd = Sound.find("Chest1", "vanilla")
local command = Artifact.find("Command", "vanilla")

local damage = itemPools.damage
damage.ignoreLocks = false
damage.weighted = true
-- Common
damage:add(Item.find("Barbed Wire", "vanilla"))
damage:add(Item.find("Bundle of Fireworks", "vanilla"))
damage:add(Item.find("Crowbar", "vanilla"))
damage:add(Item.find("Fire Shield", "vanilla"))
damage:add(Item.find("Gasoline", "vanilla"))
damage:add(Item.find("Headstompers", "vanilla"))
damage:add(Item.find("Lens Maker's Glasses", "vanilla"))
damage:add(Item.find("Mortar Tube", "vanilla"))
damage:add(Item.find("Rusty Blade", "vanilla"))
damage:add(Item.find("Snake Eyes", "vanilla"))
damage:add(Item.find("Soldier's Syringe", "vanilla"))
damage:add(Item.find("Sticky Bomb", "vanilla"))
damage:add(Item.find("Warbanner", "vanilla"))
-- Uncommon
damage:add(Item.find("Arms Race", "vanilla"))
damage:add(Item.find("AtG Missile Mk. 1", "vanilla"))
damage:add(Item.find("Chargefield Generator", "vanilla"))
damage:add(Item.find("Dead Man's Foot", "vanilla"))
damage:add(Item.find("Energy Cell", "vanilla"))
damage:add(Item.find("Frost Relic", "vanilla"))
damage:add(Item.find("Golden Gun", "vanilla"))
damage:add(Item.find("Panic Mines", "vanilla"))
damage:add(Item.find("Predatory Instincts", "vanilla"))
damage:add(Item.find("Toxic Centipede", "vanilla"))
damage:add(Item.find("Ukulele", "vanilla"))
damage:add(Item.find("Will-o'-the-wisp", "vanilla"))
-- Rare
damage:add(Item.find("AtG Missile Mk. 2", "vanilla"))
damage:add(Item.find("Brilliant Behemoth", "vanilla"))
damage:add(Item.find("Ceremonial Dagger", "vanilla"))
damage:add(Item.find("Fireman's Boots", "vanilla"))
damage:add(Item.find("Heaven Cracker", "vanilla"))
damage:add(Item.find("Hyper-Threader", "vanilla"))
damage:add(Item.find("Laser Turbine", "vanilla"))
damage:add(Item.find("Plasma Chain", "vanilla"))
damage:add(Item.find("Shattering Justice", "vanilla"))
damage:add(Item.find("Happiest Mask", "vanilla"))
damage:add(Item.find("Telescopic Sight", "vanilla"))
damage:add(Item.find("Tesla Coil", "vanilla"))
damage:add(Item.find("The Hit List", "vanilla"))
damage:add(Item.find("The Ol' Lopper", "vanilla"))
-- Starstorm
callback.register("postLoad", function()
  if modloader.checkMod("Starstorm") then
    damage:add(Item.find("Detritive Trematode", "Starstorm"))
    damage:add(Item.find("Armed Backpack", "Starstorm"))
    damage:add(Item.find("Brass Knuckles", "Starstorm"))
    damage:add(Item.find("Fork", "Starstorm"))
    damage:add(Item.find("Malice", "Starstorm"))
    damage:add(Item.find("Needles", "Starstorm"))
    damage:add(Item.find("Strange Can", "Starstorm"))
    damage:add(Item.find("Poisonous Gland", "Starstorm"))
    damage:add(Item.find("Hunter's Sigil", "Starstorm"))
    damage:add(Item.find("Cryptic Source", "Starstorm"))
    damage:add(Item.find("Man-o'-war", "Starstorm"))
    damage:add(Item.find("Green Chocolate", "Starstorm"))
    damage:add(Item.find("Erratic Gadget", "Starstorm"))
    damage:add(Item.find("Bane Flask", "Starstorm"))
    damage:add(Item.find("Galvanic Core", "Starstorm"))
    damage:add(Item.find("Insecticide", "Starstorm"))
    damage:add(Item.find("Juddering Egg", "Starstorm"))
  end
end)

local specialtyDamage = MapObject.new({
  name = "Category Chest - Damage",
  sprite = sprites.damage,
  baseCost = 30,
  currency = "gold",
  costIncrease = 0,
  affectedByDirector = true,
  affectPurchases = true,
  mask = sprites.mask,
  useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to purchase Damage Chest&!&&y&($&$&)&!&",
  activeText = "&y& $&$& &!&",
  maxUses = 1,
  triggerFireworks = true
})
-----------------------------------
local healing = itemPools.healing
healing.ignoreLocks = false
healing.weighted = true
-- Common
healing:add(Item.find("Bitter Root", "vanilla"))
healing:add(Item.find("Bustling Fungus", "vanilla"))
healing:add(Item.find("First Aid Kit", "vanilla"))
healing:add(Item.find("Meat Nugget", "vanilla"))
healing:add(Item.find("Monster Tooth", "vanilla"))
healing:add(Item.find("Mysterious Vial", "vanilla"))
healing:add(Item.find("Sprouting Egg", "vanilla"))
-- Uncommon
healing:add(Item.find("Guardian's Heart", "vanilla"))
healing:add(Item.find("Harvester's Scythe", "vanilla"))
healing:add(Item.find("Infusion", "vanilla"))
healing:add(Item.find("Leeching Seed", "vanilla"))
-- Rare
healing:add(Item.find("Interstellar Desk Plant", "vanilla"))
healing:add(Item.find("Repulsion Armor", "vanilla"))
-- Starstorm
callback.register("postLoad", function()
  if modloader.checkMod("Starstorm") then
    healing:add(Item.find("Dormant Fungus", "Starstorm"))
    healing:add(Item.find("Distinctive Stick", "Starstorm"))
    healing:add(Item.find("Wonder Herbs", "Starstorm"))
    healing:add(Item.find("Gold Medal", "Starstorm"))
  end
end)

local specialtyHealing = MapObject.new({
  name = "Category Chest - Healing",
  sprite = sprites.healing,
  baseCost = 30,
  currency = "gold",
  costIncrease = 0,
  affectedByDirector = true,
  affectPurchases = true,
  mask = sprites.mask,
  useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to purchase Healing Chest&!&&y&($&$&)&!&",
  activeText = "&y& $&$& &!&",
  maxUses = 1,
  triggerFireworks = true
})
-----------------------------------
local util = itemPools.util
util.ignoreLocks = false
util.weighted = true
-- Common
util:add(Item.find("Hermit's Scarf", "vanilla"))
util:add(Item.find("Life Savings", "vanilla"))
util:add(Item.find("Paul's Goat Hoof", "vanilla"))
util:add(Item.find("Spikestrip", "vanilla"))
util:add(Item.find("Taser", "vanilla"))
util:add(Item.find("Warbanner", "vanilla"))
-- Uncommon
util:add(Item.find("56 Leaf Clover", "vanilla"))
util:add(Item.find("Boxing Gloves", "vanilla"))
util:add(Item.find("Concussion Grenade", "vanilla"))
util:add(Item.find("Filial Imprinting", "vanilla"))
util:add(Item.find("Hopoo Feather", "vanilla"))
util:add(Item.find("Prison Shackles", "vanilla"))
util:add(Item.find("Infusion", "vanilla"))
util:add(Item.find("Red Whip", "vanilla"))
util:add(Item.find("Rusty Jetpack", "vanilla"))
util:add(Item.find("Smart Shopper", "vanilla"))
util:add(Item.find("Time Keeper's Secret", "vanilla"))
util:add(Item.find("Tough Times", "vanilla"))
-- Rare
util:add(Item.find("Alien Head", "vanilla"))
util:add(Item.find("Ancient Scepter", "vanilla"))
util:add(Item.find("Beating Embryo", "vanilla"))
util:add(Item.find("Dio's Friend", "vanilla"))
util:add(Item.find("Happiest Mask", "vanilla"))
util:add(Item.find("Old Box", "vanilla"))
util:add(Item.find("Permafrost", "vanilla"))
util:add(Item.find("Photon Jetpack", "vanilla"))
util:add(Item.find("Rapid Mitosis", "vanilla"))
util:add(Item.find("Thallium", "vanilla"))
util:add(Item.find("Wicked Ring", "vanilla"))
-- Starstorm
callback.register("postLoad", function()
  if modloader.checkMod("Starstorm") then
    util:add(Item.find("Diary", "Starstorm"))
    util:add(Item.find("Ice Tool", "Starstorm"))
    util:add(Item.find("Molten Coin", "Starstorm"))
    util:add(Item.find("Coffee Bag", "Starstorm"))
    util:add(Item.find("Guarding Amulet", "Starstorm"))
    util:add(Item.find("X-4 Stimulant", "Starstorm"))
    util:add(Item.find("Broken Blood Tester", "Starstorm"))
    util:add(Item.find("Balloon", "Starstorm"))
    util:add(Item.find("Prototype Jet Boots", "Starstorm"))
    util:add(Item.find("Roulette", "Starstorm"))
    util:add(Item.find("Crowning Valiance", "Starstorm"))
    util:add(Item.find("Metachronic Trinket", "Starstorm"))
    util:add(Item.find("Hottest Sauce", "Starstorm"))
    util:add(Item.find("Low Quality Speakers", "Starstorm"))
    util:add(Item.find("Field Accelerator", "Starstorm"))
    util:add(Item.find("Vaccine", "Starstorm"))
    util:add(Item.find("Nkota's Heritage", "Starstorm"))
    util:add(Item.find("Droid Head", "Starstorm"))
    util:add(Item.find("Baby's Toys", "Starstorm"))
    util:add(Item.find("Composite Injector", "Starstorm"))
    util:add(Item.find("Swift Skateboard", "Starstorm"))
    util:add(Item.find("Portable Reactor", "Starstorm"))
  end
end)

local specialtyUtil = MapObject.new({
  name = "Category Chest - Utility",
  sprite = sprites.utility,
  baseCost = 30,
  currency = "gold",
  costIncrease = 0,
  affectedByDirector = true,
  affectPurchases = true,
  mask = sprites.mask,
  useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to purchase Utility Chest&!&&y&($&$&)&!&",
  activeText = "&y& $&$& &!&",
  maxUses = 1,
  triggerFireworks = true
})

for _, pool in ipairs(itemPools) do
  for _, item in ipairs(pool:toList()) do
    local weight = 1
    if item.color == "w" then
      weight = 0
    elseif item.color == "g" then
      weight = 0.75
    elseif item.color == "r" then
      weight = 0.95
    end
    pool:setWeight(item, weight)
  end
end

callback.register("onObjectActivated", function(objectInstance, frame, player, x, y)
  if objectInstance:getObject() == specialtyDamage or objectInstance:getObject() == specialtyHealing or objectInstance:getObject() == specialtyUtil then
    if frame == 1 then
      openSnd:play(0.8 + math.random() * 0.2)
      misc.shakeScreen(5)
    elseif frame == 7 then
      local pool
      if objectInstance:getObject() == specialtyDamage then
        pool = damage
      elseif objectInstance:getObject() == specialtyHealing then
        pool = healing
      elseif objectInstance:getObject() == specialtyUtil then
        pool = util
      end
      if net.host then
        local item = pool:roll()
        item:create(objectInstance.x, objectInstance.y - (2*objectInstance.sprite.height))
        if net.online then
          SyncChest:sendAsHost("all", nil, objectInstance.x, objectInstance.y - (2*objectInstance.sprite.height), item:getObject():getName())
        end
      end
    end
  end
end)
callback.register("onObjectFailure", function(objectInstance, player)
  if objectInstance:getObject() == specialtyDamage or objectInstance:getObject() == specialtyHealing or objectInstance:getObject() == specialtyUtil then
    Sound.find("Error", "vanilla"):play(1)
  end
end)

local damageCard = Interactable.new(specialtyDamage, "specialtyDamage")
damageCard.spawnCost = 65

local healingCard = Interactable.new(specialtyHealing, "specialtyHealing")
healingCard.spawnCost = 65

local utilCard = Interactable.new(specialtyUtil, "specialtyUtil")
utilCard.spawnCost = 65

for _, stage in ipairs(Stage.findAll("vanilla")) do
  stage.interactables:add(damageCard)
  stage.interactables:add(healingCard)
  stage.interactables:add(utilCard)
end
if modloader.checkMod("Starstorm") then
  for _, ss_stage in ipairs(Stage.findAll("Starstorm")) do
    ss_stage.interactables:add(damageCard)
    ss_stage.interactables:add(healingCard)
    ss_stage.interactables:add(utilCard)
  end
end
