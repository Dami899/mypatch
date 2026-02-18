list.Set("NPC", "npc_racervehicle", {
	Name = "#uv.npc.0racer",
	Class = "npc_racervehicle",
	Category = "#uv.unitvehicles"
})
AddCSLuaFile("npc_racervehicle.lua")
include("entities/uvapi.lua")

ENT.Base = "base_entity"
ENT.Type = "ai"

ENT.PrintName = "RacerVehicle"
ENT.Author = "Razor"
ENT.Contact = "Romeo"
ENT.Purpose = "It ain't over until I say it's over."
ENT.Instruction = "Spawn on/under the vehicle until it shows a spawn effect."
ENT.Spawnable = false
ENT.Modelname = "models/props_lab/huladoll.mdl"

local dvd = DecentVehicleDestination

if SERVER then	
	--Setting ConVars.
	local DetectionRange = GetConVar("unitvehicle_detectionrange")
	local RacerPursuitTech = GetConVar("unitvehicle_racerpursuittech")

	function ENT:FindBestStartNode()
		if not self.v or not UVRace_CompiledPaths then return nil end

		local pos = self.v:WorldSpaceCenter()
		local forward = self.v.IsSimfphyscar
			and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward()
			or self.v:GetForward()

		-- degrees → dot thresholds
		local cones = {
			math.cos(math.rad(10)),
			math.cos(math.rad(15)),
			math.cos(math.rad(20)),
			math.cos(math.rad(30)),
		}

		local bestNode, bestDist

		for _, dotThreshold in ipairs(cones) do
			bestNode, bestDist = nil, math.huge

			for _, node in ipairs(UVRace_CompiledPaths) do
				local p = node.Points and node.Points[1]
				if not isvector(p) then continue end

				local dir = p - pos
				local dist = dir:LengthSqr()
				local ndir = dir:GetNormalized()

				if ndir:Dot(forward) < dotThreshold then continue end

				-- LOS check (prevents wall issues)
				if util.TraceLine({
					start = pos,
					endpos = p,
					mask = MASK_NPCWORLDSTATIC,
					filter = { self, self.v }
				}).Fraction < 1 then
					continue
				end

				if dist < bestDist then
					bestDist = dist
					bestNode = node
				end
			end

			if bestNode then
				return bestNode
			end
		end

		return nil
	end

	local function GetNextNode(current, forward)
		local bestNode = nil
		local closestDot = -math.huge
		for _, node in ipairs(current.Paths) do
			local dir = (node.Points[1] - current.Points[#current.Points]):GetNormalized()
			local dot = dir:Dot(forward)
			if dot > closestDot then
				closestDot = dot
				bestNode = node
			end
		end
		return bestNode or current.Paths[1]
	end

	function ENT:BuildNodePath(start)
		local path = {}
		local visited = {}
		local current = start

		while current and not visited[current] do
			visited[current] = true
			table.insert(path, current)

			if not current.Out or #current.Out == 0 then
				break
			end

			-- simple heuristic: choose most forward
			local best, bestDot = nil, -1
			local curDir = (current.Points[#current.Points] - current.Points[1]):GetNormalized()

			for _, nextNode in ipairs(current.Out) do
				local dir = (nextNode.Points[#nextNode.Points] - nextNode.Points[1]):GetNormalized()
				local dot = curDir:Dot(dir)
				if dot > bestDot then
					bestDot = dot
					best = nextNode
				end
			end

			current = best
		end

		return path
	end

	function ENT:StartNodeRace()
		if not self.v then return end

		local startNode = self:FindBestStartNode()
		if startNode then
			self.NodePath = self:BuildNodePath(startNode)
			self.CurrentNodeIndex = 1
			self.CurrentNode = self.NodePath[self.CurrentNodeIndex]
			self.NextNode = self.NodePath[self.CurrentNodeIndex + 1]
		else
			self.NodePath = nil
			self.CurrentNodeIndex = nil
			self.CurrentNode = nil
			self.NextNode = nil
		end
	end

	function GetClosestPoint(ent, pos, margin, safeDistance)
		if not IsValid(ent) then return nil end
		
		margin = margin or 1
		safeDistance = safeDistance or 100
		
		local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
		local localPos = ent:WorldToLocal(pos)
		
		local paddedMins = Vector(mins.x + margin, mins.y + margin, mins.z + margin)
		local paddedMaxs = Vector(maxs.x - margin, maxs.y - margin, maxs.z - margin)
		
		local clamped = Vector(
		math.Clamp(localPos.x, paddedMins.x, paddedMaxs.x),
		math.Clamp(localPos.y, paddedMins.y, paddedMaxs.y),
		math.Clamp(localPos.z, paddedMins.z, paddedMaxs.z))
		
		local worldPoint = ent:LocalToWorld(clamped)
		
		if pos:DistToSqr(worldPoint) < (safeDistance * safeDistance) then
			local forwardOffset = ent:GetForward() * 50
			return ent:GetPos() + forwardOffset
		end
		
		return worldPoint
	end
	
	local function ClosestPointOnLineSegment(p, a, b, padding)
		local ab = b - a
		local length = ab:Length()
		
		if length <= padding * 2 then
			return a + ab * 0.5
		end
		
		local dir = ab:GetNormalized()
		local a_padded = a + dir * padding
		local b_padded = b - dir * padding
		
		local ab_padded = b_padded - a_padded
		local t = ((p - a_padded):Dot(ab_padded)) / ab_padded:LengthSqr()
		t = math.Clamp(t, 0, 1)
		
		return a_padded + ab_padded * t
	end

	function ENT:OnRemove()
		--By undoing, driving, diving in water, or getting stuck, and the vehicle is remaining.
		if IsValid(self.v) and self.v:IsVehicle() then
			self.v.RacerVehicle = nil
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
				if self.v.uvbusted then
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
				if self.v.uvbusted then
					self.v:SetSteering(steerinput, 0)
				end
			elseif self.v.IsGlideVehicle then
				self.v:TurnOff()
				self.v:TriggerInput("Throttle", 0)
				if self.v.uvbusted then
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
			
			local e = EffectData()
			e:SetEntity(self.v)
			util.Effect("entity_remove", e) --Perform an effect.
			
		end
		
	end
	
	function ENT:StraightToRace(point)
		if not self.v or not self.e then
			return
		end
		local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = point, mask = MASK_NPCWORLDSTATIC, filter = {self, self.v, self.e}}).Fraction==1
		return tobool(tr)
	end
	
	function ENT:Stop()
		if self.v.IsScar then
			self.v:GoNeutral()
			self.v:NotTurning()
			self.v:HandBrakeOn()
		elseif self.v.IsSimfphyscar then
			self.v.PressedKeys = self.v.PressedKeys or {}
			self.v.PressedKeys["W"] = false
			self.v.PressedKeys["A"] = false
			self.v.PressedKeys["S"] = false
			self.v.PressedKeys["D"] = false
			self.v.PressedKeys["Shift"] = false
			self.v.PressedKeys["Space"] = true
		elseif isfunction(self.v.SetThrottle) and isfunction(self.v.SetSteering) and isfunction(self.v.SetHandbrake) and not self.v.IsGlideVehicle then
			self.v:SetThrottle(0)
			self.v:SetSteering(0, 0)
			if self.v:GetVelocity():LengthSqr() < 10000 then 
				self.v:SetHandbrake(true)
			else 
				self.v:SetHandbrake(false)
			end
		elseif self.v.IsGlideVehicle then
			self.v:TriggerInput("Handbrake", 1)
			self.v:TriggerInput("Throttle", 0)
			self.v:TriggerInput("Brake", 0)
			self.v:TriggerInput("Steer", 0)
		end
		self.moving = CurTime()
	end
	
	function ENT:CanSeeGoal(target)
		if not self.v or not target then
			return
		end
		local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = target, mask = MASK_NPCWORLDSTATIC, filter = {self, self.v}}).Fraction==1
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
		
		local trleft = util.TraceLine({start = self.v:LocalToWorld(leftstart), endpos = (self.v:LocalToWorld(left)+(vector_up * 50)), mask = MASK_SOLID}).Fraction
		local trright = util.TraceLine({start = self.v:LocalToWorld(rightstart), endpos = (self.v:LocalToWorld(right)+(vector_up * 50)), mask = MASK_SOLID}).Fraction
		
		if trleft > trright then
			return turnleft
		end
		if trleft < trright then
			return turnright
		end
		
		return false
		
	end
	
	function ENT:ObstaclesNearby()
		if not self.v then
			return
		end
		local tr = util.TraceLine({start = self.v:WorldSpaceCenter(), endpos = (self.v:WorldSpaceCenter()+(self.v:GetVelocity()*2)), mask = MASK_SOLID}).Fraction ~= 1
		return tobool(tr)
	end

	function ENT:FindRace()
		if (self.v.uvraceparticipant and UVRaceInEffect) and (UVRaceTable['Participants'] and UVRaceTable['Participants'][self.v]) then
			if not UVRaceInProgress then self.PatrolWaypoint = nil; return end
			
			local array = UVRaceTable['Participants'][self.v]
			
			local current_checkp = #array.Checkpoints + 1
			local next_checkp = #array.Checkpoints + 2
			local selected_point = nil
			local next_point

			if next_checkp >= GetGlobalInt("uvrace_checkpoints") then --Finish line
				next_checkp = 1
			end
			
			for _, v in ipairs(ents.FindByClass('uvrace_brush*')) do
				if v:GetID() == current_checkp then
					selected_point = v
				end
				if v:GetID() == next_checkp then
					next_point = v
				end
			end
			
			if selected_point then
				local target = selected_point
				local pos1, pos2 = nil, nil

				pos1 = (InfMap and InfMap.unlocalize_vector( target:GetPos1(), target:GetChunk() )) or target:GetPos1()
				pos2 = (InfMap and InfMap.unlocalize_vector( target:GetPos2(), target:GetChunkMax() )) or target:GetPos2()

				local target_pos = ClosestPointOnLineSegment(
					self.v:WorldSpaceCenter(), 
					pos1, 
					pos2, 
					200
				)
				
				local velocity = self.v:GetVelocity()
				--print(velocity:LengthSqr())
				local normalized_velocity = velocity:GetNormalized()
				
				local tolerance = 750
				--local dotThreshold = 1
				
				if next_point then
					local toCheckpoint = (target_pos - self.v:WorldSpaceCenter()):GetNormalized()
					local forward = self.v.IsSimfphyscar and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward() or self.v:GetForward()
					
					local dot = forward:Dot(toCheckpoint)
					local dist = self.v:WorldSpaceCenter():Distance(target_pos)
					
					if dist < tolerance and velocity:LengthSqr() > 100000 then --dot > dotThreshold
						target = next_point

						pos1 = (InfMap and InfMap.unlocalize_vector( target:GetPos1(), target:GetChunk() )) or target:GetPos1()
						pos2 = (InfMap and InfMap.unlocalize_vector( target:GetPos2(), target:GetChunkMax() )) or target:GetPos2()

						target_pos = ClosestPointOnLineSegment(
							self.v:WorldSpaceCenter(), 
							pos1, 
							pos2, 
							200
						)
						--end
					end
				end

				pos1 = (InfMap and InfMap.unlocalize_vector( target:GetPos1(), target:GetChunk() )) or target:GetPos1()
				pos2 = (InfMap and InfMap.unlocalize_vector( target:GetPos2(), target:GetChunkMax() )) or target:GetPos2()
				
				local size = (pos2 - pos1):LengthSqr()
				
				--print('Vehicle velocity', velocity:LengthSqr())
				
				if velocity:LengthSqr() < 150000 then
					target_pos = target.target_point
				end
				
				if size < 200000 then
					target_pos = target.target_point
				end

				self.PatrolWaypoint = {
					['Target'] = target_pos,
					['SpeedLimit'] = ((target:GetSpeedLimit() == 0 and math.huge) or target:GetSpeedLimit())
				}
			end
			
			
		else
			if next(dvd.Waypoints) == nil then
				self.PatrolWaypoint = nil
				return
			end
			
			local Waypoint = dvd.GetNearestWaypoint(self.v:WorldSpaceCenter())
			if Waypoint.Neighbors then --Keep going straight
				self.PatrolWaypoint = dvd.Waypoints[Waypoint.Neighbors[math.random(#Waypoint.Neighbors)]]
			else
				self.PatrolWaypoint = Waypoint
			end
		end		
	end
	
	function ENT:Race()
		self:FindRace()
		
		local selfvelocity = self.v:GetVelocity():LengthSqr()
		
		-- Node-based navigation override
		if not self.NodePath and self.v.uvraceparticipant then
			self:StartNodeRace()
		end
		
		if self.PatrolWaypoint and self.NodePath and self.CurrentNode then
			if not self.racing then
				self.racing = true
			end

			--Set handbrake
			if self.v.IsScar then
				self.v:HandBrakeOff()
			elseif self.v.IsSimfphyscar then
				self.v.PressedKeys = self.v.PressedKeys or {}
				self.v.PressedKeys["Space"] = false
			elseif isfunction(self.v.SetHandbrake) and not self.v.IsGlideVehicle then
				self.v:SetHandbrake(false)
			end

			UVSetVehiclePerformanceMultiplier(self.v, 3)
			
			-- Determine target position inside the node
			self.CurrentPointIndex = self.CurrentPointIndex or 1
			local points = self.CurrentNode.Points or {}
			if #points == 0 then return end -- Safety check
			
			local pos = self.v:WorldSpaceCenter()
			local points = self.CurrentNode.Points
			if #points == 0 then return end

			-- Use path guidance: get current point and the following point
			local nextPoint = points[self.CurrentPointIndex]
			local followingPoint = points[self.CurrentPointIndex + 1] or points[#points]

			-- Guidance position along the segment
			local targetPos = ClosestPointOnLineSegment(pos, nextPoint, followingPoint, 100)

			-- Steering calculation
			local forward = self.v.IsSimfphyscar and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward() or self.v:GetForward()
			local toTarget = targetPos - pos
			local dist = toTarget:Length()
			local dir = toTarget:GetNormalized()
			local right = dir:Cross(forward)
			local steer_amount = right:Length()
			local steer = right.z > 0 and steer_amount or -steer_amount

			-- Smooth throttle near corners
			local speed = self.v:GetVelocity():LengthSqr()
			local speedLimit = self.CurrentNode.StartSpeed^2 or math.huge
			local throttle = 1
			local cornerDist = 400
			
			if dist < cornerDist then
				throttle = math.Clamp(dist / cornerDist, -1, 1) -- slows down as approaching
			end
			
			if speed > speedLimit * 350 then
				throttle = -1
			elseif speed > speedLimit * 300 then
				throttle = math.min(throttle, 0.5)
			end

			-- local avoid = self:ObstaclesNearbySide()
			-- if avoid then
				-- steer = steer + (avoid * 0.5)
				-- throttle = throttle * 0.8
			-- end

			-- if self:ObstaclesNearby() then
				-- throttle = 0.25
			-- end

			-- Traction control
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
					throttleInput = throttleInput and (throttleInput * self.AI_ThrottleMul) --Glide traction control
					self.usenitrous = UVCFEligibleToUse(self) and self.AI_ThrottleMul == 1 and true or false
				end
			end

			if self.stuck then
				-- steer = 0
				throttle = throttle * -1
			end --Getting unstuck

			-- Apply throttle/steer (same as your existing code block)
			if self.v.IsScar then
				if throttle > 0 then self.v:GoForward(throttle) else self.v:GoBack(-throttle) end
				if steer > 0 then self.v:TurnRight(steer) elseif steer < 0 then self.v:TurnLeft(-steer) else self.v:NotTurning() end
			elseif self.v.IsSimfphyscar then
				self.v.PressedKeys = self.v.PressedKeys or {}
				self.v.PressedKeys["joystick_throttle"] = throttle
				self.v.PressedKeys["joystick_brake"] = throttle * -1
				self.v:PlayerSteerVehicle(self, steer < 0 and -steer or 0, steer > 0 and steer or 0)
			elseif self.v.IsGlideVehicle then
				if cffunctions then
					CFtoggleNitrous( self.v, self.usenitrous )
				end
				self.v:TriggerInput("Handbrake", 0)
				self.v:TriggerInput("Throttle", throttleInput or throttle)
				self.v:TriggerInput("Brake", throttle * -1)
				self.v:TriggerInput("Steer", steer * 1)
			elseif isfunction(self.v.SetThrottle) and not self.v.IsGlideVehicle then
				self.v:SetThrottle(throttle)
				self.v:SetSteering(steer, 0)
			end

			-- Move to next node if close
			self.CurrentPointIndex = self.CurrentPointIndex or 1
			local points = self.CurrentNode.Points
			local targetPos = points[self.CurrentPointIndex]

			if dist < 600 then
				self.CurrentPointIndex = self.CurrentPointIndex + 1
				if self.CurrentPointIndex > #points then
					local nextNodes = {}
					local currentPosNode = self.CurrentNode.To
					if UVRace_CompiledPaths and currentPosNode then
						for _, seg in ipairs( UVRace_CompiledPaths ) do if seg.From == currentPosNode then table.insert( nextNodes, seg ) end end
					end

					if #nextNodes > 0 then
						local chosen = nextNodes[math.random(#nextNodes)]
						-- print(self.v, "BRANCH COUNT: " .. #nextNodes)
						-- PrintTable(chosen)
						self.CurrentNode = chosen
						self.NextNode = nil
						self.CurrentPointIndex = 1
					else
						self.NodePath = nil
						self.CurrentNode = nil
						self.NextNode = nil
					end
				end
			end

			--Resetting
			if not (selfvelocity < 10000 and (throttle > 0 or throttle < 0)) then 
				self.moving = CurTime()
			end
			if self.stuck then 
				self.moving = CurTime()
			end
			
			local timeout = 1
			if timeout and timeout > 0 then
				if CurTime() > self.moving + timeout then --If it has got stuck for enough time.
					self.stuck = true
					self.moving = CurTime()
					timer.Simple(2, function() 
						if IsValid(self.v) then 
							self.stuck = nil 
							self.PatrolWaypoint = nil 
							
							if self.v.uvraceparticipant and ((not self.v.UVBustingProgress) or self.v.UVBustingProgress <= 0) then
								UVResetPosition( self.v )
								self:StartNodeRace()
							end
						end 
					end)
				end
			end

			-- Skip old PatrolWaypoint code
			return
		elseif self.PatrolWaypoint then
			if not self.racing then
				self.racing = true
			end
			
			--Set handbrake
			if self.v.IsScar then
				self.v:HandBrakeOff()
			elseif self.v.IsSimfphyscar then
				--self.v:SetActive(true)
				--self.v:StartEngine()
				self.v.PressedKeys = self.v.PressedKeys or {}
				self.v.PressedKeys["Space"] = false
			elseif isfunction(self.v.SetHandbrake) and not self.v.IsGlideVehicle then
				self.v:SetHandbrake(false)
			end
			
			--Racing techniques
			local WaypointPos = self.PatrolWaypoint["Target"]
			local forward = self.v.IsSimfphyscar and self.v:LocalToWorldAngles(self.v.VehicleData.LocalAngForward):Forward() or self.v:GetForward()
			local dist = WaypointPos - self.v:WorldSpaceCenter()
			local vect = dist:GetNormalized()
			local vectdot = vect:Dot(self.v:GetVelocity())
			local throttle = dist:Dot(forward) > 0 and 1 or -1
			local right = vect:Cross(forward)
			local steer_amount = right:Length()
			local steer = right.z > 0 and steer_amount or -steer_amount
			local speedlimitmph = self.PatrolWaypoint["SpeedLimit"]
			self.Speeding = speedlimitmph^2

			local throttleInput = nil
			local brakeInput = nil
			self.maxTurn = 0

			if selfvelocity > self.Speeding*350 then -- Above it - slam on brakes!
				throttle = -1
			elseif selfvelocity > self.Speeding*300 then -- Near or on the speed limit - half throttle
				throttle = 0.5
			end

			if self.stuck then
				steer = 0
				throttle = throttle * -1
				throttleInput = nil
			end --Getting unstuck

			if self:ObstaclesNearby() and not self.v.uvraceparticipant and not (self.v.UVWanted and UVTargeting) then
				throttle = throttle * -1
			end --Slow down when free roaming

			-- Traction control
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
				end
			end
			
			if dist:Dot(forward) < 0 and not self.stuck then
				if vectdot > 0 then
					if right.z > 0 then 
						steer = -1 
					else 
						steer = 1 
					end
				end
			end --K turn
			
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
				self.v.PressedKeys = self.v.PressedKeys or {}
				self.v.PressedKeys["Shift"] = false
				self.v.PressedKeys["joystick_throttle"] = throttle
				self.v.PressedKeys["joystick_brake"] = throttle * -1
				self.v:PlayerSteerVehicle(self, steer < 0 and -steer or 0, steer > 0 and steer or 0)
			elseif self.v.IsGlideVehicle then
				if cffunctions then
					CFtoggleNitrous( self.v, self.usenitrous )
				end
				self.v:TriggerInput("Handbrake", 0)
				self.v:TriggerInput("Throttle", throttle)
				self.v:TriggerInput("Brake", throttle * -1)

				if self.v.uvraceparticipant then
					steer = steer * 2
				else
					steer = steer * 1.5
				end

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
			end
			
			local timeout = 1
			if timeout and timeout > 0 then
				if CurTime() > self.moving + timeout then --If it has got stuck for enough time.
					self.stuck = true
					self.moving = CurTime()
					timer.Simple(2, function() 
						if IsValid(self.v) then 
							self.stuck = nil 
							self.PatrolWaypoint = nil 
							
							if self.v.uvraceparticipant and ((not self.v.UVBustingProgress) or self.v.UVBustingProgress <= 0) then
								UVResetPosition( self.v )
							end
						end 
					end)
				end
			end
			
		else
			self:Stop()
		end
		
		--Pursuit Tech
		if self.v.PursuitTech and UVTargeting then
			for k, v in pairs(self.v.PursuitTech) do
				if v.Tech ~= 'Shockwave' and v.Tech ~= 'Jammer' and v.Tech ~= 'Repair Kit' then
					UVDeployWeapon(self.v, k)
				end
				if v.Tech == "Repair Kit" then
					if self.v.IsGlideVehicle then
						if self.v:GetChassisHealth() <= (self.v.MaxChassisHealth / 3) then
							UVDeployWeapon(self.v, k)
						else
							for _, v in pairs(self.v.wheels) do
								if IsValid(v) and v.bursted and not self.repairtimer then
									local id = "tire_repair"..self.v:EntIndex()
									self.repairtimer = true
									
									timer.Create(id, 1, 1, function()
										UVDeployWeapon(self.v, k)
										timer.Simple(5, function() self.repairtimer = false; end)
									end)
									break
								end
							end
						end
					elseif self.v.IsSimfphyscar then
						if self.v:GetCurHealth() <= (self.v:GetMaxHealth() / 3) then
							UVDeployWeapon(self.v, k)
						else
							for _, wheel in pairs(self.v.Wheels) do
								if IsValid(wheel) and wheel:GetDamaged() and not self.repairtimer then
									local id = "tire_repair"..self.v:EntIndex()
									self.repairtimer = true
									
									timer.Create(id, 1, 1, function()
										UVDeployWeapon(self.v, k)
										timer.Simple(5, function() self.repairtimer = false; end)
									end)
									break
								end
							end
						end
					elseif vcmod_main and self.v:GetClass() == "prop_vehicle_jeep" then
						if self.v:VC_getHealth() <= (self.v:VC_getHealthMax() / 3) then
							UVDeployWeapon(self.v, k)
						end
					end
				end
			end
		end	
	end
	
	function ENT:Think()
		--if UVTargeting then return end
		self:SetPos(self.v:GetPos() + (vector_up * 50))
		self:SetAngles(self.v:GetPhysicsObject():GetAngles()+Angle(0,180,0))
		
		if self.v then
			if self.v.raceinvited then
				if not table.HasValue(UVRaceCurrentParticipants, self.v) then
					UVRaceAddParticipant( self.v, nil, true )
					return
				end
				self.v.raceinvited = false
				timer.Remove('RaceInviteExpire'..v:EntIndex())
			end
		end
		
		if not GetConVar("ai_ignoreplayers"):GetBool() then
			self:Race()
		else
			self:Stop()
		end
		
		-- Make their computing rate higher ONLY if they are in a race
		-- if self.v.uvraceparticipant then
		-- 	self:NextThink( CurTime() )
		-- 	return true
		-- end
		
		
    -- ====== DEBUG: Draw line to target node ======
		local targetPos = nil
		
		-- Use NodePath target if racing on nodes
		if self.NodePath and self.CurrentNode then
			local points = self.CurrentNode.Points or {}
			if #points > 0 then
				targetPos = points[self.CurrentPointIndex or 1]
			end
		-- elseif self.PatrolWaypoint then
			-- targetPos = self.PatrolWaypoint["Target"]
		end

		if targetPos then
			debugoverlay.Line(self.v:WorldSpaceCenter(), targetPos, 1, Color(255,0,0), true)
			debugoverlay.Sphere(targetPos, 20, 1, Color(0,255,0), true)
		end
	end

	function ENT:Initialize()
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetModel(self.Modelname)
		self:SetHealth(-1)
		
		self.moving = CurTime()
		
		timer.Simple(3, function()
			if IsValid(self.v) then
				if vcmod_main and self.v:GetClass() == "prop_vehicle_jeep" and GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then 
					self.v:VC_setRunningLights(true)
				end
			end
		end)
		
		--Pick up a vehicle in the given sphere.
		if self.vehicle then
			local v = self.vehicle
			if v.RacerVehicle and v.RacerVehicle:IsNPC() then return end
			if v.IsScar then --If it's a SCAR.
				if not v:HasDriver() then --If driver's seat is empty.
					self.v = v
					v.RacerVehicle = self
					v.HasDriver = function() return true end --SCAR script assumes there's a driver.
					v.SpecialThink = function() end --Tanks or something sometimes make errors so disable thinking.
					v:StartCar()
				end
			elseif v.IsSimfphyscar and v:IsInitialized() then --If it's a Simfphys Vehicle.
				if not IsValid(v:GetDriver()) then --Fortunately, Simfphys Vehicles can use GetDriver()
					self.v = v
					v.RacerVehicle = self
					v:SetActive(true)
					v:StartEngine()
					if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then
						v:SetLightsEnabled(true)
					end
					if GetConVar("unitvehicle_autohealth"):GetBool() or AutoHealthRacer:GetBool() then
						v:SetMaxHealth(math.huge)
						v:SetCurHealth(math.huge)
					end
				end
			elseif isfunction(v.EnableEngine) and isfunction(v.StartEngine) and not v.IsGlideVehicle then --Normal vehicles should use these functions. (SCAR and Simfphys cannot.)
				if isfunction(v.GetWheelCount) and v:GetWheelCount() and not IsValid(v:GetDriver()) then
					self.v = v
					v.RacerVehicle = self
					v:EnableEngine(true)
					v:StartEngine(true)
					if GetConVar("unitvehicle_autohealth"):GetBool() or AutoHealthRacer:GetBool() then
						if vcmod_main and v:GetClass() == "prop_vehicle_jeep" then
							v:VC_repairFull_Admin()
							if not v:VC_hasGodMode() then
								v:VC_setGodMode(true)
							end
						end
					end
				end
			elseif v.IsGlideVehicle then --Glide
				if not IsValid(v:GetDriver()) then
					self.v = v
					v.RacerVehicle = self
					v:SetEngineState(2)
					v.inputThrottleModifierMode = 2
					v.AirControlForce = vector_origin
					if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 and v.CanSwitchHeadlights then
						v:SetHeadlightState(1)
					end
					if AutoHealthRacer:GetBool() then
						v:SetChassisHealth(math.huge)
						v:SetEngineHealth(math.huge)
						v:UpdateHealthOutputs()
						v.FallOnCollision = nil
					end
				end
			end
		else
			local distance = DetectionRange:GetFloat()
			for k, v in pairs(ents.FindInSphere(self:GetPos(), distance)) do
				if v:GetClass() == 'prop_vehicle_prisoner_pod' then continue end
				if v.RacerVehicle and v.RacerVehicle:IsNPC() then continue end
				if v:IsVehicle() then
					if v.IsScar then --If it's a SCAR.
						if not v:HasDriver() then --If driver's seat is empty.
							self.v = v
							v.RacerVehicle = self
							v.HasDriver = function() return true end --SCAR script assumes there's a driver.
							v.SpecialThink = function() end --Tanks or something sometimes make errors so disable thinking.
							v:StartCar()
							break
						end
					elseif v.IsSimfphyscar and v:IsInitialized() then --If it's a Simfphys Vehicle.
						if not IsValid(v:GetDriver()) then --Fortunately, Simfphys Vehicles can use GetDriver()
							self.v = v
							v.RacerVehicle = self
							v:SetActive(true)
							v:StartEngine()
							if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 then
								v:SetLightsEnabled(true)
							end
							if GetConVar("unitvehicle_autohealth"):GetBool() or AutoHealthRacer:GetBool() then
								v:SetMaxHealth(math.huge)
								v:SetCurHealth(math.huge)
							end
							break
						end
					elseif isfunction(v.EnableEngine) and isfunction(v.StartEngine) and not v.IsGlideVehicle then --Normal vehicles should use these functions. (SCAR and Simfphys cannot.)
						if isfunction(v.GetWheelCount) and v:GetWheelCount() and not IsValid(v:GetDriver()) then
							self.v = v
							v.RacerVehicle = self
							v:EnableEngine(true)
							v:StartEngine(true)
							if GetConVar("unitvehicle_autohealth"):GetBool() or AutoHealthRacer:GetBool() then
								if vcmod_main and v:GetClass() == "prop_vehicle_jeep" then
									v:VC_repairFull_Admin()
									if not v:VC_hasGodMode() then
										v:VC_setGodMode(true)
									end
								end
							end
							break
						end
					elseif v.IsGlideVehicle then --Glide
						if not IsValid(v:GetDriver()) then
							self.v = v
							v.RacerVehicle = self
							v:TurnOn()
							v.inputThrottleModifierMode = 2
							v.AirControlForce = vector_origin
							if GetConVar("unitvehicle_enableheadlights"):GetInt() == 2 and v.CanSwitchHeadlights then
								v:SetHeadlightState(1)
							end
							if AutoHealthRacer:GetBool() then
								v:SetChassisHealth(math.huge)
								v:SetEngineHealth(math.huge)
								v:UpdateHealthOutputs()
								v.FallOnCollision = nil
							end
							break
						end
					end
				end
			end
		end
		
		if not IsValid(self.v) then SafeRemoveEntity(self) return end --When there's no vehicle, remove Racer Vehicle.
		local e = EffectData()
		e:SetEntity(self.v)
		util.Effect("propspawn", e) --Perform a spawn effect.
		self.v:EmitSound( "beams/beamstart5.wav" )
		
		if not self.v.racer and UVNames then
			self.v.racer = UVNames.Racers[math.random(1, #UVNames.Racers)]
			local joinmessage = "Racer AI (" .. self.v.racer .. ") has joined the game"
			
			net.Start( "UVRacerJoin" )
			net.WriteString(joinmessage)
			net.Broadcast()
		end
		
		local pttable = {
			--"EMP",
			"ESF",
			"Jammer",
			"Shockwave",
			"Spikestrip",
			"Stunmine",
			"Repair Kit",
		}
		
		if RacerPursuitTech:GetBool() then
			if not self.v.PursuitTech then
				self.v.PursuitTech = {}
				
				for i=1, 2, 1 do
					local selected_pt = pttable[math.random(#pttable)]
					local sanitized_pt = string.lower(string.gsub(selected_pt, " ", ""))
					local sel_k, sel_v
					
					for k,v in pairs(self.v.PursuitTech) do
						if v.Tech == selected_pt then
							sel_k, sel_v = k, v
							self.v.PursuitTech[k] = nil
							break
						end
					end
					
					local ammo_count = GetConVar("uvpursuittech_" .. sanitized_pt .. "_maxammo"):GetInt()
					ammo_count = ammo_count > 0 and ammo_count or math.huge
					
					self.v.PursuitTech[i] = {
						Tech = selected_pt,
						Ammo = ammo_count,
						Cooldown = GetConVar("uvpursuittech_" .. sanitized_pt .. "_cooldown"):GetInt(),
						LastUsed = -math.huge,
						Upgraded = false
					}
				end
				
				table.insert(UVRVWithPursuitTech, self.v)
				
				self.v:CallOnRemove( "UVRVWithPursuitTechRemoved", function(car)
					if table.HasValue(UVRVWithPursuitTech, car) then
						table.RemoveByValue(UVRVWithPursuitTech, car)
					end
				end)
			end
		end

		if isfunction(self.v.UVVehicleInitialize) then --For vehicles that has a driver bodygroup
			self.v:UVVehicleInitialize()
		end

		if cffunctions then
			UVCFInitialize(self)
		end

		local function BodygroupDamageScript()
			return self.v.frontdamaged or self.v.reardamaged or self.v.leftdamaged or self.v.rightdamaged
		end

		if CustomizeRacer:GetBool() and not self.restrictedCustomization then
			local color = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))

			self.v:SetColor(color)
			self.v:SetSkin( math.random( 0, self.v:SkinCount() - 1 ) )

			if not BodygroupDamageScript() then
				for i = 0, self.v:GetNumBodyGroups() - 1 do
    			    local bodygroupCount = self.v:GetBodygroupCount( i )
    			    if bodygroupCount > 0 then
    			        self.v:SetBodygroup( i, math.random( 0, bodygroupCount - 1 ) )
    			    end
    			end
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
else
	function ENT:Initialize()
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetModel(self.Modelname)
	end
end

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