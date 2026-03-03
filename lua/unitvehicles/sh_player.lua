AddCSLuaFile()

local dvd = DecentVehicleDestination

local temp_keybinds = {
    [KEY_T] = 1,
    [KEY_P] = 2,
}

local keybind_requests = {}

hook.Add( "PlayerButtonDown", "PlayerButtonDownHandler", function( ply, button )
    if CLIENT and not IsFirstTimePredicted() then
        return
    end
    
    if keybind_requests[ply] then
        local slot = keybind_requests[ply]
        keybind_requests[ply] = nil
        
        net.Start("UVGetNewKeybind")
        net.WriteInt(slot, 16)
        net.WriteInt(button, 16)
        net.Send(ply)
    end
end)

function UVIsVehicleInCone( source, target, radius, distance )
    local posSource = source:GetPos()
    local posTarget = target:GetPos()

    local dirSource = source:GetForward()

    local dirNormal = ( posTarget - posSource ):GetNormalized()
    local dot = dirSource:Dot( dirNormal )

    local checkAngle = math.cos( math.rad( radius / 2 ) )

    return dot >= checkAngle and posSource:DistToSqr( posTarget ) <= distance
end

function UVGetELS(vehicle)
	if not (IsValid(vehicle) and vehicle:IsVehicle()) then return end
	if vehicle.IsScar then
		return vehicle.SirenIsOn
	elseif vehicle.IsSimfphyscar then
		return vehicle:GetEMSEnabled()
	elseif Photon2
    and isfunction(vehicle.GetPhotonControllerFromAncestor) then
        local pc = vehicle:GetPhotonControllerFromAncestor()
        if IsValid(pc) then
            return pc:GetChannelMode("Emergency.Warning") ~= "OFF"
        end
	elseif Photon and not GetConVar("unitvehicle_vcmodelspriority"):GetBool()
	and isfunction(vehicle.ELS_Siren)
	and isfunction(vehicle.ELS_Lights) then
		return vehicle:ELS_Siren() and vehicle:ELS_Lights()
	elseif vcmod_main and vcmod_els
	and isfunction(vehicle.VC_getELSLightsOn) then
		return vehicle:VC_getELSLightsOn()
	end
end

function UVGetELSSound(vehicle)
	if not (IsValid(vehicle) and vehicle:IsVehicle()) then return end
	if vehicle.IsScar then
		return vehicle.SirenIsOn
	elseif vehicle.IsSimfphyscar then
		return vehicle.ems and vehicle.ems:IsPlaying()
	elseif Photon2
    and isfunction(vehicle.GetPhotonControllerFromAncestor) then
        local pc = vehicle:GetPhotonControllerFromAncestor()
        if IsValid(pc) then
            return pc:GetChannelMode("Emergency.Siren") ~= "OFF"
        end
	elseif Photon and not GetConVar("unitvehicle_vcmodelspriority"):GetBool()
	and isfunction(vehicle.ELS_Siren) then
		return vehicle:ELS_Siren()
	elseif vcmod_main and vcmod_els
	and isfunction(vehicle.VC_getELSSoundOn)
	and isfunction(vehicle.VC_getStates) then
		local states = vehicle:VC_getStates()
		return vehicle:VC_getELSSoundOn() or istable(states) and states.ELS_ManualOn
	end
end

