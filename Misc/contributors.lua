-- This is really just a test. Let me know if you think it's a good idea for mod contributors to have a special effect like this in Multiplayer lobbies. If you didn't know already, Starstorm does something similar

local names = {"Axo"}

callback.register("onPlayerInit", function(player)
	if net.online then
		local username = player:get("user_name")
		for _, name in pairs(names) do
			if string.lower(name) == string.lower(username) then
				player:getData().contributor = true
			end
		end
	end
end)

callback.register("onPlayerStep", function(player)
	if player:getData().contributor == true then
		local trail = Object.find("EfTrail", "vanilla"):create(player.x, player.y)
		trail.sprite = player.sprite
		trail.subimage = player.subimage
		trail.blendColor = Color.RED
		trail.xscale = player.xscale
		trail.yscale = player.yscale
		trail.angle = player.angle
		trail.alpha = 1
		trail.depth = 0
	end
end)
