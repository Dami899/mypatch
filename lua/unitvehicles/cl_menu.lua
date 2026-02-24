UV = UV or {}
UVMenu = UVMenu or {}

-- Current Version -- Change this whenever a new update is releasing!
UV.CurVersion = "v1.2.0" --MAJOR.MINOR.PATCH

-- Credits List
UV.Credits = {
["UVTeam"] = [[
Roboboy
Aux
Moka
ET7970]],
["Translations"] = {
		-- { flag = "bg", desc = "Български | Bulgarian", name = "REPLACEME" },
		{ flag = "cz", desc = "Čeština | Czech", name = "Despe" },
		-- { flag = "dk", desc = "Dansk | Danish", name = "REPLACEME" },
		{ flag = "de", desc = "Deutsch | German", name = "Marig" },
		{ flag = "gr", desc = "Ελληνικά | Greek", name = "TalonSolid" },
		{ flag = "es", desc = "Español | Spanish", name = "Dami" },
		-- { flag = "et", desc = "Eesti | Estonian", name = "REPLACEME" },
		-- { flag = "fi", desc = "Suomi | Finnish", name = "REPLACEME" },
		-- { flag = "fr", desc = "Français | French", name = "REPLACEME" },
		-- { flag = "il", desc = "עברית | Hebrew", name = "REPLACEME" },
		-- { flag = "hr", desc = "Hrvatski | Croatian", name = "REPLACEME" },
		-- { flag = "hu", desc = "Magyar | Hungarian", name = "REPLACEME" },
		-- { flag = "it", desc = "Italiano | Italian", name = "REPLACEME" },
		-- { flag = "jp", desc = "日本語 | Japanese", name = "REPLACEME" },
		-- { flag = "kr", desc = "한국어 | Korean", name = "REPLACEME" },
		-- { flag = "lt", desc = "Lietuvių | Lithuanian", name = "REPLACEME" },
		-- { flag = "nl", desc = "Nederlands | Dutch", name = "REPLACEME" },
		-- { flag = "no", desc = "Norsk | Norwegian", name = "REPLACEME" },
		{ flag = "pl", desc = "Polski | Polish", name = "TheSilent1" },
		-- { flag = "br", desc = "Português (Brasil) | Brazilian Portuguese", name = "REPLACEME" },
		-- { flag = "pt", desc = "Português | Portuguese", name = "REPLACEME" },
		{ flag = "ru", desc = "Русский | Russian", name = "WladZ" },
		-- { flag = "sk", desc = "Slovenčina | Slovak", name = "REPLACEME" },
		{ flag = "se", desc = "Svenska | Swedish", name = "Moka" },
		{ flag = "th", desc = "แบบไทย | Thai", name = "Takis036" },
		-- { flag = "tr", desc = "Türkçe | Turkish", name = "REPLACEME" },
		{ flag = "ua", desc = "Українська | Ukrainian", name = "Mr.Negative & Renegade_Glitch" },
		-- { flag = "vn", desc = "Tiếng Việt | Vietnamese", name = "REPLACEME" },
		{ flag = "cn", desc = "简体中文 | Simplified Chinese", name = "Pathfinder_FUFU" },
		-- { flag = "tw", desc = "繁體中文 | Traditional Chinese", name = "REPLACEME" },
	},
["Contributors"] = [[
TalonSolid
dr. drehow315
CoreFan19
Dami899
mustang
]],
}

-- Formats PNote Strings
local MonthNames = {
    en = {
        full  = { "January","February","March","April","May","June","July","August","September","October","November","December" },
        short = { "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec" },
    },

    fr = {
        full  = { "janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre" },
        short = { "janv.","févr.","mars","avr.","mai","juin","juil.","août","sept.","oct.","nov.","déc." },
    },

    de = {
        full  = { "Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember" },
        short = { "Jan.","Feb.","März","Apr.","Mai","Juni","Juli","Aug.","Sept.","Okt.","Nov.","Dez." },
    },

    ["es-ES"] = {
        full  = { "enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre" },
        short = { "ene.","feb.","mar.","abr.","may.","jun.","jul.","ago.","sept.","oct.","nov.","dic." },
    },

    it = {
        full  = { "gennaio","febbraio","marzo","aprile","maggio","giugno","luglio","agosto","settembre","ottobre","novembre","dicembre" },
        short = { "gen","feb","mar","apr","mag","giu","lug","ago","set","ott","nov","dic" },
    },

    ["pt-BR"] = {
        full  = { "janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro" },
        short = { "jan","fev","mar","abr","mai","jun","jul","ago","set","out","nov","dez" },
    },

    ["pt-PT"] = {
        full  = { "janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro" },
        short = { "jan","fev","mar","abr","mai","jun","jul","ago","set","out","nov","dez" },
    },

    nl = {
        full  = { "januari","februari","maart","april","mei","juni","juli","augustus","september","oktober","november","december" },
        short = { "jan","feb","mrt","apr","mei","jun","jul","aug","sep","okt","nov","dec" },
    },

    pl = {
        full  = { "stycznia","lutego","marca","kwietnia","maja","czerwca","lipca","sierpnia","września","października","listopada","grudnia" },
        short = { "sty","lut","mar","kwi","maj","cze","lip","sie","wrz","paź","lis","gru" },
    },

    cs = {
        full  = { "ledna","února","března","dubna","května","června","července","srpna","září","října","listopadu","prosince" },
        short = { "led","úno","bře","dub","kvě","čer","čvc","srp","zář","říj","lis","pro" },
    },

    sk = {
        full  = { "januára","februára","marca","apríla","mája","júna","júla","augusta","septembra","októbra","novembra","decembra" },
        short = { "jan","feb","mar","apr","máj","jún","júl","aug","sep","okt","nov","dec" },
    },

    ["sv-SE"] = {
        full  = { "januari","februari","mars","april","maj","juni","juli","augusti","september","oktober","november","december" },
        short = { "jan","feb","mar","apr","maj","jun","jul","aug","sep","okt","nov","dec" },
    },

    da = {
        full  = { "januar","februar","marts","april","maj","juni","juli","august","september","oktober","november","december" },
        short = { "jan","feb","mar","apr","maj","jun","jul","aug","sep","okt","nov","dec" },
    },

    no = {
        full  = { "januar","februar","mars","april","mai","juni","juli","august","september","oktober","november","desember" },
        short = { "jan","feb","mar","apr","mai","jun","jul","aug","sep","okt","nov","des" },
    },

    fi = {
        full  = { "tammikuuta","helmikuuta","maaliskuuta","huhtikuuta","toukokuuta","kesäkuuta","heinäkuuta","elokuuta","syyskuuta","lokakuuta","marraskuuta","joulukuuta" },
        short = { "tammi","helmi","maalis","huhti","touko","kesä","heinä","elo","syys","loka","marras","joulu" },
    },

    et = {
        full  = { "jaanuar","veebruar","märts","aprill","mai","juuni","juuli","august","september","oktoober","november","detsember" },
        short = { "jaan","veebr","märts","apr","mai","juuni","juuli","aug","sept","okt","nov","dets" },
    },

    lt = {
        full  = { "sausio","vasario","kovo","balandžio","gegužės","birželio","liepos","rugpjūčio","rugsėjo","spalio","lapkričio","gruodžio" },
        short = { "sau","vas","kov","bal","geg","bir","lie","rgp","rgs","spa","lap","gru" },
    },

    hr = {
        full  = { "siječnja","veljače","ožujka","travnja","svibnja","lipnja","srpnja","kolovoza","rujna","listopada","studenoga","prosinca" },
        short = { "sij","velj","ožu","tra","svi","lip","srp","kol","ruj","lis","stu","pro" },
    },

    hu = {
        full  = { "január","február","március","április","május","június","július","augusztus","szeptember","október","november","december" },
        short = { "jan","feb","márc","ápr","máj","jún","júl","aug","szept","okt","nov","dec" },
    },

    ro = {
        full  = { "ianuarie","februarie","martie","aprilie","mai","iunie","iulie","august","septembrie","octombrie","noiembrie","decembrie" },
        short = { "ian","feb","mar","apr","mai","iun","iul","aug","sept","oct","nov","dec" },
    },

    bg = {
        full  = { "януари","февруари","март","април","май","юни","юли","август","септември","октомври","ноември","декември" },
        short = { "ян.","фев.","март","апр.","май","юни","юли","авг.","септ.","окт.","ноем.","дек." },
    },

    ru = {
        full  = { "января","февраля","марта","апреля","мая","июня","июля","августа","сентября","октября","ноября","декабря" },
        short = { "янв.","февр.","март","апр.","май","июнь","июль","авг.","сент.","окт.","нояб.","дек." },
    },

    uk = {
        full  = { "січня","лютого","березня","квітня","травня","червня","липня","серпня","вересня","жовтня","листопада","грудня" },
        short = { "січ","лют","бер","квіт","трав","черв","лип","серп","вер","жовт","лист","груд" },
    },

    el = {
        full  = { "Ιανουαρίου","Φεβρουαρίου","Μαρτίου","Απριλίου","Μαΐου","Ιουνίου","Ιουλίου","Αυγούστου","Σεπτεμβρίου","Οκτωβρίου","Νοεμβρίου","Δεκεμβρίου" },
        short = { "Ιαν","Φεβ","Μαρ","Απρ","Μαΐ","Ιουν","Ιουλ","Αυγ","Σεπ","Οκτ","Νοε","Δεκ" },
    },

    tr = {
        full  = { "Ocak","Şubat","Mart","Nisan","Mayıs","Haziran","Temmuz","Ağustos","Eylül","Ekim","Kasım","Aralık" },
        short = { "Oca","Şub","Mar","Nis","May","Haz","Tem","Ağu","Eyl","Eki","Kas","Ara" },
    },

    he = {
        full  = { "ינואר","פברואר","מרץ","אפריל","מאי","יוני","יולי","אוגוסט","ספטמבר","אוקטובר","נובמבר","דצמבר" },
        short = { "ינו׳","פבר׳","מרץ","אפר׳","מאי","יונ׳","יול׳","אוג׳","ספט׳","אוק׳","נוב׳","דצמ׳" },
    },

    ja = {
        full  = { "1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月" },
        short = { "1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月" },
    },

    ko = {
        full  = { "1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월" },
        short = { "1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월" },
    },

    ["zh-CN"] = {
        full  = { "1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月" },
        short = { "1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月" },
    },

    ["zh-TW"] = {
        full  = { "1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月" },
        short = { "1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月" },
    },

    th = {
        full  = { "มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม" },
        short = { "ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค." },
    },

    -- vi = {
        -- full  = { "tháng 1","tháng 2","tháng 3","tháng 4","tháng 5","tháng 6","tháng 7","tháng 8","tháng 9","tháng 10","tháng 11","tháng 12" },
        -- short = { "Th1","Th2","Th3","Th4","Th5","Th6","Th7","Th8","Th9","Th10","Th11","Th12" },
    -- },
}

