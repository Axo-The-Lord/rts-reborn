local path = "Actors/roboball/"

local sprites = {
    idle = Sprite.load("RoboBallIdle", path.."idle", 1, 25, 25),
    idleS = Sprite.load("RoboBallSIdle", path.."superIdle", 1, 29, 41),
    turn = Sprite.load("RoboBallTurn", path.."turn", 7, 25, 25),
    turnS = Sprite.load("RoboBallSTurn", path.."turnSuper", 7, 25, 25),
    shoot1 = Sprite.load("RoboBallShoot1", path.."shoot1", 7, 25, 25),
    death = Sprite.load("RoboBallDeath", path.."death", 2, 25, 25),
    deathS = Sprite.load("RoboBallSDeath", path.."deathSuper", 2, 25, 25),
    spawn = Sprite.load("RoboBallSpawn", path.."spawn", 11, 25, 25),
    spawnS = Sprite.load("RoboBallSSpawn", path.."spawnSuper", 11, 25, 25),
    mask = Sprite.load("RoboBallMask", path.."mask", 1, 25, 25),
    charge = Sprite.load("RoboBallReticule", path.."reticule", 2, 16, 16),
    ---------------------------------
    idleP = Sprite.load("RoboBallPIdle", path.."probeIdle", 1, 5, 5),
    maskP = Sprite.load("RoboBallPMask", path.."probeMask", 1, 16, 15),
    glowP = Sprite.load("RoboBallPGlow", path.."probeFlash", 1, 5, 5),
    deathP = Sprite.load("RoboBallPDeath", path.."probeDeath", 7, 15, 17),
    ---------------------------------
    palette = Sprite.load("RoboBallPal", path.."palette", 1, 0,0),
    sparks = Sprite.find("Sparks2", "vanilla"),
    sparks1 = Sprite.load("RoboBallSparks1", path.."Sparks1", 5, 21, 20),
    sparks2 = Sprite.load("RoboBallSparks2", path.."sparks2", 7, 56, 42),
    sparks3 = Sprite.load("RoboBallSparks3", path.."sparks3", 5, 15, 16),
}

local sounds = {
    death = Sound.load("RoboBallDeath", path.."death.ogg"),
    deployProbe = Sound.load("RoboBallMSpawn", path.."deployProbe.ogg"),
    hit = Sound.load("RoboBallHit", path.."hit.ogg"),
    bulletImpact = Sound.load("RoboBallBulletImpact", path.."impact.ogg"),
    probeDeath = Sound.load("RoboBallMDeath", path.."probeDeath.ogg"),
    shoot1_1 = Sound.load("RoboBallShoot1_1", path.."windup.ogg"),
    shoot1_2 = Sound.load("RoboBallShoot1_2", path.."shoot1.ogg"),
    shoot2 = Sound.load("RoboBallShoot2", path.."shoot2.ogg"),
    shoot3_1 = Sound.load("RoboBallShoot3_1", path.."ultCharge.ogg"),
    shoot3_2 = Sound.load("RoboBallShoot3_2", path.."shoot3.ogg"),
    spawn = Sound.load("RoboBallSSpawn", path.."superRoboballSpawn.ogg"),
}

local roboball = Object.base("BossClassic", "RoboBall")
roboball.sprite = sprites.idle

local superroboball = Object.base("BossClassic", "RoboBallS")
superroboball.sprite = sprites.idleS

local roboballp = Object.base("EnemyClassic", "RoboBallP")
roboballp.sprite = sprites.idleP

local objects = {
    fireTrail = Object.find("FireTrail", "vanilla"),
    whiteFlash = Object.find("WhiteFlash", "vanilla")
}

local actors = ParentObject.find("actors", "vanilla")

roboballp:addCallback("create", function(actor)
    local actorAc = actor:getAccessor()
    local data = actor:getData()
    actorAc.name = "Solus Probe"
    actorAc.maxhp = 200 * Difficulty.getScaling("hp")
    actorAc.hp = actorAc.maxhp
    actorAc.damage = 15 * Difficulty.getScaling("damage")
    actorAc.armor = 10
    actorAc.pHmax = 0.5
    actorAc.pGravity1 = 0
    actorAc.pGravity2 = 0
    actorAc.yy = 0
    actor.mask = sprites.maskP
    actor:setAnimations{
        idle = sprites.idleP,
        walk = sprites.idleP,
        jump = sprites.idleP,
        death = sprites.deathP,
		palette = sprites.palette
    }
    actorAc.sound_hit = sounds.hit.id
    actorAc.hit_pitch = 2
    actorAc.sound_death = sounds.probeDeath.id
    actorAc.health_tier_threshold = 3
    actorAc.knockback_cap = actorAc.maxhp
    actorAc.facing = 1
    actorAc.rotating = 0
    actorAc.direction = 0
    actorAc.targetDirection = 0
    actorAc.targetAngle = 0
    actorAc.z_range = 100
    actorAc.shake_frame = -1
    actorAc.can_drop = 1
    actorAc.can_jump = 1
    actorAc.z_charge = 0
    actorAc.z_target_x = 0
    actorAc.z_target_y = 0
    actorAc.beam_x = 0
    actorAc.beam_y = 0
    actorAc.moveDown = 0
end)

