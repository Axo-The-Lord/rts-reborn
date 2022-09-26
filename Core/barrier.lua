--alright, lets try something different
local initOverheal = function(player)
	local data = player:getData()
	local ac = player:getAccessor()
	data.barrier = 0
end
function addOverheal(player, value)
	if player and player:isValid() then
		local data = player:getData()
		local ac = player:getAccessor()
		data.barrier = math.approach(data.barrier, ac.maxhp, value)
	end
end
local stepOverheal = function(player)
	local data = player:getData()
	local ac = player:getAccessor()
	if data.barrier > 0 then
		data.barrier = math.approach(data.barrier, 0, (ac.maxhp*0.0333)/60)
	end
	--debug
	if modloader.checkFlag("barrier_debug") then
		if input.checkKeyboard("t") == input.HELD then
			addOverheal(player, 50)
		elseif input.checkKeyboard("y") == input.HELD then
			data.barrier = 0
		end
	end
end
local tempDrawOverheal = function(player)
	local data = player:getData()
	local ac = player:getAccessor()
	
	if data.barrier and data.barrier > 0 then
		local x1 = player.x - 20
		local y1 = player.y + 10 
		local x2 = player.x + 20
		local y2 = player.y + 11
		local current = math.ceil(data.barrier)
		local maximum = ac.maxhp
		local color1 = Color.WHITE
		local color2 = Color.ROR_ORANGE
		local color3 = Color.ORANGE
		
		graphics.color(Color.DARK_GRAY)
		graphics.rectangle(x1, y1 - 1, x2, y2 + 1, true)
		
		graphics.color(Color.BLACK)
		graphics.rectangle(x1 + 1, y1, x2 - 1, y2, false)
		
		local barVal = math.floor((x2 - x1) * math.min(current / maximum, 1))
		if barVal ~= 0 then
			graphics.color(Color.mix(color1, color2, (current / maximum)))
			graphics.rectangle(x1 + 1, y1, x1 + barVal - 1, y2, false)
		end
	end
end
local trueDrawOverheal = function(player, x, y)
	local data = player:getData()
	local ac = player:getAccessor()
	
	if data.barrier and data.barrier > 0 then

		local xLeftBound = x - 35
		local xRightBound = x + 126
		xRightBound = xLeftBound + (161 * (data.barrier/ac.maxhp))
		
		local yUpperBound = y + 28
		local yLowerBound = y + 36
		
		for i = 0, 1 do
			graphics.color(Color.ORANGE)
			graphics.alpha(0.75 + (data.barrier/ac.maxhp))
			graphics.rectangle(xLeftBound - i, yUpperBound - i, xRightBound + i, yLowerBound + i, true)
			graphics.alpha(1)
		end
		
	end
end
callback.register("onPlayerInit", initOverheal)
callback.register("onPlayerStep", stepOverheal)
--callback.register("onPlayerDraw", tempDrawOverheal)
callback.register("onPlayerHUDDraw", trueDrawOverheal)

callback.register("onDamage", function(target, damage, source)
	if target and target:isValid() then
		local data = target:getData()
		local ac = target:getAccessor()
		if data.barrier and data.barrier > 0 then
			local barrier = data.barrier
			data.barrier = math.approach(data.barrier, 0, damage)
			local diff = barrier - data.barrier
			ac.hp = ac.hp + diff
		end
	end
end)

--require("Paladin/paladin")
