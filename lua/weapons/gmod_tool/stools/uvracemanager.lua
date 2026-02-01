TOOL.Category = "uv.unitvehicles"
TOOL.Name = "#tool.uvracemanager.name"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["speedlimit"] = 50
TOOL.ClientConVar["laps"] = 1

cleanup.Register("uvrace_ents")

local MAX_TRACE_LENGTH = math.sqrt(3) * 2 * 16384
local checkpointTable = {}
local pos1, selectedCP
local secondClick = false

if SERVER then
	local dvd = DecentVehicleDestination

	local function ImportExportText(name, export, ply)
		local nick = ply:Nick():lower():Replace(" ", "_")
				
		local racename = name
		
		local filename = "unitvehicles/races/" .. game.GetMap() .. "/" .. nick .. "." .. name .. ".txt"

		local str = export and "Exported UV Race to " .. filename or "Imported UV Race from " .. filename
		-- ply:ChatPrint(str)
		if export then
			ply:ChatPrint(str)
		end
	end

	UVRace_LoadedEntities = {}
	UVRace_LoadedConstraints = {}

	function UVLoadRace( jsonString )
		if type( jsonString ) ~= "string" then return end

		local startchar = string.find( jsonString, '' )
		if ( startchar != nil ) then
			jsonString = string.sub( jsonString, startchar )
		end

		jsonString = jsonString:reverse()
		local startchar = string.find( jsonString, '' )
		if ( startchar != nil ) then
			jsonString = string.sub( jsonString, startchar )
		end
		jsonString = jsonString:reverse()

		local saveArray = util.JSONToTable( jsonString )
		if not saveArray then return end

		if saveArray.Waypoints then
			UVRace_LoadedWaypoints = true
			dvd.Waypoints = table.Copy( saveArray.Waypoints )
			net.Start("Decent Vehicle: Clear waypoints")
			net.Broadcast()
			net.Start("Decent Vehicle: Retrive waypoints")
			dvd.WriteWaypoint(1)
			net.Broadcast()
		end

		for entityId, entityObject in pairs( UVRace_LoadedEntities ) do
			if IsValid( entityObject ) then entityObject:Remove() end
			UVRace_LoadedEntities[entityId] = nil
		end
 
		for entityId, entityObject in pairs( UVRace_LoadedConstraints ) do
			if IsValid( entityObject ) then entityObject:Remove() end
			UVRace_LoadedConstraints[entityId] = nil
		end

		local Entities = table.Copy( saveArray.Entities )
		local Constraints = table.Copy( saveArray.Constraints )

		UVRace_LoadedEntities = UVCreateEntitiesFromTable( Entities )

		for _k, Constraint in pairs( Constraints ) do
			local constraintEnt = nil

			ProtectedCall(function()
				constraintEnt = UVCreateConstraintsFromTable( Constraint, UVRace_LoadedEntities )
			end)

			if IsValid( constraintEnt ) then
				table.insert( UVRace_LoadedConstraints, constraintEnt )
			end
		end
	end

	function UVSaveRace( saveProps, saveDV )
		local AllowedEntities = ents.GetAll()

		for index, entity in ipairs( AllowedEntities ) do
			local shouldBeSaved = gmsave.ShouldSaveEntity( entity, entity:GetSaveTable() )
			local createdByMap = entity:CreatedByMap()
			local isConstraint = entity:IsConstraint()
			local isPursuitBreaker = entity.PursuitBreaker
			local isRoadblock = entity.UVRoadblock
			local isInvalid = not shouldBeSaved or createdByMap or isConstraint or isPursuitBreaker or isRoadblock or not saveProps

			if isInvalid then AllowedEntities[index] = nil end
		end

		table.insert( AllowedEntities, game.GetWorld() )

		local saveArray = duplicator.CopyEnts( AllowedEntities )
		if not saveArray then return end
		--print(saveDV, dvd)
		if saveDV and dvd then
			saveArray.Waypoints = table.Copy( dvd.Waypoints )
		end

		duplicator.FigureOutRequiredAddons( saveArray )
		return util.TableToJSON( saveArray )
	end

	local blacklist = {
		["uvrace_checkpoint"] = true,
		["uvrace_brushpoint"] = true,
		["uvrace_spawn"] = true,
	}
	
	local function Export(ply, cmd, args)
		if not ply:IsSuperAdmin() then return end
		local plynick = Entity(1):Nick()
		
		local str = "name " .. args[1] .. " '" .. plynick .. "'\n"
		
		local nick = plynick:lower():Replace(" ", "_")
		local name = args[1]:lower():Replace(" ", "_")
		
		local filename = "unitvehicles/races/" .. game.GetMap() .. "/" .. nick .. "." .. name .. ".txt"
		
		for _, ent in ipairs(ents.FindByClass("uvrace_checkpoint")) do
			ent.DoNotDuplicate = true
			local strinfmap = InfMap and " " .. tostring(ent:GetLocalPos()) .. " " .. tostring(ent:GetLocalMaxPos()) .. " " .. tostring(ent:GetChunk()) .. " " .. tostring(ent:GetChunkMax()) or ""
			str = str .. tostring(ent:GetID()) .. " " .. tostring(ent:GetPos()) .. " " .. tostring(ent:GetMaxPos()) .. " " .. tostring(ent:GetSpeedLimit()) .. strinfmap .. "\n"
		end
		
		for _, ent in ipairs(ents.FindByClass("uvrace_spawn")) do
			ent.DoNotDuplicate = true
			str = str .. "spawn " .. tostring(ent:GetPos()) .. " " .. tostring(ent:GetAngles().y) .. " " .. tostring(ent:GetGridSlot()) .. "\n"
		end
		
		file.CreateDir("unitvehicles/races/" .. game.GetMap())
		file.Write(filename, str)

		--if args[2] then --Save props option
		local jsonfilename = "unitvehicles/races/" .. game.GetMap() .. "/" .. nick .. "." .. name .. ".json"
		local jsonstr = UVSaveRace( args[2] == "true", args[3] == "true" )

		file.Write(jsonfilename, jsonstr)
		--end
		
		ImportExportText(name, true, ply)
	end
	concommand.Add("uvrace_export", Export)
	
	local function SetID(len, ply)
		if not ply:IsSuperAdmin() then return end
		local ent = net.ReadEntity()
		local id = net.ReadUInt(16)
		local speedlimit = net.ReadUInt(16)
		
		ent:SetID(id)
		if speedlimit ~= 0 then
			ent:SetSpeedLimit(speedlimit)
		end
		if id == 65535 then
			ent:Remove()
			return
		end
		UVRaceCheckFinishLine()
	end
	net.Receive("UVRace_SetID", SetID)
