include("shared.lua")

local mat = Material("sprites/light_glow02_add")
local matr = Matrix()
local Headlights = GetConVar("unitvehicle_enableheadlights")

function ENT:Initialize()

	self.Model = self:GetModel()

	if self.Model == "models/uvair_default.mdl" then
		self.SpotlightPos = Vector(159.89,0,11.88)
		self.StrobePos = Vector(-391.33,0,141.96)
		self.StrobePos2 = Vector(34.67,0,23.31)
		self.PortPos = Vector(-256.3,57.13,62.06)
		self.StarboardPos = Vector(-256.3,-57.13,62.06)
		self.SternPos = Vector(-380.99,0,67.72)
	elseif self.Model == "models/hp2heliai/hp2heliai.mdl" then
		self.SpotlightPos = Vector(77.65,0,-60.62)
		self.StrobePos = Vector(-71.47,0,25.84)
		self.StrobePos2 = Vector(-7.27,0,-68.58)
		self.PortPos = Vector(-247.8,39.53,60.79)
		self.StarboardPos = Vector(-247.8,-49.77,60.79)
		self.SternPos = Vector(-234.44,-5.02,-5.88)
	elseif self.Model == "models/nfs_mwpolhel/nfs_mwpolhel.mdl" then
		self.SpotlightPos = Vector(85,0,25)
		self.StrobePos = Vector(-295,0,140)
		self.StrobePos2 = Vector(-28.07,0,17.35)
		self.PortPos = Vector(-6.28,77.58,32.67)
		self.StarboardPos = Vector(-6.28,-77.58,32.67)
		self.SternPos = Vector(-298.67,-0.15,109.86)
	elseif self.Model == "models/nfs_ucpolhel/nfs_ucpolhel.mdl" then
		self.SpotlightPos = Vector(-110,0,35)
		self.StrobePos = Vector(-390,0,165)
		self.StrobePos2 = Vector(21.35,0,31.85)
		self.PortPos = Vector(-390.39,59.07,160.17)
		self.StarboardPos = Vector(-390.39,-59.07,160.17)
		self.SternPos = Vector(-390.09,0,129.25)
	elseif self.Model == "models/nfs_hppolhel/nfs_hppolhel.mdl" then
		self.SpotlightPos = Vector(124,0,21.9)
		self.StrobePos = Vector(-357.5,0,182.5)
		self.StrobePos2 = Vector(22.04,0,31.47)
		self.PortPos = Vector(-299.36,69.42,85.83)
		self.StarboardPos = Vector(-299.36,-69.42,85.83)
		self.SternPos = Vector(-386.26,0,104.55)
	elseif self.Model == "models/nfs_nlpolhel/nfs_nlpolhel.mdl" then
		self.SpotlightPos = Vector(96,0,13)
		self.StrobePos = Vector(-352,0,189)
		self.StrobePos2 = Vector(-207.08,0,66.06)
		self.PortPos = Vector(-260.58,60.42,97.85)
		self.StarboardPos = Vector(-260.58,-60.42,97.85)
		self.SternPos = Vector(-394.18,0,180.08)
	elseif self.Model == "models/nfs_paybackpolhel/nfs_paybackpolhel.mdl" then
		self.SpotlightPos = Vector(26,0,10)
		self.StrobePos = Vector(-457,0,220)
		self.StrobePos2 = Vector(-126.1,-0.61,42.66)
		self.PortPos = Vector(-95.66,77.16,71.55)
		self.StarboardPos = Vector(-95.66,-77.16,71.55)
		self.SternPos = Vector(-462.08,-0.74,72.05)
	elseif self.Model == "models/unboundheli/unboundheli.mdl" then
		self.SpotlightPos = Vector(28.63,0,-0.05)
		self.StrobePos = Vector(-465.71,0,200.94)
		self.StrobePos2 = Vector(-128.14,0,20.19)
		self.PortPos = Vector(-102.39,76.75,50.76)
		self.StarboardPos = Vector(-102.39,-76.75,50.76)
		self.SternPos = Vector(-472.19,0,50.45)
	elseif self.Model == "models/thecrewheli/thecrewheli.mdl" then
		self.SpotlightPos = Vector(126.11,0,16.96)
		self.StrobePos = Vector(-404.87,0,170.23)
		self.StrobePos2 = Vector(-53.16,0,22.9)
		self.PortPos = Vector(-284.61,62.39,99.24)
		self.StarboardPos = Vector(-284.61,-62.39,99.24)
		self.SternPos = Vector(-402.28,0,106.04)
	elseif self.Model == "models/NFSU_COPHELI/NFSU_COPHELI.mdl" then
		self.SpotlightPos = Vector(85,0,25)
		self.StrobePos = Vector(-295,0,140)
		self.StrobePos2 = Vector(-28.07,0,17.35)
		self.PortPos = Vector(-6.28,77.58,32.67)
		self.StarboardPos = Vector(-6.28,-77.58,32.67)
		self.SternPos = Vector(-298.67,-0.15,109.86)
	end

	self.RotorSoundPatch = "<chopper/mwheli.wav"
	self.Rotor2SoundPatch = "<chopper/mwheli2.wav"
	self.Rotor3SoundPatch = "<chopper/mwheli3.wav"
	self.Rotor4SoundPatch = "<chopper/mwheli4.wav"

	self.RotorSound = CreateSound(self,self.RotorSoundPatch)
	self.RotorSound:SetSoundLevel(85)
	self.RotorSound:Play()
	self.RotorSound2 = CreateSound(self,self.Rotor2SoundPatch)
	self.RotorSound2:SetSoundLevel(85)
	self.RotorSound2:Play()
	self.RotorSound3 = CreateSound(self,self.Rotor3SoundPatch)
	self.RotorSound3:SetSoundLevel(85)
	self.RotorSound3:Play()
	self.RotorSound4 = CreateSound(self,self.Rotor4SoundPatch)
	self.RotorSound4:SetSoundLevel(85)
	self.RotorSound4:Play()
	
	self.Spotlight = ProjectedTexture()
	self.Spotlight:SetTexture("effects/flashlight001")
	self.Spotlight:SetFarZ(2048)
	self.Spotlight:SetFOV(50)
	self.Spotlight:SetColor(color_white)
	local pos,ang = LocalToWorld(self.SpotlightPos,Angle(),self:GetPos(),self:GetAngles())
	self.Spotlight:SetPos(pos)
	self.Spotlight:SetAngles(ang)
	self.Spotlight:SetEnableShadows(false)
	self.Spotlight:Update()
	
	self:DrawShadow(true)
	self.Scale = Vector(1,1,1)

	self.canusespotlight = false

	timer.Create("UVAirSpotlight" .. self:EntIndex(), 1, 0, function()
		if not IsValid(self) then
			return
		end

		if Headlights:GetInt() == 0 then
			self.canusespotlight = false
			return
		elseif Headlights:GetInt() == 2 then
			self.canusespotlight = true
			return
		end

	    if not IsValid(self:GetTarget()) then 
			self.canusespotlight = false
			return 
		end

	    local c = render.ComputeLighting( self:GetTarget():GetPos(), Vector( 0, 0, 1 ) )
	    local avg = ( c[1] * 0.2126 ) + ( c[2] * 0.7152 ) + ( c[3] * 0.0722 ) -- Luminosity method
	    local shouldBeOn = Either( self.canusespotlight, avg < 1.3, avg < 0.2 )

	    self.canusespotlight = shouldBeOn
	end)
