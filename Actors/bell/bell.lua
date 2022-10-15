local path = "Actors/bell/"

local sprites = {
    idle = Sprite.load("BellIdle", path.."idle", 1, 8,16),
    walk = Sprite.load("BellWalk", path.."walk", 8, 8,16),
    death = Sprite.load("BellDeath", path.."death", 7, 16,17),
    mask = Sprite.load("BellMask", path.."idle", 1,8,14),
    palette = Sprite.load("BellPal", path.."palette", 1, 0, 0)
}

local sounds = {
    hit = Sound.load("BellHit", path.."Hit.ogg"),
    spawn = Sound.load("BellSpawn", path.."Spawn.ogg"),
    death = Sound.load("BellDeath", path.."Death.ogg"),
    prepare = {
        [0] = Sound.load("BellShoot1Load1", path.."Attack1.ogg"),
        [1] = Sound.load("BellShoot1Load2", path.."Attack2.ogg"),
        [2] = Sound.load("BellShoot1Load3", path.."Attack3.ogg"),
    },
    hurl = {
        [0] = Sound.load("BellShoot1Fire1", path.."Throw.ogg"),
        [1] = Sound.load("BellShoot1Fire2", path.."Throw2.ogg"),
        [2] = Sound.load("BellShoot1Fire3", path.."Throw3.ogg"),
    },
    impact = Sound.load("BellShoot1Impact", path.."Impact.ogg")
}


local bell = Object.base("EnemyClassic", "Bell")
bell.sprite = sprites.idle

EliteType.registerPalette(sprites.palette, bell)


local actors = ParentObject.find("actors", "vanilla")
local player = Object.find("P", "vanilla")

local spikeSpr = Sprite.load("EfSpikeball", path.."spikeball", 6, 6, 7)
local spikeMask = Sprite.load(path.."spikeMask", 1, 6, 7)
local spikeBall = Object.new("BellBlast")
spikeBall.sprite = spikeSpr
spikeBall:addCallback("create", function(self)
    local data = self:getData()
	local selfAc = self:getAccessor()
    self.mask = spikeMask
	selfAc.activity = 1
    selfAc.attack_speed = 1
    self.spriteSpeed = self:get("attack_speed") * 0.25
    self.angle = math.random(360)
    selfAc.life = 0
    selfAc.vx = 0
    selfAc.vy = 0
    selfAc.ay = 0.25
    selfAc.rotate = 1
    selfAc.bounce = 0
    selfAc.team = "enemy"
    selfAc.bounceCount = 0
    selfAc.xOff = 0
	selfAc.yOff = 0
    ---------------
    data.hitEnemies = {}

end)

local spikeThrowWait = 60
local spikeDecayTime = 30*60 --Time it takes for a stationary spike ball to destroy
local maxSpikes = 15
local spikesCount = 0

callback.register("onStageEntry", function()
    spikesCount = 0
end)
callback.register("onGameStart", function()
    spikesCount = 0
end)

