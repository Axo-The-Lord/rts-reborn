-- Combat Shrine

local combatShrine = MapObject.new({
    name = "Combat Shrine",
    sprite = Sprite.load("combatShrine", "MapObjects/resources/combatShrine.png", 7, 32, 45),
    baseCost = 0,
    currency = "gold",
    costIncrease = 0,
    affectedByDirector = false,
    mask = Sprite.load("combatShrineMask", "MapObjects/resources/combatShrineMask.png", 1, 32, 45),
    activeText = "",
    useText = "&w&Press&!& &y&'"..input.getControlString("enter").."'&!& &w&to pray to the Shrine of Combat&!&",
    maxUses = 1,
    triggerFireworks = true,
})

callback.register("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == combatShrine then
        if frame == 1 then
            Sound.find("Shrine1", "vanilla"):play(1 + math.random() * 0.01)
            misc.shakeScreen(5)
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