roboballp:addCallback("step", function(actor)
    local actorAc = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(actorAc.target)
    if misc.getTimeStop() > 0 then
        actorAc.speed = 0
        return
    end
    ------------------------------------------
    if actorAc.state == "chase" or actorAc.state == "attack1" then
        local zz = actorAc.z_range
		for u = 0, zz do
            local xorigin = math.cos(math.rad(actor.angle)) * 4
            local yorigin = math.sin(math.rad(actor.angle)) * 4
			local angle = posToAngle(actor.x + xorigin, actor.y + yorigin, target.x, target.y, true)
			actorAc.z_target_x = actor.x + ((math.cos(angle) * zz) * (u / zz))
			actorAc.z_target_y = actor.y - ((math.sin(angle) * zz) * (u / zz))
			if target:getObject():findLine(actor.x + xorigin, actor.y + yorigin, actorAc.z_target_x, actorAc.z_target_y) or Stage.collidesPoint(actorAc.z_target_x, actorAc.z_target_y) then
				break
			end
		end
        if (target.y < actor.y) then
            actorAc.moveUp = 1
        elseif target.y > actor.y then
            actorAc.moveDown = 1
        else
            actorAc.moveUp = 0
            actorAc.moveDown = 0
        end    
    else
        actorAc.z_target_x = actor.x + ((math.cos(actor.angle) * actorAc.z_range))
        actorAc.z_target_y = actor.y - ((math.sin(actor.angle) * actorAc.z_range))
    end
    actor.xscale = 1
    actorAc.yy = actorAc.yy + (actorAc.pHmax / 10)
    if actorAc.moveUp == 1 then
        actorAc.pVspeed = -math.abs((math.sin(actorAc.yy) / 5))
    elseif actorAc.moveDown == 1 then
        actorAc.pVspeed = math.abs((math.sin(actorAc.yy) / 5))
    else
        actorAc.pVspeed = (math.sin(actorAc.yy) / 5)
    end
    ------------------------------------------
    if actorAc.activity == 0 and actorAc.state ~= "set up" then
        if target and target:isValid() then
            if distance(target.x, target.y, actor.x, actor.y) < actorAc.z_range then
                actorAc.z_skill = 1
            else
                actorAc.z_skill = 0
            end
        end
        ----------------------------------------------------
        if actorAc.z_skill == 1 and actor:getAlarm(2) == -1 and actorAc.z_charge == 0 then
            actorAc.z_charge = 5*60
            actor:setAlarm(2, 10*60)
            actorAc.z_skill = 0
            actorAc.beam_x = actor.x + ((math.cos(actor.angle) * actorAc.z_range))
            actorAc.beam_y = actor.y + ((math.sin(actor.angle) * actorAc.z_range))
            actorAc.state = "attack1"
            return
        end
    end
    ------------------------------------------
    if actorAc.state == "idle" then

    elseif actorAc.state == "chase" then

    elseif actorAc.state == "attack1" then
        if target and target:isValid() then
            --Strafe
            local dist = distance(actor.x, actor.y, target.x, target.y)
            if dist > actorAc.z_range then
                if actor.x > target.x then
                    actorAc.moveLeft = 1
                    actorAc.moveRight = 0
                else
                    actorAc.moveLeft = 0
                    actorAc.moveRight = 1
                end
                
            else
                if actor.x > target.x then
                    actorAc.moveLeft = 0
                    actorAc.moveRight = 1
                else
                    actorAc.moveLeft = 1
                    actorAc.moveRight = 0
                end
            end

        end
        if actorAc.z_charge > 0 then
            actorAc.z_charge = actorAc.z_charge - 1
            actorAc.beam_x = math.approach(actorAc.beam_x, actorAc.z_target_x, actorAc.pHmax)
            actorAc.beam_y = math.approach(actorAc.beam_y, actorAc.z_target_y, actorAc.pHmax)
            if actorAc.z_charge % 15 == 0 then
                actor:fireExplosion(actorAc.beam_x, actorAc.beam_y, 0.1, 0.5, 0.3, sprites.sparks3, nil)
            end
        else
            actorAc.state = "chase"
            return
        end
        
    elseif actorAc.state == "set up" then

    end
end)

