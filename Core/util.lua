-- A NOTE FROM THE AUTHOR:
-- This is (basically) the main library for RTS. If you are a modder and want to make use of RTS's custom functions, you've come to the right place. Please keep in mind that because I am bad at organizing, some stuff that would be useful to put here are seperate files in the Misc folder. So you might want to check that out too.
-- Please note that some of these functions and even some of the libraries in this folder are borrowed from other mods, mainly Starstorm. I didn't want to make this mod Starstorm-dependent so here they are.

-- Enjoy! :)

-- Returns the y coordinate of the ground relative to the specified coordinates and direction.
-- Parameters:
	-- x: The x coordinate to search from.
	-- y: The y coordinate to search from.
	-- dir: Which direction to search; positive values search downwards, negative values search upwards. Defaults to searching downwards.
FindGround = function(x, y, dir)
	local dy = y
	local step = 1
	if dir then
		if dir < 0 then
			dir = -1
		elseif dir > 0 then
			dir = 1
		else
			dir = 1
		end
		step = dir
	end
	local sX, sY = Stage.getDimensions()
	while dy ~= (sY*step) do
		if Stage.collidesPoint(x, dy) then
			break
		else
			dy = dy + step
		end
	end
	return dy
end

-- Prints to the console when a profile flag is enabled. You shouldn't use this in an RTS-dependent mod (probably).
local debugSet = modloader.checkFlag("rts_debug")
function debugPrint(...)
	if debugSet then print(...) end
end
export("debugPrint", debugPrint)

-- Finds if a table contains a certain value. Returns true if the value is found, false if the value is not.
-- Parameters:
	-- t: The table you are searching.
	-- value: What you are looking for in the table.
function contains(t, value)
	if t then
		for _, v in pairs(t) do
			if v == value then
				return true
			end
		end
		return false
	else
		return false
	end
end

function colorString(str, color)
	return "&" .. tostring(color.gml) .. "&" .. str .. "&!&"
end

-- Neik's functions and stuff
function angleDif(current, target)
	return ((((current - target) % 360) + 540) % 360) - 180
end
local syncInputRelease = net.Packet.new("SSInputRelease", function(sender, player, key)
	local playerI = player:resolve()
	if playerI and playerI:isValid() and key then
		playerI:getData()._keyRelease = key
	end
end)
local hostSyncInputRelease = net.Packet.new("SSInputRelease2", function(sender, player, key)
	local playerI = player:resolve()
	if playerI and playerI:isValid() and key then
		playerI:getData()._keyRelease = key
		syncInputRelease:sendAsHost(net.EXCLUDE, sender, player, key)
	end
end)

function syncControlRelease(player, control)
	if player:control(control) == input.RELEASED then
		if net.online and net.localPlayer == player then
			if net.host then
				syncInputRelease:sendAsHost(net.ALL, nil, player:getNetIdentity(), control)
			else
				hostSyncInputRelease:sendAsClient(player:getNetIdentity(), control)
			end
		end

		return true

	elseif player:getData()._keyRelease == control then
		player:getData()._keyRelease = nil

		return true
	else

		return false
	end
end

function distance(x1, y1, x2, y2)
	local distance = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
	return distance
end
function posToAngle(x1, y1, x2, y2, rad)
	local deltaX = x2 - x1
	local deltaY = y1 - y2
	local result = math.atan2(deltaY, deltaX)

	if not rad then
		result = math.deg(result)
	end

	return result
end

-- bezier functions -- <altzeus> to use those, create tables with .x and .y variables and send em like that -- taken from https://github.com/nshafer/Bezier/blob/master/Bezier.lua
function bezier4(p1,p2,p3,p4,mu)
	local mum1,mum13,mu3;
	local p = {}

	mum1 = 1 - mu
	mum13 = mum1 * mum1 * mum1
	mu3 = mu * mu * mu

	p.x = mum13*p1.x + 3*mu*mum1*mum1*p2.x + 3*mu*mu*mum1*p3.x + mu3*p4.x
	p.y = mum13*p1.y + 3*mu*mum1*mum1*p2.y + 3*mu*mu*mum1*p3.y + mu3*p4.y

	return p
