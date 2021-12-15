--------------------------------------------------------------------------

        -- Custom Map Object Library by Sivelos
                    -- Version 2.0.0

--------------------------------------------------------------------------


MapObject = {}

local actors = ParentObject.find("actors", "vanilla")
local objectInstance = {}
local objectProperties = {}
local objectSpawnRules = {}
local objectSprites = {}
local objectCallbacks = {}
local objectCount = 0

--------------------------------------------------------------------------

-- Use the control character &$& to insert your object's cost into the activeText or useText.

--------------------------------------------------------------------------


local variables = {
    ["sprite"] = "Sprite", -- The mapObject's sprite. It will always stay on the first frame of its sprite if it doesn't have a useSprite.

    -- Optional
    ["baseCost"] = "number", --The base cost of the object. Defaults to 25.
    ["currency"] = "string", -- The name of the variable that the map object will deduct from the activator upon activating.
        --Keep in mind what variables are used by which objects, since some variables might return nil. Defaults to "gold".
        --Certain strings will affect unique stats.
            -- "gold": The default currency. Affects the player's gold.
            -- "items": The object will deduct items from the player - if this currency is used, please make sure to set the "itemTier" variable as well.
    ["isPercentage"] = "boolean", --When set to 1, the object will deduct a percentage of the player's stat based on cost. Used for stuff like Blood shrines.
                                  --Example: if cost is equal to 0.5 and isPercentage is true, it would charge the player 50% of their currency.
    ["itemTier"] = "string", --If currency is set to "items", the object will deduct items from the specified item tier.
        --Example: If itemTier is "uncommon", the object will deduct [cost] Uncommon items from the player.
        --Must be common, uncommon, rare, or use.
    ["affectedByDirector"] = "boolean", --When set to true, the object's cost will be modified upon creation, like chests.
    ["affectPurchases"] = "boolean", --When set to true, activating this object will count towards the activator's purchases.
    ["costIncrease"] = "number", --The percentage of which the object's base cost is added to its current cost when recalculating the cost. Set to 0 for it to never increase.
    ["customCostCalculation"] = "boolean", --If true, a callback will be fired after the object is activated where you can put custom cost recalculation logic. Keep in mind that this will disable default cost calculation.
    ["mask"] = "Sprite", -- Used for collisions.
    ["input"] = "string", --the input as a string required to activate the object. Defaults to enter. See the RORML Documentation's page on the Input module for more information.
    ["name"] = "string", -- The object's name.
    ["activeText"] = "string", --The text displayed beneath a mapObject at all times. Example: The cost of a Rock Shrine. Supports colored text.
    ["useText"] = "string", --The text that appears above a mapObject when being collided with by a player. Typically prompts the player to activate the object. Supports colored text.
    ["useXOff"] = "number", --Offsets the object's use text along the X axis by this much. Useful for repositioning the use text. Defaults to 0. NOTE: This applies to the Use Text AFTER it has been formatted to not include control characters such as &!& into its positioning.
    ["useYOff"] = "number", --Offsets the object's use text along the Y axis by this much. Useful for repositioning the use text. Defaults to 0. NOTE: This applies to the Use Text AFTER it has been formatted to not include control characters such as &!& into its positioning.
    ["useSprite"] = "Sprite", -- The sprite displayed by the object when it is used. Upon reaching its final frame, it will return to its normal sprite, or play its death sprite if it is considered dead.
    ["deathSprite"] = "Sprite", -- The sprite displayed by the object when it dies. Typically played after its useSprite after becoming dead. Upon reaching its final frame, it will stop animating and stay on that frame until destroyed.
    ["destroyOnDeath"] = "boolean", --If set to true, when the object reaches the last frame of its deathSprite (if applicable), it will be PERMANENTLY removed from the map.
    ["maxUses"] = "number", --the amount of times the object can be activated before dying.
    ["unlimitedUses"] = "boolean", --If set to true, the mapObject will not check for maxUses and can be used infinitely. Good for testing or objects that conditionally incriment uses.
    ["waitBeforeNextUse"] = "number", --Will make the object wait for X frames before becoming activatable again - if applicable.
    ["triggerFireworks"] = "boolean", -- Whether or not the mapObject will spawn Fireworks upon being activated.

    --[[ Should NOT be set outside this library, but can be read, with some exceptions.
    ["cost"] = "number", --The cost of the object, after modifications by the Director and recalculation logic. Can be set outside the library.
    ["uses"] = "number", -- The amount of times the mapObject has been used. Can be set outside the library.
    ["activated"] = "number", --Set to 1 when the object is activated. When activated, the object will not accept input nor detect collisions.
    ["dead"] = "number", --Set to 1 when the object's used exceed maximum uses. When dead, the object is considered unusable and will not accept input.
    ["active"] = "number", --Determines if the object logic should be run. If equal to 1, the logic will not be run.
    ["collidingWithPlayer"] = "number", -- Set to 1 when a player is colliding with the mapObject. 0 otherwise.
    ["waitTimer"] = "number", --Set to waitBeforeNextUse upon activation, and counts down each step until it hits zero.
    ["activator"] = "number", --The playerIndex of the player who activated the object.]]

}

