local path = "Actors/beetleGuard/"
local path2 = "Actors/beetleGuardAlly/"

local sprites = {
    idle = Sprite.load("BeetleGIdle", path.."idle", 1, 10,13),
    walk = Sprite.load("BeetleGWalk", path.."walk", 12, 10,15),
    jump = Sprite.load("BeetleGJump", path.."jump", 1, 6,12),
    shoot1 = Sprite.load("BeetleGShoot1", path.."shoot1", 10, 12, 22),
    shoot2 = Sprite.load("BeetleGShoot2", path.."shoot2", 9, 12, 34),
    spawn = Sprite.load("BeetleGSpawn", path.."spawn", 8,8,16),
    death = Sprite.load("BeetleGDeath", path.."death", 11, 17,21),
    mask = Sprite.load("BeetleGMask", path.."mask", 1, 10, 13),
    palette = Sprite.find("BeetlePal"),
    sparks = Sprite.load("Slam", path.."slam", 9, 16, 27)
}

local allySprites = {
    idle = Sprite.load("BeetleGSIdle", path2.."idle", 1, 10,13),
    walk = Sprite.load("BeetleGSWalk", path2.."walk", 12, 10,16),
    jump = Sprite.load("BeetleGSJump", path2.."jump", 1, 6,12),
    shoot1 = Sprite.load("BeetleGSShoot1", path2.."shoot1", 10, 12, 22),
    shoot2 = Sprite.load("BeetleGSShoot2", path2.."shoot2", 9, 12, 34),
    spawn = Sprite.load("BeetleGSSpawn", path2.."spawn", 8,17,16),
    death = Sprite.load("BeetleGSDeath", path2.."death", 11, 17,21),
}

local sounds = {
    spawn = Sound.load("BeetleGSpawn", path.."spawn"),
    death = Sound.load("BeetleGDeath", path.."death"),
    slam = Sound.load("BeetleGShoot1", path.."slam"),
    sunder = Sound.load("BeetleGShoot2", path.."pound"),
}

local objects = {
    dust = Object.find("MinerDust", "vanilla"),
    sparks = Object.find("EfSparks", "vanilla")
}


local beetleG = Object.base("EnemyClassic", "BeetleG")
beetleG.sprite = sprites.idle

local beetleGAlly = Object.base("EnemyClassic", "BeetleGS")
beetleGAlly.sprite = allySprites.idle

EliteType.registerPalette(sprites.palette, beetleG)



local poi = Object.find("POI", "vanilla")
local shouldBeWithinXOfParent = 50
local tpToParentRange = 500

local sunderProj = Object.new("SunderProjectile")
sunderProj:addCallback("create", function(self)
    local data = self:getData()
    local selfAc = self:getAccessor()
    data.life = 3*60
    data.team = "enemy"
    self.mask = sprites.mask
    data.damage = 14 * Difficulty.getScaling("damage")
    data.speed = 5
    data.dir = 1
    self.y = FindGround(self.x, self.y)
    data.target = poi:findNearest(self.x, self.y)
end)
sunderProj:addCallback("step", function(self)
    local data = self:getData()
    local selfAc = self:getAccessor()
    -------------------------
    if data.life > -1 then
        data.life = data.life - 1
    else
        self:destroy()
        return
    end
    -------------------------
    local dir = data.dir
    if not self:collidesMap(self.x, self.y) then
        if self:collidesMap(self.x, self.y + 16) then
            self.y = FindGround(self.x, self.y)
        else
            self:destroy()
            return
        end
    end
	self.x = self.x + data.speed * dir
    if self:collidesMap(self.x + (selfAc.speed * dir), self.y - 8) then
        if not self:collidesMap(self.x + (selfAc.speed * dir), self.y - 16) then
            self.y = self.y - 16
        else
            self:destroy()
            return
        end
    end
    if data.target and data.target:isValid() then
        if data.target:get("parent") then
            local tgParent = Object.findInstance(data.target:get("parent"))
            if tgParent and self:collidesWith(tgParent, self.x, self.y) then
                self:destroy()
                return
            end
        end
        if self:collidesWith(data.target, self.x, self.y) then
            self:destroy()
            return
        end
    end
    -------------------------
    local dust = objects.dust:findNearest(self.x, self.y)
    if not dust or not self:collidesWith(dust, self.x, self.y - 6) then
        local d = objects.dust:create(self.x, self.y - 6)
        d.xscale = dir
    end
end)

