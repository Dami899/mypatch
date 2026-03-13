UV.RegisterSpeedometer( "underground2", "NFS: Underground 2" )

-- [[ Convars ]] --
-- Speedometer
CreateClientConVar("uvspeedo_underground2_gauge", 0, true, false)
CreateClientConVar("uvspeedo_underground2_x", 0.875, true, false)
CreateClientConVar("uvspeedo_underground2_y", 0.825, true, false)

-- Background colour
CreateClientConVar("uvspeedo_underground2_col_needle_r", 255, true, false)
CreateClientConVar("uvspeedo_underground2_col_needle_g", 255, true, false)
CreateClientConVar("uvspeedo_underground2_col_needle_b", 255, true, false)

CreateClientConVar("uvspeedo_underground2_col_lettering_r", 255, true, false)
CreateClientConVar("uvspeedo_underground2_col_lettering_g", 255, true, false)
CreateClientConVar("uvspeedo_underground2_col_lettering_b", 255, true, false)

CreateClientConVar("uvspeedo_underground2_col_gauge_r", 255, true, false)
CreateClientConVar("uvspeedo_underground2_col_gauge_g", 255, true, false)
CreateClientConVar("uvspeedo_underground2_col_gauge_b", 255, true, false)

UV_UI.speedometer = UV_UI.speedometer or {}
UV_UI.speedometer.underground2 = UV_UI.speedometer.underground2 or {}

