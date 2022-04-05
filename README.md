# DayZ Legacy Custom Addons 

<p align="center">
  <a href="https://www.codacy.com/gh/doctashay/DayZ-Missions/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=doctashay/DayZ-Missions&amp;utm_campaign=Badge_Grade" rel="nofollow"><img src="https://app.codacy.com/project/badge/Grade/5bdca7ad1b064f35a1462325a1d9442b" alt="Codacy Badge" style="max-width:100%;"></a>
  <a href="https://discord.gg/TF7CXGMFqg"><img src="https://img.shields.io/discord/756287461377703987" alt="Discord"></a>
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt=PRs Welcome></a>
</p>

## Repository Description
This repository contains the custom server and client script modules that support DayZ Legacy, particularly regarding the new content that we port from later versions of the game, and custom modules that we add on top of the game, such as base building, or AI missions. 

In DayZ Standalone, there are two script modules stored in the `addons` folder, `server_data.pbo` and `modules_DayZ.pbo`. These modules carry the prefix `\dz\server_data\` and `\dz\modulesDayZ\` respectively. 

**Anything that should be executed on the client should be contained within `modulesDayZ`, while scripts meant for the server should be executed either in `server_data` or the server mission, depending on the complexity.** 

`server_data` contains script data such as the following:
- Character creation scripts
- Character save scripts
- Timer-based events
- Damage calculation
- Weapon and item interaction management
- Loot economy 
- Loot spawning
- Zombie spawning
- Animal spawning
- Event spawning
- Other server-sided modules (events that should take place for all players) 

`modulesDayZ` seems to contain more client-oriented script data such as:
- Character status management (this includes hunger and sicknesses, heat comfort, health, blood, etc.)
- Restraint processing (handcuffs and struggling)
- Character animation
- Local light processing
- Character messaging 
- Local damage processing (bleed effects, etc)
- Cooking, gas canister, fireplace logic
- Melee processing
- Explosion processing (ammo in fireplace, spraycans, etc)
- Some UI scripts

My general approach to modifying this scripted data was to create a duplicate of these two addons, put them in their own `@DayZLegacy` mod, and redirect the server to use my hybrid addons whenever the mod is specified in the launch parameters. In this way, you can effectively have two versions of the game, one that is entirely vanilla and unmodified, and one which contains the many fixes that I've implemented into these hybrid addons. 
