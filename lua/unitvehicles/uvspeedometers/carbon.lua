UV.RegisterSpeedometer( "carbon", "NFS: Carbon" )

-- [[ Convars ]] --
-- Speedometer
-- CreateClientConVar("uvspeedo_carbon_gauge", 0, true, false)
CreateClientConVar("uvspeedo_carbon_x", 0.875, true, false)
CreateClientConVar("uvspeedo_carbon_y", 0.825, true, false)

-- Background colour
CreateClientConVar("uvspeedo_carbon_col_needle_r", 86, true, false)
CreateClientConVar("uvspeedo_carbon_col_needle_g", 214, true, false)
CreateClientConVar("uvspeedo_carbon_col_needle_b", 205, true, false)

CreateClientConVar("uvspeedo_carbon_col_lettering_r", 255, true, false)
CreateClientConVar("uvspeedo_carbon_col_lettering_g", 255, true, false)
CreateClientConVar("uvspeedo_carbon_col_lettering_b", 255, true, false)

CreateClientConVar("uvspeedo_carbon_col_gauge_r", 86, true, false)
CreateClientConVar("uvspeedo_carbon_col_gauge_g", 214, true, false)
CreateClientConVar("uvspeedo_carbon_col_gauge_b", 205, true, false)

UV_UI.speedometer = UV_UI.speedometer or {}
UV_UI.speedometer.carbon = UV_UI.speedometer.carbon or {}
UVMenu.CustomizeSpeedo = UVMenu.CustomizeSpeedo or {}

UVMenu.CustomizeSpeedo.carbon = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1250),
		Height = UV.ScaleH(760),
		Description = true,
		-- ColorPreview = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.ui.speedometer.cust",
				{ type = "label", text = "NFS: Carbon" },
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
						func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
				{ type = "slider", text = "uv.ui.xaxis", desc = "uv.ui.xaxis.desc", convar = "uvspeedo_carbon_x", min = 0, max = 1, decimals = 3 },
				{ type = "slider", text = "uv.ui.yaxis", desc = "uv.ui.yaxis.desc", convar = "uvspeedo_carbon_y", min = 0, max = 1, decimals = 3 },
				{ type = "coloralpha", text = "uv.speedo.needle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_carbon_col_needle" },
				{ type = "coloralpha", text = "uv.speedo.lettering", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_carbon_col_lettering" },
				{ type = "coloralpha", text = "uv.speedo.face", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_carbon_col_gauge" },
			},
		}
	})
end

local function carbon_bar( progress, width, height, col, icon )
    local w = ScrW()
    local h = ScrH()

    local outlineX = width - (w * -0.05)
    local outlineY = height - (w * 0.1)
    local outlineW = (w * 0.135)
    local outlineH = (w * 0.0275)

    if icon then
        local iconX = outlineX + (w * 0.13)
        local iconY = outlineY + (w * -0.006)
        local iconW = (w * 0.04)
        local iconH = (w * 0.04)

        surface.SetDrawColor(progress > 0 and col.accent or col.empty)
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(iconX, iconY, iconW, iconH)
    end

    surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED"])
    surface.SetDrawColor(color_black)
    surface.DrawTexturedRect(outlineX, outlineY, outlineW, outlineH)

    local barMarginX = (w * 0.002)
    local barMarginY = (w * 0.0025)
    local innerX = outlineX + barMarginX
    local innerY = outlineY + barMarginY
    local innerW = (w * 0.13)
    local innerH = (w * 0.0225)

    surface.SetDrawColor( progress > 0 and col.accentFade or col.empty )
    surface.DrawTexturedRect(innerX, innerY, innerW, innerH)

    local T = math.Clamp((progress or 0) * innerW, 0, innerW)
    T = math.floor(T)

    surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED"])
    surface.SetDrawColor(col.accent)
    surface.DrawTexturedRectUV(innerX + (innerW - T), innerY, T, innerH, 0, 0, T / (innerW), 1)

end