local DateFormats = {
    en = "{day} {month} {year}",
    fr = "{day} {month} {year}",
    de = "{day}. {month} {year}",
    ["es-ES"] = "{day} {month} {year}",
    it = "{day} {month} {year}",
    ["pt-BR"] = "{day} {month} {year}",
    ["pt-PT"] = "{day} {month} {year}",
    nl = "{day} {month} {year}",
    pl = "{day} {month} {year}",
    cs = "{day} {month} {year}",
    sk = "{day} {month} {year}",
    ["sv-SE"] = "{day} {month} {year}",
    da = "{day} {month} {year}",
    no = "{day} {month} {year}",
    fi = "{day}. {month} {year}",
    et = "{day}. {month} {year}",
    lt = "{year} m. {month} {day} d.",
    hr = "{day}. {month} {year}.",
    hu = "{year}. {month} {day}.",
    ro = "{day} {month} {year}",
    bg = "{day} {month} {year}",
    ru = "{day} {month} {year}",
    uk = "{day} {month} {year}",
    el = "{day} {month} {year}",
    tr = "{day} {month} {year}",
    he = "{day} ב{month} {year}",
    ja = "{year}年{month}{day}日",
    ko = "{year}년 {month} {day}일",
    ["zh-CN"] = "{year}年{month}{day}日",
    ["zh-TW"] = "{year}年{month}{day}日",
    th = "{day} {month} {year}",
    -- vi = "{day} {month} {year}",
}

local function FormatPatchDate(dateTbl, useFullMonth)
    local lang = GetConVar("gmod_language"):GetString()
    local format = DateFormats[lang] or "%Y-%m-%d"

	-- Fallback
    if format:find("%%") then
        local time = os.time({
            year  = dateTbl.year,
            month = dateTbl.month,
            day   = dateTbl.day,
            hour  = 12
        })

        return os.date(format, time)
    end

    -- Fancy shit
    local months = MonthNames[lang] or MonthNames["en"]
    local monthType = useFullMonth and "full" or "short"
    local monthName = months[monthType][dateTbl.month]

    return format
        :gsub("{day}", dateTbl.day)
        :gsub("{month}", monthName)
        :gsub("{year}", dateTbl.year)
end

if CLIENT then
	list.Set("DesktopWindows", "UnitVehiclesMenu", {
		title = UVString("uv.unitvehicles"),
		icon  = "unitvehicles/icons/MILESTONE_OUTRUN_PURSUITS_WON.png",
		init = function(icon, window)
			RunConsoleCommand("unitvehicles_menu")
		end
	})
end

concommand.Add("unitvehicles_menu", function()
	if GetConVar("unitvehicle_uvmenu_firstsetup"):GetBool() and (LocalPlayer():IsAdmin() and LocalPlayer():IsSuperAdmin()) then
		UVMenu.OpenMenu(UVMenu.FirstTimeSetup, true)
	else
		if UVMenu.CurrentMenu and IsValid(UVMenu.CurrentMenu) then
			UVMenu.OpenMenu(UVMenu.CurrentMenu, true)
		elseif UVMenu.LastMenu then
			UVMenu.OpenMenu(UVMenu.LastMenu)
		else
			UVMenu.OpenMenu(UVMenu.Main)
		end
	end
	UVMenu.PlaySFX("menuopen")
end)

-- Pursuit Themes
local pursuitfiles, pursuitfolders = file.Find("sound/uvpursuitmusic/*", "GAME")
local pursuitcontent = {}

if pursuitfolders then
	for _, v in ipairs(pursuitfolders) do
		pursuitcontent[#pursuitcontent + 1] = { v, v }
	end
end

-- Race SFX
local racesfxfiles, racesfxfolders = file.Find("sound/uvracesfx/*", "GAME")
local racesfxcontent = {}

if racesfxfolders then
	for _, v in ipairs(racesfxfolders) do
		racesfxcontent[#racesfxcontent + 1] = { v, v }
	end
end

-- AI Spawner helper
local function SpawnAI(amount, racestart, police)
	local beginrace = racestart or false
	local cv = police and "uv_spawnvehicles" or "uvrace_spawnai"
	
	for i = 1, amount do
		RunConsoleCommand(cv)
	end
	
	if beginrace then
		timer.Simple(0.5, function()
			RunConsoleCommand("uvrace_startinvite")
		end)

		timer.Simple(2, function()
			RunConsoleCommand("uvrace_startrace", GetConVar("unitvehicle_racelaps"):GetString())
		end)
	end
end

-- HUD Type helper
local function BuildHUDComboLists()
    local mainHUDs = {}
    local backupHUDs = {}

	-- PrintTable(UV.HUDRegistry)

    for _, hud in pairs(UV.HUDRegistry or {}) do
		table.insert(mainHUDs, {
			hud.name,       -- display text
			hud.codename    -- convar value
		})

        if hud.backup then
            table.insert(backupHUDs, {
                hud.name,
                hud.codename
            })
        end
    end

    table.sort(mainHUDs, function(a, b)
        return a[1] < b[1]
    end)

    table.sort(backupHUDs, function(a, b)
        return a[1] < b[1]
    end)

    return mainHUDs, backupHUDs
end

local mainHUDList, backupHUDList = BuildHUDComboLists()

------- [ Main Menu ]-------
UVMenu.Main = function()
	local mainHUDList, backupHUDList = BuildHUDComboLists()
	
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = UVString("uv.unitvehicles") .. " - " .. UV.CurVersion,
		Width  = UV.ScaleW(1540),
		Height = UV.ScaleH(760),
		Description = true,
		UnfocusClose = true,
		Tabs = {
		
			{ TabName = "uv.menu.welcome", Icon = "unitvehicles/icons_settings/info.png", NoTitle = true, -- Welcome Page
				
				-- { type = "label", text = "uv.menu.pnotes" },
				{ type = "image", text = "uv.ft.title", image = "unitvehicles/icons_settings/Welcome.png" },
				{ type = "infosimple", text = string.format( UVString("uv.menu.lastupdate"), UV.CurVersion, FormatPatchDate(UV.PNotes[UV.CurVersion].Date) ) },
				{ type = "button", text = "uv.menu.updatehistory", desc = "uv.menu.updatehistory.desc", playsfx = "clickopen", prompts = {"uv.prompt.open.menu"}, func = function() UVMenu.OpenMenu(UVMenu.UpdateHistory, true) end },
				-- { type = "image", image = "unitvehicles/icons_settings/pnotes/" .. UV.CurVersion .. ".png" },
				
				{ type = "label", text = "uv.menu.quick", desc = "uv.menu.quick.desc" },
				{ type = "combo", text = "uv.ui.main", desc = "uv.ui.main.desc", convar = "unitvehicle_hudtype_main", content = mainHUDList },
				{ type = "bool", text = "uv.audio.uvtrax.enable", desc = "uv.audio.uvtrax.desc", convar = "unitvehicle_racingmusic" },
				{ type = "combo", text = "uv.audio.uvtrax.profile", desc = "uv.audio.uvtrax.profile.desc", convar = "unitvehicle_racetheme", requireparentconvar = "unitvehicle_racingmusic" },
				
				{ type = "button", text = "uv.pm.spawnas", desc = "uv.pm.spawnas.desc", convar = "uv_spawn_as_unit", prompts = {"uv.prompt.open.menu"}, func = 
				function(self2)
					UVMenu.CloseCurrentMenu(true)
					UVMenu.PlaySFX("clickopen")
					timer.Simple(tonumber(GetConVar("uvmenu_close_speed"):GetString()) or 0.2, function()
						RunConsoleCommand("uv_spawn_as_unit")
					end)
				end
				},
				
				{ type = "button", text = "uv.pm.pursuit.start", convar = "uv_startpursuit", sv = true },
				{ type = "button", text = "uv.pm.pursuit.stop", convar = "uv_stoppursuit", sv = true },
				
				-- { type = "info", text = UV.PNotes[UV.CurVersion].Text },
			},
			
			{ TabName = "uv.rm", Icon = "unitvehicles/icons/race_events.png", sv = true, playsfx = "clickopen", Prompts = { "uv.prompt.open.menu" }, func = function()
					UVMenu.OpenMenu(UVMenu.RaceManager) -- Race Manager
				end,
			},
			
			{ TabName = "uv.pm", Icon = "unitvehicles/icons/milestone_911.png", -- Pursuit Manager
				{ type = "button", text = "uv.pm.spawnas", desc = "uv.pm.spawnas.desc", convar = "uv_spawn_as_unit", prompts = {"uv.prompt.open.menu"}, func = 
				function(self2)
					UVMenu.CloseCurrentMenu(true)
					UVMenu.PlaySFX("clickopen")
					timer.Simple(tonumber(GetConVar("uvmenu_close_speed"):GetString()) or 0.2, function()
						RunConsoleCommand("uv_spawn_as_unit")
					end)
				end
				},
				{ type  = "buttonsw", text  = UVString("uv.pm.spawnai.val"), desc  = "uv.pm.spawnai.val.desc", sv = true, min = 1, max = 20, start = 1,
					func = function(self2, amount)
						SpawnAI(amount, nil, true)
					end,
				},
				{ type = "button", text = "uv.pm.clearai", desc = "uv.pm.clearai.desc", convar = "uv_despawnvehicles", prompts = {"uv.prompt.confirm"}, sv = true },
				
				{ type = "label", text = "uv.pursuit", sv = true },
				-- { type = "button", text = "uv.pm.pursuit.toggle", desc = "uv.pm.pursuit.toggle.desc", convar = "uv_startpursuit", sv = true },
				{ type = "button", text = "uv.pm.pursuit.start", convar = "uv_startpursuit", sv = true },
				{ type = "button", text = "uv.pm.pursuit.stop", convar = "uv_stoppursuit", sv = true },
				{ type = "slider", text = "uv.pm.heatlevel", desc = "uv.pm.heatlevel.desc", command = "uv_setheat", min = 1, max = MAX_HEAT_LEVEL, decimals = 0, sv = true },
				{ type = "button", text = "uv.pm.clearbounty", desc = "uv.pm.clearbounty.desc", convar = "uv_clearbounty", prompts = {"uv.prompt.confirm"}, sv = true },
				{ type = "button", text = "uv.pm.wantedtable", convar = "uv_wantedtable", prompts = {"uv.prompt.confirm"}, sv = true },

				{ type = "label", text = "uv.hm", sv = true },
				{ type = "button", text = "uv.hm.open", desc = "uv.hm.open.desc", playsfx = "clickopen", prompts = {"uv.prompt.open.menu"}, func = function() UVMenu.OpenMenu(UVMenu.HeatManager, true) end, sv = true },
			},
			
			{ TabName = "uv.airacer", Icon = "unitvehicles/icons/(9)T_UI_PlayerRacer_Large_Icon.png", sv = true, -- AI Racer Manager
				{ type = "combo", text = "uv.tool.base.title", desc = "uv.tool.base.desc", convar = "unitvehicle_racer_vehiclebase", sv = true, content = {
						{ "uv.base.hl2", 1 } ,
						{ "uv.base.simfphys", 2 } ,
						{ "uv.base.glide", 3 } ,
					},
				},
				{ type = "combo", text = "uv.tool.spawncondition", desc = "uv.tool.spawncondition.desc", convar = "unitvehicle_racer_spawncondition", sv = true, content = {
						{ "uv.tool.spawncondition.never", 1 } ,
						{ "uv.tool.spawncondition.driving", 2 } ,
						{ "uv.tool.spawncondition.always", 3 } ,
					},
				},
				{ type = "slider", text = "uv.tool.maxamount", desc = "uv.tool.maxamount.desc", convar = "unitvehicle_racer_maxracer", min = 0, max = 20, decimals = 0, sv = true },

				{ type = "buttonsw", text = UVString("uv.airacer.spawnai.val"), desc = "uv.airacer.spawnai.val.desc", convar = "uvrace_spawnai", sv = true, min = 1, max = 20, start = 1, func = function(self2, amount) SpawnAI(amount) end, },
				{ type = "button", text = "uv.airacer.clear", desc = "uv.airacer.clear.desc", convar = "uv_clearracers", prompts = {"uv.prompt.confirm"}, sv = true },
				
				{ type = "bool", text = "uv.airacer.override", desc = "uv.airacer.override.desc", convar = "unitvehicle_racer_assignracers", sv = true },
				{ type = "vehicleoverride", text = "uv.airacer.overridelist", desc = "uv.airacer.overridelist.desc", convar = "unitvehicle_racer_racers", sv = true, parentconvar = "unitvehicle_racer_assignracers" },
			},
			
			{ TabName = "uv.tm", Icon = "unitvehicles/icons_settings/gameplay.png", sv = true, -- Traffic Manager
				{ type = "combo", text = "uv.tool.base.title", desc = "uv.tool.base.desc", convar = "unitvehicle_traffic_vehiclebase", sv = true, content = {
						{ "uv.base.hl2", 1 } ,
						{ "uv.base.simfphys", 2 } ,
						{ "uv.base.glide", 3 } ,
					},
				},
				{ type = "combo", text = "uv.tool.spawncondition", desc = "uv.tool.spawncondition.desc", convar = "unitvehicle_traffic_spawncondition", sv = true, content = {
						{ "uv.tool.spawncondition.never", 1 } ,
						{ "uv.tool.spawncondition.driving", 2 } ,
						{ "uv.tool.spawncondition.always", 3 } ,
					},
				},
				{ type = "slider", text = "uv.tool.maxamount", desc = "uv.tool.maxamount.desc", convar = "unitvehicle_traffic_maxtraffic", min = 0, max = 20, decimals = 0, sv = true },

				{ type = "button", text = "uv.tm.clear", desc = "uv.tm.clear.desc", convar = "uv_cleartraffic", prompts = {"uv.prompt.confirm"}, sv = true },

				{ type = "bool", text = "uv.airacer.override", desc = "uv.tm.override.desc", convar = "unitvehicle_traffic_assigntraffic", sv = true },
				{ type = "vehicleoverride", text = "uv.airacer.overridelist", desc = "uv.airacer.overridelist.desc", convar = "unitvehicle_traffic_vehicles", sv = true, parentconvar = "unitvehicle_traffic_assigntraffic" },
			},

			{ TabName = "uv.settings", Icon = "unitvehicles/icons_settings/options.png", playsfx = "clickopen", Prompts = { "uv.prompt.open.menu" }, func = function()
					UVMenu.OpenMenu(UVMenu.Settings) -- Settings Menu
				end,
			},

			{ TabName = "uv.faq", Icon = "unitvehicles/icons_settings/question.png", playsfx = "clickopen", Prompts = { "uv.prompt.open.menu" }, func = function()
					UVMenu.OpenMenu(UVMenu.FAQ, true) -- FAQ
				end,
			},

			{ TabName = "uv.credits", Icon = "unitvehicles/icons/milestone_outrun_pursuits_won.png", playsfx = "clickopen", Prompts = { "uv.prompt.open.menu" }, func = function()
					UVMenu.OpenMenu(UVMenu.Credits, true) -- Credits
				end,
			},
			
			-- { TabName = "uv.ft", playsfx = "clickopen", Prompts = { "uv.prompt.open.menu" }, func = function() -- DEBUG
					-- UVMenu.OpenMenu(UVMenu.FirstTimeSetup, true) -- First-Time Setup
				-- end,
			-- },
			
		}
	})
