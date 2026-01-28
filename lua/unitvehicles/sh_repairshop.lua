AddCSLuaFile()

if CLIENT then
    
    net.Receive("UVHUDRepairCooldown", function() --Inform the player when the repair shop can be used again
        local timeleft = net.ReadInt(32)
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.cooldown"),
			color = Color(255, 0, 0),
			critical = true,
			time = 3,
        })
		
		UV_UI.general.events.CenterNotification({
            text = string.format( UVString("uv.repairshop.cooldown.time"), timeleft ),
			critical = true,
			time = 3,
        })
        surface.PlaySound("ui/pursuit/repairunavailable.wav")
    end)

    net.Receive("UVHUDRepair", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.used"),
			critical = true,
			time = 3,
        })
        surface.PlaySound("ui/pursuit/repair.wav")
    end)

    net.Receive("UVHUDRepairCommander", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.nocommander"),
			color = Color(255, 0, 0),
			critical = true,
			time = 2,
        })
        surface.PlaySound("ui/pursuit/repairunavailable.wav")
    end)

    net.Receive("UVHUDRefilledPT", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.used.pt"),
			critical = true,
			time = 2,
        })
    end)

    net.Receive("UVHUDRepairAvailable", function()
		UV_UI.general.events.CenterNotification({
            text = UVString("uv.repairshop.available"),
			color = Color(50, 255, 50),
			critical = true,
			time = 3,
        })
        surface.PlaySound("ui/pursuit/repairavailable.wav")
    end)

    net.Receive("uvrepairsimfphys", function()
        local veh = net.ReadEntity()
	    if not IsValid( veh ) then return end
	    veh:Backfire( false )
        veh.DamageSnd:Stop()
    end)

end