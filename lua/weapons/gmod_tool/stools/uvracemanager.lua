TOOL.Category = "uv.unitvehicles"
TOOL.Name = "#tool.uvracemanager.name"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["speedlimit"] = 50
TOOL.ClientConVar["laps"] = 1

cleanup.Register("uvrace_ents")

-- Tool modes
local MODE_CHECKPOINT = 0
local MODE_GRID = 1
local MODE_NODE = 2

local MAX_MODE = 1 -- Restrict to GRID only for now

local MAX_TRACE_LENGTH = math.sqrt(3) * 2 * 16384
local checkpointTable = {}
local pos1, selectedCP
local secondClick = false

if SERVER then
	TOOL.nodeTable = TOOL.nodeTable or  {}

	-- Add node function
	function TOOL:AddNode(pos)
		local newNode = {
			Pos = pos,
			Links = {},
			SpeedLimit = GetConVar("uvracemanager_speedlimit"):GetInt(),
			WaitTime = 0
		}

		local id = #self.nodeTable + 1
		self.nodeTable[id] = newNode

		-- auto-link previous node
		if id > 1 then
			self.nodeTable[id - 1].Links[#self.nodeTable[id - 1].Links + 1] = id
			newNode.Links[#newNode.Links + 1] = id - 1
		end

		-- network to clients
		net.Start("UVRace_AddNode")
		net.WriteUInt(id, 16)
		net.WriteVector(pos)
		net.Send(player.GetAll())

		return id
	end

	-- Remove node function
	function TOOL:RemoveNode(id)
		if not self.nodeTable[id] then return end

		-- Remove links pointing to this node
		for _, node in pairs(self.nodeTable) do
			for i = #node.Links, 1, -1 do
				if node.Links[i] == id then
					table.remove(node.Links, i)
				end
			end
		end

		self.nodeTable[id] = nil

		-- network removal
		net.Start("UVRace_RemoveNode")
		net.WriteUInt(id, 16)
		net.Send(player.GetAll())
	end

	-- Toggle link between two nodes
	function TOOL:ToggleLink(a, b)
		if not self.nodeTable[a] or not self.nodeTable[b] then return end

		local linksA = self.nodeTable[a].Links
		local linksB = self.nodeTable[b].Links

		local idx = table.Find(linksA, b)
		if idx then
			table.remove(linksA, idx)
		else
			linksA[#linksA + 1] = b
		end

		-- reciprocal
		if not table.HasValue(linksB, a) then
			linksB[#linksB + 1] = a
		else
			local idx2 = table.Find(linksB, a)
			table.remove(linksB, idx2)
		end

		net.Start("UVRace_UpdateLink")
		net.WriteUInt(a, 16)
		net.WriteUInt(b, 16)
		net.Send(player.GetAll())
	end

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

	net.Receive("UVRace_ToolMode", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep:IsWeapon() then return end

		if wep:GetClass() ~= "gmod_tool" then return end

		local tool = wep:GetToolObject()
		if not tool then return end

		tool.ToolMode = net.ReadUInt(2)
	end)

	local ClientNodes = {}

	net.Receive("UVRace_AddNode", function()
		local id = net.ReadUInt(16)
		local pos = net.ReadVector()
		ClientNodes[id] = { Pos = pos, Links = {} }
	end)

	net.Receive("UVRace_RemoveNode", function()
		local id = net.ReadUInt(16)
		ClientNodes[id] = nil
	end)

	net.Receive("UVRace_UpdateLink", function()
		local a = net.ReadUInt(16)
		local b = net.ReadUInt(16)
		if ClientNodes[a] and ClientNodes[b] then
			local links = ClientNodes[a].Links
			if not table.HasValue(links, b) then
				links[#links + 1] = b
			else
				for i = #links, 1, -1 do
					if links[i] == b then table.remove(links, i) end
				end
			end
		end
	end)

	TOOL.Information = {
		{ name = "info",      stage = 3 },
		{ name = "left_node", stage = 3 },
		{ name = "right_node",stage = 3 },
		{ name = "reload",    stage = 3 },

		{ name = "info",      stage = 2 },
		{ name = "left_grid", stage = 2 },
		{ name = "reload",    stage = 2 },

		{ name = "info", stage = 1 },
		{ name = "left", stage = 1 },
		{ name = "use",  stage = 1 },

		{ name = "info",   stage = 0 },
		{ name = "left",   stage = 0 },
		{ name = "right",  stage = 0 },
		{ name = "reload", stage = 0 },
	}

	CreateClientConVar("unitvehicle_cpheight", 64)
	
	local ang0 = Angle(0, 0, 0)
	local vec0 = Vector(0, 0, 0)
	
	local col_white = Color(255, 255, 255)
	local col_blue = Color(0, 0, 255, 200)
	local col_red = Color(255, 0, 0, 200)
	
	function TOOL:DrawHUD()
		local ply = self:GetOwner()
		if not IsValid(ply) then return end

		local startpos = ply:EyePos()
		local tr = util.TraceLine({
			start = startpos,
			endpos = startpos + (ply:GetAimVector() * MAX_TRACE_LENGTH),
			filter = ply
		})
		local hp = tr.HitPos

		cam.Start3D()
		render.SetColorMaterial()

		-- Draw nodes
		for id, node in pairs(ClientNodes or {}) do
			-- Sphere
			render.DrawSphere(node.Pos, 8, 12, 12, col_white)

			-- Draw node ID above the node
			-- cam.Start3D2D(node.Pos + Vector(0,0,12), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 1)
				-- draw.SimpleText(tostring(id), "DermaDefault", 0, 0, Color(255,255,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			-- cam.End3D2D()

			-- Links
			for _, linkedID in ipairs(node.Links) do
				local other = ClientNodes[linkedID]
				if other then
					render.DrawLine(node.Pos, other.Pos, col_red)
				end
			end
		end

		-- Draw checkpoint preview if pos1 exists
		if pos1 then
			render.DrawBox(pos1, Angle(0,0,0), Vector(0,0,0), hp - pos1, col_blue)
		end

		-- Crosshair
		render.DrawLine(hp + Vector(0, 10, 0), hp - Vector(0, 10, 0), Color(255,255,255))
		render.DrawLine(hp + Vector(10, 0, 0), hp - Vector(10, 0, 0), Color(255,255,255))
		render.DrawLine(hp + Vector(0, 0, 10), hp - Vector(0, 0, 10), Color(255,255,255))

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

function TOOL:Initialize()
	self.ToolMode = self.ToolMode or MODE_CHECKPOINT
end

function TOOL:Deploy()
	self.ToolMode = self.ToolMode or MODE_CHECKPOINT
	self.secondClick = false

	if self.ToolMode == MODE_GRID then
		self:SetStage(2)
	elseif self.ToolMode == MODE_NODE then
		self:SetStage(3)
	else
		self:SetStage(0)
	end
end

function TOOL:Holster()
	self.secondClick = false
	self:SetStage(0)
end

function TOOL:LeftClick(trace)
	if not trace.Hit then return end
	if CLIENT then return true end

	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end

	if self.ToolMode == MODE_GRID then
		local spawn = ents.Create("uvrace_spawn")
		if not IsValid(spawn) then return end
		
		self:SetStage(2)

		spawn:SetAngles(Angle(0, ply:EyeAngles().y, 0))
		spawn:SetPos(trace.HitPos)
		spawn:Spawn()

		undo.Create("UVRaceEnt")
		undo.AddEntity(spawn)
		undo.SetPlayer(ply)
		undo.Finish()
		ply:AddCleanup("uvrace_ents", spawn)
		return true
	end
	
	if self.ToolMode == MODE_NODE then
		local ply = self:GetOwner()
		if not ply:IsSuperAdmin() then return true end

		local hitPos = trace.HitPos
		local nodeID = self:AddNode(hitPos)

		undo.Create("UVRaceNode")
		undo.AddFunction(function()
			self:RemoveNode(nodeID)
		end)
		undo.SetPlayer(ply)
		undo.Finish()

		return true
	end

	local hitPos = trace.HitPos
	local pos, chunk

	if InfMap then
		pos, chunk = InfMap.localize_vector(hitPos)
	else
		pos = hitPos
		chunk = Vector()
	end

	local keyPos = self.secondClick and "Pos1" or "Pos0"
	local keyChunk = self.secondClick and "Chunk1" or "Chunk0"

	self[keyPos] = pos
	self[keyChunk] = chunk
	
	net.Start("UVRace_UpdatePos")
	net.WriteBool(self.secondClick) -- is pos2?
	net.WriteVector(pos)
	net.WriteBool(InfMap ~= nil)
	if InfMap then
		net.WriteVector(chunk)
	end
	net.Send(ply)

	if self.secondClick then
		if ply:KeyDown(IN_USE) then
			self.Pos1.z = self.Pos1.z + GetConVar("unitvehicle_cpheight"):GetInt()
		end

		local cp = ents.Create("uvrace_checkpoint")
		if not IsValid(cp) then return end

		local svPos = InfMap and InfMap.unlocalize_vector(self.Pos0, self.Chunk0) or self.Pos0
		local svMax = InfMap and InfMap.unlocalize_vector(self.Pos1, self.Chunk1) or self.Pos1

		cp:SetPos(svPos)
		cp:SetMaxPos(svMax)
		cp:SetLocalPos(self.Pos0)
		cp:SetLocalMaxPos(self.Pos1)
		cp:SetChunk(self.Chunk0)
		cp:SetChunkMax(self.Chunk1)

		cp:SetSpeedLimit(GetConVar("uvracemanager_speedlimit"):GetInt())
		cp:Spawn()

		undo.Create("UVRaceEnt")
		undo.AddEntity(cp)
		undo.SetPlayer(ply)
		undo.Finish()

		ply:AddCleanup("uvrace_ents", cp)
	end

	self:SetStage(self.secondClick and 0 or 1)
	self.secondClick = not self.secondClick
	return true
end

function TOOL:RightClick()
	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * MAX_TRACE_LENGTH,
		filter = ply
	})

	local ent = tr.Entity
	if not IsValid(ent) then return end

	if self.ToolMode == MODE_CHECKPOINT and ent:GetClass() == "uvrace_checkpoint" then
		net.Start("UVRace_SelectID")
		net.WriteEntity(ent)
		net.Send(ply)
		return true
	end
	
	if self.ToolMode == MODE_NODE then
		local ply = self:GetOwner()
		if not ply:IsSuperAdmin() then return true end

		local tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:GetAimVector() * MAX_TRACE_LENGTH,
			filter = ply
		})
		local pos = tr.HitPos

		-- Find nearest node
		local nearestID, nearestDist = nil, 1e9
		for id, node in pairs(self.nodeTable) do
			local dist = node.Pos:Dist(pos)
			if dist < nearestDist then
				nearestDist = dist
				nearestID = id
			end
		end
		if not nearestID then return true end

		if self.SelectedNode then
			if self.SelectedNode == nearestID then
				-- double click = remove
				self:RemoveNode(nearestID)
			else
				self:ToggleLink(self.SelectedNode, nearestID)
			end
		end

		self.SelectedNode = nearestID
		return true
	end
end

function TOOL:Reload(trace)
	if CLIENT then return true end

	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	if self.secondClick then return end

	self.ToolMode = self.ToolMode or MODE_CHECKPOINT

	self.ToolMode = self.ToolMode + 1
	if self.ToolMode > MAX_MODE then
		self.ToolMode = MODE_CHECKPOINT
	end

	self.secondClick = false

	if self.ToolMode == MODE_GRID then
		self:SetStage(2)
	elseif self.ToolMode == MODE_NODE then
		self:SetStage(3)
	else
		self:SetStage(0)
	end

	net.Start("UVRace_ToolMode")
	net.WriteUInt(self.ToolMode, 2)
	net.Send(ply)

	return false
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

local toolicon_racer = Material("unitvehicles/icons/race_events.png", "ignorez")

function TOOL:DrawToolScreen(w, h)
	local mode = self.ToolMode or MODE_CHECKPOINT
	local modetext

	if mode == MODE_GRID then
		modetext = UVString("tool.uvracemanager.grid")
	elseif mode == MODE_NODE then
		modetext = UVString("tool.uvracemanager.node")
	else
		modetext = UVString("tool.uvracemanager.cp")
	end

	surface.SetDrawColor(Color(0,0,0))
	surface.DrawRect(0,0,w,h)
	
	surface.SetDrawColor(255,255,255,25)
	surface.SetMaterial(toolicon_racer)
	surface.DrawTexturedRect(0,0,w,h)

	draw.SimpleText( UVString("tool.uvracemanager.name"), "UVFont5Shadow", w * 0.5, h * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( modetext, "UVFont5UI", w * 0.5, h * 0.45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

if CLIENT then
	concommand.Add("uvrace_queryimport", function()
		UVMenu.OpenMenu(UVMenu.RaceManagerTrackSelect, true)
	end)
	
	concommand.Add("uvrace_racemenu", function()
		UVMenu.OpenMenu(UVMenu.RaceManagerStartRace, true)
	end)
end