UV_UI.general = UV_UI.general or {}

local function uv_general()
    local hudyes = GetConVar("cl_drawhud"):GetBool()
    if not hudyes then return end

    local w, h = ScrW(), ScrH()
    local vehicle = LocalPlayer():GetVehicle()
    if not IsValid(vehicle) then
        UVHUDPursuitTech = nil
        return
    end

    UVHUDPursuitTech = vehicle.PursuitTech or (IsValid(vehicle:GetParent()) and vehicle:GetParent().PursuitTech) or nil
    if not UVHUDPursuitTech then return end

    local PT_Replacement_Strings = {
        ['EMP'] = '#uv.ptech.emp.short',
        ['ESF'] = '#uv.ptech.esf.short',
        ['Killswitch'] = '#uv.ptech.killswitch.short',
        ['Jammer'] = '#uv.ptech.jammer.short',
        ['Shockwave'] = '#uv.ptech.shockwave.short',
        ['Stunmine'] = '#uv.ptech.stunmine.short',
        ['Spikestrip'] = '#uv.ptech.spikes.short',
        ['Repair Kit'] = '#uv.ptech.repairkit.short',
        ['Power Play'] = '#uv.ptech.powerplay.short',
        ['Shock Ram'] = '#uv.ptech.shockram.short',
        ['GPS Dart'] = '#uv.ptech.gpsdart.short',
        ['Juggernaut'] = '#uv.ptech.juggernaut.short',
    }

	-- local debugjam = true

    -- if not debugjam then
    if not uvclientjammed then
        for i = 1, 2 do
            local keyCode = GetConVar("unitvehicle_pursuittech_keybindslot_" .. i):GetInt()
            local tech = UVHUDPursuitTech[i]

            local xOffset = 0.815 + ((i - 1) * 0.0595)
            local y = h * 0.6
            local bw, bh = w * 0.06, h * 0.06
            local x = w * xOffset
            local keyX = w * (0.8425 + ((i - 1) * 0.0625))
            local textX = w * (0.8425 + ((i - 1) * 0.0625))
            local keyY = h * 0.57

            local bgColor = Color(0, 0, 0, 225)
            local fillOverlayColor = nil
            local fillFrac = 0
            local showFillOverlay = false
            local textColor = Color(255, 255, 255, 125)
            local keyColor = Color(255, 255, 255, 125)
            local ammoText, techText = " - ", " - "
            local keyText = UVBindButtonName(keyCode)
			
			
            -- local bw, bh = UV_UI.W(w * 0.06), h * 0.06
            -- local x = UV_UI.X(w * xOffset)
            -- local keyX = UV_UI.X(w * (0.8425 + ((i - 1) * 0.0625)))
            -- local textX = UV_UI.X(w * (0.8425 + ((i - 1) * 0.0625)))

            if tech then
                -- Handle key press as before
                if input.IsKeyDown(keyCode) and not gui.IsGameUIVisible() and vgui.GetKeyboardFocus() == nil then
                    net.Start("UVPTUse")
                    net.WriteInt(i, 16)
                    net.SendToServer()
                end

                -- Duration-aware cooldown
                local timeSinceUsed = CurTime() - tech.LastUsed
                local duration = tech.Duration or 0
                local inDuration = duration > 0 and timeSinceUsed <= duration
                local inCooldown = tech.Ammo > 0 and timeSinceUsed <= (duration > 0 and duration + tech.Cooldown or tech.Cooldown)

                if inDuration then
                    fillFrac = math.Clamp(timeSinceUsed / duration, 0, 1)
                    showFillOverlay = true
                elseif inCooldown then
                    fillFrac = math.Clamp((timeSinceUsed - duration) / tech.Cooldown, 0, 1)
                    showFillOverlay = true
                end

                -- Choose overlay color
                if showFillOverlay then
                    local blink = 255 * math.abs(math.sin(RealTime() * 3))
                    fillOverlayColor = Color(blink, blink, 0, 175)
                else
                    bgColor = tech.Ammo > 0 and Color(100, 255, 100, 175) or Color(200, 0, 0, 175)
                    textColor = tech.Ammo > 0 and Color(255, 255, 255) or Color(255, 75, 75)
                    keyColor = tech.Ammo > 0 and Color(255, 255, 255) or Color(255, 75, 75)
                end

                ammoText = tech.Ammo > 0 and tech.Ammo or " - "
                techText = PT_Replacement_Strings[tech.Tech] or tech.Tech
            end

            if hudyes then
				if i == 1 then
					surface.SetMaterial(UVMaterials["PT_LEFT_BG"])
				else
					surface.SetMaterial(UVMaterials["PT_RIGHT_BG"])
				end
				surface.SetDrawColor(Color(0,0,0,125))
                surface.DrawTexturedRect(x, y, bw, bh)

				if i == 1 then
					surface.SetMaterial(UVMaterials["PT_LEFT"])
				else
					surface.SetMaterial(UVMaterials["PT_RIGHT"])
				end
                surface.SetDrawColor(bgColor)
                surface.DrawTexturedRect(x, y, bw, bh)

				if showFillOverlay and fillOverlayColor then
					surface.SetDrawColor(fillOverlayColor)

					if i == 1 then
						surface.SetMaterial(UVMaterials["PT_LEFT"])
						local T = math.Clamp(fillFrac * bw, 0, bw)
						-- surface.DrawTexturedRectUV( x + (bw - T), y, T, bh, 1 - (T / bw), 0, 1, 1 )
						surface.DrawTexturedRectUV( x, y, T, bh, 0, 0, T / bw, 1 )
					else
						surface.SetMaterial(UVMaterials["PT_RIGHT"])
						local T = math.Clamp(fillFrac * bw, 0, bw)
						surface.DrawTexturedRectUV( x, y, T, bh, 0, 0, T / bw, 1 )
					end
				end

				draw.SimpleTextOutlined( techText, "UVMostWantedLeaderboardFont", textX, y + (h * 0.0075), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0,0,0))
				draw.SimpleTextOutlined( ammoText, "UVMostWantedLeaderboardFont", textX, y + (h * 0.0275), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0,0,0))

				local mk = markup.Parse( UVReplaceKeybinds( "[key:unitvehicle_pursuittech_keybindslot_" .. i .. "]", "Big" ), w )
				mk:Draw(keyX, keyY, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end
	else
		local y = h * 0.6
		local textX = w * 0.87375
		local blink = 255 * math.abs(math.sin(RealTime() * 6))

		draw.SimpleTextOutlined( UVString("uv.ptech.jammer.hit.you"), "UVMostWantedLeaderboardFont", textX, y + (h * 0.0175), Color(255, 0, 0, blink), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0,0,0,blink))
    end
