UV.RegisterHUD( "underground", "NFS: Underground" )

UV_UI.racing.underground = UV_UI.racing.underground or {}

UV_UI.racing.underground.states = {
    FrozenTime = false,
    FrozenTimeValue = 0
}

UV_UI.racing.underground.events = {
    onLapComplete = function( ... )
        local participant  = select( 1, ... )
        local new_lap      = select( 2, ... )
        local old_lap      = select( 3, ... )
        local lap_time     = select( 4, ... )
        local lap_time_cur = select( 5, ... )
        
        if participant:GetDriver() ~= LocalPlayer() then return end
        
        UV_UI.racing.underground.states.FrozenTime = true
        UV_UI.racing.underground.states.FrozenTimeValue = lap_time
        
        if timer.Exists( "_UG_TIME_FROZEN_DELAY" ) then timer.Remove( "_UG_TIME_FROZEN_DELAY" ) end
        timer.Create("_UG_TIME_FROZEN_DELAY", 3, 1, function()
            UV_UI.racing.underground.states.FrozenTime = false
        end)
    end,
    
    ShowResults = function(sortedRacers) -- Underground 1
        local debriefcolor = Color(255, 183, 61)
        
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
        OK:SetPos(w*0.5, h*0.9)
        OK:SetSize(w*0.2, h*0.025)
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
            
            local name = info["Name"] or "Unknown"
            local totalTime = info["TotalTime"] and info["TotalTime"] or UVString("uv.race.suffix.dnf")
            
            if info["Busted"] then totalTime = UVString("uv.race.suffix.busted") end
            
            local entry = {
                y = yPos,
                posText = tostring(i),
                nameText = name,
                timeText = UV_FormatRaceEndTime(totalTime)
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
            local fadeDuration = 0.25 -- seconds
            local fadeAlpha = 1
            
            if closing then
                OK:SetEnabled(false)
				gui.EnableScreenClicker(false)
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
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            
            -- Draw rows and alternating backgrounds fully visible when revealed
            local startIndex = scrollOffset + 1
            local endIndex = math.min(startIndex + entriesToShow - 1, #displaySequence)
            
            -- Upper blue BG
            surface.SetDrawColor(38, 93, 160, math.floor(200 * fadeAlpha))
            surface.DrawRect(w * 0.7, 0, w * 0.33, h * 0.075)
            
            -- Lower blue BG
            surface.DrawRect(w * 0.7, h * 0.9, w * 0.33, h * 0.125)
            
            for i = startIndex, endIndex do
                local entry = displaySequence[i]
                local localIndex = i - startIndex + 1
                local yPos = h * 0.08 + (localIndex - 1) * (h * 0.09)
                
                surface.SetDrawColor(38, 93, 160, math.floor(200 * fadeAlpha))
                surface.DrawRect(w * 0.7, yPos, w * 0.33, h * 0.085)
                
                surface.SetDrawColor(104, 172, 255, math.floor(200 * fadeAlpha))
                surface.DrawRect(w * 0.7025, yPos + (h * 0.005), w * 0.33, h * 0.0375)
                
                if entry.posText then
                    draw.SimpleText(entry.posText, "UVFont", w * 0.715, yPos + (h * 0.04), Color(255, 255, 255, math.floor(255 * fadeAlpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                if entry.nameText then
                    draw.SimpleText(entry.nameText, "UVFont", w * 0.99, yPos, Color(255, 255, 255, math.floor(255 * fadeAlpha)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                end
                if entry.timeText then
                    draw.SimpleText(entry.timeText, "UVFont4", w * 0.99, yPos + (h * 0.05), Color(255, 255, 255, math.floor(255 * fadeAlpha)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                end
            end
            
            local blink = 255 * math.abs(math.sin(RealTime() * 8))
            
            if scrollOffset > 0 then
                draw.SimpleText("▲", "UVFont3", w * 0.86, h * 0.0175, Color(255,255,255, math.floor(blink * fadeAlpha)), TEXT_ALIGN_CENTER)
            end
            
            if scrollOffset < #displaySequence - entriesToShow then
                draw.SimpleText("▼", "UVFont3", w * 0.86, h * 0.9, Color(255,255,255, math.floor(blink * fadeAlpha)), TEXT_ALIGN_CENTER)
            end
            
            -- Time since panel was created
            local elapsed = CurTime() - timestart
            
            -- Only start auto-close countdown after reveal + flash
            local autoCloseDuration = 30  -- 30 seconds countdown
            
            local autoCloseTimer = 0
            local autoCloseRemaining = autoCloseDuration
            
            autoCloseTimer = elapsed
            autoCloseRemaining = math.max(0, autoCloseDuration - autoCloseTimer)

			local conttext = "<color=104,172,255><font=UVFont4>" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue")) .. "</font></color>"
			local mk = markup.Parse(conttext)
			local conttextl = mk:GetWidth()

			local conttexts = conttextl + (w * 0.005)
			
			local autotext = string.format( UVString("uv.results.autoclose"), math.ceil(autoCloseRemaining) )
			local autotextl = surface.GetTextSize(autotext)
			local autotexts = autotextl + (w * 0.005)
			
			surface.SetDrawColor(38, 93, 160, math.floor(200 * fadeAlpha) )
			surface.DrawRect( w*0.6975 - conttexts, h*0.9, conttexts, h*0.025)
			
			surface.SetAlphaMultiplier(math.floor(255 * fadeAlpha) / 255)
			mk:Draw(w * 0.6945, h * 0.9005, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			surface.SetAlphaMultiplier(1)
			
			surface.DrawRect( w*0.6975 - autotexts, h*0.925, autotexts, h*0.025)
			draw.DrawText( autotext, "UVFont4", w*0.6945, h*0.9255, Color( 104, 172, 255, math.floor(255 * fadeAlpha) ), TEXT_ALIGN_RIGHT )
	
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
                    surface.PlaySound( "uvui/ug/closemenu.wav" )
					hook.Remove("CreateMove", "JumpKeyCloseResults")
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
						UV_UI.racing.underground.events.ShowResults(sortedRacers)
					end)
					return
				end
                UV_UI.racing.underground.events.ShowResults(sortedRacers)
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
				"UVFont-Shadow",
				x, y,
				noticol,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				0.5, Color(0,0,0,200)
			)
		end)
	end,

}

local function underground_racing_main( ... )
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
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(UV_UI.X(w * 0.02), h * 0.175, UV_UI.W(w * 0.175), h * 0.0225)
    draw.DrawText( UVString("uv.race.hud.time.ug"), "UVFont4", UV_UI.X(w * 0.022), h * 0.175, Color(255, 255, 255), TEXT_ALIGN_LEFT )
    
    local current_time = nil 
    
    if UV_UI.racing.underground.states.FrozenTime then
        current_time = UVDisplayTimeRace( UV_UI.racing.underground.states.FrozenTimeValue )
    elseif not my_array.LastLapTime then
        current_time = UVDisplayTimeRace( (UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time)) or 0 )
    else
        current_time = UVDisplayTimeRace( CurTime() - my_array.LastLapCurTime )
    end
    
    draw.DrawText( current_time or UVDisplayTimeRace( 0 ), "UVFont4", UV_UI.X(w * 0.1925), h * 0.175, Color(255, 255, 255), TEXT_ALIGN_RIGHT )
    
    -- Best Timer
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(UV_UI.X(w * 0.02), h * 0.2, UV_UI.W(w * 0.175), h * 0.0225)
	
    draw.DrawText( UVString("uv.race.hud.best.ug"), "UVFont4", UV_UI.X(w * 0.022), h * 0.2, Color(255, 255, 255), TEXT_ALIGN_LEFT )
    draw.DrawText( UVDisplayTimeRace(my_array.BestLapTime or 0), "UVFont4", UV_UI.X(w * 0.1925), h * 0.2, Color(255, 255, 255), TEXT_ALIGN_RIGHT )
    
    -- Lap & Checkpoint Counter
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(UV_UI.X(w * 0.02), h * 0.075, UV_UI.W(w * 0.175), h * 0.095)
	
    -- Lap Counter
    draw.DrawText( UVString("uv.race.hud.lap.ug"), "UVFont5", UV_UI.X(w * 0.1), h * 0.125, Color(125, 125, 255), TEXT_ALIGN_LEFT ) 
    draw.DrawText( my_array.Lap, "UVFont3Bigger", UV_UI.X(w * 0.1), h * 0.065, Color(255, 255, 255), TEXT_ALIGN_RIGHT )
    draw.DrawText( "/ " .. UVHUDRaceInfo.Info.Laps, "UVFont3", UV_UI.X(w * 0.1025), h * 0.08, Color(125, 125, 255), TEXT_ALIGN_LEFT)
    
    local racer_count = #string_array
    local lang = UVString
    
    -- Position Counter
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(UV_UI.X(w * 0.8), h * 0.075, UV_UI.W(w * 0.175), h * 0.105)
    
    draw.DrawText( UVHUDRaceCurrentPos, "UVFont3Bigger", UV_UI.X(w * 0.88), h * 0.065, Color(255, 255, 255), TEXT_ALIGN_RIGHT ) -- Upper, Your Position
    draw.DrawText( UVString("uv.race.pos.") .. UVHUDRaceCurrentPos, "UVFont5", UV_UI.X(w * 0.8825), h * 0.08, Color(255, 255, 255), TEXT_ALIGN_LEFT) -- Upper, Your Position Suffix
    draw.DrawText( "/" .. UVHUDRaceCurrentParticipants, "UVFont5", UV_UI.X(w * 0.88), h * 0.12, Color(125, 125, 255), TEXT_ALIGN_LEFT) -- Lower, Total Positions
    
    -- Racer List
    local alt = math.floor(CurTime() / 5) % 2 == 1 -- toggles every 5 seconds
    for i = 1, math.Clamp(racer_count, 1, 16), 1 do
        --if racer_count == 1 then return end
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
            color = UVColors.MW_Others
            surface.SetDrawColor(150, 150, 255, 200)
        elseif entry[3] == "Disqualified" or entry[3] == "Busted" then
            color = UVColors.MW_Disqualified
            surface.SetDrawColor(0, 0, 0, 200)
        else
            color = UVColors.MW_Others
            surface.SetDrawColor(0, 0, 0, 200)
        end
        
        local text = alt and (status_text) or (racer_name)
        
        -- surface.SetDrawColor(0, 0, 0, 200)
        draw.NoTexture()
        surface.DrawRect(UV_UI.X(w * 0.82), h * 0.16 + racercount, UV_UI.W(w * 0.155), h * 0.025)
        
        surface.SetDrawColor(0, 0, 0, 200)
        draw.NoTexture()
        surface.DrawRect(UV_UI.X(w * 0.8), h * 0.16 + racercount, UV_UI.W(w * 0.0175), h * 0.025)
        
        draw.DrawText(i .. ":", "UVFont4", UV_UI.X(w * 0.808), (h * 0.16) + racercount, color, TEXT_ALIGN_CENTER)
        draw.DrawText(text, "UVFont4", UV_UI.X(w * 0.97), (h * 0.16) + racercount, color, TEXT_ALIGN_RIGHT)
    end
end

UV_UI.racing.underground.main = underground_racing_main