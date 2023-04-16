-- Gesture of the Drowned

local item = Item("Gesture of the Drowned")
item.pickupText = "Dramatically reduce Use Item cooldown... BUT it automatically activates."
item.sprite = Sprite.load("Items/resources/gesture.png", 1, 16, 16)
Lunar.addItem(item)
item.color = LunarColor

-- Pickup
item:addCallback("pickup", function(player)
    if player:countItem(item) > 1 then
        player:set("use_cooldown", player:get("use_cooldown") * 0.85)
    else
        player:set("use_cooldown", player:get("use_cooldown") / 2)
    end
end)

-- Force Activation
local sound = Sound.find("Pickup", "vanilla")

registercallback("onPlayerStep", function(player)
    if player:countItem(item) > 0 then
        if player.useItem then
            if player:getAlarm(0) <= -1 then
                player:activateUseItem()
                if modloader.checkFlag("rts-mute-gesture") then
                    if (player.useItem.useCooldown * 60) * (1 - player:get("use_cooldown")) < 60 then
                        if sound:isPlaying() then
                            sound:stop()
                        end
                    end

                end
                if player:getAlarm(0) > 0 then
                    player:setAlarm(0, (((player.useItem.useCooldown * 60) * (player:get("use_cooldown") / 45) )))
                end
            end
        end
    end
end)

-- Item Log
item:setLog{
	group = "end",
	description = "&b&Reduce Use Item Cooldown&!& by &b&50%&!&. Forces your Use Item to &b&activate&!& whenever it is off &b&cooldown&!&.",
	story = "Fossils. Remnants. How cruel.\n\nThis moon once housed life. Life that you may have held dear, had the timing been right. But our timing was wrong. We were born much too late.\n\nNow, it is just calcium to me - and irrelevant to you. Isn\'t that right?",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = colorString("Unaccounted For", LunarColor)
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
	TabMenu.setItemInfo(item, 1, "Dramatically reduce Use Item cooldown... BUT it automatically activates.", nil)
end