sunderProj:addCallback("destroy", function(self)
    local data = self:getData()
    local self = self:getAccessor()
    misc.shakeScreen(5)
    local explosion
    if data.parent then
        explosion = data.parent:fireExplosion(self.x, self.y, 1, 1, 1, sprites.shoot1FX, nil, nil)
    else
        explosion = misc.fireExplosion(self.x, self.y, 1, 1, data.damage, data.team, sprites.shoot1FX, nil, nil)
    end
    explosion:set("knockup", 3)
end)

local attack1StartFunc = function(actor)
	Monster.setActivityState(actor, 1, actor:getAnimation("shoot1"), 0.25, true, true)
	Monster.activateSkillCooldown(actor, 1)
end
local attack1StepFunc = function(actor, relevantFrame)
	if relevantFrame == 1 then
		sounds.slam:play(0.9 + math.random() * 0.2)
	elseif relevantFrame == 8 then
		misc.shakeScreen(5)
		local slam = actor:fireExplosion(actor.x + (5 * actor.xscale), actor.y, 20 / 19, 12 / 4, 4.4, sprites.sparks, nil, nil)
		slam:set("knockup", 5)
		--slam.depth = actor.depth - 1
	end
end

local attack2StartFunc = function(actor)
	Monster.setActivityState(actor, 2, actor:getAnimation("shoot2"), 0.25, true, true)
	Monster.activateSkillCooldown(actor, 2)
end
local attack2StepFunc = function(actor, relevantFrame)
	if relevantFrame == 1 then
		sounds.sunder:play(0.9 + math.random() * 0.2)
	elseif relevantFrame == 8 then
		local actorAc = actor:getAccessor()
		misc.shakeScreen(5)
		local s = sunderProj:create(actor.x + (8 * actor.xscale), actor.y)
		s:getData().dir = actor.xscale
		s:getData().parent = actor
		s:getData().team = actorAc.team
		s:getData().damage = actorAc.damage
		s:getData().target = Object.findInstance(actorAc.target)
	end
end


beetleG:addCallback("create", function(actor)
    local actorAc = actor:getAccessor()
    local data = actor:getData()
    actorAc.name = "Beetle Guard"
    actorAc.maxhp = 400 * Difficulty.getScaling("hp")
    actorAc.hp = actorAc.maxhp
    actorAc.damage = 14 * Difficulty.getScaling("damage")
    actorAc.pHmax = 1.3
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        shoot1 = sprites.shoot1,
        shoot2 = sprites.shoot2,
        death = sprites.death,
		palette = sprites.palette
    }
    actorAc.sound_hit = Sound.find("MushHit","vanilla").id
    actorAc.sound_death = sounds.death.id
    actor.mask = sprites.mask
    actorAc.health_tier_threshold = 3
    actorAc.knockback_cap = actorAc.maxhp
    actorAc.exp_worth = 50
    actorAc.shake_frame = 7
    actorAc.stun_immune = 1
    actorAc.can_drop = 1
    actorAc.can_jump = 1
end)

Monster.giveAI(beetleG)

Monster.setSkill(beetleG, 1, 20, 3 * 60, attack1StartFunc)
Monster.skillCallback(beetleG, 1, attack1StepFunc)

Monster.setSkill(beetleG, 2, 150, 4 * 60, attack2StartFunc)
Monster.skillCallback(beetleG, 2, attack2StepFunc)


-- ALLY

beetleGAlly:addCallback("create", function(actor)
    local actorAc = actor:getAccessor()
    local data = actor:getData()
    actorAc.team = "player"
    actorAc.name = "Beetle Guard"
    actorAc.maxhp = 1000 * Difficulty.getScaling("hp")
    actorAc.hp_regen = 0.1
    actorAc.hp = actorAc.maxhp
    actorAc.damage = 14 * Difficulty.getScaling("damage")
    actorAc.pHmax = 1.3
    actor:setAnimations{
        idle = allySprites.idle,
        walk = allySprites.walk,
        jump = allySprites.idle,
        shoot1 = allySprites.shoot1,
        shoot2 = allySprites.shoot2,
        death = allySprites.death,
		--palette = sprites.palette --needs palette, but does it need eliting?
    }
    actorAc.sound_hit = Sound.find("MushHit","vanilla").id
    actorAc.sound_death = sounds.death.id
    actor.mask = sprites.mask
    actorAc.health_tier_threshold = 1
    actorAc.knockback_cap = actorAc.maxhp
    actorAc.shake_frame = 7
    actorAc.stun_immune = 1
    actorAc.z_range = 20
    actorAc.x_range = 150
    actorAc.can_drop = 1
    actorAc.can_jump = 1
    data.ally = true
    local p = poi:create(actor.x, actor.y)
    p:set("parent", actor.id)
end)

