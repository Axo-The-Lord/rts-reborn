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
* Someone talented should totally rewrite this. I know it's a massive undertaking, and it *does* work, but not very well.

**util**
* This is basically where you can dump any functions you may need for development. It only has like 2 things in there right now because I've never needed to use anything else, but if you need some function from a Starstorm library or something, go ahead and add it.

**Core things that haven't been started yet:**
* A teleporter library for handling orbs, portals, hidden realms, etc. Sivelos did make one but it might need some tweaking, I'm not sure.

## MISC

**text**
* Could be changed to be a part of util

**title**
* Resize the titles to properly fit the main menu

## MAPOBJECTS


**lunarBud**
* Fix the smoke effect. This could probably be a particle of its own, perhaps similar to SPEE-D's or F.A.E's.
* Active Text is super displaced for some reason??

**useBarrel**
* This mostly served as a test to see if the mapObjectLib worked. I'm going to leave it here for now in case you need something to test the mapObjectLib, but it will not make it to final release.

**MapObjects that haven't been started yet:**
* Combat Shrine
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
* Make the Newt turn around to see the player when they walk to the other side of him

## ITEMS

**Focus Crystal**
* Is the sound too loud?

**Rose Buckler**
* Does being able to switch directions without removing the effect make it too powerful?

**Death Mark**
* Needs a visual effect, I was thinking something similar to Seraph's shatter effect?

**Brainstalks**
* Still needs the lightning particle effect
* Vignette is not working properly

**Wake of Vultures**
* Fix the current color overlays
* Add more elite abilities such as shooting missiles, healing, etc. How are they triggered?
* Add support for Starstorm elites
* Might have to be postponed to the next update? It's pretty ambitious

**Planula**
* I don't see a point in keeping this item if you can only access it through Command. It's been disabled but the code is still there.

**Beads of Fealty**
* Needs proper item log?
* Maybe disable it until we add obliteration? It was just a test to see if Lunar Items worked or not.

**Transcendence**
* Needs to be rewritten completely.
* Needs proper item log?
* Starstorm Tab Menu

~~**Brittle Crown**~~ \~Affenstark
* ~~Proper item log?~~
* ~~Maybe making actual coins come out of the enemy instead of some damage number, similar to the money bag equipment~~

**Shaped Glass**
* Proper item log?
* It's also broken rn (in a bad way)

**Spinel Tonic**
* Needs to be rewritten completely.
* ~~Proper item log?~~ \~Affenstark
* It needs to use the vignette object

**Effigy of Grief**
* Add 5 maximum?
* Proper item log?

**Jade Elephant**
* Proper item log?

## SURVIVORS

**Artificer**
* Sprites needed: death, decoy, select, shoot1_down, shoot2_charge, shoot2_fire, shoot3, shoot5_1, shoot5_2, shoot5_3, efFireyScepter, skills
* Resprites(?): jump, iceIdle, iceDeath, iceSpawn, nanoBomb
* Proper ENV Suit sound
* Sounds for the ice spikes
* Nano-bomb sounds
* ENV Suit doesn't work correctly with Photon Jetpack
* Ignite stacking needs to be handled better
* Flamethrower needs to be reworked
* Needs Secondary and Utility
* Stitch fire trail to walk
* Rewrite the special as it is currently horrible
* Should the flame bolts be aimed at a 45-degree angle instead of straight down when hovering?
* Should the hitbox of the flame bolt change at all?

## STAGES

**Bazaar Between Time**
* Needs a tileset
* Basically not started at all

## Other

* Icon needs text
* Rainfusion Description needs finalizing
* Remove stupid .DS_Store who uses MacOS anyway amirite
