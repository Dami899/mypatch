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
	UVRace_Nodes = UVRace_Nodes or {}
	UVRace_NextNodeID = UVRace_NextNodeID or 0
	TOOL.LastPlacedNode = nil
	local tool = TOOL
	
	function TOOL:GetNearestNode(pos, radius)
		local best, bestID
		local r2 = radius * radius

		for id, node in pairs(UVRace_Nodes) do
			local d2 = node.Pos:DistToSqr(pos)
			if d2 <= r2 and (not best or d2 < best) then
				best = d2
				bestID = id
			end
		end

		return bestID
	end

	function TOOL:AddNode(pos)
		UVRace_NextNodeID = UVRace_NextNodeID + 1
		local id = UVRace_NextNodeID

		UVRace_Nodes[id] = {
			Pos = pos,
			Links = {},
			SpeedLimit = GetConVar("uvracemanager_speedlimit"):GetInt(),
			Curve = 0
		}

		-- Auto-link logic
		local from = self.SelectedNode or self.LastPlacedNode
		if from and UVRace_Nodes[from] then
			UVRace_Nodes[from].Links[id] = true

			net.Start("UVRace_NodeLinks")
				net.WriteUInt(from, 16)
				net.WriteTable(UVRace_Nodes[from].Links)
			net.Broadcast()
		end

		self.LastPlacedNode = id

		net.Start("UVRace_NodeAdd")
			net.WriteUInt(id, 16)
			net.WriteVector(pos)
			net.WriteUInt(UVRace_Nodes[id].SpeedLimit, 16)
		net.Broadcast()

		return id
	end

	function TOOL:RemoveNode(id)
		if not UVRace_Nodes[id] then return end

		-- Remove links
		for nid, node in pairs(UVRace_Nodes) do
			if node.Links[id] then
				node.Links[id] = nil

				net.Start("UVRace_NodeLinks")
					net.WriteUInt(nid, 16)
					net.WriteTable(node.Links)
				net.Broadcast()
			end
		end

		UVRace_Nodes[id] = nil

		net.Start("UVRace_NodeRemove")
			net.WriteUInt(id, 16)
		net.Broadcast()
		
		if self.SelectedNode == id then
			self.SelectedNode = nil

			net.Start("UVRace_NodeSelect")
				net.WriteUInt(0, 16)
			net.Broadcast()
		end
	end

	function TOOL:ToggleLink(from, to)
		local A = UVRace_Nodes[from]
		local B = UVRace_Nodes[to]
		if not A or not B then return end

		if A.Links[to] then
			A.Links[to] = nil
		else
			A.Links[to] = {
				Curve = 0 -- default straight
			}
		end

		net.Start("UVRace_NodeLinks")
			net.WriteUInt(from, 16)
			net.WriteTable(A.Links)
		net.Broadcast()
	end

	function TOOL:ClearNodes()
		for id, _ in pairs(UVRace_Nodes) do
			-- Inform clients to remove the node
			net.Start("UVRace_NodeRemove")
				net.WriteUInt(id, 16)
			net.Broadcast()
		end

		UVRace_Nodes = {}
		self.LastPlacedNode = nil
		self.SelectedNode = nil
		UVRace_NextNodeID = 0
		
		net.Start("UVRace_ClearAllNodes")
		net.Broadcast()
	end

	net.Receive("UVRace_UpdateNodeSettings", function(_, ply)
		if not ply:IsSuperAdmin() then return end

		local id = net.ReadUInt(16)
		local speed = net.ReadUInt(16)

		local node = UVRace_Nodes[id]
		if not node then return end

		node.SpeedLimit = speed

		net.Start("UVRace_NodeAdd")
			net.WriteUInt(id, 16)
			net.WriteVector(node.Pos)
			net.WriteUInt(node.SpeedLimit, 16)
		net.Broadcast()
	end)

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

	function UVLoadRace(jsonString)
		if type(jsonString) ~= "string" then return end

		-- Clean up weird characters at start
		local startchar = string.find(jsonString, '')
		if startchar then
			jsonString = string.sub(jsonString, startchar)
		end

		jsonString = jsonString:reverse()
		startchar = string.find(jsonString, '')
		if startchar then
			jsonString = string.sub(jsonString, startchar)
		end
		jsonString = jsonString:reverse()

		local saveArray = util.JSONToTable(jsonString)
		if not saveArray then return end

		-- Load waypoints for DecentVehicleDestination
		if saveArray.Waypoints then
			UVRace_LoadedWaypoints = true
			dvd.Waypoints = table.Copy(saveArray.Waypoints)
			net.Start("Decent Vehicle: Clear waypoints")
			net.Broadcast()
			net.Start("Decent Vehicle: Retrive waypoints")
			dvd.WriteWaypoint(1)
			net.Broadcast()
		end

		-- Clear previous entities
		for entityId, entityObject in pairs(UVRace_LoadedEntities) do
			if IsValid(entityObject) then entityObject:Remove() end
			UVRace_LoadedEntities[entityId] = nil
		end

		-- Clear previous constraints
		for entityId, entityObject in pairs(UVRace_LoadedConstraints) do
			if IsValid(entityObject) then entityObject:Remove() end
			UVRace_LoadedConstraints[entityId] = nil
		end

		local Entities = table.Copy(saveArray.Entities)
		local Constraints = table.Copy(saveArray.Constraints)

		UVRace_LoadedEntities = UVCreateEntitiesFromTable(Entities)

		for _k, Constraint in pairs(Constraints) do
			local constraintEnt = nil

			ProtectedCall(function()
				constraintEnt = UVCreateConstraintsFromTable(Constraint, UVRace_LoadedEntities)
			end)

			if IsValid(constraintEnt) then
				table.insert(UVRace_LoadedConstraints, constraintEnt)
			end
		end

		-- Node init
		local importedIDs = {}
		tool:ClearNodes()

		if saveArray.Nodes then
			-- Create nodes
			for _, ndata in ipairs(saveArray.Nodes) do
				local id = ndata.ID
				
				UVRace_NextNodeID = math.max(UVRace_NextNodeID, id)
				importedIDs[id] = true

				UVRace_Nodes[id] = {
					Pos = Vector(ndata.Pos.x, ndata.Pos.y, ndata.Pos.z),
					Links = {},
					SpeedLimit = ndata.SpeedLimit or 0
				}
			end

			-- Restore links
			for _, ndata in ipairs(saveArray.Nodes) do
				local id = ndata.ID
				local node = UVRace_Nodes[id]
				if node and ndata.Links then
					node.Links = table.Copy(ndata.Links)
				end
			end
		end

		-- Broadcast nodes to clients
		for id, node in pairs(UVRace_Nodes) do
			net.Start("UVRace_NodeAdd")
				net.WriteUInt(id, 16)
				net.WriteVector(node.Pos)
				net.WriteUInt(node.SpeedLimit, 16)
			net.Broadcast()
		end

		for id, node in pairs(UVRace_Nodes) do
			net.Start("UVRace_NodeLinks")
				net.WriteUInt(id, 16)
				net.WriteTable(node.Links)
			net.Broadcast()
		end

		undo.Create("UVRaceImport")

		-- add entities
		for _, ent in pairs(UVRace_LoadedEntities) do
			undo.AddEntity(ent)
		end

		-- add node cleanup
		undo.AddFunction(function()
			for id in pairs(importedIDs) do
				if UVRace_Nodes[id] then
					tool:RemoveNode(id)
				end
			end
		end)

		undo.SetPlayer(ply)
		undo.Finish()
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
		
		-- Include nodes
		saveArray.Nodes = {}

		for id, node in pairs(UVRace_Nodes) do
			local Links = {}
			for linkedID in pairs(node.Links) do
				Links[linkedID] = true
			end

			table.insert(saveArray.Nodes, {
				ID = id,
				Pos = {x = node.Pos.x, y = node.Pos.y, z = node.Pos.z},
				SpeedLimit = node.SpeedLimit or 0,
				Links = Links
			})
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
		
		-- Export nodes
		for id, node in pairs(UVRace_Nodes) do
			if node then
				local line = "node " .. id .. " "
				line = line .. string.format("%.6f %.6f %.6f %d", node.Pos.x, node.Pos.y, node.Pos.z, node.SpeedLimit)

				-- Export links
				for linkedID in pairs(node.Links) do
					line = line .. " " .. linkedID
				end

				str = str .. line .. "\n"
			end
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
	local ClientNodes = {}
	local HoverNode
	local SelectedNode = nil

	net.Receive("UVRace_NodeAdd", function()
		local id = net.ReadUInt(16)
		local pos = net.ReadVector()
		local speed = net.ReadUInt(16)

		ClientNodes[id] = ClientNodes[id] or {}
		ClientNodes[id].Pos = pos
		ClientNodes[id].SpeedLimit = speed
		ClientNodes[id].Links = ClientNodes[id].Links or {}
	end)

	net.Receive("UVRace_NodeRemove", function()
		local id = net.ReadUInt(16)

		if SelectedNode == id then
			SelectedNode = nil
		end

		if HoverNode == id then
			HoverNode = nil
		end

		ClientNodes[id] = nil
	end)

	net.Receive("UVRace_NodeLinks", function()
		local id = net.ReadUInt(16)
		local links = net.ReadTable()

		if ClientNodes[id] then
			ClientNodes[id].Links = links
		end
	end)

	net.Receive("UVRace_NodeSelect", function()
		SelectedNode = net.ReadUInt(16)
	end)

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

	net.Receive("UVRace_ClearAllNodes", function()
		ClientNodes = {}
		HoverNode = nil
		SelectedNode = nil
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
	
	local function PickNodeFromView(maxdist)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local eye = ply:EyePos()
		local aim = ply:GetAimVector()
		local bestID, bestDist

		for id, node in pairs(ClientNodes) do
			local to = node.Pos - eye
			local proj = to:Dot(aim)

			if proj > 0 and proj < maxdist then
				local closest = eye + aim * proj
				local dist = closest:DistToSqr(node.Pos)

				if dist < (12 * 12) and (not bestDist or dist < bestDist) then
					bestDist = dist
					bestID = id
				end
			end
		end

		return bestID
	end

	local matBeam = Material("cable/redlaser")
	local col_white = Color(255, 255, 255)
	local col_blue = Color(0, 0, 255, 200)
	local col_red = Color(255, 0, 0, 200)

	function TOOL:DrawHUD()
		local ply = self:GetOwner()
		if not IsValid(ply) then return end
		
		HoverNode = PickNodeFromView(4096*2)

		local startpos = ply:EyePos()
		local tr = util.TraceLine({
			start = startpos,
			endpos = startpos + (ply:GetAimVector() * MAX_TRACE_LENGTH),
			filter = ply
		})
		local hp = tr.HitPos

		cam.Start3D()
		render.SetColorMaterial()

		render.SetMaterial(matBeam)

		for fromID, node in pairs(ClientNodes) do
			for toID in pairs(node.Links) do
				local other = ClientNodes[toID]
				if not other then continue end

				local col = col_white
				if fromID == SelectedNode or toID == SelectedNode then
					col = col_red
				elseif fromID == HoverNode or toID == HoverNode then
					col = col_blue
				end

				render.DrawBeam( node.Pos, other.Pos, 30, 0, 1, col )
			end
		end

		render.SetColorMaterial()

		for id, node in pairs(ClientNodes) do
			local col = col_white

			if id == HoverNode then
				col = col_blue
			end

			if id == SelectedNode then
				col = col_red
			end

			render.DrawSphere(node.Pos, 8, 12, 12, col)
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
		
		if HoverNode and ClientNodes[HoverNode] then
			local node = ClientNodes[HoverNode]

			local text = "Speed: " .. (node.SpeedLimit or 0)
			draw.SimpleText(
				text,
				"DermaDefaultBold",
				ScrW() / 2,
				ScrH() / 2 + 20,
				color_white,
				TEXT_ALIGN_CENTER
			)
		end
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

	net.Receive("UVRace_NodeSettings", function()
		local id = net.ReadUInt(16)
		local node = ClientNodes[id]

		local frame = vgui.Create("DFrame")
		frame:SetSize(300, 160)
		frame:Center()
		frame:SetTitle("Node Settings")
		frame:MakePopup()

		local speed = vgui.Create("DNumSlider", frame)
		speed:Dock(TOP)
		speed:SetText("Speed Limit")
		speed:SetMin(0)
		speed:SetMax(500)
		speed:SetDecimals(0)
		if node then
			speed:SetValue(node.SpeedLimit or 0)
		end

		local apply = vgui.Create("DButton", frame)
		apply:Dock(BOTTOM)
		apply:SetText("Apply")
		apply.DoClick = function()
			net.Start("UVRace_UpdateNodeSettings")
				net.WriteUInt(id, 16)
				net.WriteUInt(speed:GetValue(), 16)
			net.SendToServer()
			frame:Close()
		end
	end)

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
	self.SelectedNode = nil
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
	SelectedNode = nil
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
		if CLIENT then return true end
		if not ply:IsSuperAdmin() then return false end

		local pos = trace.HitPos
		local id = self:GetNearestNode(pos, 12)

		-- Clicked empty space → create node
		if not id then
			local newID = self:AddNode(pos)

			undo.Create("UVRaceNode")
				undo.AddFunction(function()
					if UVRace_Nodes[newID] then
						self:RemoveNode(newID)
					end
				end)
				undo.SetPlayer(ply)
			undo.Finish()

			return true
		end

		-- No selection → select node
		if not self.SelectedNode then
			self.SelectedNode = id
			net.Start("UVRace_NodeSelect")
				net.WriteUInt(id, 16)
			net.Send(ply)
			return true
		end

		-- Same node → delete
		if self.SelectedNode == id then
			self:RemoveNode(id)
			self.SelectedNode = nil

			net.Start("UVRace_NodeSelect")
				net.WriteUInt(0, 16)
			net.Send(ply)

			return true
		end

		-- Different node → toggle link
		self:ToggleLink(self.SelectedNode, id)
		self.SelectedNode = nil

		net.Start("UVRace_NodeSelect")
			net.WriteUInt(0, 16)
		net.Send(ply)

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

function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if not IsValid(ply) then return false end

	-- Checkpoint behavior unchanged
	if self.ToolMode == MODE_CHECKPOINT then
		if CLIENT then return true end
		if not ply:IsSuperAdmin() then return false end

		local ent = trace.Entity
		if IsValid(ent) and ent:GetClass() == "uvrace_checkpoint" then
			net.Start("UVRace_SelectID")
				net.WriteEntity(ent)
			net.Send(ply)
			return true
		end

		return false
	end

	-- Node settings
	if self.ToolMode ~= MODE_NODE then return false end
	if CLIENT then return true end
	if not ply:IsSuperAdmin() then return false end

	local id = self:GetNearestNode(trace.HitPos, 12)
	if not id then return false end

	net.Start("UVRace_NodeSettings")
		net.WriteUInt(id, 16)
	net.Send(ply)

	return true
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