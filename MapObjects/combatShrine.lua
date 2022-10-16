-- Combat Shrine

local combatShrine = MapObject.new({
    name = "Combat Shrine",
    sprite = Sprite.load("combatShrine", "MapObjects/resources/combatShrine.png", 7, 17, 45),
    baseCost = 0,
    currency = "gold",
    costIncrease = 0,
    affectedByDirector = false,
    mask = Sprite.load("combatShrineMask", "MapObjects/resources/combatShrineMask.png", 1, 17, 45),
    activeText = "",
    useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to pray to the Shrine of Combat&!&",
    maxUses = 1,
    triggerFireworks = true,
})

local objSpawn = Object.find("Spawn")

callback.register("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == combatShrine then
        if frame == 1 then
            Sound.find("Shrine1", "vanilla"):play(1 + math.random() * 0.01)
            misc.shakeScreen(10)
			local cardOptions = {}
			for _, card in ipairs(Stage.getCurrentStage().enemies:toTable()) do
				if card.cost < Difficulty.getScaling() * 80 then
					table.insert(cardOptions, card)
				end
			end
			local mcard = table.irandom(cardOptions)
			if mcard then
				local eliteType
				if Difficulty.getScaling() * 80 > mcard.cost * 10 then
					eliteType = table.irandom(mcard.eliteTypes:toTable())
				end
				local count = 3
				for i = 1, count do
					local x = objectInstance.x + ((- count * 0.5) + (i - 1)) * 16
					local image = (mcard.sprite or mcard.object.sprite)
					local y = objectInstance.y - image.height + image.yorigin
					if mcard.type == "classic" then
						local spawn = objSpawn:create(x, y)
						spawn.sprite = mcard.sprite
						spawn.spriteSpeed = 0.15
						spawn:set("child", mcard.object.id)
						if mcard.sound then
							mcard.sound:play(math.random(0.9 + math.random() * 0.2))
						end
						if eliteType then
							spawn:set("prefix_type", 1)
							spawn:set("elite_type", eliteType.id)
						end
					elseif mcard.type == "offscreen" then 
						local actor = mcard.object:create(x, y - 20)
						if eliteType then
							actor:set("prefix_type", 1)
							actor:set("elite_type", eliteType.id)
						end
					else
						local actor = mcard.object:create(x, y)
						if eliteType then
							actor:set("prefix_type", 1)
							actor:set("elite_type", eliteType.id)
						end
					end
				end
			end
        end
    end
end)

-- Stages
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

local shrineCard = Interactable.new(combatShrine, "combatShrine")
shrineCard.spawnCost = 75
for _, stage in ipairs(Stage.findAll("vanilla")) do
	stage.interactables:add(shrineCard)
end
if modloader.checkMod("Starstorm") then
	for _, ss_stage in ipairs(Stage.findAll("Starstorm")) do
		if not contains(stageBlacklist, ss_stage) then
			ss_stage.interactables:add(shrineCard)
		end
	end
end