spikeBall:addCallback("step", function(self)
    local data = self:getData()
    if data.parent and not data.parent:isValid() then
        self:destroy()
        return
    end
    if self:get("activity") == 0 then --Invisible, waiting to be "spawned"
        self.alpha = 0
        if data.parent and self:get("xOff") and self:get("yOff") then
            self.x = data.parent.x + (self:get("xOff") * data.parent.xscale)
            self.y = data.parent.y + self:get("yOff")
        end
        self:set("life", self:get("life") + 1)
        if self:get("life") >= self:get("delay") then
            self.alpha = 1
            self.subimage = 1
            self.spriteSpeed = self:get("attack_speed") * 0.25
            self:set("activity", 1)
        end
    elseif self:get("activity") == 1 then --Spawn Animation
        if data.parent and self:get("xOff") and self:get("yOff") then
            self.x = data.parent.x + (self:get("xOff") * data.parent.xscale)
            self.y = data.parent.y + self:get("yOff")
        end
        if math.floor(self.subimage) >= spikeSpr.frames then
            self:set("life", 0)
            self.spriteSpeed = 0
            self:set("activity", 2)
        elseif math.round(self.subimage) == 1 then
            sounds.prepare[self:get("sound")]:play(self:get("attack_speed") + math.random() * 0.05)
        end
    elseif self:get("activity") == 2 then --Waiting to be thrown
        if data.parent and self:get("xOff") and self:get("yOff") then
            self.x = data.parent.x + (self:get("xOff") * data.parent.xscale)
            self.y = data.parent.y + self:get("yOff")
        end
        self:set("life", self:get("life") + 1)
        if self:get("life") >= spikeThrowWait then
            data.hitEnemies = {}
            if data.target and data.target:isValid() then
                if data.target:isValid() then
                    self:set("vx", (data.target.x - self.x) * 0.1)
                    self:set("vy", (data.target.y - self.y) * 0.1)
                    spikesCount = spikesCount + 1
                    sounds.hurl[self:get("sound")]:play(self:get("attack_speed") + math.random() * 0.05)
                    self:set("activity", 3)
                end
            else
				local nearestInstance = nil
				local r = 300
				local myTeam = selfAc.team
				for _, instance2 in ipairs(actors:findAllEllipse(self.x-r, self.y-r, self.x+r, self.y+r)) do
					if not isa(instance2, "PlayerInstance") or instance2:get("dead") == 0 then
						if instance2:get("team") ~= myTeam then
							local dis = Distance(self.x, self.y, instance2.x, instance2.y)
							if not nearestInstance or dis < nearestInstance.dis then
								nearestInstance = {inst = instance2, dis = dis}
							end
						end
					end
				end
				if nearestInstance then
					data.target = nearestInstance.inst
				end
			end
        end

    elseif self:get("activity") == 3 then --Simulate physics
        self.x = self.x + (self:get("vx") or 0)
        self.y = self.y + (self:get("vy") or 0)	
        self:set("vx", (self:get("vx") or 0) + (self:get("ax") or 0))
        self:set("vy", (self:get("vy") or 0) + (self:get("ay") or 0))
        if self:get("vx") > 0 then self:set("direction", 1)
        elseif self:get("vx") < 0 then self:set("direction", -1)
        else self:set("direction", 0) end
        if self:get("rotate") ~= nil then
            self.yscale = 1
            self.xscale = 1
            local _pvx = self:get("vx") or 0
            local _pvy = -(self:get("vy") or 0)
            local _angle = math.atan(_pvy/_pvx)*(180/math.pi)
            if _pvx < 0 then _angle = _angle + 180 end
            self.angle = (self:get("rotate") + _angle)%360
        end
        for _, actor in ipairs(actors:findAll()) do
            if self:isValid() and self:collidesWith(actor, self.x, self.y) then
                if actor:get("team") ~= self:get("team") and not data.hitEnemies[actor] then
                    data.hitEnemies[actor] = true
                    if data.parent then
                        data.parent:fireExplosion(self.x, self.y, 0.25, 1, 1, nil, nil)
                    else
                        local impact = misc.fireExplosion(self.x, self.y, 0.25, 1, 19 * misc.director:get("enemy_buff"), self:get("team"), nil, nil)
                    end
                end
            end
        end
        if self:collidesMap(self.x,self.y) then
            if self:get("bounceCount") <= 0 then
                self:set("bounce", 0)
            end
            local _vx = (self:get("vx") or 0)
            local _vy = (self:get("vy") or 0)
            if self:get("bounce") > 0 then
                self.x = self.x - _vx
                self.y = self.y - _vy
            else
                self.x = self.x - (self.mask.width/4)
                self.y = self.y - (self.mask.height/4)
            end
            local _vcollision = self:collidesMap(self.x, self.y + _vy)
            local _hcollision = self:collidesMap(self.x + _vx, self.y)
            if (not _hcollision) and (not _vcollision) then
                self:set("vx", - _vx * self:get("bounce"))
                self:set("vy", - _vy * self:get("bounce"))
            elseif _vcollision then
                self:set("vy", - _vy * self:get("bounce"))
            elseif _hcollision then
                self:set("vx", - _vx * self:get("bounce"))
            end
            if self:get("bounceCount") > 0 then
                self:set("bounceCount", self:get("bounceCount") - 1)
            end
            if self:get("bounce") <= 0 then
                sounds.impact:play(0.9 + math.random() * 0.3)
                if data.parent then
                    data.parent:fireExplosion(self.x, self.y, 0.25, 1, 1, nil, nil)
                else
                    local impact = misc.fireExplosion(self.x, self.y, 0.25, 1, 19 * misc.director:get("enemy_buff"), self:get("team"), nil, nil)
                end
                self:set("life", spikeDecayTime)
                self:set("activity", 4)
            end
        end
    elseif self:get("activity") == 4 then --Stationary, counting down until death
        if self:get("life") <= 0 or spikesCount >= maxSpikes then
            self.xscale = self.xscale - 0.1
            self.yscale = self.yscale - 0.1
            if self.xscale <= 0 then
                spikesCount = spikesCount - 1
                self:destroy()
            end
        else
            self:set("life", self:get("life") - 1)
        end
    end
end)


