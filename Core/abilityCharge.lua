-- Skill Charges

Ability = {}
local hudElement = Sprite.load("Graphics/UI/skillCharge.png", 2, 9, 8)

local abilities = {
	Equipment = 0,
	Z = 2,
	X = 3,
	C = 4,
	V = 5,
}

local constants = {
	zero = -1,
	second = 60
}

local chargeVars = { -- The variable that stores the current uses of an actor's ability.
	[0] = "equip_charges",
	[2] = "z_charges",
	[3] = "x_charges",
	[4] = "c_charges",
	[5] = "v_charges",
}
local maxChargeVars = { -- The variable that stores the maximum uses of an actor's ability.
	[0] = "equip_max",
	[2] = "z_max",
	[3] = "x_max",
	[4] = "c_max",
	[5] = "v_max",
}
local enableVars = { -- Whether or not multiple charges are enabled for that ability.
	[0] = "equip_charge_enabled",
	[2] = "z_charge_enabled",
	[3] = "x_charge_enabled",
	[4] = "c_charge_enabled",
	[5] = "v_charge_enabled",
}
local cooldownVars = { -- The cooldown of the ability. Affected by the default "cdr" variable.
	[0] = "equip_cooldown",
	[2] = "z_cooldown",
	[3] = "x_cooldown",
	[4] = "c_cooldown",
	[5] = "v_cooldown",
}
local cdrVars = { -- Cooldown reduction for each ability. The default cooldown reduction variables are applied before these.
	[0] = "equip_cdr",
	[2] = "z_cdr",
	[3] = "x_cdr",
	[4] = "c_cdr",
	[5] = "v_cdr",
}
local alarmVars = { -- The current value of the alarm tied to the ability.
	[0] = "equip_alarm",
	[2] = "z_alarm",
	[3] = "x_alarm",
	[4] = "c_alarm",
	[5] = "v_alarm",
}
local stopVars = { -- The value an alarm will be set to when a skill is triggered. Useful if your skill is instant and you still want a small delay. Defaults to -1.
	[0] = "equip_stop",
	[2] = "z_stop",
	[3] = "x_stop",
	[4] = "c_stop",
	[5] = "v_stop",
}

local drawCoordinates = {
	[0] = {x = -100, y = -100},
	[2] = {x = 9, y = -3},
	[3] = {x = 32, y = -3},
	[4] = {x = 55, y = -3},
	[5] = {x = 78, y = -3},
}

local InitAbilities = function(actor)
	local data = actor:getData()
	local a = actor:getAccessor()
	for _, ability in pairs(abilities) do
		if not a[chargeVars[ability]] then
			a[chargeVars[ability]] = 1
		end
		if not a[maxChargeVars[ability]] then
			a[maxChargeVars[ability]] = 1
		end

		if not a[enableVars[ability]] then
			a[enableVars[ability]] = 0
		end
		if not a[cooldownVars[ability]] then
			a[cooldownVars[ability]] = -1
		end
		if not a[cdrVars[ability]] then
			a[cdrVars[ability]] = 0
		end
		if not a[alarmVars[ability]] then
			a[alarmVars[ability]] = -1
		end
		if not a[stopVars[ability]] then
			a[stopVars[ability]] = -1
		end
		if ability > 0 then
			actor:activateSkillCooldown(ability - 1)
			a[cooldownVars[ability]] = actor:getAlarm(ability)
			actor:setAlarm(ability, -1)
		end
	end
end

local StepAbilities = function(actor)
	local data = actor:getData()
	local a = actor:getAccessor()
	for _, ability in pairs(abilities) do
		-- Check if ability has multiple charges enabled at all
		if a[enableVars[ability]] == 1 then
			-- Check if a skill has been used
			if actor:getAlarm(ability) > a[stopVars[ability]] then
				-- Remove a charge
				if a[chargeVars[ability]] > 0 then
					local var = actor:getAlarm(ability)
					actor:setAlarm(ability, a[stopVars[ability]])
					a[alarmVars[ability]] = a[alarmVars[ability]] + (var)
					a[chargeVars[ability]] = a[chargeVars[ability]] - 1
				end
			else
			-- If we're out of charges and the vanilla timer isn't counting, set vanilla alarm to our current alarm, to a max of the current cooldown
				if a[chargeVars[ability]] < 1 then
					actor:setAlarm(ability, math.clamp(a[alarmVars[ability]], a[stopVars[ability]], ((a[cooldownVars[ability]] * (1-a[cdrVars[ability]])) + 1)))
				end
			end
			-- Increment internal timer
			if a[alarmVars[ability]] > -1 then --Check if our internal timer should be counting...
				a[alarmVars[ability]] = a[alarmVars[ability]] - 1
				-- If the alarm is equal to a multiple of the cooldown, add a count to the charges
				if (a[alarmVars[ability]] % ((a[cooldownVars[ability]] * (1-a[cdrVars[ability]])) + 1) == 0) then
					if a[chargeVars[ability]] < a[maxChargeVars[ability]] then
						if a[chargeVars[ability]] < 1 then
							actor:setAlarm(ability, constants.zero)
						end
						a[chargeVars[ability]] = a[chargeVars[ability]] + 1
					end
				end
			else
				-- If the internal timer isn't counting and the player doesn't have enough charges, begin counting again
				if a[chargeVars[ability]] > 0 and a[chargeVars[ability]] < a[maxChargeVars[ability]] then
					a[alarmVars[ability]] = ((a[cooldownVars[ability]] * (1-a[cdrVars[ability]])) + 1)
				end
			end
			-- If the vanilla cooldown isn't counting and the actor has full charges, set the internal timer to zero
			if actor:getAlarm(ability) == -1 and a[chargeVars[ability]] >= a[maxChargeVars[ability]] then
				a[alarmVars[ability]] = constants.zero
			end
		end
	end
