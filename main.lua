-- RTS REBORN --

-- CORE --

require("Core.abilityCharge")
require("Misc.damage")
require("Core.lunar")
require("Core.mapObjectLib")
require("Misc.vignette")

-- MAPOBJECTS --

require("MapObjects.useBarrel")
require("MapObjects.categoryChest")
require("MapObjects.lunarBud")

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
  -- "fuelCell",
  "bandolier",
  "deathMark",

  -- Rare
  "brainstalks",
  "wakeOfVultures",
  "afterburner",

  -- Boss
  "planula",

  -- Lunar
  "beads",
  -- "transcendence",
  "brittleCrown",
  "shapedGlass",
  -- "spinelTonic", Not ready yet

  -- Use
  "elephant",
  "hud",
  "goragsOpus"
}
for _, item in ipairs(Items) do
  local i = require("Items."..item)
end