elseif CLIENT then
	
	TOOL.Information = {
		{ name = "info", stage = 0},
		{ name = "left", stage = 0 },
		{ name = "right", stage = 0 },
		{ name = "reload", stage = 0 },
		
		{ name = "info", stage = 1},
		{ name = "left", stage = 1 },
		{ name = "use", stage = 1 },
	}
	
	//CreateClientConVar("unitvehicle_racelaps", "3")
	-- CreateClientConVar("unitvehicle_racetheme", "carbon - bending light")
	-- CreateClientConVar("unitvehicle_sfxtheme", "unbound")

	-- local files, folders = file.Find( "sound/uvracemusic/*", "GAME" )
	-- if folders ~= nil then
	-- 	if not table.HasValue( folders, GetConVar("unitvehicle_racetheme"):GetString() ) then
	-- 		GetConVar("unitvehicle_racetheme"):SetString("default")
	-- 	end	
	-- end
	
	
	CreateClientConVar("uvracemanager_dnftimer", "30", true, false)
	
	CreateClientConVar("unitvehicle_cpheight", 64)
	
	local ang0 = Angle(0, 0, 0)
	local vec0 = Vector(0, 0, 0)
	
	local col_white = Color(255, 255, 255)
	local col_blue = Color(0, 0, 255, 200)
	
	function TOOL:DrawHUD()
		local ply = self:GetOwner()
		
		local startpos = ply:EyePos()
		
		local tr = util.TraceLine({
			start = startpos,
			endpos = startpos + (ply:GetAimVector() * MAX_TRACE_LENGTH),
			filter = ply
		})
		
		if not tr.Hit then return end
		
		local hp = tr.HitPos
		
		cam.Start3D()
		render.SetColorMaterial()
		
		if pos1 then
			render.DrawBox(pos1, ang0, vec0, hp - pos1, col_blue)
		end
		
		render.DrawLine(hp + Vector(0, 10, 0), hp - Vector(0, 10, 0), col_white)
		render.DrawLine(hp + Vector(10, 0, 0), hp - Vector(10, 0, 0), col_white)
		render.DrawLine(hp + Vector(0, 0, 10), hp - Vector(0, 0, 10), col_white)
		
		cam.End3D()
	end
	
	local function Count()
		local cpIDTbl = {}
		local lang = language.GetPhrase
		
		for _, ent in ipairs(ents.FindByClass("uvrace_checkpoint")) do
			local index = cpIDTbl[ent:GetID()]

			if index then
				cpIDTbl[ent:GetID()] = index + 1
			else
				cpIDTbl[ent:GetID()] = 1
			end
		end
		
		for id, count in pairs(cpIDTbl) do
			local str = count > 1 and "tool.uvracemanager.count.checkpoints" or "tool.uvracemanager.count.checkpoint"
			chat.AddText(string.format(lang(str), count, id))
		end
		
		chat.AddText(string.format(lang("tool.uvracemanager.count.startpoint"),#ents.FindByClass("uvrace_spawn") ) )
	end
	concommand.Add("uvrace_count", Count)
	
	local function UpdatePos()
		local ispos2 = net.ReadBool()
		local pos = net.ReadVector()
		local chunk = net.ReadBool()
		if chunk then
			chunk = net.ReadVector()
		end
		
		if ispos2 then
			table.insert(checkpointTable, {pos1 = pos1, pos2 = pos, id = #checkpointTable})
			pos1 = nil
		else
			--print(pos)
			pos1 = pos
		end
	end
	net.Receive("UVRace_UpdatePos", UpdatePos)
	
	local function SelectID()
		local ent = net.ReadEntity()
		
		selectedCP = ent
		
		local cpID = ent:GetID()
		
		Derma_StringRequest("#tool.uvracemanager.checkpoint.setid", "#tool.uvracemanager.checkpoint.setid.desc", cpID, function(text)
			local id = tonumber(text)
			selectedCP:SetID(id)
			if GetConVar("uvracemanager_speedlimit"):GetInt() > 0 then
				selectedCP:SetSpeedLimit(GetConVar("uvracemanager_speedlimit"):GetInt())
			end
			
			net.Start("UVRace_SetID")
			net.WriteEntity(selectedCP)
			net.WriteUInt(id, 16)
			net.WriteUInt(GetConVar("uvracemanager_speedlimit"):GetInt(), 16)
			net.SendToServer()
			
		end, nil, "#addons.confirm", "#addons.cancel")
	end
	net.Receive("UVRace_SelectID", SelectID)

	local function UpdateVars( ply, cmd, args )
		local convar = args[1]
		local value = args[2]
		
		net.Start( "UVUpdateSettings" )
		
		net.WriteTable({
			[convar] = value
		})
		
		net.SendToServer()
	end
	concommand.Add("uvrace_updatevars", UpdateVars)
	
	local function QuerySaveProps(txt, exportDv)
		Derma_Query(
			"#tool.uvracemanager.export.props.desc",
			"#tool.uvracemanager.export.props",
			"#openurl.yes",
			function()
				chat.AddText("Exporting UV Race...")
				RunConsoleCommand("uvrace_export", txt, "true", exportDv) 
			end,
			"#openurl.nope",
			function()
				chat.AddText("Exporting UV Race...")
				RunConsoleCommand("uvrace_export", txt, "false", exportDv) 
			end
		)
	end

	local function QueryExport()
		Derma_StringRequest("#uv.tool.export.settings", "#tool.uvracemanager.export.desc", "", function(txt)
			Derma_Query("#tool.uvracemanager.export.dv.desc", "#tool.uvracemanager.export.dv", "#openurl.yes", function()
				QuerySaveProps(txt, "true")
			end, "#openurl.nope", function()
				QuerySaveProps(txt, "false")
			end)
		end, nil, "#addons.confirm", "#addons.cancel")
	end
	concommand.Add("uvrace_queryexport", QueryExport)
end

function TOOL:LeftClick(trace)
	if not trace.Hit then return end
	if CLIENT then return end
	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end

	local trHit = trace.HitPos

	local unlocalizedPos, chunk

	if InfMap then
		unlocalizedPos, chunk = InfMap.localize_vector( trace.HitPos )
	end

	local pos = unlocalizedPos or trace.HitPos
	chunk = chunk or Vector()

	local keyPos = self.secondClick and "Pos1" or "Pos0"
	local keyChunk = self.secondClick and "Chunk1" or "Chunk0"

	self[keyPos] = pos
	self[keyChunk] = chunk

	if self.secondClick then
		if ply:KeyDown( IN_USE ) then
			self.Pos1.z = self.Pos1.z + (GetConVar("unitvehicle_cpheight"):GetInt() or 64)
		end

		local cPoint = ents.Create("uvrace_checkpoint")

		local svPos = ( InfMap and InfMap.unlocalize_vector( self.Pos0, self.Chunk0 ) ) or self.Pos0
		local svMaxPos = ( InfMap and InfMap.unlocalize_vector( self.Pos1, self.Chunk1 ) ) or self.Pos1

		cPoint:SetPos(svPos)
		cPoint:SetMaxPos(svMaxPos)

		cPoint:SetLocalPos(self.Pos0)
		cPoint:SetLocalMaxPos(self.Pos1)

		cPoint:SetChunk(self.Chunk0)
		cPoint:SetChunkMax(self.Chunk1)

		if game.SinglePlayer() then
			cPoint:SetSpeedLimit(GetConVar("uvracemanager_speedlimit"):GetInt())
		end

		cPoint:Spawn()

		undo.Create("UVRaceEnt")
		undo.AddEntity(cPoint)
		undo.SetPlayer(ply)
		undo.Finish()
			
		ply:AddCleanup("uvrace_ents", cPoint)
	end

	if self.secondClick then
		self.Pos0 = nil
		self.Chunk0 = nil
		self.Pos1 = nil
		self.Chunk1 = nil
	end

	self:SetStage( self.secondClick and 0 or 1 )
	net.Start("UVRace_UpdatePos")

	net.WriteBool(self.secondClick)
	net.WriteVector(pos)

	net.WriteBool(chunk ~= nil)
	net.WriteVector(chunk)

	net.Send(ply)

	self.secondClick = not self.secondClick

	return true
end

function TOOL:RightClick()
	local ply = self:GetOwner()
	local startpos = ply:EyePos()
	if not ply:IsSuperAdmin() then return end
	
	local tr = util.TraceLine({
		start = startpos,
		endpos = startpos + (ply:GetAimVector() * MAX_TRACE_LENGTH),
		filter = ply
	})
	
	local ent = tr.Entity
	if ent:GetClass() ~= "uvrace_checkpoint" then return end
	
	selectedCP = ent

	net.Start("UVRace_SelectID")
	net.WriteEntity(ent)
	net.Send(self:GetOwner())
	
	return true
end

function TOOL:Reload( trace )
	if not trace.Hit then return end
	local hp = trace.HitPos
	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end
	
	if game.SinglePlayer() or SERVER then
		local spawn = ents.Create("uvrace_spawn")
		spawn:SetAngles(Angle(0, ply:EyeAngles().y, 0))
		spawn:Spawn()

		spawn:SetPos(hp + spawn:LocalToWorld(Vector(spawn:BoundingRadius(), 0, 0)))
		
		undo.Create("UVRaceEnt")
		undo.AddEntity(spawn)
		undo.SetPlayer(ply)
		undo.Finish()
		
		ply:AddCleanup("uvrace_ents", spawn)
	end
	
	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Button",  { Label	= "#uv.rm.loadrace", Command = "uvrace_queryimport" })
	panel:AddControl("Button",  { Label	= "#tool.uvracemanager.settings.saverace", Command = "uvrace_queryexport" })

	panel:AddControl("Label", {Text = "#uv.rm.startracereate"})
	local speed_slider = panel:NumSlider("#uv.rm.startracereate.speedlimit", "uvracemanager_speedlimit", 1, 500, 0)
	local cpheight_slider = panel:NumSlider("#uv.rm.startracereate.cpheight", "unitvehicle_cpheight", 1, 500, 0)
	
	panel:AddControl("Label", {Text = "#tool.uvracemanager.settings.clearassets"})
	panel:AddControl("Button", {Label = "#tool.uvracemanager.settings.clearassets.cp", Command = "uvrace_killcps"})
	panel:AddControl("Button", {Label = "#tool.uvracemanager.settings.clearassets.startpos", Command = "uvrace_killspawns"})
	panel:AddControl("Button", {Label = "#tool.uvracemanager.settings.clearassets.all", Command = "uvrace_killall"})
	panel:AddControl("Label", {Text = " "})
	panel:AddControl("Button", {Label = "#tool.uvracemanager.settings.getraceinfo", Command = "uvrace_count" })
	
end

if CLIENT then
	concommand.Add("uvrace_queryimport", function()
		UVMenu.OpenMenu(UVMenu.RaceManagerTrackSelect, true)
	end)
	
	concommand.Add("uvrace_racemenu", function()
		UVMenu.OpenMenu(UVMenu.RaceManagerStartRace, true)
	end)
end