roboballp:addCallback("draw", function(actor)
    local actorAc = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(actorAc.target)
    if misc.getTimeStop() == 0 then
        if actorAc.moveDown == 1 then
            actorAc.targetAngle = 270
        end
        if actorAc.moveLeft == 1 then
            actorAc.targetAngle = 180
        end
        if actorAc.moveRight == 1 then
            actorAc.targetAngle = 0
        end
        if actorAc.moveUp == 1 then
            actorAc.targetAngle = 90
        end
        if (target and target:isValid()) and (actorAc.state == "chase" or actorAc.state == "attack1") then
            actorAc.targetAngle = posToAngle(actor.x, actor.y, target.x, target.y)
        end
        actor.angle = math.approach(actor.angle, actorAc.targetAngle, actorAc.pHmax * 5)
    end
    --------------------------------
    actorAc.yy = actorAc.yy + 1
    --------------------------------
    --Draw glow effect
    if actorAc.state == "chase" or actorAc.state == "attack1" then
        graphics.setBlendMode("additive")
        graphics.drawImage{
            image = sprites.glowP,
            x = actor.x,
            y = actor.y,
            alpha = math.sin(actorAc.yy * 0.1),
            angle = actor.angle,
        }
        graphics.setBlendMode("normal")
    end
    --------------------------------
    --Draw beam
    if actorAc.z_charge > 0 then
        local xorigin = math.cos(math.rad(actor.angle)) * -4
        local yorigin = math.sin(math.rad(actor.angle)) * -4
        if actorAc.z_charge % 2 == 0 then
            graphics.color(Color.fromRGB(204, 255, 250))
        else
            graphics.color(Color.fromRGB(255, 255, 201))
        end
        graphics.alpha(0.5)
        graphics.line(actor.x + xorigin, actor.y + yorigin, actorAc.beam_x, actorAc.beam_y, 3 + math.sin(actorAc.yy))
        graphics.alpha(1)
        if actorAc.z_charge % 2 == 0 then
            graphics.color(Color.fromRGB(255, 255, 201))
        else
            graphics.color(Color.fromRGB(204, 255, 250))
        end
        graphics.circle(actor.x + xorigin, actor.y + yorigin, 5+ math.sin(actorAc.yy), true)
        graphics.line(actor.x + xorigin, actor.y + yorigin, actorAc.beam_x, actorAc.beam_y, 1)
    end
end)

local probeLog = MonsterLog.new("Solus Probe")
MonsterLog.map[roboballp] = probeLog

probeLog.displayName = "Solus Probe"
probeLog.story = "These Solus probes attract just as much attention from the other creatures on this planet as I do. The Probes are mining drones by nature, and from a distance I've observed them using their laser tools to chip away at cliffsides, gathering stone and dirt for some unknown purpse. The probes are controlled by an external control unit, and yet I haven't encountered a single one so far. Could these probes have gone beyond their programming, or is the control unit back at the ship, stuck in some rubble?\n\nWhatever the case, the probes are also capable of defending themselves. They must be running on a high-alert protocol, as they zap anyone and anything that approaches... including me."
probeLog.statHP = 220
probeLog.statDamage = 15
probeLog.statSpeed = 0.5
probeLog.sprite = sprites.idleP
probeLog.portrait = sprites.idleP
probeLog.portraitSubimage = 1

local roboBullet = Object.new("RoboBallBullet")
roboBullet:addCallback("create", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    selfAc.f = 0
    selfAc.team = "enemy"
    selfAc.damage = 12
    selfAc.direction = 0
    selfAc.speed2 = 5
end)
roboBullet:addCallback("step", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    if misc.getTimeStop() > 0 then
        selfAc.speed = 0
    else
        selfAc.f = selfAc.f + 1
        selfAc.speed = selfAc.speed2
    end
    local nearest = actors:findNearest(self.x, self.y)
    if Stage.collidesPoint(self.x, self.y) or ((distance(self.x, self.y, nearest.x, nearest.y) < 5) and nearest:get("team") ~= selfAc.team) or selfAc.f > 2*60 then
        self:destroy()
    end
end)
roboBullet:addCallback("destroy", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    local parent = data.parent
    sounds.bulletImpact:play(0.9 + math.random() * 0.1)
    misc.shakeScreen(5)
    if parent and parent:isValid() then
        parent:fireExplosion(self.x, self.y, 1, 1, 1, sprites.sparks3, nil)
        
        if parent:get("elite_type") == 0 then
            local f = objects.fireTrail:create(self.x, self.y)
            f:set("damage", parent:get("damage") * 0.5)
            f:set("team", parent:get("team"))
            f:set("parent", parent.id)
        end
    else
        misc.fireExplosion(self.x, self.y, 1, 1, 10, selfAc.team, sprites.sparks3, nil)
    end
end)
roboBullet:addCallback("draw", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    
    graphics.alpha(0.75)
    if selfAc.f % 2 == 0 then
        graphics.color(Color.fromRGB(255, 255, 201))
    else
        graphics.color(Color.fromRGB(204, 255, 250))
    end
    graphics.circle(self.x, self.y, 5 + math.sin(selfAc.f), false)
    if selfAc.f % 2 == 0 then
        graphics.color(Color.fromRGB(204, 255, 250))
    else
        graphics.color(Color.fromRGB(255, 255, 201))
    end
    graphics.alpha(1)
    graphics.circle(self.x, self.y, 2.5 + math.cos(selfAc.f), false)
    graphics.alpha(0.75)
    graphics.circle(self.x, self.y, 7.5, true)

end)

local ultAOE = 32 --Radius of the Unit'selfAc blast.

