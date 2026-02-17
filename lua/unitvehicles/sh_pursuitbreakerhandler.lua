AddCSLuaFile()

if SERVER then
    
    local function RemovePursuitBreaker(ent)
        
        if not IsValid( ent ) then return end
        
        constraint.RemoveAll( ent )
        
        timer.Simple( 1, function() if (IsValid( ent )) then ent:Remove() end end )
        
        ent:SetNotSolid( true )
        ent:SetMoveType( MOVETYPE_NONE )
        ent:SetNoDraw( true )
        
        local ed = EffectData()
        ed:SetOrigin( ent:GetPos() )
        ed:SetEntity( ent )
        util.Effect( "entity_remove", ed, true, true )
        
    end
    
    function UVLoadPursuitBreaker(jsonfile, checkdistance)
        local JSONData = file.Read( "unitvehicles/pursuitBreakers/"..game.GetMap().."/"..jsonfile, "DATA" )
        if not JSONData then return end
        
        local pbdata = util.JSONToTable(JSONData, true) --Load Pursuit Breaker
        
        local location = pbdata.Location or pbdata.Maxs
        local activeduration = pbdata.ActiveDuration or 10
        local dontunweldprops = pbdata.DontUnweldProps or nil
        
        if checkdistance then
            local ply = ents.FindByClass('player')[1]
            local enemylocation
            local suspect = ply
            local suspectlocation = suspect and suspect:GetPos() or vector_origin
            if next(UVWantedTableVehicle) ~= nil then
                local suspects = UVWantedTableVehicle
                local random_entry = math.random(#suspects)	
                suspect = suspects[random_entry]
                enemylocation = (suspect:GetPos()+(vector_up * 50))
            else
                enemylocation = (suspectlocation+(vector_up * 50))
            end
            local distance = enemylocation:DistToSqr(location)
            if distance < 25000000 then
                return
            end
        end
        
        if table.HasValue(UVLoadedPursuitBreakers, jsonfile) then 
            for _, ent in ents.Iterator() do
                if ent.PursuitBreaker == jsonfile then 
                    local ConstrainedEntities = constraint.GetAllConstrainedEntities( ent )
                    for _, ent in pairs( ConstrainedEntities ) do
                        RemovePursuitBreaker(ent)
                    end
                end
            end
            if table.HasValue(UVLoadedPursuitBreakers, jsonfile) then
                table.RemoveByValue(UVLoadedPursuitBreakers, jsonfile)
            end
            timer.Simple(1, function()
                if not table.HasValue(UVLoadedPursuitBreakers, jsonfile) then
                    UVLoadPursuitBreaker(jsonfile) --Try again
                end
            end)
            return
        end
        table.insert(UVLoadedPursuitBreakers, jsonfile)
        table.insert(UVLoadedPursuitBreakersLoc, location)
        
        net.Start("UVAddPursuitBreaker")
        net.WriteString(jsonfile)
        net.WriteInt(location.x, 32)
        net.WriteInt(location.y, 32)
        net.WriteInt(location.z, 32)
        net.Broadcast()

        --local entities, constraints = duplicator.Paste( Entity(1), pbdata.Entities, pbdata.Constraints )

        local entities, constraints = {}, {}

        for k, ent in pairs( pbdata.Entities ) do
            local entClass = ent.Class
            local entPos = ent.Pos or ent.Maxs
            local entAng = ent.Angle or Angle(0, 0, 0)
            local entModel = ent.Model
           -- print(entClass, entPos, entAng, entModel)

            local gib = ents.Create( entClass )
            if not IsValid( gib ) then continue end

            duplicator.DoGeneric( gib, ent )

            gib:SetPos( Vector(entPos.x, entPos.y, entPos.z) )

            gib:SetAngles( entAng )
            gib:SetModel( entModel )

            gib:Spawn()

            gib.BoneMods = table.Copy( ent.BoneMods )
			gib.EntityMods = table.Copy( ent.EntityMods )
			gib.PhysicsObjects = table.Copy( ent.PhysicsObjects )

            duplicator.ApplyEntityModifiers( Entity(1), gib )
	        duplicator.ApplyBoneModifiers( Entity(1), gib )

            entities[k] = gib

            timer.Simple(0, function()
                if not IsValid(gib) then return end
                
                local phys = gib:GetPhysicsObject()

                if IsValid( phys ) and gib.PhysicsObjects then
                    phys:EnableMotion( not gib.PhysicsObjects[0].Frozen )
                    phys:SetAngles( gib.PhysicsObjects[0].Angle )
                    phys:SetPos( gib.PhysicsObjects[0].Pos )

                    if gib.PhysicsObjects[0].Sleep then
                        phys:Sleep()
                    else
                        phys:Wake()
                    end
                end
            end)

            table.Merge( gib:GetTable(), ent )

            --gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end

        for _, constraint in pairs( pbdata.Constraints ) do
            -- local constraintType = constraint.Type
            -- local ent1 = constraint.Ent1
            -- local ent2 = constraint.Ent2
            -- local constraintData = constraint.Data or {}
            -- local newConstraint = constraint.Create(constraintType, ent1, ent2, constraintData)
            -- if not newConstraint then continue end
            -- table.insert(constraints, newConstraint)

            local Ent = duplicator.CreateConstraintFromTable( constraint, entities, nil )
            if IsValid( Ent ) then
                table.insert( constraints, Ent )
            end
        end
        
        for k, ent in pairs( entities ) do
            ent.PursuitBreaker = jsonfile
            ent.PursuitBreakerLoc = location
            ent.ActiveDuration = activeduration
            ent.DontUnweldProps = dontunweldprops
            ent:AddCallback("PhysicsCollide", function(ent, data)
                local object = data.HitEntity
                
                if data.Speed > 10 and not object:IsWorld() and not object.PursuitBreaker then
                    if ent.PursuitBreaker then
                        UVTriggerPursuitBreaker(ent, object, data.TheirOldVelocity)
                    elseif not ent.PursuitBreakerActive then
                        return
                    end
                    
                    local car
                    
                    if object:GetClass() == "gmod_sent_vehicle_fphysics_wheel" then
                        car = object:GetBaseEnt()
                    elseif object.IsSimfphyscar then
                        car = object
                    elseif object.IsGlideVehicle then
                        car = object
                    elseif object:GetClass() == "prop_vehicle_jeep" then
                        car = object
                    end
                    
                    --On first hit
                    if not IsValid(car) then return end

                    local driver = car.UnitVehicle or car.TrafficVehicle
                
                    if driver then
                        if driver:IsNPC() then
                            driver:Wreck()
                        else
                            UVPlayerWreck(car)
                        end
                    end
                    
                end
            end)
        end
        
    end
    
    local function UVSetPhysicsCollisions( ent, collisions )
        
        if ( not IsValid( ent ) or not IsValid( ent:GetPhysicsObject() ) ) then return end
        
        ent:GetPhysicsObject():EnableCollisions( collisions )
        
    end
    
    local function UVRemoveConstraints( ent, const_type )
        if ( not ent.Constraints ) then return end
        
        local c = ent.Constraints
        local i = 0
        
        for k, v in pairs( c ) do
            
            if ( not IsValid( v ) ) then
                
                c[ k ] = nil
                
            elseif ( v.Type == const_type ) then
                
                if v.Ent1:GetClass() == "gmod_thruster" or v.Ent2:GetClass() == "gmod_thruster" then --Ignore thrusters
                    c[ k ] = nil
                else
                    
                    UVSetPhysicsCollisions( v.Ent1, true )
                    UVSetPhysicsCollisions( v.Ent2, true )
                    
                    c[ k ] = nil
                    v:Remove()
                    
                    i = i + 1 
                end
            end
            
        end
        
        if ( table.IsEmpty( c ) ) then
            ent:IsConstrained()
        end
        
        local bool = i ~= 0
        return bool, i
        
    end
    
    function UVTriggerPursuitBreaker(hitent, object, objectvelocity)
        if hitent.PursuitBreakerActive or not hitent.PursuitBreaker then return end
        
        local entities = {}
        local constraints = {}
        local jsonfile = hitent.PursuitBreaker
        local location = hitent.PursuitBreakerLoc
        local activeduration = hitent.ActiveDuration or 10
        local dontunweldprops = hitent.DontUnweldProps or nil
        
        hitent.PursuitBreaker = nil
        
        if table.HasValue(UVLoadedPursuitBreakersLoc, location) then
            table.RemoveByValue(UVLoadedPursuitBreakersLoc, location)
        end
        
        net.Start("UVTriggerPursuitBreaker")
        net.WriteString(jsonfile)
        net.WriteInt(location.x, 32)
        net.WriteInt(location.y, 32)
        net.WriteInt(location.z, 32)
        net.Broadcast()
        
        duplicator.GetAllConstrainedEntitiesAndConstraints(hitent, entities, constraints)
        
        local r = math.huge
        local closestdistance, closestbreakableent = r^2
        
        for k, ent in pairs(entities) do
            ent.PursuitBreaker = nil
            ent.PursuitBreakerActive = true
            
            timer.Simple(activeduration, function()
                if IsValid(ent) then
                    ent.PursuitBreakerActive = nil
                end
            end)
            
            timer.Simple(UVPBCooldown:GetInt(), function()
                if IsValid(ent) then
                    ent:Remove()
                    if table.HasValue(UVLoadedPursuitBreakers, jsonfile) then
                        table.RemoveByValue(UVLoadedPursuitBreakers, jsonfile)
                    end
                end
            end)
            
            if not dontunweldprops then
                UVRemoveConstraints(ent, "Weld") --Unweld everything but thrusters
            end
            
            if ent:GetClass() == "gmod_thruster" then
                ent:SetOn(true)
                ent:StartThrustSound()
            end
            
            if IsValid(ent:GetPhysicsObject()) then
                ent:GetPhysicsObject():EnableMotion(true)
            end
            
            if not (ent:Health() < 1) and ent:GetClass() == "prop_physics" then
                local hitentpos = hitent:WorldSpaceCenter()
                local distance = hitentpos:DistToSqr(ent:WorldSpaceCenter())
                if distance < closestdistance then
                    closestdistance, closestbreakableent = distance, ent
                end
            end
            
        end
        
        local hitentphys = hitent:GetPhysicsObject()
        local phys = object:GetPhysicsObject()
        if objectvelocity and IsValid(phys) and IsValid(hitentphys) then
            hitentphys:SetVelocity(objectvelocity)
            phys:SetVelocity(objectvelocity)
        end
        
        if IsValid(closestbreakableent) then 
            closestbreakableent:Fire("Break") 
        end
        
        local Chatter = GetConVar("unitvehicle_chatter")
        
        --Check if it's a gas station
        if UVTargeting then
            if string.find(jsonfile:lower(), "gas") then
                UVSoundChatter(hitent, 1, "pursuitbreakergas", 8)
            else
                if Chatter:GetBool() then
                    local units = ents.FindByClass("npc_uv*")
                    local airUnits = ents.FindByClass("uvair")
                    
                    table.Add( units, airUnits )
                    
                    if next(units) ~= nil then 
                        local randomunit = units[math.random(#units)]
                        UVSoundChatter(randomunit, randomunit.voice, "pursuitbreaker", 4) 
                    end
                    
                end
            end
        end

        return hitent
        
    end
    
    function UVAutoLoadPursuitBreaker()
        local pursuitBreakers = file.Find( "unitvehicles/pursuitBreakers/"..game.GetMap().."/*.json", "DATA" )
        
        if not pursuitBreakers then return end
        if next(pursuitBreakers) == nil then return end
        
        local availablePursuitBreakers = {}
        for k, v in pairs(pursuitBreakers) do
            if not table.HasValue(UVLoadedPursuitBreakers, v) then
                table.insert(availablePursuitBreakers, v)
            end
        end
        
        if next(availablePursuitBreakers) == nil then return end
        
        local randompb = availablePursuitBreakers[math.random(#availablePursuitBreakers)]
        UVLoadPursuitBreaker(randompb, true)
    end
    
else

    UVHUDPursuitBreakers = {}

    hook.Add("PostCleanupMap", "UVPBCleanup", function()
        UVHUDPursuitBreakers = {}
    end)
    
    net.Receive("UVAddPursuitBreaker", function()
        local jsonfile = net.ReadString()
        local location = Vector(net.ReadInt(32), net.ReadInt(32), net.ReadInt(32))

        table.insert(UVHUDPursuitBreakers, location)

        if GMinimap then
            blip, id = GMinimap:AddBlip( {
                id = jsonfile,
                position = location,
                icon = "unitvehicles/icons/MINIMAP_ICON_PURSUIT_BREAKER.png",
                scale = 1.5,
                color = Color( 255, 127, 127, 255 ),
                lockIconAng = true
            } )
        end
    end)
    
    net.Receive("UVTriggerPursuitBreaker", function()
        local jsonfile = net.ReadString()
        local location = Vector(net.ReadInt(32), net.ReadInt(32), net.ReadInt(32))

        table.RemoveByValue(UVHUDPursuitBreakers, location)

        if GMinimap then
            GMinimap:RemoveBlipById( jsonfile )
        end
    end)
    
end