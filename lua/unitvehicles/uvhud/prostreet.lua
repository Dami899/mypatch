UV.RegisterHUD( "prostreet", "NFS: ProStreet" )

-- [[ Convars ]] --
-- Racing
CreateClientConVar("uvhud_prostreet_race_raceramount", 8, true, false)
local maxracernrcv = GetConVar("uvhud_prostreet_race_raceramount"):GetString()

UVMenu.CustomizeHUD = UVMenu.CustomizeHUD or {}
UVMenu.CustomizeHUD.prostreet = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1200),
		Height = UV.ScaleH(760),
		DynamicHeight = true,
		Description = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.ui.custhud",
				{ type = "label", text = "NFS: ProStreet" },
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
						func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
				{ type = "infosimple", text = "uv.ui.custhud.race" },
				{ type = "slider", text = "uv.ui.custhud.raceramount", desc = "uv.ui.custhud.raceramount.desc", convar = "uvhud_prostreet_race_raceramount", min = 4, max = 18, decimals = 0 },
			},
		}
	})
end

UV_UI.racing.prostreet = UV_UI.racing.prostreet or {}

local function prostreet_racing_main( ... )
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
    surface.DrawRect(UV_UI.XScaled(w * 0.425), h * 0.075, UV_UI.W(w * 0.15), h * 0.05)

	draw.SimpleTextOutlined(UVString("uv.race.hud.time.ps"), "UVFont5", w * 0.5, h * 0.035, Color( 255, 255, 255, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.5, Color( 0, 0, 0 ) )
	draw.SimpleTextOutlined(Carbon_FormatRaceTime((UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time)) or 0), "UVFont5", w * 0.5, h * 0.0775, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.5, Color( 0, 0, 0 ) )

    -- Lap & Checkpoint Counter
	local lapname = "REPLACEME"
	local lapamount = "REPLACEME"
	
    if UVHUDRaceInfo.Info.Laps > 1 then
		lapname = UVString("uv.race.hud.lap.ps")
		lapamount = my_array.Lap .. "/" .. UVHUDRaceInfo.Info.Laps
    else
		lapname = UVString("uv.race.hud.complete.ps")
		lapamount = math.floor(((checkpoint_count / GetGlobalInt("uvrace_checkpoints")) * 100)) .. "%"
    end
    
	draw.SimpleTextOutlined(lapname, "UVFont5", UV_UI.X(w * 0.9), h * 0.075, Color( 255, 255, 255, 150 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.5, Color( 0, 0, 0 ) )
	draw.SimpleTextOutlined(lapamount, "UVFont5", UV_UI.X(w * 0.97), h * 0.075, Color( 200, 255, 100 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.5, Color( 0, 0, 0 ) )

    local racer_count = #string_array
    local lang = UVString
    
    -- Racer List
    local alt = math.floor(CurTime() / 5) % 2 == 1 -- toggles every 5 seconds
    local boxyes = false
    for i = 1, math.Clamp(racer_count, 1, GetConVar("uvhud_prostreet_race_raceramount"):GetString()), 1 do
        --if racer_count == 1 then return end
        local entry = string_array[i]
        
        local racer_name = entry[1]
        local is_local_player = entry[2]
        local mode = entry[3]
        local diff = entry[4]
        local racercount = i * w * 0.0135
        local racercountbox = i * w * 0.0135 * math.Clamp(racer_count, 1, GetConVar("uvhud_prostreet_race_raceramount"):GetString())
        
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
            color = Color(200, 255, 100)
        elseif entry[3] == "Disqualified" or entry[3] == "Busted" then
            color = UVColors.MW_Disqualified
        else
            color = UVColors.MW_Others
        end
        
        local text = alt and (status_text) or (racer_name)

		surface.SetFont("UVFont4")
		local ymax = UV_UI.W(w * 0.1)
		textW = surface.GetTextSize(text)
		if textW > ymax then
			while surface.GetTextSize(text .. "...") > ymax do
				text = string.sub(text, 1, -2)
			end
			text = text .. "..."
		end

        if not boxyes then
            surface.SetDrawColor(0, 0, 0, 200)
            draw.NoTexture()
            surface.DrawRect(UV_UI.X(w * 0.025), h * 0.1, UV_UI.W(w * 0.15), h * 0.04 + racercountbox)
            boxyes = true
        end
        
        draw.DrawText(i .. "      " .. text, "UVFont4", UV_UI.X(w * 0.0275), (h * 0.1) + racercount, color, TEXT_ALIGN_LEFT)
    end
end

UV_UI.racing.prostreet.main = prostreet_racing_main

UV_UI.racing.prostreet.states = {
    LapCompleteText = nil,
	notificationQueue = {},
	notificationActive = nil,
}

UV_UI.racing.prostreet.events = {
	CenterNotification = function( params )
		local immediate = params.immediate or false

		if UV_UI.racing.prostreet.states.notificationActive then
			if immediate then
				hook.Remove("HUDPaint", "UV_CENTERNOTI_PROSTREET")
				UV_UI.racing.prostreet.states.notificationActive = false
				UV_UI.racing.prostreet.states.notificationQueue = {}
				timer.Simple(0, function()
					UV_UI.racing.prostreet.events.CenterNotification(params)
				end)
				return
			else
				table.insert(UV_UI.racing.prostreet.states.notificationQueue, params)
				return
			end
		end

		UV_UI.racing.prostreet.states.notificationActive = true

		local ptext = params.text or "ERROR: NO TEXT"
		local pnoicon = params.noIcon

		local pfontUpper = params.fontUpper or "UVCarbonFont"
		local pfontLower = params.fontLower or "UVCarbonFont"

		local pcolorUpper = params.colorUpper or Color(255, 255, 255)
		local pcolorLower = params.colorLower or Color(255, 255, 255)

		local ptextposLower = params.textPosLower or 0.385

		local SID = 0.35

		local prostreet_noti_animState = {
			active = false,
			startTime = 0,
			slideInDuration = SID,
			holdDuration = 3,
			slideDownDuration = 0.25,
			upper = {
				startX = ScrW() * 0.25,
				centerX = ScrW() / 2,
				y = ScrH() * 0.35,
				slideDownEndY = ScrH() * 0.6,
			},
			lower = {
				startX = ScrW() * 0.75,
				centerX = ScrW() / 2,
				y = ScrH() * ptextposLower,
				slideDownEndY = ScrH() * 0.635,
			},
		}

        UV_UI.racing.carbon.events.prostreet_noti_animState = prostreet_noti_animState
        prostreet_noti_animState.active = true
        prostreet_noti_animState.startTime = CurTime()
        
        ----------------------------------------------------------------------------
        
        -- Remove any existing HUDPaint hook with the same name (avoid duplicates)
        if hook.GetTable().HUDPaint and hook.GetTable().HUDPaint.UV_CENTERNOTI_PROSTREET then
            hook.Remove("HUDPaint", "UV_CENTERNOTI_PROSTREET")
        end
        
        -- Add the HUDPaint hook freshly for this animation
        hook.Add("HUDPaint", "UV_CENTERNOTI_PROSTREET", function()
            local elapsed = CurTime() - prostreet_noti_animState.startTime
            
            local function calcPosAlpha(elapsed, elem)
                local x, y, alpha = elem.centerX, elem.y, 255
                if elapsed < prostreet_noti_animState.slideInDuration then
                    local t = elapsed / prostreet_noti_animState.slideInDuration
                    x = Lerp(t, elem.startX, elem.centerX)
                    alpha = Lerp(t, 0, 255)
                elseif elapsed < prostreet_noti_animState.slideInDuration + prostreet_noti_animState.holdDuration then
                    x = elem.centerX
                    alpha = 255
                elseif elapsed < prostreet_noti_animState.slideInDuration + prostreet_noti_animState.holdDuration + prostreet_noti_animState.slideDownDuration then
                    local t = (elapsed - prostreet_noti_animState.slideInDuration - prostreet_noti_animState.holdDuration) / prostreet_noti_animState.slideDownDuration
                    -- y = Lerp(t, elem.y, elem.slideDownEndY)
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
            local ux, uy, ualpha = calcPosAlpha(elapsed, prostreet_noti_animState.upper)
            carbon_noti_draw( upperLine, pfontUpper, nil, ux, uy, Color(pcolorUpper.r, pcolorUpper.g, pcolorUpper.b, ualpha), nil)

			-- Lower
            local lx, ly, lalpha = calcPosAlpha(elapsed, prostreet_noti_animState.lower)
            carbon_noti_draw( lowerLine, pfontLower, nil, lx, ly, Color(pcolorLower.r, pcolorLower.g, pcolorLower.b, lalpha), nil)

            -- Disable animation and remove hook when done
            if elapsed > prostreet_noti_animState.slideInDuration + prostreet_noti_animState.holdDuration + prostreet_noti_animState.slideDownDuration then
                prostreet_noti_animState.active = false
                hook.Remove("HUDPaint", "UV_CENTERNOTI_PROSTREET")
				timer.Simple(0, function()
					UV_UI.racing.prostreet.states.notificationActive = false
					if #UV_UI.racing.prostreet.states.notificationQueue > 0 then
						local nextParams = table.remove(UV_UI.racing.prostreet.states.notificationQueue, 1)
						timer.Simple(0.05, function() -- give a few ms buffer
							UV_UI.racing.prostreet.events.CenterNotification(nextParams)
						end)
					end
				end)
            end
		end)
	end,
	
    ShowResults = function(sortedRacers) -- ProStreet
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
        OK:SetPos(w*0.2565, h*0.9)
        OK:SetSize(w*0.3, h*0.035)

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
        
        local entriesToShow = 8
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
            local totalTime = info["TotalTime"] and info["TotalTime"] or UVString("uv.race.suffix.dnf")
            
            if info["Busted"] then totalTime = UVString("uv.race.suffix.busted") end
            
            if info["LocalPlayer"] then
                LP = true
                LC = Color(0, 0, 0)
            end
            
            local entry = {
                y = yPos,
                posText = tostring(i),
                nameText = name,
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
        
        local playedfadeSound = false
        
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
                
                if not playedfadeSound and elapsedFade >= 0.05 then
                    playedfadeSound = true
                    surface.PlaySound( "uvui/ps/closemenu2.wav" )
                end
                
                if elapsedFade >= fadeDuration then
                    hook.Remove("CreateMove", "JumpKeyCloseResults")
                    if IsValid(ResultPanel) then
                        ResultPanel:Close()
                    end
                    return -- early exit, avoid drawing anymore
                end
            end
            -- Setup transformation matrix
            local matrix = Matrix()
            matrix:Translate(Vector(w * 0.5, 0, 0))         -- move origin to horizontal center
            matrix:Scale(Vector(scaleX, 1, 1))              -- scale horizontally
            matrix:Translate(Vector(-w * 0.5, 0, 0))        -- move origin back
            
            cam.PushModelMatrix(matrix)
            
            -- Draw rows and alternating backgrounds fully visible when revealed
            local startIndex = scrollOffset + 1
            local endIndex = math.min(startIndex + entriesToShow - 1, #displaySequence)
            
            -- Black BG Textured Elements
            surface.SetDrawColor(0, 0, 0, 255 * fadeAlpha)
            surface.SetMaterial(UVMaterials["RESULTS_PS_CURVES"])
            surface.DrawTexturedRect(w * 0.31, h * 0.125, w * 0.125, h * 0.11)
            
            surface.SetMaterial(UVMaterials["RESULTS_PS_HUB"])
            surface.DrawTexturedRectRotated(w * 0.31, h * 0.185, w * 0.1, h * 0.09, -12.5)
            
            surface.SetMaterial(UVMaterials["RESULTS_PS_SP8"])
            surface.DrawTexturedRectRotated(w * 0.255, h * 0.2, w * 0.07, h * 0.125, -32.5)
            
            surface.SetMaterial(UVMaterials["RESULTS_PS_SP8"])
            surface.DrawTexturedRectRotated(w * 0.2035, h * 0.27, w * 0.07, h * 0.125, -130)
            
            surface.SetMaterial(UVMaterials["RESULTS_PS_WING_INV"])
            surface.DrawTexturedRect(w * 0.18, h * 0.26, w * 0.055, h * 0.25, 0)
            
            local baseHeight = 0.31
            local extraHeight = 0
            
            if #displaySequence > 4 then
                local extraEntries = math.min(#displaySequence, 8) - 4
                extraHeight = extraEntries * (h * 0.06)
            end
            
            -- Black BG Element
            surface.SetDrawColor(0, 0, 0, 255 * fadeAlpha)
            surface.DrawRect(w * 0.2, h * 0.2, w * (1 - 2 * 0.2), (h * baseHeight) + extraHeight)
            
            -- White BG Element
            surface.SetDrawColor(200, 200, 200, 255 * fadeAlpha)
            surface.DrawRect(w * 0.21, h * 0.25, w * (1 - 2 * 0.21), (h * (baseHeight - 0.06)) + extraHeight)
            
            draw.SimpleText(UVString("uv.results.race.raceresults"), "UVFont2", w * 0.205, h * 0.2025, Color(255, 255, 255, 255 * fadeAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            for i = startIndex, endIndex do
                local entry = displaySequence[i]
                local localIndex = i - startIndex + 1
                local yPos = h * 0.255 + (localIndex - 1) * (h * 0.06)
                
                if entry.localPlayer then
                    surface.SetDrawColor(255, 255, 0, 255 * fadeAlpha)
                else
                    surface.SetDrawColor(175, 175, 175, 255 * fadeAlpha)
                end
                surface.DrawRect(w * 0.2175, yPos, w * (1 - 2 * 0.2175), h * 0.055)
                
                if entry.posText then
                    draw.SimpleText(entry.posText, "UVFont2", w * 0.22, yPos, Color(entry.color.r, entry.color.g, entry.color.b, 255 * fadeAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                if entry.nameText then
                    draw.SimpleText(entry.nameText, "UVFont2", w * 0.25, yPos, Color(entry.color.r, entry.color.g, entry.color.b, 255 * fadeAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                if entry.timeText then
                    draw.SimpleText(entry.timeText, "UVFont2", w * 0.775, yPos, Color(entry.color.r, entry.color.g, entry.color.b, 255 * fadeAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
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

			local conttext = "<color=255,255,255><font=UVCarbonLeaderboardFont>" .. UVReplaceKeybinds("[+jump] " .. UVString("uv.results.continue")) .. "</font></color>"
			local mk = markup.Parse(conttext)
			local conttextw = mk:GetWidth()

			surface.SetFont("UVCarbonLeaderboardFont")
			local autotext = string.format( UVString("uv.results.autoclose"), math.ceil(autoCloseRemaining) )
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

            cam.PopModelMatrix()
            
            if autoCloseRemaining <= 0 then
                hook.Remove("CreateMove", "JumpKeyCloseResults")
                if not closing then
                    surface.PlaySound( "uvui/ps/closemenu.wav" )
                    closing = true
                    closeStartTime = CurTime()
                end
            end
        end
        
        function OK:DoClick()
            if not closing then
                surface.PlaySound( "uvui/ps/closemenu.wav" )
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
					surface.PlaySound( "uvui/ps/closemenu.wav" )
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
						UV_UI.racing.prostreet.events.ShowResults(sortedRacers)
					end)
					return
				end
                UV_UI.racing.prostreet.events.ShowResults(sortedRacers)
            end
        end)
    end,
    
    onLapComplete = function( participant, new_lap, old_lap, lap_time, lap_time_cur, is_local_player, is_global_best, lap_final, local_finished, user_finished, suppress_lap_ui )
        local name = UVHUDRaceInfo.Participants[participant] and UVHUDRaceInfo.Participants[participant].Name or "Unknown"
        local llt = ""
        		
		local cps = GetGlobalInt("uvrace_checkpoints")
		local participant_count = UVHUDRaceInfo.Participants and table.Count(UVHUDRaceInfo.Participants) or 0

		local finishtext = (participant_count > 1 and cps > 1) and 
		UVString("uv.race.finished") .. "\n" .. string.format( UVString("uv.race.finishspot"), UVString("uv.race.pos.num." .. UVHUDRaceCurrentPos) )
		or UVString("uv.race.finished")

		if local_finished then 
			UV_UI.racing.prostreet.events.CenterNotification({
				text = finishtext,
			})
			return
		end
	
		if suppress_lap_ui then return end

        if is_local_player and lap_final then llt = UVString("uv.race.finallap") .. " " end
        
        if is_global_best then
            UV_UI.racing.prostreet.states.LapCompleteText = llt .. string.format(UVString("uv.race.fastest.laptime"), name, Carbon_FormatRaceTime( lap_time ) )
        else
            if is_local_player then
                UV_UI.racing.prostreet.states.LapCompleteText = llt .. string.format(UVString("uv.race.laptime.carbon"), Carbon_FormatRaceTime( lap_time ) )
            else
                return
            end
        end
		UV_UI.racing.prostreet.events.CenterNotification({
			text = UV_UI.racing.prostreet.states.LapCompleteText,
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

		UV_UI.racing.prostreet.events.CenterNotification({
			text = disqtext,
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
		local cached = UV_UI.racing.general.SplitDiffCache and UV_UI.racing.general.SplitDiffCache[my_vehicle]
		local aheadDiff, behindDiff = "N/A", "N/A"

		if cached then
			aheadDiff = cached.Ahead or "N/A"
			behindDiff = cached.Behind or "N/A"
		end

		-- CenterNoti itself
		local splittime = "--:--.---"
		local showahead = false
		local noticol = false
		
		local splittext = ""

		if aheadDiff ~= "N/A" then -- If car is ahead
			splittext = string.format( UVString("uv.race.car.ahead"), "+" .. aheadDiff )
		end
		
		if behindDiff ~= "N/A" then -- If car is behind
			splittext = splittext .. "\n" .. string.format( UVString("uv.race.car.behind"), "-" .. behindDiff )
		end

		UV_UI.racing.prostreet.events.CenterNotification({
			text = splittext,
			colorUpper = Color(200, 75, 75),
			colorLower = Color(100, 255, 100),
			fontUpper = "UVCarbonLeaderboardFont",
			fontLower = "UVCarbonLeaderboardFont",
			textPosLower = 0.37,
			immediate = true,
		})
	end,

	onRaceStartTimer = function(data)
		local starttime = data.starttime
		local now = CurTime()
		
		local function EaseOutCubic(t)
			return 1 - math.pow(1 - t, 3)
		end

		local function EaseInCubic(t)
			return t * t * t
		end

		local map = {
			[4] = "3",
			[3] = "2",
			[2] = "1",
			[1] = UVString("uv.race.go")
		}

		local value = map[starttime]
		if not value then return end

		-- LOCAL state
		local HUDCountdownTick = {
			mode = starttime == 1 and "GO" or "COUNTDOWN",
			startTime = now
		}

		local alive = true

		local text = {
			value = value,
			scale = starttime == 1 and 3.4 or 2.4,
			alpha = 255,
			color = starttime == 1 and Color(0,255,0) or Color(255,220,0)
		}

		local plate, startL, startR

		if starttime == 1 then
			plate = {
				alpha = 0,
				size = 0.4,
				start = now + 0.04
			}

			startL = {
				x = -220,
				alpha = 0,
				start = now + 0.10
			}

			startR = {
				x = 220,
				alpha = 0,
				start = now + 0.10
			}
		end

		local hookID = "UV_RaceCountdown_ProStreet_" .. tostring(now)

		hook.Add("HUDPaint", hookID, function()
			if not alive then return end

			local now = CurTime()
			local t = now - HUDCountdownTick.startTime
			local cx, cy = ScrW() * 0.5, ScrH() * 0.4
		
			-- "START" ghost text
			local function drawStartGhost(st, invert, now, cy)
				if not st or now < st.start then return end
				local dt = now - st.start

				-- X slide: start far → near center
				local slideDuration = 1.1
				local p = math.Clamp(dt / slideDuration, 0, 1)
				st.x = Lerp(EaseOutCubic(p), invert and 220 or -220, invert and -22 or 22)

				-- Alpha: fade in quickly, then fade out after 0.7s
				local alpha = 0
				if dt < 0.4 then
					alpha = Lerp(EaseOutCubic(dt / 0.4), 0, 150)
				elseif dt < 0.6 then
					alpha = Lerp(EaseOutCubic((dt - 0.6)/0.20), 150, 0)
				else
					return
				end

				draw.SimpleText( UVString("uv.race.start"), "UVFont5ShadowBig", cx + st.x, cy, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			if HUDCountdownTick.mode == "COUNTDOWN" then
				if t < 0.06 then
					text.scale = 1.45
					text.alpha = 255

				elseif t < 0.16 then
					local p = (t - 0.06) / 0.10
					text.scale = Lerp(p, 1.45, 1.75)

				elseif t < 0.28 then
					local p = (t - 0.16) / 0.12
					text.scale = Lerp(p, 1.75, 1.35)

				elseif t < 0.62 then
					text.scale = 1.35

				elseif t < 0.78 then
					local p = (t - 0.62) / 0.16
					text.scale = Lerp(p, 1.35, 7.5)
					text.alpha = Lerp(p, 255, 0)
				else
					alive = false
					hook.Remove("HUDPaint", hookID)
					return
				end
			end

			if HUDCountdownTick.mode == "GO" then
				drawStartGhost(startL, false, now, cy)
				drawStartGhost(startR, true, now, cy)
				
				if t < 0.01 then
					text.scale = 3.6
					text.alpha = 0

				elseif t < 0.08 then
					local p = (t - 0.01) / 0.07
					text.scale = Lerp(p, 7.5, 1.55)
					text.alpha = Lerp(p, 0, 255)

				elseif t < 0.38 then
					local p = (t - 0.08) / 0.30
					text.scale = Lerp(p, 1.55, 1.45)

				elseif t < 0.95 then
					text.scale = 1.45

				elseif t < 1.15 then
					local p = (t - 0.95) / 0.20
					text.scale = Lerp(p, 1.45, 7.5)
					text.alpha = Lerp(p, 255, 0)
				else
					alive = false
					hook.Remove("HUDPaint", hookID)
					return
				end
			end

			if HUDCountdownTick.mode == "GO" and plate and now >= plate.start then
				local pt = now - plate.start

				if pt < 0.10 then
					plate.alpha = Lerp(pt / 0.10, 0, 125)
				elseif pt < 0.5 then
					plate.alpha = 125
				elseif pt < 0.75 then
					plate.alpha = Lerp((pt - 0.75) / 0.20, 125, 0)
				end

				DrawIcon( UVMaterials["RACE_FLAG_PS"], cx - plate.size * 0.5, cy - plate.size * 0.25, plate.size, Color(255, 255, 255, plate.alpha) )
			end

			local m = Matrix()
			m:Translate(Vector(cx, cy, 0))
			m:Scale(Vector(text.scale, text.scale, 1))
			m:Translate(Vector(-cx, -cy, 0))

			cam.PushModelMatrix(m)
			draw.SimpleTextOutlined( text.value, "UVFont5ShadowBig", cx, cy, Color(text.color.r, text.color.g, text.color.b, text.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,text.alpha) )
			cam.PopModelMatrix()
		end)
	end,

	onWrongWay = function(timestamp, isWrongWay)
		if isWrongWay then
			UV_UI.racing.prostreet.events.CenterNotification({
				text = UVString("uv.race.wrongway"),
				-- colorUpper = Color(200, 75, 75),
				immediate = true,
			})
		end
	end,
}