local roboBlast = Object.new("RoboBallUlt")
roboBlast:addCallback("create", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    selfAc.f = 0
    selfAc.size = ultAOE
    selfAc.phase = 0
    selfAc.detonate = 5*60
    selfAc.a = 1
    self.y = FindGround(self.x, self.y)
end)
roboBlast:addCallback("step", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    local parent = data.parent
    selfAc.f = selfAc.f + 1
    if selfAc.phase == 0 then
        if selfAc.f > selfAc.detonate then
            misc.shakeScreen(10)
            if not objects.whiteFlash:find(1) then
                objects.whiteFlash:create(self.x, self.y)
            end
            if not sounds.shoot3_2:isPlaying() then
                sounds.shoot3_2:play(0.9 + math.random() * 0.1)
            end
            if parent then
                local exp = parent:fireExplosion(self.x, self.y, selfAc.size / 19, 1, 1, sprites.sparks2, nil)
                exp:set("knockup", 6)
            end
            selfAc.phase = 1
        end
    elseif selfAc.phase == 1 then
        if selfAc.a > 0 then
            selfAc.a = selfAc.a - 0.01
        else
            self:destroy()
            return
        end
    end
    
end)
roboBlast:addCallback("draw", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    if selfAc.phase == 0 then
        if selfAc.f % 2 == 0 then
            graphics.color(Color.fromRGB(255, 255, 201))
        else
            graphics.color(Color.fromRGB(204, 255, 250))
        end
        graphics.alpha(0.5)
        graphics.line(self.x - selfAc.size, self.y, self.x - selfAc.size, self.y - 9999, 1)
        graphics.line(self.x + selfAc.size, self.y, self.x + selfAc.size, self.y - 9999, 1)
        graphics.alpha(math.abs(math.sin((math.pi / selfAc.size) * selfAc.f)))
        for i = -selfAc.size/2, selfAc.size/2 do
            if i % (selfAc.size / 4) == 0 then
                graphics.rectangle((self.x - (((selfAc.size/10) * i))), self.y - ((selfAc.f % selfAc.size) * 0.5), (self.x - ((selfAc.size/10) * i)) + ((selfAc.size/4) * ((selfAc.size - math.abs(i)) / selfAc.size)), self.y - (selfAc.size/2) - ((selfAc.f % selfAc.size) * 0.5))
            end
        end
        if selfAc.f % 2 == 0 then
            graphics.color(Color.fromRGB(204, 255, 250))
        else
            graphics.color(Color.fromRGB(255, 255, 201))
        end
        for i = -ultAOE/2, ultAOE/2 do
            if i % (ultAOE / 4) == 0 then
                graphics.rectangle((self.x - ((selfAc.size/10) * i)), self.y - ((selfAc.f % selfAc.size) * 0.5), (self.x - ((selfAc.size/10) * i)) + ((selfAc.size/4) * ((selfAc.size - math.abs(i)) / selfAc.size)), self.y - (selfAc.size/2) - ((selfAc.f % selfAc.size) * 0.5), true)
            end
        end
    elseif selfAc.phase == 1 then
        if selfAc.f % 2 == 0 then
            graphics.color(Color.fromRGB(255, 255, 201))
        else
            graphics.color(Color.fromRGB(204, 255, 250))
        end
        graphics.alpha(selfAc.a)
        for i = -ultAOE/2, ultAOE/2 do
            if i % (ultAOE / 4) == 0 then
                graphics.rectangle((self.x - (((selfAc.size/10) * i))), self.y - (selfAc.size * (1-selfAc.a)), (self.x - ((selfAc.size/10) * i)) + ((selfAc.size/4) * ((selfAc.size - math.abs(i)) / selfAc.size)), self.y - (selfAc.size/2) - (selfAc.size * (1-selfAc.a)))
            end
        end
        if selfAc.f % 2 == 0 then
            graphics.color(Color.fromRGB(204, 255, 250))
        else
            graphics.color(Color.fromRGB(255, 255, 201))
        end
        for i = -ultAOE/2, ultAOE/2 do
            if i % (ultAOE / 4) == 0 then
                graphics.rectangle((self.x - ((selfAc.size/10) * i)), self.y - (selfAc.size * (1-selfAc.a)), (self.x - ((selfAc.size/10) * i)) + ((selfAc.size/4) * ((selfAc.size - math.abs(i)) / selfAc.size)), self.y - (selfAc.size/2) - (selfAc.size * (1-selfAc.a)), true)
            end
        end
    end
    
end)

local RoboBallTurn = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if (self.moveLeft == 1 and self.facing ~= -1) or (self.moveRight == 1 and self.facing ~= 1) then
        self.state = "turn"
        return
    end
end

local bullets = 7 --How many bullets the Units will fire in their barrage attack.
local barrageIncrement = 15 --How quickly it takes the Unit to charge up one stock of their barrage.
local groundEasing = 25 --How close to the ground the Unit will descend.

