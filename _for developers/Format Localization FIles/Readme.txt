This tool automatically restructures the .properties localization files present to match the (EN) English files.

---> Requirements <---
1) Python 3.11 or newer

---> How do I use this? <---
1) Move the .py file into the base addon folder (where "lua", "sound", "resources", etc. are)
2) Run the .py file.
3) Choose which file to format - "unitvehicles" is default.
4) Confirm and done!

---> Important Notes <---
1) A copy of the English file will be created and stored in "_for developers/Localization Backup". If strings in English differ from this backup, those strings will be replaced in all languages.
2) Non-translated strings, or missing strings have a prefix and are commented out.