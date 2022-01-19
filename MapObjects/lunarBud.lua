-- Lunar Bud

local sound = Sound.load("MapObjects/resources/bud.ogg")
local smoke = ParticleType.find("Dust2", "vanilla")
local color = tostring(LunarColor.gml)

local lunarBud = MapObject.new({
	name = "Lunar Bud",
	sprite = Sprite.load("MapObjects/resources/lunarBud.png", 5, 10, 14),
	baseCost = 1,
	currency = "lunar_coins",
	affectedByDirector = false,
	affectPurchases = true,
	costIncrease = 1,
	mask = Sprite.load("budMask", "MapObjects/resources/budMask", 4, 3, 17),
	activeText = "&"..color.."&&$& LUNAR&!&",
	useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to open Lunar Bud&!&&y&(&$& Lunar)&!&",
	maxUses = 1,
	triggerFireworks = true
})

lunarBud:addCallback("step", function(self)
	if self:isValid() and self:get("dead") ~= 1 then
		smoke:burst("below", self.x + math.random(-self.sprite.width / 4, self.sprite.width / 4), self.y + 5, 20)
	end
end)

registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
	if objectInstance:getObject() == lunarBud then
		if frame == 1 then
			misc.shakeScreen(5)
			sound:play(1)
		elseif frame == 4 then
			local pool = ItemPool.find("lunar", "rts-reborn")
			if Artifact.find("Command") and Artifact.find("Command").active then
				local crate = pool:getCrate():create(objectInstance.x, objectInstance.y + 3)
			else
				if net.host then
					local item = pool:roll()
					item:create(objectInstance.x, objectInstance.y - 20)
					if net.online then
						SyncChest:sendAsHost("all", nil, objectInstance.x, objectInstance.y - (2 * objectInstance.sprite.height), item:getObject():getName())
					end
				end
			end
		end
	end
end)

registercallback("onObjectFailure", function(objectInstance, player)
	if objectInstance:getObject() == lunarBud then
		Sound.find("Error", "vanilla"):play(1)
	end
end)

local budCard = Interactable.new(lunarBud, "lunarBud")
--budCard.spawnCost = 1
budCard.spawnCost = 100

for _, stage in ipairs(Stage.findAll("vanilla")) do
	stage.interactables:add(budCard)
end
if modloader.checkMod("Starstorm") then
	for _, ss_stage in ipairs(Stage.findAll("Starstorm")) do
		ss_stage.interactables:add(budCard)
	end
end