end

-- Settings
UVMenu.Settings = function()
	local mainHUDList, backupHUDList = BuildHUDComboLists()
	
	local addonTabRows = {}

	-- Add third-party addon blocks
	if UVMenu.AddonEntries and #UVMenu.AddonEntries > 0 then
		for _, block in ipairs(UVMenu.AddonEntries) do
			-- Optional visual separator
			table.insert(addonTabRows, { type = "spacer" })

			for _, row in ipairs(block) do
				table.insert(addonTabRows, row)
			end
		end
	else
		-- No addons present → default label
		table.insert(addonTabRows, {
			type = "infosimple",
			text = "uv.addons.none",
		})
	end
	
	local function BuildSoundProfileList()
		local t = {}

		for id, data in SortedPairs(UVMenu.SoundProfiles) do
			table.insert(t, { data.displayname, id })
		end

		return t
	end

	UVMenu.CurrentMenu = UVMenu:Open({
		Name = UVString("uv.unitvehicles") .. " | " .. UVString("uv.settings"),
		Width  = UV.ScaleW(1540),
		Height = UV.ScaleH(760),
		Description = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.ui.title", Icon = "unitvehicles/icons_settings/display.png",

				{ type = "label", text = "uv.settings.general" },
				{ type = "combo", text = "uv.ui.main", desc = "uv.ui.main.desc", convar = "unitvehicle_hudtype_main", content = mainHUDList },
				{ type = "combo", text = "uv.ui.backup", desc = "uv.ui.backup.desc", convar = "unitvehicle_hudtype_backup", content = backupHUDList },
				{ type = "bool", text = "uv.ui.racertags", desc = "uv.ui.racertags.desc", convar = "unitvehicle_racertags" },
				{ type = "bool", text = "uv.ui.preracepopup", desc = "uv.ui.preracepopup.desc", convar = "unitvehicle_preraceinfo" },
				{ type = "combo", text = "uv.ui.unitstype", desc = "uv.ui.unitstype.desc", convar = "unitvehicle_unitstype", content = {
						{ "uv.ui.unitstype.meter", 0 },
						{ "uv.ui.unitstype.feet", 1 },
						{ "uv.ui.unitstype.yards", 2 },
					},
				},
				{ type = "slider", text = "uv.ui.deadzone", desc = "uv.ui.deadzone.desc", convar = "unitvehicle_hud_deadzone", min = 0, max = 500, decimals = 0 },
				{ type = "slider", text = "uv.ui.scale", desc = "uv.ui.scale.desc", convar = "unitvehicle_hud_scale", min = 0.1, max = 1, decimals = 2 },

				{ type = "label", text = "uv.pursuit" },
				{ type = "bool", text = "uv.ui.policescanner", desc = "uv.ui.policescanner.desc", convar = "unitvehicle_policescanner" },
				{ type = "bool", text = "uv.ui.policescanner.vehicle", desc = "uv.ui.policescanner.vehicle.desc", convar = "unitvehicle_policescanner_vehicle", requireparentconvar = "unitvehicle_policescanner" },
				-- { type = "bool", text = "uv.ui.subtitles", desc = "uv.ui.subtitles.desc", convar = "unitvehicle_subtitles" },
				{ type = "bool", text = "uv.ui.vehnametakedown", desc = "uv.ui.vehnametakedown.desc", convar = "unitvehicle_vehiclenametakedown" },

				{ type = "label", text = "uv.ui.menu", desc = "uv.ui.menu.desc" },
				{ type = "bool", text = "uv.ui.menu.hidedesc", desc = "uv.ui.menu.hidedesc.desc", convar = "uvmenu_hide_description" },
				{ type = "bool", text = "uv.ui.menu.hideprompts", desc = "uv.ui.menu.hideprompts.desc", convar = "uvmenu_hide_prompts" },
				{ type = "slider", text = "uv.ui.menu.openspeed", desc = "uv.ui.menu.openspeed.desc", convar = "uvmenu_open_speed", min = 0.1, max = 1, decimals = 2 },
				{ type = "slider", text = "uv.ui.menu.closespeed", desc = "uv.ui.menu.closespeed.desc", convar = "uvmenu_close_speed", min = 0.1, max = 1, decimals = 2 },
				{ type = "button", text = "uv.ui.menu.custcol", desc = "uv.ui.menu.custcol.desc", playsfx = "clickopen", prompts = {"uv.prompt.open.menu"}, func = function() UVMenu.OpenMenu(UVMenu.SettingsCol, true) end },
				{ type = "bool", text = "uv.ft.force", desc = "uv.ft.force.desc", convar = "unitvehicle_uvmenu_firstsetup", sv = true },
			},
			{ TabName = "uv.audio.title", Icon = "unitvehicles/icons_settings/audio.png",

				{ type = "label", text = "uv.settings.general" },
				{ type = "slider", text = "uv.audio.volume", desc = "uv.audio.volume.desc", convar = "unitvehicle_pursuitthemevolume", min = 0, max = 2, decimals = 1 },
				{ type = "slider", text = "uv.audio.copchatter", desc = "uv.audio.copchatter.desc", convar = "unitvehicle_chattervolume", min = 0, max = 5, decimals = 1 },
				{ type = "bool", text = "uv.audio.mutecp", desc = "uv.audio.mutecp.desc", convar = "unitvehicle_mutecheckpointsfx" },
				{ type = "bool", text = "uv.audio.menu.sfx", desc = "uv.audio.menu.sfx.desc", convar = "uvmenu_sound_enabled" },
				{ type = "combo", text = "uv.audio.menu.sfx.profile", desc = "uv.audio.menu.sfx.profile.desc", convar = "uvmenu_sound_set", requireparentconvar = "uvmenu_sound_enabled", content = BuildSoundProfileList() },

				--{ type = "uvtrax", text = "uv.audio.uvtrax.playlists", desc = "uv.audio.uvtrax.playlists.desc", requireparentconvar = "unitvehicle_racingmusic" },

				{ type = "label", text = "uv.audio.pursuit" },
				{ type = "bool", text = "uv.audio.pursuit.enable", desc = "uv.audio.pursuit.desc", convar = "unitvehicle_playmusic" },
				{ type = "bool", text = "uv.audio.pursuit.sfx", desc = "uv.audio.pursuit.sfx.desc", convar = "unitvehicle_pursuitsfx" },
				{ type = "combo", text = "uv.audio.pursuittheme", desc = "uv.audio.pursuittheme.desc", convar = "unitvehicle_pursuittheme", content = pursuitcontent, requireparentconvar = "unitvehicle_playmusic" },
				{ type = "bool", text = "uv.audio.pursuitpriority", desc = "uv.audio.pursuitpriority.desc", convar = "unitvehicle_racingmusicpriority", requireparentconvar = "unitvehicle_playmusic" },
				{ type = "bool", text = "uv.audio.pursuittheme.random", desc = "uv.audio.pursuittheme.random.desc", convar = "unitvehicle_pursuitthemeplayrandomheat" },
				{ type = "combo", text = "uv.audio.pursuittheme.random.type", desc = "uv.audio.pursuittheme.random.type.desc", convar = "unitvehicle_pursuitthemeplayrandomheattype", requireparentconvar = "unitvehicle_pursuitthemeplayrandomheat", content = {
						{ "uv.audio.pursuittheme.random.type.sequential", "sequential" },
						{ "uv.audio.pursuittheme.random.minutes", "everyminutes" },
					},
				},
				{ type = "slider", text = "uv.audio.pursuittheme.random.minutes", desc = "uv.audio.pursuittheme.random.minutes.desc", convar = "unitvehicle_pursuitthemeplayrandomheatminutes", min = 1, max = 10, decimals = 0, requireparentconvar = "unitvehicle_pursuitthemeplayrandomheat" },
				
				{ type = "label", text = "uv.audio.racing" },
				{ type = "combo", text = "uv.audio.racing.sfx", desc = "uv.audio.racing.sfx.desc", convar = "unitvehicle_sfxtheme", content = racesfxcontent },
			},
			{ TabName = "uv.audio.uvtrax", Icon = "unitvehicles/icons/ICON_EA_TRAX.png",
				--{ type = "label", text = "uv.audio.uvtrax" },
				{ type = "bool", text = "uv.audio.uvtrax.enable", desc = "uv.audio.uvtrax.desc", convar = "unitvehicle_racingmusic" },
				{ type = "bool", text = "uv.audio.uvtrax.shuffle", desc = "uv.audio.uvtrax.shuffle.desc", convar = "unitvehicle_racetheme_shuffle", requireparentconvar = "unitvehicle_racingmusic" },
				{ type = "combo", text = "uv.audio.uvtrax.profile", desc = "uv.audio.uvtrax.profile.desc", convar = "unitvehicle_racetheme", content = uvtraxcontent, requireparentconvar = "unitvehicle_racingmusic" },
				{ type = "bool", text = "uv.audio.uvtrax.freeroam", desc = "uv.audio.uvtrax.freeroam.desc", convar = "unitvehicle_uvtraxinfreeroam", requireparentconvar = "unitvehicle_racingmusic" },
				{ type = "bool", text = "uv.audio.uvtrax.pursuits", desc = "uv.audio.uvtrax.pursuits.desc", convar = "unitvehicle_racingmusicoutsideraces", requireparentconvar = "unitvehicle_racingmusic" },

				{ type = "label", text = "uv.audio.uvtrax.editor", requireparentconvar = "unitvehicle_racingmusic" },
				{ type = "uvtrax", text = "uv.audio.uvtrax.profiles", desc = "uv.audio.uvtrax.profiles.desc", requireparentconvar = "unitvehicle_racingmusic" },
			},
			{ TabName = "uv.controls", Icon = "unitvehicles/icons_settings/controls.png",

				{ type = "label", text = "uv.controls.pt" },
				{ type = "keybind", text = "uv.keybind.slot1", desc = "uv.keybind.slot1.desc", convar = "unitvehicle_pursuittech_keybindslot_1", slot = 1 },
				{ type = "keybind", text = "uv.keybind.slot2", desc = "uv.keybind.slot2.desc", convar = "unitvehicle_pursuittech_keybindslot_2", slot = 2 },
				
				{ type = "label", text = "uv.controls.races" },
				{ type = "keybind", text = "uv.keybind.skipsong", desc = "uv.keybind.skipsong.desc", convar = "unitvehicle_keybind_skipsong", slot = 3 },
				{ type = "keybind", text = "uv.keybind.prevsong", desc = "uv.keybind.prevsong.desc", convar = "unitvehicle_keybind_prevsong", slot = 6 },
				{ type = "keybind", text = "uv.keybind.resetposition", desc = "uv.keybind.resetposition.desc", convar = "unitvehicle_keybind_resetposition", slot = 4 },
				{ type = "keybind", text = "uv.keybind.showresults", desc = "uv.keybind.showresults.desc", convar = "unitvehicle_keybind_raceresults", slot = 5 },
				
				-- { type = "label", text = "uv.controls.controllermode" },
				-- { type = "bool", text = "uv.controls.controllermode.enable", desc = "uv.controls.controllermode.enable.desc", convar = "unitvehicle_controllermode" },
				
				{ type = "label", text = "uv.controls.glyphs" },
				{ type = "bool", text = "uv.controls.glyphs.enable", desc = "uv.controls.glyphs.enable.desc", convar = "unitvehicle_glyph_override" },
				{ type = "bindoverride", text = "uv.controls.glyphs.list.enable", desc = "uv.controls.glyphs.list.desc", convar = "unitvehicle_glyph_set", requireparentconvar = "unitvehicle_glyph_override" },
			},
			{ TabName = "uv.pursuit", Icon = "unitvehicles/icons/milestone_pursuit.png", sv = true,
				{ type = "label", text = "uv.pursuit.heatlevels", sv = true },
				{ type = "bool", text = "uv.pursuit.heatlevels.enable", desc = "uv.pursuit.heatlevels.enable.desc", convar = "unitvehicle_heatlevels", sv = true },
				{ type = "bool", text = "uv.pursuit.heatlevels.aiunits", desc = "uv.pursuit.heatlevels.aiunits.desc", convar = "unitvehicle_spawnmainunits", sv = true },
				
				{ type = "label", text = "uv.settings.general", sv = true },
				{ type = "bool", text = "uv.pursuit.canexitvehicle", desc = "uv.pursuit.canexitvehicle.desc", convar = "unitvehicle_canexitvehicle", sv = true },
				{ type = "bool", text = "uv.pursuit.spottedfreezecam", desc = "uv.pursuit.spottedfreezecam.desc", convar = "unitvehicle_spottedfreezecam", sv = true, sp = true },
				{ type = "bool", text = "uv.pursuit.randomplayerunits", desc = "uv.pursuit.randomplayerunits.desc", convar = "unitvehicle_randomplayerunits", sv = true },
				{ type = "bool", text = "uv.pursuit.autohealth", desc = "uv.pursuit.autohealth.desc", convar = "unitvehicle_autohealth", sv = true },
				{ type = "bool", text = "uv.pursuit.wheelsdetaching", desc = "uv.pursuit.wheelsdetaching.desc", convar = "unitvehicle_wheelsdetaching", sv = true },
				{ type = "slider", text = "uv.pursuit.repaircooldown", desc = "uv.pursuit.repaircooldown.desc", convar = "unitvehicle_repaircooldown", min = 5, max = 300, decimals = 0, sv = true },
				{ type = "slider", text = "uv.pursuit.repairrange", desc = "uv.pursuit.repairrange.desc", convar = "unitvehicle_repairrange", min = 10, max = 1000, decimals = 0, sv = true },
				{ type = "bool", text = "uv.pursuit.noevade", desc = "uv.pursuit.noevade.desc", convar = "unitvehicle_neverevade", sv = true },
				{ type = "slider", text = "uv.pursuit.bustedtime", desc = "uv.pursuit.bustedtime.desc", convar = "unitvehicle_bustedtimer", min = 0, max = 10, decimals = 1, sv = true },
				{ type = "slider", text = "uv.pursuit.respawntime", desc = "uv.pursuit.respawntime.desc", convar = "unitvehicle_spawncooldown", min = 0, max = 120, decimals = 0, sv = true },
				{ type = "slider", text = "uv.pursuit.spikeduration", desc = "uv.pursuit.spikeduration.desc", convar = "unitvehicle_spikestripduration", min = 0, max = 120, decimals = 0, sv = true },
				
				{ type = "label", text = "uv.pursuit.roadblocks", sv = true },
				{ type = "slider", text = "uv.pursuit.roadblocks.maxnr", desc = "uv.pursuit.roadblocks.maxnr.desc", convar = "unitvehicle_roadblock_maxrb", min = 0, max = 10, sv = true },
				{ type = "combo", text = "uv.pursuit.roadblocks.alwaysjoinpursuit", desc = "uv.pursuit.roadblocks.alwaysjoinpursuit.desc", convar = "unitvehicle_roadblock_override", sv = true, content = {
						{ "uv.pursuit.roadblocks.alwaysjoinpursuit.off", 0 },
						{ "uv.pursuit.roadblocks.alwaysjoinpursuit.always", 1 },
						{ "uv.pursuit.roadblocks.alwaysjoinpursuit.never", 2 },
					},
				},
			},
			{ TabName = "uv.ptech", Icon = "unitvehicles/icons_carbon/wingman_target.png", sv = true,
				{ type = "label", text = "uv.settings.general", sv = true },
				{ type = "bool", text = "uv.ptech.racer", desc = "uv.ptech.racer.desc", convar = "unitvehicle_racerpursuittech", sv = true },
				{ type = "bool", text = "uv.ptech.friendlyfire", desc = "uv.ptech.friendlyfire.desc", convar = "unitvehicle_racerfriendlyfire", sv = true },
				{ type = "bool", text = "uv.ptech.roadblockfriendlyfire", desc = "uv.ptech.roadblockfriendlyfire.desc", convar = "unitvehicle_spikestriproadblockfriendlyfire", sv = true },
			},
			{ TabName = "uv.pb", Icon = "unitvehicles/icons/minimap_icon_pursuit_breaker.png", sv = true,
				{ type = "label", text = "uv.settings.general", sv = true },
				{ type = "slider", text = "uv.pb.maxnr", desc = "uv.pb.maxnr.desc", convar = "unitvehicle_pursuitbreaker_maxpb", min = 0, max = 10, sv = true },
				{ type = "combo", text = "uv.tool.spawncondition", desc = "uv.tool.spawncondition.pb.desc", convar = "unitvehicle_pursuitbreaker_spawncondition", sv = true, content = {
						{ "uv.tool.spawncondition.never", 0 },
						{ "uv.tool.spawncondition.driving", 1 },
						{ "uv.tool.spawncondition.always", 2 },
					},
				},
				{ type = "slider", text = "uv.pb.cooldown", desc = "uv.pb.cooldown.desc", convar = "unitvehicle_pursuitbreaker_pbcooldown", min = 10, max = 600, sv = true },
			},
			{ TabName = "uv.ai.title", Icon = "unitvehicles/icons/cops_icon.png", sv = true,
				{ type = "label", text = "uv.ailogic", sv = true },
				{ type = "bool", text = "uv.ailogic.optimizerespawn", desc = "uv.ailogic.optimizerespawn.desc", convar = "unitvehicle_optimizerespawn", sv = true },
				{ type = "bool", text = "uv.ailogic.wrecking", desc = "uv.ailogic.wrecking.desc", convar = "unitvehicle_canwreck", sv = true },
				{ type = "slider", text = "uv.ailogic.detectionrange", desc = "uv.ailogic.detectionrange.desc", convar = "unitvehicle_detectionrange", min = 1, max = 100, decimals = 0, sv = true },
				{ type = "combo", text = "uv.ailogic.headlights", desc = "uv.ailogic.headlights.desc", convar = "unitvehicle_enableheadlights", sv = true, content = {
						{ "uv.ailogic.headlights.off", 0 } ,
						{ "uv.ailogic.headlights.auto", 1 } ,
						{ "uv.ailogic.headlights.always", 2 } ,
					},
				},
				{ type = "bool", text = "uv.ailogic.autohealthracer", desc = "uv.ailogic.autohealthracer.desc", convar = "unitvehicle_autohealthracer", sv = true },
				{ type = "bool", text = "uv.ailogic.customizeracer", desc = "uv.ailogic.customizeracer.desc", convar = "unitvehicle_customizeracer", sv = true },
				{ type = "bool", text = "uv.ailogic.tractioncontrol", desc = "uv.ailogic.tractioncontrol.desc", convar = "unitvehicle_tractioncontrol", sv = true },
				
				{ type = "label", text = "uv.ainav", sv = true },
				{ type = "bool", text = "uv.ainav.pathfind", desc = "uv.ainav.pathfind.desc", convar = "unitvehicle_pathfinding", sv = true },
				{ type = "bool", text = "uv.ainav.dvpriority", desc = "uv.ainav.dvpriority.desc", convar = "unitvehicle_dvwaypointspriority", sv = true },
				{ type = "bool", text = "uv.ainav.dvdistancebased", desc = "uv.ainav.dvdistancebased.desc", convar = "unitvehicle_dvwaypointsdistancebased", sv = true },
				
				{ type = "label", text = "uv.chatter", sv = true },
				{ type = "bool", text = "uv.chatter.enable", desc = "uv.chatter.enable.desc", convar = "unitvehicle_chatter", sv = true },
				
				{ type = "label", text = "uv.response", sv = true },
				{ type = "bool", text = "uv.response.enable", desc = "uv.response.enable.desc", convar = "unitvehicle_callresponse", sv = true },
				{ type = "slider", text = "uv.response.speedlimit", desc = "uv.response.speedlimit.desc", convar = "unitvehicle_speedlimit", min = 0, max = 100, decimals = 0, sv = true },
			},
			{ TabName = "uv.addons", Icon = "unitvehicles/icons/generic_cart.png", sv = true,
				unpack(addonTabRows)
			},

			{ TabName = "uv.back", playsfx = "clickback", Prompts = { "uv.prompt.return" }, func = function()
					UVMenu.OpenMenu(UVMenu.Main)
				end,
			},
		}
	})
