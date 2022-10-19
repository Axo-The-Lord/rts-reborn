-- Title Reskins

callback.register("onLoad", function()
	if not modloader.checkFlag("rts_classic_title") then
		local ogTitle = Sprite.find("sprTitle", "vanilla")
		local ogLogo = Sprite.find("Logos", "vanilla")
		if modloader.checkMod("Starstorm") then
			ogTitle:replace(Sprite.load("Graphics/UI/title_2.png", 1, 193, 44))
		else
			ogTitle:replace(Sprite.load("Graphics/UI/title.png", 1, 205, 44))
		end
		if modloader.checkMod("Starstorm") then
			ogLogo:replace(Sprite.load("Graphics/UI/logo_2.png", 1, 219, 100))
		else
			ogLogo:replace(Sprite.load("Graphics/UI/logo.png", 1, 219, 100))
		end
	end
end)