Monster.giveAI(beetleGAlly)

Monster.setSkill(beetleGAlly, 1, 20, 3 * 60, attack1StartFunc)
Monster.skillCallback(beetleGAlly, 1, attack1StepFunc)

Monster.setSkill(beetleGAlly, 2, 150, 4 * 60, attack2StartFunc)
Monster.skillCallback(beetleGAlly, 2, attack2StepFunc)

beetleGAlly:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
	
	local parent = data.parent
	if parent and parent:isValid() then
		if distance(actor.x, actor.y, parent.x, parent.y) > shouldBeWithinXOfParent and distance(actor.x, actor.y, parent.x, parent.y) <= shouldBeWithinXOfParent / 3 and actor.x >= parent.x - 16 and actor.x <= parent.x + 16 then
			if parent.x > actor.x then
				actor:set("moveLeft", 1)
				actor:set("moveRight", 0)
			else
				actor:set("moveLeft", 0)
				actor:set("moveRight", 1)
			end
		elseif distance(actor.x, actor.y, parent.x, parent.y) > tpToParentRange then
			actor.x = parent.x
			actor.y = parent.y - actor.sprite.yorigin
		end
	end
	--[[if self.state == "spawn" then
		if actor.sprite == allySprites.spawn then
			self.invincible = 2
			local frame = math.floor(actor.subimage)
			if frame >= allySprites.spawn.frames then
				self.activity = 0
				self.activity_type = 0
				actor.spriteSpeed = 0.25
				self.state = "chase"
				actor.sprite = allySprites.idle
				return
			end
		else
			actor.sprite = allySprites.spawn
			actor.spriteSpeed = 0.25
			self.activity = 5
			self.activity_type = 3
			return
		end
    end]] -- i dont think this works, "spawn" is never set as a state
end)

beetleGAlly:addCallback("destroy", function(actor)
    local data = actor:getData()
    local parent = data.parent
    if parent then
        local d = parent:getData()
		if d.guards > 0 then
			d.guards = d.guards - 1
		end
    end
end)

local monsCard = MonsterCard.new("Beetle Guard", beetleG)
monsCard.cost = 100
monsCard.type = "classic"
monsCard.sound = sounds.spawn
monsCard.sprite = sprites.spawn
for _, e in ipairs(EliteType.findAll("vanilla")) do
    monsCard.eliteTypes:add(e)
end
monsCard.canBlight = true
monsCard.isBoss = false

local stages = {
    Stage.find("Desolate Forest"),
    Stage.find("Dried Lake"),
    Stage.find("Boar Beach"),
    Stage.find("Sky Meadow"),
    Stage.find("Temple of the Elders")
}

AddMCardToStages(monsCard,stages)

local monsLog = MonsterLog.new("Beetle Guard")
MonsterLog.map[beetleG] = monsLog

monsLog.displayName = "Beetle Guard"
monsLog.story = "The Beetle Guard is a vast and powerful beast, demanding fear and respect among the lesser Beetle drones. The Guard is absolutely terrifying to face in battle, as its chitin armor is much more durable than the average Beetle's. I spent many of my dwindling supplies trying to fell just one of them, and that battle took about an hour.\n\nDespite their hunched posture, the Guard is deceptively mobile, able to cross a 100 meter gap in under a minute. It attacks by swinging its tree trunk-like arms, sending rocks and dirt flying.\n\nAmong the Beetle hierarchy, the Guard seems to rank much higher than the lesser Beetle workers. I've observed a pack of Beetles fleeing once a Guard wandered into the area."
monsLog.statHP = 600
monsLog.statDamage = 14
monsLog.statSpeed = 1.5
monsLog.sprite = sprites.shoot1
monsLog.portrait = sprites.idle