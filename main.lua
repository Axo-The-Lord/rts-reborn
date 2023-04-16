-- RTS REBORN!

-- CORE --

local Libraries = {
  "util",
  "abilityCharge",
  "lunar",
  "barrier",
  "mapObjectLib", -- This version of MapObjectLib is really old and I don't want to use it but for some reason everything breaks when I try to use the newest version aaaaaaaaaaaa
  "monsterLib",
  "portal"
}
for _, core in ipairs(Libraries) do
  require("Core."..core)
end

-- MISCELLANEOUS --

local Miscellaneous = {
  "text",
  "vignette",
  "title",
  "contributors"
}
for _, misc in ipairs(Miscellaneous) do
  require("Misc."..misc)
end

-- MAPOBJECTS --

local MapObjects = {
  "categoryChest",
  "lunarBud",
  "combatShrine"
  -- "useBarrel" disabled
}
for _, mapobject in ipairs(MapObjects) do
  require("MapObjects."..mapobject)
end

-- ACTORS --

local Actors = {
  "newt",
  "beetle",
  "beetleGuard",
  "bell",
  "roboball"
}
for _, actor in ipairs(Actors) do
	require("Actors."..actor.."."..actor)
end

-- ITEMS --

local Items = {
  -- Common
  "aprounds",
  "backupMag",
  "crystal",
  -- "steak", disabled (bitter root exists)
  -- "armorPlate", disabled (tough times exists)
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
  -- "planula", no Grandparents yet :(
  -- Lunar
  "beads",
  "transcendence",
  "brittleCrown",
  "shapedGlass",
  "spinelTonic",
  "effigy",
  "meteor",
  "gesture",
  -- Use
  "elephant",
  "hud",
  "goragsOpus"
}
for _, item in ipairs(Items) do
  require("Items."..item)
end

-- SURVIVORS --

require("survivors/artificer")
