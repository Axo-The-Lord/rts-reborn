-- Artiicer
-- This file likely has a lot of comments lol

local path = "Survivors/artificer/"

local arti = Survivor.new("Artificer")

local baseSprites = {
	idle = Sprite.load("arti_idle", path.."idle.png", 1, 4, 7),
	walk = Sprite.load("arti_walk", path.."walk.png", 1, 4, 7),
	jump = Sprite.load("arti_jump", path.."jump.png", 1, 5, 8),
	climb = Sprite.load("arti_climb", path.."climb.png", 2, 4, 5),
	death = Sprite.load("arti_death", path.."death.png", 6, 7, 8), -- Seven ate Nine
	decoy = Sprite.load("arti_decoy", path.."decoy.png", 1, 8, 11),
	shoot1_1 = Sprite.load("arti_shoot1", path.."shoot1_1.png", 4, 3, 7),
	shoot1_2 = Sprite.load("arti_shoot1_2", path.."shoot1_2.png", 4, 5, 8),
	shoot2_charge = Sprite.load("arti_shoot2_charge", path.."shoot2_charge", 8, 4, 7),
	shoot2_fire = Sprite.load("arti_shoot2_fire", path.."shoot2_fire", 6, 4, 7),
	shoot3 = Sprite.load("arti_shoot3", path.."shoot3.png", 8, 8, 8),
	shoot4_1 = Sprite.load("arti_shoot4", path.."shoot4_1.png", 2, 3, 6),
	shoot4_2 = Sprite.load("arti_shoot4_2", path.."shoot4_2.png", 2, 5, 6),
	shoot4_3 = Sprite.load("arti_shoot4_3", path.."shoot4_3.png", 2, 3, 6)
}

local sprSkills = Sprite.load("arti_skills", path.."skills.png", 4, 0, 0)
local sprBolt = Sprite.load("flameBolt", path.."bolt.png", 4, 12, 4)
local sprBoltMask = Sprite.load("flameBoltMask", path.."boltMask.png", 1, 12, 4)
local sprFirey = Sprite.find("EfFirey", "vanilla")
local sprIgnite = Sprite.load("igniteBuff", path.."ignite.png", 8, 10, 8)

local sndEnvSuit = Sound.load("arti_env", path.."envSuit.ogg") -- Should honestly make a table...
local sndShoot1 = Sound.load("arti_shoot1", path.."shoot1.ogg")
local sndShoot1_impact = Sound.load("arti_shoot1_impact", path.."shoot1_impact.ogg")
local sndShoot2 = Sound.load("arti_shoot2", path.."shoot2.ogg")
local sndShoot2_impact = Sound.load("arti_shoot2_impact", path.."shoot2_impact.ogg")
local sndShoot4_start = Sound.load("arti_shoot4_start", path.."shoot4_start.ogg")
local sndShoot4_loop = Sound.load("arti_shoot4_loop", path.."shoot4_loop.ogg")
local sndShoot4_end = Sound.load("arti_shoot4_end", path.."shoot4_end.ogg")

arti:setLoadoutInfo(
[[&y&Artificer&!& is a high burst damage survivor who excels in &y&fighting large groups
and bosses alike&!&.
&b&Frozen enemies&!& are &y&executed at low health&!&, making it great to eliminate tanky enemies.
Remember that Artificer has &y&NO defensive skills&!& - positioning and defensive items are key!]], sprSkills
)

arti:setLoadoutSkill(1, "Flame Bolt",
[[Fire a bolt for &y&220% damage&!& that &r&ignites&!& enemies. Hold up to 4.
Firing while hovering with the &y&ENV Suit&!& will aim the bolt &y&downward&!&.]])
arti:setLoadoutSkill(2, "Charged Nano-Bomb",
[[Charge up an &y&exploding&!& nano-bomb that deals &y&400%-2000%&!& damage.]])
arti:setLoadoutSkill(3, "Snapfreeze",
[[Create a barrier that hurts and &b&freezes&!& enemies for &y&100%&!& damage.]])
arti:setLoadoutSkill(4, "Flamethrower",
[[&r&Burn&!& all enemies in front of you for &y&1700% damage&!&.]])

