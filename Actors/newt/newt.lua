-- Newt

local path = "Actors/newt/"

local sprites = {
	spawn = Sprite.load(path.."spawn.png", 9, 28, 63),
	idle = Sprite.load(path.."idle.png", 4, 22, 25),
	mask = Sprite.load(path.."mask.png", 1, 22, 25)
}

local sounds = {
	Sound.load(path.."newt1.ogg"),
	Sound.load(path.."newt2.ogg"),
	Sound.load(path.."newt3.ogg"),
	Sound.load(path.."newt4.ogg"),
	Sound.load(path.."newt5.ogg"),
	Sound.load(path.."newt6.ogg"),
	Sound.load(path.."newt7.ogg"),
	Sound.load(path.."newt8.ogg"),
	Sound.load(path.."newt9.ogg"),
	Sound.load(path.."newt10.ogg"),
	Sound.load(path.."newt11.ogg")
}

local newt = Object.base("Enemy", "Newt")
newt.sprite = sprites.idle
newt:addCallback("create", function(actor)
	local selfAc = actor:getAccessor()
	selfAc.name = "Newt"
	selfAc.name2 = "Bogus Salamander"
	selfAc.show_boss_health = 1
	selfAc.team = "Newtral" -- heehee
	selfAc.maxhp = 500000 * Difficulty.getScaling("hp")
	selfAc.hp = selfAc.maxhp
	selfAc.damage = 0
	selfAc.pHmax = 0
	selfAc.armor = 100
	actor:setAnimations{
		spawn = sprites.spawn,
		idle = sprites.idle
	}
	actor.mask = sprites.mask
	selfAc.exp_worth = 1000000
	selfAc.knockback_cap = 9999999999999999
	selfAc.knockback_value = 0
	selfAc.stun_immune = 1
end)

newt:addCallback("step", function(actor)
	actor:set("move_left", 0)
	actor:set("move_right", 0)
	if actor:getAlarm(2) == -1 then
		sounds[math.random(1, #sounds)]:play(0.9 + math.random() * 0.2, 2)
		actor:setAlarm(2, 6*60)
		return
	end
	local player = Object.find("P", "vanilla"):findNearest(actor.x, actor.y)
	if player.x > actor.x then
		actor.xscale = 1
	else
		actor.xscale = -1
	end
end)
