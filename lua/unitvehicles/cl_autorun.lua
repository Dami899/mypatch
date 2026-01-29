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
local ChatterText = GetConVar("unitvehicle_chattertext")
local Headlights = GetConVar("unitvehicle_enableheadlights")
local SpawnMainUnits = GetConVar("unitvehicle_spawnmainunits")
local RepairCooldown = GetConVar("unitvehicle_repaircooldown")
local RepairRange = GetConVar("unitvehicle_repairrange")
local RacerTags = GetConVar("unitvehicle_racertags")

--unit convars
local UVUHelicopterBusting = GetConVar("unitvehicle_unit_helicopterbusting")

local dvd = DecentVehicleDestination

-- Fuck GMod sometimes.
function UVString(key)
    if not isstring(key) then return "" end
    if key:StartWith("#") then
        key = key:sub(2)
    end
    return string.Trim(language.GetPhrase(key))
end

if not game.SinglePlayer() then return end

hook.Add("OnEntityCreated", "UVHeadlights", function(NPC)
	local uvclasses = {
		["npc_racervehicle"] = true,
		["npc_trafficvehicle"] = true,
		["npc_uvpatrol"] = true,
		["npc_uvsupport"] = true,
		["npc_uvpursuit"] = true,
		["npc_uvinterceptor"] = true,
		["npc_uvspecial"] = true,
		["npc_uvcommander"] = true,
	}

	if not uvclasses[NPC:GetClass()] then return end
	
	NPC.canuseheadlights = false
	timer.Create("UVHeadlights" .. NPC:EntIndex(), 1, 0, function()
		if not IsValid(NPC) then
			return
		end
		
		if Headlights:GetInt() == 0 then
			NPC.canuseheadlights = false
			return
		elseif Headlights:GetInt() == 2 then
			NPC.canuseheadlights = true
			return
		end

	    local c = render.ComputeLighting( NPC:GetPos(), Vector( 0, 0, 1 ) )
	    local avg = ( c[1] * 0.2126 ) + ( c[2] * 0.7152 ) + ( c[3] * 0.0722 ) -- Luminosity method
	    local shouldBeOn = Either( NPC.canuseheadlights, avg < 1.3, avg < 0.2 )

	    NPC.canuseheadlights = shouldBeOn

		net.Start( "UVToggleHeadlights" )
			net.WriteEntity( NPC )
			net.WriteBool( NPC.canuseheadlights )
		net.SendToServer()
	end)
end)

hook.Add( "EntityRemoved", "UVClearHeadlights", function( NPC, fullUpdate )
	if ( fullUpdate ) then return end

	if timer.Exists("UVHeadlights" .. NPC:EntIndex()) then
		timer.Remove("UVHeadlights" .. NPC:EntIndex())
	end

	if timer.Exists("UVAirSpotlight" .. NPC:EntIndex()) then
		timer.Remove("UVAirSpotlight" .. NPC:EntIndex())
	end
end )