arti.loadoutColor = Color.fromHex(0xf7c1fd)
arti.loadoutSprite = Sprite.load(path.."select.png", 4, 2, 0)
arti.titleSprite = baseSprites.walk
arti.endingQuote = "..and so she left, in love with a new passion: to explore."
callback.register("postLoad", function()
	if modloader.checkMod("Starstorm") then
		SurvivorVariant.setInfoStats(SurvivorVariant.getSurvivorDefault(arti), {{"Strength", 6}, {"Vitality", 5}, {"Toughness", 3}, {"Agility", 9}, {"Difficulty", 8}, {"Curiosity", 9}})
		SurvivorVariant.setDescription(SurvivorVariant.getSurvivorDefault(arti), "With the intense belief that heaven is a planet, not a mystical place, the Artificer searches deep into space for the Promised Land.")
	end
end)

arti:addCallback("init", function(player)
	Ability.addCharge(player, "z", 3) -- 4 flame bolts
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(110, 12, 0.017)
	player:setSkill(1,
		"Flame Bolt",
		"Fire a bolt for 220% damage that ignites enemies. Hold up to 4.",
		sprSkills, 1,
		1 * 60
	)
	player:setSkill(2,
		"Charged Nano-Bomb",
		"Charge up an exploding nano-bomb that deals 400%-2000% damage.",
		sprSkills, 2,
		5 * 60
	)
	player:setSkill(3,
		"Snapfreeze",
		"Create a barrier that hurts and freezes enemies for 100% damage.",
		sprSkills, 3,
		12 * 60
	)
	player:setSkill(4,
		"Flamethrower",
		"Burn all enemies in front of you for 1700% damage.",
		sprSkills, 4,
		5 * 60
	)
end)

arti:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(33, 2.4, 0.003, 20)
end)

arti:addCallback("useSkill", function(player, skill)
	if player:get("activity") == 0 then
		if skill == 1 then
			if player:get("moveLeft") + player:get("moveRight") > 0 then
				player:survivorActivityState(1, player:getAnimation("shoot1_2"), 0.25, true, true)
			else
				player:survivorActivityState(1, player:getAnimation("shoot1_1"), 0.25, true, true)
			end
		elseif skill == 2 then
			player:getData().charge = nil
			player:survivorActivityState(2.1, player:getAnimation("shoot2_charge"), 0.06, true, true)
		elseif skill == 3 then
			player:survivorActivityState(3, player:getAnimation("shoot3"), 0.25, true, true)
		elseif skill == 4 then
            player:getData().timer = 0
			player:getData().flamethrowerDirection = player:getFacingDirection()
			player:getData().flamethrowerLoops = 100
			sndShoot4_start:play(0.8 + math.random() * 0.2)
			if player:get("moveLeft") + player:get("moveRight") > 0 then
				player:survivorActivityState(4, player:getAnimation("shoot4_2"), 0.25, false, true)
			else
				player:survivorActivityState(4, player:getAnimation("shoot4_1"), 0.25, false, true)
			end
		end
		player:activateSkillCooldown(skill)
	end
end)

-- ENV Suit
local envParticle = ParticleType.new("jetpack")
envParticle:shape("Disc")
envParticle:color(Color.fromRGB(255,239, 182), Color.fromRGB(205, 100, 50), Color.fromRGB(163, 0, 1))
envParticle:alpha(1, 0)
envParticle:additive(true)
envParticle:size(0.05, 0.05, -0.001, 0)
envParticle:life(30, 30)
envParticle:speed(1, 1, 0, 0)
envParticle:direction(270, 270, 0, 0)

callback.register("onPlayerStep", function(player)
	local playerData = player:getData()
	if player:getSurvivor() == arti then
		if playerData.geyser then
			if player:collidesWith(Object.find("Geyser","vanilla"), player.x, player.y) and playerData.geyser <= 0 then
				playerData.geyser = 30
			end
			if playerData.geyser > 0 then
				playerData.geyser = playerData.geyser - 1
			end
		else
			playerData.geyser = 0
		end
		if player:get("activity") ~= 30 and player:get("moveUpHold") == 1 and player:get("free") == 1 and playerData.geyser <= 0 then
			playerData.envSuit = playerData.envSuit + 1
			if playerData.envSuit == 15 then
				sndEnvSuit:play(0.8 + math.random() * 0.2, 0.7)
			end
			if playerData.envSuit >= 15 then
				player:set("pVspeed", 0)
				if playerData.envSuit % 5 == 0 then
					envParticle:burst("middle", player.x - (2 * player.xscale), player.y, 1)
					envParticle:burst("middle", player.x + (1 * player.xscale), player.y, 1)
					player:set("pVspeed", player:get("pGravity1"))
				end
			end
		else
			playerData.envSuit = 0
        end
	end
end)

