local files, _ = file.Find("unitvehicles/*.lua", "LUA")

UV = UV or {}
UV.HUDRegistry = UV.HUDRegistry or {}
UV.SpeedometerRegistry = UV.SpeedometerRegistry or {}

if CLIENT then
	function UV.RegisterHUD(codename, displayname, isBackup)
		if not codename or not displayname then return end

		UV.HUDRegistry[codename] = {
			codename = codename,
			name = displayname,
			backup = isBackup or false
		}
	end
	
	function UV.RegisterSpeedometer(codename, displayname)
		if not codename or not displayname then return end

		UV.SpeedometerRegistry[codename] = {
			codename = codename,
			name = displayname
		}
	end
end

for _, f in ipairs(files) do
    local path = "unitvehicles/" .. f

    if SERVER then
        -- Send every file to the client
        AddCSLuaFile(path)
    end

    -- Include depending on prefix (same behavior as autorun)
    if SERVER and f:StartWith("sv_") then
        include(path)
    elseif CLIENT and f:StartWith("cl_") then
        include(path)
    elseif f:StartWith("sh_") then
        include(path)
    end
end