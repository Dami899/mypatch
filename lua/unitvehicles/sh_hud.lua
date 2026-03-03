UV = UV or {}

UV.Tips = UV.Tips or {}

UV.Tips.Racer = {
	-- General Pursuit Tech
	"uv.tip.pt.emp1",
	"uv.tip.pt.esf1",
	"uv.tip.pt.repairkit1",
	
	-- Racer-specific Pursuit Tech
	"uv.tip.racer.pt.jammer1",
	"uv.tip.racer.pt.jammer2",
	"uv.tip.racer.pt.shockwave1",
	"uv.tip.racer.pt.stunmine1",
	"uv.tip.racer.pt.powerplay1",
	"uv.tip.racer.pt.juggernaut1",
	"uv.tip.racer.pt.ghost1",

	-- General Racer-specific
	"uv.tip.racer.cooldown",
	"uv.tip.racer.aitactics1",
	"uv.tip.racer.aitactics2",
	"uv.tip.racer.pb",
	"uv.tip.racer.comunits1",
	"uv.tip.racer.comunits2",
	"uv.tip.racer.airunits1",
	"uv.tip.racer.leastagro",
	"uv.tip.racer.spikes",
	"uv.tip.racer.roadblocks",
	"uv.tip.racer.boxedin",
	"uv.tip.racer.upgradedunits",
	"uv.tip.racer.stuck",
}

UV.Tips.Units = {
	-- General Pursuit Tech
	"uv.tip.pt.emp1",
	"uv.tip.pt.esf1",
	"uv.tip.pt.repairkit1",
	
	-- Unit-specific Pursuit Tech
	"uv.tip.unit.pt.killswitch1",
    "uv.tip.unit.pt.spikes1",
    "uv.tip.unit.pt.shockram1",
    "uv.tip.unit.pt.gpsdart1",
    "uv.tip.unit.pt.grappler1",
	
	-- General Unit-specific
	"uv.tip.unit.pit",
	"uv.tip.unit.teamwork",
	"uv.tip.unit.roadblocks",
	"uv.tip.unit.loneunit",
	"uv.tip.unit.comunit",
	"uv.tip.unit.nocooldown",
	"uv.tip.unit.respawn",
}

UVColors = {
    -- Original HUD
    ["Original_LocalPlayer"] = Color(255, 217, 0),
    ["Original_Others"] = Color(255, 255, 255),
    ["Original_Disqualified"] = Color(255, 50, 50, 133),
	
	-- Most Wanted HUD
    ["MW_LocalPlayer"] = Color(223, 184, 127), --Color(255, 187, 0),
    ["MW_Accent"] = Color(223, 184, 127),
    ["MW_Others"] = Color(255, 255, 255),
    ["MW_Disqualified"] = Color(255, 50, 50, 133),
    ["MW_Cop"] = Color(61, 184, 255, 107),
    ["MW_CopShade"] = Color(41, 149, 212, 107),
    ["MW_Racer"] = Color(255, 221, 142, 107),
    ["MW_RacerShade"] = Color(166, 142, 85, 107),
	
    -- Carbon HUD
    ["Carbon_Accent"] = Color(86, 214, 205),
    ["Carbon_AccentTransparent"] = Color(86, 214, 205, 50),
    ["Carbon_AccentDarker"] = Color(62, 153, 145),
    ["Carbon_Accent2"] = Color(168, 168, 168),
    ["Carbon_Accent2Bright"] = Color(189, 189, 189),
    ["Carbon_Accent2Transparent"] = Color(168, 168, 168, 100),
    ["Carbon_LocalPlayer"] = Color(86, 214, 205),
    ["Carbon_Others"] = Color(255, 255, 255),
    ["Carbon_OthersDark"] = Color(255, 255, 255, 121),
    ["Carbon_Disqualified"] = Color(255, 50, 50, 133),
	
    -- Undercover HUD
    ["Undercover_Accent1"] = Color(255, 255, 255),
    ["Undercover_Accent2"] = Color(187, 226, 220),
    ["Undercover_Accent2Transparent"] = Color(187, 226, 220, 150)
}

