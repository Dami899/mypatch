TOOL.Category		=	"uv.unitvehicles"
TOOL.Name			=	"#tool.uvnamechanger.name"
TOOL.Command		=	nil
TOOL.ConfigName		=	""

TOOL.ClientConVar["name"] = ""

if CLIENT then

	TOOL.Information = {
		{ name = "left" },
	}

	function TOOL.BuildCPanel(CPanel)
		CPanel:AddControl("Label", { Text = "#tool.uvnamechanger.desc" })

		local NameEntry = vgui.Create( "DTextEntry", CPanel )
		NameEntry:SetPlaceholderText( "#uv.tool.fillme" )
		NameEntry:SetSize(CPanel:GetWide(), 22)
		NameEntry:SetValue(GetConVar("uvnamechanger_name"):GetString())
		NameEntry:SetConVar("uvnamechanger_name")
		CPanel:AddItem(NameEntry)
	end
end

function TOOL:LeftClick( trace )
	if CLIENT then return true end

	local namestring = self:GetClientInfo("name")
	local ply = self:GetOwner()
	local ent = trace.Entity

	if not ply:IsSuperAdmin() then
		notification.AddLegacy( "#uv.superadmin.settings", NOTIFY_ERROR, 5 )
		surface.PlaySound( "buttons/button10.wav" )
		return
	end

	if ent.racer then
		ent.racer = namestring
		return true
	end

	if ent.UnitVehicle and ent.UnitVehicle.callsign then
		ent.UnitVehicle.callsign = namestring
		return true
	end
		
	return false
end
