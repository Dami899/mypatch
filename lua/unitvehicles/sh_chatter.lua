AddCSLuaFile()

--[[References (* = not used, yet)
TEN-CODE
10-1: Receiving poorly
10-2: Receiving well
10-3: Stop transmitting
10-4: Message received and understood
10-5: Relay message
10-6: Responding from a distance
10-7: Detailed, out of service
10-8: In service
10-9: Repeat message
10-10: Negative, standing by
10-11: Talking too rapidly
*10-12: Visitors present
10-13: Advise weather/road conditions
10-16: Urgent pickup at location
10-17: Urgent business
10-18: Anything for us?
10-19: Nothing for you, return to base
10-20: Current location
10-21: Call by landline
*10-22: Report in person to
10-23: On scene
10-24: Completed last assignment
10-25: Out of service
10-26: Going for fuel
10-27: Moving to different radio channel
10-28: Identify your station
10-29: Run for wants and warrants
10-32: Wanted suspect
10-33: Officer needs help
10-34: Requesting Pursuit/Interceptor unit
10-35: Confidential information
10-36: Police unit traffic collision
10-37: Requesting tow truck
10-38: Requesting ambulance
10-39: PIT maneuver
10-41: Self PIT
10-42: Traffic accident
10-43: Traffic jam
10-44: Requesting Special/Commander unit
10-45: Ramming suspect
10-50: Hit & Run
10-59: Herding
*10-60: What is next message number?
10-62: Unable to copy, use landline
10-63: Offset
10-65: Vehicle box
10-67: Spike strip
10-70: Requesting fire department
10-71: Requesting Air unit
10-73: Roadblock
10-75: Rolling roadblock
10-77: Negative contact
10-81: Speed Trap location
10-82: Rolling chicane
10-83: Set up quadrant
10-85: Backup
10-87: Vehicle/suspect pursuit
*10-90: Smoke screen
10-93: Check my frequency on this channel
10-96: Traffic stop
10-100: 5-minute break
UNIT REQUEST CODES
Air Support: Police Helicopter
PURSUIT STAGE CODES
Code 1: Situation under control
Code 2: ASAP, no lights or sirens(on)
Code 3: Emergency, lights and sirens(on)
Code 4: Suspect under arrest
Code 5: More units needed
Code 6: High-risk racer
Code 7: Change in Condition
Code 8: Suspect found
Code 10: Confidential information
PURSUIT CONDITIONS
*Condition 1: Heat level 1
Condition 2: Heat level 2
Condition 3: Heat level 3
Condition 4: Heat level 4
Condition 5: Heat level 5
Condition 6: Heat level 6
OTHER CODES
28/29: Run suspect for wants/warrants
51-50: Possible mental disorder
"Positive hit": Ran suspect has a criminal record
APB: All-points bulletin
*ACCI: Accident investigator
ASAP: As soon as possible
Assault PO: Assault on a police officer
DUI: Driving under the influence
EMS: Emergency medical services
ETA: Estimated time of arrival
*GD: General duty
*HAZMAT: Hazardous materials unit
HVT: High value target
KS: Kill switch
*MHA: Mental Health Act
MVA: Motor vehicle accident
NCIC: National Criminal Information Center
PC: Police car/cruiser
PDT: Portable data transmitter/terminal
PID: Positive identification
Primary: Unit behind suspect
RTB: Return to base
Secondary: Unit behind primary
TAC: Tactical radio channel
TC: Traffic collision
VCB: Visual contact broken
Wrecker: Tow truck
]]

