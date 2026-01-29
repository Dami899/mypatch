UV.RegisterHUD( "world", "NFS: World", true )

local altFontLanguages = {
	["cs"] = true, -- Czech
	["el"] = true, -- Greek
	["uk"] = true, -- Ukrainian
}

local function GetFontSuffixForLanguage()
	local lang = GetConVar("gmod_language"):GetString()
	if altFontLanguages[lang] then
		return "-Alt"
	end
	return ""
end

UV_UI.racing.world = UV_UI.racing.world or {}
UV_UI.pursuit.world = UV_UI.pursuit.world or {}

UV_UI.pursuit.world.states = {
    TagsColor = Color(255,255,255,150),
    WrecksColor = Color(255,255,255,150),
    UnitsColor = Color(255,255,255,150),
    BustedColor = Color(255, 255, 255, 50),
    EvasionColor = Color(255, 255, 255, 50),
    
    TakedownText = nil,
}

UV_UI.racing.world.states = {
    LapCompleteText = nil,
	notificationQueue = {},
	notificationActive = nil,
	
	notificationQueue2 = {}, -- Alt Noti.
	notificationActive2 = nil,
}

UV_UI.racing.world.events = {
	CenterNotification = function(params)
		local ptext = params.text or "REPLACEME"
		local pcol = params.color or Color( 255, 255, 255 )
		local pcolbg = params.colorbg or Color( 0, 0, 0 )
		local immediate = params.immediate or nil
		local iscritical = params.critical or nil
		local notitimer = params.timer or 1

		local StartClosing
		local closing = false
		local closeStartTime = nil

		-- Handle queue logic
		if UV_UI.racing.world.states.notificationActive then
			if immediate then
				-- Retain critical entries only
				local retainedQueue = {}
				for _, v in ipairs(UV_UI.racing.world.states.notificationQueue) do
					if v.critical then
						table.insert(retainedQueue, v)
					end
				end

				UV_UI.racing.world.states.notificationQueue = retainedQueue
				table.insert(UV_UI.racing.world.states.notificationQueue, 1, params)

				timer.Simple(0, function()
					if not closing and StartClosing then
						StartClosing()
					end
				end)
			else
				table.insert(UV_UI.racing.world.states.notificationQueue, params)
			end
			return
		end

		UV_UI.racing.world.states.notificationActive = true

		local hookName = "UV_CENTERNOTI_WORLD"
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
			timer.Create("UV_CENTERNOTI_WORLD_CLEANUP", expandDuration, 1, function()
				hook.Remove("HUDPaint", hookName)
				UV_UI.racing.world.states.notificationActive = false

				if #UV_UI.racing.world.states.notificationQueue > 0 then
					local nextParams = table.remove(UV_UI.racing.world.states.notificationQueue, 1)
					-- If the queued entry has 'immediate', allow mid-close interruption next round
					timer.Simple(0, function()
						UV_UI.racing.world.events.CenterNotification(nextParams)
					end)
				end
			end)
		end

		-- Mid-life force-close handler for 'immediate' queueing
		timer.Create("UV_CENTERNOTI_WORLD_FORCECHECK", 0.05, 0, function()
			if CurTime() - startTime >= notitimer and not closing and #UV_UI.racing.world.states.notificationQueue > 0 then
				StartClosing()
				timer.Remove("UV_CENTERNOTI_WORLD_FORCECHECK")
			end
		end)

		-- Regular close trigger
		timer.Create("UV_CENTERNOTI_WORLD_TIMER", displayDuration - expandDuration, 1, function()
			if not closing then
				StartClosing()
			end
			timer.Remove("UV_CENTERNOTI_WORLD_FORCECHECK")
		end)

		hook.Add("HUDPaint", hookName, function()
			local showhud = GetConVar("cl_drawhud"):GetBool()
			local now = CurTime()
			local realTime = RealTime()
			local animTime = now - startTime
			local barProgress = 0
			local currentWidth

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
			local barY = h * 0.2

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

			-- Draw bar
			if showhud then 
				surface.SetMaterial(UVMaterials["COOLDOWNBG_WORLD"])
				surface.SetDrawColor(Color(255, 255, 255))
				surface.DrawTexturedRect(barX, barY, currentWidth, barHeight)
				
				surface.SetMaterial(UVMaterials["PT_BG"])
				surface.SetDrawColor(Color(colorVal, colorVal, colorVal, 125))
				surface.DrawTexturedRect(barX, barY, currentWidth, barHeight)
			end

			-- Text
			if animTime >= whiteStart then
				local outlineAlpha = math.Clamp(255 - colorVal, 0, 255)

				if closing then
					local closeAnimTime = now - closeStartTime
					local fade = 1 - math.Clamp(closeAnimTime / expandDuration, 0, 1)
					outlineAlpha = outlineAlpha * fade
				end

				mw_noti_draw(showhud and ptext, "UVWorldFont2" .. GetFontSuffixForLanguage(), w * 0.5, h * 0.285, pcol, pcolbg)
			end
		end)
	end,

	ShowResults = function(sortedRacers) -- World
		local w, h = ScrW(), ScrH()

		--------------------------------------

		local ResultPanel = vgui.Create("DFrame")
		local OK = vgui.Create("DButton")

		ResultPanel:Add(OK)
		ResultPanel:SetSize(w, h)
		ResultPanel:SetBackgroundBlur(true)
		ResultPanel:ShowCloseButton(false)
		ResultPanel:Center()
		ResultPanel:SetTitle("")
		ResultPanel:SetDraggable(false)
		ResultPanel:SetKeyboardInputEnabled(false)

		ResultPanel:SetVisible(true)
		ResultPanel:MoveToFront()
		ResultPanel:RequestFocus()
		gui.EnableScreenClicker(true)

		OK:SetText("")
		OK:SetPos(w*0.55, h*0.7)
		OK:SetSize(w*0.12, h*0.05)
		OK:SetEnabled(true)
		OK.Paint = function() end

		local timestart = CurTime()
		local displaySequence = {}

		local fakeLoadingDuration = math.Rand(0.5, 3.5)
		local loading = true
		local loadingStart = CurTime()

		local bgScale, bgAlpha, bgAnimStart = 0, 0, CurTime()
		local contentAlpha, contentStart = 0, CurTime()

		local racersArray = {}
		for _, dict in pairs(sortedRacers) do table.insert(racersArray, dict) end

		table.sort(racersArray, function(a, b)
			local tA = (type(a.array and a.array.TotalTime) == "number") and a.array.TotalTime or math.huge
			local tB = (type(b.array and b.array.TotalTime) == "number") and b.array.TotalTime or math.huge
			return tA < tB
		end)

		local entriesToShow = 9
		local scrollOffset = 0

		for i, dict in ipairs(racersArray) do
			local info = dict.array or {}
			local LP, LC, LC2 = false, Color(200,200,200), Color(0,0,0)
			
			if info.LocalPlayer then LP, LC = true, Color(225,255,255) end
			
			local totalTime = info.TotalTime or UVString("uv.race.suffix.dnf")
			
			if info.Busted then totalTime = UVString("uv.race.suffix.busted") end

			table.insert(displaySequence, {
				y = h*0.08 + (i-1)*(h*0.09),
				posText = tostring(i),
				nameText = info.Name or "Unknown",
				timeText = UV_FormatRaceEndTime(totalTime),
				color = LC,
				colorbg = LC2,
				localPlayer = LP,
				vehName = info.VehicleName
			})
		end

		local closing = false
		local closeStartTime = 0
		local playedfadeSound = false

        function ResultPanel:OnMouseWheeled(delta)
            if delta > 0 then
                scrollOffset = math.max(scrollOffset - 1, 0)
            elseif delta < 0 then
                local maxOffset = math.max(0, #displaySequence - entriesToShow)
                scrollOffset = math.min(scrollOffset + 1, maxOffset)
            end
            
            return true -- prevent further processing
        end

		local contMarkup = markup.Parse( "<font=UVWorldFont3"..GetFontSuffixForLanguage()..">" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue")) .. "</font>" )

		ResultPanel.Paint = function(self, w, h)
			local curTime = CurTime()
			local elapsedAnim = curTime - bgAnimStart
			local effectiveAlpha = contentAlpha
			local headerAlpha = 0

			-- Opening background animation
			bgScale = math.Clamp(elapsedAnim / 0.2, 0, 1)
			bgAlpha = math.Clamp((elapsedAnim - 0.1)/0.3, 0, 1)*255

			local shrinkFactor = 1
			local baseHeight = h - h*0.5
			local scaledHeight = baseHeight * bgScale * shrinkFactor
			local yOffset = (baseHeight - scaledHeight) * 0.5

			-- Closing two-phase logic
			if closing then
				OK:SetEnabled(false)
				gui.EnableScreenClicker(false)
				local elapsedFade = curTime - closeStartTime
				local textFadeDuration, bgShrinkDuration = 0.125, 0.15

				-- Phase 1: fade out texts/buttons
				local textProgress = math.Clamp(elapsedFade / textFadeDuration, 0, 1)
				effectiveAlpha = contentAlpha * (1 - textProgress)
				headerAlpha = 255 * (1 - textProgress)

				-- Phase 2: shrink background vertically
				local bgProgress = math.Clamp((elapsedFade - textFadeDuration) / bgShrinkDuration, 0, 1)
				shrinkFactor = 1 - bgProgress

				scaledHeight = baseHeight * bgScale * shrinkFactor
				yOffset = (baseHeight - scaledHeight) * 0.5

				if not playedfadeSound and elapsedFade >= 0.05 then
					playedfadeSound = true
					surface.PlaySound("uvui/world/close.wav")
				end

				if elapsedFade >= textFadeDuration + bgShrinkDuration then
					hook.Remove("CreateMove", "JumpKeyCloseResults")
					if IsValid(ResultPanel) then ResultPanel:Close() end
					return
				end
			end

			if not loading and not closing then
				local revealProgress = math.Clamp((curTime - contentStart) / 0.6, 0, 1)
				contentAlpha = revealProgress * 255
			end

			if loading then
				headerAlpha = bgAlpha
			else
				headerAlpha = effectiveAlpha
			end

			-- Draw background
			surface.SetDrawColor( 255, 255, 255, bgAlpha)
			surface.SetMaterial(UVMaterials["RESULTSBG_WORLD"])
			surface.DrawTexturedRect( w*0.33, h*0.25 + yOffset, w - w*0.66, scaledHeight )

			-- Header
			local headerDrawAlpha = 0

			if loading then
				headerDrawAlpha = bgAlpha
			elseif closing then
				headerDrawAlpha = effectiveAlpha
			else
				headerDrawAlpha = 255
			end
			
			draw.SimpleTextOutlined( UVString("uv.results.race.raceresults"), "UVWorldFont3" .. GetFontSuffixForLanguage(), w*0.335, h*0.255, Color( 137, 242, 248, headerDrawAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ))

			-- Loading elements
			if loading then
				OK:SetEnabled(false)
				draw.SimpleTextOutlined( UVString("uv.race.loading"), "UVWorldFont6" .. GetFontSuffixForLanguage(), w*0.5, h*0.525, Color( 200, 200, 200, headerAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, headerAlpha ) )
				DrawIcon( UVMaterials["LOADING_WORLD_R"], w*0.5, h*0.5, 0.05, Color( 255, 255, 255, headerAlpha ), { rotation = ( -RealTime() * 360 ) % 360 } )
				DrawIcon( UVMaterials["LOADING_WORLD_L"], w*0.5, h*0.5, 0.04, Color( 255, 255, 255, headerAlpha ), { rotation = ( RealTime() * 180 ) % 360 } )
				-- surface.SetDrawColor( 255, 255, 255, headerAlpha )
				surface.SetDrawColor( 225,225,225, headerAlpha )
				surface.SetMaterial(UVMaterials["RESULTS_NEXTBTN_INACTIVE_WORLD"])
				surface.DrawTexturedRect( w*0.55, h*0.7, w*0.12, h*0.05 )

				surface.SetAlphaMultiplier(headerAlpha / 255)
				contMarkup:Draw(w * 0.61, h * 0.712, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				surface.SetAlphaMultiplier(1)

				if curTime - loadingStart >= fakeLoadingDuration then
					loading = false
					timestart = CurTime()
					OK:SetEnabled(true)
					contentAlpha = 0
					contentStart = CurTime()
				else return end
			end

			-- Draw race rows
			local startIndex = scrollOffset + 1
            local endIndex = math.min(startIndex + entriesToShow - 1, #displaySequence)
			local bannerKeys = {
				"RESULTS_1ST_BANNER_WORLD",
				"RESULTS_2ND_BANNER_WORLD",
				"RESULTS_3RD_BANNER_WORLD"
			}

			for i = startIndex, endIndex do
				local entry = displaySequence[i]
				local localIndex = i - startIndex + 1
				local yPos = h*0.31 + (localIndex-1)*(h*0.045)
				local bannerKey = bannerKeys[i] or "RESULTS_4TH_BANNER_WORLD"
				surface.SetDrawColor( 255, 255, 255, effectiveAlpha )
				surface.SetMaterial( UVMaterials[bannerKey] )
				surface.DrawTexturedRectRotated( w*0.5, yPos, w*0.325, h*0.04, 0 )
				local entrycol, entrycolbg = Color( entry.color.r, entry.color.g, entry.color.b, effectiveAlpha ), Color( entry.colorbg.r, entry.colorbg.g, entry.colorbg.b, effectiveAlpha )

				if entry.posText then 
					draw.SimpleTextOutlined( entry.posText, "UVWorldFont6" .. GetFontSuffixForLanguage(), w*0.34, yPos - (h*0.014), entrycol, TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP, 1, entrycolbg )
				end
				if entry.nameText then 
					draw.SimpleTextOutlined( entry.nameText, "UVWorldFont6" .. GetFontSuffixForLanguage(), w*0.355, yPos - (h*0.0225), entrycol, TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP, 1, entrycolbg )
				end
				if entry.vehName then 
					draw.SimpleTextOutlined( entry.vehName, "UVWorldFont7" .. GetFontSuffixForLanguage(), w*0.355, yPos, entrycol, TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP, 1, entrycolbg )
				end
				if entry.timeText then 
					draw.SimpleTextOutlined( entry.timeText, "UVWorldFont7" .. GetFontSuffixForLanguage(), w*0.66, yPos, entrycol, TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP, 1, entrycolbg )
				end
			end

			-- Scroll arrows
			local blink = effectiveAlpha * math.abs(math.sin(RealTime()*8))
			if scrollOffset > 0 then
				draw.SimpleText("▲","UVWorldFont6", w*0.5, h*0.265, Color(255,255,255,math.floor(blink)), TEXT_ALIGN_CENTER)
			end
			
			if scrollOffset < #displaySequence-entriesToShow then
				draw.SimpleText("▼","UVWorldFont6", w*0.5,h*0.6875,Color(255,255,255,math.floor(blink)),TEXT_ALIGN_CENTER)
			end

			-- Next button and auto-close
			local elapsed = math.max(0, curTime - timestart)
			local autoCloseRemaining = math.max(0,30 - elapsed)
			local autotext = string.format(UVString("uv.results.autoclose"), math.ceil(autoCloseRemaining))

			surface.SetDrawColor(255,255,255,effectiveAlpha*math.abs(math.sin(RealTime()*3)))
			surface.SetMaterial(UVMaterials["RESULTS_NEXTBTN_GLOW_WORLD"])
			surface.DrawTexturedRect(w*0.55,h*0.7,w*0.12,h*0.05)
			-- surface.SetDrawColor(255,255,255,effectiveAlpha)
			surface.SetDrawColor(225,225,225,effectiveAlpha)
			surface.SetMaterial(UVMaterials["RESULTS_NEXTBTN_WORLD"])
			surface.DrawTexturedRect(w*0.55,h*0.7,w*0.12,h*0.05)

			surface.SetAlphaMultiplier(effectiveAlpha / 255)
			contMarkup:Draw(w * 0.61, h * 0.712, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			surface.SetAlphaMultiplier(1)

			draw.SimpleTextOutlined(autotext,"UVWorldFont7" .. GetFontSuffixForLanguage(),w*0.335,h*0.725, Color(200,200,200,effectiveAlpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,1,Color(0,0,0,effectiveAlpha))

			if autoCloseRemaining <= 0 and not closing then
				hook.Remove("CreateMove", "JumpKeyCloseResults")
				closing = true
				closeStartTime = CurTime()
			end
		end

		function OK:DoClick()
			if loading or closing then return end
			closing = true
			closeStartTime = CurTime()
		end

		hook.Add("CreateMove","JumpKeyCloseResults",function()
			if loading then return end
			local ply = LocalPlayer()
			if not IsValid(ply) then return end
			if ply:KeyPressed(IN_JUMP) and IsValid(ResultPanel) then
				hook.Remove("CreateMove","JumpKeyCloseResults")
				closing = true
				closeStartTime = CurTime()
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
				glidetext = UVString("uv.race.finished.statserror")
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
						UV_UI.racing.world.events.ShowResults(sortedRacers)
					end)
					return
				end
				UV_UI.racing.world.events.ShowResults(sortedRacers)
			end
		end)
	end,

	onLapComplete = function( participant, new_lap, old_lap, lap_time, lap_time_cur, is_local_player, is_global_best, lap_final, local_finished, user_finished, suppress_lap_ui )
		local name = UVHUDRaceInfo.Participants[participant] and UVHUDRaceInfo.Participants[participant].Name or "Unknown"
		
		local cps = GetGlobalInt("uvrace_checkpoints")
		local participant_count = UVHUDRaceInfo.Participants and table.Count(UVHUDRaceInfo.Participants) or 0

		local finishtext = (participant_count > 1 and cps > 1) and 
		UVString("uv.race.finished") .. "\n" .. string.format( UVString("uv.race.finishspot"), UVString("uv.race.pos.num." .. UVHUDRaceCurrentPos) )
		or UVString("uv.race.finished")

		if local_finished then 
			UV_UI.racing.world.events.CenterNotification({
				text = finishtext,
				color = Color( 137, 242, 248 ),
				colorbg = Color(66, 194, 222, 50),
			})
			return
		end
	
		if suppress_lap_ui then return end

		if is_global_best then
			UV_UI.racing.world.states.LapCompleteText = string.format(UVString("uv.race.fastest.laptime"), name, Carbon_FormatRaceTime( lap_time ) )
		else
			if is_local_player then
				UV_UI.racing.world.states.LapCompleteText = string.format(UVString("uv.race.laptime"), Carbon_FormatRaceTime( lap_time ) )
			else
				return
			end
		end
		UV_UI.racing.world.events.CenterNotification({
			text = UV_UI.racing.world.states.LapCompleteText,
			color = Color( 137, 242, 248 ),
			colorbg = Color(66, 194, 222, 50),
		})
	end,
		
	onParticipantDisqualified = function(data)
		local participant = data.Participant
		local is_local_player = data.is_local_player
		
		local info = UVHUDRaceInfo.Participants[participant]
		local name = info and info.Name or "Unknown"

		if not info then return end

		local disqtext = string.format(UVString("uv.race.wrecked"), name)
		if is_local_player then disqtext = UVString("uv.chase.wrecked") end

		UV_UI.racing.world.events.CenterNotification({
			text = disqtext,
			color = Color( 137, 242, 248 ),
			colorbg = Color(66, 194, 222, 50),
			immediate = is_local_player and true or false,
			timer = is_local_player and 3 or 1,
		})
	end,

	onRaceStartTimer = function(data)
		local starttime = data.starttime
		local noready = data.noReadyText
		local nobg = data.noBG

		local countdownTexts = {
			[4] = 3,
			[3] = 2,
			[2] = 1,
			[1] = UVString("uv.race.go")
		}

		-- local textToShow = countdownTexts[starttime]
		-- if not textToShow then return end
		
		-- ensure the table exists
		UVWorldCountdown = UVWorldCountdown or {}

		-- store the server-provided starttime
		UVWorldCountdown.starttime = starttime
		UVWorldCountdown.valueStartTime = CurTime() -- reset animation timing

		-- resolve text (READY... if above 4, otherwise from table)
		UVWorldCountdown.label = countdownTexts[starttime] and tostring(countdownTexts[starttime]) or nil

		-- === CONFIG / HELPERS ===
		local DUR_FADE_IN     = 0.05
		local DUR_BG_ANIM     = 0.15
		local DUR_FADE_OUT    = 0.15
		local DISPLAY_TOTAL   = 0.3    -- total time each value is visible

		local READY_TEXT = noready and " " or UVString("uv.race.getready")
		
		local tickStart = CurTime()
		local lifetime  = DISPLAY_TOTAL + 0.75

		if starttime > 4 then
			UVWorldCountdown.label = READY_TEXT
		else
			UVWorldCountdown.label = countdownTexts[starttime] and tostring(countdownTexts[starttime]) or nil
		end
		
		local function LerpColor(t, cFrom, cTo)
			return Color(
				math.Round(Lerp(t, cFrom.r, cTo.r)),
				math.Round(Lerp(t, cFrom.g, cTo.g)),
				math.Round(Lerp(t, cFrom.b, cTo.b)),
				math.Round(Lerp(t, (cFrom.a or 255), (cTo.a or 255)))
			)
		end

		-- === HOOK CREATION ===
		hook.Add("HUDPaint", "UV_Countdown_World", function()
			if not UVWorldCountdown or not UVWorldCountdown.starttime then return end
			local vs = UVWorldCountdown

			if CurTime() > tickStart + lifetime then
				hook.Remove("HUDPaint", "UV_Countdown_World")
				return
			end

			-- cleanup after finished
			if vs.starttime == 0 then
				if not vs.cleanupTime then
					vs.cleanupTime = CurTime() + 1 -- wait 1s
				elseif CurTime() >= vs.cleanupTime then
					hook.Remove("HUDPaint", "UV_Countdown_World")
					UVWorldCountdown = nil
				end
				return
			end

			if not vs.label then return end

			-- === TIMING / ANIMATION ===
			local t = CurTime() - (vs.valueStartTime or 0)
			local currentAlpha, bgPad, bgColor

			if vs.label == READY_TEXT then
				-- READY... stays solid, no flicker
				currentAlpha = 255
				bgPad = 8
				bgColor = Color(89, 176, 193, 50)
			else
				-- countdown values fade/animate
				-- 1) fade-in
				local inT = math.Clamp(t / DUR_FADE_IN, 0, 1)
				currentAlpha = Lerp(inT, 0, 255)

				-- 2) background animation
				local bgStart = DUR_FADE_IN
				local bgEnd   = DUR_FADE_IN + DUR_BG_ANIM
				local bgT = 0
				if t >= bgStart then bgT = math.Clamp((t - bgStart) / DUR_BG_ANIM, 0, 1) end

				bgPad = Lerp(bgT, 12, 4)
				local bgTarget = Color( 89, 176, 193, 50 )
				bgColor = LerpColor(bgT, Color( 89, 176, 193, 255 ), bgTarget)

				-- 3) fade-out at end
				local fadeOutStart = DISPLAY_TOTAL - DUR_FADE_OUT
				if t >= fadeOutStart then
					local outT = math.Clamp((t - fadeOutStart) / DUR_FADE_OUT, 0, 1)
					currentAlpha = Lerp(outT, 255, 0)
					bgColor.a = math.max(0, math.floor(bgColor.a * (currentAlpha / 255)))
				end
			end

			local textColor = Color(137, 242, 248, math.ceil(currentAlpha))

			-- === DRAW SIDE BARS ===
			local barW = ScrW() * 0.5
			local barH = ScrH() * 0.2
			local barY = (ScrH() - barH) * 0.5

			-- fade bars out when GO fades out
			local barAlpha = 255
			if vs.starttime == 1 then
				local barFadeStart = (vs.valueStartTime or 0) + (DISPLAY_TOTAL - DUR_FADE_OUT)
				if CurTime() >= barFadeStart then
					local barOutT = math.Clamp((CurTime() - barFadeStart) / DUR_FADE_OUT, 0, 1)
					barAlpha = Lerp(barOutT, 255, 0)
				end
			end
			if not nobg then
				surface.SetDrawColor(255, 255, 255, barAlpha)
				-- left bar
				surface.SetMaterial(UVMaterials['RACE_CDBG_LEFT_WORLD'])
				surface.DrawTexturedRect(0, (ScrH() - ScrH() * 0.2) * 0.5, ScrW() * 0.5, ScrH() * 0.2)

				-- right bar
				surface.SetMaterial(UVMaterials['RACE_CDBG_RIGHT_WORLD'])
				surface.DrawTexturedRect(ScrW() - ScrW() * 0.5, (ScrH() - ScrH() * 0.2) * 0.5, ScrW() * 0.5, ScrH() * 0.2)
			end
			
			-- === DRAW TEXT ===
			draw.SimpleTextOutlined( vs.label or "", "UVWorldFont5" .. GetFontSuffixForLanguage(), ScrW() * 0.5, ScrH() * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, math.floor(bgPad), bgColor )
		end)

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
		local noticol = Color(0, 255, 0)

		if aheadDiff == "N/A" and behindDiff ~= "N/A" then -- 1st place
			splittime = "+ " .. behindDiff
		elseif aheadDiff ~= "N/A" then -- 2nd place or below
			splittime = "- " .. aheadDiff
			showahead = true
			noticol = Color(200, 75, 75)
		end
		
		local splittext = string.format( UVString("uv.race.splittime"), splittime )

		UV_UI.racing.world.events.CenterNotification({
			text = splittext,
			color = Color( 137, 242, 248 ),
			colorbg = Color(66, 194, 222, 50),
		})
	end,

}

UV_UI.pursuit.world.events = {
    notifState = {},
    onUnitTakedown = function( unitType, name, bounty, bountyCombo, isPlayer )
		local uname = isPlayer and UVString( unitType ) or name -- Fallback
		
		if GetConVar("unitvehicle_vehiclenametakedown"):GetBool() then
			uname = name and string.Trim(UVString(name), "#") or nil
		end
		
		UV_UI.racing.world.events.CenterNotification({
			text = string.format( UVString( "uv.hud.mw.takedown" ), uname, bounty, bountyCombo ),
			color = Color( 137, 242, 248 ),
			colorbg = Color(66, 194, 222, 50),
			immediate = true,
		})
	end,
    onUnitWreck = function(...)
        
        hook.Remove("Think", "MW_WRECKS_COLOR_PULSE")
        
        if timer.Exists("MW_WRECKS_COLOR_PULSE_DELAY") then timer.Remove("MW_WRECKS_COLOR_PULSE_DELAY") end
        UV_UI.pursuit.world.states.WrecksColor = Color(255,255,0, 150)
        
        timer.Create("MW_WRECKS_COLOR_PULSE_DELAY", 1, 1, function()
            hook.Add("Think", "MW_WRECKS_COLOR_PULSE", function()
                UV_UI.pursuit.world.states.WrecksColor.b = UV_UI.pursuit.world.states.WrecksColor.b + 600 * RealFrameTime()
                if UV_UI.pursuit.world.states.WrecksColor.b >= 255 then hook.Remove("Think", "MW_WRECKS_COLOR_PULSE") end
            end)
        end)
        
    end,
    onUnitTag = function(...)
        
        hook.Remove("Think", "MW_TAGS_COLOR_PULSE")
        if timer.Exists("MW_TAGS_COLOR_PULSE_DELAY") then timer.Remove("MW_TAGS_COLOR_PULSE_DELAY") end
        
        UV_UI.pursuit.world.states.TagsColor = Color(255,255,0, 150)
        
        timer.Create("MW_TAGS_COLOR_PULSE_DELAY", 1, 1, function()
            
            hook.Add("Think", "MW_TAGS_COLOR_PULSE", function()
                UV_UI.pursuit.world.states.TagsColor.b = UV_UI.pursuit.world.states.TagsColor.b + 600 * RealFrameTime()
                if UV_UI.pursuit.world.states.TagsColor.b >= 255 then hook.Remove("Think", "MW_TAGS_COLOR_PULSE") end
            end)
            
        end)
        
    end,
    onResourceChange = function(...)
        
        local new_data = select( 1, ... )
        local old_data = select( 2, ... )
        
        hook.Remove("Think", "MW_RP_COLOR_PULSE")
        UV_UI.pursuit.world.states.UnitsColor = (new_data < (old_data or 0) and Color(255,50,50, 150)) or Color(50,255,50, 150)
        --UVResourcePointsColor = (rp_num < UVResourcePoints and Color(255,50,50)) or Color(50,255,50)
        
        local clrs = {}
        
        for _, v in pairs( { 'r', 'g', 'b' } ) do
            if UV_UI.pursuit.world.states.UnitsColor[v] ~= 255 then table.insert(clrs, v) end
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
                UV_UI.pursuit.world.states.UnitsColor[v] = val
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
			cnt = UVString("uv.chase.busted")
		end

		UV_UI.racing.world.events.CenterNotification({
			text = cnt,
			color = Color( 137, 242, 248 ),
			colorbg = Color(66, 194, 222, 50),
			immediate = lp and true or false,
		})
	end,
	
    ShowDebrief = function(params) -- Carbon
        if UVHUDDisplayRacing then return end
        if IsValid(ResultPanel) then ResultPanel:Remove() end
        
        local debriefdata = params.dataTable or escapedtable
        local debrieftitletext = params.titleText or "Title Text"
        local debrieftitlevar = params.titleVar or " "
		local debriefunitspawn = params.spawnAsUnit or false
		local debvriefbustedbg = params.bustedBG or false
        
        local w = ScrW()
        local h = ScrH()
        
        --------------------------------------
        
        local time = UVDisplayTime(UVTimerProgress)
        local unit = debriefdata["Unit"] or "Unknown"
        local deploys = debriefdata["Deploys"]
        local roadblocksdodged = debriefdata["Roadblocks"]
        local spikestripsdodged = debriefdata["Spikestrips"]
        local bounty = UVBounty
        local tags = UVTags
        local wrecks = UVWrecks
        local suspects = UVHUDWantedSuspectsNumber

		--------------------------------------

		local ResultPanel = vgui.Create("DFrame")
		local OK = vgui.Create("DButton")

		ResultPanel:Add(OK)
		ResultPanel:SetSize(w, h)
		ResultPanel:SetBackgroundBlur(true)
		ResultPanel:ShowCloseButton(false)
		ResultPanel:Center()
		ResultPanel:SetTitle("")
		ResultPanel:SetDraggable(false)
		ResultPanel:SetKeyboardInputEnabled(false)

		ResultPanel:SetVisible(true)
		ResultPanel:MoveToFront()
		ResultPanel:RequestFocus()
		gui.EnableScreenClicker(true)

		OK:SetText("")
		OK:SetPos(w*0.55, h*0.65)
		OK:SetSize(w*0.12, h*0.05)
		OK:SetEnabled(true)
		OK.Paint = function() end

		local timestart = CurTime()

		local fakeLoadingDuration = math.Rand(0.5, 3.5)
		local loading = true
		local loadingStart = CurTime()

		local bgScale, bgAlpha, bgAnimStart = 0, 0, CurTime()
		local contentAlpha, contentStart = 0, CurTime()

		local closing = false
		local closeStartTime = 0
		local playedfadeSound = false

		local contMarkup = markup.Parse( "<font=UVWorldFont3"..GetFontSuffixForLanguage()..">" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue")) .. "</font>" )

        ResultPanel.Paint = function(self, w, h)
			local curTime = CurTime()
			local elapsedAnim = curTime - bgAnimStart
			local effectiveAlpha = contentAlpha
			local headerAlpha = 0

			-- Opening background animation
			bgScale = math.Clamp(elapsedAnim / 0.2, 0, 1)
			bgAlpha = math.Clamp((elapsedAnim - 0.1)/0.3, 0, 1)*255

			local shrinkFactor = 1
			local baseHeight = h - h*0.6
			local scaledHeight = baseHeight * bgScale * shrinkFactor
			local yOffset = (baseHeight - scaledHeight) * 0.5

			-- Closing two-phase logic
			if closing then
				OK:SetEnabled(false)
				gui.EnableScreenClicker(false)
				local elapsedFade = curTime - closeStartTime
				local textFadeDuration, bgShrinkDuration = 0.125, 0.15

				-- Phase 1: fade out texts/buttons
				local textProgress = math.Clamp(elapsedFade / textFadeDuration, 0, 1)
				effectiveAlpha = contentAlpha * (1 - textProgress)
				headerAlpha = 255 * (1 - textProgress)

				-- Phase 2: shrink background vertically
				local bgProgress = math.Clamp((elapsedFade - textFadeDuration) / bgShrinkDuration, 0, 1)
				shrinkFactor = 1 - bgProgress

				scaledHeight = baseHeight * bgScale * shrinkFactor
				yOffset = (baseHeight - scaledHeight) * 0.5

				if not playedfadeSound and elapsedFade >= 0.05 then
					playedfadeSound = true
					surface.PlaySound("uvui/world/close.wav")
				end

				if elapsedFade >= textFadeDuration + bgShrinkDuration then
					hook.Remove("CreateMove", "JumpKeyCloseDebrief")
					hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
					if IsValid(ResultPanel) then ResultPanel:Close() end
					return
				end
			end

			if not loading and not closing then
				local revealProgress = math.Clamp((curTime - contentStart) / 0.6, 0, 1)
				contentAlpha = revealProgress * 255
			end

			if loading then
				headerAlpha = bgAlpha
			else
				headerAlpha = effectiveAlpha
			end

			-- Draw background
			surface.SetDrawColor( 255, 255, 255, bgAlpha)
			surface.SetMaterial(UVMaterials["RESULTSBG_WORLD"])
			surface.DrawTexturedRect( w*0.33, h*0.3 + yOffset, w - w*0.66, scaledHeight )

			-- Header
			local headerDrawAlpha = 0

			if loading then
				headerDrawAlpha = bgAlpha
			elseif closing then
				headerDrawAlpha = effectiveAlpha
			else
				headerDrawAlpha = 255
			end
			
			draw.SimpleTextOutlined( UVString("uv.results.pursuit.carbon"), "UVWorldFont3" .. GetFontSuffixForLanguage(), w*0.335, h*0.305, Color( 137, 242, 248, headerDrawAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ))

			-- Loading elements
			if loading then
				OK:SetEnabled(false)
				draw.SimpleTextOutlined( UVString("uv.race.loading"), "UVWorldFont6" .. GetFontSuffixForLanguage(), w*0.5, h*0.525, Color( 200, 200, 200, headerAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, headerAlpha ) )
				DrawIcon( UVMaterials["LOADING_WORLD_R"], w*0.5, h*0.5, 0.05, Color( 255, 255, 255, headerAlpha ), { rotation = ( -RealTime() * 360 ) % 360 } )
				DrawIcon( UVMaterials["LOADING_WORLD_L"], w*0.5, h*0.5, 0.04, Color( 255, 255, 255, headerAlpha ), { rotation = ( RealTime() * 180 ) % 360 } )
				surface.SetDrawColor( 255, 255, 255, headerAlpha )
				surface.SetMaterial(UVMaterials["RESULTS_NEXTBTN_INACTIVE_WORLD"])
				surface.DrawTexturedRect( w*0.55, h*0.65, w*0.12, h*0.05 )

				surface.SetAlphaMultiplier(headerAlpha / 255)
				contMarkup:Draw(w * 0.61, h * 0.661, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				surface.SetAlphaMultiplier(1)

				if curTime - loadingStart >= fakeLoadingDuration then
					loading = false
					timestart = CurTime()
					OK:SetEnabled(true)
					contentAlpha = 0
					contentStart = CurTime()
				else return end
			end

			-- Header
			surface.SetDrawColor(255, 255, 255, effectiveAlpha)
			surface.SetMaterial(UVMaterials[debvriefbustedbg and "RESULTS_SHEEN_BUSTED" or "RESULTS_SHEEN_ESCAPED"])
			surface.DrawTexturedRect(w * 0.33, h * 0.305, w - ( w * 0.66 ), h * 0.1)

			draw.SimpleTextOutlined( debrieftitletext, "UVWorldFont2" .. GetFontSuffixForLanguage(), w * 0.5, h * 0.33, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, effectiveAlpha) )
			draw.SimpleTextOutlined( debrieftitlevar, "UVWorldFont3" .. GetFontSuffixForLanguage(), w * 0.5, h * 0.375, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )

            -- Text
			draw.SimpleTextOutlined( UVString("uv.results.chase.bounty"), "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.34, h * 0.46, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( UVString("uv.results.chase.time"), "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.34, h * 0.485, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( UVString("uv.results.chase.units.deployed"), "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.34, h * 0.51, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( UVString("uv.results.chase.units.damaged"), "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.34, h * 0.535, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( UVString("uv.results.chase.units.destroyed"), "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.34, h * 0.56, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( UVString("uv.results.chase.dodged.blocks"), "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.34, h * 0.585, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( UVString("uv.results.chase.dodged.spikes"), "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.34, h * 0.61, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
            		
			draw.SimpleTextOutlined( "$" .. bounty, "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.66, h * 0.46, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( time, "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.66, h * 0.485, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( deploys, "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.66, h * 0.51, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( tags, "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.66, h * 0.535, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( wrecks, "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.66, h * 0.56, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( roadblocksdodged, "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.66, h * 0.585, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )
			draw.SimpleTextOutlined( spikestripsdodged, "UVWorldFont3" .. GetFontSuffixForLanguage(),w * 0.66, h * 0.61, Color( 225, 255, 255, effectiveAlpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, effectiveAlpha ) )

			-- Next button and auto-close
			local elapsed = math.max(0, curTime - timestart)
			local autoCloseRemaining = math.max(0,30 - elapsed)
			local autotext = string.format(UVString("uv.results.autoclose"), math.ceil(autoCloseRemaining))

			surface.SetDrawColor(255,255,255,effectiveAlpha*math.abs(math.sin(RealTime()*3)))
			surface.SetMaterial(UVMaterials["RESULTS_NEXTBTN_GLOW_WORLD"])
			surface.DrawTexturedRect(w*0.55,h*0.65,w*0.12,h*0.05)
			surface.SetDrawColor(255,255,255,effectiveAlpha)
			surface.SetMaterial(UVMaterials["RESULTS_NEXTBTN_WORLD"])
			surface.DrawTexturedRect(w*0.55,h*0.65,w*0.12,h*0.05)
			
			surface.SetAlphaMultiplier(effectiveAlpha / 255)
			contMarkup:Draw(w * 0.61, h * 0.661, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			surface.SetAlphaMultiplier(1)

			draw.SimpleTextOutlined(autotext,"UVWorldFont7" .. GetFontSuffixForLanguage(),w*0.335,h*0.675, Color(200,200,200,effectiveAlpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,1,Color(0,0,0,effectiveAlpha))

			if debriefunitspawn and (UVHUDWantedSuspects and #UVHUDWantedSuspects > 0) then
				local uwMarkup = markup.Parse( "<color=200,200,200><font=UVWorldFont7"..GetFontSuffixForLanguage()..">" .. UVReplaceKeybinds("[+reload] " .. UVString("uv.pm.spawnas"), "Small") .. "</font></color>" )
				surface.SetAlphaMultiplier(effectiveAlpha / 255)
				uwMarkup:Draw(w * 0.335, h * 0.655, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				surface.SetAlphaMultiplier(1)
			end
			
			if autoCloseRemaining <= 0 and not closing then
				hook.Remove("CreateMove", "JumpKeyCloseDebrief")
				hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
				closing = true
				closeStartTime = CurTime()
			end
        end
        
        function OK:DoClick() 
            hook.Remove("CreateMove", "JumpKeyCloseDebrief")
			hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
			closing = true
			closeStartTime = CurTime()
        end

		hook.Add("CreateMove", "JumpKeyCloseDebrief", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if ply:KeyPressed(IN_JUMP) then
				if IsValid(ResultPanel) then
					hook.Remove("CreateMove", "JumpKeyCloseDebrief")
					hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
					closing = true
					closeStartTime = CurTime()
				end
			end
		end)

		if debriefunitspawn and (UVHUDWantedSuspects and #UVHUDWantedSuspects > 0) then
			hook.Add("CreateMove", "ReloadKeyCloseDebrief", function()
				local ply = LocalPlayer()
				if not IsValid(ply) then return end

				if ply:KeyPressed(IN_RELOAD) then
					if IsValid(ResultPanel) then
						hook.Remove("CreateMove", "JumpKeyCloseDebrief")
						hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
						closing = true
						closeStartTime = CurTime()

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
        color = Color(255, 183, 61),
        iconMaterial = UVMaterials['RESULTCOP'],
        titleText = UVString("uv.results.escapedfrom"),
    }
    UV_UI.pursuit.world.events.ShowDebrief(params)
end,

onRacerBustedDebrief = function(bustedtable)
    local params = {
        dataTable = bustedtable,
        color = Color(255, 183, 61),
        iconMaterial = UVMaterials['RESULTCOP'],
		titleText = UVString("uv.results.busted"),
        titleVar = string.format( UVString("uv.results.bustedby"), UVString( bustedtable["Unit"] ) ),
		spawnAsUnit = true,
		bustedBG = true,
    }
    UV_UI.pursuit.world.events.ShowDebrief(params)
end,

onCopBustedDebrief = function(bustedtable)
    local params = {
        dataTable = bustedtable,
        color = Color(61, 183, 255),
        textcolor = Color(142, 221, 255, 107),
        iconMaterial = UVMaterials['RESULTCOP'],
        titleText = UVString("uv.results.busted"),
        titleVar = UVString("uv.results.suspects.busted"),
        -- titleVar = string.format( UVString("uv.results.suspects.busted"), bustedtable["Unit"] ),
    }
    UV_UI.pursuit.world.events.ShowDebrief(params)
end,

onCopEscapedDebrief = function(escapedtable)
    local params = {
        dataTable = escapedtable,
        color = Color(61, 183, 255),
        textcolor = Color(142, 221, 255, 107),
        iconMaterial = UVMaterials['RESULTCOP'],
        titleText = string.format(UVString("uv.results.suspects.escaped.num"), UVHUDWantedSuspectsNumber),
		bustedBG = true,
    }
    UV_UI.pursuit.world.events.ShowDebrief(params)
end,

	onPullOverRequest = function(...)
		UV_UI.racing.world.events.CenterNotification({
			text = UVString("uv.hud.fine.pullover"),
			color = Color( 137, 242, 248 ),
			colorbg = Color(66, 194, 222, 50),
			immediate = true,
			timer = 3,
		})
	end,
	onFined = function( finenr )
		UV_UI.racing.world.events.CenterNotification({
			text = string.format( UVString("uv.hud.fine.fined"), finenr),
			color = Color( 137, 242, 248 ),
			colorbg = Color(66, 194, 222, 50),
			immediate = true,
			timer = 5,
		})
	end,
}

-- Functions

function UVDisplayTimeRaceWorld(time) -- include milliseconds in the string
	local formattedtime = string.FormattedTime( time )

	local hours = math.floor( time / 3600 )
	if hours < 1 then
		timestring = string.format( "%02d:%02d", formattedtime.m, formattedtime.s )
	else
		timestring = string.format( "%02d:%02d:%02d", formattedtime.h, formattedtime.m, formattedtime.s )
	end

	local milliseconds = math.floor( ( time - math.floor( time ) ) * 100 )
	timestring = timestring .. string.format( ".%02d", milliseconds )

	return timestring
end

local function world_racing_main( ... )
    local w = ScrW()
    local h = ScrH()
    
    local my_vehicle = select(1, ...)
    local my_array = select(2, ...)
    local string_array = select(3, ...)
    
    local racer_count = #string_array
    local lang = UVString
    
    local checkpoint_count = #my_array["Checkpoints"]
    
    ------------------------------------
    
	local worldcols = {
		reg = Color( 200, 200, 200 ),
		regbg = Color( 0, 0, 0),
		
		val = Color( 137, 242, 248 ),
		valbg = Color( 89, 176, 193, 50 ),

		plr = Color( 225, 255, 255 ),
		plrbg = Color( 66, 194, 222, 50 ),
		
		dnf = Color( 200, 200, 200, 150 ),
		dnfbg = Color( 0, 0, 0, 125 ),
		
		busted = Color( 255, 255, 255, 100 ),
		bustedbg = Color( 222, 66, 66, 50 ),
		
		finished = Color( 255, 255, 255, 100 ),
		finishedbg = Color( 66, 222, 66, 50 ),
	}

    -- Timer
	draw.SimpleTextOutlined( UVString("uv.race.hud.laptime.world"), "UVWorldFont1", UV_UI.X(w * 0.83), h * 0.1175, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg )
	
    local current_time = "--:--.--"
    
    if not my_array.LastLapTime then
        current_time = UVDisplayTimeRaceWorld( (UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time)) or 0 )
    else
        current_time = UVDisplayTimeRaceWorld( CurTime() - my_array.LastLapCurTime )
    end

	-- Split into main and ms
	local mainTime, msTime = current_time:match("^(.-)(%.%d+)$")
	if not mainTime then
		mainTime = current_time
		msTime = ""
	end

	-- Draw main part
	draw.SimpleTextOutlined( mainTime, "UVWorldFont2" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8225), h * 0.125, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )

	-- MS Code
	surface.SetFont("UVWorldFont2")
	local mainW = surface.GetTextSize(mainTime)
	draw.SimpleTextOutlined( msTime, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8225) + mainW, h * 0.137, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )

    -- Lap & Checkpoint Counter
    if UVHUDRaceInfo.Info.Laps > 1 then
		draw.SimpleTextOutlined( UVString("uv.race.hud.lap"), "UVWorldFont1", UV_UI.X(w * 0.93), h * 0.1725, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg )
		draw.SimpleTextOutlined( my_array.Lap .. "/" .. UVHUDRaceInfo.Info.Laps,"UVWorldFont4" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.925),h * 0.1825, worldcols.val,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
	
		-- Best Lap Timer
		draw.SimpleTextOutlined( UVString("uv.race.hud.besttime.world"), "UVWorldFont1", UV_UI.X(w * 0.83), h * 0.1675, worldcols.reg, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg )
		
		local btt, bttm = "-", ""
		if my_array.BestLapTime then
			btt = UVDisplayTimeRaceWorld(my_array.BestLapTime)

			-- Split into main and ms
			local mainBestTime, msBestTime = btt:match("^(.-)(%.%d+)$")
			if not mainBestTime then
				mainBestTime = btt
				msBestTime = ""
			end

			-- Draw main part
			draw.SimpleTextOutlined( mainBestTime, "UVWorldFont2" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8225), h * 0.175, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )

			-- MS Code
			surface.SetFont("UVWorldFont2" .. GetFontSuffixForLanguage())
			local bestW = surface.GetTextSize(mainBestTime)
			draw.SimpleTextOutlined( msBestTime, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8225) + bestW, h * 0.187, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
		else
			draw.SimpleTextOutlined( btt, "UVWorldFont2" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.85), h * 0.175, worldcols.val, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, worldcols.valbg )
		end
    else -- Single Lap / Sprint
		draw.SimpleTextOutlined( UVString("uv.race.hud.complete"), "UVWorldFont1", UV_UI.X(w * 0.83), h * 0.1675, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg )
		draw.SimpleTextOutlined( math.floor(((checkpoint_count / GetGlobalInt("uvrace_checkpoints")) * 100)) .. "%","UVWorldFont2" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8225), h * 0.175, worldcols.val,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
    end

    local racer_count = #string_array
    
    -- Position Counter
    if racer_count > 1 then
        draw.SimpleTextOutlined(UVString("uv.results.race.pos.caps"), "UVWorldFont1", UV_UI.X(w * 0.93), h * 0.1225, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg )
        draw.SimpleTextOutlined(UVHUDRaceCurrentPos .. "/" .. UVHUDRaceCurrentParticipants,"UVWorldFont4" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.925), h * 0.1325, worldcols.val,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
    end
    
    -- Racer List
    local alt = math.floor(CurTime() / 5) % 2 == 1 -- toggles every 5 seconds
    for i = 1, math.Clamp(racer_count, 1, 14), 1 do
        if racer_count == 1 then return end
		
        local entry = string_array[i]
        
        local racer_name = entry[1]
        local is_local_player = entry[2]
        local mode = entry[3]
        local diff = entry[4]
        local racercount = i * (h * 0.0275)
        
        local Strings = {
            ["Time"] = "%s",
            ["Lap"] = lang("uv.race.suffix.lap"),
            ["Laps"] = lang("uv.race.suffix.laps"),
            ["Finished"] = lang("uv.race.suffix.finished"),
            ["Disqualified"] = lang("uv.race.suffix.dnf"),
            ["Busted"] = lang("uv.race.suffix.busted"),
        }
        
        local status_text = "- - - - -"
        
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
						num = ((num > 0 and "+") or "-") .. tostring(math.abs(num))
					elseif num then
						num = ((num > 0 and "+") or "-") .. string.format("%.2f", math.abs(num))
					end

					table.insert(args, num)
				end

				status_text = (#args <= 0) and status_string or string.format(status_string, unpack(args))
			end
		end
        
        local color = nil
        local colorbg = nil
		local bgs = 3
        
        if is_local_player then
            color = worldcols.plr
            colorbg = worldcols.plrbg
			-- bgs = 4
        elseif entry[3] == "Disqualified" then
            color = worldcols.dnf
            colorbg = worldcols.dnfbg
			-- bgs = 2
        elseif entry[3] == "Busted" then
            color = worldcols.busted
            colorbg = worldcols.bustedbg
        elseif entry[3] == "Finished" then
            color = worldcols.finished
            colorbg = worldcols.finishedbg
        else
            color = worldcols.val
            colorbg = worldcols.valbg
        end
        
        local text = alt and (status_text) or (racer_name)

        if is_local_player then
			DrawIcon(UVMaterials["RACE_PLAYERMARKER_WORLD"], UV_UI.X(w * 0.815), (h * 0.2075) + racercount, 0.02, Color(255, 255, 255) )
        end

        if entry[3] == "Finished" then
			-- DrawIcon(UVMaterials["RACE_PLAYERMARKER_WORLD"], w * 0.815, (h * 0.2075) + racercount, 0.02, Color(255, 255, 255) )
        end

        if entry[3] == "Disqualified" then
			DrawIcon(UVMaterials["RACE_DNFMARKER_WORLD"], UV_UI.X(w * 0.815), (h * 0.2075) + racercount, 0.02, Color(255, 255, 255) )
        end

        if entry[3] == "Busted" then
			DrawIcon(UVMaterials["RACE_BUSTEDMARKER_WORLD"], UV_UI.X(w * 0.815), (h * 0.2075) + racercount, 0.03, Color(255, 255, 255) )
        end

        draw.SimpleTextOutlined( i, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8225), (h * 0.1925) + racercount, color,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, bgs, colorbg )
        draw.SimpleTextOutlined( racer_name, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8425), (h * 0.1925) + racercount, color,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, bgs, colorbg )
    end
end

local function world_pursuit_main( ... )
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
    
    local states = UV_UI.pursuit.world.states
    
    local UVWrecksColor = states.WrecksColor
    local UVTagsColor = states.TagsColor
    local UVUnitsColor = states.UnitsColor
    
    --------------------------------------------------
        
	local worldcols = {
		reg = Color( 200, 200, 200 ),
		regbg = Color( 0, 0, 0),
		val = Color( 137, 242, 248 ),
		valbg = Color( 89, 176, 193, 50 ),
				
		busted = Color( 255, 240, 240, 255 ),
		bustedbg = Color( 222, 66, 66, 50 ),
	}
	
    outofpursuit = CurTime()
    
    local UVHeatBountyMin
    local UVHeatBountyMax
    
    states.EvasionColor = Color(255, 255, 255, 50)
    states.BustedColor = Color(255, 255, 255, 50)
    
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
                states.BustedColor = Color(255, blink, blink)
            end
        end
    end
    
    --if not UVHUDRace then
    local ResourceText = UVResourcePoints
    local theme_color = (UVHUDCopMode and table.Copy(UVColors.MW_Cop)) or table.Copy(UVColors.MW_Racer)

    -- [ Upper Right Info Box ] --
    -- Timer
	draw.SimpleTextOutlined( UVString("uv.chase.time.world"), "UVWorldFont1", UV_UI.X(w * 0.885), h * 0.1175, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg )
	
	-- Split into main and ms
	local mainTime, msTime = UVTimer:match("^(.-)(%.%d+)$")
	if not mainTime then
		mainTime = UVTimer
		msTime = ""
	end

	surface.SetFont("UVWorldFont2" .. GetFontSuffixForLanguage())
	local mainW = surface.GetTextSize(mainTime)
	draw.SimpleTextOutlined( mainTime, "UVWorldFont2" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.88), h * 0.125, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
	draw.SimpleTextOutlined( msTime, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.88) + mainW, h * 0.137, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
    
	-- General Icons
	DrawIcon(UVMaterials["UNIT_WORLD"], UV_UI.X(w * 0.89), h * 0.19, 0.06, Color(255, 255, 255) ) -- Damaged
	DrawIcon(UVMaterials["UNIT_DMG_WORLD"], UV_UI.X(w * 0.899), h * 0.1775, 0.03, Color(255, 255, 255) ) -- Damage Marker
	draw.SimpleTextOutlined( UVTags, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.9025), h * 0.176, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
	
	DrawIcon(UVMaterials["UNIT_WORLD"], UV_UI.X(w * 0.94), h * 0.19, 0.06, Color(255, 255, 255) ) -- Wrecks
	DrawIcon(UVMaterials["UNIT_CROSS_WORLD"], UV_UI.X(w * 0.94), h * 0.19, 0.03, Color(255, 255, 255) ) -- Wrecked Cross
	draw.SimpleTextOutlined( UVWrecks, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.9525), h * 0.176, worldcols.val, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )

    -- Cost to State
	draw.SimpleTextOutlined( UVString("uv.chase.cts.world"), "UVWorldFont1", UV_UI.X(w * 0.885), h * 0.21, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg ) -- Bounty Text
	
    DrawIcon(UVMaterials["CTS_WORLD"], UV_UI.X(w * 0.8825), h * 0.2425, .06, Color(255, 255, 255)) -- Icon
	draw.SimpleTextOutlined( "$" .. UVBounty,"UVWorldFont4" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.8915),h * 0.223, worldcols.val,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, worldcols.valbg )
    
    -- Heat Level
    local UVHeatMinConVar = GetConVar( 'unitvehicle_unit_heatminimumbounty' .. UVHeatLevel )
    local UVHeatMaxConVar = GetConVar( 'unitvehicle_unit_heatminimumbounty' .. UVHeatLevel + 1 )
    
	draw.SimpleTextOutlined( UVString("uv.chase.heatlevel"), "UVWorldFont1", UV_UI.X(w * 0.885), h * 0.265, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg ) -- Bounty Text
	draw.SimpleTextOutlined( UVHeatLevel, "UVWorldFont3" .. GetFontSuffixForLanguage(), UV_UI.X(w * 0.9625), h * 0.279, worldcols.val,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.valbg ) -- Bounty Text

    UVHeatBountyMin = ( UVHeatMinConVar and UVHeatMinConVar:GetInt() ) or math.huge
    UVHeatBountyMax = ( UVHeatMaxConVar and UVHeatMaxConVar:GetInt() ) or math.huge

    local HeatProgress = 0
	local blink = 255 * math.abs(math.sin(RealTime() * 4))
    local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
    local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
    
    if MaxHeatLevel:GetInt() ~= UVHeatLevel then
        if UVUTimeTillNextHeatEnabled:GetInt() == 1 and UVTimeTillNextHeat then --Time till next heat level
            local timedHeatConVar = GetConVar( 'unitvehicle_unit_timetillnextheat' .. UVHeatLevel )
            
            local maxtime = timedHeatConVar and timedHeatConVar:GetInt() or 0
            HeatProgress = (maxtime - UVTimeTillNextHeat) / maxtime
        else
            HeatProgress = ((UVBountyNo - UVHeatBountyMin) / (UVHeatBountyMax - UVHeatBountyMin))
        end
    end

	surface.SetMaterial(UVMaterials["WARNING_WORLD"])
    if HeatProgress >= 0.6 and HeatProgress < 0.75 then
    -- if HeatProgress < 0.75 then
		DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.X(w * 0.8775), h * 0.294, .03, Color(255, 255, 255, blink) )
    elseif HeatProgress >= 0.75 and HeatProgress < 0.9 then
		DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.X(w * 0.8775), h * 0.294, .03, Color(255, 255, 255, blink2) )
    elseif HeatProgress >= 0.9 then
		DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.X(w * 0.8775), h * 0.294, .03, Color(255, 255, 255, blink3) )
    end

    surface.SetDrawColor(Color(0, 0, 0, 200))
    surface.DrawRect(UV_UI.X(w * 0.885), h * 0.285, UV_UI.W(w * 0.075), h * 0.0175)
    surface.SetDrawColor(Color(100, 220, 255))
	
    local B = math.Clamp((HeatProgress) * UV_UI.W(w * 0.075), 0, UV_UI.W(w * 0.075))
    surface.DrawRect(UV_UI.X(w * 0.885), h * 0.285, B, h * 0.0175)

    draw.NoTexture()
	surface.SetDrawColor(0, 0, 0, 200)
	
    surface.DrawRect(UV_UI.X(w * 0.903), h * 0.285, UV_UI.W(w * 0.002), h * 0.0175) -- Left Middle
    surface.DrawRect(UV_UI.X(w * 0.922), h * 0.285, UV_UI.W(w * 0.002), h * 0.0175) -- Middle
    surface.DrawRect(UV_UI.X(w * 0.941), h * 0.285, UV_UI.W(w * 0.002), h * 0.0175) -- Right Middle

    -- [[ Commander Stuff ]]
    if UVOneCommanderActive then
        ResourceText = "⛊"

        local cname = "uv.unit.commander"
        if IsValid(UVHUDCommander) then
            local driver = UVHUDCommander:GetDriver()
            if IsValid(driver) and driver:IsPlayer() then
                cname = driver:Nick()
				draw.SimpleTextOutlined( cname, "UVWorldFont1", UV_UI.X(w * 0.92),h * 0.345, worldcols.reg,TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, worldcols.regbg )
            end
        end

		draw.SimpleTextOutlined( UVString("uv.unit.commander.caps"), "UVWorldFont1", UV_UI.X(w * 0.885),h * 0.31, worldcols.reg,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.regbg ) -- Bounty Text

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
        local healthcolor = Color(255, 255, 255)
        local blink = 255 * math.abs(math.sin(RealTime() * 4))
        local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
        local blink3 = 255 * math.abs(math.sin(RealTime() * 8))

		if healthratio < 0.4 and healthratio > 0.25 then
			DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.X(w * 0.8775), h * 0.337, .03, Color(255, 255, 255, blink) )
		elseif healthratio < 0.25 and healthratio > 0.1 then
			DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.X(w * 0.8775), h * 0.337, .03, Color(255, 255, 255, blink2) )
		elseif healthratio < 0.1 then
			DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.X(w * 0.8775), h * 0.337, .03, Color(255, 255, 255, blink3) )
		end

        if healthratio > 0 then
            surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(UV_UI.X(w * 0.885), h * 0.3275, UV_UI.W(w * 0.075), h * 0.0175)
            surface.SetDrawColor(Color(100, 220, 255))
            local T = math.Clamp((healthratio) * (UV_UI.W(w * 0.075)), 0, UV_UI.W(w * 0.075))
            surface.DrawRect(UV_UI.X(w * 0.885), h * 0.3275, T, h * 0.0175)

			draw.NoTexture()
			surface.SetDrawColor(0, 0, 0, 200)

			surface.DrawRect(UV_UI.X(w * 0.903), h * 0.3275, UV_UI.W(w * 0.002), h * 0.0175) -- Left Middle
			surface.DrawRect(UV_UI.X(w * 0.922), h * 0.3275, UV_UI.W(w * 0.002), h * 0.0175) -- Middle
			surface.DrawRect(UV_UI.X(w * 0.941), h * 0.3275, UV_UI.W(w * 0.002), h * 0.0175) -- Right Middle

        end
    end

    -- [ Bottom Info Box ] --
	local bottomyplus = 0

    if (LocalPlayer().uvspawningunit and LocalPlayer().uvspawningunit.vehicle) or (not UVHUDCopMode and UVHUDRaceFinishCountdownStarted) then
        bottomyplus = -(h * 0.065)
    end

    local bottomy = h * 0.89 + bottomyplus

	-- Evade Box, Icons
	DrawIcon(UVMaterials["CHASEBAR_CAR_WORLD"], UV_UI.XScaled(w * 0.38), bottomy, .035, Color( 255, 255, 255 )) -- Racer Icon
	DrawIcon(UVMaterials["CHASEBAR_COP_WORLD"], UV_UI.XScaled(w * 0.62), bottomy, .035, Color( 255, 255, 255 )) -- Cop Icon
	
	DrawIcon(UVMaterials["CHASEBAR_ARROW_LEFT_WORLD"], UV_UI.XScaled(w * 0.3675), bottomy + (h * 0.022), .035, Color( 255, 255, 255 )) -- Left Arrow
	DrawIcon(UVMaterials["CHASEBAR_ARROW_RIGHT_WORLD"], UV_UI.XScaled(w * 0.6325), bottomy + (h * 0.022), .035, Color( 255, 255, 255 )) -- Right Arrow
	
	-- Borders
    draw.NoTexture()
	surface.SetDrawColor(255, 255, 255, 200)
	surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy + (h*0.029), UV_UI.W(w * 0.258), h * 0.004, 0) -- Bottom
	surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy + (h*0.0225), UV_UI.W(w * 0.008), h * 0.004, 90) -- Middle
	surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.372), bottomy + (h*0.0225), UV_UI.W(w * 0.008), h * 0.004, 90) -- Left
	surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.628), bottomy + (h*0.0225), UV_UI.W(w * 0.008), h * 0.004, 90) -- Right
	
	-- Evade Box, BGs
	surface.SetDrawColor(200, 200, 200, 75)
	
	surface.SetMaterial(UVMaterials["CHASEBAR_LEFT_WORLD"]) -- Left
	surface.DrawTexturedRect(UV_UI.XScaled(w * (0.5 - 0.125)), bottomy + (h*0.00725), UV_UI.W(w * 0.125), h * 0.03)
	
	surface.SetMaterial(UVMaterials["CHASEBAR_RIGHT_WORLD"]) -- Right
	surface.DrawTexturedRect(UV_UI.XScaled(w * 0.5), bottomy + (h*0.00725), UV_UI.W(w * 0.125), h * 0.03)

    if not UVHUDDisplayCooldown then
        -- Evade Meter
        if not UVHUDDisplayNotification and not UVHUDDisplayCooldown and UnitsChasing == 0 and BustingProgress == 0 then
            if not EvadingProgress then
                EvadingProgress = 0
                UVEvadingProgress = EvadingProgress
            end
            
            local T = math.Clamp((UVEvadingProgress) * (UV_UI.W(w * 0.125)), 0, UV_UI.W(w * 0.125))
			T = math.floor(T)
            surface.SetDrawColor(100, 200, 255)
			surface.SetMaterial(UVMaterials["CHASEBAR_LEFT_WORLD"]) -- Left
			surface.DrawTexturedRectUV(UV_UI.XScaled(w * (0.5 - 0.125)) + (UV_UI.W(w * 0.125) - T), bottomy + (h * 0.00725), T, h * 0.03, 1 - (T / (UV_UI.W(w * 0.125))), 0, 1, 1)
        else
            EvadingProgress = 0
        end

        -- Busted Meter
        if UVHUDDisplayBusting and not UVHUDDisplayCooldown then
            if not BustingProgress or BustingProgress == 0 then
                BustingProgress = CurTime()
            end
            
            local blink = 255 * math.abs(math.sin(RealTime() * 4))

            local timeLeft = ((UVHUDDisplayNotification and -1) or (UVBustTimer - UVBustingProgress))

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(UVMaterials["WARNINGBG_WORLD"])
			
			if timeLeft >= 2 and timeLeft < 3 then
				surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy - (h * 0.0), UV_UI.W(w * 0.2575), h * 0.065, 0)
                DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.XScaled(w * 0.5), bottomy + (h * 0.001), .06, Color(255, 255, 255, blink) )
			elseif timeLeft >= 1 and timeLeft < 2 then
				surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy - (h * 0.0), UV_UI.W(w * 0.2575), h * 0.065, 0)
                DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.XScaled(w * 0.5), bottomy + (h * 0.001), .06, Color(255, 255, 255, blink2) )
			elseif timeLeft < 1 then
				surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy - (h * 0.0), UV_UI.W(w * 0.2575), h * 0.065, 0)
                DrawIcon(UVMaterials["WARNING_WORLD"], UV_UI.XScaled(w * 0.5), bottomy + (h * 0.001), .06, Color(255, 255, 255, blink3) )
            end

            local T = math.Clamp((UVBustingProgress / UVBustTimer) * (UV_UI.W(w * 0.125)), 0, UV_UI.W(w * 0.125))
            T = math.floor(T)
            surface.SetDrawColor(255, 0, 0)
			surface.SetMaterial(UVMaterials["CHASEBAR_RIGHT_WORLD"]) -- Right
			surface.DrawTexturedRectUV(UV_UI.XScaled(w * 0.5), bottomy + (h * 0.00725), T, h * 0.03, 0, 0, T / (UV_UI.W(w * 0.125)), 1)
        else
            UVBustedColor = Color(255, 100, 100, 125)
            BustingProgress = 0
        end
		
		local btrm = 0
		
		-- Resource & Backup Timer
		if UVHUDDisplayBackupTimer then
			if UVBackupTimerSeconds > 10 then 
				 DrawIcon(UVMaterials["CHASEBAR_ARROW_RIGHT_WORLD"], UV_UI.XScaled(w * 0.4625), bottomy + (h * 0.05), .035, Color( 255, 255, 255 ))
			elseif UVBackupTimerSeconds < 10 then
				 DrawIcon(UVMaterials["CHASEBAR_ARROW_RIGHT_WORLD"], UV_UI.XScaled(w * 0.4625), bottomy + (h * 0.05), .035, Color( 255, 255, 255, blink ))
			elseif UVBackupTimerSeconds < 5 then
				DrawIcon(UVMaterials["CHASEBAR_ARROW_RIGHT_WORLD"], UV_UI.XScaled(w * 0.4625), bottomy + (h * 0.05), .035, Color( 255, 255, 255, blink2 ))
			elseif UVBackupTimerSeconds < 3 then
				DrawIcon(UVMaterials["CHASEBAR_ARROW_RIGHT_WORLD"], UV_UI.XScaled(w * 0.4625), bottomy + (h * 0.05), .035, Color( 255, 255, 255, blink3 ))
			end

			draw.SimpleTextOutlined( UVBackupTimer, "UVWorldFont4" .. GetFontSuffixForLanguage(), UV_UI.XScaled(w * 0.4675), bottomy + (h * 0.03), worldcols.busted,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.bustedbg ) -- Bounty Text
			btrm = w * 0.0525
		end
		
		DrawIcon(UVMaterials["CHASEBAR_COP_WORLD"], UV_UI.XScaled(w * 0.495) + btrm, bottomy + (h * 0.05), .035, Color( 255, 255, 255 )) -- Racer Icon
		draw.SimpleTextOutlined( ResourceText, "UVWorldFont4" .. GetFontSuffixForLanguage(), UV_UI.XScaled(w * 0.505) + btrm, bottomy + (h * 0.03), worldcols.busted,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, worldcols.bustedbg ) -- Bounty Text

    else
        -- Cooldown Meter
        if UVHUDDisplayCooldown then
            
            local blink = 255 * math.abs(math.sin(RealTime() * 4))
            local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
            local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
            
            if not CooldownProgress or CooldownProgress == 0 then
                CooldownProgress = CurTime()
            end

            EvadingProgress = 0
            
            -- Upper Box
            if not UVHUDCopMode then
                local T = math.Clamp((UVCooldownTimer) * (UV_UI.W(w * 0.125)), 0, UV_UI.W(w * 0.125))
				T = math.floor(T)
				
				surface.SetDrawColor(255, 255, 255) -- Background
				surface.SetMaterial(UVMaterials["COOLDOWNBG_WORLD"])
				surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy - (h * 0.005), UV_UI.W(w * 0.2575), h * 0.08, 0)
				DrawIcon(UVMaterials["CHASEBAR_COOLDOWN_WORLD"], UV_UI.XScaled(w * 0.5), bottomy - (h * 0.015), .035, Color(255, 255, 255, blink) )
				draw.SimpleTextOutlined( UVString("uv.chase.cooldown"), "UVWorldFont1", UV_UI.XScaled(w * 0.5), bottomy - (h * 0.0015), worldcols.val,TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, worldcols.valbg )

                surface.SetDrawColor(100, 200, 255, 255)
				surface.SetMaterial(UVMaterials["CHASEBAR_LEFT_WORLD"]) -- Left Bar
				surface.DrawTexturedRectUV(UV_UI.XScaled(w * (0.5 - 0.125)) + (UV_UI.W(w * 0.125) - T), bottomy + (h * 0.00725), T, h * 0.03, 1 - (T / (UV_UI.W(w * 0.125))), 0, 1, 1)
				
				surface.SetMaterial(UVMaterials["CHASEBAR_RIGHT_WORLD"]) -- Right Bar
				surface.DrawTexturedRectUV(UV_UI.XScaled(w * 0.5), bottomy + (h * 0.00725), T, h * 0.03, 0, 0, T / (w * 0.125), 1)
            else
				surface.SetDrawColor(255, 255, 255) -- Background
				surface.SetMaterial(UVMaterials["COOLDOWNBG_WORLD"])
				surface.DrawTexturedRectRotated(UV_UI.XScaled(w * 0.5), bottomy - (h * 0.005), UV_UI.W(w * 0.2575), h * 0.08, 0)
				DrawIcon(UVMaterials["CHASEBAR_COOLDOWN_WORLD"], UV_UI.XScaled(w * 0.5), bottomy - (h * 0.015), .035, Color(255, 255, 255, blink) )
				draw.SimpleTextOutlined( UVString("uv.chase.cooldown"), "UVWorldFont1", UV_UI.XScaled(w * 0.5), bottomy - (h * 0.0015), worldcols.val,TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, worldcols.valbg )
            end
        else
            CooldownProgress = 0
        end
    end
end

UV_UI.pursuit.world.main = world_pursuit_main
UV_UI.racing.world.main = world_racing_main