-- Ignite (Debuff)
local igniteStacks = 8
local ignite = {}
for i = 1, igniteStacks do
	ignite[i] = Buff.new("ignite"..i)
	ignite[i].sprite = sprIgnite
	ignite[i].subimage = i

	ignite[i]:addCallback("start", function(actor) -- Altzeus you are cool
		actor:getData().igniteTimer = 1
	end)
	ignite[i]:addCallback("step", function(actor)
		if actor:getData().igniteTimer == 0 then
			if not actor:get("invincible") or actor:get("invincible") <= 0 then
				local damageDone = math.ceil((actor:getData().igniteParent:get("damage") * .25 * i) * (100 / (100 + actor:get("armor"))))
				if misc.getOption("video.show_damage") == true and damageDone > 0 then
					misc.damage(damageDone, actor.x - 4, actor.y - 10, false, Color.ROR_ORANGE)
				end
				actor:set("hp", actor:get("hp") - damageDone)
			end
			ParticleType.find("Fire4", "vanilla"):burst("above", actor.x, actor.y, i)
			actor:getData().igniteTimer = 30
		else
			actor:getData().igniteTimer = math.approach(actor:getData().igniteTimer, 0, 1)
		end
	end)
end

-- Flame Bolt (Object)
local objFlameBolt = Object.new("flameBolt")
objFlameBolt.sprite = sprBolt
objFlameBolt:addCallback("create", function(self)
	local selfAc = self:getAccessor()
	local selfData = self:getData()
	self.mask = sprBoltMask
	selfData.life = 2 * 60
	self.spriteSpeed = 0.25
	selfData.speed = 5
	self.xscale = 1
	self.yscale = 1
	selfData.angle = 0
end)
objFlameBolt:addCallback("step", function(self)
	local selfAc = self:getAccessor()
	local selfData = self:getData()
	local enemy = ParentObject.find("enemies", "vanilla"):findNearest(self.x, self.y)
	local parent = selfData.parent
	self.angle = selfData.angle
	local angle = math.rad(selfData.angle)

	self.x = self.x + math.cos(angle) * selfData.speed -- AnAwesomeDude living up to her name once again
	self.y = self.y - math.sin(angle) * selfData.speed

	if math.chance(30) then
		ParticleType.find("Spark", "vanilla"):burst("middle", self.x, self.y, 1)
	end

	if (enemy and enemy:isValid() and self:collidesWith(enemy, self.x, self.y)) or self:collidesMap(self.x, self.y) or selfData.life == 0 then
		if selfData.parent then
			local hit = selfData.parent:fireExplosion(self.x, self.y, 8 / 19, 4 / 4, 2.2, sprFirey, nil)
			hit:getData().doIgnite = true
			sndShoot1_impact:play(0.8 + math.random() * 0.2, 1)
			selfData.life = 0
		end
	end
	if selfData.life == 0 then
		self:destroy()
	else
		selfData.life = selfData.life - 1
	end
end)

callback.register("preHit", function(damager, hit)
	local parent = damager:getParent()
	if parent and parent:isValid() and hit and hit:isValid() then
		if damager:getData().doIgnite == true then
			hit:getData().igniteParent = parent
            local hasUp
            for i = 1, 7 do
                if hit:hasBuff(ignite[i]) then
                    hit:removeBuff(ignite[i])
                    hit:applyBuff(ignite[i + 1], 4 * 60)
                    hasUp = true
                    break
                end
            end
            if not hasUp then
                if hit:hasBuff(ignite[8]) then
                    hit:applyBuff(ignite[8], 4 * 60)
                else
                    hit:applyBuff(ignite[1], 4 * 60)
                end
            end
		end
	end
end)

-- Flamethrower (Particle)
local specialFire = ParticleType.new("flamethrower")
specialFire:sprite(sprFirey, true, true, false)
specialFire:alpha(1)
specialFire:scale(1, 1)
specialFire:size(0.8, 1.2, 0.01, 0.02)
specialFire:angle(0, 360, 0.01, 0.02, false)
specialFire:life(45, 60)

