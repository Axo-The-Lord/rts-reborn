--Beetle.lua

local path = "Actors/beetle/"

local sprites = {
    idle = Sprite.load("BeetleIdle", path.."idle", 1, 6,11),
    walk = Sprite.load("BeetleWalk", path.."walk", 7, 7,12),
    jump = Sprite.load("BeetleJump", path.."jump", 1, 6,12),
    shoot1 = Sprite.load("BeetleShoot1", path.."shoot1", 10, 6, 14),
    spawn = Sprite.load("BeetleSpawn", path.."spawn", 13,8,12),
    death = Sprite.load("BeetleDeath", path.."death", 6, 19,15),
    mask = Sprite.load("BeetleMask", path.."idle", 1, 6,11),
    palette = Sprite.load("BeetlePal", path.."palette", 1, 0,0),
    hit = Sprite.find("Bite1", "vanilla"),
	portrait = Sprite.load("BeetlePortrait", path.."portrait", 1, 119, 199)
}

local sounds = {
    attack = Sound.load("BeetleShoot1", path.."attack"),
    spawn = Sound.load("BeetleSpawn", path.."spawn"),
    death = Sound.load("BeetleDeath", path.."death"),
}

local beetle = Object.base("EnemyClassic", "Beetle")
beetle.sprite = sprites.idle

EliteType.registerPalette(sprites.palette, beetle)

beetle:addCallback("create", function(actor)
    local actorAc = actor:getAccessor()
    local data = actor:getData()
    actorAc.name = "Beetle"
    actorAc.maxhp = 80 * Difficulty.getScaling("hp")
    actorAc.hp = actorAc.maxhp
    actorAc.damage = 12 * Difficulty.getScaling("damage")
    actorAc.pHmax = 0.8
	actorAc.walk_speed_coeff = 1.1
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        shoot1 = sprites.shoot1,
        death = sprites.death,
		palette = sprites.palette
    }
    actorAc.sound_hit = Sound.find("MushHit","vanilla").id
    actorAc.sound_death = sounds.death.id
    actor.mask = sprites.mask
    actorAc.health_tier_threshold = 3
    actorAc.knockback_cap = 5
    actorAc.exp_worth = 3
    actorAc.can_drop = 1
    actorAc.can_jump = 1
end)

Monster.giveAI(beetle)

Monster.setSkill(beetle, 1, 10, 2 * 60, function(actor)
	Monster.setActivityState(actor, 1, actor:getAnimation("shoot1"), 0.2, true, true)
	Monster.activateSkillCooldown(actor, 1)
end)
Monster.skillCallback(beetle, 1, function(actor, relevantFrame)
	if relevantFrame == 1 then
		sounds.attack:play(0.9 + math.random() * 0.2)
	elseif relevantFrame == 8 then
		actor:fireExplosion(actor.x + (5 * actor.xscale), actor.y, 1, 1, 2, nil, sprites.hit, nil)
	end
end)

--------------------------------------

local card = MonsterCard.new("Beetle", beetle)
card.sprite = sprites.spawn
card.sound = sounds.spawn
card.canBlight = true
card.type = "classic"
card.cost = 8
for _, elite in ipairs(EliteType.findAll("vanilla")) do
    card.eliteTypes:add(elite)
end

local stages = {
    Stage.find("Desolate Forest"),
    Stage.find("Dried Lake"),
    Stage.find("Boar Beach"),
    Stage.find("Sky Meadow"),
    Stage.find("Temple of the Elders")
}

AddMCardToStages(card,stages)

local monsLog = MonsterLog.new("Beetle")
MonsterLog.map[beetle] = monsLog

monsLog.displayName = "Beetle"
monsLog.story = "Day 4. I encountered several insect-like lifeforms. They emerged from the ground, pushing up from the dirt. They were roughly each the size of a small cow, and were covered in several chitin plates. Initially, all they did was glower at me until they built up enough courage and numbers to attack.\n\nNow and then I catch glimpses of them from afar. They have a bizarre social hierarchy that I can't discern. I spotted a lone Beetle minding its own business, and several more Beetles approached and mercilessly attacked the creature, leaving it bloodied and bruised. I almost felt pity for the Beetle, but I knew that it too would attack me with the same ferocity as its brethren.\n\nOccasionally, I've seen them hop around repeatedly in place. Is this some kind of dance?"
monsLog.statHP = 80
monsLog.statDamage = 12
monsLog.statSpeed = 1
monsLog.sprite = sprites.walk
monsLog.portrait = sprites.portrait