local function underground2_speedometer( ... )
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

	local gearText = gear
	if gear == -1 then gearText = "R"
	elseif gear == 0 then gearText = "N" end

	local speedopos = {
		x = w * GetConVar("uvspeedo_underground2_x"):GetString(),
		y = h * GetConVar("uvspeedo_underground2_y"):GetString(),
	}

	local cvs = {
		gaugetype = GetConVar("uvspeedo_underground2_gauge"):GetString(),
		needle = {
			r = GetConVar("uvspeedo_underground2_col_needle_r"):GetInt(),
			g = GetConVar("uvspeedo_underground2_col_needle_g"):GetInt(),
			b = GetConVar("uvspeedo_underground2_col_needle_b"):GetInt(),
		},
		lettering = {
			r = GetConVar("uvspeedo_underground2_col_lettering_r"):GetInt(),
			g = GetConVar("uvspeedo_underground2_col_lettering_g"):GetInt(),
			b = GetConVar("uvspeedo_underground2_col_lettering_b"):GetInt(),
		},
		gauge = {
			r = GetConVar("uvspeedo_underground2_col_gauge_r"):GetInt(),
			g = GetConVar("uvspeedo_underground2_col_gauge_g"):GetInt(),
			b = GetConVar("uvspeedo_underground2_col_gauge_b"):GetInt(),
		},
	}

	local blink = math.floor(RealTime()*2)==math.Round(RealTime()*2) and 1 or 0
	
	local speedocol = {
		needle = Color(cvs.needle.r or 223,cvs.needle.g or 184,cvs.needle.b or 127),
		lettering = Color(cvs.lettering.r or 255,cvs.lettering.g or 255,cvs.lettering.b or 255),
		gauge = Color(cvs.gauge.r or 223,cvs.gauge.g or 184,cvs.gauge.b or 127),

		gearw = Color( 196 * blink, 208 * blink, 151 * blink),
		extraoff = Color(0,0,0,150),
		nitrous = Color(19,146,190),
		speedbr = Color(223,184,127),
		health = Color(200,75,75, 100),
	}

	local spn = "uv.kmh"
	if speedname == "MPH" then spn = "uv.mph" end

	local function DrawMeter(x, y, radius, thickness, nitrous, rotation, color, arc)
		nitrous = math.Clamp(nitrous or 0, 0, 1)
		rotation = rotation or -135
		arc = arc or 170
		
		local startAng = rotation

		local fillEnd = startAng + (arc * nitrous)

		Glide.DrawOutlinedCircle(
			radius,
			x,
			y,
			thickness,
			color,
			fillEnd,
			rotation + 360
		)
	end

	if cffunctions then
		-- [[ Nitrous ]] --
		if nitrousenabled then
			DrawMeter( speedopos.x + UV_UI.W(w * 0.002), speedopos.y - UV_UI.W(w * 0.002), UV_UI.W(w * 0.1025), UV_UI.W(w * 0.01), 1, 90, speedocol.extraoff, 150 )
			DrawMeter( speedopos.x + UV_UI.W(w * 0.002), speedopos.y - UV_UI.W(w * 0.002), UV_UI.W(w * 0.1015), UV_UI.W(w * 0.0075), nitrous, 90, speedocol.nitrous, 150 )

			local nitrocol = nitrous <= 0 and speedocol.extraoff or speedocol.nitrous
			
			-- surface.SetDrawColor(nitrocol)
			-- surface.SetMaterial(Material("unitvehicles/speedometers/mw/n20_icon.png"))
			-- surface.DrawTexturedRectRotated( speedopos.x - (w * 0.08), speedopos.y + (w * 0.08), UV_UI.W(w * 0.03), UV_UI.W(w * 0.03), 0 )
		end

		-- [[ Speedbreaker ]] --
		if game.SinglePlayer() and speedbreakerenabled then
			DrawMeter( speedopos.x + UV_UI.W(w * 0.002), speedopos.y - UV_UI.W(w * 0.002), UV_UI.W(w * 0.1025), UV_UI.W(w * 0.01), 1, 245, speedocol.extraoff, 75 )
			DrawMeter( speedopos.x + UV_UI.W(w * 0.002), speedopos.y - UV_UI.W(w * 0.002), UV_UI.W(w * 0.1015), UV_UI.W(w * 0.0075), speedbreaker, 245, speedocol.speedbr, 75 )

			local spbcol = speedbreaker <= 0 and speedocol.extraoff or speedocol.speedbr
			
			-- surface.SetDrawColor(spbcol)
			-- surface.SetMaterial(Material("unitvehicles/speedometers/mw/persuit_icon.png"))
			-- surface.DrawTexturedRectRotated( speedopos.x + (w * 0.08), speedopos.y - (w * 0.08), UV_UI.W(w * 0.03), UV_UI.W(w * 0.03), 0 )
		end
	end

	-- [[ Speedometer ]] --
	surface.SetMaterial(Material("unitvehicles/speedometers/ug2/tach_fill_custom_" .. cvs.gaugetype .. ".png", "mips smooth")) -- Background
	surface.SetDrawColor(speedocol.gauge)
	surface.DrawTexturedRectRotated( speedopos.x + UV_UI.W(w * 0.08), speedopos.y + UV_UI.W(w * 0.077), UV_UI.W(w * 0.34), UV_UI.W(w * 0.34), 0 )

	surface.SetMaterial(Material("unitvehicles/speedometers/ug2/3rdperson_10500lines_custom_" .. cvs.gaugetype .. ".png")) -- BG Filler
	surface.SetDrawColor(speedocol.lettering)
	surface.DrawTexturedRectRotated( speedopos.x, speedopos.y - (w * 0.001), UV_UI.W(w * 0.17), UV_UI.W(w * 0.17), 0 )

	surface.SetMaterial(Material("unitvehicles/speedometers/ug2/drift_angle_backing2.png")) -- Lower "drift angle" filler
	surface.SetDrawColor(0,0,0,100)
	surface.DrawTexturedRectRotated( speedopos.x - (w * 0.064), speedopos.y + (w * 0.067), UV_UI.W(w * 0.17), UV_UI.W(w * 0.085), 0 )

	if rpm >= maxrpm * 0.95 then
		draw.SimpleText("▲", "UVFont", speedopos.x + (w * 0.05), speedopos.y - (h * 0.0475), speedocol.gearw, TEXT_ALIGN_RIGHT)
	end
	
	draw.SimpleText( gearText, "UVFont", speedopos.x + (w * 0.07), speedopos.y - (h * 0.0475), speedocol.lettering, TEXT_ALIGN_RIGHT )
		
	-- [[ Health ]] --
	surface.SetDrawColor(speedocol.lettering)
	surface.SetMaterial(Material("unitvehicles/speedometers/ug2/3rdperson_turbofill_custom_" .. cvs.gaugetype .. ".png"))
	surface.DrawTexturedRectRotated( speedopos.x - (w * 0.085), speedopos.y + (w * 0.08), UV_UI.W(w * 0.165), UV_UI.W(w * 0.165), 0 )
	
	surface.SetDrawColor(speedocol.lettering)
	surface.SetMaterial(Material("unitvehicles/speedometers/ug2/3rdperson_turbolines_custom_" .. cvs.gaugetype .. ".png"))
	surface.DrawTexturedRectRotated( speedopos.x - (w * 0.085), speedopos.y + (w * 0.08), UV_UI.W(w * 0.165), UV_UI.W(w * 0.165), 0 )
	
	local healthmeter = {
		idle = 0,
		max = 225,
		direction = -1
	}

	ug2_health_lerp = Lerp(FrameTime() * 8, ug2_health_lerp or health, health)

	local healthFrac = math.Clamp(ug2_health_lerp, 0, 1)

	local healthAngle = healthmeter.idle + healthmeter.direction * (healthFrac * (healthmeter.max - healthmeter.idle))

	-- DrawMeter( speedopos.x - UV_UI.W(w * 0.121), speedopos.y + UV_UI.W(w * 0.044), UV_UI.W(w * 0.041), UV_UI.W(w * 0.009), health, 5, speedocol.health, 220 )

	surface.SetMaterial(Material("unitvehicles/speedometers/ug2/3rdperson_turbodial_custom_" .. cvs.gaugetype .. ".png"))
	surface.SetDrawColor(speedocol.needle)

	surface.DrawTexturedRectRotated( speedopos.x - UV_UI.W(w * 0.121), speedopos.y + UV_UI.W(w * 0.044), UV_UI.W(w * 0.02), UV_UI.W(w * 0.075), healthAngle )
	
	-- [[ RPM ]] --
	local speedStr = tostring(speed)

	surface.SetFont("UVMWFont7Smaller")
	local digitW, _ = UV_UI.W(w * 0.0125)

	local baseX = speedopos.x + UV_UI.W(w * 0.07)
	local yPos = speedopos.y + UV_UI.W(h * 0.005)

	for i = 1, #speedStr do
        local digitChar = string.sub( speedStr, i, i )
		local digitX = baseX - ( #speedStr - i)  * ( digitW + UV_UI.W(w * 0.0025) )
		draw.SimpleText(digitChar, "UVFont", digitX, yPos, speedocol.lettering, TEXT_ALIGN_RIGHT)
	end

	draw.SimpleText( UVString(spn), "UVFont-Smaller", speedopos.x + (h * 0.125), speedopos.y + (h * 0.05), speedocol.lettering, TEXT_ALIGN_RIGHT )

	local tachometer = {
		idle = 0,
		max = 225,
		direction = -1
	}

	ug2_rpm_lerp = Lerp(FrameTime() * 8, ug2_rpm_lerp or rpm, rpm)
	local rpmFrac = math.Clamp(ug2_rpm_lerp / maxrpm, 0, 1)
	local angle = tachometer.idle + tachometer.direction * (rpmFrac * (tachometer.max - tachometer.idle))

	if redlining then
		angle = angle + math.abs( math.Clamp( math.cos( RealTime() * redlinestrength ), 0, 1 ) * 5 )
	end

	surface.SetMaterial(Material("unitvehicles/speedometers/ug2/3rdperson_rpmdial_custom_" .. cvs.gaugetype .. ".png")) -- Needle
	surface.SetDrawColor(speedocol.needle)
	surface.DrawTexturedRectRotated( speedopos.x + UV_UI.W(w * 0.0025), speedopos.y - UV_UI.W(w * 0.00), UV_UI.W(w * 0.02), UV_UI.W(w * 0.17), angle )
end

UV_UI.speedometer.underground2.main = underground2_speedometer

UV_UI.speedometer.underground2.offsets = { x = 0.06, y = 0.25 }

UVMenu.CustomizeHUD = UVMenu.CustomizeHUD or {}

UVMenu.CustomizeHUD.underground2 = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1250),
		Height = UV.ScaleH(760),
		Description = true,
		-- ColorPreview = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "NFS: Underground 2",
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
						func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
				{ type = "label", text = "uv.speedo" },
				{ type = "slider", text = "uv.speedo", convar = "uvspeedo_underground2_gauge", min = 0, max = 10, decimals = 0 },
				{ type = "slider", text = "uv.ui.xaxis", desc = "uv.ui.xaxis.desc", convar = "uvspeedo_underground2_x", min = 0, max = 1, decimals = 3 },
				{ type = "slider", text = "uv.ui.yaxis", desc = "uv.ui.yaxis.desc", convar = "uvspeedo_underground2_y", min = 0, max = 1, decimals = 3 },
				{ type = "coloralpha", text = "uv.speedo.needle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_underground2_col_needle" },
				{ type = "coloralpha", text = "uv.speedo.lettering", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_underground2_col_lettering" },
				{ type = "coloralpha", text = "uv.speedo.face", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_underground2_col_gauge" },
			},
		}
	})
end
