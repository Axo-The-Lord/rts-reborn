-- This library handles Orbs and Portals to hidden realms.

Portal = {}

local sprites = {
    gateFX = Sprite.load("TPGateway", "Graphics/gateway.png", 1, 22, 24),
    mask = Sprite.load("Graphics/gatewayMask.png", 1, 20.5, 20.5),
    spark = Sprite.load("Graphics/sparks.png", 8, 6, 4),
    warp = Sprite.find("EfRecall", "vanilla"),
    exp4 = Sprite.find("EfExp4", "vanilla"),
    exp3 = Sprite.find("EfExp3", "vanilla"),
    exp2 = Sprite.find("EfExp2", "vanilla")
}

local objects = {
    players = Object.find("P", "vanilla"),
    teleporter = Object.find("Teleporter", "vanilla"),
    exp = Object.find("EfExp", "vanilla"),
    sparks = Object.find("EfSparks", "vanilla")
}

local sounds = {
    tpSound = Sound.find("Teleporter", "vanilla"),
    coin = Sound.find("Coin", "vanilla")
}

-- Spark particles
local tpSpark = ParticleType.new("Sparks")
tpSpark:sprite(sprites.spark, true, true, false)
tpSpark:additive(true)
tpSpark:life(15, 15)
tpSpark:angle(0, 360, 0, 0, false)

-- Portal Transport Manager
local manager = Object.new("PortalTransportManager")
manager:addCallback("create", function(this)
    local data = this:getData()
    data.cd = 60*1.5
end)
manager:addCallback("step", function(this)
    local data = this:getData()
    if data.cd <= -1 then
        sounds.tpSound:play()
        for _, p in ipairs(misc.players) do
            local s = objects.sparks:create(p.x, p.y + p.sprite.yorigin)
            s.yscale = 1
            s.sprite = sprites.warp
            p.visible = true
            p:set("activity", 0):set("activity_type", 0)
        end
        this:destroy()
        return
    else
        data.cd = data.cd - 1
    end
end)

local SyncPortalActivity = net.Packet.new("Sync Portal Activity", function(id, activity)
    local p = Object.findInstance(id)
    if p and p:isValid() then
        local data = p:getData()
        data.activity = activity
    end
end)

-- Transport function
local Transport = function(target, destination, namespace)
    local player = Object.findInstance(target)
    if player and player:isValid() then
        local stage = Stage.find(destination, namespace)
        if stage then
            if net.localPlayer == player then
                local m = manager:create(0, 0)
                m:set("persistent", 1)
                Stage.transport(stage)
            end
        end
    end
end

-- random packet stuff i don't understand :)
local SyncStageTransport = net.Packet.new("Sync Portal Transfer", function(stage, namespace)
    for _, p in ipairs(misc.players) do
        Transport(p.id, stage, namespace)
    end
end)

-- The actual portal object!!
local tpGateway = Object.new("Portal")

