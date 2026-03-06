resource.AddSingleFile("resource/fonts/VCR_OSD_MONO_1.001.ttf")

--convars
local HeatLevels = GetConVar("unitvehicle_heatlevels")
local DetectionRange = GetConVar("unitvehicle_detectionrange")
local PlayMusic = GetConVar("unitvehicle_playmusic")
local NeverEvade = GetConVar("unitvehicle_neverevade")
local BustedTimer = GetConVar("unitvehicle_bustedtimer")
local CanWreck = GetConVar("unitvehicle_canwreck")
local Chatter = GetConVar("unitvehicle_chatter")
local SpeedLimit = GetConVar("unitvehicle_speedlimit")
local AutoHealth = GetConVar("unitvehicle_autohealth")
local MinHeatLevel = GetConVar("unitvehicle_unit_minheat")
local MaxHeatLevel = GetConVar("unitvehicle_unit_maxheat")
local SpikeStripDuration = GetConVar("unitvehicle_spikestripduration")
local Pathfinding = GetConVar("unitvehicle_pathfinding")
local VCModELSPriority = GetConVar("unitvehicle_vcmodelspriority")
local CallResponse = GetConVar("unitvehicle_callresponse")
local Headlights = GetConVar("unitvehicle_enableheadlights")
local SpawnMainUnits = GetConVar("unitvehicle_spawnmainunits")
local RepairCooldown = GetConVar("unitvehicle_repaircooldown")
local RepairRange = GetConVar("unitvehicle_repairrange")
local RacerTags = GetConVar("unitvehicle_racertags")
local RacerPursuitTech = GetConVar("unitvehicle_racerpursuittech")

--unit convars
local UVUHelicopterBusting = GetConVar("unitvehicle_unit_helicopterbusting")

local dvd = DecentVehicleDestination

NETWORK_STRINGS = {
	-- Pursuit Tech
	"UV_SendPursuitTech",
	"UVPTUse",
	"UVPTEvent",
	
	"UVWeaponESFEnable",
	"UVWeaponESFDisable",

	"UVWeaponJuggernautEnable",
	"UVWeaponJuggernautDisable",

	"UVWeaponGrapplerEnable",
	"UVWeaponGrapplerDisable",
	
	"UVWeaponJammerEnable",
	"UVWeaponJammerDisable",
	
	-- Repair Shop
	"UVHUDRepairCooldown",
	"UVHUDRepair",
	"UVHUDRepairAvailable",
	"UVHUDRefilledPT",
	"UVHUDRepairCommander",
	"uvrepairsimfphys",
	"UVRepairShopAdjust",
	"UVRepairShopRetrieve",
	"UVRepairShopCreate",
	"UVRepairShopRefresh",
	"UVRepairShopLoad",
	"UVRepairShopLoadAll",
	
	-- Pursuit Table
	"UVGet_PursuitTable",
	"UVSet_PursuitTable",
	
	-- Chatter / Sounds
	"UV_Chatter",
	"UV_Sound",
	
	-- Settings
	"UVGetSettings_Local",
	"UVUpdateSettings",
	
	-- Keybinds
	'UVGetNewKeybind',
	'UVPTKeybindRequest',

	-- Pursuit
	"UVHUDBackuptimer",
	"UVHUDStopBackupTimer",
	"UVHUDStopPursuit",
	"UVHUDStartPursuitCountdown",
	"UVHUDStartPursuitNotification",
	
	-- Busted / Busting
	"UVBusted",
	"UVHUDUpdateBusting",
	"UVHUDBusting",
	"UVHUDStopBusting",
	"UVHUDStopBustingTimeLeft",
	"UVHUDEnemyBusted",
	
	-- Wanted
	"UVHUDWanted",
	
	-- Evading
	"UVHUDEvading",
	
	-- Cooldown
	"UVHUDCooldown",
	"UVHUDStopCooldown",
	"UVHUDHiding",
	"UVHUDStopHiding",

	-- Fined
	"UVPullOver",
	"UVFined",
	"UVFineArrest",
	
	-- Wanted Suspects
	"UVHUDWantedSuspects",
	
	-- Wanted Vehicles
	"UV_AddWantedVehicle",
	"UV_RemoveWantedVehicle",
	
	-- Cop Mode
	"UVHUDCopMode",
	"UVHUDStopCopMode",
	
	-- Cop Mode Busting
	"UVHUDCopModeBusting",
	"UVHUDStopCopModeBusting",
	
	-- Debrief
	"UVHUDBustedDebrief",
	"UVHUDEscapedDebrief",
	"UVHUDCopModeEscapedDebrief",
	"UVHUDCopModeBustedDebrief",
	"UVHUDWreckedDebrief",
	
	-- Player unit respawn
	"UVHUDRespawnInUV",
	"UVCancelUnitRespawn",
	"UVSpawnQueueUpdate",

	-- Player unit select
	"UVHUDRespawnInUVGetInfo",
	"UVHUDRespawnInUVSelect",
	"UVHUDRespawnInUVPlyMsg",
	
	-- Commander
	"UVHUDOneCommander",
	"UVHUDStopOneCommander",
	
	-- Unit Takedown
	"UVUnitTakedown",
	
	-- Heat level
	"UVHUDHeatLevelIncrease",
	"UVHUDTimeTillNextHeat",
	
	-- Pursuit breakers
	"UVHUDPursuitBreakers",
	"UVAddPursuitBreaker",
	"UVTriggerPursuitBreaker",
	"UVPursuitBreakerAdjust",
	"UVPursuitBreakerRetrieve",
	"UVPursuitBreakerCreate",
	"UVPursuitBreakerRefresh",
	"UVPursuitBreakerLoad",
	"UVPursuitBreakerLoadAll",
	
	-- Roadblocks
	"UVAddRoadblock",
	"UVTriggerRoadblock",
	"UVRoadblocksAdjust",
	"UVRoadblocksRetrieve",
	"UVRoadblocksCreate",
	"UVRoadblocksRefresh",
	"UVRoadblocksLoad",
	"UVRoadblocksLoadAll",
	
	-- Unit Vehicle Add/Remove
	"UVHUDAddUV",
	"UVHUDReAddUV",
	"UVHUDRemoveUV",
	
	-- Unit Manager
	"UVUnitManagerAdjustUnit",
	"UVUnitManagerGetUnitInfo",
	"UVUnitManagerGetUnitAssignment",

	-- Traffic Manager
	"UVTrafficManagerAdjustTraffic",
	"UVTrafficManagerGetTrafficInfo",

	-- Racer Manager
	"UVRacerManagerAdjustRacer",
	"UVRacerManagerGetRacerInfo",
	
	-- Racers
	"UVUpdateRacerName",
	"UVUpdateSuspectVisibility",
	"UVRacerJoin",
	
	-- Race creation
	"UVRace_UpdatePos",
	"UVRace_SelectID",
	"UVRace_SetID",
	"UVRace_SetSpeedLimit",
	"UVStartRace",
	"UVRace_TrackReady",
	"UVRace_RacersList",
	"UVRace_HideRacersList",
	"UVRace_ToolMode",
	
	"UVRace_NodeAdd",
	"UVRace_NodeRemove",
	"UVRace_NodeLinks",
	"UVRace_NodeSelect",
	"UVRace_NodeSettings",
	"UVRace_UpdateNodeSettings",
	"UVRace_ClearAllNodes",

	-- Race
	"uvrace_begin",
	"uvrace_start",
	"uvrace_end",
	"uvrace_participants",
	"uvrace_notification",
	"uvrace_decline",
	"uvrace_sendmessage",
	"uvrace_resetcountdown",
	"uvrace_resetfailed",
	"uvrace_replace",
	"uvrace_disqualify",
	"uvrace_checkpointcomplete",
	"uvrace_checkpointsplit",
	"uvrace_lapcomplete",
	"uvrace_racecomplete",
	"uvrace_info",
	"uvrace_invite",
	"uvrace_racerinvited",
	"uvrace_announcebestlaptime",
	'UVResetPosition',
	"UVRace_BeginEndCountdown",
	"UVRace_StopEndCountdown",
	"UVSpottedFreeze",
	"UVSpottedUnfreeze",

	-- Headlights
	"UVToggleHeadlights",
	
	-- Glide Nodes
	"RequestGlideVehicles",
	"GlideVehiclesTable",
	
	-- DV Warning
	"UV_OpenDVWarning",
}

for _, v in pairs( NETWORK_STRINGS ) do
	util.AddNetworkString( v )
end

file.AsyncRead('unitvehicles/names/Names.json', 'DATA', function( _, _, status, data )
	UVNames = util.JSONToTable(data)
end, true)

timer.Simple(5, function()
	if not DecentVehicleDestination then
		PrintMessage( HUD_PRINTTALK, UVString("uv.system.dvnotinstalled"))
	end
	if not Glide then
		PrintMessage( HUD_PRINTTALK, UVString("uv.system.glidenotinstalled"))
	end
end)

--DEFAULT PRESETS
local datafiles, datafolders = file.Find("data_static/uvdefaultdata/*", "GAME")

for _, folder in ipairs(datafolders) do
    local path = "unitvehicles/" .. folder
    if not file.IsDir(path, "DATA") then
        file.CreateDir(path)
    end

    local datafiles2, datafolders2 = file.Find("data_static/uvdefaultdata/"..folder.."/*", "GAME")
    if datafiles2 then
        for _, filename in ipairs(datafiles2) do
            local source = "data_static/uvdefaultdata/" .. folder .. "/" .. filename
            local destination = "unitvehicles/" .. folder .. "/" .. filename
            if file.Exists(source, "GAME") then
                file.Write(destination, file.Read(source, "GAME"))
            end
        end
    end

    for _, folder2 in ipairs(datafolders2) do
        local subpath = path .. "/" .. folder2
        if not file.IsDir(subpath, "DATA") then
            file.CreateDir(subpath)
        end
        local datafiles3, datafolders3 = file.Find("data_static/uvdefaultdata/"..folder.."/"..folder2.."/*", "GAME")
        if datafiles3 then
            for _, filename in ipairs(datafiles3) do
                local source = "data_static/uvdefaultdata/" .. folder .. "/" .. folder2 .. "/" .. filename
                local destination = "unitvehicles/" .. folder .. "/" .. folder2 .. "/" .. filename
                if file.Exists(source, "GAME") then
                    file.Write(destination, file.Read(source, "GAME"))
                end
            end
        end
    end

end

concommand.Add("uv_spawnvehicles", function(ply)
	if ply and not ply:IsSuperAdmin() then return end
	
	PrintMessage( HUD_PRINTTALK, "Spawning Unit Vehicle(s)...")
	
	UVApplyHeatLevel()
	UVAutoSpawn(ply)
	
	uvIdleSpawning = CurTime()
	UVPresenceMode = true
	
	UVRestoreResourcePoints()
end)

concommand.Add( "uv_setheat", function( ply, cmd, args )
	if ply and not ply:IsSuperAdmin() then return end
	UVHeatLevel = math.Clamp( (tonumber(args[1]) or 1), 1, MAX_HEAT_LEVEL )
end)

function UV_DespawnVehicles(ply)
	UVPresenceMode = false
	
	-- PrintMessage( HUD_PRINTTALK, "Despawning Unit Vehicle(s)!")
	
	for k, v in pairs(ents.FindByClass("npc_uv*")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByClass("uvair")) do
		v:Remove()
	end
	
	UVRestoreResourcePoints()
end

concommand.Add("uv_despawnvehicles", function(ply)
	if ply and not ply:IsSuperAdmin() then return end
	UV_DespawnVehicles(ply)
end)

concommand.Add("uv_resetallsettings", function(ply)
	if ply and not ply:IsSuperAdmin() then return end
	
	ply:EmitSound("buttons/button15.wav", 0, 100, 0.5, CHAN_STATIC)
	
	HeatLevels:Revert()
	DetectionRange:Revert()
	PlayMusic:Revert()
	RacingMusic:Revert()
	NeverEvade:Revert()
	BustedTimer:Revert()
	CanWreck:Revert()
	Chatter:Revert()
	SpeedLimit:Revert()
	AutoHealth:Revert()
	MinHeatLevel:Revert()
	MaxHeatLevel:Revert()
	SpikeStripDuration:Revert()
	Pathfinding:Revert()
	VCModELSPriority:Revert()
	CallResponse:Revert()
	Headlights:Revert()
	SpawnMainUnits:Revert()
	RepairCooldown:Revert()
	RepairRange:Revert()
	RacerTags:Revert()
end)

function UV_StartPursuit(ply, skipCountdown)
	if UVTargeting or UVCounterActive then return end

	skipCountdown = skipCountdown or false

	if SpawnMainUnits:GetBool() then
		UVAutoSpawn(nil)
		
		uvIdleSpawning = CurTime()
		UVPresenceMode = true
	end
	
	-- immediate pursuit
	if skipCountdown then
		RunConsoleCommand("ai_ignoreplayers", "0")
		UVLosing = CurTime()
		UVTargeting = true
		UVCounterActive = false

		-- Random police unit announcement
		UVChatterPursuitStartAcknowledge(Entity(1))

		timer.Simple(5, function()
			if not UVTargeting then return end
			local _, v = next( UVWantedTableVehicle )
			if v then
				UVChatterDispatchCallVehicleDescription( Entity(1), v )
				UVSoundChatter(Entity(1), nil, "heat" .. UVHeatLevel, nil, "DISPATCH")
			end
		end)	
		return
	end

	-- Normal start
	net.Start("UVHUDStartPursuitNotification")
	net.WriteString("uv.hud.chase.starting")
	net.Broadcast()

	UVApplyHeatLevel()
	UVRestoreResourcePoints()
	UVCounterActive = true

	if IsValid(ply) then
		ply:EmitSound("ui/pursuit/startingpursuit/chaseresuming_start.wav", 0, 100, 0.5, CHAN_STATIC)
	end

	timer.Create("uv_pursuit_start", 1, 6, function()
		local time = timer.RepsLeft("uv_pursuit_start")

		for _, plyTarget in ipairs(player.GetAll()) do
			net.Start("UVHUDStartPursuitCountdown")
			net.WriteInt(time, 11)
			net.Send(plyTarget)
		end

		if time > 1 then
			if time <= 4 and IsValid(ply) then
				ply:EmitSound("ui/pursuit/startingpursuit/chaseresuming_" .. (time - 1) .. ".wav")
			end
		else
			if UVTargeting then return end
			if IsValid(ply) then
				ply:EmitSound("ui/pursuit/startingpursuit/chaseresuming_go.wav", 0, 100, 0.5, CHAN_STATIC)
			end

			RunConsoleCommand("ai_ignoreplayers", "0")
			UVLosing = CurTime()
			UVTargeting = true
			UVCounterActive = false

			-- Random police unit announcement
			UVChatterPursuitStartAcknowledge(Entity(1))

			timer.Simple(5, function()
				if not UVTargeting then return end
				local _, v = next( UVWantedTableVehicle )
				if v then
					UVChatterDispatchCallVehicleDescription( Entity(1), v )
					UVSoundChatter(Entity(1), nil, "heat" .. UVHeatLevel, nil, "DISPATCH")
				end
			end)	
		end
	end)
end

concommand.Add("uv_startpursuit", function(ply)
	if ply and not ply:IsSuperAdmin() then return end
	UV_StartPursuit(ply)
end)

function UV_StopPursuit(ply)
	UVCooldownTimerProgress = 1
	UVCounterActive = false
end

concommand.Add("uv_stoppursuit", function(ply)
	if ply and not ply:IsSuperAdmin() then return end
	UV_StopPursuit(ply)
end)

concommand.Add("uv_wantedtable", function(ply)
	print("Bounty: "..string.Comma(UVBounty))
	print("/// Wanted Vehicles ///")
	PrintTable(UVWantedTableVehicle)
	print("/// Wanted Drivers ///")
	PrintTable(UVWantedTableDriver)
	print("/// Potential Suspects ///")
	PrintTable(UVPotentialSuspects)
end)

concommand.Add("uv_clearbounty", function(ply)
	if ply and not ply:IsSuperAdmin() then return end
	PrintMessage( HUD_PRINTTALK, "Bounty cleared" )
	
	UVBounty = 0
end)

function UVApplyHeatLevel()
	local minHeat = MinHeatLevel:GetInt()
	local maxHeat = MaxHeatLevel:GetInt()
	
	if minHeat > maxHeat then
		UVHeatLevel = MaxHeatLevel:GetInt()
	end
end