end

callback.register("onPlayerInit", function(player)
	InitAbilities(player)
end)
callback.register("postStep", function()
	for _, player in ipairs(misc.players) do
		StepAbilities(player)
	end
end)

callback.register("onPlayerHUDDraw", function(player, x, y)
	local data = player:getData()
	local p = player:getAccessor()
	local color = player:getSurvivor().loadoutColor
	local activeColor = color
	local cooldownColor = Color.fromRGB(color.red * 0.85, color.blue * 0.85, color.green * 0.85)
	for _, ability in pairs(abilities) do
		if p[enableVars[ability]] == 1 then
			if p[chargeVars[ability]] <= 0 then
				graphics.drawImage{
					image = hudElement,
					x = x + drawCoordinates[ability].x,
					y = y + drawCoordinates[ability].y,
					subimage = 2,
					color = cooldownColor
				}
			else
				graphics.drawImage{
					image = hudElement,
					x = x + drawCoordinates[ability].x,
					y = y + drawCoordinates[ability].y,
					subimage = 2,
					color = activeColor
				}
			end
			graphics.color(Color.WHITE)
			graphics.print(p[chargeVars[ability]], x + drawCoordinates[ability].x, y + drawCoordinates[ability].y - (graphics.textHeight("0", NewDamageFont) / 4), NewDamageFont, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
			graphics.drawImage{
				image = hudElement,
				x = x + drawCoordinates[ability].x,
				y = y + drawCoordinates[ability].y,
				subimage = 1,
			}
		end
	end
end)

local stringToSlot = {
	["z"] = 2,
	["x"] = 3,
	["c"] = 4,
	["v"] = 5,
	["equipment"] = 0,
}

Ability.addCharge = function(player, slot, increment, noDelay)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	if p[enableVars[slot]] ~= 1 then
		p[enableVars[slot]] = 1
	end
	p[maxChargeVars[slot]] = (p[maxChargeVars[slot]] or 1) + increment
	if noDelay then
		p[chargeVars[slot]] = (p[chargeVars[slot]] or 1) + increment
	end
end


Ability.getCharge = function(player, slot)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	return p[chargeVars[slot]]
end

Ability.setCharge = function(player, slot, charges)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	p[chargeVars[slot]] = charges
end

Ability.getMaxCharge = function(player, slot)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	return p[maxChargeVars[slot]]
end

Ability.setMaxCharge = function(player, slot, charges)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	p[maxChargeVars[slot]] = charges
end

Ability.setCooldown = function(player, slot, cd)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	p[cooldownVars[slot]] = cd
end

Ability.getCooldown = function(player, slot)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	return p[cooldownVars[slot]]
end

Ability.setCooldownReduction = function(player, slot, cdr)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	p[cdrVars[slot]] = cdr
end

Ability.getCooldownReduction = function(player, slot)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	return p[cdrVars[slot]]
end

Ability.setStop = function(player, slot, stop)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	p[stopVars[slot]] = stop
end

Ability.getStop = function(player, slot)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	return p[stopVars[slot]]
end

Ability.disable = function(player, slot)
	local p = player:getAccessor()
	slot = stringToSlot[slot]
	p[maxChargeVars[slot]] = 1
	p[chargeVars[slot]] = 1
	p[enableVars[slot]] = 0
end

Ability.enabled = function(player, slot)
	slot = stringToSlot[slot]
	if player:getAccessor()[enableVars[stringToSlot[slot]]] == 1 then
		return true
	else
		return false
	end
end

export("Ability")
return Ability
