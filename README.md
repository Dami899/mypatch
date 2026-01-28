# /// RACE /// CHASE /// ESCAPE ///

***Unit Vehicles*** is a Sandbox-oriented addon that allows players, in both Multiplayer with others or Singleplayer with AI, to engage in high-speed pursuits as or against police and thrilling races on any map.

"I want every single unit, after the guy." ~ Sergeant Cross

## Requirements
You'll need two addons for Unit Vehicles to work flawlessly:

- [Decent Vehicles - Basic AI](https://steamcommunity.com/workshop/filedetails/?id=1587455087) - Required for AI pathfinding.
- [Glide // Styled's Vehicle Base](https://steamcommunity.com/workshop/filedetails/?id=3389728250) - Used by default UVPD vehicles, and highly recommended for the addon.

**Highly recommended**
- [Unit Vehicles Starter Data Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=3515525556) - Contains lots of data content provided by the UV development team and the community. Contains AI Racer Names, Pursuit Breakers, Races, Roadblocks, the **Rockport PD** Preset and various Decent Vehicle waypoints for plenty of maps.

## Features
***/// Racing ///***
- Participate in Sprint or Circuit racing against your friends or AI!
- Fight your opponents with various Pursuit Techs!
- Create your own Races using the **Race Manager** tool!

***/// Pursuits ///***
- Participate in thrilling Pursuits as a Racer or a Unit!
- Utilize Pursuit Breakers to keep the Units off your back!
- Fight the Racers or Units with various Pursuit Techs!
- Up to 10 Heat Levels - the higher the level, the tougher the Units!
- Create your own Pursuit Breakers, Roadblocks and Units using the **various tools**!

***/// General ///***
- Easy-to-use custom menu
- Offers support for Glide, Simfphys, Photon 2 and Base HL2 Jeeps
- Various UI Styles resembling older NFS titles to choose from
- Fine-tune every little bit of the addon to fit your preference
- Localization support:

|`Full`|`Partial`|`Minimal`|
|---|---|---|
|English|Czech|Danish|
|Spanish|German|Finnish|
|Russian|Greek|French|
|Swedish|Ukrainian|Hungarian|
|S. Chinese| |Italian|
|Polish| |Japanese|
|Thai| |Korean|
| | |Dutch|
| | |Brazilian|
| | |Slovakian|
| | |T. Chinese|

## FAQ
| Question | Answer |
| --- | --- |
| `Where are the races, Pursuit Breakers, Roadblocks, etc.?` | Unit Vehicles does not come prepackaged with any races, Pursuit Breakers or Roadblocks. You can always run using the default Heat Preset. Alternatively, you can utilize the **Starter Data Pack** (linked above) to get you started with a bunch of presets! |
| `What vehicle bases are supported?` | **Glide** is highly recommended and has the most support, but you can also use **Simfphys**, **Photon 2** or even **Base HL2**. |
| `Where is my created data stored?` | It is stored in the game's **data** folder. Here you'll find Unit data, Racer Names, Pursuit Breaker data, Race data and Roadblock data. |
| `I want to assist in development!` | All you need to do is download this Git and start changing. Once you're ready, send us a pull request, and we'll take a look at it. If it's good, we'll implement it! |
| `Can I localize Unit Vehicles?` | Yes you can! First check the `Regarding localization pull requests` section at the bottom though. |
| `I have more questions!` | First you should check the in-game **UV Menu**'s **FAQ**. While in-game, hold your Context key (`C` by default) and click **Unit Vehicles**, then navigate to **FAQ**. |

## Regarding pull requests
- When you create a fork, ensure your changes are done in its own separate branch. Do not use `main`.
- If you are aware of bugs in your code, mention them in your PR.
- Work-in-progress commits are to be published as PR drafts. Also applies if you wish for input from other contributors.
- Please follow the [CFC style guidelines](https://github.com/CFC-Servers/cfc_glua_style_guidelines) when providing code. Optionally, you can install [glualint](https://github.com/FPtje/GLuaFixer) and its extention to get warnings in your preferred text editor.

## Regarding localization pull requests
- Localizations are stored in `resource/localization` inside `.properties` files. These can be opened in any text editor.
- Please prioritize translating the `unitvehicles` and `unitvehicles_settings` files above all else. Any `unitvehicles_subtitles` files are optional.
- When contributing to a language that already has a translator (or translators), please be mindful not to change existing strings.
- Work-in-progress translations are to be published as PR drafts. Also applies if you wish for input from other contributors.
- Various elements in the texts are to be kept as-is; `%s`, `[+attack]` and so on.
- When translating the FAQ (located in `lua/unitvehicles/uv_menu_faq`), please add a language identifier above it. For example `-- Polska (Polish) pl`.