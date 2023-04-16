-- Lunar Bud

local budDust = Sprite.load("budDust", "MapObjects/Resources/budDust.png", 1, 18, 14)
local sound = Sound.load("MapObjects/resources/bud.ogg")
local color = tostring(LunarColor.gml) -- had to unuse this

-- Timer
local timer = 0
callback.register("onStep", function()
	timer = timer + 1
end)

local smoke = ParticleType.new("budSmoke")
smoke:sprite(budDust, true, true, false)
smoke:size(0.0002, 0.5, 0.005, 0.005)
smoke:life(60, 150)
smoke:direction(45, 145, 0, 1)
smoke:alpha(0.1, 0.6, 0)
smoke:angle(0, 360, 0.5, 0, true)
smoke:gravity(0.0008, 90)
smoke:color(LunarColor)
smoke:additive(true)	
smoke:speed(0.5, 1, -0.015, -0.01)

local lunarBud = MapObject.new({
	name = "Lunar Bud",
	sprite = Sprite.load("MapObjects/resources/lunarBud.png", 5, 10, 14),
	baseCost = 1,
	currency = "lunar_coins",
	affectedByDirector = false,
	affectPurchases = true,
	costIncrease = 1,
	mask = Sprite.load("budMask", "MapObjects/resources/budMask", 4, 3, 17),
	activeText = "&b&&$& LUNAR&!&",
	useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to open Lunar Bud&!& &y&(&$& Lunar)&!&",
	maxUses = 1,
	useXOff = 40,
	triggerFireworks = true
})

lunarBud:addCallback("step", function(self)
	if self:isValid() and self:get("dead") ~= 1 and timer % 30 == 0 then
		smoke:burst("below", self.x, self.y + 5, 1)
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
				local crate = pool:getCrate():create(objectInstance.x, objectInstance.y - objectInstance.sprite.height)
			else
				if net.host then
					local item = pool:roll()
					item:create(objectInstance.x, objectInstance.y - objectInstance.sprite.height)
					if net.online then
						SyncChest:sendAsHost("all", nil, objectInstance.x, objectInstance.y - objectInstance.sprite.height, item:getObject():getName())
					end
				end
			end
		end
	end
end)

registercallback("onObjectFailure", function(lunarBud, player)
	if objectInstance:getObject() == lunarBud then
		Sound.find("Error", "vanilla"):play(1)
	end
end)

-- Stages
local stages = {}

local stageBlacklist = {}
if modloader.checkMod("Starstorm") then
	table.insert(stageBlacklist, Stage.find("The Void", "Starstorm"))
	table.insert(stageBlacklist, Stage.find("The Void Shop", "Starstorm"))
	table.insert(stageBlacklist, Stage.find("Void Gates", "Starstorm"))
	table.insert(stageBlacklist, Stage.find("Void Paths", "Starstorm"))
	table.insert(stageBlacklist, Stage.find("Void End", "Starstorm"))
	table.insert(stageBlacklist, Stage.find("The Red Plane", "Starstorm"))
	table.insert(stageBlacklist, Stage.find("The Unknown", "Starstorm"))
	table.insert(stageBlacklist, Stage.find("Mount of the Goats", "Starstorm"))
end

local budCard = Interactable.new(lunarBud, "lunarBud")
--budCard.spawnCost = 175

for _, stage in ipairs(Stage.findAll("vanilla")) do
	table.insert(stages, stage)
end
if modloader.checkMod("Starstorm") then
	for _, ss_stage in ipairs(Stage.findAll("Starstorm")) do
		if not contains(stageBlacklist, ss_stage) then
			table.insert(stages, stage)
		end
	end
end

MapObject.customSpawnRules(lunarBud, {
	stages = stages,
	chance = 80,
	min = 1,
	max = 2,
	mpScale = 0.5
})