spawnable_ground = {}
local oB = Object.find("B")

-- Callbacks:
-- NOTE: due to binding callbacks to specific object instances being unsupported by RoRML at the time of writing, it is recommended that
-- you check to make sure the passed in objectInstance is the proper object, as the following callbacks are global.
-- Example:
--[[
    registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == myObject then
        --Do things
    end
end)
]]
local onObjectActivated = createcallback("onObjectActivated") --Triggered each frame while the object is activated. Put whatever your object does here.
    -- Parameters: the activated object, the object's current frame of animation, the object's coordinates, and the player who activated it.
local onObjectFailure = createcallback("onObjectFailure") --Triggered if the player tries to use the object with insufficient funds.
    -- Parameters: The activated object, and the player who tried to activate it.
local postObjectUse = createcallback("postObjectUse") --Triggered after the object is activated and after it returns to its idle state.
    -- Parameters: the activated object, and the player who activated it.
local onObjectDeath = createcallback("onObjectDeath") --Triggered when the object dies. If the object dies upon use, this will be triggered instead of postObjectUse.
    -- Parameters: the activated object, and the player who activated it.
local onCostCalculation = createcallback("onCostCalculation") --Triggered after the object has been activated, and only if customCostCalculation is true. Put any custom cost recalculation logic here.
    -- Parameters: the activated object, the player who activated it, its uses, its base cost, its current cost, and its currency as a string.
    -- Note: You will have to set the cost yourself if you use this callback. [object]:set("cost", var), for example.

local debugPrint = function(message, flag)
    if not flag then
        if modloader.checkFlag("mapObjectLib_debug") then
            print(message)
        end
    else
        if modloader.checkFlag(flag) then
            print(message)
        end
    end
end

local ActivateObj = function(self, player)
    if self:get("activated") == 0 then
        local currencyVal = 0
        self:set("activator", player.playerIndex)
        currencyVal = MapObject.GetObjectCurrencyVal(self, player)
        if currencyVal >= self:get("cost") then
            MapObject.DeductCost(self, player)
            if self:get("affectPurchases") then
                if self:get("affectPurchases") == 1 then
                    player:set("opened_chests", player:get("opened_chests") + 1)
                end
            end
            self:set("activated", 1)
            self.sprite = (objectSprites[self:get("useSprite")] or self.sprite)
            self.spriteSpeed = 0.25
            self:set("waitTimer", self:get("waitBeforeNextUse"))
            if self:get("unlimitedUses") ~= 1 then
                self:set("uses", self:get("uses") + 1)
            end
            if self:get("customCostCalculation") == 1 then
                onCostCalculation(self, self:get("activator"), self:get("uses"), self:get("baseCost"), self:get("cost"), self:get("currency"))
            else
                self:set("cost", MapObject.CalculateCost(self))
            end
            if self:get("triggerFireworks") and player:countItem(Item.find("Bundle of Fireworks", "vanilla")) then
                for i = 1, player:countItem(Item.find("Bundle of Fireworks", "vanilla")) * 8 do
                    Object.find("EfFirework","vanilla"):create(self.x, self.y)
                end
            end

        else
            onObjectFailure(self, player)
        end
    end
end