roboball:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Solus Control Unit"
    self.name2 = "Corrupt AI"
    self.maxhp = 1200 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 15 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.6
    self.pGravity1 = 0
    self.pGravity2 = 0
    self.yy = 0
    actor.mask = sprites.mask
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.idle,
        jump = sprites.idle,
        death = sprites.death
    }
    self.sound_hit = sounds.hit.id
    self.sound_death = sounds.death.id
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.knockback_cap = self.maxhp
    self.facing = 1
    self.rotating = 0
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 200
    self.x_range = 0
    self.c_range = 300
    self.v_range = 0
    self.shake_frame = 0
    self.can_drop = 1
    self.can_jump = 1
    self.z_charge = 0
    self.z_stock = 0
    self.z_target_x = 0
    self.z_target_y = 0
    self.chargeAngle = 0
    self.reticuleAlpha = 0
    self.moveDown = 0
    data.rage = false
end)

superroboball:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Alloy Worship Unit"
    self.name2 = "Friend of Vultures"
    self.maxhp = 2000 * (Difficulty.getScaling("hp") * 1.5)
    self.hp = self.maxhp
    self.damage = 15 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.6
    self.pGravity1 = 0
    self.pGravity2 = 0
    self.yy = 0
    actor.mask = sprites.mask
    actor:setAnimations{
        idle = sprites.idleS,
        walk = sprites.idleS,
        jump = sprites.idleS,
        death = sprites.deathS
    }
    self.sound_hit = sounds.hit.id
    self.sound_death = sounds.death.id
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.knockback_cap = self.maxhp
    self.facing = 1
    self.rotating = 0
    self.z_range = 400
    self.x_range = 0
    self.c_range = 400
    self.v_range = 0
    self.shake_frame = 0
    self.can_drop = 1
    self.can_jump = 1
    self.z_charge = 0
    self.z_stock = 0
    self.z_target_x = 0
    self.z_target_y = 0
    self.c_charge = 0
    self.chargeAngle = 0
    self.reticuleAlpha = 0
    self.moveDown = 0
    data.rage = false
end)

