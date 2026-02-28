AddCSLuaFile()

--[[
Type 1 = Speeding
• Exceeding posted speed limits
Type 2 = Damage To Property
• Colliding with non-world entities
Type 3 = Hit And Run
• Colliding with vehicles
Type 4 = Street Racing
• Commiting either of the crimes above with multiple potential suspects
]]

local dvd = DecentVehicleDestination

if SERVER then

    UVTimeToCheckForPotentialSuspects = CurTime()
    
    timer.Create("UVCheckForCalls", 2, 0, function()
        for _, ent in ents.Iterator() do
            if UVPassConVarFilter(ent) and not table.HasValue(UVPotentialSuspects, ent) then
                table.insert(UVPotentialSuspects, ent)
                ent:CallOnRemove( "UVWantedPotentialSuspectRemoved", function(vehicle)
                    if table.HasValue(UVPotentialSuspects, vehicle) then
                        table.RemoveByValue(UVPotentialSuspects, vehicle)
                    end
                end)
            end
        end

        local timeout = 3
        local ctimeout = 1

        local function SpawnAI(racer, traffic)

            if racer and traffic then
                local chance = math.random(1,2)
                if chance == 1 then
                    UVAutoSpawnRacer()
                else
                    UVAutoSpawnTraffic()
                end
            elseif racer then
                UVAutoSpawnRacer()
            elseif traffic then
                UVAutoSpawnTraffic()
            end
            
        end
        
        if CurTime() > UVTimeToCheckForPotentialSuspects + timeout then --Check for potential suspects
            local SpawnRacerAI
            local SpawnTrafficAI

            if #ents.FindByClass("npc_racervehicle") < UVRMaxRacer:GetInt() then
                if UVRSpawnCondition:GetInt() == 3 then
                    SpawnRacerAI = true
                elseif UVRSpawnCondition:GetInt() == 2 and UVGetIfSomeoneDriving() then
                    SpawnRacerAI = true
                end
            end

            if #ents.FindByClass("npc_trafficvehicle") < UVTMaxTraffic:GetInt() then
                if UVTSpawnCondition:GetInt() == 3 then
                    SpawnTrafficAI = true
                elseif UVTSpawnCondition:GetInt() == 2 and UVGetIfSomeoneDriving() then
                    SpawnTrafficAI = true
                end
            end

            SpawnAI(SpawnRacerAI, SpawnTrafficAI)

            if #UVLoadedPursuitBreakers < UVPBMax:GetInt() then
				if UVPBSpawnCondition:GetInt() == 3 then
                    UVAutoLoadPursuitBreaker()
                elseif UVPBSpawnCondition:GetInt() == 2 and UVGetIfSomeoneDriving() then
                    UVAutoLoadPursuitBreaker()
                end
			end

            if #UVLoadedRepairShops < UVRSMax:GetInt() then
				if UVRSSpawnCondition:GetInt() == 3 then
                    UVAutoLoadRepairShop()
                elseif UVRSSpawnCondition:GetInt() == 2 and UVGetIfSomeoneDriving() then
                    UVAutoLoadRepairShop()
                end
			end

            UVCheckForSpeeders()
            UVTimeToCheckForPotentialSuspects = CurTime()
        end

        if UVTargeting then 
            uvcallexists = false
        end
        
        if GetConVar("ai_ignoreplayers"):GetBool() or not GetConVar("unitvehicle_callresponse"):GetBool() or UVTargeting or uvcallexists then
            if UVCallLocation and UVTargeting then --Remove the call, allow for new calls to come in
                UVCallLocation = nil
            end
            if UVPreInfractionCount and UVPreInfractionCount > 0 then
                UVPreInfractionCount = 0
            end
        end
        
    end)
    
    function UVCheckForSpeeders()
        if next(UVPotentialSuspects) == nil or next(dvd.Waypoints) == nil then return end
        
        local SpeedTable = {}
        
        for k, v in pairs(UVPotentialSuspects) do
            local speed = v:GetVelocity():Length2DSqr()
            table.insert(SpeedTable, speed)
        end
        
        local fastestSpeeder = table.GetWinningKey(SpeedTable)
        local suspect = UVPotentialSuspects[fastestSpeeder]
        local speed = SpeedTable[fastestSpeeder]
        local SpeedLimit

        local SpeedLimitDV = next(dvd.Waypoints) ~= nil and dvd.GetNearestWaypoint(suspect:WorldSpaceCenter())["SpeedLimit"]^2 or nil
        local SpeedLimitConVar = (GetConVar("unitvehicle_speedlimit"):GetFloat()*17.6)^2
        
        --Determine which speed limit to use based on which is lower, if any
        if SpeedLimitDV and SpeedLimitDV < SpeedLimitConVar then
            SpeedLimit = SpeedLimitDV
        else
            SpeedLimit = SpeedLimitConVar
        end
        
        if speed > (SpeedLimit+30976) then
            UVPreInfractionCount = UVPreInfractionCount + 1
            if UVPreInfractionCount >= 10 then
                UVCallInitiate(suspect, 1)
            end
        end
        
    end
    
    function UVCallInitiate(suspectvehicle, type)
        if not GetConVar("unitvehicle_callresponse"):GetBool() or UVTargeting or uvcallexists then return end
        
        UVPreInfractionCount = 0
        
        uvcallexists = true
        
        local calllocation = suspectvehicle:GetPos()+(vector_up * 50)
        
        if #UVPotentialSuspects > 1 then --Multiple suspects
            type = 4
        end
        
        local timecheck = 5
        
        if type == 1 then --Speeding
            if GetConVar("unitvehicle_chatter"):GetBool() then
                timecheck = UVChatterDispatchCallSpeeding(UVHeatLevel)
            end
        elseif type == 2 then --Damage To Property
            if GetConVar("unitvehicle_chatter"):GetBool() then
                timecheck = UVChatterDispatchCallDamageToProperty(UVHeatLevel)
            end
        elseif type == 3 then --Hit and Run
            if GetConVar("unitvehicle_chatter"):GetBool() then
                timecheck = UVChatterDispatchCallHitAndRun(UVHeatLevel)
            end
        elseif type == 4 then --Street Racing
            if GetConVar("unitvehicle_chatter"):GetBool() then
                timecheck = UVChatterDispatchCallStreetRacing(UVHeatLevel)
            end
        end

        timecheck = 5
        
        timer.Simple(0.5, function()
            UVApplyHeatLevel()
            UVUpdateHeatLevel()
            UVAutoSpawn()
            uvIdleSpawning = CurTime()
            UVPresenceMode = true
            UVRestoreResourcePoints()
        end)
        
        timer.Simple(timecheck, function()
            if type ~= 4 then
                UVCallReportDescription(suspectvehicle, calllocation)
            else
                UVCallRespond(suspectvehicle, true) --No questions asked
                UVCallLocation = calllocation
            end
        end)
        
    end
    
    function UVCallReportDescription(suspectvehicle, calllocation)
        if UVTargeting then return end

        
        local timecheck = 5

        
        if next(ents.FindByClass("npc_uv*" )) ~= nil and GetConVar("unitvehicle_chatter"):GetBool() then
            local units = ents.FindByClass("npc_uv*" )
            local random_entry = math.random(#units)	
            local unit = units[random_entry]
            timecheck = UVChatterCallRequestDescription(unit)
            timer.Simple(timecheck, function()
                if not IsValid(suspectvehicle) or UVTargeting then return end
                local timecheck2 = 5
                local mathdescription = math.random(1,2)
                if mathdescription == 1 then --Known description
                    if next(ents.FindByClass("npc_uv*" )) ~= nil and GetConVar("unitvehicle_chatter"):GetBool() then
                        local e = UVGetVehicleMakeAndModel(suspectvehicle)
                        local units = ents.FindByClass("npc_uv*" )
                        local random_entry = math.random(#units)	
                        local unit = units[random_entry]
                        UVChatterDispatchCallVehicleDescription(unit, suspectvehicle, e)
                    end
                    timer.Simple(timecheck2 or 5, function()
                        UVCallRespond(suspectvehicle)
                        UVCallLocation = calllocation
                    end)
                else --Unknown description
                    if next(ents.FindByClass("npc_uv*" )) ~= nil and GetConVar("unitvehicle_chatter"):GetBool() then
                        local units = ents.FindByClass("npc_uv*" )
                        local random_entry = math.random(#units)	
                        local unit = units[random_entry]
                        UVChatterDispatchCallUnknownDescription(unit)
                    end
                    timer.Simple(timecheck2 or 5, function()
                        UVCallRespond(suspectvehicle)
                        UVCallLocation = calllocation
                    end)
                end
            end)
        end
        
    end
    
    function UVCallRespond(suspectvehicle)

        uvcallexists = nil
        
        if UVTargeting then return end
        
        if next(ents.FindByClass("npc_uv*" )) == nil then return end
        
        if GetConVar("unitvehicle_chatter"):GetBool() then
            local units = ents.FindByClass("npc_uv*" )
            local random_entry = math.random(#units)	
            local unit = units[random_entry]
            UVChatterCallResponding(unit)
        end
        
        for k, v in pairs(UVPotentialSuspects) do
            UVAddToWantedListVehicle(v)
        end
        
    end
    
else
    
    net.Receive("UVHUDWanted", function()
        local soundfiles = file.Find("sound/ui/pursuit/wanted/*", "GAME" )
        if not soundfiles or #soundfiles == 0 or not PursuitSFX:GetBool() then return end
        surface.PlaySound("ui/pursuit/wanted/"..soundfiles[math.random(1, #soundfiles)])
        
        if Glide then
            Glide.Notify( {
                text = UVString("uv.hud.popup.wanted"),
                icon = "unitvehicles/icons/MILESTONE_PURSUIT.png",
                sound = "glide/ui/phone_notify.wav",
                lifetime = 5
            } )
        else
            chat.AddText(Color(255,0,0), UVString("uv.hud.popup.wanted"))
        end
        
    end)
    
end