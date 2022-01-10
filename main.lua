-- RTS REBORN!

-- CORE --

local Libraries = {
	"abilityCharge",
	"lunar",
	"mapObjectLib", -- This version of MapObjectLib is really old and I don't want to use it but for some reason everything breaks when I try to use the newest version aaaaaaaaaaaa
	"util"
}
for _, core in ipairs(Libraries) do
	local c = require("Core."..core)
end

-- MISCELLANEOUS --

local Miscellaneous = {
	"text",
	"vignette",
	"title",
	"contributors"
}
for _, misc in ipairs(Miscellaneous) do
	local m = require("Misc."..misc)
end

-- MAPOBJECTS --

local MapObjects = {
	"categoryChest",
	"lunarBud",
	"useBarrel"
}
for _, mapobject in ipairs(MapObjects) do
	local mo = require("MapObjects."..mapobject)
end

-- ACTORS --

require("Actors.newt")

-- ITEMS --

local Items = {
	-- Common
	"aprounds",
	"backupMag",
	"crystal",
	-- Uncommon
	"warhorn",
	"pauldron",
	"roseBuckler",
	"deathMark",
	-- Rare
	"brainstalks",
	"wakeOfVultures",
	"afterburner",
	-- Boss
	-- "planula",
	-- Lunar
	"beads",
	"transcendence",
	"brittleCrown",
	"shapedGlass",
	"spinelTonic",
	"effigy",
	-- Use
	"elephant",
	"hud",
	"goragsOpus"
}
for _, item in ipairs(Items) do
	local i = require("Items."..item)
end

-- SURVIVORS --

require("survivors/artificer")
