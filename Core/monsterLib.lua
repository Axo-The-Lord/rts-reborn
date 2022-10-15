Monster = {}
export("Monster")
Monster.skills = {}

local indexToKey = {
	[1] = "z", [2] = "x", [3] = "c", [4] = "v"
}
function Monster.setSkill(object, index, range, cooldown, startFunc)
	local key = indexToKey[index]
	
	if not Monster.skills[object] then
		Monster.skills[object] = {}
	end
	Monster.skills[object][index] = {key = key, range = range, cooldown = cooldown, onStart = startFunc} --skilldata
end

function Monster.activateSkillCooldown(actor, index)
	local actorObj = actor:getObject()
	if Monster.skills[actorObj] and Monster.skills[actorObj][index] then
		local skillCooldown = Monster.skills[actorObj][index].cooldown
		local alarmIndex = index + 1
		actor:setAlarm(alarmIndex, skillCooldown * (1 - actor:get("cdr")))
	end
end

function Monster.setActivityState(actor, index, sprite, speed, scaleSpeed, resetHSpeed, stepFunc)
	local actorAc = actor:getAccessor()
	local actorData = actor:getData()
	if actorAc.activity == 0 then
		actorData._attackFrameLast = 0 -- for anim. handler
		actorAc.activity = index
		actorAc.activity_type = 1
		actor.subimage = 1
		actor.sprite = sprite
		actorData._attackAnimation = sprite
		actorData._attackSpeed = speed
		actorData._attackScale = scaleSpeed
		actorData._attackResetSpeed = resetHSpeed
	end
end

function Monster.skillCallback(object, index, stepFunc)
	Monster.skills[object][index].onStep = stepFunc
end

function Monster.giveAI(object) -- this goes first!
	Monster.skills[object] = {}
	object:addCallback("create", function(self)
		local selfAc = self:getAccessor()
		local selfData = self:getData()
		for skillIndex, skillData in pairs(Monster.skills[object]) do
			selfAc[skillData.key.."_range"] = skillData.range
		end
	end)
	object:addCallback("step", function(self)
		local selfAc = self:getAccessor()
		local selfData = self:getData()
		
		local activity = selfAc.activity
		
		if misc.getTimeStop() == 0 then
			if activity == 0 then
				for skillIndex, skillData in pairs(Monster.skills[object]) do
					local alarmIndex = skillIndex + 1
					local skillVar = skillData.key.."_skill"
					if self:get(skillVar) > 0 and self:getAlarm(alarmIndex) == -1 then -- is active and usable
						self:set(skillVar, 0)
						if skillData.onStart then
							skillData.onStart(self)
						end
					else
						self:set(skillVar, 0)
					end
				end
			else
				local skill = Monster.skills[object][activity]
				if skill then
					local relevantFrame = 0
					local newFrame = math.floor(self.subimage)
					if newFrame > selfData._attackFrameLast then
						relevantFrame = newFrame
						selfData._attackFrameLast = newFrame
					end
					if selfData._attackResetSpeed and relevantFrame == 1 and selfAc.free == 0 then
						selfAc.pHspeed = 0
					end
					if skill.onStep then
						skill.onStep(self, relevantFrame)
					end
					local mult = 1
					if selfData._attackScale then mult = selfAc.attack_speed end
					self.spriteSpeed = selfData._attackSpeed * mult
					if selfData._attackAnimation then
						self.sprite = selfData._attackAnimation
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
		if self.sprite.id == selfAc.sprite_death then
			self.subimage = 1
		end
	end)
end

--npcInstance:setAnimation("shoot"..k, i.sprite)
--npcInstance:getData()._attackFrameLast = 0