if SERVER then
	UVClassName = {"POLICE"}
	
	file.AsyncRead('data_static/chatter.json', 'GAME', function( _, _, status, data )
		_uvchatterarray = util.JSONToTable(data)
	end, true)
	
	--Spam check--
	
	function UVRelayToClients( init_time, sound_name, param, can_skip, players, callsign )
		if players and type(players) == "table" then
			if #players == 0 then return end
		end

		net.Start('UV_Chatter')
		net.WriteFloat(init_time)
		net.WriteString(sound_name)
		net.WriteBool(can_skip)
		net.WriteBool(callsign ~= nil)

		if callsign ~= nil then
			net.WriteString(callsign)
		end

		if players and type(players) == "table" then
			net.Send( players )
		else
			net.Broadcast()
		end
	end
	
	function UVRelaySoundToClients( sound_name, can_skip )
		local array = {
			['FileName'] = sound_name,
			['CanSkip'] = can_skip
		}
		net.Start('UV_Sound')
		net.WriteTable(array)
		--net.WriteBool(can_skip)
		--net.WriteInt(tonumber(param))
		net.Broadcast()
	end
	
	function UVDelayChatter(seconds)
		--if UVChatterDelayed then return 5 end
		UVChatterDelayed = true
		
		if not seconds then
			seconds = 2
		end
		
		timer.Remove('UVDelayChatter')
		timer.Create('UVDelayChatter', seconds, 1, function()
			UVChatterDelayed = false
		end)

		return seconds
	end
	
	UVChatterQueue = UVChatterQueue or {}
	UVFileFindCache = UVFileFindCache or {}
	UVChatterQueueActive = UVChatterQueueActive or false
	UVChatterQueueFinishTime = UVChatterQueueFinishTime or 0
	
	function UVResetChatterQueue()
		UVChatterQueue = {}
		UVChatterQueueActive = false
		UVChatterQueueFinishTime = 0
	end
	
	local function ProcessChatterQueue()
		if #UVChatterQueue == 0 then return end
		if UVChatterQueueActive then return end
		if UVChatterQueueFinishTime > 0 and CurTime() < UVChatterQueueFinishTime then return end
		
		local queueItem = table.remove(UVChatterQueue, 1)
		if not queueItem then return end
		
		UVChatterQueueActive = true
		UVChatterQueueFinishTime = 0
		
		local duration = queueItem.func()
		
		if duration and duration ~= 5 and duration > 0 then
			UVChatterQueueFinishTime = CurTime() + duration
		else
			UVChatterQueueFinishTime = CurTime()
		end
		
		UVChatterQueueActive = false
	end
	
	if not UVChatterQueueThinkActive then
		UVChatterQueueThinkActive = true
		hook.Add("Think", "UVChatterQueueProcessor", function()
			ProcessChatterQueue()
		end)
	end
	
	--return 5 = no sound chatter
	-- function UVSoundChatter(self, voice, chattertype, parameters, ...)
	-- 	--[[ Voice Type
	-- 	1 = Undercover Dispatch
	-- 	2 = Undercover Helicopter (Air)
	-- 	3-8 = Undercover Local (Patrol, Support)
	-- 	9-10 = Undercover Federal (Special, Commander(one commander disabled))
	-- 	11 = Payback/Heat Rhino
	-- 	12 = Most Wanted Cross (Commander(one commander enabled))
	-- 	13-18 = Most Wanted Local (Pursuit, Interceptor)
	-- 	19 = Most Wanted Helicopter (Air)
	-- 	*Others are non-engaging support units. If both are included in the same folder(chattertype), it'd be a 50/50 chance.
	-- 	]]

	local function GetUnitVoiceProfile(unit, isDispatch, isMisc)
		local voiceProfile = ""
		
		if isDispatch then
			voiceProfile = GetConVar("unitvehicle_unit_dispatch_voiceprofile"):GetString()
		elseif isMisc then
			voiceProfile = GetConVar("unitvehicle_unit_misc_voiceprofile"):GetString()
		else
			local unitType = unit and unit.type
			if not unitType then return GetConVar("unitvehicle_unit_dispatch_voiceprofile"):GetString() end
			
			voiceProfile = GetConVar("unitvehicle_unit_" .. unitType .. "_voiceprofile"):GetString()
		end
		
		return voiceProfile
	end

	local function CachedFileFind(path, searchPath)
		searchPath = searchPath or "GAME"
		local key = path
		if UVFileFindCache[key] == nil then
			local files, directories = file.Find(path, searchPath)
			UVFileFindCache[key] = { files, directories }
		end
		local cached = UVFileFindCache[key]
		return cached[1], cached[2]
	end
	
	local function _PlayUVSoundChatter(self, voice, chattertype, parameters, ...)
		
		if not IsValid(self) or not voice or not (GetConVar("unitvehicle_chatter"):GetBool() and not GetConVar("unitvehicle_chattertext"):GetBool()) then 
			return 0
		end

		-- if not UVLastPlay then
		-- 	UVLastPlay = CurTime()
		-- elseif CurTime() - UVLastPlay < 0.5  then
		-- 	return 5
		-- end

		local initTime = CurTime()
		
		local isDispatch = (select(1, ...) == "DISPATCH")
		
		local unitVoiceProfile = GetUnitVoiceProfile(self, isDispatch, false)
		local miscVoiceProfile = GetUnitVoiceProfile(self, isDispatch, true)
		
		if UVJammerDeployed then
			local staticFiles = CachedFileFind("sound/chatter2/" .. miscVoiceProfile .. "/misc/static/*", "GAME")
			if next(staticFiles) == nil then return 5 end
			
			local soundFile = "chatter2/"..miscVoiceProfile.."/misc/static/"..staticFiles[1]
			UVRelayToClients(initTime, soundFile, parameters, true)
			return 5
		end

		local function HandleCallSounds(is_dispatch, is_priority)
			local callsign = self and self.callsign
			if is_dispatch or isDispatch then
				voice = "dispatch"
				unitVoiceProfile = GetConVar("unitvehicle_unit_dispatch_voiceprofile"):GetString()
			end

			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			table.Shuffle(soundFiles)
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/"..soundFiles[1]
			
			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end

			ChatterLastPlay = initTime

			local function _init()
				UVRelayToClients(initTime, soundFile, parameters, not (is_priority or voice == "dispatch"), nil, (voice == "dispatch" and "uv.unit.dispatch") or (callsign))
				timer.Simple(SoundDuration(soundFile or ""), function()
					if ChatterLastPlay ~= initTime then return 5 end
					if radioOffFile then
						UVRelayToClients(initTime, radioOffFile, parameters, true)
					end
				end)
			end

			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			local chirpGenericFile
			
			if radioOnFile then
				UVRelayToClients(initTime, radioOnFile, parameters, true)
				timer.Simple(SoundDuration(radioOnFile or ""), function()
					if ChatterLastPlay ~= initTime then return 5 end
					_init()
				end)
			else
				if next(chirpGenericFiles) ~= nil then
					chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
				end

				if chirpGenericFile then
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, chirpGenericFile, parameters, true)
				end
				
				timer.Simple(0.1, function()
					if ChatterLastPlay ~= initTime then return 5 end
					_init()
				end)
			end
			return UVDelayChatter((SoundDuration(soundFile or "") + SoundDuration(radioOnFile or "") + (chirpGenericFile and 0.1 or 0) + SoundDuration(radioOffFile or "") + math.random(1, 2)))
		end

		-- 	--[[Parameters
		-- 	1 = No voice restriction
		-- 	2 = Bullhorn
		-- 	3 = Static
		-- 	4 = Emergency
		-- 	5 = Identify
		-- 	6 = Call
		-- 	7 = Losing
		-- 	8 = Emergency (No voice restriction)
		--  9 = In person
		--  10 = Vehicle Description
		-- 	]]
		
		if parameters == 1 then
			return HandleCallSounds(isDispatch, true)
			
		elseif parameters == 2 then
			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/bullhorn/"..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/bullhorn/"..chattertype.."/"..soundFiles[1]
			
			--self:EmitSound(soundFile, 10000, 100, 1, CHAN_STREAM)
			if not IsValid(self) then return 5 end
			self:EmitSound(soundFile, 120)
				-- local bullhorn = CreateSound(self, soundFile, recpFilter)
				-- bullhorn:SetSoundLevel(120)
				-- bullhorn:Play()

			return 2
			
		elseif parameters == 3 then
			local callsign = self and self.callsign

			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			table.Shuffle(soundFiles)
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/"..soundFiles[1]
			
			if not soundFile then return 5 end
			
			local staticFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/static/*", "GAME")
			if next(staticFiles) == nil then return 5 end
			table.Shuffle(staticFiles)
			local staticFile = "chatter2/"..miscVoiceProfile.."/misc/static/"..staticFiles[1]

			ChatterLastPlay = initTime

			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end

			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			table.Shuffle(chirpGenericFiles)
			local chirpGenericFile
			
			if radioOnFile then
				if ChatterLastPlay ~= initTime then return 5 end
				UVRelayToClients(initTime, radioOnFile, parameters, true)
			else
				if next(chirpGenericFiles) ~= nil then
					chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
				end

				if chirpGenericFile then
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, chirpGenericFile, parameters, true)
				end
			end

			timer.Simple(radioOnFile and SoundDuration(radioOnFile) or (chirpGenericFile and 0.1 or 0), function()
				if ChatterLastPlay ~= initTime then return 5 end
				UVRelayToClients(initTime, staticFile, parameters, true)
				timer.Simple(SoundDuration(staticFile or ""), function()
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, soundFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (callsign))
					timer.Simple(SoundDuration(soundFile or ""), function()
						if radioOffFile then
							if ChatterLastPlay ~= initTime then return 5 end
							UVRelayToClients(initTime, radioOffFile, parameters, true)
						end
					end)
				end)
			end)
			
			
			return UVDelayChatter(SoundDuration(soundFile or "") + SoundDuration(staticFile or "") + SoundDuration(radioOnFile or "") + (chirpGenericFile and 0.1 or 0) + SoundDuration(radioOffFile or "") + math.random(1, 2))
			
		elseif parameters == 4 then
			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			table.Shuffle(soundFiles)
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/"..soundFiles[1]
			
			if not soundFile then return 5 end
			
			ChatterLastPlay = initTime

			local emergencyFile = "chatter2/"..miscVoiceProfile.."/misc/emergency/copresponse.mp3"
			local emergencyDuration = SoundDuration(emergencyFile)

			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end
			
			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			table.Shuffle(chirpGenericFiles)
			local chirpGenericFile
			
			UVRelayToClients(initTime, emergencyFile, parameters, false)
			timer.Simple(SoundDuration(emergencyFile or ""), function()
				if radioOnFile then
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, radioOnFile, parameters, false)
				else
					if next(chirpGenericFiles) ~= nil then
						chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
					end
			
					if chirpGenericFile then
						if ChatterLastPlay ~= initTime then return 5 end
						UVRelayToClients(initTime, chirpGenericFile, parameters, false)
					end
				end
				timer.Simple(radioOnFile and SoundDuration(radioOnFile) or (chirpGenericFile and 0.1 or 0), function()
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, soundFile, parameters, false, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
					timer.Simple(SoundDuration(soundFile or ""), function()
						if radioOffFile then
							if ChatterLastPlay ~= initTime then return 5 end
							UVRelayToClients(initTime, radioOffFile, parameters, false)
						end
					end)
				end)
			end)
			
			return UVDelayChatter((SoundDuration(soundFile or "") + emergencyDuration + SoundDuration(radioOnFile or "") + (chirpGenericFile and 0.1 or 0) + SoundDuration(radioOffFile or "") + math.random(1, 2)))
			
		elseif parameters == 5 then
			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			table.Shuffle(soundFiles)
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/"..soundFiles[1]
			
			if not soundFile then return 5 end

			ChatterLastPlay = initTime
			
			local identifyFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/"..voice.."/identify/*", "GAME")
			if next(identifyFiles) == nil then return 5 end
			table.Shuffle(identifyFiles)
			local identifyFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/identify/"..identifyFiles[1]
			
			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end

			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			table.Shuffle(chirpGenericFiles)
			local chirpGenericFile
			
			if radioOnFile then
				if ChatterLastPlay ~= initTime then return 5 end
				UVRelayToClients(initTime, radioOnFile, parameters, true)
			else
				if next(chirpGenericFiles) ~= nil then
					chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
				end

				if chirpGenericFile then
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, chirpGenericFile, parameters, true)
				end
			end
			timer.Simple(radioOnFile and SoundDuration(radioOnFile) or (chirpGenericFile and 0.1 or 0), function()
				if ChatterLastPlay ~= initTime then return 5 end
				UVRelayToClients(initTime, identifyFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
				timer.Simple(SoundDuration(identifyFile or ""), function()
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, soundFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
					timer.Simple(SoundDuration(soundFile or ""), function()
						if radioOffFile then
							if ChatterLastPlay ~= initTime then return 5 end
							UVRelayToClients(initTime, radioOffFile, parameters, true)
						end
					end)
				end)
			end)
			
			return UVDelayChatter(SoundDuration(soundFile or "") + SoundDuration(identifyFile or "") + SoundDuration(radioOnFile or "") + (chirpGenericFile and 0.1 or 0) + SoundDuration(radioOffFile or "") + math.random(1, 2))
			
		elseif parameters == 6 then

			voice = "dispatch"
			unitVoiceProfile = GetConVar("unitvehicle_unit_dispatch_voiceprofile"):GetString()
			
			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/"..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			table.Shuffle(soundFiles)
			local soundFile = "chatter2/"..unitVoiceProfile.."/dispatch/"..chattertype.."/"..soundFiles[1]

			ChatterLastPlay = initTime
			
			local emergencyFile = "chatter2/"..miscVoiceProfile.."/misc/emergency/copresponse.mp3"
						
			local addressFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/addressgroup_map/"..game.GetMap().."/*", "GAME")
			table.Shuffle(addressFiles)
			local chosenPath = "chatter2/"..unitVoiceProfile.."/dispatch/addressgroup_map/"..game.GetMap().."/"

			if not addressFiles or #addressFiles == 0 then
				local mapName = game.GetMap()
				if mapName:find("_") then
					mapName = mapName:gsub("^[^_]+_", ""):gsub("(_.+)$", "")
					-- print("Found no " .. game.GetMap() .. " files - switching to " .. mapName)
					addressFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/addressgroup_map/"..mapName.."/*", "GAME")
					chosenPath = "chatter2/"..unitVoiceProfile.."/dispatch/addressgroup_map/"..mapName.."/"
				end
			end

			if not addressFiles or #addressFiles == 0 then
				-- print("Found no alternative files - switching to default")
				addressFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/addressgroup/*", "GAME")
				table.Shuffle(addressFiles)
				chosenPath = "chatter2/"..unitVoiceProfile.."/dispatch/addressgroup/"
			end

			local addressFile
			if addressFiles and #addressFiles > 0 then
				addressFile = chosenPath..addressFiles[1]
			end

			local locationFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/d_location/*", "GAME")
			table.Shuffle(locationFiles)
			local locationFile
			if locationFiles then
				locationFile = "chatter2/"..unitVoiceProfile.."/dispatch/d_location/"..locationFiles[1]
			end
			
			local requestFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/unitrequest/*", "GAME")
			table.Shuffle(requestFiles)
			local requestFile
			if requestFiles then
				requestFile = "chatter2/"..unitVoiceProfile.."/dispatch/unitrequest/"..requestFiles[1]
			end

			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end

			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			table.Shuffle(chirpGenericFiles)
			local chirpGenericFile
						
			local soundDuration_soundFile = SoundDuration(soundFile or "")
			local soundDuration_emergencyFile = SoundDuration(emergencyFile or "")
			local soundDuration_addressFile = SoundDuration(addressFile or "")
			local soundDuration_locationFile = SoundDuration(locationFile or "")
			local soundDuration_requestFile = SoundDuration(requestFile or "")
			local soundDuration_radioOffFile = SoundDuration(radioOffFile or "")
			local soundDuration_radioOnFile = SoundDuration(radioOnFile or "")
			local soundDuration_chirpGenericFile

			UVRelayToClients(initTime, emergencyFile, parameters, false)
			timer.Simple(soundDuration_emergencyFile, function()
				if radioOnFile then
					UVRelayToClients(initTime, radioOnFile, parameters, false)
				else
					if next(chirpGenericFiles) ~= nil then
						chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
						soundDuration_chirpGenericFile = 0.1
					end
	
					if chirpGenericFile then
						if ChatterLastPlay ~= initTime then return 5 end
						UVRelayToClients(initTime, chirpGenericFile, parameters, true)
					end
				end
				timer.Simple(soundDuration_radioOnFile or soundDuration_chirpGenericFile or 0, function()
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, addressFile or "", parameters, false, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
					timer.Simple(soundDuration_addressFile, function()
						if ChatterLastPlay ~= initTime then return 5 end
						UVRelayToClients(initTime, soundFile or "", parameters, false, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
						timer.Simple(soundDuration_soundFile, function()
							if ChatterLastPlay ~= initTime then return 5 end
							UVRelayToClients(initTime, locationFile or "", parameters, false, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
							timer.Simple(soundDuration_locationFile, function()
								if ChatterLastPlay ~= initTime then return 5 end
								UVRelayToClients(initTime, requestFile or "", parameters, false, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
								timer.Simple(soundDuration_requestFile, function()
									if radioOffFile then
										if ChatterLastPlay ~= initTime then return 5 end
										UVRelayToClients(initTime, radioOffFile or "", parameters, false)
									end
								end)
							end)
						end)
					end)
				end)
			end)
			return UVDelayChatter((soundDuration_soundFile + soundDuration_emergencyFile + soundDuration_addressFile + soundDuration_locationFile + soundDuration_requestFile + soundDuration_radioOffFile + soundDuration_radioOnFile + (soundDuration_chirpGenericFile or 0) + math.random(1, 2)))
			
		elseif parameters == 7 then
			if not UVEnemyEscaping then return 5 end
			
			voice = "dispatch"
			unitVoiceProfile = GetConVar("unitvehicle_unit_dispatch_voiceprofile"):GetString()
			
			local emergencyFile = "chatter2/"..miscVoiceProfile.."/misc/emergency/copresponse.mp3"
			local breakawayFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/dispbreakaway/*", "GAME")
			table.Shuffle(breakawayFiles)
			local breakawayFile
			if next(breakawayFiles) ~= nil then
				breakawayFile = "chatter2/"..unitVoiceProfile.."/dispatch/dispbreakaway/"..breakawayFiles[1]
			end
			
			local locationFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/d_location/*", "GAME")
			table.Shuffle(locationFiles)
			local locationFile
			if next(locationFiles) ~= nil then
				locationFile = "chatter2/"..unitVoiceProfile.."/dispatch/d_location/"..locationFiles[1]
			end
			
			local quadrantFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile.."/dispatch/quadrant/*", "GAME")
			table.Shuffle(quadrantFiles)
			local quadrantFile
			if next(quadrantFiles) ~= nil then
				quadrantFile = "chatter2/"..unitVoiceProfile.."/dispatch/quadrant/"..quadrantFiles[1]
			end

			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end
			
			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			table.Shuffle(chirpGenericFiles)
			local chirpGenericFile

			ChatterLastPlay = initTime

			UVRelayToClients(initTime, emergencyFile, parameters, true)
			timer.Simple(SoundDuration(emergencyFile or ""), function()
				if radioOnFile then
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, radioOnFile, parameters, true)
				else
					if next(chirpGenericFiles) ~= nil then
						chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
					end
	
					if chirpGenericFile then
						if ChatterLastPlay ~= initTime then return 5 end
						UVRelayToClients(initTime, chirpGenericFile, parameters, true)
					end
				end
				timer.Simple(radioOnFile and SoundDuration(radioOnFile) or (chirpGenericFile and 0.1 or 0), function()
					if ChatterLastPlay ~= initTime then return 5 end
					if not UVEnemyEscaping then return end
					if breakawayFile then
						UVRelayToClients(initTime, breakawayFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
					end
					timer.Simple(SoundDuration(breakawayFile or ""), function()
						if ChatterLastPlay ~= initTime then return 5 end
						if not UVEnemyEscaping then return end
						if locationFile then
							UVRelayToClients(initTime, locationFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
						end
						timer.Simple(SoundDuration(locationFile or ""), function()
							if ChatterLastPlay ~= initTime then return 5 end
							if not UVEnemyEscaping then return end
							if quadrantFile then
								UVRelayToClients(initTime, quadrantFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
							end
							timer.Simple(SoundDuration(quadrantFile or ""), function()
								if radioOffFile then
									if ChatterLastPlay ~= initTime then return 5 end
									if not UVEnemyEscaping then return end
									UVRelayToClients(initTime, radioOffFile, parameters, true)
								end
							end)
						end)
					end)
				end)
			end)
			
			return UVDelayChatter((SoundDuration(emergencyFile or "") + SoundDuration(breakawayFile or "") + SoundDuration(locationFile or "") + SoundDuration(quadrantFile or "") + SoundDuration(radioOnFile or "") + SoundDuration(radioOffFile or "") + math.random(1, 2)))
			
		elseif parameters == 8 then
			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			table.Shuffle(soundFiles)
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/"..chattertype.."/"..soundFiles[1]
			
			local emergencyFile = "chatter2/"..miscVoiceProfile.."/misc/emergency/copresponse.mp3"

			ChatterLastPlay = initTime

			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end

			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			table.Shuffle(chirpGenericFiles)
			local chirpGenericFile
			
			UVRelayToClients(initTime, emergencyFile, parameters, true)
			timer.Simple(SoundDuration(emergencyFile or ""), function()
				if radioOnFile then
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, radioOnFile, parameters, true)
				else
					if next(chirpGenericFiles) ~= nil then
						chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
					end
	
					if chirpGenericFile then
						if ChatterLastPlay ~= initTime then return 5 end
						UVRelayToClients(initTime, chirpGenericFile, parameters, true)
					end
				end
				timer.Simple(radioOnFile and SoundDuration(radioOnFile) or (chirpGenericFile and 0.1 or 0), function()
					if ChatterLastPlay ~= initTime then return 5 end
					UVRelayToClients(initTime, soundFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
					timer.Simple(SoundDuration(soundFile or ""), function()
						if ChatterLastPlay ~= initTime then return 5 end
						if radioOffFile then
							UVRelayToClients(initTime, radioOffFile, parameters, true)
						end
					end)
				end)
			end)
			
			return UVDelayChatter((SoundDuration(soundFile) + SoundDuration(emergencyFile) + SoundDuration(radioOnFile or "") + (chirpGenericFile and 0.1 or 0) + SoundDuration(radioOffFile or "") + math.random(1, 2)))
		elseif parameters == 9 then -- in person chatter
			local players = select(1, ...)

			local soundFiles = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/inperson/" ..chattertype.."/*", "GAME")
			if next(soundFiles) == nil then return 5 end
			table.Shuffle(soundFiles)
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/inperson/"..chattertype.."/"..soundFiles[1]
			
			UVRelayToClients(initTime, soundFile, parameters, true, players, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))

			return 0
		elseif parameters == 10 then
			if is_dispatch or isDispatch then
				voice = "dispatch"
				unitVoiceProfile = GetConVar("unitvehicle_unit_dispatch_voiceprofile"):GetString()
			end

			local vehicle = select(2, ...)

			local vehicleModel = vehicle.UVVehicleModel or string.Explode( "[ -.]", UVGetVehicleMakeAndModel(vehicle), true )
			local vehicleColor = ( vehicle.UVVehicleColor and {name = vehicle.UVVehicleColor} ) or UVColor(vehicle)

			local _, vehicleBrands = CachedFileFind("sound/chatter2/"..unitVoiceProfile..'/'..voice.."/vehicledescription/*", "GAME")
			if next(vehicleBrands) == nil then return 5 end
			table.Shuffle(vehicleBrands)

			local brand = nil

			for _, vehicleBrand in pairs( vehicleBrands ) do
				local found = false

				if type( vehicleModel ) == "table" then
					for i = 1, #vehicleModel do
						if string.lower( vehicleBrand ) == string.lower( vehicleModel[i] ) then
							brand = vehicleBrand
							found = true
							break
						end
					end
				else
					if string.lower( vehicleBrand ) == string.lower( vehicleModel ) then
						brand = vehicleBrand
						found = true
						break
					end
				end
				

				if found then break end
			end

			if not brand then brand = 'genericsportscar' end

			local soundFiles = CachedFileFind( "sound/chatter2/"..unitVoiceProfile..'/'..voice.."/vehicledescription/"..brand.."/"..vehicleColor.name.."/*", "GAME" )
			if next(soundFiles) == nil then soundFiles = CachedFileFind( "sound/chatter2/"..unitVoiceProfile..'/'..voice.."/vehicledescription/"..brand.."/default/*", "GAME" ) end
			if next(soundFiles) == nil then return UVChatterDispatchCallUnknownDescription(self, vehicle, vehicleModel) end
			table.Shuffle(soundFiles)

			local color = vehicleColor.name
			if not file.Exists( "sound/chatter2/"..unitVoiceProfile..'/'..voice.."/vehicledescription/"..brand.."/"..color, "GAME" ) then color = "default" end
			local soundFile = "chatter2/"..unitVoiceProfile..'/'..voice.."/vehicledescription/"..brand.."/"..color.."/"..soundFiles[1]

			local radioOnFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radioon/*", "GAME")
			table.Shuffle(radioOnFiles)
			local radioOnFile
			if next(radioOnFiles) ~= nil then
				radioOnFile = "chatter2/"..miscVoiceProfile.."/misc/radioon/"..radioOnFiles[1]
			end
			
			local radioOffFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/radiooff/*", "GAME")
			table.Shuffle(radioOffFiles)
			local radioOffFile
			if next(radioOffFiles) ~= nil then
				radioOffFile = "chatter2/"..miscVoiceProfile.."/misc/radiooff/"..radioOffFiles[1]
			end

			local chirpGenericFiles = CachedFileFind("sound/chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/*", "GAME")
			table.Shuffle(chirpGenericFiles)
			local chirpGenericFile

			ChatterLastPlay = initTime
			
			if radioOnFile then
				UVRelayToClients(initTime, radioOnFile, parameters, true)
			else
				if next(chirpGenericFiles) ~= nil then
					chirpGenericFile = "chatter2/"..miscVoiceProfile.."/misc/chirpgeneric/"..chirpGenericFiles[1]
					UVRelayToClients(initTime, chirpGenericFile, parameters, true)
				end
			end
			timer.Simple(radioOnFile and SoundDuration(radioOnFile) or (chirpGenericFile and 0.1 or 0), function()
				if ChatterLastPlay ~= initTime then return 5 end
				UVRelayToClients(initTime, soundFile, parameters, true, nil, (voice == "dispatch" and "uv.unit.dispatch") or (self and self.callsign))
				timer.Simple(SoundDuration(soundFile or ""), function()
					if ChatterLastPlay ~= initTime then return 5 end
					if radioOffFile then
						UVRelayToClients(initTime, radioOffFile, parameters, true)
					end
				end)
			end)

			return UVDelayChatter(SoundDuration(soundFile or "") + SoundDuration(radioOnFile or "") + (chirpGenericFile and 0.1 or 0) + SoundDuration(radioOffFile or "") + math.random(1, 2))
		end
		
		return HandleCallSounds()
	end
	
	function UVSoundChatter(self, voice, chattertype, parameters, ...)
		if not self or not voice or not (GetConVar("unitvehicle_chatter"):GetBool() and not GetConVar("unitvehicle_chattertext"):GetBool()) then 
			return 5 
		end
		
		local args = {...}
		
		table.insert(UVChatterQueue, {
			func = function()
				return _PlayUVSoundChatter(self, voice, chattertype, parameters, unpack(args))
			end
		})
		
		return 5
	end
	
	
	-- 	List of variables:
	-- 	self.callsign = UNIT_CALLSIGN
	-- 	e = UNIT_SUSPECTMODEL
	-- 	UVClassName[math.random(1, #UVClassName)] = UNIT_CLASSES
	-- 	game.GetMap() = MAP_GET
	-- 	math.random(1,9) = MATH_RANDOM19
	-- 	math.random(1,1000) = MATH_RANDOMUNIT
	-- 	backuptimeleft = MATH_BACKUPTIMELEFT
	-- 	unit.callsign = UNIT_SECONDARYCALLSIGN
	-- 	color = UNIT_SUSPECTCOLOR
	-- 	model = UNIT_SUSPECTMAKE
	
	function _getFormatParam(param, unit, args)
		local variable_list = {
			['UNIT_CALLSIGN'] = {(unit and unit.callsign) or 'Unit', Color(53, 134, 255)},
			['UNIT_SUSPECTMODEL'] = {args.suspectmodel, Color(255, 54, 54)},
			['UNIT_CLASSES'] = {UVClassName[math.random(1, #UVClassName)], Color(255,255,255)},
			['MAP_GET'] = {game.GetMap(), Color(255,238,0)},
			['MATH_RANDOM19'] = {math.random(1,9), Color(255,255,255)},
			['MATH_RANDOMUNIT'] = {math.random(1,1000), Color(53, 134, 255)},
			['MATH_BACKUPTIMELEFT'] = {string.NiceTime(uvresourcepointstimerleft), Color(255,255,255)},
			['UNIT_SECONDARYCALLSIGN'] = {args.altcallsign, Color(53, 134, 255)},
			['UNIT_SUSPECTCOLOR'] = {args.suspectcolor, Color(255, 54, 54)},
			['UNIT_SUSPECTMAKE'] = {args.suspectmake, Color(255, 54, 54)},
		}
		
		return variable_list[param]
	end
	
	function UVTextChatter(unit, args, ...) -- ... = directory to array with text/variables, since some entries are dictionaries
		if not GetConVar("unitvehicle_chattertext"):GetBool() then return end
		
		local format_arg_list = {}
		
		local sub_dir_count = select('#', ...)
		local array_pointer = _uvchatterarray
		
		for i = 1, sub_dir_count, 1 do
			local _target = array_pointer[select(i, ...)]
			
			if type(_target) == 'table' then
				array_pointer = _target
			else break end
		end
		if type(array_pointer) ~= 'table' then error('Improperly formatted JSON') return end
		
		--
		
		local option = array_pointer[math.random(1, #array_pointer)]
		local format_var_list = {}
		
		if not option then return end
		
		local txt = string.Split(option.text, "%s")
		local array = {}
		
		for i, v in pairs(option.variables) do
			if i == 1 then
				table.insert(array, Color(255,255,255))
			end
			
			local entry = _getFormatParam(v, unit, args)
			
			local color = entry[2]
			for _, v in pairs({txt[i], color, entry[1], Color(242,242,242)}) do
				table.insert(array, v)
			end
			
			if i == #option.variables then
				for _, v in pairs({txt[#txt], color}) do
					table.insert(array, v)
				end
			end
		end
		
		if #option.variables <  1 then
			for _, v in pairs({Color(189,189,189), option.text}) do
				table.insert(array, v)
			end
		end
		
		net.Start('UV_Text')
		net.WriteTable(array)
		net.Broadcast()
	end
	
	--UV old chatter goes here--
	
	function UVChatterOnRemove(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "onremove")
		end
		if UVChatterDelayed then return end
		-- UVDelayChatter()
		if self.v.UVPatrol then
			UVTextChatter(self, {}, 'OnRemove', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {}, 'OnRemove', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'OnRemove', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'OnRemove', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'OnRemove', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'OnRemove', 'UVCommander')
		end
	end
	
	function UVChatterArrest(self, enemy)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local randomno = math.random(1,2)
			if randomno == 1 then
				UVChatterQueue = {}
				local time = UVSoundChatter(self, self.voice, "arrest", nil)
				return time == 0 and 5 or time
			else
				local time = UVSoundChatter(self, self.voice, "arrest", 2, enemy)
				return time == 0 and 5 or time
			end
		end
		-- UVDelayChatter()
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		
		if self.v then
			if self.v.UVPatrol then
				UVTextChatter(self, {['suspectmodel'] = e}, 'Arrest', 'UVPatrol')
			elseif self.v.UVSupport then
				UVTextChatter(self, {['suspectmodel'] = e}, 'Arrest', 'UVSupport')
			elseif self.v.UVPursuit then
				UVTextChatter(self, {['suspectmodel'] = e}, 'Arrest', 'UVPursuit')
			elseif self.v.UVSpecial then
				UVTextChatter(self, {['suspectmodel'] = e}, 'Arrest', 'UVSpecial')
			elseif self.v.UVCommander then
				UVTextChatter(self, {['suspectmodel'] = e}, 'Arrest', 'UVCommander')
			end
		else
			UVTextChatter(self, {['suspectmodel'] = e}, 'Arrest', 'UVPatrol')
		end
	end
	
	function UVChatterArrestAcknowledge(self)
		if #UVWantedTableVehicle > 0 then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "arrestacknowledge", 1, "DISPATCH")
		end
		if not IsValid(self.v) then return end
		-- UVDelayChatter()
		if self.v.UVPatrol then
			UVTextChatter(self, {}, 'ArrestAcknowledge', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {}, 'ArrestAcknowledge', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'ArrestAcknowledge', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'ArrestAcknowledge', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'ArrestAcknowledge', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'ArrestAcknowledge', 'UVCommander')
		end
	end

	function UVChatterFineArrest(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local driver = UVGetDriver(self.e)
			if driver and driver:IsPlayer() then
				return UVSoundChatter(self, self.voice, "finearrest", 9, {driver})
			end
		end
		-- UVDelayChatter()
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		if self.v.UVPatrol then
			UVTextChatter(self, {['suspectmodel'] = e}, 'FineArrest', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {['suspectmodel'] = e}, 'FineArrest', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {['suspectmodel'] = e}, 'FineArrest', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {['suspectmodel'] = e}, 'FineArrest', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {['suspectmodel'] = e}, 'FineArrest', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {['suspectmodel'] = e}, 'FineArrest', 'UVCommander')
		end
	end
	
	function UVChatterFinePaid(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local driver = UVGetDriver(self.e)
			if driver and driver:IsPlayer() then
				return UVSoundChatter(self, self.voice, "finepaid", 9, {driver})
			end
		end
		-- UVDelayChatter()
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		if self.v.UVPatrol then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Fine', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Fine', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Fine', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Fine', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Fine', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Fine', 'UVCommander')
		end
	end
	
	function UVChatterWreck(self)
		if self:GetClass() ~= "uvair" and UVChatterDelayed or not UVTargeting then return end --Air Unit gets priority
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			if self:GetClass() == "uvair" then UVResetChatterQueue() end
			return UVSoundChatter(self, self.voice, "wreck", 3)
		end
		-- UVDelayChatter()
		local wrecksound = {
			"physics/metal/metal_large_debris1.wav",
			"physics/metal/metal_large_debris2.wav",
			"vehicles/v8/vehicle_impact_heavy1.wav",
			"vehicles/v8/vehicle_impact_heavy2.wav",
			"vehicles/v8/vehicle_impact_heavy3.wav",
			"vehicles/v8/vehicle_impact_heavy4.wav",
			"vehicles/v8/vehicle_rollover1.wav",
			"vehicles/v8/vehicle_rollover2.wav",
			"npc/metropolice/die1.wav",
			"npc/metropolice/die2.wav",
			"npc/metropolice/die3.wav",
			"npc/metropolice/die4.wav",
			"npc/metropolice/knockout2.wav",
			"npc/metropolice/pain1.wav",
			"npc/metropolice/pain2.wav",
			"npc/metropolice/pain3.wav",
			"npc/metropolice/pain4.wav",
			"npc/metropolice/vo/off2.wav",
			"npc/combine_soldier/die1.wav",
			"npc/combine_soldier/die2.wav",
			"npc/combine_soldier/die3.wav",
			"npc/combine_soldier/pain1.wav",
			"npc/combine_soldier/pain2.wav",
			"npc/combine_soldier/pain3.wav",
			"npc/combine_gunship/gunship_explode2.wav",
			"vo/citadel/br_failing11.wav",
			"vo/citadel/br_youfool.wav",
			"vo/citadel/br_no.wav",
		}
		if self.v then
			self.v:EmitSound(wrecksound[math.random(#wrecksound)])
		end
		if self.v.UVPatrol then
			UVTextChatter(self, {}, 'Wreck', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {}, 'Wreck', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'Wreck', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'Wreck', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'Wreck', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'Wreck', 'UVCommander')
		end
	end
	
	function UVChatterRoadblockMissed(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local randomno = math.random(1,2)
			local a = {"DISPATCH", nil}; local selected = a[math.random(1, #a)]
			if randomno == 1 then
				return UVSoundChatter(self, self.voice, "roadblockmissed")
			else
				return UVSoundChatter(self, self.voice, "roadblockmissed", 1, selected)
			end
		end
		-- UVDelayChatter()
		if self.v.UVSupport then
			UVTextChatter(self, {}, 'RoadblockMissed', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'RoadblockMissed', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'RoadblockMissed', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'RoadblockMissed', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'RoadblockMissed', 'UVCommander')
		end
	end
	
	function UVChatterRoadblockHit(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local randomno = math.random(1,2)
			local a = {"DISPATCH", nil}; local selected = a[math.random(1, #a)]
			if randomno == 1 then
				return UVSoundChatter(self, self.voice, "roadblockhit")
			else
				return UVSoundChatter(self, self.voice, "roadblockhit", 1, selected)
			end
		end
		-- UVDelayChatter()
		if self.v.UVSupport then
			UVTextChatter(self, {}, 'RoadblockHit', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'RoadblockHit', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'RoadblockHit', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'RoadblockHit', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'RoadblockHit', 'UVCommander')
		end
	end
	
	function UVChatterRoadblockDeployed(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "roadblockdeployed")
				end
			end
			local randomno = math.random(1,2)
			local a = {"DISPATCH", nil}; local selected = a[math.random(1, #a)]
			if randomno == 1 then
				return UVSoundChatter(self, self.voice, "roadblockdeployed")
			else
				return UVSoundChatter(self, self.voice, "roadblockdeployed", selected == 'DISPATCH' and 1 or nil, selected)
			end
		end
		-- UVDelayChatter()
		if self.v.UVSupport then
			UVTextChatter(self, {}, 'RoadblockDeployed', 'UVSupport')		
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'RoadblockDeployed', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'RoadblockDeployed', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'RoadblockDeployed', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'RoadblockDeployed', 'UVCommander')
		end
	end
	
	-- function UVChatterHeatTwo(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		local timecheck = 5
	-- 		local randomno = math.random(1,2)
	-- 		if randomno == 1 then
	-- 			local airrandomno = math.random(1,2)
	-- 			local airUnits = ents.FindByClass("uvair")
	-- 			if next(airUnits) ~= nil then
	-- 				local random_entry = math.random(#airUnits)	
	-- 				local unit = airUnits[random_entry]
	-- 				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
	-- 					timecheck = UVSoundChatter(unit, unit.voice, "heattwo", 4)
	-- 				else
	-- 					timecheck = UVSoundChatter(self, self.voice, "heattwo", 4)
	-- 				end
	-- 			else
	-- 				timecheck = UVSoundChatter(self, self.voice, "heattwo", 4)
	-- 			end
	-- 		else
	-- 			timecheck = UVSoundChatter(self, self.voice, "heattwo", 8)
	-- 		end
	-- 		timer.Simple(timecheck, function()
	-- 			if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 				local units = ents.FindByClass("npc_uv*")
	-- 				local random_entry = math.random(#units)	
	-- 				local unit = units[random_entry]
	-- 				if unit == self then return end
	-- 				UVChatterAcknowledgeGeneral(unit)
	-- 			end
	-- 		end)
	-- 		return
	-- 	end
	-- 	-- UVDelayChatter()
	-- 	timer.Simple(math.random(3,5), function()
	-- 		if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 			local units = ents.FindByClass("npc_uv*")
	-- 			local random_entry = math.random(#units)	
	-- 			local unit = units[random_entry]
	-- 			if unit == self then return end
	-- 			UVChatterAcknowledgeGeneral(unit)
	-- 		end
	-- 	end)
	-- 	UVTextChatter(self, {}, 'HeatTwo')
	-- end
	
	-- function UVChatterHeatThree(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		local timecheck = 5
	-- 		local randomno = math.random(1,2)
	-- 		if randomno == 1 then
	-- 			local airrandomno = math.random(1,2)
	-- 			local airUnits = ents.FindByClass("uvair")
	-- 			if next(airUnits) ~= nil then
	-- 				local random_entry = math.random(#airUnits)	
	-- 				local unit = airUnits[random_entry]
	-- 				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
	-- 					timecheck = UVSoundChatter(unit, unit.voice, "heatthree", 4)
	-- 				else
	-- 					timecheck = UVSoundChatter(self, self.voice, "heatthree", 4)
	-- 				end
	-- 			else
	-- 				timecheck = UVSoundChatter(self, self.voice, "heatthree", 4)
	-- 			end
	-- 		else
	-- 			timecheck = UVSoundChatter(self, self.voice, "heatthree", 8)
	-- 		end
	-- 		timer.Simple(timecheck, function()
	-- 			if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 				local units = ents.FindByClass("npc_uv*")
	-- 				local random_entry = math.random(#units)	
	-- 				local unit = units[random_entry]
	-- 				if unit == self then return end
	-- 				UVChatterAcknowledgeGeneral(unit)
	-- 			end
	-- 		end)
	-- 		return
	-- 	end
	-- 	-- UVDelayChatter()
	-- 	timer.Simple(math.random(3,5), function()
	-- 		if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 			local units = ents.FindByClass("npc_uv*")
	-- 			local random_entry = math.random(#units)	
	-- 			local unit = units[random_entry]
	-- 			if unit == self then return end
	-- 			UVChatterAcknowledgeGeneral(unit)
	-- 		end
	-- 	end)
	
	-- 	UVTextChatter(self, {}, 'HeatThree')
	-- end
	
	-- function UVChatterHeatFour(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		local timecheck = 5
	-- 		local randomno = math.random(1,2)
	-- 		if randomno == 1 then
	-- 			local airrandomno = math.random(1,2)
	-- 			local airUnits = ents.FindByClass("uvair")
	-- 			if next(airUnits) ~= nil then
	-- 				local random_entry = math.random(#airUnits)	
	-- 				local unit = airUnits[random_entry]
	-- 				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
	-- 					timecheck = UVSoundChatter(unit, unit.voice, "heatfour", 4)
	-- 				else
	-- 					timecheck = UVSoundChatter(self, self.voice, "heatfour", 4)
	-- 				end
	-- 			else
	-- 				timecheck = UVSoundChatter(self, self.voice, "heatfour", 4)
	-- 			end
	-- 		else
	-- 			timecheck = UVSoundChatter(self, self.voice, "heatfour", 8)
	-- 		end
	-- 		timer.Simple(timecheck, function()
	-- 			if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 				local units = ents.FindByClass("npc_uv*")
	-- 				local random_entry = math.random(#units)	
	-- 				local unit = units[random_entry]
	-- 				if unit == self then return end
	-- 				UVChatterAcknowledgeGeneral(unit)
	-- 			end
	-- 		end)
	-- 		return
	-- 	end
	-- 	-- UVDelayChatter()
	-- 	timer.Simple(math.random(3,5), function()
	-- 		if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 			local units = ents.FindByClass("npc_uv*")
	-- 			local random_entry = math.random(#units)	
	-- 			local unit = units[random_entry]
	-- 			if unit == self then return end
	-- 			UVChatterAcknowledgeGeneral(unit)
	-- 		end
	-- 	end)
	-- 	UVTextChatter(self, {}, 'HeatFour')
	-- end
	
	-- function UVChatterHeatFive(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		local timecheck = 5
	-- 		local randomno = math.random(1,2)
	-- 		if randomno == 1 then
	-- 			local airrandomno = math.random(1,2)
	-- 			local airUnits = ents.FindByClass("uvair")
	-- 			if next(airUnits) ~= nil then
	-- 				local random_entry = math.random(#airUnits)	
	-- 				local unit = airUnits[random_entry]
	-- 				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
	-- 					timecheck = UVSoundChatter(unit, unit.voice, "heatfive", 4)
	-- 				else
	-- 					timecheck = UVSoundChatter(self, self.voice, "heatfive", 4)
	-- 				end
	-- 			else
	-- 				timecheck = UVSoundChatter(self, self.voice, "heatfive", 4)
	-- 			end
	-- 		else
	-- 			timecheck = UVSoundChatter(self, self.voice, "heatfive", 8)
	-- 		end
	-- 		timer.Simple(timecheck, function()
	-- 			if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 				local units = ents.FindByClass("npc_uv*")
	-- 				local random_entry = math.random(#units)	
	-- 				local unit = units[random_entry]
	-- 				local timecheck = 5
	-- 				local randomno = math.random(1,2)
	-- 				if randomno == 1 then
	-- 					timecheck = UVSoundChatter(self, self.voice, "heatfiveacknowledge")
	-- 				else
	-- 					timecheck = UVSoundChatter(self, self.voice, "heatfiveargue")
	-- 					timer.Simple(timecheck, function()
	-- 						if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 							local units = ents.FindByClass("npc_uv*")
	-- 							local random_entry = math.random(#units)	
	-- 							local unit = units[random_entry]
	-- 							UVSoundChatter(self, self.voice, "heatfivereassure", 1)
	-- 						end
	-- 					end)
	-- 				end
	-- 			end
	-- 		end)
	-- 		return
	-- 	end
	-- 	-- UVDelayChatter()
	-- 	timer.Simple(math.random(3,5), function()
	-- 		if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 			local units = ents.FindByClass("npc_uv*")
	-- 			local random_entry = math.random(#units)	
	-- 			local unit = units[random_entry]
	-- 			if unit == self then return end
	-- 			UVChatterAcknowledgeGeneral(unit)
	-- 		end
	-- 	end)
	-- 	UVTextChatter(self, {}, 'HeatFive')
	-- end
	
	-- function UVChatterHeatSix(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		local timecheck = 5
	-- 		local randomno = math.random(1,2)
	-- 		if randomno == 1 then
	-- 			local airrandomno = math.random(1,2)
	-- 			local airUnits = ents.FindByClass("uvair")
	-- 			if next(airUnits) ~= nil then
	-- 				local random_entry = math.random(#airUnits)	
	-- 				local unit = airUnits[random_entry]
	-- 				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
	-- 					timecheck = UVSoundChatter(unit, unit.voice, "heatsix", 4)
	-- 				else
	-- 					timecheck = UVSoundChatter(self, self.voice, "heatsix", 4)
	-- 				end
	-- 			else
	-- 				timecheck = UVSoundChatter(self, self.voice, "heatsix", 4)
	-- 			end
	-- 		else
	-- 			timecheck = UVSoundChatter(self, self.voice, "heatsix", 8)
	-- 		end
	-- 		timer.Simple(timecheck, function()
	-- 			if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 				local units = ents.FindByClass("npc_uv*")
	-- 				local random_entry = math.random(#units)	
	-- 				local unit = units[random_entry]
	-- 				if unit == self then return end
	-- 				UVChatterAcknowledgeGeneral(unit)
	-- 			end
	-- 		end)
	-- 		return
	-- 	end
	-- 	-- UVDelayChatter()
	-- 	timer.Simple(math.random(3,5), function()
	-- 		if next(ents.FindByClass("npc_uv*")) ~= nil then
	-- 			local units = ents.FindByClass("npc_uv*")
	-- 			local random_entry = math.random(#units)	
	-- 			local unit = units[random_entry]
	-- 			if unit == self then return end
	-- 			UVChatterAcknowledgeGeneral(unit)
	-- 		end
	-- 	end)
	-- 	UVTextChatter(self, {}, 'HeatSix')
	-- end
	
	function UVChatterReportHeat(self, heat)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timeCheck = 5
			local randomChance = math.random(1,3)
			
			if randomChance == 1 then
				local airRandomChance = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil then
					local randomEntry = math.random(#airUnits)
					local unit = airUnits[randomEntry]
					if not (unit.crashing or unit.disengaging) and airRandomChance == 1 then
						timeCheck = UVSoundChatter(unit, unit.voice, "heat" .. heat, 4)
					else
						timeCheck = UVSoundChatter(self, self.voice, "heat" .. heat, 4)
					end
				else
					timeCheck = UVSoundChatter(self, self.voice, "heat" .. heat, 4)
				end
			elseif randomChance == 3 then
				timeCheck = UVSoundChatter(self, self.voice, "heat" .. heat, nil, "DISPATCH")
			else
				timeCheck = UVSoundChatter(self, self.voice, "heat" .. heat, 8)
			end
			
			timer.Simple(timeCheck, function()
				if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					local timeCheck = 5
					local randomno = math.random(1,2)
					if randomno == 1 then
						timeCheck = UVSoundChatter(self, self.voice, "heat" .. heat .. "acknowledge", 1)
					elseif next(ents.FindByClass("npc_uvspecial")) ~= nil then
						timeCheck = UVSoundChatter(self, self.voice, "heat" .. heat .. "argue", 1)
						timer.Simple(timeCheck, function()
							if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
								local units = ents.FindByClass("npc_uv*")
								local random_entry = math.random(#units)	
								local unit = units[random_entry]
								UVSoundChatter(self, self.voice, "heat" .. heat .. "reassure", nil, "DISPATCH")
							end
						end)
					end
				end
			end)
			
			return
		end
		-- UVDelayChatter()
		UVTextChatter(self, {}, 'Heat', tostring(heat))
	end
	
	function UVChatterPursuitStartRanAway(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 0.1
			if randomno == 1 then
				timecheck = UVSoundChatter(self, self.voice, "finearrest", 2)
			else
				timecheck = UVSoundChatter(self, self.voice, "pursuitstartranaway", 4)
			end
			timer.Simple(timecheck, function()
				if IsValid(self) and IsValid(self.e) then
					local e = UVGetVehicleMakeAndModel(self.e)
					UVChatterVehicleDescription(self, self.e, e)
				end
			end)
			return
		end
		-- UVDelayChatter()
		timer.Simple(math.random(3,4), function()
			if IsValid(self) then
				UVChatterPursuitStartAcknowledge(self)
			end
		end)
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		if self.v.UVPatrol then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartRanAway', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartRanAway', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartRanAway', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartRanAway', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartRanAway', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartRanAway', 'UVCommander')
		end
	end
	
	function UVChatterPursuitStartAcknowledge(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			if #UVWantedTableVehicle > 1 then
				return UVSoundChatter(self, self.voice, "pursuitstartacknowledgemultipleenemies", nil, "DISPATCH")
			else
				if UVHeatLevel < 2 then
					return UVSoundChatter(self, self.voice, "pursuitstartacknowledge", nil, "DISPATCH")
				elseif UVHeatLevel < 5 then
					return UVSoundChatter(self, self.voice, "pursuitstartacknowledgemed", nil, "DISPATCH")
				else
					return UVSoundChatter(self, self.voice, "pursuitstartacknowledgehigh", nil, "DISPATCH")
				end
			end
		end
		-- UVDelayChatter()
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		if self.v.UVPatrol then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartAcknowledge', 'UVPatrol')	
		elseif self.v.UVSupport then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartAcknowledge', 'UVSupport')	
		elseif self.v.UVPursuit then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartAcknowledge', 'UVPursuit')	
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartAcknowledge', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartAcknowledge', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {['suspectmodel'] = e}, 'PursuitStartAcknowledge', 'UVCommander')
		end
	end
	
	function UVChatterTrafficStopSpeeding(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = UVSoundChatter(self, self.voice, "trafficstopspeeding")
			timer.Simple(timecheck, function()
				if IsValid(self) and not UVEnemyBusted then
					UVChatterDispatchAcknowledgeRequest(self)
				end
			end)
			return
		end
		if UVChatterDelayed then return end
		-- UVDelayChatter()
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		if self.v.UVPatrol then
			UVTextChatter(self, {['suspectmodel'] = e}, 'TrafficStopSpeeding', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {['suspectmodel'] = e}, 'TrafficStopSpeeding', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {['suspectmodel'] = e}, 'TrafficStopSpeeding', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {['suspectmodel'] = e}, 'TrafficStopSpeeding', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {['suspectmodel'] = e}, 'TrafficStopSpeeding', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {['suspectmodel'] = e}, 'TrafficStopSpeeding', 'UVCommander')
		end
	end
	
	function UVChatterTrafficStopRammed(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = UVSoundChatter(self, self.voice, "trafficstoprammed", 3)
			timer.Simple(timecheck, function()
				if IsValid(self) and not UVEnemyBusted then
					UVChatterDispatchAcknowledgeRequest(self)
				end
			end)
			return
		end
		-- UVDelayChatter()
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		if self.v.UVPatrol then
			UVTextChatter(self, {}, 'TrafficStopRammed', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {}, 'TrafficStopRammed', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'TrafficStopRammed', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'TrafficStopRammed', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'TrafficStopRammed', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'TrafficStopRammed', 'UVCommander')
		end
	end
	
	function UVChatterLeftPursuit(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "leftpursuit")
		end
		-- UVDelayChatter()
		if self.v.UVPatrol then
			UVTextChatter(self, {}, 'LeftPursuit', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {}, 'LeftPursuit', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {}, 'LeftPursuit', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {}, 'LeftPursuit', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {}, 'LeftPursuit', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {}, 'LeftPursuit', 'UVCommander')
		end
	end
	
	function UVChatterResponding(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			-- if self.v.rhino then
			-- 	return UVSoundChatter(self, self.voice, "responding")
			-- end
			local randomno = math.random(1,10)
			local a = {"DISPATCH", nil}; local selected = a[math.random(1, #a)]
			if randomno == 1 then
				return UVSoundChatter(self, self.voice, "responding")
			elseif randomno == 2 then
				if self.v.rhino then
					return UVSoundChatter(self, self.voice, "rhinoresponding", 1, selected)
				end
				return UVSoundChatter(self, self.voice, "responding", 1, selected)
			else
				return
			end
		end
		-- UVDelayChatter()
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		if self.v.UVPatrol then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Responding', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Responding', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Responding', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Responding', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Responding', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, {['suspectmodel'] = e}, 'Responding', 'UVCommander')
		end
	end
	
	function UVChatterKillswitchStart(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptkillswitchstart")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVPursuit then
			UVTextChatter(self, args, 'KillswitchStart', 'UVPursuit')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'KillswitchStart', 'UVSpecial')
		end
	end
	
	function UVChatterKillswitchMissed(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptkillswitchmissed")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVPursuit then
			UVTextChatter(self, args, 'KillswitchMissed', 'UVPursuit')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'KillswitchMissed', 'UVSpecial')
		end
	end

	function UVChatterESFDeployed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptesfdeployed")
		end
	end

	function UVChatterESFHit( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptesfhit")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVPursuit then
			UVTextChatter(self, args, 'ESFHit', 'UVPursuit')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'ESFHit', 'UVSpecial')
		end
	end

	function UVChatterESFMissed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptesfmissed")
		end
	end

	function UVChatterEMPDeployed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptempdeployed")
		end
	end

	function UVChatterEMPHit( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptemphit")
		end
	end

	function UVChatterEMPMissed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptempmissed")
		end
	end

	function UVChatterShockRamDeployed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptshockramdeployed")
		end
	end

	function UVChatterShockRamHit( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptshockramhit")
		end
	end

	function UVChatterShockRamMissed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptshockrammissed")
		end
	end

	function UVChatterGPSDartDeployed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptgpsdartdeployed")
		end
	end

	function UVChatterGPSDartHit( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptgpsdarthit")
		end
	end

	function UVChatterGPSDartMissed( self )
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptgpsdartmissed")
		end
	end

	function UVChatterRepairKitDeployed(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptrepairkitdeployed")
		end
		-- UVDelayChatter()

		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVPursuit then
			UVTextChatter(self, args, 'RepairKitDeployed', 'UVPursuit')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'RepairKitDeployed', 'UVSpecial')
		end
	end
	
	function UVChatterKillswitchHit(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptkillswitchhit")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVPursuit then
			UVTextChatter(self, args, 'KillswitchHit', 'UVPursuit')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'KillswitchHit', 'UVSpecial')
		end
	end
	
	function UVChatterSpikeStripDeployed(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptspikestripdeployed")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVInterceptor then
			UVTextChatter(self, args, 'SpikeStripDeployed', 'UVInterceptor')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'SpikeStripDeployed', 'UVCommander')
		end
	end
	
	function UVChatterBusting(self)
		if UVChatterDelayed then return end
		local randomno = math.random(1,2)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			if randomno == 1 then
				return UVSoundChatter(self, self.voice, "busting")
			else
				return UVSoundChatter(self, self.voice, "busting", 2)
			end
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'Busting', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Busting', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'Busting', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Busting', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'Busting', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Busting', 'UVCommander')
		end
	end
	
	function UVChatterBustEvaded(self)
		if UVChatterDelayed or not IsValid(self.v) then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "bustevaded")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if not self.v then return end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'BustEvaded', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'BustEvaded', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'BustEvaded', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'BustEvaded', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'BustEvaded', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'BustEvaded', 'UVCommander')
		end
	end
	
	function UVChatterEnemyInfront(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "enemyinfront")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVInterceptor then
			UVTextChatter(self, args, 'EnemyInfront', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'EnemyInfront', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'EnemyInfront', 'UVCommander')
		end
	end
	
	function UVChatterAggressive(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			timecheck = UVSoundChatter(self, self.voice, "aggressive")
			timer.Simple(timecheck, function()
				if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if unit == self then return end
					UVChatterAcknowledgeRequest(unit)
				end
			end)
			return
		end
		-- UVDelayChatter()
		timer.Simple(math.random(3,5), function()
			if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				if unit == self then return end
				UVChatterAcknowledgeRequest(unit)
			end
		end)
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'Aggressive', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Aggressive', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'Aggressive', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Aggressive', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'Aggressive', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Aggressive', 'UVCommander')
		end
	end
	
	function UVChatterPassive(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			timecheck = UVSoundChatter(self, self.voice, "passive")
			timer.Simple(timecheck, function()
				if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if unit == self then return end
					UVChatterAcknowledgeGeneral(unit)
				end
			end)
			return
		end
		-- UVDelayChatter()
		timer.Simple(math.random(3,5), function()
			if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				if unit == self then return end
				UVChatterAcknowledgeGeneral(unit)
			end
		end)
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'Passive', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Passive', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'Passive', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Passive', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'Passive', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Passive', 'UVCommander')
		end
	end
	
	function UVChatterCloseToEnemy(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local randomno = math.random(1,2)
			if randomno == 1 then
				return UVSoundChatter(self, self.voice, "closetoenemy")
			else
				return UVSoundChatter(self, self.voice, "closetoenemy", 2)
			end
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'CloseToEnemy', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'CloseToEnemy', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'CloseToEnemy', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'CloseToEnemy', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'CloseToEnemy', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'CloseToEnemy', 'UVCommander')
		end
	end
	
	function UVChatterFoundEnemy(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			UVResetChatterQueue()
			return UVSoundChatter(self, self.voice, "foundenemy", 4)
		end

		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'FoundEnemy', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'FoundEnemy', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'FoundEnemy', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'FoundEnemy', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'FoundEnemy', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'FoundEnemy', 'UVCommander')
		end
	end
	
	function UVChatterFoundMultipleEnemies(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "foundmultipleenemies")
				end
			end
			return UVSoundChatter(self, self.voice, "foundmultipleenemies")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'FoundMultipleEnemies', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'FoundMultipleEnemies', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'FoundMultipleEnemies', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'FoundMultipleEnemies', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'FoundMultipleEnemies', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'FoundMultipleEnemies', 'UVCommander')
		end
	end
	
	function UVChatterLosing(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")

			UVResetChatterQueue()
			
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					timecheck = UVSoundChatter(unit, unit.voice, "losing")
				else
					timecheck = UVSoundChatter(self, self.voice, "losing")
				end
			else
				timecheck = UVSoundChatter(self, self.voice, "losing")
			end
			
			timer.Simple(timecheck, function()
				if next(ents.FindByClass("npc_uv*")) ~= nil and UVEnemyEscaping then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					UVChatterLosingAcknowledge(unit)
				end
			end)
			return
		end
		timer.Simple(math.random(3,5), function()
			if next(ents.FindByClass("npc_uv*")) ~= nil and UVEnemyEscaping then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				UVChatterLosingAcknowledge(unit)
			end
		end)
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'Losing', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Losing', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'Losing', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Losing', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'Losing', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Losing', 'UVCommander')
		end
	end
	
	function UVChatterLosingAcknowledge(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "losingacknowledge", 7)
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'LosingAcknowledge', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'LosingAcknowledge', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'LosingAcknowledge', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'LosingAcknowledge', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'LosingAcknowledge', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'LosingAcknowledge', 'UVCommander')
		end
	end
	
	function UVChatterLosingUpdate(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local randomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil and randomno == 1 then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) then
					UVSoundChatter(unit, unit.voice, "losingupdate", 1, "DISPATCH") -- !! MIGHT BE BETTER TO PUT THIS INSIDE THE UNITS FOLDER TOO !!
				else
					UVSoundChatter(self, self.voice, "losingupdate", 1, "DISPATCH") -- !! MIGHT BE BETTER TO PUT THIS INSIDE THE UNITS FOLDER TOO !!
				end
			else
				UVSoundChatter(self, self.voice, "losingupdate", 1, "DISPATCH") -- !! MIGHT BE BETTER TO PUT THIS INSIDE THE UNITS FOLDER TOO !!
			end
			return
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'LosingUpdate', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'LosingUpdate', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'LosingUpdate', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'LosingUpdate', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'LosingUpdate', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'LosingUpdate', 'UVCommander')
		end
	end
	
	function UVChatterLost(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			-- timecheck = UVSoundChatter(self, self.voice, "lost", 1, "DISPATCH") -- MIGHT BE BETTER TO PUT THIS INSIDE THE UNITS FOLDER TOO
			timecheck = UVSoundChatter(self, self.voice, "lost")
			timer.Simple(timecheck, function()
				UVSoundChatter(Entity(1), 1, "lostacknowledge", 1, "DISPATCH")
			end)
			return
		end
		timer.Simple(5, function()
			UVChatterLostAcknowledge(self)
		end)
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'Lost', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Lost', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'Lost', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Lost', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'Lost', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Lost', 'UVCommander')
		end
	end
	
	function UVChatterLostAcknowledge(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "lostacknowledge", 1, "DISPATCH")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'LostAcknowledge', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'LostAcknowledge', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'LostAcknowledge', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'LostAcknowledge', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'LostAcknowledge', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'LostAcknowledge', 'UVCommander')
		end
	end
	
	function UVChatterInitialize(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "initialize")
		end
		if UVChatterDelayed then return end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'Initialize', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Initialize', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'Initialize', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Initialize', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'Initialize', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Initialize', 'UVCommander')
		end
	end
	
	--UV mid chatter goes here--
	
	-- function UVChatterAirOnRemove(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "aironremove")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirOnRemove')
	-- end
	
	-- function UVChatterAirArrest(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airarrest")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local e = UVGetVehicleMakeAndModel(self:GetTarget())
	
	-- 	UVTextChatter(self, {['suspectmodel'] = e}, 'AirArrest')
	-- end
	
	-- function UVChatterAirArrestAcknowledge(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airarrestacknowledge")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirArrestAcknowledge')
	-- end
	
	-- function UVChatterAirWreck(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airwreck")
	-- 	end
	-- 	if UVChatterDelayed then return end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirWreck')
	-- end
	
	-- function UVChatterAirSpikeStripDeployed(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airspikestripdeployed")
	-- 	end
	-- 	if UVChatterDelayed then return end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirSpikeStripDeployed')
	-- end
	
	-- function UVChatterAirBusting(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airbusting")
	-- 	end
	-- 	if UVChatterDelayed then return end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirBusting')
	-- end
	
	-- function UVChatterAirBustEvadedUpdate(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airbustevadedupdate")
	-- 	end
	-- 	if UVChatterDelayed then return end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirBustEvadedUpdate')
	-- end
	
	-- function UVChatterAirBustEvaded(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airbustevaded")
	-- 	end
	-- 	if UVChatterDelayed then return end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirBustEvaded')
	-- end
	
	-- function UVChatterAirAggressive(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airaggressive")
	-- 	end
	-- 	if UVChatterDelayed then return end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirAggressive')
	-- end
	
	-- function UVChatterAirPassive(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airpassive")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirPassive')
	-- end
	
	-- function UVChatterAirCloseToEnemy(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airclosetoenemy", 2)
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self:GetTarget()) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self:GetTarget())
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirCloseToEnemy')
	-- end
	
	-- function UVChatterAirFoundEnemy(self)
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airfoundenemy", 4)
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirFoundEnemy')
	-- end
	
	-- function UVChatterAirInitialize(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		local randomno = math.random(1,2)
	-- 		if randomno == 1 then
	-- 			UVSoundChatter(self, self.voice, "airinitialize")
	-- 		else
	-- 			UVSoundChatter(self, self.voice, "airinitialize", 1)
	-- 		end
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirInitialize')
	-- end
	
	-- function UVChatterAirSpottedEnemy(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airspottedenemy")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirSpottedEnemy')
	-- end
	
	-- function UVChatterAirLowOnFuel(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airlowonfuel")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirLowOnFuel')
	-- end
	
	-- function UVChatterAirDisengaging(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airdisengaging")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirDisengaging')
	-- end
	
	-- function UVChatterAirSpikeStripMiss(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airspikestripmiss")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirSpikeStripMiss')
	-- end
	
	-- function UVChatterAirSpikeStripHit(unit)
	-- 	--if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(unit, unit.voice, "airspikestriphit")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(unit.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(unit.e)
	-- 	end
	
	-- 	UVTextChatter(unit, args, 'AirSpikeStripHit')
	-- end
	
	-- function UVChatterAirExplosiveBarrelDeployed(self)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(self, self.voice, "airexplosivebarreldeployed")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(self.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
	-- 	end
	
	-- 	UVTextChatter(self, args, 'AirExplosiveBarrelDeployed')
	-- end
	
	-- function UVChatterAirExplosiveBarrelHit(unit)
	-- 	if UVChatterDelayed then return end
	-- 	if not GetConVar("unitvehicle_chattertext"):GetBool() then
	-- 		return UVSoundChatter(unit, unit.voice, "airexplosivebarrelhit")
	-- 	end
	-- 	-- UVDelayChatter()
	
	-- 	local args = {}
	-- 	if IsValid(unit.e) then
	-- 		args['suspectmodel'] = UVGetVehicleMakeAndModel(unit.e)
	-- 	end
	
	-- 	UVTextChatter(unit, args, 'AirExplosiveBarrelHit')
	-- end
	
	function UVChatterDisengaging(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "disengaging")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		UVTextChatter(self, args, 'Disengaging')
	end
	
	function UVChatterExplosiveBarrelDeployed(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptexplosivebarreldeployed")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		UVTextChatter(self, args, 'ExplosiveBarrelDeployed')
	end
	
	function UVChatterSpikeStripMiss(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "ptspikestripmissed")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then	
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		UVTextChatter(self, args, 'SpikeStripMiss')
	end
	
	function UVChatterSpottedEnemy(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "spottedenemy")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		UVTextChatter(self, args, 'SpottedEnemy')
	end
	
	function UVChatterLowOnFuel(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "lowonfuel")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		UVTextChatter(self, args, 'LowOnFuel')
	end
	
	
	function UVChatterSpikeStripHit(unit)
		--if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "ptspikestriphit", 1, "DISPATCH")
				end
			end
			local randomno = math.random(1,2)
			local a = {"DISPATCH", nil}; local selected = a[math.random(1, #a)]
			if randomno == 1 then
				return UVSoundChatter(unit, unit.voice, "ptspikestriphit")
			else
				return UVSoundChatter(unit, unit.voice, "ptspikestriphit", 1, selected)
			end
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(unit.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(unit.e)
		end
		
		if unit.v.UVInterceptor then
			UVTextChatter(unit, args, 'SpikeStripHit', 'UVInterceptor')
		elseif unit.v.UVCommander then
			UVTextChatter(unit, args, 'SpikeStripHit', 'UVCommander')
		end
	end
	
	function UVChatterExplosiveBarrelHit(unit)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(unit, unit.voice, "ptexplosivebarrelhit")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(unit.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(unit.e)
		end
		
		if unit.v.UVSpecial then
			UVTextChatter(unit, args, 'ExplosiveBarrelHit', 'UVSpecial')
		elseif unit.v.UVCommander then
			UVTextChatter(unit, args, 'ExplosiveBarrelHit', 'UVCommander')
		end
	end
	
	function UVChatterEnemyCrashed(unit)
		if UVChatterDelayed then return end
		-- UVDelayChatter()
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1, 2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "enemycrashed")
				end
			end
			return UVSoundChatter(unit, unit.voice, "enemycrashed")
		end
		
		local args = {}
		if IsValid(unit.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(unit.e)
		end
		
		if unit.v.UVPatrol then
			UVTextChatter(unit, args, 'EnemyCrashed', 'UVPatrol')
		elseif unit.v.UVSupport then
			UVTextChatter(unit, args, 'EnemyCrashed', 'UVSupport')
		elseif unit.v.UVPursuit then
			UVTextChatter(unit, args, 'EnemyCrashed', 'UVPursuit')
		elseif unit.v.UVInterceptor then
			UVTextChatter(unit, args, 'EnemyCrashed', 'UVInterceptor')
		elseif unit.v.UVSpecial then
			UVTextChatter(unit, args, 'EnemyCrashed', 'UVSpecial')
		elseif unit.v.UVCommander then
			UVTextChatter(unit, args, 'EnemyCrashed', 'UVCommander')
		end
	end
	
	--UV new chatter goes here--
	
	function UVChatterDispatchAcknowledgeRequest(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "dispatchacknowledgerequest", 1)
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, args, 'DispatchAcknowledgeRequest', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, args, 'DispatchAcknowledgeRequest', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, args, 'DispatchAcknowledgeRequest', 'UVSpecial_UVCommander')
		end
	end
	
	function UVChatterDispatchDenyRequest(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "denyrequest")
				end
			end
			return UVSoundChatter(self, self.voice, "denyrequest")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, args, 'DispatchDenyRequest', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, args, 'DispatchDenyRequest', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, args, 'DispatchDenyRequest', 'UVSpecial_UVCommander')
		end
	end
	
	function UVChatterDispatchIdleTalk(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "dispatchidletalk", 1)
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, args, 'DispatchIdleTalk', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, args, 'DispatchIdleTalk', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, args, 'DispatchIdleTalk', 'UVSpecial_UVCommander')
		end
	end
	
	function UVChatterAcknowledgeGeneral(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "acknowledgegeneral")
				end
			end
			return UVSoundChatter(self, self.voice, "acknowledgegeneral")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		UVTextChatter(self, args, 'AcknowledgeGeneral')
	end
	
	function UVChatterAcknowledgeRequest(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "acknowledgerequest")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then 
			UVTextChatter(self, args, 'AcknowledgeRequest', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'AcknowledgeRequest', 'UVSupport')
		elseif self.v.UVPursuit then 
			UVTextChatter(self, args, 'AcknowledgeRequest', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'AcknowledgeRequest', 'UVInterceptor')
		elseif self.v.UVSpecial then 
			UVTextChatter(self, args, 'AcknowledgeRequest', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'AcknowledgeRequest', 'UVCommander')
		end
	end
	
	function UVChatterDenyRequest(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "denyrequest")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then 
			UVTextChatter(self, args, 'DenyRequest', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'DenyRequest', 'UVSupport')
		elseif self.v.UVPursuit then 
			UVTextChatter(self, args, 'DenyRequest', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'DenyRequest', 'UVInterceptor')
		elseif self.v.UVSpecial then 
			UVTextChatter(self, args, 'DenyRequest', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'DenyRequest', 'UVCommander')
		end
	end
	
	function UVChatterIdleTalk(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "idletalk", 1, "DISPATCH")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then 
			UVTextChatter(self, args, 'IdleTalk', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'IdleTalk', 'UVSupport')
		elseif self.v.UVPursuit then 
			UVTextChatter(self, args, 'IdleTalk', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'IdleTalk', 'UVInterceptor')
		elseif self.v.UVSpecial then 
			UVTextChatter(self, args, 'IdleTalk', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'IdleTalk', 'UVCommander')
		end
	end
	
	function UVChatterDamaged(self)
		if UVChatterDelayed or not UVTargeting then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local function ChatterChopperUnavailable()
				if next(ents.FindByClass("npc_uv*")) ~= nil then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if unit == self then return end
					timecheck = UVSoundChatter(unit, unit.voice, "damagedcheckin")
					timer.Simple(timecheck, function()
						if IsValid(self) then
							UVSoundChatter(self, self.voice, "damaged") 
						end
					end)
				end
			end
			local randomno = math.random(1,2)
			local timecheck = 5
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil and randomno == 1 then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) then
					timecheck = UVSoundChatter(unit, unit.voice, "damagedcheckin")
					timer.Simple(timecheck, function()
						if IsValid(self) then
							UVSoundChatter(self, self.voice, "damaged") 
						end
					end)
				else
					ChatterChopperUnavailable()
				end
			else
				ChatterChopperUnavailable()
			end
			return
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then 
			UVTextChatter(self, args, 'Damaged', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Damaged', 'UVSupport')
		elseif self.v.UVPursuit then 
			UVTextChatter(self, args, 'Damaged', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Damaged', 'UVInterceptor')
		elseif self.v.UVSpecial then 
			UVTextChatter(self, args, 'Damaged', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Damaged', 'UVCommander')
		end
	end
	
	function UVChatterRammed(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "rammed")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then 
			UVTextChatter(self, args, 'Rammed', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Rammed', 'UVSupport')
		elseif self.v.UVPursuit then 
			UVTextChatter(self, args, 'Rammed', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Rammed', 'UVInterceptor')
		elseif self.v.UVSpecial then 
			UVTextChatter(self, args, 'Rammed', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Rammed', 'UVCommander')
		end
	end
	
	function UVChatterRammedEnemy(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "rammedenemy")
				end
			end
			return UVSoundChatter(self, self.voice, "rammedenemy")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'RammedEnemy', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'RammedEnemy', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'RammedEnemy', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'RammedEnemy', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'RammedEnemy', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'RammedEnemy', 'UVCommander')
		end
	end
	
	function UVChatterRequestBackup(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					timecheck = UVSoundChatter(unit, unit.voice, "requestbackup", 1)
				else
					timecheck = UVSoundChatter(self, self.voice, "requestbackup", 1)
				end
			else
				timecheck = UVSoundChatter(self, self.voice, "requestbackup", 1)
			end
			timer.Simple(timecheck, function()
				if IsValid(self) then
					UVChatterBackupOnTheWay(self)
				end
			end)
			return
		end
		-- UVDelayChatter()
		timer.Simple(math.random(3,5), function()
			if IsValid(self) then
				UVChatterBackupOnTheWay(self)
			end
		end)
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'RequestBackup', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'RequestBackup', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'RequestBackup', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'RequestBackup', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'RequestBackup', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'RequestBackup', 'UVCommander')
		end
	end
	
	function UVChatterOnScene(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "onscene", 5)
		end
		local seconds = 5
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'OnScene', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'OnScene', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'OnScene', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'OnScene', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'OnScene', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'OnScene', 'UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterBackupOnTheWay(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			local randomno = math.random(1,2)
			-- if randomno == 1 then
			-- 	timecheck = UVSoundChatter(self, self.voice, "backupontheway")
			-- else
			-- 	timecheck = UVSoundChatter(self, self.voice, "backupontheway", 1, "DISPATCH")
			-- end
			timecheck = UVSoundChatter(self, self.voice, "backupontheway", 1, "DISPATCH")
			timer.Simple(timecheck, function()
				if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if unit == self then return end
					UVChatterAcknowledgeGeneral(unit)
				end
			end)
			return
		end
		local seconds = 5
		timer.Simple(math.random(3,5), function()
			if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				UVChatterAcknowledgeGeneral(unit)
			end
		end)
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, args, 'BackupOnTheWay', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, args, 'BackupOnTheWay', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, args, 'BackupOnTheWay', 'UVSpecial_UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterBackupOnScene(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			local randomno = math.random(1,2)
			if randomno == 1 then
				local airrandomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
						timecheck = UVSoundChatter(unit, unit.voice, "backuponscene")
					else
						timecheck = UVSoundChatter(self, self.voice, "backuponscene")
					end
				else
					timecheck = UVSoundChatter(self, self.voice, "backuponscene")
				end
			else
				timecheck = UVSoundChatter(self, self.voice, "backuponscene", 1, "DISPATCH")
			end
			timer.Simple(timecheck, function()
				if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if unit == self then return end
					UVChatterAcknowledgeGeneral(unit)
				end
			end)
			return
		end
		local seconds = 5
		timer.Simple(math.random(3,5), function()
			if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				UVChatterAcknowledgeGeneral(unit)
			end
		end)
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, args, 'BackupOnScene', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, args, 'BackupOnScene', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, args, 'BackupOnScene', 'UVSpecial_UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterHitTraffic(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "hittraffic")
				end
			end
			return UVSoundChatter(self, self.voice, "hittraffic")
		end
		local seconds = 5
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'HitTraffic', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'HitTraffic', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'HitTraffic', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'HitTraffic', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'HitTraffic', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'HitTraffic', 'UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterMultipleUnitsDown(self)
		if UVChatterDelayed or not UVTargeting then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local randomno = math.random(1,2)
			local timecheck = 5
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil and randomno == 1 then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) then
					timecheck = UVSoundChatter(unit, unit.voice, "multipleunitsdown", 4)
				else
					timecheck = UVSoundChatter(self, self.voice, "multipleunitsdown", 4)
				end
			else
				timecheck = UVSoundChatter(self, self.voice, "multipleunitsdown", 4)
			end
			timer.Simple(timecheck, function()
				if IsValid(self) then
					return UVSoundChatter(self, self.voice, "dispatchmultipleunitsdownacknowledge", 1, "DISPATCH")
				end
			end)
			return
		end
		local seconds = 5
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'MultipleUnitsDown', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'MultipleUnitsDown', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'MultipleUnitsDown', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'MultipleUnitsDown', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'MultipleUnitsDown', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'MultipleUnitsDown', 'UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterAirDown(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "airdown", 4)
		end
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		UVTextChatter(self, args, 'AirDown')
	end
	
	function UVChatterRequestSitrep(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local MathAsk = math.random(1,2)
			if MathAsk == 2 then
				if UVEnemyEscaping then --During cooldown
					UVChatterLosingUpdate(self)
				else
					local MathReply = math.random(1,2)
					if MathReply == 1 then
						UVChatterSitrep(self)
					else
						UVChatterUpdateHeading(self)
					end
				end
				return
			end
			local timecheck = 5
			timecheck = UVSoundChatter(self, self.voice, "requestsitrep", 1, "DISPATCH")
			timer.Simple(timecheck, function()
				if IsValid(self) then
					if UVEnemyEscaping then --During cooldown
						UVChatterLosingUpdate(self)
					else
						local MathReply = math.random(1,2)
						if MathReply == 1 then
							UVChatterSitrep(self)
						else
							UVChatterUpdateHeading(self)
						end
					end
				end
			end)
			return
		end
		-- UVDelayChatter()
		local MathAsk = math.random(1,2)
		if MathAsk == 2 then
			if UVEnemyEscaping then --During cooldown
				UVChatterLosingUpdate(self)
			else
				local MathReply = math.random(1,2)
				if MathReply == 1 then
					UVChatterSitrep(self)
				else
					UVChatterUpdateHeading(self)
				end
			end
			return
		end
		timer.Simple(math.random(3,5), function()
			if IsValid(self) then
				if UVEnemyEscaping then --During cooldown
					UVChatterLosingUpdate(self)
				else
					local MathReply = math.random(1,2)
					if MathReply == 1 then
						UVChatterSitrep(self)
					else
						UVChatterUpdateHeading(self)
					end
				end
			end
		end)
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, args, 'RequestSitrep', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, args, 'RequestSitrep', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, args, 'RequestSitrep', 'UVSpecial_UVCommander')
		end
	end
	
	function UVChatterSitrep(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "sitrep")
				end
			end
			return UVSoundChatter(self, self.voice, "sitrep")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'Sitrep', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'Sitrep', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'Sitrep', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'Sitrep', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'Sitrep', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'Sitrep', 'UVCommander')
		end
	end
	
	function UVChatterUpdateHeading(self)
		if not IsValid(self.e) then return end
		local Heading = self.e:GetVelocity():Angle().y
		local args = {}
		
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.e:GetVelocity():Length2DSqr() < 50000 then --Stopped
			if not GetConVar("unitvehicle_chattertext"):GetBool() then
				return UVSoundChatter(self, self.voice, "headingstopped")
			end
			-- UVDelayChatter()
			if self.v.UVPatrol or self.v.UVSupport then
				UVTextChatter(self, args, 'UpdateHeading', 'Stopped', 'UVPatrol_UVSupport')
			elseif self.v.UVPursuit then
				UVTextChatter(self, args, 'UpdateHeading', 'Stopped', 'UVPursuit')
			elseif self.v.UVSpecial or self.v.UVCommander then
				UVTextChatter(self, args, 'UpdateHeading', 'Stopped', 'UVSpecial_UVCommander')
			end
		elseif Heading > 45 and Heading < 135 then --North
			if not GetConVar("unitvehicle_chattertext"):GetBool() then
				local airrandomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
						return UVSoundChatter(unit, unit.voice, "headingnorth")
					end
				end
				return UVSoundChatter(self, self.voice, "headingnorth")
			end
			-- UVDelayChatter()
			UVTextChatter(self, args, 'UpdateHeading', 'North')
		elseif Heading > 315 and Heading < 45 then --East
			if not GetConVar("unitvehicle_chattertext"):GetBool() then
				local airrandomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
						return UVSoundChatter(unit, unit.voice, "headingeast")
					end
				end
				return UVSoundChatter(self, self.voice, "headingeast")
			end
			-- UVDelayChatter()
			UVTextChatter(self, args, 'UpdateHeading', 'East')
		elseif Heading > 225 and Heading < 315 then --South
			if not GetConVar("unitvehicle_chattertext"):GetBool() then
				local airrandomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
						return UVSoundChatter(unit, unit.voice, "headingsouth")
					end
				end
				return UVSoundChatter(self, self.voice, "headingsouth")
			end
			-- UVDelayChatter()
			UVTextChatter(self, args, 'UpdateHeading', 'South')
		elseif Heading > 135 and Heading < 225 then --West
			if not GetConVar("unitvehicle_chattertext"):GetBool() then
				local airrandomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
						return UVSoundChatter(unit, unit.voice, "headingwest")
					end
				end
				return UVSoundChatter(self, self.voice, "headingwest")
			end
			-- UVDelayChatter()
			UVTextChatter(self, args, 'UpdateHeading', 'West')
		end
	end
	
	function UVChatterRequestDisengage(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					timecheck = UVSoundChatter(unit, unit.voice, "requestdisengage")
				else
					timecheck = UVSoundChatter(self, self.voice, "requestdisengage")
				end
			else
				timecheck = UVSoundChatter(self, self.voice, "requestdisengage")
			end
			timer.Simple(timecheck, function()
				if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if unit == self then return end
					UVChatterDoNotDisengage(unit, self)
				end
			end)
			return
		end
		-- UVDelayChatter()
		timer.Simple(math.random(3,5), function()
			if next(ents.FindByClass("npc_uv*")) ~= nil and not UVEnemyBusted then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				if unit == self then return end
				UVChatterDoNotDisengage(unit, self)
			end
		end)
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'RequestDisengage', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'RequestDisengage', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'RequestDisengage', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'RequestDisengage', 'UVInterceptor')
		end
	end
	
	function UVChatterDoNotDisengage(self, unit)
		if not unit.callsign then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "donotdisengage")
		end
		-- UVDelayChatter()
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		if unit.callsign then
			args['altcallsign'] = unit.callsign
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'DoNotDisengage', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'DoNotDisengage', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'DoNotDisengage', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'DoNotDisengage', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'DoNotDisengage', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'DoNotDisengage', 'UVCommander')
		end
	end
	
	function UVChatterDispatchCallDamageToProperty(heatlevel)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(Entity(1), 1, "dispatchcalldamagetoproperty", 6)
		end
		local seconds = 5
		
		local args = {}
		-- if IsValid(self.e) then
		-- 	args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		-- end
		
		if heatlevel < 3 then
			UVTextChatter(self, args, 'DispatchCallDamageToProperty', 'Low')
		elseif heatlevel < 5 then
			UVTextChatter(self, args, 'DispatchCallDamageToProperty', 'Medium')
		else
			UVTextChatter(self, args, 'DispatchCallDamageToProperty', 'High')
		end
		
		return seconds
	end
	
	function UVChatterDispatchCallHitAndRun(heatlevel)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(Entity(1), 1, "dispatchcallhitandrun", 6)
		end
		local seconds = 5
		
		local args = {}
		-- if IsValid(self.e) then
		-- 	args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		-- end
		
		if heatlevel < 3 then
			UVTextChatter(self, args, 'DispatchCallHitAndRun', 'Low')
		elseif heatlevel < 5 then
			UVTextChatter(self, args, 'DispatchCallHitAndRun', 'Medium')
		else
			UVTextChatter(self, args, 'DispatchCallHitAndRun', 'High')
		end
		
		return seconds
	end
	
	function UVChatterDispatchCallSpeeding(heatlevel)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(Entity(1), 1, "dispatchcallspeeding", 6)
		end
		local seconds = 5
		
		local args = {}
		-- if IsValid(self.e) then
		-- 	args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		-- end
		
		if heatlevel < 3 then
			UVTextChatter(self, args, 'DispatchCallSpeeding', 'Low')
		elseif heatlevel < 5 then
			UVTextChatter(self, args, 'DispatchCallSpeeding', 'Medium')
		else
			UVTextChatter(self, args, 'DispatchCallSpeeding', 'High')
		end
		
		return seconds
	end
	
	function UVChatterDispatchCallStreetRacing(heatlevel)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(Entity(1), 1, "dispatchcallstreetracing", 6)
		end
		local seconds = 5
		
		local args = {}
		-- if IsValid(self.e) then
		-- 	args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		-- end
		
		if heatlevel < 3 then
			UVTextChatter(self, args, 'DispatchCallStreetRacing', 'Low')
		elseif heatlevel < 5 then
			UVTextChatter(self, args, 'DispatchCallStreetRacing', 'Medium')
		else
			UVTextChatter(self, args, 'DispatchCallStreetRacing', 'High')
		end
		return seconds
	end
	
	function UVChatterDispatchCallVehicleDescription(self, vehicle, model)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, nil, 10, "DISPATCH", vehicle)
			--return UVSoundChatter(self, self.voice, "dispatchcallunknowndescription", 1, "DISPATCH")
		end
		if UVTargeting or not self or not vehicle then return end
		local color = UVColorName(vehicle)
		local seconds = 5
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, {['suspectmodel'] = model, ['suspectcolor'] = color}, 'DispatchCallVehicleDescription', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, {['suspectmodel'] = model, ['suspectcolor'] = color}, 'DispatchCallVehicleDescription', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, {['suspectmodel'] = model, ['suspectcolor'] = color}, 'DispatchCallVehicleDescription', 'UVSpecial_UVCommander')
		end
		return seconds
	end
	
	function UVChatterDispatchCallUnknownDescription(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "dispatchcallunknowndescription", 1, "DISPATCH")
		end
		if UVTargeting then return end
		local seconds = 5
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol or self.v.UVSupport then
			UVTextChatter(self, args, 'DispatchCallUnknownDescription', 'UVPatrol_UVSupport')
		elseif self.v.UVPursuit or self.v.UVInterceptor then
			UVTextChatter(self, args, 'DispatchCallUnknownDescription', 'UVPursuit_UVInterceptor')
		elseif self.v.UVSpecial or self.v.UVCommander then
			UVTextChatter(self, args, 'DispatchCallUnknownDescription', 'UVSpecial_UVCommander')
		end
		return seconds
	end
	
	function UVChatterCallRequestDescription(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "callrequestdescription", 1)
		end
		if UVTargeting then return end
		
		local seconds = 5
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'CallRequestDescription', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'CallRequestDescription', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'CallRequestDescription', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'CallRequestDescription', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'CallRequestDescription', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'CallRequestDescription', 'UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterCallResponding(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "callresponding", 5)
		end
		if UVTargeting then return end
		local seconds = 5
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'CallResponding', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'CallResponding', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'CallResponding', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'CallResponding', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'CallResponding', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'CallResponding', 'UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterCallResponded(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "callresponded")
		end
		local seconds = 5
		
		local args = {}
		if IsValid(self.e) then
			args['suspectmodel'] = UVGetVehicleMakeAndModel(self.e)
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'CallResponded', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'CallResponded', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'CallResponded', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'CallResponded', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'CallResponded', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'CallResponded', 'UVCommander')
		end
		
		return seconds
	end
	
	function UVChatterPursuitStartWanted(self)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = 5
			timecheck = UVSoundChatter(self, self.voice, "pursuitstartwanted", 4)
			timer.Simple(timecheck, function()
				if IsValid(self) and IsValid(self.e) then
					local e = UVGetVehicleMakeAndModel(self.e)
					UVChatterVehicleDescription(self, self.e, e)
				end
			end)
			return
		end
		-- UVDelayChatter()
		timer.Simple(math.random(3,4), function()
			if IsValid(self) then
				UVChatterPursuitStartAcknowledge(self)
			end
		end)
		if not IsValid(self.e) then return end
		local e = UVGetVehicleMakeAndModel(self.e)
		local args = {}
		if e then
			args['suspectmodel'] = e
		end
		
		if self.v.UVPatrol then
			UVTextChatter(self, args, 'PursuitStartWanted', 'UVPatrol')
		elseif self.v.UVSupport then
			UVTextChatter(self, args, 'PursuitStartWanted', 'UVSupport')
		elseif self.v.UVPursuit then
			UVTextChatter(self, args, 'PursuitStartWanted', 'UVPursuit')
		elseif self.v.UVInterceptor then
			UVTextChatter(self, args, 'PursuitStartWanted', 'UVInterceptor')
		elseif self.v.UVSpecial then
			UVTextChatter(self, args, 'PursuitStartWanted', 'UVSpecial')
		elseif self.v.UVCommander then
			UVTextChatter(self, args, 'PursuitStartWanted', 'UVCommander')
		end
	end
	
	function UVChatterStuntJump(self)
		if UVChatterDelayed then return end
		-- UVDelayChatter()
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "stuntjump")
		end
	end
	
	function UVChatterStuntRoll(self)
		if UVChatterDelayed then return end
		-- UVDelayChatter()
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "stuntroll")
		end
	end
	
	function UVChatterStuntSpin(self)
		if UVChatterDelayed then return end
		-- UVDelayChatter()
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			return UVSoundChatter(self, self.voice, "stuntspin")
		end
	end

	function UVChatterVehicleDescription(self, vehicle)
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local timecheck = UVSoundChatter(self, self.voice, nil, 10, "", vehicle)
			if not timecheck then return end
			timer.Simple(timecheck, function()
				if IsValid(self) then
					UVChatterPursuitStartAcknowledge(self)
				end
			end)
			return
		end
	end

	function UVChatterHitTrafficSemi(self)
		if UVChatterDelayed then return end
		if not GetConVar("unitvehicle_chattertext"):GetBool() then
			local airrandomno = math.random(1,2)
			local airUnits = ents.FindByClass("uvair")
			if next(airUnits) ~= nil then
				local random_entry = math.random(#airUnits)	
				local unit = airUnits[random_entry]
				if not (unit.crashing or unit.disengaging) and airrandomno == 1 then
					return UVSoundChatter(unit, unit.voice, "hittrafficsemi")
				end
			end
			return UVSoundChatter(self, self.voice, "hittrafficsemi")
		end
	end
	
end
if CLIENT then
	net.Receive("UV_Text", function()
		chat.AddText( unpack(net.ReadTable()) )
	end)
end