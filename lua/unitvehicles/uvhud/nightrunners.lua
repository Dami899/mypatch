UV.RegisterHUD( "nightrunners", "NIGHTRUNNERS" )

-- [[ Convars ]] --
-- Racing
CreateClientConVar("uvhud_nightrunners_race_raceramount", 3, true, false)
local maxracernrcv = GetConVar("uvhud_nightrunners_race_raceramount")

UVMenu.CustomizeHUD = UVMenu.CustomizeHUD or {}
UVMenu.CustomizeHUD.nightrunners = function()
	UVMenu.CurrentMenu = UVMenu:Open({
		Name = " ",
		Width  = UV.ScaleW(1200),
		Height = UV.ScaleH(760),
		DynamicHeight = true,
		Description = true,
		UnfocusClose = true,
		Tabs = {
			{ TabName = "uv.ui.custhud",
				{ type = "label", text = "NIGHTRUNNERS" },
				{ type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
					func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
				},
				{ type = "infosimple", text = "uv.ui.custhud.race" },
				{ type = "slider", text = "uv.ui.custhud.raceramount", desc = "uv.ui.custhud.raceramount.desc", convar = "uvhud_nightrunners_race_raceramount", min = 1, max = 4, decimals = 0 },
			},
		}
	})
end

UV_UI.racing.nightrunners = UV_UI.racing.nightrunners or {}