end

UV_UI.general.main = uv_general

UV_UI.general.states = {
	notificationQueue = {},
	notificationActive = false,
	closing = false,
	closingStartTime = nil,
	ptext = nil,
	startTime = nil,
}

UV_UI.general.events = {
	CenterNotification = function(params)
		local ptext = params.text or "REPLACEME"
		local pcol = params.color or Color( 255, 255, 255 )
		local immediate = params.immediate or nil
		local iscritical = params.critical or nil
		local notitimer = params.timer or 1

		local StartClosing
		local closing = false
		local closeStartTime = nil

		-- Handle queue logic
		if UV_UI.general.states.notificationActive then
			if immediate then
				-- Retain critical entries only
				local retainedQueue = {}
				for _, v in ipairs(UV_UI.general.states.notificationQueue) do
					if v.critical then
						table.insert(retainedQueue, v)
					end
				end

				UV_UI.general.states.notificationQueue = retainedQueue
				table.insert(UV_UI.general.states.notificationQueue, 1, params)

				timer.Simple(0, function()
					if not closing and StartClosing then
						StartClosing()
					end
				end)
			else
				table.insert(UV_UI.general.states.notificationQueue, params)
			end
			return
		end

		UV_UI.general.states.notificationActive = true

		local hookName = "UV_CENTERNOTI_PURSUITTECH"
		local displayDuration = 3
		local w, h = ScrW(), ScrH()
		local startTime = CurTime()
		local closing = false
		local closeStartTime = nil

		local delay = 0.1
		local expandDuration = 0.15
		local whiteFadeInDuration = 0.0175
		local blackFadeOutDuration = 0.65

		local expandStart = delay
		local whiteStart = expandStart + expandDuration
		local blackStart = whiteStart + whiteFadeInDuration

		-- Remove any prior hook
		hook.Remove("HUDPaint", hookName)

		StartClosing = function()
			if closing then return end
			closing = true
			closeStartTime = CurTime()

			-- Ensure we clean everything after closing finishes
			timer.Create("UV_CENTERNOTI_CLEANUP", expandDuration, 1, function()
				hook.Remove("HUDPaint", hookName)
				UV_UI.general.states.notificationActive = false

				if #UV_UI.general.states.notificationQueue > 0 then
					local nextParams = table.remove(UV_UI.general.states.notificationQueue, 1)
					-- If the queued entry has 'immediate', allow mid-close interruption next round
					timer.Simple(0, function()
						UV_UI.general.events.CenterNotification(nextParams)
					end)
				end
			end)
		end

		-- Mid-life force-close handler for 'immediate' queueing
		timer.Create("UV_CENTERNOTI_FORCECHECK", 0.05, 0, function()
			if CurTime() - startTime >= notitimer and not closing and #UV_UI.general.states.notificationQueue > 0 then
				StartClosing()
				timer.Remove("UV_CENTERNOTI_FORCECHECK")
			end
		end)

		-- Regular close trigger
		timer.Create("UV_CENTERNOTI_TIMER", displayDuration - expandDuration, 1, function()
			if not closing then
				StartClosing()
			end
			timer.Remove("UV_CENTERNOTI_FORCECHECK")
		end)

		hook.Add("HUDPaint", hookName, function()
			local showhud = GetConVar("cl_drawhud"):GetBool()
			local now = CurTime()
			local realTime = RealTime()
			local animTime = now - startTime
			local barProgress = 0
			local currentWidth
			local text = UVString(UV_CurrentSubtitle)
			local hasValidSubtitle = UV_CurrentSubtitle and text ~= "" and text ~= UV_CurrentSubtitle and CurTime() < (UV_SubtitleEnd or 0)
			local subconvar = GetConVar("unitvehicle_subtitles"):GetBool() and hasValidSubtitle

			if closing then
				local closeAnimTime = now - closeStartTime
				barProgress = 1 - math.Clamp(closeAnimTime / expandDuration, 0, 1)
				currentWidth = Lerp(barProgress, 0, w)
			else
				if animTime >= expandStart then
					barProgress = math.Clamp((animTime - expandStart) / expandDuration, 0, 1)
				end
				currentWidth = Lerp(barProgress, 0, w)
			end

			local barHeight = h * 0.175
			local barX = (w - currentWidth) / 2
			local barY = h * (subconvar and 0.575 or 0.675)

			-- Color Fade Logic
			local colorVal = 0
			if animTime >= whiteStart and animTime < blackStart then
				local p = (animTime - whiteStart) / whiteFadeInDuration
				colorVal = Lerp(math.Clamp(p, 0, 1), 0, 255)
			elseif animTime >= blackStart then
				local p = (animTime - blackStart) / blackFadeOutDuration
				colorVal = Lerp(math.Clamp(p, 0, 1), 255, 0)
			end

			if closing then
				-- Fade out during closing
				local closeAnimTime = now - closeStartTime
				local fade = 1 - math.Clamp(closeAnimTime / expandDuration, 0, 1)
				colorVal = colorVal * fade
			end
			
			
			if not showhud then return end

			-- Draw bar
			surface.SetMaterial(UVMaterials["COOLDOWNBG_WORLD"])
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawTexturedRect(barX, barY, currentWidth, barHeight)
			
			surface.SetMaterial(UVMaterials["PT_BG"])
			surface.SetDrawColor(Color(colorVal, colorVal, colorVal, 150))
			surface.DrawTexturedRect(barX, barY, currentWidth, barHeight)

			-- Text
			if animTime >= whiteStart then
				local outlineAlpha = math.Clamp(255 - colorVal, 0, 255)

				if closing then
					local closeAnimTime = now - closeStartTime
					local fade = 1 - math.Clamp(closeAnimTime / expandDuration, 0, 1)
					outlineAlpha = outlineAlpha * fade
				end
				
				mw_noti_draw(showhud and ptext, "UVFont5Shadow", w * 0.5, h * (subconvar and 0.66 or 0.76), pcol, pcolbg) -- Subconvar > barY + 0.095
			end
		end)
	end,
}

