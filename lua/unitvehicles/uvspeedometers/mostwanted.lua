UV.RegisterSpeedometer( "mostwanted", "NFS: Most Wanted" )

-- [[ Convars ]] --
-- Speedometer
CreateClientConVar("uvspeedo_mostwanted_gauge", 0, true, false)
CreateClientConVar("uvspeedo_mostwanted_x", 0.875, true, false)
CreateClientConVar("uvspeedo_mostwanted_y", 0.825, true, false)

-- Background colour
CreateClientConVar("uvspeedo_mostwanted_col_needle_r", 223, true, false)
CreateClientConVar("uvspeedo_mostwanted_col_needle_g", 184, true, false)
CreateClientConVar("uvspeedo_mostwanted_col_needle_b", 127, true, false)

CreateClientConVar("uvspeedo_mostwanted_col_lettering_r", 255, true, false)
CreateClientConVar("uvspeedo_mostwanted_col_lettering_g", 255, true, false)
CreateClientConVar("uvspeedo_mostwanted_col_lettering_b", 255, true, false)

CreateClientConVar("uvspeedo_mostwanted_col_gauge_r", 223, true, false)
CreateClientConVar("uvspeedo_mostwanted_col_gauge_g", 184, true, false)
CreateClientConVar("uvspeedo_mostwanted_col_gauge_b", 127, true, false)

UV_UI.speedometer = UV_UI.speedometer or {}
UV_UI.speedometer.mostwanted = UV_UI.speedometer.mostwanted or {}
UVMenu.CustomizeHUD = UVMenu.CustomizeHUD or {}

UVMenu.CustomizeHUD.mostwanted = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1250),
		Height = UV.ScaleH(760),
		Description = true,
		-- ColorPreview = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.ui.speedometer.cust",
				{ type = "label", text = "NFS: Most Wanted" },
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
						func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
				{ type = "slider", text = "uv.speedo", convar = "uvspeedo_mostwanted_gauge", min = 0, max = 10, decimals = 0 },
				{ type = "slider", text = "uv.ui.xaxis", desc = "uv.ui.xaxis.desc", convar = "uvspeedo_mostwanted_x", min = 0, max = 1, decimals = 3 },
				{ type = "slider", text = "uv.ui.yaxis", desc = "uv.ui.yaxis.desc", convar = "uvspeedo_mostwanted_y", min = 0, max = 1, decimals = 3 },
				{ type = "coloralpha", text = "uv.speedo.needle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_mostwanted_col_needle" },
				{ type = "coloralpha", text = "uv.speedo.lettering", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_mostwanted_col_lettering" },
				{ type = "coloralpha", text = "uv.speedo.face", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_mostwanted_col_gauge" },
			},
		}
	})
end

