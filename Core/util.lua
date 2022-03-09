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

--and THESE are a few inherited functions from starstorm -
--PosToAngle
--AngleDif
--ColorString
--syncControlRelease

-- PosToAngle
function posToAngle(x1, y1, x2, y2, rad)
	local deltaX = x2 - x1
	local deltaY = y1 - y2
	local result = math.atan2(deltaY, deltaX)
	
	if not rad then
		result = math.deg(result)
	end
	
	return result
end

-- Angledif
function angleDif(current, target)
  return ((((current - target) % 360) + 540) % 360) - 180
end

-- Color String
function colorString(str, color)
    return "&" .. tostring(color.gml) .. "&" .. str .. "&!&"
end

--syncControlRelease
local syncInputRelease
syncInputRelease = net.Packet.new("SSInputRel", function(sender, player, key)
	local playerI = player:resolve()
	if playerI and playerI:isValid() and key then
		playerI:getData()._keyRelease = key
	end
	if net.host then
		syncInputRelease:sendAsHost(net.EXCLUDE, sender, player, key)
	end
end)
function syncControlRelease(player, control)
	if player:control(control) == input.RELEASED then
		if net.online and net.localPlayer == player then
			if net.host then
				syncInputRelease:sendAsHost(net.ALL, nil, player:getNetIdentity(), control)
			else
				syncInputRelease:sendAsClient(player:getNetIdentity(), control)
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