local SyncActivation = net.Packet.new("Sync Map Object Activation", function(player, id)
    local mapobject = Object.findInstance(id)
    if mapobject and mapobject:isValid() then
        ActivateObj(mapobject, player)
    end
end)

MapObject.new = function(properties) --Creates a brand new Map Object using the provided variables. You probably shouldn't touch this method unless something is very, very wrong.
    local _mapObject = nil
    if (not properties) or (not properties.name) then objectCount = objectCount + 1 ; _mapObject =  Object.new(tostring(objectCount))
	else _mapObject = Object.base("mapobject", tostring(properties.name)) end
	objectProperties[_mapObject] = {}
	for k,v in pairs(variables) do
		if (v ~= "boolean" and properties[k] and type(properties[k]) == v) or (v == "boolean" and (properties[k] == false or properties[k] == true)) then
			if v == "Sprite" then
                if k == "sprite" then
                    _mapObject.sprite = properties[k]
                end
				objectProperties[_mapObject][k] = properties[k]:getName()
				objectSprites[properties[k]:getName()] = properties[k]
			elseif v == "boolean" then
				if (properties[k] == true) then objectProperties[_mapObject][k] = 1
				else objectProperties[_mapObject][k] = 0 end
            else
                objectProperties[_mapObject][k] = properties[k]
            end
		end
    end
    _mapObject:addCallback("create", function(objectInstance)
        if objectInstance:isValid() then
            debugPrint("Successfully spawned Map Object "..(objectInstance:getObject():getName() or "[Name Missing]").." at x:"..objectInstance.x..", y:"..objectInstance.y..".")
            for k,v in pairs(objectProperties[objectInstance:getObject()]) do
		    	objectInstance:set(k, v)
            end
            if objectSprites[objectInstance:get("useSprite")] ~= nil then
                objectInstance.spriteSpeed = 0.25
            else
                objectInstance.spriteSpeed = 0
            end
            if objectInstance:get("waitBeforeNextUse") == nil then
                objectInstance:set("waitBeforeNextUse", 60)
            end
            if objectInstance:get("input") == nil then
                objectInstance:set("input", "enter")
            end
            if objectInstance:get("baseCost") == nil then
                objectInstance:set("baseCost", 25)
            end
            if objectInstance:get("currency") == nil then
                objectInstance:set("currency", "gold")
            end
            objectInstance:set("cost", objectInstance:get("baseCost"))
            if objectInstance:get("activeText") == nil then
                objectInstance:set("activeText", "$"..objectInstance:get("cost"))
            end
            if objectInstance:get("useText") == nil then
                objectInstance:set("useText", "Press '".. objectInstance:get("input").."' to activate.")
            end
            if objectInstance:get("useXOff") == nil then
                objectInstance:set("useXOff", 0)
            end
            if objectInstance:get("useYOff") == nil then
                objectInstance:set("useYOff", 0)
            end
            if objectInstance:get("affectedByDirector") == nil then
                objectInstance:set("affectedByDirector", 0)
            end
            objectInstance:set("cost", MapObject.CalculateCost(objectInstance) or objectInstance:get("baseCost"))
            objectInstance:set("waitTimer", objectInstance:get("waitBeforeNextUse") or 0)
            objectInstance:set("dead", 0)
            objectInstance:set("activated", 0)
            objectInstance:set("active", 0)
            objectInstance:set("uses", 0)
            if objectInstance:get("affectedByDirector") == 1 then
                local director = misc.director
                objectInstance:set("cost", math.round(objectInstance:get("baseCost") * Difficulty.getScaling("cost")))
            end
            objectInstance.mask = objectSprites[objectProperties[objectInstance:getObject()].mask] or objectInstance.sprite
        end
    end)
    _mapObject:addCallback("step", function(self)
        if self:get("active") == 0 then
            self:set("currentSubimage", math.round(self.subimage))
            local player = actors:findNearest(self.x, self.y)
            if self:collidesWith(actors:findNearest(self.x, self.y), self.x, self.y) and isa(player, "PlayerInstance") then
                self:set("collidingWithPlayer", 1)
                if input.checkControl(self:get("input"), player) == input.PRESSED then
                    ActivateObj(self, player)
                    if net.online then
                        if net.host then
                            SyncActivation:sendAsHost(net.ALL, nil, self.id)
                        else
                            SyncActivation:sendAsClient(self.id)
                        end
                    end
                end
            else
                self:set("collidingWithPlayer", 0)
            end

            if self:get("activated") == 1 then
                if self:get("dead") ~= 1 then
                    if math.round(self.subimage) >= self.sprite.frames + 1 then
                        if self:get("uses") >= self:get("maxUses") then
                            self:set("dead", 1)
                            self.sprite = (objectSprites[self:get("deathSprite")] or self.sprite)
                            if objectSprites[self:get("deathSprite")] ~= nil then
                                self.spriteSpeed = 0.25
                                self.subimage = 1
                            else
                                self.spriteSpeed = 0
                            end
                        else
                            if self:get("waitTimer") <= 0 then
                                self:set("activated", 0)
                                self.subimage = 1
                                if objectSprites[self:get("useSprite")] ~= nil then
                                    self.spriteSpeed = 0.25
                                else
                                    self.spriteSpeed = 0
                                end
                            end
                        end
                    end
                end
                if self:get("currentSubimage") ~= self:get("lastSubimage") then
                    if self:get("dead") == 1 then
                        --print(math.round(self.subimage) .. "/".. self.sprite.frames)
                        if math.round(self.subimage) >= self.sprite.frames + 1 then
                            self.spriteSpeed = 0
                            if self:get("destroyOnDeath") == 1 then
                                self:destroy()
                            else
                                self:set("active", 1)
                            end
                        end
                    else
                        onObjectActivated(self, math.round(self.subimage) - 1, misc.players[self:get("activator")], self.x, self.y)
                        if math.round(self.subimage) >= self.sprite.frames + 1 then
                            if self:get("uses") >= self:get("maxUses") then
                                onObjectDeath(self, self:get("activator"))
                            else
                                postObjectUse(self, self:get("activator"))
                            end
                            self.spriteSpeed = 0
                        end
                    end
                end
            end
            if self:isValid() then
                self:set("lastSubimage", math.round(self.subimage))
                if self:get("waitTimer") > 0 then
                   self:set("waitTimer", self:get("waitTimer") - 1)
                end
            end
        end

    end)
    _mapObject:addCallback("draw", function(self)
        if self:get("active") == 0 then
            if self:get("activated") == 0 then
                --Draw use text
                graphics.alpha(1)
                local cost = self:get("cost")
                if self:get("isPercentage") == 1 then
                    cost = cost * 100
                end
                local useText = self:get("useText"):gsub("&$&", tostring(cost))
                local useFormatted = useText:gsub("&[%a]&", "")
                if self:get("collidingWithPlayer") == 1 then
                   graphics.printColor(useText, (self.x - (graphics.textWidth(useFormatted, graphics.FONT_DEFAULT) / 2)) + self:get("useXOff"), (self.y - (self.sprite.height + (graphics.textHeight(useText, graphics.FONT_DEFAULT) + 5))) + self:get("useYOff"), graphics.FONT_DEFAULT)
                end
                --Draw active text
                local font = false
                local activeText = self:get("activeText"):gsub("&$&", tostring(cost))
                local activeFormatted = activeText:gsub("&[%a%p%C]&", "")
                if string.find(activeFormatted, "%a") then
                    font = true
                end
                graphics.alpha(0.7+(math.random()*0.15))
                if font then
                    graphics.printColor(activeText, self.x - (graphics.textWidth(activeFormatted, NewDamageFont) / 2), self.y + (graphics.textHeight(activeFormatted, NewDamageFont)), NewDamageFont)
                else
                    graphics.printColor(activeText, self.x - (graphics.textWidth(activeFormatted, graphics.FONT_DAMAGE) / 2), self.y + (graphics.textHeight(activeFormatted, graphics.FONT_DAMAGE)), graphics.FONT_DAMAGE)
                end
            end
        end
    end)
    return _mapObject