end

function ENT:Draw()
	local vel = WorldToLocal(self:GetVelocity(),Angle(),Vector(),Angle(0,self:GetAngles().y,0))
	local speed = self:GetVelocity():Length2D()
	
	self.Scale = Vector(1,1,1)
	matr:SetScale(self.Scale)

	self:EnableMatrix("RenderMultiply",matr)
	self:DrawModel()
	
	local spotpos = self.Spotlight:GetPos()
	local strobepos = LocalToWorld(self.StrobePos*self.Scale,Angle(),self:GetPos(),self:GetAngles())
	local strobepos2 = LocalToWorld(self.StrobePos2*self.Scale,Angle(),self:GetPos(),self:GetAngles())
	local portpos = LocalToWorld(self.PortPos*self.Scale,Angle(),self:GetPos(),self:GetAngles())
	local starboardpos = LocalToWorld(self.StarboardPos*self.Scale,Angle(),self:GetPos(),self:GetAngles())
	local sternpos = LocalToWorld(self.SternPos*self.Scale,Angle(),self:GetPos(),self:GetAngles())
	
	local spotdist = EyePos():Distance(spotpos)
	local strobedist = EyePos():Distance(strobepos)
	local strobedist2 = EyePos():Distance(strobepos2)
	local portdist = EyePos():Distance(portpos)
	local starboarddist = EyePos():Distance(starboardpos)
	local sterndist = EyePos():Distance(sternpos)
	
	if IsValid(self:GetTarget()) and self.canusespotlight and spotdist<10000 and util.TraceLine({start = EyePos(),endpos = spotpos,filter = LocalPlayer(),mask = MASK_OPAQUE}).Fraction==1 then
		mat:SetInt("$ignorez",0)
		
			render.SetMaterial(mat)
			render.DrawSprite(spotpos,256,256,Color(255,255,255,255-spotdist/10000*255))
		
		mat:SetInt("$ignorez",1)
	end
	
	if strobedist<10000 and math.floor(CurTime()*1)==math.Round(CurTime()*1) and util.TraceLine({start = EyePos(),endpos = strobepos,filter = LocalPlayer(),mask = MASK_OPAQUE}).Fraction==1 then
		mat:SetInt("$ignorez",0)
		
			render.SetMaterial(mat)
			render.DrawSprite(strobepos,128,128,Color(255,0,0,255-strobedist/10000*255))
		
		mat:SetInt("$ignorez",1)
	end

	if strobedist2<10000 and math.floor(CurTime()*1.1)==math.Round(CurTime()*1.1) and util.TraceLine({start = EyePos(),endpos = strobepos2,filter = LocalPlayer(),mask = MASK_OPAQUE}).Fraction==1 then
		mat:SetInt("$ignorez",0)
		
			render.SetMaterial(mat)
			render.DrawSprite(strobepos2,128,128,Color(255,0,0,255-strobedist2/10000*255))
		
		mat:SetInt("$ignorez",1)
	end

	if portdist<10000 and util.TraceLine({start = EyePos(),endpos = portpos,filter = LocalPlayer(),mask = MASK_OPAQUE}).Fraction==1 then
		mat:SetInt("$ignorez",0)
		
			render.SetMaterial(mat)
			render.DrawSprite(portpos,64,64,Color(255,0,0,255-portdist/10000*255))
		
		mat:SetInt("$ignorez",1)
	end

	if starboarddist<10000 and util.TraceLine({start = EyePos(),endpos = starboardpos,filter = LocalPlayer(),mask = MASK_OPAQUE}).Fraction==1 then
		mat:SetInt("$ignorez",0)
		
			render.SetMaterial(mat)
			render.DrawSprite(starboardpos,64,64,Color(0,255,0,255-starboarddist/10000*255))
		
		mat:SetInt("$ignorez",1)
	end

	if sterndist<10000 and util.TraceLine({start = EyePos(),endpos = sternpos,filter = LocalPlayer(),mask = MASK_OPAQUE}).Fraction==1 then
		mat:SetInt("$ignorez",0)
		
			render.SetMaterial(mat)
			render.DrawSprite(sternpos,64,64,Color(255,255,255,255-sterndist/10000*255))
		
		mat:SetInt("$ignorez",1)
	end

