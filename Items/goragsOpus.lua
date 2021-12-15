-- Gorag's Opus

local item = Item("Gorag\'s Opus")
item.pickupText = "You and all your allies enter a frenzy."
item.sprite = Sprite.load("Items/resources/goragsOpus.png", 2, 15, 17)
item.isUseItem = true
item.useCooldown = 45
item:setTier("use")

local teamFrenzy = Buff.find("War Cry", "rts-reborn")
local sound = Sound.find("frenzySound", "rts-reborn")

-- Use
item:addCallback("use", function(actor, embryo)
  local actors = ParentObject.find("actors", "vanilla")
  for _, ally in ipairs(actors:findMatching("team", "player")) do
    sound:play(0.9 + math.random() * 0.4, 0.7)
    if embryo then
      ally:applyBuff(teamFrenzy, 10.5 * 60)
    else
      ally:applyBuff(teamFrenzy, 7 * 60)
    end
  end
end)

-- Item Log
item:setLog{
  group = "use",
	description = "All allies enter a &y&frenzy&!& for &b&7&!& seconds. Increases &b&movement speed&!& by &b&50%&!& and &y&attack speed&!& by &y&100%&!&.",
	story = "Audio transcription complete from \"Carrion Crows Tour 2055: Special Edition\"\n\n\"Halfway through the tour we were at this little shop down in Groveside and the guy at the desk is trying to sell us random junk.\"\n\n\"Yeah, he was totally out of the loop, had no idea who we were.\"\n\n\"Yep, anyways, as a joke, I\'m thinking I\'ll buy this ancient looking drum and use it on stage at the next show. Then we\'d circle back and show this guy a video of his merch being used in the biggest performance on the planet.\"\n\n\"We tried to find him again, but the shop was all shut down. Couldn\'t figure out what happened to him.\"\n\n\"Thing is, that drum drove our fans wild. It turned out to be our most successful tour ever.\"",
	destination = "Some Place", -- Add destination!
	date = "Some Date", -- Add date!
	priority = "&o&Volatile&!&"
}
