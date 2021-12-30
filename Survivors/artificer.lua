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
		--[[elseif skill == 2 then
			player:survivorActivityState(2, sprShoot2, 0.25, true, true)]]--
		elseif skill == 3 then
			player:survivorActivityState(3, player:getAnimation("shoot3"), 0.25, true, true)
		elseif skill == 4 then
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
    if player:get("moveUpHold") == 1 and player:get("free") == 1 and playerData.geyser <= 0 then
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
      -- Get ready for it
      if hit:hasBuff(ignite[1]) then
        hit:removeBuff(ignite[1])
        hit:applyBuff(ignite[2], 4 * 60)
      elseif hit:hasBuff(ignite[2]) then
        hit:removeBuff(ignite[2])
        hit:applyBuff(ignite[3], 4 * 60)
      elseif hit:hasBuff(ignite[3]) then
        hit:removeBuff(ignite[3])
        hit:applyBuff(ignite[4], 4 * 60)
      elseif hit:hasBuff(ignite[4]) then
        hit:removeBuff(ignite[4])
        hit:applyBuff(ignite[5], 4 * 60)
      elseif hit:hasBuff(ignite[5]) then
        hit:removeBuff(ignite[5])
        hit:applyBuff(ignite[6], 4 * 60)
      elseif hit:hasBuff(ignite[6]) then
        hit:removeBuff(ignite[6])
        hit:applyBuff(ignite[7], 4 * 60)
      elseif hit:hasBuff(ignite[7]) then
        hit:removeBuff(ignite[7])
        hit:applyBuff(ignite[8], 4 * 60)
      else
        if not hit:hasBuff(ignite[8]) then
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

-- Skill Code
arti:addCallback("onSkill", function(player, skill, relevantFrame)
  if skill == 1 then
    local playerAc = player:getAccessor() -- "Agile"
    playerAc.pHspeed = math.approach(playerAc.pHspeed, 0, 0.025)
    if playerAc.moveRight == 1 then
      playerAc.pHspeed = playerAc.pHmax
    elseif playerAc.moveLeft == 1 then
      playerAc.pHspeed = -playerAc.pHmax
    end
    if relevantFrame == 2 then
      sndShoot1:play(0.8 + math.random() * 0.2, 1)
      local newFlameBolt = objFlameBolt:create(player.x, player.y)
      newFlameBolt:getData().parent = player
      newFlameBolt:getData().team = player:get("team")
      if player:getData().envSuit >= 15 then
        newFlameBolt:getData().angle = 270
      else
        newFlameBolt:getData().angle = player:getFacingDirection()
      end
    end
  elseif skill == 4 then
    local playerAc = player:getAccessor() -- "Agile"
    playerAc.pHspeed = math.approach(playerAc.pHspeed, 0, 0.025)
    if playerAc.moveRight == 1 then
      playerAc.pHspeed = playerAc.pHmax
    elseif playerAc.moveLeft == 1 then
      playerAc.pHspeed = -playerAc.pHmax
    end
    for i = 0, player:get("sp") do
      -- particle
      local bullet = player:fireBullet(player.x, player.y - 2, player:getData().flamethrowerDirection, 60, 0.1 * player:get("attack_speed"), nil, DAMAGER_BULLET_PIERCE)
      if math.chance(50) then
        bullet:getData().doIgnite = true
      end
      if not sndShoot4_loop:isPlaying() then
        sndShoot4_loop:play()
      end
      if i ~= 0 then
        bullet:set("climb", i * 8)
      end
    end
    if player.subimage > player.sprite.frames - 1 and player:getData().flamethrowerLoops ~= 0 then
      player.subimage = 1
      player:getData().flamethrowerLoops = player:getData().flamethrowerLoops - 1
    end
  end -- elseif
end)
