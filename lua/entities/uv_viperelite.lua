AddCSLuaFile()

local modelpath = "models/unitvehiclescars/uv_viperelite/"

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.Author = "Police Commander Moka"

-- ENT.PrintName = "Dodge Viper SRT-10 Pursuit Commander"
ENT.PrintName = "#uv.veh.viper"

ENT.GlideCategory = "unitvehiclesglide"
ENT.ChassisModel = modelpath .. "base.mdl"
ENT.CanSwitchSiren = true

DEFINE_BASECLASS( "base_glide_car" )

ENT.NitrousPower = 2.25
ENT.NitrousDepletionRate = 0.66
ENT.NitrousRegenRate = 0.2

ENT.SirenTable = {
    ")uvcars/code3 rls/emv_wail.wav",
    ")uvcars/code3 rls/emv_yelp.wav",
    ")uvcars/code3 rls/emv_hyperyelp.wav",
    ")uvcars/code3 rls/emv_hilo.wav",
}

if CLIENT then

    ENT.SirenVolume = 1

    ENT.SirenLoopSound = ")uvcars/code3 rls/emv_wail.wav"
    ENT.SirenLoopAltSound = ")uvcars/code3 rls/emv_horn.wav"
    ENT.HornSound = ")uvcars/code3 rls/emv_horn.wav"

    ENT.CameraOffset = Vector( -220, 0, 65 )

    ENT.ExhaustOffsets = {
        { pos = Vector( 0.603, 1.061, 0.108 ) * 45.1, angle = Angle( 0, -90, 0 ) }, -- Necessary L1
        { pos = Vector( 0.786, 1.061, 0.108 ) * 45.1, angle = Angle( 0, -90, 0 ) }, -- Necessary L1
		
        { pos = Vector( 0.603, -1.061, 0.108 ) * 45.1, angle = Angle( 0, 90, 0 ) }, -- Necessary L1
        { pos = Vector( 0.786, -1.061, 0.108 ) * 45.1, angle = Angle( 0, 90, 0 ) }, -- Necessary L1
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 40.16, 17.93, 30.53 ), width = 15 },
        { offset = Vector( 40.16, -17.93, 30.53 ), width = 15 },
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 42.45, 0, 33.9 ), angle = Angle() }
    }

    ENT.Headlights = {
        { offset = Vector(98.2, 25.87, 13.5), color = Color(160,205,255) },
        { offset = Vector(98.2, -25.87, 13.5), color = Color(160,205,255) },
    }

	local lightpos = {
		front = {
			l = Vector( 1.74, 0.74, 0.507 ) * 45.1,
			r = Vector( 1.74, -0.74, 0.507 ) * 45.1,
		},
		rear = {
			l = Vector( -2.046, 0.7, 0.655 ) * 45.1,
			r = Vector( -2.046, -0.7, 0.655 ) * 45.1,
		},
		reverse = {
			l = Vector( -2.111, 0.56, 0.556 ) * 45.1,
			r = Vector( -2.111, -0.56, 0.556 ) * 45.1,
		},
	}

    ENT.LightSprites = {
			-- Headlights Low Beams, Left / Right
        { type = "headlight", beamType = "low", offset = lightpos.front.l, color = Color(100,165,255), dir = Vector( 1, 0.0, 0 ), size = 60, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightflareouter" ) },
        { type = "headlight", beamType = "low", offset = lightpos.front.l, color = Color(180,210,255), dir = Vector( 1, 0.0, 0 ), size = 12, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },
		
        { type = "headlight", beamType = "low", offset = lightpos.front.r, color = Color(100,165,255), dir = Vector( 1, -0.0, 0 ), size = 60, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightflareouter" ) },
        { type = "headlight", beamType = "low", offset = lightpos.front.r, color = Color(180,210,255), dir = Vector( 1, -0.0, 0 ), size = 12, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },
		
		-- Headlights High Beams, Left / Right
        { type = "headlight", beamType = "high", offset = lightpos.front.l, color = Color(100,165,255), dir = Vector( 1, 0.0, 0 ), size = 120, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightflareouter" ) },
        { type = "headlight", beamType = "high", offset = lightpos.front.l, color = Color(180,210,255), dir = Vector( 1, 0.0, 0 ), size = 24, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },
		
        { type = "headlight", beamType = "high", offset = lightpos.front.r, color = Color(100,165,255), dir = Vector( 1, -0.0, 0 ), size = 120, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightflareouter" ) },
        { type = "headlight", beamType = "high", offset = lightpos.front.r, color = Color(180,210,255), dir = Vector( 1, -0.0, 0 ), size = 24, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },

		-- Rear Lights
        { type = "taillight", offset = lightpos.rear.l, color = Color(255,0,0,50), dir = Vector( -1, 0.5, 0 ), size = 30, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },
        { type = "taillight", offset = lightpos.rear.r, color = Color(255,0,0,50), dir = Vector( -1, -0.5, 0 ), size = 30, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },

        { type = "brake", offset = lightpos.rear.l, color = Color(255,0,0,200), dir = Vector( -1, 0.5, 0 ), size = 20, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },
        { type = "brake", offset = lightpos.rear.r, color = Color(255,0,0,200), dir = Vector( -1, -0.5, 0 ), size = 20, spriteMaterial = Material( "mokanfsw/universal/textures/lights/headlightglow" ) },

        { type = "reverse", offset = lightpos.reverse.l, color = Color(255,255,255), dir = Vector( -1, 0.5, 0 ), size = 20 },
        { type = "reverse", offset = lightpos.reverse.r, color = Color(255,255,255), dir = Vector( -1, 0.5, 0 ), size = 20 },
		
        { type = "signal_left", offset = Vector( 77.07, 37.73, 22.13 ), dir = Vector( 1, 0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_left", offset = Vector( -90.86, 34.25, 25.05 ), dir = Vector( -1, 0.85, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
				
        { type = "signal_right", offset = Vector( 77.07, -37.73, 22.13 ), dir = Vector( 1, -0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -90.86, -34.25, 25.05 ), dir = Vector( -1, -0.85, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
    }

    ENT.SirenCycle = 0.3

		local coplights = {
		blue = {
			[1] = Vector( 2.281, -0.07, 0.292 ) * 45.1,
			[2] = Vector( 2.269, 0.201, 0.292 ) * 45.1,
			[3] = Vector( -2.065, -0.686, 0.538 ) * 45.1,
			[4] = Vector( -0.559, -0.443, 1.08 ) * 45.1,
			[5] = Vector( -0.559, -0.223, 1.099 ) * 45.1,
			[6] = Vector( -0.559, 0.224, 1.099 ) * 45.1,
			[7] = Vector( -0.559, 0.443, 1.08 ) * 45.1,
			[8] = Vector( 2.075, -0.537, 0.276 ) * 45.1,
		},
		red = {
			[1] = Vector( 2.281, 0.07, 0.292 ) * 45.1,
			[2] = Vector( 2.272, -0.201, 0.292 ) * 45.1,
			[3] = Vector( -2.065, 0.686, 0.542 ) * 45.1,
			[4] = Vector( -2.267, 0, 0.233 ) * 45.1,
			[5] = Vector( -0.559, -0.344, 1.094 ) * 45.1,
			[6] = Vector( -0.559, 0.345, 1.094 ) * 45.1,
			[7] = Vector( 2.078, 0.537, 0.276 ) * 45.1,
		},
	}
	

    ENT.SirenLights = {
	-- RED
        { offset = Vector( 2.281, 0.07, 0.292 ) * 45.1, time = 0, duration = 0.5, size = 50, color = Color(255,30,0), },
        { offset = Vector( 2.272, -0.201, 0.292 ) * 45.1, time = 0, duration = 0.5, size = 50, color = Color(255,30,0), },
        -- { offset = Vector( -2.065, 0.686, 0.542 ) * 45.1, time = 0, duration = 0.5, size = 50, color = Color(255,30,0), },
        { offset = Vector( -2.267, 0, 0.233 ) * 45.1, time = 0, duration = 0.5, size = 50, color = Color(255,30,0), },
        { offset = Vector( -0.559, -0.344, 1.094 ) * 45.1, time = 0, duration = 0.5, size = 50, color = Color(255,30,0), },
        { offset = Vector( -0.559, 0.345, 1.094 ) * 45.1, time = 0, duration = 0.5, size = 50, color = Color(255,30,0), },
        { offset = Vector( 2.078, 0.537, 0.276 ) * 45.1, time = 0, duration = 0.5, size = 50, color = Color(255,30,0), },
		
        { offset = Vector( -97.97, 14.46, 47.26 ), time = 0, duration = 0.5, size = 25, color = Color(255,30,0), },
        { offset = Vector( -97.97, 2.85, 47.26 ), time = 0, duration = 0.5, size = 25, color = Color(255,30,0), },
        { offset = Vector( -97.97, -9.07, 47.26 ), time = 0, duration = 0.5, size = 25, color = Color(255,30,0), },

        -- { offset = Vector(-22.01,19.92,53.04),spriteMaterial = Material( "models/unitvehiclescars/shared/policesprite" ), time = 0, duration = 0.5, size = 180, color = Color(255,30,0), },

	-- BLUE
        { offset = Vector( 2.281, -0.07, 0.292 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },
        { offset = Vector( 2.269, 0.201, 0.292 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },
        -- { offset = Vector( -2.065, -0.686, 0.538 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },
        { offset = Vector( -0.559, -0.443, 1.08 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },
        { offset = Vector( -0.559, -0.223, 1.099 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },
        { offset = Vector( -0.559, 0.224, 1.099 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },
        { offset = Vector( -0.559, 0.443, 1.08 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },
        { offset = Vector( 2.075, -0.537, 0.276 ) * 45.1, time = 0.5, duration = 0.5, size = 50, color = Color(0,115,255), },

        -- { offset = Vector(-22.01,0,53.04),spriteMaterial = Material( "models/unitvehiclescars/shared/policesprite" ), time = 0.5, duration = 0.5, size = 180, color = Color(0,115,255), },
		
        { offset = Vector( -97.97, -14.46, 47.26 ), time = 0.5, duration = 0.5, size = 25, color = Color(0,115,255), },
        { offset = Vector( -97.97, -2.85, 47.26 ), time = 0.5, duration = 0.5, size = 25, color = Color(0,115,255), },
        { offset = Vector( -97.97, 9.07, 47.26 ), time = 0.5, duration = 0.5, size = 25, color = Color(0,115,255), },
    }

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "moka_nfsw_muscle_viperacr" )
    end


	function ENT:BuildLightCache()
		if self._LightCacheBuilt then return end
		self._LightCacheBuilt = true

		local rearIDs = self.LightSubMaterials and self.LightSubMaterials.Rearlights or {}
		local brakeIDs = self.LightSubMaterials and self.LightSubMaterials.Brakelights or {}

		-- Lookup tables
		self._RearLookup = {}
		for i, id in ipairs(rearIDs) do
			self._RearLookup[id] = i
		end

		self._BrakeLookup = {}
		for i, id in ipairs(brakeIDs) do
			self._BrakeLookup[id] = i
		end

		-- Combined ID set
		self._AllRearBrakeIDs = {}
		for _, id in ipairs(rearIDs) do self._AllRearBrakeIDs[id] = true end
		for _, id in ipairs(brakeIDs) do self._AllRearBrakeIDs[id] = true end

		-- Overlap flag
		self._RearBrakeOverlap = self:SubMaterialsOverlap(rearIDs, brakeIDs)
	end

	ENT.LightStates = {
		Headlights = false,
		Rearlights = false,
		Brakelights = false
	}

	function ENT:SubMaterialsOverlap(a, b)
		if not a or not b then return false end

		for _, v in ipairs(a) do
			for _, v2 in ipairs(b) do
				if v == v2 then return true end
			end
		end

		return false
	end

	function ENT:UpdateLightState(name, state, materialsOn)
		if self.LightStates[name] == state then return end
		self.LightStates[name] = state

		local submats = self.LightSubMaterials and self.LightSubMaterials[name]
		if not submats then return end

		for i, id in ipairs(submats) do
			local mat = state and materialsOn[i] or ""
			self:SetSubMaterial(id, mat or "")
		end
	end

	function ENT:NFSW_UpdateRearBrakeLights(rearOn, brakeOn)
		if not self.LightSubMaterials or not self.LightMaterials then return end

		local rearIDs = self.LightSubMaterials.Rearlights or {}
		local brakeIDs = self.LightSubMaterials.Brakelights or {}

		local rearLookup = {}
		for i, id in ipairs(rearIDs) do
			rearLookup[id] = i
		end

		local brakeLookup = {}
		for i, id in ipairs(brakeIDs) do
			brakeLookup[id] = i
		end

		local allIDs = {}
		for _, id in ipairs(rearIDs) do allIDs[id] = true end
		for _, id in ipairs(brakeIDs) do allIDs[id] = true end

		for id, _ in pairs(allIDs) do
			local mat = ""

			if brakeOn and brakeLookup[id] then
				local i = brakeLookup[id]
				mat = self.LightMaterials.Brakelights[i] or ""
			elseif rearOn and rearLookup[id] then
				local i = rearLookup[id]
				mat = self.LightMaterials.Rearlights[i] or ""
			end

			self:SetSubMaterial(id, mat)
		end
	end

	function ENT:NFSW_UpdateLights()
		if not self.LightMaterials then return end

		self:BuildLightCache()

		local eo, hl, br = self:IsEngineOn(), self:GetHeadlightState(), self:IsBraking()

		local headlightsOn = hl > 0
		local rearLightsOn = (hl > 0) or (eo and br)
		local brakeLightsOn = eo and br

		self:UpdateLightState("Headlights", headlightsOn, self.LightMaterials.Headlights)

		if self:SubMaterialsOverlap(self.LightSubMaterials.Rearlights, self.LightSubMaterials.Brakelights) then
			local rearIDs = self.LightSubMaterials.Rearlights or {}
			local brakeIDs = self.LightSubMaterials.Brakelights or {}

			-- Build lookup tables
			local rearLookup = {}
			for i, id in ipairs(rearIDs) do
				rearLookup[id] = i
			end

			local brakeLookup = {}
			for i, id in ipairs(brakeIDs) do
				brakeLookup[id] = i
			end

			-- Merge all IDs
			local allIDs = {}
			for _, id in ipairs(rearIDs) do allIDs[id] = true end
			for _, id in ipairs(brakeIDs) do allIDs[id] = true end

			-- Resolve per ID
			for id, _ in pairs(self._AllRearBrakeIDs) do
				local mat = ""

				if brakeLightsOn and self._BrakeLookup[id] then
					local i = self._BrakeLookup[id]
					mat = self.LightMaterials.Brakelights[i] 
						or self.LightMaterials.Brakelights[1] 
						or ""
				elseif rearLightsOn and self._RearLookup[id] then
					local i = self._RearLookup[id]
					mat = self.LightMaterials.Rearlights[i] 
						or self.LightMaterials.Rearlights[1] 
						or ""
				end

				self:SetSubMaterial(id, mat)
			end
			self.LightStates.Rearlights = rearLightsOn
			self.LightStates.Brakelights = brakeLightsOn
		else
			self:UpdateLightState("Rearlights", rearLightsOn, self.LightMaterials.Rearlights)
			self:UpdateLightState("Brakelights", brakeLightsOn, self.LightMaterials.Brakelights)
		end
	end

	ENT.LightSubMaterials = {
		Headlights = {16},
		Rearlights = {12},
		Brakelights = {12}
	}
	
	ENT.LightMaterials = {
		Headlights = { "models/unitvehiclescars/uv_viperelite/headlightreflector_headlight_right_on" },
		Rearlights = { "models/unitvehiclescars/uv_viperelite/brakelight_brakelight_right_on" },
		Brakelights = { "models/unitvehiclescars/uv_viperelite/brakelight_brakelight_right_brake" }
	}

	function ENT:OnUpdateMisc()
		BaseClass.OnUpdateMisc(self)

		self:NFSW_UpdateLights()
	end
end


if SERVER then
    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 19, 0, -4 ) )
    end

    ENT.SpawnPositionOffset = Vector( 0, 0, 20 )
    ENT.ChassisMass = 1561 / 2
    ENT.IsHeavyVehicle = false

    function ENT:GetGears()
        return {
            [-1] = 4,
            [0] = 0,
            [1] = 3,
            [2] = 1.85,
            [3] = 1.3,
            [4] = 1,
            [5] = 0.8,
            [6] = 0.65,
        }
    end
		
	function ENT:GetGearCooldowns()
		return {
			[1] = 0,
			[2] = 0.4,
			[3] = 0.4,
			[4] = 0.4,
			[5] = 0.4,
			[6] = 0.4,
		}
	end

	local WP = {
		F = { x = 1.27, y = 1.03, z = 0.35 },
		R = { x = 1.23, y = 1.07, z = 0.375 },
		scale = 45.1,
		
		FrontYOffset = 7,
		FrontZOffset = -3.5,
		
		RearYOffset = 7,
		RearZOffset = -3.5,
	}

	ENT.WheelPos = {
		[1] = Vector(  WP.F.x,  WP.F.y,  WP.F.z  ) * WP.scale + Vector(0, -WP.FrontYOffset, WP.FrontZOffset), -- FL
		[2] = Vector(  WP.F.x, -WP.F.y,  WP.F.z  ) * WP.scale + Vector(0,  WP.FrontYOffset, WP.FrontZOffset), -- FR
		[3] = Vector( -WP.R.x,  WP.R.y,  WP.R.z  ) * WP.scale + Vector(0, -WP.RearYOffset, WP.RearZOffset), -- RL
		[4] = Vector( -WP.R.x, -WP.R.y,  WP.R.z  ) * WP.scale + Vector(0,  WP.RearYOffset, WP.RearZOffset), -- RR
	}

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( -34, 16, 0 ), Angle( 0, 270, 2 ), Vector( 20, 80, 0 ), true )
        self:CreateSeat( Vector( -22, -16, 1 ), Angle( 0, 270, 18 ), Vector( 20, -80, 0 ), true )

        self:SetSuspensionLength( 10 * 0.6 )
        self:SetSpringStrength( 55 * 10 )
        self:SetSpringDamper( 55 * 20 )

        self:SetDifferentialRatio( 4.08 / 6 * (0.45 * 1.4) )
        self:SetTransmissionEfficiency( 1 )
        self:SetPowerDistribution( -0.9 )
        self:SetBrakePower( 1100 * 2 )

        self:SetMinRPM( 800 )
        self:SetMaxRPM( 7250 )
        self:SetMinRPMTorque( 7250 * (0.829 * 1.9) )
        self:SetMaxRPMTorque( 7250 * (0.829 * 1.9) )
        self:SetMaxSteerAngle( 40 )
        self:SetSteerConeChangeRate( 7 )
        self:SetSteerConeMaxSpeed( 1600 )
        self:SetSteerConeMaxAngle( 0.3 )
		self:SetCounterSteer ( 0.8 )

        self:SetForwardTractionMax( 887 * 7.45 )
        self:SetForwardTractionBias( 0 )
        self:SetSideTractionMultiplier( 35 )
        self:SetSideTractionMaxAng( 20 )
        self:SetSideTractionMax( 887 * 6 )
        self:SetSideTractionMin( 887 * 4 )

		self:SetTurboCharged( false )
		self:SetFastTransmission( false )

        self:CreateWheel( self.WheelPos[1], { model = modelpath .. "wheelfr.mdl", modelAngle = Angle( 0, 90, 0 ), modelScale = Vector( 0.4, 1, 1 ), radius = 15, steerMultiplier = 1 } )
        self:CreateWheel( self.WheelPos[2], { model = modelpath .. "wheelfr.mdl", modelAngle = Angle( 0, -90, 0 ), modelScale = Vector( 0.4, 1, 1 ), radius = 15, steerMultiplier = 1 } )
        self:CreateWheel( self.WheelPos[3], { model = modelpath .. "wheelbk.mdl", modelAngle = Angle( 0, 90, 0 ), modelScale = Vector( 0.4, 1, 1 ), radius = 15.25 } )
        self:CreateWheel( self.WheelPos[4], { model = modelpath .. "wheelbk.mdl", modelAngle = Angle( 0, -90, 0 ), modelScale = Vector( 0.4, 1, 1 ), radius = 15.25 } )
    end

    function ENT:OnPostThink( dt, selfTbl )
        BaseClass.OnPostThink( self, dt, selfTbl )

        if self.wrecked and !self.emittedwreckedsound then
            self.emittedwreckedsound = true
            local wreckedsoundtable = file.Find( "sound/mokanfs/siren/wrecked/*.wav", "GAME")
            self:EmitSound( "mokanfs/siren/wrecked/" .. wreckedsoundtable[math.random(1,#wreckedsoundtable)], 100, math.random( 90, 110 ) )
        end
    end
    
    function ENT:Repair()
        BaseClass.Repair(self) --Overrides the repair function

        self:SetIsEngineOnFire( false )
        self:SetChassisHealth( self.MaxChassisHealth )
        self:SetEngineHealth( 1.0 )
        self:UpdateHealthOutputs()

        --reset bodygroups
        self:SetBodygroup( 1, 0 )
        self:SetBodygroup( 2, 0 )
        self:SetBodygroup( 3, 0 )
        self:SetBodygroup( 4, 0 )
        self:SetBodygroup( 5, 0 )
        self:SetBodygroup( 6, 0 )
        self:SetBodygroup( 7, 0 )

        self.frontdamaged = 0
        self.reardamaged = 0
        self.leftdamaged = 0
        self.rightdamaged = 0
    end

    function ENT:UVVehicleInitialize()
        self:SetBodygroup( 8, 1 )
    end

    function ENT:UVPhysicsCollide(data)

        local velocityChange = data.OurNewVelocity - data.OurOldVelocity
        local surfaceNormal = data.HitNormal

        local speed = velocityChange:Length()

        if speed < 500 then return end --Minimum speed to trigger, you can adjust the speed here

        local hitpos = data.HitPos
        local forward = self:GetForward()
        local dist = data.HitPos - self:WorldSpaceCenter()
        local vect = dist:GetNormalized()
        local right = (vect:Cross(forward)).z
        local forwarddot = dist:Dot(forward)

        local fronthit = forwarddot > 0 and right > -0.5 and right < 0.5
        local rearhit = forwarddot < 0 and right > -0.5 and right < 0.5
        local lefthit = right < -0.5
        local righthit = right > 0.5
        
        self.frontdamaged = self.frontdamaged or 0
        self.reardamaged = self.reardamaged or 0
        self.leftdamaged = self.leftdamaged or 0
        self.rightdamaged = self.rightdamaged or 0

        if fronthit then --FRONT
            if speed < 3000 and self.frontdamaged < 1 then
                self:SetBodygroup( 1, 1 )
                self:SetBodygroup( 2, 1 )
                self.frontdamaged = 1
            end
        end

        if rearhit then --REAR
            if self.reardamaged < 1 then
                self:SetBodygroup( 5, 1 )
                self:SetBodygroup( 6, 1 )
                self.reardamaged = 1
			end
        end

        if lefthit then --LEFT
            if speed < 600 and self.leftdamaged < 1 then
                self:SetBodygroup( 3, 1 )
                self:SetBodygroup( 7, 1 )
                self.leftdamaged = 1
			end
        end

        if righthit then --RIGHT
            if speed < 600 and self.rightdamaged < 1 then
                self:SetBodygroup( 4, 1 )
                self:SetBodygroup( 7, 1 )
                self.rightdamaged = 1
            end
        end
    end
end

local spawnColors = {
    Color(255, 255, 255),
}

function ENT:GetSpawnColor()
    return spawnColors[math.random(#spawnColors)]
end