local function carbon_speedometer( ... )
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
		x = w * (GetConVar("uvspeedo_carbon_x"):GetFloat()),
		y = h * (GetConVar("uvspeedo_carbon_y"):GetFloat()),
	}

	local cvs = {
		needle = {
			r = GetConVar("uvspeedo_carbon_col_needle_r"):GetInt(),
			g = GetConVar("uvspeedo_carbon_col_needle_g"):GetInt(),
			b = GetConVar("uvspeedo_carbon_col_needle_b"):GetInt(),
		},
		lettering = {
			r = GetConVar("uvspeedo_carbon_col_lettering_r"):GetInt(),
			g = GetConVar("uvspeedo_carbon_col_lettering_g"):GetInt(),
			b = GetConVar("uvspeedo_carbon_col_lettering_b"):GetInt(),
		},
		gauge = {
			r = GetConVar("uvspeedo_carbon_col_gauge_r"):GetInt(),
			g = GetConVar("uvspeedo_carbon_col_gauge_g"):GetInt(),
			b = GetConVar("uvspeedo_carbon_col_gauge_b"):GetInt(),
		},
	}

	local col = {
		needle = Color(cvs.needle.r, cvs.needle.g, cvs.needle.b),
		lettering = Color(cvs.lettering.r, cvs.lettering.g, cvs.lettering.b),
        letteringFade = Color(cvs.lettering.r * 0.75, cvs.lettering.g * 0.75, cvs.lettering.b * 0.75),
		gauge = Color(cvs.gauge.r, cvs.gauge.g, cvs.gauge.b),
		accent = Color(cvs.gauge.r, cvs.gauge.g, cvs.gauge.b),
        accentFade = Color(cvs.gauge.r * 0.5, cvs.gauge.g * 0.5, cvs.gauge.b * 0.5),
		redline = Color(196, 31, 31),
		empty = Color(98, 98, 98),
        shiftUp = Color(110, 110, 110, 180),
        shiftReady = Color(cvs.gauge.r, cvs.gauge.g, cvs.gauge.b),
        shiftRed = Color(196, 31, 31),
		barBg = Color(40, 40, 40, 180),
	}

	local spn = (speedname == "MPH") and (UVString and UVString("uv.mph") or "MPH") or (UVString and UVString("uv.kmh") or "KMH")

	local leftX = speedopos.x - (w * 0.165)
	local rightX = speedopos.x - (w * 0.01)
	local baseY = speedopos.y

    -- Speedo Background Fade

    local bgFadeMat = UVMaterials["HUD_BACKGROUND_BACKING"]
    if bgFadeMat then
        surface.SetDrawColor( color_white )
        surface.SetMaterial( bgFadeMat )
        surface.DrawTexturedRectRotated(speedopos.x - (w * 0.025), speedopos.y - (h * 0.005), (w * 0.2), (h * 0.2), 0)
    end

    local nitroIcon = UVMaterials["NOS_ICON"]
    carbon_bar( cffunctions and nitrousenabled and nitrous or 0, leftX, baseY - (w * -0.01), col, nitroIcon )

    local speedbreakerIcon = UVMaterials["SPEEDBREAKER_ICON"]
    carbon_bar( cffunctions and speedbreakerenabled and speedbreaker or 0, leftX, baseY - (w * -0.05), col, speedbreakerIcon )

	-- Speedometer
	local speedStr = tostring(speed)

	local digitW, _ = (w * 0.04)
	local spacing = digitW * 1

	local baseX = speedopos.x - (w * 0.01)
	local yPos = speedopos.y - (h * 0.025)

	for i = 1, 3 do
		local digitX = baseX - ( 3 - i ) * ( digitW + (w * -0.01) )
		draw.SimpleText("8", "UVCarbonMonoFont7", digitX, yPos, Color( col.lettering.r, col.lettering.g, col.lettering.b, 20  ), TEXT_ALIGN_RIGHT)
	end

	for i = 1, #speedStr do
        local digitChar = string.sub( speedStr, i, i )
		local digitX = baseX - ( #speedStr - i)  * ( digitW + (w * -0.01) )
		draw.SimpleTextOutlined(digitChar, "UVCarbonMonoFont7", digitX, yPos, col.lettering, TEXT_ALIGN_RIGHT, nil, 2, Color(0, 0, 0))
	end

	draw.SimpleText( UVString(spn), "UVCarbonFont-Smaller", speedopos.x - (w * 0.035), speedopos.y + (h * 0.055), col.letteringFade, TEXT_ALIGN_RIGHT )

    draw.SimpleTextOutlined( gearText, "UVCarbonFont", leftX + (w * 0.0375), baseY + (h * 0.00), col.accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.5, Color(0, 0, 0))

    local gearIcon = UVMaterials["HUD_GEAR"]
    if gearIcon then
        surface.SetDrawColor(col.accent)
        surface.SetMaterial(gearIcon)
        surface.DrawTexturedRectRotated(leftX + (w * 0.05), baseY + (w * 0.0125), (w * 0.03), (w * 0.03), 0)
    end

	-- RPM Tachometer
	local rpmFrac = (maxrpm and maxrpm > 0) and math.Clamp(rpm / maxrpm, 0, 1) or 0
	carbon_rpm_lerp = Lerp(FrameTime() * 8, carbon_rpm_lerp or rpmFrac, rpmFrac)
	rpmFrac = carbon_rpm_lerp

	local tachBgMat = UVMaterials["RPM_BACKING"]
	if tachBgMat:IsError() then
		tachBgMat = UVMaterials["RPM_COLOR"]
	end
	if not tachBgMat:IsError() then
		surface.SetDrawColor(color_black)
		surface.SetMaterial(tachBgMat)
		surface.DrawTexturedRectRotated(rightX + (w * 0.04), baseY - (w * 0.0025), (w * 0.1), (w * 0.165), 0)
	end

    local tachBgFillMat = UVMaterials["RPM_COLOR"]
    if tachBgFillMat:IsError() then
        tachBgFillMat = UVMaterials["RPM_COLOR"]
    end
    if not tachBgFillMat:IsError() then
        surface.SetDrawColor(col.accentFade)
        surface.SetMaterial(tachBgFillMat)
        surface.DrawTexturedRectRotated(rightX + (w * 0.04), baseY - (w * 0.0025), (w * 0.1), (w * 0.165), 0)
    end

	local tachFillMat = UVMaterials["RPM_COLOR"]
	local tachFillUVMat = UVMaterials["RPM_COLOR"]
    local redlineColor = col.redline
    local needleColor = col.needle
    local setColor = needleColor

    if rpmFrac >= 0.8 then
        local yellow = { r = 102, g = 102, b = 0 }
        if rpmFrac < 0.85 then
            local t = math.Remap(rpmFrac, 0.8, 0.85, 0, 1)
            local needleR = Lerp(t, needleColor.r, yellow.r)
            local needleG = Lerp(t, needleColor.g, yellow.g)
            local needleB = Lerp(t, needleColor.b, yellow.b)
            setColor = Color(needleR, needleG, needleB)
        else
            local t = math.Remap(rpmFrac, 0.85, 1, 0, 1)
            local needleR = Lerp(t, yellow.r, redlineColor.r)
            local needleG = Lerp(t, yellow.g, redlineColor.g)
            local needleB = Lerp(t, yellow.b, redlineColor.b)
            setColor = Color(needleR, needleG, needleB)
        end
    end

    surface.SetDrawColor(setColor)
	surface.SetMaterial(tachFillUVMat)

    -- i remapped the value according to the current texture, change if needed
	local rectW = (w * 0.1)
	local rectH = (w * 0.165)

	local rectCenterX = rightX + (w * 0.04)
	local rectCenterY = baseY - (w * 0.0025)

	local rectX = rectCenterX - rectW * 0.5
	local rectTop = rectCenterY - rectH * 0.5

	-- i remapped the value according to the current texture, change if needed
	local frac = math.Remap(rpmFrac, 0, 1, 0.15, 0.85)

	local th = rectH * frac
	local fillY = rectTop + (rectH - th)

	surface.DrawTexturedRectUV( rectX, fillY, rectW, th, 0, 1 - frac, 1, 1 )

    local tachLabelType = maxrpm >= 10000 and "RPM_10000" or "RPM_8000"
    local tachLabelMat = UVMaterials[tachLabelType]

    local tachOffsets = {
        ["RPM_8000"] = {
            x = (w * 0.03),
            y = (w * 0.0),
        },
        ["RPM_10000"] = {
            x = (w * 0.035),
            y = (w * 0.005),
        },
    }

    if tachLabelMat then
        surface.SetDrawColor(col.accent)
        surface.SetMaterial(tachLabelMat)
        surface.DrawTexturedRectRotated(rectCenterX + tachOffsets[tachLabelType].x, baseY + tachOffsets[tachLabelType].y, rectW, rectH, 4.5)
    end

    -- Shift Up Logic
    local shiftUpIcon = UVMaterials["SHIFT_ICON_NORMAL"]
    if shiftUpIcon and not shiftUpIcon:IsError() then
        local color = col.shiftUp
        if rpmFrac >= 0.8 and rpmFrac < 0.9 then
            color = col.shiftReady
            color.a = 255 * math.abs( math.sin( CurTime() * 2 ) )
        elseif rpmFrac >= 0.9 then
            color = col.shiftRed
            color.a = 255 * math.abs( math.sin( CurTime() * 6 ) )
        end
        surface.SetDrawColor( color )
        surface.SetMaterial( shiftUpIcon )
        surface.DrawTexturedRect(rightX + (w * 0.0595), baseY - (w * 0.09), (w * 0.037), (w * 0.037))
    end
end

UV_UI.speedometer.carbon.main = carbon_speedometer

UV_UI.speedometer.carbon.offsets = { x = 0.1025, y = 0.24 }