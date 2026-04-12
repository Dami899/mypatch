AddCSLuaFile()

local IMPORT_ROOT = "data_static/uv_import/"

local function EnsureDir(path)
    if not file.IsDir(path, "DATA") then
        file.CreateDir(path)
    end
end

local function Normalize(str)
    if not str then return "" end

    str = string.Replace(str, "\r\n", "\n")
    str = string.Trim(str)

    return str
end

local function FilesDiffer(src, dst)
    local srcData = file.Read(src, "GAME")
    if not srcData then return false end

    local dstData = file.Read(dst, "DATA")
    if not dstData then return true end

    return srcData ~= dstData
end

local function ScanImportData(folder)
    local result = {
        new = {},
        replace = {}
    }

    local base = IMPORT_ROOT .. folder .. "/uvdata/"
    local _, datafolders = file.Find(base .. "*", "GAME")

    for _, dataFld in ipairs(datafolders or {}) do
        local files, subfolders = file.Find(base .. dataFld .. "/*", "GAME")

        -- Top-level files
        for _, filename in ipairs(files or {}) do
            local src = base .. dataFld .. "/" .. filename
            local dst = "unitvehicles/" .. dataFld .. "/" .. filename

            if file.Exists(dst, "DATA") then
                if FilesDiffer(src, dst) then
                    table.insert(result.replace, {src = src, dst = dst})
                end
            else
                table.insert(result.new, {src = src, dst = dst})
            end
        end

        -- Subfolder files
        for _, sub in ipairs(subfolders or {}) do
            local files2 = file.Find(base .. dataFld .. "/" .. sub .. "/*", "GAME")

            for _, filename in ipairs(files2 or {}) do
                local src = base .. dataFld .. "/" .. sub .. "/" .. filename
                local dst = "unitvehicles/" .. dataFld .. "/" .. sub .. "/" .. filename

                if file.Exists(dst, "DATA") then
                    if FilesDiffer(src, dst) then
                        table.insert(result.replace, {src = src, dst = dst})
                    end
                else
                    table.insert(result.new, {src = src, dst = dst})
                end
            end
        end
    end

    -- DV WAYPOINTS
    local dvbase = IMPORT_ROOT .. folder .. "/uvdvwaypoints/"
    local dvfiles = file.Find(dvbase .. "*", "GAME")

    for _, filename in ipairs(dvfiles or {}) do
        local src = dvbase .. filename
        local dst = "decentvehicle/" .. filename

        if file.Exists(dst, "DATA") then
            if FilesDiffer(src, dst) then
                table.insert(result.replace, {src = src, dst = dst, type = "waypoints"})
            end
        else
            table.insert(result.new, {src = src, dst = dst, type = "waypoints"})
        end
    end

    return result
end

local function ImportEntries(entries, isReplace)
    for _, v in ipairs(entries) do
        local dir = string.GetPathFromFilename(v.dst)
        EnsureDir(dir)

        local data = file.Read(v.src, "GAME")
        if data then
            file.Write(v.dst, data)
        end
    end
end

local function ImportNew(entries)
    ImportEntries(entries, false)
end

local function ImportReplace(entries)
    ImportEntries(entries, true)
end

local function CountEntries(entries)
    local counts = {
        names = false, -- special case
        pb = 0,
        race = 0,
        repair = 0,
        rb = 0,
        waypoints = 0,
        navmesh = 0,
        presets = 0
    }

    for _, v in ipairs(entries) do
        local path = v.dst:lower()

        -- NAMES (singular file)
        if string.find(path, "names") then
            counts.names = true
        end

        if string.find(path, "pursuitbreakers") then counts.pb = counts.pb + 1 end
        if string.find(path, "races") then counts.race = counts.race + 1 end
        if string.find(path, "repairshops") then counts.repair = counts.repair + 1 end
        if string.find(path, "roadblocks") then counts.rb = counts.rb + 1 end
        if string.find(path, "preset_import") then counts.presets = counts.presets + 1 end

        -- Waypoints (explicit flag OR fallback)
        if v.type == "waypoints" then
            counts.waypoints = counts.waypoints + 1
        end

        -- Navmesh (fallback detection)
        if string.find(path, "navmesh") then
            counts.navmesh = counts.navmesh + 1
        end
    end

    return counts
end

