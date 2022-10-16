# RTS REBORN

Hello! This is the official GitHub repository for **RTS Reborn**: A continuation of Sivelos's **Risk of Rain 2: Return to Sender** mod for Risk of Rain ModLoader.

You can download the development version of the mod here, but more importantly, this is where you can contribute to the mod!

If you push even the smallest changes to this repository, you'll get your name in the credits of the mod, the contributor role on the Discord (https://discord.gg/aruVgb6NNP), and a special particle effect in multiplayer lobbies.

This Readme is going to act a lot like a To-Do list for those of you who are interested in contributing, to see how close we are to finishing the next update.

## CORE

**abilityCharge**
* Change the cooldown from 0 to 0.5 seconds to avoid casting all charges in one click
* Change color of charges to a dimmer color rather than the opposite (I'm not sure how RGB works though)
* Add the ability to override for characters such as HAN-D or Executioner

**lunar**
* Properly change UI when Starstorm is enabled

**mapObjectLib**
* Someone talented should rewrite this?? I know it's a massive undertaking, and it *does* work, but not very well.

**util**
* This is basically where you can dump any functions you may need for development. It only has like 2 things in there right now because I've never needed to use anything else, but if you need some function from a Starstorm library or something, go ahead and add it.

**Core things that haven't been started yet:**
* A teleporter library for handling orbs, portals, hidden realms, etc. Sivelos did make one but it might need some tweaking, I'm not sure.

## MISC

**text**
* Could be changed to be a part of util

**title**
* Could use a lot of tweaking, sprite- and placement-wise

## MAPOBJECTS

**lunarBud**
* Fix the smoke effect. This could probably be a particle of its own, perhaps similar to SPEE-D's or F.A.E's.
* Active Text is super displaced for some reason??

**useBarrel**
* This mostly served as a test to see if the mapObjectLib worked. I'm going to leave it here for now in case you need something to test the mapObjectLib, but it will not make it to final release.

**MapObjects that haven't been started yet:**
* Lunar Cauldron
* Shop Buds
* Newt Altars
* Lunar Shop Refresher (no sprites yet)
* Lunar Seer (no sprites yet)

## ACTORS

**Newt**
* Resprite needs to be finished. That includes Idle, Banish, Death, and Spawn animations.
* Make the Newt "spawn" once you are within a certain radius of him
* Make the Newt close off the Bazaar for the rest of the run if he banishes you
* Make all Lunar mapObjects free (minus cauldrons) if you kill him

## ITEMS

**Death Mark**
* Needs a visual effect, I was thinking something similar to Seraph's shatter effect?
* Effectiveness / balancing should be discussed.

**Brittle Crown**
* Give the coin objects some kind of momentum?

**Spinel Tonic**
* Stat changes need to be rewritten completely.

## SURVIVORS

**Artificer**
* A lot of stuff, I'll figure out exactly what we need as we go.
* Could use a polish pass

## STAGES

**Bazaar Between Time**
* Needs a tileset
* Basically not started at all
