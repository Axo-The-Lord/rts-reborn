-- RTS REBORN!

-- CORE --

local Libraries = {
  "util",
  "abilityCharge",
  "lunar",
  "barrier",
  "mapObjectLib" -- This version of MapObjectLib is really old and I don't want to use it but for some reason everything breaks when I try to use the newest version aaaaaaaaaaaa

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
  "combatShrine"
  -- "useBarrel" disabled
}
for _, mapobject in ipairs(MapObjects) do
  local mo = require("MapObjects."..mapobject)
end

-- ACTORS --

require("Actors.newt")
-- require("Actors.beetle.beetle") disabled

-- ITEMS --

local Items = {
  -- Common
  "aprounds",
  "backupMag",
  "crystal",
  -- "steak", disabled
  -- "raplate", disabled
  -- Uncommon
  "warhorn",
  "pauldron",
  "roseBuckler",
  "deathMark",
  -- Rare
  "brainstalks",
  --"wakeOfVultures", too ambitious for now, maybe
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
