AddCSLuaFile()

MAX_HEAT_LEVEL = 10 -- You could theoretically change this :)

local dvd = DecentVehicleDestination

-- wait a few seconds :^)
timer.Simple(5, function()
	physenv.SetPerformanceSettings(
		{
			['MaxVelocity'] = 99999, ['MaxAngularVelocity'] = 99999
		}
	)
end)

--Sound--
local UVSoundSource
local UVSoundLoop
local UVSoundMiscSource
local UVLoadedSounds

local PURSUIT_MUSIC_FILEPATH = "uvpursuitmusic"

local showhud = GetConVar("cl_drawhud")

local SpawnCooldownTable = {}

UV_CurrentSubtitle = ""
UV_SubtitleEnd = 0
UV_CurrentSubtitleCallsign = ""

UVCounterActive = false -- Is the Race or Pursuit countdown active?
local ShouldArchive = (SERVER or game.SinglePlayer()) and FCVAR_ARCHIVE or nil

PT_Slots_Replacement_Strings = {
	[1] = "uv.ptech.slot.right",
	[2] = "uv.ptech.slot.left"
}

local Control_Strings = {
	[1] = "uv.ptech.slot.left",
	[2] = "uv.ptech.slot.right",
	[3] = "uv.keybind.skipsong",
	[4] = "uv.keybind.resetposition",
	[5] = "uv.keybind.showresults"
}

local Colors = {
	['Yellow'] = Color(255, 255, 0),
	['White'] = Color(255, 255, 255),
	['RacerTheme'] = Color(255, 221, 142, 107),
	['RacerThemeShade'] = Color(166, 142, 85, 107),
	['CopTheme'] = Color(61, 184, 255, 107),--Color(148, 142, 255, 107),
	['CopThemeShade'] = Color(41, 149, 212, 107)--Color(93, 85, 166, 107)
}

PursuitTable = {
	['InPursuit'] = false,
	['InCooldown'] = false,
	['IsEvading'] = false,
	['PursuitStart'] = 0,
	['Heat'] = 1,
	['UnitsChasing'] = 0,
	['ResourcePoints'] = 0,
	['Deploys'] = 0,
	['PursuitLength'] = 0,
	['Wrecks'] = 0,
	['Tags'] = 0,
	['Bounty'] = 0,
	['CommanderActive'] = false,
	['CommanderEntity'] = nil
	--['ChasedVehicles'] = {},
}

function UVGetVehicle(driver)
	if not IsValid(driver) then return false end
	
	local seat = driver:GetVehicle()
	if not IsValid(seat) then return false end
	
	if seat.IsSimfphyscar or seat:GetClass() == "prop_vehicle_jeep" then
		return seat
	else
		return seat:GetParent()
	end
	
end

function UVGetDriver(vehicle)
	if not IsValid(vehicle) then return nil end

	if vehicle.IsSimfphyscar or vehicle:GetClass() == "prop_vehicle_jeep" then
		return vehicle:GetDriver()
	elseif vehicle.IsGlideVehicle then
		if not vehicle.seats or next(vehicle.seats) == nil then return nil end

		local seat = vehicle.seats[1]

		if IsValid( seat ) then
			local driver = seat:GetDriver()
			return (IsValid(driver) and driver) or nil
		end
	end

	return nil
end

function UVGetDriverName(vehicle)
	local driver = UVGetDriver(vehicle)
    local driverName = IsValid(driver) and driver:GetName()

    if not driverName then
        driverName = (vehicle.UnitVehicle and vehicle.UnitVehicle.callsign) or vehicle.racer or 'Racer ' .. vehicle:EntIndex()
    end

	return driverName
end

--Sound spam check--

function UVDelaySound()
	if UVSoundDelayed then return end
	UVSoundDelayed = true
	timer.Simple(1, function()
		UVSoundDelayed = false
	end)
end

local PursuitFilePathsTable = {}

