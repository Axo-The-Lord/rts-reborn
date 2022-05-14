local path = "Actors/beetle/"
local enemyName = "Beetle"

local sprMask = Sprite.load(enemyName.."Mask", path.."mask", 1, 6, 11)
local sprPalette = Sprite.load(enemyName.."Pal", path.."palette", 1, 0, 0)


local animations = {
    spawn=Sprite.load(enemyName.."Spawn", path.."spawn", 13, 8, 12),
    idle=Sprite.load(enemyName.."Idle", path.."idle", 1, 6, 11),
    walk=Sprite.load(enemyName.."Walk", path.."walk", 7, 7, 12),
    jump=Sprite.load(enemyName.."Jump", path.."jump", 1, 6, 12),
    shoot1=Sprite.load(enemyName.."Shoot1", path.."shoot1", 10, 6, 14),
    death=Sprite.load(enemyName.."Death", path.."death", 6, 19, 15),
    palette=sprPalette
}

local sndShoot1 = Sound.load("BeetleShoot1", path.."shoot1.ogg")
local sndDeath = Sound.load("BeetleDeath", path.."death.ogg")
local sndSpawn = Sound.load("BeetleSpawn", path.."spawn.ogg")

local beetle = Object.base("EnemyClassic", enemyName)
beetle.sprite = animations.idle

EliteType.registerPalette(sprPalette, beetle)

--NPC.setSkill(object, index, range, cooldown, sprite, speed, startFunc, updateFunc)
NPC.setSkill(beetle, 1, 25, 60 * 2, animations.shoot1, 0.25, function(actor)
	local target = Object.findInstance(actor:get("target"))
	if target and target:isValid() then
		if target.x > actor.x then
			actor.xscale = math.abs(actor.xscale)
		else
			actor.xscale = math.abs(actor.xscale) * -1
		end
	end
end, function(actor, relevantFrame)
	local actorData = actor:getData()
	if relevantFrame == 8 then
		local target = Object.findInstance(actor:get("target"))
		actor:fireExplosion(actor.x + (5 * actor.xscale), actor.y, 1, 1, 2, nil, nil, nil)
		sndShoot1:play(0.9 + math.random() * 0.2)
	end
end)

beetle:addCallback("create", function(self)
	local selfAc = self:getAccessor()
	self.mask = sprMask
	selfAc.name = "Beetle"
	selfAc.damage = 17 * Difficulty.getScaling("damage")
	selfAc.maxhp = 120 * Difficulty.getScaling("hp")
	selfAc.armor = 15
	selfAc.hp = selfAc.maxhp
	selfAc.pHmax = 0.5
	selfAc.knockback_cap = selfAc.maxhp / 5
	selfAc.exp_worth = 20 * Difficulty.getScaling()
	selfAc.can_drop = 0
	selfAc.can_jump = 0
	selfAc.sound_hit = Sound.find("MushHit","vanilla").id
	selfAc.hit_pitch = 1
	selfAc.sound_death = sndDeath.id
    for key,val in pairs(animations) do
        self:setAnimation(key, val)
    end
end)

beetle:addCallback("step", function(self)
    local selfAc = self:getAccessor()
    local object = self:getObject()
    local selfData = self:getData()
    local activity = selfAc.activity
    if self:collidesMap(self.x, self.y) then
		for i = 1, 20 do
			if not self:collidesMap(self.x + i, self.y) then
				self.x = self.x + i
				break
			end
		end
		for i = 1, 20 do
			if not self:collidesMap(self.x - i, self.y) then
				self.x = self.x - i
				break
			end
		end
	end

	if misc.getTimeStop() == 0 then
        if activity == 0 then
            for k, v in pairs(NPC.skills[object]) do
                if self:get(v.key.."_skill") > 0 and self:getAlarm(k + 1) == -1 then
                    selfData.attackFrameLast = 0
                    self:set(v.key.."_skill", 0)
                    if v.start then
                        v.start(self)
                    end
                    selfAc.activity = k
                    self.subimage = 1
                    if v.cooldown then
                        self:setAlarm(k + 1, v.cooldown * (1 - self:get("cdr")))
                    end
                else
                    self:set(v.key.."_skill", 0)
                end
            end
        else
            local skill = NPC.skills[object][activity]
            if skill then
                local relevantFrame = 0
                local newFrame = math.floor(self.subimage)
                if newFrame > selfData.attackFrameLast then
                    relevantFrame = newFrame
                    selfData.attackFrameLast = newFrame
                end
                if selfAc.free == 0 then
                    selfAc.pHspeed = 0
                end
                if skill.update then
                    skill.update(self, relevantFrame)
                end
                self.spriteSpeed = skill.speed * selfAc.attack_speed
                selfAc.activity_type = 1
                if skill.sprite then
                    self.sprite = skill.sprite
                end
                if newFrame == self.sprite.frames then
                    selfAc.activity = 0
                    selfAc.activity_type = 0
                    selfAc.state = "chase"
                end
            end
        end
    else
        self.spriteSpeed = 0
    end
end)

local card = MonsterCard.new(enemyName, beetle)
card.type = "classic"
card.cost = 8
card.sound = sndSpawn
card.sprite = animations.spawn
card.isBoss = false
card.canBlight = true

for _, elite in ipairs(EliteType.findAll("vanilla")) do
    card.eliteTypes:add(elite)
end

local stages = {
    Stage.find("Desolate Forest"),
    Stage.find("Dried Beach"),
    Stage.find("Ancient Tomb"),
    Stage.find("Temple of the Elders"),
    Stage.find("Sky Meadow")
}

AddMCardToStages(card,stages)

local monsLog = MonsterLog.new(enemyName)
MonsterLog.map[beetle] = monsLog

monsLog.displayName = "Beetle"
monsLog.story = "Day 4. I encountered several insect-like lifeforms. They emerged from the ground, pushing up from the dirt. They were roughly each the size of a small cow, and were covered in several chitin plates. Initially, all they did was glower at me until they built up enough courage and numbers to attack.\n\nNow and then I catch glimpses of them from afar. They have a bizarre social hierarchy that I can't discern. I spotted a lone Beetle minding its own business, and several more Beetles approached and mercilessly attacked the creature, leaving it bloodied and bruised. I almost felt pity for the Beetle, but I knew that it too would attack me with the same ferocity as its brethren.\n\nOccasionally, I've seen them hop around repeatedly in place. Is this some kind of dance?"
monsLog.statHP = 120
monsLog.statDamage = 17
monsLog.statSpeed = 0.5
monsLog.sprite = animations.walk
monsLog.portrait = Sprite.load(enemyName.." Portrait",path.."portrait.png",1,239/2,239/2)
monsLog.portraitSubimage = 1
