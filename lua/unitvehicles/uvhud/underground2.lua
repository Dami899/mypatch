UV.RegisterHUD( "underground2", "NFS: Underground 2" )

UV_UI.racing.underground2 = UV_UI.racing.underground2 or {}

UV_UI.racing.underground2.states = {
    FrozenTime = false,
    FrozenTimeValue = 0
}

UV_UI.racing.underground2.events = {
    onLapComplete = function( ... )
        local participant  = select( 1, ... )
        local new_lap      = select( 2, ... )
        local old_lap      = select( 3, ... )
        local lap_time     = select( 4, ... )
        local lap_time_cur = select( 5, ... )
        
        if participant:GetDriver() ~= LocalPlayer() then return end
        
        UV_UI.racing.underground2.states.FrozenTime = true
        UV_UI.racing.underground2.states.FrozenTimeValue = lap_time
        
        if timer.Exists( "_UG_TIME_FROZEN_DELAY" ) then timer.Remove( "_UG_TIME_FROZEN_DELAY" ) end
        timer.Create("_UG_TIME_FROZEN_DELAY", 3, 1, function()
            UV_UI.racing.underground2.states.FrozenTime = false
        end)
    end,
    
    ShowResults = function(sortedRacers) -- Underground 2
        local w = ScrW()
        local h = ScrH()
        
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
                        		
        -- ResultPanel:MakePopup()
        ResultPanel:SetVisible(true)
		ResultPanel:MoveToFront()
		ResultPanel:RequestFocus()
		gui.EnableScreenClicker(true)

        OK:SetText("")
        OK:SetPos(w*0.775, h*0.84)
        OK:SetSize(w*0.15, h*0.0425)
        OK:SetEnabled(true)
        OK.Paint = function() end
        
        local timestart = CurTime()
        local displaySequence = {}
        
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
        
        local entriesToShow = 9
        local scrollOffset = 0
        
        local i = 0
        for place, dict in ipairs(racersArray) do
            local info = dict.array or {}
            i = i + 1
            
            -- Staggered vertical layout
            local visibleIndex = i -- 1 to entriesToShow
            local rowHeight = h * 0.09
            local yPos = h*0.08 + (i - 1) * rowHeight
            local LP, LC = false, Color(255, 255, 255)
            
            local name = info["Name"] or "Unknown"
            local totalTime = info["TotalTime"] and info["TotalTime"] or UVString("uv.race.suffix.dnf")
            
            if info["Busted"] then totalTime = UVString("uv.race.suffix.busted") end
				
			local ymax = w * 0.45
			local ynmax = w * 0.175
			surface.SetFont("UVFont")
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

            if info["LocalPlayer"] then
                LP = true
                LC = Color(196, 208, 151)
            end
            
            local entry = {
                y = yPos,
                posText = tostring(i),
                nameText = name,
				carText = vehname,
                timeText = UV_FormatRaceEndTime(totalTime),
                color = LC,
                localPlayer = LP
            }
            
            table.insert(displaySequence, entry)
        end
        
        local closing = false
        local closeStartTime = 0
        
        function ResultPanel:OnMouseWheeled(delta)
            if delta > 0 then
                scrollOffset = math.max(scrollOffset - 1, 0)
            elseif delta < 0 then
                local maxOffset = math.max(0, #displaySequence - entriesToShow)
                scrollOffset = math.min(scrollOffset + 1, maxOffset)
            end
            
            return true -- prevent further processing
        end
        
        ResultPanel.Paint = function(self, w, h)
            local curTime = CurTime()
            local fadeDuration = 0.2 -- seconds
            local fadeAlpha = 1
            
            if closing then
				gui.EnableScreenClicker(false)
                OK:SetEnabled(false)
                local elapsedFade = curTime - closeStartTime
                fadeAlpha = 1 - math.Clamp(elapsedFade / fadeDuration, 0, 1)
                
                if elapsedFade >= fadeDuration then
                    hook.Remove("CreateMove", "JumpKeyCloseResults")
                    if IsValid(ResultPanel) then
                        ResultPanel:Close()
                    end
                    return -- early exit, avoid drawing anymore
                end
            end
            
            -- Main black background
            -- surface.SetDrawColor(0, 0, 0, 150)
            -- surface.DrawRect(0, 0, w, h)
            
            -- Draw rows and alternating backgrounds fully visible when revealed
            local startIndex = scrollOffset + 1
            local endIndex = math.min(startIndex + entriesToShow - 1, #displaySequence)
            
            -- BG Element
            surface.SetDrawColor(255, 255, 255, math.floor(255 * fadeAlpha))
            surface.SetMaterial(UVMaterials["RESULTS_UG2_BG"])
            surface.DrawTexturedRect(0, 0, w, h) -- Upper
            
            -- Gray BG Elements
            surface.SetDrawColor(196, 208, 151, math.floor(255 * fadeAlpha))
            surface.SetMaterial(UVMaterials["RESULTS_UG2_SHINE"])
            surface.DrawTexturedRect(0, 0, w, h) -- Upper
            
            draw.SimpleText(UVString("uv.results.race.eventresults"), "UVFont", w * 0.05, h * 0.12, Color(196, 208, 151, math.floor(255 * fadeAlpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(UVString("uv.results.race.name"), "UVFont", w * 0.1, h * 0.2025, Color(255, 255, 255, math.floor(255 * fadeAlpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(UVString("uv.results.race.car"), "UVFont", w * 0.3, h * 0.2025, Color(255, 255, 255, math.floor(255 * fadeAlpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(UVString("uv.results.race.time.finish"), "UVFont", w * 0.9, h * 0.205, Color(255, 255, 255, math.floor(255 * fadeAlpha)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            
            for i = startIndex, endIndex do
                local entry = displaySequence[i]
                local localIndex = i - startIndex + 1
                local yPos = h * 0.29 + (localIndex - 1) * (h * 0.06)
                
                if entry.localPlayer then
                    surface.SetDrawColor(255, 255, 255, math.floor(200 * fadeAlpha))
                    surface.SetMaterial(UVMaterials["RESULTS_UG2_LP"])
                    surface.DrawTexturedRect(0, yPos, w, h * 0.055) -- Upper
                end
                
                if entry.posText then
                    draw.SimpleText(entry.posText, "UVFont", w * 0.085, yPos, Color(entry.color.r, entry.color.g, entry.color.b, math.floor(255 * fadeAlpha)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                end
                if entry.nameText then
                    draw.SimpleText(entry.nameText, "UVFont", w * 0.1, yPos, Color(entry.color.r, entry.color.g, entry.color.b, math.floor(255 * fadeAlpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                if entry.carText then
                    draw.SimpleText(entry.carText, "UVFont", w * 0.3, yPos, Color(entry.color.r, entry.color.g, entry.color.b, math.floor(255 * fadeAlpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                if entry.timeText then
                    draw.SimpleText(entry.timeText, "UVFont", w * 0.9, yPos, Color(entry.color.r, entry.color.g, entry.color.b, math.floor(255 * fadeAlpha)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                end
            end
            
            local blink = 255 * math.abs(math.sin(RealTime() * 8))
            
            if scrollOffset > 0 then
                draw.SimpleText("▲", "UVFont3", w * 0.5, h * 0.2425, Color(255,255,255, math.floor(blink * fadeAlpha)), TEXT_ALIGN_CENTER)
            end
            
            if scrollOffset < #displaySequence - entriesToShow then
                draw.SimpleText("▼", "UVFont3", w * 0.5, h * 0.815, Color(255,255,255, math.floor(blink * fadeAlpha)), TEXT_ALIGN_CENTER)
            end
            
            -- Time since panel was created
            local elapsed = CurTime() - timestart
            
            -- Only start auto-close countdown after reveal + flash
            local autoCloseDuration = 30  -- 30 seconds countdown
            
            local autoCloseTimer = 0
            local autoCloseRemaining = autoCloseDuration
            
            autoCloseTimer = elapsed
            autoCloseRemaining = math.max(0, autoCloseDuration - autoCloseTimer)

			local conttext = "<color=255,255,255><font=UVFont4>" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue")) .. "</font></color>"
			local mk = markup.Parse(conttext)
			
            surface.SetDrawColor(255, 255, 255, math.floor(200 * fadeAlpha) )
            surface.SetMaterial(UVMaterials["RESULTS_UG2_BUTTON"])
            surface.DrawTexturedRect( w*0.775, h*0.84, w * 0.15, h*0.0425)

			surface.SetAlphaMultiplier(math.floor(255 * fadeAlpha) / 255)
			mk:Draw(w * 0.85, h * 0.8475, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			surface.SetAlphaMultiplier(1)
			
            draw.DrawText( string.format( UVString("uv.results.autoclose"), math.ceil(autoCloseRemaining) ), "UVFont", w*0.05, h*0.85, Color( 196, 208, 151, math.floor(255 * fadeAlpha) ), TEXT_ALIGN_LEFT )
            
            if autoCloseRemaining <= 0 then
                hook.Remove("CreateMove", "JumpKeyCloseResults")
                if not closing then
                    surface.PlaySound( "uvui/ug/closemenu.wav" )
                    closing = true
                    closeStartTime = CurTime()
                end
            end
        end
        
        function OK:DoClick()
			hook.Remove("CreateMove", "JumpKeyCloseResults")
            if not closing then
                surface.PlaySound( "uvui/ug/closemenu.wav" )
                closing = true
                closeStartTime = CurTime()
            end
        end

		hook.Add("CreateMove", "JumpKeyCloseResults", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if ply:KeyPressed(IN_JUMP) then
				if IsValid(ResultPanel) and not closing then
					hook.Remove("CreateMove", "JumpKeyCloseResults")
					surface.PlaySound( "uvui/ug/closemenu.wav" )
					closing = true
					closeStartTime = CurTime()
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
						UV_UI.racing.underground2.events.ShowResults(sortedRacers)
					end)
					return
				end
                UV_UI.racing.underground2.events.ShowResults(sortedRacers)
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
		local cached = UV_UI.racing.general.SplitDiffCache and UV_UI.racing.general.SplitDiffCache[my_vehicle]
		local aheadDiff, behindDiff = "N/A", "N/A"

		if cached then
			aheadDiff = cached.Ahead or "N/A"
			behindDiff = cached.Behind or "N/A"
		end

		-- CenterNoti itself
		local splittime = "--:--.---"
		local noticol = Color(0, 255, 0)

		if aheadDiff == "N/A" and behindDiff ~= "N/A" then -- 1st place
			splittime = "+ " .. behindDiff
		elseif aheadDiff ~= "N/A" then -- 2nd place or below
			splittime = "- " .. aheadDiff
			noticol = Color(200, 75, 75)
		end
		
		local splittext = string.format( UVString("uv.race.splittime"), splittime )

		-- Display for 1 second using HUDPaint
		local startTime = CurTime()
		local duration = 1.5

		hook.Remove("HUDPaint", "UV_SPLITTIME")
		hook.Add("HUDPaint", "UV_SPLITTIME", function()
			local elapsed = CurTime() - startTime
			if elapsed > duration then
				hook.Remove("HUDPaint", "UV_SPLITTIME")
				return
			end

			local x, y = ScrW() * 0.5, ScrH() * 0.3
			draw.SimpleTextOutlined(
				splittime,
				"UVFont2-Smaller",
				x, y,
				noticol,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				0.5, Color(0,0,0,200)
			)
		end)
	end,
}

local function underground2_racing_main( ... )
    local w = ScrW()
    local h = ScrH()
    
    local my_vehicle = select(1, ...)
    local my_array = select(2, ...)
    local string_array = select(3, ...)
    
    local racer_count = #string_array
    local lang = UVString
    
    local checkpoint_count = #my_array["Checkpoints"]
    
    ------------------------------------
    
    -- Position Counter
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(UVMaterials["RACE_BG_UPPER_UG2"])
    surface.DrawTexturedRect(UV_UI.X(w * 0.72), h * 0.075, UV_UI.W(w * 0.255), h * 0.15)
    
    draw.DrawText( UVHUDRaceCurrentPos, "UVFont3Big", UV_UI.X(w * 0.79), h * 0.11, Color(255, 255, 255), TEXT_ALIGN_RIGHT ) -- Upper, Your Position
    draw.DrawText( UVString("uv.race.pos." .. UVHUDRaceCurrentPos), "UVFont3", UV_UI.X(w * 0.7925), h * 0.14, Color(255, 255, 255), TEXT_ALIGN_LEFT) -- Upper, Your Position
    draw.DrawText( "/" .. UVHUDRaceCurrentParticipants, "UVFont3Big", UV_UI.X(w * 0.82), h * 0.11, Color(255, 255, 255), TEXT_ALIGN_LEFT ) -- Lower, Total Positions
    
    -- Lap & Checkpoint Counter
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(UVMaterials["RACE_BG_LAP_UG2"])
    surface.DrawTexturedRect(UV_UI.X(w * 0.7135), h * 0.1525, UV_UI.W(w * 0.2655), h * 0.15)
    
    if UVHUDRaceInfo.Info.Laps > 1 then
        draw.DrawText( UVString("uv.race.hud.lap.ug"), "UVFont5", UV_UI.X(w * 0.735), h * 0.205, Color(255, 255, 255), TEXT_ALIGN_LEFT ) -- Lap Counter
        draw.DrawText( my_array.Lap .. "/" .. UVHUDRaceInfo.Info.Laps, "UVFont5", UV_UI.X(w * 0.945), h * 0.205, Color(255, 255, 255), TEXT_ALIGN_RIGHT ) -- Lap Counter
    else
        draw.DrawText( UVString("uv.race.hud.complete.ug2"), "UVFont", UV_UI.X(w * 0.735), h * 0.205, Color(255, 255, 255), TEXT_ALIGN_LEFT )
        draw.DrawText( math.floor(((checkpoint_count / GetGlobalInt("uvrace_checkpoints")) * 100)) .. "%", "UVFont", UV_UI.X(w * 0.945), h * 0.205, Color(255, 255, 255), TEXT_ALIGN_RIGHT )
    end
    
    -- Racer List
    local racer_count = #string_array
    local alt = math.floor(CurTime() / 5) % 2 == 1 -- toggles every 5 seconds
    for i = 1, math.Clamp(racer_count, 1, 4), 1 do
        local entry = string_array[i]
        
        local racer_name = entry[1]
        local is_local_player = entry[2]
        local mode = entry[3]
        local diff = entry[4]
        local racercount = i * w * 0.0155
        
        local Strings = {
            ["Time"] = "%s",
            ["Lap"] = lang("uv.race.suffix.lap"),
            ["Laps"] = lang("uv.race.suffix.laps"),
            ["Finished"] = lang("uv.race.suffix.finished"),
            ["Disqualified"] = lang("uv.race.suffix.dnf"),
            ["Busted"] = lang("uv.race.suffix.busted"),
        }
        
        local status_text = "-----"
        
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
            color = Color(200, 255, 200)
            surface.SetDrawColor(0, 0, 0, 200)
        elseif entry[3] == "Disqualified" or entry[3] == "Busted" then
            color = UVColors.MW_Disqualified
            surface.SetDrawColor(0, 0, 0, 125)
        else
            color = UVColors.MW_Others
            surface.SetDrawColor(0, 0, 0, 125)
        end
        
        local text = alt and (status_text) or (racer_name)
        
        draw.NoTexture()
        surface.DrawRect(UV_UI.X(w * 0.743), h * 0.235 + racercount, UV_UI.W(w * 0.227), h * 0.025)
        
        surface.SetDrawColor(0, 0, 0, 125)
        draw.NoTexture()
        surface.DrawRect(UV_UI.X(w * 0.725), h * 0.235 + racercount, UV_UI.W(w * 0.015), h * 0.025)
        
        draw.DrawText(i .. ":", "UVFont4", UV_UI.X(w * 0.738), (h * 0.235) + racercount, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
        draw.DrawText(text, "UVFont4", UV_UI.X(w * 0.965), (h * 0.235) + racercount, color, TEXT_ALIGN_RIGHT)
    end
    
    -- Timer
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(UVMaterials["RACE_BG_TIME_UG2"])
    surface.DrawTexturedRect(UV_UI.X(w * 0.708), h * 0.355, UV_UI.W(w * 0.276), h * 0.075)
    
    draw.DrawText( UVString("uv.race.orig.time"), "UVFont5UI", UV_UI.X(w * 0.73), h * 0.375, Color(255, 255, 255), TEXT_ALIGN_LEFT )
    
    local current_time = nil 
    
    if UV_UI.racing.underground2.states.FrozenTime then
        current_time = Carbon_FormatRaceTime( UV_UI.racing.underground2.states.FrozenTimeValue )
    elseif not my_array.LastLapTime then
        current_time = Carbon_FormatRaceTime( (UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time)) or 0 )
    else
        current_time = Carbon_FormatRaceTime( CurTime() - my_array.LastLapCurTime )
    end
    
    draw.DrawText( current_time, "UVFont5UI", UV_UI.X(w * 0.965), h * 0.375, Color(255, 255, 255), TEXT_ALIGN_RIGHT )
end

UV_UI.racing.underground2.main = underground2_racing_main