-- Lunar API

LunarCoins = 0
local AddedItemPools = {}
LunarColor = Color.fromHex(0x808EE1)

-- Lunar Coins
local coinUI
if modloader.checkMod("Starstorm") then
	coinUI = Sprite.load("Graphics/UI/coinUI_2.png", 1, 2, 11)
else
	coinUI = Sprite.load("Graphics/UI/coinUI.png", 1, 2, 11)
end
local LunarCoinDropChance = 1 -- Percent chance of dropping a Lunar Coin on-kill.
local dropSound = Sound.load("Items/resources/coinDrop.ogg")

-- Load Lunar Coins on Game Start
callback.register("onGameStart", function()
	LunarCoins = save.read("lunar_coins")
	for _, player in ipairs(misc.players) do
		Lunar.SetLunarCoins(player, LunarCoins)
	end
end, 10000)
callback.register("onStep", function()
	for _, player in ipairs(misc.players) do
		if player:isValid() then
			LunarCoins = player:get("lunar_coins")
		end
	end
end, 10000)

-- Define Lunar Item Pool
local lunar = ItemPool.new("lunar")
lunar.ignoreEnigma = false
local lunarCrate = lunar:getCrate()
lunarCrate.sprite = Sprite.load("Graphics/lunarCrate.png", 1, 8, 9)

-- API Functions
local lunar_items = {}
Lunar = {}

Lunar.addItem = function(item)
	lunar_items[item] = true
	lunar:add(item)
end

Lunar.addItem = function(item, notAddingToPool)
	lunar_items[item] = true
	if notAddingToPool ~= true then
		lunar:add(item)
	end
end

Lunar.GetLunarCoins = function(player)
	return player:get("lunar_coins") or 0
end

Lunar.SetLunarCoins = function(player, coins)
	player:set("lunar_coins", coins)
	if net.host == true then
		debugPrint("Lunar Items: Writing Lunar Coins to player's Save File.")
		save.write("lunar_coins", player:get("lunar_coins"))
		debugPrint("Lunar Items: Writing complete. "..player:get("lunar_coins").." Coin(s) saved.")
	end
end

-- Draw Lunar Coin count to HUD
callback.register("onPlayerHUDDraw", function(playerInstance, x, y)
	if misc.hud:get("show_gold") == 1 then
		local x1, y1 = graphics.getGameResolution()
		local coins = Lunar.GetLunarCoins(playerInstance) or 0
		graphics.drawImage({
			coinUI,
			13,
			(Sprite.find("Money", "vanilla").height * 2) + 5
		})
		graphics.color(Color.WHITE)
		graphics.printColor(tostring(coins), 13 + coinUI.width, ((Sprite.find("Money", "vanilla").height * 2) - 1), graphics.FONT_MONEY)
	end
end)

-- Lunar Coin (item)
local lunarCoin = Item.new("Lunar Coin")
lunarCoin.pickupText = "A strange currency. Maybe you can use it somewhere...?"
lunarCoin.sprite = Sprite.load("Items/resources/lunarCoin.png", 1, 10, 10)
lunarCoin.color = LunarColor

lunarCoin:addCallback("pickup", function(player)
	Lunar.SetLunarCoins(player, Lunar.GetLunarCoins(player) + 1)
	player:removeItem(lunarCoin)
	LunarCoins = Lunar.GetLunarCoins(player)
end)

if not save.read("lunar_coins") then
	debugPrint("Lunar Items: Lunar Coin count has not been found on player's save file.")
	save.write("lunar_coins", 0)
end

callback.register("onPlayerInit", function(player)
	if net.host == true then
		debugPrint("Lunar Items: Reading player's Save File for Lunar Coins...")
		if save.read("lunar_coins") then
			Lunar.SetLunarCoins(player, save.read("lunar_coins"))
		end
	end
end)

callback.register("onMinuteChange", function()
	debugPrint("Lunar Items: Saving players' Lunar Coins to file...")
	for _, player in ipairs(misc.players) do
		if net.host then
			save.write("lunar_coins", Lunar.GetLunarCoins(player))
		end
	end
	debugPrint("Lunar Coins: Save complete.")
end)

local CreateLunarCoin = net.Packet.new("Sync Lunar Coins", function(player, x, y)
	dropSound:play(1)
	lunarCoin:create(x, y)
end)

-- Dropping Coins
callback.register("onNPCDeath", function(actorInstance)
	if net.host then
		if math.chance(LunarCoinDropChance) then
			dropSound:play(1, 1)
			lunarCoin:create(actorInstance.x, actorInstance.y)
			if net.online then
				local x = actorInstance.x
				local y = actorInstance.y
				CreateLunarCoin:sendAsHost(net.ALL, nil, x, y)
			end
		end
	end
end)

-- Lunar Item Handler
callback.register("onItemInit", function(instance)
	if lunar_items[instance:getItem()] == true then
		instance:set("lunar", 1)
		instance:set("pickupTimer", 10)
	end
end)

local itemPO = ParentObject.find("items")
local touching = {}

callback.register("onStep", function()
	for _, inst in ipairs(itemPO:findMatching("lunar", 1)) do
		local acc = inst:getAccessor()
		-- Disables normal pickups
		inst:setAlarm(0, 10)
		if acc.pickupTimer > 0 then
			acc.pickupTimer = acc.pickupTimer - 1
		end
		-- Track if the item is being touched
		touching[inst] = nil
		if acc.used == 0 then -- Don't allow pickups if already picked up
			for _, player in ipairs(misc.players) do
				if inst:collidesWith(player, inst.x, inst.y) and acc.pickupTimer <= 0 then
					if player:control("enter") == input.PRESSED then
						if acc.is_use == 1 then
							if player.useItem ~= nil then
								local item = player.useItem
								item:create(inst.x, inst.y)
							end
							player.useItem = inst:getItem()
						else
							player:giveItem(inst:getItem())
						end
						acc.used = 1
						break
					else
						-- This makes sure the correct button for pickup is displayed in the pickup text
						touching[inst] = player
					end
				end
			end
		end
	end
end)
callback.register("onDraw", function()
	for _, inst in ipairs(itemPO:findMatching("lunar", 1)) do
		if touching[inst] then
			graphics.color(Color.WHITE)
			graphics.printColor("Press &y&'"..input.getControlString("enter").."'&!& to pick up.", math.floor(inst.x + 0.5 - 56), math.floor(inst.y + 0.5) + 40)
		end
	end
end)

--Exports
export("LunarCoins")
export("LunarColor")
export("Lunar")