end

-- Colour Settings
UVMenu.SettingsCol = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1250),
		Height = UV.ScaleH(760),
		Description = true,
		-- ColorPreview = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.ui.menu.custcol",
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
						func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
				{ type = "label", text = "uv.ui.menu.col.bg" },
				{ type = "coloralpha", text = "uv.ui.menu.col", desc = "uv.ui.menu.col.desc", convar = "uvmenu_col_bg" },
				
				{ type = "label", text = "uv.ui.menu.col.description" },
				{ type = "coloralpha", text = "uv.ui.menu.col", desc = "uv.ui.menu.col.desc", convar = "uvmenu_col_desc" },
				
				{ type = "label", text = "uv.ui.menu.col.tabs" },
				{ type = "coloralpha", text = "uv.ui.menu.col.background", desc = "uv.ui.menu.col.background.desc", convar = "uvmenu_col_tabs" },
				{ type = "coloralpha", text = "uv.ui.menu.col", desc = "uv.ui.menu.col.desc", convar = "uvmenu_col_tab_default" },
				{ type = "coloralpha", text = "uv.ui.menu.col.active", desc = "uv.ui.menu.col.active.desc", convar = "uvmenu_col_tab_active" },
				{ type = "coloralpha", text = "uv.ui.menu.col.hover", desc = "uv.ui.menu.col.hover.desc", convar = "uvmenu_col_tab_hover" },
				
				{ type = "label", text = "uv.ui.menu.col.label" },
				{ type = "coloralpha", text = "uv.ui.menu.col", desc = "uv.ui.menu.col.desc", convar = "uvmenu_col_label" },
				
				{ type = "label", text = "uv.ui.menu.col.bool" },
				{ type = "coloralpha", text = "uv.ui.menu.col", desc = "uv.ui.menu.col.desc", convar = "uvmenu_col_bool" },
				{ type = "coloralpha", text = "uv.ui.menu.col.active", desc = "uv.ui.menu.col.active.desc", convar = "uvmenu_col_bool_active" },
				
				{ type = "label", text = "uv.ui.menu.col.button" },
				{ type = "coloralpha", text = "uv.ui.menu.col", desc = "uv.ui.menu.col.desc", convar = "uvmenu_col_button" },
				{ type = "coloralpha", text = "uv.ui.menu.col.hover", desc = "uv.ui.menu.col.hover.desc", convar = "uvmenu_col_button_hover" },

				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
						func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
			},
		}
	})