end

function ENT:Think()
	local speed = self:GetVelocity():Length()
	
	self.RotorSound:ChangePitch(100+math.Round(math.Clamp(speed/80,0,5),1))
	self.RotorSound2:ChangePitch(self.RotorSound:GetPitch(),1)
	self.RotorSound3:ChangePitch(self.RotorSound:GetPitch(),1)
	self.RotorSound4:ChangePitch(self.RotorSound:GetPitch(),1)
	
	self.Spotlight:SetPos(LocalToWorld(self.SpotlightPos*self.Scale,Angle(),self:GetPos(),self:GetAngles()))
	if IsValid(self:GetTarget()) and self.canusespotlight then
		self.Spotlight:SetBrightness(10)
		self.Spotlight:SetAngles((self:GetTargetPos()-self.Spotlight:GetPos()):Angle())
	else
		self.Spotlight:SetBrightness(0)
	end
	self.Spotlight:Update()

	if not self.NextGroundFX then self.NextGroundFX = 0 end

	local pos = self:GetPos()
	local floor = util.TraceLine({
		start = pos,
		endpos = pos - Vector(0,0,1000),
		filter = self,
		mask = MASK_ALL
	})

	if floor.Hit then
		local height = pos.z - floor.HitPos.z

		if height < 600 and CurTime() > self.NextGroundFX then
			local strength = math.Clamp(1 - (height / 600), 0, 1)

			local effectdata = EffectData()
			effectdata:SetOrigin( floor.HitPos )
			effectdata:SetScale( strength * 1000 )
			effectdata:SetEntity( self )
			util.Effect( "ThumperDust", effectdata )

			local watereffectdata = EffectData()
			watereffectdata:SetOrigin( floor.HitPos )
			watereffectdata:SetScale( strength * 100 )
			watereffectdata:SetEntity( self )
			util.Effect( "waterripple", watereffectdata )

			self.NextGroundFX = CurTime() + Lerp(strength, 0.15, 0.06)
		end
	end	
end

function ENT:OnRemove()
	self.RotorSound:Stop()
	self.RotorSound2:Stop()
	self.RotorSound3:Stop()
	self.RotorSound4:Stop()
	self.Spotlight:Remove()
end