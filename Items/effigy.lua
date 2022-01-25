-- Effigy of Grief

local item = Item("Effigy of Grief")
item.pickupText = "Drop an effigy that cripples ALL characters inside."
item.sprite = Sprite.load("Items/resources/effigy.png", 2, 10, 17)
Lunar.addItem(item)
item.color = LunarColor
item.isUseItem = true
item.useCooldown = 15

ItemPool.find("enigma", "vanilla"):add(item)

-- Buff
local buff = Buff.new("Grieving") --"Cripple"?
buff.sprite = Sprite.load("Items/resources/effigyDebuff", 1, 5, 7)

buff:addCallback("start", function(actor)
	local acc = actor:getAccessor()
	acc.armor = acc.armor - 20
	acc.pHmax = acc.pHmax - 0.5
end)
buff:addCallback("end", function(actor)
	local acc = actor:getAccessor()
	acc.armor = acc.armor + 20
	acc.pHmax = acc.pHmax + 0.5
end)

-- Object
local effigyObject = Object.new("Placed Effigy")
local sound = Sound.find("WormExplosion", "vanilla")
effigyObject.sprite = Sprite.load("Items/resources/effigyObject.png", 5, 9, 26)
local actors = ParentObject.find("actors", "vanilla")
local mask = Sprite.load("Items/resources/effigyMask.png", 1, 6, 13)

effigyObject:addCallback("create", function(self)
	local data = self:getData()
	self.mask = mask
	self:set("radius", 100)
	self.spriteSpeed = 0.2
	misc.shakeScreen(5)
	sound:play()
	self.y = FindGround(self.x, self.y)
end)
effigyObject:addCallback("step", function(self)
	local data = self:getData()
	if math.floor(self.subimage) >= self.sprite.frames then
		self.spriteSpeed = 0
	end
	for _, inst in ipairs(actors:findAllEllipse(self.x - self:get("radius"), self.y - self:get("radius"), self.x + self:get("radius"), self.y + self:get("radius"))) do
		inst:applyBuff(buff, 0.5 * 60)
	end
end)
effigyObject:addCallback("draw", function(self)
	local data = self:getData()
	graphics.color(Color.fromHex(0x6279ff))
	graphics.alpha(0.75)
	graphics.circle(self.x, self.y, self:get("radius"), true)
	graphics.alpha(0.05)
	graphics.circle(self.x, self.y, self:get("radius"), false)
end)

-- Item
item:addCallback("use", function(player, embryo)
	local pDat = player:getData()
	if #pDat.effigy_list == 5 or false then
		pDat.effigy_list[1]:destroy()
		table.remove(pDat.effigy_list, 1)
	end
	local newEffigy = effigyObject:create(player.x, player.y)
	pDat.effigy_list[#pDat.effigy_list+1] = newEffigy
	if embryo then
		newEffigy:set("radius", 100 * 1.25)
	else
		newEffigy:set("radius", 100)
	end
end)

item:setLog{
	group = "end",
	description = "ALL characters within are &b&slowed by 50%&!& and have their &y&armor reduced to 20.&!&",
	story = "\"This relic tells a story... But it is not a fairy tale. It\'s a tragedy. A story of betrayal, regret, and sorrow. A story of two.\"\n\n\"Uh… okay…? How the hell do you know that?\"",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = colorString("Unaccounted For", LunarColor)
}

callback.register("onPlayerInit", function(p)
	p:getData().effigy_list = {}
end)