end

MapObject.create = function(mapObject, x, y)
    local _objectInstance = mapObject:create(x,y)
    return _objectInstance
end

--Changes the passed-in MapObject's variables when called.
MapObject.configure = function(objectInstance, properties)
	if objectInstance:get("dead") == 0 then
		for k,v in pairs(variables) do
			if (v ~= "boolean" and properties[k] and type(properties[k]) == v) or (properties[k] == false or properties[k] == true) then
				if v == "Sprite" then
					if k == "sprite" then objectInstance.sprite = properties[k] end
					objectInstance:set(k, properties[k]:getName())
					objectSprites[properties[k]:getName()] = properties[k]
				elseif v == "boolean" then
					if properties[k] == true then objectInstance:set(k, 1)
					else objectInstance:set(k, 0) end
				else objectInstance:set(k, properties[k])	end
			end
		end
	end
end

--The default cost recalculation logic for Map Objects. Returns the new cost of the Object. Takes in an object instance.
MapObject.CalculateCost = function(objectInstance)
    if objectInstance:isValid() then
        if objectInstance:get("dead") == 0 then
            local newCost = 0
            newCost = objectInstance:get("cost")
            newCost = math.round((newCost * objectInstance:get("costIncrease")))
            return newCost
        end
    end
end

-- Returns the current value of the object's currency.
-- Variables:
    -- objectInstance: The MapObject instance whose currency variable will be used in the check.
    -- player: The player whose currency is being checked.