end

-- FAQ Menu
UVMenu.FAQ = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = UVString("uv.unitvehicles") .. " | " .. UVString("uv.faq"),
		Width  = UV.ScaleW(1540),
		Height = UV.ScaleH(760),
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.faq.intro", Icon = "unitvehicles/icons_settings/info.png",
				{ type = "info", text = UVGetFAQText("Intro") },
				{ type = "info", text = UVGetFAQText("Requirements") },
				-- { type = "info", text = UVGetFAQText("Github") },
				{ type = "info", text = UVGetFAQText("ConVars") },
				{ type = "info", text = UVGetFAQText("Roadmap") },
			},

			{ TabName = "uv.faq.racing", Icon = "unitvehicles/icons/race_events.png",
				{ type = "info", text = UVGetFAQText("Racing.Starting"), sv = true },
				{ type = "info", text = UVGetFAQText("Racing.SpawnAI"), sv = true },
				{ type = "info", text = UVGetFAQText("Racing.Create"), sv = true },
				{ type = "info", text = UVGetFAQText("Racing.Create.Speedlimit"), sv = true },
				{ type = "info", text = UVGetFAQText("Racing.Create.PathNode"), sv = true },
				
				{ type = "info", text = UVGetFAQText("Racing.Joining") },
				{ type = "info", text = UVGetFAQText("Racing.Resetting") },
			},

			{ TabName = "uv.faq.pursuits", Icon = "unitvehicles/icons/milestone_911.png",
				{ type = "info", text = UVGetFAQText("Pursuit.Starting"), sv = true },
				{ type = "info", text = UVGetFAQText("Pursuit.CreateUnits"), sv = true },
				{ type = "info", text = UVGetFAQText("Pursuit.PursuitSettings"), sv = true },
				{ type = "info", text = UVGetFAQText("Pursuit.Roadblocks"), sv = true },
				{ type = "info", text = UVGetFAQText("Pursuit.Pursuitbreaker"), sv = true },
				
				{ type = "info", text = UVGetFAQText("Pursuit.JoinAsUnit") },
				{ type = "info", text = UVGetFAQText("Pursuit.Respawn") },
			},

			{ TabName = "uv.faq.other", Icon = "unitvehicles/icons_settings/info.png",
				{ type = "info", text = UVGetFAQText("Other.PursuitTech") },
				
				{ type = "info", text = UVGetFAQText("Other.CreateTraffic"), sv = true },
				{ type = "info", text = UVGetFAQText("Other.RenameAI"), sv = true },
				{ type = "info", text = UVGetFAQText("Other.DataFolder"), sv = true },
			},

			{ TabName = "uv.back", playsfx = "clickback", Prompts = { "uv.prompt.return" }, func = function()
					UVMenu.OpenMenu(UVMenu.Main)
				end,
			},
		}
	})
end

-- Credits Menu
UVMenu.Credits = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(500),
		Height = UV.ScaleH(700),
		DynamicHeight = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.credits", Icon = "unitvehicles/icons_settings/info.png",
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.Main) end
				},
				{ type = "label", text = "uv.credits.uvteam" },
				{ type = "infosimple", text = UV.Credits["UVTeam"] },
				{ type = "label", text = "uv.credits.translations" },
				{ type = "info_flags", entries = UV.Credits["Translations"] },
				{ type = "label", text = "uv.credits.contributors" },
				{ type = "info", text = UV.Credits["Contributors"] },
			},
		}
	})
end

------- [ Race Manager ] -------
UVMenu.RaceManager = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(580),
		Height = UV.ScaleH(380),
		DynamicHeight = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.rm",
				-- No track loaded, none active
				{ type = "button", text = "uv.rm.loadrace", sv = true, playsfx = "clickopen", prompts = {"uv.prompt.open.menu"},
					cond = function() return #ents.FindByClass( "uvrace_spawn" ) == 0 end,
					func = function(self2) RunConsoleCommand("uvrace_queryimport") end
				},
				
				-- Track loaded, race not started
				{ type = "button", text = "uv.rm.startrace", sv = true, playsfx = "clickopen", prompts = {"uv.prompt.open.menu"},
					cond = function() return #ents.FindByClass( "uvrace_spawn" ) > 0 and not (UVRaceStarting or UVHUDDisplayRacing) end,
					func = function(self2) UVMenu.OpenMenu(UVMenu.RaceManagerStartRace, true) end
				},
				{ type = "button", text = "uv.rm.sendinvite", sv = true, convar = "uvrace_startinvite", playsfx = "confirm", prompts = {"uv.prompt.confirm"},
					cond = function() return #ents.FindByClass( "uvrace_spawn" ) > 0 and not (UVRaceStarting or UVHUDDisplayRacing) end,
				},
				{ type = "button", text = "uv.rm.changerace", sv = true, playsfx = "clickopen", prompts = {"uv.prompt.open.menu"},
					cond = function() return #ents.FindByClass( "uvrace_spawn" ) > 0 and not (UVRaceStarting or UVHUDDisplayRacing) end,
					func = function(self2) RunConsoleCommand("uvrace_queryimport") end
				},
				{ type = "button", text = "uv.rm.cancelrace", sv = true, playsfx = "clickopen", prompts = {"uv.prompt.confirm"},
					cond = function() return #ents.FindByClass( "uvrace_spawn" ) > 0 and not (UVRaceStarting or UVHUDDisplayRacing) end,
					func = function(self2) RunConsoleCommand("uvrace_stop") UVMenu.OpenMenu(UVMenu.RaceManager) end
				},
				
				-- Race active
				{ type = "button", text = "uv.rm.stoprace", sv = true, playsfx = "clickopen", prompts = {"uv.prompt.confirm"},
					cond = function() return UVRaceStarting or UVHUDDisplayRacing end,
					func = function(self2) RunConsoleCommand("uvrace_stop") UVMenu.OpenMenu(UVMenu.RaceManager) end
				},

				-- Always active
				{ type = "button", text = "uv.rm.options", sv = true, playsfx = "clickopen", prompts = {"uv.prompt.open.menu"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.RaceManagerSettings, true) end
				},
				{ type = "button", text = "uv.back", sv = true, playsfx = "clickback", prompts = {"uv.prompt.return"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.Main) end
				},
			}
		}
	})
end

-- Race Manager, Settings
UVMenu.RaceManagerSettings = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(900),
		Height = UV.ScaleH(600),
		DynamicHeight = true,
		Description = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.rm.options",
				{ type = "slider", text = "uv.rm.options.laps", desc = "uv.rm.options.laps.desc", convar = "unitvehicle_racelaps", min = 1, max = 99, decimals = 0, sv = true },
				{ type = "slider", text = "uv.rm.options.dnftimer", desc = "uv.rm.options.dnftimer.desc", convar = "unitvehicle_racednftimer", min = 0, max = 90, decimals = 0, sv = true },
				{ type = "bool", text = "uv.rm.options.visiblecheckpoints", desc = "uv.rm.options.visiblecheckpoints.desc", convar = "unitvehicle_racevisiblecheckpoints", sv = true },
				{ type = "label", text = "uv.pursuit" },
				{ type = "slider", text = "uv.rm.options.pursuitstart", desc = "uv.rm.options.pursuitstart.desc", convar = "unitvehicle_racepursuitstart", min = 0, max = 90, decimals = 0, sv = true },
				{ type = "bool", text = "uv.rm.options.pursuitclear", desc = "uv.rm.options.pursuitclear.desc", convar = "unitvehicle_racepursuitstop", sv = true },
				{ type = "bool", text = "uv.rm.options.pursuitclear.ai", desc = "uv.rm.options.pursuitclear.ai.desc", convar = "unitvehicle_racepursuitstop_despawn", parentconvar = "unitvehicle_racepursuitstop", sv = true },
				{ type = "label", text = "uv.ai.title" },
				{ type = "bool", text = "uv.rm.options.clearai", desc = "uv.rm.options.clearai.desc", convar = "unitvehicle_raceclearai", sv = true },
				{ type = "button", text = "uv.back", sv = true, playsfx = "clickback", prompts = {"uv.prompt.return"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.RaceManager) end
				},
			}
		}
	})
end

local function extractFullRaceName( headerSplit )
	local raceName = ''
	local splitCopy = table.Copy(headerSplit)

	table.remove(splitCopy, 1)

	for _, v in ipairs(splitCopy) do
		if string.sub(v, 1, 1) == "'" then break end
		raceName = raceName .. v .. " "
	end

	return raceName
end