function PopulatePursuitFilePaths( theme )
	if PursuitFilePathsTable[theme] then return end
	PursuitFilePathsTable[theme] = {}

	local path = PURSUIT_MUSIC_FILEPATH .. "/" .. theme .. "/"
	
	local function scanFolderRecursive(basePath, tbl)
		local _, folders = file.Find( "sound/" .. basePath .. "*", "GAME")
		for _, folder in pairs(folders) do
			if folder ~= "." and folder ~= ".." then
				local subfolderPath = basePath .. folder .. "/"
				local files2, folders2 = file.Find("sound/" .. subfolderPath .. "*", "GAME")

				if not tbl[folder] then
					tbl[folder] = {}
				end

				if #folders2 == 0 then
					for _, v in pairs( files2 ) do
						table.insert(tbl[folder], subfolderPath .. v)
					end
				else
					for _, v in pairs( folders2 ) do
						tbl[folder][v] = {}
					end
				end

				-- for _, folderName in pairs(folders) do
				-- 	local filePath = subfolderPath .. fileName
				-- 	if not file.IsDir(filePath, "GAME") then
				-- 		table.insert(tbl[folder], filePath)
				-- 	end
				-- end

				-- Recursively scan subfolders
				scanFolderRecursive(subfolderPath, tbl[folder])
			end
		end
	end

	scanFolderRecursive(path, PursuitFilePathsTable[theme])
	-- local introFiles = file.Find(path .. "intro/*", "GAME")
	-- if introFiles and #introFiles > 0 then
	-- 	PursuitFilePathsTable[theme].intro = {}
	-- 	for _, v in ipairs(introFiles) do
	-- 		PursuitFilePathsTable[theme].intro[#PursuitFilePathsTable[theme].intro + 1] = path .. "intro/" .. v	
	-- 	end
	-- end

	-- local transitionFiles = file.Find(path .. "transition/*", "GAME")
	-- if transitionFiles and #transitionFiles > 0 then
	-- 	PursuitFilePathsTable[theme].transition = {}
	-- 	for _, v in ipairs(transitionFiles) do
	-- 		PursuitFilePathsTable[theme].transition[#PursuitFilePathsTable[theme].transition + 1] = path .. "transition/" .. v	
	-- 	end
	-- end

	-- local heatFiles = file.Find(path .. "heat/*", "GAME")
	-- if heatFiles and #heatFiles > 0 then
	-- 	PursuitFilePathsTable[theme].heat = {}
	-- 	for _, v in ipairs(heatFiles) do
	-- 		PursuitFilePathsTable[theme].heat[#PursuitFilePathsTable[theme].heat + 1] = path .. "heat/" .. v	
	-- 	end
	-- end

	-- local bustedFiles = file.Find(path .. "busted/*", "GAME")
	-- if bustedFiles and #bustedFiles > 0 then
	-- 	PursuitFilePathsTable[theme].busted = {}
	-- 	for _, v in ipairs(bustedFiles) do
	-- 		PursuitFilePathsTable[theme].busted[#PursuitFilePathsTable[theme].busted + 1] = path .. "busted/" .. v	
	-- 	end
	-- end

	-- local escapedFiles = file.Find(path .. "escaped/*", "GAME")
	-- if escapedFiles and #escapedFiles > 0 then
	-- 	PursuitFilePathsTable[theme].escaped = {}
	-- 	for _, v in ipairs(escapedFiles) do
	-- 		PursuitFilePathsTable[theme].escaped[#PursuitFilePathsTable[theme].escaped + 1] = path .. "escaped/" .. v	
	-- 	end
	-- end

	return PursuitFilePathsTable[theme]
end
--print("hhahahaha")

function UVSoundHeat(heatlevel)
	if not PlayMusic:GetBool() then return end
	if (not RacingMusicPriority:GetBool()) and RacingMusic:GetBool() and UVHUDDisplayRacing then return end
	if RacingThemeOutsideRace:GetBool() then UVSoundRacing() return end
	if UVPlayingHeat or UVSoundDelayed then return end

	if timer.Exists("UVPursuitThemeReplay") then
		timer.Remove("UVPursuitThemeReplay")
	end

	heatlevel = heatlevel or 1

	local _lastheatlevel = lastHeatlevel

	if PursuitThemePlayRandomHeat:GetBool() then
		if PursuitThemePlayRandomHeatType:GetString() == "everyminutes" then
			heatlevel = UVSelectedHeatTrack
			_lastheatlevel = UVLastHeatLevel or 1
		else
			heatlevel = math.random( 1, MAX_HEAT_LEVEL )
		end
	end

	if not lastHeatlevel then
		_lastheatlevel = heatlevel
	end

	heatlevel = tostring(heatlevel)
	_lastheatlevel = tostring(_lastheatlevel)

	local theme = PursuitTheme:GetString()

	local soundtable

	-- if UVHeatLevelIncrease then
	-- 	UVPlayingHeat = false
	-- 	soundtable = file.Find("sound/uvpursuitmusic/" .. theme .. "/transition/*", "GAME")

	-- 	-- Only play if folder exists and has sound files
	-- 	if soundtable and #soundtable > 0 then
	-- 		UVPlaySound("uvpursuitmusic/" .. theme .. "/transition/" .. soundtable[math.random(1, #soundtable)], false)
	-- 	end
	-- else
	-- 	UVPlayingHeat = true
	-- 	soundtable = file.Find("sound/uvpursuitmusic/" .. theme .. "/" .. heat .. "/*", "GAME")

	-- 	-- Fallback to heat1 if the desired heat folder is missing or empty
	-- 	if not soundtable or #soundtable == 0 then
	-- 		soundtable = file.Find("sound/uvpursuitmusic/" .. theme .. "/heat1/*", "GAME")
	-- 		if soundtable and #soundtable > 0 then
	-- 			UVPlaySound("uvpursuitmusic/" .. theme .. "/heat1/" .. soundtable[math.random(1, #soundtable)], true)
	-- 		end
	-- 	else
	-- 		UVPlaySound("uvpursuitmusic/" .. theme .. "/" .. heat .. "/" .. soundtable[math.random(1, #soundtable)], true)
	-- 	end
	-- end

	-- timer.Create("UVPursuitThemeRandom", 600, 0, function()
	-- 	if PursuitThemePlayRandomHeat:GetBool() then
	-- 		UVSoundHeat(math.random(1, MAX_HEAT_LEVEL))
	-- 	end
	-- end)

	if not PursuitFilePathsTable[theme] then
		PopulatePursuitFilePaths(theme)
		UVResetRandomHeatTrack()
	end

	if UVHeatLevelIncrease then
		UVHeatLevelIncrease = false
		UVHeatPlayTransition = true
		UVHeatPlayIntro = true
	end
	
	if UVHeatPlayTransition then
		UVHeatPlayTransition = false
		UVHeatPlayMusic = true
	--local transitionArray = (PursuitFilePathsTable[theme].transition and PursuitFilePathsTable[theme].transition[heatlevel]) or {}
		local transitionArray = PursuitFilePathsTable[theme].transition and (PursuitFilePathsTable[theme].transition[_lastheatlevel] or PursuitFilePathsTable[theme].transition["default"]) or {}

		if transitionArray and #transitionArray > 0 then
			table.Shuffle(transitionArray)
			local transitionTrack = transitionArray[1]

			if transitionTrack then
				UVPlaySound(transitionTrack, true)
				UVPlayingHeat = true
			end
		end

		if heatlevel ~= _lastheatlevel then
			lastHeatlevel = tonumber( heatlevel )
		end
	-- local transitionTrack = UVGetRandomSound( PURSUIT_MUSIC_FILEPATH .. "/" .. theme .. "/transition/" .. heatlevel )
	-- if transitionTrack then
	-- 	UVPlaySound(transitionTrack, true)
	-- 	UVPlayingHeat = true
	-- end
	elseif UVHeatPlayIntro then
		UVHeatPlayIntro = false
		UVHeatPlayMusic = true

		--local introArray = (PursuitFilePathsTable[theme].intro and PursuitFilePathsTable[theme].intro[heatlevel]) or {}
		local introArray = (PursuitFilePathsTable[theme].intro and (PursuitFilePathsTable[theme].intro[heatlevel] or PursuitFilePathsTable[theme].intro["default"]))

		if introArray and #introArray > 0 then
			table.Shuffle(introArray)
			local introTrack = introArray[1]

			if introTrack then
				UVPlaySound(introTrack, true)
				UVPlayingHeat = true
			end
		end

		-- local introTrack = UVGetRandomSound( PURSUIT_MUSIC_FILEPATH .. "/" .. theme .. "/intro/" .. heatlevel )
		-- if introTrack then
		-- 	UVPlaySound(introTrack, true)
		-- 	UVPlayingHeat = true
		-- end
	elseif UVHeatPlayMusic then
		-- local musicTrack = UVGetRandomSound( PURSUIT_MUSIC_FILEPATH .. "/" .. theme .. "/heat/" .. heatlevel ) or UVGetRandomSound( PURSUIT_MUSIC_FILEPATH .. "/" .. theme .. "/heat/5" )
		-- if musicTrack then
		-- 	UVPlaySound(musicTrack, true)
		-- 	UVPlayingHeat = true
		-- end

		--local heatArray = (PursuitFilePathsTable[theme].heat and PursuitFilePathsTable[theme].heat[heatlevel]) or {}
		local heatArray = PursuitFilePathsTable[theme].heat and (PursuitFilePathsTable[theme].heat[heatlevel] or PursuitFilePathsTable[theme].heat["default"]) or {}

		if heatArray and #heatArray > 0 then
			table.Shuffle(heatArray)
			local heatTrack = heatArray[1]

			if heatTrack then
				-- if PursuitThemePlayRandomHeat:GetBool() and PursuitThemePlayRandomHeatType:GetString() == "everyminutes" then
				-- 	UVHeatPlayTransition = true
				-- end
				UVPlaySound(heatTrack, true, false)
				UVPlayingHeat = true
			end
		end
	end

	UVPlayingRace = false
	-- UVPlayingHeat is handled above
	UVPlayingBusting = false
	UVPlayingCooldown = false
	UVPlayingBusted = false
	UVPlayingEscaped = false
end

function UVSoundBusting(heatlevel)
	if not PlayMusic:GetBool() then return end
	if (not RacingMusicPriority:GetBool()) and RacingMusic:GetBool() and UVHUDDisplayRacing then return end
	if RacingThemeOutsideRace:GetBool() then UVSoundRacing() return end	
	if UVPlayingBusting or UVSoundDelayed then return end

	if timer.Exists("UVPursuitThemeReplay") then
		timer.Remove("UVPursuitThemeReplay")
	end

	local theme = PursuitTheme:GetString()
	--local soundtable = file.Find("sound/uvpursuitmusic/" .. theme .. "/busting/*", "GAME")

	-- if not soundtable or #soundtable == 0 then UVSoundHeat( UVHeatLevel ) return end

	-- UVPlaySound("uvpursuitmusic/" .. theme .. "/busting/" .. soundtable[math.random(1, #soundtable)], true)

	heatlevel = heatlevel or 1

	if not PursuitFilePathsTable[theme] then
		PopulatePursuitFilePaths(theme)
		UVResetRandomHeatTrack()
	end

	if PursuitThemePlayRandomHeat:GetBool() then
		if PursuitThemePlayRandomHeatType:GetString() == "everyminutes" then
			heatlevel = UVSelectedHeatTrack
		else
			heatlevel = math.random( 1, MAX_HEAT_LEVEL )
		end
	end

	heatlevel = tostring(heatlevel)


	-- local bustingSound = UVGetRandomSound( PURSUIT_MUSIC_FILEPATH .. "/" .. theme .. "/busting/" .. heatlevel ) or UVGetRandomSound( PURSUIT_MUSIC_FILEPATH .. "/" .. theme .. "/busting/5" )
	-- if bustingSound then
	-- 	UVPlaySound(bustingSound, true)
	-- else
	-- 	UVSoundHeat( UVHeatLevel )
	-- 	return
	-- end
	
	--local bustingArray = (PursuitFilePathsTable[theme].busting and PursuitFilePathsTable[theme].busting[heatlevel]) or {}
	local bustingArray = PursuitFilePathsTable[theme].busting and (PursuitFilePathsTable[theme].busting[heatlevel] or PursuitFilePathsTable[theme].busting["default"]) or {}

	if bustingArray and #bustingArray > 0 then
		table.Shuffle(bustingArray)
		local bustingTrack = bustingArray[1]

		if bustingTrack then
			UVHeatPlayIntro = false
			UVHeatPlayTransition = false
			UVPlaySound(bustingTrack, true)
		else
			UVSoundHeat( UVHeatLevel )
			return
		end
	else
		UVSoundHeat( UVHeatLevel )
		return
	end

	UVPlayingRace = false
	UVPlayingHeat = false
	UVPlayingBusting = true
	UVPlayingCooldown = false
	UVPlayingBusted = false
	UVPlayingEscaped = false
end

function UVSoundCooldown(heatlevel)
	if not PlayMusic:GetBool() then return end
	if (not RacingMusicPriority:GetBool()) and RacingMusic:GetBool() and UVHUDDisplayRacing then return end
	if RacingThemeOutsideRace:GetBool() then UVSoundRacing() return end	
	if UVPlayingCooldown or UVSoundDelayed then return end

	if timer.Exists("UVPursuitThemeReplay") then
		timer.Remove("UVPursuitThemeReplay")
	end

	local theme = PursuitTheme:GetString()
	heatlevel = heatlevel or 1

	if not PursuitFilePathsTable[theme] then
		PopulatePursuitFilePaths(theme)
		UVResetRandomHeatTrack()
	end

	if PursuitThemePlayRandomHeat:GetBool() then
		if PursuitThemePlayRandomHeatType:GetString() == "everyminutes" then
			heatlevel = UVSelectedHeatTrack
		else
			heatlevel = math.random( 1, MAX_HEAT_LEVEL )
		end
	end

	heatlevel = tostring(heatlevel)

	local appendingString = "low"

	local vehicle = LocalPlayer():GetVehicle()
	if vehicle then
		vehicle = IsValid(vehicle:GetParent()) and vehicle:GetParent() or vehicle
	end
	local physObj = IsValid(vehicle:GetPhysicsObject()) and vehicle:GetPhysicsObject() or vehicle


	appendingString = (physObj and physObj:GetVelocity():LengthSqr() > 500000) and "high" or "low"

	local cooldownArray = PursuitFilePathsTable[theme].cooldown and (PursuitFilePathsTable[theme].cooldown[heatlevel] or PursuitFilePathsTable[theme].cooldown["default"])
	cooldownArray = cooldownArray and cooldownArray[appendingString or 'low'] or (cooldownArray and cooldownArray['default'] or {})

	if cooldownArray and #cooldownArray > 0 then
		table.Shuffle(cooldownArray)
		local cooldownTrack = cooldownArray[1]

		if cooldownTrack then
			UVPlaySound(cooldownTrack, true)
		else
			UVSoundHeat( UVHeatLevel )
			return
		end
	else
		UVSoundHeat( UVHeatLevel )
		return
	end

	UVPlayingRace = false
	UVPlayingHeat = false
	UVPlayingBusting = false
	UVPlayingCooldown = true
	UVPlayingBusted = false
	UVPlayingEscaped = false
end

function UVSoundBusted(heatlevel)
	if not PlayMusic:GetBool() then return end
	if UVPlayingBusted or UVSoundDelayed then return end

	if timer.Exists("UVPursuitThemeReplay") then
		timer.Remove("UVPursuitThemeReplay")
	end

	if UVSoundLoop then
		UVStopSound()
		UVLoadedSounds = nil
		UVSoundLoop:Stop()
		UVSoundLoop = nil
	end

	local theme = PursuitTheme:GetString()
	heatlevel = heatlevel or 1

	if PursuitThemePlayRandomHeat:GetBool() then
		if PursuitThemePlayRandomHeatType:GetString() == "everyminutes" then
			heatlevel = UVSelectedHeatTrack
		else
			heatlevel = math.random( 1, MAX_HEAT_LEVEL )
		end
	end

	heatlevel = tostring(heatlevel)

	if not PursuitFilePathsTable[theme] then
		PopulatePursuitFilePaths(theme)
		UVResetRandomHeatTrack()
	end

	local bustedArray = PursuitFilePathsTable[theme].busted and (PursuitFilePathsTable[theme].busted[heatlevel] or PursuitFilePathsTable[theme].busted["default"]) or {}

	if bustedArray and #bustedArray > 0 then
		table.Shuffle(bustedArray)
		local bustedTrack = bustedArray[1]

		if bustedTrack then
			UVPlaySound(bustedTrack, false, true, nil, true)
		else
			UVSoundHeat( UVHeatLevel )
			return
		end
	else
		return
	end

	UVPlayingRace = false
	UVPlayingHeat = false
	UVPlayingBusting = false
	UVPlayingCooldown = false
	UVPlayingBusted = true
	UVPlayingEscaped = true
end

function UVSoundEscaped(heatlevel)
	if not PlayMusic:GetBool() then return end
	if (not RacingMusicPriority:GetBool()) and RacingMusic:GetBool() and UVHUDDisplayRacing then return end
	if RacingThemeOutsideRace:GetBool() then UVSoundRacing() return end	
	if UVPlayingEscaped or UVSoundDelayed then return end

	if timer.Exists("UVPursuitThemeReplay") then
		timer.Remove("UVPursuitThemeReplay")
	end

	if UVSoundLoop then
		UVSoundLoop:Stop()
		UVSoundLoop = nil
	end

	local theme = PursuitTheme:GetString()
	heatlevel = heatlevel or 1

	if PursuitThemePlayRandomHeat:GetBool() then
		if PursuitThemePlayRandomHeatType:GetString() == "everyminutes" then
			heatlevel = UVSelectedHeatTrack
		else
			heatlevel = math.random( 1, MAX_HEAT_LEVEL )
		end
	end

	heatlevel = tostring(heatlevel)

	if not PursuitFilePathsTable[theme] then
		PopulatePursuitFilePaths(theme)
		UVResetRandomHeatTrack()
	end

	local escapedArray = PursuitFilePathsTable[theme].escaped and (PursuitFilePathsTable[theme].escaped[heatlevel] or PursuitFilePathsTable[theme].escaped["default"]) or {}

	if escapedArray and #escapedArray > 0 then
		table.Shuffle(escapedArray)
		local escapedTrack = escapedArray[1]

		if escapedTrack then
			UVPlaySound(escapedTrack, false)
		else
			UVSoundHeat( UVHeatLevel )
			return
		end
	else
		UVSoundHeat( UVHeatLevel )
		return
	end

	UVPlayingRace = false
	UVPlayingHeat = false
	UVPlayingBusting = false
	UVPlayingCooldown = false
	UVPlayingBusted = true
	UVPlayingEscaped = true
end
 
if CLIENT then
	cvars.RemoveChangeCallback("unitvehicle_pursuitthemevolume", "UV_PursuitVolumeChanged")
	cvars.AddChangeCallback("unitvehicle_pursuitthemevolume", function(convar, old, new)
		local vol = tonumber(new)
		if not vol then return end

		if IsValid(UVSoundLoop) then
			UVSoundLoop:SetVolume(vol)
		end

		if IsValid(UVSoundSource) then
			UVSoundSource:SetVolume(vol)
		end
	end, "UV_PursuitVolumeChanged")
end
 
function UVInitSound( src, loop, stoploop, timeout, applyMusicVolume )
	if not IsValid(src) then UVStopSound() return end

	if loop then
		UVSoundLoop = src
		src:SetVolume(PursuitVolume:GetFloat())
	else
		UVSoundSource = src
	end

	if applyMusicVolume then
		src:SetVolume(PursuitVolume:GetFloat())
	end

	src:EnableLooping(loop)
	src:Play()

	local duration = src:GetLength()

	if duration > 0 then
		expectedEndTime = RealTime() + duration + (timeout or 0)
	end

	UVLoadedSounds = src

	UVDelaySound()
	hook.Remove("Think", "CheckSoundFinished")
	
	hook.Add("Think", "CheckSoundFinished", function()
		if expectedEndTime then
			if RealTime() >= expectedEndTime then
				hook.Remove("Think", "CheckSoundFinished")
				UVStopSound()
			end
		end
	end)
end

function UVPlaySound( FileName, Loop, StopLoop, Timeout, applyMusicVolume, func )
	if UVLoadedSounds ~= FileName then
		if Loop or StopLoop then
			if UVSoundLoop then
				UVSoundLoop:Stop()
				UVSoundLoop = nil
			end
		else
			if UVSoundSource then
				UVSoundSource:Stop()
				UVSoundSource = nil
			end
		end
	end 

	local expectedEndTime

	UVDelaySound()

	if UVLoadedSounds ~= FileName or (not UVSoundLoop) then
		sound.PlayFile("sound/"..FileName, "noblock", function(source, err, errname)
			if func and source then func() end
			UVInitSound(source, Loop, StopLoop, Timeout, applyMusicVolume)
		end)
	end
end

function UVStopSound()
	UVPlayingRace = false
	UVPlayingHeat = false
	UVPlayingBusting = false
	UVPlayingCooldown = false
	UVPlayingBusted = false
	UVPlayingEscaped = false
	UVSoundDelayed = false
end

function UVDisplayTime(time)
	time = time or 0
	local formattedtime
	local hours = math.floor( time / 3600 )
	if hours < 1 then
		formattedtime = string.FormattedTime( time, "%02i:%02i.%02i" )
	else --1 hour pursuit challenge completed
		formattedtime = hours..":"..string.FormattedTime( time, "%02i:%02i.%02i" )
	end
	return formattedtime
end

HEAT_SETTINGS = {
	'bountytime',
	'timetillnextheat',
	'heatminimumbounty',
	'maxunits',
	'unitsavailable',
	'bustspeed',
	'backuptimer',
	'cooldowntimer',
	'roadblocks',
	'helicopters',
}

HEAT_DEFAULTS = {
	['maxunits'] = {
		['1'] = 2,
		['2'] = 4,
		['3'] = 6,
		['4'] = 8,
		['5'] = 10,
		['6'] = 10
	},
	['bountytime'] = {
		['1'] = 1000,
		['2'] = 5000,
		['3'] = 10000,
		['4'] = 50000,
		['5'] = 100000,
		['6'] = 500000
	},
	['timetillnextheat'] = {
		['Enabled'] = 0,
		['1'] = 120,
		['2'] = 120,
		['3'] = 180,
		['4'] = 180,
		['5'] = 240
	},
	['heatminimumbounty'] = {
		['1'] = 1000,
		['2'] = 10000,
		['3'] = 50000,
		['4'] = 250000,
		['5'] = 1000000,
		['6'] = 5000000,
	},
	['unitsavailable'] = {
		['1'] = 10,
		['2'] = 20,
		['3'] = 30,
		['4'] = 40,
		['5'] = 50,
		['6'] = 60,
	},
	['bustspeed'] = {
		['1'] = 10,
		['2'] = 10,
		['3'] = 15,
		['4'] = 15,
		['5'] = 20,
		['6'] = 20,
	},
	['backuptimer'] = {
		['1'] = 120,
		['2'] = 120,
		['3'] = 90,
		['4'] = 90,
		['5'] = 60,
		['6'] = 60,
	},
	['cooldowntimer'] = {
		['1'] = 20,
		['2'] = 40,
		['3'] = 60,
		['4'] = 80,
		['5'] = 100,
		['6'] = 120,
	},
	['roadblocks'] = {
		['1'] = 0,
		['2'] = 1,
		['3'] = 1,
		['4'] = 1,
		['5'] = 1,
		['6'] = 1,
	},
	['helicopters'] = {
		['1'] = 0,
		['2'] = 0,
		['3'] = 0,
		['4'] = 1,
		['5'] = 1,
		['6'] = 1,
	}
}

NETWORK_STRINGS = {
	"UV_SendPursuitTech"
}

-- ========================
-- Racer Pursuit Tech ConVars
-- ========================
-- PT Duration
UVPTPTDuration = CreateConVar("uvpursuittech_ptduration", 60, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

-- ESF
UVPTESFDuration = CreateConVar("uvpursuittech_esf_duration", 10, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTESFPower = CreateConVar("uvpursuittech_esf_power", 1000000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTESFDamage = CreateConVar("uvpursuittech_esf_damage", 0.2, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTESFCommanderDamage = CreateConVar("uvpursuittech_esf_damagecommander", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTESFMaxAmmo = CreateConVar("uvpursuittech_esf_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTESFCooldown = CreateConVar("uvpursuittech_esf_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- Jammer
UVPTJammerDuration = CreateConVar("uvpursuittech_jammer_duration", 10, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTJammerMaxAmmo = CreateConVar("uvpursuittech_jammer_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTJammerCooldown = CreateConVar("uvpursuittech_jammer_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- Shockwave
UVPTShockwavePower = CreateConVar("uvpursuittech_shockwave_power", 1000000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTShockwaveDamage = CreateConVar("uvpursuittech_shockwave_damage", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTShockwaveCommanderDamage = CreateConVar("uvpursuittech_shockwave_damagecommander", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTShockwaveMaxAmmo = CreateConVar("uvpursuittech_shockwave_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTShockwaveCooldown = CreateConVar("uvpursuittech_shockwave_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- Spike Strip
UVPTSpikeStripDuration = CreateConVar("uvpursuittech_spikestrip_duration", 60, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTSpikeStripMaxAmmo = CreateConVar("uvpursuittech_spikestrip_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTSpikeStripCooldown = CreateConVar("uvpursuittech_spikestrip_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- Stun Mine
UVPTStunMinePower = CreateConVar("uvpursuittech_stunmine_power", 1000000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTStunMineDamage = CreateConVar("uvpursuittech_stunmine_damage", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTStunMineCommanderDamage = CreateConVar("uvpursuittech_stunmine_damagecommander", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTStunMineMaxAmmo = CreateConVar("uvpursuittech_stunmine_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTStunMineCooldown = CreateConVar("uvpursuittech_stunmine_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- EMP
UVPTEMPDamage = CreateConVar("uvpursuittech_emp_damage", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTEMPForce = CreateConVar("uvpursuittech_emp_force", 100, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTEMPMaxAmmo = CreateConVar("uvpursuittech_emp_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTEMPCooldown = CreateConVar("uvpursuittech_emp_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")
UVPTEMPMaxDistance = CreateConVar("uvpursuittech_emp_maxdistance", 1000, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Distance")

-- Juggernaut
UVPTJuggernautDuration = CreateConVar("uvpursuittech_juggernaut_duration", 10, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTJuggernautMaxAmmo = CreateConVar("uvpursuittech_juggernaut_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTJuggernautCooldown = CreateConVar("uvpursuittech_juggernaut_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- Ghost
UVPTGhostDuration = CreateConVar("uvpursuittech_ghost_duration", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPTGhostMaxAmmo = CreateConVar("uvpursuittech_ghost_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTGhostCooldown = CreateConVar("uvpursuittech_ghost_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- RepairKit
UVPTRepairKitMaxAmmo = CreateConVar("uvpursuittech_repairkit_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTRepairKitCooldown = CreateConVar("uvpursuittech_repairkit_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- Powerplay
UVPTPowerPlayMaxAmmo = CreateConVar("uvpursuittech_powerplay_maxammo", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVPTPowerPlayCooldown = CreateConVar("uvpursuittech_powerplay_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- ========================
-- Unit Pursuit Tech ConVars
-- ========================
-- PT Duration
UVUnitPTDuration = CreateConVar("uvpursuittech_ptduration_unit", 20, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

-- ESF
UVUnitPTESFDuration = CreateConVar("uvpursuittech_esf_duration_unit", 10, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTESFPower = CreateConVar("uvpursuittech_esf_power_unit", 1000000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTESFDamage = CreateConVar("uvpursuittech_esf_damage_unit", 0.2, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTESFMaxAmmo = CreateConVar("uvpursuittech_esf_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Pursuit Tech Max Ammo")
UVUnitPTESFCooldown = CreateConVar("uvpursuittech_esf_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Pursuit Tech Cooldown")

-- Spike Strip
UVUnitPTSpikeStripDuration = CreateConVar("uvpursuittech_spikestrip_duration_unit", 60, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTSpikeStripMaxAmmo = CreateConVar("uvpursuittech_spikestrip_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Pursuit Tech Max Ammo")
UVUnitPTSpikeStripCooldown = CreateConVar("uvpursuittech_spikestrip_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Pursuit Tech Cooldown")
UVUnitPTSpikeStripRoadblockFriendlyFire = CreateConVar("unitvehicle_spikestriproadblockfriendlyfire",0,{FCVAR_ARCHIVE, FCVAR_REPLICATED})

-- KillSwitch
UVUnitPTKillSwitchLockOnTime = CreateConVar("uvpursuittech_killswitch_lockontime_unit", 3, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTKillSwitchDisableDuration = CreateConVar("uvpursuittech_killswitch_disableduration_unit", 2.5, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTKillSwitchMaxAmmo = CreateConVar("uvpursuittech_killswitch_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTKillSwitchCooldown = CreateConVar("uvpursuittech_killswitch_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

-- EMP
UVUnitPTEMPDamage = CreateConVar("uvpursuittech_emp_damage_unit", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTEMPForce = CreateConVar("uvpursuittech_emp_force_unit", 100, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTEMPMaxAmmo = CreateConVar("uvpursuittech_emp_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTEMPCooldown = CreateConVar("uvpursuittech_emp_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTEMPMaxDistance = CreateConVar("uvpursuittech_emp_maxdistance_unit", 1000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

-- RepairKit
UVUnitPTRepairKitMaxAmmo = CreateConVar("uvpursuittech_repairkit_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Max Ammo")
UVUnitPTRepairKitCooldown = CreateConVar("uvpursuittech_repairkit_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Pursuit Tech Cooldown")

-- ShockRam
UVUnitPTShockRamPower = CreateConVar("uvpursuittech_shockram_power_unit", 1000000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTShockRamDamage = CreateConVar("uvpursuittech_shockram_damage_unit", 0.1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTShockRamMaxAmmo = CreateConVar("uvpursuittech_shockram_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTShockRamCooldown = CreateConVar("uvpursuittech_shockram_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

-- GPS Dart
UVUnitPTGPSDartDuration = CreateConVar("uvpursuittech_gpsdart_duration_unit", 300, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTGPSDartMaxAmmo = CreateConVar("uvpursuittech_gpsdart_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTGPSDartCooldown = CreateConVar("uvpursuittech_gpsdart_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

-- Grappler
UVUnitPTGrapplerDuration = CreateConVar("uvpursuittech_grappler_duration_unit", 10, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTGrapplerDisableDuration = CreateConVar("uvpursuittech_grappler_disableduration_unit", 10, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTGrapplerLength = CreateConVar("uvpursuittech_grappler_length_unit", 1000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTGrapplerStrength = CreateConVar("uvpursuittech_grappler_strength_unit", 10000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTGrapplerMaxAmmo = CreateConVar("uvpursuittech_grappler_maxammo_unit", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUnitPTGrapplerCooldown = CreateConVar("uvpursuittech_grappler_cooldown_unit", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

HeatLevels = CreateConVar("unitvehicle_heatlevels", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If set to 1, Heat Levels will increase from its minimum value to its maximum value during a pursuit." )
DetectionRange = CreateConVar("unitvehicle_detectionrange", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Minimum spawning distance to the vehicle in studs when manually spawning Units. Use greater values if you have trouble spawning Units.")
NeverEvade = CreateConVar("unitvehicle_neverevade", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, you won't be able to evade the Unit Vehicles. Good luck.")
BustedTimer = CreateConVar("unitvehicle_bustedtimer", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Time in seconds before the enemy gets busted. Set this to 0 to disable.")
SpawnCooldown = CreateConVar("unitvehicle_spawncooldown", 30, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Time in seconds before player units can spawn again. Set this to 0 to disable.")
CanWreck = CreateConVar("unitvehicle_canwreck", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Unit Vehicles can crash out. Set this to 0 to disable.")
Chatter = CreateConVar("unitvehicle_chatter", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units' radio chatter can be heard.")
SpeedLimit = CreateConVar("unitvehicle_speedlimit", 60, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Speed limit in MPH for idle Units to enforce. Patrolling Units still enforces speed limits set on DV Waypoints. Set this to 0 to disable.")
AutoHealthRacer = CreateConVar("unitvehicle_autohealthracer", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, all racers will have unlimited vehicle health and your health as a racer will be set according to your vehicle's mass.")
AutoHealth = CreateConVar("unitvehicle_autohealth", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, all suspects will have unlimited vehicle health and your health as a suspect will be set according to your vehicle's mass.")
WheelsDetaching = CreateConVar("unitvehicle_wheelsdetaching", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, wrecked vehicles will have their wheels detached.")
MinHeatLevel = CreateConVar("unitvehicle_unit_minheat", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Sets the minimum Heat Level achievable during pursuits (1-6). Use high Heat Levels for more aggressive Units on your tail and vice versa.")
MaxHeatLevel = CreateConVar("unitvehicle_unit_maxheat", 6, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Sets the maximum Heat Level achievable during pursuits (1-6). Use low Heat Levels for less aggressive Units on your tail and vice versa.")
SpikeStripDuration = CreateConVar("unitvehicle_spikestripduration", 20, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicle: Time in seconds before the tires gets reinflated after hitting the spikes. Set this to 0 to disable reinflating tires.")
Pathfinding = CreateConVar("unitvehicle_pathfinding", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units uses A* pathfinding algorithm on navmesh/Decent Vehicle Waypoints to navigate. Impacts computer performance.")
VCModELSPriority = CreateConVar("unitvehicle_vcmodelspriority", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units using base HL2 vehicles will attempt to use VCMod ELS over Photon if both are installed.")
CallResponse = CreateConVar("unitvehicle_callresponse", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units will spawn and respond to the location regarding various calls.")
Headlights = CreateConVar("unitvehicle_enableheadlights", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: AI Vehicles will shine their headlights. 0 = Off, 1 = Automatic, 2 = Always on")
UseNitrousRacer = CreateConVar("unitvehicle_usenitrousracer", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Racer vehicles will use nitrous.")
UseNitrousUnit = CreateConVar("unitvehicle_usenitrousunit", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Unit vehicles will use nitrous.")
CustomizeRacer = CreateConVar("unitvehicle_customizeracer", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Randomizes color/skin/bodygroups when spawning AI Racers")
SpawnMainUnits = CreateConVar("unitvehicle_spawnmainunits", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, main AI Units (Patrol, Support, etc.) will spawn to patrol/chase.")
DVWaypointsPriority = CreateConVar("unitvehicle_dvwaypointspriority", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units will attempt to navigate on Decent Vehicle Waypoints FIRST instead of navmesh (if both are installed).")
DVWaypointsDistanceBased = CreateConVar("unitvehicle_dvwaypointsdistancebased", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units will use a distance-based approach to navigate on Decent Vehicle Waypoints. 0 = Direct engaging when suspect is in view, 1 = Navigate via waypoints if too far from suspect.")
RepairCooldown = CreateConVar("unitvehicle_repaircooldown", 60, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicle: Time in seconds between each repair. Set this to 0 to make all repair shops a one-time use.")
RepairRange = CreateConVar("unitvehicle_repairrange", 100, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicle: Distance in studs between the repair shop and the vehicle to repair.")
-- RacerTags = CreateConVar("unitvehicle_racertags", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Racers and Commander Units will have name tags above their vehicles.")
RacerPursuitTech = CreateConVar("unitvehicle_racerpursuittech", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Racers will spawn with pursuit tech (spike strips, ESF, etc.).")
RacerFriendlyFire = CreateConVar("unitvehicle_racerfriendlyfire", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Racers will be able to attack eachother with Pursuit Tech.")
OptimizeRespawn = CreateConVar("unitvehicle_optimizerespawn", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units will be teleported ahead of the suspect instead of despawning (does not work with simfphys).")
SpottedFreezeCam = CreateConVar("unitvehicle_spottedfreezecam", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, the game will freeze and the camera will point to the closest Unit when starting a pursuit (single-player only).")
RandomPlayerUnits = CreateConVar("unitvehicle_randomplayerunits", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, player-controlled Units will be chosen randomly from the available units.")
TractionControl = CreateConVar("unitvehicle_tractioncontrol", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Units and Racer Vehicles will apply reduced throttle when wheel spinning.")
CanExitVehicle = CreateConVar("unitvehicle_canexitvehicle", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, players can exit their vehicle during pursuits or races.")
UnitDifficulty = CreateConVar( "unitvehicle_unitdifficulty", 1.0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Increases Unit AI difficulty." )
UnitCatchup = CreateConVar( "unitvehicle_unitcatchup", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit AI catch-up." )

UVUCommanderEvade = CreateConVar("unitvehicle_unit_onecommanderevading", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If enabled, will allow racers to escape while commander is on scene.")
UVUOneCommander = CreateConVar("unitvehicle_unit_onecommander", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUOneCommanderHealth = CreateConVar("unitvehicle_unit_onecommanderhealth", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUCommanderRepair = CreateConVar("unitvehicle_unit_commanderrepair", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED},"Unit Vehicles: If set to 1, Commander Units can utilize the Repair Shop to repair themselves.")

UVUTimeTillNextHeatEnabled = CreateConVar("unitvehicle_unit_timetillnextheatenabled", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, Heat Levels will progress automatically based on the time until the next heat level.")

UVTVehicleBase = CreateConVar("unitvehicle_traffic_vehiclebase", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "\n1 = Default Vehicle Base (prop_vehicle_jeep)\n2 = simfphys\n3 = Glide")
UVTAssignTraffic = CreateConVar("unitvehicle_traffic_assigntraffic", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Spawns Traffic Vehicles only from the list. Otherwise, spawns a random Traffic Vehicle from the database.")
UVTSpawnCondition = CreateConVar("unitvehicle_traffic_spawncondition", 2, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "\n1) Never \n2) When driving \n3) Always")
UVTMaxTraffic = CreateConVar("unitvehicle_traffic_maxtraffic", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Max amount of Traffic Vehicles roaming.")
UVTTrafficVehicles = CreateConVar("unitvehicle_traffic_vehicles", "", {ShouldArchive}, "Assigned Traffic Vehicles (for override mode)")

--racer convars
UVRVehicleBase = CreateConVar("unitvehicle_racer_vehiclebase", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "\n1 = Default Vehicle Base (prop_vehicle_jeep)\n2 = simfphys\n3 = Glide")
UVRAssignRacers = CreateConVar("unitvehicle_racer_assignracers", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Spawns Racer Vehicles only from the list. Otherwise, spawns a random Racer Vehicle from the database.")
UVRRacers = CreateConVar("unitvehicle_racer_racers", "", {ShouldArchive}, "Assigned Racer Vehicles")
UVRSpawnCondition = CreateConVar("unitvehicle_racer_spawncondition", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "\n1) Never \n2) When driving \n3) Always")
UVRMaxRacer = CreateConVar("unitvehicle_racer_maxracer", 5, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Max amount of Racer Vehicles roaming.")

--unit convars
UVUVehicleBase = CreateConVar("unitvehicle_unit_vehiclebase", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "\n1 = Default Vehicle Base (prop_vehicle_jeep)\n2 = simfphys\n3 = Glide")

UVUPursuitTech = CreateConVar("unitvehicle_unit_pursuittech", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can use weapons (spike strips, ESF, EMP, etc.).")
UVUPursuitTech_ESF = CreateConVar("unitvehicle_unit_pursuittech_esf", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with ESF.")
UVUPursuitTech_EMP = CreateConVar("unitvehicle_unit_pursuittech_emp", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with EMP.")
UVUPursuitTech_Spikestrip = CreateConVar("unitvehicle_unit_pursuittech_spikestrip", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with spike strips.")
UVUPursuitTech_Killswitch = CreateConVar("unitvehicle_unit_pursuittech_killswitch", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with killswitch.")
UVUPursuitTech_RepairKit = CreateConVar("unitvehicle_unit_pursuittech_repairkit", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with repair kits.")
UVUPursuitTech_ShockRam = CreateConVar("unitvehicle_unit_pursuittech_shockram", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with shock rams.")
UVUPursuitTech_GPSDart = CreateConVar("unitvehicle_unit_pursuittech_gpsdart", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with gps darts.")
UVUPursuitTech_Grappler = CreateConVar("unitvehicle_unit_pursuittech_grappler", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: If set to 1, AI and player-controlled Unit Vehicles can spawn with gps darts.")

UVUHelicopterModel = CreateConVar("unitvehicle_unit_helicoptermodel", "Default", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Unit Vehicles: Helicopter model to use with Air Unit.")
UVUHelicopterBarrels = CreateConVar("unitvehicle_unit_helicopterbarrels", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "1 = Barrels\n0 = No Barrels")
UVUHelicopterSpikeStrip = CreateConVar("unitvehicle_unit_helicopterspikestrip", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "1 = Spike Strips\n0 = No Spike Strips")
UVUHelicopterBusting = CreateConVar("unitvehicle_unit_helicopterbusting", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "1 = Helicopter can bust racers\n0 = Helicopter cannot bust racers")

UVUBountyPatrol = CreateConVar("unitvehicle_unit_bountypatrol", 1000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUBountySupport = CreateConVar("unitvehicle_unit_bountysupport", 5000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUBountyPursuit = CreateConVar("unitvehicle_unit_bountypursuit", 10000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUBountyInterceptor = CreateConVar("unitvehicle_unit_bountyinterceptor", 20000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUBountyAir = CreateConVar("unitvehicle_unit_bountyair", 75000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUBountySpecial = CreateConVar("unitvehicle_unit_bountyspecial", 25000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUBountyCommander = CreateConVar("unitvehicle_unit_bountycommander", 100000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVUBountyRhino = CreateConVar("unitvehicle_unit_bountyrhino", 50000, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
	
local defaultvoicetable = {
	"cop1, cop2, cop3, cop4, cop5, cop6", --Patrol
	"cop1, cop2, cop3, cop4, cop5, cop6", --Support
	"cop1, cop2, cop3, cop4, cop5, cop6", --Pursuit
	"cop1, cop2, cop3, cop4, cop5, cop6", --Interceptor
	"cop1, cop2, cop3, cop4, cop5, cop6", --Special
	"cop1, cop2, cop3, cop4, cop5, cop6", --Commander
	"rhino1", --Rhino
	"air", --Air
}

local ReplicatedVars = {
	["unitvehicle_racer_racers"] = true,
	["unitvehicle_traffic_vehicles"] = true,
}

for index, v in pairs( {'Patrol', 'Support', 'Pursuit', 'Interceptor', 'Special', 'Commander', 'Rhino', 'Air'} ) do
	local lowercaseUnit = string.lower( v )

	ReplicatedVars["unitvehicle_unit_" .. lowercaseUnit .. "_voice"] = true
	ReplicatedVars["unitvehicle_unit_" .. lowercaseUnit .. "_voiceprofile"] = true

	CreateConVar( "unitvehicle_unit_" .. lowercaseUnit .. "_voice", defaultvoicetable[index], {ShouldArchive})
	CreateConVar( "unitvehicle_unit_" .. lowercaseUnit .. "_voiceprofile", "default", {ShouldArchive})
end

for _, v in pairs( {'Misc', 'Dispatch'} ) do
	local lowercaseType = string.lower( v )
	CreateConVar( "unitvehicle_unit_" .. lowercaseType .. "_voiceprofile", "", {FCVAR_ARCHIVE, FCVAR_REPLICATED})
end

for i = 1, MAX_HEAT_LEVEL do
	local prevIterator = i - 1

	local timeTillNextHeatId = ((prevIterator == 0 and 'enabled') or prevIterator)

	for _, v in pairs( {'Patrol', 'Support', 'Pursuit', 'Interceptor', 'Special', 'Commander', 'Rhino'} ) do
		local lowercaseUnit = string.lower( v )
		local conVarKey = string.format( 'units%s%s', lowercaseUnit, i )

		-------------------------------------------

		ReplicatedVars["unitvehicle_unit_" .. conVarKey] = true

		CreateConVar( "unitvehicle_unit_" .. conVarKey, "", {ShouldArchive})
		CreateConVar( "unitvehicle_unit_" .. conVarKey .. "_chance", 100, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
		CreateConVar( "unitvehicle_unit_" .. conVarKey .. "_limit", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
	end

	for _, conVar in pairs( HEAT_SETTINGS ) do
		local conVarKey = conVar .. ((conVar == 'timetillnextheat' and timeTillNextHeatId) or i)
		local check = (conVar == "timetillnextheat")

		CreateConVar( "unitvehicle_unit_" .. conVarKey, HEAT_DEFAULTS[conVar][tostring( ( check and timeTillNextHeatId ) or i )] or 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
	end
end

UVPBMax = CreateConVar("unitvehicle_pursuitbreaker_maxpb", 2, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVPBSpawnCondition = CreateConVar("unitvehicle_pursuitbreaker_spawncondition", 2, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "\n1) Never \n2) When driving \n3) Always")
UVPBCooldown = CreateConVar("unitvehicle_pursuitbreaker_pbcooldown", 60, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

UVRBMax = CreateConVar("unitvehicle_roadblock_maxrb", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
UVRBOverride = CreateConVar("unitvehicle_roadblock_override", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED})


if SERVER then

	--convars--
	--traffic convars

	--UVUVoiceProfile = CreateConVar("unitvehicle_unit_voiceprofile", "nfsmw", {FCVAR_ARCHIVE}, "Unit Vehicles: If set to 1, Units will use the voice profile assigned to them. If set to 0, Units will use a random voice profile.")

	

	--UVUTimeTillNextHeatEnabled = GetConVar('unitvehicle_unit_timetillnextheatenabled')

	unitvehicles = true

	UVHUDPursuit = nil
	UVHUDBusting = nil
	UVHUDCooldown = nil

	PursuitTable = {
		['InPursuit'] = false,
		['InCooldown'] = false,
		['IsEvading'] = false,
		['PursuitStart'] = 0,
		['Heat'] = 1,
		['UnitsChasing'] = 0,
		['ResourcePoints'] = 0,
		['Deploys'] = 0,
		['PursuitLength'] = 0,
		['Wrecks'] = 0,
		['Tags'] = 0,
		['Bounty'] = 0,
		['CommanderActive'] = false,
		['CommanderEntity'] = nil
		--['ChasedVehicles'] = {},
	}

	--Exiting the vehicle during pursuits or races
	hook.Add("CanExitVehicle", "UVExitingVehicleWhlistInPursuit", function( veh, ply)
		local vehicle_entity = veh:GetParent()

		if CanExitVehicle:GetBool() then return true end

		if UVTargeting then return false end
		if (IsValid(vehicle_entity) and vehicle_entity.uvraceparticipant) or veh.uvraceparticipant then return false end
	end)

	--Non-collision damage to prop_vehicle_jeep UVs
	hook.Add( "EntityTakeDamage", "UVDamage", function( target, dmginfo )
		if VC then return end
		if target.v and target.v:GetClass() == "prop_vehicle_jeep" and target.v.UnitVehicle then
			local damage = target:GetMaxHealth()*(dmginfo:GetDamage()*10)
			UVDamage(target.v, damage)
		end
	end )

	hook.Add("PostCleanupMap", "UVCleanup", function()
		UVTargeting = nil
		UVResetStats()
		UVPresenceMode = false
		UVCallLocation = nil
		uvcallexists = nil
		UVHiding = nil
		UVCommanderLastHealth = nil
		UVCommanderLastEngineHealth = nil
		UVCommanders = {}
		UVWantedTableDriver = {}
		UVPlayerUnitTablePlayers = {}
		UVJammerDeployed = nil
		UVPreInfractionCount = 0
		if next(UVLoadedPursuitBreakers) ~= nil then
			for k, v in pairs(UVLoadedPursuitBreakers) do
				net.Start("UVTriggerPursuitBreaker")
				net.WriteString(v)
				net.Broadcast()
			end
		end
		UVLoadedPursuitBreakers = {}
		UVLoadedPursuitBreakersLoc = {}
		UVLoadedRoadblocks = {}
		UVLoadedRoadblocksLoc = {}
		UVWreckedVehicles = {}
		net.Start( "UVHUDStopCopMode" )
		net.Broadcast()
	end)

	function UpdatePursuitTable( key, value )
		-- done so serialization works
		if value == nil then value = false end

		if PursuitTable[key] ~= value then
			PursuitTable[key] = value

			-- We will be using WriteData as it seems more performant and optimized

			local serializedJson = util.TableToJSON( {[key] = value} )
			local compressedJson = util.Compress( serializedJson )
			local messageSize = #compressedJson

			net.Start( "UVSet_PursuitTable" )
			net.WriteUInt( messageSize, 16 )
			net.WriteData( compressedJson, messageSize )
			net.Broadcast()
		end
	end

	UVHeliCooldown = -math.huge
	UVBustSpeed = 10
	UVCooldownTimer = 20
	UVCooldownTimerProgress = 0
	UVCooldownProgressTimeout = CurTime()
	UVBounty = 0
	UVHeatLevel = 1
	UVWrecks = 0
	UVDeploys = 0
	UVTags = 0
	UVRoadblocksDodged = 0
	UVSpikestripsDodged = 0
	UVComboBounty = 1
	UVBountyTimer = CurTime()
	UVBountyTime = 0
	UVBountyTimerProgress = 0
	UVBusting = CurTime()
	UVBustingProgress = CurTime()
	UVBustingLastProgress = CurTime()
	UVBustingLastProgress2 = 0
	UVLosing = CurTime()
	UVBackupTimer = CurTime()
	UVPreInfractionCount = 0
	UVPreInfractionCountCooldown = CurTime()
	UVUnitsChasing = {}
	UVWantedTableVehicle = {}
	UVWantedTableDriver = {}
	UVPotentialSuspects = {}
	UVResourcePoints = 10
	UVMaxUnits = 3
	UVTacticFormationNo = 1
	UVVehicleInitializing = {}
	UVPlayerUnitTableVehicle = {}
	UVPlayerUnitTablePlayers = {}
	UVCommanders = {}
	UVRVWithPursuitTech = {}
	UVLoadedPursuitBreakers = {}
	UVLoadedPursuitBreakersLoc = {}
	UVLoadedRoadblocks = {}
	UVLoadedRoadblocksLoc = {}
	UVWreckedVehicles = {}
	UVUnitVehicles = {}

	--Think
	hook.Add("Think", "UVServerThink", function()
		--One Commander Active
		if UVOneCommanderActive then
			if not UVCommanderRespawning and (UVUOneCommander:GetInt() ~= 1 or next(UVCommanders) == nil) then
				UVOneCommanderActive = nil
				UVCommanderLastHealth = nil
				UVCommanderLastEngineHealth = nil
				net.Start("UVHUDStopOneCommander")
				net.Broadcast()
			end
			for k, v in pairs(UVCommanders) do
				if not IsValid(v) then
					table.RemoveByValue(UVCommanders, v)
				end
			end
		end

		if UVUOneCommander:GetInt() == 1 and next(UVCommanders) ~= nil then
			UVOneCommanderActive = true
			net.Start("UVHUDOneCommander")
			net.WriteEntity(UVCommanders[1])
			net.Broadcast()
		end

		--Bounty
		if not UVTargeting then
			UVBountyTimer = CurTime()
			UVHiding = nil
			if UVOneCommanderDeployed then
				if not UVOneCommanderActive then
					UVOneCommanderDeployed = nil
				end
			end
			if UVCommanderRespawning then
				UVCommanderRespawning = nil
			end
			if UVCommanderLastHealth then
				UVCommanderLastHealth = nil
				UVCommanderLastEngineHealth = nil
			end
		else
			if not UVEnemyEscaping then
				UVBountyTimerProgress = CurTime() - UVBountyTimer
				UVHiding = nil
			else
				UVBountyTimer = CurTime() - UVBountyTimerProgress
			end
		end

		local botimeout = 10
		if not UVEnemyEscaping and UVBountyTimerProgress >= botimeout then
			UVBounty = UVBounty+UVBountyTime
			UVBountyTimer = CurTime()
		end

		local ltimeout = (UVCooldownTimer+5)

		--Wrecked vehicles
		if next(UVWreckedVehicles) ~= nil then
			for k, car in pairs(UVWreckedVehicles) do
				if not IsValid(car) then
					table.RemoveByValue(UVWreckedVehicles, car)
				end
			end
		end

		--Idle presence
		if not UVTargeting and (UVPresenceMode) and uvIdleSpawning - CurTime() + 5 <= 0 then
			HandleVehicleSpawning(true)
			uvIdleSpawning = CurTime()
		end

		--Deploying backup
		if not UVTargeting or UVEnemyBusted or UVEnemyEscaped then
			UVBackupTimer = CurTime()
		end

		local backupTimeout = 2

		if backupTimeout then
			if CurTime() > UVBackupTimer + backupTimeout then
				if HeatLevels:GetBool() then
					UVUpdateHeatLevel()
				end
				if #UVUnitsChasing < 2 then
					UVTacticFormationNo = math.random(0,6)
				end
				UVChangeTactics(UVTacticFormationNo)
				UVBackupTimer = CurTime()
			end
		end

		--Actual backup timer
		if UVTargeting then
			if UVResourcePoints < UVMaxUnits then
				if not UVBackupUnderway then
					UVResourcePointsTimer = CurTime()
					UVResourcePointsTimerMax = UVBackupTimerMax
					UVBackupUnderway = true
					timer.Simple(1, function()
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)
						local unit = units[random_entry]
						local uvchatter = math.random(1,10)
						if unit and Chatter:GetBool() then
							UVChatterBackupOnTheWay(unit)
						end
					end)
				else
					net.Start( "UVHUDBackuptimer" )
					net.WriteString(UVResourcePointsTimerLeft)
					net.Broadcast()
				end

				if not UVResourcePointsTimerMax then
					UVResourcePointsTimerMax = UVBackupTimerMax
				end

				UVResourcePointsTimerLeft = (UVResourcePointsTimer - CurTime() + UVResourcePointsTimerMax)
				if UVResourcePointsTimerLeft <= 10 then
					if not UVBackupTenSeconds then
						UVBackupTenSeconds = true
						--Entity(1):EmitSound("ui/pursuit/backup/countdown_start.wav", 0, 100, 0.5, CHAN_STATIC)
						--Entity(1):EmitSound("ui/pursuit/backup/countdown_tick.wav", 0, 100, 0.5, CHAN_STATIC)
						UVRelaySoundToClients("ui/pursuit/backup/countdown_start.wav", false)
						UVRelaySoundToClients("ui/pursuit/backup/countdown_tick.wav", false)
						timer.Create( "UVBackupTenSecondsTick", 1, 9, function() 
							--Entity(1):EmitSound("ui/pursuit/backup/countdown_tick.wav", 0, 100, 0.5, CHAN_STATIC)
							UVRelaySoundToClients("ui/pursuit/backup/countdown_tick.wav", false)
						end)
						for i=6,9 do
							timer.Simple( i + 1, function()
								if i == 9 then
									UVRelaySoundToClients("ui/pursuit/backup/countdown_end.wav", false)
								else
									UVRelaySoundToClients("ui/pursuit/backup/countdown_".. 9 - i ..".wav", false)
								end
							end)
						end
					end
				else
					if UVBackupTenSeconds then
						UVBackupTenSeconds = nil
					end
				end
				if UVResourcePointsTimerLeft <= 0 and UVBackupUnderway then
					net.Start( "UVHUDStopBackupTimer" )
					net.Broadcast()
					UVResourcePointsTimer = CurTime()
					UVRestoreResourcePoints()
					--PrintMessage( HUD_PRINTCENTER, "REINFORCEMENTS INCOMING!")
					if next(ents.FindByClass("npc_uv*")) ~= nil then
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)
						local unit = units[random_entry]
						local uvchatter = math.random(1,10)
						if Chatter:GetBool() then
							UVChatterBackupOnScene(unit)
						end
					end
				end
			else
				if UVBackupUnderway then
					UVBackupUnderway = nil
					-- net.Start( "UVHUDStopBackupTimer" )
					-- net.Broadcast()
				end
				UVResourcePointsTimer = CurTime()
				-- net.Start( "UVHUDStopBackupTimer" )
				-- net.Broadcast()
			end
		end

		--Check if busting/hiding
		if next(UVWantedTableVehicle) ~= nil then
			for k, v in pairs(UVWantedTableVehicle) do
				if not v.UVBustingProgress then
					v.UVBustingProgress = 0
				end

				if not v.UVBustingLastProgress then 
					v.UVBustingLastProgress = CurTime()
				end

				if not v.UVBustingLastProgress2 then 
					v.UVBustingLastProgress2 = CurTime()
				end

				UVCheckIfBeingBusted(v)
			end
			if #UVWantedTableVehicle == 1 and UVEnemyEscaping then
				UVHiding = UVCheckIfHiding(UVWantedTableVehicle[1])
			end
		end

		if next(UVPotentialSuspects) ~= nil then
			for k, v in pairs(UVPotentialSuspects) do
				if UVTargeting and not table.HasValue(UVWantedTableVehicle, v) then
					UVAddToWantedListVehicle(v)
				end
			end
		end

		if next(UVVehicleInitializing) ~= nil then
			for k, car in pairs(UVVehicleInitializing) do
				if IsValid(car) and ((isfunction(car.IsInitialized) and car:IsInitialized()) or car.IsGlideVehicle or car:GetClass() == "prop_vehicle_jeep") then
					if car.uvclasstospawnon == "npc_uvpatrol" then
						car.playerbounty = UVUBountyPatrol:GetInt()
					elseif car.uvclasstospawnon == "npc_uvsupport" then
						car.playerbounty = UVUBountySupport:GetInt()
					elseif car.uvclasstospawnon == "npc_uvpursuit" then
						car.playerbounty = UVUBountyPursuit:GetInt()
					elseif car.uvclasstospawnon == "npc_uvinterceptor" then
						car.playerbounty = UVUBountyInterceptor:GetInt()
					elseif car.uvclasstospawnon == "npc_uvspecial" then
						if car.rhino then
							car.playerbounty = UVUBountyRhino:GetInt()
						else
							car.playerbounty = UVUBountySpecial:GetInt()
						end
					elseif car.uvclasstospawnon == "npc_uvcommander" then
						car.playerbounty = UVUBountyCommander:GetInt()
						local health = car.uvlasthealth or UVUOneCommanderHealth:GetInt()
						local enginehealth = car.uvlastenginehealth or 1.0
						if car.IsSimfphyscar then
							car:SetCurHealth(health)
						elseif car.IsGlideVehicle then
							car.MaxChassisHealth = UVUOneCommanderHealth:GetInt()
							car:SetChassisHealth( health )
							car:SetEngineHealth( enginehealth )
							car:UpdateHealthOutputs()
						elseif car:GetClass() == "prop_vehicle_jeep" then
							if vcmod_main then
								car:VC_setHealthMax(UVUOneCommanderHealth:GetInt())
								car:VC_setHealth(health)
							else
								car:SetMaxHealth(UVUOneCommanderHealth:GetInt())
								car:SetHealth(health)
							end
						end
						table.insert(UVCommanders, car)
						UVCommanderRespawning = nil
					end
					if not car.UnitVehicle then 
						local uv = ents.Create(car.uvclasstospawnon) 
						uv:SetPos(car:GetPos())
						uv.uvscripted = true
						uv.vehicle = car
						uv:Spawn()
						uv:Activate()
					else
						car.UnitVehicle.uvplayerlastvehicle = car
						if car.IsSimfphyscar then
							car.UnitVehicle:EnterVehicle( car.DriverSeat )
						elseif car.IsGlideVehicle then
							local seat = car.seats[1]
							if IsValid(seat) then
								car.UnitVehicle:EnterVehicle(seat)
							end
						elseif car:GetClass() == "prop_vehicle_jeep" then
							car.UnitVehicle:EnterVehicle(car)
						end
					end
					table.RemoveByValue(UVVehicleInitializing, car)
				end
			end
		end

		local playerUnitActive = false

		--Player-controlled Unit Vehicles
		if next(UVPlayerUnitTableVehicle) ~= nil then
			for k, car in pairs(UVPlayerUnitTableVehicle) do

				if not table.HasValue(UVUnitVehicles, car) and car.UnitVehicle then
					table.insert(UVUnitVehicles, car)
				end
				
				if IsValid(car) and not car.wrecked and
					(car:Health() <= 0 and car:GetClass() == "prop_vehicle_jeep" or --No health 
						car.uvclasstospawnon ~= "npc_uvcommander" and CanWreck:GetBool() and car:GetPhysicsObject():GetAngles().z > 90 and car:GetPhysicsObject():GetAngles().z < 270 and car.rammed --[[or car:GetVelocity():LengthSqr() < 10000)]] or --Flipped
						car:WaterLevel() > 2 or --Underwater
						car:IsOnFire() or --On fire
						UVPlayerIsWrecked(car)) then --Other parameters
					UVPlayerWreck(car)
				end

				if UVGetDriver(car) and UVGetDriver(car):IsPlayer() then
					local driver = UVGetDriver(car)
					if car.PursuitTech then
						-- local status = car.PursuitTechStatus or "Ready"
						-- net.Start( "UVHUDPursuitTech" )
						-- net.WriteString(car.PursuitTech)
						-- net.WriteString(status)
						-- net.Send(driver)
						-- net.Start("UVHUDPursuitTech")
						-- net.WriteTable(car.PursuitTech)
						-- net.Broadcast()
					end

					playerUnitActive = true

					if not table.HasValue(UVPlayerUnitTablePlayers, driver) then
						table.insert(UVPlayerUnitTablePlayers, driver)
						driver.uvplayerlastvehicle = car
						hook.Add("CanExitVehicle", "UVPlayerExitUnitVehicle", function(vehicle, driver)
							if UVTargeting then return end
							if table.HasValue(UVPlayerUnitTablePlayers, driver) then
								table.RemoveByValue(UVPlayerUnitTablePlayers, driver)
								hook.Remove( "simfphysOnDestroyed", "UVExplosion"..car:EntIndex())
								UVDeactivateESF(car)
								net.Start( "UVHUDStopCopMode" )
								net.Send(driver)
							end
						end)
						hook.Add("PostPlayerDeath", "UVPlayerKilled", function(driver)
							if table.HasValue(UVPlayerUnitTablePlayers, driver) then
								table.RemoveByValue(UVPlayerUnitTablePlayers, driver)
								hook.Remove( "simfphysOnDestroyed", "UVExplosion"..car:EntIndex())
								UVDeactivateESF(car)
								net.Start( "UVHUDStopCopMode" )
								net.Send(driver)
							end
						end)
						hook.Add( "simfphysOnDestroyed", "UVExplosion"..car:EntIndex(), function(car, gib) 
							if table.HasValue(UVPlayerUnitTablePlayers, driver) then
								table.RemoveByValue(UVPlayerUnitTablePlayers, driver)
								hook.Remove( "simfphysOnDestroyed", "UVExplosion"..car:EntIndex())
								UVDeactivateESF(car)
								net.Start( "UVHUDStopCopMode" )
								net.Send(driver)
							end
							if (not car.UnitVehicle) or car.wrecked then return end
							if car.UnitVehicle:IsPlayer() then
								UVPlayerWreck(car)
							end
						end)
						net.Start( "UVHUDCopMode" )
						net.Send(driver)
					end
				end

				if car.uvkillswitching then
					UVKillSwitchCheck(car)
				end

				local suspects = UVWantedTableVehicle
				local closestsuspect = nil
				local closestdistancetosuspect = math.huge

				local visualrange = UVHiding and 1000000 or 25000000
				local visible_suspects = visible_suspects or {}

				for _, w in pairs(suspects) do
					if IsValid(w) then
						local enemypos = w:WorldSpaceCenter()
						local distance = enemypos:DistToSqr(car:WorldSpaceCenter())

						if distance < closestdistancetosuspect then
							closestdistancetosuspect = distance
							closestsuspect = w
						end

						local last_visible = w.inunitview or false
						local in_view = w.gpsdarttagged and next(w.gpsdarttagged) ~= nil or UVVisualOnTarget(car, w) and (car.uvplayerdistancetoenemy or math.huge) < visualrange

						w.inunitview = in_view
						if in_view then
							if not table.HasValue(visible_suspects, w) then
								table.insert(visible_suspects, w)
							end
						else
							if table.HasValue(visible_suspects, w) then
								table.RemoveByValue(visible_suspects, w)
							end
						end

						if last_visible ~= w.inunitview then
							net.Start("UVUpdateSuspectVisibility")
							net.WriteEntity(w)
							net.WriteBool(w.inunitview)
							net.Broadcast()
						end
					end
				end

				if IsValid(closestsuspect) then
					local is_vehicle =
						closestsuspect.IsSimfphyscar or
						closestsuspect.IsGlideVehicle or
						closestsuspect:GetClass() == "prop_vehicle_jeep"

					if is_vehicle then
						if not IsValid(car.e) or car.e ~= closestsuspect then
							car.e = closestsuspect
							UVAddToWantedListVehicle(closestsuspect)
						end

						car.uvplayerdistancetoenemy = closestdistancetosuspect
					end
				end

				-- Tracking logic for chasing units
				if IsValid(car.e) and car.uvplayerdistancetoenemy then
					local in_view = UVVisualOnTarget(car, car.e) and car.uvplayerdistancetoenemy < visualrange

					if in_view then
						UVLosing = CurTime()
						if not table.HasValue(UVUnitsChasing, car) then
							table.insert(UVUnitsChasing, car)
						end
					else
						if table.HasValue(UVUnitsChasing, car) then
							table.RemoveByValue(UVUnitsChasing, car)
						end
					end
				else
					if table.HasValue(UVUnitsChasing, car) then
						table.RemoveByValue(UVUnitsChasing, car)
					end
				end
			end
		end

		UVUnitsHavePlayers = playerUnitActive

		if next(ents.FindByClass("npc_uv*")) ~= nil then
			for k, unit in pairs(ents.FindByClass("npc_uv*")) do
				if not unit.v then return end
				if not table.HasValue(UVUnitVehicles, unit.v) then
					table.insert(UVUnitVehicles, unit.v)
				end
			end
		end

		local visible_suspects = {}

		if next(UVUnitVehicles) ~= nil or (UVTargeting and not UVEnemyEscaping) then
			local newUnits = {}
			for k, unit in pairs(UVUnitVehicles) do
				if IsValid(unit) and unit.UnitVehicle then
					table.insert(newUnits, unit)
				end
			end
			UVUnitVehicles = newUnits
			
			if next(UVWantedTableVehicle) ~= nil then
				for _, v in pairs(UVWantedTableVehicle) do
					local last_visible_value = v.inunitview

					local visualrange = 25000000
					if UVHiding then
						visualrange = 1000000
					end

					local check = false

					for _, j in pairs(ents.FindByClass("uvair")) do
						if (not (j.Downed and j.disengaging and j.crashing)) and j:GetTarget() == v then
							v.inunitview = true
							check = true
							table.insert(visible_suspects, v)
						end
					end

					if not check then
						for _, unit in pairs(UVUnitVehicles) do
								if UVVisualOnTarget(unit, v) then
									v.inunitview = true
									table.insert(visible_suspects, v)
								else
									if not table.HasValue(visible_suspects, v) then
										v.inunitview = false 
									end
								end
						end
					end

					if v.gpsdarttagged and next(v.gpsdarttagged) ~= nil then
						v.inunitview = true
					end

					v._lastVisibilityChange = v._lastVisibilityChange or 0
					local now = CurTime()

					if last_visible_value ~= v.inunitview then
						v._lastVisibilityChange = now

						net.Start("UVUpdateSuspectVisibility")
						net.WriteEntity(v)
						net.WriteBool(v.inunitview)
						net.Broadcast()
					end
				end
			end
		end

		--Idle chatter
		if #ents.FindByClass("npc_uv*") > 0 and not UVTargeting then
			if not (timer.Exists("uvidletalk")) then
				timer.Create("uvidletalk", 10, 0, function()
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)
					local unit = units[random_entry]
					local uvchatter = math.random(1,10)
					if Chatter:GetBool() then
						if uvchatter == 1 then
							UVChatterDispatchIdleTalk(unit)
						elseif uvchatter == 2 then
							UVChatterIdleTalk(unit)
						end
					end
				end)
			end
		else
			if timer.Exists("uvidletalk") then
				timer.Remove("uvidletalk")
			end
		end

		-- if UVTargeting then
		-- 	if not UVTimer then
		-- 		UVTimer = CurTime()
		-- 	end
		-- end

		--Losing		
		local ltimeout = (UVCooldownTimer+5)

		if UVHUDPursuit then
			net.Start("UVHUDEvading")
			net.WriteString(math.Clamp((CurTime() - UVLosing) / 5, 0, 1))
			net.Broadcast()
		end

		if not UVEnemyEscaped and UVTargeting and UVLosing ~= CurTime() and (UVLosing - CurTime() + ltimeout) < (ltimeout - 5) and #UVWantedTableVehicle > 0 then
			if not UVEnemyEscaping then
				UVEnemyEscaping = true
				UVCooldownProgressTimeout = CurTime()
				if timer.Exists("UVTimeTillNextHeat") then
					timer.Pause("UVTimeTillNextHeat")
				end
				if Chatter:GetBool() and not UVCalm and not UVEnemyBusted then
					if next(ents.FindByClass("npc_uv*")) ~= nil then
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)	
						local unit = units[random_entry]
						UVChatterLosing(unit)
						timer.Simple(math.random(10,20), function()
							if UVEnemyEscaping then
								UVChatterLosingUpdate(unit) 
							end
						end)
					end
				end
				--Entity(1):EmitSound("ui/pursuit/escaping.wav", 0, 100, 0.5)
				UVRelaySoundToClients("ui/pursuit/escaping.wav", false)
			end
			if UVEnemyEscaping then
				local cooldowntimer = UVCooldownTimer
				if UVHiding then
					cooldowntimer = cooldowntimer/4
				end
				local cooldownprogresstick = 0.01
				local cooldownprogress = ((1/cooldowntimer)*cooldownprogresstick)
				if CurTime() > UVCooldownProgressTimeout + cooldownprogresstick then
					UVCooldownTimerProgress = UVCooldownTimerProgress+cooldownprogress
					UVCooldownProgressTimeout = CurTime()
				end 
			end
		else
			if UVEnemyEscaping and not UVEnemyEscaped and not UVEnemyBusted then
				UVEnemyEscaping = nil
				UVCooldownTimerProgress = 0
				if timer.Exists("UVTimeTillNextHeat") then
					timer.UnPause("UVTimeTillNextHeat")
				end
				if UVTargeting then 
					--Entity(1):EmitSound("ui/pursuit/resume.wav", 0, 100, 0.5)
					UVRelaySoundToClients("ui/pursuit/resume.wav", false)
				end
				local function ChatterChopperUnavailable()
					if next(ents.FindByClass("npc_uv*")) ~= nil then
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)	
						local unit = units[random_entry]
						UVChatterFoundEnemy(unit)
					end
				end
				if Chatter:GetBool() and not UVCalm and not UVEnemyBusted then
					local airUnits = ents.FindByClass("uvair")
					if next(airUnits) ~= nil then
						local random_entry = math.random(#airUnits)	
						local unit = airUnits[random_entry]
						if not (unit.crashing or unit.disengaging) then
							UVChatterFoundEnemy(unit)
						else
							ChatterChopperUnavailable()
						end
					else
						ChatterChopperUnavailable()
					end
				end
			end
		end

		--Call off the pursuit.
		if UVTargeting and not UVEnemyEscaped and UVCooldownTimer then
			if UVCooldownTimerProgress >= 1 then
				UVCooldownTimerProgress = 0
				UVTargeting = nil
				UVEnemyEscaped = true
				timer.Simple(10, function() if UVEnemyEscaped then UVEnemyEscaped = nil end end)
				for k, v in pairs(ents.FindByClass("npc_uv*")) do
					v:ForgetEnemy()
				end
				for k, v in pairs(player.GetAll()) do
					v:SetHealth(100)
					v:SetMaxHealth(100)
					if v:InVehicle() then
						local car = v:GetVehicle()
						if car:GetClass() == "prop_vehicle_jeep" and vcmod_main then
							car:VC_repairFull_Admin()
							if car:VC_hasGodMode() then
								car:VC_setGodMode(false)
							end
						elseif car.IsSimfphyscar then
							if car.simfphysoldhealth then
								car:SetMaxHealth(car.simfphysoldhealth)
								car:SetCurHealth(car.simfphysoldhealth)
								car.simfphysoldhealth = nil
							end
							if istable(car.Wheels) then
								for i = 1, table.Count( car.Wheels ) do
									local Wheel = car.Wheels[ i ]
									if IsValid(Wheel) then
										Wheel:SetDamaged( false )
										Wheel.UVTireDeflatable = nil
									end
								end
							end
						end
					end
				end
				for k, v in pairs(ents.FindByClass("uvair")) do
					v.disengaging = true 
				end
				if #ents.FindByClass("npc_uv*") > 0 then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if Chatter:GetBool() then
						UVChatterLost(unit) 
					end
				end
				--Entity(1):EmitSound("ui/pursuit/escaped.wav")
				UVRelaySoundToClients("ui/pursuit/escaped.wav", false)
			end

		end

		--Never evade option
		if (NeverEvade:GetBool() and UVTargeting) or (((not UVUCommanderEvade:GetBool()) and UVOneCommanderActive) and not UVEnemyEscaping) then
			UVLosing = CurTime()
		end

		if CurTime() > (uv_next_racer_name_check or 0) then 
			uv_next_racer_name_check = CurTime() + 5

			for _, v in pairs(UVWantedTableVehicle) do
				if v.racer then
					net.Start( "UVUpdateRacerName" )
					net.WriteEntity( v )
					net.WriteString( v.racer )
					net.Broadcast()
				end
			end
		end

		UpdatePursuitTable( 'InPursuit', UVTargeting )
		UpdatePursuitTable( 'Heat', UVHeatLevel )
		UpdatePursuitTable( 'UnitsChasing', #UVUnitsChasing )
		UpdatePursuitTable( 'ResourcePoints', UVResourcePoints )
		UpdatePursuitTable( 'Deploys', UVDeploys )
		UpdatePursuitTable( 'Wrecks', UVWrecks )
		UpdatePursuitTable( 'Tags', UVTags )
		UpdatePursuitTable( 'Bounty', UVBounty )

		--SPOTTED CAMERA
		local FREEZE_DURATION = 2.7

		if game.SinglePlayer() and SpottedFreezeCam:GetBool() then
			local ply = Entity(1)

			if ply.isUVFrozen and RealTime() >= ply.isUVFreezeTime then
        	    net.Start("UVSpottedUnfreeze")
        	    net.Send(ply)

        	    ply.isUVFrozen = nil
				--ply:Freeze(false)

				-- if IsValid(ply.UVLastVehicleDriven) then
				-- 	if ply.UVLastVehicleDriven.IsSimfphyscar then
				-- 		ply:EnterVehicle( ply.UVLastVehicleDriven.DriverSeat )
				-- 	elseif ply.UVLastVehicleDriven.IsGlideVehicle then
				-- 		local seat = ply.UVLastVehicleDriven.seats[1]
				-- 		if IsValid(seat) then
				-- 			ply:EnterVehicle(seat)
				-- 		end
				-- 	elseif ply.UVLastVehicleDriven:GetClass() == "prop_vehicle_jeep" then
				-- 		ply:EnterVehicle(ply.UVLastVehicleDriven)
				-- 	end
				-- end

        	    game.SetTimeScale(1.0)
				CF_CanSetTimeScale = true
        	end
		end

		--HUD Triggers
		if UVTargeting then

			if not UVHUDPursuit then
				UVLosing = CurTime()
				UVRestoreResourcePoints()
				for _, ent in ents.Iterator() do
					if UVPassConVarFilter(ent) then
						UVAddToWantedListVehicle(ent)
					end
				end
				if timer.Exists("UVTimeTillNextHeat") then
					timer.UnPause("UVTimeTillNextHeat")
				end

				local function StartPursuitSound()
					if UVHeatLevel <= 3 then
						UVRelaySoundToClients("ui/pursuit/start.wav", false)
					else
						UVRelaySoundToClients("ui/pursuit/start_wanted_level_high.wav", false)
					end
				end

				if game.SinglePlayer() and SpottedFreezeCam:GetBool() then --SPOTTED CAMERA
					local ply = Entity(1)

					local closestunit
					local closestdistancetounit

					local units = ents.FindByClass("npc_uv*")
					local airUnits = ents.FindByClass("uvair")
					local playerUnits = UVPlayerUnitTableVehicle

					table.Add( units, airUnits )
					table.Add( units, playerUnits )

					local r = math.huge
					local closestdistancetounit, closestunit = r^2

					for i, w in pairs(units) do
						local plypos = ply:WorldSpaceCenter()
						local distance = plypos:DistToSqr(w:WorldSpaceCenter())
						if distance < closestdistancetounit and UVStraightToWaypoint(plypos, w:WorldSpaceCenter()) then
							if w:GetClass() ~= 'uvair' then
								closestdistancetounit, closestunit = distance, w.v
							else
								closestdistancetounit, closestunit = distance, w
							end
						end
					end

					if closestunit then
						ply.isUVFrozen = true
                    	ply.isUVFreezeTime = RealTime() + FREEZE_DURATION

						-- if IsValid(UVGetVehicle(ply)) then
						-- 	ply.UVLastVehicleDriven = UVGetVehicle(ply)
						-- 	ply:ExitVehicle()
						-- end
					
						--ply:Freeze(true)
                    	net.Start("UVSpottedFreeze")
                    	net.WriteFloat(FREEZE_DURATION)
                    	net.WriteEntity(closestunit)
                    	net.Send(ply)
						CF_CanSetTimeScale = false
                    	game.SetTimeScale(0.001) --Source dosen't like it if you set it to 0


						UVRelaySoundToClients("ui/pursuit/spottedfreezecam.wav", false)
					else
						StartPursuitSound()
					end
				else
					StartPursuitSound()
				end
			end

			if not UVHUDPursuit then
				UpdatePursuitTable( 'PursuitStart', CurTime() )
				UVHUDScreenFlashStartTime = CurTime()
			end

			UVHUDPursuit = true

			if timer.Exists("UVTimeTillNextHeat") then
				if not _last_timed_heat_update then _last_timed_heat_update = 0 end				
				if timer.TimeLeft("UVTimeTillNextHeat") >= 0 and CurTime() - _last_timed_heat_update > 1 then
					net.Start( "UVHUDTimeTillNextHeat" )
					net.WriteFloat( timer.TimeLeft("UVTimeTillNextHeat") )
					net.Broadcast()
				end
			elseif UVUTimeTillNextHeatEnabled:GetInt() == 1 then
				local TimeTillNextHeat = 120

				local timeTillNextHeatConVar = GetConVar( 'unitvehicle_unit_timetillnextheat' .. UVHeatLevel )

				if timeTillNextHeatConVar then
					TimeTillNextHeat = timeTillNextHeatConVar and timeTillNextHeatConVar:GetInt() or 0

					timer.Create( "UVTimeTillNextHeat", TimeTillNextHeat, 0, function()
						if UVUTimeTillNextHeatEnabled:GetInt() ~= 1 then
							timer.Remove( "UVTimeTillNextHeat" )
							return
						end

						local nextHeat = UVHeatLevel + 1
						local timeTillNextHeatNew = GetConVar( 'unitvehicle_unit_timetillnextheat' .. nextHeat ) or TimeTillNextHeat

						if nextHeat <= MaxHeatLevel:GetInt() then
							UVHeatLevel = nextHeat

							timer.Adjust("UVTimeTillNextHeat", (isnumber(timeTillNextHeatNew) and timeTillNextHeatNew or timeTillNextHeatNew:GetInt()), 0)

							UVUpdateHeatLevel(nextHeat)
							TriggerHeatLevelEffects(nextHeat)
						end
					end )
				end
			end

		else	
			if UVHUDPursuit then
				UVHUDPursuit = nil
				net.Start( "UVHUDStopPursuit" )
				net.Broadcast()
				UVHUDBusting = nil
				net.Start( "UVHUDStopBusting" )
				net.Broadcast()
				if timer.Exists("UVTimeTillNextHeat") then
					timer.Pause("UVTimeTillNextHeat")
				end

				if uvhudtimestopped then return end
				uvhudtimestopped = true
				
				if not UVEnemyEscaped then --busted
					local bustedtable = {}
					bustedtable["Deploys"] = UVDeploys
					bustedtable["Roadblocks"] = UVRoadblocksDodged
					bustedtable["Spikestrips"] = UVSpikestripsDodged
					net.Start( "UVHUDCopModeBustedDebrief" )
					net.WriteTable(bustedtable)
					net.Send(UVPlayerUnitTablePlayers)
				else --escaped
					local escapedtable = {}
					escapedtable["Deploys"] = UVDeploys
					escapedtable["Roadblocks"] = UVRoadblocksDodged
					escapedtable["Spikestrips"] = UVSpikestripsDodged
					net.Start( "UVHUDEscapedDebrief" )
					net.WriteTable(escapedtable)
					net.Send(UVWantedTableDriver)
					net.Start( "UVHUDCopModeEscapedDebrief" )
					net.WriteTable(escapedtable)
					net.Send(UVPlayerUnitTablePlayers)
				end

				timer.Simple(1, function()
					uvhudtimestopped = nil
					if not UVTargeting then
						UVResetStats()
					end
				end)
			end

		end

		if UVEnemyBusted and next(UVWantedTableVehicle) == nil then
			net.Start( "UVHUDEnemyBusted" )
			net.Broadcast()
		end

		if not UVEnemyEscaped and UVTargeting and UVEnemyEscaping and not UVEnemyBusted then
			UVHUDCooldown = true
			net.Start( "UVHUDCooldown" )
			net.WriteString(UVCooldownTimerProgress)
			net.Broadcast()
		elseif UVHUDCooldown then
			UVHUDCooldown = nil
			net.Start( "UVHUDStopCooldown" )
			net.Broadcast()
		end

		if UVHiding and UVEnemyEscaping then
			if UVHiding and not UVHUDHiding then
				UVHUDHiding = true
			end
			net.Start( "UVHUDHiding" )
			net.Broadcast()
		else
			if UVHUDHiding then
				UVHUDHiding = nil
				net.Start( "UVHUDStopHiding" )
				net.Broadcast()
			end
		end
        if UVTargeting then
            if not UVEnemyBusted and next(UVWantedTableVehicle) == nil then
                UVTargeting = nil
            end
        end
	end)
	
	net.Receive("UVCancelUnitRespawn", function(len, ply)
		if ply.uvspawningunit then
			timer.Remove(ply.uvspawningunit.timer)
			ply.uvspawningunit = nil
			
			net.Start("UVSpawnQueueUpdate")
			net.WriteString("") -- empty vehicle = clear
			net.WriteInt(0, 16)
			net.Send(ply)

			net.Start("UVHUDRespawnInUVPlyMsg")
			net.WriteString("uv.chase.select.spawn.cancel")
			net.Send(ply)
		end
	end)

	function UVHUDRespawn( ply, unit, unitnpc, isrhino, unitname )
		local timerName = "UVSpawnQueue_" .. ply:SteamID64()

		if ply.uvspawningunit then
			net.Start( "UVHUDRespawnInUVPlyMsg" )
			net.WriteString("uv.chase.select.spam")
			net.Send(ply)
			return
		end

		if (UVOneCommanderActive or UVOneCommanderDeployed) and unitnpc == "npc_uvcommander" then --Trying to spawn a Commander when it shouldn't...
			ply:PrintMessage( HUD_PRINTTALK, UVString("uv.chase.select.commander.deployed") )

			local UnitsPatrol = string.Trim( GetConVar( 'unitvehicle_unit_unitspatrol' .. UVHeatLevel ):GetString() )
			local UnitsSupport = string.Trim( GetConVar( 'unitvehicle_unit_unitssupport' .. UVHeatLevel ):GetString() )
			local UnitsPursuit = string.Trim( GetConVar( 'unitvehicle_unit_unitspursuit' .. UVHeatLevel ):GetString() )
			local UnitsInterceptor = string.Trim( GetConVar( 'unitvehicle_unit_unitsinterceptor' .. UVHeatLevel ):GetString() )
			local UnitsSpecial = string.Trim( GetConVar( 'unitvehicle_unit_unitsspecial' .. UVHeatLevel ):GetString() )
			local UnitsRhino = string.Trim( GetConVar( 'unitvehicle_unit_unitsrhino' .. UVHeatLevel ):GetString() )
			local UnitsCommander = ""

			net.Start("UVHUDRespawnInUVSelect")
			net.WriteString(UnitsPatrol)
			net.WriteString(UnitsSupport)
			net.WriteString(UnitsPursuit)
			net.WriteString(UnitsInterceptor)
			net.WriteString(UnitsSpecial)
			net.WriteString(UnitsRhino)
			net.WriteString(UnitsCommander)
			net.Send(ply)
			return
		end

		local playercontrolled = {
			["unit"] = unit,
			["unitnpc"] = unitnpc
		}

		local cooldown = SpawnCooldownTable[ply] and math.Round(SpawnCooldown:GetInt() - (CurTime() - SpawnCooldownTable[ply])) or 0
		local cooldownmsg = ""

		local plymsg = { msg = "uv.chase.select.spawning", unit = unit, cooldown = nil }

		if IsValid(ply.uvplayerlastvehicle) and ply.uvplayerlastvehicle.wrecked then
			SpawnCooldownTable[ply] = CurTime()

			ply:EmitSound("ui/redeploy/redeploy" .. math.random(1, 4) .. ".wav")

			ply:ExitVehicle()
			ply:Spawn()
			UVAutoSpawn(ply, isrhino, nil, playercontrolled)
			plymsg.msg = "uv.chase.select.spawning"

			if RandomPlayerUnits:GetBool() then plymsg.msg = "uv.chase.select.spawning.random" end

			net.Start( "UVHUDRespawnInUVPlyMsg" )
			net.WriteString(plymsg.msg)
			net.WriteString(unitname)
			net.Send(ply)
		else
			if not SpawnCooldownTable[ply] then
				SpawnCooldownTable[ply] = 0
			else
				if CurTime() - SpawnCooldownTable[ply] < SpawnCooldown:GetInt() then
					plymsg.msg = "uv.chase.select.spawning.cooldown"
					plymsg.cooldown = cooldown
					
					if RandomPlayerUnits:GetBool() then plymsg.msg = "uv.chase.select.spawning.cooldown.random" end
					
					net.Start("UVSpawnQueueUpdate")
					net.WriteString(unitname)      -- vehicle/unit name
					net.WriteInt(cooldown, 16) -- cooldown in seconds
					net.Send(ply)
				end
			end

			ply.uvspawningunit = {
				unit = unit,
				unitnpc = unitnpc,
				timer = timerName,
				cooldown = cooldown
			}

			-- timer.Simple(cooldown, function()
			timer.Create(timerName, cooldown, 1, function()
				SpawnCooldownTable[ply] = CurTime()
				ply.uvspawningunit = nil
				net.Start( "UVHUDRespawnInUVPlyMsg" )
				
				if RandomPlayerUnits:GetBool() then
					net.WriteString("uv.chase.select.spawning.random")
				else
					net.WriteString("uv.chase.select.spawning")
				end
				net.WriteString(unitname)
				net.Send(ply)
				
				net.Start("UVSpawnQueueUpdate")
				net.WriteString("") -- empty vehicle = clear
				net.WriteInt(0, 16)
				net.Send(ply)

				ply:EmitSound("ui/redeploy/redeploy" .. math.random(1, 4) .. ".wav")

				ply:ExitVehicle()
				ply:Spawn()

				if IsValid(ply.uvplayerlastvehicle) and not ply.uvplayerlastvehicle.wrecked then
					if table.HasValue(UVUnitsChasing, ply.uvplayerlastvehicle) then
						table.RemoveByValue(UVUnitsChasing, ply.uvplayerlastvehicle)
					end

					ply.uvplayerlastvehicle:Remove()
				end

				UVAutoSpawn(ply, isrhino, nil, playercontrolled)
			end)
		end
	end

	net.Receive("UVHUDRespawnInUV", function( length, ply )
		local unit = net.ReadString()
		local unitnpc = net.ReadString()
		local isrhino = net.ReadBool()
		local unitname = net.ReadString()

		UVHUDRespawn(ply, unit, unitnpc, isrhino, unitname)
	end)
	
	net.Receive("UVHUDRespawnInUVGetInfo", function( length, ply )
		if RandomPlayerUnits:GetBool() then
			UVHUDRespawn(ply, "", "", false, "Random")
			return
		end

		local UnitsPatrol = string.Trim( GetConVar( 'unitvehicle_unit_unitspatrol' .. UVHeatLevel ):GetString() )
		local UnitsSupport = string.Trim( GetConVar( 'unitvehicle_unit_unitssupport' .. UVHeatLevel ):GetString() )
		local UnitsPursuit = string.Trim( GetConVar( 'unitvehicle_unit_unitspursuit' .. UVHeatLevel ):GetString() )
		local UnitsInterceptor = string.Trim( GetConVar( 'unitvehicle_unit_unitsinterceptor' .. UVHeatLevel ):GetString() )
		local UnitsSpecial = string.Trim( GetConVar( 'unitvehicle_unit_unitsspecial' .. UVHeatLevel ):GetString() )
		local UnitsRhino = string.Trim( GetConVar( 'unitvehicle_unit_unitsrhino' .. UVHeatLevel ):GetString() )
		local UnitsCommander = string.Trim( GetConVar( 'unitvehicle_unit_unitscommander' .. UVHeatLevel ):GetString() )
		
		if UVOneCommanderActive or UVOneCommanderDeployed then
			UnitsCommander = ""
		end

		if RandomPlayerUnits:GetBool() then
			UnitsPatrol = ""
			UnitsSupport = ""
			UnitsPursuit = ""
			UnitsInterceptor = ""
			UnitsSpecial = ""
			UnitsRhino = ""
			UnitsCommander = ""
		end

		net.Start("UVHUDRespawnInUVSelect")
		net.WriteString(UnitsPatrol)
		net.WriteString(UnitsSupport)
		net.WriteString(UnitsPursuit)
		net.WriteString(UnitsInterceptor)
		net.WriteString(UnitsSpecial)
		net.WriteString(UnitsRhino)
		net.WriteString(UnitsCommander)
		net.Send(ply)
	end)

	-- net.Receive("UVHUDReAddUV", function( length, ply )
	-- 	local unitindex = net.ReadInt(32)
	-- 	local typestring = net.ReadString()
	-- 	local unit = Entity(unitindex)
	-- 	if not IsValid(unit) then return end
	-- 	net.Start("UVHUDAddUV")
	-- 	net.WriteInt(unitindex, 32)
	-- 	net.WriteString(typestring)
	-- 	net.Send(ply)
	-- end)

	gameevent.Listen( "player_activate" )
	hook.Add( "player_activate", "player_activate_example", function( data ) 
		local id = data.userid				-- Same as Player:UserID() for the speaker
		local ply = Player(id)

		print('Unit Vehicles:', 'Initializing for -', ply)

		net.Start('UVGet_PursuitTable')
		net.WriteTable(PursuitTable)
		net.Send(ply)

		for _, v in pairs( UVUnitVehicles ) do
			net.Start( "UVHUDAddUV" )
			net.WriteInt( v:EntIndex(), 32 )
			net.WriteInt( v:GetCreationID(), 32 )
			net.WriteString( "unit" )
			net.Send( ply )
		end

		for _, v in pairs( UVWantedTableVehicle ) do
			net.Start( "UV_AddWantedVehicle" )
			net.WriteInt( v:EntIndex(), 32 )
			net.WriteInt( v:GetCreationID(), 32 )
			net.Send( ply )
		end

		if not ply:IsListenServerHost() then
			for convarKey, _ in pairs(ReplicatedVars) do
				net.Start( "UVGetSettings_Local" )
				net.WriteString(convarKey)
				net.WriteString(GetConVar(convarKey):GetString())
				net.Send(ply)
			end
		end

	end )	

	net.Receive("UVUpdateSettings", function(len, ply)
		if not ply:IsSuperAdmin() then return end
		local array = net.ReadTable()
		
		for key, value in pairs(array) do
			if string.match(key, 'unitvehicle_') or string.match(key, 'uvpursuittech_') then
				local convarType = type(value)
				local convar = GetConVar(key)

				if convar then
					--[[
						So for some fucking reason unbeknownst to me, RunConsoleCommand convars refuse to work for certain strings, 
						yet it works if you set it using the ConVar::SetX functions, bullshit.
					]]
					convar:SetString(value)

					if ReplicatedVars[key] then
						for _, v in pairs( ents.FindByClass("player") ) do
							if not v:IsListenServerHost() then
								net.Start( "UVGetSettings_Local" )
								net.WriteString(key)
								net.WriteString(value)
								net.Send(v)
							end
						end
					end
				end
			end
		end
	end)

	concommand.Add( "uv_setbounty", function( ply, cmd, args )
		if not ply:IsSuperAdmin() then return end
		UVBounty = tonumber(args[1]) or 0
	end)

else -- CLIENT Settings | HUD/Options

	local displaying_busted = false 
	UVSettingKeybind = false

	local UVHUDPursuitRespawnNoticeStarted = false
	local UVHUDPursuitRespawnNoticeTriggered = false
	local UVHUDPursuitRespawnNoticeEndTime = nil
	local UVHUDPursuitRespawnNoticeStartTime = nil

	local UVHUDScreenFlashHeatUp = 0

	UVDeploys = 0
	UVUnitsChasing = 0
	UVBustingProgress = 0

	local UVClosestSuspect = nil

	UVHUDBlipSoundTime = CurTime()
	UVHUDScannerPos = Vector(0,0,0)

	KeyBindButtons = {}
	PursuitTable = {}
	UnitTable = {}
	EntityQueue = {}
	CleanupTask = {}

	local unitBlipColors = {
		[1] = Color( 0, 0, 255 ),
		[2] = Color( 150, 0, 0),
		[3] = Color( 255, 255, 255 )
	}

	PursuitTheme = CreateClientConVar("unitvehicle_pursuittheme", "", true, false, "Unit Vehicles: Pursuit Theme (string).")
	PursuitSFX = CreateClientConVar("unitvehicle_pursuitsfx", 1, true, false, "Unit Vehicles: If set to 1, Pursuit SFX will play.")
	PlayMusic = CreateClientConVar("unitvehicle_playmusic", 1, true, false, "Unit Vehicles: If set to 1, Pursuit themes will play.")
	PursuitThemePlayRandomHeat = CreateClientConVar("unitvehicle_pursuitthemeplayrandomheat", 0, true, false, "Unit Vehicles: If set to 1, random Heat Level songs will play during pursuits every 10 minutes.")
	PursuitThemePlayRandomHeatMinutes = CreateClientConVar("unitvehicle_pursuitthemeplayrandomheatminutes", 10, true, false, "Unit Vehicles: If set to 'Every X minutes', all Heat Level songs will play during pursuits every X minutes.")
	PursuitThemePlayRandomHeatType = CreateClientConVar("unitvehicle_pursuitthemeplayrandomheattype", "Sequential", true, false, "Unit Vehicles: If set to 'Sequential', random Heat Level songs will play after another. If set to 'Every 10 minutes', all Heat Level songs will play during pursuits every 10 minutes.")
	RacingMusic = CreateClientConVar("unitvehicle_racingmusic", 1, true, false, "Unit Vehicles: If set to 1, Racing music will play.")
	RacingMusicPriority = CreateClientConVar("unitvehicle_racingmusicpriority", 0, true, false, "Unit Vehicles: If set to 1, Racing music will play during pursuits while racing.")
	RacingThemeOutsideRace = CreateClientConVar("unitvehicle_racingmusicoutsideraces", 0, true, false, "Unit Vehicles: If set to 1, Racing music will play during pursuits even while not racing.")
	PursuitVolume = CreateClientConVar("unitvehicle_pursuitthemevolume", 1, true, false, "Unit Vehicles: Determines volume of the pursuit theme.")
	ChatterVolume = CreateClientConVar("unitvehicle_chattervolume", 1, true, false, "Unit Vehicles: Determines volume of the Unit Vehicles' radio chatter.")
	MuteCheckpointSFX = CreateClientConVar("unitvehicle_mutecheckpointsfx", 0, true, false, "Unit Vehicles: If set to 1, the SFX that plays when passing checkpoints will be silent.")
	UVTraxFreeroam = CreateClientConVar("unitvehicle_uvtraxinfreeroam", 0, true, false, "Unit Vehicles: If set to 1, UV TRAX™ will play in Freeroam whenever you're in a vehicle.")
	UVSubtitles = CreateClientConVar("unitvehicle_subtitles", 1, true, false, "Unit Vehicles: If set to 1, display subtitles when Cop Chatter is active. Only works for Default Chatter, and only in English.")
	UVVehicleNameTakedown = CreateClientConVar("unitvehicle_vehiclenametakedown", 0, true, false, "Unit Vehicles: If set to 1, Unit takedowns use the vehicle name instead of the unit name.")
	UVDisplayUnits = CreateClientConVar("unitvehicle_unitstype", 0, true, false, "Unit Vehicles: If set to 0 (or an invalid value), displays units in meters. If set to 1, displays units in feet. If set to 2, displays units in yards.")
	
	RacerTags = CreateClientConVar("unitvehicle_racertags", 1, true, false, "Unit Vehicles: If set to 1, Racers and Commander Units will have name tags above their vehicles.")

	UVControllerMode = CreateClientConVar("unitvehicle_controllermode", 0, true, false, "Unit Vehicles: If set to 1, certain actions in the UV Menu are swapped to work with more controller-friendly alternatives, such as JUMP instead of MOUSE1.")
	UVGlyphOverride = CreateClientConVar("unitvehicle_glyph_override", 0, true, false, "Unit Vehicles: If set to 1, it enables an override to display specified glyphs in the UV Menu and certain other elements rather than their accurate ones.")
	UVGlyphSet = CreateClientConVar("unitvehicle_glyph_set", "", true, false, "Unit Vehicles: The glyph set used for the Glyph Override.")

	UVPoliceScanner = CreateClientConVar("unitvehicle_policescanner", 1, true, false, "Unit Vehicles: If set to 1, the police scanner will be enabled.")
	UVPoliceScannerVehicle = CreateClientConVar("unitvehicle_policescanner_vehicle", 0, true, false, "Unit Vehicles: If set to 1, the police scanner will use your vehicle as its anchor rather than the camera viewpoint.")

	-- for i = 1, MAX_HEAT_LEVEL do
	-- 	local prevIterator = i - 1

	-- 	local timeTillNextHeatId = ((prevIterator == 0 and 'enabled') or prevIterator)

	-- 	for _, v in pairs( {'Patrol', 'Support', 'Pursuit', 'Interceptor', 'Special', 'Commander', 'Rhino'} ) do
	-- 		local lowercaseUnit = string.lower( v )
	-- 		local conVarKey = string.format( 'units%s%s', lowercaseUnit, i )

	-- 		-------------------------------------------

	-- 		CreateClientConVar( "unitvehicle_unit_" .. conVarKey, "", true, false)
	-- 	end

	-- 	for _, conVar in pairs( HEAT_SETTINGS ) do
	-- 		local conVarKey = conVar .. ((conVar == 'timetillnextheat' and timeTillNextHeatId) or i)
	-- 		local check = (conVar == "timetillnextheat")

	-- 		CreateClientConVar( "unitvehicle_unit_" .. conVarKey, HEAT_DEFAULTS[conVar][tostring( ( check and timeTillNextHeatId ) or i )] or 0, true, false)
	-- 	end
	-- end

	--UVUTimeTillNextHeatEnabled = CreateClientConVar("unitvehicle_unit_timetillnextheatenabled", 0, true, false)

	UVPTKeybindSlot1 = CreateClientConVar("unitvehicle_pursuittech_keybindslot_1", KEY_T, true, false)
	UVPTKeybindSlot2 = CreateClientConVar("unitvehicle_pursuittech_keybindslot_2", KEY_P, true, false)

	UVKeybindResetPosition = CreateClientConVar("unitvehicle_keybind_resetposition", KEY_M, true, false)
	UVKeybindShowRaceResults = CreateClientConVar("unitvehicle_keybind_raceresults", KEY_N, true, false)

	UVKeybindSkipSong = CreateClientConVar("unitvehicle_keybind_skipsong", KEY_RBRACKET, true, false)
	UVKeybindPrevSong = CreateClientConVar("unitvehicle_keybind_prevsong", KEY_LBRACKET, true, false)

	-- UVPBMax = CreateClientConVar("unitvehicle_pursuitbreaker_maxpb", 2, true, false)
	-- UVPBCooldown = CreateClientConVar("unitvehicle_pursuitbreaker_pbcooldown", 60, true, false)

	-- UVRBMax = CreateClientConVar("unitvehicle_roadblock_maxrb", 1, true, false)
	-- UVRBOverride = CreateClientConVar("unitvehicle_roadblock_override", 0, true, false)

	UVHUDTypeMain = CreateClientConVar("unitvehicle_hudtype_main", "mostwanted", true, false, "Unit Vehicles: Which HUD type to use when in races and pursuits.")
	UVHUDTypeBackup = CreateClientConVar("unitvehicle_hudtype_backup", "mostwanted", true, false, "Unit Vehicles: Which HUD type to use if main does not have a Pursuit UI.")

	UVHUDXDeadzone = CreateClientConVar("unitvehicle_hud_deadzone", 0, true, false, "Unit Vehicles: Increase to move UI elements closer to the center of the screen.")
	UVHUDXScale = CreateClientConVar("unitvehicle_hud_scale", 1, true, false, "Unit Vehicles: Increase or decrease the size of the UI elements.")

	UVUnitsColor = Color(255,255,255)

	UVSelectedHeatTrack = 1
	UVLastHeatChange = -math.huge

	UVHeatLevel = 1
	UVHUDWantedSuspects = {}

	PursuitTable = {
		['InPursuit'] = false,
		['InCooldown'] = false,
		['IsEvading'] = false,
		['PursuitStart'] = 0,
		['Heat'] = 1,
		['UnitsChasing'] = 0,
		['ResourcePoints'] = 0,
		['Deploys'] = 0,
		['PursuitLength'] = 0,
		['Wrecks'] = 0,
		['Tags'] = 0,
		['Bounty'] = 0,
		['CommanderActive'] = false,
		['CommanderEntity'] = nil
		--['ChasedVehicles'] = {},
	}

	local conVarList = {}
	UVUnitsConVars = conVarList
	
	conVarList["selected_heat"] = 1
	
	conVarList["vehiclebase"] = 3
	conVarList["onecommander"] = 1
	conVarList["commanderrepair"] = 1
	conVarList["onecommanderevading"] = 0
	conVarList["onecommanderhealth"] = 5000
	conVarList["helicoptermodel"] = "Default"
	conVarList["helicopterbarrels"] = 1
	conVarList["helicopterspikestrip"] = 1
	conVarList["helicopterbusting"] = 1
	
	conVarList["pursuittech"] = 1
	conVarList["pursuittech_esf"] = 1
	conVarList["pursuittech_emp"] = 1
	conVarList["pursuittech_spikestrip"] = 1
	conVarList["pursuittech_killswitch"] = 1
	conVarList["pursuittech_repairkit"] = 1
	conVarList["pursuittech_shockram"] = 1
	conVarList["pursuittech_gpsdart"] = 1
	conVarList["pursuittech_grappler"] = 1
	
	conVarList["minheat"] = 1
	conVarList["maxheat"] = 6
	
	conVarList["bountypatrol"] = 1000
	conVarList["bountysupport"] = 5000
	conVarList["bountypursuit"] = 10000
	conVarList["bountyinterceptor"] = 20000
	conVarList["bountyair"] = 75000
	conVarList["bountyspecial"] = 25000
	conVarList["bountycommander"] = 100000
	conVarList["bountyrhino"] = 50000
	
	local defaultvoicetable = {
		"cop1, cop2, cop3, cop4", --Patrol
		"cop1, cop2, cop3, cop4", --Support
		"cop1, cop2, cop3, cop4", --Pursuit
		"cop1, cop2, cop3, cop4", --Interceptor
		"cop1, cop2, cop3, cop4", --Special
		"commander1", --Commander
		"rhino1", --Rhino
		"air", --Air
	}
	
	for index, v in pairs( {'Patrol', 'Support', 'Pursuit', 'Interceptor', 'Special', 'Commander', 'Rhino', 'Air'} ) do
		local lowercaseUnit = string.lower( v )
		local conVarKey = string.format( '%s_voice', lowercaseUnit )
		local conVarKeyVoiceProfile = string.format( '%s_voiceprofile', lowercaseUnit )
		conVarList[conVarKey] = defaultvoicetable[index]
		conVarList[conVarKeyVoiceProfile] = "default"
	end
	
	for _, v in pairs( {'Misc', 'Dispatch'} ) do
		local lowercaseType = string.lower( v )
		local conVarKey = string.format( '%s_voiceprofile', lowercaseType )
		conVarList[conVarKey] = "default"
	end
	
	local unitsheat1 = {
		"default_crownvic.json", --Patrol
		"", --Support
		"", --Pursuit
		"", --Interceptor
		"", --Special
		"", --Commander
		"" --Rhino
	}
	
	local unitsheat2 = {
		"default_crownvic.json", --Patrol
		"default_explorer.json", --Support
		"", --Pursuit
		"", --Interceptor
		"", --Special
		"", --Commander
		"" --Rhino
	}
	
	local unitsheat3 = {
		"default_crownvic.json", --Patrol
		"default_explorer.json", --Support
		"", --Pursuit
		"", --Interceptor
		"", --Special
		"", --Commander
		"" --Rhino
	}
	
	local unitsheat4 = {
		"", --Patrol
		"default_explorer.json", --Support
		"", --Pursuit
		"default_corvettec7.json", --Interceptor
		"", --Special
		"", --Commander
		"" --Rhino
	}
	
	local unitsheat5 = {
		"", --Patrol
		"", --Support
		"", --Pursuit
		"default_corvettec7.json", --Interceptor
		"default_coloradozr2.json", --Special
		"", --Commander
		"default_rhinotruck.json" --Rhino
	}
	
	local unitsheat6 = {
		"", --Patrol
		"", --Support
		"", --Pursuit
		"default_corvettec7.json", --Interceptor
		"default_coloradozr2.json", --Special
		"", --Commander
		"default_rhinotruck.json" --Rhino
	}
	
	for i = 1, MAX_HEAT_LEVEL do
		local prevIterator = i - 1
		
		local timeTillNextHeatId = ((prevIterator == 0 and 'enabled') or prevIterator)
		
		for index, v in pairs( {'Patrol', 'Support', 'Pursuit', 'Interceptor', 'Special', 'Commander', 'Rhino'} ) do
			local lowercaseUnit = string.lower( v )
			local conVarKey = string.format( 'units%s%s', lowercaseUnit, i )
			local chanceConVarKey = string.format( 'units%s%s_chance', lowercaseUnit, i )
			local limitConVarKey = string.format( 'units%s%s_limit', lowercaseUnit, i )
			
			-------------------------------------------
			if i == 1 then
				conVarList[conVarKey] = unitsheat1[index]
			elseif i == 2 then
				conVarList[conVarKey] = unitsheat2[index]
			elseif i == 3 then
				conVarList[conVarKey] = unitsheat3[index]
			elseif i == 4 then
				conVarList[conVarKey] = unitsheat4[index]
			elseif i == 5 then
				conVarList[conVarKey] = unitsheat5[index]
			elseif i == 6 then
				conVarList[conVarKey] = unitsheat6[index]
			else
				conVarList[conVarKey] = ""
			end
			
			conVarList[chanceConVarKey] = 100
			conVarList[limitConVarKey] = 0
		end
		
		for _, conVar in pairs( HEAT_SETTINGS ) do
			local conVarKey = conVar .. ((conVar == 'timetillnextheat' and timeTillNextHeatId) or i)
			local check = (conVar == "timetillnextheat")
			
			conVarList[conVarKey] = HEAT_DEFAULTS[conVar][tostring( ( check and timeTillNextHeatId ) or i )] or 0
		end
	end
	
	local LEGACY_CONVARS = {
		["rhinos"] = {
			Replacement = "unitsrhino",
			HasNumber = true,
		},
	}
	
	local PROTECTED_CONVARS = {
		['selected_heat'] = true,
	}
	
	local DEFAULTS = {
		['selected_heat'] = 1,
		['minheat'] = 1,
		['maxheat'] = 6
	}
	
	local function _setConVar( cvar, value )
		-- local valueType = type( value )
		-- local cvarClass = GetConVar( cvar )
		
		-- if valueType == 'number' then
		-- 	cvarClass:SetFloat( value )
		-- else
		-- 	cvarClass:SetString( value )
		-- end
		net.Start("UVUpdateSettings")
		net.WriteTable({ ["unitvehicle_unit_" .. cvar] = value })
		net.SendToServer()
	end

	--[[
		- data is a table of convar names and values
	]]
	function UVUnitManagerLoadPresetV2(name, data)
		local warned = false
		local count = 0
		local count1 = 0

		for key, value in pairs(conVarList) do
			local incomingData = data[key] or data["unitvehicle_unit_" .. key] or data["uvunitmanager_" .. key]
			local cont

			-- MUST BE FIXED TO USE UVUPDATESETTINGS
			if string.match(key, "_chance") and not incomingData then
				_setConVar( key, 100 )
				cont = true 
			end

			if string.match(key, "_limit") and not incomingData then
				_setConVar( key, 0 )
				cont = true 
			end

			if cont then
				cont = nil
				continue
			end

			if not incomingData and GetConVar("unitvehicle_unit_" .. key) and not PROTECTED_CONVARS[key] then
				_setConVar( key, DEFAULTS[key] or "" )
			end
		end

		for incomingCV, incomingValue in pairs(data) do
			-- local isOldFormat = string.match( incomingCV, "uvunitmanager_" )
			-- incomingCV = isOldFormat and string.Split( incomingCV, "uvunitmanager_" )[2] or incomingCV
			local variable = string.Split( incomingCV, "unitvehicle_unit_" )[2] or string.Split( incomingCV, "uvunitmanager_" )[2]

			count1 = count1 + 1
			--local cvNoNumber = string.sub( incomingCV, 1, string.len(incomingCV) - 1 )

			local cvNoNumber = nil
			local number = nil

			local _incomingCV = variable

			while string.match( _incomingCV:sub(-1), "%d" ) and _incomingCV ~= "" do
				number = _incomingCV:sub( -1 )
				cvNoNumber = _incomingCV:sub( 1, -2 )
				_incomingCV = cvNoNumber
			end

			local numberIterator = 0

			if LEGACY_CONVARS[_incomingCV] then
				if not warned then
					warned = true
					local warning = string.format( UVString "tool.uvunitmanager.presets.legacy.warning", name )
					notification.AddLegacy( warning, NOTIFY_UNDO, 5 )
				end

				if LEGACY_CONVARS[_incomingCV].HasNumber then
					_setConVar( LEGACY_CONVARS[_incomingCV].Replacement .. number, incomingValue  )
				else
					_setConVar( LEGACY_CONVARS[_incomingCV].Replacement, incomingValue )
				end
			elseif not PROTECTED_CONVARS[variable] then
				_setConVar( variable, incomingValue )
			end
		end
	end

	function UVUnitManagerExportPreset( name )
		local jsonArray = {
			['Name'] = name,
			['Data'] = {}
		}

		for cVarKey, _ in pairs( conVarList ) do
			if table.HasValue( PROTECTED_CONVARS, cVarKey ) then continue end

			local newKey = 'unitvehicle_unit_' .. cVarKey
			local cVar = GetConVar( newKey )
			if cVar then
				jsonArray.Data[newKey] = cVar:GetString()
			end
		end

		if not file.IsDir( 'unitvehicles/preset_export', 'DATA' ) then
			file.CreateDir( 'unitvehicles/preset_export' )
		end

		if not file.IsDir( 'unitvehicles/preset_export/uvunitmanager', 'DATA' ) then
			file.CreateDir( 'unitvehicles/preset_export/uvunitmanager' )
		end

		file.Write( 'unitvehicles/preset_export/uvunitmanager/' .. name .. '.json', util.TableToJSON( jsonArray ) )
		chat.AddText( Color( 0, 150, 0 ), "Your preset has been exported!\nDestination: data/unitvehicles/preset_export/uvunitmanager/" .. name .. ".json" )
	end

	if not file.IsDir( 'data/unitvehicles/preset_import', 'GAME' ) then
		file.CreateDir( 'unitvehicles/preset_import' )
	end

	if not file.IsDir( 'data/unitvehicles/preset_import/uvunitmanager', 'GAME' ) then
		file.CreateDir( 'unitvehicles/preset_import/uvunitmanager' )
	end

	timer.Simple(3, function()
		local importFiles, _ = file.Find( 'data/unitvehicles/preset_import/uvunitmanager/*', 'GAME' )
		
		for _, impFile in pairs( importFiles ) do
			local success = ProtectedCall(function()
				local data = util.JSONToTable( file.Read( 'data/unitvehicles/preset_import/uvunitmanager/' .. impFile, 'GAME' ) )
				
				if type(data) == 'table' and (data.Name and data.Data) then
					presets.Add( 
						'units', 
						data.Name, 
						data.Data 
					)
				else
					error('Malformed JSON data!')
				end
				
				file.Delete( 'unitvehicles/preset_import/uvunitmanager/' .. impFile, 'DATA' )
			end)

			if success then
				MsgC( Color(0, 255, 0), "[Unit Vehicles (uvunitmanager)]: Added \"" .. string.Split( impFile, '.json' )[1] .. "\" to the presets!\n" )
			else
				MsgC( Color(255, 0, 0), "[Unit Vehicles (uvunitmanager)]: Failed to add \"" .. string.Split( impFile, '.json' )[1] .. "\" to the presets!\n" )
			end
		end
	end)

	local function InitEntity( entIndex, creationId, entType )
		local entity = Entity( entIndex )
		if not IsValid( entity ) then return end

		local localCreationId = entity:GetCreationID()

		if localCreationId ~= creationId then 
			return 
		end

		if entType == "unit" or entType == "air" then

			table.insert( UnitTable, entity )

			if GMinimap then
				local entClass = entity:GetClass()
				local unitIcon = (entType == "air" and "unitvehicles/icons/HELICOPTER_MINIMAP_ICON.png") or "unitvehicles/icons/MINIMAP_ICON_CAR.png"

				if entClass == "prop_vehicle_jeep" and entType ~= "air" then
					unitIcon = "unitvehicles/icons/MINIMAP_ICON_CAR_JEEP.png"
				end

				local blip, id = GMinimap:AddBlip({
					id = "UVBlip" .. entIndex,
					parent = entity,
					icon = unitIcon,
					scale = (entType == "air" and 2) or 1.4,
					color = Color( 150, 0, 0 ),
					alpha = 255
				})

				entity.flashIterator = 1

				timer.Create( "unit_blip_" .. id, 0.035, 0, function()
					if blip.disabled then
						blip.color = unitBlipColors[3]
						return
					end

					if not UVHUDDisplayPursuit then
						blip.color = unitBlipColors[2]
						return
					end

					-- entity.flashIterator = entity.flashIterator + 1
					local color = unitBlipColors[entity.flashIterator]
					entity.flashIterator = entity.flashIterator % #unitBlipColors + 1

					if color then
						blip.color = color
					end
				end)

				entity:CallOnRemove( "uv_entity_" .. entIndex, function()
					timer.Remove( "unit_blip_" .. id )
				end)
			end

		elseif entType == "roadblock" then

			if GMinimap then
				local blip, id = GMinimap:AddBlip( {
					id = "UVBlip" .. entIndex,
					parent = entity,
					icon = "unitvehicles/icons/MINIMAP_ICON_ROADBLOCK.png",
					scale = 1.4,
					color = Color( 255, 255, 0),
					alpha = 255
				} )
			end
			-- timer.Simple(0.1, function()
			-- 	blip.alpha = 255
			-- end)

		elseif entType == "repairshop" then

			if GMinimap then
				local blip, id = GMinimap:AddBlip( {
					id = "UVBlip" .. entIndex,
					parent = entity,
					icon = "unitvehicles/icons/repairshop.png",
					scale = 2,
					color = Color( 0, 255, 0),
					alpha = 255,
					lockIconAng = true
				} )
			end

		elseif entType == "racer" then
			table.insert( UVHUDWantedSuspects, entity )
		end

		return true
		--EntityQueue[entIndex] = nil
	end

	net.Receive("UVHUDStartPursuitNotification", function()
		UV_UI.general.events.CenterNotification({
            text = UVString( net.ReadString() ),
		})
	end)

	net.Receive("UVHUDStartPursuitCountdown", function()
		local starttime = net.ReadInt(11)

		local main = UVHUDTypeMain:GetString()
		local backup = UVHUDTypeBackup:GetString()

		if main == "" then return end

		local hudHandler = UV_UI.racing[main] and UV_UI.racing[main].events.onRaceStartTimer
		
		if not hudHandler then
			hudHandler = UV_UI.racing[backup] and UV_UI.racing[backup].events.onRaceStartTimer
		end

		if hudHandler then
			hudHandler({
				starttime = starttime,
				noBG = true,
				noReadyText = true,
			})
		else
			local countdownTexts = {
				[4] = 3,
				[3] = 2,
				[2] = 1,
				[1] = UVString("uv.race.go")
			}

			local textToShow = countdownTexts[starttime]
			if not textToShow then return end

			local startTime = CurTime()
			local duration = 1
			local hookName = "UV_PURSUITSTARTTIME"

			-- Replace existing hook cleanly
			hook.Remove("HUDPaint", hookName)
			hook.Add("HUDPaint", hookName, function()
				local elapsed = CurTime() - startTime
				if elapsed > duration then
					hook.Remove("HUDPaint", hookName)
					return
				end

				local x, y = ScrW() * 0.5, ScrH() * 0.45
				draw.SimpleTextOutlined(
					textToShow,
					"UVFont5",
					x, y,
					Color(255, 255, 255),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
					3, Color(0, 0, 0, 255)
				)
			end)
		end
	end)

	net.Receive('UVGetNewKeybind', function()
		--if UVSettingKeybind then return end
		local slot = net.ReadInt(16)
		local key = net.ReadInt(16)

		local entry = KeyBindButtons[slot]

		if entry then
			local convar = GetConVar( entry[1] )

			if convar then
				convar:SetInt( key )
			end
		else
			warn("Invalid slot key; if you run into this please report it to a developer!")
		end

		UVSettingKeybind = false
	end)

	net.Receive("UV_SendPursuitTech", function()
		local car = net.ReadEntity()
		local slot = net.ReadUInt(2)
		local active = net.ReadBool()
		if not IsValid(car) then return end

		-- Entire table cleared
		if not active and slot == 0 then
			car.PursuitTech = nil
			return
		end

		if active then
			if not car.PursuitTech then car.PursuitTech = {} end
			if not car.PursuitTech[slot] then car.PursuitTech[slot] = {} end

			car.PursuitTech[slot].Tech = net.ReadString()
			car.PursuitTech[slot].Ammo = net.ReadUInt(8)
			car.PursuitTech[slot].Cooldown = net.ReadUInt(16)
			car.PursuitTech[slot].LastUsed = net.ReadFloat()
		elseif car.PursuitTech then
			car.PursuitTech[slot] = nil
			-- If both slots are now nil, clear the table completely for cleanliness
			if not car.PursuitTech[1] and not car.PursuitTech[2] then
				car.PursuitTech = nil
			end
		end
	end)

	net.Receive('UVGet_PursuitTable', function()
		PursuitTable = net.ReadTable()
	end)

	net.Receive('UVSet_PursuitTable', function()
		local messageSize = net.ReadUInt( 16 )
		local recvData = net.ReadData( messageSize )

		local decompData = util.Decompress( recvData )
		local dataTable = util.JSONToTable( decompData )

		for key, value in pairs( dataTable ) do
			-- Found inside uvhud
			if UV_UI_Events[key] then 
				hook.Run( 'UIEventHook', 'pursuit', UV_UI_Events[key], value, PursuitTable[key] )
			end

			PursuitTable[key] = value
		end
	end)

	net.Receive('UVGetSettings_Local', function()
		local key = net.ReadString()
		local value = net.ReadString()

		local convar = GetConVar(key)
		if convar and string.match(key, 'unitvehicle_') then
			convar:SetString(value)
		end
	end)

	unitvehicles = true

	local UVHUDCopsDamaged = Material("unitvehicles/icons/COPS_DAMAGED_ICON.png")
	local UVHUDCopsWrecked = Material("unitvehicles/icons/COPS_TAKENOUT_ICON.png")
	local UVHUDMilestoneBounty = Material("unitvehicles/icons/MILESTONE_PURSUITBOUNTY.png")
	local UVHUDMilestoneInfractions = Material("unitvehicles/icons/MILESTONE_INFRACTIONS.png")
	local UVHUDMilestoneRoadblocks = Material("unitvehicles/icons/MILESTONE_ROADBLOCKS.png")
	local UVHUDMilestoneSpikestrips = Material("unitvehicles/icons/MILESTONE_SPIKESTRIPS.png")
	local UVHUDPursuitBreaker = Material("unitvehicles/icons/WORLD_PURSUITBREAKER.png")
	local UVHUDBlipSound = "ui/pursuit/spotting_blip.wav"

	concommand.Add("uv_keybinds", function( ply, cmd, slot )
		if UVSettingKeybind then
			notification.AddLegacy( "You are already setting a keybind!", NOTIFY_ERROR, 5 )
			return
		end

		local slot = slot[1]

		net.Start("UVPTKeybindRequest")
		net.WriteInt(slot, 16)
		net.SendToServer()

		UVSettingKeybind = slot
		-- KeyBindButtons[tonumber(slot)][2]:SetText('PRESS A KEY NOW!')
	end)

	concommand.Add("uv_local_update_settings", function( ply )
		if not ply:IsSuperAdmin() then
			notification.AddLegacy( "You need to be a super admin to apply settings on server!", NOTIFY_ERROR, 5 )
			return
		end

		local convar_table = {}

		for convar_name, convar_type in pairs(LOCAL_CONVARS) do
			local convar = GetConVar(convar_name)
			local value = nil

			if convar_type == 'boolean' then
				value = convar:GetBool()
			elseif convar_type == 'integer' then
				value = convar:GetInt()
			elseif convar_type == 'string' then
				value = convar:GetString()
			end

			if value then
				convar_table[convar_name] = value
			end
		end

		net.Start("UVUpdateSettings")
		net.WriteTable(convar_table)
		net.SendToServer()

		notification.AddLegacy('Pursuit Settings applied!', NOTIFY_GENERIC, 3)
	end)

	concommand.Add("uv_spawn_as_unit", function(ply)
		net.Start("UVHUDRespawnInUVGetInfo")
		net.SendToServer()
	end)

	net.Receive("UVHUDPursuit", function()

		UVBountyString = net.ReadString()
		UVBountyNo = tonumber(UVBountyString)
		UVBounty = string.Comma(UVBountyString)

		UVHUDDisplayPursuit = true

	end)

	net.Receive("UVHUDHeatLevel", function()

		local HeatLevel = tonumber(net.ReadString())
		hook.Run( 'UIEventHook', 'pursuit', 'onHeatLevelUpdate', HeatLevel, UVHeatLevel )

		UVHeatLevel = HeatLevel

	end)

	net.Receive("UVHUDResourcePoints", function()

		local ResourcePoints = net.ReadString()
		local rp_num = tonumber(ResourcePoints)

		if rp_num ~= UVResourcePoints then
			hook.Run( 'UIEventHook', 'pursuit', 'onResourceChange', rp_num, UVResourcePoints )
		end

		UVResourcePoints = tonumber(ResourcePoints)

	end)

	net.Receive("UVHUDBackupTimer", function()

		UVBackupProgress = net.ReadString()
		UVBackupTimerSeconds = tonumber(UVBackupProgress)
		UVBackupTimer = UVDisplayTime(UVBackupProgress)
		UVHUDDisplayBackupTimer = true

	end)

	net.Receive("UVHUDStopBackupTimer", function()

		UVHUDDisplayBackupTimer = nil

	end)

	net.Receive( "UVPullOver", function()
		hook.Run( 'UIEventHook', 'pursuit', 'onPullOverRequest' )
	end)

	net.Receive( "UVFined", function()
		local finenr = net.ReadUInt(2)
		hook.Run( 'UIEventHook', 'pursuit', 'onFined', finenr )
	end)

	net.Receive( "UVFineArrest", function()
		hook.Run( 'UIEventHook', 'pursuit', 'onFineArrest' )
	end)

	net.Receive("UVHUDDeploys", function()

		local deploys = net.ReadString()

		if deploys ~= UVDeploys then
			hook.Run( 'UIEventHook', 'pursuit', 'onUnitDeploy', deploys, UVDeploys )
		end

		UVDeploys = deploys

	end)

	net.Receive("UVHUDWrecks", function()

		local wrecks = net.ReadString()

		if wrecks ~= UVWrecks then
			hook.Run( 'UIEventHook', 'pursuit', 'onUnitWreck', wrecks, UVWrecks )
		end

		UVWrecks = wrecks

	end)

	net.Receive("UVHUDTags", function()

		local tags = net.ReadString()

		if tags ~= UVTags then
			hook.Run( 'UIEventHook', 'pursuit', 'onUnitTag', wrecks, UVTags )
		end

		UVTags = tags

	end)

	net.Receive("UVHUDTimer", function()

		UVTimerStart = net.ReadString()

		if not UVTimerWhenFroze then
			UVTimerWhenFroze = 0
		end
		if not UVCooldownProgress then
			UVCooldownProgress = 0
		end

		if not UVHUDDisplayCooldown and not UVBustedState then
			if UVTimerFroze then
				UVTimerFroze = nil
			end
		else
			if not UVTimerFroze then
				UVTimerWhenFroze = CurTime()-UVCooldownProgress
				UVTimerFroze = true
			end
		end

		if not UVTimerFroze then
			UVCooldownProgress = UVCooldownProgress
			UVTimerProgress = (CurTime() - tonumber(UVTimerStart)-UVCooldownProgress)
		else
			UVTimerProgress = UVTimerProgress
			UVCooldownProgress = (CurTime() - UVTimerWhenFroze)
		end

		UVTimer = UVDisplayTime(UVTimerProgress)

	end)

	net.Receive("UVHUDTimeTillNextHeat", function()

		local time = net.ReadFloat()
		if not time then return end
		UVTimeTillNextHeat = time

	end)

	net.Receive("UVHUDStopPursuit", function()

		UVHUDDisplayPursuit = nil
		UVTimerWhenFroze = 0
		UVCooldownProgress = 0
		UVHUDRaceInProgress = nil

		UVSoundEscaped(UVHeatLevel)

	end)

	net.Receive("UVHUDUpdateBusting", function()
		local ent = net.ReadEntity()
		local progress = net.ReadFloat()

		ent.UVBustingProgress = progress
	end)


	net.Receive("UVHUDBusting", function()
		local lang = UVString
		local blink = 255 * math.abs(math.sin(RealTime() * 4))
		local blink2 = 255 * math.abs(math.sin(RealTime() * 6))
		local blink3 = 255 * math.abs(math.sin(RealTime() * 8))
		UVBustingProgress = net.ReadString()
		UVHUDDisplayBusting = true
		UVBustedColor = Color( 255, 255, 255, 50 )
		UVNotification = lang("uv.chase.busting")
		UVBustingTimeLeft = math.Round((BustedTimer:GetFloat()-UVBustingProgress),3)

		if UVBustingTimeLeft <= 0 then
			UVNotification = true
		end

	end)

	net.Receive("UVHUDStopBusting", function()

		UVHUDDisplayBusting = nil
		UVHUDDisplayNotification = nil

	end)

	net.Receive("UVHUDStopBustingTimeLeft", function()

		if not UVHUDDisplayNotification and not UVEnemyBusted and UVBustingTimeLeft < 1 and UVBustingTimeLeft >= 0 then
			UVNotificationColor = Color( 0, 255, 0)
			UVNotification = string.format(UVString("uv.chase.evadedtime"), UVBustingTimeLeft)
			UVHUDDisplayNotification = true
			timer.Simple(2, function()
				if not UVHUDDisplayBusting then
					UVHUDDisplayNotification = nil
				end
			end)
		end

	end)

	net.Receive("UVHUDEnemyBusted", function()
		local blink = 255 * math.abs(math.sin(RealTime() * 8))
		UVNotificationColor = Color(255, blink, blink)
		UVBustedColor = Color(255, 0, 0)
		local bustedtext = UVString("uv.chase.busted")
		if not UVHUDDisplayNotification then
			if UVHUDRaceInProgress then
				if #UVHUDWantedSuspects <= 1 then
					bustedtext = UVString("uv.race.shutdown")
				end
			end
			UVBustedState = true
			UVNotification = "/// " .. bustedtext .. " ///"
			UVHUDDisplayNotification = true
			timer.Simple(5.1, function()
				UVBustedState = false
				UVHUDDisplayNotification = nil
			end)
		end

		if UVHUDDisplayPursuit and not UVPlayingRace then
			UVSoundBusted( UVHeatLevel )
		end
	end)

	net.Receive("UVHUDEvading", function()
		UVEvadingProgress = net.ReadString()
	end)

	net.Receive("UVHUDCooldown", function()

		UVCooldownTimer = net.ReadString()
		UVHUDDisplayCooldown = true

	end)

	net.Receive("UVHUDStopCooldown", function()

		UVHUDDisplayCooldown = nil

	end)

	net.Receive("UVHUDHiding", function()
		local blink = 255 * math.abs(math.sin(RealTime() * 6))
		if UVHUDCopMode then return end
		UVNotificationColor = Color( blink, blink, 255)
		UVNotification = "--- " .. UVString("uv.chase.hiding") .. " ---"
		UVHUDDisplayNotification = true
		UVHUDDisplayHidingPrompt = true

	end)

	net.Receive("UVHUDStopHiding", function()

		UVHUDDisplayNotification = nil
		UVHUDDisplayHidingPrompt = nil

	end)

	net.Receive("UVHUDCopMode", function()
		UVHUDCopMode = true
	end)

	net.Receive("UVHUDStopCopMode", function()
		UVHUDCopMode = nil
	end)

	net.Receive("UVHUDCopModeBusting", function()
		local enemy = net.ReadEntity()
		enemy.beingbusted = true
	end)

	net.Receive("UVHUDStopCopModeBusting", function()
		local enemy = net.ReadEntity()
		enemy.beingbusted = nil
	end)

	net.Receive("UVHUDOneCommander", function()
		UVHUDCommander = net.ReadEntity()
		if UVHUDCommander.IsGlideVehicle then 
			if UVHUDCommander.MaxChassisHealth ~= UVUOneCommanderHealth:GetInt() then
				UVHUDCommander.MaxChassisHealth = UVUOneCommanderHealth:GetInt()
			end
		end
		if not UVOneCommanderActive and IsValid(UVHUDCommander) then
			UVOneCommanderActive = true
			local MathSound = math.random(1,6)
			surface.PlaySound("ui/pursuit/commanderonscene/commanderonscene"..MathSound..".wav")
		end
	end)

	net.Receive("UVHUDStopOneCommander", function()
		UVOneCommanderActive = nil
	end)

	net.Receive("UVHUDHeatLevelIncrease", function()
		UVHUDScreenFlashHeatUp = CurTime()

		if not lastHeatlevel then
			lastHeatlevel = tonumber( UVHeatLevel )
		end
		
		UV_UI.general.events.CenterNotification({
			text = string.format( UVString("uv.hud.heatlvl"), UVHeatLevel + 1 )
		})

		if not UVPlayingRace and UVHUDDisplayPursuit then
			if not PursuitThemePlayRandomHeat:GetBool() or (PursuitThemePlayRandomHeat:GetBool() and PursuitThemePlayRandomHeatType:GetString() ~= "everyminutes") then
				UVHeatLevelIncrease = true
				UVStopSound()
			end
		end

		-- if not UVPlayingRace and (UVHUDDisplayPursuit and not (PursuitThemePlayRandomHeat:GetBool() and PursuitThemePlayRandomHeatType:GetString() == "everyminutes")) then
		-- 	UVHeatLevelIncrease = true
		-- 	UVStopSound()
		-- end
	end)

	net.Receive("UVHUDPursuitTech", function()
		local PursuitTech = net.ReadTable()
		UVHUDPursuitTech = PursuitTech
	end)

	net.Receive("UVHUDScanner", function()
		local posx = net.ReadInt(32)
		local posy = net.ReadInt(32)
		local posz = net.ReadInt(32)

		UVHUDScanner = true
		UVHUDScannerPos.x = posx
		UVHUDScannerPos.y = posy
		UVHUDScannerPos.z = posz
	end)

	net.Receive("UVHUDAddUV", function()
		local entIndex = net.ReadInt( 32 )
		local creationId = net.ReadInt( 32 )

		table.insert( EntityQueue, {
			entIndex = entIndex,
			creationId = creationId,
			entType = net.ReadString()
		} )
	end)

	net.Receive("UVHUDRemoveUV", function()
		local entIndex = net.ReadInt(32)
		local creationId = net.ReadInt(32)

		table.insert(CleanupTask, {
			entIndex,
			creationId,
			function( entIndex, creationId )
				local entity = Entity( entIndex )

				if not IsValid(entity) then return true end
				if entity:GetCreationID() ~= creationId then return end

				if ent then
					table.RemoveByValue( UnitTable, ent )
				end

				if GMinimap then
					local blip = GMinimap:FindBlipByID("UVBlip" .. entIndex)
					if not blip then return end

					blip.color = Color( 255, 255, 255)
					blip.disabled = true
				end

				return true
			end
		})
	end)

	local corner8tex, corner32tex = surface.GetTextureID("gui/corner8"), surface.GetTextureID("gui/corner32")
	local function drawCircle(x, y, radius, seg)
		surface.SetTexture(radius <= 8 and corner8tex or corner32tex)
		surface.DrawTexturedRectUV( x-radius, y-radius, radius, radius, 0, 0, 1, 1 )
		surface.DrawTexturedRectUV( x, y-radius, radius, radius, 1, 0, 0, 1 )
		surface.DrawTexturedRectUV( x-radius, y, radius, radius, 0, 1, 1, 0 )
		surface.DrawTexturedRectUV( x, y, radius, radius, 1, 1, 0, 0 )
		draw.NoTexture()
	end

	hook.Add( "CanSeePlayerBlip", "RestrictPlayerBlipsExample", function( ply )
		if UVHUDCopMode then
			return false
		end
		return not UVHUDDisplayPursuit
	end )

	outofpursuit = 0

	function UVGetRandomHeat()
		local pursuitTheme = PursuitTheme:GetString()
		if not PursuitFilePathsTable[pursuitTheme] then return end

		local heatTable = PursuitFilePathsTable[PursuitTheme:GetString()].heat
		local heatCount = 0
		local isExcluded = false
		
		if heatTable then
			for i, v in pairs(heatTable) do
				if i ~= 'default' then
					heatCount = heatCount + 1
				end
			end
		end

		local newHeat = nil
		if heatCount > 0 then
			newHeat = math.random( 1, heatCount )
			while newHeat == UVSelectedHeatTrack and heatCount ~= 1 do
				newHeat = math.random( 1, heatCount )
			end
		else
			newHeat = 'default'
		end

		if not UVHeatPlayIntro then
			UVStopSound()
			UVHeatPlayTransition = true
		end

		UVLastHeatLevel = UVSelectedHeatTrack
		UVSelectedHeatTrack = newHeat
	end

	function UVResetRandomHeatTrack()
		if UVPlayingRace then return end
		UVLastHeatChange = CurTime()
		UVGetRandomHeat()
	end

	hook.Add("Think", "UVThink", function()

		local localPlayer = LocalPlayer()
		local vehicle = localPlayer:GetVehicle()
		local isValidVehicle = IsValid( vehicle )

		local var = UVKeybindSkipSong:GetInt()
		local varprev = UVKeybindPrevSong:GetInt()

		if isValidVehicle then
			if input.IsKeyDown(var) and not gui.IsGameUIVisible() and vgui.GetKeyboardFocus() == nil then localPlayer:ConCommand('uv_skipsong') end
			if input.IsKeyDown(varprev) and not gui.IsGameUIVisible() and vgui.GetKeyboardFocus() == nil then localPlayer:ConCommand('uv_prevsong') end
		end

		for i, v in pairs( EntityQueue ) do
			if InitEntity( v.entIndex, v.creationId, v.entType ) then
				table.remove( EntityQueue, i )
			end
		end

		for i, array in pairs( CleanupTask ) do
			if array[3]( array[1], array[2] ) then
				table.remove( CleanupTask, i )
			end
		end

		if (not UVHUDDisplayPursuit) and ((not UVHUDDisplayRacing) or (not UVHUDRace)) then
			if not UVHUDRace and (RacingMusic:GetBool() and UVTraxFreeroam:GetBool()) and vehicle ~= NULL then
				UVSoundRacing()
			else
				UVStopSound()

				UVHUDDisplayBackupTimer = nil
				UVLoadedSounds = nil

				if UVSoundLoop then
					UVSoundLoop:Stop()
					UVSoundLoop = nil
				end
			end
		elseif (UVHUDDisplayPursuit or UVHUDDisplayRacing) then
			--if not RacingMusicPriority:GetBool() then
			if (UVHUDDisplayRacing and not RacingMusic:GetBool() and not UVHUDDisplayPursuit) or (UVHUDDisplayPursuit and not PlayMusic:GetBool()) then
				UVStopSound()
				if UVSoundLoop then
					UVSoundLoop:Stop()
					UVSoundLoop = nil
				end
			end
			--end
		end
		
		if UVHUDDisplayPursuit then
			if PursuitThemePlayRandomHeat:GetBool() and PursuitThemePlayRandomHeatType:GetString() == "everyminutes" then
				if CurTime() - UVLastHeatChange > PursuitThemePlayRandomHeatMinutes:GetInt() * 60 then
					UVResetRandomHeatTrack()
				end
			end
		end

		if vehicle == NULL then 
			UVHUDDisplayBusting = false
			UVHUDPursuitTech = nil
			return 
		end

		if UVHUDDisplayPursuit then
			if not UVCooldownProgress then UVCooldownProgress = 0 end

			if UVHUDDisplayCooldown or UVBustedState then
				if not UVTimerFroze then
					UVTimerWhenFroze = CurTime() - UVCooldownProgress
					UVTimerFroze = true
				end
			else
				UVTimerFroze = false
			end

			if not UVTimerFroze and PursuitTable.PursuitStart then
				UVTimerProgress = CurTime() - tonumber( PursuitTable.PursuitStart ) - UVCooldownProgress
			else
				UVCooldownProgress = CurTime() - UVTimerWhenFroze
			end
		else
			UVHeatPlayIntro = true 
			UVHeatLevelIncrease = false
			UVHeatPlayTransition = false
			UVLastHeatChange = CurTime()
			UVHUDDisplayBackupTimer = nil
		end

		UVHUDWantedSuspectsNumber = #UVHUDWantedSuspects

		UVHUDDisplayPursuit = PursuitTable.InPursuit
		--UVHUDDisplayCooldown = PursuitTable.InCooldown
		UVHeatLevel = tonumber( PursuitTable.Heat )
		UVUnitsChasing = PursuitTable.UnitsChasing
		UVResourcePoints = PursuitTable.ResourcePoints
		UVDeploys = PursuitTable.Deploys
		UVPursuitLength = PursuitTable.PursuitLength
		UVWrecks = PursuitTable.Wrecks
		UVTags = PursuitTable.Tags
		UVBounty = string.Comma( PursuitTable.Bounty )
		UVBountyNo = PursuitTable.Bounty
		UVTimer = (UVTimerProgress and UVDisplayTime( UVTimerProgress )) or UVDisplayTime( 0 )

		if not UVBustedState then
			if UVHUDDisplayPursuit then
				if not PlayMusic:GetBool() and not UVPlayingRace then 
					UVStopSound()
					if UVSoundLoop then
						UVSoundLoop:Stop()
						UVSoundLoop = nil
					end
				else
					if not UVHUDDisplayBusting and not UVHUDDisplayCooldown and not UVHUDDisplayNotification then
						UVSoundHeat( UVHeatLevel )
					elseif UVHUDDisplayCooldown then
						UVSoundCooldown( UVHeatLevel )
					elseif UVHUDDisplayBusting and (UVHUDCopMode and UVHUDWantedSuspectsNumber == 1) or not UVHUDCopMode then
						local UVBustTimer = BustedTimer:GetFloat()
						local timeLeft = ((UVHUDDisplayNotification and -1) or (UVBustTimer - UVBustingProgress))

						if timeLeft <= UVBustTimer * 0.7 then
							UVSoundBusting( UVHeatLevel )
						end
					end
				end
			end
		end
	end)
	
	local UVHUDScreenFlashDuration = 1.25

	local function DrawScreenFlash(startTime, color)
		local elapsed = CurTime() - tonumber(startTime)
		if elapsed >= UVHUDScreenFlashDuration then return end

		local alphaFrac
		if elapsed < (UVHUDScreenFlashDuration / 6) then
			-- Quick fade-in (first 1/6)
			alphaFrac = elapsed / (UVHUDScreenFlashDuration / 6)
		else
			-- Smooth fade-out (remaining 5/6)
			local fadeOutFrac = (elapsed - (UVHUDScreenFlashDuration / 6)) / (UVHUDScreenFlashDuration * (5/6))
			alphaFrac = 1 - (fadeOutFrac ^ 2)
		end

		local alpha = 255 * math.Clamp(alphaFrac, 0, 1)
		surface.SetMaterial(UVMaterials["SCREENFLASH_SMALL"])
		surface.SetDrawColor(color.r, color.g, color.b, alpha)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	hook.Add( "HUDPaint", "UVHUDPursuit", function() --HUD

		local localPlayer = LocalPlayer()
		local vehicle = localPlayer:GetVehicle()

		local w = ScrW()
		local h = ScrH()

		local hudyes = showhud:GetBool()
		local lang = UVString
		
		local main = UVHUDTypeMain:GetString()
		local backup = UVHUDTypeBackup:GetString()

		DrawScreenFlash(PursuitTable.PursuitStart, Color(255, 255, 255)) -- white flash
		DrawScreenFlash(UVHUDScreenFlashHeatUp, Color(0, 0, 255))        -- blue flash

		local hudHandler = UV_UI.pursuit[main] and UV_UI.pursuit[main].main

		if not hudHandler then
			hudHandler = UV_UI.pursuit[backup] and UV_UI.pursuit[backup].main
		end

		local displayingracingandpursuit

		if hudHandler then
			hudHandler()

			if UV_UI.pursuit.original and UV_UI.pursuit.original.main and hudHandler == UV_UI.pursuit.original.main and UVHUDDisplayPursuit then -- Displays both racing and pursuit
				displayingracingandpursuit = true
			end
		end

		if UV_UI.general then
			UV_UI.general.main()
		end

		local var = UVKeybindResetPosition:GetInt()

		if not displayingracingandpursuit then
			if not UVHUDCopMode and ((not UVHUDDisplayPursuit or UVHUDRace) and UVHUDDisplayBusting) then  -- Being fined/busted in a race
				local UVBustTimer = BustedTimer:GetFloat()
				local finetext = "uv.chase.fining"

				if UVHUDDisplayPursuit then
					finetext = "uv.chase.busting.other"
				end

				local bottomy = h * 0.89

				if not BustingProgress or BustingProgress == 0 then
					BustingProgress = CurTime()
				end

				local blink = 255 * math.abs(math.sin(RealTime() * 4))

				local timeLeft = ((UVHUDDisplayNotification and -1) or (UVBustTimer - UVBustingProgress))

				draw.SimpleTextOutlined( UVString(finetext), "UVMostWantedLeaderboardFont", w * 0.5, bottomy - h * 0.025, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0, 255) )

				surface.SetDrawColor(200, 200, 200, 125)
				surface.DrawRect(w * 0.4, bottomy, w * 0.2, h * 0.015)

				local T = math.Clamp((UVBustingProgress / UVBustTimer) * (w * 0.2), 0, w * 0.2)
				surface.SetDrawColor(255, 100, 100)
				surface.DrawRect(w * 0.4, bottomy, T, h * 0.015)
			else
				BustingProgress = 0
			end
		end
		
		local devMode = GetConVar("developer"):GetBool()
		
		-- if UVSubtitles:GetBool() and UV_CurrentSubtitle and CurTime() < (UV_SubtitleEnd or 0) then
			-- local text = lang(UV_CurrentSubtitle)
			-- local textcs = lang(UV_CurrentSubtitleCallsign or " ")
			-- local font = "UVMostWantedLeaderboardFont"
			-- local maxWidth = w * 0.4  -- maximum width of the subtitle block
			-- local bgPadding = 8
			-- local outlineAlpha = 150

			-- surface.SetFont(font)
			-- if text == "" or text == UV_CurrentSubtitle then -- invalid or missing localization; Active for debugging purposes
			-- else
				-- local lines = {}
				-- local currentLine = ""
				-- for word in text:gmatch("%S+") do
					-- local testLine = (currentLine == "" and "" or currentLine .. " ") .. word
					-- local textWidth, _ = surface.GetTextSize(testLine)
					-- if textWidth > maxWidth then
						-- if currentLine ~= "" then
							-- table.insert(lines, currentLine)
						-- end
						-- currentLine = word
					-- else
						-- currentLine = testLine
					-- end
				-- end
				-- if currentLine ~= "" then
					-- table.insert(lines, currentLine)
				-- end

				-- local lineHeight = select(2, surface.GetTextSize("A")) * 1.2
				-- local totalHeight = #lines * lineHeight + (h * 0.02)

				-- local bgX = w * 0.5 - maxWidth * 0.5 - bgPadding
				-- local bgY = h * 0.7275 - bgPadding
				-- local bgW = maxWidth + bgPadding * 2
				-- local bgH = totalHeight + bgPadding * 2

				-- draw.RoundedBox(12, bgX, bgY, bgW, bgH, Color(0, 0, 0, 150))

				-- for i, line in ipairs(lines) do
									
					-- draw.SimpleTextOutlined( textcs, font, w * 0.5, h * 0.725, Color(255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0, outlineAlpha) )
					-- draw.SimpleTextOutlined( line, font, w * 0.5, h * 0.755 + (i - 1) * lineHeight, pcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0, outlineAlpha) )
				-- end
			-- end
		-- end

		-- if UVHUDCopMode and input.IsKeyDown(var) and not gui.IsGameUIVisible() and vgui.GetKeyboardFocus() == nil then
		if input.IsKeyDown(var) and not gui.IsGameUIVisible() and vgui.GetKeyboardFocus() == nil then
			local localPlayer = LocalPlayer()

			if localPlayer.uvspawningunit and not localPlayer.uvunitselectdelayed then
				net.Start("UVCancelUnitRespawn")
				net.SendToServer()

				localPlayer.uvunitselectdelayed = true
				timer.Simple(1, function()
					if localPlayer.uvunitselectdelayed then
						localPlayer.uvunitselectdelayed = nil
					end
				end)
			elseif not localPlayer.uvunitselectdelayed then
				LocalPlayer():ConCommand('uvrace_resetposition')
				localPlayer.uvunitselectdelayed = true
				timer.Simple(1, function()
					if localPlayer.uvunitselectdelayed then
						localPlayer.uvunitselectdelayed = nil
					end
				end)
			end
		end

		if UVHUDDisplayPursuit and vehicle ~= NULL then
			if UVOneCommanderActive and hudyes then
				if IsValid(UVHUDCommander) then
					UVRenderCommander(UVHUDCommander)
				end
			end
		end

		local entities = ents.GetAll()
		local box_color = Color(0, 255, 0)

		
		if UVHUDPursuitRespawnNoticeStarted and not UVHUDPursuitRespawnNoticeTriggered then
			UVHUDPursuitRespawnNoticeTriggered = true
			UVHUDPursuitRespawnNoticeStartTime = CurTime()
		end

		if not UVHUDPursuitRespawnNoticeStarted then
			UVHUDPursuitRespawnNoticeTriggered = false
		end

		if localPlayer.uvspawningunit and localPlayer.uvspawningunit.vehicle then
			local now = CurTime()
			local startTime = localPlayer.uvspawningunit.startTime
			local animTime = now - startTime

			-- Copied over
			local elapsed = CurTime() - localPlayer.uvspawningunit.startTime
			local remaining = math.max(0, localPlayer.uvspawningunit.cooldown - elapsed)
			local carn = lang(localPlayer.uvspawningunit.vehicle)
			local timel = string.format("%.1f", remaining)
					
			-- Phase durations
			local delay = 0.1
			local expandDuration = 0.25
			local whiteFadeInDuration = 0.025
			local blackFadeOutDuration = 1

			local expandStart = delay
			local whiteStart = expandStart + expandDuration
			local blackStart = whiteStart + whiteFadeInDuration
			local endAnim = blackStart + blackFadeOutDuration

			-- Compute bar width
			local barProgress = 0
			if animTime >= expandStart then
				barProgress = math.Clamp((animTime - expandStart) / expandDuration, 0, 1)
			end

			local currentWidth = Lerp(barProgress, 0, w)
			local barHeight = h * 0.075
			local barX = (w - currentWidth) / 2
			local barY = h - barHeight

			-- Compute bar color
			local colorVal = 0
			if animTime >= whiteStart and animTime < blackStart then
				-- black → white
				local p = (animTime - whiteStart) / whiteFadeInDuration
				colorVal = Lerp(math.Clamp(p, 0, 1), 0, 255)
			elseif animTime >= blackStart then
				-- white → black
				local p = (animTime - blackStart) / blackFadeOutDuration
				colorVal = Lerp(math.Clamp(p, 0, 1), 255, 0)
			end

			-- Draw bar
			surface.SetMaterial(UVMaterials["RESPAWN_BG"])
			surface.SetDrawColor(Color(colorVal, colorVal, colorVal, 255))
			surface.DrawTexturedRect(barX, barY, currentWidth, barHeight)

			-- Display text only after bar is white or fading
			if animTime >= whiteStart then
				local outlineAlpha = math.Clamp(255 - colorVal, 0, 255)
				local text = "%s %s"
				if RandomPlayerUnits:GetBool() then
					text = string.format( lang("uv.chase.select.spawning.cooldown.random"), timel )
				else
					text = string.format( lang("uv.chase.select.spawning.cooldown"), carn, timel )
				end
				
				-- draw.SimpleTextOutlined( text, "UVFont5", w * 0.5, h * 0.9, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0, outlineAlpha) )
				-- draw.SimpleTextOutlined( string.format( lang("uv.chase.select.spawning.cooldown2"), UVBindButtonName(UVKeybindResetPosition:GetInt()) ), "UVFont5", w * 0.5, h * 0.95, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0, outlineAlpha) )
				
				-- draw.SimpleTextOutlined( text, "UVFont5", w * 0.5, h * 0.9, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0, outlineAlpha) )
				-- draw.SimpleTextOutlined( string.format( lang("uv.chase.select.spawning.cooldown2"), UVBindButtonName(UVKeybindResetPosition:GetInt()) ), "UVFont5", w * 0.5, h * 0.95, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1.25, Color(0, 0, 0, outlineAlpha) )
				
				
				local keyCode = GetConVar("unitvehicle_keybind_resetposition"):GetInt()
				local keyText = string.lower(UVBindButtonName(keyCode))

				markup.Parse( "<font=UVSettingsFontBig>" .. text .. "</font>", w ):Draw(w * 0.5, h * 0.925, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				markup.Parse( "<font=UVSettingsFontBig>" .. string.format( lang("uv.chase.select.spawning.cooldown2"), UVReplaceKeybinds( "[key:unitvehicle_keybind_resetposition]", "Big" ) ) .. "</font>", w ):Draw(w * 0.5, h * 0.96, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		end

		if not RacerTags:GetBool() or uvclientjammed then
			if GMinimap then
				for _, ent in pairs(UVHUDWantedSuspects) do
					if ent.displayedonhud then
						local curblip = GMinimap:FindBlipByID("UVBlip"..ent:EntIndex())

						if curblip then 
							curblip.alpha = 0
						end
					end
				end
			end
		end

		-- if RacerTags:GetBool() and UVHUDWantedSuspects and UVHUDCopMode and not uvclientjammed then
		if RacerTags:GetBool() and vehicle and UVHUDWantedSuspects and not uvclientjammed and (not UVHUDRace or UVHUDCopMode) then
			if next(UVHUDWantedSuspects) ~= nil then
				local renderQueue = {}

				for _, ent in pairs(UVHUDWantedSuspects) do
					if not IsValid(ent) then continue end
					if ent:IsVehicle() and UVGetDriver(ent) == LocalPlayer() then continue end
					local dist = LocalPlayer():GetPos():Distance(ent:GetPos())
					table.insert(renderQueue, { vehicle = ent, dist = dist })
				end
				-- Sort so farther ones draw first, closer ones last (on top)
				table.sort(renderQueue, function(a, b)
					return a.dist < b.dist
				end)

				local maxSquares = 4
				local numToRender = math.min(#renderQueue, maxSquares)

				-- Render farthest first so closest overlays on top
				for i = numToRender, 1, -1 do
					local data = renderQueue[i]
					if data and IsValid(data.vehicle) then
						UVRenderEnemySquare(data.vehicle)
					end
				end

				-- Handle minimap blips *after* rendering
				-- if UVHUDCopMode then -- Only as a Cop
					for _, ent in pairs(UVHUDWantedSuspects) do
						if not IsValid(ent) then continue end

						if not GMinimap then continue end
						if not ent.displayedonhud then
							ent.displayedonhud = true
							local blip, id = GMinimap:AddBlip({
								id = "UVBlip" .. ent:EntIndex(),
								parent = ent,
								icon = "unitvehicles/icons/MINIMAP_ICON_CAR.png",
								scale = 1.4,
								color = Color(255, 191, 0),
							})
							if ent:GetClass() == "prop_vehicle_jeep" then
								blip.icon = "unitvehicles/icons/MINIMAP_ICON_CAR_JEEP.png" -- Icon points the other way
							end
						end
						
						if UVHUDCopMode and ent.displayedonhud then-- *This* only for Units
							local curblip = GMinimap:FindBlipByID("UVBlip" .. ent:EntIndex())
							if not curblip then continue end

							if ((UVHUDCopMode and UVHUDDisplayCooldown) or 
								(not ent.inunitview) and 
								not ((not GetConVar("unitvehicle_unit_onecommanderevading"):GetBool()) and UVOneCommanderActive)) 
							then
								curblip.alpha = 0
							else
								curblip.alpha = 255
							end
						end
					end
				-- end
			end
		end

		if UVHUDRoadblocks then
			if next(UVHUDRoadblocks) ~= nil then
				for _, roadblock in pairs(UVHUDRoadblocks) do
					if roadblock.location and roadblock.name then
						UVRenderRoadblock(roadblock.location, roadblock.name)
					end
				end
			end
		end

		if UVHUDPursuitBreakers then
			if next(UVHUDPursuitBreakers) ~= nil then
				for _, pos in pairs(UVHUDPursuitBreakers) do
					UVRenderPursuitBreaker(pos)
				end
			end
		end

		if UVHUDMarkedPursuitBreakers then
			if next(UVHUDMarkedPursuitBreakers) ~= nil then
				for _, pb in pairs(UVHUDMarkedPursuitBreakers) do
					if pb.location and pb.name then
						UVRenderMarkedPursuitBreaker(pb.location, pb.name)
					end
				end
			end
		end

		local areUnitsPresent = (#UnitTable > 0)

		--Police Scanner
		if UVPoliceScanner:GetBool() and (not UVHUDDisplayPursuit or UVHUDDisplayCooldown) and not UVHUDCopMode and not uvclientjammed and localPlayer:InVehicle() and areUnitsPresent then
			local scannerHandler

			-- Main HUD scanner config
			local scannerConfig =
			(UV_UI.pursuit[main] and UV_UI.pursuit[main].scannerConfig)
			or (UV_UI.pursuit[backup] and UV_UI.pursuit[backup].scannerConfig)
			or UV_UI.pursuit.general.scannerConfig
			or {
				radius = 30,
				innerRadius = 14,
				blipRadius = 8,
				maxRange = 5000,
				maxArc = 360,
				posX = w/2,
				posY = h/10,
			}

			-- HUD scanner
			if UV_UI.pursuit[main] and UV_UI.pursuit[main].scanner then scannerHandler = UV_UI.pursuit[main].scanner end
			if not scannerHandler and UV_UI.pursuit[backup] and UV_UI.pursuit[backup].scanner then scannerHandler = UV_UI.pursuit[backup].scanner end
			
			if not scannerHandler then scannerHandler = UV_UI.pursuit.general.scanner end
			
			if scannerHandler then
				scannerHandler({
					radius = scannerConfig.radius,
					innerRadius = scannerConfig.innerRadius,
					blipRadius = scannerConfig.blipRadius,
					maxRange = scannerConfig.maxRange,
					maxArc = scannerConfig.maxArc,
					posX = scannerConfig.posX,
					posY = scannerConfig.posY,

					localPlayer = localPlayer,
					w = w,
					h = h
				})
			end
		end

		if UVEMPLockingTarget then
			local diff = CurTime() - (UVEMPLockingStart or 0)

			local isUnit = table.HasValue( UnitTable, UVEMPLockingTarget )
			local maxDistance = math.pow( ( isUnit and UVUnitPTEMPMaxDistance:GetInt() ) or UVPTEMPMaxDistance:GetInt(), 2 )

			if diff > 5 then 
				UVEMPLockingStart = nil
				UVEMPLockingTarget = nil
				UVEMPLockingSource = nil

				return
			end

			if not vehicle then return end
			if not IsValid(UVEMPLockingTarget) or not IsValid(UVEMPLockingSource) then return end

			local vector = UVEMPLockingTarget:WorldSpaceCenter()
			local screenPos = vector:ToScreen()

			local timeStamps = {
				5 * 0.2, 
				5 * 0.4, 
				5 * 0.6,
				5 * 1.0
			}

			local selectedTimeStamp = nil

			for _, timeStamp in pairs(timeStamps) do
				if diff <= timeStamp then
					selectedTimeStamp = timeStamp
					break
				end
			end

			local blink = math.sin(CurTime() * (selectedTimeStamp + 5)) * 10
			local spaceCount = #timeStamps - selectedTimeStamp
			local spaceString = string.rep(" ", spaceCount)
			local selectedColor = nil

			if UVIsVehicleInCone(UVEMPLockingSource, UVEMPLockingTarget, 90, maxDistance) then
				selectedColor = Color(255, 255 * blink, 255 * blink)
			else
				selectedColor = Color(255, 255, 255, 100)
			end

			draw.DrawText("[" .. spaceString .. " <> " .. spaceString .. "]", "UVFont4", screenPos.x, screenPos.y, selectedColor, TEXT_ALIGN_CENTER)
		end

	end)

	function UVMarkAllLocationsPB()
		if not UVHUDMarkedPursuitBreakers then
			UVHUDMarkedPursuitBreakers = {}
		else
			if next(UVHUDMarkedPursuitBreakers) ~= nil then
				return
			end
		end

		local saved_pbs = file.Find("unitvehicles/pursuitbreakers/"..game.GetMap().."/*.json", "DATA")
		for k,jsonfile in pairs(saved_pbs) do
			local JSONData = file.Read( "unitvehicles/pursuitbreakers/"..game.GetMap().."/"..jsonfile, "DATA" )
			if not JSONData then return end

			local rbdata = util.JSONToTable(JSONData, true) --Load PB

			local name = jsonfile
			local location = rbdata.Location or rbdata.Maxs
			if not location then return end

			local tabletoinsert = {}
			tabletoinsert.location = location
			tabletoinsert.name = name

			table.insert(UVHUDMarkedPursuitBreakers, tabletoinsert)

			timer.Simple(10, function()
				if not UVHUDMarkedPursuitBreakers then return end
				UVHUDMarkedPursuitBreakers = {}
			end)

		end
	end

	function UVMarkAllLocations()
		if not UVHUDRoadblocks then
			UVHUDRoadblocks = {}
		else
			if next(UVHUDRoadblocks) ~= nil then
				return
			end
		end

		local saved_roadblocks = file.Find("unitvehicles/roadblocks/"..game.GetMap().."/*.json", "DATA")
		for k,jsonfile in pairs(saved_roadblocks) do
			local JSONData = file.Read( "unitvehicles/roadblocks/"..game.GetMap().."/"..jsonfile, "DATA" )
			if not JSONData then return end

			local rbdata = util.JSONToTable(JSONData, true) --Load Roadblock

			local name = jsonfile
			local location = rbdata.Location or rbdata.Maxs
			if not location then return end

			local tabletoinsert = {}
			tabletoinsert.location = location
			tabletoinsert.name = name

			table.insert(UVHUDRoadblocks, tabletoinsert)

			timer.Simple(10, function()
				if not UVHUDRoadblocks then return end
				UVHUDRoadblocks = {}
			end)

		end
	end

	function UVRenderRoadblock(pos, name)
		local localPlayer = LocalPlayer()
		local box_color = Color(255, 255, 0)

		if IsValid(localPlayer) then
			local pos = pos

			local MaxX, MinX, MaxY, MinY
			local isVisible = false

			local p = pos
			local screenPos = p:ToScreen()
			isVisible = screenPos.visible

			if MaxX ~= nil then
				MaxX, MaxY = math.max(MaxX, screenPos.x), math.max(MaxY, screenPos.y)
				MinX, MinY = math.min(MinX, screenPos.x), math.min(MinY, screenPos.y)
			else
				MaxX, MaxY = screenPos.x, screenPos.y
				MinX, MinY = screenPos.x, screenPos.y
			end

			local textX = (MinX + MaxX) / 2
			local textY = MinY - 20
			cam.Start2D()
			draw.DrawText(name.."\nv", "UVFont4", textX, textY - 30, box_color, TEXT_ALIGN_CENTER)
			cam.End2D()
		end
	end

	function UVRenderPursuitBreaker(pos)
		local localPlayer = LocalPlayer()

		if IsValid(localPlayer) then
			local w = ScrW()
			local h = ScrH()
			local pos = pos

			local screenPos = pos:ToScreen()
			if not screenPos.visible then return end
			
			local textX = screenPos.x
			local textY = screenPos.y -- This is in pixels and stays consistent
        
			-- Distance in meters
			local fadeAlpha = 1
			local fadeDist = 150

			local dist = localPlayer:GetPos():Distance(pos)
			local distMeters = dist * 0.01905

			if distMeters <= fadeDist then
				fadeAlpha = 1 * ((fadeDist - distMeters) / 25)
			elseif distMeters > fadeDist then
				fadeAlpha = 0
			end
			
			-- Edge fade (screen position based)
			local edgeFadeAlpha = 1

			local edgeStartX = w * 0.2
			local edgeEndX = w * 0.8
			local edgeStartY = h * 0.2
			local edgeEndY = h * 0.8

			-- Horizontal fade
			if textX < w * 0.05 or textX > w * 0.95 then
				edgeFadeAlpha = 0
			elseif textX < edgeStartX then
				edgeFadeAlpha = 1 * ((textX - w * 0.05) / (edgeStartX - w * 0.05))
			elseif textX > edgeEndX then
				edgeFadeAlpha = 1 * ((w * 0.95 - textX) / (w * 0.95 - edgeEndX))
			end

			-- Vertical fade
			if textY < h * 0.05 or textY > h * 0.95 then
				edgeFadeAlpha = math.min(edgeFadeAlpha, 0)
			elseif textY < edgeStartY then
				edgeFadeAlpha = math.min(edgeFadeAlpha, 1 * ((textY - h * 0.05) / (edgeStartY - h * 0.05)))
			elseif textY > edgeEndY then
				edgeFadeAlpha = math.min(edgeFadeAlpha, 1 * ((h * 0.95 - textY) / (h * 0.95 - edgeEndY)))
			end

			-- Combine with distance fade
			fadeAlpha = math.min(fadeAlpha, edgeFadeAlpha)
			
			-- Base size at some reference distance
			local baseSize = 50
			local referenceDist = 25

			-- Scale factor decreases with distance
			local minSize, maxSize = 0, 75
			local scale = math.Clamp(baseSize * (referenceDist / math.max(distMeters, 1)), minSize, maxSize)

			cam.Start2D()
			-- draw.DrawText(math.Round(distMeters) .. " m", "UVFont4", textX, textY - 65, Color(255, 0, 0, 255 * fadeAlpha), TEXT_ALIGN_CENTER)

			surface.SetDrawColor( 255, 127, 127, 255 * fadeAlpha)
			surface.SetMaterial(UVMaterials["PBREAKER"])
			surface.DrawTexturedRectRotated( textX, textY - 15, scale, scale, 0)

			cam.End2D()
		end
	end

	function UVRenderMarkedPursuitBreaker(pos, name)
		local localPlayer = LocalPlayer()
		local box_color = Color(255, 0, 0)

		if IsValid(localPlayer) then
			local pos = pos

			local MaxX, MinX, MaxY, MinY
			local isVisible = false

			local p = pos
			local screenPos = p:ToScreen()
			isVisible = screenPos.visible

			if MaxX ~= nil then
				MaxX, MaxY = math.max(MaxX, screenPos.x), math.max(MaxY, screenPos.y)
				MinX, MinY = math.min(MinX, screenPos.x), math.min(MinY, screenPos.y)
			else
				MaxX, MaxY = screenPos.x, screenPos.y
				MinX, MinY = screenPos.x, screenPos.y
			end

			local textX = (MinX + MaxX) / 2
			local textY = MinY - 20
			cam.Start2D()
			draw.DrawText(name.."\nv", "UVFont4", textX, textY - 30, box_color, TEXT_ALIGN_CENTER)
			cam.End2D()
		end
	end
	
	net.Receive( "UVHUDRespawnInUVPlyMsg", function()
		local msg = net.ReadString()
		local unit = net.ReadString() or ""
		local cooldown = net.ReadString()
		local msgt = string.format( UVString(msg), UVString(unit), cooldown )

		if (RandomPlayerUnits:GetBool() and cooldown) or not cooldown then
			msgt = string.format( UVString(msg), UVString(unit) )
		end

		UVMenu.CloseCurrentMenu()

		UV_UI.general.events.CenterNotification({
			text = msgt
		})
	end)
	
	net.Receive("UVSpawnQueueUpdate", function()
		local vehicle = net.ReadString()
		local cooldown = net.ReadInt(16)

		if vehicle == "" then
			UVHUDPursuitRespawnNoticeStarted = false
			LocalPlayer().uvspawningunit = nil
		else
			UVHUDPursuitRespawnNoticeStarted = true
			LocalPlayer().uvspawningunit = {
				vehicle = vehicle,
				cooldown = cooldown,
				startTime = CurTime()
			}
		end
	end)

	net.Receive("UVHUDRespawnInUVSelect", function()
		local UnitsPatrol     = net.ReadString()
		local UnitsSupport    = net.ReadString()
		local UnitsPursuit    = net.ReadString()
		local UnitsInterceptor= net.ReadString()
		local UnitsSpecial    = net.ReadString()
		local UnitsRhino      = net.ReadString()
		local UnitsCommander  = net.ReadString()

		local unittable = {
			UnitsPatrol,
			UnitsSupport,
			UnitsPursuit,
			UnitsInterceptor,
			UnitsSpecial,
			UnitsRhino,
			UnitsCommander
		}

		local unittablename = {
			"uv.unit.patrol",
			"uv.unit.support",
			"uv.unit.pursuit",
			"uv.unit.interceptor",
			"uv.unit.special",
			"uv.unit.rhino",
			"uv.unit.commander"
		}

		local unittablenpc = {
			"npc_uvpatrol",
			"npc_uvsupport",
			"npc_uvpursuit",
			"npc_uvinterceptor",
			"npc_uvspecial",
			"npc_uvspecial",
			"npc_uvcommander"
		}

		UVMenu.OpenMenu(function()
			UVMenu.PlaySFX("menuopen")
			UVMenu.UnitSelect(unittable, unittablename, unittablenpc)
		end, true)
	end)

	net.Receive( "UV_AddWantedVehicle", function()
		local entIndex = net.ReadInt( 32 )
		local creationId = net.ReadInt( 32 )

		-- EntityQueue[entIndex] = {
		-- 	creationId,
		-- 	'racer'
		-- }
		table.insert( EntityQueue, {
			entIndex = entIndex,
			creationId = creationId,
			entType = "racer"
		} )
	end)

	net.Receive( "UV_RemoveWantedVehicle", function()
		local entIndex = net.ReadInt( 32 )
		local entity = Entity( entIndex )

		if entity then
			table.RemoveByValue( UVHUDWantedSuspects, entity )
		end
	end)

	net.Receive( "UVUpdateSuspectVisibility" , function()
		local car = net.ReadEntity()
		local in_view = net.ReadBool()

		car.inunitview = in_view
	end)

	net.Receive( "UVRacerJoin" , function()
		local message = net.ReadString()
		chat.AddText(Color(127, 255, 159), message)
	end)

	net.Receive("UVHUDBustedDebrief", function()
		local debrieftable = net.ReadTable()

		if UVHUDCopMode then return end

		local UVDeploys = debrieftable["Deploys"]
		local UVRoadblocksDodged = debrieftable["Roadblocks"]
		local UVSpikestripsDodged = debrieftable["Spikestrips"]

		print("You have been busted by the Unit Vehicles!\n" .. 
			"Total Bounty - " .. string.Comma(UVBounty).."\n" .. 
			"Pursuit Duration - " .. UVTimer .. "\n" ..
			"Police Vehicles Involved - " .. UVDeploys .. "\n" ..
			"Damaged Police Vehicles - " .. UVTags .. "\n" ..
			"Immobilized Police Vehicles - " .. UVWrecks .. "\n" ..
			"Roadblocks Dodged - " .. UVRoadblocksDodged .. "\n" ..
			"Spike Strips Dodged - " .. UVSpikestripsDodged
		)

		timer.Simple(5, function()
			UVHUDDisplayBusting = false
			UVHUDDisplayNotification = false
		end)
				
		if UVMenu.CurrentMenu and IsValid(UVMenu.CurrentMenu) then
			UVMenu.CloseCurrentMenu()
			timer.Simple(0.5, function()
				hook.Run( 'UIEventHook', 'pursuit', 'onRacerBustedDebrief', debrieftable )
			end)
			return
		end
		hook.Run( 'UIEventHook', 'pursuit', 'onRacerBustedDebrief', debrieftable )
	end)

	net.Receive("UVHUDEscapedDebrief", function()
		local debrieftable = net.ReadTable()

		if UVHUDCopMode then return end

		local UVDeploys = debrieftable["Deploys"]
		local UVRoadblocksDodged = debrieftable["Roadblocks"]
		local UVSpikestripsDodged = debrieftable["Spikestrips"]

		print("You have escaped from the Unit Vehicles!\n" .. 
			"Total Bounty - " .. string.Comma(UVBounty).."\n" .. 
			"Pursuit Duration - " .. UVTimer .. "\n" ..
			"Police Vehicles Involved - " .. UVDeploys .. "\n" ..
			"Damaged Police Vehicles - " .. UVTags .. "\n" ..
			"Immobilized Police Vehicles - " .. UVWrecks .. "\n" ..
			"Roadblocks Dodged - " .. UVRoadblocksDodged .. "\n" ..
			"Spike Strips Dodged - " .. UVSpikestripsDodged
		)
		
		if UVMenu.CurrentMenu and IsValid(UVMenu.CurrentMenu) then
			UVMenu.CloseCurrentMenu()
			timer.Simple(0.5, function()
				hook.Run( 'UIEventHook', 'pursuit', 'onRacerEscapedDebrief', debrieftable )
			end)
			return
		end
		hook.Run( 'UIEventHook', 'pursuit', 'onRacerEscapedDebrief', debrieftable )
	end)

	net.Receive("UVHUDCopModeEscapedDebrief", function()
		local debrieftable = net.ReadTable()

		local UVDeploys = debrieftable["Deploys"]
		local UVRoadblocksDodged = debrieftable["Roadblocks"]
		local UVSpikestripsDodged = debrieftable["Spikestrips"]

		print("You lost ".. UVHUDWantedSuspectsNumber .." suspect(s)!\n" .. 
			"Total Bounty - " .. string.Comma(UVBounty).."\n" .. 
			"Pursuit Duration - " .. UVTimer .. "\n" ..
			"Police Vehicles Involved - " .. UVDeploys .. "\n" ..
			"Damaged Police Vehicles - " .. UVTags .. "\n" ..
			"Immobilized Police Vehicles - " .. UVWrecks .. "\n" ..
			"Roadblocks Dodged - " .. UVRoadblocksDodged .. "\n" ..
			"Spike Strips Dodged - " .. UVSpikestripsDodged
		)
		
		if UVMenu.CurrentMenu and IsValid(UVMenu.CurrentMenu) then
			UVMenu.CloseCurrentMenu()
			timer.Simple(0.5, function()
				hook.Run( 'UIEventHook', 'pursuit', 'onCopEscapedDebrief', debrieftable )
			end)
			return
		end
		hook.Run( 'UIEventHook', 'pursuit', 'onCopEscapedDebrief', debrieftable )
	end)

	net.Receive("UVHUDCopModeBustedDebrief", function()
		local debrieftable = net.ReadTable()

		local UVDeploys = debrieftable["Deploys"]
		local UVRoadblocksDodged = debrieftable["Roadblocks"]
		local UVSpikestripsDodged = debrieftable["Spikestrips"]

		print("You caught all the suspect(s)!\n" .. 
			"Total Bounty - " .. string.Comma(UVBounty).."\n" .. 
			"Pursuit Duration - " .. UVTimer .. "\n" ..
			"Police Vehicles Involved - " .. UVDeploys .. "\n" ..
			"Damaged Police Vehicles - " .. UVTags .. "\n" ..
			"Immobilized Police Vehicles - " .. UVWrecks .. "\n" ..
			"Roadblocks Dodged - " .. UVRoadblocksDodged .. "\n" ..
			"Spike Strips Dodged - " .. UVSpikestripsDodged
		)
		
		if UVMenu.CurrentMenu and IsValid(UVMenu.CurrentMenu) then
			UVMenu.CloseCurrentMenu()
			timer.Simple(0.5, function()
				hook.Run( 'UIEventHook', 'pursuit', 'onCopBustedDebrief', debrieftable )
			end)
			return
		end
		hook.Run( 'UIEventHook', 'pursuit', 'onCopBustedDebrief', debrieftable )
	end)

	net.Receive( "UVUpdateRacerName" , function()
		local racer_vehicle = net.ReadEntity()
		local racer_name = net.ReadString()

		racer_vehicle.racer = racer_name
	end)

	net.Receive('UV_Sound', function()
		local array = net.ReadTable()
		if not PursuitSFX:GetBool() and not string.match( array.FileName, "spottedfreezecam" ) then return end

		local audio_file = "sound/"..array.FileName
		local parameters = array.Parameter
		local can_skip = array.CanSkip

		if can_skip and IsValid(uvsoundplaying) and parameters ~= 2 then
			uvsoundplaying:Stop()
		end

		sound.PlayFile(audio_file, "", function(source, err, errname)
			if IsValid(source) then
				if not can_skip then
					uvsoundplaying = source
				end
				source:Play()
			end
		end)
	end)
	

	net.Receive('UV_Chatter', function()
		local init_time = net.ReadFloat()
		local audio_file = "sound/"..net.ReadString()
		local can_skip = net.ReadBool()
		local hasCallsign = net.ReadBool()
		local callsign = nil 
		if hasCallsign then
			callsign = net.ReadString()
		end

		-- build subtitle key
		local rel = string.gsub(audio_file, "^sound/chatter2/", "")
		rel = string.gsub(rel, "%.mp3$", "")
		rel = string.gsub(rel, "/", ".")
		local key = "uvsub."..string.lower(rel)

		if lastCanSkip == false and IsValid(uvchatterplaying) then
			local state = uvchatterplaying:GetState()
			if state ~= GMOD_CHANNEL_STOPPED and init_time ~= lastInitTime then return end
		end

		lastCanSkip = can_skip
		lastInitTime = init_time

		sound.PlayFile(audio_file, "", function(source, err, errname)
			if IsValid(source) then
				if IsValid(uvchatterplaying) then
					uvchatterplaying:Stop()
				end
				uvchatterplaying = source
				source:Play()
				source:SetVolume(ChatterVolume:GetFloat())
				
				local excludeSubstrings = {
					".misc.radioon",
					".misc.radiooff",
					".misc.emergency",
					".dispatch.idletalk",
					".bullhorn.",
				}

				local shouldUpdate = true
				for _, substr in ipairs(excludeSubstrings) do
					if string.find(key, substr, 1, true) then
						shouldUpdate = false
						break
					end
				end

				if shouldUpdate then
					UV_CurrentSubtitle = key
					UV_SubtitleEnd = CurTime() + source:GetLength()
					UV_CurrentSubtitleCallsign = callsign
				end
			end
		end)
	end)


	net.Receive('UVBusted', function()
		local array = net.ReadTable()

		local racer = array['Racer']
		local cop = array['Cop']
		local lp = false

		if racer == LocalPlayer():GetName() then lp = true end

		hook.Run( 'UIEventHook', 'pursuit', 'onRacerBusted', racer, cop, lp )
	end)

	net.Receive("UVHUDWreckedDebrief", function()
		UVMenu.OpenMenu(UVMenu.WreckedDebrief, true)
	end)

	hook.Add("PopulateToolMenu", "UVMenu", function()
		spawnmenu.AddToolMenuOption("Options", "uv.unitvehicles", "UVClientOptions", UVString("uv.ui.menu"), "", "", function(panel)
			local option
			
			panel:Clear()

			panel:Help(UVString("uv.tweakinmenu"))
			local OpenMenu = vgui.Create("DButton")
			OpenMenu:SetText(UVString("uv.tweakinmenu.open"))
			OpenMenu:SetSize(280, 20)
			OpenMenu.DoClick = function()
				UVMenu.OpenMenu(UVMenu.Main)
				UVMenu.PlaySFX("menuopen")
			end
			panel:AddItem(OpenMenu)

		end)
	end)

	local theme = PursuitTheme:GetString()
	if theme then
		PopulatePursuitFilePaths(theme)
	end

end