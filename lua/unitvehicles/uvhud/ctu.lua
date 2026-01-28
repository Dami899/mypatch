UV.RegisterHUD( "ctu", "Crash Time - Undercover" )

UV_UI.racing.ctu = UV_UI.racing.ctu or {}
-- UV_UI.pursuit.ctu = UV_UI.pursuit.ctu or {}

local function ctu_racing_main( ... )
    local w = ScrW()
    local h = ScrH()
    
    local my_vehicle = select(1, ...)
    local my_array = select(2, ...)
    local string_array = select(3, ...)
    
    local racer_count = #string_array
    local lang = UVString
    
    local checkpoint_count = #my_array["Checkpoints"]
    
    ------------------------------------
    
    -- Right Side Info
	-- Background
    surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(UVMaterials["HUD_CTU_RIGHT_BG"])
    surface.DrawTexturedRect(w - (UV_UI.X(w * 0.3)), h * 0.0775, UV_UI.X(w * 0.3), h * 0.0425)

    surface.SetDrawColor(0, 0, 0, 200)
	surface.SetMaterial(UVMaterials["HUD_CTU_RIGHT"])
    surface.DrawTexturedRect(w - (UV_UI.X(w * 0.3)), h * 0.0775, UV_UI.X(w * 0.3), h * 0.0425)

    -- Lap & Checkpoint Counter
	local lapname = "REPLACEME"
	local lapamount = "REPLACEME"
	
    if UVHUDRaceInfo.Info.Laps > 1 then
		lapname = "#uv.race.hud.laps.caps"
		lapamount = my_array.Lap .. "/" .. UVHUDRaceInfo.Info.Laps
    else
		lapname = "#uv.race.hud.complete"
		lapamount = math.floor(((checkpoint_count / GetGlobalInt("uvrace_checkpoints")) * 100)) .. "%"
    end
    
	draw.SimpleTextOutlined(lapname, "UVFont4BiggerItalic2", UV_UI.X(w * 0.72), h * 0.082, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
	draw.SimpleTextOutlined(lapamount, "UVFont4BiggerItalic2", UV_UI.X(w * 0.96), h * 0.082, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.5, Color( 0, 0, 0 ) )

    -- Timer
    local current_time = "--:--.--"
    
    if not my_array.LastLapTime then
        current_time = UVDisplayTimeRaceWorld( (UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time)) or 0 )
    else
        current_time = UVDisplayTimeRaceWorld( CurTime() - my_array.LastLapCurTime )
    end

	draw.SimpleTextOutlined("#uv.race.hud.laptime", "UVFont4BiggerItalic", UV_UI.X(w * 0.7175), h * 0.125, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
	draw.SimpleTextOutlined(current_time, "UVFont4BiggerItalic", UV_UI.X(w * 0.96), h * 0.125, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )

    -- Record Time
	if UVHUDRaceInfo.Info.Laps > 1 then
		local besttime = "--:--.--"
		
		if my_array.BestLapTime then
			besttime = UVDisplayTimeRaceWorld(my_array.BestLapTime)
		end

		draw.SimpleTextOutlined("#uv.race.hud.besttime.world", "UVFont4BiggerItalic", UV_UI.X(w * 0.715), h * 0.155, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
		
		draw.SimpleTextOutlined(besttime, "UVFont4BiggerItalic", UV_UI.X(w * 0.955), h * 0.155, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
	end

    local racer_count = #string_array
    local lang = UVString
    
    -- Left Side Info
	
    if racer_count > 1 then
		-- Background
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(UVMaterials["HUD_CTU_LEFT_BG"])
		surface.DrawTexturedRect(0, h * 0.0775, UV_UI.X(w * 0.3), h * 0.0425)

		surface.SetDrawColor(0, 0, 0, 200)
		surface.SetMaterial(UVMaterials["HUD_CTU_LEFT"])
		surface.DrawTexturedRect(0, h * 0.0775, UV_UI.X(w * 0.3), h * 0.0425)
	    
		-- Position Counter
        draw.SimpleTextOutlined("#uv.results.race.pos.caps", "UVFont4BiggerItalic2", UV_UI.X(w * 0.28),h * 0.082, Color( 255, 255, 255 ),TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
		draw.SimpleTextOutlined(UVHUDRaceCurrentPos .. "/" .. UVHUDRaceCurrentParticipants, "UVFont4BiggerItalic2", UV_UI.X(w * 0.0525), h * 0.082, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5, Color( 0, 0, 0 ) )

		-- Racer List
		local alt = math.floor(CurTime() / 5) % 2 == 1 -- toggles every 5 seconds
		for i = 1, math.Clamp(racer_count, 1, 16), 1 do
			--if racer_count == 1 then return end
			local entry = string_array[i]
			
			local racer_name = entry[1]
			local is_local_player = entry[2]
			local mode = entry[3]
			local diff = entry[4]
			local racercount = i * h * 0.025
			local racercountw = i * w * 0.001
			
			local Strings = {
				["Time"] = "%s",
				["Lap"] = lang("uv.race.suffix.lap"),
				["Laps"] = lang("uv.race.suffix.laps"),
				["Finished"] = lang("uv.race.suffix.finished"),
				["Disqualified"] = lang("uv.race.suffix.dnf"),
				["Busted"] = lang("uv.race.suffix.busted"),
			}
			
			local status_text = " "
			
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
			
			local color, colorbg = Color( 255, 255, 255 ), Color( 0, 0, 0 )
			
			if entry[3] == "Disqualified" or entry[3] == "Busted" then
				color = Color( 255, 100, 100, 175 )
				colorbg = Color( 0, 0, 0, 100 )
			end

			draw.SimpleTextOutlined(i, "UVFont4BiggerItalic2",UV_UI.X(w * 0.058) - racercountw, (h * 0.1) + racercount, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, colorbg )
			draw.SimpleTextOutlined(racer_name, "UVFont4BiggerItalic",UV_UI.X(w * 0.2085) - racercountw, (h * 0.1025) + racercount, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, colorbg )
			draw.SimpleTextOutlined(status_text, "UVFont4BiggerItalic",UV_UI.X(w * 0.075) - racercountw, (h * 0.1025) + racercount, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, colorbg )
		end
    end
end

UV_UI.racing.ctu.main = ctu_racing_main

UV_UI.racing.ctu.states = {
    LapCompleteText = nil,
	notificationQueue = {},
	notificationActive = nil,
}

UV_UI.racing.ctu.events = {
    ShowResults = function(sortedRacers) -- ctu
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
        OK:SetPos(w*0.4, h*0.8)
        OK:SetSize(w*0.2, h*0.035)

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
        
        local entriesToShow = 16
        local scrollOffset = 0
        
        local i = 0
        for place, dict in ipairs(racersArray) do
            local info = dict.array or {}
            i = i + 1
            
            -- Staggered vertical layout
            local visibleIndex = i -- 1 to entriesToShow
            local rowHeight = h * 0.09
            local yPos = h*0.08 + (i - 1) * rowHeight
            local LP, LC = false, Color(100, 100, 100)
            
            local name = info["Name"] or "Unknown"
            local totalTime = info["TotalTime"] and info["TotalTime"] or "#uv.race.suffix.dnf"
            local bestTime = info["BestLapTime"] and info["BestLapTime"] or "--:--.--"
            
            if info["Busted"] then totalTime = "#uv.race.suffix.busted" end
            
            if info["LocalPlayer"] then
                LP = true
                LC = Color(0, 0, 0)
            end
            
            local entry = {
                y = yPos,
                posText = tostring(i),
                nameText = name,
                timeText = UV_FormatRaceEndTime(totalTime),
                bestText = UV_FormatRaceEndTime(bestTime),
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
            local fadeDuration = 0.125
            local fadeAlpha = 1
            local scaleX = 1
            
            if closing then
                OK:SetEnabled(false)
				gui.EnableScreenClicker(false)
                local elapsedFade = curTime - closeStartTime
                local progress = math.Clamp(elapsedFade / fadeDuration, 0, 1)
                
                fadeAlpha = 1 - progress  -- fade out from 1 to 0
                scaleX = 1 + progress * 1  -- scale horizontally from 1 to 2 times

                if elapsedFade >= fadeDuration then
                    hook.Remove("CreateMove", "JumpKeyCloseResults")
                    if IsValid(ResultPanel) then
                        ResultPanel:Close()
                    end
                    return -- early exit, avoid drawing anymore
                end
            end

            -- Background Elements
			surface.SetDrawColor(0, 0, 0, 225 * fadeAlpha)
			surface.DrawRect(0, 0, w, h) -- Black BG
			
			surface.SetDrawColor(255, 255, 255, 255 * fadeAlpha)
			surface.SetMaterial(UVMaterials["HUD_CTU_GRADIENT_UP"])
			surface.DrawTexturedRect(0, 0, w, h * 0.25) -- Upper gradient

			surface.SetMaterial(UVMaterials["HUD_CTU_GRADIENT_DOWN"])
			surface.DrawTexturedRect(0, h * 0.75, w, h * 0.25) -- Lower gradient

			surface.SetMaterial(UVMaterials["HUD_CTU_BAR"])
			surface.DrawTexturedRect(0, h * 0.2, w, h * 0.02) -- Screen-wide bar
    	
            draw.SimpleTextOutlined("#uv.results.race.raceresults", "UVFont4BiggerItalic3", w * 0.1, h * 0.135, Color( 150, 50, 0, 255 * fadeAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 50 * fadeAlpha ) )
            
			draw.SimpleTextOutlined("#uv.results.race.bestlap.caps", "UVFont4BiggerItalic", w * 0.525, h * 0.225, Color( 150, 50, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 50 ) )
			
			draw.SimpleTextOutlined("#uv.results.race.time.caps", "UVFont4BiggerItalic", w * 0.705, h * 0.225, Color( 150, 50, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 50 ) )
			
	        local startIndex = scrollOffset + 1
            local endIndex = math.min(startIndex + entriesToShow - 1, #displaySequence)

			local rowXStart = h * 0.4565
			local rowYStart = h * 0.25
			local rowHeight = h * 0.035

            for i = startIndex, endIndex do
                local entry = displaySequence[i]
				local x = rowXStart - ((i - startIndex) * (h * 0.005))
				local y = rowYStart + ((i - startIndex) * (rowHeight - (h * 0.004)))
				local entrycol, entrycolbg = Color( 255, 255, 255, 255 * fadeAlpha ), Color( 0, 0, 0, 255 * fadeAlpha )

				-- Background for zebra striping
				surface.SetMaterial(UVMaterials['HUD_CTU_ENDBOX'])
				surface.SetDrawColor(255, 255, 255, 255 * fadeAlpha)
				surface.DrawTexturedRect(x, y, w * 0.485, rowHeight)

                if entry.localPlayer then
                    entrycol = Color( 150, 50, 0, 255 * fadeAlpha ), Color( 0, 0, 0, 50 * fadeAlpha )
                end
                
                if entry.posText then
                    draw.SimpleText(entry.posText, "UVFont4BiggerItalic", x + (w * 0.025), y + h * 0.004, entrycol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, entrycolbg )
                end
                if entry.nameText then
                    draw.SimpleText(entry.nameText, "UVFont4BiggerItalic", x + (w * 0.05), y + h * 0.004, entrycol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, entrycolbg )
                end
                if entry.bestText then
                    draw.SimpleText(entry.bestText, "UVFont4BiggerItalic", x + (w * 0.25), y + h * 0.004, entrycol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.25, entrycolbg )
                end
                if entry.timeText then
                    draw.SimpleText(entry.timeText, "UVFont4BiggerItalic", x + (w * 0.465), y + h * 0.004, entrycol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.25, entrycolbg )
                end
            end
            
            local blink = 255 * math.abs(math.sin(RealTime() * 8))
            
            if scrollOffset > 0 then
                draw.SimpleText("▲", "UVFont3", w * 0.5, h * 0.2, Color(255,255,255, math.floor(blink * fadeAlpha)), TEXT_ALIGN_CENTER)
            end
            
            if scrollOffset < #displaySequence - entriesToShow then
                draw.SimpleText("▼", "UVFont3", w * 0.5, h * 0.725, Color(255,255,255, math.floor(blink * fadeAlpha)), TEXT_ALIGN_CENTER)
            end
            
            -- Time since panel was created
            local elapsed = CurTime() - timestart
            
            -- Only start auto-close countdown after reveal + flash
            local autoCloseDuration = 30  -- 30 seconds countdown
            
            local autoCloseTimer = 0
            local autoCloseRemaining = autoCloseDuration
            
            autoCloseTimer = elapsed
            autoCloseRemaining = math.max(0, autoCloseDuration - autoCloseTimer)

			surface.SetDrawColor(255, 255, 255, 255 * fadeAlpha)
			surface.SetMaterial(UVMaterials["HUD_CTU_FOCUSBARBLACK"])
			surface.DrawTexturedRect(w * 0.4, h * 0.8, w * 0.2, h * 0.035)

			if IsValid(OK) and OK:IsHovered() then
				local blink2 = 255 * math.abs(math.sin(RealTime() * 2))

				surface.SetDrawColor(255, 255, 255, blink2 * fadeAlpha)
				surface.SetMaterial(UVMaterials["HUD_CTU_FOCUSBAR"])
				surface.DrawTexturedRect(w * 0.4, h * 0.8, w * 0.2, h * 0.035)
			end

			-- local conttext = UVBindButton("+jump") .. "    " .. UVString("uv.results.continue")
			local conttext = UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue"), "Big")
			local autotext = string.format( UVString("uv.results.autoclose"), math.ceil(autoCloseRemaining) )

			-- draw.SimpleTextOutlined(conttext, "UVFont4BiggerItalic2", w * 0.4025, h * 0.8, Color( 255, 255, 255, 255 * fadeAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 * fadeAlpha ) )
			markup.Parse( "<color=255,255,255" .. fadeAlpha .. "><font=UVFont4BiggerItalic2>" .. conttext .. "</font></color>", w * 0.95 ):Draw( w * 0.41, h * 0.8, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleTextOutlined(autotext, "UVFont4BiggerItalic2", w * 0.5, h * 0.835, Color( 255, 255, 255, 255 * fadeAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 * fadeAlpha ) )

            if autoCloseRemaining <= 0 then
                hook.Remove("CreateMove", "JumpKeyCloseResults")
                if not closing then
                    surface.PlaySound( "uvui/ctu/closemenu.wav" )
                    closing = true
                    closeStartTime = CurTime()
                end
            end
        end
        
        function OK:DoClick()
            if not closing then
                surface.PlaySound( "uvui/ctu/closemenu.wav" )
                closing = true
                closeStartTime = CurTime()
            end
        end

		hook.Add("CreateMove", "JumpKeyCloseResults", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if ply:KeyPressed(IN_JUMP) then
				if IsValid(ResultPanel) then
					hook.Remove("CreateMove", "JumpKeyCloseResults")
					surface.PlaySound( "uvui/ctu/closemenu.wav" )
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
						UV_UI.racing.ctu.events.ShowResults(sortedRacers)
					end)
					return
				end
                UV_UI.racing.ctu.events.ShowResults(sortedRacers)
            end
        end)
    end,

}