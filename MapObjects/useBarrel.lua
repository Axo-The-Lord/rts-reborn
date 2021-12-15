-- Equipment Barrel

local sound = Sound.load("MapObjects/resources/barrel.ogg")

local useBarrel = MapObject.new({
  name = "Equipment Barrel",
  sprite = Sprite.load("MapObjects/resources/useBarrel.png", 6, 5, 15),
  baseCost = 25,
  currency = "gold",
  affectedByDirector = true,
  costIncrease = 0,
  mask = Sprite.load("MapObjects/resources/barrelMask.png", 1, 3, 13),
  activeText = "&y& $&$& &!&", -- Nonsense, I know
  useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to open Equipment Barrel&!&&y&($&$&)&!&",
  maxUses = 1,
  triggerFireworks = true
})

callback.register("onObjectActivated", function(objectInstance, frame, player, x, y)
  if objectInstance:getObject() == useBarrel then
    if frame == 1 then
      sound:play(0.8 + math.random() * 0.2, 1.2)
    elseif frame == 5 then
      local pool = ItemPool.find("use", "vanilla")
      if Artifact.find("Command") and Artifact.find("Command").active then
        local crate = pool:getCrate():create(objectInstance.x, objectInstance.y)
      else
        if net.host then
          local item = pool:roll()
          item:create(objectInstance.x, objectInstance.y - (2 * objectInstance.sprite.height))
          if net.online then
            SyncChest:sendAsHost("all", nil, objectInstance.x, objectInstance.y - (2 * objectInstance.sprite.height), item:getObject():getName())
          end
        end
      end
    end
  end
end)
callback.register("onObjectFailure", function(objectInstance, player)
  if objectInstance:getObject() == useBarrel then
    Sound.find("Error", "vanilla"):play(1)
  end
end)

local barrelCard = Interactable.new(useBarrel, "useBarrel")
barrelCard.spawnCost = 40
for _, stage in ipairs(Stage.findAll("vanilla")) do
  stage.interactables:add(barrelCard)
end
if modloader.checkMod("Starstorm") then
  for _, ss_stage in ipairs(Stage.findAll("Starstorm")) do
    ss_stage.interactables:add(barrelCard)
  end
end
