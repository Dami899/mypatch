UV.RegisterHUD( "undercover", "NFS: Undercover", true )

local function DrawScaledCenteredTextLines(text, font, x, y, color, scale)
    surface.SetFont(font)
    local lines = string.Explode("\n", text)
    local totalHeight = 0
    local lineHeights, lineWidths = {}, {}
    
    for _, line in ipairs(lines) do
        local w, h = surface.GetTextSize(line)
        table.insert(lineWidths, w)
        table.insert(lineHeights, h)
        totalHeight = totalHeight + h
    end
    
    local currentY = y - totalHeight * scale / 2
    
    for i, line in ipairs(lines) do
        local w, h = lineWidths[i], lineHeights[i]
        local mat = Matrix()
        mat:Scale(Vector(scale, scale, 1))
        mat:SetTranslation(Vector(x - w / 2 * scale, currentY, 0))
        
        cam.PushModelMatrix(mat)
		draw.SimpleTextOutlined(line, font, 0, 0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
        cam.PopModelMatrix()
        
        currentY = currentY + h * scale
    end
end

UV_UI.racing.undercover = UV_UI.racing.undercover or {}
UV_UI.pursuit.undercover = UV_UI.pursuit.undercover or {}

UV_UI.pursuit.undercover.states = {
    TagsColor = Color(255,255,255,150),
    WrecksColor = Color(255,255,255,150),
    UnitsColor = Color(255,255,255,150),
    BustedColor = Color(255, 255, 255, 50),
    EvasionColor = Color(255, 255, 255, 50),
    
    TakedownText = nil,
	BottomBarPos = 0.91,
	BottomBarPosMove = 0,
}

UV_UI.racing.undercover.states = {
    LapCompleteText = nil,
	notificationQueue = {},
	isNotificationActive = nil,
}

UV_UI.racing.undercover.events = {
	CenterNotification = function(params)
		local function StartNotification(p)
			local ptext = p.text or "ERROR: NO TEXT"
			local pcolor = p.color or Color(50, 255, 50)

			local anim = {
				startTime = CurTime(),
				duration = 3,
				endTime = CurTime() + 3,

				phase1Time = 0.1,
				phase2Time = 0.2,
				pulseDuration = 2.5,
				fadeDuration = 0.5,
				pulses = 3,

				scaleIn = 1.3,
				scaleMid = 1.0,
				scaleBreathIn = 0.95,
				scaleBreathOut = 1.05,
				scaleExit = 0.1,

				text = ptext,
				color = pcolor
			}

			UV_UI.racing.undercover.states.TakedownAnim = anim
			UV_UI.racing.undercover.states.isNotificationActive = true

			-- Register draw hook
			hook.Add("HUDPaint", "UV_CENTERNOTI_UNDERCOVER", function()
				local a = UV_UI.racing.undercover.states.TakedownAnim
				if not a then return end

				local now = CurTime()
				local t = now - a.startTime
				if now >= a.endTime then
					UV_UI.racing.undercover.states.TakedownAnim = nil
					UV_UI.racing.undercover.states.isNotificationActive = false
					hook.Remove("HUDPaint", "UV_CENTERNOTI_UNDERCOVER")

					-- Pop next from queue if available
					if #UV_UI.racing.undercover.states.notificationQueue > 0 then
						local nextParams = table.remove(UV_UI.racing.undercover.states.notificationQueue, 1)
						timer.Simple(0.1, function()
							StartNotification(nextParams)
						end)
					end
					return
				end

				-- PHASE LOGIC
				local scale = a.scaleMid
				local alpha = 255
				local offsetY = 0
				local baseColor = a.color
				local t = CurTime() - a.startTime
				local phase3Start = a.phase2Time
				local phase3End = a.phase2Time + a.pulseDuration
				local phase4Start = phase3End
				local phase4End = a.endTime

				if t < a.phase1Time then
					scale = a.scaleIn
					alpha = 255
					baseColor = Color(255, 255, 255)
				elseif t < a.phase2Time then
					local p = (t - a.phase1Time) / (a.phase2Time - a.phase1Time)
					scale = Lerp(p, a.scaleIn, a.scaleMid)
				elseif t < phase3End then
					local p = (t - phase3Start) / a.pulseDuration
					local pulseT = (p * a.pulses) % 1

					if pulseT < 0.6 then
						scale = Lerp(pulseT / 0.6, a.scaleMid, a.scaleBreathIn)
					else
						scale = Lerp((pulseT - 0.6) / 0.4, a.scaleBreathIn, a.scaleBreathOut)
					end
				elseif t < phase4End then
					local p = (t - phase4Start) / a.fadeDuration
					scale = Lerp(p, a.scaleBreathOut, a.scaleExit)
					alpha = Lerp(p, 255, 0)
					offsetY = Lerp(p, 0, -30)
				end

				local x, y = ScrW() / 2, ScrH() / 2.7 + offsetY
				DrawScaledCenteredTextLines(a.text, "UVUndercoverWhiteFont", x, y, baseColor, scale)
			end)
		end

		-- Handle force param
		if params.immediate then
			-- Clear queue and interrupt current
			UV_UI.racing.undercover.states.notificationQueue = {}
			UV_UI.racing.undercover.states.TakedownAnim = nil
			UV_UI.racing.undercover.states.isNotificationActive = false
			hook.Remove("HUDPaint", "UV_CENTERNOTI_UNDERCOVER")
			StartNotification(params)
			return
		end

		-- If one is showing, queue this one
		if UV_UI.racing.undercover.states.isNotificationActive then
			table.insert(UV_UI.racing.undercover.states.notificationQueue, params)
		else
			StartNotification(params)
		end
	end,

    ShowResults = function(sortedRacers) -- Undercover
        if UVHUDDisplayRacing then return end
        
        local w = ScrW()
        local h = ScrH()
        
        --------------------------------------
        
        local debrieflinedata
        
        local BackgroundPanel = vgui.Create("DPanel")
        local ResultPanel = vgui.Create("DFrame")
        local OK = vgui.Create("DButton")
        
        BackgroundPanel:SetSize(w, h)
        BackgroundPanel:SetZPos(0)
        
        ResultPanel:Add(OK)
        ResultPanel:SetSize(w, h)
        ResultPanel:SetBackgroundBlur(true)
        ResultPanel:ShowCloseButton(false)
        ResultPanel:Center()
        ResultPanel:SetTitle("")
        ResultPanel:SetDraggable(false)
        ResultPanel:SetKeyboardInputEnabled(false)
                		
        -- ResultPanel:MakePopup()
        ResultPanel:SetVisible(false)
		ResultPanel:MoveToFront()
		ResultPanel:RequestFocus()
		gui.EnableScreenClicker(true)

        OK:SetText("")
        OK:SetPos(w*0.33, h*0.745)
        OK:SetSize(w*0.33, h*0.06)
        OK:SetEnabled(true)
        OK.Paint = function() end
        
        local fadeStart = CurTime()
        local backgroundAlpha = 0
        local backgroundFadeDuration = 0.5  -- seconds
        local fadeComplete = false
        
        local function CloseResults()
            if IsValid(ResultPanel) then ResultPanel:Close() end
            if IsValid(BackgroundPanel) then BackgroundPanel:Remove() end
            hook.Remove("CreateMove", "JumpKeyCloseResults")
        end
        
        local closing = false
        local closeStart = 0
        local closeDuration = 0.5
        
        local zoomStart = CurTime() + backgroundFadeDuration
        local zoomDuration = 0.5
        local rowDelay = 0.15
        local numTotalRows = 16
        
        local autoCloseDelay = 30
        local animationStartTime = CurTime()
        local autoCloseStartTime = animationStartTime + ((numTotalRows - 1) * rowDelay) + zoomDuration
        
        -- Then your timer start time:
        local timestart = autoCloseStartTime
        
        local function startCloseAnimation()
            if closing then return end
			gui.EnableScreenClicker(false)
            closing = true
            closeStart = CurTime()
        end
        
        BackgroundPanel.Paint = function(self, w, h)
            local elapsed = CurTime() - fadeStart
            local alpha
            
            if not fadeComplete then
                alpha = math.min(175, (elapsed / backgroundFadeDuration) * 175)
                if alpha >= 175 then
                    fadeComplete = true
                    if IsValid(ResultPanel) then
                        ResultPanel:SetVisible(true)
                    end
                end
            elseif closing then
                local fadeOutElapsed = CurTime() - closeStart
                alpha = math.max(0, 175 * (1 - (fadeOutElapsed / closeDuration)))
            else
                alpha = 175
            end
            
            backgroundAlpha = alpha
            surface.SetDrawColor(5, 25, 150, backgroundAlpha)
            surface.DrawRect(0, 0, w, h)
        end
        
        local entriesToShow = 16
        local scrollOffset = 0
        
        ResultPanel.OnMouseWheeled = function(self, delta)
            local maxOffset = math.max(0, #sortedRacers - entriesToShow)
            scrollOffset = math.Clamp(scrollOffset - delta, 0, maxOffset)
        end
        
        local racersArray = {}
        
        -- Convert sortedRacers (whatever form) to a flat array if needed
        for _, racer in pairs(sortedRacers) do
            table.insert(racersArray, racer)
        end
        
        -- Sort by TotalTime (DNF = math.huge)
        table.sort(racersArray, function(a, b)
            local timeA = a.array and a.array.TotalTime
            local timeB = b.array and b.array.TotalTime
            
            -- Treat missing or non-numeric TotalTime as a large number (DNF)
            local tA = (type(timeA) == "number") and timeA or math.huge
            local tB = (type(timeB) == "number") and timeB or math.huge
            
            return tA < tB
        end)
        
        local racersDisplayData = {}
        
        for i = 1, #racersArray do
            local racer = racersArray[i]
            local info = racer.array or racer  -- fallback if 'array' doesn't exist
            local LBCol = Color(255, 255, 255)
            
            local name = info["Name"] or "Unknown"
            local totalTime = info["TotalTime"] and info["TotalTime"] or "#uv.race.suffix.dnf"
            
            if info["Busted"] then totalTime = "#uv.race.suffix.busted" end
            
            if info["LocalPlayer"] then
                LBCol = Color(255, 200, 50)
            end
            
            -- Combine pos and name for left column text
            -- local text = i .. "    " .. name
			
            table.insert(racersDisplayData, { pos = i, text = name, value = UV_FormatRaceEndTime(totalTime), color = LBCol })
        end
        
        -- Now assign this to the data your paint function uses:
        debrieflinedata = {}
        
        -- Fill with racer data for existing racers
        -- for i = 1, math.min(#racersDisplayData, numTotalRows) do
            -- debrieflinedata[i] = racersDisplayData[i]
        -- end
        
        -- Fill remaining rows with empty placeholders
        -- for i = #racersDisplayData + 1, numTotalRows do
            -- debrieflinedata[i] = { text = "", value = "", color = Color(255,255,255) }
        -- end
		
		debrieflinedata = racersDisplayData
        
        local statusString = "#uv.results.lost" -- default fallback
        
        local localIndex = nil
        local localTime = nil
        local secondPlaceTime = nil
        
        for i, info in ipairs(racersArray) do
            local racer = racersArray[i]
            local info = racer.array or racer  -- fallback if 'array' doesn't exist
            
            if info["LocalPlayer"] then
                localIndex = i
                localTime = tonumber(info["TotalTime"]) or math.huge
            elseif i == 2 then
                secondPlaceTime = tonumber(info["TotalTime"]) or math.huge
            end
        end
        
        if localIndex == 1 then
            local timeDiff = (secondPlaceTime or 0) - (localTime or 0)
            if timeDiff >= 10 then
                statusString = "#uv.results.dominated"
            else
                statusString = "#uv.results.won"
            end
        end
        
        ResultPanel.Paint = function(self, w, h)
            local now = CurTime()
            
            local zoomElapsed = closing and (now - closeStart) or (now - zoomStart)
            local zoomFrac = math.Clamp(zoomElapsed / zoomDuration, 0, 1)
            
            local function easeOutCubic(t) return 1 - (1 - t)^3 end
            local function easeInCubic(t) return t^3 end
            
            local easedFrac = closing and easeInCubic(zoomFrac) or easeOutCubic(zoomFrac)
            local zoomScale = Lerp(easedFrac, closing and 1.0 or 2.0, closing and 2.0 or 1.0)
            local panelAlpha = closing and (1 - easedFrac) or 1
            
            if closing and zoomFrac >= 1 then
                CloseResults()
                return
            end
            
            local mat = Matrix()
            mat:Translate(Vector(w*0.5, h*0.5, 0))
            mat:Scale(Vector(zoomScale, zoomScale, 1))
            mat:Translate(Vector(-(w*0.5), -(h*0.5), 0))
            
            local tabAlpha = math.floor(panelAlpha * 235)
            local textAlpha = math.floor(panelAlpha * 255)
            
            cam.Start2D()
            cam.PushModelMatrix(mat)
            local timeremaining = math.ceil(autoCloseDelay - (CurTime() - timestart))
            local lang = UVString
            
            -- Upper Results Tab
            surface.SetDrawColor( 0, 0, 0, tabAlpha )
            surface.DrawRect( w*0.33, h*0.15, w*0.33, h*0.06)
            
            draw.DrawText(statusString, "UVUndercoverWhiteFont", w*0.332, h*0.155, Color( 255, 200, 50, textAlpha ), TEXT_ALIGN_LEFT )
            
            -- Text
            local rowYOffsetBase = h * 0.21
            local rowYOffsetBaseAlt = h * (0.21 + 0.0325)
            
            local labelStartX, valueStartX = w * 0.25, w * 0.75 -- Offscreen starting points
            local labelTargetX, valueTargetX = w * 0.332, w * 0.6575
            
            for i = 1, numTotalRows do
                local rowStartTime = zoomStart + zoomDuration + (i - 1) * rowDelay
                local rowEndTime = rowStartTime + rowDelay
                local rowProgress = math.Clamp((CurTime() - rowStartTime) / rowDelay, 0, 1)
                local ease = 1 - math.pow(1 - rowProgress, 2)
                
                local isDark = i % 2 == 0
                local baseAlpha = isDark and 150 or 75
                local rowColor = isDark and Color(50, 50, 50) or Color(150, 150, 150)
                
                local yOffset = ((i % 2 == 1) and rowYOffsetBase or rowYOffsetBaseAlt) + math.floor((i - 1) / 2) * h * 0.0675
                local rowHeight = h * 0.035
                local rowWidth = w * 0.33
                local rowX = w * 0.33
                local halfWidth = rowWidth / 2
                local alpha = ease * baseAlpha * panelAlpha
                
                -- Animate left half
                local leftX = Lerp(ease, labelStartX, rowX)
                surface.SetDrawColor(rowColor.r, rowColor.g, rowColor.b, alpha)
                surface.DrawRect(leftX, yOffset, halfWidth + (h * 0.001), rowHeight)
                
                -- Animate right half
                local rightX = Lerp(ease, valueStartX, rowX + halfWidth)
                surface.DrawRect(rightX, yOffset, halfWidth, rowHeight)
            end
            
            for i = 1, entriesToShow do
                local dataIndex = i + scrollOffset
                local line = debrieflinedata[dataIndex]
                if not line then continue end -- Skip if no data for this row
                
                local rowStartTime = zoomStart + zoomDuration + (dataIndex - 1) * rowDelay
                local rowProgress = math.Clamp((CurTime() - rowStartTime) / rowDelay, 0, 1)
                local alpha = rowProgress * 255
                local ease = 1 - math.pow(1 - rowProgress, 2) -- smooth end
                
                local yOffset = ((i % 2 == 1) and rowYOffsetBase or rowYOffsetBaseAlt) + math.floor((i - 1) / 2) * h * 0.0675
                
                local labelX = Lerp(ease, labelStartX, labelTargetX)
                local valueX = Lerp(ease, valueStartX, valueTargetX)
                
                draw.SimpleText(line.pos, "UVUndercoverAccentFont", labelX, yOffset - (h * 0.0025),
                Color(line.color.r, line.color.g, line.color.b, alpha * panelAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(line.text, "UVUndercoverAccentFont", labelX + 40, yOffset - (h * 0.0025),
                Color(line.color.r, line.color.g, line.color.b, alpha * panelAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(tostring(line.value), "UVUndercoverAccentFont", valueX, yOffset - (h * 0.0025),
                Color(line.color.r, line.color.g, line.color.b, alpha * panelAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end
            
            -- Time remaining and closing					
            surface.SetDrawColor( 0, 0, 0, tabAlpha )
            surface.DrawRect( w*0.33, h*0.745, w*0.33, h*0.06)
            
            if timeremaining > autoCloseDelay then
                timeremaining = autoCloseDelay
            end
            
            local blink = 255 * math.abs(math.sin(RealTime() * 8))
            
            if scrollOffset > 0 then
                draw.SimpleText("▲", "UVFont5UI", w * 0.5, h * 0.1775, Color(255,255,255,blink), TEXT_ALIGN_CENTER)
            end
            
            if scrollOffset < #sortedRacers - entriesToShow then
                draw.SimpleText("▼", "UVFont5UI", w * 0.5, h * 0.7375, Color(255,255,255,blink), TEXT_ALIGN_CENTER)
            end

			local conttext = "<font=UVUndercoverAccentFont>" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue"), "Big") .. "</font>"
			local mk = markup.Parse(conttext)
			
			surface.SetAlphaMultiplier(textAlpha / 255)
			mk:Draw( w*0.5, h*0.755, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			surface.SetAlphaMultiplier(1)
			
            draw.DrawText( string.format( lang("uv.results.autoclose"), math.max(0, timeremaining) ), "UVUndercoverLeaderboardFont", w*0.5, h*0.815, Color( 255, 255, 255, textAlpha ), TEXT_ALIGN_CENTER )
            
            if timeremaining < 1 then
                startCloseAnimation()
            end
            
            cam.PopModelMatrix()
            cam.End2D()
        end
        
        function OK:DoClick() 
            startCloseAnimation()
            OK:SetEnabled(false)
        end

		hook.Add("CreateMove", "JumpKeyCloseResults", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if ply:KeyPressed(IN_JUMP) then
				if IsValid(ResultPanel) and not closing then
					hook.Remove("CreateMove", "JumpKeyCloseResults")
					startCloseAnimation()
				end
			end
		end)
    end,
    
    onRaceEnd = function( sortedRacers, stringArray )
        local triggerTime = CurTime()
        local duration = 10
        local glidetext = UVReplaceKeybinds( string.format( UVString("uv.race.finished.viewstats"),"[key:unitvehicle_keybind_raceresults]") )
        local glideicon = "unitvehicles/icons/INGAME_ICON_LEADERBOARD.png"
        
        -----------------------------------------

        if Glide then
            if not istable(sortedRacers) or #sortedRacers == 0 then
                glidetext = "#uv.race.finished.statserror"
                glideicon = "unitvehicles/icons/GENERIC_ALERT.png"
            end
            Glide.Notify({
                text = glidetext,
                lifetime = duration,
                immediate = true,
                icon = glideicon,
            }) 
        end
        
        hook.Add( "Think", "RaceResultDisplay", function()
            if CurTime() - triggerTime > duration then
                hook.Remove( 'Think', 'RaceResultDisplay' )
                return
            end
            
            if input.IsKeyDown( UVKeybindShowRaceResults:GetInt() ) and not gui.IsGameUIVisible() and vgui.GetKeyboardFocus() == nil then
                hook.Remove( 'Think', 'RaceResultDisplay' )
				if UVMenu.CurrentMenu and IsValid(UVMenu.CurrentMenu) then
					UVMenu.CloseCurrentMenu()
					timer.Simple(0.5, function()
						UV_UI.racing.undercover.events.ShowResults(sortedRacers)
					end)
					return
				end
                UV_UI.racing.undercover.events.ShowResults(sortedRacers)
            end
        end)
    end,

	onLapComplete = function( participant, new_lap, old_lap, lap_time, lap_time_cur, is_local_player, is_global_best, lap_final, local_finished, user_finished, suppress_lap_ui )
		local name = UVHUDRaceInfo.Participants[participant] and UVHUDRaceInfo.Participants[participant].Name or "Unknown"
		
		local cps = GetGlobalInt("uvrace_checkpoints")
		local participant_count = UVHUDRaceInfo.Participants and table.Count(UVHUDRaceInfo.Participants) or 0

		local finishtext = (participant_count > 1 and cps > 1) and 
		UVString("uv.race.finished") .. "\n" .. string.format( UVString("uv.race.finishspot"), UVString("uv.race.pos.num." .. UVHUDRaceCurrentPos) )
		or "#uv.race.finished"

		if local_finished then 
			UV_UI.racing.undercover.events.CenterNotification({
				text = finishtext,
			})
			return
		end
	
		if suppress_lap_ui then return end

		if is_global_best then
			UV_UI.racing.undercover.states.LapCompleteText = string.format(UVString("uv.race.fastest.laptime"), name, Carbon_FormatRaceTime( lap_time ) )
		else
			if is_local_player then
				UV_UI.racing.undercover.states.LapCompleteText = string.format(UVString("uv.race.laptime.carbon"), Carbon_FormatRaceTime( lap_time ) )
			else
				return
			end
		end
		
		UV_UI.racing.undercover.events.CenterNotification({
			text = UV_UI.racing.undercover.states.LapCompleteText,
			color = Color(0,194,255)
		})
    end,
	
	onParticipantDisqualified = function(data)
		local participant = data.Participant
		local is_local_player = data.is_local_player
		
		local info = UVHUDRaceInfo.Participants[participant]
		local name = info and info.Name or "Unknown"

		if not info then return end

		local disqtext = string.format(UVString("uv.race.wrecked"), name)
		if is_local_player then disqtext = "#uv.chase.wrecked" end

		UV_UI.racing.undercover.events.CenterNotification({
			text = disqtext,
			color = Color(255, 50, 50),
			immediate = is_local_player and true or false,
		})
	end,

	onLapSplit = function(participant, checkpoint, is_local_player, numParticipants)
		if not is_local_player then return end
		if numParticipants <= 1 then return end

		-- Use the participant vehicle directly
		local my_vehicle = participant
		if not IsValid(my_vehicle) then return end

		-- Pull cached diffs from general racing HUD
		local cached = UV_UI.general.racing.SplitDiffCache and UV_UI.general.racing.SplitDiffCache[my_vehicle]
		local aheadDiff, behindDiff = "N/A", "N/A"

		if cached then
			aheadDiff = cached.Ahead or "N/A"
			behindDiff = cached.Behind or "N/A"
		end

		-- CenterNoti itself
		local splittime = "--:--.---"
		local showahead = false
		local noticol = false

		if aheadDiff == "N/A" and behindDiff ~= "N/A" then -- 1st place
			splittime = behindDiff
		elseif aheadDiff ~= "N/A" then -- 2nd place or below
			splittime = "-" .. aheadDiff
			showahead = true
			noticol = Color(200, 75, 75)
		end
		
		local splittext = string.format( UVString("uv.race.splittime"), splittime )

		UV_UI.racing.undercover.events.CenterNotification({
			text = splittext,
			color = noticol,
			immediate = true,
		})
	end,

}

UV_UI.pursuit.undercover.events = {
	onUnitTakedown = function( unitType, name, bounty, bountyCombo, isPlayer )
		local uname = isPlayer and UVString( unitType .. ".caps" ) or name -- Fallback
		
		if GetConVar("unitvehicle_vehiclenametakedown"):GetBool() then
			uname = name and string.Trim(UVString(name), "#") or nil
		end
		
		UV_UI.racing.undercover.events.CenterNotification({
			text = string.format( UVString( "uv.hud.undercover.takedown" ), uname, bounty, bountyCombo ),
			immediate = true,
		})
    end,
    onUnitDeploy = function(...)
        local new_value = select (1, ...)
        local old_value = select (2, ...)
    end,
    
    onUnitWreck = function(...)
        hook.Remove("Think", "MW_WRECKS_COLOR_PULSE")
        
        if timer.Exists("MW_WRECKS_COLOR_PULSE_DELAY") then timer.Remove("MW_WRECKS_COLOR_PULSE_DELAY") end
        UV_UI.pursuit.mostwanted.states.WrecksColor = Color(255,255,0, 150)
        
        timer.Create("MW_WRECKS_COLOR_PULSE_DELAY", 1, 1, function()
            hook.Add("Think", "MW_WRECKS_COLOR_PULSE", function()
                UV_UI.pursuit.mostwanted.states.WrecksColor.b = UV_UI.pursuit.mostwanted.states.WrecksColor.b + 600 * RealFrameTime()
                if UV_UI.pursuit.mostwanted.states.WrecksColor.b >= 255 then hook.Remove("Think", "MW_WRECKS_COLOR_PULSE") end
            end)
        end)
        
    end,
    onUnitTag = function(...)
        
        hook.Remove("Think", "MW_TAGS_COLOR_PULSE")
        if timer.Exists("MW_TAGS_COLOR_PULSE_DELAY") then timer.Remove("MW_TAGS_COLOR_PULSE_DELAY") end
        
        UV_UI.pursuit.mostwanted.states.TagsColor = Color(255,255,0, 150)
        
        timer.Create("MW_TAGS_COLOR_PULSE_DELAY", 1, 1, function()
            
            hook.Add("Think", "MW_TAGS_COLOR_PULSE", function()
                UV_UI.pursuit.mostwanted.states.TagsColor.b = UV_UI.pursuit.mostwanted.states.TagsColor.b + 600 * RealFrameTime()
                if UV_UI.pursuit.mostwanted.states.TagsColor.b >= 255 then hook.Remove("Think", "MW_TAGS_COLOR_PULSE") end
            end)
            
        end)
        
    end,
    onResourceChange = function(...)
        
        local new_data = select( 1, ... )
        local old_data = select( 2, ... )
        
        hook.Remove("Think", "MW_RP_COLOR_PULSE")
        UV_UI.pursuit.mostwanted.states.UnitsColor = (new_data < (old_data or 0) and Color(255,50,50, 150)) or Color(50,255,50, 150)
        --UVResourcePointsColor = (rp_num < UVResourcePoints and Color(255,50,50)) or Color(50,255,50)
        
        local clrs = {}
        
        for _, v in pairs( { 'r', 'g', 'b' } ) do
            if UV_UI.pursuit.mostwanted.states.UnitsColor[v] ~= 255 then table.insert(clrs, v) end
        end 
        
        -- if timer.Exists("UVWrecksColor") then
        -- 	timer.Remove("UVWrecksColor")
        -- end
        local val = 50
        
        hook.Add("Think", "MW_RP_COLOR_PULSE", function()
            val = val + 200 * RealFrameTime()
            -- UVResourcePointsColor.b = val
            -- UVResourcePointsColor.g = val
            for _, v in pairs( clrs ) do
                UV_UI.pursuit.mostwanted.states.UnitsColor[v] = val
            end
            
            if val >= 255 then hook.Remove("Think", "MW_RP_COLOR_PULSE") end
        end)
        
    end,
    onChasingUnitsChange = function(...)
        
    end,
    onHeatLevelUpdate = function(...)
        
    end,
        
	onRacerBusted = function( racer, cop, lp )
		local cnt = string.format(UVString("uv.hud.racer.arrested"), racer, UVString(cop))
		
		if lp then
			cnt = "#uv.chase.busted"
		end

		UV_UI.racing.undercover.events.CenterNotification({
			text = cnt,
			color = Color(255,50,50),
			immediate = lp and true or false,
		})
	end,
	
    ShowDebrief = function(params) -- Undercover
        if UVHUDDisplayRacing then return end
        
        local w = ScrW()
        local h = ScrH()
        
        --------------------------------------
        
        local debriefdata = params.dataTable or escapedtable
        local debrieftitletext = params.titleText or "Title Text"
		local debriefunitspawn = params.spawnAsUnit or false
        
        local time = UVDisplayTime(UVTimerProgress)
        local unit = debriefdata["Unit"] or "Unknown"
        local deploys = debriefdata["Deploys"]
        local roadblocksdodged = debriefdata["Roadblocks"]
        local spikestripsdodged = debriefdata["Spikestrips"]
        local bounty = UVBounty
        local tags = UVTags
        local wrecks = UVWrecks
        local suspects = UVHUDWantedSuspectsNumber
        
        local lineData = {
            { text = "#uv.results.chase.costtostate", value = "$" .. bounty },
            { text = "#uv.results.chase.time", value = time },
            { text = "#uv.results.chase.units.deployed", value = deploys },
            { text = "#uv.results.chase.units.damaged", value = tags },
            { text = "#uv.results.chase.units.destroyed", value = wrecks },
            { text = "#uv.results.chase.dodged.blocks", value = roadblocksdodged },
            { text = "#uv.results.chase.dodged.spikes", value = spikestripsdodged },
        }
        
        local debrieflinedata = params.lineData or lineData
        local debriefcop = params.isCop or false
        
        local BackgroundPanel = vgui.Create("DPanel")
        local ResultPanel = vgui.Create("DFrame")
        local OK = vgui.Create("DButton")
        
        BackgroundPanel:SetSize(w, h)
        BackgroundPanel:SetZPos(0)
        
        ResultPanel:Add(OK)
        ResultPanel:SetSize(w, h)
        ResultPanel:SetBackgroundBlur(true)
        ResultPanel:ShowCloseButton(false)
        ResultPanel:Center()
        ResultPanel:SetTitle("")
        ResultPanel:SetDraggable(false)
        ResultPanel:SetKeyboardInputEnabled(false)
        		
        -- ResultPanel:MakePopup()
        ResultPanel:SetVisible(false)
		ResultPanel:MoveToFront()
		ResultPanel:RequestFocus()
		gui.EnableScreenClicker(true)

        OK:SetText("")
        OK:SetPos(w*0.33, h*0.6425)
        OK:SetSize(w*0.33, h*0.06)
        OK:SetEnabled(true)
        OK.Paint = function() end
        
        local fadeStart = CurTime()
        local backgroundAlpha = 0
        local backgroundFadeDuration = 0.5  -- seconds
        local fadeComplete = false
        
        local function CloseResults()
            if IsValid(ResultPanel) then ResultPanel:Close() end
            if IsValid(BackgroundPanel) then BackgroundPanel:Remove() end
            hook.Remove("CreateMove", "JumpKeyCloseDebrief")
            hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
        end
        
        local closing = false
        local closeStart = 0
        local closeDuration = 0.5
        
        local zoomStart = CurTime() + backgroundFadeDuration
        local zoomDuration = 0.5
        local rowDelay = 0.15
        local numTotalRows = 11
        
        local autoCloseDelay = 30
        local animationStartTime = CurTime()
        local autoCloseStartTime = animationStartTime + ((numTotalRows - 1) * rowDelay) + zoomDuration
        
        -- Then your timer start time:
        local timestart = autoCloseStartTime
        
        local function startCloseAnimation()
            if closing then return end
			gui.EnableScreenClicker(false)
            closing = true
            closeStart = CurTime()
        end
        
        BackgroundPanel.Paint = function(self, w, h)
            local elapsed = CurTime() - fadeStart
            local alpha
            
            if not fadeComplete then
                alpha = math.min(175, (elapsed / backgroundFadeDuration) * 175)
                if alpha >= 175 then
                    fadeComplete = true
                    if IsValid(ResultPanel) then
                        ResultPanel:SetVisible(true)
                    end
                end
            elseif closing then
                local fadeOutElapsed = CurTime() - closeStart
                alpha = math.max(0, 175 * (1 - (fadeOutElapsed / closeDuration)))
            else
                alpha = 175
            end
            
            backgroundAlpha = alpha
            surface.SetDrawColor(5, 25, 150, backgroundAlpha)
            surface.DrawRect(0, 0, w, h)
        end
        
        local bustedTabHeight = 0
        
        ResultPanel.Paint = function(self, w, h)
            local now = CurTime()
            
            local zoomElapsed = closing and (now - closeStart) or (now - zoomStart)
            local zoomFrac = math.Clamp(zoomElapsed / zoomDuration, 0, 1)
            
            local function easeOutCubic(t) return 1 - (1 - t)^3 end
            local function easeInCubic(t) return t^3 end
            
            local easedFrac = closing and easeInCubic(zoomFrac) or easeOutCubic(zoomFrac)
            local zoomScale = Lerp(easedFrac, closing and 1.0 or 2.0, closing and 2.0 or 1.0)
            local panelAlpha = closing and (1 - easedFrac) or 1
            
            if closing and zoomFrac >= 1 then
                CloseResults()
                return
            end
            
            local mat = Matrix()
            mat:Translate(Vector(w*0.5, h*0.5, 0))
            mat:Scale(Vector(zoomScale, zoomScale, 1))
            mat:Translate(Vector(-(w*0.5), -(h*0.5), 0))
            
            local tabAlpha = math.floor(panelAlpha * 235)
            local textAlpha = math.floor(panelAlpha * 255)
            
            cam.Start2D()
            cam.PushModelMatrix(mat)
            local timeremaining = math.ceil(autoCloseDelay - (CurTime() - timestart))
            local lang = UVString
            
            -- Upper Results Tab
            surface.SetDrawColor( 0, 0, 0, tabAlpha )
            surface.DrawRect( w*0.33, h*0.215, w*0.33, h*0.06)
            
            if debriefcop then
                local blend = (math.sin(CurTime() * 6) + 1) / 2
                surface.SetMaterial(UVMaterials["ARREST_LIGHT_UC"])
                surface.SetDrawColor(255 * blend, 0, 255 * (1 - blend), 175)
                surface.DrawTexturedRect(w * 0.33, h * 0.215, w * 0.33, h * 0.06)
                
                surface.SetMaterial(UVMaterials["ARREST_BG_UC"])
                surface.SetDrawColor(255, 255, 255, textAlpha)
                local bustedTabY = h * 0.2735
                bustedTabHeight = h * 0.03
                surface.DrawTexturedRect(w * 0.25, bustedTabY, w * 0.5, h * 0.06)
                
                numTotalRows = 10
            end
            
            draw.DrawText(debrieftitletext, "UVUndercoverWhiteFont", w*0.332, h*0.22, Color( 255, 200, 50, textAlpha ), TEXT_ALIGN_LEFT )
            
            -- Text
            local rowYOffsetBase = debriefcop and (h * 0.275 + bustedTabHeight) or h * 0.275
            local rowYOffsetBaseAlt = debriefcop and (h * 0.3075 + bustedTabHeight) or h * 0.3075
            
            local labelStartX, valueStartX = w * 0.25, w * 0.75 -- Offscreen starting points
            local labelTargetX, valueTargetX = w * 0.332, w * 0.6575
            
            for i = 1, numTotalRows do
                local rowStartTime = zoomStart + zoomDuration + (i - 1) * rowDelay
                local rowEndTime = rowStartTime + rowDelay
                local rowProgress = math.Clamp((CurTime() - rowStartTime) / rowDelay, 0, 1)
                local ease = 1 - math.pow(1 - rowProgress, 2)
                
                local isDark = i % 2 == 0
                local baseAlpha = isDark and 150 or 75
                local rowColor = isDark and Color(50, 50, 50) or Color(150, 150, 150)
                
                local yOffset = ((i % 2 == 1) and rowYOffsetBase or rowYOffsetBaseAlt) + math.floor((i - 1) / 2) * h * 0.0675
                local rowHeight = h * 0.035
                local rowWidth = w * 0.33
                local rowX = w * 0.33
                local halfWidth = rowWidth / 2
                local alpha = ease * baseAlpha * panelAlpha
                
                -- Animate left half
                local leftX = Lerp(ease, labelStartX, rowX)
                surface.SetDrawColor(rowColor.r, rowColor.g, rowColor.b, alpha)
                surface.DrawRect(leftX, yOffset, halfWidth + (h * 0.001), rowHeight)
                
                -- Animate right half
                local rightX = Lerp(ease, valueStartX, rowX + halfWidth)
                surface.DrawRect(rightX, yOffset, halfWidth, rowHeight)
            end
            
            for i, line in ipairs(debrieflinedata) do
                local rowStartTime = zoomStart + zoomDuration + (i - 1) * rowDelay
                local rowEndTime = rowStartTime + rowDelay
                local rowProgress = math.Clamp((CurTime() - rowStartTime) / rowDelay, 0, 1)
                local alpha = rowProgress * 255
                local ease = 1 - math.pow(1 - rowProgress, 2) -- smooth end
                
                local yOffset = ((i % 2 == 1) and rowYOffsetBase or rowYOffsetBaseAlt) + math.floor((i - 1) / 2) * h * 0.0675
                
                local labelX = Lerp(ease, labelStartX, labelTargetX)
                local valueX = Lerp(ease, valueStartX, valueTargetX)
                
                draw.SimpleText(line.text, "UVUndercoverAccentFont", labelX, yOffset, Color(255, 255, 255, alpha * panelAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(tostring(line.value), "UVUndercoverAccentFont", valueX, yOffset, Color(255, 255, 255, alpha * panelAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end
            
            -- Time remaining and closing					
            surface.SetDrawColor( 0, 0, 0, tabAlpha )
            surface.DrawRect( w*0.33, h*0.6425, w*0.33, h*0.06)
            
            if timeremaining > autoCloseDelay then
                timeremaining = autoCloseDelay
            end
			
			local cy, cx, cc = w*0.5, h*0.6525, TEXT_ALIGN_CENTER
			
			local conttext = "<font=UVUndercoverAccentFont>" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue"), "Big") .. "</font>"
			local mk = markup.Parse(conttext)

			local spawntext = "<font=UVUndercoverAccentFont>" .. UVReplaceKeybinds("[+reload] " .. UVString("uv.pm.spawnas"), "Big") .. "</font>"
			local mk2 = markup.Parse(spawntext)

			if debriefunitspawn and (UVHUDWantedSuspects and #UVHUDWantedSuspects > 0) then
				cy, cx, cc = w*0.6575, h*0.6375, TEXT_ALIGN_RIGHT

				surface.SetAlphaMultiplier(textAlpha / 255)
				mk2:Draw( w*0.6575, h*0.665, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				surface.SetAlphaMultiplier(1)
			end

			surface.SetAlphaMultiplier(textAlpha / 255)
			mk:Draw( cy, cx, cc, TEXT_ALIGN_TOP)
			surface.SetAlphaMultiplier(1)
			
            draw.DrawText( string.format( lang("uv.results.autoclose"), math.max(0, timeremaining) ), "UVUndercoverLeaderboardFont", w*0.5, h*0.71, Color( 255, 255, 255, textAlpha ), TEXT_ALIGN_CENTER )
            				
            if timeremaining < 1 then
                startCloseAnimation()
            end
            
            cam.PopModelMatrix()
            cam.End2D()
        end
        
        function OK:DoClick() 
            startCloseAnimation()
            OK:SetEnabled(false)
        end

		hook.Add("CreateMove", "JumpKeyCloseDebrief", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if ply:KeyPressed(IN_JUMP) then
				if IsValid(ResultPanel) and not closing then
					hook.Remove("CreateMove", "JumpKeyCloseDebrief")
					hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
					startCloseAnimation()
				end
			end
		end)

		if debriefunitspawn and (UVHUDWantedSuspects and #UVHUDWantedSuspects > 0) then
			hook.Add("CreateMove", "ReloadKeyCloseDebrief", function()
				local ply = LocalPlayer()
				if not IsValid(ply) then return end

				if ply:KeyPressed(IN_RELOAD) then
					if IsValid(ResultPanel) and not closing then
						gui.EnableScreenClicker(false)
						hook.Remove("CreateMove", "JumpKeyCloseDebrief")
						hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
						startCloseAnimation()

						net.Start("UVHUDRespawnInUVGetInfo")
						net.SendToServer()
					end
				end
			end)
		end
    end,
    
    onRacerEscapedDebrief = function(escapedtable)
        local params = {
            dataTable = escapedtable,
            titleText = "#uv.results.evaded",
        }
        UV_UI.pursuit.undercover.events.ShowDebrief(params)
    end,
    
    onRacerBustedDebrief = function(bustedtable)
        local unit = UVString(bustedtable["Unit"]) or "Unknown"
        local time = UVDisplayTime(UVTimerProgress)
        local deploys = bustedtable["Deploys"]
        local roadblocksdodged = bustedtable["Roadblocks"]
        local spikestripsdodged = bustedtable["Spikestrips"]
        local bounty = UVBounty
        local tags = UVTags
        local wrecks = UVWrecks
        
        local params = {
            isCop = true,
            dataTable = bustedtable,
            titleText = "#uv.results.busted",
            lineData = {
                { text = "#uv.results.bustedby.carbon", value = unit },
                { text = "#uv.results.chase.bounty", value = "$" .. bounty },
                { text = "#uv.results.chase.time", value = time },
                { text = "#uv.results.chase.units.deployed", value = deploys },
                { text = "#uv.results.chase.units.damaged", value = tags },
                { text = "#uv.results.chase.units.destroyed", value = wrecks },
                { text = "#uv.results.chase.dodged.blocks", value = roadblocksdodged },
                { text = "#uv.results.chase.dodged.spikes", value = spikestripsdodged },
            },
			spawnAsUnit = true,
        }
        UV_UI.pursuit.undercover.events.ShowDebrief(params)
    end,
    
    onCopBustedDebrief = function(bustedtable)
        local time = UVDisplayTime(UVTimerProgress)
        local deploys = bustedtable["Deploys"]
        local roadblocksdodged = bustedtable["Roadblocks"]
        local spikestripsdodged = bustedtable["Spikestrips"]
        local bounty = UVBounty
        local tags = UVTags
        local wrecks = UVWrecks
        local suspects = UVHUDWantedSuspectsNumber
        
        local params = {
            isCop = true,
            dataTable = bustedtable,
            titleText = "#uv.results.won",
            lineData = {
                { text = "#uv.results.suspects.busted", value = " " },
                { text = "#uv.results.chase.bounty", value = "$" .. bounty },
                { text = "#uv.results.chase.time", value = time },
                { text = "#uv.results.chase.units.deployed", value = deploys },
                { text = "#uv.results.chase.units.damaged", value = tags },
                { text = "#uv.results.chase.units.destroyed", value = wrecks },
                { text = "#uv.results.chase.dodged.blocks", value = roadblocksdodged },
                { text = "#uv.results.chase.dodged.spikes", value = spikestripsdodged },
            }
        }
        UV_UI.pursuit.undercover.events.ShowDebrief(params)
    end,
    
    onCopEscapedDebrief = function(escapedtable)
        local time = UVDisplayTime(UVTimerProgress)
        local deploys = escapedtable["Deploys"]
        local roadblocksdodged = escapedtable["Roadblocks"]
        local spikestripsdodged = escapedtable["Spikestrips"]
        local bounty = UVBounty
        local tags = UVTags
        local wrecks = UVWrecks
        local suspects = UVHUDWantedSuspectsNumber
        
        local params = {
            isCop = true,
            dataTable = escapedtable,
            titleText = "#uv.results.lost",
            lineData = {
                { text = "#uv.results.suspects.escaped.num.carbon", value = suspects },
                { text = "#uv.results.chase.bounty", value = "$" .. bounty },
                { text = "#uv.results.chase.time", value = time },
                { text = "#uv.results.chase.units.deployed", value = deploys },
                { text = "#uv.results.chase.units.damaged", value = tags },
                { text = "#uv.results.chase.units.destroyed", value = wrecks },
                { text = "#uv.results.chase.dodged.blocks", value = roadblocksdodged },
                { text = "#uv.results.chase.dodged.spikes", value = spikestripsdodged },
            }
        }
        UV_UI.pursuit.undercover.events.ShowDebrief(params)
    end,

	onPullOverRequest = function(...)
		UV_UI.racing.undercover.events.CenterNotification({
			text = UVString("uv.hud.fine.pullover"),
			color = Color(0,194,255),
			immediate = true,
		})
	end,
	onFined = function( finenr )
		UV_UI.racing.undercover.events.CenterNotification({
			text = string.format( UVString("uv.hud.fine.fined"), finenr),
			color = Color(0,194,255),
			immediate = true,
		})
	end,
}

local function undercover_racing_main( ... )
    local w = ScrW()
    local h = ScrH()
    
    local my_vehicle = select(1, ...)
    local my_array = select(2, ...)
    local string_array = select(3, ...)
    
    local racer_count = #string_array
    local lang = UVString
    
    local checkpoint_count = #my_array["Checkpoints"]
    
    ------------------------------------
    
    -- Timer
    draw.SimpleTextOutlined("#uv.race.hud.time", "UVUndercoverAccentFont", UV_UI.X(w * 0.75), h * 0.123, UVColors.Undercover_Accent2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    draw.SimpleTextOutlined(Carbon_FormatRaceTime((UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time)) or 0),"UVUndercoverWhiteFont", UV_UI.X(w * 0.75), h * 0.15, UVColors.Undercover_Accent1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
	
	local laptext = "REPLACEME"
	local lapamount = "REPLACEME"
	
    if UVHUDRaceInfo.Info.Laps > 1 then
		laptext = "#uv.race.hud.lap"
		lapamount = my_array.Lap .. "/" .. UVHUDRaceInfo.Info.Laps
    else
		laptext = "#uv.race.hud.complete"
		lapamount = math.floor(((checkpoint_count / GetGlobalInt("uvrace_checkpoints")) * 100)) .. "%"
    end
	
    draw.SimpleTextOutlined(laptext, "UVUndercoverAccentFont", UV_UI.X(w * 0.94), h * 0.123, UVColors.Undercover_Accent2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    draw.SimpleTextOutlined(lapamount, "UVUndercoverWhiteFont", UV_UI.X(w * 0.94), h * 0.15, UVColors.UVUndercoverWhiteFont, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
	
    surface.SetDrawColor(UVColors.Undercover_Accent2:Unpack())
    surface.DrawRect(UV_UI.X(w * 0.75), h * 0.195, UV_UI.W(w * 0.19), h * 0.005) -- Divider
    
    -- -- Racer List
    local alt = math.floor(CurTime() / 5) % 2 == 1 -- toggles every 5 seconds
    
    local baseY = h * 0.21 -- starting Y position of the list (adjust this freely)
    local spacing = h * 0.035 -- spacing between each racer (vertical gap)
    
    for i = 1, math.Clamp(racer_count, 1, 12), 1 do
        if racer_count == 1 then
            return
        end
        local entry = string_array[i]
        
        local racer_name = entry[1]
        local is_local_player = entry[2]
        local mode = entry[3]
        local diff = entry[4]
        
        --local racercount = i * w * 0.02
        local racercount = (i - 1) * spacing
        
        local status_text = "-----"
        
        local Strings = {
            ["Time"] = "%s",
            ["Lap"] = lang("uv.race.suffix.lap"),
            ["Laps"] = lang("uv.race.suffix.laps"),
            ["Finished"] = lang("uv.race.suffix.finished"),
            ["Disqualified"] = lang("uv.race.suffix.dnf"),
            ["Busted"] = lang("uv.race.suffix.busted"),
        }
        
		if entry[3] then
			local status_string = Strings[entry[3]]

			if status_string then
				local args = {}

				if entry[4] then
					local num = tonumber(entry[4])

					if entry[3] == "Lap" and num then
						-- choose singular/plural string
						local lapString = (math.abs(num) > 1) and Strings["Laps"] or Strings["Lap"]
						-- rebuild status_string so the format target is correct
						status_string = lapString
						num = ((num > 0 and "+ ") or "- ") .. tostring(math.abs(num))
					elseif num then
						num = ((num > 0 and "+ ") or "- ") .. string.format("%.2f", math.abs(num))
					end

					table.insert(args, num)
				end

				status_text = (#args <= 0) and status_string or string.format(status_string, unpack(args))
			end
		end

        local color = nil
        
        if is_local_player then
            color = UVColors.Undercover_Accent1
        elseif entry[3] == "Disqualified" or entry[3] == "Busted" then
            color = UVColors.Carbon_Disqualified
        else
            color = UVColors.Undercover_Accent2
        end
        
        local text = alt and (status_text) or (racer_name)

		surface.SetFont("UVUndercoverLeaderboardFont")
		local ymax = UV_UI.W(w * 0.14)
		textW = surface.GetTextSize(text)
		if textW > ymax then
			while surface.GetTextSize(text .. "...") > ymax do
				text = string.sub(text, 1, -2)
			end
			text = text .. "..."
		end

        -- This should only draw on LocalPlayer() but couldn't figure it out
        if is_local_player then
            surface.SetDrawColor(UVColors.Undercover_Accent2Transparent:Unpack())
            surface.DrawRect(UV_UI.X(w * 0.75), baseY + racercount, UV_UI.W(w * 0.19), h * 0.03)
        end

		draw.SimpleTextOutlined(text, "UVUndercoverLeaderboardFont", UV_UI.X(w * 0.76), baseY + racercount, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
		draw.SimpleTextOutlined(i, "UVUndercoverLeaderboardFont", UV_UI.X(w * 0.93), baseY + racercount, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
			
    end
end

local function undercover_pursuit_main( ... )
    local hudyes = GetConVar("cl_drawhud"):GetBool()
    
    if not hudyes then return end
    if not UVHUDDisplayPursuit then return end
    if UVHUDDisplayRacing then return end

    local vehicle = LocalPlayer():GetVehicle()
    
    local w = ScrW()
    local h = ScrH()
    local lang = UVString
    
    local UnitsChasing = tonumber(UVUnitsChasing)
    local UVBustTimer = BustedTimer:GetFloat()
    
    local states = UV_UI.pursuit.undercover.states
    
    local UVWrecksColor = states.WrecksColor
    local UVTagsColor = states.TagsColor
    local UVUnitsColor = states.UnitsColor
    
    --------------------------------------------------
    
    outofpursuit = CurTime()
    
    local UVHeatBountyMin
    local UVHeatBountyMax
    
    states.EvasionColor = Color(50, 173, 255)
    states.BustedColor = Color(255, 100, 100, 125)
    
    if vehicle == NULL then return end
    
    if UVHUDCopMode and not UVHUDDisplayNotification then
        UVHUDDisplayBusting = false
    end
    
    if UVHUDCopMode and next(UVHUDWantedSuspects) ~= nil then
        local ply = LocalPlayer()
        
        UVClosestSuspect = nil
        UVHUDDisplayBusting = false
        
        local closestDistance = math.huge
        
        for _, suspect in pairs(UVHUDWantedSuspects) do
            if IsValid(suspect) then
                local dist = ply:GetPos():DistToSqr(suspect:GetPos())
                
                if (#UVHUDWantedSuspects == 1 or dist < 250000) and dist < closestDistance then
                    closestDistance = dist
                    UVClosestSuspect = suspect
                end
            end
        end
        
        if UVClosestSuspect then
            if UVClosestSuspect.beingbusted then
                UVHUDDisplayBusting = true
                UVBustingProgress = UVClosestSuspect.UVBustingProgress or 0
                
                local blink = 255 * math.abs(math.sin(RealTime() * 8))
                states.BustedColor = Color(255, 100, 100, blink)
            end
        end
    end
    
    --if not UVHUDRace then
    local ResourceText = UVResourcePoints
    
    -- [[ Commander Stuff ]]
    if UVOneCommanderActive then
        if not UVHUDCommanderLastHealth or not UVHUDCommanderLastMaxHealth then
            UVHUDCommanderLastHealth = 0
            UVHUDCommanderLastMaxHealth = 0
        end
        if IsValid(UVHUDCommander) then
            if UVHUDCommander.IsSimfphyscar then
                UVHUDCommanderLastHealth = UVHUDCommander:GetCurHealth()
                UVHUDCommanderLastMaxHealth =
                UVUOneCommanderHealth:GetInt() - (UVHUDCommander:GetMaxHealth() * 0.3)
            elseif UVHUDCommander.IsGlideVehicle then
                local enginehealth = UVHUDCommander:GetEngineHealth()
                UVHUDCommanderLastHealth = UVHUDCommander:GetChassisHealth() * enginehealth
                UVHUDCommanderLastMaxHealth = UVUOneCommanderHealth:GetInt()
            elseif vcmod_main then
                UVHUDCommanderLastHealth =
                UVUOneCommanderHealth:GetInt() * (UVHUDCommander:VC_getHealth() / 100) --vcmod returns % health clientside
                UVHUDCommanderLastMaxHealth = UVUOneCommanderHealth:GetInt()
            else
                UVHUDCommanderLastHealth = UVHUDCommander:Health()
                UVHUDCommanderLastMaxHealth = UVUOneCommanderHealth:GetInt()
            end
        end
        local healthratio = UVHUDCommanderLastHealth / UVHUDCommanderLastMaxHealth
        local healthcolor
        local blink = 255 * math.abs(math.sin(RealTime() * 4))
        local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
        local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
        
        if healthratio >= 0.5 then
            healthcolor = Color(255, 255, 255, 200)
        elseif healthratio >= 0.25 then
            healthcolor = Color(255, blink, blink, 200)
        else
            healthcolor = Color(255, blink2, blink2, 200)
        end
        
        ResourceText = "⛊"
        surface.SetDrawColor(0, 0, 0, 100)
        draw.NoTexture()
        surface.DrawRect(UV_UI.XScaled(w * 0.345), 0, UV_UI.W(w * 0.314), h * 0.05)
        if healthratio > 0 then
            surface.SetDrawColor(Color(109, 109, 109, 200))
            surface.DrawRect(UV_UI.XScaled(w * 0.345), h * 0.05, UV_UI.W(w * 0.314), 8)
            surface.SetDrawColor(healthcolor)
            local T = math.Clamp((healthratio) * (UV_UI.W(w * 0.314)), 0, UV_UI.W(w * 0.314))
            surface.DrawRect(UV_UI.XScaled(w * 0.345), h * 0.05, T, 8)
        end
        draw.DrawText("⛊", "UVUndercoverWhiteFont", UV_UI.XScaled(w * 0.35), 0, UVColors.Undercover_Accent2, TEXT_ALIGN_LEFT)
        draw.DrawText("⛊", "UVUndercoverWhiteFont", UV_UI.XScaled(w * 0.65), 0, UVColors.Undercover_Accent2, TEXT_ALIGN_RIGHT)
        
        local cname = "#uv.unit.commander"
        if IsValid(UVHUDCommander) then
            local driver = UVHUDCommander:GetDriver()
            if IsValid(driver) and driver:IsPlayer() then
                cname = driver:Nick()
            end
        end
        
        draw.DrawText(cname,"UVUndercoverWhiteFont", w * 0.5, 0, UVColors.Undercover_Accent2,TEXT_ALIGN_CENTER)
    end
    
    -- [ Upper Right Info Box ] --
    -- Divider
    surface.SetDrawColor(UVColors.Undercover_Accent2:Unpack())
    surface.DrawRect(UV_UI.X(w * 0.75), h * 0.195, UV_UI.W(w * 0.19), h * 0.005)
    
    -- Timer
	draw.SimpleTextOutlined("#uv.race.hud.time", "UVUndercoverAccentFont", UV_UI.X(w * 0.75), h * 0.123, UVColors.Undercover_Accent2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
	
	draw.SimpleTextOutlined(UVTimer, "UVUndercoverWhiteFont", UV_UI.X(w * 0.75), h * 0.15, UVColors.Undercover_Accent1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )

    -- Bounty
    DrawIcon(UVMaterials["CTS_UC"], UV_UI.X(w * 0.76), h * 0.235, .06, UVColors.Undercover_Accent1) -- Icon
	draw.SimpleTextOutlined(UVBounty, "UVUndercoverWhiteFont", UV_UI.X(w * 0.775), h * 0.21, UVColors.Undercover_Accent1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )

    -- General Icons
    DrawIcon(UVMaterials["UNITS"], UV_UI.X(w * 0.76), h * 0.355, .06, UVColors.Undercover_Accent1)
    draw.SimpleTextOutlined(ResourceText .. (UVHUDDisplayBackupTimer and "   < " .. UVBackupTimer or ""), "UVUndercoverWhiteFont", UV_UI.X(w * 0.78), h * 0.3325, UVColors.Undercover_Accent1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )

    DrawIcon(UVMaterials["UNITS_DAMAGED"], UV_UI.X(w * 0.76), h * 0.415, .07, UVColors.Undercover_Accent1)
    draw.SimpleTextOutlined(UVTags, "UVUndercoverWhiteFont", UV_UI.X(w * 0.78), h * 0.3925, UVColors.Undercover_Accent1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    
    DrawIcon(UVMaterials["UNITS_DISABLED_UC"], UV_UI.X(w * 0.76), h * 0.475, .07, UVColors.Undercover_Accent1)
    draw.SimpleTextOutlined(UVWrecks, "UVUndercoverWhiteFont", UV_UI.X(w * 0.78), h * 0.4525, UVColors.Undercover_Accent1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    
    -- Heat Level
    DrawIcon(UVMaterials["HEAT"], UV_UI.X(w * 0.76), h * 0.295, .06, UVColors.Undercover_Accent1) -- Icon
    draw.SimpleTextOutlined("x" .. UVHeatLevel, "UVUndercoverWhiteFont", UV_UI.X(w * 0.8), h * 0.275, UVColors.Undercover_Accent1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )

    local UVHeatMinConVar = GetConVar( 'unitvehicle_unit_heatminimumbounty' .. UVHeatLevel )
    local UVHeatMaxConVar = GetConVar( 'unitvehicle_unit_heatminimumbounty' .. UVHeatLevel + 1 )
    
    UVHeatBountyMin = ( UVHeatMinConVar and UVHeatMinConVar:GetInt() ) or math.huge
    UVHeatBountyMax = ( UVHeatMaxConVar and UVHeatMaxConVar:GetInt() ) or math.huge
    
    surface.SetDrawColor(Color(109, 109, 109, 200))
    surface.DrawRect(UV_UI.X(w * 0.805), h * 0.2815, UV_UI.W(w * 0.1375), h * 0.035)
    surface.SetDrawColor(Color(255, 255, 255))
    local HeatProgress = 0
    if MaxHeatLevel:GetInt() ~= UVHeatLevel then
        if UVUTimeTillNextHeatEnabled:GetInt() == 1 and UVTimeTillNextHeat then --Time till next heat level
            local timedHeatConVar = GetConVar( 'unitvehicle_unit_timetillnextheat' .. UVHeatLevel )
            
            local maxtime = timedHeatConVar and timedHeatConVar:GetInt() or 0
            HeatProgress = (maxtime - UVTimeTillNextHeat) / maxtime
        else
            HeatProgress = ((UVBountyNo - UVHeatBountyMin) / (UVHeatBountyMax - UVHeatBountyMin))
        end
    end
    local B = math.Clamp((HeatProgress) * UV_UI.W(w * 0.1375), 0, UV_UI.W(w * 0.1375))
    local blink = 255 * math.abs(math.sin(RealTime() * 4))
    local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
    local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
    
    if HeatProgress >= 0.6 and HeatProgress < 0.75 then
        surface.SetDrawColor(Color(255, blink, blink))
    elseif HeatProgress >= 0.75 and HeatProgress < 0.9 then
        surface.SetDrawColor(Color(255, blink2, blink2))
    elseif HeatProgress >= 0.9 and HeatProgress < 1 then
        surface.SetDrawColor(Color(255, blink3, blink3))
    elseif HeatProgress >= 1 then
        surface.SetDrawColor(Color(255, 0, 0))
    end
    
    surface.DrawRect(UV_UI.X(w * 0.805), h * 0.2815, B, h * 0.035)
    
    -- [ Bottom Info Box ] --
	local bottomyplus = 0

    if (LocalPlayer().uvspawningunit and LocalPlayer().uvspawningunit.vehicle) or (not UVHUDCopMode and UVHUDRaceFinishCountdownStarted) then
        bottomyplus = -(h * 0.05)
    end

    local bottomy = h * 0.91 + bottomyplus

    if not UVHUDDisplayCooldown then
        -- Evade Box, All BG
        draw.NoTexture()
        surface.SetDrawColor(100, 100, 100, 230)
        surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy + (h*0.013), UV_UI.W(w * 0.3), h * 0.03, 0)

		-- Borders
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy - (h*0.004), UV_UI.W(w * 0.304), h * 0.004, 0) -- Top
        surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy + (h*0.029), UV_UI.W(w * 0.304), h * 0.004, 0) -- Bottom
        surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.349), bottomy + (h*0.013), h * 0.037, h * 0.004, 90) -- Left
        surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.6515), bottomy + (h*0.013), h * 0.037, h * 0.004, 90) -- Right

        -- Evade Box, Evade BG
        surface.SetMaterial(UVMaterials["BACKGROUND_CARBON_FILLED"])
        surface.SetDrawColor(50, 214, 255, 100)
        surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.575), bottomy + (h*0.013), UV_UI.W(w * 0.15), h * 0.03, 0)
        
        -- Evade Box, Busted BG
        surface.SetMaterial(UVMaterials["BACKGROUND_CARBON_FILLED_INVERTED"])
        surface.SetDrawColor(255, 0, 0, 100)
        surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.425), bottomy + (h*0.014), UV_UI.W(w * 0.15), h * 0.03, 0)

        -- Evade Box, Busted Meter
        if UVHUDDisplayBusting and not UVHUDDisplayCooldown then
            if not BustingProgress or BustingProgress == 0 then
                BustingProgress = CurTime()
            end
            
            local blink = 255 * math.abs(math.sin(RealTime() * 4))
            local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
            local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
            
            local timeLeft = ((UVHUDDisplayNotification and -1) or (UVBustTimer - UVBustingProgress))
            
            local playbusting = (UVHUDCopMode and UVHUDWantedSuspectsNumber == 1) or not UVHUDCopMode
            
            if timeLeft >= UVBustTimer * 0.5 then
                states.BustedColor = Color(255, 100, 100, blink)
            elseif timeLeft >= UVBustTimer * 0.2 then
                states.BustedColor = Color(255, 100, 100, blink2)
            elseif timeLeft >= 0 then
                states.BustedColor = Color(255, 100, 100, blink3)
            else
                states.BustedColor = Color(255, 100, 100)
            end
            
            local T = math.Clamp((UVBustingProgress / UVBustTimer) * (UV_UI.W(w * 0.15)), 0, UV_UI.W(w * 0.15))
            T = math.floor(T)
            surface.SetDrawColor(255, 0, 0)
            surface.DrawRect(UV_UI.XScaled(w * 0.35) + (UV_UI.W(w * 0.15) - T), bottomy - (h * 0.002), T, h * 0.03)
        else
            UVBustedColor = Color(255, 100, 100, 125)
            BustingProgress = 0
        end
        
        -- Evade Box, Evade Meter
        if not UVHUDDisplayNotification and not UVHUDDisplayCooldown and UnitsChasing == 0 and BustingProgress == 0 then
            --UVSoundHeat(UVHeatLevel)
            if not EvadingProgress then
                EvadingProgress = 0
                UVEvadingProgress = EvadingProgress
            end
            
            local T = math.Clamp((UVEvadingProgress) * (UV_UI.W(w * 0.15)), 0, UV_UI.W(w * 0.15))
            surface.SetDrawColor(50, 173, 255)
            surface.DrawRect(UV_UI.XScaled(w * 0.5), bottomy - (h * 0.002), T, h * 0.03)
            states.EvasionColor = Color(50, 173, 255, blink)
        else
            EvadingProgress = 0
        end
        
        -- Evade Box, Icons
        DrawIcon(UVMaterials["BUSTED_ICON_UC"], UV_UI.XScaled(w * 0.33), bottomy + (h*0.012), .06, Color(255,0,0, 255)) -- Icon
        DrawIcon(UVMaterials["EVADE_ICON_UC"], UV_UI.XScaled(w * 0.67), bottomy + (h*0.012), .06, Color(50, 173, 255, 255)) -- Icon
        
        DrawIcon(UVMaterials["BUSTED_ICON_UC_GLOW"], UV_UI.XScaled(w * 0.33), bottomy + (h*0.012), .06, states.BustedColor) -- Icon, Glow
        DrawIcon(UVMaterials["EVADE_ICON_UC_GLOW"], UV_UI.XScaled(w * 0.67), bottomy + (h*0.012), .06, states.EvasionColor) -- Icon, Glow
		
        -- Evade Box, Dividers
		draw.NoTexture()
        surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectRotated(w * 0.5, bottomy + (h*0.013), w * 0.002, h * 0.03, 0)
    else
        -- Lower Box
        -- Evade Box, Cooldown Meter
        if UVHUDDisplayCooldown then
            
            local blink = 255 * math.abs(math.sin(RealTime() * 4))
            local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
            local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
            
            if not CooldownProgress or CooldownProgress == 0 then
                CooldownProgress = CurTime()
            end
            
            --UVSoundCooldown(UVHeatLevel)
            EvadingProgress = 0
            
            -- Upper Box
            if not UVHUDCopMode then
                DrawIcon(UVMaterials["EVADE_ICON_UC_GLOW"], UV_UI.XScaled(w * 0.6925), bottomy + (h*0.015), .05, Color(50, 214, 255, blink2)) -- Icon, Glow
                DrawIcon(UVMaterials["EVADE_ICON_UC"], UV_UI.XScaled(w * 0.6925), bottomy + (h*0.015), .05, Color(50, 214, 255, 255)) -- Icon
                
                surface.SetDrawColor(200, 200, 200, 125)
                surface.DrawRect(UV_UI.XScaled(w * 0.333), bottomy, UV_UI.W(w * 0.344), h * 0.03)
                
                local T = math.Clamp((UVCooldownTimer) * (UV_UI.W(w * 0.344)), 0, UV_UI.W(w * 0.344))
                surface.SetDrawColor(50, 173, 255, 255)
                
                surface.DrawRect(UV_UI.XScaled(w * 0.333), bottomy, T, h * 0.03)
            else
                DrawIcon(UVMaterials["EVADE_ICON_UC_GLOW"], UV_UI.XScaled(w * 0.5), bottomy - (h*0.025), .05, Color(50, 214, 255, blink2)) -- Icon, Glow
                DrawIcon(UVMaterials["EVADE_ICON_UC"], UV_UI.XScaled(w * 0.5), bottomy - (h*0.025), .05, Color(50, 214, 255, 125)) -- Icon
                
                surface.SetDrawColor(50, 214, 255, 50)
                surface.DrawRect(w * 0.333, bottomy, w * 0.344, h * 0.04)
                
                draw.DrawText("#uv.chase.cooldown", "UVUndercoverWhiteFont", w * 0.5, bottomy - (h * 0.005), Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
        else
            CooldownProgress = 0
        end
    end
end

UV_UI.pursuit.undercover.main = undercover_pursuit_main
UV_UI.racing.undercover.main = undercover_racing_main