local function PrintImportSummary(title, entries)
    local counts = CountEntries(entries)

    MsgC(Color(0,255,0), "\n[Unit Vehicles] " .. title .. "\n")
	
	if counts.names then MsgC(Color(200,255,200), "Racer Names updated\n") end
    if counts.pb > 0 then MsgC(Color(200,255,200), "Pursuit Breakers: " .. counts.pb .. "\n") end
    if counts.race > 0 then MsgC(Color(200,255,200), "Races: " .. counts.race .. "\n") end
    if counts.repair > 0 then MsgC(Color(200,255,200), "Repair Shops: " .. counts.repair .. "\n") end
    if counts.rb > 0 then MsgC(Color(200,255,200), "Roadblocks: " .. counts.rb .. "\n") end
    if counts.waypoints > 0 then MsgC(Color(200,255,200), "Waypoints: " .. counts.waypoints .. "\n") end
    if counts.navmesh > 0 then MsgC(Color(200,255,200), "Nav Meshes: " .. counts.navmesh .. "\n") end
    if counts.presets > 0 then MsgC(Color(200,255,200), "Presets: " .. counts.presets .. "\n") end
end

local function BuildEntryText(counts)
    local t = {}

    -- NAMES (no count)
    if counts.names then
        table.insert(t, UVString("uv.system.starter.replace.names"))
    end

    if counts.pb > 0 then
        table.insert(t, string.format(UVString("uv.system.starter.replace.pb"), counts.pb))
    end

    if counts.race > 0 then
        table.insert(t, string.format(UVString("uv.system.starter.replace.race"), counts.race))
    end

    if counts.repair > 0 then
        table.insert(t, string.format(UVString("uv.system.starter.replace.repair"), counts.repair))
    end

    if counts.rb > 0 then
        table.insert(t, string.format(UVString("uv.system.starter.replace.rb"), counts.rb))
    end

    if counts.waypoints > 0 then
        table.insert(t, string.format(UVString("uv.system.starter.replace.waypoints"), counts.waypoints))
    end

    if counts.navmesh > 0 then
        table.insert(t, string.format(UVString("uv.system.starter.replace.navmesh"), counts.navmesh))
    end

    if counts.presets > 0 then
        table.insert(t, string.format(UVString("uv.system.starter.replace.presets"), counts.presets))
    end

    if #t == 0 then
        return "No changes detected"
    end

    return table.concat(t, "\n")
end

local function ScanFoldersAsync(folders, onDone)
    local allNew = {}
    local allReplace = {}

    local i = 1

    timer.Create("UV_ImportScan", 0, 0, function()
        local folder = folders[i]
        if not folder then
            timer.Remove("UV_ImportScan")
            if onDone then onDone(allNew, allReplace) end
            return
        end

        local scan = ScanImportData(folder)

        table.Add(allNew, scan.new)
        table.Add(allReplace, scan.replace)

        i = i + 1
    end)
end

function UV_StartImportFlow()
    local _, folders = file.Find(IMPORT_ROOT .. "*", "GAME")

    ScanFoldersAsync(folders or {}, function(allNew, allReplace)

        print("[UV] New:", #allNew, "Replace:", #allReplace)

        local function OpenReplaceMenu()
            if GetConVar("uvmenu_disabledatareplace"):GetBool() then
                PrintImportSummary("Replace disabled (skipped):", allReplace)
                return
            end

            if #allReplace == 0 then return end

            local counts = CountEntries(allReplace)
            local text = BuildEntryText(counts)

            UVMenu.ImportDataText = text

            UVMenu.ImportOnSkip = function() end

            UVMenu.ImportOnConfirm = function()
                ImportReplace(allReplace)
                PrintImportSummary("Replaced data:", allReplace)
            end

            UVMenu.OpenMenu(UVMenu.ImportReplace, true)
        end

        if #allNew > 0 and not GetConVar("uvmenu_disabledataimport"):GetBool() then
            local counts = CountEntries(allNew)
            local text = BuildEntryText(counts)

            UVMenu.ImportDataText = text

            UVMenu.ImportOnSkip = function()
                OpenReplaceMenu()
            end

            UVMenu.ImportOnConfirm = function()
                ImportNew(allNew)
                PrintImportSummary("Imported NEW data:", allNew)
                OpenReplaceMenu()
            end

            UVMenu.OpenMenu(UVMenu.ImportAdd, true)
        else
            OpenReplaceMenu()
        end

    end)
end

if CLIENT then
    hook.Add("InitPostEntity", "UV_RunImportFlow", function()
        timer.Simple(1, function()
            UV_StartImportFlow()
        end)
    end)
end