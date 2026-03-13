list.Set("NPC", "npc_uvsupport", {
	Name = "#uv.npc.2support",
	Class = "npc_uvsupport",
	Category = "#uv.unitvehicles"
})
AddCSLuaFile("npc_uvsupport.lua")
include("entities/uvapi.lua")

ENT.Base = "base_entity"
ENT.Type = "ai"

ENT.PrintName = "UVSupport"
ENT.Author = "Cross"
ENT.Contact = "Sierra"
ENT.Purpose = "To be called out if Patrol units hit trouble. You are that trouble."
ENT.Instruction = "Spawn on/under the vehicle until it shows a spawn effect."
ENT.Spawnable = false
ENT.Modelname = "models/props_lab/huladoll.mdl"

local dvd = DecentVehicleDestination

if SERVER then	
	--Setting ConVars.
	local DetectionRange = GetConVar("unitvehicle_detectionrange")
	local NeverEvade = GetConVar("unitvehicle_neverevade")
	local BustedTimer = GetConVar("unitvehicle_bustedtimer")
	local EvadeTimer = GetConVar("unitvehicle_evadetimer")
	local CanWreck = GetConVar("unitvehicle_canwreck")
	local Chatter = GetConVar("unitvehicle_chatter")
	local SpeedLimit = GetConVar("unitvehicle_speedlimit")
	local AutoHealth = GetConVar("unitvehicle_autohealth")
	local MinHeatLevel = GetConVar("unitvehicle_unit_minheat")
	local MaxHeatLevel = GetConVar("unitvehicle_unit_maxheat")
	local HeatLevels = GetConVar("unitvehicle_heatlevels")
	local PursuitTech = GetConVar("unitvehicle_unit_pursuittech")
	local DVWaypointsPriority = GetConVar("unitvehicle_dvwaypointspriority")
	local OptimizeRespawn = GetConVar("unitvehicle_optimizerespawn")
	local Catchup = GetConVar("unitvehicle_unitcatchup")

	local UVPathClasses = {
		["npc_uvpatrol"] = true, ["npc_uvpursuit"] = true, ["npc_uvsupport"] = true,
		["npc_uvinterceptor"] = true, ["npc_uvcommander"] = true, ["npc_uvspecial"] = true,
	}
	
	function ENT:OnRemove()
		if table.HasValue(UVUnitsChasing, self) then
			table.RemoveByValue(UVUnitsChasing, self)
		end
		if Chatter:GetBool() and IsValid(self.v) and not self.wrecked and not UVTargeting then
			UVChatterOnRemove(self)
		end
		--By undoing, driving, diving in water, or getting stuck, and the vehicle is remaining.
		if IsValid(self.v) and self.v:IsVehicle() then
			self.v.UVSupport = nil
			self.v.UnitVehicle = nil
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

			if self.v.roadblocking then
				self.roadblocking = true
			end
			
			self:SetELS(false)
			self:SetELSSound(false)
			self:SetHorn(false)
			
			local e = EffectData()
			e:SetEntity(self.v)
			util.Effect("entity_remove", e) --Perform an effect.
			net.Start("UVHUDRemoveUV")
			net.WriteInt(self.v:EntIndex(), 32)
			net.WriteInt(self.v:GetCreationID(), 32)
			net.Broadcast()
			if (self.uvscripted and not self.wrecked) then
				SafeRemoveEntity(self.v)
			end
			
		end
		
		if self.metwithenemy and not UVResourcePointsRefreshing and UVResourcePoints > 1 and not UVOneCommanderActive and not self.roadblocking then
			UVResourcePoints = (UVResourcePoints - 1)
		end
		
	end
	
	--Find an enemy around.
	function ENT:TargetEnemy()
		if UVEnemyBusted or UVEnemyEscaped then return end
		local t = ents.FindInSphere(self.v:WorldSpaceCenter(), 2500)
		local distance, nearest = math.huge, nil --The nearest enemy is the target.
		for k, v in pairs(t) do
			if self:Validate(v) and ((SpeedLimit:GetFloat() > 0 and v:GetVelocity():LengthSqr() > (self.Speeding+30976)) or self.v.rammed or v.UVWanted or v.uvraceparticipant) and self:StraightToTarget(v) then --Target conditions
				local d = v:WorldSpaceCenter():DistToSqr(self.v:WorldSpaceCenter())
				if distance > d then
					distance = d
					nearest = v
				end
			end
		end
		
		return nearest
	end
	
	function ENT:TargetEnemyAdvanced()
		local t = ents.FindInSphere(self.v:WorldSpaceCenter(), math.huge)
		local distance, nearest = math.huge, nil --The nearest enemy is the target.
		for k, v in pairs(t) do
			if self:Validate(v) then --Target conditions
				local d = v:WorldSpaceCenter():DistToSqr(self.v:WorldSpaceCenter())
				if distance > d then
					distance = d
					nearest = v
				end
			end
		end
		
		return nearest
	end
	
	function ENT:ForgetEnemy()
		UVEnemyEscaping = nil
		if IsValid(self.e) then
			if table.HasValue(UVWantedTableVehicle, self.e) and not UVEnemyEscaped then
				table.RemoveByValue(UVWantedTableVehicle, self.e)
				net.Start( "UV_RemoveWantedVehicle" )
				net.WriteInt( self.e:EntIndex(), 32 )
				net.Broadcast()
			end
			self.e = nil
		end
		if self.edriver then
			if table.HasValue(UVWantedTableDriver, self.edriver) and not UVEnemyEscaped then
				table.RemoveByValue(UVWantedTableDriver, self.edriver)
			end
			self.edriver = nil
		end
	end
	
	--Validate the given enemy.
	function ENT:Validate(v)
		local valid = 
		IsValid(v) and --Has existence
		IsValid(v:GetPhysicsObject()) and --Has physics
		not v.UnitVehicle and
		(v:IsVehicle() and not GetConVar("ai_ignoreplayers"):GetBool()) 
		if not valid then return false end
		
		return UVPassConVarFilter(v)
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
			if not UVTargeting and IsValid(self.e) and #UVWantedTableVehicle > 0 then
				UVTargeting = true
			end
			table.insert(UVWreckedVehicles, self.v)
			self.v:CallOnRemove("UVWreckedVehicleRemoved", function()
				if table.HasValue(UVWreckedVehicles, self.v) then
					table.RemoveByValue(UVWreckedVehicles, self.v)
				end
			end)
			if not timer.Exists("uvcombotime") then
				timer.Create("uvcombotime", 5, 1, function() 
					UVComboBounty = 1 
					timer.Remove("uvcombotime")
				end)
			else --Multiple units down
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
			local v = UVGetVehicleMakeAndModel(self.v)
			local bountyplus = (UVUBountySupport:GetInt())*(UVComboBounty)
			local bounty = string.Comma(bountyplus)
			if IsValid(self.e) and isfunction(self.e.GetDriver) and IsValid(UVGetDriver(self.e)) then 
				UVNotifyCenter({UVGetDriver(self.e)}, "uv.hud.combo", "UNITS_DISABLED", "uv.unit.support", v, bountyplus, UVComboBounty, UVGetDriver(self.e):IsPlayer())
			end
			UVWrecks = UVWrecks + 1
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
			if self.v:IsVehicle() then
				UVBounty = (UVBounty+bountyplus)
			end
			if Chatter:GetBool() and IsValid(self.v) then
				UVChatterWreck(self)
			end
			SafeRemoveEntity(self)
			UVComboBounty = UVComboBounty + 1
		end
	end
	
	function ENT:Stop()
		self.moving = CurTime()
		self.tableroutetoenemy = {}
		self.PatrolWaypoint = nil
		self:SetELS(false)
		self:SetELSSound(false)
		self:SetHorn(false)
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

	-- function ENT:StraightToPoint(point)
	-- 	if not self.v or not point then
	-- 		return
	-- 	end
	-- 	local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = point, mask = MASK_NPCWORLDSTATIC, filter = {self, self.v}}).Fraction==1
	-- 	return tobool(tr)
	-- end
	
	-- function ENT:StraightToTarget(target, considerVelocity)
	-- 	if not self.v or not target then
	-- 		return
	-- 	end
		
	-- 	local targetPos = target:WorldSpaceCenter()
	-- 	if considerVelocity then
	-- 		local physObj = target:GetPhysicsObject()
	-- 		if IsValid(physObj) then
	-- 			targetPos = targetPos + physObj:GetVelocity()
	-- 		else
	-- 			targetPos = targetPos + target:GetVelocity()
	-- 		end
	-- 		local trace = util.TraceLine({start = target:WorldSpaceCenter(), endpos = targetPos, mask = MASK_NPCWORLDSTATIC, filter = {self, self.v, target}})
	-- 		if trace.Hit then targetPos = trace.HitPos end
	-- 	end

	-- 	local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = targetPos, mask = MASK_NPCWORLDSTATIC, filter = {self, self.v, target}}).Fraction==1
	-- 	return tobool(tr)
	-- end

	function ENT:StraightToTarget(target, considerVelocity, checkDist)
		if not self.v or not target then
			return false
		end
		
		local targetPos = target:WorldSpaceCenter()

		if checkDist then
			if targetPos:DistToSqr(self.v:WorldSpaceCenter()) > checkDist then return false end
		end
		
		if considerVelocity then
			local targetVel = vector_origin
			local physObj = target:GetPhysicsObject()

			if IsValid(physObj) then
				local vel = physObj:GetVelocity()
				targetVel = vel * 5
			else
				local vel = target:GetVelocity()
				targetVel = vel * 5
			end

			targetPos = targetPos + targetVel
			local trace = util.TraceLine({
				start = target:WorldSpaceCenter(), 
				endpos = targetPos, 
				mask = (InfMap and MASK_ALL or MASK_NPCWORLDSTATIC), 
				filter = {self, self.v, target, 'glide_wheel', 'npc_uv*'}
			})

			if trace.Hit then targetPos = trace.HitPos end
		end
	
		local startPos = self.v:WorldSpaceCenter()
		
		local tr = util.TraceLine({
			start = startPos, 
			endpos = targetPos, 
			mask = (InfMap and MASK_ALL or MASK_NPCWORLDSTATIC), 
			filter = {self, self.v, target, 'glide_wheel', 'npc_uv*'}
		})
		
		if tr.Fraction < 0.8 then return false end
		
		-- local midPoint = (startPos + targetPos) / 2
		-- local groundCheck = util.TraceLine({
		-- 	start = midPoint,
		-- 	endpos = midPoint - Vector(0, 0, 250),
		-- 	mask = MASK_NPCWORLDSTATIC,
		-- 	filter = {self, self.v, target}
		-- })

		return true
		
		-- return groundCheck.Hit and groundCheck.Fraction < 0.7
	end
	
	function ENT:VisualOnTarget(target)
		if not self.v or not target then
			return
		end
		local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = target:WorldSpaceCenter(), mask = MASK_OPAQUE, filter = {self, self.v, target}}).Fraction==1
		return tobool(tr)
	end
	
	function ENT:ObstaclesNearby()
		if not self.v or not self.v.rideheight then
			return
		end

		local class = self.v:GetClass()
		local pos = class == "prop_vehicle_jeep" and self.v:WorldSpaceCenter() or self.v:GetPos()
		pos.z = pos.z + self.v.rideheight

		local tr = util.TraceLine({start = pos, endpos = (pos+(self.v:GetVelocity()*2)), mask = MASK_NPCWORLDSTATIC})
		if tr.HitTexture == "TOOLS/TOOLSSKYBOX" then return false end
		local Fraction = tr.Fraction ~= 1
		local HitNormal = tr.HitNormal.z < 0.45 --Ignore small inclines

		return tobool(Fraction and HitNormal)
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
		
		local trleft = util.TraceLine({start = self.v:LocalToWorld(leftstart), endpos = (self.v:LocalToWorld(left)+(vector_up * 50)), mask = MASK_NPCWORLDSTATIC})
		local trright = util.TraceLine({start = self.v:LocalToWorld(rightstart), endpos = (self.v:LocalToWorld(right)+(vector_up * 50)), mask = MASK_NPCWORLDSTATIC})
		if trleft.HitTexture == "TOOLS/TOOLSSKYBOX" then return false end
		if trright.HitTexture == "TOOLS/TOOLSSKYBOX" then return false end
		local Fraction = trleft.Fraction ~= 1 or trright.Fraction ~= 1
		local HitNormal = trleft.HitNormal.z < 0.45 or trright.HitNormal.z < 0.45 --Ignore small inclines

		if not tobool(Fraction and HitNormal) then return false end

		if trleft.Fraction > trright.Fraction then
			return turnleft
		end
		if trleft.Fraction < trright.Fraction then
			return turnright
		end

		return false

	end

	

	function ENT:FriendlyNearbySide()
		if not self.v or not self.v.width then
			return
		end

		local width = self.v.width/2

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
		
		local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = (self.v:WorldSpaceCenter()+(self.v:GetVelocity()*2)), mask = MASK_SOLID})
		local trleft = util.TraceLine({start = self.v:LocalToWorld(leftstart), endpos = (self.v:LocalToWorld(left)+(vector_up * 50)), mask = MASK_SOLID})
		local trright = util.TraceLine({start = self.v:LocalToWorld(rightstart), endpos = (self.v:LocalToWorld(right)+(vector_up * 50)), mask = MASK_SOLID})

		if IsValid(tr.Entity) and tr.Entity.UnitVehicle then
			return tr.Entity:GetVelocity():LengthSqr()
		end

		if IsValid(trleft.Entity) and trleft.Entity.UnitVehicle then
			return trleft.Entity:GetVelocity():LengthSqr()
		end

		if IsValid(trright.Entity) and trleft.Entity.UnitVehicle then
			return trright.Entity:GetVelocity():LengthSqr()
		end
		
		return

	end
	
	function ENT:PathFindToEnemy(vectors)
		
		if not vectors or not isvector(vectors) or not GetConVar("unitvehicle_pathfinding"):GetBool() or self.NavigateCooldown or self.v.roadblocking then -- or self.NavigateBlind
			return
		end
		
		self.NavigateCooldown = true
		timer.Create(self._cooldownString, 1, 1, function()
			self.NavigateCooldown = nil 
		end)
		
		if DVWaypointsPriority:GetBool() then
			local enemy_nearest_waypoint = nil
			local friendly_nearest_waypoint = nil

			if dvd then
				local friendly_position = self.v:WorldSpaceCenter()

				enemy_nearest_waypoint = dvd.GetNearestWaypoint( vectors )
				friendly_nearest_waypoint = dvd.GetNearestWaypoint( friendly_position )

				local friendly_waypoint_position = friendly_nearest_waypoint and friendly_nearest_waypoint.Target + ( vector_up * 50 ) or vector_origin
				local enemy_waypoint_position = enemy_nearest_waypoint and enemy_nearest_waypoint.Target + ( vector_up * 50 ) or vector_origin

				if enemy_nearest_waypoint then
					local friendly_waypoint_distance = friendly_nearest_waypoint and friendly_waypoint_position:DistToSqr( friendly_position ) or math.huge
					local enemy_waypoint_distance = enemy_nearest_waypoint.Target:DistToSqr(vectors)
					local comparison_value = ( dvd.WaypointSize or 200 ) ^ 4

					local enemyTooFarFromWaypoint = enemy_waypoint_distance > comparison_value
					local enemyCanSeeWaypoint = enemy_nearest_waypoint and UVStraightToWaypoint( vectors, enemy_waypoint_position )
					local friendlyTooFarFromWaypoint = friendly_waypoint_distance > comparison_value
					local friendlyCanSeeWaypoint = friendly_nearest_waypoint and UVStraightToWaypoint( friendly_position, friendly_waypoint_position )

					local friedlyEnemyDistance = friendly_position:DistToSqr(vectors)
					local isFriendlyEnemyTooClose = friedlyEnemyDistance < 500000

					local isInvalid = enemyTooFarFromWaypoint or not enemyCanSeeWaypoint or not friendlyCanSeeWaypoint or isFriendlyEnemyTooClose
					if isInvalid then enemy_nearest_waypoint = nil end
				end
			end

			if enemy_nearest_waypoint then
				if UVNavigateDVWaypoint(self, vectors) then
					return
				elseif UVNavigateNavmesh(self, vectors) then
					return
				end
			else
				if UVNavigateNavmesh(self, vectors) then
					return
				elseif UVNavigateDVWaypoint(self, vectors) then
					return
				end
			end
		else
			if UVNavigateNavmesh(self, vectors) then
				return
			elseif UVNavigateDVWaypoint(self, vectors) then
				return
			end
		end
		
		if next(self.tableroutetoenemy) == nil and not self.NavigateBlind then
			self.NavigateBlind = true
			if self.returningtopatrol then
				self.returningtopatrol = nil
			end
		end
		
	end
	
	function ENT:DriveOnPath()
		local waypoints = table.Copy( self.tableroutetoenemy )
		if not waypoints or next(waypoints) == nil then 
			return self.v:WorldSpaceCenter() + (forward * 100)
		end
		
		local unitpos = self.v:WorldSpaceCenter()
		local reachThreshold = 250000
		local passedThreshold = 16000000
		
		local forward = self.v.IsSimfphyscar and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward() or self.v:GetForward()
		local velocity = self.v:GetVelocity()
		local velocityNormalized = velocity:GetNormalized()
		local hasVelocity = velocity:LengthSqr() > 10000
		
		for i = #waypoints, 1, -1 do
			local waypoint = waypoints[i]
			local toWaypoint = waypoint - unitpos
			local distSqr = toWaypoint:LengthSqr()
			
			if distSqr < reachThreshold then
				table.remove(waypoints, i)
			else
				local toWaypointNormalized = toWaypoint:GetNormalized()
				local forwardDot = toWaypointNormalized:Dot(forward)
				
				if forwardDot < -0.3 and distSqr > 62500 then -- 250 units squared minimum
					table.remove(waypoints, i)
				elseif distSqr > passedThreshold and forwardDot < 0 then
					table.remove(waypoints, i)
				end
			end
		end
		
		if next(waypoints) == nil then
			self.tableroutetoenemy = {}
			return unitpos + (forward * 100)
		end
		
		local bestWaypoint = waypoints[1]
		local bestScore = -math.huge
		local hasAnyClearPath = false
		
		for i = 1, #waypoints do
			local waypointpos = waypoints[i] + (vector_up * 50)
			if UVStraightToWaypoint(unitpos, waypointpos) then
				hasAnyClearPath = true
				break
			end
		end
		
		for i = 1, #waypoints do
			local waypoint = waypoints[i]
			local waypointpos = waypoint + (vector_up * 50)
			local toWaypoint = waypoint - unitpos
			local distSqr = toWaypoint:LengthSqr()
			local dist = math.sqrt(distSqr)
			local toWaypointNormalized = toWaypoint:GetNormalized()
			
			local hasLineOfSight = UVStraightToWaypoint(unitpos, waypointpos)
			
			local score = 0
			
			if not hasLineOfSight then
				if hasAnyClearPath then
					score = score - 1000
				else
					score = score - 200 - ( dist / 10 )
				end
			else
				score = score + 300
			end
			
			local forwardDot = toWaypointNormalized:Dot( forward )
			if forwardDot > 0 then
				score = score + forwardDot * 100
			else
				score = score + forwardDot * 50
			end
			
			if hasVelocity then
				local velocityDot = toWaypointNormalized:Dot( velocityNormalized )
				if velocityDot > 0 then
					score = score + velocityDot * 75
				else
					score = score + velocityDot * 25
				end
			end
			
			local distanceScore = 1 / ( dist + 1 ) * 50
			if forwardDot > 0 then
				score = score + distanceScore
			else
				score = score + distanceScore * 0.5
			end
			
			local progressBonus = ( i / #waypoints ) * 25
			if forwardDot > 0.3 then
				score = score + progressBonus
			end
			
			if dist > 2000 then
				score = score - ( dist - 2000 ) / 100
			end
			
			if score > bestScore then
				bestScore = score
				bestWaypoint = waypoint
			end
		end

		local needOffset = false
		local searchRadius = 800
		local aheadMaxDistSq = 500000
		local onWaypointRadiusSq = 40000
		local forwardDotMin = 0.2
		for _, veh in ipairs( UVUnitVehicles ) do
			if veh ~= self.v and IsValid(veh) then 
				local otherPos = veh:WorldSpaceCenter()
				local toOther = otherPos - (unitpos + (forward * 100))
				local distSq = toOther:LengthSqr()
				local fwdDot = toOther:GetNormalized():Dot(forward)
				local distToWpSq = (otherPos - bestWaypoint):LengthSqr()
				if UVStraightToWaypoint(unitpos, otherPos) and ((fwdDot > forwardDotMin and distSq < aheadMaxDistSq) or distToWpSq < onWaypointRadiusSq) then
					needOffset = true
					break
				end
			end
		end
		if needOffset then
			local right = forward:Cross(vector_up)
			if right:LengthSqr() > 0.01 then
				right:Normalize()
				local offsetAmount = 90
				if self.__entIndex % 2 == 0 then
					bestWaypoint = bestWaypoint + right * offsetAmount
				else
					bestWaypoint = bestWaypoint - right * offsetAmount
				end
			end
		end

		return bestWaypoint + (vector_up * 50)
	end

	function ENT:FindPatrol()
		
		if next(dvd.Waypoints) == nil then
			return
		end
		
		local Waypoint = dvd.GetNearestWaypoint(self.v:WorldSpaceCenter())
		if UVTargeting and Waypoint.Neighbors then --Keep going straight whilst in pursuit
			self.PatrolWaypoint = dvd.Waypoints[Waypoint.Neighbors[math.random(#Waypoint.Neighbors)]]
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
			
			--Determine patrol standards
			if not UVCallLocation then
				if self.respondingtocall then
					self.respondingtocall = nil
				end
				if self.returningtopatrol then
					self.returningtopatrol = true
				end
			else
				if not self.respondingtocall or not self.returningtopatrol then --Respond to call when not busy
					self.respondingtocall = true
				end
			end
			
			if not self.respondingtocall and not self.returningtopatrol then
				self.tableroutetoenemy = {}
				self.waypointPos = self.PatrolWaypoint["Target"]+(vector_up * 50)
				self:SetELS(false)
				self:SetELSSound(false)
				self:SetHorn(false)
			elseif not self.returningtopatrol then
				if self.tableroutetoenemy and next(self.tableroutetoenemy) ~= nil then
					local Waypoint = self.tableroutetoenemy[#self.tableroutetoenemy]
					local Neighbor = self.tableroutetoenemy[(#self.tableroutetoenemy-1)]
					self.waypointPos = self:DriveOnPath()
				else
					self:PathFindToEnemy(UVCallLocation)
					self:SetELS(true)
					self:SetELSSound(true)
					self:ChangeELSSiren()
					return
				end
			else
				if self.tableroutetoenemy and next(self.tableroutetoenemy) ~= nil then
					local Waypoint = self.tableroutetoenemy[#self.tableroutetoenemy]
					local Neighbor = self.tableroutetoenemy[(#self.tableroutetoenemy-1)]
					self.waypointPos = self:DriveOnPath()
				else
					self:PathFindToEnemy(self.PatrolWaypoint["Target"])
					self:SetELS(false)
					self:SetELSSound(false)
					self:SetHorn(false)
					return
				end
			end

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
				throttle = 0
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
			if self:ObstaclesNearby() or vectdot > 0 and dist:LengthSqr() < (selfvelocity*2) and selfvelocity > 774400 then
				if self.v:GetClass() == "prop_vehicle_jeep" then
					throttle = 0
				else
					throttle = -1
				end
			end --Slow down
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
			
			--When there
			if dist:LengthSqr() < 250000 and UVStraightToWaypoint(self.v:WorldSpaceCenter(), self.waypointPos) then
				if not self.respondingtocall and not self.returningtopatrol then
					if self.PatrolWaypoint.Neighbors then
						local WaypointTable = {}
						for k, v in pairs(self.PatrolWaypoint.Neighbors) do
							if not dvd.Waypoints[v] then continue end
							if not self.PreviousPatrolWaypoint or self.PreviousPatrolWaypoint["Target"] ~= dvd.Waypoints[v]["Target"] then
								table.insert(WaypointTable, v)
							end
						end --Don't turn around
						self.PreviousPatrolWaypoint = self.PatrolWaypoint
						self.PatrolWaypoint = dvd.Waypoints[WaypointTable[math.random(#WaypointTable)]] or nil
					else
						self.PatrolWaypoint = nil
					end
				elseif not self.returningtopatrol then
					if self.tableroutetoenemy then
						if next(self.tableroutetoenemy) == nil then
							self.PatrolWaypoint = nil
							self.respondingtocall = false
							self.returningtopatrol = true
							UVCallLocation = nil --Remove the call, allow for new calls to come in
							UVChatterCallResponded(self)
						end
					end --When there
				else
					if self.tableroutetoenemy then
						if next(self.tableroutetoenemy) == nil then
							self.returningtopatrol = false
						end
					end --When there
				end
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
			elseif isfunction(self.v.SetThrottle) and not self.v.IsGlideVehicle then
				self.v:SetThrottle(throttle)
				self.v:SetSteering(steer, 0)
			elseif self.v.IsGlideVehicle then
				if cffunctions then
					CFtoggleNitrous( self.v, self.usenitrous )
				end
				self.v:TriggerInput("Throttle", throttle)
				self.v:TriggerInput("Brake", throttle * -1)
				steer = steer * 2 --Attempt to make steering more sensitive.
				self.v:TriggerInput("Steer", steer)
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
			
			local timeout = 1
			if timeout and timeout > 0 then
				if CurTime() > self.moving + timeout and not UVTargeting then --If it has got stuck for enough time.
					self.invincible = true
					self.stuck = true
					self.moving = CurTime()
					timer.Simple(1, function() if IsValid(self.v) then self.invincible = nil end end)
					timer.Simple(1, function() if IsValid(self.v) then self.stuck = nil end end)
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

	function ENT:ApplyUnitDifficulty(multiplier, catchup)
		if not IsValid(self.v) then return end

		local mult = multiplier or 1 + (GetConVar("unitvehicle_unitdifficulty"):GetFloat() or 0)

		if catchup then
			mult = mult * 2
		end

		if mult == self.perfmult then return end

		UVSetVehiclePerformanceMultiplier(self.v, mult, catchup)
		self.perfmult = mult
	end
	
	function ENT:Think()
		-- if UVTargeting then return end
		self:SetPos(self.v:GetPos() + (vector_up * 50))
		self:SetAngles(self.v:GetPhysicsObject():GetAngles()+Angle(0,180,0))
		
		if not self.spawned and not self.damaged then
			if self.v.IsGlideVehicle then
				if self.v:GetEngineHealth() <= 0.5 then
					self.damaged = true
					if Chatter:GetBool() and self.v.rammed then
						UVChatterDamaged(self)
					end
				end
			elseif self.v.IsSimfphyscar then
				if self.v:GetCurHealth() <= self.v:GetMaxHealth()/2 then
					self.damaged = true
					if Chatter:GetBool() and self.v.rammed then
						UVChatterDamaged(self)
					end
				end
			elseif not vcmod_main then
				if self.v:Health() <= self.v:GetMaxHealth()/4 then 
					self.damaged = true
					if Chatter:GetBool() and self.v.rammed then
						UVChatterDamaged(self)
					end
				end
			else
				if self.v:GetClass() == "prop_vehicle_jeep" and self.v:VC_GetHealth(true) < 25 then
					self.damaged = true
					if Chatter:GetBool() and self.v.rammed then
						UVChatterDamaged(self)
					end
				end
			end
		end
		
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
		
		if not UVTargeting then
			self.bountytimer = CurTime() --Bounty parameters
		end
		
		--Target nearest enemy/remove when marked for deletion
		if IsValid(self.e) then
			local closestsuspect
			local closestdistancetosuspect
			local suspects = UVWantedTableVehicle
			local r = math.huge
			local closestdistancetosuspect, closestsuspect = r^2
			for i, w in pairs(suspects) do
				local unitpos = self.v:WorldSpaceCenter()
				local distance = unitpos:DistToSqr(w:WorldSpaceCenter())
				if distance < closestdistancetosuspect then
					closestdistancetosuspect, closestsuspect = distance, w
				end
			end
			if closestsuspect ~= self.e and self:StraightToTarget(closestsuspect) then
				self.e = closestsuspect
				UVAddToWantedListVehicle(self.e)
				if not closestsuspect.UVWanted then
					closestsuspect.UVWanted = closestsuspect
				end
				if isfunction(self.e.GetDriver) and IsValid(UVGetDriver(self.e)) and UVGetDriver(self.e):IsPlayer() then 
					self.edriver = UVGetDriver(self.e)
					UVAddToWantedListDriver(self.edriver)
				else
					self.edriver = nil
				end
				if not self.spawncooldown then
					self.v:SetNoDraw(false)
					self.v:SetCollisionGroup(0)
				end
				UVCalm = nil
				local chatterchance = math.random(1,10)
				if chatterchance == 1 and Chatter:GetBool() and IsValid(self.v) then
					UVChatterFoundMultipleEnemies(self) 
				end
			end
			if UVTargeting and closestdistancetosuspect > 100000000 and not self:StraightToTarget(closestsuspect) and 
			not UVEnemyBusted and not UVEnemyEscaped and self.uvmarkedfordeletion then
				if not OptimizeRespawn:GetBool() or (UVResourcePoints <= (#ents.FindByClass("npc_uv*")) and #ents.FindByClass("npc_uv*") ~= 1) then
					SafeRemoveEntity(self)
				else
					UVOptimizeRespawn(self.v)
				end
				if Chatter:GetBool() and IsValid(self.v) and not UVEnemyEscaping and not self.invincible and not UVEnemyBusted then
					UVChatterLeftPursuit(self) 
				end
			end
		end
		
		if not self:Validate(self.e) then --If it doesn't have an enemy.

			self:ApplyUnitDifficulty(1)

			if UVEnemyBusted and #UVWantedTableVehicle == 0 then --Stop moving
				self:Stop()
			else --Patrol
				self:Patrol()
				if self.v.roadblocking and not self.spawned then
					self.v.roadblocking = nil
				end
			end
			
			if UVEnemyBusted then
				self.moving = CurTime()
			end
			self.rdeploying = CurTime()
			--self.bountytimer = CurTime()
			
			if UVTargeting then 
				local enemy = self:TargetEnemyAdvanced() --Find an ongoing pursuit.
				if IsValid(enemy) then
					self.idle = nil
					self.e = enemy
					UVAddToWantedListVehicle(self.e)
					if not enemy.UVWanted then
						enemy.UVWanted = enemy
					end
					if isfunction(self.e.GetDriver) and IsValid(UVGetDriver(self.e)) and UVGetDriver(self.e):IsPlayer() then 
						self.edriver = UVGetDriver(self.e)
						UVAddToWantedListDriver(self.edriver)
					else
						self.edriver = nil
					end
					self.moving = CurTime()
					self.toofar = nil 
					if Chatter:GetBool() and IsValid(self) then
						if self.v.roadblocking then
							UVChatterRoadblockDeployed(self)
						else
							UVChatterResponding(self)
						end
					end
				end
			else
				local enemy = self:TargetEnemy() --Find an enemy.			
				if IsValid(enemy) then
					self.e = enemy
					UVAddToWantedListVehicle(self.e)
					if not enemy.UVWanted then
						enemy.UVWanted = enemy
					end
					if isfunction(self.e.GetDriver) and IsValid(UVGetDriver(self.e)) and UVGetDriver(self.e):IsPlayer() then 
						self.edriver = UVGetDriver(self.e)
						UVAddToWantedListDriver(self.edriver)
						else
						self.edriver = nil
					end
					self.moving = CurTime()
					UVLosing = CurTime()
					self.idle = nil
					timer.Simple(15, function() 
						UVTrafficStop = false
						if UVCalm and IsValid(self.e) and not UVHUDBusting then
							if UVTargeting then return end
							UVRestoreResourcePoints()
							UVTargeting = true
							if IsValid(self) then
								UVChatterPursuitStartRanAway(self)
							end
							UVLosing = CurTime()
							if Photon and isfunction(self.v.ELS_ManualSiren) then
								self.v:ELS_ManualSiren(false)
							end
							self:ChangeELSSiren()
						end
					end)
					self.toofar = nil
					self.aggressive = nil
					if (UVBounty >= GetConVar( 'unitvehicle_unit_heatminimumbounty1' ):GetInt() or self.e.uvraceparticipant) and not UVTargeting and not UVEnemyBusted then
						timer.Simple(0.1, function()
							if UVTargeting then return end
							UVTargeting = true
							if Chatter:GetBool() and IsValid(self) then
								UVChatterPursuitStartWanted(self)
							end
						end)
						return
					end
					if UVTrafficStop then return end
					if isfunction(self.e.GetDriver) and IsValid(UVGetDriver(self.e)) and UVGetDriver(self.e):IsPlayer() then 
						--UVGetDriver(self.e):PrintMessage( HUD_PRINTCENTER, "PULL OVER TO PAY A FINE!")
						if UVGetDriver(self.e) and UVGetDriver(self.e):IsPlayer() then
							net.Start( "UVPullOver" )
							net.Send(UVGetDriver(self.e))
						end
					end
					if not UVCalm then
						UVCalm = true
					end
					if not self.v.rammed then
						if Chatter:GetBool() and IsValid(self.v) then
							UVChatterTrafficStopSpeeding(self)
						end
					else
						if Chatter:GetBool() and IsValid(self.v) then
							UVChatterTrafficStopRammed(self) 
						end
					end
					UVTrafficStop = true
				end
			end 
			
			self.idle = true
			
			if self.chasing and IsValid(self.e) then
				self.chasing = nil
			end
			
			if not self.toofar then
				self.toofar = true
			end
			
			if table.HasValue(UVUnitsChasing, self) then
				table.RemoveByValue(UVUnitsChasing, self)
			end
			
		else --It does.
			
			self.chasing = true
			
			if self.idle then
				self.idle = nil
			end
			
			--Drive the vehicle.
			--Set handbrake off.		
			
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
			
			--Figures
			local edist --Fixed/Varied distance between the vehicle and the enemy.
			if not self.formationpoint then
				edist = self.e:WorldSpaceCenter() - self.v:WorldSpaceCenter()
			else
				edist = self.e:LocalToWorld(self.formationpoint) - self.v:WorldSpaceCenter()
			end

			local eedist = self.e:WorldSpaceCenter() - self.v:WorldSpaceCenter() --Fixed distance between the vehicle and the enemy.

			local selfvelocity = self.v:GetVelocity():LengthSqr()
			local enemyvelocity = self.e:GetVelocity():LengthSqr()

			local forward = self.v.IsSimfphyscar and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward() or self.v:GetForward()

			-- pursuit tactic
			local enemyVel = self.e:GetVelocity()
			local enemyVelLenSqr = enemyVel:LengthSqr()
			local eedistNorm = eedist:GetNormalized()
			local suspectPulledOver = enemyVelLenSqr <= UVBustSpeed * 10
			local suspectHeadingTowardNPC = enemyVelLenSqr > 30976 and enemyVel:GetNormalized():Dot(eedistNorm) < -0.3
			local suspectHeadingAwayFromNPC = enemyVelLenSqr > 30976 and enemyVel:GetNormalized():Dot(eedistNorm) > 0.3
			local suspectBehindNPC = eedist:Dot(forward) < 0
			local suspectSameDirectionAsNPC = enemyVelLenSqr > 30976 and enemyVel:GetNormalized():Dot(forward) > 0.5

			local suspectOnWaypointGrid = true
			if dvd and next(dvd.Waypoints or {}) ~= nil then
				local suspectPos = self.e:WorldSpaceCenter()
				local nearestToSuspect = dvd.GetNearestWaypoint(suspectPos)
				if nearestToSuspect then
					local waypointSize = dvd.WaypointSize or 200
					local maxDistSqr = waypointSize ^ 4
					suspectOnWaypointGrid = nearestToSuspect.Target:DistToSqr(suspectPos) <= maxDistSqr
				else
					suspectOnWaypointGrid = false
				end
			end

			self.tableroutetoenemy = self.tableroutetoenemy or {}
			local suspectInView = not UVEnemyEscaping and self:StraightToTarget(self.e, true, DVWaypointsDistanceBased:GetBool() and 4000000)
			local useDirectDriveBranch = suspectInView and (suspectHeadingAwayFromNPC or suspectPulledOver or not suspectOnWaypointGrid)
			local followSuspectHeadingOnGrid = suspectOnWaypointGrid and suspectBehindNPC and suspectSameDirectionAsNPC
			
			if useDirectDriveBranch then
				if (not suspectOnWaypointGrid or suspectHeadingAwayFromNPC or suspectPulledOver) and next(self.tableroutetoenemy) ~= nil then
					self.tableroutetoenemy = {}
				end
				if self.NavigateBlind then
					self.NavigateBlind = nil
				end
				if self.NavigateCooldown then
					self.NavigateCooldown = nil
					timer.Remove(self._cooldownString)
				end
				if (not self.formationpoint or enemyvelocity <= UVBustSpeed * 10)
					or UVCalm or UVEnemyEscaping or self:ObstaclesNearbySide() then
					if not self.driveinfront or self:ObstaclesNearbySide() then
						self.targetpos = self.e:WorldSpaceCenter()
					else
						self.targetpos = (self.e:WorldSpaceCenter() + self.e:GetVelocity())
					end
				else
					self.targetpos = (self.e:LocalToWorld(self.formationpoint) + self.e:GetVelocity())
				end
			elseif followSuspectHeadingOnGrid then
				local suspectPos = self.e:WorldSpaceCenter()
				local suspectDir = enemyVelLenSqr > 0 and enemyVel:GetNormalized() or forward
				local aheadDist = 2000
				local aheadTarget = suspectPos + suspectDir * aheadDist

				local myPos = self.v:WorldSpaceCenter()
				local Waypoint, WaypointID = dvd.GetNearestWaypoint(myPos)
				
				self.targetpos = myPos + suspectDir * 2000

				if Waypoint and Waypoint.Target then

					-- searches for waypoints that are neighboring the nearest waypoint to unit (right way)
					local laneStart = Waypoint.Target
					local neighborTarget

					local bestDot = -1

					if Waypoint.Neighbors then	
						for _, n in ipairs( Waypoint.Neighbors ) do
							local waypoint = dvd.Waypoints[n]

							local dir = ( waypoint.Target - laneStart ):GetNormalized()
							local dot = dir:Dot( suspectDir )

							if dot > bestDot then
								bestDot = dot
								neighborTarget = waypoint.Target
							end
						end
					end

					-- if we can't find any viable neighbors then we can assume that the pursuit is going the wrong way,
					-- for which we must look for waypoints that connect to the nearest waypoint
					-- (tried to keep it optimized ¯\_(ツ)_/¯)
					if 0 > bestDot then
						local possibleNeighbors = {}
						local bestDot = -1
						
						for _, waypoint in ipairs( dvd.Waypoints ) do
							if not waypoint.Neighbors then continue end
							if not table.HasValue( waypoint.Neighbors, WaypointID ) then continue end
							
							local direction = ( waypoint.Target - laneStart ):GetNormalized()
							local dot = direction:Dot( suspectDir )
							
							if dot > bestDot then
								bestDot = dot
								neighborTarget = waypoint.Target
							end
						end
					end

					if neighborTarget then
						self.targetpos = neighborTarget
					else
						self.targetpos = myPos + suspectDir * 2000
					end
				end

			elseif next(self.tableroutetoenemy) ~= nil and #self.tableroutetoenemy > 1 then
				self.targetpos = self:DriveOnPath()
				if next(self.tableroutetoenemy) == nil then
					self.targetpos = self.e:WorldSpaceCenter()
				else
					local toTarget = self.targetpos - self.v:WorldSpaceCenter()
					if toTarget:LengthSqr() < 10000 then
						self.tableroutetoenemy = {}
						self.targetpos = self.e:WorldSpaceCenter()
					end
				end
			else
				self:PathFindToEnemy(self.e:WorldSpaceCenter())
				if next(self.tableroutetoenemy) ~= nil and #self.tableroutetoenemy > 1 then
					self.targetpos = self:DriveOnPath()
					if next(self.tableroutetoenemy) == nil then
						self.targetpos = self.e:WorldSpaceCenter()
					else
						local toTarget = self.targetpos - self.v:WorldSpaceCenter()
						if toTarget:LengthSqr() < 10000 then
							self.tableroutetoenemy = {}
							self.targetpos = self.e:WorldSpaceCenter()
						end
					end
				else
					if self.NavigateBlind then
						self.NavigateBlind = nil
					end
					if self.NavigateCooldown then
						self.NavigateCooldown = nil
						timer.Remove(self._cooldownString)
					end
					if (not self.formationpoint or enemyvelocity <= UVBustSpeed * 10)
						or UVCalm or UVEnemyEscaping or self:ObstaclesNearbySide() then
						if not self.driveinfront or self:ObstaclesNearbySide() then
							self.targetpos = self.e:WorldSpaceCenter()
						else
							self.targetpos = (self.e:WorldSpaceCenter() + self.e:GetVelocity())
						end
					else
						self.targetpos = (self.e:LocalToWorld(self.formationpoint) + self.e:GetVelocity())
					end
				end
			end
			
			--Driving techniques
			forward = self.v.IsSimfphyscar and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward() or self.v:GetForward() --Forward vector (reuse from above).
			local dist = self.targetpos - self.v:WorldSpaceCenter() --Varied distance between the vehicle and the enemy.
			local vect = dist:GetNormalized() --Enemy direction vector.
			local vectdot = vect:Dot(self.v:GetVelocity()) --Dot product, velocity and direction.
			local throttle = dist:Dot(forward) > 0 and 1 or -1 --Throttle depends on their positional relationship.
			local right = vect:Cross(forward) --The enemy is right side or not.
			local steer_amount = right:Length() --Steering parameter/sensitivity.
			local steer = right.z > 0 and steer_amount or -steer_amount --Actual steering parameter.
			local evect = edist:GetNormalized() --Fixed enemy direction vector.
			local eevectdot = evect:Dot(self.v:GetVelocity()) --Fixed dot product, velocity and direction.
			local eeright = evect:Cross(forward) --Fixed value for when enemy is right side or not.
			local evectdot = vect:Dot(self.e:GetVelocity()) --Enemy's dot product, velocity and direction.
			local eeevectdot = evect:Dot(self.e:GetVelocity()) --Fixed enemy's dot product, velocity and direction.
			local eforward = self.e.IsSimfphyscar and --Forward vector.
			self.e:LocalToWorldAngles(self.e.VehicleData.LocalAngForward):Forward() or self.e:GetForward() --Enemy foward vector
			local eright = vect:Cross(eforward) --The pursuer is right side or not
			local eevect = eedist:GetNormalized() --Fixed enemy direction vector.
			local eeeright = eevect:Cross(forward) --Fixed value for when enemy is right side or not.
			local ph = self.v:GetPhysicsObject() --Get pursuer's physics
			if not (ph and IsValid(ph)) then return end
			local eph = self.e:GetPhysicsObject() --Get enemy's physics
			if not (eph and IsValid(eph)) then return end
			
			--Unique driving techniques
			if (UVEnemyEscaping or not self:StraightToTarget(self.e, true)) and not self.stuck then
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
				if not self.invincible then
					self.invincible = true
				end
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
				if self.v.IsSimfphyscar then
					if self:ObstaclesNearby() then
						if self.v:GetGear() >= 3 then
							throttle = -1
						else
							throttle = 1
						end
					end
				elseif self.v.IsGlideVehicle then
					if self:ObstaclesNearby() then
						if self.v:GetGear() >= 1 then
							throttle = -1
						else
							throttle = 1
						end
					end
				end --Slow down
			elseif (dist:LengthSqr() > 250000 or dist:LengthSqr() < 250000 and not self:StraightToTarget(self.e, true)) and self.stuck then --No eyes on the target
				if right.z > 0 then steer = -1 else steer = 1 end
				if UVEnemyEscaping then throttle = -1 else throttle = throttle * -1 end
			else --Getting unstuck
				if edist:Dot(forward) < 0 and (edist:Length2DSqr() > 100000 or self.formationpoint) and eevectdot < 0 then
					if eeevectdot > 0 or enemyvelocity < 100000 then
						throttle = 0
						if self.v.IsSimfphyscar or self.v.IsGlideVehicle then
							self:UVHandbrakeOn()
						end
						if right.z < 0 then steer = -1 else steer = 1 end 
					else 
						if (enemyvelocity/1.25) > selfvelocity then 
							throttle = 1 
						else
							if self.v.IsSimfphyscar or self.v.IsGlideVehicle then
								throttle = throttle * -1
							else
								throttle = 0
							end
						end
						if self:ObstaclesNearby() then
							throttle = -1
						end --Slow down
					end
				end --U turn/rolling roadblock
				if dist:Dot(forward) < 0 and dist:Length2DSqr() > 250000 and vectdot > 0 and not self.stuck then
					if eeevectdot > 0 or enemyvelocity < 100000 then
						if right.z > 0 then steer = -1 else steer = 1 end
					else
						throttle = throttle * -1
					end
				end --K/J turn
				if eeeright.z > -0.2 and eeeright.z < 0.2 and eeevectdot < 0 and eedist:Dot(forward) < 0 and eedist:Length2DSqr() < 250000 and self.aggressive then
					throttle = -1
				end --Brake checking
				if selfvelocity > enemyvelocity and edist:Dot(forward) > 0 and edist:Dot(eforward) > 0 and eevectdot > 0 and eeevectdot > 0 and edist:Length2DSqr() < 100000 and enemyvelocity > 250000 and not UVCalm then
					if not self.aggressive and not self.formationpoint then throttle = 0 end
				end --PIT technique/get infront
				if enemyvelocity < 100000 and dist:Length2DSqr() < selfvelocity then
					if self.v.IsSimfphyscar or self.v.IsGlideVehicle then
						throttle = throttle * -1
					else
						self:UVHandbrakeOn()
					end
				end --Slow down when enemy's stopped
				if evectdot < 0 and enemyvelocity > 100000 and dist:Dot(forward) > 0 and throttle > 0 and (self:StraightToTarget(self.e, true) or not self.aggressive) then
					if selfvelocity > 123904 then throttle = 0 end
					if dist:Dot(eforward) < 0 then
						if eright.z < 0 then steer = 1 else steer = -1 end
					else
						if eright.z < 0 then steer = -1 else steer = 1 end
					end
					if self.aggressive then self:SetHorn(true) end
				elseif not self.ramming then
					self:SetHorn(false)
				end --Head-on slam
				if dist:Dot(forward) < 0 and vectdot < 0 and evectdot < 0 and dist:Dot(eforward) < 0 and enemyvelocity > 100000 then 
					steer = eright.z 
					if dist:Length2DSqr() > 250000 and eright.z < 0.5 and eright.z > -0.5 then if right.z > 0.75 then steer = -1 elseif right.z < -0.75 then steer = 1 end end
				end --Herding
				if UVCalm and edist:Length2DSqr() < 250000 and evectdot > 0 then
					throttle = 0
				end --No ramming
				if (self.v.IsSimfphyscar or self.v.IsGlideVehicle) and eedist:LengthSqr() < 6250000 and (selfvelocity/2) > enemyvelocity and enemyvelocity > 100000 then
					throttle = -1
				end --Slow down when enemy slows down
				
				--If the vehicle is too close to the enemy...  
				if (edist:Length2DSqr() < 100000 and eevectdot < 0 and enemyvelocity > 100000 and eeevectdot < 0) and not self.formationpoint and not self:ObstaclesNearbySide() then 
					if not self.driveinfront and not self.formationpoint then
						if selfvelocity > enemyvelocity then
							throttle = 0
						else
							throttle = 1
						end
					else
						if selfvelocity < enemyvelocity then 
							throttle = 1 
						else
							throttle = 0
						end
					end
				end --Herding technique
				if enemyvelocity < 30976 and dist:Length2DSqr() < 100000 and self:StraightToTarget(self.e, true) then
					throttle = 0 
					if vectdot < 0 or eright.z > -0.2 and eright.z < 0.2 or UVCalm then self:UVHandbrakeOn() end
				end --Pinning/boxing in
				if self.invincible then
					self.invincible = nil
				end
			end
			
			--Roadblocking
			if self.v.roadblocking then
				self:UVHandbrakeOn()
				if not self.v.roadblockingmissed and eeevectdot > 0 and self.v.roadblocking and self:StraightToTarget(self.e, true) then
					self.v.roadblockingmissed = true
					
					if self.v.disperse then
						self.v.roadblocking = nil
					end

					if Chatter:GetBool() then
						UVChatterRoadblockMissed(self)
					end
				end
			end
		
			--Awareness to friendly vehicles
			local t = UVUnitVehicles
			local distance, nearest = math.huge, nil --The nearest friendly.
			for k, f in pairs(t) do
				if f ~= self.v and IsValid(f) then --Friendly conditions
					local d = f:WorldSpaceCenter():DistToSqr(self.v:WorldSpaceCenter())
					if distance > d then
						distance = d
						nearest = f --Friendly
						local fforward = f.IsSimfphyscar and f:LocalToWorldAngles(f.VehicleData.LocalAngForward):Forward() or f:GetForward() --Forward vector.
						local fdist = f:WorldSpaceCenter() - self.v:WorldSpaceCenter() --Distance between the vehicle and the friendly.
						local fedist = self.e:WorldSpaceCenter() - f:WorldSpaceCenter() --Distance between the enemy and the friendly.
						local fvect = fdist:GetNormalized() --Friendly direction vector.
						local fvectdot = fvect:Dot(self.v:GetVelocity()) --Dot product, velocity and direction.
						local fright = fvect:Cross(forward) --The friendly is right side or not.
						if dist:LengthSqr() > fedist:LengthSqr() then
							if fvectdot > 0 then
								if UVCalm and fdist:LengthSqr() < 100000 then
									throttle = -1
								elseif fdist:LengthSqr() < 100000 and enemyvelocity > 200000 and not self.formationpoint then
									throttle = -1
								end
							end
						end -- Follow behind
						if fvectdot > 0 and f:GetVelocity():LengthSqr() < (UVBustSpeed*2) and dist:LengthSqr() < 2500000 and selfvelocity > fdist:LengthSqr() and enemyvelocity < (UVBustSpeed*2) then
							if fright.z < 0.1 and fright.z > -0.9 then
								steer = 1
							end
							if fright.z > -0.1 and fright.z < 0.9 then 
								steer = -1
							end
						end -- Surronding target vehicles
					end
				end
			end	

			--Busting 
			local btimeout = GetConVar("unitvehicle_bustedtimer"):GetFloat()

			--Resetting
			if not (selfvelocity < 10000 and (throttle > 0 or throttle < 0)) then --Reset conditions.
				self.moving = CurTime()
			end
			if self.displaybusting then
				self.moving = CurTime()
			end
			if self.stuck then 
				self.moving = CurTime()
				if selfvelocity > 100000 and vectdot > 0 and not UVEnemyEscaping then
					self.stuck = nil
				end
			end

			local timeout = 1
			if timeout and timeout > 0 then
				if CurTime() > self.moving + timeout then --If it has got stuck for enough time.
					self.invincible = true
					self.stuck = true
					self.moving = CurTime()
					timer.Simple(2, function() if IsValid(self.v) then self.invincible = nil end end)
					timer.Simple(1, function() if IsValid(self.e) then self.stuck = nil self:PathFindToEnemy(self.e:WorldSpaceCenter()) end end)
				end
			end

			--First encounter with enemy
			if not self.metwithenemy and edist:LengthSqr() < 25000000 and self:StraightToTarget(self.e) then
				self.metwithenemy = true
				if Chatter:GetBool() and IsValid(self.v) and UVTargeting and not UVEnemyEscaping and not self.v.roadblocking and not self.v.disperse then
					UVChatterOnScene(self) 
				end
			end

			--Spawning
			if self.toofar and edist:LengthSqr() < 25000000 and self:StraightToTarget(self.e) then
				if not self.spawncooldown then
					timer.Simple(1, function() if IsValid(self.v) then self.invincible = nil end end)
					self.invincible = true
					self.toofar = nil
					self:ChangeELSSiren()
					--if ph:GetAngles().z > 90 and ph:GetAngles().z < 270 then self.v:PointAtEntity(self.e) end
				end	
			end
			
			--Bounty
			local botimeout = 10
			if botimeout then
				if CurTime() > self.bountytimer + botimeout then
					self.bountytimer = CurTime()
					local aggressive = math.random(0,1)
					if aggressive == 0 then
						self.driveinfront = nil
					else
						self.driveinfront = true
					end
					local MathAggressive = math.random(1,10) 
					if MathAggressive == 1 then
						if not self.aggressive and UVTargeting then
							self.aggressive = true
							if Chatter:GetBool() and IsValid(self.v) and self:StraightToTarget(self.e) and not UVCalm then
								UVChatterAggressive(self) 
							end
						else
							self.aggressive = nil
							if Chatter:GetBool() and IsValid(self.v) and self:StraightToTarget(self.e) and not UVCalm then
								UVChatterPassive(self) 
							end
						end
					elseif MathAggressive == 2 then
						if Chatter:GetBool() and HeatLevels:GetBool() and IsValid(self.v) and not UVCalm and #UVUnitsChasing == 1 then
							UVChatterRequestBackup(self)
						end
					elseif MathAggressive == 3 then
						if Chatter:GetBool() and IsValid(self.v) and not UVCalm then
							UVChatterRequestSitrep(self)
						end
					else
						local MathAggressive2 = math.random(1,10)
						if Chatter:GetBool() and MathAggressive2 == 1 and not UVEnemyEscaping then
							UVChatterRequestDisengage(self)
						end
					end
					if isfunction(self.e.GetDriver) and IsValid(UVGetDriver(self.e)) and UVGetDriver(self.e):IsPlayer() then 
						self.edriver = UVGetDriver(self.e)
						UVAddToWantedListDriver(self.edriver)
					else
						self.edriver = nil
					end
					local MathSiren = math.random(1,100)
					if MathSiren < 30 then
						self:ChangeELSSiren()
					end
					if Chatter:GetBool() and IsValid(self.v) and enemyvelocity > 100000 and self:StraightToTarget(self.e) and MathAggressive ~= 1 then
						UVChatterCloseToEnemy(self, self.e) 
					end
				end
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
					if not UVEnemyEscaping and self:StraightToTarget(self.e, true) and self.metwithenemy and not self.stuck then
						if math.abs(steer) > 0.5 and selfvelocity > 100000 and enemyvelocity < selfvelocity then
							if self.v:GetGear() >= 3 then
								throttle = -1
							else
								throttle = 1
							end
						end --Cornering
					end
				elseif self.v.IsGlideVehicle then
					local maxSlip = 0
					for _, wheel in ipairs(self.v.wheels) do
						maxSlip = math.max(maxSlip, math.abs(wheel:GetForwardSlip() or 0))
					end
					local minThrottle = 0.5
					local recoverRate = FrameTime()
					self.AI_ThrottleMul = self.AI_ThrottleMul or 1
					if maxSlip > 8 then
						self.AI_ThrottleMul = math.max(self.AI_ThrottleMul - FrameTime()*2, minThrottle)
					else
						self.AI_ThrottleMul = math.min(self.AI_ThrottleMul + recoverRate, 1)
					end
					throttle = throttle * self.AI_ThrottleMul --Glide traction control
					self.usenitrous = UVCFEligibleToUse(self) and self.AI_ThrottleMul == 1 and true or false
					if dist:Length2DSqr() > 250000 and vectdot < 0 and dist:Dot(forward) > 0 and (right.z > 0.75 or right.z < -0.75) and not self.stuck then
						steer = 0
						throttle = 1
					end --Straighten out
					if not UVEnemyEscaping and self:StraightToTarget(self.e, true) and self.metwithenemy and not self.stuck then
						if math.abs(steer) > 0.5 and selfvelocity > 100000 and enemyvelocity < selfvelocity then
							if self.v:GetGear() >= 1 then
								throttle = -1
							else
								throttle = 1
							end
						end --Cornering
					end
				else
					if vectdot > 0 and evectdot > 0 and dist:Dot(forward) > 0 and dist:Length2DSqr() > 250000 and self:StraightToTarget(self.e, true) then 
						local maththrottle = throttle - math.abs(steer)
						if maththrottle >= 0 then
							throttle = maththrottle
						end
					end --Cornering
				end
			end
			
			if self.v.roadblocking then
				throttle = 0
				steer = 0
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
			elseif isfunction(self.v.SetThrottle) and not self.v.IsGlideVehicle then
				self.v:SetThrottle(throttle)
				self.v:SetSteering(steer, 0)
			elseif self.v.IsGlideVehicle then
				if cffunctions then
					CFtoggleNitrous( self.v, self.usenitrous )
				end
				self.v:TriggerInput("Throttle", throttle)
				self.v:TriggerInput("Brake", throttle * -1)
				steer = steer * 2 --Attempt to make steering more sensitive.
				self.v:TriggerInput("Steer", steer)
			end
			
			--Losing conditions
			local visualrange = 25000000
			if UVHiding then
				visualrange = 1000000
			end
			if self:VisualOnTarget(self.e) and eedist:LengthSqr() < visualrange then
				UVLosing = CurTime()
				self:ApplyUnitDifficulty()
				if not table.HasValue(UVUnitsChasing, self) then
					table.insert(UVUnitsChasing, self)
				end
			else
				self:ApplyUnitDifficulty(nil, Catchup:GetBool() and (CurTime() - (self.__spawn_time or 0) > 3))
				if table.HasValue(UVUnitsChasing, self) then
					table.RemoveByValue(UVUnitsChasing, self)
				end
			end
			
			--Set ELS
			self:SetELS(true)
			self:SetELSSound(true)
			
			--When too far to chase enemy
			if edist:LengthSqr() > 25000000 and not self.toofar and not self:VisualOnTarget(self.e) then
				self.toofar = true
			end
			
		end --if not self:Validate(self.e)
		
		--Targeting
		--if IsValid(self.e) and not UVTargeting and not UVCalm then
		--	UVTargeting = true
		--end
		
	end
	
	function ENT:Initialize()
		if next(dvd.Waypoints) == nil then
			net.Start("UV_OpenDVWarning")
			net.Broadcast() -- or target a specific player
			SafeRemoveEntity(self)
			return
		end

		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetModel(self.Modelname)
		self:SetHealth(-1)
		self.bountytimer = CurTime()
		-- self.callsign = "uv.unit.support"..self:EntIndex()
		self.type = "support"
		self.callsign = "uv.unit.support"
		self.moving = CurTime()
		self.deploying = CurTime()
		self.rdeploying = CurTime()
		self.ks = CurTime()
		self.heli = CurTime()
		self.stuck = nil
		self.spawned = true
		self.toofar = true
		self.perfmult = 1

		local selectedVoice = GetConVar("unitvehicle_unit_support_voice"):GetString()
		local splittedText = string.Explode( ",", selectedVoice )

		local ya = {}

		for k, v in pairs( splittedText ) do
			table.insert( ya, string.Trim( v ) )
		end
		
		self._cooldownString = "NavigateCooldown_Entity"..self:EntIndex()
		self.voice = ya[math.random(1, #ya)]
		
		UVCalm = nil
		UVEnemyBusted = nil
		UVEnemyEscaped = nil
		UVRCooldown = nil
		local aggressive = math.random(0,1)
		if aggressive == 0 then
			self.driveinfront = nil
		else
			self.driveinfront = true
		end
		local MathAggressive = math.random(0,1)
		if MathAggressive == 1 then
			self.aggressive = true
		end
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
			if v.UnitVehicle and v.UnitVehicle:IsNPC() then return end
			if v.IsScar then --If it's a SCAR.
				if not v:HasDriver() then --If driver's seat is empty.
					self.v = v
					v.uvclasstospawnon = self:GetClass()
					v.UVSupport = self
					v.UnitVehicle = self
					v.HasDriver = function() return true end --SCAR script assumes there's a driver.
					v.SpecialThink = function() end --Tanks or something sometimes make errors so disable thinking.
					v:StartCar()
				end
			elseif v.IsSimfphyscar and v:IsInitialized() then --If it's a Simfphys Vehicle.
				if not IsValid(v:GetDriver()) then --Fortunately, Simfphys Vehicles can use GetDriver()
					self.v = v
					v.uvclasstospawnon = self:GetClass()
					v.UVSupport = self
					v.UnitVehicle = self
					v:SetActive(true)
					v:StartEngine()
					if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then
						v:SetLightsEnabled(true)
					end
					v:SetBulletProofTires(true)
				end
			elseif isfunction(v.EnableEngine) and isfunction(v.StartEngine) and not v.IsGlideVehicle then --Normal vehicles should use these functions. (SCAR and Simfphys cannot.)
				if isfunction(v.GetWheelCount) and v:GetWheelCount() and not IsValid(v:GetDriver()) then
					self.v = v
					v.uvclasstospawnon = self:GetClass()
					v.UVSupport = self
					v.UnitVehicle = self
					v:EnableEngine(true)
					v:StartEngine(true)
				end
			elseif v.IsGlideVehicle then --Glide
				if not IsValid(v:GetDriver()) then
					self.v = v
					v.uvclasstospawnon = self:GetClass()
					v.UVSupport = self
					v.UnitVehicle = self
					v:SetEngineState(2)
					v.inputThrottleModifierMode = 2
					v.AirControlForce = vector_origin
					if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 and v.CanSwitchHeadlights then
						v:SetHeadlightState(1)
					end
					for k, v in pairs(v.wheels) do
						if v.params then
							v.params.isBulletProof = true
						end
					end
				end
			end
		else
			local distance = DetectionRange:GetFloat()
			for k, v in pairs(ents.FindInSphere(self:GetPos(), distance)) do
				if v:GetClass() == 'prop_vehicle_prisoner_pod' then continue end
				if v.UnitVehicle and v.UnitVehicle:IsNPC() then continue end
				if v:IsVehicle() then
					if v.IsScar then --If it's a SCAR.
						if not v:HasDriver() then --If driver's seat is empty.
							self.v = v
							v.uvclasstospawnon = self:GetClass()
							v.UVSupport = self
							v.UnitVehicle = self
							v.HasDriver = function() return true end --SCAR script assumes there's a driver.
							v.SpecialThink = function() end --Tanks or something sometimes make errors so disable thinking.
							v:StartCar()
						end
					elseif v.IsSimfphyscar and v:IsInitialized() then --If it's a Simfphys Vehicle.
						if not IsValid(v:GetDriver()) then --Fortunately, Simfphys Vehicles can use GetDriver()
							self.v = v
							v.uvclasstospawnon = self:GetClass()
							v.UVSupport = self
							v.UnitVehicle = self
							v:SetActive(true)
							v:StartEngine()
							if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then
								v:SetLightsEnabled(true)
							end
							v:SetBulletProofTires(true)
						end
					elseif isfunction(v.EnableEngine) and isfunction(v.StartEngine) and not v.IsGlideVehicle then --Normal vehicles should use these functions. (SCAR and Simfphys cannot.)
						if isfunction(v.GetWheelCount) and v:GetWheelCount() and not IsValid(v:GetDriver()) then
							self.v = v
							v.uvclasstospawnon = self:GetClass()
							v.UVSupport = self
							v.UnitVehicle = self
							v:EnableEngine(true)
							v:StartEngine(true)
						end
					elseif v.IsGlideVehicle then --Glide
						if not IsValid(v:GetDriver()) then
							self.v = v
							v.uvclasstospawnon = self:GetClass()
							v.UVSupport = self
							v.UnitVehicle = self
							v:TurnOn()
							v.inputThrottleModifierMode = 2
							v.AirControlForce = vector_origin
							if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 and v.CanSwitchHeadlights then
								v:SetHeadlightState(1)
							end
							for k, v in pairs(v.wheels) do
								if v.params then
									v.params.isBulletProof = true
								end
							end
						end
					end
				end
			end
		end
		
		if not IsValid(self.v) or not IsValid(self.v:GetPhysicsObject()) then SafeRemoveEntity(self) return end --When there's no vehicle, remove Unit Vehicle.
		UVDeploys = UVDeploys + 1

		if isfunction(self.v.UVVehicleInitialize) then --For vehicles that has a driver bodygroup
			self.v:UVVehicleInitialize()
		end

		if cffunctions then
			UVCFInitialize(self)
		end
		
		local deletiontime = self.v.roadblocking and 10 or 1
		local roadblockingtime = math.random(20,60)
		if self.uvscripted then
			timer.Simple(deletiontime, function()
				if IsValid(self) then
					self.uvmarkedfordeletion = true
				end
			end)
			timer.Simple(roadblockingtime, function()
				if IsValid(self.v) and self.v.roadblocking then
					self.v.roadblocking = nil
				end
			end)
		end
		
		if not self.uvscripted then
			local e = EffectData()
			e:SetEntity(self.v)
			util.Effect("propspawn", e) --Perform a spawn effect.
		end
		if not UVTargeting then self.v:EmitSound( "buttons/lever4.wav" ) end
		self.mass = math.Round(self.v:GetPhysicsObject():GetMass())
		if Chatter:GetBool() and IsValid(self.v) and not UVTargeting then
			UVChatterInitialize(self) 
		end
		
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

		self.v.rideheight = collisionmin.z
		
		local min, max = self.v:GetHitBoxBounds(0, 0) --NPCs aim at the top of the vehicle referred by hit box.
		if not isvector(max) then min, max = self.v:GetModelBounds() end --If getting hit box bounds is failed, get model bounds instead.
		if not isvector(max) then max = vector_up * math.random(80, 200) end --If even getting model bounds is failed, set a random value.
		
		local tr = util.TraceHull({start = self.v:GetPos() + vector_up * max.z, 
		endpos = self.v:GetPos(), ignoreworld = true,
		mins = Vector(-16, -16, -1), maxs = Vector(16, 16, 1)})
		self.CollisionHeight = tr.HitPos.z - self.v:GetPos().z
		if self.CollisionHeight < 10 then self.CollisionHeight = max.z end
		self.v:DeleteOnRemove(self)

		self.__spawn_time = CurTime()
		self.__entIndex = self:EntIndex()
		
		net.Start("UVHUDAddUV")
		net.WriteInt(self.v:EntIndex(), 32)
		net.WriteInt(self.v:GetCreationID(), 32)
		net.WriteString("unit")
		net.Broadcast()
		
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
