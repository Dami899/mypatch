UV.RegisterHUD( "carbon", "NFS: Carbon", true )

UV_UI.racing.carbon = UV_UI.racing.carbon or {}
UV_UI.pursuit.carbon = UV_UI.pursuit.carbon or {}

UV_UI.pursuit.carbon.states = {
    TagsColor = Color(255,255,255,150),
    WrecksColor = Color(255,255,255,150),
    UnitsColor = Color(255,255,255,150),
    BustedColor = Color(255, 255, 255, 50),
    EvasionColor = Color(255, 255, 255, 50),
    
    TakedownText = nil,
}

UV_UI.racing.carbon.states = {
    LapCompleteText = nil,
	notificationQueue = {},
	notificationActive = nil,
}

UV_UI.racing.carbon.events = {
	CenterNotification = function( params )
		local immediate = params.immediate or false
		local racenoti = params.raceNoti or false

		if UV_UI.racing.carbon.states.notificationActive then
			if immediate then
				hook.Remove("HUDPaint", "UV_CENTERNOTI_CARBON")
				UV_UI.racing.carbon.states.notificationActive = false
				UV_UI.racing.carbon.states.notificationQueue = {}
				timer.Simple(0, function()
					UV_UI.racing.carbon.events.CenterNotification(params)
				end)
				return
			else
				table.insert(UV_UI.racing.carbon.states.notificationQueue, params)
				return
			end
		end

		UV_UI.racing.carbon.states.notificationActive = true

		local ptext = params.text or "ERROR: NO TEXT"
		local piconMat = params.iconMaterial or UVMaterials["UNITS_DISABLED_CARBON"]
		local piconSize = params.iconSize or 0.06
		local pnoicon = params.noIcon

		local pfontUpper = params.fontUpper or "UVCarbonFont"
		local pfontLower = params.fontLower or "UVCarbonFont-Smaller"

		local pcolUpper = params.colorUpper or Color(255, 255, 255)
		local pcolLower = params.colorLower or Color(175, 175, 175)

		local printCol = params.ringColor or Color(175, 175, 175)
		
		local pflyUp = params.flyUp or false

		local SID = 0.2

		local carbon_noti_animState = {
			active = false,
			startTime = 0,
			slideInDuration = SID,
			holdDuration = 3,
			slideDownDuration = 0.2,
			upper = {
				startX = ScrW() * 0.25,
				centerX = ScrW() / 2,
				y = ScrH() * 0.35,
				slideDownEndY = ScrH() * 0.6,
				slideUpEndY = ScrH() * 0.2,
			},
			lower = {
				startX = ScrW() * 0.75,
				centerX = ScrW() / 2,
				y = ScrH() * 0.385,
				slideDownEndY = ScrH() * 0.635,
				slideUpEndY = ScrH() * 0.235,
			},
			ring = {
				scaleStart = 0.5,
				scaleEnd = 0.09,
				alphaStart = 15,
				alphaEnd = 150,
				scale = 0.2,
				alpha = 15,
				
				shrinkStart = 0,
				shrinkDuration = SID,
				disappearTime = 0.03,
				reappearDelay = SID + 0.03,
				expandStartTime = nil,
				expanded = false,
				visible = true
			},
			ringClone = {
				createdTime = nil,
				blinkInterval = 0.125,
				blinkCount = 0,
				maxBlinks = 2,
				scale = 0.085,
				scaleDuration = 0.6,
				targetScale = 0.07,
				alpha = 175,
				visible = true,
				fadeAfterBlinkStart = nil,
			},
			icon = {
			  scale = piconSize,
			  baseScale = piconSize,
			  overshootScale = piconSize + 0.01,
			  alpha = 255,
			  ExpandDuration = 0.125,
			},
			circle = {
				scaleStart = 0.4,
				scaleEnd = 0.0575,
				alphaStart = 15,
				alphaEnd = 100,

				scale = 0.2,
				alpha = 15,
				rotation = 0,

				spinStartTime = nil,
				spinDuration = 5,
				drawY = ScrH() / 3.35
			},
		}

        UV_UI.racing.carbon.events.carbon_noti_animState = carbon_noti_animState
        carbon_noti_animState.active = true
        carbon_noti_animState.startTime = CurTime()
        
        ----------------------------------------------------------------------------
        
        -- Remove any existing HUDPaint hook with the same name (avoid duplicates)
        if hook.GetTable().HUDPaint and hook.GetTable().HUDPaint.UV_CENTERNOTI_CARBON then
            hook.Remove("HUDPaint", "UV_CENTERNOTI_CARBON")
        end
        
        -- Add the HUDPaint hook freshly for this animation
        hook.Add("HUDPaint", "UV_CENTERNOTI_CARBON", function()
            local elapsed = CurTime() - carbon_noti_animState.startTime
            
            local function calcPosAlpha(elapsed, elem)
                local x, y, alpha = elem.centerX, elem.y, 255
                if elapsed < carbon_noti_animState.slideInDuration then
                    local t = elapsed / carbon_noti_animState.slideInDuration
                    x = Lerp(t, elem.startX, elem.centerX)
                    alpha = Lerp(t, 0, 255)
                elseif elapsed < carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration then
                    x = elem.centerX
                    alpha = 255
                elseif elapsed < carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration + carbon_noti_animState.slideDownDuration then
                    local t = (elapsed - carbon_noti_animState.slideInDuration - carbon_noti_animState.holdDuration) / carbon_noti_animState.slideDownDuration
                    y = Lerp(t, elem.y, (pflyUp and elem.slideUpEndY or elem.slideDownEndY))
                    alpha = Lerp(t, 255, 0)
                else
                    alpha = 0
                end
                return x, y, alpha
            end

            local lines = string.Explode("\n", ptext)
            if #lines < 1 then return end
            local upperLine = lines[1] or ""
            local lowerLine = lines[2] or ""

            -- Upper
            local ux, uy, ualpha = calcPosAlpha(elapsed, carbon_noti_animState.upper)
            carbon_noti_draw( upperLine, pfontUpper, nil, ux, uy, Color(pcolUpper.r, pcolUpper.g, pcolUpper.b, ualpha), nil)

			-- Lower
            local lx, ly, lalpha = calcPosAlpha(elapsed, carbon_noti_animState.lower)
            carbon_noti_draw( lowerLine, pfontLower, nil, lx, ly, Color(pcolLower.r, pcolLower.g, pcolLower.b, lalpha), nil)

            -- Disable animation and remove hook when done
            if elapsed > carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration + carbon_noti_animState.slideDownDuration then
                carbon_noti_animState.active = false
                hook.Remove("HUDPaint", "UV_CENTERNOTI_CARBON")
				timer.Simple(0, function()
					UV_UI.racing.carbon.states.notificationActive = false
					if #UV_UI.racing.carbon.states.notificationQueue > 0 then
						local nextParams = table.remove(UV_UI.racing.carbon.states.notificationQueue, 1)
						timer.Simple(0.05, function() -- give a few ms buffer
							UV_UI.racing.carbon.events.CenterNotification(nextParams)
						end)
					end
				end)
            end

			if pnoicon then return end
			-- Other Elements
			-- Outer Ring
			local ring = carbon_noti_animState.ring
			local elapsed = CurTime() - carbon_noti_animState.startTime

			local mergeEndTime = carbon_noti_animState.slideInDuration
			local blinkDuration = 0.1 -- total blink time (two blinks)
			local blinkInterval = blinkDuration / 2 -- one blink cycle (fade out + in)

			if elapsed < mergeEndTime then
				-- Shrinking phase: scale down & alpha up
				local t = math.Clamp(elapsed / mergeEndTime, 0, 1)
				ring.scale = Lerp(t, ring.scaleStart, ring.scaleEnd)
				ring.alpha = Lerp(t, ring.alphaStart, ring.alphaEnd)
			elseif elapsed < mergeEndTime + blinkDuration then
				-- Blink phase: fade ring out and back in twice

				local blinkElapsed = elapsed - mergeEndTime
				-- Calculate blink phase (0 to 1 to 0) twice in blinkDuration
				local phase = (blinkElapsed / blinkInterval) % 2
				-- Map phase to alpha (1->0->1) using triangle wave
				local alphaFactor = phase < 1 and (1 - phase) or (phase - 1)
				ring.alpha = Lerp(alphaFactor, ring.alphaEnd, 0)

				-- Keep scale steady during blinking
				ring.scale = ring.scaleEnd
			else
				-- Expansion + fade out phase
				local expandElapsed = elapsed - (mergeEndTime + blinkDuration)
				local expandDuration = 0.3
				local t = math.Clamp(expandElapsed / expandDuration, 0, 1)

				ring.scale = Lerp(t, ring.scaleEnd, ring.scaleStart) -- expand out
				ring.alpha = Lerp(t, ring.alphaEnd, 0)   -- fade out
			end

			DrawIcon(UVMaterials["TAKEDOWN_RING_CARBON"], ScrW() / 2, ScrH() / 3.35, ring.scale, Color(printCol.r, printCol.g, printCol.b, ring.alpha))

			-- Outer Ring Duplicate
			local clone = carbon_noti_animState.ringClone

			-- Spawn clone ring after main ring shrinks
			if not clone.createdTime and elapsed >= carbon_noti_animState.slideInDuration then
				clone.createdTime = CurTime()
				clone.blinkCount = 0
			end

			if clone.createdTime then
				local cloneElapsed = CurTime() - clone.createdTime
				local blinkCycle = clone.blinkInterval * 2

				-- Blinking logic
				if clone.blinkCount < clone.maxBlinks then
					local blinkCycle = clone.blinkInterval * 2
					local cloneElapsed = CurTime() - clone.createdTime
					local cycleTime = cloneElapsed % blinkCycle

					if cycleTime < clone.blinkInterval then
						-- Pop in (fully opaque)
						clone.alpha = 255
					else
						-- Fade out during second half of the cycle
						local fadeT = (cycleTime - clone.blinkInterval) / clone.blinkInterval
						clone.alpha = Lerp(fadeT, 255, 0)
					end

					-- Count completed full blink cycles
					local completedCycles = math.floor(cloneElapsed / blinkCycle)
					if completedCycles > clone.blinkCount then
						clone.blinkCount = completedCycles
					end

				else
					-- After blinking ends, fade from 255 to ring.alphaEnd
					if not clone.fadeAfterBlinkStart then
						clone.fadeAfterBlinkStart = CurTime()
					end

					local fadeT = math.Clamp((CurTime() - clone.fadeAfterBlinkStart) / 0.3, 0, 1)
					clone.alpha = Lerp(fadeT, 255, ring.alphaEnd)
				end

				-- Gradual scale-down over total blink duration
				local totalDuration = clone.scaleDuration
				local scaleT = math.min(cloneElapsed / totalDuration, 1)
				clone.scale = Lerp(scaleT, 0.085, clone.targetScale)

				-- Apply final slide down and fade for clone ring (matching text timing)
				local totalDuration = carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration + carbon_noti_animState.slideDownDuration
				if CurTime() > carbon_noti_animState.startTime + carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration then
					local slideElapsed = CurTime() - (carbon_noti_animState.startTime + carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration)
					local t = math.Clamp(slideElapsed / carbon_noti_animState.slideDownDuration, 0, 1)

					-- Move the clone downward (same offset as text)
					local slideOffset = Lerp(t, 0, ScrH() * 0.2)
					clone.drawY = (ScrH() / 3.35) + (pflyUp and -slideOffset or slideOffset)

					-- Fade out over time
					clone.alpha = Lerp(t, clone.alpha, 0)
				else
					clone.drawY = ScrH() / 3.35 -- stay at normal position
				end

				if clone.visible then
					DrawIcon(UVMaterials["TAKEDOWN_RING_CARBON"], ScrW() / 2, clone.drawY, clone.scale, Color(printCol.r, printCol.g, printCol.b, clone.alpha))
				end
			end

			-- Inner Circle
			local circle = carbon_noti_animState.circle
			local t = math.Clamp(elapsed / carbon_noti_animState.slideInDuration, 0, 1)

			-- Step 1: Animate scale + alpha like ring
			if elapsed < carbon_noti_animState.slideInDuration then
				circle.scale = Lerp(t, circle.scaleStart, circle.scaleEnd)
				circle.alpha = Lerp(t, circle.alphaStart, circle.alphaEnd)
			end

			-- Step 2: Start spinning after 4.1 is done blinking
			local clone = carbon_noti_animState.ringClone
			local blinkDoneTime = carbon_noti_animState.startTime + carbon_noti_animState.ring.reappearDelay + (clone.maxBlinks * clone.blinkInterval * 2)

			if CurTime() > blinkDoneTime and not circle.spinStartTime then
				circle.spinStartTime = CurTime()
			end

			if circle.spinStartTime then
				local spinElapsed = CurTime() - circle.spinStartTime
				local spinT = math.Clamp(spinElapsed / circle.spinDuration, 0, 1)
				circle.rotation = Lerp(spinT, 0, -360)
			end

			-- Step 3: Follow slide down like Element 4.1
			if elapsed > carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration then
				local slideT = (elapsed - carbon_noti_animState.slideInDuration - carbon_noti_animState.holdDuration) / carbon_noti_animState.slideDownDuration
				local slideOffset = Lerp(slideT, 0, ScrH() * 0.2)
				circle.drawY = (ScrH() / 3.35) + (pflyUp and -slideOffset or slideOffset)
				circle.alpha = Lerp(slideT, circle.alphaEnd, 0)
			end

			DrawIcon( UVMaterials["TAKEDOWN_CIRCLE_CARBON"], ScrW() / 2, circle.drawY, circle.scale, Color(printCol.r, printCol.g, printCol.b, circle.alpha), { rotation = circle.rotation } )

			-- Takedown Icon
			local icon = carbon_noti_animState.icon
			local elapsed = CurTime() - carbon_noti_animState.startTime

			local slideDownStart = carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration
			local slideDownEnd = slideDownStart + carbon_noti_animState.slideDownDuration

			local slideOffset = 0
			if elapsed > slideDownStart and elapsed < slideDownEnd then
				local t = (elapsed - slideDownStart) / carbon_noti_animState.slideDownDuration
				slideOffset = Lerp(t, 0, ScrH() * 0.2)
			elseif elapsed >= slideDownEnd then
				slideOffset = ScrH() * 0.2
			end

			local currentY = (ScrH() / 3.35) + (pflyUp and -slideOffset or slideOffset)
			local shrinkEnd = carbon_noti_animState.slideInDuration + carbon_noti_animState.ring.shrinkDuration
			local expandEnd = carbon_noti_animState.slideInDuration + carbon_noti_animState.holdDuration

			-- 1) Initial: fully visible
			if elapsed < carbon_noti_animState.slideInDuration then
				icon.scale = icon.baseScale
				icon.alpha = 255

			-- 2) Shrink to 0 instantly when Element 4 finishes shrinking
			elseif elapsed < shrinkEnd then
				icon.scale = 0  -- instant shrink
				icon.alpha = 255

			-- 3) Expand with overshoot during Element 4 expand
			elseif elapsed < expandEnd then
				local expandStart = carbon_noti_animState.slideInDuration + carbon_noti_animState.ring.shrinkDuration
				local expandElapsed = elapsed - expandStart
				local expandDuration = carbon_noti_animState.icon.ExpandDuration
				local t = math.Clamp(expandElapsed / expandDuration, 0, 1)

				if t < 0.8 then
					icon.scale = Lerp(t / 0.8, 0, icon.overshootScale)
				else
					icon.scale = icon.baseScale
				end

				icon.alpha = 255

			-- 4) Slide down with element 4.1, fade out alpha
			elseif elapsed < slideDownEnd then
				local fadeT = (elapsed - slideDownStart) / carbon_noti_animState.slideDownDuration
				icon.alpha = Lerp(fadeT, 255, 0)
			else
				icon.alpha = 0
			end

			DrawIcon(piconMat, ScrW() / 2, currentY, icon.scale, Color(255, 255, 255, icon.alpha))
		end)
	end,
	
    ShowResults = function(sortedRacers) -- Carbon
        if UVHUDDisplayRacing then return end
        if IsValid(ResultPanel) then ResultPanel:Remove() end
        
        local w = ScrW()
        local h = ScrH()
        
        --------------------------------------

        OK = vgui.Create("DButton", vgui.GetWorldPanel())
        OK:SetText("")
        OK:SetPos(w*0.2565, h*0.9)
        OK:SetSize(w*0.3, h*0.035)
        OK.Paint = function() end

        ResultPanel = vgui.Create("DPanel", vgui.GetWorldPanel())
        ResultPanel:Add(OK)
        ResultPanel:SetSize(w, h)
        -- ResultPanel:SetPos(0, 0)
        ResultPanel:SetMouseInputEnabled(true)
        ResultPanel:SetKeyboardInputEnabled(false)
        ResultPanel:SetZPos(32767)

        local targetY = 0
        local overshootY = h * 0.1  -- drops 10% below target before bouncing back
        local startY = -h           -- start fully above the screen
        
        ResultPanel:SetPos(0, startY)
        
        local animTime = 0.33
        local bounceTime = 0.1
        local startTime = CurTime()
        
        hook.Add("Think", "ResultPanelEntranceAnim", function()
            local elapsed = CurTime() - startTime
            
            if elapsed < animTime then
                if elapsed < animTime - bounceTime then
                    local frac = elapsed / (animTime - bounceTime)
                    local y = Lerp(frac, startY, overshootY)
                    ResultPanel:SetPos(0, y)
                else
                    local frac = (elapsed - (animTime - bounceTime)) / bounceTime
                    local y = Lerp(frac, overshootY, targetY)
                    ResultPanel:SetPos(0, y)
                end
            else
                ResultPanel:SetPos(0, targetY)
                hook.Remove("Think", "ResultPanelEntranceAnim")
            end
        end)
        
        local function AnimateAndRemovePanel(panel)
            if not IsValid(panel) then return end
            
            local startY = panel:GetY()
            local endY = ScrH()  -- off-screen below
            local animTime = 0.33
            local startTime = CurTime()
            
            -- Play sounds ONCE at start
            surface.PlaySound("uvui/carbon/fe_common_mb [5].wav")
            surface.PlaySound("uvui/carbon/fe_common_mb [6].wav")
            
            -- Disable interactivity
            panel:SetMouseInputEnabled(false)
            gui.EnableScreenClicker(false)
			OK:SetEnabled(false)
            
            hook.Add("Think", "ResultPanelExitAnim", function()
                if not IsValid(panel) then
                    hook.Remove("Think", "ResultPanelExitAnim")
                    return
                end
                
                local elapsed = CurTime() - startTime
                if elapsed < animTime then
                    local frac = elapsed / animTime
                    local y = Lerp(frac, startY, endY)
                    panel:SetPos(0, y)
                else
                    panel:Remove()
                    hook.Remove("Think", "ResultPanelExitAnim")
                end
            end)
        end
        
        gui.EnableScreenClicker(true)

        local timetotal = 30
        local timestart = CurTime()
        local exitStarted = false -- prevent repeated trigger
        
        local finalTitle = "★" .. UVString("uv.results.standings") .. "★"
        local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()[]{}<>,./?|"
        local revealSpeed = 0.05
        local displayStart = CurTime()
        local scrambleSound
        local isScrambling = true
        local revealedChars = 0
        
        sound.Add({
            name = "UV.Carbon.Scramble",
            channel = CHAN_STATIC,
            volume = 1.0,
            level = 70,
            pitch = { 100 },
            sound = "uvui/carbon/textfold.wav"
        })
        
        -- Start reveal timer
        timer.Create("ScrambleTextUpdate", revealSpeed, #finalTitle, function()
            revealedChars = revealedChars + 1
            
            -- Start the loop sound
            if isScrambling and not scrambleSound then
                scrambleSound = CreateSound(LocalPlayer(), "UV.Carbon.Scramble")
                if scrambleSound then
                    scrambleSound:Play()
                end
            end
            
            -- Stop when done
            if revealedChars >= #finalTitle then
                isScrambling = false
                if scrambleSound then
                    scrambleSound:FadeOut(0.2)
                    scrambleSound = nil
                end
            end
        end)
        
        local entriesToShow = 13
        local scrollOffset = 0
        
        ResultPanel.OnMouseWheeled = function(self, delta)
            local maxOffset = math.max(0, #sortedRacers - entriesToShow)
            scrollOffset = math.Clamp(scrollOffset - delta, 0, maxOffset)
        end
        
        -- Data and labels
        local racersArray = {}
        
        for _, dict in pairs(sortedRacers) do
            table.insert(racersArray, dict)
        end
        
        table.sort(racersArray, function(a, b)
            local timeA = a.array and a.array.TotalTime
            local timeB = b.array and b.array.TotalTime
            
            -- Treat missing or non-numeric TotalTime as a large number (DNF)
            local tA = (type(timeA) == "number") and timeA or math.huge
            local tB = (type(timeB) == "number") and timeB or math.huge
            
            return tA < tB
        end)
        
        ResultPanel.Paint = function(self, w, h)
			local alttext = math.floor(CurTime() / 5) % 2 == 1
            local timeremaining = math.ceil(timetotal - (CurTime() - timestart))
            local lang = UVString
            
            -- Main black BG
            surface.SetMaterial(UVMaterials['BG_BIG_CARBON'])
            surface.SetDrawColor( 0, 0, 0, 225 )
            surface.DrawTexturedRect( 0, 0, w, h)
            
            -- Upper Results Tab
            surface.SetDrawColor( 0, 0, 0, 200 )
            surface.DrawRect( w*0.25, h*0.185, w*0.5, h*0.075)
            
            surface.SetMaterial(UVMaterials['EOC_FRAME_CARBON'])
            surface.SetDrawColor(86, 214, 205)
            surface.DrawTexturedRect( w*0.26, h*0.17825, w*0.485, h*0.09)
            
            DrawIcon( UVMaterials['X_OUTER_CARBON'], w*0.255, h*0.215, 0.2, Color(0,0,0) ) -- Icon
            DrawIcon( Material("unitvehicles/hud_carbon/x_anim"), w*0.255, h*0.215, 0.2, Color(255,255,255) ) -- Animated Icon; TBD
            
            local timePassed = CurTime() - displayStart
            local charsToReveal = math.min(#finalTitle, math.floor(timePassed / revealSpeed))
            
            local animatedTitle = ""
            
            for i = 1, #finalTitle do
                if i <= charsToReveal then
                    animatedTitle = animatedTitle .. finalTitle:sub(i, i)
                else
                    local randIndex = math.random(#charset)
                    local randChar = charset:sub(randIndex, randIndex)
                    animatedTitle = animatedTitle .. randChar
                end
            end
            
            draw.DrawText(animatedTitle, "UVCarbonFont", w * 0.3, h * 0.2, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            
            -- Next Lower, results subtext
            -- surface.SetMaterial(UVMaterials['BACKGROUND_BIGGER'])
            surface.SetDrawColor( 0, 0, 0, 235 )
            surface.DrawRect( w*0.25, h*0.3, w*0.5, h*0.03)
            
            draw.DrawText( "#uv.results.race.pos.caps", "UVCarbonLeaderboardFont", w*0.2565, h*0.3025, Color( 255, 255, 255), TEXT_ALIGN_LEFT )
            draw.DrawText( "#uv.results.race.name.caps", "UVCarbonLeaderboardFont", w*0.325, h*0.3025, Color( 255, 255, 255), TEXT_ALIGN_LEFT )
            draw.DrawText( "#uv.results.race.car.caps", "UVCarbonLeaderboardFont", w*0.45, h*0.3025, Color( 255, 255, 255), TEXT_ALIGN_LEFT )
            draw.DrawText( "#uv.results.race.time.caps", "UVCarbonLeaderboardFont", w*0.74, h*0.3025, Color( 255, 255, 255), TEXT_ALIGN_RIGHT )
            
            -- Draw visible racer entries
            local startIndex = scrollOffset + 1
            local endIndex = math.min(startIndex + entriesToShow - 1, #sortedRacers)
            
            local rowYStart = h * 0.34
            local rowHeight = h * 0.035
            
            for i = startIndex, endIndex do
                local racer = racersArray[i]
                local y = rowYStart + ((i - startIndex) * rowHeight)
                local ymax = w * 0.2
                local ynmax = w * 0.12
				
                local info = racer.array or racer  -- fallback if 'array' doesn't exist
                
                local name = info["Name"] or "Unknown"
                local totalTime = info["TotalTime"] and info["TotalTime"] or "#uv.race.suffix.dnf"
                
                if info["Busted"] then totalTime = "#uv.race.suffix.busted" end
				
			   	surface.SetFont("UVCarbonLeaderboardFont")
               local vehname = info["VehicleName"]
			   vehname = vehname and string.Trim(UVString(vehname), "#") or "<UNKNOWN>"

				textW = surface.GetTextSize(vehname)
				if textW > ymax then
					while surface.GetTextSize(vehname .. "...") > ymax do
						vehname = string.sub(vehname, 1, -2)
					end
					vehname = vehname .. "..."
				end
				
				textnW = surface.GetTextSize(name)
				if textnW > ynmax then
					while surface.GetTextSize(name .. "...") > ynmax do
						name = string.sub(name, 1, -2)
					end
					name = name .. "..."
				end
				
                -- Background for zebra striping
                local bgAlpha = (i % 2 == 0) and 100 or 50
                surface.SetMaterial(UVMaterials['BACKGROUND_CARBON_FILLED'])
                surface.SetDrawColor(86, 214, 205, bgAlpha)
                surface.DrawTexturedRect(w * 0.25, y, w * 0.485, rowHeight)
                
                surface.SetMaterial(UVMaterials['ARROW_CARBON'])
                surface.DrawTexturedRect( w * 0.735, y, w * 0.015, rowHeight)

				draw.SimpleTextOutlined( tostring(i), "UVCarbonLeaderboardFont", w * 0.2565, y + h * 0.0035, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0) )
				draw.SimpleTextOutlined( name, "UVCarbonLeaderboardFont", w * 0.325, y + h * 0.0035, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0) )
				draw.SimpleTextOutlined( vehname, "UVCarbonLeaderboardFont", w * 0.45, y + h * 0.0035, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0) )
				draw.SimpleTextOutlined( UV_FormatRaceEndTime(totalTime), "UVCarbonLeaderboardFont", w * 0.74, y + h * 0.0035, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0) )
            end
            
            -- Time remaining and closing
            local blink = 255 * math.abs(math.sin(RealTime() * 8))
			
			local conttext = "<color=255,255,255><font=UVCarbonLeaderboardFont>" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue")) .. "</font></color>"
			local mk = markup.Parse(conttext)
			local conttextw = mk:GetWidth()

			surface.SetFont("UVCarbonLeaderboardFont")
			local autotext = string.format( UVString("uv.results.autoclose"), math.max(0, timeremaining) )
			local autotextw = surface.GetTextSize(autotext)

			local wdist = w * 0.000565

			surface.SetDrawColor( 100, 100, 100, 200 )
			surface.DrawRect( w*0.2565, h*0.9, (wdist * conttextw), h*0.035)
			surface.DrawRect( w*0.2665 + (wdist * conttextw), h*0.9, (wdist * autotextw), h*0.035)

			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect( w*0.2565, h*0.9, (wdist * conttextw), h*0.035)
			surface.DrawOutlinedRect( w*0.2665 + (wdist * conttextw), h*0.9, (wdist * autotextw), h*0.035)

			mk:Draw( w * 0.2585, h * 0.905, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleTextOutlined( autotext, "UVCarbonLeaderboardFont", w*0.2685 + (wdist * conttextw), h*0.905, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0) )

            if scrollOffset > 0 then
                draw.SimpleText("▲", "UVFont5UI", w * 0.5, h * 0.3, Color(255,255,255,blink), TEXT_ALIGN_CENTER)
            end
            
            if scrollOffset < #sortedRacers - entriesToShow then
                draw.SimpleText("▼", "UVFont5UI", w * 0.5, h * 0.79, Color(255,255,255,blink), TEXT_ALIGN_CENTER)
            end
            
            if not exitStarted and timeremaining < 1 then
                exitStarted = true
                hook.Remove("CreateMove", "JumpKeyCloseResults")
                AnimateAndRemovePanel(ResultPanel)
            end
            
        end
        
        function OK:DoClick() 
            hook.Remove("CreateMove", "JumpKeyCloseResults")
            AnimateAndRemovePanel(ResultPanel)
        end

		hook.Add("CreateMove", "JumpKeyCloseResults", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if ply:KeyPressed(IN_JUMP) then
				if IsValid(ResultPanel) then
					hook.Remove("CreateMove", "JumpKeyCloseResults")
					AnimateAndRemovePanel(ResultPanel)
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
						UV_UI.racing.carbon.events.ShowResults(sortedRacers)
					end)
					return
				end
                UV_UI.racing.carbon.events.ShowResults(sortedRacers)
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
			UV_UI.racing.carbon.events.CenterNotification({
				text = finishtext,
				noIcon = true,
			})
			return
		end
	
		if suppress_lap_ui then return end

		if is_global_best then
			UV_UI.racing.carbon.states.LapCompleteText = string.format(UVString("uv.race.fastest.laptime"), name, Carbon_FormatRaceTime( lap_time ) )
		else
			if is_local_player then
				UV_UI.racing.carbon.states.LapCompleteText = string.format(UVString("uv.race.laptime.carbon"), Carbon_FormatRaceTime( lap_time ) )
			else
				return
			end
		end
		UV_UI.racing.carbon.events.CenterNotification({
			text = UV_UI.racing.carbon.states.LapCompleteText,
			iconMaterial = UVMaterials["CLOCK_BG"],
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

		UV_UI.racing.carbon.events.CenterNotification({
			text = disqtext,
			noIcon = true,
			immediate = is_local_player and true or false,
		})
	end,

	onRaceStartTimer = function(data)
		local starttime = data.starttime
		
		HUDCountdownTick = {
			value = starttime,           -- 4, 3, 2, 1, or "GO"
			startTime = CurTime(),       -- for animation timing
			duration = starttime <= 1 and 3 or 1.25
		}

		if starttime ~= 5 then return end  -- trigger only once

		-- Include carbon_noti_animState locally
		local carbon_noti_animState = {
			ring = {scale = 1, alpha = 150, duration = 0.25},
			circle = {scale = 1, alpha = 150, duration = 0.25},
			upper = {scale = 1, alpha = 255, duration = 0.25}, -- for future text
		}

		local tickDuration = 1
		local initialDelay = 0.75
		local numTicks = 4 -- countdown 4→1

		-- Use correct materials from UVMaterials
		local ringMat = UVMaterials["TAKEDOWN_RING_CARBON"]
		local circleMat = UVMaterials["TAKEDOWN_CIRCLE_CARBON"]
		local flashMat = UVMaterials["GLOW_ICON"]
		local animState = carbon_noti_animState

		local Animations = {}

		for i = 0, numTicks-1 do
			timer.Simple(initialDelay + i * tickDuration, function()
				local stage = 4 - i 

				-- Ring
				local ringData = animState.ring
				Animations["Ring_"..stage] = {
					start = CurTime(),
					duration = ringData.duration,
					baseSize = ringData.scale * 512,
					minSize = ringData.scale * 96,
					alpha = ringData.alpha,
					material = ringMat,
					active = true
				}

				-- Flashes
				Animations["Flash_"..stage] = {
					startTime = 0,
					duration = 0.15,
					alpha = 0,
					size = animState.circle.scale * 512,
					material = flashMat,
					active = false
				}

				-- Text
				Animations["Text"] = {
					value = stage == 1 and "#uv.race.go" or (stage - 1),
					color = Color(0, 255, 255),
					alpha = 0,
					flash = false,
					active = false,
				}

				timer.Simple(ringData.duration, function()
					local flash = Animations["Flash_"..stage]
					flash.startTime = CurTime()
					flash.active = true

					local textAnim = Animations["Text"]
					if textAnim then
						textAnim.flash = true
						textAnim.color = Color(255, 255, 255)
						textAnim.alpha = 255
					end
				end)

				timer.Simple(ringData.duration + Animations["Flash_"..stage].duration, function()
					local textAnim = Animations["Text"]
					if textAnim then
						textAnim.flash = false
						textAnim.color = Color(0, 255, 255)
						textAnim.alphaDelayStart = CurTime()
						textAnim.alphaDelayDuration = stage == 1 and 1.5 or 0.5
					end
				end)

				-- Circle starts after ring shrinks
				if stage == 4 then
					local circData = animState.circle
					timer.Simple(ringData.duration, function()
						Animations["Circle"] = {
							start = CurTime(),
							duration = circData.duration,
							size = circData.scale * 96,
							alpha = circData.alpha,
							spin = 0,
							material = circleMat,
							active = true,
							expanding = false
						}
					end)
					timer.Simple(ringData.duration, function()
						local textAnim = Animations["Text"]
						if textAnim then
							textAnim.active = true   -- start rendering the text
						end
					end)
				end
			end)
		end

		-- Expand & fade circle on last tick (GO)
		timer.Simple(initialDelay + (numTicks-1) * tickDuration, function()
			local textAnim = Animations["Text"]
			local circle = Animations["Circle"]
			
			if textAnim then
				textAnim.fadeStart = CurTime()
				textAnim.fadeDuration = fadeTimeBeforeNext
				textAnim.startAlpha = textAnim.alpha
			end
			
			timer.Simple(animState.ring.duration, function()
				if circle then
					circle.expanding = true
					circle.expandStart = CurTime()
					circle.expandDuration = animState.circle.duration
					circle.startAlpha = circle.alpha
				end
			end)
		end)

		-- Draw hook
		hook.Add("HUDPaint", "UV_RaceCountdown_Circle", function()
			if not HUDCountdownTick then return end

			local t = CurTime() - HUDCountdownTick.startTime
			if t > HUDCountdownTick.duration then
				HUDCountdownTick = nil  -- auto cleanup after tick ends
				return
			end

			local now = CurTime()

			-- Draw rings
			for key, ring in pairs(Animations) do
				if not ring.active or not ring.baseSize then continue end
				local t = math.min((now - ring.start) / ring.duration, 1)
				local size = Lerp(t, ring.baseSize, ring.minSize)
				local alpha = Lerp(t, ring.alpha, 0)

				surface.SetDrawColor(86, 214, 205, alpha)  -- aqua
				surface.SetMaterial(ring.material)
				surface.DrawTexturedRectRotated(ScrW()/2, ScrH() * 0.375, size, size, 0)

				if t >= 1 then ring.active = false end
			end

			-- Draw Flashes
			for key, flash in pairs(Animations) do
				if string.sub(key, 1, 6) == "Flash_" and flash.active then
					local t = (CurTime() - flash.startTime) / flash.duration
					if t >= 1 then
						flash.active = false
						flash.alpha = 0
					else
						if t < 0.5 then
							flash.alpha = Lerp(t / 0.5, 0, 175)
						else
							flash.alpha = Lerp((t-0.5)/0.5, 175, 0)
						end
					end

					surface.SetDrawColor(255, 255, 255, flash.alpha)
					surface.SetMaterial(flash.material)
					surface.DrawTexturedRectRotated(ScrW()/2, ScrH()*0.375, 128, 128, 0)
				end
			end

			-- Draw spinning circle
			local circle = Animations["Circle"]
			if circle and circle.active then
				circle.spin = circle.spin - FrameTime() * 90
				local size = circle.size
				local alpha = circle.alpha

				if circle.expanding then
					local t = math.min((now - circle.expandStart) / circle.expandDuration, 1)
					size = Lerp(t, circle.size, circle.size * 3)
					alpha = Lerp(t, circle.startAlpha, 0)
					if t >= 1 then circle.active = false end
				end

				surface.SetDrawColor(86, 214, 205, alpha)
				surface.SetMaterial(circle.material)
				surface.DrawTexturedRectRotated(ScrW()/2, ScrH() * 0.375, size, size, circle.spin)
			end
			
			-- Text
			local textAnim = Animations["Text"]
			if textAnim then
				if textAnim.alphaDelayStart then
					local t = (CurTime() - textAnim.alphaDelayStart)
					if t > textAnim.alphaDelayDuration then
						local fadeT = math.min((t - textAnim.alphaDelayDuration) / 0.15, 1)
						textAnim.alpha = Lerp(fadeT, 255, 0)
					end
				end

				draw.SimpleTextOutlined(
					textAnim.value,
					"UVFont5",
					ScrW() * 0.5,
					ScrH() * 0.35,
					Color(textAnim.color.r, textAnim.color.g, textAnim.color.b, textAnim.alpha),  -- main text with alpha
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_TOP,
					1.25,
					Color(0, 0, 0, textAnim.alpha)  -- outline respects same alpha
				)
			end

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
		local noticol = Color(0, 255, 255)

		if aheadDiff == "N/A" and behindDiff ~= "N/A" then -- 1st place
			splittime = behindDiff
		elseif aheadDiff ~= "N/A" then -- 2nd place or below
			splittime = "-" .. aheadDiff
			showahead = true
			noticol = Color(200, 75, 75)
		end
		
		local splittext = string.format( UVString("uv.race.splittime"), splittime )

		UV_UI.racing.carbon.events.CenterNotification({
			text = splittext,
			iconMaterial = UVMaterials["SPLITTIME_CARBON"],
			iconSize = 0.0475,
			colorLower = noticol,
			ringColor = noticol,
			flyUp = true,
		})
	end,
}

UV_UI.pursuit.carbon.events = {
	onUnitTakedown = function( unitType, name, bounty, bountyCombo, isPlayer )
		local uname = isPlayer and UVString( unitType .. ".caps" ) or name -- Fallback
		
		if GetConVar("unitvehicle_vehiclenametakedown"):GetBool() then
			uname = name and string.Trim(UVString(name), "#") or nil
		end
		
		UV_UI.racing.carbon.events.CenterNotification({
			text = string.format( UVString( "uv.hud.carbon.takedown" ), uname, bounty, bountyCombo ),
			iconSize = 0.0475,
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
		
		UV_UI.racing.carbon.events.CenterNotification({
			text = cnt,
			noIcon = true,
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
        
        OK = vgui.Create("DButton", vgui.GetWorldPanel())
        OK:SetText("")
        OK:SetPos(w*0.2565, h*0.9)
        OK:SetSize(w*0.3, h*0.035)
        OK.Paint = function() end
        
        ResultPanel = vgui.Create("DPanel", vgui.GetWorldPanel())
        ResultPanel:Add(OK)
        ResultPanel:SetSize(w, h)
        -- ResultPanel:SetPos(0, 0)
        ResultPanel:SetMouseInputEnabled(true)
        ResultPanel:SetKeyboardInputEnabled(false)
        ResultPanel:SetZPos(32767)
        
        local targetY = 0
        local overshootY = h * 0.1  -- drops 10% below target before bouncing back
        local startY = -h           -- start fully above the screen
        
        ResultPanel:SetPos(0, startY)
        
        local animTime = 0.33
        local bounceTime = 0.1
        local startTime = CurTime()
        
        hook.Add("Think", "ResultPanelEntranceAnim", function()
            local elapsed = CurTime() - startTime
            
            if elapsed < animTime then
                if elapsed < animTime - bounceTime then
                    local frac = elapsed / (animTime - bounceTime)
                    local y = Lerp(frac, startY, overshootY)
                    ResultPanel:SetPos(0, y)
                else
                    local frac = (elapsed - (animTime - bounceTime)) / bounceTime
                    local y = Lerp(frac, overshootY, targetY)
                    ResultPanel:SetPos(0, y)
                end
            else
                ResultPanel:SetPos(0, targetY)
                hook.Remove("Think", "ResultPanelEntranceAnim")
            end
        end)
        
        local function AnimateAndRemovePanel(panel)
            if not IsValid(panel) then return end
            
            local startY = panel:GetY()
            local endY = ScrH()  -- off-screen below
            local animTime = 0.33
            local startTime = CurTime()
            
            -- Play sounds ONCE at start
            surface.PlaySound("uvui/carbon/fe_common_mb [5].wav")
            surface.PlaySound("uvui/carbon/fe_common_mb [6].wav")
            
            -- Disable interactivity
            panel:SetMouseInputEnabled(false)
            gui.EnableScreenClicker(false)
            OK:SetEnabled(false)
            
            hook.Add("Think", "ResultPanelExitAnim", function()
                if not IsValid(panel) then
                    hook.Remove("Think", "ResultPanelExitAnim")
                    return
                end
                
                local elapsed = CurTime() - startTime
                if elapsed < animTime then
                    local frac = elapsed / animTime
                    local y = Lerp(frac, startY, endY)
                    panel:SetPos(0, y)
                else
                    panel:Remove()
                    hook.Remove("Think", "ResultPanelExitAnim")
                end
            end)
        end
        
        gui.EnableScreenClicker(true)
        
        local timetotal = 30
        local timestart = CurTime()
        local exitStarted = false -- prevent repeated trigger
        
        local finalTitle = "★" .. UVString("uv.results.pursuit.carbon") .. "★"
        local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()[]{}<>,./?|"
        local revealSpeed = 0.05
        local displayStart = CurTime()
        local scrambleSound
        local isScrambling = true
        local revealedChars = 0
        
        sound.Add({
            name = "UV.Carbon.Scramble",
            channel = CHAN_STATIC,
            volume = 1.0,
            level = 70,
            pitch = { 100 },
            sound = "uvui/carbon/textfold.wav"
        })
        
        -- Start reveal timer
        timer.Create("ScrambleTextUpdate", revealSpeed, #finalTitle, function()
            revealedChars = revealedChars + 1
            
            -- Start the loop sound
            if isScrambling and not scrambleSound then
                scrambleSound = CreateSound(LocalPlayer(), "UV.Carbon.Scramble")
                if scrambleSound then
                    scrambleSound:Play()
                end
            end
            
            -- Stop when done
            if revealedChars >= #finalTitle then
                isScrambling = false
                if scrambleSound then
                    scrambleSound:FadeOut(0.2)
                    scrambleSound = nil
                end
            end
        end)

        ResultPanel.Paint = function(self, w, h)
            local timeremaining = math.ceil(timetotal - (CurTime() - timestart))
            local lang = UVString
            
            -- Main black BG
            surface.SetMaterial(UVMaterials['BG_BIG_CARBON'])
            surface.SetDrawColor( 0, 0, 0, 225 )
            surface.DrawTexturedRect( 0, 0, w, h)
            
            -- Upper Results Tab
            surface.SetDrawColor( 0, 0, 0, 200 )
            surface.DrawRect( w*0.25, h*0.185, w*0.5, h*0.075)
            
            surface.SetMaterial(UVMaterials['EOC_FRAME_CARBON'])
            surface.SetDrawColor(86, 214, 205)
            surface.DrawTexturedRect( w*0.26, h*0.17825, w*0.485, h*0.09)
            
            DrawIcon( UVMaterials['X_OUTER_CARBON'], w*0.255, h*0.215, 0.2, Color(0,0,0) ) -- Icon
            DrawIcon( Material("unitvehicles/hud_carbon/x_anim"), w*0.255, h*0.215, 0.2, Color(255,255,255) ) -- Animated Icon; TBD
            
            local timePassed = CurTime() - displayStart
            local charsToReveal = math.min(#finalTitle, math.floor(timePassed / revealSpeed))
            
            local animatedTitle = ""
            
            for i = 1, #finalTitle do
                if i <= charsToReveal then
                    animatedTitle = animatedTitle .. finalTitle:sub(i, i)
                else
                    local randIndex = math.random(#charset)
                    local randChar = charset:sub(randIndex, randIndex)
                    animatedTitle = animatedTitle .. randChar
                end
            end
            
            draw.DrawText(animatedTitle, "UVCarbonFont", w * 0.3, h * 0.2, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            
            -- Next Lower, results subtext
            -- surface.SetMaterial(UVMaterials['BACKGROUND_BIGGER'])
            surface.SetDrawColor( 0, 0, 0, 235 )
            surface.DrawRect( w*0.25, h*0.3, w*0.5, h*0.03)
            
            draw.DrawText( "#uv.results.chase.item.carbon", "UVCarbonLeaderboardFont", w*0.2565, h*0.3025, Color( 255, 255, 255), TEXT_ALIGN_LEFT )
            
            draw.DrawText( "#uv.results.chase.value.carbon", "UVCarbonLeaderboardFont", w*0.74, h*0.3025, Color( 255, 255, 255), TEXT_ALIGN_RIGHT )
            
            -- All middle tabs, light ones
            local numRectsLight = 3
            for i=0, numRectsLight, 1 do
                local yPos = i * h * 0.08
                surface.SetMaterial(UVMaterials['BACKGROUND_CARBON_FILLED'])
                surface.SetDrawColor( 86, 214, 205, 175 )
                surface.DrawTexturedRect( w*0.25, h*0.34 + yPos, w*0.485, h*0.035)
                
                surface.SetMaterial(UVMaterials['ARROW_CARBON'])
                surface.DrawTexturedRect( w*0.735, h*0.34 + yPos, w*0.015, h*0.035)
            end
            
            -- All middle tabs, dark ones
            local numRectsDark = 3
            for i=0, numRectsDark, 1 do
                local yPos = i * h * 0.08
                surface.SetMaterial(UVMaterials['BACKGROUND_CARBON_FILLED'])
                surface.SetDrawColor( 86, 214, 205, 75 )
                surface.DrawTexturedRect( w*0.25, h*0.38 + yPos, w*0.485, h*0.035)
                
                surface.SetMaterial(UVMaterials['ARROW_CARBON'])
                surface.DrawTexturedRect( w*0.735, h*0.38 + yPos, w*0.015, h*0.035)
            end
            
            local h1, h2 = h*0.3825, h*0.4225

            -- Text
            draw.SimpleTextOutlined( debrieftitletext, "UVCarbonLeaderboardFont", w*0.2565, h*0.3425, Color( 255, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0) )
            
            draw.SimpleTextOutlined( "#uv.results.chase.bounty", "UVCarbonLeaderboardFont", w*0.2565, h1, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( "#uv.results.chase.time", "UVCarbonLeaderboardFont", w*0.2565, h2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( "#uv.results.chase.units.deployed", "UVCarbonLeaderboardFont", w*0.2565, h1 + h*0.08, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( "#uv.results.chase.units.damaged", "UVCarbonLeaderboardFont", w*0.2565, h2 + h*0.08, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( "#uv.results.chase.units.destroyed", "UVCarbonLeaderboardFont", w*0.2565, h1 + h*0.16, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( "#uv.results.chase.dodged.blocks", "UVCarbonLeaderboardFont", w*0.2565, h2 + h*0.16, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( "#uv.results.chase.dodged.spikes", "UVCarbonLeaderboardFont", w*0.2565, h1 + h*0.24, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            
            draw.SimpleTextOutlined( debrieftitlevar, "UVCarbonLeaderboardFont", w*0.74, h*0.3425, Color( 255, 255, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            
            draw.SimpleTextOutlined( bounty, "UVCarbonLeaderboardFont", w*0.74, h1, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( time, "UVCarbonLeaderboardFont", w*0.74, h2, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( deploys, "UVCarbonLeaderboardFont", w*0.74, h1 + h*0.08, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( tags, "UVCarbonLeaderboardFont", w*0.74, h2 + h*0.08, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( wrecks, "UVCarbonLeaderboardFont", w*0.74, h1 + h*0.16, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( roadblocksdodged, "UVCarbonLeaderboardFont", w*0.74, h2 + h*0.16, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))
            draw.SimpleTextOutlined( spikestripsdodged, "UVCarbonLeaderboardFont", w*0.74, h1 + h*0.24, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0))

            -- Time remaining and closing
			local conttext = "<color=255,255,255><font=UVCarbonLeaderboardFont>" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue")) .. "</font></color>"
			local mk = markup.Parse(conttext)
			local conttextw = mk:GetWidth()

			surface.SetFont("UVCarbonLeaderboardFont")
			local autotext = string.format( UVString("uv.results.autoclose"), math.max(0, timeremaining) )
			local autotextw = surface.GetTextSize(autotext)
			
			local uwstext = "<color=255,255,255><font=UVCarbonLeaderboardFont>" .. UVReplaceKeybinds("[+reload] " .. UVString("uv.pm.spawnas")) .. "</font></color>"
			local mk2 = markup.Parse(uwstext)
			local uwstextw = mk2:GetWidth()

			local wdist = w * 0.000565

			surface.SetDrawColor( 100, 100, 100, 200 )
			surface.DrawRect( w*0.2565, h*0.9, (wdist * conttextw), h*0.035)
			surface.DrawRect( w*0.2665 + (wdist * conttextw), h*0.9, (wdist * autotextw), h*0.035)

			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect( w*0.2565, h*0.9, (wdist * conttextw), h*0.035)
			surface.DrawOutlinedRect( w*0.2665 + (wdist * conttextw), h*0.9, (wdist * autotextw), h*0.035)

			mk:Draw( w * 0.2585, h * 0.905, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleTextOutlined( autotext, "UVCarbonLeaderboardFont", w*0.2685 + (wdist * conttextw), h*0.905, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0) )

			if debriefunitspawn and (UVHUDWantedSuspects and #UVHUDWantedSuspects > 0) then
				surface.SetDrawColor( 100, 100, 100, 200 )
				surface.DrawRect( w*0.2765 + (wdist * (conttextw + autotextw)), h*0.9, (wdist * uwstextw), h*0.035)
				
				surface.SetDrawColor( 0, 0, 0, 255 )
				surface.DrawOutlinedRect( w*0.2765 + (wdist * (conttextw + autotextw)), h*0.9, (wdist * uwstextw), h*0.035)

				mk2:Draw( w*0.2785 + (wdist * (conttextw + autotextw)), h * 0.905, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end

            if not exitStarted and timeremaining < 1 then
                exitStarted = true
                hook.Remove("CreateMove", "JumpKeyCloseDebrief")
				hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
                AnimateAndRemovePanel(ResultPanel)
            end
        end
        
        function OK:DoClick() 
            hook.Remove("CreateMove", "JumpKeyCloseDebrief")
			hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
            AnimateAndRemovePanel(ResultPanel)
        end

		hook.Add("CreateMove", "JumpKeyCloseDebrief", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if ply:KeyPressed(IN_JUMP) then
				if IsValid(ResultPanel) then
					hook.Remove("CreateMove", "JumpKeyCloseDebrief")
					hook.Remove("CreateMove", "ReloadKeyCloseDebrief")
					AnimateAndRemovePanel(ResultPanel)
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
						AnimateAndRemovePanel(ResultPanel)

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
            titleText = "#uv.results.escapedfrom",
        }
        UV_UI.pursuit.carbon.events.ShowDebrief(params)
    end,
    
    onRacerBustedDebrief = function(bustedtable)
        local params = {
            dataTable = bustedtable,
            titleText = "#uv.results.bustedby.carbon",
            titleVar = UVString( bustedtable["Unit"] ),
			spawnAsUnit = true,
        }
        UV_UI.pursuit.carbon.events.ShowDebrief(params)
    end,
    
    onCopBustedDebrief = function(bustedtable)
        local params = {
            dataTable = bustedtable,
            titleText = "#uv.results.suspects.busted",
            titleVar = bustedtable["Unit"],
        }
        UV_UI.pursuit.carbon.events.ShowDebrief(params)
    end,
    
    onCopEscapedDebrief = function(escapedtable)
        local params = {
            dataTable = escapedtable,
            titleText = "#uv.results.suspects.escaped.num.carbon",
            titleVar = UVHUDWantedSuspectsNumber,
        }
        UV_UI.pursuit.carbon.events.ShowDebrief(params)
    end,
	
	onPullOverRequest = function(...)
		UV_UI.racing.carbon.events.CenterNotification({
			text = UVString("uv.hud.fine.pullover"),
			noIcon = true,
			immediate = true,
		})
	end,
	onFined = function( finenr )
		UV_UI.racing.carbon.events.CenterNotification({
			text = string.format( UVString("uv.hud.fine.fined"), finenr),
			noIcon = true,
			immediate = true,
		})
	end,
}

local function carbon_racing_main( ... )
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
    surface.SetMaterial(UVMaterials["ARROW_CARBON"])
    surface.SetDrawColor(UVColors.Carbon_AccentTransparent)
    surface.DrawTexturedRect(UV_UI.X(w * 0.815), h * 0.111, UV_UI.W(w * 0.025), h * 0.033)
    
    DrawIcon(UVMaterials["CLOCK_BG"], UV_UI.X(w * 0.815), h * 0.124, .0625, UVColors.Carbon_Accent) -- Icon
    
	draw.SimpleTextOutlined(Carbon_FormatRaceTime((UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time)) or 0), "UVCarbonFont", UV_UI.X(w * 0.97), h * 0.105, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    
    -- Lap & Checkpoint Counter
    surface.SetMaterial(UVMaterials["BACKGROUND_CARBON"])
    surface.SetDrawColor(UVColors.Carbon_Accent2Transparent:Unpack())
    surface.DrawTexturedRect(UV_UI.X(w * 0.69), h * 0.157, UV_UI.W(w * 0.2), h * 0.04)
    
    local laptext = "<color=" .. UVColors.Carbon_Accent.r .. ", " .. UVColors.Carbon_Accent.g .. ", " ..UVColors.Carbon_Accent.b ..">" .. my_array.Lap .. ": </color>" .. UVHUDRaceInfo.Info.Laps
    local laptextdark = "<color=0,0,0>" .. my_array.Lap .. ": " .. UVHUDRaceInfo.Info.Laps .. "</color>"
    local lapname = "REPLACEME"
	
    if UVHUDRaceInfo.Info.Laps > 1 then
		lapname = "uv.race.hud.lap"
    else
		lapname = "uv.race.hud.complete"
        laptext = math.floor(((checkpoint_count / GetGlobalInt("uvrace_checkpoints")) * 100)) .. "%"
        laptextdark = "<color=0,0,0>" .. laptext .. "</color>"
    end
    
	draw.SimpleTextOutlined("#" .. lapname, "UVCarbonFont", UV_UI.X(w * 0.875), h * 0.155, UVColors.Carbon_Accent2Bright, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
	
    markup.Parse("<font=UVCarbonFont>" .. laptextdark):Draw(UV_UI.X(w * 0.97) - 1,h * 0.155 - 1,TEXT_ALIGN_RIGHT,TEXT_ALIGN_RIGHT)
    markup.Parse("<font=UVCarbonFont>" .. laptextdark):Draw(UV_UI.X(w * 0.97) - 1,h * 0.155 + 1,TEXT_ALIGN_RIGHT,TEXT_ALIGN_RIGHT)
    markup.Parse("<font=UVCarbonFont>" .. laptextdark):Draw(UV_UI.X(w * 0.97) + 1,h * 0.155 - 1,TEXT_ALIGN_RIGHT,TEXT_ALIGN_RIGHT)
    markup.Parse("<font=UVCarbonFont>" .. laptextdark):Draw(UV_UI.X(w * 0.97) + 1,h * 0.155 - 1,TEXT_ALIGN_RIGHT,TEXT_ALIGN_RIGHT)
    markup.Parse("<font=UVCarbonFont>" .. laptext):Draw(UV_UI.X(w * 0.97),h * 0.155,TEXT_ALIGN_RIGHT,TEXT_ALIGN_RIGHT)

    -- Racer List
    local alt = math.floor(CurTime() / 5) % 2 == 1 -- toggles every 5 seconds
    for i = 1, math.Clamp(racer_count, 1, 16), 1 do
        if racer_count == 1 then
            return
        end
        local entry = string_array[i]
        
        local racer_name = entry[1]
        local is_local_player = entry[2]
        local mode = entry[3]
        local diff = entry[4]
        
        local racercount = i * (h * 0.025)
        
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
						local lapString = (math.abs(num) > 1) and Strings["Laps"] or Strings["Lap"]
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
            color = UVColors.Carbon_LocalPlayer
        elseif entry[3] == "Disqualified" or entry[3] == "Busted" then
            color = UVColors.Carbon_Disqualified
        else
            color = (i > 4 and UVColors.Carbon_OthersDark) or UVColors.Carbon_Others
        end
        
        local text = alt and (status_text) or (racer_name)
        
        if is_local_player then
            surface.SetMaterial(UVMaterials["BACKGROUND_CARBON_INVERTED"])
            surface.SetDrawColor(89, 255, 255, 100)
            surface.DrawTexturedRect(UV_UI.X(w * 0.72), h * 0.185 + racercount, UV_UI.W(w * 0.255), h * 0.025)
        end

		draw.SimpleTextOutlined(i, "UVCarbonLeaderboardFont", UV_UI.X(w * 0.97), (h * 0.185) + racercount, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
		draw.SimpleTextOutlined(text, "UVCarbonLeaderboardFont", UV_UI.X(w * 0.9525), (h * 0.185) + racercount, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    end
end

local function carbon_pursuit_main( ... )
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
    
    local states = UV_UI.pursuit.carbon.states
    
    local UVWrecksColor = states.WrecksColor
    local UVTagsColor = states.TagsColor
    local UVUnitsColor = states.UnitsColor
    
    --------------------------------------------------
    
    outofpursuit = CurTime()
    
    local UVHeatBountyMin
    local UVHeatBountyMax
    states.EvasionColor = Color(47, 77, 20)
    states.BustedColor = Color(61, 21, 0)
    
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
                
                states.BustedColor = Color(255, 0, 0)
            end
        end
    end
    
    --if not UVHUDRace then
    local ResourceText = UVResourcePoints
    
    -- [ Upper Right Info Box ] --
    -- Timer
    if not UVHUDDisplayBackupTimer then
        surface.SetMaterial(UVMaterials["ARROW_CARBON"])
        surface.SetDrawColor(UVColors.Carbon_AccentTransparent)
        surface.DrawTexturedRect(UV_UI.X(w * 0.8), h * 0.111, UV_UI.W(w * 0.025), h * 0.033)
    else
        surface.SetMaterial(UVMaterials["BACKGROUND_CARBON_SOLID"])
        surface.SetDrawColor(Color(194, 68, 0))
        surface.DrawTexturedRect(UV_UI.X(w * 0.795), h * 0.111, UV_UI.W(w * 0.085), h * 0.033)
        
        surface.SetMaterial(UVMaterials["ARROW_CARBON"])
        surface.DrawTexturedRectRotated(UV_UI.X(w * 0.84), h * 0.1512, UV_UI.W(w * 0.01), h * 0.02, -90)
        
        draw.DrawText(UVBackupTimer,"UVCarbonLeaderboardFont",UV_UI.X(w * 0.8425),h*0.1125,Color(0,0,0),TEXT_ALIGN_CENTER)
    end
    
    DrawIcon(UVMaterials["CLOCK_BG"], UV_UI.X(w * 0.8), h * 0.124, .0625, UVColors.Carbon_Accent) -- Icon
	draw.SimpleTextOutlined(UVTimer, "UVCarbonFont", UV_UI.X(w * 0.97), h * 0.105, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    
    local UVHeatMinConVar = GetConVar( 'unitvehicle_unit_heatminimumbounty' .. UVHeatLevel )
    local UVHeatMaxConVar = GetConVar( 'unitvehicle_unit_heatminimumbounty' .. UVHeatLevel + 1 )
    
    UVHeatBountyMin = ( UVHeatMinConVar and UVHeatMinConVar:GetInt() ) or math.huge
    UVHeatBountyMax = ( UVHeatMaxConVar and UVHeatMaxConVar:GetInt() ) or math.huge
    
    local hl10 = 0
    local hlcm = 0
    if UVHeatLevel > 9 then hl10 = w * 0.01 end
    if (UVHUDDisplayCooldown and UVHUDCopMode) then hlcm = h * 0.0475 end
    
    DrawIcon(UVMaterials["HEAT_CARBON"], UV_UI.X(w * 0.8 - hl10), h * 0.26 - hlcm, .045, UVColors.Carbon_Accent) -- Icon
    draw.SimpleTextOutlined("x" .. UVHeatLevel, "UVCarbonFont", UV_UI.X(w * 0.83), h * 0.2375 - hlcm, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    
    surface.SetDrawColor(Color(0,0,0))
    surface.DrawRect(UV_UI.X(w * 0.835) - 4, h * 0.2525 - hlcm - 3, UV_UI.W(w * 0.145) + 8.5, h * 0.015 + 6)
	
    surface.SetDrawColor(UVColors.Carbon_AccentDarker)
    surface.DrawRect(UV_UI.X(w * 0.835), h * 0.2525 - hlcm, UV_UI.W(w * 0.145), h * 0.015)

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
    local B = math.Clamp((HeatProgress) * UV_UI.W(w * 0.145), 0, UV_UI.W(w * 0.145))
    local blink = 255 * math.abs(math.sin(RealTime() * 4))
    local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
    local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
    
    surface.SetDrawColor(UVColors.Carbon_Accent)
    
    surface.DrawRect(UV_UI.X(w * 0.835), h * 0.2525 - hlcm, B, h * 0.015)
    
    -- General Icons
    surface.SetMaterial(UVMaterials["BACKGROUND_CARBON_SMALL_INVERTED"])
    surface.SetDrawColor(Color(255, 255, 255, 50))
    surface.DrawTexturedRect(UV_UI.X(w * 0.9), h * 0.16, UV_UI.W(w * 0.075), h * 0.033)
    
    DrawIcon(UVMaterials["UNITS_DISABLED_CARBON"], UV_UI.X(w * 0.97), h * 0.175, .05, UVColors.Carbon_Accent)
	draw.SimpleTextOutlined(UVWrecks, "UVCarbonFont", UV_UI.X(w * 0.9125), h * 0.1525, UVColors.Carbon_Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    
    surface.SetMaterial(UVMaterials["BACKGROUND_CARBON_SMALL"])
    surface.SetDrawColor(Color(255, 255, 255, 50))
    surface.DrawTexturedRect(UV_UI.X(w * 0.79), h * 0.16, UV_UI.W(w * 0.075), h * 0.033)
    
    DrawIcon(UVMaterials["UNITS_CARBON"], UV_UI.X(w * 0.8), h * 0.175, .05, UVColors.Carbon_Accent)
	draw.SimpleTextOutlined(ResourceText, "UVCarbonFont", UV_UI.X(w * 0.853), h * 0.1525, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )

    -- [[ Commander Stuff ]]
    if UVOneCommanderActive then
        ResourceText = "⛊"
        
        surface.SetDrawColor(0, 0, 0, 200) -- Milestone BG
        surface.DrawRect(UV_UI.X(w * 0.79), h * 0.35, UV_UI.W(w * 0.19), h * 0.03)

        local cname = "#uv.unit.commander"
        if IsValid(UVHUDCommander) then
            local driver = UVHUDCommander:GetDriver()
            if IsValid(driver) and driver:IsPlayer() then
                cname = driver:Nick()
            end
        end

		draw.SimpleTextOutlined("⛊", "UVCarbonFont", UV_UI.X(w * 0.7925), h * 0.339, UVColors.Carbon_Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
		
		draw.SimpleTextOutlined(cname, "UVCarbonFont-Smaller", UV_UI.X(w * 0.8825), h * 0.3465, UVColors.Carbon_Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
		
		draw.SimpleTextOutlined("⛊", "UVCarbonFont", UV_UI.X(w * 0.975), h * 0.339, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
        
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
            healthcolor = UVColors.Carbon_Accent
        elseif healthratio >= 0.25 then
            healthcolor = Color(255, blink, blink, 200)
        else
            healthcolor = Color(255, blink2, blink2, 200)
        end
        if healthratio > 0 then
            surface.SetDrawColor(Color(0,0,0))
            surface.DrawRect(UV_UI.X(w * 0.79) - 4, h * 0.385 - 3, UV_UI.W(w * 0.19) + 8.5, h * 0.015 + 6)
            surface.SetDrawColor(UVColors.Carbon_AccentDarker)
            surface.DrawRect(UV_UI.X(w * 0.79), h * 0.385, UV_UI.W(w * 0.19), h * 0.015)
            
            surface.SetDrawColor(healthcolor)
            local T = math.Clamp((healthratio) * (UV_UI.W(w * 0.19)), 0, UV_UI.W(w * 0.19))
            surface.DrawRect(UV_UI.X(w * 0.79), h * 0.385, T, h * 0.015)
        end
    end
    
    -- [ Bottom Info Box ] --
    local middlergb = {
        r = 227,
        g = 219,
        b = 21,
        a = 255
    }
    
    if not UVHUDDisplayCooldown then
        -- Evade Box, Backgrounds
		-- Busted Meter
        surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED"])
        surface.SetDrawColor(Color(61, 21, 0))
        surface.DrawTexturedRect(UV_UI.X(w * 0.782), h * 0.195, UV_UI.W(w * 0.0935), h * 0.032)
        
		-- Evade Meter
        surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED_INVERTED"])
        surface.SetDrawColor(Color(47, 77, 20))
        surface.DrawTexturedRect(UV_UI.X(w * 0.895), h * 0.195, UV_UI.W(w * 0.0935), h * 0.032)

        -- Evade Box, Busted Meter
        if UVHUDDisplayBusting and not UVHUDDisplayCooldown then
            if not BustingProgress or BustingProgress == 0 then
                BustingProgress = CurTime()
            end
            
            local timeLeft = ((UVHUDDisplayNotification and -1) or (UVBustTimer - UVBustingProgress))
            
            local playbusting = (UVHUDCopMode and UVHUDWantedSuspectsNumber == 1) or not UVHUDCopMode
            
            states.BustedColor = Color(194, 68, 0)
            
            local T = math.Clamp((UVBustingProgress / UVBustTimer) * (UV_UI.W(w * 0.0935)), 0, UV_UI.W(w * 0.0935))
            T = math.floor(T)
			surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED"])
			surface.SetDrawColor(Color(194, 68, 0))
			surface.DrawTexturedRectUV(UV_UI.X(w * 0.782) + (UV_UI.W(w * 0.0935) - T), h * 0.195, T, h * 0.032, 1 - (T / (w * 0.0935)), 0, 1, 1)
            middlergb = {
                r = 92,
                g = 87,
                b = 7,
            }
        else
            UVBustedColor = Color(194, 68, 0, 0)
            BustingProgress = 0
        end
        
        -- Evade Box, Evade Meter
        if not UVHUDDisplayNotification and not UVHUDDisplayCooldown and UnitsChasing == 0 and BustingProgress == 0 then
            --UVSoundHeat(UVHeatLevel)
            if not EvadingProgress then
                EvadingProgress = 0
                UVEvadingProgress = EvadingProgress 
            end
            
            local T = math.Clamp((UVEvadingProgress) * (UV_UI.W(w * 0.0935)), 0, UV_UI.W(w * 0.0935))

			surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED_INVERTED"])
			surface.SetDrawColor(Color(147, 247, 69))
			surface.DrawTexturedRectUV(UV_UI.X(w * 0.895), h * 0.195, T, h * 0.032, 0, 0, T / (UV_UI.W(w * 0.0935)), 1)
			
            middlergb = {
                r = 92,
                g = 87,
                b = 7,
            }
            
            states.EvasionColor = Color(147, 247, 69)
        else
            EvadingProgress = 0
        end
        
        -- Evade Box, Middle Piece
		surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED_MIDDLE"])
		surface.SetDrawColor(middlergb.r, middlergb.g, middlergb.b, 255)
		surface.DrawTexturedRect(UV_UI.X(w * 0.874), h * 0.195, UV_UI.W(w * 0.023), h * 0.032)

		draw.SimpleTextOutlined("#uv.chase.busted", "UVCarbonLeaderboardFont", UV_UI.X(w * 0.7875), h* 0.2175, states.BustedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0, 50 ) )
		draw.SimpleTextOutlined("#uv.chase.evade", "UVCarbonLeaderboardFont", UV_UI.X(w * 0.98), h* 0.2175, states.EvasionColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0, 50 ) )
		
        -- Lower Box
        local lbtext = "REPLACEME"
        local uloc, utype = "uv.chase.unit", UnitsChasing
        if not UVHUDCopMode then
            if UnitsChasing ~= 1 then
                uloc = "uv.chase.units"
            end
        else
            utype = UVHUDWantedSuspectsNumber
            uloc = "uv.chase.suspects"
        end

		draw.SimpleTextOutlined(string.format(lang(uloc), utype), "UVCarbonLeaderboardFont", UV_UI.X(w * 0.98), h * 0.27, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
    else
        -- Lower Box
        -- Evade Box, All BG (Moved to inner if clauses)
        
        -- Evade Box, Cooldown Meter
        if UVHUDDisplayCooldown then
            if not CooldownProgress or CooldownProgress == 0 then
                CooldownProgress = CurTime()
            end
            
            --UVSoundCooldown(UVHeatLevel)
            EvadingProgress = 0
            
            -- Upper Box
            if not UVHUDCopMode then
                local T = math.Clamp((UVCooldownTimer) * (UV_UI.W(w * 0.2)), 0, UV_UI.W(w * 0.2))
                T = math.floor(T)

				surface.SetMaterial(UVMaterials["BAR_CARBON_FILLED_COOLDOWN"])
				surface.SetDrawColor(UVColors.Carbon_AccentDarker)
				surface.DrawTexturedRect(UV_UI.X(w * 0.782), h * 0.18, UV_UI.W(w * 0.2), h * 0.064)
				
				surface.SetDrawColor(UVColors.Carbon_Accent)
				surface.DrawTexturedRectUV(UV_UI.X(w * 0.782) + (UV_UI.W(w * 0.2) - T), h * 0.18, T, h * 0.064, 1 - (T / (UV_UI.W(w * 0.2))), 0, 1, 1)

				draw.SimpleTextOutlined("#uv.chase.cooldown", "UVCarbonLeaderboardFont", UV_UI.X(w * 0.98), h * 0.221, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
            else
				draw.SimpleTextOutlined("#uv.chase.cooldown", "UVCarbonLeaderboardFont", UV_UI.X(w * 0.98), h * 0.225, UVColors.Carbon_Accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, Color( 0, 0, 0 ) )
            end
        else
            CooldownProgress = 0
        end
    end
end

UV_UI.pursuit.carbon.main = carbon_pursuit_main
UV_UI.racing.carbon.main = carbon_racing_main