tpGateway:addCallback("create", function(self)
    local data = self:getData()
    data.f = 0
    self.blendColor =  Color.fromRGB(math.random(255), math.random(255), math.random(255))
    data.blendMode = "additive"
    data.rate = 1
    data.rim = sprites.gateFX
    data.destination = nil
    data.sizeRate = 0.01
    data.text = "&w&Press &y&'"..input.getControlString("enter").."'&w& to enter the Portal.&!&"
    if math.random() < 0.5 then
        data.rotateScale = -1
    else
        data.rotateScale = 1
    end
    self.mask = sprites.mask
    self.xscale = 0
    self.yscale = 0
    data.exp_cd = 0
    data.activity = 0
    data.warpCD = -1
end)
tpGateway:addCallback("step", function(self)
    local data = self:getData()
    if data.activity > -1 then
        data.f = data.f + data.rate
        if data.f % 15 == 0 then
            tpSpark:burst("above", self.x + math.random(-data.rim.width/2, data.rim.width/2), self.y + math.random(-data.rim.width/2, data.rim.width/2), 1, self.blendColor)
        end
        if data.activity == 0 then -- appearance animation
            if self.xscale < 1 then -- grow
                self.xscale = self.xscale + data.sizeRate
                self.yscale = self.yscale + data.sizeRate
            end
            if self.xscale >= 1 then
                data.activity = 1
            end
        elseif data.activity == 1 then -- take input
            local closestP = objects.players:findNearest(self.x, self.y)
            if closestP and closestP:isValid() then
                if self:collidesWith(closestP, self.x, self.y) then
                    data.displayText = true
                    if input.checkControl("enter", closestP) == input.PRESSED then
                        if data.destination then
                            data.activity = 3 -- proceed to destination
                        else
                            data.activity = 2 -- create invisible teleporter to proceed to next level
                        end
                        if net.online then
                            if net.host then
                                SyncPortalActivity:sendAsHost(net.ALL, nil, self.id, data.activity)
                            else
                                SyncPortalActivity:sendAsClient(self.id, data.activity)
                            end
                        end
                    end
                else
                    data.displayText = false
                end
            end
        elseif data.activity == 2 then -- make invisible teleporter so we can go to next level, only if data.destination is nil
            if not data.madeTp then
                local tpInst = objects.teleporter:create(self.x, self.y)
                tpInst.sprite = Sprite.find("Empty", "rts-reborn")
                tpInst:getData().noEffects = true
                tpInst:set("active", 4)
                data.madeTp = true
            end

        elseif data.activity == 3 then -- create xp
            if misc.getGold() > 0 then
                if data.exp_cd <= 0 then
                    local xx, yy
                    local cX, cY = camera.x, camera.y
                    local w, h = graphics.getHUDResolution()
                    xx = (cX) + 30
                    yy = (cY) + 30
                    local e = objects.exp:create(xx, yy)
                    e:set("direction", math.random(360))
                    e:set("speed", math.random(1, 3))
                    e:setAlarm(0, 1)
                    sounds.coin:play()
                    if misc.getGold() >= 10000 then
                        e:set("value", math.ceil(misc.getGold() * 0.15))
                        misc.setGold(math.max(0, misc.getGold() - math.ceil(misc.getGold() * 0.05)))
                        e.sprite = sprites.exp4
                    elseif misc.getGold() >= 2000 then
                        e:set("value", 100)
                        misc.setGold(math.max(0, misc.getGold() - 500))
                        e.sprite = sprites.exp3
                    else
                        e:set("value", 10)
                        misc.setGold(math.max(0, misc.getGold() - 50))
                        e.sprite = sprites.exp2
                    end
                    if net.online then
                        e:set("target", net.localPlayer.id)
                    end
                    data.exp_cd = 5
                else
                    data.exp_cd = data.exp_cd - 1
                end
            end
            if math.floor(misc.getGold()) < 50 then
                local e = #objects.exp:findAll()
                if e <= 0 then
                    data.warpCD = 60
                    sounds.tpSound:play()
                    for _, p in ipairs(misc.players) do
                        local s = objects.sparks:create(p.x, p.y + p.sprite.yorigin)
                        s.yscale = 1
                        s.sprite = sprites.warp
                        p.visible = false
                        p:set("activity", 99)
                            :set("activity_type", 3)
                            :set("pHspeed", 0)
                            :set("pVspeed", 0)

                    end
                    data.activity = 4
                    if net.online and net.host then
                        SyncPortalActivity:sendAsHost(net.ALL, nil, self.id, data.activity)
                    end
                end
            end
        elseif data.activity == 4 then -- leaving
            if data.warpCD > -1 then
                data.warpCD = data.warpCD - 1
            else
                if net.online then
                    if net.host then
                        for _, p in ipairs(misc.players) do
                            if p ~= net.localPlayer then
                                SyncStageTransport:sendAsHost(net.DIRECT, p, p.id, data.destination:getName(), data.destination:getOrigin())
                            else
                                Transport(net.localPlayer.id, data.destination:getName(), data.destination:getOrigin())
                            end

                        end
                    end
                else
                    local m = manager:create(0, 0)
                    m:set("persistent", 1)
                    Stage.transport(data.destination)
                end
            end
        end
    end
end)