MapObject.GetObjectCurrencyVal = function(objectInstance, player)
    if objectInstance:get("currency") == "gold" then
        return misc.getGold()
    elseif objectInstance:get("currency") == "items" then
        local poolsToCheck = {
            ItemPool.find("common", "vanilla"),
            ItemPool.find("uncommon", "vanilla"),
            ItemPool.find("rare", "vanilla"),
            ItemPool.find("use", "vanilla"),
        }
        local itemCounts = {
            ["common"] = 0,
            ["uncommon"] = 0,
            ["rare"] = 0,
            ["use"] = 0
        }
        local tierToCheck = "common"
        if objectInstance:get("itemTier") then
            if objectInstance:get("itemTier") == "uncommon" then
                tierToCheck = "uncommon"
            elseif objectInstance:get("itemTier") == "rare" then
                tierToCheck = "rare"
            elseif objectInstance:get("itemTier") == "use" then
                tierToCheck = "use"
            end
        end
        for _, pool in ipairs(poolsToCheck) do
            for _, item in ipairs(pool:toList()) do
                if pool == ItemPool.find("common", "vanilla") then
                    itemCounts.common = itemCounts.common + player:countItem(item)
                elseif pool == ItemPool.find("uncommon", "vanilla") then
                    itemCounts.uncommon = itemCounts.uncommon + player:countItem(item)
                elseif pool == ItemPool.find("rare", "vanilla") then
                    itemCounts.rare = itemCounts.rare + player:countItem(item)
                elseif pool == ItemPool.find("use", "vanilla") then
                    itemCounts.use = itemCounts.use + player:countItem(item)
                end
            end
        end
        return itemCounts[tierToCheck]
    else
        return player:get(objectInstance:get("currency")) or 0
    end
end

-- Removes [cost] from the player's currency stat.
-- Variables:
    -- objectInstance: The MapObject instance deducting the cost.
    -- player: The player affected by the MapObject.
local itemremover = require("Core.irl.main")

