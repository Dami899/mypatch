print("Import disabled")

UVContent = {}

local WS_CONTENT_ROOT = "data_static/uv_import/"
local LOCAL_CONTENT_ROOT = "unitvehicles/"

local REPLICATION_BATCH_SIZE = 50
local REPLICATION_DELAY = 0.1
local REPLICATED_FILES = {
    ['glide>>units'] = true,
    ['glide>>traffic'] = true,
    ['glide>>racers'] = true,
    ['lvs>>units'] = true,
    ['lvs>>traffic'] = true,
    ['lvs>>racers'] = true,
    ['prop_vehicle_jeep>>units'] = true,
    ['prop_vehicle_jeep>>traffic'] = true,
    ['prop_vehicle_jeep>>racers'] = true,
    ['simfphys>>units'] = true,
    ['simfphys>>traffic'] = true,
    ['simfphys>>racers'] = true,
    ['pursuitbreakers>>' .. game.GetMap()] = true,
    ['roadblocks>>' .. game.GetMap()] = true,
    ['repairshops>>' .. game.GetMap()] = true,
    -- ['races>>' .. game.GetMap()] = true, Race replication is handled by race handler since client doesn't really have a use for the file list ...
}

local ReplicationQueue = {}

local load_queue = {}

local function scanFolder( folder, ptrTable, searchType )
    local files, subfolders = file.Find( folder .. "*", searchType )

    if next( subfolders ) == nil then
        for _, file in ipairs( files ) do
            -- DATA is local file and takes prio over workshop content
            if searchType == "DATA" then
                for i, v in ipairs( ptrTable ) do
                    if v.file == file then
                        table.remove( ptrTable, i )
                        break
                    end
                end
            end

            table.insert( ptrTable, {
                file = file,
                path = folder .. file,
                searchType = searchType
            } )
        end
    else
        for _, subfolder in ipairs( subfolders ) do
            -- print(subfolder)
            if not ptrTable[subfolder] then
                ptrTable[subfolder] = {}
            end
            scanFolder( folder .. subfolder .. "/", ptrTable[subfolder], searchType )
        end
    end

    -- for _, file in ipairs( files ) do
    --     -- local path = folder .. file
    --     -- local data = file.Read( path, "GAME" )

    --     -- if data then
    --     --     table.insert( ptrTable, data )
    --     -- end
    -- end

    -- for _, subfolder in ipairs( subfolders ) do
    --     ptrTable[subfolder] = {}
    --     scanFolder( folder .. subfolder .. "/", ptrTable[subfolder] )
    -- end
end

if SERVER then
    local _, wsContentFolders = file.Find( WS_CONTENT_ROOT .. "*", "GAME" )
    local _, localContentFolders = file.Find( LOCAL_CONTENT_ROOT .. "*", "DATA" )

    MsgC(Color(0,255,0), "\n[Unit Vehicles] Mounting workshop content...\n")

    for _, folder in ipairs( wsContentFolders ) do
        scanFolder( WS_CONTENT_ROOT .. folder .. "/uvdata/", UVContent, "GAME" )
        MsgC(Color(0,255,0), "\tMounted workshop content: " .. folder .. "\n")
    end

    MsgC(Color(0,255,0), "\n[Unit Vehicles] Mounting local content...\n")

    scanFolder( LOCAL_CONTENT_ROOT, UVContent, "DATA" )

    -- We must let hook listeners register first
    timer.Simple( 0, function()
        hook.Run( "UVContentEvent", "Initialize" )
    end )
    
    -- for _, folder in ipairs( localContentFolders ) do
    --     scanFolder( LOCAL_CONTENT_ROOT .. folder .. "/", UVContent, "DATA" )
        --MsgC(Color(0,255,0), "\tMounted local content: " .. folder .. "\n")
    --end
    -- hook.Add("Think", "UV_ContentReplication", function()
    --     local task = next( ReplicationQueue )
    --     if not task then return end

    --     if task.operation == 1 then
            
    --     end
    -- end)
    -- timer.Simple( 2, function() 
    --     for _, ply in player.Iterator() do
    --         UV_SendContent( ply, 'glide>>units' )
    --         UV_SendContent( ply, 'glide>>traffic' )
    --         UV_SendContent( ply, 'glide>>racers' )
    
    --         UV_SendContent( ply, 'lvs>>units' )
    --         UV_SendContent( ply, 'lvs>>traffic' )
    --         UV_SendContent( ply, 'lvs>>racers' )
    
    --         UV_SendContent( ply, 'prop_vehicle_jeep>>units' )
    --         UV_SendContent( ply, 'prop_vehicle_jeep>>traffic' )
    --         UV_SendContent( ply, 'prop_vehicle_jeep>>racers' )
    
    --         UV_SendContent( ply, 'simfphys>>units' )
    --         UV_SendContent( ply, 'simfphys>>traffic' )
    --         UV_SendContent( ply, 'simfphys>>racers' )
    
    --         --UV_SendContent( ply, 'races>>' .. game.GetMap() )
    --     end
    
    -- end )
    -- PrintTable(table.GetKeys(UVContent))