-- Nano Bomb object
local objNanoBomb = Object.new("ArtificerNanoBomb")
objNanoBomb.sprite = sprBolt
objNanoBomb:addCallback("create", function(self)
	local selfData = self:getData()

	selfData.direction = 0
	selfData.life = 600
	selfData.parent = nil
	self.mask = boltMask
	self.angle = 0
	selfData.charge = 0
	selfData.gravity = 0.015
	selfData.vSpeed = 0
	selfData.team = "player"
	selfData.damage = 12
	self.sprite = Sprite.find("Nothing")
	self.mask = Sprite.find("Pixel")
end)
objNanoBomb:addCallback("step", function(self)
	local selfData = self:getData()

	self.x = self.x + math.cos(math.rad(selfData.direction)) * 2
	self.y = self.y - math.sin(math.rad(selfData.direction)) * 2

	--self.angle = selfData.direction
	--selfData.direction = selfData.direction - angleDif(selfData.direction, 270) * 0.01
	self.y = self.y + selfData.vSpeed
	selfData.vSpeed = selfData.vSpeed + selfData.gravity

	if self:collidesMap(self.x, self.y) or selfData.life == 0 then
		if selfData.parent then
			selfData.parent:fireExplosion(self.x, self.y, 30/19, 30/4, 2)
			for i = 1, 3 do
				Object.find("ChainLightning"):create(self.x, self.y):set("parent", selfData.parent.id):set("team", selfData.team):set("damage", math.ceil(selfData.damage)):set("bounce", 2)
			end
			--Sound.find("ChainLightning"):play((0.9 / self.xscale) + math.random() * 0.2)
			sndShoot2_impact:play(0.9 + math.random() * 0.2, 0.8)
		end
		self:destroy()
	else
		selfData.life = selfData.life - 1
	end

	if self:isValid() and selfData.parent then
		local r = 20
		local actors = ParentObject.find("actors"):findAllEllipse(self.x - r, self.y - r, self.x + r, self.y + r)
		for _, actor in ipairs(actors) do
			if self:collidesWith(actor, self.x, self.y) and actor:get("team") ~= selfData.parent:get("team") then
				selfData.parent:fireExplosion(self.x, self.y, 30/19, 30/4, 2)
				for i = 1, 3 do
					Object.find("ChainLightning"):create(self.x, self.y):set("parent", selfData.parent.id):set("team", selfData.team):set("damage", math.ceil(selfData.damage)):set("bounce", 2)
				end
				--Sound.find("ChainLightning"):play((0.9 / self.xscale) + math.random() * 0.2)
				sndShoot2_impact:play(0.9 + math.random() * 0.2, 0.8)
				self:destroy()
				break
			end
		end
	end

	if self:isValid() and selfData.parent and selfData.charge > 6 and selfData.life % 20 == 0 then
		selfData.targets = {}
		local r = 70 * self.xscale
		local actors = ParentObject.find("actors"):findAllEllipse(self.x - r, self.y - r, self.x + r, self.y + r)
		for _, actor in ipairs(actors) do
			if actor:get("team") ~= selfData.parent:get("team") then
				selfData.parent:fireBullet(self.x, self.y, 0, 1, 1):set("specific_target", actor.id)
				local angle = {
				ang = posToAngle(self.x, self.y, actor.x, actor.y)+ math.random(-45, 45) * 2,
				amp1 = math.random(2, 5) / 2,
				amp2 = math.random(2, 5) / 2
				}
				selfData.targets[actor] = angle
			end
		end
	end
end)
objNanoBomb:addCallback("draw", function(self)
	local selfData = self:getData()
	
	graphics.alpha(1)
	graphics.color(Color.fromHex(0x7EB7FF))
	graphics.circle(self.x, self.y, 2 + self.xscale * 3 + math.random(3), false)
	graphics.alpha(1)
	graphics.color(Color.fromHex(0x0014A9))
	graphics.circle(self.x, self.y, self.xscale * 3 + math.random(2), false)
	
	if selfData.targets then
		for actor, angle in pairs(selfData.targets) do
			if actor:isValid() then
				local dis = distance(self.x, self.y, actor.x, actor.y)
				local xy1 = {x = self.x, y = self.y}
				local xy4 = {x = actor.x, y = actor.y}
				xy2 = {x = xy1.x + math.cos(math.rad(angle.ang)) * dis / angle.amp1, y = xy1.y - math.sin(math.rad(angle.ang)) * dis / angle.amp1}
				xy3 = {x = xy4.x + math.cos(math.rad(angle.ang)) * dis / angle.amp2, y = xy4.y - math.sin(math.rad(angle.ang)) * dis / angle.amp2}
				graphics.color(Color.LIGHT_BLUE)
				graphics.alpha((selfData.life % 20)^2 / 20^2)
				local points = createCubicCurve(xy1, xy2, xy3, xy4, dis)
				for i = 1, dis do
					graphics.pixel(points[i].x, points[i].y)
				end
			end
		end
	end
end)