function UVSetELS(on, vehicle)
    if not IsValid(vehicle) then return end
	if on == UVGetELS(vehicle) or vehicle.DontHaveEMS then return end
	if vehicle.IsGlideVehicle then
		if not vehicle.CanSwitchSiren then return end
		if on then
			vehicle:SetSirenState(2)
		else
			vehicle:SetSirenState(0)
		end
	elseif vehicle.IsScar then
		if vehicle.SirenIsOn == nil then return end
		if not vehicle.SirenSound then return end
		vehicle.SirenIsOn = on
		vehicle:SetNWBool("SirenIsOn", on)
		if on then
			vehicle.SirenSound:Play()
		else
			vehicle.SirenSound:Stop()	
		end
	elseif vehicle.IsSimfphyscar then
		local v_list = list.Get( "simfphys_lights" )[vehicle.LightsTable]
		if not v_list then vehicle.DontHaveEMS = true return end
		local sounds = v_list.ems_sounds or false
		if sounds == false then vehicle.DontHaveEMS = true return end

		table.remove(sounds)
		
		local numsounds = table.Count( sounds )
		local sirenNum
		
		if on then
			vehicle.emson = true
			vehicle:SetEMSEnabled( vehicle.emson )
		else
			vehicle.emson = false
			vehicle:SetEMSEnabled( false )
			if vehicle.ems then
				if on and not vehicle.ems:IsPlaying() and not vehicle.honking then
					vehicle.ems:Play()
				elseif not on and vehicle.ems:IsPlaying() or vehicle.honking then
					vehicle.ems:Stop()
				end
			end
		end
		sirenNum = math.random( 1, numsounds )
		
		if sirenNum ~= 0 and not vehicle.honking then
			vehicle.ems = CreateSound(vehicle, sounds[sirenNum])
			vehicle.ems:Play()
		end
	elseif Photon2
    and isfunction(vehicle.GetPhotonControllerFromAncestor) then
        local pc = vehicle:GetPhotonControllerFromAncestor()
        if IsValid(pc) then
			local sirendata = GetPhoton2Siren(vehicle)
			local randomsiren = "T"..math.random(1, #sirendata.OrderedTones)
            pc:SetChannelMode("Emergency.Warning", on and "MODE3" or "OFF")
            pc:SetChannelMode("Emergency.Siren", on and randomsiren or "OFF")
        end
	elseif Photon and not GetConVar("unitvehicle_vcmodelspriority"):GetBool()
	and isfunction(vehicle.ELS_SirenOn)
	and isfunction(vehicle.ELS_SirenOff)
	and isfunction(vehicle.ELS_LightsOff) then
		if on then
			vehicle:ELS_SirenOn()
		else
			vehicle:ELS_SirenOff()
			vehicle:ELS_LightsOff()
		end
	elseif vcmod_main and vcmod_els
	and isfunction(vehicle.VC_setELSLights)
	and isfunction(vehicle.VC_setELSSound) then
		vehicle:VC_setELSLights(on)
		vehicle:VC_setELSSound(on)
	end
end

function UVSetELSSound(on, vehicle)
    if not IsValid(vehicle) then return end
	if on == UVGetELSSound(vehicle) or vehicle.DontHaveEMS then return end
	if vehicle.IsGlideVehicle then
		if not vehicle.CanSwitchSiren then return end
		if on then
			vehicle:SetSirenState(2)
		else
			vehicle:SetSirenState(0)
		end
	elseif vehicle.IsScar then
		if not vehicle.SirenSound then return end
		if on then
			vehicle.SirenSound:Play()
		else
			vehicle.SirenSound:Stop()
		end
	elseif vehicle.IsSimfphyscar then
		if vehicle.ems then
			if on and not vehicle.ems:IsPlaying() and not vehicle.honking then
				vehicle.ems:Play()
			elseif not on and vehicle.ems:IsPlaying() or vehicle.honking then
				vehicle.ems:Stop()
			end
		end
	elseif Photon2
    and isfunction(vehicle.GetPhotonControllerFromAncestor) then
        local pc = vehicle:GetPhotonControllerFromAncestor()
        if IsValid(pc) then
			local sirendata = GetPhoton2Siren(vehicle)
			local randomsiren = "T"..math.random(1, #sirendata.OrderedTones)
            pc:SetChannelMode("Emergency.Siren", on and randomsiren or "OFF")
        end
	elseif Photon and not GetConVar("unitvehicle_vcmodelspriority"):GetBool()
	and isfunction(vehicle.ELS_SirenOn)
	and isfunction(vehicle.ELS_SirenOff)
	and isfunction(vehicle.ELS_LightsOff) 
	and isfunction(vehicle.ELS_SirenToggle) then --test
		if on then
			vehicle:ELS_SirenOn()
			vehicle:ELS_SirenToggle()
		else
			vehicle:ELS_SirenOff()
		end

		vehicle:ELS_LightsOff()
	elseif vcmod_main and vcmod_els
	and isfunction(vehicle.VC_setELSSound) then
		vehicle:VC_setELSSound(on)
	end
end

if SERVER then
    function UVNotifyCenter( ply_array, frmt, icon_name, ... )
        for _, v in pairs( ply_array ) do
            
            net.Start('UVUnitTakedown')

            net.WriteString( select( 1, ... ) ) -- Unit Type
            net.WriteString( select( 2, ... ) ) -- Name
            net.WriteUInt( select( 3, ... ), 32 ) -- Bounty
            net.WriteUInt( select( 4, ... ), 7 ) -- Combo
            net.WriteBool( select( 5, ... ) ) -- Player
            
            net.Send( v )
            
        end
    end

    function UVGetHeadlight(vehicle)
        if vehicle.IsGlideVehicle then
            return vehicle:GetHeadlightState()
        elseif vcmod_main and vehicle:GetClass() == "prop_vehicle_jeep" then
            return 0 -- TODO: Implement VC_getRunningLights()
        end
    end

    function UVSetHeadlight(vehicle, state)
        if vehicle.IsGlideVehicle then
            vehicle:SetHeadlightState( state )
        elseif vcmod_main and vehicle:GetClass() == "prop_vehicle_jeep" then
            vehicle:VC_setRunningLights( state >= 1 )
        end
    end

    function UVDamage(vehicle, damage) --damage in fraction of max health (0.1 = 10% of max health)
        if not IsValid(vehicle) then return end

        if vehicle.UVWanted and GetConVar("unitvehicle_autohealth"):GetBool() then return end

        if vehicle.IsSimfphyscar then

            local MaxHealth = vehicle:GetMaxHealth()
            local damage = MaxHealth*damage
            vehicle:ApplyDamage( damage, DMG_GENERIC )

        elseif vehicle.IsGlideVehicle then

            vehicle:SetEngineHealth( vehicle:GetEngineHealth() - damage )
            vehicle:UpdateHealthOutputs()
            
        elseif vehicle:GetClass() == "prop_vehicle_jeep" then
            if VC then
                local damage = Vehicle:VC_getHealthMax()*damage
                Vehicle:VC_damageHealth(damage)
                return 
            end

            local NPC = vehicle.UnitVehicle and vehicle.UnitVehicle:IsNPC()
            if not NPC then return end
		    
            local damage = NPC:GetMaxHealth()*damage
		    target:SetHealth(target:Health()-damage)
        end
    end

    function UVRepair(vehicle, forcerepair)
		local cooldown = 5
		local cooldown2 = RepairCooldown:GetInt()
		
		vehicle.uvrepairdelayed = true
		timer.Simple(cooldown, function()
			if IsValid(vehicle) then
				vehicle.uvrepairdelayed = false
			end
		end)
		
		local function UVRepairCooldown()
			local cooldowntimeleft = cooldown2 - (CurTime() - vehicle.uvrepaircooldown)
			if UVGetDriver(vehicle) then
				if UVGetDriver(vehicle):IsPlayer() then
					net.Start("UVHUDRepairCooldown")
					net.WriteInt(cooldowntimeleft, 32)
					net.Send(UVGetDriver(vehicle))
				end
			end
			return
		end
		
		if vehicle.uvrepaircooldown and not forcerepair then
			UVRepairCooldown()
			return
		end
		
		local ptrefilled = false
		
		if vehicle.PursuitTech then
			for k, v in pairs(vehicle.PursuitTech) do
				-- local max_ammo = GetConVar('unitvehicle_'..((vehicle.UnitVehicle and 'unitpursuittech') or 'pursuittech')..'_maxammo_'..string.lower(string.gsub(v.Tech, " ", ""))):GetInt()
				local techShort = string.lower(string.gsub(v.Tech, " ", ""))
				local max_ammo = GetConVar("uvpursuittech_" .. techShort .. "_maxammo" .. (vehicle.UnitVehicle and "_unit" or "")):GetInt()
				if v.Ammo < max_ammo then
					ptrefilled = true
					v.Ammo = max_ammo
				end
			end
		end
		
		if ptrefilled then
			for i=1, 2 do
				UVReplicatePT( vehicle, i )
			end
		end
	
		local repairnet = "UVHUDRepair"
		local comcanrep = GetConVar("unitvehicle_unit_commanderrepair"):GetBool()
		local canrepair = true
	
		if comcanrep then
			if table.HasValue(UVCommanders, vehicle) then
				if UVGetDriver(vehicle) and UVGetDriver(vehicle):IsPlayer() then
					repairnet = "UVHUDRepairCommander"
					canrepair = false
				end
			end
		end
	
		if canrepair then
			if vehicle:GetClass() == "prop_vehicle_jeep" then
				if vcmod_main then
					if not ptrefilled and vehicle:VC_getHealthMax() == vehicle:VC_getHealth() then return end
				
					vehicle:VC_repairFull_Admin()
				else
					if not ptrefilled and vehicle:GetMaxHealth() == vehicle:Health() then return end
				
					local mass = vehicle:GetPhysicsObject():GetMass()
					vehicle:SetMaxHealth((AutoHealth:GetBool() and vehicle.UVWanted and math.huge) or (mass))
					vehicle:SetHealth((AutoHealth:GetBool() and vehicle.UVWanted and math.huge) or (mass))
					vehicle:StopParticles()
				end
			end
			if vehicle.IsSimfphyscar then	
				local repaired_tires = false 
				
				if istable(vehicle.Wheels) then
					for i = 1, table.Count( vehicle.Wheels ) do
						local Wheel = vehicle.Wheels[ i ]
						if IsValid(Wheel) and Wheel:GetDamaged() then
							repaired_tires = true
							Wheel:SetDamaged( false )
						end
					end
				end
				
				if not ptrefilled and not repaired_tires and vehicle:GetCurHealth() == vehicle:GetMaxHealth() then return end
				
				--vehicle.simfphysoldhealth = vehicle:GetMaxHealth()
				vehicle:SetCurHealth((AutoHealth:GetBool() and vehicle.UVWanted and math.huge) or (vehicle.simfphysoldhealth or vehicle:GetMaxHealth()))
				vehicle:SetOnFire( false )
				vehicle:SetOnSmoke( false )
				
				net.Start( "simfphys_lightsfixall" )
				net.WriteEntity( vehicle )
				net.Broadcast()
				
				net.Start( "uvrepairsimfphys" )
				net.WriteEntity( vehicle )
				net.Broadcast()
				
				vehicle:OnRepaired()
			
			end
			if vehicle.IsGlideVehicle then
				local repaired = false
				
				for _, v in pairs(vehicle.wheels) do
					if IsValid(v) and v.bursted then
						repaired = true
						v.bursted = false
					    v:Repair()
					    timer.Remove("uvspiked"..v:EntIndex())
					end
				end
				
				if not ptrefilled and not repaired and vehicle:GetChassisHealth() >= vehicle.MaxChassisHealth then return end
				vehicle:Repair()

                if AutoHealth:GetBool() and vehicle.UVWanted then
                    vehicle:SetChassisHealth(math.huge)
				    vehicle:SetEngineHealth(math.huge)
                    vehicle:UpdateHealthOutputs()
                end
				
				if cffunctions then
					CFRefillNitrous(vehicle)
				end
			end
		end
	
		if UVGetDriver(vehicle) then
			if UVGetDriver(vehicle):IsPlayer() then
				if UVGetDriver(vehicle):GetMaxHealth() == 100 then
					UVGetDriver(vehicle):SetHealth(vehicle:GetPhysicsObject():GetMass())
					UVGetDriver(vehicle):SetMaxHealth(vehicle:GetPhysicsObject():GetMass())
				end
				net.Start(repairnet)
				net.Send(UVGetDriver(vehicle))
				if ptrefilled then
					net.Start("UVHUDRefilledPT")
					net.Send(UVGetDriver(vehicle))
				end
			end
		end
		
		vehicle.uvrepaircooldown = CurTime()
		if cooldown2 > 0 then
			timer.Simple(cooldown2, function()
				if IsValid(vehicle) then
					vehicle.uvrepaircooldown = nil
					if UVGetDriver(vehicle) then
						if UVGetDriver(vehicle):IsPlayer() then
							net.Start("UVHUDRepairAvailable")
							net.Send(UVGetDriver(vehicle))
						end
					end
				end
			end)
		end
	end

    function UVGetRaceLeader()
        if not UVRaceTable or not UVRaceTable['Participants'] then return end

        local Participants = UVRaceTable['Participants']
        local TotalCheckpoints = GetGlobalInt("uvrace_checkpoints", 0)
        local LeadersCurrentCheckpoint = 0
        local Time = math.huge
        local Leaders = {}
        local Leader

        --Look for any racer(s) with most checkpoints passed
        for entity, racer in pairs(Participants) do
            local CheckpointsPassed = #racer['Checkpoints'] + (TotalCheckpoints * (racer['Lap'] - 1))

            if CheckpointsPassed > LeadersCurrentCheckpoint then
                LeadersCurrentCheckpoint = CheckpointsPassed
            end
        end

        --If there are at least 2 racers who did the above, look for the one with the least amount of time
        for entity, racer in pairs(Participants) do
            local CheckpointsPassed = #racer['Checkpoints'] + (TotalCheckpoints * (racer['Lap'] - 1))

            if CheckpointsPassed == LeadersCurrentCheckpoint then
                table.insert( Leaders, racer )
            end
        end

        for entity, racer in pairs(Leaders) do
            local CurrentTime = next(racer['Checkpoints']) ~= nil and racer['Checkpoints'][#racer['Checkpoints']] or racer['LastLapCurTime'] or racer['Position']
            if CurrentTime < Time then
                Time = racer['Checkpoints'][#racer['Checkpoints']] or racer['Position']
                Leader = racer.Vehicle
            end
        end

        return IsValid(Leader) and Leader
    end

    function UVOptimizeRespawn( vehicle, rhino, commander, suspectwaypoint )
        if UVOptimizeRespawnDelayed and not suspectwaypoint then return end

        UVOptimizeRespawnDelayed = true
        timer.Simple(1, function()
            UVOptimizeRespawnDelayed = nil
        end)

        local NPC = vehicle.UnitVehicle
        if not NPC then return end

        local vehicle_class = vehicle:GetClass()
        
        if vehicle_class == "gmod_sent_vehicle_fphysics_base" then
            SafeRemoveEntity(NPC) --yeahhh
            return
        end

        NPC.uvmarkedfordeletion = nil
        timer.Simple(1, function()
            NPC.uvmarkedfordeletion = true
        end)
        
        local phys = vehicle:GetPhysicsObject()
        phys:SetVelocity(vector_origin)
        
        local uvnextclasstospawn
	    local enemylocation
	    local suspect
	    local suspectvelocity = Vector(0,0,0)
        local uvspawnpoint
        local uvspawnpointwaypoint
        local uvspawnpointangles
        
	    if next(dvd.Waypoints) == nil then
	    	PrintMessage( HUD_PRINTTALK, "There's no Decent Vehicle waypoints to spawn vehicles! Download Decent Vehicle (if you haven't) and place some waypoints!")
	    	return
	    end
    
	    if next(UVWantedTableVehicle) ~= nil then
	    	local suspects = UVWantedTableVehicle
	    	local random_entry = math.random(#suspects)
	    	suspect = UVGetRaceLeader() or suspects[random_entry]
        
	    	enemylocation = (suspect:GetPos() + Vector(0, 0, 50))
	    	suspectvelocity = suspect:GetVelocity()
	    elseif not playercontrolled then
	    	enemylocation = dvd.Waypoints[math.random(#dvd.Waypoints)]["Target"] + Vector(0, 0, 50)
	    else
	    	enemylocation = ply:GetPos() + Vector(0, 0, 50)
	    end
    
	    local enemywaypoint = dvd.GetNearestWaypoint(enemylocation)
	    local enemywaypointgroup = enemywaypoint["Group"]
	    local waypointtable = {}
	    local prioritywaypointtable = {}
	    local prioritywaypointtable2 = {}
	    local prioritywaypointtable3 = {}
	    for k, v in ipairs(dvd.Waypoints) do
	    	local Waypoint = v["Target"]
	    	local distance = enemylocation - Waypoint
	    	local vect = distance:GetNormalized()
	    	local evectdot = vect:Dot(suspectvelocity)
	    	if distance:LengthSqr() > 25000000 then
	    		if enemywaypointgroup == v["Group"] then
	    			if UVStraightToWaypoint(enemylocation, Waypoint) then
	    				if evectdot < 0 then
	    					table.insert(prioritywaypointtable, v)
	    				elseif distance:LengthSqr() < 25000000 then
	    					table.insert(prioritywaypointtable2, v)
	    				end
	    			elseif distance:LengthSqr() < 100000000 then
	    				table.insert(prioritywaypointtable3, v)
	    			end
	    		elseif distance:LengthSqr() < 100000000 then
	    			table.insert(waypointtable, v)
	    		end
	    	end
	    end

	    if next(prioritywaypointtable) ~= nil then
	    	uvspawnpointwaypoint = prioritywaypointtable[math.random(#prioritywaypointtable)]
	    	uvspawnpoint = uvspawnpointwaypoint["Target"]
	    elseif next(prioritywaypointtable2) ~= nil then
	    	uvspawnpointwaypoint = prioritywaypointtable2[math.random(#prioritywaypointtable2)]
	    	uvspawnpoint = uvspawnpointwaypoint["Target"]
	    elseif next(prioritywaypointtable3) ~= nil then
	    	uvspawnpointwaypoint = prioritywaypointtable3[math.random(#prioritywaypointtable3)]
	    	uvspawnpoint = uvspawnpointwaypoint["Target"]
	    elseif next(waypointtable) ~= nil then
	    	uvspawnpointwaypoint = waypointtable[math.random(#waypointtable)]
	    	uvspawnpoint = uvspawnpointwaypoint["Target"]
	    else
	    	uvspawnpointwaypoint = dvd.Waypoints[math.random(#dvd.Waypoints)]
	    	uvspawnpoint = uvspawnpointwaypoint["Target"]
	    end

        if suspectwaypoint then
            uvspawnpointwaypoint = suspectwaypoint
            uvspawnpoint = uvspawnpointwaypoint["Target"]
        end

	    local neighbor = dvd.Waypoints[uvspawnpointwaypoint.Neighbors[math.random(#uvspawnpointwaypoint.Neighbors)]]

	    if neighbor then
	    	local neighborpoint = neighbor["Target"]
	    	local neighbordistance = neighborpoint - uvspawnpoint
	    	uvspawnpointangles = neighbordistance:Angle()+Angle(0,180,0)
	    else
	    	uvspawnpointangles = Angle(0,math.random(0,360),0)
	    end
    
	    if UVTargeting then
	    	if not rhino then
	    		local mathangle = math.random(1,2)
	    		if mathangle == 2 then
	    			uvspawnpointangles = uvspawnpointangles+Angle(0,180,0)
	    		end
	    	else
	    		uvspawnpointangles = suspectvelocity:Angle() + Angle(0,180,0)
	    	end
	    end

        if vehicle.IsGlideVehicle then
            local pos = uvspawnpoint+(vector_up * 50)
		    local ang = uvspawnpointangles

            if not commander then
                UVRepair(vehicle, true)
            end

            vehicle:SetPos( pos )
            vehicle:SetAngles( ang )
            vehicle:PhysWake()
        else
            local physObj = vehicle:GetPhysicsObject()
            physObj:EnableMotion(false)

            local pos = uvspawnpoint+(vector_up * 50)
		    local ang = uvspawnpointangles
            
            ang.yaw = ang.yaw - 90
            
            vehicle:SetPos( pos )
            vehicle:SetAngles( ang )
            vehicle:SetVelocity(Vector(0,0,0))

            if not commander then
                UVRepair(vehicle, true)
            end
            
            timer.Simple(.5, function()
                physObj:EnableMotion(true)
                physObj:Wake()
            end)
        end

        if NPC.metwithenemy and not UVResourcePointsRefreshing and UVResourcePoints > 1 and not UVOneCommanderActive and not vehicle.roadblocking then
			UVResourcePoints = (UVResourcePoints - 1)
		end

        if vehicle.roadblocking then
            vehicle.roadblocking = nil
        end

        NPC.metwithenemy = nil
        NPC.rhinohit = nil
    end
    
    function UVResetPosition( vehicle )
        -- Check if vehicle is a race participant
       -- if not table.HasValue( UVRaceCurrentParticipants, vehicle ) then return end
       -- if not UVRaceInProgress then return end
        
        -- local entry = UVRaceTable.Participants [vehicle]
        -- if not entry then return end
        
        if vehicle.hasreset then return end
        
        local vehicle_class = vehicle:GetClass()
        
        local checkpoint = nil
        local next_checkpoint = nil
        local pos = nil
        local dir = nil
        local ang = angle_zero
        
        -- Get last passed checkpoint
        if not UVRaceInProgress or not table.HasValue( UVRaceCurrentParticipants, vehicle ) then
            if not dvd then return end
            local waypoint = dvd.GetNearestWaypoint( vehicle:GetPos() )

            pos = waypoint.Target + ( vector_up * 20 )
            ang = waypoint.Neighbors[1] and ( dvd.Waypoints[waypoint.Neighbors[1]].Target - waypoint.Target ):GetNormalized():Angle() or Angle(0)
        else
            local entry = UVRaceTable.Participants [vehicle]
            if not entry then return end

            local look_up_needle = # entry.Checkpoints

            for _, v in pairs(ents.FindByClass("uvrace_checkpoint")) do
                local id = v:GetID()
                
                if id == look_up_needle then
                    checkpoint = v
                elseif id == look_up_needle +1 then
                    next_checkpoint = v
                end
            end

            if not checkpoint then return end

            pos = checkpoint:GetPos() + checkpoint:OBBCenter()
            
            if next_checkpoint then
                local next_pos = next_checkpoint:GetPos() + next_checkpoint:OBBCenter()
                ang = (next_pos - pos):GetNormalized():Angle()
            end
        end
                
        -- Teleport to the checkpoint
        local ground_trace = util.TraceLine({start = pos, endpos = pos +- ((checkpoint and checkpoint:GetUp() or vector_origin) * 1000), mask = MASK_NPCWORLDSTATIC, filter = {checkpoint}})
        
        local next_pos = nil
        local next_dir = nil
        local delay = 0.1
                
        if vehicle_class == "gmod_sent_vehicle_fphysics_base" then
            vehicle = UVTeleportSimfphysVehicle( vehicle, (ground_trace.Hit and ground_trace.HitPos) or pos, ang )
            delay = 0.9
        elseif vehicle.IsGlideVehicle then
            vehicle:SetPos( (ground_trace.Hit and (ground_trace.HitPos + (Vector(0,0,1) * 25))) or pos )
            vehicle:SetAngles( ang )
            vehicle:PhysWake()
        else
            local physObj = vehicle:GetPhysicsObject()
            physObj:EnableMotion(false)
            
            ang.yaw = ang.yaw - 90
            
            vehicle:SetPos( (ground_trace.Hit and (ground_trace.HitPos + (Vector(0,0,1) * 50))) or pos )
            vehicle:SetAngles( ang )
            vehicle:SetVelocity(Vector(0,0,0))
            
            timer.Simple(.5, function()
                physObj:EnableMotion(true)
                physObj:Wake()
            end)
        end
        
        vehicle.hasreset = CurTime()
        timer.Simple(10, function()
            vehicle.hasreset = nil
        end)

        --Prevent abuse during pursuits by teleporting a Unit ahead
        timer.Simple(delay, function()
            if UVTargeting then
                local units = ents.FindByClass("npc_uv*")
                if #units == 0 then return end
                local unit = units[math.random(1, #units)]

                if IsValid(unit) then
                    local enemywaypoint = dvd.GetNearestWaypoint( vehicle:GetPos() )
                    if not enemywaypoint.Neighbors or next(enemywaypoint.Neighbors) == nil then return end
                    local neighbor = dvd.Waypoints[enemywaypoint.Neighbors[math.random(#enemywaypoint.Neighbors)]]

                    if neighbor and unit.v then
                        UVOptimizeRespawn( unit.v, unit.v.rhino, unit.v.uvclasstospawnon == "npc_uvcommander", neighbor )
                    end
                end
            end
        end)
    end
    
    net.Receive("UVResetPosition", function(len, ply)
        local car = UVGetVehicle( ply )
        
        if car then
            if car.UnitVehicle then
                ply:ConCommand( "uv_spawn_as_unit" )
                return
            end
            
           -- if not table.HasValue( UVRaceCurrentParticipants, car ) then return end
           -- if not UVRaceInProgress then return end
            
            local key = "VehicleReset_"..car:EntIndex()
            if timer.Exists( key ) then return end
            
            if car.hasreset then
                net.Start("uvrace_resetfailed")
                net.WriteString("uv.race.resetcooldown")
                net.Send(ply)
                return
            end
            
            if car:GetVelocity():LengthSqr() > 5000 then
                net.Start("uvrace_resetfailed")
                net.WriteString("uv.race.resetstationary")
                net.Send(ply)
                return
            end
            
            if car.UVHUDBusting then
                timer.Remove(key)
                net.Start("uvrace_resetfailed")
                net.WriteString("uv.race.resetbusting")
                net.Send(ply)
                return
            end
            
            net.Start( "uvrace_resetcountdown" )
            net.WriteInt(2, 4)
            net.Send(ply)
            
            timer.Create( key, 1, 2, function()
                local remaining_reps = timer.RepsLeft( key )
                
                if not IsValid(car) or car:GetDriver() ~= ply then
                    timer.Remove(key)
                end
                
                if car:GetVelocity():LengthSqr() > 5000 then
                    net.Start("uvrace_resetfailed")
                    net.WriteString("uv.race.resetstationary")
                    net.Send(ply)
                    return
                end
                
                if car.UVHUDBusting then
                    timer.Remove(key)
                    net.Start("uvrace_resetfailed")
                    net.WriteString("uv.race.resetbusting")
                    net.Send(ply)
                    return
                end
                
                if remaining_reps > 0 then
                    net.Start( "uvrace_resetcountdown" )
                    net.WriteInt(remaining_reps, 4)
                    net.Send(ply)
                else
                    if IsValid(car) and car:GetDriver() == ply then
                        UVResetPosition(car)
                    end
                end
            end)
            --UVResetPosition(car)
        end
    end)
    
    net.Receive( "UVPTKeybindRequest", function( len, ply )
        local slot = net.ReadInt( 16 )
        
        if not slot then return end
        keybind_requests[ply] = slot
    end)
    
    net.Receive( "UVPTUse", function( len, ply )
        local slot = net.ReadInt( 16 )
        
        if table.HasValue(UVPlayerUnitTablePlayers, ply) then --UNIT VEHICLES
            for k, car in pairs(UVPlayerUnitTableVehicle) do
                if UVGetDriver(car) == ply and not car.wrecked then
                    UVDeployWeapon( car, slot ) 
                end
            end
        elseif next(UVRVWithPursuitTech) ~= nil then --RACER VEHICLES
            for k, car in pairs(UVRVWithPursuitTech) do
                if UVGetDriver(car) == ply and not car.wrecked and not car.uvbusted then
                    UVDeployWeapon( car, slot ) 
                end
            end
        end
        
    end)

    function UVIsPTUpgraded(car)
        return car.uvclasstospawnon == "npc_uvspecial" or car.uvclasstospawnon == "npc_uvcommander"
    end

	function UVReplicatePT(car, slot)
		-- If the car or slot is invalid, stop
		if not IsValid(car) then return end

		-- If the entire PursuitTech table is gone, tell clients to clear everything
		if not car.PursuitTech then
			net.Start("UV_SendPursuitTech")
				net.WriteEntity(car)
				net.WriteUInt(slot or 0, 2)  -- slot is still sent but unused on clear
				net.WriteBool(false)          -- false = not active
			net.Broadcast()
			return
		end

		local ptSlot = car.PursuitTech[slot]

		if ptSlot and ptSlot.Tech then
			net.Start("UV_SendPursuitTech")
				net.WriteEntity(car)
				net.WriteUInt(slot, 2)
				net.WriteBool(true)
				net.WriteString(ptSlot.Tech)
				net.WriteUInt(ptSlot.Ammo or 0, 8)
				net.WriteUInt(ptSlot.Cooldown or 0, 16)
				net.WriteFloat(ptSlot.LastUsed or 0)
			net.Broadcast()
		else
			-- Clear this slot on clients
			net.Start("UV_SendPursuitTech")
				net.WriteEntity(car)
				net.WriteUInt(slot, 2)
				net.WriteBool(false)
			net.Broadcast()
		end
	end

    --[[
        EXPECTED DATA:
        - EventType (STRING)
            1 = Message
            2 = Event
        - Args (ARRAY)
    ]]
    function UVPTEvent( players, pt, eventType, args )
        local playersType = type( players )

        if playersType == 'table' then
            if #players < 1 then return end
        end

        net.Start( 'UVPTEvent' )
        --net.WriteUInt( eventType, 15 )
        net.WriteString( pt )
        net.WriteString( eventType )

        if args then
            local message = ( type( args ) == 'table' and util.TableToJSON( args ) ) or args
            local compressedMessage = util.Compress( message )
            local dataSize = #compressedMessage

            net.WriteBool( true )
            net.WriteUInt( dataSize, 16 )
            net.WriteData( compressedMessage, dataSize )
        else
            net.WriteBool( false )
        end

        if playersType == 'string' and string.lower( players ) == 'all' then
            net.Broadcast()
        else
            net.Send( table.ClearKeys( players ) )
        end
    end

    function ReportPTEvent( user, target, pt, event, args )
        if not IsValid( user ) then return end
        local attacker = UVGetDriver(user)
		local attackerName = UVGetDriverName(user)

        local victimNames = nil
        local playerTargets = {}

        if type( target ) == 'table' then
            victimNames = {}

            for _, v in pairs( target ) do
                local victim = UVGetDriver( v )
                local victimName = UVGetDriverName( v )

                if victim then
                    table.insert( playerTargets, victim )
                end

                table.insert( victimNames, victimName )
            end

        elseif isentity( target ) then
            local _target = UVGetDriver( target ) or nil

            if _target then
                table.insert( playerTargets, _target )
            end

            victimNames = UVGetDriverName( target )
        end

        if not attacker then attacker = nil end

        local message = {
            User = attackerName,
            Target = victimNames,
        }

        if args then
            for i, v in pairs( args ) do
                message[i] = v
            end
        end

        UVPTEvent( {attacker, unpack( playerTargets )}, pt, event, message )
    end
    
    function UVDeployWeapon(car, slot)
        if UVJammerDeployed and not car.jammerexempt then return end
        if not car.PursuitTech then return end
        
        if car.uvraceparticipant then
            if UVRaceInEffect and not UVRaceInProgress then return end
        end
        
        local pursuit_tech = car.PursuitTech[slot]
        if not pursuit_tech then return end
        
        if pursuit_tech.Ammo <= 0 then return end
        
        local driver = car:GetDriver()

        local used = false
        
        if pursuit_tech.Tech == "Shockwave" then --SHOCKWAVE
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            if IsValid(driver) then
                UVPTEvent({driver}, 'Shockwave', 'Use', {['Test'] = 'Hello world!'})
            end
            
            UVDeployShockwave(car)
            
            used = true
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
        elseif pursuit_tech.Tech == "ESF" then --ESF
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            car:RemoveCallOnRemove("uvesf"..car:EntIndex())
            
            UVDeployESF(car)
            
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            used = true

            -- if IsValid(driver) then
            --     driver:PrintMessage( HUD_PRINTCENTER, "ESF deployed!")
            -- end
            if IsValid(driver) then
                UVPTEvent({driver}, 'ESF', 'Use')
            end
            
            car:EmitSound("gadgets/esf/start.wav")
            car:EmitSound("gadgets/esf/onloop.wav")
            
            timer.Simple(UVPTESFDuration:GetInt(), function()
                UVDeactivateESF(car)
            end)
            
            car:CallOnRemove("uvesf"..car:EntIndex(), function()
                UVDeactivateESF(car)
            end)
        elseif pursuit_tech.Tech == "Stunmine" then --MINE
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            UVDeployStunmine(car)
            
            if IsValid(driver) then
                UVPTEvent({driver}, 'StunMine', 'Use')
            end
            
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            used = true

        elseif pursuit_tech.Tech == "Jammer" then --JAMMER
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            UVDeployJammer(car)
            
            if IsValid(driver) then
                UVPTEvent('all', 'Jammer', 'Use', {['User'] = UVGetDriverName(car)})
            end
            
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            used = true

        elseif pursuit_tech.Tech == "Spikestrip" then --SPIKESTRIP
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end

            if car.UnitVehicle then
                UVChatterSpikeStripDeployed(car)
            end

            UVDeploySpikeStrip(car, not car.UnitVehicle)

            timer.Simple( .5, function()
                if IsValid(car) and (not UVJammerDeployed or car.exemptfromjammer) then
                    if (car.UnitVehicle and UVIsPTUpgraded(car)) or (car.RacerVehicle) then
                        UVDeploySpikeStrip(car, not car.UnitVehicle)
                    end
                end
            end)
            
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            used = true

            if IsValid(driver) then
                UVPTEvent({driver}, 'Spikestrip', 'Use')
            end
        elseif pursuit_tech.Tech == 'Repair Kit' then
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end

            if car.UnitVehicle then
                UVChatterRepairKitDeployed(car)
            end
            
            local repaired = UVDeployRepairKit(car)

            if repaired then
                pursuit_tech.LastUsed = CurTime()
                pursuit_tech.Ammo = pursuit_tech.Ammo - 1
                used = true

                if IsValid(driver) then
                    UVPTEvent({driver}, 'RepairKit', 'Use')
                end
            end
        elseif pursuit_tech.Tech == 'Killswitch' then
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            local result = UVDeployKillSwitch(car)
            
            if result then
                used = true
                pursuit_tech.LastUsed = CurTime()
                pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            end
        elseif pursuit_tech.Tech == 'Power Play' then
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            local result = UVPowerPlay(car)
            
            if result then
                used = true
                pursuit_tech.LastUsed = CurTime()
                pursuit_tech.Ammo = pursuit_tech.Ammo - 1

                if IsValid(driver) then
                    UVPTEvent({driver}, 'PowerPlay', 'Use')
                end
            end
        elseif pursuit_tech.Tech == 'EMP' then
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            local result = UVDeployEMP(car)
            
            if result then
                used = true
                pursuit_tech.LastUsed = CurTime()
                pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            end
        elseif pursuit_tech.Tech == "Shock Ram" then
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            if IsValid(driver) then
                UVPTEvent({driver}, 'ShockRam', 'Use', {['Test'] = 'Hello world!'})
            end
            
            UVDeployShockRam(car)
            
            used = true
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
        elseif pursuit_tech.Tech == "GPS Dart" then
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            
            if IsValid(driver) then
                UVPTEvent({driver}, 'GPSDart', 'Use', {['Test'] = 'Hello world!'})
            end
            
            UVDeployGPSDart(car)

            timer.Simple( .5, function()
                if IsValid(car) and UVIsPTUpgraded(car) and (not UVJammerDeployed or car.exemptfromjammer) then
                    UVDeployGPSDart(car)
                end
            end)
            
            used = true
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
        elseif pursuit_tech.Tech == "Juggernaut" then --Juggernaut
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            car:RemoveCallOnRemove("uvjuggernaut"..car:EntIndex())
            
            UVDeployJuggernaut(car)
            
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            used = true

            if IsValid(driver) then
                UVPTEvent({driver}, 'Juggernaut', 'Use')
            end
            
            car:EmitSound("gadgets/juggernaut/juggernauton.wav")
            car:EmitSound("gadgets/juggernaut/idle.wav")
            
            timer.Simple(UVPTJuggernautDuration:GetInt(), function()
                UVDeactivateJuggernaut(car)
            end)
            
            car:CallOnRemove("uvjuggernaut"..car:EntIndex(), function()
                UVDeactivateJuggernaut(car)
            end)
        elseif pursuit_tech.Tech == "Ghost" then --Ghost
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            car:RemoveCallOnRemove("uvghost"..car:EntIndex())
            
            UVDeployGhost(car)
            
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            used = true

            if IsValid(driver) then
                UVPTEvent({driver}, 'Ghost', 'Use')
            end
            
            timer.Simple(UVPTGhostDuration:GetInt(), function()
                UVDeactivateGhost(car)
            end)
            
            car:CallOnRemove("uvghost"..car:EntIndex(), function()
                UVDeactivateGhost(car)
            end)
        elseif pursuit_tech.Tech == "Grappler" then --Grappler
            local Cooldown = pursuit_tech.Cooldown
            if CurTime() - pursuit_tech.LastUsed < Cooldown then return end
            car:RemoveCallOnRemove("uvgrappler"..car:EntIndex())
            
            UVDeployGrappler(car)
            
            pursuit_tech.LastUsed = CurTime()
            pursuit_tech.Ammo = pursuit_tech.Ammo - 1
            used = true

            if IsValid(driver) then
                UVPTEvent({driver}, 'Grappler', 'Use')
            end
            
            timer.Simple(UVUnitPTGrapplerDuration:GetInt(), function()
                UVDeactivateGrappler(car)
            end)
            
            car:CallOnRemove("uvgrappler"..car:EntIndex(), function()
                UVDeactivateGrappler(car)
            end)
        end

        if used then
            UVReplicatePT( car, slot )
        end

        return used
    end
    
    --SPIKESTRIP
    function UVDeploySpikeStrip(unit, racer)
        local spikes = ents.Create("entity_uvspikestrip")
        spikes.uvdeployed = true
        local timecheck
        if racer then
            timecheck = UVPTSpikeStripDuration:GetInt()
            spikes.racerdeployed = unit
        else
            timecheck = UVUnitPTSpikeStripDuration:GetInt()
            spikes.unitdeployed = unit
        end
        local ph = unit:GetPhysicsObject()
        local pos = unit:GetPos()
        if unit.IsGlideVehicle then
            pos = pos + (unit:GetForward() * -unit:BoundingRadius())
        end
        spikes:SetPos(pos)
        if unit:GetClass() == "prop_vehicle_jeep" then
            spikes:SetAngles(ph:GetAngles())
        else
            spikes:SetAngles(ph:GetAngles()+Angle(0,90,0))
        end
        spikes:Spawn()
        spikes.PhysgunDisabled = false
        local phspikes = spikes:GetPhysicsObject()
        phspikes:EnableMotion(true)
        phspikes:SetVelocity(ph:GetVelocity())
        timer.Simple(timecheck, function() 
            if IsValid(spikes) then 
                if UVTargeting and not racer then
                    UVSpikestripsDodged = UVSpikestripsDodged + 1
                end
                spikes:Remove()
            end
        end)
    end

    -- EMP
    function UVDeployEMP(car)
        if car.empTarget then return false end
        
        local vehiclePool = {}
        local isUnit = car.UnitVehicle
        local carCreationID = car:GetCreationID()
        local carEntityIndex = car:EntIndex()
        local carPos = car:WorldSpaceCenter()
        local carDriver = UVGetDriver( car )
        local hookIdentifier = "UVEMP_"..carEntityIndex

        local useCooldown = 5

        local target, targetDriver, targetCreationID, targetEntityIndex = nil

        if isUnit or RacerFriendlyFire:GetBool() then table.Add( vehiclePool, UVPotentialSuspects ) end
        if not isUnit then table.Add( vehiclePool, UVUnitVehicles ) end

        local shortestTargetDistance = math.huge
        local maxDistance = math.pow( ( isUnit and UVUnitPTEMPMaxDistance:GetInt() ) or UVPTEMPMaxDistance:GetInt(), 2 )

        for _, v in pairs( vehiclePool ) do
            local vehicleDistance = v:WorldSpaceCenter():DistToSqr(carPos)
            if UVIsVehicleInCone( car, v, 90, maxDistance ) and vehicleDistance < shortestTargetDistance and not v.LockedOnBy and not v.wrecked then
                target = v
                shortestTargetDistance = vehicleDistance
                break
            end
        end

        local lastUse = car.lastEMPUse or 0

        if not target then
            if CurTime() - lastUse >= useCooldown then 
                car.lastEMPUse = CurTime()

                UVPTEvent(
                    {carDriver}, 
                    'EMP', 
                    'NoTarget'
                )
            end

            return false
        end

        targetDriver = UVGetDriver( target )
        targetCreationID = target:GetCreationID()
        targetEntityIndex = target:EntIndex()

        car.empTarget = target
        car.startLock = CurTime()

        target.LockedOnBy = car

        car:EmitSound("gadgets/emp/lockfromloop.wav")
        target:EmitSound("gadgets/emp/lockonloop.wav")

        local function cleanup()
            car.empTarget = nil
            car.startLock = nil
            car.empCleanup = nil
            target.LockedOnBy = nil

            hook.Remove( "Think", hookIdentifier )
        end

        local function globalCleanup()
            cleanup()
            UVPTEvent( 
                {
                    carDriver,
                    targetDriver
                }, 
                'EMP', 
                'Missed'
            )
        end

        car.empCleanup = globalCleanup

        hook.Add( "Think", hookIdentifier, function()
            if not IsValid( car ) or not IsValid( target ) then return cleanup() end
            if UVJammerDeployed and not car.jammerexempt then 
                cleanup()

                UVPTEvent( 
                    {
                        carDriver,
                        targetDriver
                    }, 
                    'EMP', 
                    'Missed'
                )

                if car.UnitVehicle then
                    UVChatterEMPMissed(car)
                end

                car:StopSound("gadgets/emp/lockfromloop.wav")
                target:StopSound("gadgets/emp/lockonloop.wav")
                target:EmitSound("gadgets/emp/miss.wav")
                
                return false
            end

            if CurTime() - car.startLock >= 5 then
                cleanup()

                if not UVIsVehicleInCone( car, target, 90, maxDistance ) then 
                    UVPTEvent( 
                        {
                            carDriver,
                            targetDriver
                        }, 
                        'EMP', 
                        'Missed'
                    )

                    if car.UnitVehicle then
                        UVChatterEMPMissed(car)
                    end

                    car:StopSound("gadgets/emp/lockfromloop.wav")
                    target:StopSound("gadgets/emp/lockonloop.wav")
                    target:EmitSound("gadgets/emp/miss.wav")

                    return false
                end

                local effData = EffectData()
                effData:SetEntity(target)
                util.Effect( "entity_remove", effData )

                local damage = ( isUnit and UVUnitPTEMPDamage:GetFloat() ) or UVPTEMPDamage:GetFloat()
                damage = (table.HasValue(UVCommanders, target) and UVPTEMPCommanderDamage:GetFloat()) or damage
                
                local force = ( isUnit and UVUnitPTEMPForce:GetInt() ) or UVPTEMPForce:GetInt()
                local lastHeadlightState = UVGetHeadlight( target )

				if UVIsPTUpgraded(car) then
					damage = damage * 2
					force = force * 2
				end
                
                UVDamage( 
                    target, 
                    damage
                )

                hook.Add( "Think", hookIdentifier .. "headlight", function() 
                    UVSetHeadlight( 
                        target, 
                        math.random( 0, 2 ) 
                    ) 
                end)

                timer.Simple( 1, function()
                    hook.Remove( "Think", hookIdentifier .. "headlight" )
                    UVSetHeadlight( 
                        target, 
                        lastHeadlightState 
                    )
                end)

                local targetPhysObj = target:GetPhysicsObject()
                local targetForward = target:GetForward()
                local targetRight = target:GetRight()

                local targetPos = target:WorldSpaceCenter()

                targetPhysObj:ApplyForceOffset( 
                    ( math.Rand( -1, 1 ) * targetRight ) * ( targetPhysObj:GetMass() * force ), -- ( force / 100 )
                    targetPos - ( targetForward * 100 )
                )

                --

                UVPTEvent( 
                    {
                        carDriver,
                        targetDriver
                    }, 
                    'EMP', 
                    'Hit',
                    {
                        {carEntityIndex, carCreationID, UVGetDriverName( car )},
                        {targetEntityIndex, targetCreationID, UVGetDriverName( target )}
                    }
                )

                car:StopSound("gadgets/emp/lockfromloop.wav")
                target:StopSound("gadgets/emp/lockonloop.wav")

                if car.UnitVehicle then
                    UVChatterEMPHit(car)
                end
            end
        end )

        car:CallOnRemove("UVEMP_"..carEntityIndex, function() cleanup() end)

        UVPTEvent( 
            {
                carDriver, 
                targetDriver
            }, 
            'EMP', 
            'Locking',
            {
                {carEntityIndex, carCreationID, UVGetDriverName( car )},
                {targetEntityIndex, targetCreationID, UVGetDriverName( target )}
            }
        )

        if car.UnitVehicle then
            UVChatterEMPDeployed(car)
        end

        return true
    end
    
    --REPAIR KIT
    function UVDeployRepairKit(car)
        local is_repaired = false
        
        if car:GetClass() == "prop_vehicle_jeep" then
            if vcmod_main then
                if car:VC_getHealthMax() == car:VC_getHealth() then return end
                is_repaired = true
                car:EmitSound('ui/pursuit/repair.wav')
                car:VC_repairFull_Admin()
            else
                local mass = vehicle:GetPhysicsObject():GetMass()
                vehicle:SetMaxHealth(mass)
                vehicle:SetHealth(mass)
                vehicle:StopParticles()
            end
        end
        if car.IsSimfphyscar then
            local repaired_tires = false 
            
            if istable(car.Wheels) then
                for i = 1, table.Count( car.Wheels ) do
                    local Wheel = car.Wheels[ i ]
                    if IsValid(Wheel) and Wheel:GetDamaged() then
                        repaired_tires = true
                        Wheel:SetDamaged( false )
                    end
                end
            end
            
            if not repaired_tires and car:GetCurHealth() == car:GetMaxHealth() then return end
            
            is_repaired = true
            car:EmitSound('ui/pursuit/repair.wav')
            
            -- TODO: There is some bug when AI is using a simfphys car, GetMaxHealth for some reason returns -inf...
            if IsValid(car:GetDriver()) then
                car.simfphysoldhealth = car:GetMaxHealth()
                car:SetCurHealth(car:GetMaxHealth())
            end
            
            car:SetOnFire( false )
            car:SetOnSmoke( false )
            
            net.Start( "simfphys_lightsfixall" )
            net.WriteEntity( car )
            net.Broadcast()
            
            net.Start( "uvrepairsimfphys" )
            net.WriteEntity( car )
            net.Broadcast()
            
            car:OnRepaired()
        end
        if car.IsGlideVehicle then
            local repaired = false
            
            for _, v in pairs(car.wheels) do
                if IsValid(v) and v.bursted then
                    repaired = true
                    v.bursted = false
					v:Repair()
					timer.Remove("uvspiked"..v:EntIndex())
                end
            end

            if not repaired and car:GetChassisHealth() >= car.MaxChassisHealth then return end
            is_repaired = true
            car:EmitSound('ui/pursuit/repair.wav')
            car:Repair()
        end
        
        local driver = UVGetDriver(car)
        
        if driver then
            if driver:IsPlayer() then
                if driver:GetMaxHealth() == 100 then
                    driver:SetHealth(car:GetPhysicsObject():GetMass())
                    driver:SetMaxHealth(car:GetPhysicsObject():GetMass())
                end
            end
        end
        
        return is_repaired
    end
    
    --STUNMINE
    function UVDeployStunmine(unit)
        local mine = ents.Create("entity_uvstunmine")
        mine.uvdeployed = true
        mine.racerdeployed = unit
        mine.deployedby = UVGetDriverName(unit)
        local ph = unit:GetPhysicsObject()
        mine:SetPos(unit:WorldSpaceCenter())
        mine:SetAngles(ph:GetAngles())
        mine:Spawn()
        mine.PhysgunDisabled = false
        local phmine = mine:GetPhysicsObject()
        phmine:EnableMotion(true)
        phmine:SetVelocity(Vector(0,0,0))
        timer.Simple(60, function() 
            if IsValid(mine) then 
                mine:Remove()
            end
        end)
    end
    
    --ESF
    function UVDeployESF(car)
        local driver = UVGetDriver(car)

        car.esfon = true
        local e = EffectData()
        e:SetEntity(car)
        util.Effect("entity_remove", e)
        net.Start("UVWeaponESFEnable")
        net.WriteEntity(car)
        net.Broadcast()

        if car.UnitVehicle then
            UVChatterESFDeployed(car)
        end
    end
    
    function UVDeactivateESF(car)
        if not car.esfon then return end

        if IsValid(car) then
            car.esfon = nil

            net.Start("UVWeaponESFDisable")
            net.WriteEntity(car)
            net.Broadcast()

            car:StopSound("gadgets/esf/onloop.wav")

            local e = EffectData()
            e:SetEntity(car)
            util.Effect("entity_remove", e)
            car:EmitSound("gadgets/esf/off.wav")

            if not car.uvesfhit and car.uvesfdeployed and car.esfon then
                -- if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
                --     UVGetDriver(car):PrintMessage( HUD_PRINTCENTER, "ESF deactivated!")
                -- end
                UVPTEvent( {UVGetDriver(car)}, 'ESF', 'Deactivate' )
            end

            car.uvesfhit = nil
            
            if car.UnitVehicle then
                UVChatterESFMissed(car)
            end
        end
    end
    
    function UVDeployKillSwitch(car)
        if next(UVWantedTableVehicle) ~= nil then
            car.uvkillswitchingtarget = nil
            
            local suspects = UVWantedTableVehicle
            local r = math.huge
            local closestdistancetosuspect, closestsuspect = r^2
            for i, w in pairs(suspects) do
                local carPos = car:WorldSpaceCenter()
                local distance = carPos:DistToSqr(w:WorldSpaceCenter())
                if distance < closestdistancetosuspect then
                    closestdistancetosuspect, closestsuspect = distance, w
                end
            end
            
            if closestdistancetosuspect < 250000 then
                car.uvkillswitchingtarget = closestsuspect
                car.uvkillswitching = true
                local MathSound = math.random(1,2)
                car:EmitSound("gadgets/killswitch/start"..MathSound..".wav")
                closestsuspect:EmitSound("gadgets/killswitch/startloop.wav")
				
                ReportPTEvent( car, closestsuspect, 'Killswitch', 'Locking' )
                timer.Simple(UVUnitPTKillSwitchLockOnTime:GetInt(), function() --HIT
                    if IsValid(car) and IsValid(car.uvkillswitchingtarget) then
                        if car.uvkillswitching and not car.uvkillswitchingtarget.enginedisabledbyuv then
                            car.uvkillswitching = nil
                            local kstime = UVUnitPTKillSwitchDisableDuration:GetInt()
                            local enemyVehicle = car.uvkillswitchingtarget
                            local enemyCallsign = enemyVehicle.racer or "Racer "..enemyVehicle:EntIndex()
                            local enemyDriver = UVGetDriver(enemyVehicle)

                            if UVIsPTUpgraded(car) then
				            	kstime = kstime * 2
				            end
                            
                            if enemyDriver and enemyDriver:IsPlayer() then
                                enemyCallsign = enemyDriver:GetName()
                            end
                            if enemyVehicle.IsSimfphyscar then
                                enemyVehicle:SetActive(false)
                            elseif enemyVehicle.IsGlideVehicle then
                                enemyVehicle:TurnOff()
                            elseif enemyVehicle:GetClass() == "prop_vehicle_jeep" then
                                enemyVehicle:StartEngine(false)
                            end
                            -- if isfunction(enemyVehicle.GetDriver) and IsValid(UVGetDriver(enemyVehicle)) and UVGetDriver(enemyVehicle):IsPlayer() then 
                            --     UVGetDriver(enemyVehicle):PrintMessage( HUD_PRINTCENTER, "YOU HAVE BEEN KILLSWITCHED!")
                            -- end
                            -- if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
                            --     UVGetDriver(car):PrintMessage( HUD_PRINTCENTER, "KILLSWITCHED "..enemyCallsign.."!")
                            -- end
                            ReportPTEvent( car, closestsuspect, 'Killswitch', 'Hit' )
                            enemyVehicle.enginedisabledbyuv = true
                            car:StopSound("gadgets/killswitch/start1.wav")
                            car:StopSound("gadgets/killswitch/start2.wav")
                            enemyVehicle:StopSound("gadgets/killswitch/startloop.wav")
                            enemyVehicle:EmitSound("gadgets/killswitch/hit.wav")
                            timer.Simple(kstime, function() 
                                if IsValid(enemyVehicle) then
                                    if enemyVehicle.IsSimfphyscar then
                                        enemyVehicle:SetActive(true)
                                        enemyVehicle:StartEngine()
                                    elseif enemyVehicle.IsGlideVehicle then
                                        enemyVehicle:TurnOn()
                                    elseif enemyVehicle:GetClass() == "prop_vehicle_jeep" then
                                        enemyVehicle:StartEngine(true)
                                    end
                                    -- if isfunction(enemyVehicle.GetDriver) and IsValid(UVGetDriver(enemyVehicle)) and UVGetDriver(enemyVehicle):IsPlayer() then 
                                    --     UVGetDriver(enemyVehicle):PrintMessage( HUD_PRINTCENTER, "Engine restarted!")
                                    -- end
                                    UVPTEvent( {UVGetDriver( enemyVehicle )}, 'Killswitch', 'EngineRestarting' )
                                    enemyVehicle.enginedisabledbyuv = nil
                                end
                            end)
                            car.PursuitTechStatus = "Reloading"
                            timer.Simple(UVUnitPTDuration:GetInt(), function()
                                if IsValid(car) and car.uvkillswitchdeployed and not car.wrecked then
                                    car.uvkillswitchdeployed = nil
                                    car:EmitSound("buttons/button4.wav")
                                    car.PursuitTechStatus = "Ready"
                                end
                            end)
                            car.uvkillswitchingtarget = nil
                            if car.UnitVehicle then
                                UVChatterKillswitchHit(car.UnitVehicle)
                            end
                        end
                    end
                end)
                return true
            else
                car.uvkillswitchdeployed = nil
                car.uvkillswitchingtarget = nil
                if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
					if not car.uvNextTooFarTime or car.uvNextTooFarTime < CurTime() then
						UVPTEvent({UVGetDriver(car)}, 'Killswitch', 'TooFar')
						car.uvNextTooFarTime = CurTime() + 3
					end
                end
                
                return false
            end
            
        else
            car.uvkillswitchdeployed = nil
            car.uvkillswitchingtarget = nil
            if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
				if not car.uvNextNoTargetTime or car.uvNextNoTargetTime < CurTime() then
					UVPTEvent({UVGetDriver(car)}, 'Killswitch', 'NoTarget')
					car.uvNextNoTargetTime = CurTime() + 3
				end
            end
            
            return false
        end
    end
    
    function UVKillSwitchCheck(car)
        local enemy = car.uvkillswitchingtarget
        local AI = car.UnitVehicle
        
        if not IsValid(enemy) or (UVJammerDeployed and not car.exemptfromjammer) then
            UVDeactivateKillSwitch(car)
            return
        end
        
        local carPos = car:WorldSpaceCenter()
        local distance = carPos:DistToSqr(enemy:WorldSpaceCenter())
        
        if distance > 250000 then
            UVDeactivateKillSwitch(car)
        end
    end
    
    function UVDeactivateKillSwitch(car)
        if not car.uvkillswitching then return end

        car.uvkillswitching = nil
        local enemyVehicle = car.uvkillswitchingtarget
        if IsValid(enemyVehicle) then
            enemyVehicle:StopSound("gadgets/killswitch/startloop.wav")
            enemyVehicle:EmitSound("gadgets/killswitch/miss.wav")
            -- if isfunction(enemyVehicle.GetDriver) and IsValid(UVGetDriver(enemyVehicle)) and UVGetDriver(enemyVehicle):IsPlayer() then 
            --     UVGetDriver(enemyVehicle):PrintMessage( HUD_PRINTCENTER, "Killswitch countered!")
            -- end
        end

        car:StopSound("gadgets/killswitch/start1.wav")
        car:StopSound("gadgets/killswitch/start2.wav")

        -- if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
        --     UVGetDriver(car):PrintMessage( HUD_PRINTCENTER, "Killswitch missed!")
        -- end

        ReportPTEvent( car, enemyVehicle, 'Killswitch', 'Counter' )

        -- car.PursuitTechStatus = "Reloading"
        -- timer.Simple(UVUnitPTDuration:GetInt(), function()
        --     if IsValid(car) and car.uvkillswitchdeployed and not car.wrecked then
        --         car.uvkillswitchdeployed = nil
        --         car:EmitSound("buttons/button4.wav")
        --         car.PursuitTechStatus = "Ready"
        --     end
        -- end)

        -- car.uvkillswitchingtarget = nil
        if car.UnitVehicle then
            UVChatterKillswitchMissed(car.UnitVehicle)
        end

    end
    
    --SHOCKWAVE
    function UVDeployShockwave(car)
        local carchildren = car:GetChildren()
        local carconstraints = constraint.GetAllConstrainedEntities(car)
        local carPos = car:WorldSpaceCenter()
        local objects = ents.FindInSphere(carPos, 1000)

        local affectedTargets = {}

        for k, object in pairs(objects) do
            if not object.UnitVehicle and not car.UnitVehicle and not RacerFriendlyFire:GetBool() then
			elseif object ~= car and (not table.HasValue(carchildren, object) and not table.HasValue(carconstraints, object) and IsValid(object:GetPhysicsObject()) or object.UnitVehicle or object.UVWanted or object:GetClass() == "entity_uv*" or object.uvdeployed) then

                local objectphys = object:GetPhysicsObject()
                local vectorDifference = object:WorldSpaceCenter() - carPos

                local angle = vectorDifference:Angle()
                local power = UVPTShockwavePower:GetFloat()
                local damage = UVPTShockwaveDamage:GetFloat()
                local force = power * (1 - (vectorDifference:Length()/1000))

                objectphys:ApplyForceCenter(angle:Forward()*force)
                UVRamVehicle(object)
                
                local attachVictim = false
                --if object.UnitVehicle then
                    damage = (table.HasValue(UVCommanders, object) and UVPTShockwaveCommanderDamage:GetFloat()) or damage
                    local phmass = math.Round(objectphys:GetMass())
                    UVBounty = UVBounty+phmass
                    UVDamage(object, damage)
                    attachVictim = true

                if attachVictim and object:IsVehicle() then
                    table.insert( affectedTargets, object )
                end
            end
        end

        local MathSound = math.random(1,4)
        car:EmitSound( "gadgets/shockwave/"..MathSound..".wav" )

        local effect = EffectData()
        effect:SetEntity(car)
        util.Effect("entity_remove", effect)
        util.ScreenShake( carPos, 5, 5, 1, 1000 )

        if #affectedTargets > 0 then
            ReportPTEvent( car, affectedTargets, 'Shockwave', 'Hit' )
        end
    end

    --JAMMER
    function UVDeployJammer(car)
        if UVJammerDeployed then return end
        
        UVJammerDeployed = true
        car.jammerdeployed = true
        car.jammerexempt = true
        
        if UVBackupUnderway and not UVBackupTenSeconds and UVResourcePointsTimerMax then
            UVResourcePointsTimerMax = UVResourcePointsTimerMax + 10
        end

        local isUnit = car.UnitVehicle
        
        net.Start("UVWeaponJammerEnable")
        if (UVGetDriver(car) and UVGetDriver(car):IsPlayer()) then
            net.WriteEntity(UVGetDriver(car))
        end
        net.Broadcast()
        
        car:EmitSound( "gadgets/jammer/loop2.wav" )
        
        car:CallOnRemove("UVJammerRemove", function()
            UVEndJammer(car)
        end)
        
        timer.Simple(UVPTJammerDuration:GetInt(), function()
            if IsValid(car) then
                UVEndJammer(car)
                car:RemoveCallOnRemove("UVJammerRemove")
            end
        end)
        
        for k, unit in pairs(ents.FindByClass("npc_uv*")) do
            if unit.v then
                UVDeactivateESF(unit.v)
                UVDeactivateKillSwitch(unit.v)
                UVDeactivateGrappler(unit.v)
                constraint.RemoveConstraints( unit.v, "Rope" )
                if car.empCleanup then 
                    car.empCleanup()
                end
            end
        end
        
        for k, unitplayers in pairs(UVPlayerUnitTableVehicle) do
            if IsValid(unitplayers) then
                UVDeactivateESF(UVPlayerUnitTableVehicle)
                UVDeactivateKillSwitch(UVPlayerUnitTableVehicle)
                UVDeactivateGrappler(UVPlayerUnitTableVehicle)
                constraint.RemoveConstraints( UVPlayerUnitTableVehicle, "Rope" )
                if car.empCleanup then 
                    car.empCleanup() 
                end
            end
        end
        
        UVSoundChatter(car, 1, "", 3)
        
    end
    
    function UVEndJammer(car)
        UVJammerDeployed = nil
        car.jammerexempt = nil
        net.Start("UVWeaponJammerDisable")
        if IsValid(UVGetDriver(car)) then
            net.WriteEntity(UVGetDriver(car))
        end
        net.Broadcast()
        car:StopSound( "gadgets/jammer/loop2.wav" )
        car:EmitSound( "gadgets/jammer/deactivate1.wav" )
        
        if UVTargeting then
            UVSoundChatter(car, 1, "dispatchjammerend", 8)
        end
    end

    --POWER PLAY
    function UVPowerPlay(car)
        local pos = car:WorldSpaceCenter()

        local function WreckClosestUnit(car)
            local closest_unit
            local shortest_distanceunit = math.huge
            
            for _, ent in ents.Iterator() do
                if IsValid(ent) then
                    if ent.UnitVehicle then
                        local distunit = pos:Distance(ent:GetPos())
                    
                        if distunit < shortest_distanceunit then
                            shortest_distanceunit = distunit
                            closest_unit = ent
                        end
                    end
                end
            end

            if IsValid(closest_unit) then
                if closest_unit.UnitVehicle then
                    if closest_unit.UnitVehicle:IsNPC() then
                        closest_unit.UnitVehicle:Wreck()
                    else
                        UVPlayerWreck(closest_unit)
                    end
                    return closest_unit
                end
            else
                if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
		            if not car.uvNextNoPBTime or car.uvNextNoPBTime < CurTime() then
		            	UVPTEvent({UVGetDriver(car)}, 'PowerPlay', 'NoPB')
		            	car.uvNextNoPBTime = CurTime() + 3
		            end
                end

                return false
            end
        end

        if next(UVLoadedPursuitBreakers) == nil then --No PB
            return WreckClosestUnit(car)
        end

        local closest_ent
        local shortest_distance = math.huge
        local maximum_distance = 75000000

        for _, ent in ents.Iterator() do
            if IsValid(ent) then
                if ent.PursuitBreaker then
                    local dist = pos:DistToSqr(ent:GetPos())

                    if dist < shortest_distance and dist <= maximum_distance then
                        shortest_distance = dist
                        closest_ent = ent
                    end
                end
            end
        end
        
        if IsValid(closest_ent) then
            return UVTriggerPursuitBreaker(closest_ent, car)
        -- else --It can happen :3
        --     return WreckClosestUnit(car)
        else
            if isfunction(car.GetDriver) and IsValid(UVGetDriver(car)) and UVGetDriver(car):IsPlayer() then 
                if not car.uvNextNoPBTime or car.uvNextNoPBTime < CurTime() then
                    UVPTEvent({UVGetDriver(car)}, 'PowerPlay', 'NoPB')
                    car.uvNextNoPBTime = CurTime() + 3
                end
            end

            return false
        end
    end

    --SHOCK RAM
    function UVDeployShockRam(car)
        local carchildren = car:GetChildren()
        local carconstraints = constraint.GetAllConstrainedEntities(car)
        local carPos = car:WorldSpaceCenter()
        local objects = ents.FindInSphere(carPos, 1000)

        local affectedTargets = {}

        for k, object in pairs(objects) do
            if object.UnitVehicle then
                table.RemoveByValue(objects, object) --No friendly fire
            end
        end

        for k, object in pairs(objects) do
            if UVIsVehicleInCone( car, object, 90, 1000000 ) and object ~= car and (not table.HasValue(carchildren, object) and not table.HasValue(carconstraints, object) and IsValid(object:GetPhysicsObject()) or object.UVWanted or object:GetClass() == "entity_uv*" or object.uvdeployed) then

                local objectphys = object:GetPhysicsObject()
                local vectorDifference = object:WorldSpaceCenter() - carPos

                local angle = vectorDifference:Angle()
                local power = UVUnitPTShockRamPower:GetFloat()
                local damage = UVUnitPTShockRamDamage:GetFloat()

                if UVIsPTUpgraded(car) then
					power = power * 2
                    damage = damage * 2
				end

                local force = power * (1 - (vectorDifference:Length()/1000))

                objectphys:ApplyForceCenter(angle:Forward()*force)
                UVRamVehicle(object)
                
                local attachVictim = false
                --if object.UnitVehicle then
                    local phmass = math.Round(objectphys:GetMass())
                    UVBounty = UVBounty+phmass
                    UVDamage(object, damage)
                    attachVictim = true
                --end

                if attachVictim and object:IsVehicle() then
                    -- local victimName = UVGetDriverName(object)
                    -- table.insert( args.Hit, victimName )
                    table.insert( affectedTargets, object )
                end
            end
        end

        local MathSound = math.random(1,4)
        car:EmitSound( "gadgets/shockwave/"..MathSound..".wav" ) --Placeholder

        local effect = EffectData()
        effect:SetEntity(car)
        util.Effect("entity_remove", effect)
        util.ScreenShake( carPos, 5, 5, 1, 1000 )

        if car.UnitVehicle then
            UVChatterShockRamDeployed(car.UnitVehicle)
        end

        if #affectedTargets > 0 then
            ReportPTEvent( car, affectedTargets, 'ShockRam', 'Hit' )
            if car.UnitVehicle then
                UVChatterShockRamHit(car.UnitVehicle)
            end
        else
            if car.UnitVehicle then
                UVChatterShockRamMissed(car.UnitVehicle)
            end
        end
    end

    --GPS DART
    function UVDeployGPSDart(car)
        local ph = car:GetPhysicsObject()
        local launchSpeed = 5000
        local angle = car:GetClass() == "prop_vehicle_jeep" and ph:GetAngles()+Angle(0,90,0) or ph:GetAngles()
        angle.x = angle.z - 1
        local force = launchSpeed + (ph:GetVelocity():Length() * 5)

        local gpsdart = ents.Create("entity_uvgpsdart")
        gpsdart.uvdeployed = car

        gpsdart:SetPos(car:WorldSpaceCenter())

        if car:GetClass() == "prop_vehicle_jeep" then
            gpsdart:SetAngles(ph:GetAngles()+Angle(0,90,0))
        else
            gpsdart:SetAngles(ph:GetAngles())
        end

        gpsdart:Spawn()
        gpsdart.PhysgunDisabled = false

        local phgpsdart = gpsdart:GetPhysicsObject()
        phgpsdart:EnableMotion(true)
        phgpsdart:ApplyForceCenter(angle:Forward()*force)
    end

    --JUGGERNAUT
    function UVDeployJuggernaut(car)
        local driver = UVGetDriver(car)

        car.juggernauton = true
        local e = EffectData()
        e:SetEntity(car)
        util.Effect("entity_remove", e)
        net.Start("UVWeaponJuggernautEnable")
        net.WriteEntity(car)
        net.Broadcast()
    end
    
    function UVDeactivateJuggernaut(car)
        if not car.juggernauton then return end

        if IsValid(car) then
            car.juggernauton = nil

            net.Start("UVWeaponJuggernautDisable")
            net.WriteEntity(car)
            net.Broadcast()

            car:StopSound("gadgets/juggernaut/idle.wav")

            local e = EffectData()
            e:SetEntity(car)
            util.Effect("entity_remove", e)
            car:EmitSound("gadgets/juggernaut/juggernautoff.wav")

            car.uvjuggernauthit = nil
        end
    end

    --GHOST
    function UVDeployGhost(car)
        local driver = UVGetDriver(car)

        car.ghoston = true
        
        car:SetCollisionGroup(20)

        car.ogrendermode = car:GetRenderMode()
        car:SetRenderMode(RENDERMODE_TRANSALPHA) --Required for transparency

        local c = car:GetColor()
        car:SetColor(Color(c.r, c.g, c.b, 100))
    end
    
    function UVDeactivateGhost(car)
        if not car.ghoston then return end

        if IsValid(car) then
            car.ghoston = nil

            car:SetCollisionGroup(0)

            car:SetRenderMode(car.ogrendermode)
            car.ogrendermode = nil

            local c = car:GetColor()
            car:SetColor(Color(c.r, c.g, c.b, 255))
        end
    end

    --GRAPPLER
    function UVDeployGrappler(car)
        car.grappleron = true

        constraint.RemoveConstraints( car, "Rope" )
        
        net.Start("UVWeaponGrapplerEnable")
        net.WriteEntity(car)
        net.Broadcast()

        if car.UnitVehicle then
            UVChatterGrapplerDeployed(car)
        end
    end
    
    function UVDeactivateGrappler(car)
        car.grappleron = nil

        if car.wrecked then
            constraint.RemoveConstraints( car, "Rope" )
        end

        if IsValid(car) then
            net.Start("UVWeaponGrapplerDisable")
            net.WriteEntity(car)
            net.Broadcast()
        end

        timer.Simple(1, function()
            if IsValid(car) and car.UnitVehicle and not IsValid(car.grappler) then
                UVChatterGrapplerMissed(car)
            end
        end)
    end

    function UVGrapple(car, object)
        local carpos = car:WorldSpaceCenter()
        local carlocal = car:WorldToLocal(carpos)

        local closest_ent = object
        local shortest_distance = math.huge

        local closest_entpos = closest_ent:WorldSpaceCenter()
        local closest_entlocal = object:WorldToLocal(closest_entpos)

        local weld_entity = nil

        local grapplerThinkID = "UVGrapplerThink"..car:EntIndex()
        
        if object.IsSimfphyscar then
            if istable(object.Wheels) then
			    for i = 1, table.Count( object.Wheels ) do
                    local Wheel = object.Wheels[ i ]
			    	if IsValid(Wheel) then
                        local dist = carpos:DistToSqr(Wheel:WorldSpaceCenter())

                        if dist < shortest_distance then
                            shortest_distance = dist
                            closest_ent = Wheel
                            selected_index = i
                        end
                    end
			    end
            end

            closest_entpos = closest_ent:WorldSpaceCenter()
            closest_entlocal = object:WorldToLocal(closest_entpos)
            closest_entphys = closest_ent:GetPhysicsObject()
        elseif object.IsGlideVehicle then 
            for _, v in pairs(object.wheels) do
				if IsValid(v) then
                    local dist = carpos:DistToSqr(v:WorldSpaceCenter())

                    if dist < shortest_distance then
                        
                        shortest_distance = dist
                        closest_ent = v
                    end
                end
			end

            closest_entpos = closest_ent:WorldSpaceCenter()
            closest_entlocal = object:WorldToLocal(closest_entpos)
            closest_entphys = closest_ent:GetPhysicsObject()

            hook.Add("Think", grapplerThinkID, function()
                if not IsValid(car) or not IsValid(object) then hook.Remove("Think", grapplerThinkID) return end
                closest_ent.state.angularVelocity = 0
            end)
        end

        local length = UVUnitPTGrapplerLength:GetInt()
        local strength = UVUnitPTGrapplerStrength:GetInt()
        local disableduration = UVUnitPTGrapplerDisableDuration:GetInt()

        if UVIsPTUpgraded(car) then --stronger, lasting
			strength = strength * 2
			disableduration = disableduration * 2
		end

        local cons, rope

        --Create rope constraint
        timer.Simple(0, function()
            cons, rope = constraint.Rope( 
                car, --Entity 1
                object, --Entity 2
                0, -- bone1
                0, -- bone2
                carlocal, --localPos1
                closest_entlocal, --localPos2
                length, --length
                0, --addlength
                strength, --strength
                5, --width
                "cable/new_cable_lit", --material
                false, --rigid
                Color(225,255,0) --color
            )

            car.grappler = rope

            local time = disableduration

            timer.Simple(time, function()
                if IsValid(car) then
                    constraint.RemoveConstraints( car, "Rope" )
                    hook.Remove("Think", grapplerThinkID)
                    if IsValid(weld_entity) then weld_entity:Remove() end
                end
            end)
        end)

        UVDeactivateGrappler(car)

        ReportPTEvent( car, object, 'Grappler', 'Hit' )

        if car.UnitVehicle then
            UVChatterGrapplerHit(car)
        end
    end
    
else -- client settings

    UVWithESF = {}
    UVWithJuggernaut = {}
    UVWithGrappler = {}
    
    net.Receive("UVUnitTakedown", function()
		if UVHUDCopMode then return end
		if UVHUDDisplayRacing then return end
		
		local unitType = net.ReadString()
        local name = net.ReadString()
        local bounty = net.ReadUInt( 32 )
        local bountyCombo = net.ReadUInt( 7 )
        local isPlayer = net.ReadBool()
        hook.Run( 'UIEventHook', 'pursuit', 'onUnitTakedown', unitType, name, string.Comma( bounty ), bountyCombo, isPlayer)
    end)
    
    net.Receive("UVWeaponJammerEnable", function()
        local ply = net.ReadEntity()
        if ply ~= LocalPlayer() then --VICTIM
            uvclientjammed = true
            surface.PlaySound( "gadgets/jammer/activate2.wav" )
            LocalPlayer():EmitSound("gadgets/jammer/loop1.wav", 100, 100, 1, CHAN_STATIC)
            hook.Add("RenderScreenspaceEffects", "UVJammedScreen", function()
                DrawMaterialOverlay( "effects/tvscreen_noise003a", 1 )
            end )
            -- notification.AddLegacy( "YOU'RE BEING JAMMED!", NOTIFY_ERROR, 10 )
        else --ATTACKER
            surface.PlaySound( "gadgets/jammer/activate1.wav" )
            -- notification.AddLegacy( "Jammer is now active!", NOTIFY_GENERIC, 10 )
        end
    end)
    
    net.Receive("UVWeaponJammerDisable", function()
        local ply = net.ReadEntity()
        if ply ~= LocalPlayer() then --VICTIM
            uvclientjammed = nil
            LocalPlayer():StopSound( "gadgets/jammer/loop1.wav" )
            surface.PlaySound( "gadgets/jammer/deactivate1.wav" )
        else --ATTACKER
            surface.PlaySound( "gadgets/jammer/deactivate2.wav" )
        end
        hook.Remove("RenderScreenspaceEffects", "UVJammedScreen")
    end)

    --[[
        EXPECTED DATA:
        - EventType (UINT, 15)
            1 = Message
            2 = Event
        - Args (DATA)
    ]]
    net.Receive("UVPTEvent", function()
        local pt = net.ReadString()
        local eventType = net.ReadString() --net.ReadUInt( 15 )
        local isArgsSent = net.ReadBool()

        local args = nil

        if isArgsSent then
            args = util.JSONToTable( util.Decompress( net.ReadData( net.ReadUInt( 16 ) ) ) )
        end
        hook.Run( 'onPTEvent', pt, eventType, args )
    end)
    
    hook.Add("Think", "UVClientWeaponThink", function()
        if not UVWithESF then
            UVWithESF = {}
        end
        if not UVWithJuggernaut then
            UVWithJuggernaut = {}
        end
        if not UVWithGrappler then
            UVWithGrappler = {}
        end
    end)
    
    net.Receive("UVWeaponESFEnable", function()
        local unit = net.ReadEntity()
        table.insert(UVWithESF, unit)
    end)
    
    net.Receive("UVWeaponESFDisable", function()
        local unit = net.ReadEntity()
        table.RemoveByValue(UVWithESF, unit)
    end)
    
    hook.Add("PreDrawHalos", "UVWeaponESFShow", function()
        if next(UVWithESF) == nil then return end
        halo.Add( UVWithESF, Color(255,255,255), 10, 10, 1 )
    end)

    net.Receive("UVWeaponJuggernautEnable", function()
        local unit = net.ReadEntity()
        table.insert(UVWithJuggernaut, unit)
    end)
    
    net.Receive("UVWeaponJuggernautDisable", function()
        local unit = net.ReadEntity()
        table.RemoveByValue(UVWithJuggernaut, unit)
    end)
    
    hook.Add("PreDrawHalos", "UVWeaponJuggernautShow", function()
        if next(UVWithJuggernaut) == nil then return end
        halo.Add( UVWithJuggernaut, Color(255,93,0), 10, 10, 1 )
    end)

    net.Receive("UVWeaponGrapplerEnable", function()
        local unit = net.ReadEntity()
        table.insert(UVWithGrappler, unit)
    end)
    
    net.Receive("UVWeaponGrapplerDisable", function()
        local unit = net.ReadEntity()
        table.RemoveByValue(UVWithGrappler, unit)
    end)
    
    hook.Add("PreDrawHalos", "UVWeaponGrapplerShow", function()
        if next(UVWithGrappler) == nil then return end
        halo.Add( UVWithGrappler, Color(225,255,0), 10, 10, 1 )
    end)

end