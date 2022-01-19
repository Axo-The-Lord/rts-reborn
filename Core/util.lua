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

-- Starstorm's NPC skills stuff.

NPC = {}
NPC.skills = {}
function NPC.setSkill(object, index, range, cooldown, sprite, speed, startFunc, updateFunc)
	local key = nil
	if index == 1 then key = "z"
	elseif index == 2 then key = "x"
	elseif index == 3 then key = "c"
	else key = "v" end
	
	if not NPC.skills[object] then
		NPC.skills[object] = {}
	end
	if not NPC.skills[object][index] then
		NPC.skills[object][index] = {key = key, range = range, cooldown = cooldown, sprite = sprite, speed = speed, start = startFunc, update = updateFunc}
	end
end
function NPC.new(name)
	local obj = Object.base("EnemyClassic",name)
	obj:addCallback("step", function(self)
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
	return obj
end
callback.register("postStep", function()
	for object, _ in pairs(NPC.skills) do
		for _, npcInstance in ipairs(object:findAll()) do
			if not npcInstance:getData()._checked then
				local obj = npcInstance:getObject()
				
				if NPC.skills[obj] then
					for k, i in pairs(NPC.skills[obj]) do
						npcInstance:set(i.key.."_range", i.range)
						if i.sprite then
							npcInstance:setAnimation("shoot"..k, i.sprite)
						end
					end
				end
				
				npcInstance:getData().attackFrameLast = 0
				npcInstance:getData()._checked = true
			end
		end
	end
end)

-- Minor NPC Utility for adding card to stages
function AddMCardToStages(card,stages)
	for __,stage in pairs(stages) do
		stage.enemies:add(card)
	end
end