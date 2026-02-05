list.Set("NPC", "npc_trafficvehicle", {
	Name = "#uv.npc.0trafficvehicle",
	Class = "npc_trafficvehicle",
	Category = "#uv.unitvehicles"
})
AddCSLuaFile("npc_trafficvehicle.lua")
include("entities/uvapi.lua")

ENT.Base = "base_entity"
ENT.Type = "ai"

ENT.PrintName = "TrafficVehicle"
ENT.Author = "Ranjeet"
ENT.Contact = "Tango"
ENT.Purpose = "*honking sound*"
ENT.Instruction = "Spawn on/under the vehicle until it shows a spawn effect."
ENT.Spawnable = false
ENT.Modelname = "models/props_lab/huladoll.mdl"

local dvd = DecentVehicleDestination



if SERVER then	
	--Setting ConVars.
	local DetectionRange = GetConVar("unitvehicle_detectionrange")
	local CanWreck = GetConVar("unitvehicle_canwreck")
	local OptimizeRespawn = GetConVar("unitvehicle_optimizerespawn")
	local SpeedLimit = GetConVar("unitvehicle_speedlimit")
	local DVWaypointsPriority = GetConVar("unitvehicle_dvwaypointspriority")
	local OptimizeRespawn = GetConVar("unitvehicle_optimizerespawn") 
	
	function ENT:OnRemove()
		--By undoing, driving, diving in water, or getting stuck, and the vehicle is remaining.
		if IsValid(self.v) and self.v:IsVehicle() then
			self.v.TrafficVehicle = nil
			local steerinput = (math.random(-100, 100)) / 100
			if self.v.IsScar then --If the vehicle is SCAR.
				self.v.HasDriver = self.v.BaseClass.HasDriver --Restore some functions.
				self.v.SpecialThink = self.v.BaseClass.SpecialThink
				if not self.v:HasDriver() then --If there's no driver, stop the engine.
					self.v:TurnOffCar()
					self.v:HandBrakeOn()
					self.v:GoNeutral()
					self.v:NotTurning()
				end
			elseif self.v.IsSimfphyscar then --The vehicle is Simfphys Vehicle.
				self.v.GetDriver = self.v.OldGetDriver or self.v.GetDriver
				if not IsValid(self.v:GetDriver()) then --If there's no driver, stop the engine.
					self.v:StopEngine()
				end
				self.v.PressedKeys = self.v.PressedKeys or {} --Reset key states.
				self.v.PressedKeys["Shift"] = false
				if self.v.wrecked then
					local randomno = math.random(1, 3)
					if randomno == 1 then
						self.v.PressedKeys["Space"] = false
					elseif randomno == 2 then
						self.v.PressedKeys["Space"] = true
					elseif randomno == 3 then
						self.v:SetActive(false)
					end
					self.v:PlayerSteerVehicle(self, steerinput < 0 and -steerinput or 0, steerinput > 0 and steerinput or 0)
				end
			elseif not IsValid(self.v:GetDriver()) and --The vehicle is normal vehicle.
			isfunction(self.v.StartEngine) and isfunction(self.v.SetHandbrake) and 
			isfunction(self.v.SetThrottle) and isfunction(self.v.SetSteering) and not self.v.IsGlideVehicle then
				self.v.GetDriver = self.v.OldGetDriver or self.v.GetDriver
				--self.v:StartEngine(false) --Reset states.
				--self:UVHandbrakeOn()
				self.v:SetThrottle(0)
				if self.v.wrecked then
					self.v:SetSteering(steerinput, 0)
				end
			elseif self.v.IsGlideVehicle then
				self.v:TurnOff()
				self.v:TriggerInput("Throttle", 0)
				if self.v.wrecked then
					local randomno = math.random(1, 4)
					if randomno == 1 then
						self.v:TriggerInput("Handbrake", 0)
						self.v:TriggerInput("Brake", 0)
					elseif randomno == 2 then
						self.v:TriggerInput("Handbrake", 1)
						self.v:TriggerInput("Brake", 0)
					elseif randomno == 3 then
						self.v:TriggerInput("Handbrake", 0)
						self.v:TriggerInput("Brake", 1)
					elseif randomno == 4 then
						self.v:TriggerInput("Handbrake", 1)
						self.v:TriggerInput("Brake", 1)
					end
					self.v:TriggerInput("Steer", steerinput)
				else
					self.v:TriggerInput("Handbrake", 1)
					self.v:TriggerInput("Brake", 0)
				end
			end

			-- if self.v.GetIsHonking then
			self:SetHorn(false)
			-- end
			
			local e = EffectData()
			e:SetEntity(self.v)
			util.Effect("entity_remove", e) --Perform an effect.

			if (self.uvscripted and not self.wrecked) then
				SafeRemoveEntity(self.v)
			end
			
		end
		
	end

	function ENT:IsWrecked()
		if not self.v then return end
		if self.v:IsFlagSet(FL_DISSOLVING) then return true end
		if self.v.IsScar then
			return self.v:IsDestroyed()
		elseif self.v.IsSimfphyscar then
			return self.v:GetCurHealth() <= 0 or self.v:OnFire() or self.v.destroyed
		elseif self.v.IsGlideVehicle then
			return self.v:GetEngineHealth() <= 0 or self.v:GetIsEngineOnFire()
		elseif isfunction(self.v.VC_GetHealth) then
			local health = self.v:VC_GetHealth(false)
			return isnumber(health) and health <= 0
		end
	end

	function ENT:Wreck()
		if IsValid(self.v) and not self.v.wrecked then
			self.wrecked = true
			self.v.wrecked = true
			local despawntime = 60
			if #UVWantedTableVehicle > 1 then
				despawntime = 10
			end
			table.insert(UVWreckedVehicles, self.v)
			self.v:CallOnRemove("UVWreckedVehicleRemoved", function()
				if table.HasValue(UVWreckedVehicles, self.v) then
					table.RemoveByValue(UVWreckedVehicles, self.v)
				end
			end)

			for _, v in pairs(constraint.GetAllConstrainedEntities(self.v)) do
				v.wrecked = true
				v.wrecked = true
				table.insert(UVWreckedVehicles, v)
				v:CallOnRemove("UVWreckedVehicleRemoved", function()
					if table.HasValue(UVWreckedVehicles, v) then
						table.RemoveByValue(UVWreckedVehicles, v)
					end
				end)
				timer.Simple(despawntime, function()
					if IsValid(wreck) then
						SafeRemoveEntity(wreck)
					end
				end)
			end

			if self.v.IsGlideVehicle then
				local wreck = self.v
				timer.Simple(despawntime, function()
					if IsValid(wreck) then
						SafeRemoveEntity(wreck)
					end
				end)
				wreck:SetEngineHealth(0)
				wreck:UpdateHealthOutputs()
				wreck.UnflipForce = 0
				wreck.AngularDrag = vector_origin
				if wreck.CanSwitchHeadlights then
					wreck:SetHeadlightState(0)
				end
				if wreck:GetVelocity():LengthSqr() > 250000 then
					UVGlideDetachWheels(wreck)
				end
			elseif self.v.IsSimfphyscar then
				local wreck = self.v
				timer.Simple(despawntime, function()
					if IsValid(wreck) then
						SafeRemoveEntity(wreck)
					end
				end)
				if wreck:GetVelocity():LengthSqr() > 250000 and WheelsDetaching:GetBool() then
					for i = 1, #wreck.Wheels do
						local wheelmathchance = math.random(1,2)
						local Wheel = wreck.Wheels[math.random(1, #wreck.Wheels)]
						if wheelmathchance == 1 then
							constraint.RemoveAll(Wheel)
						end
					end
				end
				wreck:SetCurHealth(0)
				wreck:SetLightsEnabled(false)
			elseif self.v:GetClass() == "prop_vehicle_jeep" then
				local wreck = self.v
				wreck:EmitSound( "vehicles/v8/vehicle_rollover"..math.random(1,2)..".wav" )
				wreck:AddCallback("PhysicsCollide", function(ent, coldata)
					local ouroldvel = coldata.OurOldVelocity:Length()
					local dot = coldata.OurOldVelocity:GetNormalized():Dot(coldata.HitNormal)
					dot = math.abs(dot) / 2
					local dmg = ouroldvel * dot
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
			SafeRemoveEntity(self)
		end
	end

	function ENT:Stop()
		self.moving = CurTime()
		self.PatrolWaypoint = nil
		self:SetELS(false)
		self:SetELSSound(false)
		self:SetHorn(false)

		if self.v.rammed then
			self:SetHorn(true)
		else
			self:SetHorn(false)
		end

		if self.v.IsScar then
			self.v:GoNeutral()
			self.v:NotTurning()
			self.v:HandBrakeOn()
		elseif self.v.IsSimfphyscar then
			self.v:SetActive(true)
			self.v:StartEngine()
			self.v.PressedKeys = self.v.PressedKeys or {}
			self.v.PressedKeys["W"] = false
			self.v.PressedKeys["A"] = false
			self.v.PressedKeys["S"] = false
			self.v.PressedKeys["D"] = false
			self.v.PressedKeys["Shift"] = false
			self.v.PressedKeys["Space"] = true
			self.v.PressedKeys["joystick_throttle"] = 0
			self.v.PressedKeys["joystick_brake"] = 0
		elseif isfunction(self.v.SetThrottle) and isfunction(self.v.SetSteering) and isfunction(self.v.SetHandbrake) and not self.v.IsGlideVehicle then
			self.v:SetThrottle(0)
			self.v:SetSteering(0, 0)
			self.v:SetHandbrake(true)
		elseif self.v.IsGlideVehicle then
			self.v:TriggerInput("Handbrake", 1)
			self.v:TriggerInput("Throttle", 0)
			self.v:TriggerInput("Brake", 0)
			self.v:TriggerInput("Steer", 0)
		end
	end
	
	function ENT:ObstaclesNearby()
		if not self.v then
			return
		end
		local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = (self.v:WorldSpaceCenter()+(self.v:GetVelocity()*2)), filter = {self.v, 'glide_wheel'}, mask = MASK_ALL}).Fraction ~= 1
		return tobool(tr)
	end

	function ENT:ObstaclesNearbySide()
		if not self.v or not self.v.width then
			return
		end

		local width = self.v.width/2
		local turnleft = -1
		local turnright = 1

		local speed = self.v:GetVelocity():LengthSqr()
		speed = math.sqrt(speed)

		local left = Vector(-width,math.Clamp(speed, width, math.huge),0)
		local right = Vector(width,math.Clamp(speed, width, math.huge),0)
		local leftstart = Vector(-width,0,0)
		local rightstart = Vector(width,0,0)

		if self.v.IsSimfphyscar then
			left:Rotate(Angle(0, (self.v.VehicleData.LocalAngForward.y-90), 0))
			right:Rotate(Angle(0, (self.v.VehicleData.LocalAngForward.y-90), 0))
			leftstart:Rotate(Angle(0, (self.v.VehicleData.LocalAngForward.y-90), 0))
			rightstart:Rotate(Angle(0, (self.v.VehicleData.LocalAngForward.y-90), 0))
		elseif self.v.IsGlideVehicle then
			left:Rotate(Angle(0, -90, 0))
			right:Rotate(Angle(0, -90, 0))
			leftstart:Rotate(Angle(0, -90, 0))
			rightstart:Rotate(Angle(0, -90, 0))
		end
		
		local trleft = util.TraceLine({start = self.v:LocalToWorld(leftstart), endpos = (self.v:LocalToWorld(left)+Vector(0,0,25)), filter = {self.v, 'glide_wheel'}, mask = MASK_ALL}).Fraction
		local trright = util.TraceLine({start = self.v:LocalToWorld(rightstart), endpos = (self.v:LocalToWorld(right)+Vector(0,0,25)), filter = {self.v, 'glide_wheel'}, mask = MASK_ALL}).Fraction

		if trleft > trright then
			return turnleft
		end
		if trleft < trright then
			return turnright
		end

		return false

	end

	function ENT:FindPatrol()

		if next(dvd.Waypoints) == nil then
			return
		end

		local Waypoint = dvd.GetNearestWaypoint(self.v:WorldSpaceCenter())
		if Waypoint.Neighbors then
			local WaypointTable = {}
			for k, v in pairs(Waypoint.Neighbors) do
				if not self.PreviousPatrolWaypoint or self.PreviousPatrolWaypoint["Target"] ~= dvd.Waypoints[v]["Target"] then
					table.insert(WaypointTable, v)
				end
			end --Don't turn around
			self.PatrolWaypoint = dvd.Waypoints[WaypointTable[math.random(#WaypointTable)]]
		else
			self.PatrolWaypoint = Waypoint
		end

	end

	function ENT:Patrol()

		if next(dvd.Waypoints) == nil then
			return
		end

		if self.PatrolWaypoint then

			if not self.patrolling then
				self.patrolling = true
			end

			--Set handbrake
			if self.v.IsScar then
				self.v:HandBrakeOff()
			elseif self.v.IsSimfphyscar then
				self.v:SetActive(true)
				self.v:StartEngine()
				self.v.PressedKeys = self.v.PressedKeys or {}
				self.v.PressedKeys["Space"] = false
			elseif isfunction(self.v.SetHandbrake) and not self.v.IsGlideVehicle then
				self.v:SetHandbrake(false)
			elseif self.v.IsGlideVehicle then
				self.v:TriggerInput("Handbrake", 0)
			end

			self.waypointPos = self.PatrolWaypoint["Target"]+(vector_up * 50)

			local selfvelocity = self.v:GetVelocity():LengthSqr()
			
			--Patrolling techniques
			local forward = self.v.IsSimfphyscar and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward() or self.v:GetForward()
			local dist = self.waypointPos - self.v:WorldSpaceCenter()
			local vect = dist:GetNormalized()
			local vectdot = vect:Dot(self.v:GetVelocity())
			local throttle = dist:Dot(forward) > 0 and 1 or -1
			local right = vect:Cross(forward)
			local steer_amount = right:Length()
			local steer = right.z > 0 and steer_amount or -steer_amount
			local speedlimitmph = self.PatrolWaypoint["SpeedLimit"]
			self.Speeding = speedlimitmph^2

			--Unique patrolling techniques
			if self.stuck then
				if right.z > 0 then 
					steer = -1 
				else 
					steer = 1 
				end
				throttle = throttle * -1
			end --Getting unstuck
			if not self.respondingtocall and (selfvelocity > self.Speeding or selfvelocity > 1115136) then
				throttle = -1
			end
			if GetConVar("unitvehicle_tractioncontrol"):GetBool() and selfvelocity > 10000 and not self.stuck then
				if self.v.IsSimfphyscar then
					if istable(self.v.Wheels) then
						for i = 1, table.Count( self.v.Wheels ) do
							local Wheel = self.v.Wheels[ i ]
							if not Wheel then return end
							if Wheel:GetGripLoss() > 0 then
								throttle = throttle * Wheel:GetGripLoss() --Simfphys traction control
							end
						end
					end
				elseif self.v.IsGlideVehicle then
					local EntityMeta = FindMetaTable( "Entity" )
					local getTable = EntityMeta.GetTable
					local selfvTbl = getTable( self.v )
					local wheelslip = selfvTbl.avgForwardSlip > 0 and selfvTbl.avgForwardSlip or selfvTbl.avgForwardSlip < 0 and selfvTbl.avgForwardSlip * -1
					if wheelslip ~= false then
						throttle = throttle - (wheelslip/10) --Glide traction control
					end
				else
					local maththrottle = throttle - math.abs(steer)
					if maththrottle >= 0 then
						throttle = maththrottle
					end --Cornering
				end
			end
			if dist:Dot(forward) < 0 and not self.stuck then
				if vectdot > 0 then
					if right.z > 0 then 
						steer = -1 
					else 
						steer = 1 
					end
				else
					if right.z < 0 then 
						steer = -1 
					else 
						steer = 1 
					end
				end
			end --K turn

			

			local turn = self:ObstaclesNearbySide()
			if turn then
				if turn == -1 then
					if vectdot > 0 then
						steer = -1
					else
						steer = 1
					end
				end
				if turn == 1 then
					if vectdot > 0 then
						steer = 1
					else
						steer = -1
					end
				end
			end

			if self.v.rammed then
				self:SetHorn(true)
			else
				self:SetHorn(false)
			end

			local speedInUnits = self.v:GetVelocity():Length()
			local arrivalThreshold = math.Clamp(150 + (speedInUnits * 0.5), 150, 600)

			if dist:Length() < arrivalThreshold and UVStraightToWaypoint(self.v:WorldSpaceCenter(), self.waypointPos) then
			    if self.PatrolWaypoint.Neighbors then
			        local WaypointTable = {}
			        for k, v in pairs(self.PatrolWaypoint.Neighbors) do
			            -- Ensure we aren't picking the waypoint we literally just came from
			            if not self.PreviousPatrolWaypoint or self.PreviousPatrolWaypoint["Target"] ~= dvd.Waypoints[v]["Target"] then
			                table.insert(WaypointTable, v)
			            end
			        end
				
			        if #WaypointTable > 0 then
			            self.PreviousPatrolWaypoint = self.PatrolWaypoint
			            self.PatrolWaypoint = dvd.Waypoints[WaypointTable[math.random(#WaypointTable)]]
			            -- Small delay before allowing the next waypoint switch to prevent "bouncing"
			            self.NextWaypointTime = CurTime() + 0.5 
			        else
			            self.PatrolWaypoint = nil
			        end
			    else
			        self.PatrolWaypoint = nil
			    end
			end

			--Emergency Stop
			if self.emergencystop then
				if not self.emergencystopcooldown then
					self.emergencystopcooldown = true
					timer.Simple(10, function()
						if IsValid(self) then
							self.emergencystop = nil
							self.emergencystopcooldown = nil
						end
					end)
				end

				throttle = 0
				self:UVHandbrakeOn()
			end

			--Set throttle/steering
			if self.v.IsScar then
				if throttle > 0 then
					self.v:GoForward(throttle)
				else
					self.v:GoBack(-throttle)
				end
				if steer > 0 then
					self.v:TurnRight(steer)
				elseif steer < 0 then
					self.v:TurnLeft(-steer)
				else
					self.v:NotTurning()
				end
			elseif self.v.IsSimfphyscar then
				self.v:SetActive(true)
				self.v:StartEngine()
				self.v.PressedKeys = self.v.PressedKeys or {}
				self.v.PressedKeys["Shift"] = false
				self.v.PressedKeys["joystick_throttle"] = throttle
				self.v.PressedKeys["joystick_brake"] = throttle * -1
				self.v:PlayerSteerVehicle(self, steer < 0 and -steer or 0, steer > 0 and steer or 0)
			elseif self.v.IsGlideVehicle then
				self.v:TriggerInput("Throttle", throttle)
				self.v:TriggerInput("Brake", throttle * -1)
				steer = steer * 2 --Attempt to make steering more sensitive.
				self.v:TriggerInput("Steer", steer)
			elseif isfunction(self.v.SetThrottle) and not self.v.IsGlideVehicle then
				self.v:SetThrottle(throttle)
				self.v:SetSteering(steer, 0)
			end

			--Resetting
			if not (selfvelocity < 10000 and (throttle > 0 or throttle < 0)) then 
				self.moving = CurTime()
			end
			if self.stuck then 
				self.moving = CurTime()
				if selfvelocity > 100000 and vectdot > 0 and not UVEnemyEscaping then
					self.stuck = nil
				end
			end

			local timeout = 3
			if timeout and timeout > 0 then
				if CurTime() > self.moving + timeout and not UVTargeting then --If it has got stuck for enough time.
					self.invincible = true
					self.stuck = true
					self.moving = CurTime()
					timer.Simple(1, function() 
						if IsValid(self.v) then 
							self.stuck = nil 
						end 
					end)
					if not self.respondingtocall then
						self.returningtopatrol = true
					end
				end
			end
			
		else
			if self.patrolling then
				self.patrolling = nil
				self.Speeding = (SpeedLimit:GetFloat()*17.6)^2
			end
			self:Stop()
			self:FindPatrol()
		end
		
	end

	function ENT:UVHandbrakeOff()
		if self.v.IsScar then
			self.v:HandBrakeOff()
		elseif self.v.IsSimfphyscar then
			self.v:SetActive(true)
			self.v:StartEngine()
			self.v.PressedKeys = self.v.PressedKeys or {}
			self.v.PressedKeys["Space"] = false
		elseif isfunction(self.v.SetHandbrake) and not self.v.IsGlideVehicle then
			self.v:SetHandbrake(false)
		end
	end

	function ENT:UVHandbrakeOn()
		if self.v.IsScar then
			self.v:HandBrakeOn()
		elseif self.v.IsSimfphyscar then
			self.v.PressedKeys = self.v.PressedKeys or {}
			self.v.PressedKeys["Space"] = true
		elseif isfunction(self.v.SetHandbrake) and not self.v.IsGlideVehicle then
			self.v:SetHandbrake(true)
		elseif self.v.IsGlideVehicle then
			self.v:TriggerInput("Handbrake", 1)
		end
	end
	
	function ENT:Think()
		--if not self.v.GetIsHonking then return end

		self:SetPos(self.v:GetPos() + (vector_up * 50))
		self:SetAngles(self.v:GetPhysicsObject():GetAngles()+Angle(0,180,0))

		--Flipping/crash
		if self.v and not self.wrecked and not self.spawned and
		(self.v:Health() < 0 and self.v:GetClass() == "prop_vehicle_jeep" or --No health 
		self.v:GetPhysicsObject():GetAngles().z > 90 and self.v:GetPhysicsObject():GetAngles().z < 270 and (self.v.rammed or self.v:GetVelocity():LengthSqr() < 10000 and self.stuck) and CanWreck:GetBool() or --Flipped
		self.v:WaterLevel() > 2 or --Underwater
		self:IsOnFire()) or --On fire
		self:IsWrecked() then --Other parameters
			self:Wreck()
		end

		if not IsValid(self.v) or --The tied vehicle goes NULL.
		not self.v:IsVehicle() or --Somehow it become non-vehicle entity.
		IsValid(self.v:GetDriver()) then --It has an driver.
			self:Wreck()
			return
		end
		
		self:Patrol()
	end
	
	function ENT:Initialize()
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetModel(self.Modelname)
		self:SetHealth(-1)
		self.spawned = true
		
		self.Speeding = (SpeedLimit:GetFloat()*17.6)^2 --MPH to in/s^2
		timer.Simple(1, function() 
			if IsValid(self.v) then 
				timer.Simple(2, function()
					if IsValid(self.v) then
						if vcmod_main and self.v:GetClass() == "prop_vehicle_jeep" and GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then 
							self.v:VC_setRunningLights(true)
						end
					end
				end)
				self.spawned = nil
			end 
		end)

		--Pick up a vehicle in the given sphere.
		if self.vehicle then
			local v = self.vehicle
			if v.TrafficVehicle and v.TrafficVehicle:IsNPC() then return end
			if v.IsScar then --If it's a SCAR.
				if not v:HasDriver() then --If driver's seat is empty.
					self.v = v
					v.TrafficVehicle = self
					v.HasDriver = function() return true end --SCAR script assumes there's a driver.
					v.SpecialThink = function() end --Tanks or something sometimes make errors so disable thinking.
					v:StartCar()
				end
			elseif v.IsSimfphyscar and v:IsInitialized() then --If it's a Simfphys Vehicle.
				if not IsValid(v:GetDriver()) then --Fortunately, Simfphys Vehicles can use GetDriver()
					self.v = v
					v.TrafficVehicle = self
					v:SetActive(true)
					v:StartEngine()
					if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then
						v:SetLightsEnabled(true)
					end
				end
			elseif isfunction(v.EnableEngine) and isfunction(v.StartEngine) and not v.IsGlideVehicle then --Normal vehicles should use these functions. (SCAR and Simfphys cannot.)
				if isfunction(v.GetWheelCount) and v:GetWheelCount() and not IsValid(v:GetDriver()) then
					self.v = v
					v.TrafficVehicle = self
					v:EnableEngine(true)
					v:StartEngine(true)
				end
			elseif v.IsGlideVehicle and v.GetIsHonking then --Glide ( current way of checking if it is a valid vehicle is to check for ishonking netvar :^) )
				if not IsValid(v:GetDriver()) then
					self.v = v
					v.TrafficVehicle = self
					v:SetEngineState(2)
					v.inputThrottleModifierMode = 2
					v.AirControlForce = vector_origin
					if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 and v.CanSwitchHeadlights then
						v:SetHeadlightState(1)
					end

					v.UVConstrainedEntities = {}

					for _, entity in pairs(constraint.GetAllConstrainedEntities(v)) do
						table.insert(v.UVConstrainedEntities, entity)

						entity:CallOnRemove("UVConstrainedEntitiesRemoved", function()
							if v.UVConstrainedEntities and table.HasValue(v.UVConstrainedEntities, entity) then
								table.RemoveByValue(v.UVConstrainedEntities, entity)
							end
						end)
					end

					v.OnSocketDisconnect = function( car, socket )
						for _, entity in pairs(v.UVConstrainedEntities) do
							entity.wrecked = true
							table.insert(UVWreckedVehicles, entity)
							entity:CallOnRemove("UVWreckedVehicleRemoved", function()
								if table.HasValue(UVWreckedVehicles, entity) then
									table.RemoveByValue(UVWreckedVehicles, entity)
								end
							end)

							local despawntime = 60
							if #UVWantedTableVehicle > 1 then
								despawntime = 10
							end

							timer.Simple(despawntime, function()
								if IsValid(wreck) then
									SafeRemoveEntity(wreck)
								end
							end)
						end

						if IsValid(car.TrafficVehicle) then
							car.wrecked = nil
							car.TrafficVehicle:Wreck()
						end
					end
				end
			end
		else
			local distance = DetectionRange:GetFloat()
			for k, v in pairs(ents.FindInSphere(self:GetPos(), distance)) do
				if v:GetClass() == 'prop_vehicle_prisoner_pod' then continue end
				if v.TrafficVehicle and v.TrafficVehicle:IsNPC() then continue end
				if v:IsVehicle() then
					if v.IsScar then --If it's a SCAR.
						if not v:HasDriver() then --If driver's seat is empty.
							self.v = v
							v.TrafficVehicle = self
							v.HasDriver = function() return true end --SCAR script assumes there's a driver.
							v.SpecialThink = function() end --Tanks or something sometimes make errors so disable thinking.
							v:StartCar()
						end
					elseif v.IsSimfphyscar and v:IsInitialized() then --If it's a Simfphys Vehicle.
						if not IsValid(v:GetDriver()) then --Fortunately, Simfphys Vehicles can use GetDriver()
							self.v = v
							v.TrafficVehicle = self
							v:SetActive(true)
							v:StartEngine()
							if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then
								v:SetLightsEnabled(true)
							end
						end
					elseif isfunction(v.EnableEngine) and isfunction(v.StartEngine) and not v.IsGlideVehicle then --Normal vehicles should use these functions. (SCAR and Simfphys cannot.)
						if isfunction(v.GetWheelCount) and v:GetWheelCount() and not IsValid(v:GetDriver()) then
							self.v = v
							v.TrafficVehicle = self
							v:EnableEngine(true)
							v:StartEngine(true)
						end
					elseif v.IsGlideVehicle then --Glide
						if not IsValid(v:GetDriver()) then
							self.v = v
							v.TrafficVehicle = self
							v:TurnOn()
							v.inputThrottleModifierMode = 2
							v.AirControlForce = vector_origin
							if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 and v.CanSwitchHeadlights then
								v:SetHeadlightState(1)
							end
							
							v.UVConstrainedEntities = {}

							for _, entity in pairs(constraint.GetAllConstrainedEntities(v)) do
								table.insert(v.UVConstrainedEntities, entity)
							
								entity:CallOnRemove("UVConstrainedEntitiesRemoved", function()
									if table.HasValue(v.UVConstrainedEntities, entity) then
										table.RemoveByValue(v.UVConstrainedEntities, entity)
									end
								end)
							end
						
							v.OnSocketDisconnect = function( car, socket )
								for _, entity in pairs(v.UVConstrainedEntities) do
									entity.wrecked = true
									table.insert(UVWreckedVehicles, entity)
									entity:CallOnRemove("UVWreckedVehicleRemoved", function()
										if table.HasValue(UVWreckedVehicles, entity) then
											table.RemoveByValue(UVWreckedVehicles, entity)
										end
									end)

									local despawntime = 60
									if #UVWantedTableVehicle > 1 then
										despawntime = 10
									end

									timer.Simple(despawntime, function()
										if IsValid(wreck) then
											SafeRemoveEntity(wreck)
										end
									end)
								end
							
								if IsValid(car.TrafficVehicle) then
									car.wrecked = nil
									car.TrafficVehicle:Wreck()
								end
							end
						end
					end
				end
			end
		end
	
		if not IsValid(self.v) or not IsValid(self.v:GetPhysicsObject()) then SafeRemoveEntity(self) return end --When there's no vehicle, remove Traffic Vehicle.

		if isfunction(self.v.UVVehicleInitialize) then --For vehicles that has a driver bodygroup
			self.v:UVVehicleInitialize()
		end

		if not self.uvscripted then
			local e = EffectData()
			e:SetEntity(self.v)
			util.Effect("propspawn", e) --Perform a spawn effect.
		end
		if not UVTargeting then self.v:EmitSound( "vo/npc/male01/hi02.wav" ) end
		self.mass = math.Round(self.v:GetPhysicsObject():GetMass())

		local collisionmin, collisionmax = self.v:GetCollisionBounds()
		if isvector(collisionmin) and isvector(collisionmax) then
			if self.v.IsSimfphyscar or self.v.IsGlideVehicle then
				self.v.width = ((collisionmax.y)-(collisionmin.y))
				self.v.length = ((collisionmax.x)-(collisionmin.x))
			else
				self.v.width = ((collisionmax.x)-(collisionmin.x))
				self.v.length = ((collisionmax.y)-(collisionmin.y))
			end
		end
		
		local min, max = self.v:GetHitBoxBounds(0, 0) --NPCs aim at the top of the vehicle referred by hit box.
		if not isvector(max) then min, max = self.v:GetModelBounds() end --If getting hit box bounds is failed, get model bounds instead.
		if not isvector(max) then max = vector_up * math.random(80, 200) end --If even getting model bounds is failed, set a random value.
		
		local tr = util.TraceHull({start = self.v:GetPos() + vector_up * max.z, 
			endpos = self.v:GetPos(), ignoreworld = true,
			mins = Vector(-16, -16, -1), maxs = Vector(16, 16, 1)})
		self.CollisionHeight = tr.HitPos.z - self.v:GetPos().z
		if self.CollisionHeight < 10 then self.CollisionHeight = max.z end
		self.v:DeleteOnRemove(self)
		
	end
else --if CLIENT
	function ENT:Initialize()
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetModel(self.Modelname)
	end
end --if SERVER

--For Half Life Renaissance Reconstructed
function ENT:GetNoTarget()
	return false
end

--For Simfphys Vehicles
function ENT:GetInfoNum(key, default)
	if key == "cl_simfphys_ctenable" then return 1 --returns the default value
	elseif key == "cl_simfphys_ctmul" then return 0.7 --because there's a little weird code in
	elseif key == "cl_simfphys_ctang" then return 15 --Simfphys:PlayerSteerVehicle()
	elseif isnumber(default) then return default end
	return 0
end
