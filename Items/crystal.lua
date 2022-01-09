-- Focus Crystal

local item = Item("Focus Crystal")
item.pickupText = "Deal bonus damage to nearby enemies."
item.sprite = Sprite.load("Items/resources/crystal.png", 1, 11, 13)
item:setTier("common")

local effectRange = 35
local procSprite = Sprite.load("Items/resources/crystalBonus.png", 5, 5.5, 5.5)
local procSound = Sound.load("Items/resources/crystal.ogg")
local sparks = Object.find("EfSparks", "vanilla")

-- Timer
local timer = 0
callback.register("onStep", function()
	timer = timer + 1
end)

-- Draw
callback.register("onPlayerDrawBelow", function(player)
    if player:countItem(item) > 0 then
        graphics.color(Color.fromHex(0xE73A4A))
        graphics.alpha(0.5 + math.sin(timer * 0.05) * 0.2)
        graphics.circle(player.x, player.y, effectRange, true)
    end
end)

callback.register("onHit", function(damager, actor, x, y)
	local parent = damager:getParent()
	if isa(parent, "PlayerInstance") then
		local stack = parent:countItem(item)
		if stack > 0 then
			local xx = parent.x - actor.x
			local yy = parent.y - actor.y
			local zz = math.sqrt(math.pow(xx, 2) + math.pow(yy, 2))
			if zz <= effectRange then
				local effect = sparks:create(actor.x, actor.y)
				effect.sprite = procSprite
				effect.xscale = parent.xscale
				procSound:play(0.9 + math.random() * 0.3, 0.7)
				local damageBonus = parent:get("damage") * 0.2 * stack
				damager:set("damage", parent:get("damage") + damageBonus)
				if misc.getOption("video.show_damage") == true then
					misc.damage(damageBonus, actor.x, actor.y, false, Color.PINK)
				end
			end
		end
	end
end)

-- Item Log
item:setLog{
	group = "common",
	description = "Increase damage to enemies within &y&13m&!& for &y&20%&!&&lt&(+20% per stack)&!&.",
	story = "Hope they don\'t up the price for this thing. I haven\'t had troubles with UES before, but I\'ve never had to ship a crystal this far before. Let me know if the package is marked as \"heavy\" when you get it.",
	destination = "Geofferson Principality,\nHighward,\nTitan",
	date = "05/23/2056",
	priority = "Standard"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, nil, "+20% extra damage to enemies within a 13m radius.", "+20% damage.")
end