local function nightrunners_racing_main( ... )
    local w = ScrW()
    local h = ScrH()
    
    local my_vehicle = select(1, ...)
    local my_array = select(2, ...)
    local string_array = select(3, ...)
	local raw_array = select(4, ...)
    
    local racer_count = #string_array
    local lang = UVString
    
    local checkpoint_count = #my_array["Checkpoints"]
    
    ------------------------------------

	draw.SimpleText(NightRunners_FormatRaceTime( UVHUDRaceInfo.Info.Started and (CurTime() - UVHUDRaceInfo.Info.Time) or 0), "UVNightRunnersFont-Bigger", UV_UI.X(w * 0.05), h * 0.05, Color( 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5 )

	-- Positions
	draw.SimpleText(UVHUDRaceCurrentPos, "UVNightRunnersFont-Big", UV_UI.X(w * 0.07), h * 0.12, Color( 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.5 )
	draw.SimpleText(UVHUDRaceCurrentParticipants, "UVNightRunnersFont", UV_UI.X(w * 0.095), h * 0.13, Color( 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5 )
	
	local draw_index = 0
	local baseHeight = h * 0.13
	local meterOffset = UV.ScaleH(70)
	local meterSign = "+"

	for pos, v in ipairs(string_array) do
		local racer_name = v[1]
        local is_local_player = v[2]
        local mode = v[3]
        local diff = v[4]
		if is_local_player then meterSign = "-" continue end
		draw_index = draw_index + 1

		if draw_index > maxracernrcv:GetInt() then break end

		local racer_vehicle = raw_array[pos].vehicle

		local signalType = "0"
		local meterDist = 0
		local isDq = mode == 'Disqualified' or mode == 'Busted'

		if IsValid(racer_vehicle) then
			local distSqr = racer_vehicle:GetPos():DistToSqr(my_vehicle:GetPos())
			meterDist = math.floor( ( math.sqrt(distSqr) / ( 39.3701 * 0.5 ) ) + 0.5 )
			local calc = 550 / meterDist

			signalType = tostring( math.min ( math.floor( calc ), 4 ) )
			if meterDist > 450 or isDq then signalType = "0" end
		end

		local signalLost = meterDist >= 550 or isDq

		local height = baseHeight + ( draw_index * UV.ScaleH(120) )
		local textWidth = #racer_name

		draw.SimpleText(racer_name, "UVNightRunnersFont-Smaller", UV_UI.X(w * 0.05), height, Color( 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5 )
		draw.SimpleText(signalLost and "SIGNAL LOST" or meterSign .. " " .. meterDist .. "m", "UVNightRunnersFont-Small", UV_UI.X(w * 0.05), height + meterOffset, Color( 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5 )
		DrawIcon(UVMaterials["OPP_NR_SIGNAL_" .. signalType], UV_UI.X(w * 0.08) + (textWidth * UV.ScaleW(23)), height + UV.ScaleH(35), 0.05, Color( 255, 255, 255) )
	end

	-- Laps display
	local lapDisplayHeight = h * 0.2
	local needle = UV_UI.racing.nightrunners.states.LapDisplay
	if needle.Active then
		needle.__t = needle.__t + RealFrameTime()
		if needle.__t >= needle.BlipDuration then needle.__HIDDEN = not needle.__HIDDEN needle.__t = 0 end
		if needle.__HIDDEN and CurTime() - needle.StartTime >= needle.Duration then needle.Active = false needle.__HIDDEN = false needle.__t = 0 return end

		if not needle.__HIDDEN then
			if needle.IsFinalLap then
				draw.SimpleText( "FINAL LAP", "UVNightRunnersFont-BigNonItalic", UV_UI.X(w * 0.5), lapDisplayHeight + UV.ScaleH(45), Color( 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.5 )
			else
				draw.SimpleText( "NEW LAP", "UVNightRunnersFont-BigNonItalic", UV_UI.X(w * 0.5), lapDisplayHeight, Color( 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.5 )
				draw.SimpleText( needle.DisplayedLap .. " / " .. UVHUDRaceInfo.Info.Laps, "UVNightRunnersFont-BigNonItalic", UV_UI.X(w * 0.5), lapDisplayHeight + UV.ScaleH(90), Color( 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.5 )
			end
		end
	end

	-- Wipe out notice
	local NoticeDisplay = UV_UI.racing.nightrunners.states.NoticeDisplay
	if NoticeDisplay.Active then
		NoticeDisplay.__t = NoticeDisplay.__t + RealFrameTime()
		if NoticeDisplay.__t >= NoticeDisplay.Duration then NoticeDisplay.Active = false NoticeDisplay.__t = 0 end

		draw.SimpleText( NoticeDisplay.Text, "UVNightRunnersFontNonItalic", UV_UI.X(w * 0.5), h * 0.35, Color( 255, 255, 255, 255 * (NoticeDisplay.__t / 1.5)), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.5 )
	end
end

UV_UI.racing.nightrunners.main = nightrunners_racing_main

UV_UI.racing.nightrunners.states = {
    LapCompleteText = nil,
	LapDisplay = {
		-- public
		Active = false,
		StartTime = CurTime(),
		IsFinalLap = false,
		DisplayedLap = 0,
		Duration = 3,
		BlipDuration = 0.5,

		-- priv
		__t = 0,
		__HIDDEN = false,
	},
	NoticeDisplay = {
		Active = true,
		StartTime = CurTime(),
		Text = "",
		Duration = 5,

		-- private
		__t = 0,
	},
	RaceResultDisplay = {
		Active = true,
		StartTime = CurTime(),
	},
	notificationQueue = {},
	notificationActive = nil,
}

UV_UI.racing.nightrunners.events = {
	CenterNotification = function( params )
		local NoticeDisplay = UV_UI.racing.nightrunners.states.NoticeDisplay
		NoticeDisplay.Text = params.text
		NoticeDisplay.Active = true
		NoticeDisplay.StartTime = CurTime()
		NoticeDisplay.__t = 0
	end,

    ShowResults = function(sortedRacers)
		local h = ScrH()
		local w = ScrW()
		local lPlr = LocalPlayer()
		
		local resultPanel = vgui.Create("DFrame")

        resultPanel:SetSize(w, h)
        resultPanel:SetBackgroundBlur(true)
        resultPanel:ShowCloseButton(false)
        resultPanel:Center()
        resultPanel:SetTitle("")
        resultPanel:SetDraggable(false)
        resultPanel:SetKeyboardInputEnabled(false)

		resultPanel:SetVisible(true)
		resultPanel:MoveToFront()

		local maxPerPage = 3
		local currentPage = 1
		local maxPages = math.ceil( #sortedRacers / maxPerPage )
		local lang = UVString

		function resultPanel:OnMouseWheeled(delta)
			currentPage = math.Clamp( math.floor( currentPage - delta - 0.5 ), 1, maxPages )
			return true
		end

		function resultPanel:OnMouseReleased(CODE)
			if CODE == MOUSE_LEFT then
				resultPanel:Remove()
				gui.EnableScreenClicker(false)
			end
		end

		resultPanel.Paint = function(self, w, h)
			if lPlr:KeyPressed(IN_JUMP) then
				resultPanel:Remove()
				gui.EnableScreenClicker(false)
				return
			end

			resultPanel:RequestFocus()
			gui.EnableScreenClicker(true)
			draw.SimpleText( "RESULTS", "UVNightRunnersFont-Big", UV_UI.X(w * 0.5), h * 0.2, Color( 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

			local newLineIndex = 0
			
			for i = math.Clamp( ( currentPage - 1 ) * maxPerPage + 1, 1, math.huge ), currentPage * maxPerPage do
				newLineIndex = newLineIndex + 1
				local racer = sortedRacers[i]
				if not racer then break end
				draw.SimpleText( string.upper( lang("uv.race.pos.num." .. i) ), "UVNightRunnersFontNonItalic", UV_UI.X(w * 0.26), h * 0.3 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				draw.SimpleText( racer.array.Name, "UVNightRunnersFontNonItalic", UV_UI.X(w * 0.33), h * 0.3 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				local totalTime = racer.array.TotalTime and NightRunners_FormatRaceTime( racer.array.TotalTime ) or "DNF"
				draw.SimpleText( totalTime, "UVNightRunnersFontNonItalic", UV_UI.X(w * 0.73 ), h * 0.3 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
			end

			draw.SimpleText( currentPage .. " / " .. maxPages, "UVNightRunnersFontNonItalic", UV_UI.X(w * 0.5), h * 0.45 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			if currentPage > 1 then
				draw.SimpleText( "< ", "UVNightRunnersFontNonItalic", UV_UI.X(w * 0.45), h * 0.45 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			if currentPage < maxPages then
				draw.SimpleText( " >", "UVNightRunnersFontNonItalic", UV_UI.X(w * 0.55), h * 0.45 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
			end
			draw.SimpleText( "[SCROLL]: SWITCH PAGE", "UVNightRunnersFont-SmallNonItalic", UV_UI.X(w * 0.5), h * 0.53 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			draw.SimpleText( "[JUMP/MOUSELEFT]: CLOSE", "UVNightRunnersFont-SmallNonItalic", UV_UI.X(w * 0.5), h * 0.56 + (newLineIndex * UV.ScaleH(100)), Color( 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end
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
						UV_UI.racing.nightrunners.events.ShowResults(sortedRacers)
					end)
					return
				end
				UV_UI.racing.nightrunners.events.ShowResults(sortedRacers)
			end
		end)
	end,

	onParticipantDisqualified = function(data)
		local participant = data.Participant
		local is_local_player = data.is_local_player
		
		local info = UVHUDRaceInfo.Participants[participant]
		local name = info and info.Name or "Unknown"

		if not info then return end

		local disqtext = string.format("%s has been wiped out !", name)
		if is_local_player then disqtext = UVString("uv.chase.wrecked") end

		UV_UI.racing.nightrunners.events.CenterNotification({
			text = disqtext,
		})
	end,

	onLapSplit = function(participant, checkpoint, is_local_player, numParticipants)
	end,

	onRaceStartTimer = function(data)
	end,

	onWrongWay = function(timestamp, isWrongWay)
	end,
}