UVMaterials = {
    ["RACE_COUNTDOWN_BG"] = Material("unitvehicles/hud/COUNTDOWN_BG.png"),
    ["RESPAWN_BG"] = Material("unitvehicles/hud/RESPAWN_BG.png"),
    ["PT_BG"] = Material("unitvehicles/hud/PT_BG.png"),
    ["SCREENFLASH"] = Material("unitvehicles/hud/SCREENFLASH.png"),
    ["SCREENFLASH_SMALL"] = Material("unitvehicles/hud/SCREENFLASH_SMALL.png"),
	
    ["PT_LEFT"] = Material("unitvehicles/hud/PTLeft.png"),
    ["PT_RIGHT"] = Material("unitvehicles/hud/PTRight.png"),
    ["PT_LEFT_BG"] = Material("unitvehicles/hud/PTLeftBG.png"),
    ["PT_RIGHT_BG"] = Material("unitvehicles/hud/PTRightBG.png"),
    
    ["GLOW_ICON"] = Material("unitvehicles/icons/CIRCLE_GLOW_LIGHT.png"),
    ["UNITS_DAMAGED"] = Material("unitvehicles/icons/COPS_DAMAGED_ICON.png"),
    ["UNITS_DISABLED"] = Material("unitvehicles/icons/COPS_TAKENOUT_ICON.png"),
    ["UNITS"] = Material("unitvehicles/icons/COPS_ICON.png"),
    ["HEAT"] = Material("unitvehicles/icons/HEAT_ICON.png"),
    ["CLOCK"] = Material("unitvehicles/icons/TIMER_ICON.png"),
    ["CLOCK_BG"] = Material("unitvehicles/icons/TIMER_ICON_BG.png", "smooth mips"),
    ["CHECK"] = Material("unitvehicles/icons/MINIMAP_ICON_CIRCUIT.png"),
    ["RESULTCOP"] = Material("unitvehicles/icons/(9)T_UI_PlayerCop_Large_Icon.png"),
    ["RESULTRACE"] = Material("unitvehicles/icons/INGAME_ICON_LEADERBOARD.png"),
    ["HIDECAR"] = Material("unitvehicles/icons/HIDE_CAR_ICON.png"),
    ["PBREAKER"] = Material("unitvehicles/icons/MINIMAP_ICON_PURSUIT_BREAKER.png"),
    ["PBREAKER3D"] = Material("unitvehicles/icons/WORLD_PURSUITBREAKER.png"),
    
    ["RACE_BG_POS"] = Material("unitvehicles/hud/POSITION_BACKING.png"),
    ["RACE_BG_TIME"] = Material("unitvehicles/hud/TIME_BACKING.png"),
    
    ["PURSUIT_BG_TOP"] = Material("unitvehicles/hud/PURSUIT_BACKING_TOP.png"),
    ["PURSUIT_BG_BOTTOM"] = Material("unitvehicles/hud/PURSUIT_BACKING_BOTTOM.png"),
    ["PURSUIT_BG_PULSE"] = Material("unitvehicles/hud/PURSUIT_LEADERLIST_PULSE.png"),
    
    ["PURSUIT_BG_BOTBAR"] = Material("unitvehicles/hud/OUTRUN_BACKING.png"),
    ["PURSUIT_BG_BOTBAR_ALT"] = Material("unitvehicles/hud/OUTRUN_BACKING_ALT.png"),
    
    ["BACKGROUND"] = Material("unitvehicles/hud/NFSMW_BACKGROUND.png"),
    ["BACKGROUND_BIG"] = Material("unitvehicles/hud/NFSMW_BACKGROUND_BIG.png"),
    ["BACKGROUND_BIGGER"] = Material("unitvehicles/hud/NFSMW_BACKGROUND_BIGGER.png"),
	
    ["SCANNER_BG"] = Material("unitvehicles/hud/RADAR_BACKING.png"),
    ["SCANNER_MIDDLE"] = Material("unitvehicles/hud/RADAR_ICON.png"),
    ["SCANNER_ARROW"] = Material("unitvehicles/hud/RADAR_DIRECTIONARROW.png"),
	
    ["SCANNER_LEDS_BG"] = Material("unitvehicles/hud/RADAR_LEDS.png"),
    ["SCANNER_LEDS_BG_INV"] = Material("unitvehicles/hud/RADAR_LEDS_INV.png"),
    
    ["SCANNER_LEDS"] = Material("unitvehicles/hud/RADAR_LEDS_COLOR.png"),
    ["SCANNER_LEDS_INV"] = Material("unitvehicles/hud/RADAR_LEDS_COLOR_INV.png"),
    
    -- Carbon
    ["TAKEDOWN_CIRCLE_CARBON"] = Material("unitvehicles/icons_carbon/FULL_CIRCLE.png"),
    ["TAKEDOWN_RING_CARBON"] = Material("unitvehicles/icons_carbon/FULL_CIRCLE_RING.png"),
    
    ["UNITS_DISABLED_CARBON"] = Material("unitvehicles/icons_carbon/COPS_DESTROYED.png"),
    ["UNITS_CARBON"] = Material("unitvehicles/icons_carbon/COPS_INVOLVED.png"),
    ["HEAT_CARBON"] = Material("unitvehicles/icons_carbon/FLASHER_ICON_HEAT.png"),
	
    ["SPLITTIME_CARBON"] = Material("unitvehicles/icons_carbon/FLASHER_ICON_SPLITTIME.png"),
    
    ["ARROW_CARBON"] = Material("unitvehicles/hud_carbon/NFSC_ARROWRIGHT.png"),
    ["BACKGROUND_CARBON"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT.png"),
    ["BACKGROUND_CARBON_INVERTED"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT_INV.png"),
    ["BACKGROUND_CARBON_SMALL"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT_SMALL.png"),
    ["BACKGROUND_CARBON_SMALL_INVERTED"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT_SMALL_INV.png"),
    ["BACKGROUND_CARBON_SOLID"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT_SOLID.png"),
    ["BACKGROUND_CARBON_SOLID_INVERTED"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT_SOLID_INV.png"),
    
    ["BACKGROUND_CARBON_FILLED"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT_FILLED.png"),
    ["BACKGROUND_CARBON_FILLED_INVERTED"] = Material("unitvehicles/hud_carbon/NFSC_GRADIENT_FILLED_INV.png"),
    
    ["BAR_CARBON_FILLED"] = Material("unitvehicles/hud_carbon/HUD_GENERIC_METER_COLOR.png"),
    ["BAR_CARBON_FILLED_INVERTED"] = Material("unitvehicles/hud_carbon/HUD_GENERIC_METER_COLOR_INV.png"),
	
    ["BAR_CARBON_FILLED_MIDDLE"] = Material("unitvehicles/hud_carbon/HUD_GENERIC_METER_COLOR_CENTER.png"),
    ["BAR_CARBON_FILLED_COOLDOWN"] = Material("unitvehicles/hud_carbon/HUD_COOLDOWN_METER_COLOR.png"),
    
    ["X_OUTER_CARBON"] = Material("unitvehicles/hud_carbon/SHAPE_INGAME_OUTLINE.png"),
    ["EOC_FRAME_CARBON"] = Material("unitvehicles/hud_carbon/PC_HELP_FRAME_LONG.png"),
    
    ["BG_BIG_CARBON"] = Material("unitvehicles/hud_carbon/NFSC_BG_BIG.png"),
    
    -- Undercover
    ["ARREST_BG_UC"] = Material("unitvehicles/hud_undercover/BUSTED_HEADER.png"),
    ["ARREST_LIGHT_UC"] = Material("unitvehicles/hud_undercover/BUSTED_COPLIGHT_BG.png"),
    
    ["UNITS_DISABLED_UC"] = Material("unitvehicles/icons_undercover/HUD_COP_TAKEDOWN_ICON.png"),
    ["CTS_UC"] = Material("unitvehicles/icons_undercover/HUD_CTS_ICON.png"),
    
    ["BUSTED_ICON_UC"] = Material("unitvehicles/icons_undercover/BUST_COP_ICON.png", "smooth mips"),
    ["BUSTED_ICON_UC_GLOW"] = Material("unitvehicles/icons_undercover/BUSTED_ICON_GLOW.png", "smooth mips"),
    ["EVADE_ICON_UC"] = Material("unitvehicles/icons_undercover/EVADE_CAR_ICON.png", "smooth mips"),
    ["EVADE_ICON_UC_GLOW"] = Material("unitvehicles/icons_undercover/EVADE_ICON_GLOW.png", "smooth mips"),
    
    -- Underground 2
    ["RACE_BG_UPPER_UG2"] = Material("unitvehicles/hud_underground2/3RDPERSON_BOXCORNER.png"),
    ["RACE_BG_LAP_UG2"] = Material("unitvehicles/hud_underground2/3RDPERSON_BOXLAPS.png"),
    ["RACE_BG_TIME_UG2"] = Material("unitvehicles/hud_underground2/3RDPERSON_BOXTIME.png"),
    ["RACE_BG_TIME_UG2_ALT"] = Material("unitvehicles/hud_underground2/3RDPERSON_BOXTIME2.png"),
    
    ["RESULTS_UG2_BG"] = Material("unitvehicles/hud_underground2/results_bg_bg.png"),
    ["RESULTS_UG2_SHINE"] = Material("unitvehicles/hud_underground2/results_bg_shine.png"),
    ["RESULTS_UG2_LP"] = Material("unitvehicles/hud_underground2/results_bg_lp.png"),
    ["RESULTS_UG2_BUTTON"] = Material("unitvehicles/hud_underground2/UI_PC_GENERIC_BUTTON.png"),
    
    -- ProStreet
    ["RESULTS_PS_CURVES"] = Material("unitvehicles/icons_prostreet/curves.png"),
    ["RESULTS_PS_HUB"] = Material("unitvehicles/icons_prostreet/hub_44.png"),
    ["RESULTS_PS_WING"] = Material("unitvehicles/icons_prostreet/flixfx_wing.png"),
    ["RESULTS_PS_WING_INV"] = Material("unitvehicles/icons_prostreet/flixfx_wing_inv.png"),
    ["RESULTS_PS_SP8"] = Material("unitvehicles/icons_prostreet/flixfx_sp8.png"),
    ["RACE_FLAG_PS"] = Material("unitvehicles/icons_prostreet/flag.png"),
    
	-- World
	["RACE_CDBG_LEFT_WORLD"] = Material("unitvehicles/hud_world/race_starter_bg_left.png"),
	["RACE_CDBG_RIGHT_WORLD"] = Material("unitvehicles/hud_world/race_starter_bg_right.png"),
	
	["RACE_PLAYERMARKER_WORLD"] = Material("unitvehicles/hud_world/race_playerarrow.png"),
	["RACE_DNFMARKER_WORLD"] = Material("unitvehicles/hud_world/race_playerdnf.png"),
	["RACE_BUSTEDMARKER_WORLD"] = Material("unitvehicles/hud_world/race_playerbusted.png"),
	["CTS_WORLD"] = Material("unitvehicles/hud_world/pursuit_cts.png"),
	
	["WARNING_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_warning.png"),
	["WARNINGBG_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_centernoti_bg.png"),
	["COOLDOWNBG_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_centernoti_bg_blue.png"),
	["UNIT_WORLD"] = Material("unitvehicles/hud_world/pursuit_policecar.png"),
	["UNIT_DMG_WORLD"] = Material("unitvehicles/hud_world/pursuit_policecar_dmg.png"),
	["UNIT_DMG_WORLD_LIT"] = Material("unitvehicles/hud_world/pursuit_policecar_dmg_red.png"),
	["UNIT_CROSS_WORLD"] = Material("unitvehicles/hud_world/pursuit_policecarcross.png"),
	["UNIT_CROSS_WORLD_LIT"] = Material("unitvehicles/hud_world/pursuit_policecarcross_lit.png"),
	
	["CHASEBAR_LEFT_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_left.png"),
	["CHASEBAR_RIGHT_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_right.png"),
	
	["CHASEBAR_ARROW_LEFT_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_arrow_left.png"),
	["CHASEBAR_ARROW_RIGHT_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_arrow_right.png"),
	
	["CHASEBAR_CAR_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_escapecar.png"),
	["CHASEBAR_COP_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_copcar.png"),
	["CHASEBAR_COOLDOWN_WORLD"] = Material("unitvehicles/hud_world/pursuitbar_cooldown.png"),
	
	["RESULTSBG_WORLD"] = Material("unitvehicles/hud_world/result/result_bg.png"),
	
	["LOADING_WORLD_L"] = Material("unitvehicles/hud_world/result/loading_left.png"),
	["LOADING_WORLD_R"] = Material("unitvehicles/hud_world/result/loading_right.png"),
	["LOADING_WORLD_SHINE1"] = Material("unitvehicles/hud_world/result/loading_shine1.png"),
	["LOADING_WORLD_SHINE2"] = Material("unitvehicles/hud_world/result/loading_shine2.png"),
	["LOADING_WORLD_SHINE3"] = Material("unitvehicles/hud_world/result/loading_shine3.png"),
	
	["RESULTS_1ST_WORLD"] = Material("unitvehicles/hud_world/result/result_1st.png"),
	["RESULTS_2ND_WORLD"] = Material("unitvehicles/hud_world/result/result_2nd.png"),
	["RESULTS_3RD_WORLD"] = Material("unitvehicles/hud_world/result/result_3rd.png"),
	["RESULTS_4TH_WORLD"] = Material("unitvehicles/hud_world/result/result_4th.png"),
	
	["RESULTS_1ST_BANNER_WORLD"] = Material("unitvehicles/hud_world/result/result_banner_1st.png"),
	["RESULTS_2ND_BANNER_WORLD"] = Material("unitvehicles/hud_world/result/result_banner_2nd.png"),
	["RESULTS_3RD_BANNER_WORLD"] = Material("unitvehicles/hud_world/result/result_banner_3rd.png"),
	["RESULTS_4TH_BANNER_WORLD"] = Material("unitvehicles/hud_world/result/result_banner_4th.png"),
	
	["RESULTS_NEXTBTN_WORLD"] = Material("unitvehicles/hud_world/result/nextbutton.png"),
	["RESULTS_NEXTBTN_GLOW_WORLD"] = Material("unitvehicles/hud_world/result/nextbutton_glowing.png"),
	["RESULTS_NEXTBTN_INACTIVE_WORLD"] = Material("unitvehicles/hud_world/result/nextbutton_inactive.png"),
	
	["RESULTS_BANNER_ESCAPED"] = Material("unitvehicles/hud_world/result/result_banner_escaped.png"),
	["RESULTS_BANNER_BUSTED"] = Material("unitvehicles/hud_world/result/result_banner_busted.png"),
	
	["RESULTS_SHEEN_ESCAPED"] = Material("unitvehicles/hud_world/result/result_sheen_blue.png"),
	["RESULTS_SHEEN_BUSTED"] = Material("unitvehicles/hud_world/result/result_sheen_red.png"),
	    
    -- Crash Time - Undercover
    ["HUD_CTU_LEFT"] = Material("unitvehicles/hud_ctu/hud_left.png"),
    ["HUD_CTU_LEFT_BG"] = Material("unitvehicles/hud_ctu/hud_left_bg.png"),
    ["HUD_CTU_RIGHT"] = Material("unitvehicles/hud_ctu/hud_right.png"),
    ["HUD_CTU_RIGHT_BG"] = Material("unitvehicles/hud_ctu/hud_right_bg.png"),
	
    ["HUD_CTU_GRADIENT_UP"] = Material("unitvehicles/hud_ctu/PauseGradient.png"),
    ["HUD_CTU_GRADIENT_DOWN"] = Material("unitvehicles/hud_ctu/PauseGradientBottom.png"),
    ["HUD_CTU_BAR"] = Material("unitvehicles/hud_ctu/OrangeTickerBar.png"),
    ["HUD_CTU_ENDBOX"] = Material("unitvehicles/hud_ctu/Endbox.png"),
    ["HUD_CTU_FOCUSBAR"] = Material("unitvehicles/hud_ctu/FocusBar.png"),
    ["HUD_CTU_FOCUSBARBLACK"] = Material("unitvehicles/hud_ctu/FocusBarBlack.png"),
}

UV_UI_Events = {
    ['Wrecks'] = 'onUnitWreck',
    ['Deploys'] = 'onUnitDeploy',
    ['Tags'] = 'onUnitTag',
    ['ResourcePoints'] = 'onResourceChange',
    ['UnitsChasing'] = 'onChasingUnitsChange',
    ['Heat'] = 'onHeatLevelUpdate',
}

function UVBindButtonName(var)
	local keyName = input.GetKeyName(var)
	if not keyName then return "UNKNOWN" end
	local upperKeyName = string.upper(keyName)
	return upperKeyName
end

if CLIENT then
	-- Size-related stuff
	UV.BaseW = 1920
	UV.BaseH = 1080

	UV.DebugRes = nil
	-- Uncomment if you want to debug certain screen resolutions. Below are the resolutions for 16:9:
	-- UV.DebugRes = { w = 1280, h = 720 } -- 16:9 720p (!! Bare Minimum !!)
	-- UV.DebugRes = { w = 640, h = 480 } -- 16:9 480p (For testing - never work with this as a baseline)
	
	function UV_GetW()
		return UV.DebugRes and UV.DebugRes.w or ScrW()
	end

	function UV_GetH()
		return UV.DebugRes and UV.DebugRes.h or ScrH()
	end

	function UV.ScaleW(px)
		return math.Round(px * (UV_GetW() / UV.BaseW))
	end

	function UV.ScaleH(px)
		return math.Round(px * (UV_GetH() / UV.BaseH))
	end

	function UV.Scale(px)
		return math.Round(px * (math.min(UV_GetH(), UV.BaseH) / UV.BaseH))
	end

	-- Original HUD & General
	surface.CreateFont("UVFont", { font = "Arial", size = UV.ScaleH(50), weight = 500, italic = true, extended = true })
	surface.CreateFont("UVFont-Shadow", { font = "Arial", size = UV.ScaleH(50), weight = 500, italic = true, shadow = true, extended = true })
	surface.CreateFont("UVFont-Smaller", { font = "Arial", size = UV.ScaleH(46), weight = 500, italic = true, extended = true })
	surface.CreateFont("UVFont-Bolder", { font = "Arial", size = UV.ScaleH(46), weight = 1000, italic = false, shadow = true, extended = true })
	surface.CreateFont("UVFont2", { font = "Arial", size = UV.ScaleH(50), weight = 500, extended = true })
	surface.CreateFont("UVFont2-Smaller", { font = "Arial", size = UV.ScaleH(40), weight = 500, extended = true })
	surface.CreateFont("UVFont3", { font = "Arial", size = UV.ScaleH(50), weight = 500, shadow = true, extended = true })
	surface.CreateFont("UVFont3Big", { font = "Arial", size = UV.ScaleH(92), weight = 500, extended = true })
	surface.CreateFont("UVFont3Bigger", { font = "Arial", size = UV.ScaleH(130), weight = 500, extended = true })
	surface.CreateFont("UVFont4", { font = "Arial", size = UV.ScaleH(25), weight = 1100, shadow = true, extended = true })

	-- CTU
	surface.CreateFont("UVFont4BiggerItalic", { font = "Arial", size = UV.ScaleH(27), weight = 1100, shadow = true, extended = true, italic = true })
	surface.CreateFont("UVFont4BiggerItalic2", { font = "Arial", size = UV.ScaleH(32), weight = 1100, shadow = true, extended = true, italic = true })
	surface.CreateFont("UVFont4BiggerItalic3", { font = "Arial", size = UV.ScaleH(70), weight = 1100, shadow = true, extended = true, italic = true })

	-- Carbon Fonts
	surface.CreateFont("UVCarbonFont", { font = "HelveticaNeue LT 57 Cn", size = UV.ScaleH(46), shadow = true, weight = 1000, extended = true })
	surface.CreateFont("UVCarbonFont-Smaller", { font = "HelveticaNeue LT 57 Cn", size = UV.ScaleH(38), shadow = true, weight = 1000, extended = true })

	-- Undercover Fonts
	surface.CreateFont("UVUndercoverAccentFont", { font = "HelveticaNeue LT 57 Cn", size = UV.ScaleH(36), shadow = true, weight = 1000, extended = true })
	surface.CreateFont("UVUndercoverLeaderboardFont", { font = "HelveticaNeue LT 57 Cn", size = UV.ScaleH(32), shadow = true, weight = 1000, extended = true })
	surface.CreateFont("UVUndercoverWhiteFont", { font = "Aquarius Six", size = UV.ScaleH(51), shadow = true, weight = 1, extended = true })
	surface.CreateFont("UVCarbonLeaderboardFont", { font = "HelveticaNeue LT 57 Cn", size = UV.ScaleH(25), shadow = true, weight = 1000, extended = true })

	-- Most Wanted Fonts
	surface.CreateFont("UVFont5", { font = "EurostileBold", size = UV.ScaleH(46), weight = 500, extended = true })
	surface.CreateFont("UVFont5UI", { font = "EurostileBold", size = UV.ScaleH(38), weight = 500, extended = true })
	surface.CreateFont("UVFont5UI-BottomBar", { font = "EurostileBold", size = UV.ScaleH(44), weight = 500, extended = true })
	surface.CreateFont("UVFont5WeightShadow", { font = "EurostileBold", size = UV.ScaleH(46), weight = 500, shadow = true, extended = true })
	surface.CreateFont("UVFont5Shadow", { font = "EurostileBold", size = UV.ScaleH(32), weight = 350, shadow = true, extended = true })
	surface.CreateFont("UVFont5ShadowBig", { font = "EurostileBold", size = UV.ScaleH(108), weight = 500, shadow = true, extended = true })
	surface.CreateFont("UVMostWantedLeaderboardFont", { font = "EurostileBold", size = UV.ScaleH(25), weight = 1000, shadow = true, extended = true })
	surface.CreateFont("UVMostWantedLeaderboardFont2", { font = "EurostileBold", size = UV.ScaleH(18), weight = 1000, shadow = true, extended = true })

	-- World Fonts
	surface.CreateFont("UVWorldFont1", { font = "HelveticaNeue LT 57 Cn", size = UV.ScaleH(16), shadow = false, weight = 1000, extended = true })
	surface.CreateFont("UVWorldFont2", { font = "Reg-B-I", size = UV.ScaleH(43), shadow = false, weight = 1000, extended = true })
	surface.CreateFont("UVWorldFont3", { font = "Reg-B-I", size = UV.ScaleH(27), shadow = false, weight = 1000, extended = true })
	surface.CreateFont("UVWorldFont4", { font = "Reg-B-I", size = UV.ScaleH(38), shadow = false, weight = 1000, extended = true })
	surface.CreateFont("UVWorldFont5", { font = "Reg-B-I", size = UV.ScaleH(162), shadow = false, weight = 1000, extended = true })
	surface.CreateFont("UVWorldFont6", { font = "Reg-B-I", size = UV.ScaleH(24), shadow = false, weight = 1000, extended = true })
	surface.CreateFont("UVWorldFont7", { font = "Reg-B-I", size = UV.ScaleH(19), shadow = false, weight = 1000, extended = true })

	-- World Fonts Backup (for specific languages)
	surface.CreateFont("UVWorldFont1-Alt", { font = "Arial", size = UV.ScaleH(16), shadow = false, weight = 1000, italic = true, extended = true })
	surface.CreateFont("UVWorldFont2-Alt", { font = "Arial", size = UV.ScaleH(40), shadow = false, weight = 1000, italic = true, extended = true })
	surface.CreateFont("UVWorldFont3-Alt", { font = "Arial", size = UV.ScaleH(26), shadow = false, weight = 1000, italic = true, extended = true })
	surface.CreateFont("UVWorldFont4-Alt", { font = "Arial", size = UV.ScaleH(38), shadow = false, weight = 1000, italic = true, extended = true })
	surface.CreateFont("UVWorldFont5-Alt", { font = "Arial", size = UV.ScaleH(151), shadow = false, weight = 1000, italic = true, extended = true })
	surface.CreateFont("UVWorldFont6-Alt", { font = "Arial", size = UV.ScaleH(24), shadow = false, weight = 1000, italic = true, extended = true })
	surface.CreateFont("UVWorldFont7-Alt", { font = "Arial", size = UV.ScaleH(19), shadow = false, weight = 1000, italic = true, extended = true })

	-- Settings Fonts
	surface.CreateFont("UVSettingsFont", { font = "EurostileBold", size = UV.ScaleH(25), weight = 1000, shadow = true, extended = true })
	surface.CreateFont("UVSettingsFont-Italic", { font = "EurostileBold", size = UV.ScaleH(25), weight = 1000, shadow = true, extended = true, italic = true })
	surface.CreateFont("UVSettingsFontBig", { font = "EurostileBold", size = UV.ScaleH(35), weight = 1000, shadow = true, extended = true })
	surface.CreateFont("UVSettingsFontBig-Italic", { font = "EurostileBold", size = UV.ScaleH(35), weight = 1000, shadow = true, extended = true, italic = true })
	surface.CreateFont("UVSettingsFontSmall", { font = "EurostileBold", size = UV.ScaleH(18), weight = 1000, shadow = true, extended = true })
	surface.CreateFont("UVSettingsFontSmall-Italic", { font = "EurostileBold", size = UV.ScaleH(18), weight = 1000, shadow = true, extended = true, italic = true })
	surface.CreateFont("UVSettingsFontSmall-Bold", { font = "EurostileBold", size = UV.ScaleH(22), weight = 1000, shadow = true, extended = true })

	-- Keybind Fonts
	surface.CreateFont("UVKeybindFont", { font = "Destiny Keys", size = UV.ScaleH(25), weight = 500, extended = true })
	surface.CreateFont("UVKeybindFontBig", { font = "Destiny Keys", size = UV.ScaleH(35), weight = 500, extended = true })
	surface.CreateFont("UVKeybindFontSmall", { font = "Destiny Keys", size = UV.ScaleH(17.5), weight = 500, extended = true })

    local isUVFrozen = false
    local effectDuration = 0
    local UVFreezeTime = 0

    local spottedCameraView = {}
    local cameraTransitionTime = 2
    local transitionStart = 0

    local copEnt = nil

    net.Receive("UVSpottedFreeze", function()
        effectDuration = net.ReadFloat()
        copEnt = net.ReadEntity()

        isUVFrozen = true
        UVFreezeTime = RealTime() + effectDuration
        transitionStart = RealTime()

        -- LocalPlayer():SetNoDraw(true)
        -- local hands = LocalPlayer():GetHands()
        -- if IsValid(hands) then
        --     hands:SetNoDraw(true)
        -- end
        if Glide then
            if Glide.Camera.isActive and IsValid(Glide.Camera.vehicle) then
                _OldGlideCameraFunction = Glide.Camera.ShouldBeActive
                Glide.Camera.ShouldBeActive = function()
                    return false
                end
            end
        end

        RunConsoleCommand("cl_drawhud", 0)
    end)

    net.Receive("UVSpottedUnfreeze", function()
        isUVFrozen = false

        -- LocalPlayer():SetNoDraw(false)
        -- local hands = LocalPlayer():GetHands()
        -- if IsValid(hands) then
        --     hands:SetNoDraw(false)
        -- end
        if Glide then
            if not Glide.Camera.isActive and IsValid(Glide.Camera.vehicle) and _OldGlideCameraFunction then
                Glide.Camera.ShouldBeActive = _OldGlideCameraFunction
            end
        end

        RunConsoleCommand("cl_drawhud", 1)
    end)

    local orbitYaw = 0

    gameevent.Listen( "player_spawn" ); hook.Add( "player_spawn", "UVOnLocalPlayerSpawn", function( data ) 
	    local id = data.userid

        if LocalPlayer():UserID() == id then
            UVLastVehicleDriven = nil
        end
    end )

    hook.Add("CalcView", "UVCalcView", function(ply, origin, angles, fov, znear, zfar)
        
        UVLastVehicleDriven = IsValid(UVGetVehicle(ply)) and UVGetVehicle(ply) or UVLastVehicleDriven
        local isVehicleValid = IsValid(UVLastVehicleDriven)

        --Spotted (SINGLEPLAYER)
        if isUVFrozen and IsValid(copEnt) then

            local t = math.Clamp((RealTime() - transitionStart) / cameraTransitionTime, 0, 1)

            local copPos = copEnt:WorldSpaceCenter() or copEnt:GetPos()
            local plyPos = ply:GetPos()
            local dist = plyPos:Distance(copPos)
            
            local camPos = plyPos + ply:GetForward() * -300 + Vector(0, 0, 100)
            local camAng = (copPos - camPos):Angle()
            local camFov
            
            local normalized_dist = math.Clamp(dist / 5000, 0, 1)

            camFov = Lerp(normalized_dist, 30, 5)

            local currentView = {
                origin = ply:EyePos() + ply:GetForward() * -300 + Vector(0, 0, 100),
                angles = ply:EyeAngles(),
                fov = fov,
            }

            local spottedCameraView = {}

            spottedCameraView.origin = LerpVector(t, currentView.origin, camPos)
            spottedCameraView.angles = LerpAngle(t, currentView.angles, camAng)
            spottedCameraView.fov = Lerp(t, currentView.fov, camFov)

            return spottedCameraView
        end

        -- Dead
        if not ply:Alive() and isVehicleValid then
            local orbitDistance = 200

            local orbitSpeed = 45 

            orbitYaw = orbitYaw + (FrameTime() * orbitSpeed)
            
            local targetPos = UVLastVehicleDriven:GetPos()

            local camAngles = Angle(0, orbitYaw, 0)
            
            local camPos = targetPos + camAngles:Forward() * - orbitDistance

            camPos = camPos + (vector_up * 100)
            
            local view = {}
            view.origin = camPos
            view.angles = (targetPos - camPos):Angle()
            view.fov = 90
            view.drawviewer = false
            
            return view
        end

    end)

    if not isVehicleValid then
        UVLastVehicleDriven = nil
    end
	
	local HUDCountdownTick = nil

	-- Glyph tables
	UVKeyGlyphs = {}

	-- Keyboard & Mouse
	UVKeyGlyphs.kb = {
		["MOUSE1"] = "<color=51,150,218></color>" .. "", 
		["MOUSE2"] = "<color=51,150,218></color>" .. "", 
		["MOUSE3"] = "<color=51,150,218></color>" .. "", 
		["MOUSE4"] = "<color=51,150,218></color>" .. "", 
		["MOUSE5"] = "<color=51,150,218></color>" .. "", 
		["MWHEELDOWN"] = "<color=51,150,218></color>" .. "",
		["MWHEELUP"] = "<color=51,150,218></color>" .. "",
		
		["ö"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ä"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ì"] = "<color=51,51,51><color=255,255,255></color></color>",
		["è"] = "<color=51,51,51><color=255,255,255></color></color>",
		["é"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ß"] = "<color=51,51,51><color=255,255,255></color></color>",
		["c"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ò"] = "<color=51,51,51><color=255,255,255></color></color>",
		["à"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ù"] = "<color=51,51,51><color=255,255,255></color></color>",
		["a"] = "<color=51,51,51><color=255,255,255></color></color>",
		["b"] = "<color=51,51,51><color=255,255,255></color></color>",
		["c"] = "<color=51,51,51><color=255,255,255></color></color>",
		["d"] = "<color=51,51,51><color=255,255,255></color></color>",
		["e"] = "<color=51,51,51><color=255,255,255></color></color>",
		["f"] = "<color=51,51,51><color=255,255,255></color></color>",
		["g"] = "<color=51,51,51><color=255,255,255></color></color>",
		["h"] = "<color=51,51,51><color=255,255,255></color></color>",
		["i"] = "<color=51,51,51><color=255,255,255></color></color>",
		["j"] = "<color=51,51,51><color=255,255,255></color></color>",
		["k"] = "<color=51,51,51><color=255,255,255></color></color>",
		["l"] = "<color=51,51,51><color=255,255,255></color></color>",
		["m"] = "<color=51,51,51><color=255,255,255></color></color>",
		["n"] = "<color=51,51,51><color=255,255,255></color></color>",
		["o"] = "<color=51,51,51><color=255,255,255></color></color>",
		["p"] = "<color=51,51,51><color=255,255,255></color></color>",
		["q"] = "<color=51,51,51><color=255,255,255></color></color>",
		["r"] = "<color=51,51,51><color=255,255,255></color></color>",
		["s"] = "<color=51,51,51><color=255,255,255></color></color>",
		["t"] = "<color=51,51,51><color=255,255,255></color></color>",
		["u"] = "<color=51,51,51><color=255,255,255></color></color>",
		["v"] = "<color=51,51,51><color=255,255,255></color></color>",
		["w"] = "<color=51,51,51><color=255,255,255></color></color>",
		["x"] = "<color=51,51,51><color=255,255,255></color></color>",
		["y"] = "<color=51,51,51><color=255,255,255></color></color>",
		["z"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ü"] = "<color=51,51,51><color=255,255,255></color></color>",
		
		["0"] = "<color=51,51,51><color=255,255,255></color></color>",
		["1"] = "<color=51,51,51><color=255,255,255></color></color>",
		["2"] = "<color=51,51,51><color=255,255,255></color></color>",
		["3"] = "<color=51,51,51><color=255,255,255></color></color>",
		["4"] = "<color=51,51,51><color=255,255,255></color></color>",
		["5"] = "<color=51,51,51><color=255,255,255></color></color>",
		["6"] = "<color=51,51,51><color=255,255,255></color></color>",
		["7"] = "<color=51,51,51><color=255,255,255></color></color>",
		["8"] = "<color=51,51,51><color=255,255,255></color></color>",
		["9"] = "<color=51,51,51><color=255,255,255></color></color>",
		["'"] = "<color=51,51,51><color=255,255,255></color></color>",
		["*"] = "<color=51,51,51><color=255,255,255></color></color>",
		["+"] = "<color=51,51,51><color=255,255,255></color></color>",
		[","] = "<color=51,51,51><color=255,255,255></color></color>",
		["-"] = "<color=51,51,51><color=255,255,255></color></color>",
		
		["KP_SLASH"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_MULTIPLY"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_INS"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_END"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_DOWNARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_PGDN"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_LEFTARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_5"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_RIGHTARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_HOME"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_UPARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_PGUP"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_MINUS"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_PLUS"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_ENTER"] = "<color=51,51,51><color=255,255,255></color></color>",
		["KP_DEL"] = "<color=51,51,51><color=255,255,255></color></color>",
		
		["SPACE"] = "<color=51,51,51><color=255,255,255></color></color>",
		["DEL"] = "<color=51,51,51><color=255,255,255></color></color>",
		["BACKSPACE"] = "<color=51,51,51><color=255,255,255></color></color>",
		["TAB"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ENTER"] = "<color=51,51,51><color=255,255,255></color></color>",
		["SHIFT"] = "<color=51,51,51><color=255,255,255></color></color>",
		["RSHIFT"] = "<color=51,51,51><color=255,255,255></color></color>",
		["CTRL"] = "<color=51,51,51><color=255,255,255></color></color>",
		["RCTRL"] = "<color=51,51,51><color=255,255,255></color></color>",
		["ALT"] = "<color=51,51,51><color=255,255,255></color></color>",
		["RALT"] = "<color=51,51,51><color=255,255,255></color></color>",
		["UPARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["DOWNARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["LEFTARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["RIGHTARROW"] = "<color=51,51,51><color=255,255,255></color></color>",
		["INS"] = "<color=51,51,51><color=255,255,255></color></color>",
		["END"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F1"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F2"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F3"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F4"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F5"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F6"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F7"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F8"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F9"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F10"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F11"] = "<color=51,51,51><color=255,255,255></color></color>",
		["F12"] = "<color=51,51,51><color=255,255,255></color></color>",
		
		["["] = "<color=51,51,51><color=255,255,255></color></color>",
		["]"] = "<color=51,51,51><color=255,255,255></color></color>",
		["/"] = "<color=51,51,51><color=255,255,255></color></color>",
		["SEMICOLON"] = "<color=51,51,51><color=255,255,255></color></color>",
		["="] = "<color=51,51,51><color=255,255,255></color></color>",
		["\\"] = "<color=51,51,51><color=255,255,255></color></color>",
		["."] = "<color=51,51,51><color=255,255,255></color></color>",
		-- ["."] = "<color=51,51,51><color=255,255,255></color></color>",
		["CAPSLOCK"] = "<color=51,51,51><color=255,255,255></color></color>",
	}

	-- Unified Xbox controller glyphs
	UVKeyGlyphs.xbox = {
		-- Face buttons
		a = "<color=115,164,108><color=51,51,51></color></color>",
		b = "<color=206,89,89><color=51,51,51></color></color>",
		x = "<color=93,123,210><color=51,51,51></color></color>",
		y = "<color=227,194,45><color=51,51,51></color></color>",

		-- Face buttons (360)
		a360 = "<color=255,255,255><color=0,200,0></color></color>",
		b360 = "<color=255,255,255><color=200,0,0></color></color>",
		x360 = "<color=255,255,255><color=0,200,200></color></color>",
		y360 = "<color=255,255,255><color=225,225,0></color></color>",

		-- Face buttons (New)
		anew = "<color=51,51,51><color=255,255,255></color></color>",
		bnew = "<color=51,51,51><color=255,255,255></color></color>",
		xnew = "<color=51,51,51><color=255,255,255></color></color>",
		ynew = "<color=51,51,51><color=255,255,255></color></color>",

		-- Start / Back
		start  = "<color=255,255,255><color=51,51,51></color></color>",
		back   = "<color=255,255,255><color=51,51,51></color></color>",
		start360 = "<color=50,50,50></color>",
		back360  = "<color=50,50,50></color>",

		-- Triggers & Bumpers
		r2 = "<color=255,255,255></color>",
		r1 = "<color=255,255,255></color>",
		l2 = "<color=255,255,255></color>",
		l1 = "<color=255,255,255></color>",

		-- Sticks
		rs  = "<color=255,255,255></color>",
		rsc = "<color=255,255,255></color>",
		ls  = "<color=255,255,255></color>",
		lsc = "<color=255,255,255></color>",

		-- D-Pad
		du  = "<color=255,255,255></color>",
		dr  = "<color=255,255,255></color>",
		dd  = "<color=255,255,255></color>",
		dl  = "<color=255,255,255></color>",
		da  = "<color=255,255,255></color>",
		dlr = "<color=255,255,255></color>",
		dud = "<color=255,255,255></color>",
	}

	-- Unified PlayStation controller glyphs
	UVKeyGlyphs.ps = {
		-- Face buttons
		a = "<color=116,154,244><color=51,51,51></color></color>",
		b = "<color=255,100,96><color=51,51,51></color></color>",
		x = "<color=216,132,184><color=51,51,51></color></color>",
		y = "<color=128,176,128><color=51,51,51></color></color>",

		-- Face buttons
		anew = "<color=51,51,51><color=255,255,255></color></color>",
		bnew = "<color=51,51,51><color=255,255,255></color></color>",
		xnew = "<color=51,51,51><color=255,255,255></color></color>",
		ynew = "<color=51,51,51><color=255,255,255></color></color>",

		-- Special buttons
		share = "<color=255,255,255></color>",
		start = "<color=255,255,255></color>",
		pad   = "<color=96,96,96><color=34,34,34></color></color>",

		-- Triggers & Bumpers
		r1 = "<color=255,255,255></color>",
		r2 = "<color=255,255,255></color>",
		l1 = "<color=255,255,255></color>",
		l2 = "<color=255,255,255></color>",

		-- Sticks
		rs  = "<color=255,255,255></color>",
		rsc = "<color=255,255,255></color>",
		ls  = "<color=255,255,255></color>",
		lsc = "<color=255,255,255></color>",

		-- D-Pad
		du  = "<color=255,255,255></color>",
		dr  = "<color=255,255,255></color>",
		dd  = "<color=255,255,255></color>",
		dl  = "<color=255,255,255></color>",
		da  = "<color=255,255,255></color>",
		dlr = "<color=255,255,255></color>",
		dud = "<color=255,255,255></color>",
	}

	-- Unified Switch controller glyphs
	UVKeyGlyphs.switch = {
		-- Face buttons
		a = "<color=255,255,255><color=51,51,51></color></color>",
		b = "<color=255,255,255><color=51,51,51></color></color>",
		x = "<color=255,255,255><color=51,51,51></color></color>",
		y = "<color=255,255,255><color=51,51,51></color></color>",

		-- Start / Back
		start  = "<color=255,255,255><color=51,51,51></color></color>",
		back   = "<color=255,255,255><color=51,51,51></color></color>",

		-- Triggers & Bumpers
		r2 = "<color=255,255,255></color>",
		r1 = "<color=255,255,255></color>",
		l2 = "<color=255,255,255></color>",
		l1 = "<color=255,255,255></color>",

		-- Sticks
		rs  = "<color=255,255,255></color>",
		rsc = "<color=255,255,255></color>",
		ls  = "<color=255,255,255></color>",
		lsc = "<color=255,255,255></color>",

		-- D-Pad
		du  = "<color=255,255,255></color>",
		dr  = "<color=255,255,255></color>",
		dd  = "<color=255,255,255></color>",
		dl  = "<color=255,255,255></color>",
		da  = "<color=255,255,255></color>",
		dlr = "<color=255,255,255></color>",
		dud = "<color=255,255,255></color>",
	}

	local UVGlyphOverrideTable = {}
	local lastGlyphUpdate = -1
	local UVCommandFallbacks = {
		invnext = "MWHEELDOWN",  -- default glyph key
		invprev = "MWHEELUP",
		slot1   = "1",
		slot2   = "2",
		lastinv = "q",
	}

	local function UpdateGlyphOverrides()
		if lastGlyphUpdate == FrameNumber() then return end
		lastGlyphUpdate = FrameNumber()

		table.Empty(UVGlyphOverrideTable)

		if UVGlyphOverride:GetBool() ~= true then return end

		local raw = UVGlyphSet:GetString()
		if raw == "" then return end

		local lines = string.Split(raw, ", ")
		for _, line in ipairs(lines) do
			line = string.Trim(line)
			if line == "" then continue end

			local parts = string.Split(line, " ")
			if #parts >= 2 then
				local token = parts[1]
				local glyph = parts[2]
				UVGlyphOverrideTable[token] = glyph
			end
		end
	end

	local function ResolveGlyphOverride(token)
		UpdateGlyphOverrides()
		return UVGlyphOverrideTable[token]
	end

	-- The main functions
	function UVKeybindIcon(key, size)
		local font = "UVKeybindFont"  -- default
		if size == "Big" then
			font = "UVKeybindFontBig"
		elseif size == "Small" then
			font = "UVKeybindFontSmall"
		end
		
		local alpha = alpha or 255

		local wrap = function(str)
			return "<font=" .. font .. ">" .. str .. "</font>"
		end

		local parts = string.Split(key, ".")
		local glyph = "[" .. key .. "]"

		if #parts == 1 then
			if UVKeyGlyphs.kb[parts[1]] then
				glyph = UVKeyGlyphs.kb[parts[1]]
			end
		elseif #parts == 2 then
			local family, subkey = parts[1], parts[2]
			if family == "kb" and UVKeyGlyphs.kb[subkey] then
				glyph = UVKeyGlyphs.kb[subkey]
			elseif family == "mouse" and UVKeyGlyphs.mouse[subkey] then
				glyph = UVKeyGlyphs.mouse[subkey]
			elseif family == "xbox" and UVKeyGlyphs.xbox[subkey] then
				glyph = UVKeyGlyphs.xbox[subkey]
			elseif family == "ps" and UVKeyGlyphs.ps[subkey] then
				glyph = UVKeyGlyphs.ps[subkey]
			elseif family == "switch" and UVKeyGlyphs.switch[subkey] then
				glyph = UVKeyGlyphs.switch[subkey]
			elseif subkey == "all" then
				local tbl = UVKeyGlyphs[family]
				if tbl then
					local out = {}
					for _, glyph in pairs(tbl) do
						out[#out + 1] = glyph
					end
					glyph = table.concat(out, "")
				end
			end
		end

		return wrap(glyph)
	end

	local function ResolveKeybind(token)
		if token:sub(1, 1) == "+" then -- console command (+use, +jump, etc.)
			return input.LookupBinding(token, true)
		end

		local cv = GetConVar(token)
		if cv then
			return input.GetKeyName(cv:GetInt())
		end

		return nil
	end

	local function ResolveCommandGlyph(cmd)
		-- Check for user override first
		local override = ResolveGlyphOverride(cmd)
		if override then return override end

		local clean = cmd:gsub("^%+", "")
		-- Check fallback table
		if UVCommandFallbacks[clean] then return UVCommandFallbacks[clean] end

		-- Fallback to normal keybind
		return ResolveKeybind(cmd) or "???"
	end

	function UVReplaceKeybinds(str, glyphsize)
		local glyphsize = glyphsize or nil

		-- [+use] or [command]
		str = str:gsub("%[([%+]?[%w_]+)%]", function(cmd)
			return UVKeybindIcon(ResolveCommandGlyph(cmd), glyphsize)
		end)

		-- [key:convar_name]
		str = str:gsub("%[key:([%w_]+)%]", function(cvar)
			local override = ResolveGlyphOverride("key:" .. cvar)
			if override then
				return UVKeybindIcon(override, glyphsize)
			end

			local key = ResolveKeybind(cvar)
			if not key then return "???" end
			return UVKeybindIcon(key, glyphsize)
		end)

		-- [string:phrase]
		str = str:gsub("%[string:([^%]]+)%]", function(locstring)
			return "<color=255,255,0>" .. UVString(locstring) .. "</color>"
		end)

		-- [glyph:phrase]
		str = str:gsub("%[glyph:([^%]]+)%]", function(glyph)
			return UVKeybindIcon(glyph, glyphsize)
		end)

		return str
	end

	function UVDiscordTextFormat(str)
	str = str:gsub("%*%*(.-)%*%*", "<font=UVSettingsFontSmall-Bold>%1</font>")
	str = str:gsub("(%s)%*(.-)%*", "<font=UVSettingsFontSmall-Italic> %2 </font>")
	str = str:gsub("^%*(.-)%*", "[i]%1[/i]")
	str = str:gsub("__(.-)__", "[u]%1[/u]")
	str = str:gsub("^#%s*(.-)\n", "<font=UVSettingsFontBig>%1</font>\n")
	str = str:gsub("\n#%s*(.-)\n", "\n<font=UVSettingsFontBig>%1</font>\n")
	return str
end

end

function Carbon_FormatRaceTime(curTime)
    local minutes = math.floor(curTime / 60)
    local seconds = math.floor(curTime % 60)
    local milliseconds = math.floor((curTime % 1) * 100)
    
    if minutes > 0 then
        return string.format("%d:%02d.%02d", minutes, seconds, milliseconds)
    else
        return string.format("%01d.%02d", seconds, milliseconds)
    end
end

function UV_FormatRaceEndTime(seconds)
    if not seconds then return nil end
    if type(seconds) == "string" then
        return seconds
    elseif type(seconds) == "number" then
        local minutes = math.floor(seconds / 60)
        local secs = seconds % 60
        return string.format("%d:%05.2f", minutes, secs)
    else
        return "NIL"
    end
end

UV_UI = UV_UI or {}

function UV_UI.GetSide(x, screenW)
    if x > screenW * 0.55 then return 1 end
    if x < screenW * 0.45 then return -1 end
    return 0
end

function UV_UI.ScaleX(x, scale, screenW)
    local centerX = screenW * 0.5
    return centerX + (x - centerX) * scale
end

function UV_UI.ResolveX(x, scale, deadzone, screenW)
    local side = UV_UI.GetSide(x, screenW)
    local scaledX = UV_UI.ScaleX(x, scale, screenW)

    if side == 1 then
        return scaledX - deadzone
    elseif side == -1 then
        return scaledX + deadzone
    end

    return scaledX
end

function UV_UI.ScaleW(width, scale)
    return width * scale
end

function UV_UI.X(x)
    local w = ScrW()
    local scale = math.Clamp(UVHUDXScale:GetFloat(), 0.1, 1)
    local deadzone = math.Clamp(UVHUDXDeadzone:GetFloat(), 0, 500)
    return UV_UI.ResolveX(x, scale, deadzone, w)
end

function UV_UI.XScaled(x) -- For centered elements
    local w = ScrW()
    local scale = math.Clamp(UVHUDXScale:GetFloat(), 0.1, 1)
    local centerX = w * 0.5
    return centerX + (x - centerX) * scale
end

function UV_UI.W(width)
    local scale = math.Clamp(UVHUDXScale:GetFloat(), 0.1, 1)
    return width * scale
end


for _, v in pairs( {'racing', 'pursuit'} ) do
    UV_UI[v] = UV_UI[v] or {}
end

-- Universal
function DrawIcon(material, x, y, height_ratio, color, args)
    local tex = material:GetTexture("$basetexture")
    
    if tex then
        local texW, texH = tex:Width(), tex:Height()
        local aspect = texW / texH
        
        local desiredHeight = UV_GetH() * height_ratio
        local desiredWidth = desiredHeight * aspect
        
        -- Center coords for DrawTexturedRectRotated
        local centerX = x
        local centerY = y
        
        if color then
            surface.SetDrawColor(color:Unpack())
        else
            surface.SetDrawColor(255, 255, 255)
        end
        
        surface.SetMaterial(material, args)
        
        -- Check if 'args' table contains 'rotation' key
        if args and args.rotation then
            surface.DrawTexturedRectRotated(centerX, centerY, desiredWidth, desiredHeight, args.rotation)
        else
            -- Adjust x,y for non-rotated draw (top-left corner)
            local drawX = x - desiredWidth / 2
            local drawY = y - desiredHeight / 2
            surface.DrawTexturedRect(drawX, drawY, desiredWidth, desiredHeight)
        end
    end
end

function UVRenderCommander(ent)
    local localPlayer = LocalPlayer()
    local box_color = Color(0, 161, 255)
    local lang = UVString
    
    if IsValid(ent) then
        if not UVHUDDisplayPursuit then return end
        
        local callsign = lang("uv.unit.commander")
        local driver = UVGetDriver(ent)
        local notitext = "uv.unit.commander.noti"
        
        -- if driver and driver:IsPlayer() then
        if driver then
            callsign = driver:IsPlayer() and driver:GetName() or lang("uv.unit.commander")
            if not ent.lplayernotified then
                ent.lplayernotified = true
                if localPlayer == driver then
                    notitext = "uv.unit.commander.noti.you"
                end
                if Glide then
                    Glide.Notify( {
                        text = "<color=61,183,255>" .. UVString(notitext),
                        icon = "unitvehicles/icons/MINIMAP_ICON_EVENT_RIVAL.png",
                        lifetime = 5,
                        immediate = true
                    } )
                else
                    chat.AddText(
                    Color(0, 81, 161), "[Unit Vehicles] ",
                    Color(61, 183, 255), UVString(notitext) )
                end
                return
            end
        end
		
		if localPlayer == driver then return end
		
		-- Anchor point at vehicle origin (or lightly above)
		local anchorPos = ent:GetPos() + Vector(0, 0, 70) -- Light lift to target roof

		-- Convert to 2D screen space
		local screenPos = anchorPos:ToScreen()
		if not screenPos.visible then return end

		-- Fixed screen offset (so it doesn’t drift with distance)
		local textX = screenPos.x
		local textY = screenPos.y - 120 -- This is in pixels and stays consistent
		
        local w = ScrW()
        local h = ScrH()
        
        local dist = localPlayer:GetPos():Distance(ent:GetPos())
        local distInMeters = dist * 0.01905

        -- Distance in meters
        local fadeAlpha = 255
        local fadeDist = 200
        
        if distInMeters <= fadeDist then
            fadeAlpha = 255 * ((fadeDist - distInMeters) / 25)
        elseif distInMeters > fadeDist then
            fadeAlpha = 0
        end
        		
		-- Edge fade (screen position based)
		local edgeFadeAlpha = 255

		local edgeStartX = w * 0.2
		local edgeEndX = w * 0.8
		local edgeStartY = h * 0.2
		local edgeEndY = h * 0.8

		-- Horizontal fade
		if textX < w * 0.05 or textX > w * 0.95 then
			edgeFadeAlpha = 0
		elseif textX < edgeStartX then
			edgeFadeAlpha = 255 * ((textX - w * 0.05) / (edgeStartX - w * 0.05))
		elseif textX > edgeEndX then
			edgeFadeAlpha = 255 * ((w * 0.95 - textX) / (w * 0.95 - edgeEndX))
		end

		-- Vertical fade
		if textY < h * 0.05 or textY > h * 0.95 then
			edgeFadeAlpha = math.min(edgeFadeAlpha, 0)
		elseif textY < edgeStartY then
			edgeFadeAlpha = math.min(edgeFadeAlpha, 255 * ((textY - h * 0.05) / (edgeStartY - h * 0.05)))
		elseif textY > edgeEndY then
			edgeFadeAlpha = math.min(edgeFadeAlpha, 255 * ((h * 0.95 - textY) / (h * 0.95 - edgeEndY)))
		end

		-- Combine with distance fade
		fadeAlpha = math.min(fadeAlpha, edgeFadeAlpha)
	
		local feet  = distInMeters * 3.28084
		local yards = distInMeters * 1.09361

		local unitType = GetConVar("unitvehicle_unitstype"):GetInt() -- 0=M,1=FT,2=YD

		local displayDist, displayString
		if unitType == 1 then
			displayDist = feet
			displayString = UVString("uv.dist.feet")
		elseif unitType == 2 then
			displayDist = yards
			displayString = UVString("uv.dist.yards")
		else
			displayDist = distInMeters
			displayString = UVString("uv.dist.meter")
		end
		
        cam.Start2D()
			if not GetConVar("cl_drawhud"):GetBool() then return end
			
			-- local bustdist = math.Round(displayDist) .. " m"
			
			local bustdist = string.format( displayString, math.Round(displayDist) )
			
			local cname = lang("uv.unit.commander")
			if IsValid(UVHUDCommander) then
				local driver = UVHUDCommander:GetDriver()
				if IsValid(driver) and driver:IsPlayer() then
					cname = driver:Nick()
				end
			end

			surface.SetFont("UVFont4")
			local textWidth, textHeight = surface.GetTextSize(cname)
			local padding = 8

			local rectywidth = math.max(textWidth + padding, 75)
			local rectxpos = textX - (rectywidth / 2)
			local rectypos = textY + 22.5
			
			surface.SetDrawColor( 0, 161, 255, fadeAlpha )
			surface.DrawRect( rectxpos - 3, rectypos - 2, 4, 59) -- Left
			surface.DrawRect( rectxpos + rectywidth - 1, rectypos - 2, 4, 59) -- Right
			surface.DrawRect( rectxpos, rectypos - 2, rectywidth, 3) -- Up
			surface.DrawRect( rectxpos, rectypos + 54, rectywidth, 3) -- Down
			
			surface.SetMaterial(UVMaterials["ARROW_CARBON"])
			surface.DrawTexturedRectRotated( textX, textY + 87.5 + 5, 17.5, 17.5, -90)
			
			surface.SetDrawColor( 0, 0, 0, math.min(200, fadeAlpha) )
			surface.DrawRect( rectxpos, rectypos, rectywidth, 54)
			
			draw.DrawText(cname, "UVFont4", textX, textY + 20 + 5, Color(255, 255, 255, fadeAlpha), TEXT_ALIGN_CENTER)
			
			draw.DrawText(bustdist, "UVFont4", textX, textY + 42.5 + 5, Color(255, 255, 255, fadeAlpha), TEXT_ALIGN_CENTER)
        cam.End2D()
    end
end

function UVRenderEnemySquare(ent)
    if not IsValid(ent) then return end
    if not RacerTags:GetBool() then return end
    
    local localPlayer = LocalPlayer()
    local box_color = (not UVHUDCopMode and Color(255, 255, 255)) or Color( 255, 132, 0 )
    local blink = 255 * math.abs(math.sin(RealTime() * 4))
    local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
    local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
    
    local lang = UVString
    
    local entbustedtimeleft = math.Round((BustedTimer:GetFloat()-(ent.UVBustingProgress or 0)),3)
    
    if ent.beingbusted then
        if (entbustedtimeleft > 2 and entbustedtimeleft < 3) then
            box_color = Color( 255, blink, blink)
        elseif entbustedtimeleft < 2 then
            box_color = Color( 255, blink2, blink2)
        elseif entbustedtimeleft < 1 then
            box_color = Color( 255, blink3, blink3)
        end
    end
	
    ent._bustAlpha = ent._bustAlpha or 0
	ent._bustOffset = ent._bustOffset or 0

	if IsValid(ent) then
		if not (UVHUDDisplayPursuit or UVHUDDisplayRacing) then return end

		if (UVHUDCopMode and UVHUDDisplayCooldown) or
		   (UVHUDCopMode and (tonumber(UVUnitsChasing) <= 0 or not ent.inunitview) and 
		   not ((not GetConVar("unitvehicle_unit_onecommanderevading"):GetBool()) and UVOneCommanderActive))
		then return end

		if UVHUDRaceInfo and UVHUDRaceInfo.Participants and UVHUDRaceInfo.Participants[ent] then
			local pdata = UVHUDRaceInfo.Participants[ent]
			if (not UVHUDCopMode) and pdata.Finished or pdata.Disqualified or pdata.Busted then
				return
			end
		end
		
		local enemycallsign = UVGetDriverName(ent)
		--local enemydriver = UVGetDriver( ent )
		local enemypos = false
		
		if UVHUDRaceInfo then
			local function GetRacerPositionForEntity(ent)
				if UVHUDCopMode then return end
				if not UVHUDRaceInfo.Participants then return nil end

				local sorted_table, string_array = UVFormLeaderboard(UVHUDRaceInfo.Participants)
				if not istable(sorted_table) or not istable(string_array) then return nil end

				for i, entry in ipairs(string_array) do
					local participant_ent = nil
					if sorted_table[i] then
						participant_ent = sorted_table[i].vehicle
					end

					if participant_ent == ent then
						return i
					end
				end

				return nil
			end

			-- Prefer player name if valid
			-- if IsValid(enemydriver) then
			-- 	if localPlayer == enemydriver then return end
			-- 	enemycallsign = enemydriver:GetName()
			-- end

			-- Fallback: use name from leaderboard data
			if not UVHUDCopMode then
				if UVHUDRaceInfo and UVHUDRaceInfo.Participants then
					local racerInfo = UVHUDRaceInfo.Participants[ent]
					if racerInfo then
						local pos = GetRacerPositionForEntity(ent)
						if pos then
							enemypos = UVString("uv.race.pos.num." .. pos)
						end
						if racerInfo.Name then
							enemycallsign = racerInfo.Name
						end
					end
				end
			end
		end

		-- Anchor point at vehicle origin (or lightly above)
		local anchorPos = ent:GetPos() + Vector(0, 0, 70) -- Light lift to target roof

		-- Convert to 2D screen space
		local screenPos = anchorPos:ToScreen()
		if not screenPos.visible then return end

		-- Fixed screen offset (so it doesn’t drift with distance)
		local textX = screenPos.x
		local textY = screenPos.y - 120 -- This is in pixels and stays consistent

        local w = ScrW()
        local h = ScrH()
        
        -- Distance in meters
        local fadeAlpha = 255
        local fadeDist = 100

        local dist = localPlayer:GetPos():Distance(ent:GetPos())
        local distInMeters = dist * 0.01905
        
        if not UVHUDCopMode then
            if distInMeters <= fadeDist then
                fadeAlpha = 255 * ((fadeDist - distInMeters) / 25)
            elseif distInMeters > fadeDist then
                fadeAlpha = 0
            end
        end
		
		-- Edge fade (screen position based)
		local edgeFadeAlpha = 255

		local edgeStartX = w * 0.2
		local edgeEndX = w * 0.8
		local edgeStartY = h * 0.2
		local edgeEndY = h * 0.8

		-- Horizontal fade
		if textX < w * 0.05 or textX > w * 0.95 then
			edgeFadeAlpha = 0
		elseif textX < edgeStartX then
			edgeFadeAlpha = 255 * ((textX - w * 0.05) / (edgeStartX - w * 0.05))
		elseif textX > edgeEndX then
			edgeFadeAlpha = 255 * ((w * 0.95 - textX) / (w * 0.95 - edgeEndX))
		end

		-- Vertical fade
		if textY < h * 0.05 or textY > h * 0.95 then
			edgeFadeAlpha = math.min(edgeFadeAlpha, 0)
		elseif textY < edgeStartY then
			edgeFadeAlpha = math.min(edgeFadeAlpha, 255 * ((textY - h * 0.05) / (edgeStartY - h * 0.05)))
		elseif textY > edgeEndY then
			edgeFadeAlpha = math.min(edgeFadeAlpha, 255 * ((h * 0.95 - textY) / (h * 0.95 - edgeEndY)))
		end

		-- Combine with distance fade
		fadeAlpha = math.min(fadeAlpha, edgeFadeAlpha)

		local xheight = 0
		-- if not UVHUDCopMode then xheight = h * 0 end

		-- if #enemycallsign > 20 then -- If too long
			-- enemycallsign = string.sub(enemycallsign, 1, 20 - 3) .. "..."
		-- end

		ent._bustAlpha = ent._bustAlpha or 0
		ent._bustOffset = ent._bustOffset or 0
	
		local feet  = distInMeters * 3.28084
		local yards = distInMeters * 1.09361

		local unitType = GetConVar("unitvehicle_unitstype"):GetInt() -- 0=M,1=FT,2=YD

		local displayDist, displayString
		if unitType == 1 then
			displayDist = feet
			displayString = UVString("uv.dist.feet")
		elseif unitType == 2 then
			displayDist = yards
			displayString = UVString("uv.dist.yards")
		else
			displayDist = distInMeters
			displayString = UVString("uv.dist.meter")
		end
		
        cam.Start2D()
			if not GetConVar("cl_drawhud"):GetBool() then return end
			local pos = ent:GetPos() + Vector(0, 0, 80)
			local bustpro = math.Clamp(math.floor((((ent.UVBustingProgress or 0) / BustedTimer:GetInt()) * 100) + .5), 0, 100)
			local bustdist = math.Round(distInMeters) .. " m"
						
			local bustdist = string.format( displayString, math.Round(displayDist) )

			enemypos = enemypos or bustdist

			surface.SetFont("UVFont4")
			local textWidth, textHeight = surface.GetTextSize(enemycallsign)
			local padding = 8

			local rectywidth = math.max(textWidth + padding, 75)
			local rectxpos = textX - (rectywidth / 2)
			local rectypos = textY + 17.5
			
			local targetAlpha = bustpro >= 4 and 1 or 0
			local targetOffset = bustpro >= 2 and -20 or -40

			-- Smoothly approach the target alpha and offset
			ent._bustAlpha = math.Approach(ent._bustAlpha, fadeAlpha * targetAlpha, FrameTime() * 600)
			ent._bustOffset = Lerp(FrameTime() * 10, ent._bustOffset, targetOffset)

			if ent._bustAlpha > 0 then
				local T = math.Clamp(((ent.UVBustingProgress or 0) / BustedTimer:GetInt()) * rectywidth, 0, rectywidth)
				T = math.floor(T)
				
				if ent.beingbusted then
					surface.SetDrawColor(0, 0, 0, ent._bustAlpha)
					surface.DrawRect(rectxpos, rectypos + ent._bustOffset, rectywidth, h * 0.0125)

					surface.SetDrawColor(255, 0, 0, ent._bustAlpha)
					surface.DrawRect(rectxpos, rectypos + ent._bustOffset, T, h * 0.0125)
				end

				draw.DrawText(UVString("uv.chase.busting.other"), "UVFont4", textX, textY + ent._bustOffset - (h * 0.01), Color(box_color.r, box_color.g, box_color.b, ent._bustAlpha), TEXT_ALIGN_CENTER)
			end

			surface.SetDrawColor( box_color.r, box_color.g, box_color.b, fadeAlpha )
			surface.DrawRect( rectxpos - 3, rectypos - 2, 4, 59 + xheight) -- Left
			surface.DrawRect( rectxpos + rectywidth - 1, rectypos - 2, 4, 59 + xheight) -- Right
			surface.DrawRect( rectxpos, rectypos - 2, rectywidth, 3) -- Up
			surface.DrawRect( rectxpos, rectypos + 54 + xheight, rectywidth, 3) -- Down
			
			surface.SetMaterial(UVMaterials["ARROW_CARBON"])
			surface.DrawTexturedRectRotated( textX, textY + 87.5 + xheight, 17.5, 17.5, -90)
			
			surface.SetDrawColor( 0, 0, 0, math.min(200, fadeAlpha) )
			surface.DrawRect( rectxpos, rectypos, rectywidth, 54 + xheight)

			draw.DrawText(enemycallsign, "UVFont4", textX, textY + 20, Color(255, 255, 255, fadeAlpha), TEXT_ALIGN_CENTER)
			
			if UVHUDRaceInfo and UVHUDRaceInfo.Participants then
				draw.DrawText(enemypos or bustdist, "UVFont4", textX, textY + 42.5, Color(255, 255, 255, fadeAlpha), TEXT_ALIGN_CENTER)
			else
				draw.DrawText(bustdist, "UVFont4", textX, textY + 42.5, Color(255, 255, 255, fadeAlpha), TEXT_ALIGN_CENTER)
			end
        cam.End2D()
    end
end

function mw_noti_draw(text, font, x, y, color, colorbg)
    surface.SetFont(font)
    local lines = string.Explode("\n", text)
    
    local lH = {}
    local mW = 0
    local tH = 0
    
    for _, line in ipairs(lines) do
        local w, h = surface.GetTextSize(line)
        table.insert( lH, h )
        mW = math.max( mW, w )
        tH = tH + h
    end
    
    local currentY = y - tH/2
    
	if not colorbg then colorbg = Color(0, 0, 0) end
	
    for i, line in ipairs(lines) do
        local w,h = surface.GetTextSize(line)
		draw.SimpleTextOutlined(line, font, x - w/2, currentY, Color(color.r, color.g, color.b, color.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( colorbg.r, colorbg.g, colorbg.b, colorbg.a or color.a ) )
        currentY = currentY + h
    end
end

function carbon_noti_draw(text, font, font2, x, y, color, color2, colorbg )
    surface.SetFont(font)
    local lines = string.Explode("\n", text)
    
    local lH = {}
    local mW = 0
    local tH = 0
    
    for _, line in ipairs(lines) do
        local w, h = surface.GetTextSize(line)
        table.insert( lH, h )
        mW = math.max( mW, w )
        tH = tH + h
    end
    
    local currentY = y - tH/2
    
    for i, line in ipairs(lines) do
        local drawFont = font
        local drawColor = color
        
        -- Customize second line
        if i == 2 then
            drawFont = font2
            drawColor = color2
        end
    
		if not colorbg then colorbg = Color(0, 0, 0, color.a) end
	
        local w,h = surface.GetTextSize(line)
		draw.SimpleTextOutlined(line, font, x, currentY, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color( colorbg.r, colorbg.g, colorbg.b, colorbg.a or color.a ))
        currentY = currentY + h
    end
end

-- Automatically add all files to client and server
local path = "unitvehicles/uvhud/"
local files = file.Find(path .. "*.lua", "LUA")

table.sort(files)

for _, f in ipairs(files) do
    AddCSLuaFile(path .. f)
    if CLIENT then
        include(path .. f)
    end
end

-- timer.Simple(1, function()
    -- for k,v in pairs(UV_UI) do
        -- if type(v) == "table" then
            -- print("[UV_UI] found HUD:", k)
        -- end
    -- end
	
    -- for k,v in pairs(UV_UI.racing) do
        -- if type(v) == "table" then
            -- print("[UV_UI] found racing HUD:", k)
        -- end
    -- end
	
    -- for k,v in pairs(UV_UI.pursuit) do
        -- if type(v) == "table" then
            -- print("[UV_UI] found pursuit HUD:", k)
        -- end
    -- end
-- end)

-- Hooks
local function onEvent(type, eventName, ...)
    local main = UVHUDTypeMain:GetString()
    local backup = UVHUDTypeBackup:GetString()

    -- Try to resolve the event function from main UI first
    local handler = UV_UI[type] and UV_UI[type][main] and UV_UI[type][main].events and UV_UI[type][main].events[eventName]

    -- If not found, and type is pursuit, fall back to backup UI
    if not handler and type == "pursuit" then
        handler = UV_UI.pursuit[backup] and UV_UI.pursuit[backup].events and UV_UI.pursuit[backup].events[eventName]
    end

    if handler then
        handler(...)
    end
end

hook.Add( "UIEventHook", "UI_Event", onEvent )