elseif CLIENT then
    -- timer.Simple( 5, function()
    --     PrintTable(UVContent)
    -- end )
    net.Receive( "UVContent_Add", function( len, ply )
        local bytes = net.ReadUInt( 16 )
        local data = net.ReadData( bytes )
    
        local uncompData = util.Decompress( data )
        local dataTable = util.JSONToTable( uncompData )    

        local i = 0

        for _, v in pairs( dataTable[2] ) do
            i = i + 1
            UV_AddFile( dataTable[1], v )
        end

        if i > 1 then
            hook.Run( "UVContentEvent", "BatchAdd", dataTable[1], dataTable[2] )
        else
            hook.Run( "UVContentEvent", "Add", dataTable[1], dataTable[2][1] )
        end
    end )

    net.Receive( "UVContent_Remove", function( len, ply )
        local path = net.ReadString()
        local filename = net.ReadString()

        UV_RemoveFile( path, filename )
        hook.Run( "UVContentEvent", "Remove", path, filename )
    end )
end

local function getStack( path )
    local stack = UVContent
    local hay = string.Explode( ">>", path )
    local needle = hay[#hay]

    for i, v in ipairs( hay ) do
        if stack[v] == nil then stack[v] = {} end
        stack = stack[v]
    end

    return stack
end

local function getFile( path, fileName )
    local stack = getStack( path )

    for i, v in ipairs( stack ) do
        if v.file == fileName then return v end
    end
end

local function network_RemoveContent( path, fileName, _ply )
    net.Start( "UVContent_Remove" )
    net.WriteString( path )
    net.WriteString( fileName )
    if _ply then
        net.Send( _ply )
    else
        net.Broadcast()
    end
end

local function network_AddContent( contentTable, _ply )
    local compData = util.Compress( util.TableToJSON(contentTable) )
    local dataSize = #compData

    net.Start( "UVContent_Add" )
    net.WriteUInt( dataSize, 16 )
    net.WriteData( compData, dataSize )

    if _ply then
        net.Send( _ply )
    else
        net.Broadcast()
    end
end

local function sendContentInBatch(ply, data, path)
    local sent = 0

    local function SendBatch(sent)
        if sent > #data then return end

        local startNeedle = sent
        local endNeedle = math.min( startNeedle + REPLICATION_BATCH_SIZE, #data )

        local batch = {
            [1] = path,
            [2] = {},
        }

        for i = startNeedle, endNeedle do
            batch[2][i] = data[i]
        end

        network_AddContent( batch, ply )
        timer.Simple( REPLICATION_DELAY, function() SendBatch(endNeedle + 1) end )
    end

    SendBatch(1)
end

function UV_SendContent( ply, path )
    sendContentInBatch( ply, UV_GetFiles( path ), path )
end

function UV_GetFiles( path )
    local files = {}
    local stack = getStack( path )

    for i, v in ipairs( stack ) do
        table.insert( files, v.file )
    end

    return files
end

function UV_GetFile( path, fileName )
    return getFile( path, fileName )
end

-- Useless on client at the moment since the server doesn't send path info to clients
-- Although I was thinking of sending some "isWorkshop" boolean flag to client, should we need to use something like this on client
function UV_IsWorkshop( path, filename )
    local file = getFile( path, filename )
    if not file then return end

    return string.sub( file.path, 1, #WS_CONTENT_ROOT ) == WS_CONTENT_ROOT
end

function UV_LoadFile( path, fileName )
    local fileEntry = getFile( path, fileName )
    if not fileEntry then return end

    return file.Read( fileEntry.path, fileEntry.searchType )
end

function UV_AddFile( path, fileName, directory, searchType )
    local stack = type( path ) == "string" and getStack( path ) or path
    if CLIENT then
        --print("Adding file to client", path, fileName, directory, searchType)
    end

    table.insert( stack, {
        file = fileName,
        path = directory and directory .. fileName or fileName,
        searchType = searchType
    } )

    hook.Run( "UVContentEvent", "Add", path, fileName )

    if SERVER and REPLICATED_FILES[path] then
        network_AddContent( {
            [1] = path,
            [2] = { fileName } 
        }, nil )
    end
end

function UV_RemoveFile( path, fileName )
    local stack = type( path ) == "string" and getStack( path ) or path

    local fileInfo = getFile( path, fileName )
    if not fileInfo then return end

    for i, v in ipairs( stack ) do
        if v.file == fileName then
            table.remove( stack, i )
            break
        end
    end

    -- We check if it's a file within the local data folder
    -- If it is we of course want to remove it there also
    -- Make sure to check if it's the SERVER too; we don't want connected clients to lose their files
    if SERVER and not UV_IsWorkshop( path, fileName ) then
        file.Delete( fileInfo.path, fileInfo.searchType )
    end

    hook.Run( "UVContentEvent", "Remove", path, fileName )

    if SERVER and REPLICATED_FILES[path] then
        network_RemoveContent( path, fileName, nil )
    end
end

-- The rule I am following right now is to only send mandatory files,
-- Rest can probably be sent on demand in separate functions across the codebase.
hook.Add( "player_activate", "UV_PlayerContentReplicator", function( data )
    local id = data.userid
    local ply = Player(id)
    
    for path, _ in pairs( REPLICATED_FILES ) do
        print('Replicating', path, 'for', ply:Nick())
        UV_SendContent( ply, path )
    end

    UV_SendRaceList( ply )
    UV_SendPresets( ply )
end )

-- hook.Add( "PlayerInitialSpawn", "UV/Load", function( ply )
-- 	load_queue[ ply ] = true
-- end )

-- Rule that I am following right now is to just 
-- hook.Add( "StartCommand", "UV/Load", function( ply, cmd )
-- 	if load_queue[ ply ] and not cmd:IsForced() then
-- 		load_queue[ ply ] = nil

--         UV_SendContent( ply, 'glide>>units' )
--         UV_SendContent( ply, 'glide>>traffic' )
--         UV_SendContent( ply, 'glide>>racers' )

--         UV_SendContent( ply, 'lvs>>units' )
--         UV_SendContent( ply, 'lvs>>traffic' )
--         UV_SendContent( ply, 'lvs>>racers' )

--         UV_SendContent( ply, 'prop_vehicle_jeep>>units' )
--         UV_SendContent( ply, 'prop_vehicle_jeep>>traffic' )
--         UV_SendContent( ply, 'prop_vehicle_jeep>>racers' )

--         UV_SendContent( ply, 'simfphys>>units' )
--         UV_SendContent( ply, 'simfphys>>traffic' )
--         UV_SendContent( ply, 'simfphys>>racers' )

--         UV_SendRaceList( ply )

--         -- UV_SendContent( ply, 'races>>' .. game.GetMap() )
-- 	end
-- end )
-- --[[
--     1 = Add
--     2 = Remove
--     3 = Replication of tbl
-- ]]

-- function UV_Replicate( path, data, operation, _players )
--     local queueInfo = {
--         timestamp = os.time(),
--         lastProcessed = 0,
--         i = 1,
--         path = path,
--         operation = operation,
--         data = data,
--         receiver = _players
--     }
    
--     local task = table.Copy( queueInfo )
--     ReplicationQueue[_players] = ReplicationQueue[_players] or {}

--     table.insert( ReplicationQueue[_players], task )
-- end

-- local IMPORT_ROOT = "data_static/uv_import/"

-- local function EnsureDir(path)
--     if not file.IsDir(path, "DATA") then
--         file.CreateDir(path)
--     end
-- end

-- local function Normalize(str)
--     if not str then return "" end

--     str = string.Replace(str, "\r\n", "\n")
--     str = string.Trim(str)

--     return str
-- end

-- local function FilesDiffer(src, dst)
--     local srcData = file.Read(src, "GAME")
--     if not srcData then return false end

--     local dstData = file.Read(dst, "DATA")
--     if not dstData then return true end

--     return srcData ~= dstData
-- end

-- local function ScanImportData(folder, allowNew, allowReplace)
--     local result = {
--         new = {},
--         replace = {}
--     }

--     local base = IMPORT_ROOT .. folder .. "/uvdata/"
--     local _, datafolders = file.Find(base .. "*", "GAME")

--     for _, dataFld in ipairs(datafolders or {}) do
--         local files, subfolders = file.Find(base .. dataFld .. "/*", "GAME")

--         -- Top-level files
--         for _, filename in ipairs(files or {}) do
--             local src = base .. dataFld .. "/" .. filename
--             local dst = "unitvehicles/" .. dataFld .. "/" .. filename

-- 			if file.Exists(dst, "DATA") then
-- 				if allowReplace and FilesDiffer(src, dst) then
-- 					table.insert(result.replace, {src = src, dst = dst})
-- 				end
-- 			else
-- 				if allowNew then
-- 					table.insert(result.new, {src = src, dst = dst})
-- 				end
-- 			end
--         end

--         -- Subfolder files
--         for _, sub in ipairs(subfolders or {}) do
--             local files2 = file.Find(base .. dataFld .. "/" .. sub .. "/*", "GAME")

--             for _, filename in ipairs(files2 or {}) do
--                 local src = base .. dataFld .. "/" .. sub .. "/" .. filename
--                 local dst = "unitvehicles/" .. dataFld .. "/" .. sub .. "/" .. filename

-- 				if file.Exists(dst, "DATA") then
-- 					if allowReplace and FilesDiffer(src, dst) then
-- 						table.insert(result.replace, {src = src, dst = dst})
-- 					end
-- 				else
-- 					if allowNew then
-- 						table.insert(result.new, {src = src, dst = dst})
-- 					end
-- 				end
--             end
--         end
--     end

--     -- DV WAYPOINTS
--     local dvbase = IMPORT_ROOT .. folder .. "/uvdvwaypoints/"
--     local dvfiles = file.Find(dvbase .. "*", "GAME")

--     for _, filename in ipairs(dvfiles or {}) do
--         local src = dvbase .. filename
--         local dst = "decentvehicle/" .. filename

-- 		if file.Exists(dst, "DATA") then
-- 			if allowReplace and FilesDiffer(src, dst) then
-- 				table.insert(result.replace, {src = src, dst = dst, type = "waypoints"})
-- 			end
-- 		else
-- 			if allowNew then
-- 				table.insert(result.new, {src = src, dst = dst, type = "waypoints"})
-- 			end
-- 		end
--     end

--     return result
-- end

-- local function ImportEntries(entries, isReplace)
--     for _, v in ipairs(entries) do
--         local dir = string.GetPathFromFilename(v.dst)
--         EnsureDir(dir)

--         local data = file.Read(v.src, "GAME")
--         if data then
--             file.Write(v.dst, data)
--         end
--     end
-- end

-- local function ImportNew(entries)
--     ImportEntries(entries, false)
-- end

-- local function ImportReplace(entries)
--     ImportEntries(entries, true)
-- end

-- local function CountEntries(entries)
-- 	local counts = {
-- 		names = false,
-- 		pb = 0,
-- 		race = 0,
-- 		repair = 0,
-- 		rb = 0,
-- 		waypoints = 0,
-- 		navmesh = 0,
-- 		presets = 0,

-- 		vehicles = {
-- 			glide = {racers = 0, traffic = 0, units = 0},
-- 			lvs = {racers = 0, traffic = 0, units = 0},
-- 			prop_vehicle_jeep = {racers = 0, traffic = 0, units = 0},
-- 			simfphys = {racers = 0, traffic = 0, units = 0}
-- 		}
-- 	}

--     for _, v in ipairs(entries) do
--         local path = v.dst:lower()

--         -- NAMES (singular file)
--         if string.find(path, "names") then
--             counts.names = true
--         end

--         if string.find(path, "pursuitbreakers") then counts.pb = counts.pb + 1 end
--         if string.find(path, "races") then counts.race = counts.race + 1 end
--         if string.find(path, "repairshops") then counts.repair = counts.repair + 1 end
--         if string.find(path, "roadblocks") then counts.rb = counts.rb + 1 end
--         if string.find(path, "preset_import") then counts.presets = counts.presets + 1 end

--         -- Waypoints (explicit flag OR fallback)
--         if v.type == "waypoints" then
--             counts.waypoints = counts.waypoints + 1
--         end

--         -- Navmesh (fallback detection)
--         if string.find(path, "navmesh") then
--             counts.navmesh = counts.navmesh + 1
--         end
		
-- 		-- Vehicles
-- 		local base, vtype = string.match(path, "^unitvehicles/([^/]+)/([^/]+)/")

-- 		if base and vtype and counts.vehicles[base] and counts.vehicles[base][vtype] then
-- 			counts.vehicles[base][vtype] = counts.vehicles[base][vtype] + 1
-- 		end
--     end

--     return counts
-- end

-- local function PrintImportSummary(title, entries)
--     local counts = CountEntries(entries)

--     MsgC(Color(0,255,0), "\n[Unit Vehicles] " .. title .. "\n")
	
-- 	if counts.names then MsgC(Color(200,255,200), "Racer Names updated\n") end
--     if counts.pb > 0 then MsgC(Color(200,255,200), "Pursuit Breakers: " .. counts.pb .. "\n") end
--     if counts.race > 0 then MsgC(Color(200,255,200), "Races: " .. counts.race .. "\n") end
--     if counts.repair > 0 then MsgC(Color(200,255,200), "Repair Shops: " .. counts.repair .. "\n") end
--     if counts.rb > 0 then MsgC(Color(200,255,200), "Roadblocks: " .. counts.rb .. "\n") end
--     if counts.waypoints > 0 then MsgC(Color(200,255,200), "Waypoints: " .. counts.waypoints .. "\n") end
--     if counts.navmesh > 0 then MsgC(Color(200,255,200), "Nav Meshes: " .. counts.navmesh .. "\n") end
--     if counts.presets > 0 then MsgC(Color(200,255,200), "Presets: " .. counts.presets .. "\n") end
-- end

-- local function BuildEntryText(counts)
--     local t = {}

-- 	local baseNames = {
-- 		glide = UVString("uv.base.glide"),
-- 		lvs = UVString("uv.base.lvs"),
-- 		prop_vehicle_jeep = UVString("uv.base.hl2"),
-- 		simfphys = UVString("uv.base.simfphys")
-- 	}

--     -- NAMES (no count)
--     if counts.names then
--         table.insert(t, UVString("uv.system.starter.replace.names"))
--     end

--     if counts.pb > 0 then
--         table.insert(t, string.format(UVString("uv.system.starter.replace.pb"), counts.pb))
--     end

--     if counts.race > 0 then
--         table.insert(t, string.format(UVString("uv.system.starter.replace.race"), counts.race))
--     end

--     if counts.repair > 0 then
--         table.insert(t, string.format(UVString("uv.system.starter.replace.repair"), counts.repair))
--     end

--     if counts.rb > 0 then
--         table.insert(t, string.format(UVString("uv.system.starter.replace.rb"), counts.rb))
--     end

--     if counts.waypoints > 0 then
--         table.insert(t, string.format(UVString("uv.system.starter.replace.waypoints"), counts.waypoints))
--     end

--     if counts.navmesh > 0 then
--         table.insert(t, string.format(UVString("uv.system.starter.replace.navmesh"), counts.navmesh))
--     end

--     if counts.presets > 0 then
--         table.insert(t, string.format(UVString("uv.system.starter.replace.presets"), counts.presets))
--     end

-- 	local order = {"glide", "lvs", "prop_vehicle_jeep", "simfphys"}

-- 	for _, base in ipairs(order) do
-- 		local types = counts.vehicles[base]
-- 		local total = types.racers + types.traffic + types.units

-- 		if total > 0 then
-- 			local baseName = baseNames[base] or base
-- 			table.insert(t, string.format( UVString("uv.system.starter.replace.vehicles"), baseName, types.racers, types.traffic, types.units ))
-- 		end
-- 	end

--     if #t == 0 then
--         return UVString("uv.system.starter.unknownerror")
--     end

--     return table.concat(t, "\n")
-- end

-- local function ScanFoldersAsync(folders, enableImport, enableReplace, onDone)
--     local allNew = {}
--     local allReplace = {}

--     local i = 1

-- 	timer.Remove("UV_ImportScan")

--     timer.Create("UV_ImportScan", 0, 0, function()
--         local folder = folders[i]
--         if not folder then
--             timer.Remove("UV_ImportScan")
--             if onDone then onDone(allNew, allReplace) end
--             return
--         end

-- 		local scan = ScanImportData(folder, enableImport, enableReplace)

--         table.Add(allNew, scan.new)
--         table.Add(allReplace, scan.replace)

--         i = i + 1
--     end)
-- end

-- local function BroadcastPendingState()
--     local has = UV_PendingReplace and #UV_PendingReplace > 0

--     net.Start("UV_HasPendingReplace")
--     net.WriteBool(has)
--     net.Broadcast()
-- end

-- function UV_StartImportFlow()
--     if not game.SinglePlayer() then
--         -- print("[UV] Client import disabled in multiplayer.")
--         return
--     end
	
--     local enableImport = GetConVar("uvmenu_enabledataimport"):GetBool()
--     local enableReplace = GetConVar("uvmenu_enabledatareplace"):GetBool()

--     -- If BOTH are disabled → do nothing at all
-- 	if not enableImport and not enableReplace then
-- 		-- print("[UV] Import + Replace disabled. Skipping entirely.")
-- 		return
-- 	end
	
--     local _, folders = file.Find(IMPORT_ROOT .. "*", "GAME")

-- 	ScanFoldersAsync(folders or {}, enableImport, enableReplace, function(allNew, allReplace)

-- 		if not enableImport then
-- 			allNew = {} -- wipe new data completely
-- 		end

-- 		if not enableReplace then
-- 			allReplace = {} -- wipe replace data completely
-- 		end

--         local function OpenReplaceMenu()
-- 			if not enableReplace then
-- 				PrintImportSummary("Replace disabled (skipped):", allReplace)
-- 				return
-- 			end

--             if #allReplace == 0 then return end

--             local counts = CountEntries(allReplace)
--             local text = BuildEntryText(counts)

--             UVMenu.ImportDataText = text

--             UVMenu.ImportOnSkip = function() end

--             UVMenu.ImportOnConfirm = function()
--                 ImportReplace(allReplace)
--                 PrintImportSummary("Replaced data:", allReplace)
--             end

--             UVMenu.OpenMenu(UVMenu.ImportReplace, true)
--         end

--         if #allNew > 0 and enableImport then
--             local counts = CountEntries(allNew)
--             local text = BuildEntryText(counts)

--             UVMenu.ImportDataText = text

--             UVMenu.ImportOnSkip = function()
--                 OpenReplaceMenu()
--             end

--             UVMenu.ImportOnConfirm = function()
--                 ImportNew(allNew)
--                 PrintImportSummary("Imported NEW data:", allNew)
--                 OpenReplaceMenu()
--             end

--             UVMenu.OpenMenu(UVMenu.ImportAdd, true)
--         else
--             OpenReplaceMenu()
--         end

--     end)
-- end

-- function UV_StartImportFlow_Server()
-- 	local enableReplace = GetConVar("uvmenu_enabledatareplace_server"):GetBool()
-- 	local enableImport = true -- always allow new data on server

--     if not enableImport and not enableReplace then return end

--     local _, folders = file.Find(IMPORT_ROOT .. "*", "GAME")

--     ScanFoldersAsync(folders or {}, enableImport, enableReplace, function(allNew, allReplace)

--         if enableImport and #allNew > 0 then
--             ImportNew(allNew)
--             PrintImportSummary("SERVER: Imported NEW data:", allNew)
--         end

-- 		if enableReplace and #allReplace > 0 then
-- 			UV_PendingReplace = allReplace
-- 			PrintImportSummary("SERVER: Pending replacements:", allReplace)

-- 			BroadcastPendingState()

-- 			for _, ply in ipairs(player.GetAll()) do
-- 				if ply:IsAdmin() then
-- 					ply:ChatPrint("[UV] Altered data detected. Use the menu to review it.")
-- 				end
-- 			end
-- 		else
-- 			UV_PendingReplace = nil
-- 			BroadcastPendingState()
-- 		end
--     end)
-- end

-- if CLIENT and game.SinglePlayer() then
--     hook.Add("InitPostEntity", "UV_RunImportFlow", function()
--         timer.Simple(1, function()
--             UV_StartImportFlow()
--         end)
--     end)
-- end

-- if SERVER then
--     hook.Add("Initialize", "UV_RunImportFlow_Server", function()
--         timer.Simple(1, function()
--             UV_StartImportFlow_Server()
--         end)
--     end)
	
-- 	hook.Add("PlayerInitialSpawn", "UV_NotifyPendingReplace", function(ply)
-- 		if not ply:IsAdmin() then return end

-- 		timer.Simple(1, function()
-- 			if not IsValid(ply) then return end

-- 			local has = UV_PendingReplace and #UV_PendingReplace > 0

-- 			net.Start("UV_HasPendingReplace")
-- 			net.WriteBool(has)
-- 			net.Send(ply)
-- 		end)

-- 		if UV_PendingReplace and #UV_PendingReplace > 0 then
-- 			timer.Simple(2, function()
-- 				if IsValid(ply) then
-- 					ply:ChatPrint("[UV] Altered data is pending replacement.")
-- 				end
-- 			end)
-- 		end
-- 	end)

--     net.Receive("UV_RequestServerReplace", function(len, ply)
--         if not IsValid(ply) or not ply:IsAdmin() then return end

--         if not UV_PendingReplace or #UV_PendingReplace == 0 then
--             ply:ChatPrint("[UV] No pending replacements.")
--             return
--         end

--         -- Send summary UI trigger (optional)
-- 		local counts = CountEntries(UV_PendingReplace)

-- 		net.Start("UV_OpenReplaceMenu")
-- 		net.WriteTable(counts)
-- 		net.Send(ply)
--     end)

-- 	net.Receive("UV_ConfirmServerReplace", function(len, ply)
-- 		if not IsValid(ply) or not ply:IsAdmin() then return end
		
-- 		if not UV_PendingReplace or #UV_PendingReplace == 0 then return end

-- 		ImportReplace(UV_PendingReplace)
-- 		PrintImportSummary("SERVER: Replaced data:", UV_PendingReplace)

-- 		for _, admin in ipairs(player.GetAll()) do
-- 			if admin:IsAdmin() then
-- 				admin:ChatPrint("[UV] Server data has been replaced.")
-- 			end
-- 		end

-- 		UV_PendingReplace = nil
-- 		BroadcastPendingState()
-- 	end)
-- end

-- if CLIENT then
--     UV_HasPendingReplace = false

--     net.Receive("UV_HasPendingReplace", function()
--         UV_HasPendingReplace = net.ReadBool()
--     end)

--     net.Receive("UV_OpenReplaceMenu", function()
-- 		local counts = net.ReadTable()
-- 		local text = BuildEntryText(counts)

--         UVMenu.ImportDataText = text

--         UVMenu.ImportOnConfirm = function()
--             net.Start("UV_ConfirmServerReplace")
--             net.SendToServer()
--         end

--         UVMenu.ImportOnSkip = function() end

--         UVMenu.OpenMenu(UVMenu.ImportReplace, true)
--     end)

-- end