AddCSLuaFile()

Glide.AddSoundSet( "Glide.NFSWorld.Interrupt", 90, 95, 105, {
    ")mokanfs/siren/inter/inter1.wav",
    ")mokanfs/siren/inter/inter2.wav",
    ")mokanfs/siren/inter/inter3.wav",
    ")mokanfs/siren/inter/inter4.wav",
    ")mokanfs/siren/inter/inter5.wav"
} )

ENT.NitrousColor = Color( 255, 150, 63 )

if CLIENT then
	-- function ENT:OnPostInitialize()
		-- self.slowBrakePressure = 0
        -- self.fastBrakePressure = 0
		-- self.TurboInertia = 0
        
        -- self.rpmFraction = 0
        -- self.streamJSONOverride = nil

        -- local sirentable = {
            -- ")mokanfs/siren/siren1.wav",
            -- ")mokanfs/siren/siren2.wav",
        -- }

        -- local altsirentable = {
            -- ")mokanfs/siren/sirenalt1.wav",
            -- ")mokanfs/siren/sirenalt2.wav",
            -- ")mokanfs/siren/sirenalt3.wav",
            -- ")mokanfs/siren/sirenalt4.wav",
        -- }

        -- self.SirenLoopSound = sirentable[math.random(1,#sirentable)]
        -- self.SirenLoopAltSound = altsirentable[math.random(1,#altsirentable)]
    -- end

	--[[ 
		Straight cut gear sound for reverse gears
	 	OnUpdateSounds is a base class method
	]]--

	-- ENT.ReverseWhineSound = "mokanfs/car_whine.wav"
    
    -- function ENT:OnUpdateSounds()
    --     BaseClass.OnUpdateSounds(self)
    --     if not self.ReverseWhineSound then return end
        
    --     local dt = FrameTime()
        
    --     local sounds = self.sounds
    --     local curGear = self:GetGear()
        
    --     -- unfortunate hack to only play the whine when the car is immobile or has clutch engaged
    --     -- Glide doesn't expose a way to check for this on client w/o netvars lol
    --     local carVelo = self:GetVelocity():Length2DSqr()
        
    --     if curGear == -1 then
    --         if sounds.reverseWhine then
    --             sounds.reverseWhine:ChangePitch( ( self.rpmFraction - 0.2 ) * 255, dt )
    --             sounds.reverseWhine:ChangeVolume( ( carVelo >= 10000 and self.rpmFraction or 0 ) * ( Glide.Config.GetVolume( 'carVolume' ) * 3 ), dt )
    --         else
    --             local snd = self:CreateLoopingSound( "reverseWhine", self.ReverseWhineSound, 85, self )
    --             snd:PlayEx( 1, ( self.rpmFraction - 0.2 ) * 255 )
    --             snd:ChangeVolume( ( carVelo >= 10000 and self.rpmFraction or 0 ) * ( Glide.Config.GetVolume( 'carVolume' ) * 3 ), dt )
    --         end
    --     elseif sounds.reverseWhine then
    --         sounds.reverseWhine:Stop()
    --         sounds.reverseWhine = nil
    --     end
    -- end
	
	ENT.SirenLoopSound = ")mokanfs/siren/siren1.wav"
	ENT.SirenLoopAltSound = ")mokanfs/siren/sirenalt1.wav"
	
	function ENT:GenerateLightSprites(lightdata, vehicleBodygroups)
		local LightSprites = {}

		-- Default colors per light type
		local colorMap = {
			headlight_low  = { Color(100,165,255), Color(180,210,255) },
			headlight_high = { Color(100,165,255), Color(180,210,255) },
			brake          = Color(255,0,0,200),
			taillight      = Color(255,0,0,50),
			reverse        = Color(255,255,255),
			signal_left    = Color(255,140,0),
			signal_right   = Color(255,140,0),
		}

		-- Default sizes per light type
		local sizeMap = {
			headlight_low  = { 60, 12 },
			headlight_high = { 80, 24 },
			brake          = 25,
			taillight      = 25,
			reverse        = 25,
			signal_left    = 40,
			signal_right   = 40,
		}

		-- Headlight materials (outer flare + glow)
		local headlightMaterials = {
			Material("mokanfsw/universal/textures/lights/headlightflareouter"),
			Material("mokanfsw/universal/textures/lights/headlightglow"),
		}

		-- Iterate through all light types
		for lightType, entries in pairs(lightdata) do
			for key, entry in pairs(entries) do
				local pos = entry.pos
				if not pos then
					print("[GenerateLightSprites] Skipping light:", lightType, key, "(missing pos)")
					continue
				end

				local dir = entry.dir or Vector(0, 0, 0)

				if entry.bodygroups then
					for _, bg in ipairs(entry.bodygroups) do
						local bgid, subid = bg[1], bg[2]

						local duplicated = table.Copy(entry)
						duplicated.ifBodygroupId = bgid
						duplicated.ifSubModelId = subid
						duplicated.bodygroups = nil
						
						if lightType == "headlight" then
							for beamType, colorType in pairs({ low = "headlight_low", high = "headlight_high" }) do
								local colors = colorMap[colorType]
								local sizes = sizeMap[colorType]

								for i = 1, #colors do
									table.insert(LightSprites, {
										type = "headlight",
										beamType = beamType,
										offset = duplicated.pos,
										dir = duplicated.dir,
										color = duplicated.color or colors[i],
										size  = duplicated.size or sizes[i],
										spriteMaterial = headlightMaterials[i],
										ifBodygroupId = bgid,
										ifSubModelId  = subid,
									})
								end
							end
						else
							table.insert(LightSprites, {
								type = lightType,
								offset = duplicated.pos,
								dir = duplicated.dir,
								color = duplicated.color or colorMap[lightType],
								size  = duplicated.size  or sizeMap[lightType],
								spriteMaterial = duplicated.spriteMaterial,
								ifBodygroupId = bgid,
								ifSubModelId  = subid,
							})
						end
					end

					continue
				end
				----------------------------------------------------------------------

				if lightType == "headlight" then
					for beamType, colorType in pairs({ low = "headlight_low", high = "headlight_high" }) do
						local colors = colorMap[colorType]
						local sizes = sizeMap[colorType]

						for i = 1, #colors do
							table.insert(LightSprites, {
								type = "headlight",
								beamType = beamType,
								offset = pos,
								dir = dir,
								color = entry.color or colors[i],
								size  = entry.size or sizes[i],
								spriteMaterial = headlightMaterials[i],
							})
						end
					end
				else
					table.insert(LightSprites, {
						type = lightType,
						offset = pos,
						dir = dir,
						color = entry.color or colorMap[lightType],
						size  = entry.size  or sizeMap[lightType],
						spriteMaterial = entry.spriteMaterial,
					})
				end
			end
		end

		return LightSprites
	end

	function ENT:GenerateSirenLights(coplights, timings, spriteMaterial, lightbarConfig, coplightsize)
		local SirenLights = {}

		local colorMap = {
			red = Color(255, 100, 100),
			blue = Color(0, 150, 255),
			white1 = Color(255, 255, 255),
			white2 = Color(255, 255, 255),
		}

		local lightRadiusMap = {
			red = 100,
			blue = 100,
			white1 = 0,
			white2 = 0,
		}

		local lbIndices = lightbarConfig and lightbarConfig.indices or {}
		local lbBodygroup = lightbarConfig and lightbarConfig.bodygroupId or nil
		local lbSubmodel = lightbarConfig and lightbarConfig.subModelId or nil

		-- Determine size multiplier based on coplightsize
		local sizeMultiplier = 1
		if coplightsize == small then
			sizeMultiplier = 0.5
		elseif coplightsize == vsmall then
			sizeMultiplier = 0.25
		end

		for colorName, vectors in pairs(coplights) do
			local lightColor = colorMap[colorName]
			local timeList = timings[colorName]
			local lightRadiusVal = lightRadiusMap[colorName]
			local indices = lbIndices[colorName]

			for i, vec in ipairs(vectors) do
				local isLightbar = false

				if indices then
					for _, idx in ipairs(indices) do
						if i == idx then
							isLightbar = true
							break
						end
					end
				end

				for _, t in ipairs(timeList) do
					local lightEntry1 = {
						offset = vec,
						spriteMaterial = spriteMaterial or Material("mokanfsw/universal/textures/lights/headlightflareouter"),
						time = t,
						duration = 0.05,
						lightRadius = lightRadiusVal,
						size = 80 * sizeMultiplier,
						color = lightColor,
					}
					local lightEntry2 = {
						offset = vec,
						spriteMaterial = Material("mokanfsw/universal/textures/lights/headlightglow"),
						time = t,
						duration = 0.05,
						lightRadius = 0,
						size = 40 * sizeMultiplier,
						color = lightColor,
					}

					if isLightbar and lbBodygroup and lbSubmodel then
						lightEntry1.ifBodygroupId = lbBodygroup
						lightEntry1.ifSubModelId = lbSubmodel
						lightEntry2.ifBodygroupId = lbBodygroup
						lightEntry2.ifSubModelId = lbSubmodel
					end

					table.insert(SirenLights, lightEntry1)
					table.insert(SirenLights, lightEntry2)
				end
			end
		end

		return SirenLights
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

	-- function ENT:SetSubMaterialSafe(id, mat) -- Unused for now
		-- self._LastSubMaterials = self._LastSubMaterials or {}

		-- if self._LastSubMaterials[id] == mat then return end

		-- self._LastSubMaterials[id] = mat
		-- self:SetSubMaterial(id, mat)
	-- end

	-- ENT.LightSubMaterials = {
		-- Headlights = {10, 18},
		-- Rearlights = {8},
		-- Brakelights = {3}
	-- }
	
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

	function ENT:NFSW_UpdatePlate()
		if not self.PlateSubMaterial then return end

		local plateMat = self:GetNWString("PlateMaterial", "")
		if self.AssignRandomPlate and plateMat ~= "" then
			self:SetSubMaterial(self.PlateSubMaterial, plateMat)
			self.AssignRandomPlate = false
		end
	end
end

if SERVER then
	function ENT:AssignRandomPlate()
		local plateFiles = file.Find("materials/mokanfsw/universal/plates/*", "GAME")

		if #plateFiles > 0 then
			local randomFile = plateFiles[math.random(1, #plateFiles)]
			local materialPath = "mokanfsw/universal/plates/" .. string.StripExtension(randomFile)
			self:SetNWString("PlateMaterial", materialPath)
			-- print("[RandomPlate] Set Plate to " .. materialPath)
		else
			self:SetNWString("PlateMaterial", "")
			-- print("[RandomPlate] No plate materials found in mokanfsw/universal/plates/")
		end
	end
	
	function ENT:PreEntityCopy()
		local info = {
			PlateMaterial = self:GetNWString("PlateMaterial", "")
		}
		duplicator.StoreEntityModifier(self, "RandomPlateData", info)
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		if ent.EntityMods and ent.EntityMods.RandomPlateData then
			local info = ent.EntityMods.RandomPlateData
			if info.PlateMaterial and info.PlateMaterial ~= "" then
				ent:SetNWString("PlateMaterial", info.PlateMaterial)
			else
				ent:AssignRandomPlate()
			end
		else
			ent:AssignRandomPlate()
		end
	end
	
	hook.Add("OnEntityCreated", "MokaAssignRandomPlate", function(ent)
		timer.Simple(0.1, function()
			if not IsValid(ent) then return end
			if not ent.AssignRandomPlate then return end

			local plate = ent:GetNWString("PlateMaterial", "")
			if plate == "" then
				ent:AssignRandomPlate()
			end
		end)
	end)

    ENT.BurnoutForce = 40
    ENT.UnflipForce = 20
	
    ENT.AirControlForce = Vector( 0.8, 0.6, 0.8 )
    ENT.AirMaxAngularVelocity = Vector( 290, 280, 290 )

	function ENT:SwitchGear( index, cooldown )
		if self:GetGear() == index then return end

		index = math.Clamp( index, self.minGear, self.maxGear )
		
		local cdTable = self:GetGearCooldowns()
		self.switchCD = cooldown or cdTable[index] or 0.25
		self.clutch = 1
		self:SetGear( index )
	end

    function ENT:DetachGibs(table)
        for i = 1, #table do
            local gib = ents.Create("prop_physics")
            gib:SetModel(table[i])
            gib:SetPos(self:GetPos())
            gib:SetAngles(self:GetAngles())
            gib:SetColor(self:GetColor())
            gib:SetCollisionGroup(COLLISION_GROUP_WORLD)
            gib:Spawn()
            if IsValid(gib:GetPhysicsObject()) then
                gib:GetPhysicsObject():SetVelocity(self:GetVelocity())
            end
            timer.Simple(15, function() --You can adjust the despawn time here
                if IsValid(gib) then
                    gib:Remove()
                end
            end)
        end
    end
	
	function ENT:_ApplyColorToWheel( wheel, color )
		if not IsValid( wheel ) or wheel:GetClass() ~= "glide_wheel" then return end

		wheel:SetColor( color )
		wheel:SetRenderMode( RENDERMODE_TRANSALPHA )
	end
	
	function ENT:WheelColor( color, index )
		if not IsColor( color ) then return end

		-- Queue requests if wheels are not ready yet
		self._queuedWheelColors = self._queuedWheelColors or {}

		table.insert( self._queuedWheelColors, {
			color = color,
			index = index
		})

		-- Apply on next tick (only once)
		if self._wheelColorTimer then return end
		self._wheelColorTimer = true

		timer.Simple( 0, function()
			if not IsValid( self ) then return end
			if type( self.wheels ) ~= "table" then return end

			for _, request in ipairs( self._queuedWheelColors ) do
				if request.index then
					local wheel = self.wheels[ request.index ]
					if IsValid( wheel ) then
						self:_ApplyColorToWheel( wheel, request.color )
					end
				else
					for _, wheel in pairs( self.wheels ) do
						self:_ApplyColorToWheel( wheel, request.color )
					end
				end
			end

			-- cleanup
			self._queuedWheelColors = nil
			self._wheelColorTimer = nil
		end )
	end
end