-- Drawing the portal
tpGateway:addCallback("draw", function(self)
    local data = self:getData()
    if data.activity > -1 then
        graphics.alpha(0.7 + math.random() * 0.2)
        if data.sprite then
            if self.xscale >= 1 then
                graphics.drawImage{
                    image = data.sprite,
                    x = self.x,
                    y = self.y,
                    subimage = self.subimage,
                    xscale = (math.sin(data.f/10)/10) + 1,
                    yscale = (math.cos(data.f/10)/10) + 1,
                }
            else
                graphics.drawImage{
                    image = data.sprite,
                    x = self.x,
                    y = self.y,
                    subimage = self.subimage,
                    xscale = self.xscale,
                    yscale = self.yscale,
                }
            end
        else
            graphics.color(self.blendColor)
            graphics.circle(self.x - 1, self.y - 1, 18 * self.xscale, false)
        end

        graphics.alpha(1)
        graphics.drawImage{
            image = data.rim,
            x = self.x,
            y = self.y,
            color = self.blendColor,
            angle = ((data.f / 2) % 360) * -data.rotateScale,
            xscale = self.xscale * 0.9,
            yscale = self.yscale * 0.9,
        }
        graphics.setBlendMode(data.blendMode)
        graphics.drawImage{
            image = data.rim,
            x = self.x,
            y = self.y,
            color = self.blendColor,
            angle = (data.f % 360) * data.rotateScale,
            xscale = self.xscale,
            yscale = self.yscale,
        }
        graphics.setBlendMode("normal")
        if data.activity == 1 and data.displayText then
            local textFormatted =  data.text:gsub("&[%a%p%C]&", "")
            graphics.printColor(data.text, self.x - (graphics.textWidth(textFormatted, graphics.FONT_DEFAULT)/2), self.y - self.mask.height, graphics.FONT_DEFAULT)
        end
    end
end)

local orbTravelRadius = 10
local portalRadius = 200 -- The distance from the teleporter that the game will pick suitable ground for the portal to be spawned.

local groundTypes = {
    "B",
    "BNoSpawn",
    "BNoSpawn2",
    "BNoSpawn3",
}

-- Orb object!!
local orb = Object.new("Orb")

orb:addCallback("create", function(self)
    self.blendColor =  Color.fromRGB(math.random(255), math.random(255), math.random(255))
    local boundTo = objects.teleporter:findNearest(self.x, self.y)
    self.depth = boundTo.depth - 1
    local data = self:getData()
    data.i = 0
    data.portal = tpGateway:create(boundTo.x + math.random(-portalRadius, portalRadius), FindGround(boundTo.x, boundTo.y) - 20)
    data.portal.blendColor = self.blendColor
    data.portal:getData().activity = -1
    data.madePortal = false
end)

orb:addCallback("step", function(self)
    local data = self:getData()
    local boundTo = objects.teleporter:findNearest(self.x, self.y)
    if boundTo and boundTo:isValid() then
        data.i = (data.i + 1) % (2*((5*orbTravelRadius) * math.pi))
        self.x = boundTo.x + ((orbTravelRadius*math.sin(data.i/(orbTravelRadius*5)))) -- speeeeeeeeen
        self.y = boundTo.y - (boundTo.sprite.height / 2)
        if boundTo:get("time") >= boundTo:get("maxtime") and boundTo:get("active") <= 3 and not data.madePortal then
            if data.portal and data.portal:isValid() then
                data.portal:getData().activity = 0
                data.madePortal = true
            end
        end
    else
        self:destroy()
        return
    end
end)

-- drawing the orb
orb:addCallback("draw", function(self)
    local data = self:getData()
    graphics.alpha(0.5)
    graphics.color(self.blendColor)
    graphics.circle(self.x, self.y, 2 + math.abs(math.sin(data.i)), false)
    graphics.alpha(1)
    graphics.circle(self.x, self.y, 1, false)
end)

-- exports
export("Portal")
export("tpSpark")

-- How much of that did I actually understand...? Pff, doesn't matter hahaha
-- haha
-- ha :(
