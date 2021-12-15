-- ============================================================================
-- Helper variable to make the other code a little more readable.
-- ============================================================================
local shirt = Item.find("White Undershirt (M)", "vanilla")

-- ============================================================================
-- This registers a new callback that happens when an item is removed.
-- Its function always has:
--     1. The affected player
--     2. The item being removed
--     3. How many items are being removed
--   as its three arguments.
-- This function is fired every time ANY item is removed, so we need to provide
--   some logic within to make it only affect our specific item.
-- ============================================================================
callback.register("onItemRemoval", function(player, item, amt)

    -- ========================================================================
    -- Here we check to see if our specific item is the one being removed.
    -- In this case we're registering a removal of the 'White Undershirt (M)'
    --   item originating from the base game.
    -- ========================================================================
    if item == shirt then

        -- ====================================================================
        -- Some items will require more advanced logic to be removed properly
        --   but the White Undershirt item is pretty simple, it just gives a
        --   one time boost of 3 armor for the first item we pick up.
        -- Because this item only gives an effect the first time it is picked
        --   up and does not have any kind of stacking effect, all we need to
        --   do is check if the player has exactly 0 of it, and then reduce
        --   their armor by 3.
        -- ====================================================================
        if player:countItem(shirt) == 0 then
            player:set("armor", player:get("armor") - 3)
        end
    end
end)

-- ==== Example of max stacks =================================================
-- Another simple but fairly common removal method just requires the reduction
--   of a single number by a set amount, like Pauls Goat Hoof from the base
--   game for example, which also has a max stack to take into account:
--[[

local hoof = Item.find("Paul's Goat Hoof", "vanilla")
callback.register("onItemRemoval", function(player, item, amt)
    if item == hoof then
        local count = player:countItem(hoof)
        if count < 25 then
            local actualAmount = math.max(math.min(count + amt, 25) - count, 0)
            player:set("pHmax", player:get("pHmax") - (0.15 * actualAmount))
        end
    end
end)

]]--

-- ==== Example of more advanced removal ======================================
-- An example of a more complicated item removal effect would be an
--   item like the Barbed Wire item from the base game, which needs to
--   have its custom object updated to reflect the number of items that
--   the player currently has:
--[[

local thorns = Object.find("EfThorns", "vanilla")
local barbed = Item.find("Barbed Wire", "vanilla")
callback.register("onItemRemoval", function(player, item, amt)
    if item == barbed then
        for _, v in ipairs(thorns:findMatching("parent", player.id)) do
            if player:countItem(barbed) == 0 then
                v:destroy()
            else
                v:set("coeff", v:get("coeff") - 0.2 * amt)
            end
        end
    end
end)

]]--
