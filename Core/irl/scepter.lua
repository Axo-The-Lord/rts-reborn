scepterRemoval = {
	[Survivor.find("Commando")] = function(player)
		player:setSkill(4, "Suppressive Fire",
			"Fires rapidly, stunning and hitting nearby enemies for 6x60% damage total.",
			Sprite.find("GManSkills"), 4, 300)
		player:setAnimation("shoot4_1", Sprite.find("GManShoot4_1"))
		player:setAnimation("shoot4_2", Sprite.find("GManShoot4_2"))
	end,
	[Survivor.find("Enforcer")] = function(player)
		player:setSkill(4, "Crowd Control",
			"Launch a stun grenade, stunning enemies in a huge radius for 250% damage. Can bounce at shallow angles.",
			Sprite.find("RiotSkills"), 5, 300)
	end,
	[Survivor.find("Bandit")] = function(player)
		player:setSkill(4, "Lights Out",
			"Fire a headshot for 600% damage. If this ability kills an enemy, the Bandit's cooldowns are all reset to 0.",
			Sprite.find("CowboySkills"), 4, 420)
		player:setAnimation("shoot4", Sprite.find("CowboyShoot4"))
	end,
	[Survivor.find("Huntress")] = function(player)
		player:setSkill(4, "Cluster Bomb",
			"Fire an explosive arrow for 320% damage. The arrow drops bomblets that detonate for 6x80%.",
			Sprite.find("Huntress1Skills"), 4, 420)
		player:setAnimation("shoot4", Sprite.find("Huntress1Shoot4"))
	end,
	[Survivor.find("HAN-D")] = function(player)
		player:setSkill(4, "FORCED_REASSEMBLEY",
			"APPLY GREAT FORCE TO ALL COMBATANTS FOR 500% DAMAGE, KNOCKING THEM IN THE AIR.",
			Sprite.find("JanitorSkills"), 3, 300)
		player:setAnimation("shoot4", Sprite.find("JanitorShoot4"))
	end,
	[Survivor.find("Engineer")] = function(player)
		local stacks = math.min(player:get("v_stack"), 2)
		player:setSkill(4, "Auto Turret",
			"Drop a turret that shoots for 3x100% damage for 30 seconds. Hold up to 2.",
			Sprite.find("EngiSkills"), 17 + stacks, 2400)
		player:set("v_stack_max", 2)
		player:set("v_stack", stacks)
	end,
	[Survivor.find("Miner")] = function(player)
		player:setSkill(4, "To The Stars",
			"Jump into the air, hitting enemies below for 3x180% damage total.",
			Sprite.find("MinerSkills"), 4, 300)
	end,
	[Survivor.find("Sniper")] = function(player)
		local sniperSkills = Sprite.find("SniperSkills")
		player:setSkill(4, "Spotter: SCAN",
			"Send your Spotter out to analyze the most dangerous enemy, increasing critical strike chance against it by 100%.",
			sniperSkills, 5, 600)
		local drone = Object.findInstance(player:get("drone"))
		if drone and drone:isValid() and drone:get("tt") >= 0 then
			player:setSkillIcon(4, sniperSkills, 6)
		end
	end,
	[Survivor.find("Acrid")] = function(player)
		player:setSkill(4, "Epidemic",
			"Release a deadly disease, poisoning enemies for 100% damage per second. The contagion spreads to two targets after 1 second.",
			Sprite.find("Feral2Skills"), 4, 660)
		player:setAnimation("shoot4", Sprite.find("Feral2Shoot4"))
	end,
	[Survivor.find("Mercenary")] = function(player)
		player:setSkill(4, "Eviscerate",
			"Target the nearest enemy, quickly attacking them for 6x110% damage. You cannot be hit for the duration.",
			Sprite.find("SamuraiSkills"), 5, 360)
		player:setAnimation("shoot4", Sprite.find("SamuraiShoot4"))
	end,
	[Survivor.find("Loader")] = function(player)
		player:setSkill(4, "M440 Conduit",
			"Place a lightning rod. After placing two, lightning surges between them, dealing 80% damage for 9 seconds.",
			Sprite.find("LoaderSkills"), 4, 120)
	end,
	[Survivor.find("CHEF")] = function(player)
		player:setSkill(4, "SECOND HELPING",
			"PREPARE A MASTER MEAL, BOOSTING THE NEXT ABILITY CAST.",
			Sprite.find("ChefSkills"), 4, 480)
	end,
}