function UVUpdateHeatLevel()
	-- local ply = Entity(1)
	-- if not ply then return end
	
	UVHeatLevel = CalculateHeatLevel(UVBounty, UVHeatLevel)
	ApplyHeatSettings(UVHeatLevel)
	HandleVehicleSpawning()
end

function CalculateHeatLevel(bounty, currentHeat)
	if UVUTimeTillNextHeatEnabled:GetInt() == 1 then
		return currentHeat or 1
	end
	
	local maxHeat = MaxHeatLevel:GetInt()
	local minHeat = MinHeatLevel:GetInt()
	local newHeat = currentHeat or 1
	
	for level = (currentHeat or 0) + 1, maxHeat do
		local condition = level > minHeat
		local convar = GetConVar("unitvehicle_unit_heatminimumbounty" .. level)
		
		if condition and convar then
			local minBounty = convar:GetInt()
			
			if bounty >= minBounty then
				newHeat = level
				TriggerHeatLevelEffects(level)
			else 
				break 
			end
		end
	end
	
	if newHeat < minHeat then
		newHeat = minHeat
		TriggerHeatLevelEffects(newHeat)
	end
	
	return newHeat
end

function UV_ClearRacer(ply)
	for _, v in pairs(ents.FindByClass("npc_racervehicle")) do
		if IsValid(v.v) then
			v.v:Remove()
		end
		v:Remove()
	end
end

concommand.Add("uv_clearracers", function(ply)
	if ply and not ply:IsSuperAdmin() then return end
	UV_ClearRacer(ply)
end)