roboball:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(self.target)
    if misc.getTimeStop() > 0 then
        return
    end
    ------------------------------------------
    if target then
        if (target.y < actor.y) or (Stage.collidesRectangle(target.x, target.y, actor.x, actor.y)) then
            self.moveUp = 1
        elseif target.y > actor.y + groundEasing and self.free == 1 then
            self.moveDown = 1
        else
            self.moveUp = 0
            self.moveDown = 0
        end
    end
    self.yy = self.yy + (self.pHmax / 10)
    if self.moveUp == 1 then
        self.pVspeed = -math.abs((math.sin(self.yy) / 5))
    elseif self.moveDown == 1 then
        self.pVspeed = math.abs((math.sin(self.yy) / 5))
    else
        self.pVspeed = (math.sin(self.yy) / 5)
    end
    ------------------------------------------
    if self.facing and actor.xscale ~= self.facing then
        actor.xscale = self.facing
    end
    ------------------------------------------
    if self.activity == 0 and self.state ~= "turn" then
        if target and target:isValid() then
            if distance(target.x, target.y, actor.x, actor.y) < self.c_range then
                self.c_skill = 1
            else
                self.c_skill = 0
            end
            if distance(target.x, target.y, actor.x, actor.y) < self.z_range then
                self.z_skill = 1
            else
                self.z_skill = 0
            end
        end
        ----------------------------------------------------
        if self.z_skill == 1 and actor:getAlarm(2) == -1 then
            self.z_skill = 0
            self.state = "attack1"
            actor.sprite = sprites.shoot1
            sounds.shoot1_1:play(self.attack_speed)
            self.z_charge = 0
            self.activity = 1
            self.activity_type = 2
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
        elseif self.x_skill == 1 and actor:getAlarm(3) == -1 then
    
        elseif self.c_skill == 1 and actor:getAlarm(4) == -1 then
            self.c_skill = 0
            self.state = "attack3"
            self.stun_immune = 1
            actor.sprite = sprites.shoot1
            sounds.shoot3_1:play(self.attack_speed)
            self.c_charge = 0
            self.activity = 1
            self.activity_type = 1
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
    
        end

    end
    if self.state == "idle" then
        RoboBallTurn(actor)
        self.reticuleAlpha = 0
    elseif self.state == "chase" then
        RoboBallTurn(actor)
    elseif self.state == "attack1" then
        if self.stunned > 0 then
            actor:setAlarm(2, 5*60)
            self.activity = 0
            self.activity_type = 0
            self.reticuleAlpha = 0
            actor.sprite = sprites.idle
            self.activity_var1 = 0
            self.activity_var2 = 0
            self.z_charge = -1
            self.z_stock = 0
            self.state = "chase"
            return
        end
        actor.spriteSpeed = (self.attack_speed * self.reticuleAlpha) / 2
        if self.activity_var1 == 0 then
            if sounds.shoot1_1:isPlaying() then
                self.reticuleAlpha = math.approach(self.reticuleAlpha, 1, self.attack_speed * 0.1)
                self.z_charge = self.z_charge + 1
                if self.z_charge % barrageIncrement == 0 then
                    if self.z_stock < bullets then
                        self.z_stock = self.z_stock + 1
                    end
                end
            else
                self.z_target_x = target.x
                self.z_target_y = target.y
                self.activity_var1 = 1
                return
            end
        elseif self.activity_var1 == 1 then
            if self.z_stock > 0 then
                self.z_charge = self.z_charge - 1
                if self.z_charge % math.floor(math.round((barrageIncrement*0.5)) / self.attack_speed) == 0 then
                    sounds.shoot1_2:play(self.attack_speed + ((9 - self.z_stock) * 0.05))
                    local i = roboBullet:create(actor.x + (9 * actor.xscale), actor.y + 6)
                    i:getData().parent = actor
                    i:getAccessor().direction = posToAngle(actor.x + (9 * actor.xscale), actor.y + 6, self.z_target_x + (20 * (3.5 - self.z_stock)), self.z_target_y)
                    i.depth = actor.depth - 1
                    self.z_stock = self.z_stock - 1
                end
            else
                if self.reticuleAlpha > 0 then
                    self.reticuleAlpha = math.approach(self.reticuleAlpha, 0, 0.1)
                else
                    actor:setAlarm(2, 5*60)
                    self.activity = 0
                    self.reticuleAlpha = 0
                    self.activity_type = 0
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    actor.sprite = sprites.idle
                    self.z_charge = -1
                    self.z_stock = 0
                    self.state = "chase"

                end
            end
        end
    elseif self.state == "attack3" then
        self.stunned = -1
        actor.spriteSpeed = self.attack_speed / 2
        if sounds.shoot3_1:isPlaying() then
            self.c_charge = self.c_charge + 1
        else
            if self.activity_var1 == 1 then
                self.c_charge = self.c_charge - 1
                for _, inst in ipairs(roboBlast:findAll()) do
                    if inst:getData().parent == actor then
                        inst:set("detonate", -1)
                    end
                end
                if self.c_charge < 0 then    
                    self.stun_immune = 0
                    actor:setAlarm(4, 30*60)
                    self.activity = 0
                    self.activity_type = 0
                    self.reticuleAlpha = 0
                    actor.sprite = sprites.idle
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    self.c_charge = -1
                    self.state = "chase"
                    return
                end
            end
        end
        if self.activity_var1 == 0 then
            for i = 0, 2 do
                local tg = misc.players[math.random(1, #misc.players)]
                if tg and distance(actor.x, actor.y, tg.x, tg.y) < self.c_range then
                    local boom = roboBlast:create(tg.x + math.random(-ultAOE, ultAOE), tg.y)
                    boom:getData().parent = actor
                end
            end
            self.activity_var1 = 1
        end
    elseif self.state == "turn" then
        self.reticuleAlpha = 0
        if self.rotating == 0 then
            actor.spriteSpeed = self.pHmax * 0.5
            actor.sprite = sprites.turn
            self.activity = 50
            self.activity_type = 2
            self.rotating = 1
        elseif self.rotating == 1 then
            if math.floor(actor.subimage) >= sprites.turn.frames - 1 then
                actor.sprite = sprites.idle
                self.spriteSpeed = 0
                self.facing = -self.facing
                self.state = "idle"
                self.activity = 0
                self.activity_type = 0
                self.rotating = 0
                return
            end
        end

    end
end)

superroboball:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(self.target)
    if misc.getTimeStop() > 0 then
        return
    end
    ------------------------------------------
    if self.shield > 0 then
        self.shield_cooldown = 60
    end
    ------------------------------------------
    if target then
        if (target.y < actor.y) or (Stage.collidesRectangle(target.x, target.y, actor.x, actor.y)) then
            self.moveUp = 1
        elseif target.y > actor.y + groundEasing and self.free == 1 then
            self.moveDown = 1
        else
            self.moveUp = 0
            self.moveDown = 0
        end
    end
    self.yy = self.yy + (self.pHmax / 10)
    if self.moveUp == 1 then
        self.pVspeed = -math.abs((math.sin(self.yy) / 5))
    elseif self.moveDown == 1 then
        self.pVspeed = math.abs((math.sin(self.yy) / 5))
    else
        self.pVspeed = (math.sin(self.yy) / 5)
    end
    ------------------------------------------
    if self.facing and actor.xscale ~= self.facing then
        actor.xscale = self.facing
    end
    ------------------------------------------
    if self.activity == 0 and self.state ~= "turn" then
        if target and target:isValid() then
            if distance(target.x, target.y, actor.x, actor.y) < self.c_range then
                self.c_skill = 1
            else
                self.c_skill = 0
            end
            if distance(target.x, target.y, actor.x, actor.y) < self.z_range then
                self.z_skill = 1
            else
                self.z_skill = 0
            end
        end
        ----------------------------------------------------
        if self.z_skill == 1 and actor:getAlarm(2) == -1 then
            self.z_skill = 0
            self.state = "attack1"
            actor.sprite = sprites.idleS
            sounds.shoot1_1:play(self.attack_speed)
            self.z_charge = 0
            self.activity = 1
            self.activity_type = 2
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
        elseif self.x_skill == 1 and actor:getAlarm(3) == -1 then
    
        elseif self.c_skill == 1 and actor:getAlarm(4) == -1 then
            self.c_skill = 0
            self.state = "attack3"
            self.stun_immune = 1
            actor.sprite = sprites.idleS
            sounds.shoot3_1:play(self.attack_speed)
            self.c_charge = 0
            self.maxshield = self.maxshield + self.maxhp
            self.shield = self.shield + self.maxhp
            self.activity = 1
            self.activity_type = 1
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
    
        end

    end
    if self.state == "idle" then
        RoboBallTurn(actor)
        self.reticuleAlpha = 0
    elseif self.state == "chase" then
        RoboBallTurn(actor)
    elseif self.state == "attack1" then
        self.knockback_value = 0
        self.force_knockback = 0
        actor.spriteSpeed = (self.attack_speed * self.reticuleAlpha) / 2
        if self.activity_var1 == 0 then
            if sounds.shoot1_1:isPlaying() then
                self.reticuleAlpha = math.approach(self.reticuleAlpha, 1, self.attack_speed * 0.1)
                self.z_charge = self.z_charge + 1
                if self.z_charge % barrageIncrement == 0 then
                    if self.z_stock < bullets then
                        self.z_stock = self.z_stock + 1
                    end
                end
            else
                self.z_target_x = target.x
                self.z_target_y = target.y
                self.activity_var1 = 1
                return
            end
        elseif self.activity_var1 == 1 then
            if self.z_stock > 0 then
                self.z_charge = self.z_charge - 1
                if self.z_charge % math.floor(math.round((barrageIncrement*0.5)) / self.attack_speed) == 0 then
                    sounds.shoot1_2:play(self.attack_speed + ((9 - self.z_stock) * 0.05))
                    local i = roboBullet:create(actor.x + (9 * actor.xscale), actor.y + 6)
                    i:getData().parent = actor
                    i:getAccessor().direction = posToAngle(actor.x + (9 * actor.xscale), actor.y + 6, self.z_target_x + (35 * (3.5 - self.z_stock)), self.z_target_y)
                    i.depth = actor.depth - 1
                    self.z_stock = self.z_stock - 1
                end
            else
                if self.reticuleAlpha > 0 then
                    self.reticuleAlpha = math.approach(self.reticuleAlpha, 0, 0.1)
                else
                    actor:setAlarm(2, 4*60)
                    self.activity = 0
                    self.reticuleAlpha = 0
                    self.activity_type = 0
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    actor.sprite = sprites.idleS
                    self.z_charge = -1
                    self.z_stock = 0
                    self.state = "chase"

                end
            end
        end
    elseif self.state == "attack3" then
        actor:setAlarm(4, 30*60)
        self.knockback_value = 0
        self.force_knockback = 0
        actor.spriteSpeed = self.attack_speed / 2
        if sounds.shoot3_1:isPlaying() then
            self.c_charge = self.c_charge + 2
        else
            if self.activity_var1 == 1 then
                self.c_charge = self.c_charge - 1
                for _, inst in ipairs(roboBlast:findAll()) do
                    if inst:getData().parent == actor then
                        inst:set("detonate", -1)
                    end
                end
                if self.c_charge < 0 then    
                    self.stun_immune = 0
                    self.activity = 0
                    self.activity_type = 0
                    self.reticuleAlpha = 0
                    self.maxshield = self.maxshield - self.maxhp
                    self.shield = self.shield - self.maxhp
                    actor.sprite = sprites.idleS
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    self.c_charge = -1
                    self.state = "chase"
                    return
                end
            end
        end
        if self.activity_var1 == 0 then
            for i = 0, 3 do
                local tg = misc.players[math.random(1, #misc.players)]
                if tg and distance(actor.x, actor.y, tg.x, tg.y) < self.c_range then
                    local boom = roboBlast:create(tg.x + math.random(-ultAOE, ultAOE), tg.y)
                    boom:getData().parent = actor
                end
            end
            self.activity_var1 = 1
        end
    elseif self.state == "turn" then
        self.reticuleAlpha = 0
        if self.rotating == 0 then
            actor.spriteSpeed = self.pHmax * 0.5
            actor.sprite = sprites.turnS
            self.activity = 50
            self.activity_type = 2
            self.rotating = 1
        elseif self.rotating == 1 then
            if math.floor(actor.subimage) >= sprites.turn.frames - 1 then
                actor.sprite = sprites.idleS
                self.spriteSpeed = 0
                self.facing = -self.facing
                self.state = "idle"
                self.activity = 0
                self.activity_type = 0
                self.rotating = 0
                return
            end
        end

    end
end)

roboball:addCallback("draw", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if self.reticuleAlpha > 0 then
        self.chargeAngle = self.chargeAngle + 5
        graphics.drawImage{
            image = sprites.charge,
            x = actor.x + (9 * actor.xscale),
            y = actor.y + 6,
            subimage = actor.subimage,
            angle = self.chargeAngle,
            alpha = (self.reticuleAlpha * (0.7 + (math.random() * 0.15)))
        }
    end
end)

superroboball:addCallback("draw", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if self.reticuleAlpha > 0 then
        self.chargeAngle = self.chargeAngle + 5
        graphics.drawImage{
            image = sprites.charge,
            x = actor.x + (9 * actor.xscale),
            y = actor.y + 6,
            subimage = actor.subimage,
            angle = self.chargeAngle,
            alpha = (self.reticuleAlpha * (0.7 + (math.random() * 0.15)))
        }
    end
end)

local roboCorpse = Object.new("RoboBallBody")
roboCorpse.sprite = sprites.death
roboCorpse:addCallback("create", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    self.mask = sprites.mask
    self.spriteSpeed = 0
    selfAc.direction = math.random(360)
    selfAc.speed = 0
    selfAc.f = 0
end)

roboCorpse:addCallback("step", function(self)
    local selfAc = self:getAccessor()
    local data = self:getData()
    selfAc.f = selfAc.f + 1
    selfAc.speed = selfAc.speed + 0.1
    self.angle = self.angle + (self.xscale * selfAc.speed)
    selfAc.direction = selfAc.direction + math.random(math.sin(selfAc.f * 0.1) * 5, math.cos(selfAc.f * 0.1) * 5)
    if selfAc.f % 5 == 0 then
        if math.random() < 0.5 then
            misc.fireExplosion(self.x + math.random(-25, 25), self.y + math.random(-25, 25), 0, 0, 0, "neutral", sprites.sparks1)
        else
            misc.fireExplosion(self.x + math.random(-25, 25), self.y + math.random(-25, 25), 0, 0, 0, "neutral", sprites.sparks3)
        end
    end
    if Stage.collidesPoint(self.x, self.y) then
        sounds.shoot3_2:play(0.8, 1)
        local flash = objects.whiteFlash:create(self.x, self.y)
        flash:set("rate", 0.01)
        misc.shakeScreen(30)
        misc.fireExplosion(self.x, self.y, 0, 0, 0, "neutral", sprites.sparks2)
        self:destroy()
        return
    end
end)

roboball:addCallback("destroy", function(actor)
    for _, inst in ipairs(roboBlast:findAll()) do
        if inst:getData().parent == actor then
            inst:set("detonate", -1)
        end
    end
    local body = roboCorpse:create(actor.x, actor.y)
    body.xscale = actor.xscale
end)

superroboball:addCallback("destroy", function(actor)
    for _, inst in ipairs(roboBlast:findAll()) do
        if inst:getData().parent == actor then
            inst:set("detonate", -1)
        end
    end
    local body = roboCorpse:create(actor.x, actor.y)
    body.sprite = sprites.deathS
    body.xscale = actor.xscale
end)

local roboBallCard = MonsterCard.new("Solus Control Unit", roboball)
roboBallCard.sprite = sprites.spawn
roboBallCard.sound = sounds.spawn
roboBallCard.canBlight = false
roboBallCard.isBoss = true
roboBallCard.type = "offscreen"
roboBallCard.cost = 800
for _, elite in ipairs(EliteType.findAll("vanilla")) do
    roboBallCard.eliteTypes:add(elite)
end
for _, elite in ipairs(EliteType.findAll("RoR2Demake")) do
    roboBallCard.eliteTypes:add(elite)
end

local monsLog1 = MonsterLog.new("Solus Control Unit")
MonsterLog.map[roboball] = monsLog1

monsLog1.displayName = "Solus Control Unit"
monsLog1.story = "This must be the mother computer of the Solus Probes I encountered earlier. The crash must have triggered its awakening, and the hostility of the planet's fauna must have forced it into a self-defense mode. A part of me wishes it had been destroyed, as it views anything that moves as a threat, including me. I don't blame it, but I would have loved to repair it and use it as a potential ally.\n\nThe Control Unit's self-defense systems weren't damage at all in the crash... Lucky me. As a swarm of Probes tailed behind it, it launched volley after volley of energy rounds at me, scorching the landscape."
monsLog1.statHP = 1200
monsLog1.statDamage = 15
monsLog1.statSpeed = 0.6
monsLog1.sprite = sprites.spawn
monsLog1.portrait = sprites.idle
monsLog1.portraitSubimage = 1

local monsLog2 = MonsterLog.new("Alloy Worship Unit")
MonsterLog.map[superroboball] = monsLog2

monsLog2.displayName = "Alloy Worship Unit"
monsLog2.story = "I shouldn't have had eggs for breakfast. After raiding some more vulture nests, I heard machines whirring to life. Turning around, I saw a Solus Control Unit rising from the ground behind me, covered in dirt and fauna. It must have been resting there for ages... I haven't been on this planet THAT long, have I?\n\nThe Alloy Worship Unit, as I have come to call it, differs from a standard Solus unit as it appears to have befriended the vultures that peck at and harass me. Tarnishing their nests has enraged the machine, and now its primary objective appears to be staining the ground black with my ashes."
monsLog2.statHP = 5000
monsLog2.statDamage = 15
monsLog2.statSpeed = 0.6
monsLog2.sprite = sprites.idleS
monsLog2.portrait = sprites.idleS
monsLog2.portraitSubimage = 1

local stages = {
    Stage.find("Magma Barracks"),
    Stage.find("Hive Cluster")
}

AddMCardToStages(roboBallCard, stages)