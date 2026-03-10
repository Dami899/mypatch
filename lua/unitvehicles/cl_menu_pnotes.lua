UV = UV or {}

-- ["VERSIONNUMBER"] = {
-- Date = "RELEASEDATE",
-- Text = [[

-- ]],
-- },

UV.PNotes = {
["v1.3.0"] = {
Date = { year = 2026, month = 3, day = 13 },
Text = [[
**New Features**
- Racing: Added a *Racer Difficulty* setting
      |-- Set it to "Easy", "Medium" or "Hard"
      |-- The higher difficulties grant the AI Racers increased traction and cornering speeds
- Racing: Added a *Catch-up* setting
      |-- When enabled, AI Racers will get increased speed and traction when far behind
- Pursuits: Added a *Unit Difficulty* and *Catch-up* setting, identical to those above, but for AI Units
- AI Racers will now reset when driving via Path Nodes and they've missed a checkpoint
- Added themed "Wrong Way!" notifications on almost all HUD Types
- Added a new tool: [string:tool.uvrepairshop.name]
      |-- Spawn Repair Shops with the tool
      |-- Save them as .json presets for each map
      |-- Allow Repair Shops to spawn on their own automatically
- Added support for themed Speedometers, tied to the chosen Main UI
      |-- Can be customized via a new *<color=255,255,0>Customize HUD</color>* button
      |-- Only works in <color=255,255,0>Glide</color> vehicles
- Added tips that are displayed on the end-of-pursuit results screens on all HUD types

**Changes**
- Pursuits: Multiple suspects can now initiate the "Hiding" phase during cooldown if all suspects have their engine turned off
- AI Racers: When resetting while driving via Path Nodes, the AI racers will now assign themselves the closest small node rather than large node
- AI Racers: Improved navigation via DV waypoints when freeroaming
- AI Racers: When freeroaming via DV waypoints, if an AI racer gets stuck for a sufficient amount of time, it will reset its navigation target
- "Unlimited Durability" now gets applied whenever you enter a vehicle, not when a pursuit begins
- When "Racer Pursuit Tech" is enabled, all players will receive random Pursuit Tech whenever they enter a vehicle
      |-- Only happens if the vehicle does not have Pursuit Tech already
- Resetting mid-pursuit also resets a Unit nearby to wherever you reset to
- Moved some settings to new locations
      |-- Call Response (AI Settings → Pursuit Settings)
      |-- Speed Limit (AI Settings → Pursuit Settings)
      |-- Radio Chatter (AI Settings → Pursuit Settings)
- The Air Unit can now be taken out when it is in the process of disengaging from the pursuit
- Updated the *Original* HUD Type to be more old-school and replicate how it was during UV's alpha stages

**Fixes**
- Fixed some keybinds not having glyphs
- Fixed that Pursuit Tech sometimes did not apply damage correctly

And many more smaller undocumented fixes.
]],
},

["v1.2.0"] = {
Date = { year = 2026, month = 2, day = 24 },
Text = [[
**New Features**
- Racing: Added support for *AI Path Nodes*
      |-- When included, AI Racers will follow these paths instead of checkpoints
      |-- Path Nodes support multi-path racing, where the AI will now randomly pick a route
      |-- *Curve Strength* allows the user to apply a gradual turn for longer paths
- Added two new Pursuit Techs:
      |-- [string:uv.ptech.ghost] (Racers) - Become non-collidable with props and other vehicles for a short time
      |-- [string:uv.ptech.grappler] (Units) - Grab a fleeing vehicle's wheels and hold them in place
- Added support for themed Police Scanners
      |-- Only *Most Wanted* has its themed scanner for the time being
      |-- Also added the option to have the vehicle's forward axis be used for the scanner rather than the camera 
- Added the ability to limit how many Units can be part of the pursuit
      |-- Applied in [string:uv.hm]
- Added a warning for when you try to spawn any AI without having Decent Vehicle waypoints loaded

**Changes**
- Temporarily disabled subtitles due to mismatching subtitles compared to existing, replaced and added default voice lines
- Improved Unit AI pathing
- Removed the legacy text-based police chatter
- Updated the description for tracks when importing them to signal if they have Path Nodes and/or Props
- Updated default Cop1 vehicle identification lines
- Music Volume now affects currently playing UVTrax and Pursuit Themes

**Fixes**
- Fixed that UVTrax provided the raw folder name in the notification rather than the metadata folder name
      |-- This only applies to UVTrax profiles that utilize JSON files for song titles, authors and folder names
- Fixed that Pursuit Breakers, when wrecking Units, caused a Pursuit to engage, even if there was no racers to pursue
- Fixed that the *Name Tags* variable was a server variable when it should've been a client variable
]],
},

["v1.1.0"] = {
Date = { year = 2026, month = 2, day = 3 },
Text = [[
**New Features**
- UV Menu: Added a new First-Time Setup menu
      |-- Will automatically display for all users, forcing them to go through necessary settings
      |-- Existing users from v1.0.0 can choose to skip the Preset selection
- Added a Police Scanner SFX toggle

**Changes**
- UV Menu: [string:uv.menu.welcome] now has [string:uv.pm.pursuit.start] and [string:uv.pm.pursuit.start] options.
- Creator: Races tool: Tweaked its functionality slightly:
      |-- [+reload] now cycles modes between Checkpoint and Grid Slots
      |-- [+attack] now creates Checkpoints or Grid Slots, depending on whichever is selected
      |-- Updated HUD tooltips to reflect these changes
      |-- If the speed limit is set to 0, editing a checkpoint's ID no longer alters its speed limit value
- Race Invites can now be sent and accepted/declined while a pursuit is active
- Units will no longer spam-use bullhorn voice lines

**Fixes**
- Fixed that the Race Host status could be "stolen" from an Admin by a Super Admin
- Fixed that the Totaled UI did not close when joining a pursuit while "Spawn as Random Unit" was enabled
- Fixed that the "Spike Strip Deployed" cop chatter had a tendency to spam
- Fixed that Voice Profiles could cause a server connection loop if too many are selected
]],
},

["v1.0.1"] = {
Date = { year = 2026, month = 1, day = 30 },
Text = [[
This patch brings fixes for bugs reported by the community as well as other improvements/tweaks to the addon.
Keep 'em coming! We appreciate your reports and feedback!

**Fixes**
- Fixed that the "Creator: Units" tool did not allow you to assign Units to a Heat Level due to outdated convars.
- Fixed that the "Creator: AI Racers" tool caused an error when trying to select a vehicle from the vehicle database.
- Fixed Unit AI getting stuck idling after pursuits get concluded.
- Slightly altered chatter behavior for more consistency.
]],
},

["v1.0.0"] = {
Date = { year = 2026, month = 1, day = 29 },
Text = [[
This lists changes that were made after v.0.42.0 and have been applied to v1.0:

**New Features**
- UV Menu: Added button prompts at the bottom of the menu to display which button does what on the highlighted setting; Can be toggled on/off in the UI Settings
- UV Menu: Added the ability for addon creators to have settings added into the UV Menu
- Several UVTrax additions:
      |-- Added a song manager where you can choose which songs play and which don't
      |-- Added the ability to shuffle the UVTrax playlist, or play them in alphabetical order
      |-- Added the ability to go to the previously played track
      |-- Added button prompts on the UVTrax pop-up
- Added new Glyphs that replace "[ SPC ]" and various other keybind notifications across the addon
- UV Menu: Added a "Glyph Override" function, allowing you to define not only your own keyboard and mouse glyphs (cosmetically, of course), but also assign Xbox, PlayStation and Switch glyphs
- Added a "Default" preset for the Heat Level Manager
- Added new elements to the Original HUD style
- Added a "You finished {place}!" notification for whenever you finish a race on most HUD types
- Added the option to disable Pursuit SFX
- UV Menu: Added a new FAQ/Racing entry for racing with AI

**Changes**
- UV Menu: "VCMod ELS" and "Circular Functions" sections in the Settings Addon tab now show/hide themselves if depending on if they are installed or not
      |-- Additionally, third-party addons can now use a custom function to integrate their settings into the UV Menu
- Race participants are now teleported in 12-participant batches
      |-- This now allows races with more than 24 racers
- Lowered the size on the "Respawning as" and "Race ends in" notifications
- "Spawn X AI" and "Fill Grid with AI" pre-race buttons no longer appear if AI cannot spawn in any vehicles
      |-- Either when "Vehicle Override" is enabled but no vehicles are selected, or if it's disabled but no presets exist
- The Race host will now be added as a proper participant rather than a hidden one
- The Race host's car will dynamically change if they enter/exit a vehicle
- Race participants will get auto-removed from the participants list if they decline their invite, or if their vehicle is destroyed before the race starts
- Pre-race player list now uses the same appearance as the Race Info player list

**Fixes**
- Fixed that Glide vehicle categories were not sorted correctly in the Vehicle Override lists
- Fixed that the "READY" banner on the NFS World HUD type remained on-screen if you swapped HUD types after it appeared and when the race countdown started, but before the race began
- Fixed that when you start a one-checkpoint race, the "Nr. of Laps" variable was always set to 1
- Fixed that Units sometimes used the *Shock Ram* Pursuit Tech when busting racers
- Fixed an error that caused Simfphys and default HL2 Jeep vehicles to create Lua errors when the AI turned their headlights on
- Fixed an error that caused Dispatch to not recognize "default" vehicle colors
      |-- Fixes that the NFS World and NFS Undercover Glide packs' police cars always played "no make and model" voicelines
- Fixed that localizations, on the Workshop addon, mysteriously had an extra blank space after them, causing them to shift very slightly to the left
]],
},

["v0.42.0"] = {
Date = { year = 2026, month = 1, day = 16 },
Text = [[
**Almost there!**
Unit Vehicles is getting closer and closer to its v1.0 release on *January 29th*!
Mark your calendars, it's almost time to **Race, Chase or Escape**!

**New Features**
- Added the *UVPD Rhino Truck*
- Added the *Heat Level Manager* to the *Pursuit Manager* UV Menu Tab
      |-- This replaces the *Manager: Units* settings.
- Added a Race Countdown to the NFS: ProStreet HUD
- Added a new, updated list appearance to the AI Racers, Pursuit Breaker, Roadblocks, Traffic & Units tools
      |-- AI Racers, Traffic and Units also have new base sorting to only list vehicles from a particular base
- Added Vehicle Override for the Traffic Manager, working identically to the AI Racer one

**Changes**
- UV Menu: All convars in the menu now control their correct server convars
      |-- This means that the "Apply Settings" buttons will be removed across the board
- Moved the "Creator: Pursuit Breaker" and "Creator: Roadblocks" settings to the UV Menu
- Renamed the "Manager: Units" tool to "Creator: Units"
- Removed all settings from all Creator tools
- Removed "Relentless" AI option and replaced it with a dynamic behaviour system
      |-- Patrol and Support Units are never relentless
      |-- Pursuit, Interceptor and Air Units have a random chance to become relentless
      |-- Special, Commander and Rhino Units are always relentless
- Improved AI Unit pursuit tactics
- Removed some default cop chatter and updated others
- Air Unit's wreck callout will now have priority over all others

**Fixes**
- Fixed that Repair Shops repaired less health than it should've when Infinite Durability is enabled
- Fixed that "Evade" and "Busted" meters could fill up at the same time on rare instances
]],
},

["v0.41.0"] = {
Date = { year = 2026, month = 1, day = 5 },
Text = [[
**New Features**
- Added the *UVPD Chevrolet Colorado ZR2 2017 Police Cruiser*
- Added a new *Update History* section in the UV Menu - accessed via the *Welcome Page*

**Changes**
- Special and Commander Units' Pursuit Tech now has x2 power (excluding Spike Strips)
- "Enable Headlights" AI Settings option now allows an "Automatic" setting, where AI enable their headlights in dark areas
- When exporting races, you can now choose if you want to export DV Waypoints or not
- Vehicles and hand-spawned entities will no longer be removed when loading a race with props
- Updated translations

**Fixes**
- Fixed that the "Glide" category within the AI Racer Manager's "Vehicle Override" was duplicated, and caused errors if too many Glide vehicles were installed
- Fixed that Keybinds never displayed their "Press any button" prompt
- Fixed that Commander Unit's health reset when "Optimize Respawn" was enabled, and the Commander Unit was moved
- Fixed that Settings were never transmitted to the server when running in a Multiplayer instance
]],
},

["v0.40.0"] = {
Date = { year = 2025, month = 12, day = 31 },
Text = [[
**The final stretch!**
We're now preparing Unit Vehicles for its v1.0 release. There's lots to do still, and we hope to keep receiving feedback until then.

**New Features**
- Added the *UVPD Chevrolet Corvette Grand Sport (C7) Police Cruiser*
- Added the ability to reset in freeroam and in pursuits
- AI Racers and Units will no longer rotate while mid-air
       |-- Only applies to Glide vehicles
- The UV Menu and all fonts will now scale properly on all resolutions
- Added the ability for the community to create custom HUDs
      |-- These are automatically added to the UV Menu Settings
- Added Polish translations
  
**UV Menu**
- Added new *AI Racer Manager*, *Traffic Manager* and *Credits* tabs
       |-- Moved all of the "Manager: AI Racers" and "Manager: Traffic" settings to these tabs
- Added new *Keybinds* tab inside the Settings instance
- Added a *Timer* variable in the UV Menu, applied to the *Totaled* and *Race Invite* menus
- Added a custom dropdown menu in the UV Menu, used by the *UVTrax Profile* and *HUD Types*
- Texts on all options will now scale and split properly
- Rewrote the entire *FAQ* section

**Changes**
- Pursuit Breakers will now always trigger a call response
- The *Vehicle Override* feature from the "Manager: AI Racers" tool (now present in the UV Menu) now supports infinite amount of racers
- The Air Unit will now create dust effects depending on what surface it hovers over
- Relentless AI Units will no longer know player hiding spots
- UV Menu: The *FAQ* tab now sends you to a separate menu instance with categorized information
- UV Menu: The *Addons* tab was moved to UV Settings
- UV Menu: The *Freeze Cam* option no longer appears in the UV Menu while in a Multiplayer session
- Updated various default Cop Chatter lines
- Updated localizations

**Fixes**
- Fixed that AI Racers sometimes steered weirdly after entering another lap
- Fixed that the Air Unit's spotlight wasn't always active
- Fixed that Units still respawned when the Backup timer was active
- Fixed that roadblocks sometimes spawned when a call response was triggered
- Fixed that the EMP Pursuit Tech did not have a localized string on the HUD
- Fixed that the Busted debrief did not always trigger if multiple racers were busted in a short time
- Fixed that the Race Options caused errors in Multiplayer
- Fixed that the Race Invite caused an error when clicking outside of its window, causing it to close prematurely
- Fixed that invalid Subtitles sent the Pursuit Tech notification upwards
- Fixed that clicking on a dropdown option outside the UV Menu, the menu would close if it was set to "Close on Unfocus"
- Fixed a lag spike when pursuit music plays for the first time
- Fixed that Pursuit Breakers sometimes did not wreck Units
]],
},

["v0.39.1"] = {
Date = { year = 2025, month = 12, day = 17 },
Text = [[
# New Features
- **UV Menu**: Added **Carbon** Menu SFX
- **Race Manager**: Added new race options:
> - Start a pursuit X seconds after a race begins
> - Stop the pursuit after the race finishes
> - Clear all AI racers and/or Units when the race finishes
> - Visually hide the checkpoint boxes when racing

- **Race Invites** now use the new menu system
- **Unit Totaled**: Slightly tweaked appearance

**Chatter**
- Added more lines for Cop6

And various other undocumented tweaks
]],
},

["v0.39.0"] = {
Date = { year = 2025, month = 12, day = 11 },
Text = [[
# New Features
**UV Menu**
Say hello to the newly introduced UV Menu, the full replacement for the Spawn Menu options and more. Accessed via the Context Menu or **unitvehicles_menu** command:

- **Welcome Page** - Includes some quick access buttons and variables, and a handy **What's New** section, where we will post update notes
- **Race Manager** - Moved the Race Manager tool race control variables here
- **Pursuit Manager** - Moved all Pursuit Manager buttons here
- **Addons** - The one place for both included and third-party UV addons. Moved **Circular Functions** variables here
- **FAQ** - Need some quick help? The Discord FAQ has been uploaded here!
- **Settings** - Want to tweak something? All Client and Server settings are present here

Additionally, both the **Unit Totaled** and **Unit Select** now use the same menu system.

Don't like the colours? Then change it! Change the colour of buttons, the background and more in the **User Interface** settings tab!

**Things to note**
- Many options are server only, meaning they will not be displayed to clients.
- The options present in the menu can still be accessed via their original methods (Spawn Menu > Options > Unit Vehicles) for roughly 3 update cycles of UV before they will be removed.
- The menu isn't perfect - it will be refined over time.

# Changes
**Tools**
- Race Manager - Renamed to **Creator: Races**

**UI**
- MW HUD: Fixed that the "Split Time" notification did not fade out properly
- Carbon HUD: Fixed that the notifications did not fade out properly

**AI**
- Fixed that the AI did not always respect Nitrous settings (Circular Functions)

**Pursuit**
- Fixed roadblocks not always spawning properly, and sometimes didn't spawn with any Units
- Fixed that regular Units sometimes appeared in Rhino-only roadblocks
- Air Support now gets removed when despawning AI Units

And various other undocumented tweaks
]],
},

}