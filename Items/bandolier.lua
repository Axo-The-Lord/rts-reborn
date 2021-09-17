-- Bandolier

local item = Item("Bandolier")
item.pickupText = "Chance on kill to drop an ammo pack that resets all skill cooldowns."
item.sprite = Sprite.load("Items/resources/bandolier.png", 1, 11, 12)
item:setTier("uncommon")

local ammoPack = Object.new("Ammo Pack")
ammoPack.sprite = Sprite.load("Items/resources/ammo.png", 1, 3, 3)
ammoPack.depth = 4

ammoPack:addCallback("create", function(self)
  self:set("vy", 0)
  self:set("ay", 0.1)
  self:set("life", 5 * 60)
  self:set("free", 1)
end)

ammoPack:addCallback("step", function(self)
  if self:get("life") > 0 then
    --"Physics"
    self.y = self.y + self:get("vy")
    self:set("vy", self:get("vy") + self:get("ay"))
    if self:collidesMap(self.x,self.y + self:get("vy")) then
      self:set("vy", 0)
      self:set("ay", 0)
    end
    self:set("life", self:get("life") - 1)
    --Pickup
    local actors = Object.find("actors"):findAll()
    for _, actor in ipairs(actors) do
      if self:collidesWith(actor, self.x, self.y) and isa(actor, "PlayerInstance") then
        for i = 2, 5 do
          actor:setAlarm(i,0)
        end
        self:destroy()
      end
    end
  else
    self:destroy()
  end
end)

callback.register("onNPCDeathProc", function(npc, player)
  local stack = player:countItem(item)
  if stack > 0 then
    if math.chance((1 - 1 / (1 + stack) ^ 0.33) * 100) then
      ammoPack:create(npc.x,npc.y)
    end
  end
end)

-- ammo pack should have a "free" variable which dictates whether or not it is in the air, once collision check is true, set "free" to false to prevent future collision checks
-- "physics" update and collision detection only occur if the ammo pack is free

-- checking if a player is nearby can be carried out in a way where the game first checks if dy <= r

-- Item Log
item:setLog{
	group = "uncommon",
	description = "&b&18%&!&&lt&(+10% per stack)&!&chance on kill to drop an ammo pack that &b&resets all cooldowns&!&.",
	story = "Thank you for your participation in the auction! We\'ve included a short history on the item, as well as documents to verify its authenticity.\n\nThis is the famous bandolier worn by B. Grundy himself. He and his pals used to raise terror all over the map of the new territories. Their favorite activity was to tie up people they didn\'t like and drag them behind their horses – Grundy clearly had a sweet spot for the old days.\n\nThe sling carries an impressive assortment of ammunition - Grundy himself carried many different guns. It was rumored that they held out for 3 whole days and nights before their weapons ran dry.",
	destination = "3950 Sunsell Ln,\nTri-City,\nEarth",
	date = "04/19/2056",
	priority = "&g&Standard&!&"
}
