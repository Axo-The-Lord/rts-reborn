-- Transcendence

local item = Item("Transcendence")
item.pickupText = "Convert all your health into shield. Increase maximum health."
item.sprite = Sprite.load("Items/resources/transcendence.png", 1, 15, 13)
Lunar.addItem(item)
item.color = LunarColor

local bugIcon = Sprite.load("Items/resources/transcendenceDisplay.png", 1, 7, 11)

callback.register("onPlayerDraw", function(player)
	if player:countItem(item) > 0 then
		if player:get("shield") > 0 then
			graphics.drawImage{
				image = bugIcon,
				x = player.x,
				y = player.y - (player.sprite.height / 2),
				alpha = 0.5
			}
		end
	end
end)

local gHeart = Item.find("Guardian's Heart")
item:addCallback("pickup", function(player)
	local pAcc = player:getAccessor()
	local pDat = player:getData()
	local itemCount = player:countItem(item)
	-- convert all current health to shields on pickup, or multiply current shields if itemCount > 1
	local shieldBonus = pAcc.maxhp * 1.5
	if itemCount > 1 then
		local shieldFactor = 1.5 + 0.25 * (itemCount-2) --(-2)=ignoring the base item(*1.5) & the current one being added
		local heartShield = 60 * player:countItem(gHeart)
		shieldBonus = ((pAcc.maxshield - heartShield) / shieldFactor) * 0.25 -- 0.25 * original hp
	end
	pAcc.maxshield = pAcc.maxshield + shieldBonus
	pAcc.shield = pAcc.maxshield
	pAcc.shield_cooldown = 7 * 60
	pAcc.maxhp_base = 1
	--percent_hp is already applied earlier in multiplying hp/shield, but then still stored for later:
	pDat.percent_hp = pDat.percent_hp or 1
	pAcc.percent_hp = 1
end)

callback.register("onPlayerStep", function(player)
	local itemCount = player:countItem(item)
	if itemCount > 0 then
		local pAcc = player:getAccessor()
		local pDat = player:getData()
		if pAcc.percent_hp > 1 then
			-- Remove percent_hp and apply new percent_hp. Also account for Guardian's Heart
			local heartShield = 60 * player:countItem(gHeart)
			local newShield = pAcc.maxshield - heartShield
			newShield = newShield / pDat.percent_hp
			--store percent_hp so it can be used later
			pDat.percent_hp = pDat.percent_hp + pAcc.percent_hp-1
			pAcc.percent_hp = 1

			newShield = newShield * pDat.percent_hp
			pAcc.maxshield = newShield + heartShield
		elseif pAcc.maxhp_base > 1 then
			local shieldFactor = 1.5 + 0.25 * (itemCount-1) --(-1)=only ignoring the base item
			local shieldBonus = (pAcc.maxhp_base-1) * shieldFactor * pDat.percent_hp
			pAcc.maxshield = pAcc.maxshield + shieldBonus
			pAcc.maxhp_base = 1
		end
	end
end)

item:setLog{
	group = "end",
	description = "&g&convert&!& all but &g&1 health&!& into &b&regenerating shields.&!& &g&Gain 50%&!& &g&maximum health.&!&",
	story = "You are trying your best to survive. You consider yourself a fast learner. You have been feeling lucky. You have been experiencing feelings of deja vu. If you understand, do not read the next paragraph.\n\nYou are taking control of your own beliefs. You feel familiar in unfamiliar environments. You have been gaining an intuition for experiences you've never had. You ponder a past life. If you understand, do not read the next paragraph.\n\nYou find yourself searching for things that never have been. You miss things you have never had. You play characters that have never lived. You have been experiencing feelings of deja vu. If you understand, do not read the next paragraph.\n\nYou have revealed my hand. Because you have consumed this information, the [observers] will now consume it in time. If you are reading this paragraph, I will be long dead, but in turn you have freed me. I will no longer exist in my universe. There will be no proof that I ever was - but I exist now in yours. I have escaped my suffering. Keep me safe. I hope you do not understand.",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = colorString("Unaccounted For", LunarColor)
}
