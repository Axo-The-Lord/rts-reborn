-- Disable self if Starstorm exists, it does the same thing basically
local starstormEnabled = modloader.checkMod("Starstorm")
if starstormEnabled then
	log("Starstorm is enabled, falling back to Starstorm's behavior for removing vanilla items.")
	return
end

-- All the removal functions
local removal_functions = {}

-- Initialize all the items
local allItems = {}
callback.register("postLoad", function()
	for _, item in ipairs(Item.findAll("vanilla")) do
		table.insert(allItems, item)
	end
	for _, namespace in ipairs(modloader.getMods()) do
		for _, item in ipairs(Item.findAll(namespace)) do
			table.insert(allItems, item)
		end
	end
end)

-- Create callback for things to register to
local itemRemovalCallback = callback.create("onItemRemoval")

-- Initialize item table for each player on init
callback.register("onPlayerInit", function(player)
	player:getData().ir_items = {}
end)

-- Code that figures out if items are removed each step, stolen from Starstorm
callback.register("onPlayerStep", function(player)
	local playerData = player:getData()
	local playerAc = player:getAccessor()

	if not playerData.lastItemCount then
		playerData.lastItemCount = player:get("item_count_total")
	end

	for _, item in ipairs(allItems) do
		local itCount = player:countItem(item)

		if playerData.ir_items[item] and itCount < playerData.ir_items[item] then
			local amount = playerData.ir_items[item] - itCount
			itemRemovalCallback(player, item, amount)
			playerAc.item_count_total = playerAc.item_count_total - amount
		end

		if itCount > 0 then
			playerData.ir_items[item] = itCount
		elseif playerData.ir_items[item] then
			playerData.ir_items[item] = nil
		end
	end
end)

callback.register("onItemRemoval", function(player, item, amt)
	if removal_functions[item] then
		local count = player:countItem(item)
		for i = count + amt - 1, count, -1 do
			removal_functions[item](player, i)
		end
	end
end)

-- Internal function to register removals for vanilla easier
function removal(name, func)
	local i = Item.find(name, "vanilla")
	if i then
		removal_functions[i] = func
	else
		log("Item '"..name.."' does not exist.")
	end
end

-- Internal function to adjust stats easier
function adjust(player, var, amt)
	player:set(var, player:get(var) + amt)
end

-- Include external files for all the removal functions for vanilla
local path = "Core/irl/"
require(path.."common")
require(path.."uncommon")
require(path.."rare")
require(path.."other")

-- An example file to show how you would register a new removal
require(path.."example")