-- ice object
local objIce = Object.new("ArtificerIceObject")
local iceMask = Sprite.load("ArtificerIceMask", path.."iceMask", 1, 0, 0)
local iceSpriteSpawn = Sprite.load("ArtificerIceSpawn", path.."iceSpawn", 4, 2, 7)
local iceSpriteIdle = Sprite.load("ArtificerIceIdle", path.."iceIdle", 7, 4, 0)
local iceSpriteDeath = Sprite.load("ArtificerIceDeath", path.."iceDeath", 7, 2, 3)
objIce.sprite = iceSpriteIdle
objIce:addCallback("create", function(self)
	local selfData = self:getData()
	self.mask = iceMask
	self.sprite = iceSpriteSpawn
	self.spriteSpeed = 0.24
	selfData.iceTotal = 0
	selfData.damageDelay = {}
end)
objIce:addCallback("step", function(self)
	if not self:collidesMap(self.x, self.y + 1) then
		local a = 0
		while a < 500 do
			if not self:collidesMap(self.x, self.y + 1) then
				self.y = self.y + 1
			else
				break
			end
		end
	end

	local selfData = self:getData()

	if self:isValid() and self.sprite == iceSpriteSpawn and self.subimage > self.sprite.frames - 2 and selfData.iceTotal > 0 then
		local ice = objIce:create(self.x + self.xscale * 12, self.y - 5)
		ice.xscale = self.xscale
		ice:getData().parent = selfData.parent
		ice:getData().iceTotal = selfData.iceTotal - 1
		selfData.iceTotal = 0
	end
	if self:isValid() and self.sprite == iceSpriteSpawn and self.subimage > self.sprite.frames - 1 then
		self.sprite = iceSpriteIdle
		self.subimage = 1
		selfData.life = 240
	end

	if self:isValid() and self.sprite == iceSpriteIdle then
		if selfData.parent then --and selfData.life % 5 == 0 then
			local r = 20
			local actors = ParentObject.find("actors"):findAllEllipse(self.x - r, self.y - r, self.x + r, self.y + r)
			for _, actor in ipairs(actors) do
				if actor:isValid() and actor:get("team") ~= selfData.parent:get("team") then
					if actor:get("frozen") == 0 then
						--selfData.parent:fireBullet(self.x, self.y, 0, 1, 1):set("specific_target", actor.id)
						--actor:getData().hitIce = selfData.life--40
						actor:set("frozen", 1)
						actor:setAlarm(7, selfData.life)
						actor:setAlarm(2, selfData.life)
						actor:setAlarm(3, selfData.life)
						actor:setAlarm(4, selfData.life)
						actor:setAlarm(5, selfData.life)
						actor:getData().icePos = actor.x
					else
						if actor:getData().icePos then
							actor.x = actor:getData().icePos
						end
						actor:set("pHspeed", 0)
					end
				end
			end
		end

		selfData.life = selfData.life - 1
		if selfData.life == 0 then
			self.sprite = iceSpriteDeath
			self.subimage = 1
		end
	end

	if self:isValid() and self.sprite == iceSpriteDeath and self.subimage > self.sprite.frames - 1 then
		self:destroy()
	end
end)