MapObject.DeductCost = function(objectInstance, player)
    local deduction = 0
    if objectInstance:get("currency") == "items" then
        debugPrint("Begnning deduction of "..objectInstance:get("cost").." "..objectInstance:get("itemTier").." item(s).")
        local poolsToCheck = {
            ItemPool.find("common", "vanilla"),
            ItemPool.find("uncommon", "vanilla"),
            ItemPool.find("rare", "vanilla"),
            ItemPool.find("use", "vanilla"),
        }
        local items = {
            ["common"] = {},
            ["uncommon"] = {},
            ["rare"] = {},
            ["use"] = {}
        }
        for _, pool in ipairs(poolsToCheck) do
            for _, item in ipairs(pool:toList()) do
                if player:countItem(item) > 0 then
                    for i=0, player:countItem(item) - 1 do
                        if pool == ItemPool.find("common", "vanilla") then
                            table.insert(items.common, item)
                        elseif pool == ItemPool.find("uncommon", "vanilla") then
                            table.insert(items.uncommon, item)
                        elseif pool == ItemPool.find("rare", "vanilla") then
                            table.insert(items.rare, item)
                        elseif pool == ItemPool.find("use", "vanilla") then
                            table.insert(items.use, item)
                        end
                        debugPrint("Adding item "..item:getName().." to list for random selection.")
                    end
                end
            end
        end
        deduction = objectInstance:get("cost")
        for i=0, deduction - 1 do
            local itemToRemove = table.irandom(items.common)
            if objectInstance:get("itemTier") == "uncommon" then
                itemToRemove = table.irandom(items.uncommon)
            elseif objectInstance:get("itemTier") == "rare" then
                itemToRemove = table.irandom(items.rare)
            elseif objectInstance:get("itemTier") == "use" then
                itemToRemove = table.irandom(items.use)
            end
            debugPrint("Removing item "..itemToRemove:getName().." from player.")
            player:removeItem(itemToRemove, 1)
            debugPrint("Progress: "..i.."/"..deduction)
        end

        debugPrint("Complete!")
    else
        if objectInstance:get("isPercentage") == 1 then
            if objectInstance:get("currency") == "gold" then
                deduction = misc.getGold() * objectInstance:get("cost")
            else
                deduction = player:get(objectInstance:get("currency")) * objectInstance:get("cost")
            end
        else
            deduction = objectInstance:get("cost")
        end
        if objectInstance:get("currency") == "gold" then
            misc.setGold(misc.getGold() - deduction)
        else
            player:set(objectInstance:get("currency"), player:get(objectInstance:get("currency")) - deduction)
        end
    end
end

local SyncSpawnedObject = net.Packet.new("Sync Spawned Objects", function(player, objID, x, y)
    local object = Object.fromID(objID)
    if object then
        MapObject.create(object, x, y)
    end
end)

-- Registers the passed in object to be spawned during onStageEntry.
-- Variables:
    -- object: The map object that will be spawned.
    -- rules: A table that can hold various other information to take into account when spawning your object. See below for what values you can pass in.
    local spawnRules = {
        --Mandatory
        ["spawnChance"] = "number", --The likelihood that the object will be spawned. The lower it is, the higher the chance. Must NOT be less than 1.
        ["maxAmount"] = "number", --The game will attempt to spawn up to this many MapObjects.

        --Optional
        ["minAmount"] = "number", --If set, the game will always spawn this many MapObjects before deciding to spawn them based on spawnChance. If not set or set to 0, each MapObject up to maxAmount will have a chance not to be spawned.
        ["coordinates"] = "table", -- Each slot in coordinates holds an 'x' and 'y' value. Your map object will be spawned in one of these coordinates at the closest "B" collision object, chosen randomly.
            --If a mapObject has already been spawned on a set of coordinates, another mapObject cannot be spawned on it.
            --Example: coordinates = {{x = 1, y = 2}, {x = 200, y = 200}}. You MUST format it this way!
            --PLEASE NOTE: If you use the spawnable_ground field alongside this, your mapObject may spawn in odd places. When spawning, it finds the closest available
            --ground to spawn, closest to the coordinates provided.
        ["bannedStages"] = "table", -- A table of strings that contains the display names of stages. Your mapObject will NOT spawn on any of the stages provided.
            -- Example: bannedStages = {"Desolate Forest", "Dried Lake"}
            -- A mapObject using this stages table will not spawn on Desolate Forest or Dried Lake, but may spawn on other stages.
        ["spawnable_ground"] = "table", --A table of strings containing the names of the collision object the object can spawn on. Defaults to B, being the universal collision object.
            -- Example: spawnable_ground = {"BNoSpawn", "Water"}
            -- A mapObject using this spawnable_ground table will only spawn on ground where enemies cannot spawn, or under water.
        ["affectedByDirector"] = "boolean", --Enabling this will cause the object's spawn chance to be influenced by the director. As you go further into a run, your object may spawn more often.
            -- Defaults to false, meaning that the director cannot affect how often your item spawns.
        ["directorInfluence"] = "number", -- When affectedByDirector is true, the amount that the spawn chance will be changed will be multiplied by this number.
            -- Example: A directorInfluence of 2 will mean that the amount the director changes the object's spawn chance will be doubled - however much that is.
            -- Defaults to 1, meaning there will be no extra influence.
        ["minimumSpawnChance"] = "number", --The object's spawn chance cannot dip below this number if influenced by the director.
            -- You probably won't need this if affectedByDirector is false.
            -- SHOULD NOT BE LESS THAN OR EQUAL TO 0!
            -- This is in place to prevent objects having a 100% chance to spawn - unless you want that.
            -- Example: If this was 5, and the object's normal spawn chance was 10, the object would have a spawn chance between 1/5 and 1/10.
            -- Defaults to 1, meaning that the object can reach a spawn chance of 100% after director influence.
        ["custom_rules"] = "table", --A table of functions that can be defined by the user to influence whether or not the object spawns.
            -- Custom Rules are taken into account prior to all other rules - please keep this in mind. If you have a custom rule preventing spawn, but all other
            -- vanilla rules are checking out, the custom rule will override it and prevent a spawn.
            -- IMPORTANT: These functions do not take any parameters, and MUST return either true or false.
            -- When taking these rules into account, the game will go through each of these functions and keep a tally of whether or not they return true or false.
            -- If a function returns true, meaning that the rule preventing the object spawning is in effect, the tally will be increased by 1.
            -- If this tally is greater than or equal to customRuleMin (explained below), the object will not spawn.
            -- There are some preset custom rules you can use, defined below.
        ["customRuleMin"] = "number" --The amount of custom rules that must return true in order to prevent an object from spawning.
            -- Example: If customRuleMin is 3, and I have four custom rules, three of those four custom rules must return true to prevent the object from spawning.
            -- Will default to 1, meaning that one custom rule returning true will prevent the object from spawning.

    }
