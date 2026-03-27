UV.RegisterSpeedometer( "nightrunners", "NIGHTRUNNERS" )

-- [[ Convars ]] --
-- Speedometer
CreateClientConVar("uvspeedo_nightrunners_x", 0.875, true, false)
CreateClientConVar("uvspeedo_nightrunners_y", 0.825, true, false)

CreateClientConVar("uvspeedo_nightrunners_shownitrous", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_maingauges_r", 38, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_maingauges_g", 225, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_maingauges_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_mainneedles_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_mainneedles_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_mainneedles_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_tempgauges_r", 38, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempgauges_g", 225, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempgauges_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_fuelgauges_r", 38, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelgauges_g", 225, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelgauges_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_tempneedles_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempneedles_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempneedles_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_fuelneedles_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelneedles_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelneedles_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_redline_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_redline_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_redline_b", 0, true, false)

UV_UI.speedometer = UV_UI.speedometer or {}
UV_UI.speedometer.nightrunners = UV_UI.speedometer.nightrunners or {}
UVMenu.CustomizeSpeedo = UVMenu.CustomizeSpeedo or {}

UVMenu.CustomizeSpeedo.nightrunners = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1250),
		Height = UV.ScaleH(760),
		Description = true,
		-- ColorPreview = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.ui.speedometer.cust",
				{ type = "label", text = "NIGHTRUNNERS" },
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
						func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
				{ type = "slider", text = "uv.ui.xaxis", desc = "uv.ui.xaxis.desc", convar = "uvspeedo_nightrunners_x", min = 0, max = 1, decimals = 3 },
				{ type = "slider", text = "uv.ui.yaxis", desc = "uv.ui.yaxis.desc", convar = "uvspeedo_nightrunners_y", min = 0, max = 1, decimals = 3 },
                { type = "bool", text = "uv.speedo.shownitrous", desc = "uv.speedo.shownitrous.desc", convar = "uvspeedo_nightrunners_shownitrous", cond = function() return cffunctions end },
				{ type = "coloralpha", text = "uv.speedo.face", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_maingauges" },
				{ type = "coloralpha", text = "uv.speedo.needle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_mainneedles" },
				{ type = "coloralpha", text = "uv.speedo.tempface", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_tempgauges" },
				{ type = "coloralpha", text = "uv.speedo.fuelface", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_fuelgauges" },
				{ type = "coloralpha", text = "uv.speedo.tempneedle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_tempneedles" },
				{ type = "coloralpha", text = "uv.speedo.fuelneedle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_fuelneedles" },
				{ type = "coloralpha", text = "uv.speedo.redline", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_redline" },
			},
		}
	})
end