local function ParseRaceFile(path)
	local content = file.Read(path, "DATA")
	if not content then return nil end

	local lines = string.Split(content, "\n")
	local header = lines[1] or ""
	local params = string.Split(header, " ")
	local raceName = extractFullRaceName( params ) or "Unknown"
	local author = header:match("'(.-)'") or "Unknown"

	local checkpoints = {}
	local idList = {}
	local spawns = {}

	for _, line in ipairs(lines) do
		if string.match(line, "^%d+%s") then
			local t = string.Explode(" ", line)
			local id = tonumber(t[1])
			if id and #t >= 8 then
				if not checkpoints[id] then
					checkpoints[id] = {}
					table.insert(idList, id)
				end
				table.insert(checkpoints[id], {
					start = Vector(tonumber(t[2]), tonumber(t[3]), tonumber(t[4])),
					endp  = Vector(tonumber(t[5]), tonumber(t[6]), tonumber(t[7])),
				})
			end
		elseif string.match(line, "^spawn") then
			local t = string.Explode(" ", line)
			if #t >= 6 then
				table.insert(spawns, Vector(tonumber(t[2]), tonumber(t[3]), tonumber(t[4])))
			end
		end
	end

	table.SortByMember(idList, nil, true)
	table.sort(idList, function(a,b) return a < b end)

	return {
		filename = string.GetFileFromFilename(path),
		name = raceName:Replace("_", " "),
		author = author,
		checkpoints = checkpoints,
		idList = idList,
		spawns = spawns,
	}
end

-- Race Manager, Track Select
UVMenu.RaceManagerTrackSelect = function()
	local files = file.Find("unitvehicles/races/" .. game.GetMap() .. "/*.txt", "DATA")
	local raceEntries = {}

	for _, fname in ipairs(files) do
		local pathBase = "unitvehicles/races/" .. game.GetMap() .. "/"
		local rec = ParseRaceFile(pathBase .. fname)

		if rec then
			local descLines = {
				string.format(UVString("uv.rm.author"), rec.author),
				string.format(UVString("uv.rm.checkpoints"), #rec.checkpoints),
				string.format(UVString("uv.rm.startslots"), #rec.spawns)
			}

			-- Attempt to read matching JSON file
			local jsonName = string.Replace(fname, ".txt", ".json")
			if file.Exists(pathBase .. jsonName, "DATA") then
				local jsonData = util.JSONToTable(file.Read(pathBase .. jsonName, "DATA") or "")

				if jsonData then
					-- Count props (duplicator saves entities inside an array-style table)
					local propCount = 0

					if jsonData.Entities and istable(jsonData.Entities) then
						for _, ent in pairs(jsonData.Entities) do
							if istable(ent) and ent.Class then
								-- Optional: only count actual props
								if string.StartWith(ent.Class, "prop_") then
									propCount = propCount + 1
								end
							end
						end
					end

					if propCount > 0 then
						table.insert(descLines, string.format(UVString("uv.rm.hasprops"), propCount))
					end

					-- Count path nodes
					if jsonData.Nodes and istable(jsonData.Nodes) then
						local nodeCount = table.Count(jsonData.Nodes)
						if nodeCount > 0 then
							table.insert(descLines, string.format(UVString("uv.rm.hasnodes"), nodeCount))
						end
					end
				end
			end

			table.insert(raceEntries, {
				type = "button",
				text = rec.name,
				desc = table.concat(descLines, "\n"),
				playsfx = "clickopen",
				prompts = {"uv.prompt.load"},
				func = function()
					RunConsoleCommand("uvrace_import", rec.filename)
					UVMenu.CloseCurrentMenu(true)
					timer.Simple(tonumber(GetConVar("uvmenu_close_speed"):GetString()) or 0.2, function()
						UVMenu.OpenMenu(UVMenu.RaceManager)
						UVMenu.PlaySFX("menuopen")
					end)
				end
			})
		end
	end

	local entriesWithBack = {}
	for _, entry in ipairs(raceEntries) do
		table.insert(entriesWithBack, entry)
	end

	table.insert(entriesWithBack, { type = "button", text = "uv.back", sv = true, playsfx = "clickback", prompts = {"uv.prompt.return"}, func = function(self2)
			UVMenu.OpenMenu(UVMenu.RaceManager)
		end
	})

	UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(690),
		Height = UV.ScaleH(705),
		DynamicHeight = true,
		Description = true,
		UnfocusClose = true,
		Tabs = {
			{
				TabName = "uv.rm.loadrace",
				unpack(entriesWithBack)
			}
		}
	})
end

-- Race Manager, Start Race
UVMenu.RaceManagerStartRace = function()
	local function GetAvailableAISlots()
		local racerList = UVRace_RacerList or {}
		local spawnCount = #ents.FindByClass("uvrace_spawn") or 0
		local existingAI = #ents.FindByClass("npc_racervehicle") or 0
		local hostAdjustment = 0

		return math.max(spawnCount - (#racerList + existingAI + hostAdjustment), 0)
	end

	local function FillGridWithAI()
		local racerList = UVRace_RacerList or {}
		local spawnCount = #ents.FindByClass("uvrace_spawn") or 0
		local existingAI = #ents.FindByClass("npc_racervehicle") or 0
		local hostAdjustment = 0

		RunConsoleCommand("uvrace_startinvite")

		local neededAI = math.max(spawnCount - (#racerList + existingAI + hostAdjustment), 0)
		for i = 1, neededAI do
			RunConsoleCommand("uvrace_spawnai")
		end

		timer.Simple(0.5, function()
			RunConsoleCommand("uvrace_startinvite")
		end)

		timer.Simple(2, function()
			RunConsoleCommand("uvrace_startrace", GetConVar("unitvehicle_racelaps"):GetString())
		end)
	end

	local maxSlots = GetAvailableAISlots()
	local spawnAmountStart = math.Clamp(1, 1, maxSlots)

	local function noaibutton()
		local air = GetConVar("unitvehicle_racer_assignracers")
		local airl = GetConVar("unitvehicle_racer_racers")
		if air:GetBool() then
			if airl:GetString() == "" then return false end
		else
			local aib = GetConVar("unitvehicle_racer_vehiclebase")
			local vlistglide = file.Find("unitvehicles/glide/racers/*.json", "DATA")
			local vlistsimfphys = file.Find("unitvehicles/simfphys/racers/*.txt", "DATA")
			local vlisthl2 = file.Find("unitvehicles/prop_vehicle_jeep/racers/*.txt", "DATA")
			
			if aib:GetInt() == 3 and (vlistglide == nil or next(vlistglide) == nil) then return false end
			if aib:GetInt() == 2 and (vlistsimfphys == nil or next(vlistsimfphys) == nil) then return false end
			if aib:GetInt() == 1 and (vlisthl2 == nil or next(vlisthl2) == nil) then return false end
		end
		
		return maxSlots > 0
	end

	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(960),
		Height = UV.ScaleH(325),
		DynamicHeight = true,
		Description = true,
		UnfocusClose = true,
		Tabs = {
			{
				TabName = "uv.rm",
				{ type = "button", text = "uv.rm.startrace", desc = "uv.rm.startrace.desc", prompts = {"uv.prompt.confirm"}, sv = true,
					func = function()
						RunConsoleCommand("uvrace_startrace", GetConVar("unitvehicle_racelaps"):GetString())
						UVMenu.CloseCurrentMenu()
					end
				},
				{ type  = "buttonsw", text  = UVString("uv.rm.startrace.addai"), desc  = "uv.rm.startrace.addai.desc", sv = true, min = 1, max = maxSlots, start = spawnAmountStart,
					func = function(self2, amount)
						SpawnAI(amount, true)
						UVMenu.CloseCurrentMenu()
					end,
					cond = noaibutton
				},
				{ type = "button", text = "uv.rm.startrace.fillai", desc = string.format( UVString("uv.rm.startrace.fillai.desc"), maxSlots ), prompts = {"uv.prompt.confirm"}, sv   = true,
					func = function()
						FillGridWithAI()
						UVMenu.CloseCurrentMenu()
					end,
					cond = noaibutton
				},
				{ type = "button", text = "uv.back", sv = true, prompts = {"uv.prompt.return"}, playsfx = "clickback",
					func = function()
						UVMenu.OpenMenu(UVMenu.RaceManager)
					end
				},
			}
		}
	})
end

------- [ Pursuit Related ]-------
-- Unit Select
function UVMenu.UnitSelect(unittable, unittablename, unittablenpc)
	local menuEntries = {}

	-- Back button
	table.insert(menuEntries, {
		type = "button",
		text = "uv.back",
		playsfx = "clickback",
		prompts = {"uv.prompt.return"},
		func = function()
			UVMenu.OpenMenu(UVMenu.Main)
		end
	})

	for classIndex, unitsString in ipairs(unittable) do
		-- split units list
		local available = {}
		for unitName in string.gmatch(unitsString, "%S+") do
			table.insert(available, unitName)
		end

		if #available > 0 then
			-- Category label
			table.insert(menuEntries, {
				type = "infosimple",
				text = unittablename[classIndex],
			})

			-- Buttons for each unit
			for _, unitName in ipairs(available) do
				table.insert(menuEntries, {
					type = "button",
					text = unitName,
					prompts = {"uv.prompt.confirm"},
					func = function()
						local npcClass = unittablenpc[classIndex]
						local isRhino = (classIndex == 6)
						local cleanLabel = UVString(unittablename[classIndex])

						net.Start("UVHUDRespawnInUV")
						net.WriteString(unitName)
						net.WriteString(npcClass)
						net.WriteBool(isRhino)
						net.WriteString(cleanLabel)
						net.SendToServer()

						UVMenu.CloseCurrentMenu(true)
					end
				})
			end
		end
	end

	-- Open the menu with fully prebuilt entries
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(580),
		Height = UV.ScaleH(705),
		DynamicHeight = true,
		-- Description = true,
		UnfocusClose = false,

		Tabs = {
			{
				TabName = "uv.chase.select.menu",
				unpack(menuEntries),
			}
		}
	})
end

-- Unit Wrecked
UVMenu.WreckedDebrief = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(580),
		Height = UV.ScaleH(300),
		DynamicHeight = true,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.chase.wrecked", Icon = "unitvehicles/icons_settings/display.png",

				{ type = "infosimple", text = UVString("uv.chase.wrecked.text1") .. "\n" .. UVString("uv.chase.wrecked.text2") },
				{ type = "button", text = "uv.chase.wrecked.rejoin", playsfx = "clickopen", prompts = {"uv.prompt.open"}, func = 
				function(self2)
					net.Start("UVHUDRespawnInUVGetInfo")
					net.SendToServer()
				end
				},
				{ type = "button", text = "uv.chase.wrecked.abandon", prompts = {"uv.prompt.confirm"}, func = 
				function(self2)
					UVMenu.CloseCurrentMenu()
				end
				},
				{ type = "timer", text = "uv.results.autoclose", duration = 10, func = 
					function(self2)
						net.Start("uvrace_invite")
						net.WriteBool(false)
						net.SendToServer()
						UVMenu.CloseCurrentMenu()
					end
				},
			}
		}
	})
end

------- [ Racing Related ]-------
UVMenu.RaceInvite = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(870),
		Height = UV.ScaleH(360),
		DynamicHeight = true,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.race.invite", Icon = "unitvehicles/icons_settings/display.png",

				{ type = "infosimple", text = UVString("uv.race.invite.desc") .. "\n" .. UVString("uv.race.invite.desc2") },
				{ type = "infosimple", text = string.format( UVString("uv.race.invite.host"), UVRace_CurrentTrackHost ) .. "\n" .. string.format( UVString("uv.prerace.name"), UVRace_CurrentTrackName ) },
				{ type = "button", text = "uv.race.invite.accept", prompts = {"uv.prompt.confirm"}, func = 
				function(self2)
					net.Start("uvrace_invite")
					net.WriteBool(true)
					net.SendToServer()
					UVMenu.CloseCurrentMenu()
				end
				},
				{ type = "button", text = "uv.race.invite.decline", prompts = {"uv.prompt.close"}, func = 
				function(self2)
					net.Start("uvrace_invite")
					net.WriteBool(false)
					net.SendToServer()
					UVMenu.CloseCurrentMenu()
				end
				},
				{ type = "timer", text = "uv.race.invite.autodecline", duration = 10, func = 
					function(self2)
						net.Start("uvrace_invite")
						net.WriteBool(false)
						net.SendToServer()
						UVMenu.CloseCurrentMenu()
					end
				},
			}
		}
	})