bell:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Brass Contraption"
    self.maxhp = 300 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 19 * Difficulty.getScaling("damage")
    self.pHmax = 0.65
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.walk,
        death = sprites.death,
		palette = sprites.palette
    }
    self.sound_hit = sounds.hit.id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.health_tier_threshold = 3
    self.knockback_cap = self.maxhp
    self.exp_worth = 10
    self.can_drop = 0
    self.can_jump = 0
    --self.flying = 1
end)

Monster.giveAI(bell)

Monster.setSkill(bell, 1, 400, 7 * 60, function(actor)
	local actorAc = actor:getAccessor()
	actorAc.state = "chase"
	for i=0, 2 do
		local spike = spikeBall:create(actor.x, actor.y)
		local data = spike:getData()
		data.parent = actor
		data.target = Object.findInstance(actorAc.target)
		if actor:getElite() == EliteType.find("Frenzied", "vanilla") then
			spike:set("bounce", 0.5)
			spike:set("bounceCount", 3)
		end
		data.team = actorAc.team
		spike:set("sound", i)
		spike:set("delay", 30 + 15 * i)
		spike:set("activity", 0)
		if i == 0 then
			spike:set("xOff", 10):set("yOff", -15)
		elseif i == 1 then
			spike:set("xOff", 0):set("yOff", -25)
		elseif i == 2 then
			spike:set("xOff", -10):set("yOff", -15)
		end
	end
	Monster.activateSkillCooldown(actor, 1)
end)


local monsCard = MonsterCard.new("Brass Contraption", bell)
monsCard.sprite = sprites.idle
monsCard.sound = sounds.spawn
monsCard.canBlight = false
monsCard.isBoss = false
monsCard.type = "classic"
monsCard.cost = 65
for _, elite in ipairs(EliteType.findAll("vanilla")) do
    monsCard.eliteTypes:add(elite)
end
for _, elite in ipairs(EliteType.findAll("RoR2Demake")) do
    monsCard.eliteTypes:add(elite)
end

local stages = {
    Stage.find("Ancient Valley"),
    Stage.find("Sunken Tomb"),
}

AddMCardToStages(monsCard,stages)


local monsLog = MonsterLog.new("Brass Contraption")
MonsterLog.map[bell] = monsLog

monsLog.displayName = "Brass Contraption"
monsLog.story = "I heard what sounded like a bell ringing behind me as I trudged up the wetland hill. I had barely enough time to duck as a spiked metal ball, at least the size of a standard basketball, whizzed over my head and punched through a tree, toppling it. Turning around, I saw the culprit- some form of machine held together by an invisible force. Electromagnetism, perhaps?\n\nI didn't have much time to find out. Hurling spiked artillery at me, the contraption glided along the ground, giving it exceptional mobility on top of its incredible destructive power.\n\nThe brass-like alloy that forms their hulls is a god send. I've been able to construct rudimentary shelters, and even repairs bits of my suit. However, despite its use, obtaining it means I must face more of those horrifying contraptions..."
monsLog.statHP = 300
monsLog.statDamage = 19
monsLog.statSpeed = 0.8
monsLog.sprite = sprites.walk
monsLog.portrait = sprites.idle