local function mostwanted_speedometer( ... )
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
		x = w * GetConVar("uvspeedo_mostwanted_x"):GetString(),
		y = h * GetConVar("uvspeedo_mostwanted_y"):GetString(),
	}

	local cvs = {
		gaugetype = GetConVar("uvspeedo_mostwanted_gauge"):GetString(),
		needle = {
			r = GetConVar("uvspeedo_mostwanted_col_needle_r"):GetInt(),
			g = GetConVar("uvspeedo_mostwanted_col_needle_g"):GetInt(),
			b = GetConVar("uvspeedo_mostwanted_col_needle_b"):GetInt(),
		},
		lettering = {
			r = GetConVar("uvspeedo_mostwanted_col_lettering_r"):GetInt(),
			g = GetConVar("uvspeedo_mostwanted_col_lettering_g"):GetInt(),
			b = GetConVar("uvspeedo_mostwanted_col_lettering_b"):GetInt(),
		},
		gauge = {
			r = GetConVar("uvspeedo_mostwanted_col_gauge_r"):GetInt(),
			g = GetConVar("uvspeedo_mostwanted_col_gauge_g"):GetInt(),
			b = GetConVar("uvspeedo_mostwanted_col_gauge_b"):GetInt(),
		},
	}

	local speedocol = {
		needle = Color(cvs.needle.r or 223,cvs.needle.g or 184,cvs.needle.b or 127),
		lettering = Color(cvs.lettering.r or 255,cvs.lettering.g or 255,cvs.lettering.b or 255),
		gauge = Color(cvs.gauge.r or 223,cvs.gauge.g or 184,cvs.gauge.b or 127),

		gearw = Color(0,0,0,100),
		extraoff = Color(0,0,0,150),
		nitrous = Color(25,255,25),
		speedbr = Color(223,184,127),
		health = Color(200,75,75),
	}

	if rpm >= maxrpm * 0.95 then
		speedocol.gearw = Color(255,255,255)
	end
	
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
			DrawMeter( speedopos.x, speedopos.y, (w * 0.092), (w * 0.006), 1, -130, speedocol.extraoff )
			DrawMeter( speedopos.x, speedopos.y, (w * 0.092), (w * 0.006), nitrous, -130, speedocol.nitrous )

			local nitrocol = nitrous <= 0 and speedocol.extraoff or speedocol.nitrous
			
			surface.SetDrawColor(nitrocol)
			surface.SetMaterial(Material("unitvehicles/speedometers/mw/n20_icon.png"))
			surface.DrawTexturedRectRotated( speedopos.x - (w * 0.08), speedopos.y + (w * 0.08), (w * 0.03), (w * 0.03), 0 )
			
			surface.SetMaterial(Material("unitvehicles/speedometers/mw/shift_up_icon.png"))
			surface.DrawTexturedRectRotated( speedopos.x - (w * 0.065), speedopos.y + (w * 0.075), (w * 0.01), (w * 0.01), -45 )
		end

		-- [[ Speedbreaker ]] --
		if game.SinglePlayer() and speedbreakerenabled then
			DrawMeter( speedopos.x, speedopos.y, (w * 0.092), (w * 0.006), 1, 50, speedocol.extraoff )
			DrawMeter( speedopos.x, speedopos.y, (w * 0.092), (w * 0.006), speedbreaker, 50, speedocol.speedbr )

			local spbcol = speedbreaker <= 0 and speedocol.extraoff or speedocol.speedbr
			
			surface.SetDrawColor(spbcol)
			surface.SetMaterial(Material("unitvehicles/speedometers/mw/persuit_icon.png"))
			surface.DrawTexturedRectRotated( speedopos.x + (w * 0.08), speedopos.y - (w * 0.08), (w * 0.03), (w * 0.03), 0 )
			
			surface.SetMaterial(Material("unitvehicles/speedometers/mw/shift_up_icon.png"))
			surface.DrawTexturedRectRotated( speedopos.x + (w * 0.065), speedopos.y - (w * 0.075), (w * 0.01), (w * 0.01), 135 )
		end
	end

	-- [[ Speedometer 00 ]] --
	surface.SetMaterial(Material("unitvehicles/speedometers/mw00/tach_fill_" .. cvs.gaugetype .. ".png", "mips smooth")) -- Background
	surface.SetDrawColor(speedocol.gauge)
	surface.DrawTexturedRectRotated( speedopos.x, speedopos.y, (w * 0.175), (w * 0.175), 0 )

	surface.SetMaterial(Material("unitvehicles/speedometers/mw00/10000_lines_" .. cvs.gaugetype .. ".png")) -- BG Filler
	surface.SetDrawColor(speedocol.lettering)
	surface.DrawTexturedRectRotated( speedopos.x, speedopos.y - (w * 0.001), (w * 0.17), (w * 0.17), 0 )

    draw.SimpleText("▲", "UVFont5UI", speedopos.x - (w * 0.008), speedopos.y - (h * 0.065), speedocol.gearw, TEXT_ALIGN_CENTER)
	draw.SimpleText( "8", "UVMWFont7Tiny", speedopos.x + (w * 0.007), speedopos.y - (h * 0.0725), Color(0,0,0,100), TEXT_ALIGN_CENTER )
	draw.SimpleText( gearText, "UVMWFont7Tiny", speedopos.x + (w * 0.013), speedopos.y - (h * 0.0725), Color(0,0,0), TEXT_ALIGN_RIGHT )
		
	-- [[ Health ]] --
	DrawMeter( speedopos.x, speedopos.y, (w * 0.078), (w * 0.007), health, -52.5, speedocol.health, 105 )

	surface.SetDrawColor(speedocol.lettering)
	surface.SetMaterial(Material("unitvehicles/speedometers/mw00/turbo_lines_0.png"))
	surface.DrawTexturedRectRotated( speedopos.x, speedopos.y - (w * 0.001), (w * 0.165), (w * 0.165), 0 )
	
	local speedStr = tostring(speed)

	surface.SetFont("UVMWFont7Smaller")
	local digitW, _ = (w * 0.0165)
	local spacing = digitW * 1

	local baseX = speedopos.x + (w * 0.027)
	local yPos = speedopos.y + (h * 0.0275)

	for i = 1, 3 do
		local digitX = baseX - ( 3 - i ) * ( digitW + (w * 0.0025) )
		draw.SimpleText("8", "UVMWFont7Smaller", digitX, yPos, Color(0,0,0,100), TEXT_ALIGN_RIGHT)
	end

	for i = 1, #speedStr do
        local digitChar = string.sub( speedStr, i, i )
		local digitX = baseX - ( #speedStr - i)  * ( digitW + (w * 0.0025) )
		draw.SimpleText(digitChar, "UVMWFont7Smaller", digitX, yPos, Color(0,0,0), TEXT_ALIGN_RIGHT)
	end

	draw.SimpleText( UVString(spn), "UVFont5Shadow", speedopos.x, speedopos.y + (h * 0.085), speedocol.lettering, TEXT_ALIGN_CENTER )

	local tachometer = {
		idle = -66.5,
		max = 161,
		direction = -1
	}

	mw_rpm_lerp = Lerp(FrameTime() * 8, mw_rpm_lerp or rpm, rpm)
	local rpmFrac = math.Clamp(mw_rpm_lerp / maxrpm, 0, 1)
	local angle = tachometer.idle + tachometer.direction * (rpmFrac * (tachometer.max - tachometer.idle))

	if redlining then
		angle = angle + math.abs( math.Clamp( math.cos( RealTime() * redlinestrength ), 0, 1 ) * 5 )
	end

	surface.SetMaterial(Material("unitvehicles/speedometers/mw00/tach_needle_" .. cvs.gaugetype .. ".png")) -- Needle
	surface.SetDrawColor(speedocol.needle)
	surface.DrawTexturedRectRotated( speedopos.x, speedopos.y, (w * 0.04), (w * 0.16), angle )
end

UV_UI.speedometer.mostwanted.main = mostwanted_speedometer

UV_UI.speedometer.mostwanted.offsets = { x = 0.06, y = 0.225 }