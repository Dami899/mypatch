AddCSLuaFile()

if SERVER then
    
    local function RemoveRepairShop(ent)
        
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
    
    function UVLoadRepairShop(jsonfile)
        local JSONData = file.Read( "unitvehicles/repairshops/"..game.GetMap().."/"..jsonfile, "DATA" )
        if not JSONData then return end
        
        local rsdata = util.JSONToTable(JSONData, true) --Load Repair Shop
        
        local location = rsdata.Location or rsdata.Maxs
        
        if table.HasValue(UVLoadedRepairShops, jsonfile) then 
            for _, ent in ents.Iterator() do
                if ent.RepairShop == jsonfile then 
                    local ConstrainedEntities = constraint.GetAllConstrainedEntities( ent )
                    for _, ent in pairs( ConstrainedEntities ) do
                        RemoveRepairShop(ent)
                    end
                end
            end
            if table.HasValue(UVLoadedRepairShops, jsonfile) then
                table.RemoveByValue(UVLoadedRepairShops, jsonfile)
            end
            timer.Simple(1, function()
                if not table.HasValue(UVLoadedRepairShops, jsonfile) then
                    UVLoadRepairShop(jsonfile) --Try again
                end
            end)
            return
        end
        table.insert(UVLoadedRepairShops, jsonfile)
        table.insert(UVLoadedRepairShopsLoc, location)


        local entities, constraints = {}, {}

        for k, ent in pairs( rsdata.Entities ) do
            local entClass = ent.Class
            local entPos = ent.Pos or ent.Maxs
            local entAng = ent.Angle or Angle(0, 0, 0)
            local entModel = ent.Model

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

        end

        for _, constraint in pairs( rsdata.Constraints ) do
            local Ent = duplicator.CreateConstraintFromTable( constraint, entities, nil )
            if IsValid( Ent ) then
                table.insert( constraints, Ent )
            end
        end
        
    end
    
    function UVAutoLoadRepairShop()
        local repairShops = file.Find( "unitvehicles/repairshops/"..game.GetMap().."/*.json", "DATA" )
        
        if not repairShops then return end
        if next(repairShops) == nil then return end
        
        local availableRepairShops = {}
        for k, v in pairs(repairShops) do
            if not table.HasValue(UVLoadedRepairShops, v) then
                table.insert(availableRepairShops, v)
            end
        end
        
        if next(availableRepairShops) == nil then return end
        
        local randomrs = availableRepairShops[math.random(#availableRepairShops)]
        UVLoadRepairShop(randomrs)
    end
    
else
    
    net.Receive("UVHUDRepairCooldown", function() --Inform the player when the repair shop can be used again
        local timeleft = net.ReadInt(32)
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.cooldown"),
			color = Color(255, 0, 0),
			critical = true,
			time = 3,
        })
		
		UV_UI.general.events.CenterNotification({
            text = string.format( UVString("uv.repairshop.cooldown.time"), timeleft ),
			critical = true,
			time = 3,
        })
        surface.PlaySound("ui/pursuit/repairunavailable.wav")
    end)

    net.Receive("UVHUDRepair", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.used"),
			critical = true,
			time = 3,
        })
        surface.PlaySound("ui/pursuit/repair.wav")
    end)

    net.Receive("UVHUDRepairCommander", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.nocommander"),
			color = Color(255, 0, 0),
			critical = true,
			time = 2,
        })
        surface.PlaySound("ui/pursuit/repairunavailable.wav")
    end)

    net.Receive("UVHUDRefilledPT", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.used.pt"),
			critical = true,
			time = 2,
        })
    end)

    net.Receive("UVHUDRepairAvailable", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.available"),
			color = Color(50, 255, 50),
			critical = true,
			time = 3,
        })
        surface.PlaySound("ui/pursuit/repairavailable.wav")
    end)

    net.Receive("uvrepairsimfphys", function()
        local veh = net.ReadEntity()
	    if not IsValid( veh ) then return end
	    veh:Backfire( false )
        veh.DamageSnd:Stop()
    end)

end