--[[MapObject.SpawnNaturally = function(object, rules)
    objectSpawnRules[object] = {}
    for k, v in pairs(spawnRules) do
        if rules[k] ~= nil then
            if rules[k] == spawnRules.spawnable_ground then
                objectSpawnRules[object][k] = {}
                for _, stage in rules[k] do
                    table.insert(objectSpawnRules[object][k], Object.find(rules[k][_]), "vanilla")
                end
            else
                objectSpawnRules[object][k] = rules[k]
            end
        end
    end
    registercallback("onStageEntry", function()
        if net.host == true then
            --Declare variables--
            debugPrint("Beginning spawn sequence for Map Object "..object:getName()..".", "mapObjectLib_debugSpawn")
            local maxAmount = objectSpawnRules[object].maxAmount
            local minAmount = objectSpawnRules[object].minAmount or 1
            local spawnChance = objectSpawnRules[object].spawnChance
            local spawnableground = objectSpawnRules[object].spawnable_ground
            local bannedStages = objectSpawnRules[object].bannedStages
            local customRules = objectSpawnRules[object].custom_rules
            local minimumRules = objectSpawnRules[object].customRuleMin or 1
            local directorInfluence = objectSpawnRules[object].directorInfluence or 1
            local affectedByDirector = objectSpawnRules[object].affectedByDirector or false
            local minimumSpawnChance = objectSpawnRules[object].minimumSpawnChance or 1
            local tally = 0
            local takenCoordinates = {}
            debugPrint(object:getName()..": Checking for custom rules...", "mapObjectLib_debugSpawn")
            if customRules then
                for _, rule in ipairs(customRules) do
                    if rule() == true then
                        tally = tally + 1
                        debugPrint(object:getName()..": Rule returned true! Adding to tally. (" ..tally.." / "..minimumRules..")", "mapObjectLib_debugSpawn")
                    else
                        debugPrint(object:getName()..": Rule returned false.", "mapObjectLib_debugSpawn")
                    end
                end
            else
                debugPrint(object:getName()..": No custom rules found.", "mapObjectLib_debugSpawn")
            end
            spawnable_ground = {}
            if spawnableground ~= nil then
                for _, collision in ipairs(spawnableground) do
                    for _, v in pairs(collision:findAll()) do
                        table.insert(spawnable_ground, {x = v.x + 8, y = v.y - 6})
                    end
                end
            else
                for _, v in pairs(oB:findAll()) do
                    table.insert(spawnable_ground, {x = v.x + 8, y = v.y - 6})
                end
            end
            -- Spawn Objects
            debugPrint(object:getName()..": Attempting to spawn objects.", "mapObjectLib_debugSpawn")
            if spawnChance > 0 then
                local canSpawnOnStage = true
                debugPrint(object:getName()..": Checking if object can spawn on "..Stage.getCurrentStage().displayName..".", "mapObjectLib_debugSpawn")
                if bannedStages then
                    for stage, _ in ipairs(bannedStages) do
                        if bannedStages[stage] == Stage.getCurrentStage().displayName then
                            debugPrint(object:getName()..": Object cannot spawn on stage "..Stage.getCurrentStage().displayName..". Terminating spawn sequence.", "mapObjectLib_debugSpawn")
                            canSpawnOnStage = false
                        end
                    end
                end
                if canSpawnOnStage then
                    debugPrint(object:getName()..": Starting spawn up to "..(maxAmount-1).." instances.", "mapObjectLib_debugSpawn")
                    for i = 0, (maxAmount - 1) or 1 do
                        local doesSpawn
                        if i < (minAmount - 1) then
                            doesSpawn = 1
                        else
                            doesSpawn = math.random(1, spawnChance)
                            debugPrint(object:getName().." #"..(i+1)..": Rolling for spawn chance. Result: "..doesSpawn, "mapObjectLib_debugSpawn")
                        end
                        if tally >= minimumRules then
                            debugPrint(object:getName()..": Custom rule tally exceeds minimum amount of rules, restricting this object's spawn. Terminating spawn sequence.", "mapObjectLib_debugSpawn")
                            doesSpawn = 2
                        end
                        if doesSpawn <= 1 then
                            debugPrint(object:getName().." #"..(i+1)..": Successfully rolled for spawn chance. Continuing...", "mapObjectLib_debugSpawn")
                            local g
                            local loc
                            local canSpawnAtCoords = true
                            if objectSpawnRules[object].coordinates then
                                debugPrint(object:getName().." #"..(i+1)..": Attempting to spawn Object at specified coordinates.", "mapObjectLib_debugSpawn")
                                loc = table.irandom(objectSpawnRules[object].coordinates) or nil
                                for _, coords in ipairs(takenCoordinates) do
                                    if loc ~= nil and coords == loc then
                                        debugPrint(object:getName().." #"..(i+1)..": Coordinates taken. Looking elsewhere.", "mapObjectLib_debugSpawn")
                                        canSpawnAtCoords = false
                                    end
                                end
                                if loc == nil then
                                    debugPrint(object:getName().." #"..(i+1)..": Coordinates taken. Looking elsewhere.", "mapObjectLib_debugSpawn")
                                    canSpawnAtCoords = false
                                end
                            else
                                debugPrint(object:getName().." #"..(i+1)..": Coordinates taken. Looking elsewhere.", "mapObjectLib_debugSpawn")
                                canSpawnAtCoords = false
                            end
                            debugPrint(object:getName().." #"..(i+1)..": Choosing location...", "mapObjectLib_debugSpawn")
                            if canSpawnAtCoords then
                                table.insert(takenCoordinates, loc)
                                g = oB:findNearest(loc.x, loc.y)
                            else
                                g = table.irandom(spawnable_ground)
                            end
                            local inst = MapObject.create(object, g.x, g.y)
                            if net.online then
                                SyncSpawnedObject:sendAsHost(net.ALL, nil, inst:getObject().id, inst.x, inst.y)
                            end
                            debugPrint(object:getName().." #"..(i+1)..": Spawn sequence complete.", "mapObjectLib_debugSpawn")
                        end
                    end
                end
            else
                error("Value spawnChance for Map Object must be greater or equal to 1.")
            end

        end

    end, 10000)
end

-- These are preset, custom rules you can use.
    -- isSacrificeActive: Returns true if Sacrifice is active. Useful for Chest-like objects.
    -- isCommandActive: Returns true if Command is active. Useful for Chest-like objects.
MapObject.PresetRules = {
    isSacrificeActive = function()
        local sacrifice = Artifact.find("Sacrifice", "vanilla")
        if sacrifice.active then
            return true
        else
            return false
        end
    end,
    isCommandActive = function()
        local sacrifice = Artifact.find("Command", "vanilla")
        if sacrifice.active then
            return true
        else
            return false
        end
    end,
}]]



export("MapObject")
return MapObject