end

------- [ Update History ] -------
local function BuildPatchNoteTabs()
    local tabs = {}
    local versions = {}

    -- Collect version keys
    for version in pairs(UV.PNotes) do
        table.insert(versions, version)
    end

    -- Sort versions (newest first)
    table.sort(versions, function(a, b)
        return a > b
    end)

    -- Build tabs
    for _, version in ipairs(versions) do
        local note = UV.PNotes[version]

        table.insert(tabs, {
            TabName = version,
            { type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"}, func = function() UVMenu.OpenMenu(UVMenu.Main) end },
            { type = "label", text = FormatPatchDate(note.Date, true) },
			
			{ type = "image", image = "unitvehicles/icons_settings/pnotes/" .. version .. ".png" },
            { type = "info", text = note.Text },
        })
    end

    return tabs
end

UVMenu.UpdateHistory = function()
    UVMenu.CurrentMenu = UVMenu:Open({
        Name = UVString("uv.unitvehicles") .. " | " .. UVString("uv.menu.updatehistory"),
        Width  = UV.ScaleW(1200),
        Height = UV.ScaleH(760),
        Description = false,
        UnfocusClose = true,
        Tabs = BuildPatchNoteTabs()
    })
end

local PresetLoadingFunctions = {
	["units"] = function(name, data)
		UVUnitManagerLoadPreset(name, data)
	end,
}

local function LoadPreset(name, presetType, data)
	if PresetLoadingFunctions[presetType] then
		PresetLoadingFunctions[presetType](name, data)
	else
		error("No preset loading function found for preset type: " .. presetType)
	end
end

local function BuildPresetTabs(preset)
	local tabs = {}
	
	for name, data in ipairs( presets.GetTable(preset) ) do
		table.insert(tabs, { type = "button", text = name, prompts = {"uv.prompt.load"}, func = function() LoadPreset(name, preset, data) end })
	end

	return tabs
end

------- [ Heat Manager ] -------
UVMenu.HeatManager = function()
    local tabs = {}

    -- Uncomment once it works
    table.insert(tabs, {
        TabName = "uv.hm.presets",
        { type = "presets", preset = "units" },
    })

    -- General settings tab
    table.insert(tabs, {
        TabName = "uv.settings.general",	
		{ type = "combo", text = "uv.tool.base.title", desc = "uv.tool.base.desc", convar = "unitvehicle_unit_vehiclebase", sv = true, content = {
				{ "uv.base.hl2", 1 } ,
				{ "uv.base.simfphys", 2 } ,
				{ "uv.base.glide", 3 } ,
			},
		},
		{ type = "bool", text = "uv.hm.timedhl", desc = "uv.hm.timedhl.desc", convar = "unitvehicle_unit_timetillnextheatenabled", sv = true },
		{ type = "slider", text = "uv.hm.minhl", desc = "uv.hm.minhl.desc", convar = "unitvehicle_unit_minheat", min = 1, max = MAX_HEAT_LEVEL, decimals = 0, sv = true },
		{ type = "slider", text = "uv.hm.maxhl", desc = "uv.hm.maxhl.desc", convar = "unitvehicle_unit_maxheat", min = 1, max = MAX_HEAT_LEVEL, decimals = 0, func = function() UVMenu.OpenMenu(UVMenu.HeatManager, true) end, sv = true },

		{ type = "label", text = "uv.hm.commander" },
		{ type = "bool", text = "uv.hm.commander.solo", desc = "uv.hm.commander.solo.desc", convar = "unitvehicle_unit_onecommander", sv = true },
		{ type = "bool", text = "uv.hm.commander.evade", desc = "uv.hm.commander.evade.desc", convar = "unitvehicle_unit_onecommanderevading", requireparentconvar = "unitvehicle_unit_onecommander", sv = true },
		{ type = "bool", text = "uv.hm.commander.norepair", desc = "uv.hm.commander.norepair.desc", convar = "unitvehicle_unit_commanderrepair", requireparentconvar = "unitvehicle_unit_onecommander", sv = true },
		{ type = "slider", text = "uv.hm.commander.health", desc = "uv.hm.commander.health.desc", convar = "unitvehicle_unit_onecommanderhealth", requireparentconvar = "unitvehicle_unit_onecommander", min = 1000, max = 10000, sv = true },
		
		{ type = "label", text = "uv.hm.air" },
		{ type = "combo", text = "uv.hm.air.model", desc = "uv.hm.air.model.desc", convar = "unitvehicle_unit_helicoptermodel", sv = true, content = {
				{ "Default", "Default" },
				{ "NFS Hot Pursuit 2", "NFS Hot Pursuit 2" },
				{ "NFS Most Wanted", "NFS Most Wanted" },
				{ "NFS Undercover", "NFS Undercover" },
				{ "NFS Hot Pursuit 2010", "NFS Hot Pursuit 2010" },
				{ "NFS No Limits", "NFS No Limits" },
				{ "NFS Rivals, Payback & Heat", "NFS Rivals, Payback & Heat" },
				{ "NFS Unbound", "NFS Unbound" },
				{ "The Crew", "The Crew" }
			},
		},
		{ type = "bool", text = "uv.hm.air.canbust", desc = "uv.hm.air.canbust.desc", convar = "unitvehicle_unit_helicopterbusting", sv = true },
		{ type = "bool", text = "uv.hm.air.pt.exp", desc = "uv.hm.air.pt.desc", convar = "unitvehicle_unit_helicopterbarrels", sv = true },
		{ type = "bool", text = "uv.hm.air.pt.spikes", desc = "uv.hm.air.pt.desc", convar = "unitvehicle_unit_helicopterspikestrip", sv = true },
						
		{ type = "label", text = "uv.ptech" },
		{ type = "bool", text = "uv.hm.enablept", desc = "uv.hm.enablept.desc", convar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.esf", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_esf", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.emp", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_emp", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.spikes", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_spikestrip", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.killswitch", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_killswitch", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.repairkit", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_repairkit", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.shockram", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_shockram", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.gpsdart", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_gpsdart", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		{ type = "bool", text = "uv.ptech.grappler", desc = "uv.hm.pt.spawnwith.desc", convar = "unitvehicle_unit_pursuittech_grappler", requireparentconvar = "unitvehicle_unit_pursuittech", sv = true },
		
		{ type = "label", text = "uv.hm.disablebounty" },
		{ type = "slider", text = "uv.unit.patrol", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountypatrol", min = 1, max = 9999999, decimals = 0, sv = true },
		{ type = "slider", text = "uv.unit.support", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountysupport", min = 1, max = 9999999, decimals = 0, sv = true },
		{ type = "slider", text = "uv.unit.pursuit", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountypursuit", min = 1, max = 9999999, decimals = 0, sv = true },
		{ type = "slider", text = "uv.unit.interceptor", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountyinterceptor", min = 1, max = 9999999, decimals = 0, sv = true },
		{ type = "slider", text = "uv.unit.special", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountyspecial", min = 1, max = 9999999, decimals = 0, sv = true },
		{ type = "slider", text = "uv.unit.commander", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountycommander", min = 1, max = 9999999, decimals = 0, sv = true },
		{ type = "slider", text = "uv.unit.rhino", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountyrhino", min = 1, max = 9999999, decimals = 0, sv = true },
		{ type = "slider", text = "uv.unit.helicopter", desc = "uv.hm.disablebounty.desc", convar = "unitvehicle_unit_bountyair", min = 1, max = 9999999, decimals = 0, sv = true },
    })

    -- Voice profile tab
    table.insert(tabs, {
        TabName = "uv.hm.vp",
        { type = "voiceprofile", text = "uv.unit.dispatch", desc = "uv.hm.vp.dispatch.desc", profilevar = "unitvehicle_unit_dispatch_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.misc", desc = "uv.hm.vp.misc.desc", profilevar = "unitvehicle_unit_misc_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.patrol", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_patrol_voice", profilevar = "unitvehicle_unit_patrol_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.support", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_support_voice", profilevar = "unitvehicle_unit_support_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.pursuit", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_pursuit_voice", profilevar = "unitvehicle_unit_pursuit_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.interceptor", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_interceptor_voice", profilevar = "unitvehicle_unit_interceptor_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.special", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_special_voice", profilevar = "unitvehicle_unit_special_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.commander", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_commander_voice", profilevar = "unitvehicle_unit_commander_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.rhino", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_rhino_voice", profilevar = "unitvehicle_unit_rhino_voiceprofile", sv = true },
        { type = "voiceprofile", text = "uv.unit.helicopter", desc = "uv.hm.vp.desc", voicevar = "unitvehicle_unit_air_voice", profilevar = "unitvehicle_unit_air_voiceprofile", sv = true },
    })

    -- Dynamic heat level tabs
	for i = 1, GetConVar("unitvehicle_unit_maxheat"):GetInt() or MAX_HEAT_LEVEL do
		local heatTab = {
			TabName = string.format(UVString("uv.hm.lvl"), i),
			{ type = "label", text = "uv.hm.heat" },
			{ type = "slider", text = "uv.hm.heat.bounty.10s", desc = "uv.hm.heat.bounty.10s.desc", convar = "unitvehicle_unit_bountytime" .. i, min = 0, max = 10000000, decimals = 0, sv = true },
		}

		if i <= 9 then
			table.insert(heatTab, { type = "slider", text = "uv.hm.heat.heatlvl.time", desc = "uv.hm.heat.heatlvl.time.desc", convar = "unitvehicle_unit_timetillnextheat" .. i, min = 20, max = 600, decimals = 0, sv = true })
		end

		table.insert(heatTab, { type = "slider", text = "uv.hm.heat.minbounty", desc = "uv.hm.heat.minbounty.desc", convar = "unitvehicle_unit_heatminimumbounty" .. i, min = 1, max = 999999999, decimals = 0, sv = true })
		table.insert(heatTab, { type = "slider", text = "uv.hm.heat.maxunits", desc = "uv.hm.heat.maxunits.desc", convar = "unitvehicle_unit_maxunits" .. i, min = 1, max = 40, decimals = 0, sv = true })
		table.insert(heatTab, { type = "slider", text = "uv.hm.heat.avaunits", desc = "uv.hm.heat.avaunits.desc", convar = "unitvehicle_unit_unitsavailable" .. i, min = 1, max = 1000, decimals = 0, sv = true })
		table.insert(heatTab, { type = "slider", text = "uv.hm.heat.backuptime", desc = "uv.hm.heat.backuptime.desc", convar = "unitvehicle_unit_backuptimer" .. i, min = 1, max = 600, decimals = 0, sv = true })
		table.insert(heatTab, { type = "slider", text = "uv.hm.heat.bustspeed", desc = "uv.hm.heat.bustspeed.desc", convar = "unitvehicle_unit_bustspeed" .. i, min = 1, max = 200, decimals = 0, sv = true })
		table.insert(heatTab, { type = "slider", text = "uv.hm.heat.cooldowntime", desc = "uv.hm.heat.cooldowntime.desc", convar = "unitvehicle_unit_cooldowntimer" .. i, min = 1, max = 600, decimals = 0, sv = true })
		table.insert(heatTab, { type = "bool", text = "uv.hm.heat.roadblocks", desc = "uv.hm.heat.roadblocks.desc", convar = "unitvehicle_unit_roadblocks" .. i, sv = true })
		table.insert(heatTab, { type = "bool", text = "uv.hm.heat.helicopter", desc = "uv.hm.heat.helicopter.desc", convar = "unitvehicle_unit_helicopters" .. i, sv = true })

		table.insert(heatTab, { type = "label", text = "uv.hm.units" })

		local units = { "Patrol", "Support", "Pursuit", "Interceptor", "Special", "Commander", "Rhino" }
		for _, unit in ipairs(units) do
			local lower = string.lower(unit)
			table.insert(heatTab, { type = "unitselect", text = "uv.unit." .. lower, convar = "unitvehicle_unit_units" .. lower .. i, sv = true })
			table.insert(heatTab, { type = "slider", text = "uv.hm.units.spawnchance", desc = "uv.hm.units.spawnchance.desc", convar = "unitvehicle_unit_units" .. lower .. i .. "_chance", min = 0, max = 100, decimals = 0, sv = true })
			table.insert(heatTab, { type = "slider", text = "uv.hm.units.limit", desc = "uv.hm.units.limit.desc", convar = "unitvehicle_unit_units" .. lower .. i .. "_limit", min = -1, max = 20, decimals = 0, sv = true })
		end

		table.insert(tabs, heatTab)
	end

    table.insert(tabs, {
        TabName = "uv.back",
        playsfx = "clickback",
		Prompts = { "uv.prompt.return" },
        func = function()
            UVMenu.OpenMenu(UVMenu.Main)
        end,
    })

    UVMenu.CurrentMenu = UVMenu:Open({
        Name = UVString("uv.unitvehicles") .. " | " .. UVString("uv.hm"),
        Width  = UV.ScaleW(1540),
        Height = UV.ScaleH(760),
        Description = true,
        UnfocusClose = true,
        Tabs = tabs
    })
end

------- [ First-Time Setup ] -------
UVMenu.FirstTimeSetup = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1200),
		Height = UV.ScaleH(1200),
		DynamicHeight = true,
		Description = false,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.ft.title", Icon = "unitvehicles/icons/generic_alert.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.ft.desc" },
				{ type = "button", text = "uv.ft.next", playsfx = "confirm", prompts = {"uv.prompt.confirm"}, func = function(self2) 
					if LocalPlayer():IsAdmin() and LocalPlayer():IsSuperAdmin() then
						UVMenu.OpenMenu(UVMenu.FirstTimeSetupPreset, true)
					else
						UVMenu.OpenMenu(UVMenu.FirstTimeSetupRacing, true)
					end
				end},
			}
		}
	})
end

UVMenu.FirstTimeSetupPreset = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(900),
		Height = UV.ScaleH(600),
		DynamicHeight = true,
		Description = false,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.ft.preset.title", Icon = "unitvehicles/icons/milestone_911.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.ft.preset.desc" },
				{ type = "info", text = "uv.ft.preset.desc2" },
				{ type = "presets", preset = "units", importonly = true, func = function(self2, name, preset)
					UVUnitManagerLoadPresetV2(name, preset)
					UVMenu.PlaySFX("confirm")
					UVMenu.CloseCurrentMenu(true)
					timer.Simple(tonumber(GetConVar("uvmenu_close_speed"):GetString()) or 0.2, function()
						UVMenu.PlaySFX("menuopen") -- This shouldn't be necessary but ah well
						UVMenu.OpenMenu(UVMenu.FirstTimeSetupBases, true)
					end)
				end },
				
				{ type = "button", text = "uv.ft.skip", playsfx = "confirm", prompts = {"uv.prompt.confirm"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupBases, true) end
				},
			}
		}
	})
end

UVMenu.FirstTimeSetupBases = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(800),
		Height = UV.ScaleH(900),
		DynamicHeight = true,
		Description = false,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.ft.bases", Icon = "unitvehicles/icons/race_events.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.ft.bases.desc" },
				{ type = "combo", text = "uv.ft.bases.units", desc = "uv.tool.base.desc", convar = "unitvehicle_unit_vehiclebase", sv = true, content = {
						{ "uv.base.hl2", 1 } ,
						{ "uv.base.simfphys", 2 } ,
						{ "uv.base.glide", 3 } ,
					},
				},
				{ type = "combo", text = "uv.ft.bases.airacer", desc = "uv.tool.base.desc", convar = "unitvehicle_racer_vehiclebase", sv = true, content = {
						{ "uv.base.hl2", 1 } ,
						{ "uv.base.simfphys", 2 } ,
						{ "uv.base.glide", 3 } ,
					},
				},
				{ type = "combo", text = "uv.ft.bases.traffic", desc = "uv.tool.base.desc", convar = "unitvehicle_traffic_vehiclebase", sv = true, content = {
						{ "uv.base.hl2", 1 } ,
						{ "uv.base.simfphys", 2 } ,
						{ "uv.base.glide", 3 } ,
					},
				},
				{ type = "buttonlr", text = "uv.ft.prev", text2 = "uv.ft.next", playsfx = "confirm", prompts = {"uv.prompt.confirm"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupPreset, true) end,
					func2 = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupGeneral, true) end,
				},
			}
		}
	})