-- Skill Code
arti:addCallback("onSkill", function(player, skill, relevantFrame)
	local playerAc = player:getAccessor()
	local playerData = player:getData()
	if skill == 1 then -- "Agile"
		playerAc.pHspeed = math.approach(playerAc.pHspeed, 0, 0.025)
        local dir = playerAc.moveRight - playerAc.moveLeft
		playerAc.pHspeed = playerAc.pHmax * dir
		if relevantFrame == 2 then
			sndShoot1:play(0.8 + math.random() * 0.2, 1)
			local newFlameBolt = objFlameBolt:create(player.x, player.y)
			newFlameBolt:getData().parent = player
			newFlameBolt:getData().team = player:get("team")
			if player:getData().envSuit >= 15 then
				newFlameBolt:getData().angle = 270 + player.xscale * 30
                local angle2 = 270 + player.xscale * 30 + 30
                local angle1 = 270 + player.xscale * 30 - 30
                for i = angle1, angle2 do
                    local actors = ParentObject.find("actors"):findAllLine(player.x, player.y, player.x + math.cos(math.rad(i)) * 200, player.y - math.sin(math.rad(i)) * 200)
                    local stop = false
                    for _, actor in ipairs(actors) do
                        if actor:isValid() and actor:get("team") ~= player:get("team") then
                            newFlameBolt:getData().angle = i
                            stop = true
                            break
                        end
                    end
                    if stop then
                        break
                    end
                end
            else
                newFlameBolt:getData().angle = player:getFacingDirection()
			end
		end
	elseif skill == 2.1 then
        playerAc.pHspeed = math.approach(playerAc.pHspeed, 0, 0.025)
        local dir = playerAc.moveRight - playerAc.moveLeft
        playerAc.pHspeed = playerAc.pHmax * 0.75 * dir
        if syncControlRelease(player, "ability2") then
            playerData.charge = math.floor(player.subimage)
            player.subimage = player.sprite.frames - 1
        end
		if relevantFrame == 1 then
			sndShoot2:play(0.9 + math.random() * 0.2)
		end
        if player.subimage > player.sprite.frames - 1 then
            player:set("activity", 0)
            if not playerData.charge then
                playerData.charge = 8
            end
            player:survivorActivityState(2.2, player:getAnimation("shoot2_fire"), 0.25, true, true)
        end
    elseif skill == 2.2 then
        if relevantFrame == 3 then
			sndShoot2:stop()
            local bullet = objNanoBomb:create(player.x + player.xscale * 5, player.y)
            local dir = player.xscale
            bullet:getData().parent = player
            bullet.xscale = 1 + (playerData.charge / 8)
            bullet.yscale = 1 + (playerData.charge / 8)
            bullet:getData().direction = player:getFacingDirection() + (playerData.charge * 4) * dir
			bullet:getData().team = playerAc.team
			bullet:getData().damage = playerAc.damage 
            bullet.angle = bullet:getData().direction
            bullet:getData().charge = playerData.charge
        end
    elseif skill == 3 then
        local dir = playerAc.moveRight - playerAc.moveLeft
        playerAc.pHspeed = playerAc.pHmax * 0.75 * dir
        if relevantFrame == 4 then
            local ice = objIce:create(player.x + player.xscale * 10, player.y - 5)
            ice.xscale = player.xscale
            ice:getData().parent = player
            ice:getData().iceTotal = 5 * (playerAc.sp + 1)
        end
    elseif skill == 4 then -- "Agile"
        playerAc.pHspeed = math.approach(playerAc.pHspeed, 0, 0.025)
        local dir = playerAc.moveRight - playerAc.moveLeft
		playerAc.pHspeed = playerAc.pHmax * dir * 0.75
        if playerData.timer % 12 == 0 then
            for i = 0, player:get("sp") do
                -- particle
                local bullet = player:fireBullet(player.x, player.y - 2, player:getData().flamethrowerDirection, 60, 0.25, nil, DAMAGER_BULLET_PIERCE)
                bullet:set("damage_degrade", 0.5)
                if math.chance(50) then
                    bullet:getData().doIgnite = true
                end
                --if not sndShoot4_loop:isPlaying() then
                --    sndShoot4_loop:play()
                --end
                if i ~= 0 then
                    bullet:set("climb", i * 8)
                end
            end
			local fire = Object.find("EfSparks"):create(player.x + 5 * player.xscale, player.y - 1)
			fire.sprite = Sprite.find("PyroFire")
			fire.xscale = player.xscale
        end
        if player.subimage > player.sprite.frames - 1 then 
			if player:getData().flamethrowerLoops == 0 then
				sndShoot4_end:play(0.9 + math.random() * 0.2, 0.8)
			else
				player.subimage = 1
				player:getData().flamethrowerLoops = player:getData().flamethrowerLoops - 1
			end
        end
        playerData.timer = playerData.timer + 1
    end -- elseif
end)

--[[callback.register("onActorStep", function(actor)
	if actor:isValid() and actor:getData().hitIce then
		actor:getData().hitIce = actor:getData().hitIce - 1
		if actor:getData().hitIce == 0 then
			actor:getData().hitIce = nil
		end
	end
end)]]

callback.register("onPlayerHUDDraw", function(player, x, y)
	local cd = math.min(player:get("z_alarm"), Ability.getCooldown(player, "z")) --this sucks but i dont fully understand the ability charge lib, why is there no function to get individual charge cooldown?
	if player:getSurvivor() == arti and cd > 0 then
		local t = math.ceil(cd / 60)
		graphics.alpha(0.7)
		graphics.color(Color.BLACK)
		graphics.rectangle(x, y, x + 17, y + 17, false)
		graphics.alpha(1)
		graphics.color(Color.WHITE)
		graphics.print(t, x + 9, y + 2, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_TOP)
	end
end)