UV_UI.general.racing = {}

UV_UI.general.racing.SplitDiffCache = UV_UI.general.racing.SplitDiffCache or {}

local function general_racing_main( ... )
    local w = ScrW()
    local h = ScrH()
    
    local my_vehicle = select(1, ...)
    local my_array = select(2, ...)
    local string_array = select(3, ...)

    local racer_count = #string_array
    if racer_count <= 1 then return end

    local checkpoint_count = #my_array["Checkpoints"]
    
    -- Find local player's index
    local myIndex
    for i = 1, #string_array do
        if string_array[i][2] then -- is_local_player
            myIndex = i
            break
        end
    end
    if not myIndex then return end

    local aheadText, behindText = "N/A", "N/A"

    -- Check nearest ahead racer
    for i = myIndex - 1, 1, -1 do
        local entry = string_array[i]
        if entry[3] == "Lap" and entry[4] then
			local laps = math.abs(entry[4])
			local lapText = (laps > 1) and UVString("uv.race.suffix.laps") or UVString("uv.race.suffix.lap")
			aheadText = string.format(lapText, laps)
            break
        elseif entry[4] then
            aheadText = string.format("%.2f", math.abs(entry[4]))
            break
        end
    end

    -- Check nearest behind racer
    for i = myIndex + 1, #string_array do
        local entry = string_array[i]
        if entry[3] == "Lap" and entry[4] then
			local laps = math.abs(entry[4])
			local lapText = (laps > 1) and UVString("uv.race.suffix.laps") or UVString("uv.race.suffix.lap")
			behindText = string.format(lapText, laps)
            break
        elseif entry[4] then
            behindText = string.format("%.2f", math.abs(entry[4]))
            break
        end
    end

	-- draw.SimpleTextOutlined( -- Debug
		-- "DEBUG Leaderboard Diffs - Ahead: " .. aheadText .. " | Behind: " .. behindText,
		-- "DermaDefaultBold",
		-- ScrW() * 0.5,
		-- 20,
		-- Color(255, 255, 0),
		-- TEXT_ALIGN_CENTER,
		-- TEXT_ALIGN_TOP,
		-- 1,
		-- Color(0,0,0)
	-- )
	
	UV_UI.general.racing.SplitDiffCache[my_vehicle] = { -- Store said debug data
		Ahead = aheadText,
		Behind = behindText,
		LastCheckpoint = checkpoint_count -- optional
	}

end

UV_UI.general.racing.main = general_racing_main