function TriggerHeatLevelEffects(level)
	if level < 2 then return end
	
	if level == MaxHeatLevel then
	    PrintMessage(HUD_PRINTCENTER, "HEAT LEVEL " .. level .. "!")
	end
	
	if next(ents.FindByClass("npc_uv*")) ~= nil and Chatter:GetBool() and UVTargeting then
		local units = ents.FindByClass("npc_uv*")
		local random_entry = math.random(#units)
		local unit = units[random_entry]
		UVChatterReportHeat(unit, level)
	end
	
	if UVTargeting then
		UVRelaySoundToClients("ui/pursuit/heatlevelrise.wav", false)
	end
	
	net.Start("UVHUDHeatLevelIncrease")
	net.Broadcast()
end

function NumberToWords(num)
	local words = {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"}
	return words[num] or tostring(num)
end

function ApplyHeatSettings(heatLevel)
	heatLevel = math.Clamp(heatLevel or 1, 1, MaxHeatLevel:GetInt())
	
	UVMaxUnits = GetConVar("unitvehicle_unit_maxunits"..heatLevel):GetInt()
	UVBountyMultiplier = heatLevel
	UVBountyTime = GetConVar("unitvehicle_unit_bountytime"..heatLevel):GetInt()
	UVCooldownTimer = GetConVar("unitvehicle_unit_cooldowntimer"..heatLevel):GetInt()
	UVBackupTimerMax = GetConVar("unitvehicle_unit_backuptimer"..heatLevel):GetInt()
	
	UVBustSpeed = (GetConVar("unitvehicle_unit_bustspeed"..heatLevel):GetInt()*17.6)^2 --MPH to in/s^2
	
	uvRoadblockDeployable = GetConVar("unitvehicle_unit_roadblocks"..heatLevel):GetInt() == 1
	uvHelicopterDeployable = GetConVar("unitvehicle_unit_helicopters"..heatLevel):GetInt() == 1
end

local function CheckVehicleLimit()
	local activeUnits = ents.FindByClass("npc_uv*")
	local activeUnitsCount = 0
	local wreckedUnitsCount = #UVWreckedVehicles

	for _, unit in pairs(activeUnits) do
		if unit.v.roadblocking then continue end
		activeUnitsCount = activeUnitsCount + 1
	end

	if #UVWreckedVehicles > 0 then
		for k, car in pairs(UVWreckedVehicles) do
			if #UVWantedTableVehicle > 0 then
				local closestsuspect
				local closestdistancetosuspect
				local suspects = UVWantedTableVehicle
				local r = math.huge
				local closestdistancetosuspect, closestsuspect = r^2
				for i, w in pairs(suspects) do
					local carpos = car:WorldSpaceCenter()
					local distance = carpos:DistToSqr(w:WorldSpaceCenter())
					if distance < closestdistancetosuspect then
						closestdistancetosuspect, closestsuspect = distance, w
					end
				end
				if closestdistancetosuspect > 25000000 then
					car:Remove()
					wreckedUnitsCount = wreckedUnitsCount - 1
				end
			end
		end
	end

	local totalUnits = activeUnitsCount + wreckedUnitsCount
	return totalUnits < UVMaxUnits and totalUnits < UVResourcePoints or activeUnitsCount < 1
end

-- Helper function for vehicle spawning logic
function HandleVehicleSpawning(Patrolling)
	
	if UVJammerDeployed then return end
	if not CheckVehicleLimit() then return end

	-- Handle other special spawns

	if not SpawnMainUnits:GetBool() then return end

	local canSpawnRoadblock = next(ents.FindByClass("npc_uv*")) ~= nil and uvRoadblockDeployable and #UVLoadedRoadblocks < UVRBMax:GetInt() 
	local canSpawnHelicopter = #ents.FindByClass("uvair") < 1 and uvHelicopterDeployable and CurTime() - UVHeliCooldown > 120

	local pool = {
		'normal',
	}

	if canSpawnRoadblock then
		table.insert(pool, 'roadblock')
	end
	if canSpawnHelicopter then
		table.insert(pool, 'helicopter')
	end
	if UVCommanderRespawning then
		table.insert(pool, 'commander')
	end

	local random = pool[math.random(#pool)]

	local funcs = {
		['helicopter'] = function()
			UVAutoSpawn(nil, nil, true)
		end,
		['roadblock'] = function()
			local units = ents.FindByClass("npc_uv*")
			local unit = units[math.random(#units)]
			if not UVDeployRoadblock(unit) then UVAutoSpawn(nil) end
		end,
		['commander'] = function()
			UVAutoSpawn(nil, nil, nil, nil, UVCommanderRespawning)
		end,
		['normal'] = function()
			UVAutoSpawn(nil)
		end,
	}

	funcs[random]()
	-- local specialChance = Patrolling and math.random(6,10) or math.random(1,10)
	
	-- if UVCommanderRespawning then
		
	-- 	if not SpawnMainUnits:GetBool() then return end
	-- 	UVAutoSpawn(nil, nil, nil, nil, UVCommanderRespawning) --COMMANDER RESPAWN
		
	-- elseif specialChance >= 1 and specialChance <= 2 and not UVEnemyEscaping then
		
	-- 	if not SpawnMainUnits:GetBool() then return end
	-- 	UVAutoSpawn(nil, true) --RHINO
		
	-- elseif specialChance >= 3 and specialChance <= 5 and next(ents.FindByClass("npc_uv*")) ~= nil and uvRoadblockDeployable then
		
	-- 	local units = ents.FindByClass("npc_uv*")
	-- 	local unit = units[math.random(#units)]
	-- 	UVDeployRoadblock(unit) --ROADBLOCK
		
	-- elseif specialChance == 6 and #ents.FindByClass("uvair") < 1 and uvHelicopterDeployable and CurTime() - UVHeliCooldown > 120 then
		
	-- 	if not SpawnMainUnits:GetBool() then return end
	-- 	UVAutoSpawn(nil, nil, true) --HELICOPTER
		
	-- elseif SpawnMainUnits:GetBool() and UVResourcePoints > (#ents.FindByClass("npc_uv*")) then
		
	-- 	UVAutoSpawn(nil) --NORMAL
		
	-- end
end

function UVResetStats()
	if next(UVWantedTableVehicle) == nil and next(UVWantedTableDriver) == nil then
		UVBounty = 0
		UVHeatLevel = 1
		
		if timer.Exists("UVTimeTillNextHeat") then
			timer.Remove("UVTimeTillNextHeat")
		end
	end
	UVDeploys = 0
	UVWrecks = 0
	UVTags = 0
	UVRoadblocksDodged = 0
	UVSpikestripsDodged = 0
	if UVBounty == 0 then
		UVHeatLevel = MinHeatLevel:GetInt()
	end
	if UVEnemyEscaping then
		UVEnemyEscaping = nil
	end
	if UVTimer then
		UVTimer = nil
	end
end

function UVRestoreResourcePoints()
	UVResourcePointsRefreshing = true

	if not UVOneCommanderActive then
		UVOneCommanderDeployed = nil
	else
		UVOneCommanderDeployed = true
	end

	timer.Simple(1, function()
		if UVResourcePointsRefreshing then
			UVResourcePointsRefreshing = false
		end
	end)
	-- if UVHeatLevel == 1 then --Heat Level 1
	-- 	UVResourcePoints = UVUUnitsAvailable1:GetInt()
	-- elseif UVHeatLevel == 2 then --Heat Level 2
	-- 	UVResourcePoints = UVUUnitsAvailable2:GetInt()
	-- elseif UVHeatLevel == 3 then --Heat Level 3
	-- 	UVResourcePoints = UVUUnitsAvailable3:GetInt()
	-- elseif UVHeatLevel == 4 then --Heat Level 4
	-- 	UVResourcePoints = UVUUnitsAvailable4:GetInt()
	-- elseif UVHeatLevel == 5 then --Heat Level 5
	-- 	UVResourcePoints = UVUUnitsAvailable5:GetInt()
	-- else --Heat Level 6
	-- 	UVResourcePoints = UVUUnitsAvailable6:GetInt()
	-- end
	
	local unitsAvailableConVar = GetConVar( "unitvehicle_unit_unitsavailable" .. UVHeatLevel )
	
	UVResourcePoints = (unitsAvailableConVar and unitsAvailableConVar:GetInt()) or 5
	UVBackupUnderway = nil
end

function UVRequestVectorsnavmesh( start, goal, carwidth )
	local startArea = navmesh.GetNearestNavArea( start )
	local goalArea = navmesh.GetNearestNavArea( goal )
	
	if UVEnemyEscaping then
		local navmeshtable = navmesh.GetAllNavAreas()
		if next(navmeshtable) ~= nil then
			goalArea = navmeshtable[math.random(#navmeshtable)] --Go to a random spot when searching
		end
	end
	
	if not carwidth then
		carwidth = 0
	end
	
	return UVEstablishVectorsnavmesh( startArea, goalArea, carwidth )
end

function UVEstablishVectorsnavmesh( start, goal, carwidth )
	if ( not IsValid( start ) or not IsValid( goal ) ) then return nil end
	if ( start == goal ) then return true end
	
	local directDistance = start:GetCenter():Distance( goal:GetCenter() )
	if directDistance > 1000000 then
		return false
	end
	
	start:ClearSearchLists()
	start:AddToOpenList()
	
	local cameFrom = {}
	local heuristicCache = {}
	
	start:SetCostSoFar( 0 )

	local initialHeuristic = UVheuristic_cost_estimate(start, goal)
	heuristicCache[start:GetID() .. "_" .. goal:GetID()] = initialHeuristic
	
	start:SetTotalCost( initialHeuristic )
	start:UpdateOnOpenList()

	local i = 0
	local maxIterations = math.min(5000, math.max(100, directDistance / 10))
	local startTime = SysTime()
	local maxTime = 0.016
	
	while ( not start:IsOpenListEmpty() and i < maxIterations ) do
		if SysTime() - startTime > maxTime then
			return false
		end
		
		i = i + 1
		local current = start:PopOpenList()
		
		if ( current == goal ) then
			return UVreconstruct_path( cameFrom, current )
		end
		
		current:AddToClosedList()
		
		if current:GetCostSoFar() > directDistance * 3 then
			return false
		end
		
		for k, neighbor in pairs( current:GetAdjacentAreas() ) do
			--print(current:ComputeAdjacentConnectionHeightChange(neighbor), neighbor:IsUnderwater())
			if ( neighbor:IsUnderwater() or 
			current:ComputeAdjacentConnectionHeightChange(neighbor) > 1 ) then
				continue
			end

			-- if carwidth and carwidth > 0 then
			-- 	local areaWidth = neighbor:GetSizeX()
			-- 	if areaWidth < carwidth then
			-- 		continue
			-- 	end
			-- end
			
			local cacheKey = neighbor:GetID() .. "_" .. goal:GetID()
			local neighborHeuristic = heuristicCache[cacheKey]
			if not neighborHeuristic then
				neighborHeuristic = UVheuristic_cost_estimate( neighbor, goal )
				heuristicCache[cacheKey] = neighborHeuristic
			end
			
			local newCostSoFar = current:GetCostSoFar() + UVheuristic_cost_estimate( current, neighbor )
			
			if ( ( neighbor:IsOpen() or neighbor:IsClosed() ) ) then
				continue
			end
			
			neighbor:SetCostSoFar( newCostSoFar )
			neighbor:SetTotalCost( newCostSoFar + neighborHeuristic )
			
			if ( neighbor:IsClosed() ) then
				neighbor:RemoveFromClosedList()
			end
			
			if ( neighbor:IsOpen() ) then
				neighbor:UpdateOnOpenList()
			else
				neighbor:AddToOpenList()
			end
			
			cameFrom[neighbor:GetID()] = current:GetID()
		end
	end

	return false
end

function UVheuristic_cost_estimate( start, goal )
	return start:GetCenter():Distance( goal:GetCenter() )
end

function UVreconstruct_path( cameFrom, current )
	local total_path = { current }
	
	current = current:GetID()
	local maxPathLength = 1000
	local pathLength = 0
	
	while ( cameFrom[ current ] and pathLength < maxPathLength ) do
		pathLength = pathLength + 1
		current = cameFrom[ current ]
		table.insert( total_path, navmesh.GetNavAreaByID( current ) )
	end
	
	-- If we hit the max length, something went wrong
	if pathLength >= maxPathLength then
		return false
	end

	--print(#total_path)
	
	return total_path
end

function UVdrawThePath( path, time )
	local prevArea
	
	for _, area in pairs( path ) do
		debugoverlay.Sphere( area:GetCenter(), 8, time or 9, color_white, true  )
		if ( prevArea ) then
			debugoverlay.Line( area:GetCenter(), prevArea:GetCenter(), time or 9, color_white, true )
		end
		
		area:Draw()
		prevArea = area
	end
end

function UVPassConVarFilter(v)
	
	if v.uvbusted then
		return false
	end
	
	if v:GetClass() == "prop_vehicle_prisoner_pod" then 
		return false 
	end

	if v.IsSimfphyscar then
		if not v:IsInitialized() then return false end
	end
	
	local innocent = IsValid(v.DecentVehicle) or IsValid(v.TrafficVehicle) or IsValid(v.UnitVehicle)
	
	if (v:GetClass() == "prop_vehicle_jeep" or v.IsSimfphyscar or v.IsGlideVehicle) then
		return (IsValid(v.MadVehicle) or (UVGetDriver(v) and UVGetDriver(v):IsPlayer()) or IsValid(v.RacerVehicle)) and not innocent or IsValid(v.UVWanted)
	end
	
	return false
end

function UVStraightToWaypoint(origin, waypoint)
	if not origin or not waypoint then
		return
	end
	
	--local originpos = util.TraceLine({start = origin, endpos = (origin+Vector(0,0,-1000)), mask = MASK_NPCWORLDSTATIC}).HitPos
	--local waypointpos = util.TraceLine({start = waypoint, endpos = (waypoint+Vector(0,0,-1000)), mask = MASK_NPCWORLDSTATIC}).HitPos
	
	local tr = util.TraceLine({start = origin, endpos = waypoint, mask = MASK_NPCWORLDSTATIC}).Fraction==1
	return tobool(tr)
end

hook.Add("OnEntityCreated", "UVCollisionGlide", function(glidevehicle) --Override Glide collisions for the time being 
	if not Glide then return end
	
	local RealTime = RealTime
	local DamageInfo = DamageInfo
	local GetWorld = game.GetWorld
	
	local Clamp = math.Clamp
	local RandomInt = math.random
	local PlaySoundSet = Glide.PlaySoundSet
	
	local cvarCollision = GetConVar( "glide_physics_damage_multiplier" )
	local cvarWorldCollision = GetConVar( "glide_world_physics_damage_multiplier" )
	
	local cvarCollision = GetConVar( "glide_physics_damage_multiplier" )
	if ( glidevehicle.IsGlideVehicle ) then
		local oldphysCollide = glidevehicle.PhysicsCollide
		glidevehicle.PhysicsCollide = function( car, coldata, ent )
			oldphysCollide(car, coldata, ent)
			-- if isfunction(car.UVPhysicsCollide) then
			-- 	car:UVPhysicsCollide(coldata)
			-- end

			if coldata.HitEntity.PursuitBreakerActive then
				local driver = car.UnitVehicle or car.TrafficVehicle
                    
				if driver then
					if driver:IsNPC() then
						driver:Wreck()
					else
						UVPlayerWreck(car)
					end
					return
				end	
			end

			if car.DecentVehicle or car.TrafficVehicle then
				UVRamVehicle(car)
			end

			local object = coldata.HitEntity

			if car.grappleron and object.UVWanted then --Grappler
				UVGrapple(car, object)
			end

			if car.juggernauton and not object:IsWorld() then --Juggernaut
				local ourOldVel = coldata.OurOldVelocity
				local ourOldAngVel = coldata.OurOldAngularVelocity
				local objectPhys = object:GetPhysicsObject()
				local Phys = car:GetPhysicsObject()
				local force = car:GetVelocity():LengthSqr()

				local carPos = car:WorldSpaceCenter()
				local vectorDifference = object:WorldSpaceCenter() - carPos
				local angle = vectorDifference:Angle()

				objectPhys:ApplyForceCenter(angle:Forward()*force)

				--Preserve momentum
        		Phys:SetVelocity(ourOldVel)
				Phys:SetAngleVelocityInstantaneous(ourOldAngVel)

				local sounds = {
					"gadgets/juggernaut/impact_hard1.wav",
					"gadgets/juggernaut/impact_hard2.wav",
					"gadgets/juggernaut/impact_hard3.wav",
					"gadgets/juggernaut/impact_medium1.wav",
					"gadgets/juggernaut/impact_medium2.wav",
					"gadgets/juggernaut/impact_medium3.wav",
					"gadgets/juggernaut/impact_soft1.wav",
					"gadgets/juggernaut/impact_soft2.wav",
					"gadgets/juggernaut/impact_soft3.wav",
				}
				
				if not car.juggernauthit then
					car.juggernauthit = true
					car:EmitSound(sounds[math.random(1, #sounds)])
					timer.Simple(1, function()
						if IsValid(car) then
							car.juggernauthit = nil
						end
					end)
				end
			end

			if car.esfon and object:IsVehicle() and not (object.UnitVehicle and car.UnitVehicle) then --ESF

				if not object.UnitVehicle and not car.UnitVehicle then
					if not RacerFriendlyFire:GetBool() then return end
				end

				local enemyVehicle = object
				local enemyCallsign

				if object.UnitVehicle then
					enemyCallsign = object.UnitVehicle.callsign or "Unit "..object:EntIndex()
				else
					enemyCallsign = object.racer or "Racer "..enemyVehicle:EntIndex()
				end

				local enemyDriver = UVGetDriver(enemyVehicle)
				local power
				local damage
				if car.UnitVehicle then
					power = UVUnitPTESFPower:GetInt()
					damage = UVUnitPTESFDamage:GetFloat()
					if UVIsPTUpgraded(car) then
						power = power * 2
						damage = damage * 2
					end
				else
					power = UVPTESFPower:GetInt()
					damage = UVPTESFDamage:GetFloat()
				end

				local carPos = car:WorldSpaceCenter()
				local enemyVehiclePhys = enemyVehicle:GetPhysicsObject()
				local vectorDifference = enemyVehicle:WorldSpaceCenter() - carPos
				local angle = vectorDifference:Angle()
				local force = power * (1 - (vectorDifference:Length()/1000))

				enemyVehiclePhys:ApplyForceCenter(angle:Forward()*force)
				UVRamVehicle(enemyVehicle)

				if enemyDriver then
					if enemyDriver:IsPlayer() then
						enemyCallsign = enemyDriver:GetName()
					end
				end

				if object.UnitVehicle or (object.UVWanted and not AutoHealth:GetBool()) or not (object.UnitVehicle and object.UVWanted) then
					damage = (table.HasValue(UVCommanders, object) and UVPTESFCommanderDamage:GetFloat()) or damage
					UVDamage(object, damage)
				end

				-- if IsValid(UVGetDriver(enemyVehicle))

				-- local attacker = UVGetDriver(car)
				-- local attackerName = UVGetDriverName(car)

				-- local victim = UVGetDriver(car)
				-- local victimName = UVGetDriverName(enemyVehicle)

				-- local args = {
				-- 	['User'] = attackerName,
				-- 	['Hit'] = victimName
				-- }

				-- local playersToSend = {}

				-- if attacker then
				-- 	table.insert( playersToSend, attacker )
				-- end

				-- if victim then
				-- 	table.insert( playersToSend, victim )
				-- end

				-- UVPTEvent( playersToSend, "ESF", "Hit", args )

				ReportPTEvent( car, enemyVehicle, 'ESF', 'Hit' )

				-- if isfunction(enemyVehicle.GetDriver) and IsValid(UVGetDriver(enemyVehicle)) and UVGetDriver(enemyVehicle):IsPlayer() then 
				-- 	UVGetDriver(enemyVehicle):PrintMessage( HUD_PRINTCENTER, "YOU HAVE BEEN HIT BY AN ESF!")
				-- end

				-- if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
				-- 	UVGetDriver(car):PrintMessage( HUD_PRINTCENTER, "ESF HIT ON "..enemyCallsign.."!")
				-- end


				local e = EffectData()
				e:SetEntity(enemyVehicle)
				util.Effect("entity_remove", e)
				enemyVehicle:EmitSound("gadgets/esf/impact.wav")
				car.uvesfhit = true
				UVDeactivateESF(car)
				if car.UnitVehicle then
					UVChatterESFHit(car.UnitVehicle)
				end

			end
			if car.UVWanted then --SUSPECT
				if object:IsWorld() or object.DecentVehicle or object.TrafficVehicle then --Crashed into world
					local ourOldVel = coldata.OurOldVelocity:Length()
					local ourNewVel = coldata.OurNewVelocity:Length()
					local resultVel = ourOldVel
					if ourOldVel > ourNewVel then --slowed
						resultVel = ourOldVel - ourNewVel
					else --sped up
						resultVel = ourNewVel - ourOldVel
					end
					local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
					dot = math.abs(dot) / 2
					local dmg = resultVel * dot
					if dmg >= 100 and not UVEnemyEscaping and UVTargeting then
						if object:IsWorld() then
							if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
								local units = ents.FindByClass("npc_uv*")
								local random_entry = math.random(#units)	
								local unit = units[random_entry]
								if IsValid(unit.e) and car == unit.e then
									UVChatterEnemyCrashed(unit) 
								end
							end
						elseif object.DecentVehicle or object.TrafficVehicle then
							if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
								local units = ents.FindByClass("npc_uv*")
								local random_entry = math.random(#units)	
								local unit = units[random_entry]
								if IsValid(unit.e) and car == unit.e then
									if object.Sockets and next(object.Sockets) ~= nil then
										UVChatterHitTrafficSemi(unit)
									else
										UVChatterHitTraffic(unit)
									end
								end
							end
						end
					end
				end
				if object.UVRoadblock and not object.UVRoadblock.RoadBlockHit then --Crashed into roadblock
					object.UVRoadblock.RoadBlockHit = true
					if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)	
						local unit = units[random_entry]
						if IsValid(unit.e) and car == unit.e then
							UVChatterRoadblockHit(unit) 
						end
					end
				end
			elseif car.UnitVehicle then --UNIT NPC
				local driver = UVGetDriver(car)
				local NPC = ((IsValid(driver) and driver) or car.UnitVehicle)--car.UnitVehicle
				if NPC and (NPC:IsNPC() or NPC:IsPlayer()) then
					if (not UVTargeting and UVPassConVarFilter(object) or UVTargeting and object.UVWanted) then
						UVRamVehicle(car)
					end
					if object.UVWanted and not car.tagged then
						car.tagged = true
						UVTags = UVTags + 1
						if car.rhino and not car.rhinohit then
							car.rhinohit = true
							if Chatter:GetBool() and UVTargeting and not NPC:IsPlayer() and not car.roadblocking and not car.disperse then
								UVSoundChatter(NPC, NPC.voice, "rhinohit", 1)
							end
						end
					end
					local ourOldVel = coldata.OurOldVelocity:Length()
					local ourNewVel = coldata.OurNewVelocity:Length()
					local resultVel = ourOldVel
					if ourOldVel > ourNewVel then --slowed
						resultVel = ourOldVel - ourNewVel
					else --sped up
						resultVel = ourNewVel - ourOldVel
					end
					local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
					dot = math.abs(dot) / 2
					local dmg = resultVel * dot
					if dmg >= 100 and object.UVWanted then
						if Chatter:GetBool() then
							if coldata.TheirOldVelocity:Length() > ourOldVel then
								if not NPC:IsPlayer() then
									UVChatterRammed(NPC)
								end
								UVDeactivateKillSwitch(car)
							else
								if not NPC:IsPlayer() then
									UVChatterRammedEnemy(NPC)
								end
							end
						end
						if not NPC.ramming and not NPC:IsPlayer() then
							NPC.ramming = true
							NPC:SetHorn(true)
						end
						timer.Simple(math.random(1,5), function()
							if NPC and not NPC:IsPlayer() then
								if NPC.ramming then
									NPC.ramming = nil
									NPC:SetHorn(false)
									NPC:ChangeELSSiren()
								end
							end
						end)
					end
				end
				if (NPC and NPC:IsPlayer()) and not UVTargeting and not UVEnemyEscaped and not UVEnemyBusted and table.HasValue(UVPotentialSuspects, object) then
					UVTargeting = true
				end
			elseif car.TrafficVehicle then --TRAFFIC
				local ourOldVel = coldata.OurOldVelocity:Length()
				local ourNewVel = coldata.OurNewVelocity:Length()
				local resultVel = ourOldVel
				if ourOldVel > ourNewVel then --slowed
					resultVel = ourOldVel - ourNewVel
				else --sped up
					resultVel = ourNewVel - ourOldVel
				end
				local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
				dot = math.abs(dot) / 2
				local dmg = resultVel * dot
				if dmg >= 100 then
					if IsValid(car.TrafficVehicle) then
						car.TrafficVehicle.emergencystop = true
					end
				end
			end
			if not object.UnitVehicle then --CALL HANDLER
				if not object:IsWorld() then
					local ctimeout = 1
					if object:IsVehicle() then --Hit And Run
						if CurTime() > UVPreInfractionCountCooldown + ctimeout then
							UVPreInfractionCount = UVPreInfractionCount + 2
							UVPreInfractionCountCooldown = CurTime()
							if UVPreInfractionCount >= 10 then
								if UVPassConVarFilter(car) and isfunction(UVCallInitiate) then
									UVCallInitiate(car, 3)
								end
							end
						end
					else --Damage to Property
						if CurTime() > UVPreInfractionCountCooldown + ctimeout then
							UVPreInfractionCount = object.PursuitBreaker and UVPreInfractionCount + 10 or UVPreInfractionCount + 1
							UVPreInfractionCountCooldown = CurTime()
							if UVPreInfractionCount >= 10 then
								if UVPassConVarFilter(car) and isfunction(UVCallInitiate) then
									UVCallInitiate(car, 2)
								end
							end
						end
					end
				end
			end
		end
	end
	
end)

hook.Add("simfphysPhysicsCollide", "UVCollisionSimfphys", function(car, coldata, ent)
	if not IsValid(car) or car:GetClass() ~= "gmod_sent_vehicle_fphysics_base" then return end

	if car.DecentVehicle or car.TrafficVehicle then
		UVRamVehicle(car)
	end

	local object = coldata.HitEntity

	if object.PursuitBreakerActive then
		local driver = car.UnitVehicle or car.TrafficVehicle
			
		if driver then
			if driver:IsNPC() then
				driver:Wreck()
			else
				UVPlayerWreck(car)
			end
			return
		end	
	end

	if car.grappleron and object.UVWanted then --Grappler
		UVGrapple(car, object)
	end

	if car.juggernauton and not object:IsWorld() then --Juggernaut
		local ourOldVel = coldata.OurOldVelocity
		local ourOldAngVel = coldata.OurOldAngularVelocity
		local objectPhys = object:GetPhysicsObject()
		local Phys = car:GetPhysicsObject()
		local force = car:GetVelocity():LengthSqr()

		local carPos = car:WorldSpaceCenter()
		local vectorDifference = object:WorldSpaceCenter() - carPos
		local angle = vectorDifference:Angle()

		objectPhys:ApplyForceCenter(angle:Forward()*force)

		--Preserve momentum
    	Phys:SetVelocity(ourOldVel)
		Phys:SetAngleVelocityInstantaneous(ourOldAngVel)

		local sounds = {
			"gadgets/juggernaut/impact_hard1.wav",
			"gadgets/juggernaut/impact_hard2.wav",
			"gadgets/juggernaut/impact_hard3.wav",
			"gadgets/juggernaut/impact_medium1.wav",
			"gadgets/juggernaut/impact_medium2.wav",
			"gadgets/juggernaut/impact_medium3.wav",
			"gadgets/juggernaut/impact_soft1.wav",
			"gadgets/juggernaut/impact_soft2.wav",
			"gadgets/juggernaut/impact_soft3.wav",
		}
		
		if not car.juggernauthit then
			car.juggernauthit = true
			car:EmitSound(sounds[math.random(1, #sounds)])
			timer.Simple(1, function()
				if IsValid(car) then
					car.juggernauthit = nil
				end
			end)
		end
	end

	if car.esfon and object:IsVehicle() and not (object.UnitVehicle and car.UnitVehicle) then --ESF
		if not object.UnitVehicle and not car.UnitVehicle then
			if not RacerFriendlyFire:GetBool() then return end
		end
		local enemyVehicle = object
		local enemyCallsign
		if object.UnitVehicle then
			enemyCallsign = object.UnitVehicle.callsign or "Unit "..object:EntIndex()
		else
			enemyCallsign = enemyVehicle.racer or "Racer "..enemyVehicle:EntIndex()
		end
		local enemyDriver = UVGetDriver(enemyVehicle)
		local power
		local damage

		if car.UnitVehicle then
			power = UVUnitPTESFPower:GetInt()
			damage = UVUnitPTESFDamage:GetFloat()
			if UVIsPTUpgraded(car) then
				power = power * 2
				damage = damage * 2
			end
		else
			power = UVPTESFPower:GetInt()
			damage = UVPTESFDamage:GetFloat()
		end

		local carPos = car:WorldSpaceCenter()
		local enemyVehiclePhys = enemyVehicle:GetPhysicsObject()
		local vectorDifference = enemyVehicle:WorldSpaceCenter() - carPos
		local angle = vectorDifference:Angle()
		local force = power * (1 - (vectorDifference:Length()/1000))

		enemyVehiclePhys:ApplyForceCenter(angle:Forward()*force)
		UVRamVehicle(enemyVehicle)

		if enemyDriver then
			if enemyDriver:IsPlayer() then
				enemyCallsign = enemyDriver:GetName()
			end
		end

		if object.UnitVehicle or (object.UVWanted and not AutoHealth:GetBool()) or not (object.UnitVehicle and object.UVWanted) then
			damage = (table.HasValue(UVCommanders, object) and UVPTESFCommanderDamage:GetFloat()) or damage
			UVDamage(object, damage)
		end

		-- if isfunction(enemyVehicle.GetDriver) and IsValid(UVGetDriver(enemyVehicle)) and UVGetDriver(enemyVehicle):IsPlayer() then 
		-- 	UVGetDriver(enemyVehicle):PrintMessage( HUD_PRINTCENTER, "YOU HAVE BEEN HIT BY AN ESF!")
		-- end

		-- if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
		-- 	UVGetDriver(car):PrintMessage( HUD_PRINTCENTER, "ESF HIT ON "..enemyCallsign.."!")
		-- end

		-- local attacker = UVGetDriver(car)
		-- local attackerName = UVGetDriverName(car)

		-- local victim = UVGetDriver(car)
		-- local victimName = UVGetDriverName(enemyVehicle)

		-- local args = {
		-- 	['User'] = attackerName,
		-- 	['Hit'] = victimName
		-- }

		-- local playersToSend = {}

		-- if attacker then
		-- 	table.insert( playersToSend, attacker )
		-- end

		-- if victim then
		-- 	table.insert( playersToSend, victim )
		-- end

		-- UVPTEvent( playersToSend, "ESF", "Hit", args )
		ReportPTEvent( car, enemyVehicle, 'ESF', 'Hit' )

		local e = EffectData()
		e:SetEntity(enemyVehicle)
		util.Effect("entity_remove", e)
		enemyVehicle:EmitSound("gadgets/esf/impact.wav")
		car.uvesfhit = true
		UVDeactivateESF(car)

		if car.UnitVehicle then
			UVChatterESFHit(car.UnitVehicle)
		end
	end
	if car.UVWanted then --SUSPECT
		if object:IsWorld() or object.DecentVehicle or object.TrafficVehicle then --Crashed into world
			local ourOldVel = coldata.OurOldVelocity:Length()
			local ourNewVel = coldata.OurNewVelocity:Length()
			local resultVel = ourOldVel

			if ourOldVel > ourNewVel then --slowed
				resultVel = ourOldVel - ourNewVel
			else --sped up
				resultVel = ourNewVel - ourOldVel
			end

			local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
			dot = math.abs(dot) / 2
			local dmg = resultVel * dot

			if dmg >= 100 and not UVEnemyEscaping and UVTargeting then
				if object:IsWorld() then
					if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)	
						local unit = units[random_entry]
						if not IsValid(unit.e) then return end
						UVChatterEnemyCrashed(unit)
					end
				elseif object.DecentVehicle or object.TrafficVehicle then
					if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)	
						local unit = units[random_entry]
						if not IsValid(unit.e) then return end
						UVChatterHitTraffic(unit)
					end
				end
			end
		end

		if object.UVRoadblock and not object.UVRoadblock.RoadBlockHit then --Crashed into roadblock
			object.UVRoadblock.RoadBlockHit = true
			if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				if IsValid(unit.e) and car == unit.e then
					UVChatterRoadblockHit(unit) 
				end
			end
		end

	elseif car.UnitVehicle then --UNIT NPC
		local driver = UVGetDriver(car)
		local NPC = ((IsValid(driver) and driver) or car.UnitVehicle)--car.UnitVehicle

		if NPC and (NPC:IsNPC() or NPC:IsPlayer()) then
			if (not UVTargeting and UVPassConVarFilter(object) or UVTargeting and object.UVWanted) then
				UVRamVehicle(car)
			end
			if object.UVWanted and not car.tagged then
				car.tagged = true
				UVTags = UVTags + 1
				if car.rhino and not car.rhinohit then
					car.rhinohit = true
					if Chatter:GetBool() and UVTargeting and not NPC:IsPlayer() and not car.roadblocking and not car.disperse then
						UVSoundChatter(NPC, NPC.voice, "rhinohit", 1)
					end
				end
			end
			local ourOldVel = coldata.OurOldVelocity:Length()
			local ourNewVel = coldata.OurNewVelocity:Length()
			local resultVel = ourOldVel
			if ourOldVel > ourNewVel then --slowed
				resultVel = ourOldVel - ourNewVel
			else --sped up
				resultVel = ourNewVel - ourOldVel
			end
			if coldata.HitEntity:IsNPC() or coldata.HitEntity:IsPlayer() then return end
			local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
			dot = math.abs(dot) / 2
			local dmg = resultVel * dot
			if dmg >= 100 and object.UVWanted then
				if Chatter:GetBool() then
					if coldata.TheirOldVelocity:Length() > ourOldVel then
						if not NPC:IsPlayer() then
							UVChatterRammed(NPC)
						end
						UVDeactivateKillSwitch(car)
					else
						if not NPC:IsPlayer() then
							UVChatterRammedEnemy(NPC)
						end
					end
				end
				if not NPC.ramming and not NPC:IsPlayer() then
					NPC.ramming = true
					NPC:SetHorn(true)
				end
				timer.Simple(math.random(1,5), function()
					if not NPC then return end
					if NPC.ramming and not NPC:IsPlayer() then
						NPC.ramming = nil
						NPC:SetHorn(false)
						NPC:ChangeELSSiren()
					end
				end)
			end
		end
		if (NPC and NPC:IsPlayer()) and not UVTargeting and not UVEnemyEscaped and not UVEnemyBusted and table.HasValue(UVPotentialSuspects, object) then
			UVTargeting = true
		end
	elseif car.TrafficVehicle then --TRAFFIC
		local ourOldVel = coldata.OurOldVelocity:Length()
		local ourNewVel = coldata.OurNewVelocity:Length()
		local resultVel = ourOldVel
		if ourOldVel > ourNewVel then --slowed
			resultVel = ourOldVel - ourNewVel
		else --sped up
			resultVel = ourNewVel - ourOldVel
		end
		local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
		dot = math.abs(dot) / 2
		local dmg = resultVel * dot
		if dmg >= 100 then
			if IsValid(car.TrafficVehicle) then
				car.TrafficVehicle.emergencystop = true
			end
		end
	end

	if not object.UnitVehicle then --CALL HANDLER
		if not object:IsWorld() then
			local ctimeout = 1
			if object:IsVehicle() then --Hit And Run
				if CurTime() > UVPreInfractionCountCooldown + ctimeout then
					UVPreInfractionCount = UVPreInfractionCount + 2
					UVPreInfractionCountCooldown = CurTime()
					if UVPreInfractionCount >= 10 then
						if UVPassConVarFilter(car) and isfunction(UVCallInitiate) then
							UVCallInitiate(car, 3)
						end
					end
				end
			else --Damage to Property
				if CurTime() > UVPreInfractionCountCooldown + ctimeout then
					UVPreInfractionCount = object.PursuitBreaker and UVPreInfractionCount + 10 or UVPreInfractionCount + 1
					UVPreInfractionCountCooldown = CurTime()
					if UVPreInfractionCount >= 10 then
						if UVPassConVarFilter(car) and isfunction(UVCallInitiate) then
							UVCallInitiate(car, 2)
						end
					end
				end
			end
		end
	end
end)

hook.Add( "simfphysOnDestroyed", "UVExplosionSimfphys", function(car, gib) 
	if not car.UnitVehicle or car.wrecked then return end
	if car.UnitVehicle:IsNPC() then
		car.UnitVehicle:Wreck()
	else
		UVPlayerWreck(car)
	end
end)

hook.Add("OnEntityCreated", "UVCollisionJeep", function(vehicle)
	if not vehicle:GetClass() == "prop_vehicle_jeep" then return end
	vehicle:AddCallback("PhysicsCollide", function(car, coldata)
		if not IsValid(car) or car:GetClass() ~= "prop_vehicle_jeep" then return end

		if car.DecentVehicle or car.TrafficVehicle then
			UVRamVehicle(car)
		end

		local object = coldata.HitEntity
		local ourOldVel = coldata.OurOldVelocity:Length()
		local ourNewVel = coldata.OurNewVelocity:Length()
		local resultVel = ourOldVel
		if ourOldVel > ourNewVel then --slowed
			resultVel = ourOldVel - ourNewVel
		else --sped up
			resultVel = ourNewVel - ourOldVel
		end
		local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
		dot = math.abs(dot) / 2
		local dmg = resultVel * dot

		if object.PursuitBreakerActive then
			local driver = car.UnitVehicle or car.TrafficVehicle
				
			if driver then
				if driver:IsNPC() then
					driver:Wreck()
				else
					UVPlayerWreck(car)
				end
				return
			end	
		end

		if car.UnitVehicle or (car.UVWanted and not AutoHealth:GetBool()) then --DAMAGE
			if not car.healthset then
				if car.uvclasstospawnon == "npc_uvcommander" or car.UVCommander then
					local health = car.uvlasthealth or UVUOneCommanderHealth:GetInt()
					car:SetMaxHealth(UVUOneCommanderHealth:GetInt())
					car:SetHealth(health)
				else
					local mass = vehicle:GetPhysicsObject():GetMass()
					vehicle:SetMaxHealth(mass)
					vehicle:SetHealth(mass)
				end
				car.healthset = true
			end
			if not vcmod_main and dmg >= 10 then
				car:SetHealth(car:Health()-dmg)
				local e = EffectData()
				e:SetOrigin(coldata.HitPos)
				if car:Health() <= (car:GetMaxHealth()/4) then
					util.Effect("cball_explode", e)
				else
					util.Effect("StunstickImpact", e)
				end
				if car:Health() <= car:GetMaxHealth()/4 and not car.jeepdamaged then 
					car.jeepdamaged = true
					if car:LookupAttachment("vehicle_engine") > 0 then
						ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, car, car:LookupAttachment("vehicle_engine"))
					end
				end
			end
		end

		if car.grappleron and object.UVWanted then --Grappler
			UVGrapple(car, object)
		end

		if car.juggernauton and not object:IsWorld() then --Juggernaut
			local ourOldAngVel = coldata.OurOldAngularVelocity
			local objectPhys = object:GetPhysicsObject()
			local Phys = car:GetPhysicsObject()
			local force = car:GetVelocity():LengthSqr()

			local carPos = car:WorldSpaceCenter()
			local vectorDifference = object:WorldSpaceCenter() - carPos
			local angle = vectorDifference:Angle()

			objectPhys:ApplyForceCenter(angle:Forward()*force)

			--Preserve momentum
    		Phys:SetVelocity(ourOldVel)
			Phys:SetAngleVelocityInstantaneous(ourOldAngVel)

			local sounds = {
				"gadgets/juggernaut/impact_hard1.wav",
				"gadgets/juggernaut/impact_hard2.wav",
				"gadgets/juggernaut/impact_hard3.wav",
				"gadgets/juggernaut/impact_medium1.wav",
				"gadgets/juggernaut/impact_medium2.wav",
				"gadgets/juggernaut/impact_medium3.wav",
				"gadgets/juggernaut/impact_soft1.wav",
				"gadgets/juggernaut/impact_soft2.wav",
				"gadgets/juggernaut/impact_soft3.wav",
			}
			
			if not car.juggernauthit then
				car.juggernauthit = true
				car:EmitSound(sounds[math.random(1, #sounds)])
				timer.Simple(1, function()
					if IsValid(car) then
						car.juggernauthit = nil
					end
				end)
			end
		end

		if car.esfon and object:IsVehicle() and not (object.UnitVehicle and car.UnitVehicle) then --ESF
			if not object.UnitVehicle and not car.UnitVehicle then
				if not RacerFriendlyFire:GetBool() then return end
			end
			local enemyVehicle = object
			local enemyCallsign
			if object.UnitVehicle then
				enemyCallsign = object.UnitVehicle.callsign or "Unit "..object:EntIndex()
			else
				enemyCallsign = object.racer or "Racer "..enemyVehicle:EntIndex()
			end
			local enemyDriver = UVGetDriver(enemyVehicle)
			local power
			local damage
			if car.UnitVehicle then
				power = UVUnitPTESFPower:GetInt()
				damage = UVUnitPTESFDamage:GetFloat()
				if UVIsPTUpgraded(car) then
					power = power * 2
					damage = damage * 2
				end
			else
				power = UVPTESFPower:GetInt()
				damage = UVPTESFDamage:GetFloat()
			end
			local carPos = car:WorldSpaceCenter()
			local enemyVehiclePhys = enemyVehicle:GetPhysicsObject()
			local vectorDifference = enemyVehicle:WorldSpaceCenter() - carPos
			local angle = vectorDifference:Angle()
			local force = power * (1 - (vectorDifference:Length()/1000))
			enemyVehiclePhys:ApplyForceCenter(angle:Forward()*force)
			UVRamVehicle(enemyVehicle)
			if enemyDriver then
				if enemyDriver:IsPlayer() then
					enemyCallsign = enemyDriver:GetName()
				end
			end
			if object.UnitVehicle or (object.UVWanted and not AutoHealth:GetBool()) or not (object.UnitVehicle and object.UVWanted) then
				damage = (table.HasValue(UVCommanders, object) and UVPTESFCommanderDamage:GetFloat()) or damage
				UVDamage(object, damage)
			end

			-- local attacker = UVGetDriver(car)
			-- local attackerName = UVGetDriverName(car)

			-- local victim = UVGetDriver(car)
			-- local victimName = UVGetDriverName(enemyVehicle)

			-- local args = {
			-- 	['User'] = attackerName,
			-- 	['Hit'] = victimName
			-- }

			-- local playersToSend = {}

			-- if attacker then
			-- 	table.insert( playersToSend, attacker )
			-- end

			-- if victim then
			-- 	table.insert( playersToSend, victim )
			-- end
			ReportPTEvent( car, enemyVehicle, 'ESF', 'Hit' )
			--UVPTEvent( playersToSend, "ESF", "Hit", args )
			-- if isfunction(enemyVehicle.GetDriver) and IsValid(UVGetDriver(enemyVehicle)) and UVGetDriver(enemyVehicle):IsPlayer() then 
			-- 	UVGetDriver(enemyVehicle):PrintMessage( HUD_PRINTCENTER, "YOU HAVE BEEN HIT BY AN ESF!")
			-- end
			-- if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
			-- 	UVGetDriver(car):PrintMessage( HUD_PRINTCENTER, "ESF HIT ON "..enemyCallsign.."!")
			-- end
			local e = EffectData()
			e:SetEntity(enemyVehicle)
			util.Effect("entity_remove", e)
			enemyVehicle:EmitSound("gadgets/esf/impact.wav")
			car.uvesfhit = true
			UVDeactivateESF(car)
			if car.UnitVehicle then
				UVChatterESFHit(car.UnitVehicle)
			end
		end

		if car.UVWanted then --SUSPECT
			if object:IsWorld() or object.DecentVehicle or object.TrafficVehicle then --Crashed into world
				if dmg >= 100 and not UVEnemyEscaping and UVTargeting then
					if object:IsWorld() then
						if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
							local units = ents.FindByClass("npc_uv*")
							local random_entry = math.random(#units)	
							local unit = units[random_entry]
							if not IsValid(unit.e) then return end
							UVChatterEnemyCrashed(unit)
						end
					elseif object.DecentVehicle or object.TrafficVehicle then
						if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
							local units = ents.FindByClass("npc_uv*")
							local random_entry = math.random(#units)	
							local unit = units[random_entry]
							if not IsValid(unit.e) then return end
							UVChatterHitTraffic(unit)
						end
					end
				end
			end
			if object.UVRoadblock and not object.UVRoadblock.RoadBlockHit then --Crashed into roadblock
				object.UVRoadblock.RoadBlockHit = true
				if Chatter:GetBool() and UVTargeting and next(ents.FindByClass("npc_uv*")) ~= nil then
					local units = ents.FindByClass("npc_uv*")
					local random_entry = math.random(#units)	
					local unit = units[random_entry]
					if IsValid(unit.e) and car == unit.e then
						UVChatterRoadblockHit(unit) 
					end
				end
			end

		elseif car.UnitVehicle then --UNIT NPC
			local driver = UVGetDriver(car)
			local NPC = ((IsValid(driver) and driver) or car.UnitVehicle)--car.UnitVehicle
			if NPC and (NPC:IsNPC() or NPC:IsPlayer()) then
				if (not UVTargeting and UVPassConVarFilter(object) or UVTargeting and object.UVWanted) then
					UVRamVehicle(car)
				end
				if object.UVWanted and not car.tagged then
					car.tagged = true
					UVTags = UVTags + 1
					if car.rhino and not car.rhinohit then
						car.rhinohit = true
						if Chatter:GetBool() and UVTargeting and not car.roadblocking and not car.disperse then
							UVSoundChatter(NPC, NPC.voice, "rhinohit", 1)
						end
					end
				end
				if dmg >= 100 and object.UVWanted then
					if Chatter:GetBool() then
						if coldata.TheirOldVelocity:Length() > ourOldVel then
							UVChatterRammed(NPC)
							UVDeactivateKillSwitch(car)
						else
							UVChatterRammedEnemy(NPC)
						end
					end
					if not NPC.ramming then
						NPC.ramming = true
						NPC:SetHorn(true)
					end
					timer.Simple(math.random(1,5), function()
						if not NPC then return end
						if NPC.ramming then
							NPC.ramming = nil
							NPC:SetHorn(false)
							NPC:ChangeELSSiren()
						end
					end)
				end
			end

			if (NPC and NPC:IsPlayer()) and not UVTargeting and not UVEnemyEscaped and not UVEnemyBusted and table.HasValue(UVPotentialSuspects, object) then
				UVTargeting = true
			end
		elseif car.TrafficVehicle then --TRAFFIC
			local ourOldVel = coldata.OurOldVelocity:Length()
			local ourNewVel = coldata.OurNewVelocity:Length()
			local resultVel = ourOldVel
			if ourOldVel > ourNewVel then --slowed
				resultVel = ourOldVel - ourNewVel
			else --sped up
				resultVel = ourNewVel - ourOldVel
			end
			local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
			dot = math.abs(dot) / 2
			local dmg = resultVel * dot
			if dmg >= 100 then
				if IsValid(car.TrafficVehicle) then
					car.TrafficVehicle.emergencystop = true
				end
			end
		end
		if not object.UnitVehicle and not object:IsWorld() then --CALL HANDLER
			local ctimeout = 1
			if object:IsVehicle() then --Hit And Run
				if CurTime() > UVPreInfractionCountCooldown + ctimeout then
					UVPreInfractionCount = UVPreInfractionCount + 2
					UVPreInfractionCountCooldown = CurTime()
					if UVPreInfractionCount >= 10 then
						if UVPassConVarFilter(car) and isfunction(UVCallInitiate) then
							UVCallInitiate(car, 3)
						end
					end
				end
			else --Damage to Property
				if CurTime() > UVPreInfractionCountCooldown + ctimeout then
					UVPreInfractionCount = object.PursuitBreaker and UVPreInfractionCount + 10 or UVPreInfractionCount + 1
					UVPreInfractionCountCooldown = CurTime()
					if UVPreInfractionCount >= 10 then
						if UVPassConVarFilter(car) and isfunction(UVCallInitiate) then
							UVCallInitiate(car, 2)
						end
					end
				end
			end
		end
	end)
end)

function UVRamVehicle(vehicle)
	local update

	if vehicle.rammed then
		vehicle.rammed = nil
	else
		update = true
	end

	vehicle.rammed = true

	-- if update and vehicle.IsGlideVehicle then
	-- 	vehicle.ogAngularDrag = vehicle.AngularDrag or vector_origin
	-- 	vehicle.AngularDrag = vector_origin
	-- end

	timer.Create("UVRamVehicle"..vehicle:EntIndex(), 3, 1, function() 
		if IsValid(vehicle) and not vehicle.wrecked then 
			vehicle.rammed = nil
			-- if vehicle.IsGlideVehicle then
			-- 	vehicle.AngularDrag = vehicle.ogAngularDrag
			-- end
		end 
	end)
end

function UVAddToWantedListVehicle(vehicle)
	if not vehicle.UVWanted then
		vehicle.UVWanted = vehicle
	end
	local driver = UVGetDriver(vehicle)
	
	if not table.HasValue(UVWantedTableVehicle, vehicle) then
		table.insert(UVWantedTableVehicle, vehicle)
		
		net.Start( "UV_AddWantedVehicle" )
		--net.WriteEntity( vehicle )
		net.WriteInt( vehicle:EntIndex(), 32 )
		net.WriteInt( vehicle:GetCreationID(), 32 )
		net.Broadcast()
		
		if (driver and driver:IsPlayer()) and not table.HasValue(UVWantedTableDriver, driver) then
			UVAddToWantedListDriver(driver)
		end
		
		if (driver and driver:IsPlayer()) then
			if driver:GetMaxHealth() == 100 then
				driver:SetHealth(driver:Health()+1000000)
				driver:SetMaxHealth(driver:GetMaxHealth()+1000000)
			end
		end

		vehicle:CallOnRemove( "UVWantedVehicleRemoved", function(ent)
			if table.HasValue(UVWantedTableVehicle, ent) then
				table.RemoveByValue(UVWantedTableVehicle, ent)
			end
			
			net.Start( "UV_RemoveWantedVehicle" )
			net.WriteInt( ent:EntIndex(), 32 )
			net.WriteInt( ent:GetCreationID(), 32 )
			net.Broadcast()
		end)
	end
end

function UVAddToWantedListDriver(driver)
	if not IsValid(driver) or not driver:IsPlayer() then return end
	if table.HasValue(UVPlayerUnitTablePlayers, driver) then
		table.RemoveByValue(UVPlayerUnitTablePlayers, driver)
		net.Start( "UVHUDStopCopMode" )
		net.Send(driver)
	end
	if not table.HasValue(UVWantedTableDriver, driver) then
		table.insert(UVWantedTableDriver, driver)
		hook.Add( "PlayerDisconnected", "UVWantedDriverDisconnect", function(driver)
			if table.HasValue(UVWantedTableDriver, driver) then
				table.RemoveByValue(UVWantedTableDriver, driver)
			end
		end)
		net.Start( "UVHUDWanted" )
		net.Send(driver)
	end
end

function UVApplyAutoHealth(vehicle)
	if not AutoHealth:GetBool() then return end
	if vcmod_main and vehicle:GetClass() == "prop_vehicle_jeep" then
		vehicle:VC_repairFull_Admin()
		if not vehicle:VC_hasGodMode() then
			vehicle:VC_setGodMode(true)
		end
	end
	if vehicle.IsSimfphyscar then
		vehicle.simfphysoldhealth = vehicle:GetMaxHealth()
		vehicle:SetBulletProofTires(true)
		vehicle:SetMaxHealth(math.huge)
		vehicle:SetCurHealth(math.huge)
		vehicle:SetOnFire( false )
		vehicle:SetOnSmoke( false )
		net.Start( "simfphys_lightsfixall" )
		net.WriteEntity( vehicle )
		net.Broadcast()
		
		net.Start( "uvrepairsimfphys" )
		net.WriteEntity( vehicle )
		net.Broadcast()
	end
	if vehicle.IsGlideVehicle then
		vehicle:SetChassisHealth(math.huge)
		vehicle:SetEngineHealth(math.huge)
		vehicle:UpdateHealthOutputs()
		vehicle.FallOnCollision = nil
		for k, v in pairs(vehicle.wheels) do
			if v.params then
				v.params.isBulletProof = true
			end
		end
	end
end

function UVGiveRacerPursuitTech(vehicle)
	if not RacerPursuitTech:GetBool() then return end

	local pttable = {
		"EMP",
		"ESF",
		"Power Play",
		"Repair Kit",
		"Spikestrip",
		"Juggernaut",
		"Ghost",
		"Jammer",
		"Shockwave",
		"Stunmine",
	}

	if not vehicle.PursuitTech then
		vehicle.PursuitTech = {}
		
		for i=1, 2, 1 do
			local selected_pt = pttable[math.random(#pttable)]
			table.remove(pttable, table.KeyFromValue(pttable, selected_pt))
			
			local sanitized_pt = string.lower(string.gsub(selected_pt, " ", ""))
			local sel_k, sel_v
			
			for k,v in pairs(vehicle.PursuitTech) do
				if v.Tech == selected_pt then
					sel_k, sel_v = k, v
					vehicle.PursuitTech[k] = nil
					break
				end
			end
			
			local ammo_count = GetConVar("uvpursuittech_" .. sanitized_pt .. "_maxammo"):GetInt()
			ammo_count = ammo_count > 0 and ammo_count or math.huge
			
			vehicle.PursuitTech[i] = {
				Tech = selected_pt,
				Ammo = ammo_count,
				Cooldown = GetConVar("uvpursuittech_" .. sanitized_pt .. "_cooldown"):GetInt(),
				LastUsed = -math.huge,
			}
		end
		
		table.insert(UVRVWithPursuitTech, vehicle)
		
		vehicle:CallOnRemove( "UVRVWithPursuitTechRemoved", function(car)
			if table.HasValue(UVRVWithPursuitTech, car) then
				table.RemoveByValue(UVRVWithPursuitTech, car)
			end
		end)

		timer.Simple(1, function()
			for i=1,2 do
				UVReplicatePT( vehicle, i )
			end
		end)
	end
end

local MUTATOR_FUNCTIONS = {
	['Multiply'] = function( baseValue, multiplier, info ) 
		return math.Clamp( baseValue * ( multiplier * ( multiplier == 1 and 1 or info.Modifier ) ), info.Min or 0, info.Max or math.huge )
	end,
	['Static'] = function( baseValue, multiplier, info ) 
		return multiplier <= info.Max and baseValue or info.Modifier
	end,
	['ModifierComparison'] = function( baseValue, multiplier, info ) 
		return baseValue * ( multiplier > info.Modifier and info.Max or info.Min )
	end
}

local VEHICLE_BASE_PERFORMANCE_SETS = {
	['Simfphys'] = {
		['Efficiency'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['MaxTraction'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['BrakePower'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		}
	},
	['Glide'] = {
		['BrakePower'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		-- Note: The cornering accuracy of the AI on Glide heavily depends on SteerConeMaxAngle, this also applies for units
		-- originally i only kept SteerConeChangeRate for Infmap use, comment out again if not plausible -aux
		['SteerConeChangeRate'] = {
			['DataType'] = "NetworkVar",
			['IsCatchup'] = true,
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		-- ['SteerConeMaxSpeed'] = {
		-- 	['DataType'] = "NetworkVar",
		-- 	['IsUnit'] = true,
		-- 	['Info'] = {
		-- 		['Type'] = "Multiply",
		-- 		['Modifier'] = 1,
		-- 		['Min'] = 0,
		-- 		['Max'] = math.huge
		-- 	}
		-- },
		['SteerConeMaxAngle'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['MaxRPM'] = {
			['DataType'] = "NetworkVar",
			['IsUnit'] = true,
			['IsCatchup'] = true,
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['MaxRPMTorque'] = {
			--['IsUnit'] = true,
			['IsCatchup'] = true,
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['MinRPMTorque'] = {
			--['IsUnit'] = true,
			['IsCatchup'] = true,
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['ForwardTractionMax'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 2,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['SideTractionMax'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['SideTractionMaxAng'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['SideTractionMin'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "Multiply",
				['Modifier'] = 1,
				['Min'] = 0,
				['Max'] = math.huge
			}
		},
		['SuspensionLength'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "ModifierComparison",
				['Modifier'] = 1,
				['Min'] = 1,
				['Max'] = 0.75
			}
		},
		['SpringStrength'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "ModifierComparison",
				['Modifier'] = 1,
				['Min'] = 1,
				['Max'] = 1.25
			}
		},
		['SpringDamper'] = {
			['DataType'] = "NetworkVar",
			['Info'] = {
				['Type'] = "ModifierComparison",
				['Modifier'] = 1,
				['Min'] = 1,
				['Max'] = 1.5
			}
		},
		['PowerDistribution'] = {
			['DataType'] = "NetworkVar",
			['IsUnit'] = true,
			['IsCatchup'] = true,
			['Info'] = {
				['Type'] = "Static",
				['Modifier'] = 0.1,
				['Min'] = 1,
				['Max'] = 1.2,
			}
		},
	},
	['prop_vehicle_jeep'] = {

	}
}

function UVSetVehiclePerformanceMultiplier( vehicle, mult, catchup )
	mult = tonumber(mult) or 1

	local isSimfphysVehicle = vehicle.IsSimfphyscar
	local isGlideVehicle = vehicle.IsGlideVehicle

	local needle = nil

	if vehicle.IsSimfphyscar then
		needle = VEHICLE_BASE_PERFORMANCE_SETS['Simfphys']
	elseif vehicle.IsGlideVehicle then
		needle = VEHICLE_BASE_PERFORMANCE_SETS['Glide']
	else
		needle = VEHICLE_BASE_PERFORMANCE_SETS['prop_vehicle_jeep']
	end

	if not vehicle.__UVOriginalPerformance then vehicle.__UVOriginalPerformance = {} end

	for stat, data in pairs( needle ) do
		local multiplier = mult
		if mult > 1 then
			if data.IsUnit and not vehicle.UnitVehicle then continue end
			if data.IsCatchup and not catchup then multiplier = 1 end
		end
		if data.DataType == "NetworkVar" then
			local getFunc = vehicle['Get'..stat]
			local setFunc = vehicle['Set'..stat]

			if isfunction( getFunc ) and isfunction( setFunc ) then
				if not vehicle.__UVOriginalPerformance[stat] then vehicle.__UVOriginalPerformance[stat] = getFunc() end
				setFunc( vehicle, MUTATOR_FUNCTIONS[data.Info.Type](
					vehicle.__UVOriginalPerformance[stat], 
					multiplier, 
					data.Info
				) )
			end
		end
	end

	if isGlideVehicle then
		vehicle:UpdateWheelParameters()
		vehicle:UpdatePowerDistribution()
	end
end

--[[
	/// INFRACTIONS LIST ///
	- Speeding (reach 10+ MPH over the limit set by the closest DV waypoint or unitvehicle_speedlimit, whichever is lower)
	- Excessive Speeding (reach 50+ MPH over the limit set by the closest DV waypoint or unitvehicle_speedlimit, whichever is lower)
	- Reckless Driving (reach 100+ MPH over the limit set by the closest DV waypoint or unitvehicle_speedlimit, whichever is lower)
	- Street Racing (be in a race event)
	- Property Damage (hit a non-vehicle entity)
	- Ramming a Police Vehicle (hit a Unit)
	- Driving Off-road (drive on a non-road surface)
	- Resisting Arrest (enter cooldown)
	- Hit and Run (hit a Traffic)
	- Overuse of Resources (trigger the backup timer)
	- Public Endangerment (use a Pursuit Tech/cause a Traffic vehicle to swerve out of your way)
	- Vehicular Homicide (cause a vehicle to explode/run over a pedestrian)

	*you must be seen by the Unit or be reported by a witness for an infraction to be counted, except for Resisting Arrest
]]

function UVAddInfraction(vehicle, infraction)
	if not IsValid(vehicle) or not vehicle:IsVehicle() then return end
	if not vehicle.Infractions then vehicle.Infractions = {} end
	table.insert(vehicle.Infractions, infraction)
end

function UVGetIfSomeoneDriving()
	for k, v in pairs(player.GetAll()) do
		if IsValid(v) and v:InVehicle() then
			return true
		end
	end
	return false
end

function UVAddToPlayerUnitListVehicle(vehicle, ply)
	net.Start("UVHUDAddUV")
	net.WriteInt(vehicle:EntIndex(), 32)
	net.WriteInt(vehicle:GetCreationID(), 32)
	net.WriteString("unit")
	net.Broadcast()
	
	if not table.HasValue(UVPlayerUnitTableVehicle, vehicle) then
		if vehicle.IsSimfphyscar then
			vehicle:SetBulletProofTires(true)
		end
		if vehicle:GetClass() == "prop_vehicle_jeep" then
			local mass = vehicle:GetPhysicsObject():GetMass()
			vehicle:SetMaxHealth(mass)
			vehicle:SetHealth(mass)
		end
		if vehicle.IsGlideVehicle then
			for k, v in pairs(vehicle.wheels) do
				if v.params then
					v.params.isBulletProof = true
				end
			end
		end
		table.insert(UVPlayerUnitTableVehicle, vehicle)
		vehicle:CallOnRemove( "UVPlayerUnitVehicleRemoved", function(ent)
			if table.HasValue(UVPlayerUnitTableVehicle, ent) then
				table.RemoveByValue(UVPlayerUnitTableVehicle, ent)
			end
			-- if table.HasValue(UVUnitsChasing, ent) then
			-- 	table.RemoveByValue(UVUnitsChasing, ent)
			-- end
		end)
	end
end

function UVChangeTactics(tactic)
	if not tactic or next(UVUnitsChasing) == nil then return end
	
	--Clear existing formations
	local AvailableUnits = {}
	for k, v in pairs(UVUnitsChasing) do
		if v.formationpoint then
			v.formationpoint = nil
		end
		table.insert(AvailableUnits, v)
	end

	local FormationPoints
	
	if tactic == 0 then --No formation
		return
	elseif #UVUnitsChasing == 1 then --One unit remaining
		FormationPoints = {
			Vector(0,-300,0), --Rear
		}
	elseif tactic == 1 then --Box formation
		FormationPoints = {
			Vector(0,300,0), --Front
			Vector(0,-300,0), --Rear
			Vector(-200,0,0), --Left
			Vector(200,0,0), --Right
			Vector(-200,300,0), --Left Front
			Vector(200,300,0),	--Right Front
			Vector(-200,-300,0), --Left Rear
			Vector(200,-300,0), --Right Rear
			Vector(0,-600,0), --Rear Rear
			Vector(0,-900,0), --Rear Rear Rear
		}
	elseif tactic == 2 then --Rolling Roadblock formation
		FormationPoints = {
			Vector(0,300,0), --Front
			Vector(0,-300,0), --Rear
			Vector(-200,300,0), --Left Front
			Vector(200,300,0), --Right Front
			Vector(-400,300,0), --Left Left Front
			Vector(400,300,0), --Right Right Front
			Vector(-200,-300,0), --Left Rear
			Vector(200,-300,0), --Right Rear
			Vector(-400,-300,0), --Left Left Rear
			Vector(400,-300,0), --Right Right Rear
		}
	elseif tactic == 3 then --Spearhead formation
		FormationPoints = {
			Vector(0,600,0), --Front Front
			Vector(0,-300,0), --Rear
			Vector(-200,300,0), --Left Front
			Vector(200,300,0), --Right Front
			Vector(-400,0,0), --Left Left
			Vector(400,0,0), --Right Right
			Vector(-200,-600,0), --Left Rear Rear
			Vector(200,-600,0), --Right Rear Rear
			Vector(-400,-900,0), --Left Left Rear Rear Rear
			Vector(400,-900,0), --Right Right Rear Rear Rear
		}
	elseif tactic == 4 then --Box formation (right priority)
		FormationPoints = {
			Vector(0,300,0), --Front
			Vector(0,-300,0), --Rear
			Vector(200,0,0), --Right
			Vector(-200,0,0), --Left
			Vector(200,300,0),	--Right Front
			Vector(-200,300,0), --Left Front
			Vector(200,-300,0), --Right Rear
			Vector(-200,-300,0), --Left Rear
			Vector(0,-600,0), --Rear Rear
			Vector(0,-900,0), --Rear Rear Rear
		}
	elseif tactic == 5 then --Rolling Roadblock formation (right priority)
		FormationPoints = {
			Vector(0,300,0), --Front
			Vector(0,-300,0), --Rear
			Vector(200,300,0), --Right Front
			Vector(-200,300,0), --Left Front
			Vector(400,300,0), --Right Right Front
			Vector(-400,300,0), --Left Left Front
			Vector(200,-300,0), --Right Rear
			Vector(-200,-300,0), --Left Rear
			Vector(400,-300,0), --Right Right Rear
			Vector(-400,-300,0), --Left Left Rear
		}
	elseif tactic == 6 then --Spearhead formation (right priority)
		FormationPoints = {
			Vector(0,600,0), --Front Front
			Vector(0,-300,0), --Rear
			Vector(200,300,0), --Right Front
			Vector(-200,300,0), --Left Front
			Vector(400,0,0), --Right Right
			Vector(-400,0,0), --Left Left
			Vector(200,-600,0), --Right Rear Rear
			Vector(-200,-600,0), --Left Rear Rear
			Vector(400,-900,0), --Right Right Rear Rear Rear
			Vector(-400,-900,0), --Left Left Rear Rear Rear
		}
	end

	if FormationPoints and istable(FormationPoints) then
		for i = 1, #UVUnitsChasing do
			if next(FormationPoints) == nil or next(AvailableUnits) == nil then break end
			local unit = AvailableUnits[1]
			local point = FormationPoints[1]
			if unit.e then
				if unit.e.IsSimfphyscar then
					point:Rotate(Angle(0, (unit.e.VehicleData.LocalAngForward.y-90), 0))
				elseif unit.e.IsGlideVehicle then
					point:Rotate(Angle(0, (unit.e:GetForward().y-90), 0))
				end
			end
			unit.formationpoint = point
			table.RemoveByValue(AvailableUnits, unit)
			table.RemoveByValue(FormationPoints, point)
		end
	end
end

function UVBustEnemy(self, enemy, finearrest)
	if not IsValid(self) or not IsValid(enemy) or (enemy.uvbusted and not finearrest) then return end

	if not self.callsign then
		self.callsign = "the Unit Vehicles"
	end

	enemy.uvbusted = true
	enemy.UVBustingProgress = 0
	-- if UVRaceTable['Participants'] then
	-- 	if UVRaceTable['Participants'][enemy] then
	-- 		UVRaceTable['Participants'][enemy].Busted = true
	-- 	end
	-- end
	if enemy.RacerVehicle then
		enemy.RacerVehicle:Remove()
	end
	if enemy.MadVehicle then
		enemy.MadVehicle:Remove()
	end
	if enemy.UVWanted then
		enemy.UVWanted = nil
	end

	net.Start("UVHUDRemoveUV")
	net.WriteInt( enemy:EntIndex(), 32 )
	net.WriteInt( enemy:GetCreationID(), 32 )
	net.Broadcast()

	if table.HasValue(UVWantedTableVehicle, enemy) then
		table.RemoveByValue(UVWantedTableVehicle, enemy)
	end
	
	net.Start( "UV_RemoveWantedVehicle" )
	net.WriteInt( enemy:EntIndex(), 32 )
	net.WriteInt( enemy:GetCreationID(), 32 )
	net.Broadcast()
	
	if table.HasValue(UVPotentialSuspects, enemy) then
		table.RemoveByValue(UVPotentialSuspects, enemy)
	end
	local timeacknowledge = 5
	local enemyDriver = UVGetDriver(enemy)
	
	if UVTargeting or self.UVAir or finearrest then --Arrest
		if enemy:IsVehicle() then
			local e = UVGetVehicleMakeAndModel(enemy)
			if Chatter:GetBool() then
				if finearrest then
					net.Start( "UVFineArrest" )
					net.Send(enemyDriver)
					timeacknowledge = UVChatterFineArrest(self) or 5
				else
					timeacknowledge = UVChatterArrest(self) or 5
				end
			end
			if next(UVPlayerUnitTablePlayers) ~= nil then
				UVRelaySoundToClients("ui/pursuit/busted.wav", false)
			end
			if IsValid(enemyDriver) and enemyDriver:IsPlayer() then
				net.Start('UVBusted')
				net.WriteTable({
					['Racer'] = enemyDriver:GetName(),
					['Cop'] = self.callsign
				})
				net.Broadcast()
			else
				net.Start('UVBusted')
				net.WriteTable({
					['Racer'] = enemy.racer or "Racer "..enemy:EntIndex(),
					['Cop'] = self.callsign
				})
				net.Broadcast()
			end
		end
		local v = EffectData()
		v:SetEntity(enemy)
		util.Effect("phys_freeze", v)
		local despawntime = 60
		table.insert(UVWreckedVehicles, vehicle)
		if enemy.IsGlideVehicle then
			local wreck = enemy
			timer.Simple(despawntime, function()
				if IsValid(wreck) then
					SafeRemoveEntity(wreck)
				end
			end)
			wreck:SetEngineHealth(0)
			wreck.UnflipForce = 0
			wreck.AngularDrag = vector_origin
			if wreck:GetVelocity():LengthSqr() > 250000 then
				UVGlideDetachWheels(wreck)
			end
		elseif enemy.IsSimfphyscar then
			local wreck = enemy
			timer.Simple(despawntime, function()
				if IsValid(wreck) then
					SafeRemoveEntity(wreck)
				end
			end)
			if enemy:GetVelocity():LengthSqr() > 250000 then
				for i = 1, #wreck.Wheels do
					local wheelmathchance = math.random(1,2)
					local Wheel = wreck.Wheels[math.random(1, #wreck.Wheels)]
					if wheelmathchance == 1 then
						constraint.RemoveAll(Wheel)
					end
				end
			end
			wreck:SetActive(false)
			--wreck:SetCurHealth(0) -- removed to prevent explosions
			wreck:SetLightsEnabled(false)
			wreck.emson = false
			wreck:SetEMSEnabled( false )
		elseif enemy:GetClass() == "prop_vehicle_jeep" then
			local wreck = enemy
			wreck:StartEngine(false)
			wreck:EmitSound( "vehicles/v8/vehicle_rollover"..math.random(1,2)..".wav" )
			wreck:AddCallback("PhysicsCollide", function(ent, coldata)
				local ourOldVel = coldata.OurOldVelocity:Length()
				local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
				dot = math.abs(dot) / 2
				local dmg = ourOldVel * dot
				if dmg < 10 then return end
				local e = EffectData()
				e:SetOrigin(coldata.HitPos)
				util.Effect("cball_explode", e)
			end)
			if wreck:LookupAttachment("vehicle_engine") > 0 then
				ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, wreck, wreck:LookupAttachment("vehicle_engine"))
			end
			local e = EffectData()
			e:SetEntity(wreck)
			util.Effect("entity_remove", e)
			timer.Simple(despawntime, function()
				if IsValid(wreck) then
					wreck:Remove()
				end
			end)
		end
		timer.Simple(timeacknowledge, function()
			if Chatter:GetBool() and IsValid(self) then
				if not self.UVAir then
					UVChatterArrestAcknowledge(self)
				else
					UVChatterArrestAcknowledge(self)
				end
			end
		end)
		if enemyDriver and enemyDriver:IsPlayer() and not enemy.DecentVehicle and not enemy.TrafficVehicle then
			local driver = enemyDriver
			local bustedtable = {}
			bustedtable["Unit"] = self.callsign
			bustedtable["Deploys"] = UVDeploys
			bustedtable["Roadblocks"] = UVRoadblocksDodged
			bustedtable["Spikestrips"] = UVSpikestripsDodged
			timer.Create('MakeArrest'..driver:EntIndex(), 3, 1, function()
				if not finearrest then
					net.Start( "UVHUDBustedDebrief" )
					net.WriteTable(bustedtable)
					net.Send(driver)
				end
				driver:KillSilent()
				driver:SetNoDraw(true)
				driver:Spectate(OBS_MODE_DEATHCAM)
				driver:SpectateEntity(driver)
				driver:SetFrags(0)
			end)
			net.Start( "UVHUDEnemyBusted" )
			net.Send(driver)
			if table.HasValue(UVWantedTableDriver, enemyDriver) then
				table.RemoveByValue(UVWantedTableDriver, enemyDriver)
			end
		end
		self.chasing = nil
		UVEnemyBusted = true
		self.aggressive = nil
		timer.Simple(timeacknowledge, function()
			if #UVWantedTableVehicle == 0 then
				UVTargeting = nil
			end
			UVEnemyBusted = nil
		end)
		self.displaybusting = nil
	else --Fine
		timer.Simple(0.01, function()
			UVTargeting = nil
			self.chasing = nil
			for k, v in pairs(ents.FindByClass("npc_uv*")) do
				v:ForgetEnemy()
			end
			net.Start( "UVHUDStopBusting" )
			net.Broadcast()
		end)
		UVEnemyBusted = true
		if not UVTargeting then
			enemy.UVHUDBusting = nil
			enemy.UVHUDBustingDelayed = nil

			UVBounty = 0
		end
		if enemy:IsVehicle() then
			local e = UVGetVehicleMakeAndModel(enemy)
			if not enemy.UVFinedCount then
				enemy.UVFinedCount = 0
			end
			enemy.UVFinedCount = enemy.UVFinedCount + 1
			if enemy.UVFinedCount >= 3 then
				UVBustEnemy(self, enemy, true)
				return
			end
			if Chatter:GetBool() and IsValid(self.v) then
				UVChatterFinePaid(self)
			end
		end
		if enemyDriver and enemyDriver:IsPlayer() then 
			local driver = enemyDriver
			timer.Simple(0.1, function()
				driver:SetFrags(0)
				-- driver:PrintMessage( HUD_PRINTCENTER, "You have been fined! You have 10 seconds to drive away.")
				net.Start( "UVFined" )
				net.WriteUInt( enemy.UVFinedCount, 3 )
				net.Send(driver)
			end)
			driver:EmitSound("ui/pursuit/fined.wav", 0, 100, 0.5)
		end
		self.aggressive = nil
		timer.Simple(10, function()
			UVEnemyBusted = nil
			enemy.uvbusted = nil
		end)
	end

	if #UVWantedTableVehicle == 0 and next(UVPlayerUnitTableVehicle) ~= nil then
		for k, car in pairs(UVPlayerUnitTableVehicle) do
			UVSetELS(false, car)
			UVSetELSSound(false, car)
		end
	end

end

function UVDelayRoadblock()
	if UVRoadblockDelayed then return end
	UVRoadblockDelayed = true
	timer.Simple(0.5, function()
		UVRoadblockDelayed = false
	end)
end

local COLORS = {
	-- REDS
	{ name = 'red', article = 'a', color = Color(255, 0, 0) },
	{ name = 'red', article = 'a', color = Color(200, 0, 0) },
	{ name = 'red', article = 'a', color = Color(220, 20, 60) },
	{ name = 'red', article = 'a', color = Color(255, 69, 0) },

	-- BEIGES
	{ name = 'beige', article = 'a', color = Color(245, 245, 220) },
	{ name = 'beige', article = 'a', color = Color(222, 184, 135) },
	{ name = 'beige', article = 'a', color = Color(210, 180, 140) },

	-- BLACKS
	{ name = 'black', article = 'a', color = Color(0, 0, 0) },
	{ name = 'black', article = 'a', color = Color(30, 30, 30) },
	{ name = 'black', article = 'a', color = Color(50, 50, 50) },

	-- BLUES
	{ name = 'blue', article = 'a', color = Color(0, 0, 255) },
	{ name = 'blue', article = 'a', color = Color(0, 0, 200) },
	{ name = 'blue', article = 'a', color = Color(65, 105, 225) },
	{ name = 'blue', article = 'a', color = Color(70, 130, 180) },
	{ name = 'blue', article = 'a', color = Color(0, 191, 255) },

	-- BROWNS
	{ name = 'brown', article = 'a', color = Color(139, 69, 19) },
	{ name = 'brown', article = 'a', color = Color(160, 82, 45) },
	{ name = 'brown', article = 'a', color = Color(165, 42, 42) },
	{ name = 'brown', article = 'a', color = Color(210, 105, 30) },

	-- GOLDS
	{ name = 'gold', article = 'a', color = Color(255, 215, 0) },
	{ name = 'gold', article = 'a', color = Color(218, 165, 32) },
	{ name = 'gold', article = 'a', color = Color(184, 134, 11) },

	-- GREENS
	{ name = 'green', article = 'a', color = Color(0, 255, 0) },
	{ name = 'green', article = 'a', color = Color(0, 128, 0) },
	{ name = 'green', article = 'a', color = Color(34, 139, 34) },
	{ name = 'green', article = 'a', color = Color(50, 205, 50) },
	{ name = 'green', article = 'a', color = Color(60, 179, 113) },

	-- ORANGES
	{ name = 'orange', article = 'an', color = Color(255, 165, 0) },
	{ name = 'orange', article = 'an', color = Color(255, 140, 0) },
	{ name = 'orange', article = 'an', color = Color(255, 120, 0) },

	-- PINKS
	{ name = 'pink', article = 'a', color = Color(255, 192, 203) },
	{ name = 'pink', article = 'a', color = Color(255, 105, 180) },
	{ name = 'pink', article = 'a', color = Color(255, 182, 193) },

	-- PURPLES
	{ name = 'purple', article = 'a', color = Color(128, 0, 128) },
	{ name = 'purple', article = 'a', color = Color(148, 0, 211) },
	{ name = 'purple', article = 'a', color = Color(186, 85, 211) },

	-- SILVERS
	{ name = 'silver', article = 'a', color = Color(192, 192, 192) },
	{ name = 'silver', article = 'a', color = Color(169, 169, 169) },
	{ name = 'silver', article = 'a', color = Color(211, 211, 211) },

	-- WHITES
	{ name = 'white', article = 'a', color = Color(255, 255, 255) },
	{ name = 'white', article = 'a', color = Color(245, 245, 245) },
	{ name = 'white', article = 'a', color = Color(250, 250, 250) },

	-- YELLOWS
	{ name = 'yellow', article = 'a', color = Color(255, 255, 0) },
	{ name = 'yellow', article = 'a', color = Color(255, 255, 102) },
	{ name = 'yellow', article = 'a', color = Color(255, 255, 153) },
}

local function UVGetColorMagnitude( c1, c2 )
	local c1 = c1:ToTable()
	local c2 = c2:ToTable()

	local magnitude = 0

	for i = 1, 3 do
		magnitude = magnitude + ( c1[i] - c2[i] ) ^ 2
	end

	return magnitude
end

function UVColor( ent )
	local vehicleColor = ent:GetColor()
	local shortestDistance = math.huge
	local closestColor = nil

	for _, cArray in pairs( COLORS ) do
		local distance = UVGetColorMagnitude( vehicleColor, cArray.color )

		if distance < shortestDistance then
			shortestDistance = distance
			closestColor = cArray
		end
	end

	return closestColor
end

function UVColorName(ent)
	
	-- if not IsValid(ent) then return end
	
	-- if ent:GetSkin() ~= 0 then
	-- 	return "a custom"
	-- end
	
	-- local color = ent:GetColor()
	-- local rgba = color:ToTable()
	-- local alpha = table.remove(rgba)
	
	-- local rgbtable = {
	-- 	{255, 0, 0},
	-- 	{255, 0, 97},
	-- 	{255, 0, 191},
	-- 	{255, 0, 255},
	-- 	{220, 0, 255},
	-- 	{127, 0, 255},
	-- 	{29, 0, 255},
	-- 	{0, 63, 255},
	-- 	{0, 161, 255},
	-- 	{0, 255, 255},
	-- 	{0, 255, 157},
	-- 	{0, 255, 63},
	-- 	{33, 255, 0},
	-- 	{127, 255, 0},
	-- 	{225, 255, 0},
	-- 	{255, 255, 0},
	-- 	{255, 191, 0},
	-- 	{255, 170, 0},
	-- 	{255, 93, 0},
	-- 	{127, 0, 0},
	-- 	{127, 0, 95},
	-- 	{63, 0, 127},
	-- 	{0, 31, 127},
	-- 	{0, 127, 127},
	-- 	{0, 127, 31},
	-- 	{63, 127, 0},
	-- 	{127, 95, 0},
	-- 	{127, 63, 63},
	-- 	{127, 63, 111},
	-- 	{95, 63, 127},
	-- 	{63, 79, 127},
	-- 	{63, 127, 127},
	-- 	{63, 127, 79},
	-- 	{95, 127, 63},
	-- 	{127, 111, 63},
	-- 	{255, 127, 127},
	-- 	{255, 127, 223},
	-- 	{191, 127, 255},
	-- 	{127, 159, 255},
	-- 	{127, 255, 255},
	-- 	{0, 255, 255},
	-- 	{127, 255, 159},
	-- 	{191, 255, 127},
	-- 	{255, 223, 127},
	-- 	{255, 255, 255},
	-- 	{218, 218, 218},
	-- 	{182, 182, 182},
	-- 	{145, 145, 145},
	-- 	{109, 109, 109},
	-- 	{72, 72, 72},
	-- 	{36, 36, 36},
	-- 	{0, 0, 0},
	-- }
	
	-- local colornametable = {
	-- 	"a red",
	-- 	"a razzmatazz",
	-- 	"a hot magenta",
	-- 	"a magenta",
	-- 	"a psychedelic purple",
	-- 	"an electric indigo",
	-- 	"a blue",
	-- 	"a blue",
	-- 	"a deep sky blue",
	-- 	"an aqua",
	-- 	"a medium spring green",
	-- 	"a free speech green",
	-- 	"a harlequin",
	-- 	"a chartreuse",
	-- 	"a chartreuse yellow",
	-- 	"a yellow",
	-- 	"an amber",
	-- 	"an orange",
	-- 	"a safety orange",
	-- 	"a maroon",
	-- 	"an eggplant",
	-- 	"an indigo",
	-- 	"a navy",
	-- 	"a teal",
	-- 	"a green",
	-- 	"a green",
	-- 	"an olive",
	-- 	"a stiletto",
	-- 	"a cadillac",
	-- 	"a gigas",
	-- 	"a jacksons purple",
	-- 	"a ming",
	-- 	"an amazon",
	-- 	"a dingley",
	-- 	"a yellow metal",
	-- 	"a vivid tangerine",
	-- 	"a neon pink",
	-- 	"a heliotrope",
	-- 	"a maya blue",
	-- 	"an electric blue",
	-- 	"a cyan",
	-- 	"a mint green",
	-- 	"a mint green",
	-- 	"a salomie",
	-- 	"a white",
	-- 	"a gainsboro",
	-- 	"a silver",
	-- 	"a suva gray",
	-- 	"a dim gray",
	-- 	"a charcoal",
	-- 	"a nero",
	-- 	"a black",
	-- }
	
	-- local index = 0
	
	-- for k, v in pairs(rgbtable) do
	-- 	index = index + 1
	-- 	if rgba[1] == v[1] and rgba[2] == v[2] and rgba[3] == v[3] then
	-- 		return colornametable[index]
	-- 	end
	-- end
	
	-- return "a"
	
end

function UVCheckIfBeingBusted(enemy)
	
	local enemyDriver = UVGetDriver(enemy)
	local btimeout = BustedTimer:GetFloat()
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
		local enemypos = enemy:WorldSpaceCenter()
		local distance = enemypos:DistToSqr(w:WorldSpaceCenter())
		if distance < closestdistancetounit then
			-- check the unit is uvair, then do not count it
			if w:GetClass() ~= 'uvair' then
				closestdistancetounit, closestunit = distance, w
			elseif UVUHelicopterBusting:GetBool() then
				closestdistancetounit, closestunit = distance, w
			end
		end
	end
	
	if not closestunit then closestunit = enemy end

	UVBustSpeed = UVBustSpeed or 5
	
	if not enemy.uvbusted and btimeout and btimeout > 0 and enemy:GetVelocity():LengthSqr() < UVBustSpeed and not UVEnemyEscaping and next(UVUnitsChasing) ~= nil and
	(closestdistancetounit < 250000 or closestunit.CloseToTarget) and 
	(IsValid(closestunit.e) or (isfunction(closestunit.GetTarget)) and IsValid(closestunit:GetTarget())) then
		if not enemy.UVHUDBusting and not enemy.UVHUDBustingDelayed then
			enemy.UVHUDBusting = true
			enemy.UVHUDBustingDelayed = true
			timer.Simple(1, function()
				enemy.UVHUDBustingDelayed = nil
			end)
			if Chatter:GetBool() and IsValid(closestunit) and not UVCalm then
				local randomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil and randomno == 1 then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if unit:GetTarget() == enemy then
						UVChatterBusting(unit)
					else
						UVChatterBusting(closestunit)
					end
				else
					UVChatterBusting(closestunit)
				end
			end
			if IsValid(enemyDriver) then
				enemyDriver:EmitSound("ui/pursuit/busting_start.wav", 0, 100, 0.5)
			end
			net.Start( "UVHUDCopModeBusting" )
			net.WriteEntity(enemy)
			net.Broadcast()
		end
		if not enemy.uvbustingincrease then
			enemy.uvbustingincrease = true
			enemy.randomptuse = math.random(1, BustedTimer:GetFloat() * .7)
			enemy.UVBustingLastProgress = CurTime()
			enemy.UVBustingLastProgress2 = enemy.UVBustingProgress
		end
		enemy.UVBustingProgress = enemy.UVBustingLastProgress2 + (CurTime() - enemy.UVBustingLastProgress)
		if enemy.UVBustingProgress >= (btimeout-1) and not enemy.nearbust then
			enemy.nearbust = true
		end
		
		if enemy.PursuitTech and not (enemy:GetDriver() and enemy:GetDriver():IsPlayer()) and enemy.randomptuse < enemy.UVBustingProgress then
			for k, v in pairs(enemy.PursuitTech) do
				if v.Tech == 'Shockwave' then
					UVDeployWeapon( enemy, k )
				end
			end
		end
	else
		if enemy.UVHUDBusting then
			if enemy.uvbustingincrease then
				enemy.uvbustingincrease = false
				enemy.UVBustingLastProgress = CurTime()
				enemy.UVBustingLastProgress2 = enemy.UVBustingProgress
				if enemy.nearbust then
					if not enemy.UVHighestBustingProgress then
						enemy.UVHighestBustingProgress = enemy.UVBustingProgress
					elseif enemy.UVBustingProgress > enemy.UVHighestBustingProgress then
						enemy.UVHighestBustingProgress = enemy.UVBustingProgress
					end
					print(enemy.UVHighestBustingProgress)
				end
			end
			if (enemy.UVBustingProgress <= 0 or enemy.uvbusted) and not enemy.UVHUDBustingDelayed then
				enemy.UVHUDBusting = nil
				enemy.UVHUDBustingDelayed = true
				timer.Simple(1, function()
					enemy.UVHUDBustingDelayed = nil
				end)
				net.Start( "UVHUDStopBusting" )
				net.Broadcast()
				if not UVTargeting and not enemy.uvbusted then
					UVTargeting = true
					if next(ents.FindByClass("npc_uv*")) ~= nil and Chatter:GetBool() then
						local units = ents.FindByClass("npc_uv*")
						local random_entry = math.random(#units)	
						local unit = units[random_entry]
						if not IsValid(unit.e) then return end
						UVChatterPursuitStartRanAway(unit)
					end
				end
				if Chatter:GetBool() and IsValid(closestunit) and not UVCalm then
					local randomno = math.random(1,2)
					local airUnits = ents.FindByClass("uvair")
					if next(airUnits) ~= nil and randomno == 1 then
						local random_entry = math.random(#airUnits)	
						local unit = airUnits[random_entry]
						if unit:GetTarget() == enemy then
							UVChatterBustEvaded(unit)
						else
							UVChatterBustEvaded(closestunit)
						end
					else
						UVChatterBustEvaded(closestunit)
					end
				end
				if IsValid(enemyDriver) then
					if enemy.UVHighestBustingProgress then
						net.Start( "UVHUDStopBustingTimeLeft" )
							net.WriteFloat(enemy.UVHighestBustingProgress)
						net.Send(enemyDriver)
					end
					enemyDriver:EmitSound("ui/pursuit/busting_whoosh_high.wav", 0, 100, 0.5)
				end
				enemy.UVHighestBustingProgress = nil
				if enemy.nearbust then
					enemy.nearbust = nil
				end
				net.Start( "UVHUDStopCopModeBusting" )
				net.WriteEntity(enemy)
				net.Broadcast()
			end
			enemy.UVBustingProgress = enemy.UVBustingLastProgress2 - (CurTime() - enemy.UVBustingLastProgress)
		end 
		enemy.UVStartBustingEnemy = false
	end
	
	--Display busting
	if enemy.UVHUDBusting then
		if enemyDriver then
			net.Start( "UVHUDBusting" )
			net.WriteString(enemy.UVBustingProgress)
			net.Send(enemyDriver)
		end
		if btimeout and btimeout > 0 and not enemy.uvbusted and enemy.UVBustingProgress >= btimeout then --Bust conditions.
			UVBustEnemy(closestunit, enemy)
		end
		UVLosing = CurTime()
	else
		UVBusting = CurTime()
		enemy.UVBustingProgress = 0
		enemy.UVBustingLastProgress = CurTime()
		enemy.UVBustingLastProgress2 = enemy.UVBustingProgress
	end
	
	if enemy.UVBustingProgress ~= 0 then
		net.Start('UVHUDUpdateBusting')
		net.WriteEntity(enemy)
		net.WriteFloat(enemy.UVBustingProgress)
		net.Broadcast()
	end
	
	if UVCheckIfWrecked(enemy) or not enemy.uvbusted and enemy:WaterLevel() > 2 or IsValid(UVGetDriver(enemy)) and UVGetDriver(enemy):Health() <= 0 then --Bust conditions.
		UVBustEnemy(closestunit, enemy)
	end
	
	local enemyph = enemy:GetPhysicsObject()
	if not enemyph then return end
	
	local enemyAngles = enemyph:GetAngles()
	local enemyVelo = enemyph:GetVelocity()
	local enemyAnglesVelo = enemyph:GetAngleVelocity()
	
	--Stunt jump
	if not UVEnemyEscaping and UVTargeting then
		if not enemy.UVStuntJump then
			local onground = util.QuickTrace(enemy:WorldSpaceCenter(), -vector_up * 500, {enemy})
			
			if not onground.Hit then
				enemy.UVStuntJump = true
				timer.Simple(10, function()
					enemy.UVStuntJump = nil
				end)
				local randomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil and randomno == 1 then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if unit:GetTarget() == enemy then
						UVChatterStuntJump(unit)
					else
						UVChatterStuntJump(closestunit)
					end
				else
					UVChatterStuntJump(closestunit)
				end
			end
		end
		
		--Stunt roll
		if not enemy.UVStuntRoll then
			if enemyAngles.z > 90 and enemyAngles.z < 270 and enemyVelo:LengthSqr() < 10000 then
				enemy.UVStuntRoll = true
				timer.Simple(10, function()
					enemy.UVStuntRoll = nil
				end)
				local randomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil and randomno == 1 then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if unit:GetTarget() == enemy then
						UVChatterStuntRoll(unit)
					else
						UVChatterStuntRoll(closestunit)
					end
				else
					UVChatterStuntRoll(closestunit)
				end
			end
		end
		
		--Stunt roll
		if not enemy.UVStuntSpin then
			if enemyAnglesVelo.z > 180 then
				enemy.UVStuntSpin = true
				timer.Simple(10, function()
					enemy.UVStuntSpin = nil
				end)
				local randomno = math.random(1,2)
				local airUnits = ents.FindByClass("uvair")
				if next(airUnits) ~= nil and randomno == 1 then
					local random_entry = math.random(#airUnits)	
					local unit = airUnits[random_entry]
					if unit:GetTarget() == enemy then
						UVChatterStuntSpin(unit)
					else
						UVChatterStuntSpin(closestunit)
					end
				else
					UVChatterStuntSpin(closestunit)
				end
			end
		end
	end
	
end

function UVCheckIfWrecked(enemy)
	if not IsValid(enemy) then return end //or AutoHealth:GetBool()
	if enemy:IsFlagSet(FL_DISSOLVING) then return true end
	if enemy.IsScar then
		return enemy:IsDestroyed()
	elseif enemy.IsSimfphyscar then
		return enemy:GetCurHealth() <= 0 or enemy:OnFire() or enemy.destroyed or enemy:WaterLevel() > 2
	elseif enemy.IsGlideVehicle then
		return enemy:GetEngineHealth() <= 0 or enemy:GetIsEngineOnFire()
	elseif vcmod_main and isfunction(enemy.VC_GetHealth) then
		local health = enemy:VC_GetHealth(false)
		return (isnumber(health) and health <= 0) or enemy:WaterLevel() > 2
	elseif enemy:GetClass() == "prop_vehicle_jeep" then
		local health = enemy:Health()
		return health < 0 or enemy:WaterLevel() > 2 --Unless set, health is 0
	end
end

function UVCheckIfHiding()
	if next(UVWantedTableVehicle) == nil then return false end

	local hiding = false

	for k, enemy in pairs(UVWantedTableVehicle) do
		if enemy:GetVelocity():LengthSqr() < 10000 then
			if enemy.IsGlideVehicle then
				hiding = enemy:GetEngineState() == 0
			elseif enemy.IsSimfphyscar then
				hiding = enemy:EngineActive() == false
			else
				hiding = true
			end
		else
			hiding = false
		end
		if not hiding then break end
	end
	
	return hiding
end

function UVVisualOnTarget(unit, target)
	if not unit or not target then
		return
	end
	if unit.wrecked then return end
	local tr = util.TraceLine({start = unit:WorldSpaceCenter(), endpos = target:WorldSpaceCenter(), mask = MASK_OPAQUE, filter = {unit, target}}).Fraction==1
	return tobool(tr)
end

function UVGetDir(v1, v2)
	return (v2 - v1):GetNormalized()
end

function UVGetAng(A, B)
	return A:GetNormalized():Dot(B:GetNormalized())
end

function UVGetAng3(A, B, C)
	return UVGetAng(B - A, C - B)
end

function UVCheckIfRedlineSimfphys(vehicle) --angle fix thanks to the piece of shit who made it
	local category = UVGetVehicleMakeAndModel(vehicle, true)
	local categories = {
		["NFS Police Cars"] = true,
		["Redline Bonus Cars"] = true,
		["Redline Cars"] = true,
		["Redline NFS Ports"] = true,
		["Redline Police Cars"] = true,
		["Redline Service Vehicles"] = true
	}
	return categories[category]
end

function UVGetVehicleMakeAndModel(vehicle, category)
	if not IsValid(vehicle) then return end
	if vehicle.IsSimfphyscar then
		local c = vehicle:GetSpawn_List()
		if ( not list.Get( "simfphys_vehicles" )[ c ] ) then return "Vehicle" end
		local t = list.Get( "simfphys_vehicles" )[ c ]
		if category then
			local category = t.Category
			return category or ""
		else
			local name = t.Name
			return name or "Vehicle"
		end
	elseif vehicle.IsGlideVehicle then
		return vehicle.PrintName or "Vehicle"
	elseif vehicle:GetClass() == "prop_vehicle_jeep" then
		local c = vehicle:GetVehicleClass()
		if ( not list.Get( "Vehicles" )[ c ] ) then return "Vehicle" end
		local t = list.Get( "Vehicles" )[ c ]
		if category then
			local category = t.Category
			return category or ""
		else
			local name = t.Name
			return name or "Vehicle"
		end
	end
	return "Vehicle"
end

function UVDeployRoadblock(self)
	if not UVTargeting then return end
	local deployed = false
	
	if UVAutoLoadRoadblock() then
		deployed = true
		if Chatter:GetBool() and IsValid(self.v) then
			UVChatterRoadblockDeployed(self)
		end
	end
	return deployed
end

function UVPlayerIsWrecked(vehicle)
	if not vehicle then return end
	if vehicle:IsFlagSet(FL_DISSOLVING) then return true end
	if vehicle.IsScar then
		return vehicle:IsDestroyed()
	elseif vehicle.IsSimfphyscar then
		return vehicle:GetCurHealth() <= 0 or vehicle:OnFire() or vehicle.destroyed
	elseif vehicle.IsGlideVehicle then
		return vehicle:GetEngineHealth() <= 0 or vehicle:GetIsEngineOnFire()
	elseif isfunction(vehicle.VC_GetHealth) then
		local health = vehicle:VC_GetHealth(false)
		return isnumber(health) and health <= 0
	end
end

function UVPlayerWreck(vehicle)
	if IsValid(vehicle) and vehicle.wrecked then return end
	if table.HasValue(UVCommanders, vehicle) then
		UVCommanders = {}
	end
	if table.HasValue(UVPlayerUnitTableVehicle, vehicle) then
		table.RemoveByValue(UVPlayerUnitTableVehicle, vehicle)
	end
	if table.HasValue(UVUnitsChasing, vehicle) then
		table.RemoveByValue(UVUnitsChasing, vehicle)
	end
	vehicle.mass = math.Round(vehicle:GetPhysicsObject():GetMass())
	if not vehicle.playerbounty then
		vehicle.playerbounty = 500
	end
	if not timer.Exists("uvcombotime") then
		timer.Create("uvcombotime", 5, 1, function() 
			UVComboBounty = 1 
			timer.Remove("uvcombotime")
		end)
	else
		timer.Remove("uvcombotime")
		timer.Create("uvcombotime", 5, 1, function() 
			if next(ents.FindByClass("npc_uv*")) ~= nil and Chatter:GetBool() and UVComboBounty >= 3 then
				local units = ents.FindByClass("npc_uv*")
				local random_entry = math.random(#units)	
				local unit = units[random_entry]
				UVChatterMultipleUnitsDown(unit)
			end
			UVComboBounty = 1
			timer.Remove("uvcombotime")
		end)
	end

	vehicle.wrecked = true
	local despawntime = 60
	table.insert(UVWreckedVehicles, vehicle)
	local name = vehicle.callsign or UVGetDriver(vehicle):GetName() or "Player"
	local bountyplus = (vehicle.playerbounty)*(UVComboBounty)
	local bounty = string.Comma(bountyplus)
	if IsValid(vehicle.e) and isfunction(vehicle.e.GetDriver) and IsValid(UVGetDriver(vehicle.e)) and UVGetDriver(vehicle.e):IsPlayer() then 
		--UVGetDriver(vehicle.e):PrintMessage( HUD_PRINTCENTER, name.." ☠ Combo Bounty x"..UVComboBounty..": "..bounty)
		UVNotifyCenter({UVGetDriver(vehicle.e)}, "uv.hud.combo", "UNITS_DISABLED", '', name, bountyplus, UVComboBounty)
		
	end
	UVWrecks = UVWrecks + 1
	
	if not UVResourcePointsRefreshing and UVResourcePoints > 1 and not UVOneCommanderActive then
		UVResourcePoints = (UVResourcePoints - 1)
	end

	UVSetELS(false, vehicle)
	UVSetELSSound(false, vehicle)
	
	net.Start("UVHUDRemoveUV")
	net.WriteInt(vehicle:EntIndex(), 32)
	net.WriteInt(vehicle:GetCreationID(), 32)
	net.Broadcast()
	
	local driver = UVGetDriver(vehicle)
	if driver and driver:IsPlayer() then
		local bustedtable = {}
		net.Start( "UVHUDWreckedDebrief" )
		net.Send(driver)
		driver:KillSilent()
		driver:SetNoDraw(true)
		driver:Spectate(OBS_MODE_DEATHCAM)
		driver:SpectateEntity(driver)
	end
	if vehicle.IsGlideVehicle then
		local wreck = vehicle
		timer.Simple(despawntime, function()
			if IsValid(wreck) then
				SafeRemoveEntity(wreck)
			end
		end)
		wreck:SetEngineHealth(0)
		wreck:UpdateHealthOutputs()
		wreck.UnflipForce = 0
		wreck.AngularDrag = vector_origin
		if wreck:GetVelocity():LengthSqr() > 250000 then
			UVGlideDetachWheels(wreck)
		end
	elseif vehicle.IsSimfphyscar then
		local wreck = vehicle
		timer.Simple(despawntime, function()
			if IsValid(wreck) then
				SafeRemoveEntity(wreck)
			end
		end)
		if vehicle:GetVelocity():LengthSqr() > 250000 and WheelsDetaching:GetBool() then
			for i = 1, #wreck.Wheels do
				local wheelmathchance = math.random(1,2)
				local Wheel = wreck.Wheels[math.random(1, #wreck.Wheels)]
				if wheelmathchance == 1 then
					constraint.RemoveAll(Wheel)
				end
			end
		end
		wreck:SetActive(false)
		wreck:SetCurHealth(0)
		wreck:SetLightsEnabled(false)
		wreck.emson = false
		wreck:SetEMSEnabled( false )
	elseif vehicle:GetClass() == "prop_vehicle_jeep" then
		local wreck = vehicle
		wreck:EmitSound( "vehicles/v8/vehicle_rollover"..math.random(1,2)..".wav" )
		wreck:AddCallback("PhysicsCollide", function(ent, coldata)
			local ourOldVel = coldata.OurOldVelocity:Length()
			local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
			dot = math.abs(dot) / 2
			local dmg = ourOldVel * dot
			if dmg < 10 then return end
			local e = EffectData()
			e:SetOrigin(coldata.HitPos)
			util.Effect("cball_explode", e)
		end)
		if wreck:LookupAttachment("vehicle_engine") > 0 then
			ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, wreck, wreck:LookupAttachment("vehicle_engine"))
		end
		local e = EffectData()
		e:SetEntity(wreck)
		util.Effect("entity_remove", e)
		timer.Simple(despawntime, function()
			if IsValid(wreck) then
				wreck:Remove()
			end
		end)
	end
	if vehicle:IsVehicle() then
		UVBounty = UVBounty+bountyplus
	end
	UVComboBounty = UVComboBounty + 1
end

-- function UVGetDriver(vehicle)
-- 	if not IsValid(vehicle) then return false end

-- 	if vehicle.IsSimfphyscar or vehicle:GetClass() == "prop_vehicle_jeep" then
-- 		return vehicle:GetDriver()
-- 	elseif vehicle.IsGlideVehicle then
-- 		local seat = vehicle.seats[1]

-- 		if IsValid( seat ) then
--             return seat:GetDriver()
--         end
-- 	end

-- 	return false
-- end

function UVNavigateDVWaypoint(self, vectors)
	
	if UVEnemyEscaping then
		vectors = dvd.Waypoints[math.random(#dvd.Waypoints)].Target
	end
	
	local FromSelfToEnemy = dvd.GetRouteVector(self.v:GetPos(), vectors)
	local FromEnemyToSelf = dvd.GetRouteVector(vectors, self.v:GetPos())
	
	if not FromSelfToEnemy or not FromEnemyToSelf then
		self.NavigateBlind = true
		return --Unable to get route
	end
	
	if #FromEnemyToSelf >= #FromSelfToEnemy then --Get the shortest route
		for k, v in pairs(FromSelfToEnemy) do
			local targetVec = v["Target"]
			local found = false
			for _, existingVec in ipairs(self.tableroutetoenemy) do
				if existingVec == targetVec then
					found = true
					break
				end
			end
			if not found then
				table.insert(self.tableroutetoenemy, targetVec)
			end
		end
		return self.tableroutetoenemy
	else
		local FromEnemyToSelfReversed = table.Reverse(FromEnemyToSelf)
		for k, v in pairs(FromEnemyToSelfReversed) do
			local targetVec = v["Target"]
			local found = false
			for _, existingVec in ipairs(self.tableroutetoenemy) do
				if existingVec == targetVec then
					found = true
					break
				end
			end
			if not found then
				table.insert(self.tableroutetoenemy, targetVec)
			end
		end
		return self.tableroutetoenemy
	end
end

function UVNavigateNavmesh(self, vectors)
	-- THIS IS THE CAUSE OF THE FUCKING LAG PROBLEMS WHEN CAR TAKES OFF!!!
	--print("UVNavigateNavmesh")
	local CNavAreaFromSelfToEnemy = UVRequestVectorsnavmesh(self.v:WorldSpaceCenter(), vectors, self.v.width)
	--print(type(CNavAreaFromSelfToEnemy), (type(CNavAreaFromSelfToEnemy) == "table" and #CNavAreaFromSelfToEnemy))
	-- WHEN YOU ARE MID AIR, IT CAN TAKE TOO LONG TO GET THE ROUTE AND IT WILL LAG THE GAME!!! THEN IT RETURNS FALSE!!!
	-- KILL IT!!
	
	if istable(CNavAreaFromSelfToEnemy) then --Get the route
		local closestpoint = self.v:WorldSpaceCenter()
		for k, v in pairs(CNavAreaFromSelfToEnemy) do
			table.insert(self.tableroutetoenemy, v:GetClosestPointOnArea(closestpoint))
			closestpoint = v:GetCenter()
		end
		return self.tableroutetoenemy
	else
		self.NavigateBlind = true
		return --Unable to get route
	end
end

function UVGlideDetachWheels(vehicle)
	if not WheelsDetaching:GetBool() then return end
	timer.Simple(0, function()
		if not IsValid(vehicle) or not vehicle.wheels then return end
		
		for i = 1, #vehicle.wheels do
			local wheelmathchance = math.random(1,2)
			local wheel = vehicle.wheels[math.random(1, #vehicle.wheels)]
			
			if wheelmathchance == 1 then
				local wheelphys = vehicle:GetPhysicsObject() --Wheels don't have a physics object
				
				local wheelmodel = wheel:GetModel()
				local wheelpos = wheel:GetPos()
				local wheelang = wheel:GetAngles()
				local wheelcolor = wheel:GetColor()
				local wheelmat = wheel:GetMaterial()
				
				local wheelvelocity = wheelphys:GetVelocity()
				local wheelangvel = wheelphys:GetAngleVelocity()
				
				table.RemoveByValue(vehicle.wheels, wheel)
				wheel:Remove()
				
				local wreckedwheel = ents.Create("prop_physics")
				wreckedwheel:SetModel(wheelmodel)
				wreckedwheel:SetPos(wheelpos)
				wreckedwheel:SetAngles(wheelang)
				wreckedwheel:SetColor(wheelcolor)
				wreckedwheel:SetMaterial(wheelmat)
				wreckedwheel:SetVelocity(wheelvelocity)
				wreckedwheel:Spawn()
				
				local wreckedwheelphys = wreckedwheel:GetPhysicsObject()
				wreckedwheelphys:SetVelocity(wheelvelocity)
				wreckedwheelphys:SetAngleVelocity(wheelangvel)
				
				timer.Simple(60, function()
					if IsValid(wreckedwheel) then
						wreckedwheel:Remove()
					end
				end)
				
			else
				
				break
				
			end
			
		end
		
	end)
	
end

function UVCFEligibleToUse(NPC)
	local vehicle = NPC.v
	return (vehicle.RacerVehicle and UseNitrousRacer:GetBool()) or (vehicle.UnitVehicle and not vehicle.roadblocking and UseNitrousUnit:GetBool())
end

local function UVCFActivateNitrous(NPC, seconds)
	NPC.usenitrous = true 
	timer.Simple(seconds, function()
		NPC.usenitrous = false
	end)
end

function UVCFInitialize(NPC)
	NPC.usenitrous = false
	
	--NPCs will decide when to use nitrous based on the amount
	NPC.preferrednitroustable = {
		0.25,
		0.5,
		0.75,
		1
	}
	NPC.preferrednitrousamount = NPC.preferrednitroustable[ math.random( 1, #NPC.preferrednitroustable ) ]
	
	local car = NPC.v
	local index = NPC:EntIndex()

	if car.RacerVehicle then --Give racers some nice colors
		local r = math.random(0, 255)
		local g = math.random(0, 255)
		local b = math.random(0, 255)

		net.Start( "cfnitrouscolor" )
    	    net.WriteEntity(car)
    	    net.WriteInt(r, 9)
    	    net.WriteInt(g, 9)
    	    net.WriteInt(b, 9)
			net.WriteBool(car.NitrousBurst)
			net.WriteBool(car.NitrousEnabled)
    	net.Broadcast()
	end

	timer.Create( "UVCFNitrous" .. index, 1, 0, function()
		if not IsValid(NPC) or not IsValid(car) then
			timer.Remove( "UVCFNitrous" .. index )
			return
		end

		local amount = car:GetNWFloat( 'NitrousAmount' )
		if amount >= NPC.preferrednitrousamount and UVCFEligibleToUse(NPC) then
			local seconds = math.random(1,5)
			UVCFActivateNitrous(NPC, seconds)
		end

		local chance = math.random(1,60)
		if chance == 1 then
			NPC.preferrednitrousamount = NPC.preferrednitroustable[ math.random( 1, #NPC.preferrednitroustable ) ]
		end
	end)

end

net.Receive("UVToggleHeadlights", function(len, ply)
	local NPC = net.ReadEntity()
	local bool = net.ReadBool()

	if not NPC.v then return end
	
	if bool then
		if NPC.v.IsGlideVehicle then
            NPC.v:SetHeadlightState( 1 )
		elseif NPC.v.IsSimfphyscar and NPC.v:IsInitialized() then
			NPC.v:SetLightsEnabled(true)
        elseif vcmod_main and NPC.v:GetClass() == "prop_vehicle_jeep" then
            NPC.v:VC_setRunningLights( true )
        end
	else
		if NPC.v.IsGlideVehicle then
            NPC.v:SetHeadlightState( 0 )
		elseif NPC.v.IsSimfphyscar and NPC.v:IsInitialized() then
			NPC.v:SetLightsEnabled(false)
        elseif vcmod_main and NPC.v:GetClass() == "prop_vehicle_jeep" then
            NPC.v:VC_setRunningLights( false )
        end
	end
end)

-- net.Receive("RequestGlideVehicles", function(len, ply)
	-- if not ply:IsSuperAdmin() then return end
	-- if not GlideRequestCooldown or CurTime() - GlideRequestCooldown > 1 then
		-- GlideRequestCooldown = CurTime()
	-- else
		-- return
	-- end

	-- local glideVehicles = {}

	-- for className, scripted in pairs(scripted_ents.GetList() or {}) do
		-- if scripted.Base == "base_glide_car" and istable(scripted.t) and scripted.t.GlideCategory then
			-- local cat = scripted.t.GlideCategory or "Default"
			-- glideVehicles[cat] = glideVehicles[cat] or {}
			-- table.insert(glideVehicles[cat], {
				-- name  = scripted.t.PrintName or className,
				-- class = className -- Use key directly, guaranteed valid
			-- })
		-- end
	-- end

	-- local totalCategories = table.Count(glideVehicles)

	-- for category, vehicles in pairs(glideVehicles) do
		-- net.Start("GlideVehiclesTable")
		-- net.WriteTable({ [category] = vehicles })
		-- net.Send(ply)
	-- end
-- end)

net.Receive("RequestGlideVehicles", function(len, ply)
	if not ply:IsSuperAdmin() then return end

	-- Simple cooldown
	if not GlideRequestCooldown or CurTime() - GlideRequestCooldown > 1 then
		GlideRequestCooldown = CurTime()
	else
		return
	end

	local glideVehicles = {}

	-- Collect all Glide vehicles into categories
	for className, scripted in pairs(scripted_ents.GetList() or {}) do
		if scripted.Base == "base_glide_car" and istable(scripted.t) and scripted.t.GlideCategory then
			local cat = scripted.t.GlideCategory or "Default"
			glideVehicles[cat] = glideVehicles[cat] or {}
			table.insert(glideVehicles[cat], {
				name  = scripted.t.PrintName or className,
				class = className
			})
		end
	end

	-- Send the *entire* table in a single message
	net.Start("GlideVehiclesTable")
	net.WriteTable(glideVehicles)
	net.Send(ply)
end)