end

UVMenu.FirstTimeSetupGeneral = function()
	local mainHUDList, backupHUDList = BuildHUDComboLists()

	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1300),
		Height = UV.ScaleH(900),
		DynamicHeight = true,
		Description = true,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.settings.general", Icon = "unitvehicles/icons_settings/options.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.ft.general.desc" },
				
				{ type = "combo", text = "uv.ui.main", desc = "uv.ui.main.desc", convar = "unitvehicle_hudtype_main", content = mainHUDList },
				{ type = "bool", text = "uv.audio.uvtrax.enable", desc = "uv.audio.uvtrax.desc", convar = "unitvehicle_racingmusic" },
				{ type = "combo", text = "uv.audio.uvtrax.profile", desc = "uv.audio.uvtrax.profile.desc", convar = "unitvehicle_racetheme", requireparentconvar = "unitvehicle_racingmusic" },
				{ type = "bool", text = "uv.response.enable", desc = "uv.response.enable.desc", convar = "unitvehicle_callresponse", sv = true },
				
				{ type = "infosimple", text = " " },
				{ type = "buttonlr", text = "uv.ft.prev", text2 = "uv.ft.next", playsfx = "confirm", prompts = {"uv.prompt.confirm"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupBases, true) end,
					func2 = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupRacing, true) end,
				},
			}
		}
	})
end

UVMenu.FirstTimeSetupRacing = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1300),
		Height = UV.ScaleH(900),
		DynamicHeight = true,
		Description = true,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.rm.options", Icon = "unitvehicles/icons/race_events.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.ft.racing.desc" },
				{ type = "info", text = "uv.ft.racing.desc2" },
				{ type = "label", text = "uv.rm.options" },
				{ type = "slider", text = "uv.rm.options.laps", desc = "uv.rm.options.laps.desc", convar = "unitvehicle_racelaps", min = 1, max = 99, decimals = 0, sv = true },
				{ type = "slider", text = "uv.rm.options.dnftimer", desc = "uv.rm.options.dnftimer.desc", convar = "unitvehicle_racednftimer", min = 0, max = 90, decimals = 0, sv = true },
				{ type = "label", text = "uv.pursuit" },
				{ type = "slider", text = "uv.rm.options.pursuitstart", desc = "uv.rm.options.pursuitstart.desc", convar = "unitvehicle_racepursuitstart", min = 0, max = 90, decimals = 0, sv = true },
				{ type = "bool", text = "uv.rm.options.pursuitclear", desc = "uv.rm.options.pursuitclear.desc", convar = "unitvehicle_racepursuitstop", sv = true },
				{ type = "bool", text = "uv.rm.options.pursuitclear.ai", desc = "uv.rm.options.pursuitclear.ai.desc", convar = "unitvehicle_racepursuitstop_despawn", parentconvar = "unitvehicle_racepursuitstop", sv = true },
				{ type = "label", text = "uv.ai.title" },
				{ type = "bool", text = "uv.rm.options.clearai", desc = "uv.rm.options.clearai.desc", convar = "unitvehicle_raceclearai", sv = true },
				
				{ type = "infosimple", text = " " },
				{ type = "buttonlr", text = "uv.ft.prev", text2 = "uv.ft.next", playsfx = "confirm", prompts = {"uv.prompt.confirm"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupGeneral, true) end,
					func2 = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupRacingAI, true) end,
				},
			}
		}
	})
end

UVMenu.FirstTimeSetupRacingAI = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1300),
		Height = UV.ScaleH(700),
		DynamicHeight = false,
		Description = true,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.ft.racing.ai.title", Icon = "unitvehicles/icons/race_events.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.ft.racing.ai.desc" },
				{ type = "info", text = "uv.ft.racing.ai.desc2" },

				{ type = "bool", text = "uv.airacer.override", desc = "uv.airacer.override.desc", convar = "unitvehicle_racer_assignracers", sv = true },
				{ type = "vehicleoverride", text = "uv.airacer.overridelist", desc = "uv.airacer.overridelist.desc", convar = "unitvehicle_racer_racers", sv = true, parentconvar = "unitvehicle_racer_assignracers" },
				
				{ type = "infosimple", text = " " },
				{ type = "buttonlr", text = "uv.ft.prev", text2 = "uv.ft.next", playsfx = "confirm", prompts = {"uv.prompt.confirm"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupRacing, true) end,
					func2 = function(self2) UVMenu.OpenMenu(UVMenu.FirstTimeSetupDone, true) end,
				},
			}
		}
	})
end

UVMenu.FirstTimeSetupDone = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(800),
		Height = UV.ScaleH(450),
		DynamicHeight = false,
		Description = false,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.ft.end.title", Icon = "unitvehicles/icons/milestone_outrun_pursuits_won.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.ft.end.desc" },
				{ type = "info", text = "uv.ft.end.desc2" },
				
				{ type = "buttonlr", text = "uv.tweakinmenu.open", text2 = "uv.ft.finish", playsfx = "confirm", prompts = {"uv.prompt.confirm"},
					func = function(self2)
						UVMenu.OpenMenu(UVMenu.Main)
						net.Start("UVUpdateSettings")
						net.WriteTable({ ["unitvehicle_uvmenu_firstsetup"] = "0" })
						net.SendToServer()
					end,
					func2 = function(self2)
						UVMenu.CloseCurrentMenu()
						net.Start("UVUpdateSettings")
						net.WriteTable({ ["unitvehicle_uvmenu_firstsetup"] = "0" })
						net.SendToServer()
					end
				},
			}
		}
	})
end


------- [ DV Warning ] -------
UVMenu.DVWarning = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(900),
		Height = UV.ScaleH(800),
		DynamicHeight = true,
		Description = false,
		UnfocusClose = false,
		HideCloseButton = true,
		Tabs = {
			{ TabName = "uv.hm.presets.warning", Icon = "unitvehicles/icons/generic_alert.png", ShowIcon = true,
				{ type = "infosimple", text = "uv.system.dvnowp" },
				{ type = "info", text = "uv.system.dvnowp2" },
				{ type = "button", text = "close", playsfx = "clickback", prompts = {"uv.prompt.confirm"}, func = function(self2) UVMenu.CloseCurrentMenu(true) end
				},
			}
		}
	})
end

net.Receive("UV_OpenDVWarning", function()
    UVMenu.OpenMenu(UVMenu.DVWarning, true)
end)