end

function createCubicCurve(p1, p2, p3, p4, steps) -- <altzeus> steps are required - just do it via distance()
	points = {}
	for i = 0, steps do
		table.insert(points, bezier4(p1, p2, p3, p4, i/steps))
	end
	return points
end

-- Minor NPC Utility for adding card to stages
function AddMCardToStages(card,stages)
	for __,stage in pairs(stages) do
		stage.enemies:add(card)
	end
end

-- Creates one of multiple portals found in Risk of Rain 2. Returns the newly created Portal.
-- NOTE: If you want to make a custom portal, please just use the "Portal" object.
-- Parameters:
    -- variant: The type of portal to spawn. Variants are listed below. Passing in a value not listed below will return a randomized Portal.
        -- gold: Creates a portal to Gilded Coast.
        -- celestial: Creates a portal to A Moment, Fractured.
        -- blue: Creates a portal to Bazaar Between Time.
        -- null: Creates a portal to Void Fields.
        -- artifact: Creates a portal to or from Bulwark's Ambry.
    -- x: The x coordinate to spawn the portal at.
    -- y: The y coordinate to spawn the portal at.
local portalMask = Sprite.load("artifactPortalMask", "Graphics/artifactPortalMask.png", 1, 35, 35)
local bazaarGateway = Sprite.load("bazaarPortal", "Graphics/gateway2.png", 1, 22, 24)
local artifactPortal = Sprite.load("artifactPortal", "Graphics/artifactPortal.png", 1, 35, 35)
MakePortal = function(variant, x, y)
    variant = string.lower(variant)
    local portal = Object.find("Portal", "rts-reborn"):create(x,y)
    local data = portal:getData()
    if variant == "gold" then
        portal.blendColor = Color.fromRGB(255, 200, 100)
		data.rim = bazaarGateway
        -- data.destination = nil
    elseif variant == "celestial" then
        portal.blendColor = Color.fromHex(0x72D6D6)
        -- data.destination = Stage.find("A Moment, Fractured", "rts-reborn")
    elseif variant == "blue" then
        portal.blendColor = LunarColor
		data.rim = bazaarGateway
        -- data.destination = Stage.find("Bazaar Between Time", "rts-reborn")
    elseif variant == "null" then
        portal.blendColor = Color.fromRGB(50, 0, 50)
        -- data.destination = Stage.find("Void Fields", "rts-reborn")
    elseif variant == "artifact" then
        portal.blendColor = Color.ROR_RED
        portal.mask = portalMask
        data.rim = artifactPortal
    end
    return portal
end

-- Creates one of multiple "orbs," which will create their respective Portal once the Teleporter is fully charged. Returns the newly created Orb, and its Portal.
-- NOTE: If you want to make a custom orb, please just use the "Orb" object.
-- Parameters:
    -- variant: The type of portal to spawn. Variants are listed below. Passing in a value not listed below will return a randomized Orb and Portal.
        -- gold: Creates a gold Orb, and a portal to Gilded Coast.
        -- celestial: Creates a celestial Orb, and a portal to A Moment, Fractured.
        -- blue: Creates a blue Orb, and a portal to Bazaar Between Time.
MakeOrb = function(variant)
    variant = string.lower(variant)
    local tp = Object.find("Teleporter", "vanilla"):findNearest(0, 0)
    if tp then
        local orb = Object.find("Orb", "rts-reborn"):create(tp.x,tp.y)
        local data = orb:getData()
        local xx, yy
        xx = tp.x + math.random(-200, 200)
        yy = tp.y + math.random(-200, -20)
        if variant == "gold" then
            orb.blendColor = Color.fromRGB(255, 200, 100)
        elseif variant == "celestial" then
            orb.blendColor = Color.fromHex(0x72D6D6)
        elseif variant == "blue" then
            orb.blendColor = LunarColor
        end
        data.portal = MakePortal(variant, xx, FindGround(xx, yy) - 20)
        data.portal:getData().activity = -1
        return orb, data.portal
    end
end
