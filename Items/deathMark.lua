-- Death Mark

local item = Item("Death Mark")
item.pickupText = "Enemies with 4 or more debuffs are marked for death, taking bonus damage."
item.sprite = Sprite.load("Items/resources/deathMark.png", 1, 11, 14)
item:setTier("uncommon")

local enemies = Object.find("enemies")

local debuffs = {
    Buff.find("slow", "vanilla"),
    Buff.find("slow2", "vanilla"),
    Buff.find("thallium", "vanilla"),
    Buff.find("snare", "vanilla"),
    Buff.find("sunder1", "vanilla"),
    Buff.find("sunder2", "vanilla"),
    Buff.find("sunder3", "vanilla"),
    Buff.find("sunder4", "vanilla"),
    Buff.find("sunder5", "vanilla"),
    Buff.find("oil", "vanilla"),
    Buff.find("Grieving", "rts-reborn")
}
callback.register("postLoad", function()
    if modloader.checkMod("Starstorm") then
        table.insert(debuffs, Buff.find("disease", "Starstorm"))
        table.insert(debuffs, Buff.find("intoxication", "Starstorm"))
        table.insert(debuffs, Buff.find("daze", "Starstorm"))
        table.insert(debuffs, Buff.find("voided", "Starstorm"))
        table.insert(debuffs, Buff.find("nbanditPull", "Starstorm"))
        table.insert(debuffs, Buff.find("needles", "Starstorm"))
        table.insert(debuffs, Buff.find("weaken1", "Starstorm"))
        table.insert(debuffs, Buff.find("weaken2", "Starstorm"))
        table.insert(debuffs, Buff.find("noteam", "Starstorm"))
    end
end)

local deathmark = Buff.new("Death Mark")
deathmark.sprite = Sprite.load("Items/resources/deathMarkBuff.png", 1, 9, 6)

callback.register("onHit", function(damager, hit)
    local parent = damager:getParent()
    if isa(parent, "PlayerInstance") and hit:getBuffs(deathmark) ~= true then
        local enemyBuffs = hit:getBuffs()
        if enemyBuffs then
            local debuffCount = 0
            for _, buff in ipairs(enemyBuffs) do
                if contains(debuffs, buff) then
                    debuffCount = debuffCount + 1
                end
            end
            print(debuffCount)
            if debuffCount >= 4 then
                hit:applyBuff(deathmark, 60 * (7 * parent:countItem(item)))
            end
        end
    end
end)

callback.register("preHit", function(damager, hit)
    if hit:hasBuff(deathmark) then
        damager:set("damage", damager:get("damage") * 1.5)
        damager:set("damage_fake", damager:get("damage_fake") * 1.5)
    end
end)

-- Item Log
item:setLog{
    group = "uncommon",
    description = "Enemies with &y&4&!& or more debuffs are &y&marked for death&!&, increasing damage taken by &y&50%&!& from all sources for &b&7&!&&lt&(+ 7 per stack)&!&seconds.",
    story = "Everyone said that I was crazy to search for lost artifacts on Mars. Idiots. There hasn\'t been any proof of a previous civilization - but I\'ve always trusted my gut. This skull proves that I\'m right - that something did exist here before.\n\nThat smug professor at the university... always disparaging my research. I loved seeing the look on his face as I shook his hand. Idiot. Karma must have been working overtime - I heard he fell ill shortly after. I suppose my success was just too much for him.\n\n...In fact, everyone I\'ve shown seems to not be returning my calls. Are they avoiding me? Are they scared this news would shake up their academic communities? Too proud to admit I\'m right?\n\nI\'ll find someone who will give me the recognition I deserve. I\'ve worked too hard and done too much. If I don\'t keep going, I think I might just die.",
    destination = "421 Lane,\nLab [72],\nMars",
    date = "02/22/2056",
    priority = "&g&High Priority&!&"
}

-- Tab Menu
if modloader.checkMod("Starstorm") then
    TabMenu.setItemInfo(item, nil, "Enemies with 4 or more debuffs take 50% more damage for 7 seconds.", "+7 second duration.")
end
