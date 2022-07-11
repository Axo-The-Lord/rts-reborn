-- Glowing Meteorite

if not modloader.checkFlag("rts_classic_meteorite") then
	local meteorite = Item.find("Glowing Meteorite","vanilla")
	meteorite.sprite:replace(Sprite.load("Items/resources/meteor", 2, 20, 19))
	local useItems = ItemPool.find("use", "vanilla")
	useItems:remove(meteorite)
	meteorite.color = LunarColor
	meteorite:setLog{
		group = "end",
		story = "What a... peculiar piece of the stars that serendipity has brought us. I\'m sure you can make more. The ratios are simple. It should be quite fun.",
		destination = "???",
		date = "???",
		priority = colorString("Unaccounted For", LunarColor)
	}
	Lunar.addItem(meteorite)
end