local function nightrunners_speedometer( ... )
	local w = ScrW()
	local h = ScrH()

	local speed = select(1, ...)
	local speedname = select(2, ...)
	local gear = select(3, ...)
	local rpm = select(4, ...)
	local maxrpm = select(5, ...)
	local throttle = select(6, ...)
	local redlining = select(7, ...)
	local redlinestrength = select(8, ...)
	local health = select(9, ...)
	local nitrousenabled = select(10, ...)
	local nitrous = select(11, ...)
	local speedbreakerenabled = select(12, ...)
	local speedbreaker = select(13, ...)

	local gearText = tostring(gear)
	if gear == -1 then gearText = "R"
	elseif gear == 0 then gearText = "N" end

	local speedopos = {
		x = w * (GetConVar("uvspeedo_nightrunners_x"):GetFloat()),
		y = h * (GetConVar("uvspeedo_nightrunners_y"):GetFloat()),
	}

	local colorValues = {
        maingauges = {
            r = GetConVar("uvspeedo_nightrunners_col_maingauges_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_maingauges_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_maingauges_b"):GetInt(),
        },
        mainneedles = {
            r = GetConVar("uvspeedo_nightrunners_col_mainneedles_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_mainneedles_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_mainneedles_b"):GetInt(),
        },
        tempgauges = {
            r = GetConVar("uvspeedo_nightrunners_col_tempgauges_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_tempgauges_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_tempgauges_b"):GetInt(),
        },
        fuelgauges = {
            r = GetConVar("uvspeedo_nightrunners_col_fuelgauges_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_fuelgauges_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_fuelgauges_b"):GetInt(),
        },
        tempneedles = {
            r = GetConVar("uvspeedo_nightrunners_col_tempneedles_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_tempneedles_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_tempneedles_b"):GetInt(),
        },
        fuelneedles = {
            r = GetConVar("uvspeedo_nightrunners_col_fuelneedles_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_fuelneedles_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_fuelneedles_b"):GetInt(),
        },
        redline = {
            r = GetConVar("uvspeedo_nightrunners_col_redline_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_redline_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_redline_b"):GetInt(),
        },
    }

    local sideGaugeSecFunc = GetConVar( 'uvspeedo_nightrunners_shownitrous' )

    local switchedOffLightColor = Color( 93, 93, 93 )
    local backingGlass = Color( 0, 0, 0, 212)
    local mainNeedleColor = Color( colorValues.mainneedles.r, colorValues.mainneedles.g, colorValues.mainneedles.b )
    local mainGaugeColor = Color( colorValues.maingauges.r, colorValues.maingauges.g, colorValues.maingauges.b )
    local redlineColor = Color( colorValues.redline.r, colorValues.redline.g, colorValues.redline.b )
    local tempGaugeColor = Color( colorValues.tempgauges.r, colorValues.tempgauges.g, colorValues.tempgauges.b )
    local fuelGaugeColor = Color( colorValues.fuelgauges.r, colorValues.fuelgauges.g, colorValues.fuelgauges.b )
    local tempNeedleColor = Color( colorValues.tempneedles.r, colorValues.tempneedles.g, colorValues.tempneedles.b )
    local fuelNeedleColor = Color( colorValues.fuelneedles.r, colorValues.fuelneedles.g, colorValues.fuelneedles.b )

    -- faces/backings
    local RPM_XPOS = speedopos.x - (w * 0.025)
    local SPEEDO_XPOS = speedopos.x - (w * 0.1)
    local TEMP_XPOS = speedopos.x + (w * 0.009)
    local FUEL_XPOS = speedopos.x + (w * 0.03)
    DrawIcon(UVMaterials["TACHO1_NR_BIG_BACKING_GLASS"], RPM_XPOS, speedopos.y - (h * 0.2), 0.3, backingGlass)
    DrawIcon(UVMaterials["TACHO1_NR_BIG_BACKING"], RPM_XPOS, speedopos.y - (h * 0.2), 0.3, color_black)
    DrawIcon(UVMaterials["TACHO1_NR_RPM_GAUGE"], RPM_XPOS, speedopos.y - (h * 0.2), 0.3, rpm == 0 and switchedOffLightColor or mainGaugeColor)
    DrawIcon(UVMaterials["TACHO1_NR_REDLINE"], RPM_XPOS, speedopos.y - (h * 0.2), 0.3, rpm == 0 and Color(redlineColor.r / 3, redlineColor.g / 3, redlineColor.b / 3, 210) or redlineColor)
    if rpm ~= 0 then
        DrawIcon(UVMaterials["TACHO1_NR_NEEDLE_GLOW"], RPM_XPOS, speedopos.y - (h * 0.182), 0.18, mainNeedleColor)
    end
    DrawIcon(UVMaterials["TACHO1_NR_NEEDLE_GLASS"], RPM_XPOS, speedopos.y - (h * 0.182), 0.05, switchedOffLightColor)

    DrawIcon(UVMaterials["TACHO1_NR_BIG_BACKING_GLASS"], SPEEDO_XPOS, speedopos.y + (h * 0.01), 0.3, backingGlass)
    DrawIcon(UVMaterials["TACHO1_NR_BIG_BACKING"], SPEEDO_XPOS, speedopos.y + (h * 0.01), 0.3, color_black)
    DrawIcon(UVMaterials["TACHO1_NR_SPEEDO_GAUGE"], SPEEDO_XPOS, speedopos.y + (h * 0.01), 0.3, rpm == 0 and switchedOffLightColor or mainGaugeColor)
    if rpm ~= 0 then
        DrawIcon(UVMaterials["TACHO1_NR_NEEDLE_GLOW"], SPEEDO_XPOS, speedopos.y + (h * 0.029), 0.18, mainNeedleColor)
    end
    DrawIcon(UVMaterials["TACHO1_NR_NEEDLE_GLASS"], SPEEDO_XPOS, speedopos.y + (h * 0.029), 0.05, switchedOffLightColor)

    DrawIcon(UVMaterials["TACHO1_NR_TEMP_GAUGE_GLASS"], TEMP_XPOS, speedopos.y + (h * 0.08), 0.28, backingGlass)
    DrawIcon(UVMaterials["TACHO1_NR_TEMP_GAUGE_BACKING"], TEMP_XPOS, speedopos.y + (h * 0.08), 0.28, color_black)
    DrawIcon(UVMaterials["TACHO1_NR_TEMP_GAUGE"], TEMP_XPOS, speedopos.y + (h * 0.08), 0.28, rpm == 0 and switchedOffLightColor or tempGaugeColor)
    DrawIcon(UVMaterials["TACHO1_NR_FUEL_GAUGE_GLASS"], FUEL_XPOS, speedopos.y - (h * 0.03), 0.28, backingGlass)
    DrawIcon(UVMaterials["TACHO1_NR_FUEL_GAUGE_BACKING"], FUEL_XPOS, speedopos.y - (h * 0.03), 0.28, color_black)
    DrawIcon(UVMaterials["TACHO1_NR_FUEL_GAUGE"], FUEL_XPOS, speedopos.y - (h * 0.03), 0.28, rpm == 0 and switchedOffLightColor or fuelGaugeColor)

    


    local gearIcon = UV_UI.speedometer.nightrunners.states.lastGearIcon or UVMaterials["TACHO1_NR_SHIFT_UP_ICON"]
    if gear ~= UV_UI.speedometer.nightrunners.states.lastGear then
        UV_UI.speedometer.nightrunners.states.lastGearSwitch = CurTime()
        UV_UI.speedometer.nightrunners.states.lastColor = mainGaugeColor
        if gear < UV_UI.speedometer.nightrunners.states.lastGear then
            gearIcon = UVMaterials["TACHO1_NR_SHIFT_DOWN_ICON"]
        else 
            gearIcon = UVMaterials["TACHO1_NR_SHIFT_UP_ICON"]
        end
    end

    UV_UI.speedometer.nightrunners.states.lastGear = gear
    
    if rpm ~= 0 then
        draw.SimpleText( gearText, "UVNightRunnersLCDFont-Tiny1", speedopos.x - (w * 0.132), speedopos.y + (h * 0.078), mainGaugeColor, TEXT_ALIGN_LEFT )
        DrawIcon(gearIcon, speedopos.x - (w * 0.141), speedopos.y + (h * 0.098), 0.02, UV_UI.speedometer.nightrunners.states.lastColor)    
    end

    UV_UI.speedometer.nightrunners.states.lastGearIcon = gearIcon
    UV_UI.speedometer.nightrunners.states.lastColor = UV_UI.speedometer.nightrunners.states.lastColor:Lerp(color_black, FrameTime() * (CurTime() - UV_UI.speedometer.nightrunners.states.lastGearSwitch < 1 and .2 or 3))

    local needleScaleFactor = math.min(w, h) * 0.3
    local tempScaleFactor = math.min(w, h) * 0.21
    local fuelScaleFactor = math.min(w, h) * 0.21

    -- rpm tacho
    local tachometer = {
		idle = 20,
		max = 235,
		direction = -1
	}

	local rpm_lerp = Lerp(FrameTime() * 8, UV_UI.speedometer.nightrunners.states.rpm_lerp or rpm, rpm)
	UV_UI.speedometer.nightrunners.states.rpm_lerp = rpm_lerp
    
	local rpmFrac = math.Clamp( rpm_lerp / maxrpm, 0, 1 )
	local angle = tachometer.idle + tachometer.direction * (rpmFrac * (tachometer.max - tachometer.idle))

	if redlining then
		angle = angle + math.abs( math.Clamp( math.cos( RealTime() * redlinestrength ), 0, 1 ) * 6 )
	end

    if rpmFrac <= 0.2 and rpmFrac > 0.05 then
		local t = RealTime() * 10
		local lowWobble = math.random(-0.7, 0.7) * 1.5 * ( 1 - rpmFrac / 0.2 )
		angle = angle + lowWobble
	end

	surface.SetMaterial(UVMaterials["TACHO1_NR_NEEDLE"])
	surface.SetDrawColor(rpm == 0 and Color(mainNeedleColor.r / 3, mainNeedleColor.g / 3, mainNeedleColor.b / 3, 210) or mainNeedleColor)
	surface.DrawTexturedRectRotated( RPM_XPOS, speedopos.y - (h * 0.182), needleScaleFactor, needleScaleFactor, angle )

    -- tacho needle
    local maxspeed = 250
    local tacho_needle = {
		idle = 20,
		max = 250,
		direction = -1
	}
	
	local tacho_lerp = Lerp( FrameTime() * 8, UV_UI.speedometer.nightrunners.states.tacho_lerp or speed, speed )
	UV_UI.speedometer.nightrunners.states.tacho_lerp = tacho_lerp
    
	local tachoFrac = math.Clamp(tacho_lerp / maxspeed, 0, 1)
	local tachoAngle = tacho_needle.idle + tacho_needle.direction * ( tachoFrac * ( tacho_needle.max - tacho_needle.idle ))

	surface.SetMaterial(UVMaterials["TACHO1_NR_NEEDLE"])
	surface.SetDrawColor(rpm == 0 and Color(mainNeedleColor.r / 3, mainNeedleColor.g / 3, mainNeedleColor.b / 3, 210) or mainNeedleColor)
	surface.DrawTexturedRectRotated( SPEEDO_XPOS, speedopos.y + (h * 0.0285), needleScaleFactor, needleScaleFactor, tachoAngle )

    -- temp needle (simulated :3)
    local maxtemp = 320
    local temp_needle = {
		idle = 7,
		max = 75,
		direction = -1
	}

    if rpm == 0 then UV_UI.speedometer.nightrunners.states.lastSwitchOff = CurTime() end

    local temp = rpm == 0 and 0 or (sideGaugeSecFunc:GetBool() and (speedbreakerenabled and maxtemp * speedbreaker or maxtemp) or math.Remap(speed, 0, maxtemp, 100, maxtemp))
	
	local temp_lerp = Lerp(FrameTime() * ((rpm == 0 or CurTime() - UV_UI.speedometer.nightrunners.states.lastSwitchOff < 1 or sideGaugeSecFunc:GetBool()) and 3 or 0.2), UV_UI.speedometer.nightrunners.states.temp_lerp or temp, temp)
	UV_UI.speedometer.nightrunners.states.temp_lerp = temp_lerp
    
	local tempFrac = math.Clamp(temp_lerp / maxtemp, 0, 1)
	local tempAngle = temp_needle.idle + temp_needle.direction * (tempFrac * (temp_needle.max - temp_needle.idle))

    if not sideGaugeSecFunc:GetBool() and rpm ~= 0 and tempFrac >= 0.91 then
        DrawIcon(UVMaterials["DASH_NR_ENGINE_OVERHEAT"], RPM_XPOS - (w * 0.02), speedopos.y - (h * 0.133), 0.023, rpm == 0 and switchedOffLightColor or color_white)
        DrawIcon(UVMaterials["DASH_NR_LIGHT"], TEMP_XPOS - (w * 0.006), speedopos.y + (h * 0.094), 0.014, rpm == 0 and switchedOffLightColor or color_white)
        DrawIcon(UVMaterials['TACHO1_NR_NEEDLE_GLOW'], TEMP_XPOS - (w * 0.006), speedopos.y + (h * 0.094), 0.1, Color(255,0,0,150))
    end

	surface.SetMaterial(UVMaterials["TACHO1_NR_SMALL_NEEDLE"]) -- Needle
	surface.SetDrawColor( rpm == 0 and Color(tempNeedleColor.r / 3, tempNeedleColor.g / 3, tempNeedleColor.b / 3, 210) or tempNeedleColor )
	surface.DrawTexturedRectRotated( TEMP_XPOS + (w * 0.018), speedopos.y + (h * 0.107), tempScaleFactor * 1, tempScaleFactor, tempAngle )

    DrawIcon(UVMaterials["TACHO1_NR_NEEDLE_GLOW"], TEMP_XPOS + (w * 0.018), speedopos.y + (h * 0.107), 0.18, Color(colorValues.tempneedles.r, colorValues.tempneedles.g, colorValues.tempneedles.b, rpm == 0 and 0 or 63))
    DrawIcon(UVMaterials["TACHO1_NR_SMALL_NEEDLE_GLASS"], TEMP_XPOS + (w * 0.018), speedopos.y + (h * 0.107), 0.25, switchedOffLightColor)

    -- fuel gauge
    local maxfuel = 100
    local quantity = rpm == 0 and 0 or (sideGaugeSecFunc:GetBool() and (nitrousenabled and maxfuel * nitrous or maxfuel) or math.Clamp(health * 100, 0, 100))
    local fuel_needle = {
		idle = -189,
		max = -255,
		direction = -1
	}
	
	local fuel_lerp = Lerp(FrameTime() * 3, UV_UI.speedometer.nightrunners.states.fuel_lerp or quantity, quantity)
	UV_UI.speedometer.nightrunners.states.fuel_lerp = fuel_lerp
    
	local fuelFrac = math.Clamp( fuel_lerp / maxfuel, 0, 1 )
	local fuelAngle = fuel_needle.idle + fuel_needle.direction * ( fuelFrac * ( fuel_needle.max - fuel_needle.idle ))

	surface.SetMaterial(UVMaterials["TACHO1_NR_SMALL_NEEDLE"]) -- Needle
	surface.SetDrawColor( rpm == 0 and Color(fuelNeedleColor.r / 3, fuelNeedleColor.g / 3, fuelNeedleColor.b / 3, 210) or fuelNeedleColor )
	surface.DrawTexturedRectRotated( FUEL_XPOS - (w * 0.02), speedopos.y - (h * 0.003), fuelScaleFactor, fuelScaleFactor, fuelAngle )

    DrawIcon(UVMaterials["TACHO1_NR_NEEDLE_GLOW"], FUEL_XPOS - (w * 0.02), speedopos.y - (h * 0.001), 0.18, Color(colorValues.fuelneedles.r, colorValues.fuelneedles.g, colorValues.fuelneedles.b, rpm == 0 and 0 or 63))
    DrawIcon(UVMaterials["TACHO1_NR_SMALL_NEEDLE_GLASS"], FUEL_XPOS - (w * 0.02), speedopos.y - (h * 0.001), 0.25, switchedOffLightColor)

    if not sideGaugeSecFunc:GetBool() and fuelFrac <= 0.2 and rpm ~= 0 then
        DrawIcon(UVMaterials["DASH_NR_LIGHT"], FUEL_XPOS + (w * 0.003), speedopos.y - (h * 0.011), 0.014, rpm == 0 and switchedOffLightColor or color_white)
        DrawIcon(UVMaterials['TACHO1_NR_NEEDLE_GLOW'], FUEL_XPOS + (w * 0.003), speedopos.y - (h * 0.011), 0.1, Color(255,0,0,150))
    end

    -- Odometer
    Glide.currentVehicle.__ODO = Glide.currentVehicle.__ODO or math.random(0, 999999)
    local dt = RealFrameTime()

    local speedInKmh = speed
    if speedname and string.lower(speedname) == "mph" then
        speedInKmh = speed * 1.60934
    end
    local kmTraveled = speedInKmh * (dt / 3600)
    Glide.currentVehicle.__ODO = math.Clamp(math.max(0, (tonumber(Glide.currentVehicle.__ODO) or 0) + kmTraveled), 0, 999999)

    local odoText = string.Comma(math.floor(Glide.currentVehicle.__ODO), "'")
    
    DrawIcon(UVMaterials["TACHO1_NR_ODOMETER"], SPEEDO_XPOS + (w * 0.021), speedopos.y + (h * 0.02), 0.26, rpm == 0 and switchedOffLightColor or color_white)
    if rpm ~= 0 then
        draw.SimpleTextOutlined( "KM", "UVNightRunnersLCDFont-ThinTiny2", SPEEDO_XPOS - (w * 0.0055), speedopos.y + (h * 0.0938), color_black, TEXT_ALIGN_LEFT, nil, 0.5, color_black )
        draw.SimpleText( odoText, "UVNightRunnersLCDFont-Tiny2NoShadow", SPEEDO_XPOS + (w * 0.049), speedopos.y + (h * 0.085), color_black, TEXT_ALIGN_RIGHT )
    end
end

UV_UI.speedometer.nightrunners.main = nightrunners_speedometer
UV_UI.speedometer.nightrunners.states = {
    lastSwitchOff = 0,
    lastGear = 0,
    lastGearSwitch = 0,
    lastGearIcon = nil,
    lastVehicle = Glide.currentVehicle,
    lastColor = Color(38, 225, 0),
	rpm_lerp = 0,
}

UV_UI.speedometer.nightrunners.offsets = { x = 0.1025, y = 0.4 }