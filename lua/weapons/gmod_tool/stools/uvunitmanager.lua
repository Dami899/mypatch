TOOL.Category		=	"uv.unitvehicles"
TOOL.Name			=	"#tool.uvunitmanager.name"
TOOL.Command		=	nil
TOOL.ConfigName		=	""

local bountytime = {}
local timetillnextheat = {}
local unitspatrol = {}
local unitssupport = {}
local unitspursuit = {}
local unitsinterceptor = {}
local unitsspecial = {}
local unitscommander = {}
local unitsrhino = {}
local heatlevel = {}
local heatminimumbounty = {}
local maxunits = {}
local unitsavailable = {}
local backuptimer = {}
local cooldowntimer = {}
local roadblocks = {}
local helicopters = {}
local bustspeed = {}

TOOL.ClientConVar['vehiclebase'] = 1

local UIElements = {}

UVUnitManagerTool = UVUnitManagerTool or {}

if SERVER then
	
	net.Receive("UVUnitManagerGetUnitInfo", function( length, ply )
		ply.UVTOOLMemory = net.ReadTable()
		ply:SelectWeapon( "gmod_tool" )
	end)

	if not file.Exists( "unitvehicles/glide/units", "DATA" ) then
		file.CreateDir( "unitvehicles/glide/units" )
		print("Created a Glide data file for the Unit Vehicles!")
	end
	
	if not file.Exists( "unitvehicles/simfphys/units", "DATA" ) then
		file.CreateDir( "unitvehicles/simfphys/units" )
		print("Created a simfphys data file for the Unit Vehicles!")
	end
	
	if not file.Exists( "unitvehicles/prop_vehicle_jeep/units", "DATA" ) then
		file.CreateDir( "unitvehicles/prop_vehicle_jeep/units" )
		print("Created a Default Vehicle Base data file for the Unit Vehicles!")
	end

end

if CLIENT then
	TOOL.Information = {
		{ name = "info"},
		{ name = "left" },
		{ name = "right" },
	}

	local selecteditem	= nil
	local UVTOOLMemory	= {}
	
	net.Receive("UVUnitManagerGetUnitInfo", function( length )
		UVTOOLMemory = net.ReadTable()
	end)
	
	net.Receive("UVUnitManagerAdjustUnit", function()
		local UnitAdjust = vgui.Create("DFrame")
		local OK = vgui.Create("DButton")
		local lang = language.GetPhrase
		
		UnitAdjust:Add(OK)
		UnitAdjust:SetSize(600, 400)
		UnitAdjust:SetBackgroundBlur(true)
		UnitAdjust:Center()
		UnitAdjust:SetTitle("#tool.uvunitmanager.create")
		UnitAdjust:SetDraggable(false)
		UnitAdjust:MakePopup()
		
		local Intro = vgui.Create( "DLabel", UnitAdjust )
		Intro:SetPos( 20, 40 )
		Intro:SetText( string.format( lang("uv.tool.create.base"), UVTOOLMemory.VehicleBase ) )
		Intro:SizeToContents()
		
		local Intro2 = vgui.Create( "DLabel", UnitAdjust )
		Intro2:SetPos( 20, 60 )
		Intro2:SetText( string.format( lang("uv.tool.create.rawname"), UVTOOLMemory.SpawnName ) )
		Intro2:SizeToContents()
		
		local Intro3 = vgui.Create( "DLabel", UnitAdjust )
		Intro3:SetPos( 20, 100 )
		Intro3:SetText( "#uv.tool.create.uniquename" )
		Intro3:SizeToContents()
		
		local UnitNameEntry = vgui.Create( "DTextEntry", UnitAdjust )
		UnitNameEntry:SetPos( 20, 120 )
		UnitNameEntry:SetPlaceholderText( "#tool.uvunitmanager.create.name" )
		UnitNameEntry:SetSize(UnitAdjust:GetWide() / 2, 22)
		
		local Intro5 = vgui.Create( "DLabel", UnitAdjust )
		Intro5:SetPos( 20, 160 )
		Intro5:SetText( "#tool.uvunitmanager.create.optional")
		Intro5:SizeToContents()

		local AssignToHeatLevelEntry, Intro4, UnitClassEntry, HeatLevelEntry = nil, nil, nil, nil

		if LocalPlayer():IsListenServerHost() then
			AssignToHeatLevelEntry = vgui.Create("DCheckBoxLabel", UnitAdjust )
			AssignToHeatLevelEntry:SetPos( 20, 200 )
			AssignToHeatLevelEntry:SetText("#tool.uvunitmanager.create.optional.assignheatlevel")
			AssignToHeatLevelEntry:SetSize(UnitAdjust:GetWide(), 22)

			Intro4 = vgui.Create( "DLabel", UnitAdjust )
			Intro4:SetPos( 20, 240 )
			Intro4:SetText( "#tool.uvunitmanager.create.optional.class" )
			Intro4:SizeToContents()

			UnitClassEntry = vgui.Create( "DComboBox", UnitAdjust )
			UnitClassEntry:SetPos( 20, 260 )
			UnitClassEntry:SetValue( "1: " .. lang("uv.unit.patrol") )
			UnitClassEntry:AddChoice( "1: " .. lang("uv.unit.patrol") )
			UnitClassEntry:AddChoice( "2: " .. lang("uv.unit.support") )
			UnitClassEntry:AddChoice( "3: " .. lang("uv.unit.pursuit") )
			UnitClassEntry:AddChoice( "4: " .. lang("uv.unit.interceptor") )
			UnitClassEntry:AddChoice( "5: " .. lang("uv.unit.special") )
			UnitClassEntry:AddChoice( "6: " .. lang("uv.unit.commander") )
			UnitClassEntry:AddChoice( "7: " .. lang("uv.unit.rhino") )
			UnitClassEntry:SetSize(UnitAdjust:GetWide() / 2, 22)

			HeatLevelEntry = vgui.Create( "DNumSlider", UnitAdjust )
			HeatLevelEntry:SetPos( 20, 300 )
			HeatLevelEntry:SetText("#tool.uvunitmanager.create.optional.heatlevel")
			HeatLevelEntry:SetValue(1)
			HeatLevelEntry:SetMinMax(1, MAX_HEAT_LEVEL)
			HeatLevelEntry:SetDecimals(0)
			HeatLevelEntry:SetSize(UnitAdjust:GetWide() / 2, 22)
		end
		
		OK:SetText("#uv.tool.create")
		OK:SetSize(UnitAdjust:GetWide() * 5 / 16, 22)
		OK:Dock(BOTTOM)
		
		function OK:DoClick()
			
			local Name = UnitNameEntry:GetValue()
			local HeatLevel, AssignToHeatLevel, UnitClass = nil, nil, nil
			if LocalPlayer():IsListenServerHost() then
				HeatLevel = math.floor(HeatLevelEntry:GetValue())
				AssignToHeatLevel = AssignToHeatLevelEntry:GetChecked()
				UnitClass = UnitClassEntry:GetValue()
			end

			if Name ~= "" then
				local charArray = string.Explode( "", string.Trim( Name ) )
				for k, v in pairs(charArray) do
					if v == string.char( 32 ) then
						charArray[k] = string.char( 95 )
					end
				end

				Name = table.concat( charArray )

				if UVTOOLMemory.VehicleBase == "gmod_sent_vehicle_fphysics_base" then
					local DataString = ""
					
					for k,v in pairs(UVTOOLMemory) do
						if k == "SubMaterials" then
							local mats = ""
							local first = true
							for k, v in pairs( v ) do
								if first then
									first = false
									mats = mats..v
								else
									mats = mats..","..v
								end
							end
							DataString = DataString..k.."="..mats.."#"
						else
							DataString = DataString..k.."="..tostring( v ).."#"
						end
					end
					
					local words = string.Explode( "", DataString )
					local shit = {}
					
					for k, v in pairs( words ) do
						shit[k] =  string.char( string.byte( v ) + 20 )
					end
					
					file.Write("unitvehicles/simfphys/units/"..Name..".txt", string.Implode("",shit) )
				elseif UVTOOLMemory.VehicleBase == "base_glide_car" or UVTOOLMemory.VehicleBase == "base_glide_motorcycle" then
					local jsondata = util.TableToJSON(UVTOOLMemory)
					file.Write("unitvehicles/glide/units/"..Name..".json", jsondata )
				elseif UVTOOLMemory.VehicleBase == "prop_vehicle_jeep" then
					local DataString = ""
					
					for k,v in pairs(UVTOOLMemory) do
						if k == "SubMaterials" then
							local mats = ""
							local first = true
							for k, v in pairs( v ) do
								if first then
									first = false
									mats = mats..v
								else
									mats = mats..","..v
								end
							end
							DataString = DataString..k.."="..mats.."#"
						else
							DataString = DataString..k.."="..tostring( v ).."#"
						end
					end
					
					local words = string.Explode( "", DataString )
					local shit = {}
					
					for k, v in pairs( words ) do
						shit[k] =  string.char( string.byte( v ) + 20 )
					end
					
					file.Write("unitvehicles/prop_vehicle_jeep/units/"..Name..".txt", string.Implode("",shit) )
				end

				if IsValid(UVUnitManagerTool.ScrollPanel) and UVUnitManagerTool.RefreshList then
					UVUnitManagerTool.RefreshList()
				end
				UnitAdjust:Close()
				
				local file_ext = (((UVTOOLMemory.VehicleBase == 'base_glide_car' or UVTOOLMemory.VehicleBase == "base_glide_motorcycle") and "json") or "txt")
				
				if AssignToHeatLevel then
					if string.StartsWith(UnitClass, "1") then
						local availableunits = GetConVar("unitvehicle_unit_unitspatrol"..HeatLevel):GetString()
						if availableunits == "" or availableunits == " " then --blank
							RunConsoleCommand("unitvehicle_unit_unitspatrol"..HeatLevel, Name.."."..file_ext)
						else
							RunConsoleCommand("unitvehicle_unit_unitspatrol"..HeatLevel, availableunits.." "..Name.."."..file_ext)
						end
					elseif string.StartsWith(UnitClass, "2") then
						local availableunits = GetConVar("unitvehicle_unit_unitssupport"..HeatLevel):GetString()
						if availableunits == "" or availableunits == " " then --blank
							RunConsoleCommand("unitvehicle_unit_unitssupport"..HeatLevel, Name.."."..file_ext)
						else
							RunConsoleCommand("unitvehicle_unit_unitssupport"..HeatLevel, availableunits.." "..Name.."."..file_ext)
						end
					elseif string.StartsWith(UnitClass, "3") then
						local availableunits = GetConVar("unitvehicle_unit_unitspursuit"..HeatLevel):GetString()
						if availableunits == "" or availableunits == " " then --blank
							RunConsoleCommand("unitvehicle_unit_unitspursuit"..HeatLevel, Name.."."..file_ext)
						else
							RunConsoleCommand("unitvehicle_unit_unitspursuit"..HeatLevel, availableunits.." "..Name.."."..file_ext)
						end
					elseif string.StartsWith(UnitClass, "4") then
						local availableunits = GetConVar("unitvehicle_unit_unitsinterceptor"..HeatLevel):GetString()
						if availableunits == "" or availableunits == " " then --blank
							RunConsoleCommand("unitvehicle_unit_unitsinterceptor"..HeatLevel, Name.."."..file_ext)
						else
							RunConsoleCommand("unitvehicle_unit_unitsinterceptor"..HeatLevel, availableunits.." "..Name.."."..file_ext)
						end
					elseif string.StartsWith(UnitClass, "5") then
						local availableunits = GetConVar("unitvehicle_unit_unitsspecial"..HeatLevel):GetString()
						if availableunits == "" or availableunits == " " then --blank
							RunConsoleCommand("unitvehicle_unit_unitsspecial"..HeatLevel, Name.."."..file_ext)
						else
							RunConsoleCommand("unitvehicle_unit_unitsspecial"..HeatLevel, availableunits.." "..Name.."."..file_ext)
						end
					elseif string.StartsWith(UnitClass, "6") then
						local availableunits = GetConVar("unitvehicle_unit_unitscommander"..HeatLevel):GetString()
						if availableunits == "" or availableunits == " " then --blank
							RunConsoleCommand("unitvehicle_unit_unitscommander"..HeatLevel, Name.."."..file_ext)
						else
							RunConsoleCommand("unitvehicle_unit_unitscommander"..HeatLevel, availableunits.." "..Name.."."..file_ext)
						end
					elseif string.StartsWith(UnitClass, "7") then
						local availableunits = GetConVar("unitvehicle_unit_unitsrhino"..HeatLevel):GetString()
						if availableunits == "" or availableunits == " " then --blank
							RunConsoleCommand("unitvehicle_unit_unitsrhino"..HeatLevel, Name.."."..file_ext)
						else
							RunConsoleCommand("unitvehicle_unit_unitsrhino"..HeatLevel, availableunits.." "..Name.."."..file_ext)
						end
					end
					notification.AddLegacy( string.format( lang("uv.tool.saved.heatlevel"), Name, HeatLevel ), NOTIFY_UNDO, 5 )
					-- Msg( "Saved "..Name.." as a Unit at Heat Level "..HeatLevel.."!\n" )
				else
					notification.AddLegacy( string.format( lang("uv.tool.saved"), Name ), NOTIFY_UNDO, 5 )
					-- Msg( "Saved "..Name.." as a Unit!\n" )
				end
				
				surface.PlaySound( "buttons/button15.wav" )
				
			else
				UnitNameEntry:SetPlaceholderText( "#uv.tool.fillme" )
				surface.PlaySound( "buttons/button10.wav" )
			end
			
		end
	end)
	
	function UVUnitManagerGetSaves( panel )
		local saved_vehicles = file.Find("unitvehicles/simfphys/units/*.txt", "DATA")
		local index = 0
		local highlight = false
		local offset = 22
		
		for k,v in pairs(saved_vehicles) do
			local printname = v
			
			if not selecteditem then
				selecteditem = printname
			end
			
			local Button = vgui.Create( "DButton", panel )
			Button:SetText( printname )
			Button:SetTextColor( Color( 255, 255, 255 ) )
			Button:SetPos( 0,index * offset)
			Button:SetSize( 280, offset )
			Button.highlight = highlight
			Button.printname = printname
			Button.Paint = function( self, w, h )
				
				local c_selected = Color( 128, 185, 128, 255 )
				local c_normal = self.highlight and Color( 108, 111, 114, 200 ) or Color( 77, 80, 82, 200 )
				local c_hovered = Color( 41, 128, 185, 255 )
				local c_ = (selecteditem == self.printname) and c_selected or (self:IsHovered() and c_hovered or c_normal)
				
				draw.RoundedBox( 5, 1, 1, w - 2, h - 1, c_ )
			end
			Button.DoClick = function( self )
				selecteditem = self.printname
				if isstring(selecteditem) then
					
					SetClipboardText(selecteditem)
					
					local DataString = file.Read( "unitvehicles/simfphys/units/"..selecteditem, "DATA" )
					
					local words = string.Explode( "", DataString )
					local shit = {}
					
					for k, v in pairs( words ) do
						shit[k] =  string.char( string.byte( v ) - 20 )
					end
					
					local Data = string.Explode( "#", string.Implode("",shit) )
					
					table.Empty( UVTOOLMemory )
					
					for _,v in pairs(Data) do
						local Var = string.Explode( "=", v )
						local name = Var[1]
						local variable = Var[2]
						
						if name and variable then
							if name == "SubMaterials" then
								UVTOOLMemory[name] = {}
								
								local submats = string.Explode( ",", variable )
								for i = 0, (table.Count( submats ) - 1) do
									UVTOOLMemory[name][i] = submats[i+1]
								end
							else
								UVTOOLMemory[name] = variable
							end
						end
					end
					
					net.Start("UVUnitManagerGetUnitInfo")
					net.WriteTable( UVTOOLMemory )
					net.SendToServer()
				end
			end
			
			index = index + 1
			highlight = not highlight
		end
	end
	
	function UVUnitManagerGetSavesGlide( panel )
		local saved_vehicles = file.Find("unitvehicles/glide/units/*.json", "DATA")
		local index = 0
		local highlight = false
		local offset = 22
		
		for k,v in pairs(saved_vehicles) do
			local printname = v
			
			if not selecteditem then
				selecteditem = printname
			end
			
			local Button = vgui.Create( "DButton", panel )
			Button:SetText( printname )
			Button:SetTextColor( Color( 255, 255, 255 ) )
			Button:SetPos( 0,index * offset)
			Button:SetSize( 280, offset )
			Button.highlight = highlight
			Button.printname = printname
			Button.Paint = function( self, w, h )
				
				local c_selected = Color( 128, 185, 128, 255 )
				local c_normal = self.highlight and Color( 108, 111, 114, 200 ) or Color( 77, 80, 82, 200 )
				local c_hovered = Color( 41, 128, 185, 255 )
				local c_ = (selecteditem == self.printname) and c_selected or (self:IsHovered() and c_hovered or c_normal)
				
				draw.RoundedBox( 5, 1, 1, w - 2, h - 1, c_ )
			end
			Button.DoClick = function( self )
				selecteditem = self.printname
				if isstring(selecteditem) then
					
					SetClipboardText(selecteditem)
					
					local JSONData = file.Read( "unitvehicles/glide/units/"..selecteditem, "DATA" )
					if not JSONData then return end
					
					UVTOOLMemory = util.JSONToTable(JSONData, true)
					
					net.Start("UVUnitManagerGetUnitInfo")
					net.WriteTable( UVTOOLMemory )
					net.SendToServer()
				end
			end
			
			index = index + 1
			highlight = not highlight
		end
	end
	
	function UVUnitManagerGetSavesJeep( panel )
		local saved_vehicles = file.Find("unitvehicles/prop_vehicle_jeep/units/*.txt", "DATA")
		local index = 0
		local highlight = false
		local offset = 22
		
		for k,v in pairs(saved_vehicles) do
			local printname = v
			
			if not selecteditem then
				selecteditem = printname
			end
			
			local Button = vgui.Create( "DButton", panel )
			Button:SetText( printname )
			Button:SetTextColor( Color( 255, 255, 255 ) )
			Button:SetPos( 0,index * offset)
			Button:SetSize( 280, offset )
			Button.highlight = highlight
			Button.printname = printname
			Button.Paint = function( self, w, h )
				
				local c_selected = Color( 128, 185, 128, 255 )
				local c_normal = self.highlight and Color( 108, 111, 114, 200 ) or Color( 77, 80, 82, 200 )
				local c_hovered = Color( 41, 128, 185, 255 )
				local c_ = (selecteditem == self.printname) and c_selected or (self:IsHovered() and c_hovered or c_normal)
				
				draw.RoundedBox( 5, 1, 1, w - 2, h - 1, c_ )
			end
			Button.DoClick = function( self )
				selecteditem = self.printname
				if isstring(selecteditem) then
					
					SetClipboardText(selecteditem)
					
					local DataString = file.Read( "unitvehicles/prop_vehicle_jeep/units/"..selecteditem, "DATA" )
					
					local words = string.Explode( "", DataString )
					local shit = {}
					
					for k, v in pairs( words ) do
						shit[k] =  string.char( string.byte( v ) - 20 )
					end
					
					local Data = string.Explode( "#", string.Implode("",shit) )
					
					table.Empty( UVTOOLMemory )
					
					for _,v in pairs(Data) do
						local Var = string.Explode( "=", v )
						local name = Var[1]
						local variable = Var[2]
						
						if name and variable then
							if name == "SubMaterials" then
								UVTOOLMemory[name] = {}
								
								local submats = string.Explode( ",", variable )
								for i = 0, (table.Count( submats ) - 1) do
									UVTOOLMemory[name][i] = submats[i+1]
								end
							else
								UVTOOLMemory[name] = variable
							end
						end
					end
					
					net.Start("UVUnitManagerGetUnitInfo")
					net.WriteTable( UVTOOLMemory )
					net.SendToServer()
				end
			end
			
			index = index + 1
			highlight = not highlight
		end
	end

	function UVUnitManagerLoadPreset(name, data)
		--print(#data)
		local warned = false
		local count = 0
		local count1 = 0

		-- Backwards compatibility, a little hacky but it works
		for _, newCV in pairs(conVarList) do
			local cont

			if string.match(newCV, "_chance") and not data[newCV] then 
				_setConVar( newCV, 100 )
				cont = true
			end

			if string.match(newCV, "_chance") and not data[newCV] then 
				_setConVar( newCV, 100 )
				cont = true
			end

			if cont then
				cont = nil
				continue
			end

			if not data[newCV] and GetConVar(newCV) and not PROTECTED_CONVARS[newCV] then _setConVar( newCV, DEFAULTS[newCV] or "" ) end--RunConsoleCommand(newCV, DEFAULTS[newCV] or "") end
		end

		for incomingCV, incomingValue in pairs(data) do
			count1 = count1 + 1
			--local cvNoNumber = string.sub( incomingCV, 1, string.len(incomingCV) - 1 )

			local cvNoNumber = nil
			local number = nil

			local _incomingCV = incomingCV

			while string.match( _incomingCV:sub(-1), "%d" ) and _incomingCV ~= "" do
				number = _incomingCV:sub( -1 )
				cvNoNumber = _incomingCV:sub( 1, -2 )
				_incomingCV = cvNoNumber
			end

			local numberIterator = 0

			if LEGACY_CONVARS[_incomingCV] then
				if not warned then
					warned = true
					local warning = string.format( language.GetPhrase "tool.uvunitmanager.presets.legacy.warning", name )
					notification.AddLegacy( warning, NOTIFY_UNDO, 5 )
				end

				if LEGACY_CONVARS[_incomingCV].HasNumber then
					_setConVar( LEGACY_CONVARS[_incomingCV].Replacement .. number, incomingValue  )
				else
					_setConVar( LEGACY_CONVARS[_incomingCV].Replacement, incomingValue )
				end
			elseif not PROTECTED_CONVARS[incomingCV] then
				_setConVar( incomingCV, incomingValue )
			end
		end
	end
	
	function TOOL.BuildCPanel(CPanel)
		local lang = language.GetPhrase

		local vehicleBases = {
			{ id = 1, name = "HL2",      path = "unitvehicles/prop_vehicle_jeep/units/", type = "txt"  },
			{ id = 2, name = "Simfphys", path = "unitvehicles/simfphys/units/",           type = "txt"  },
			{ id = 3, name = "Glide",    path = "unitvehicles/glide/units/",               type = "json" }
		}

		local activeFilterBaseId = 0
		local selecteditem = nil

		CPanel:AddControl("Label", { Text = "#tool.uvunitmanager.settings.desc" })

		local FilterBar = vgui.Create("DPanel")
		FilterBar:Dock(TOP)
		FilterBar:SetTall(24)
		FilterBar:DockMargin(0, 0, 0, 0)
		FilterBar.Paint = nil

		FilterBar.OnSizeChanged = function(self, w, h)
			local btnWidth = w / 4 -- Nr. of filters

			for _, child in ipairs(self:GetChildren()) do
				if IsValid(child) then
					child:SetWide(btnWidth)
				end
			end
		end

		CPanel:AddItem(FilterBar)

		local function AddFilterButton(text, baseId)
			local btn = vgui.Create("DButton", FilterBar)
			btn:Dock(LEFT)
			btn:DockMargin(0, 0, 0, 0)
			btn:SetWide(80)
			btn:SetText(" ")

			btn.Paint = function(self, w, h)
				local selected = (activeFilterBaseId == baseId)
				local hovered = self:IsHovered()

				local default = Color(
					GetConVar("uvmenu_col_button_r"):GetInt(),
					GetConVar("uvmenu_col_button_g"):GetInt(),
					GetConVar("uvmenu_col_button_b"):GetInt(),
					GetConVar("uvmenu_col_button_a"):GetInt()
				)

				local active = Color(
					GetConVar("uvmenu_col_bool_active_r"):GetInt(),
					GetConVar("uvmenu_col_bool_active_g"):GetInt(),
					GetConVar("uvmenu_col_bool_active_b"):GetInt(),
					GetConVar("uvmenu_col_button_a"):GetInt()
				)

				local hover = Color(
					GetConVar("uvmenu_col_button_hover_r"):GetInt(),
					GetConVar("uvmenu_col_button_hover_g"):GetInt(),
					GetConVar("uvmenu_col_button_hover_b"):GetInt(),
					GetConVar("uvmenu_col_button_hover_a"):GetInt() * math.abs(math.sin(RealTime() * 4))
				)

				local col = selected and active or default
				draw.RoundedBox(12, w * 0.0125, 0, w * 0.9875, h, col)
				if hovered then
					draw.RoundedBox(12, w * 0.0125, 0, w * 0.9875, h, hover)
				end

				draw.SimpleText( text, "UVSettingsFontSmall", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			btn.DoClick = function()
				activeFilterBaseId = baseId
				UVUnitManagerTool.RefreshList()
			end
		end

		local FrameListPanel = vgui.Create("DPanel")
		FrameListPanel:SetSize(280, 220)
		FrameListPanel.Paint = function(self, w, h)
			draw.RoundedBox(5, 0, 0, w, h, Color(115,115,115))
			draw.RoundedBox(5, 1, 1, w-2, h-2, Color(0,0,0))
		end
		CPanel:AddItem(FrameListPanel)

		local ScrollPanel = vgui.Create("DScrollPanel", FrameListPanel)
		ScrollPanel:Dock(FILL)
		ScrollPanel:DockMargin(4, 4, 4, 4)

		UVUnitManagerTool.ScrollPanel = ScrollPanel

		AddFilterButton("#all", 0)
		AddFilterButton("HL2", 1)
		AddFilterButton("Simfphys", 2)
		AddFilterButton("Glide", 3)

		local function getAvailableUnits()
			local entries = {}

			for _, base in ipairs(vehicleBases) do
				local files = file.Find(base.path .. "*." .. base.type, "DATA") or {}
				for _, filename in ipairs(files) do
					entries[#entries + 1] = {
						filename = filename,
						base     = base,
						baseId   = base.id,
						display  = "[ " .. base.name .. " ] " .. filename
					}
				end
			end

			return entries
		end

		function UVUnitManagerTool.RefreshList()
			ScrollPanel:Clear()

			local entries = getAvailableUnits()
			if #entries == 0 then
				local empty = vgui.Create("DLabel", ScrollPanel)
				empty:SetText("#uv.tool.novehicle")
				empty:SetTextColor(Color(200,200,200))
				empty:SetContentAlignment(5)
				empty:Dock(TOP)
				empty:SetTall(24)
				return
			end

			for _, entry in ipairs(entries) do
				if activeFilterBaseId ~= 0 and entry.baseId ~= activeFilterBaseId then
					continue
				end

				if not selecteditem then
					selecteditem = entry.filename
				end

				local btn = ScrollPanel:Add("DButton")
				btn:Dock(TOP)
				btn:DockMargin(0, 0, 0, 4)
				btn:SetTall(24)
				btn:SetText("")
				btn.printname = entry.filename

				btn.Paint = function(self, w, h)
					local hovered = self:IsHovered()

					local default = Color(
						GetConVar("uvmenu_col_button_r"):GetInt(),
						GetConVar("uvmenu_col_button_g"):GetInt(),
						GetConVar("uvmenu_col_button_b"):GetInt(),
						GetConVar("uvmenu_col_button_a"):GetInt()
					)

					local active = Color(
						GetConVar("uvmenu_col_bool_active_r"):GetInt(),
						GetConVar("uvmenu_col_bool_active_g"):GetInt(),
						GetConVar("uvmenu_col_bool_active_b"):GetInt(),
						GetConVar("uvmenu_col_button_a"):GetInt()
					)

					local hover = Color(
						GetConVar("uvmenu_col_button_hover_r"):GetInt(),
						GetConVar("uvmenu_col_button_hover_g"):GetInt(),
						GetConVar("uvmenu_col_button_hover_b"):GetInt(),
						GetConVar("uvmenu_col_button_hover_a"):GetInt()
							* math.abs(math.sin(RealTime() * 4))
					)

					local col = (selecteditem == self.printname) and active or default
					draw.RoundedBox(12, w * 0.0125, 0, w * 0.9875, h, col)
					if hovered then
						draw.RoundedBox(12, w * 0.0125, 0, w * 0.9875, h, hover)
					end

					draw.SimpleText( entry.display, "UVSettingsFontSmall", w * 0.05, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				end

				btn.DoClick = function()
					selecteditem = entry.filename
					SetClipboardText(selecteditem)

					if entry.base.type == "json" then
						UVTOOLMemory = util.JSONToTable(
							file.Read(entry.base.path .. selecteditem, "DATA"), true
						)
					else
						local DataString = file.Read(entry.base.path .. selecteditem, "DATA")
						local words, decoded = string.Explode("", DataString), {}

						for k, v in pairs(words) do
							decoded[k] = string.char(string.byte(v) - 20)
						end

						local Data = string.Explode("#", string.Implode("", decoded))
						table.Empty(UVTOOLMemory)

						for _, v in pairs(Data) do
							local Var = string.Explode("=", v)
							local name, variable = Var[1], Var[2]

							if name and variable then
								if name == "SubMaterials" then
									UVTOOLMemory[name] = {}
									local submats = string.Explode(",", variable)
									for i = 0, table.Count(submats) - 1 do
										UVTOOLMemory[name][i] = submats[i + 1]
									end
								else
									UVTOOLMemory[name] = variable
								end
							end
						end
					end

					net.Start("UVUnitManagerGetUnitInfo")
					net.WriteTable(UVTOOLMemory)
					net.SendToServer()
				end
			end
		end

		timer.Simple(0, function()
			if IsValid(ScrollPanel) then
				UVUnitManagerTool.RefreshList()
			end
		end)

		local RefreshBtn = vgui.Create("DButton")
		RefreshBtn:SetText("#refresh")
		RefreshBtn:SetSize(280, 20)
		RefreshBtn.DoClick = function()
			UVUnitManagerTool.RefreshList()
			surface.PlaySound("buttons/button15.wav")
		end
		CPanel:AddItem(RefreshBtn)

		local DeleteBtn = vgui.Create("DButton")
		DeleteBtn:SetText("#spawnmenu.menu.delete")
		DeleteBtn:SetSize(280, 20)
		DeleteBtn.DoClick = function()
			if not isstring(selecteditem) then return end

			for _, base in ipairs(vehicleBases) do
				if activeFilterBaseId == 0 or base.id == activeFilterBaseId then
					if file.Exists(base.path .. selecteditem, "DATA") then
						file.Delete(base.path .. selecteditem)
						notification.AddLegacy(
							string.format(language.GetPhrase("uv.tool.deleted"), selecteditem),
							NOTIFY_UNDO, 5
						)
						surface.PlaySound("buttons/button15.wav")
						break
					end
				end
			end

			selecteditem = nil
			UVUnitManagerTool.RefreshList()
		end
		CPanel:AddItem(DeleteBtn)

		CPanel:AddControl("Label", { Text = "" }) -- General Settings
		CPanel:AddControl("Label", { Text = "#uv.tweakinmenu" })
		local OpenMenu = vgui.Create("DButton")
		OpenMenu:SetText("#uv.tweakinmenu.open")
		OpenMenu:SetSize(280, 20)
		OpenMenu.DoClick = function()
			UVMenu.OpenMenu(UVMenu.HeatManager)
			UVMenu.PlaySFX("menuopen")
		end
		CPanel:AddItem(OpenMenu)
	end
end

function TOOL:RightClick(trace)
	if CLIENT then return true end
	
	local ent = trace.Entity
	local ply = self:GetOwner()
	
	if not istable(ply.UVTOOLMemory) then 
		ply.UVTOOLMemory = {}
	end
	
	if ent.IsSimfphyscar or ent.IsGlideVehicle or ent:GetClass() == "prop_vehicle_jeep" then
		if not IsValid(ent) then 
			table.Empty( ply.UVTOOLMemory )
			
			net.Start("UVUnitManagerGetUnitInfo")
			net.WriteTable( ply.UVTOOLMemory )
			net.Send( ply )
			
			return false
		end
		
		self:GetVehicleData( ent, ply )
		
	end
	
	net.Start("UVUnitManagerAdjustUnit")
	net.Send(ply)
	
	return true
end

local function ValidateModel( model )
	local v_list = list.Get( "simfphys_vehicles" )
	for listname, _ in pairs( v_list ) do
		if v_list[listname].Members.CustomWheels then
			local FrontWheel = v_list[listname].Members.CustomWheelModel
			local RearWheel = v_list[listname].Members.CustomWheelModel_R
			
			if FrontWheel then 
				FrontWheel = string.lower( FrontWheel )
			end
			
			if RearWheel then 
				RearWheel = string.lower( RearWheel )
			end
			
			if model == FrontWheel or model == RearWheel then
				return true
			end
		end
	end
	
	local list = list.Get( "simfphys_Wheels" )[model]
	
	if list then 
		return true
	end
	
	return false
end

local function GetRight( ent, index, WheelPos )
	local Steer = ent:GetTransformedDirection()
	
	local Right = ent.Right
	
	if WheelPos.IsFrontWheel then
		Right = (IsValid( ent.SteerMaster ) and Steer.Right or ent.Right) * (WheelPos.IsRightWheel and 1 or -1)
	else
		Right = (IsValid( ent.SteerMaster ) and Steer.Right2 or ent.Right) * (WheelPos.IsRightWheel and 1 or -1)
	end
	
	return Right
end

local function SetWheelOffset( ent, offset_front, offset_rear )
	if not IsValid( ent ) then return end
	
	ent.WheelTool_Foffset = offset_front
	ent.WheelTool_Roffset = offset_rear
	
	if not istable( ent.Wheels ) or not istable( ent.GhostWheels ) then return end
	
	for i = 1, table.Count( ent.GhostWheels ) do
		local Wheel = ent.Wheels[ i ]
		local WheelModel = ent.GhostWheels[i]
		local WheelPos = ent:LogicWheelPos( i )
		
		if IsValid( Wheel ) and IsValid( WheelModel ) then
			local Pos = Wheel:GetPos()
			local Right = GetRight( ent, i, WheelPos )
			local offset = WheelPos.IsFrontWheel and offset_front or offset_rear
			
			WheelModel:SetParent( nil )
			
			local physObj = WheelModel:GetPhysicsObject()
			if IsValid( physObj ) then
				physObj:EnableMotion( false )
			end
			
			WheelModel:SetPos( Pos + Right * offset )
			WheelModel:SetParent( Wheel )
		end
	end
end

local function ApplyWheel(ent, data)
	ent.CustomWheelAngleOffset = data[2]
	ent.CustomWheelAngleOffset_R = data[4]
	
	timer.Simple( 0.05, function()
		if not IsValid( ent ) then return end
		for i = 1, table.Count( ent.GhostWheels ) do
			local Wheel = ent.GhostWheels[i]
			
			if IsValid( Wheel ) then
				local isfrontwheel = (i == 1 or i == 2)
				local swap_y = (i == 2 or i == 4 or i == 6)
				
				local angleoffset = isfrontwheel and ent.CustomWheelAngleOffset or ent.CustomWheelAngleOffset_R
				
				local model = isfrontwheel and data[1] or data[3]
				
				local fAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngForward )
				local rAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngRight )
				
				local Forward = fAng:Forward() 
				local Right = swap_y and -rAng:Forward() or rAng:Forward()
				local Up = ent:GetUp()
				
				local Camber = data[5] or 0
				
				local ghostAng = Right:Angle()
				local mirAng = swap_y and 1 or -1
				ghostAng:RotateAroundAxis(Forward,angleoffset.p * mirAng)
				ghostAng:RotateAroundAxis(Right,angleoffset.r * mirAng)
				ghostAng:RotateAroundAxis(Up,-angleoffset.y)
				
				ghostAng:RotateAroundAxis(Forward, Camber * mirAng)
				
				Wheel:SetModelScale( 1 )
				Wheel:SetModel( model )
				Wheel:SetAngles( ghostAng )
				
				timer.Simple( 0.05, function()
					if not IsValid(Wheel) or not IsValid( ent ) then return end
					local wheelsize = Wheel:OBBMaxs() - Wheel:OBBMins()
					local radius = isfrontwheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local size = (radius * 2) / math.max(wheelsize.x,wheelsize.y,wheelsize.z)
					
					Wheel:SetModelScale( size )
				end)
			end
		end
	end)
end

local function GetAngleFromSpawnlist( model )
	if not model then print("invalid model") return Angle(0,0,0) end
	
	model = string.lower( model )
	
	local v_list = list.Get( "simfphys_vehicles" )
	for listname, _ in pairs( v_list ) do
		if v_list[listname].Members.CustomWheels then
			local FrontWheel = v_list[listname].Members.CustomWheelModel
			local RearWheel = v_list[listname].Members.CustomWheelModel_R
			
			if FrontWheel then 
				FrontWheel = string.lower( FrontWheel )
			end
			
			if RearWheel then 
				RearWheel = string.lower( RearWheel )
			end
			
			if model == FrontWheel or model == RearWheel then
				local Angleoffset = v_list[listname].Members.CustomWheelAngleOffset
				if (Angleoffset) then
					return Angleoffset
				end
			end
		end
	end
	
	local list = list.Get( "simfphys_Wheels" )[model]
	local output = list and list.Angle or Angle(0,0,0)
	
	return output
end

function TOOL:LeftClick( trace )
	if CLIENT then return true end
	
	local Ent = trace.Entity
	
	local ply = self:GetOwner()
	
	if not istable(ply.UVTOOLMemory) then
		ply:PrintMessage( HUD_PRINTTALK, "Select a Unit" )
		return 
	end
	
	if ply.UVTOOLMemory.VehicleBase == "base_glide_car" or ply.UVTOOLMemory.VehicleBase == "base_glide_motorcycle" then
		local SpawnCenter = trace.HitPos
		SpawnCenter.z = SpawnCenter.z - ply.UVTOOLMemory.Mins.z
		
		duplicator.SetLocalPos( SpawnCenter+Vector( 0, 0, 50 ) )
		duplicator.SetLocalAng( Angle( 0, ply:EyeAngles().yaw, 0 ) )
		
		local Ents = duplicator.Paste( self:GetOwner(), ply.UVTOOLMemory.Entities, ply.UVTOOLMemory.Constraints )

		local Ent = nil
		if next(Ents) ~= nil then
			for _, v in pairs(Ents) do
				if v.IsGlideVehicle and v.GetIsHonking then
					Ent = v
					break
				end
			end
		end
		
		if not IsValid( Ent ) then 
			PrintMessage( HUD_PRINTTALK, "The vehicle ".. ply.UVTOOLMemory.SpawnName .." dosen't seem to be installed!" )
			return 
		end

		if ply.UVTOOLMemory.SubMaterials then
			if istable( ply.UVTOOLMemory.SubMaterials ) then
				for i = 0, table.Count( ply.UVTOOLMemory.SubMaterials ) do
					Ent:SetSubMaterial( i, ply.UVTOOLMemory.SubMaterials[i] )
				end
			end

			local groups = string.Explode( ",", ply.UVTOOLMemory.BodyGroups)
			for i = 1, table.Count( groups ) do
				Ent:SetBodygroup(i, tonumber(groups[i]) )
			end

			Ent:SetSkin( ply.UVTOOLMemory.Skin )

			local c = string.Explode( ",", ply.UVTOOLMemory.Color )
			local Color =  Color( tonumber(c[1]), tonumber(c[2]), tonumber(c[3]), tonumber(c[4]) )

			local dot = Color.r * Color.g * Color.b * Color.a
			Ent.OldColor = dot
			Ent:SetColor( Color )

			local data = {
				Color = Color,
				RenderMode = 0,
				RenderFX = 0
			}
			duplicator.StoreEntityModifier( Ent, "colour", data )
		end

		for k, v in pairs(Ent.wheels) do
			if v.params then
				v.params.isBulletProof = true
			end
		end
		
		duplicator.SetLocalPos( vector_origin )
		duplicator.SetLocalAng( angle_zero )
		
		undo.Create( "Duplicator" )
		
		for k, ent in pairs( Ents ) do
			undo.AddEntity( ent )
		end
		
		for k, ent in pairs( Ents )	do
			self:GetOwner():AddCleanup( "duplicates", ent )
		end
		
		undo.SetPlayer( self:GetOwner() )
		undo.SetCustomUndoText( "Undone Glide Unit" )
		
		undo.Finish( "Undo (" .. tostring( table.Count( Ents ) ) ..  ")" )

		if cffunctions then
			for k, v in pairs(Ents) do
				if cffunctions then
					v.NitrousPower = ply.UVTOOLMemory.Entities[k].NitrousPower
					v.NitrousDepletionRate = ply.UVTOOLMemory.Entities[k].NitrousDepletionRate
					v.NitrousRegenRate = ply.UVTOOLMemory.Entities[k].NitrousRegenRate
					v.NitrousRegenDelay = ply.UVTOOLMemory.Entities[k].NitrousRegenDelay
					v.NitrousPitchChangeFrequency = ply.UVTOOLMemory.Entities[k].NitrousPitchChangeFrequency
					v.NitrousPitchMultiplier = ply.UVTOOLMemory.Entities[k].NitrousPitchMultiplier
					v.NitrousBurst = ply.UVTOOLMemory.Entities[k].NitrousBurst
					v.NitrousColor = ply.UVTOOLMemory.Entities[k].NitrousColor
					v.NitrousStartSound = ply.UVTOOLMemory.Entities[k].NitrousStartSound
					v.NitrousLoopingSound = ply.UVTOOLMemory.Entities[k].NitrousLoopingSound
					v.NitrousEndSound = ply.UVTOOLMemory.Entities[k].NitrousEndSound
					v.NitrousEmptySound = ply.UVTOOLMemory.Entities[k].NitrousEmptySound
					v.NitrousReadyBurstSound = ply.UVTOOLMemory.Entities[k].NitrousReadyBurstSound
					v.NitrousStartBurstSound = ply.UVTOOLMemory.Entities[k].NitrousStartBurstSound
					v.NitrousStartBurstAnnotationSound = ply.UVTOOLMemory.Entities[k].NitrousStartBurstAnnotationSound
					v.CriticalDamageSound = ply.UVTOOLMemory.Entities[k].CriticalDamageSound
					v.NitrousEnabled = ply.UVTOOLMemory.Entities[k].NitrousEnabled

					v:SetNWBool( 'NitrousEnabled', ply.UVTOOLMemory.Entities[k].NitrousEnabled == nil and true or ply.UVTOOLMemory.Entities[k].NitrousEnabled )

					if ply.UVTOOLMemory.Entities[k].NitrousColor then
						local r = ply.UVTOOLMemory.Entities[k].NitrousColor.r
						local g = ply.UVTOOLMemory.Entities[k].NitrousColor.g
						local b = ply.UVTOOLMemory.Entities[k].NitrousColor.b
					
						net.Start( "cfnitrouscolor" )
							net.WriteEntity(v)
							net.WriteInt(r, 9)
							net.WriteInt(g, 9)
							net.WriteInt(b, 9)
							net.WriteBool(v.NitrousBurst)
							net.WriteBool(v.NitrousEnabled)
						net.Broadcast()
					end
				end
			end
		end
		
		Ent.UnitVehicle = ply
		Ent.callsign = ply:Nick()
		UVAddToPlayerUnitListVehicle(Ent)
		
		return true
		
	elseif ply.UVTOOLMemory.VehicleBase == "prop_vehicle_jeep" then
		local class = ply.UVTOOLMemory.SpawnName
		local vehicles = list.Get("Vehicles")
		local lst = vehicles[class]
		if not lst then
			PrintMessage( HUD_PRINTTALK, "The vehicle '"..class.."' is missing!")
			return
		end
		
		local Ent = ents.Create("prop_vehicle_jeep")
		Ent.VehicleTable = lst
		Ent.VehicleName = ply.UVTOOLMemory.VehicleName
		Ent:SetModel(lst.Model) 
		Ent:SetPos(trace.HitPos)
		
		local SpawnAng = self:GetOwner():EyeAngles()
		SpawnAng.pitch = 0
		SpawnAng.yaw = SpawnAng.yaw + 90
		SpawnAng.roll = 0
		Ent:SetAngles(SpawnAng)
		
		Ent:SetKeyValue("vehiclescript", lst.KeyValues.vehiclescript)
		Ent:SetVehicleClass( class )
		Ent:Spawn()
		Ent:Activate()
		
		local vehicle = Ent
		gamemode.Call( "PlayerSpawnedVehicle", ply, vehicle ) --Some vehicles has different models implanted together, so do that.
		
		if istable( ply.UVTOOLMemory.SubMaterials ) then
			for i = 0, table.Count( ply.UVTOOLMemory.SubMaterials ) do
				Ent:SetSubMaterial( i, ply.UVTOOLMemory.SubMaterials[i] )
			end
		end
		
		timer.Simple(0.5, function()
			if not IsValid(Ent) then return end
			local groups = string.Explode( ",", ply.UVTOOLMemory.BodyGroups)
			for i = 1, table.Count( groups ) do
				Ent:SetBodygroup(i, tonumber(groups[i]) )
			end
			
			Ent:SetSkin( ply.UVTOOLMemory.Skin )
			
			local c = string.Explode( ",", ply.UVTOOLMemory.Color )
			local Color =  Color( tonumber(c[1]), tonumber(c[2]), tonumber(c[3]), tonumber(c[4]) )
			
			local dot = Color.r * Color.g * Color.b * Color.a
			Ent.OldColor = dot
			Ent:SetColor( Color )
			
			local data = {
				Color = Color,
				RenderMode = 0,
				RenderFX = 0
			}
			duplicator.StoreEntityModifier( Ent, "colour", data )
		end)
		
		undo.Create( "Vehicle" )
		undo.SetPlayer( ply )
		undo.AddEntity( Ent )
		undo.SetCustomUndoText( "Undone " .. class )
		undo.Finish( "Vehicle (" .. tostring( class ) .. ")" )
		
		Ent.UnitVehicle = ply
		Ent.callsign = ply:Nick()
		UVAddToPlayerUnitListVehicle(Ent)
		
		return true
		
	end
	
	local vname = ply.UVTOOLMemory.SpawnName
	local Update = false
	local VehicleList = list.Get( "simfphys_vehicles" )
	local vehicle = VehicleList[ vname ]
	
	if not vehicle then return false end
	
	ply.LockRightClick = true
	timer.Simple( 0.6, function() if IsValid( ply ) then ply.LockRightClick = false end end )
	
	local SpawnPos = trace.HitPos + Vector(0,0,25) + (vehicle.SpawnOffset or Vector(0,0,0))
	
	local SpawnAng = self:GetOwner():EyeAngles()
	SpawnAng.pitch = 0
	SpawnAng.yaw = SpawnAng.yaw + 180 + (vehicle.SpawnAngleOffset and vehicle.SpawnAngleOffset or 0)
	SpawnAng.roll = 0
	
	if Ent.IsSimfphyscar then
		if vname ~= Ent:GetSpawn_List() then 
			ply:PrintMessage( HUD_PRINTTALK, vname.." is not compatible with "..Ent:GetSpawn_List() )
			return
		end
		Update = true
	else
		Ent = simfphys.SpawnVehicle( ply, SpawnPos, SpawnAng, vehicle.Model, vehicle.Class, vname, vehicle )
	end
	
	if not IsValid( Ent ) then return end
	
	undo.Create( "Vehicle" )
	undo.SetPlayer( ply )
	undo.AddEntity( Ent )
	undo.SetCustomUndoText( "Undone " .. vehicle.Name )
	undo.Finish( "Vehicle (" .. tostring( vehicle.Name ) .. ")" )
	
	ply:AddCleanup( "vehicles", Ent )
	
	timer.Simple( 0.5, function()
		if not IsValid(Ent) then return end
		
		local tsc = string.Explode( ",", ply.UVTOOLMemory.TireSmokeColor )
		Ent:SetTireSmokeColor( Vector( tonumber(tsc[1]), tonumber(tsc[2]), tonumber(tsc[3]) ) )
		
		Ent.Turbocharged = tobool( ply.UVTOOLMemory.HasTurbo )
		Ent.Supercharged = tobool( ply.UVTOOLMemory.HasBlower )
		
		Ent:SetEngineSoundPreset( math.Clamp( tonumber( ply.UVTOOLMemory.SoundPreset ), -1, 23) )
		Ent:SetMaxTorque( math.Clamp( tonumber( ply.UVTOOLMemory.PeakTorque ), 20, 1000) )
		Ent:SetDifferentialGear( math.Clamp( tonumber( ply.UVTOOLMemory.FinalGear ),0.2, 6 ) )
		
		Ent:SetSteerSpeed( math.Clamp( tonumber( ply.UVTOOLMemory.SteerSpeed ), 1, 16 ) )
		Ent:SetFastSteerAngle( math.Clamp( tonumber( ply.UVTOOLMemory.SteerAngFast ), 0, 1) )
		Ent:SetFastSteerConeFadeSpeed( math.Clamp( tonumber( ply.UVTOOLMemory.SteerFadeSpeed ), 1, 5000 ) )
		
		Ent:SetEfficiency( math.Clamp( tonumber( ply.UVTOOLMemory.Efficiency ) ,0.2,4) )
		Ent:SetMaxTraction( math.Clamp( tonumber( ply.UVTOOLMemory.MaxTraction ) , 5,1000) )
		Ent:SetTractionBias( math.Clamp( tonumber( ply.UVTOOLMemory.GripOffset ),-0.99,0.99) )
		Ent:SetPowerDistribution( math.Clamp( tonumber( ply.UVTOOLMemory.PowerDistribution ) ,-1,1) )
		
		Ent:SetBackFire( tobool( ply.UVTOOLMemory.HasBackfire ) )
		Ent:SetDoNotStall( tobool( ply.UVTOOLMemory.DoesntStall ) )
		
		Ent:SetIdleRPM( math.Clamp( tonumber( ply.UVTOOLMemory.IdleRPM ),1,25000) )
		Ent:SetLimitRPM( math.Clamp( tonumber( ply.UVTOOLMemory.MaxRPM ),4,25000) )
		Ent:SetRevlimiter( tobool( ply.UVTOOLMemory.HasRevLimiter ) )
		Ent:SetPowerBandEnd( math.Clamp( tonumber( ply.UVTOOLMemory.PowerEnd ), 3, 25000) )
		Ent:SetPowerBandStart( math.Clamp( tonumber( ply.UVTOOLMemory.PowerStart ) ,2 ,25000) )
		
		Ent:SetTurboCharged( Ent.Turbocharged )
		Ent:SetSuperCharged( Ent.Supercharged )
		Ent:SetBrakePower( math.Clamp( tonumber( ply.UVTOOLMemory.BrakePower ), 0.1, 500) )
		
		Ent:SetSoundoverride( ply.UVTOOLMemory.SoundOverride or "" )
		
		Ent:SetLights_List( Ent.LightsTable or "no_lights" )
		
		Ent:SetBulletProofTires(true)
		
		Ent.snd_horn = ply.UVTOOLMemory.HornSound
		
		Ent.snd_blowoff = ply.UVTOOLMemory.snd_blowoff
		Ent.snd_spool = ply.UVTOOLMemory.snd_spool
		Ent.snd_bloweron = ply.UVTOOLMemory.snd_bloweron
		Ent.snd_bloweroff = ply.UVTOOLMemory.snd_bloweroff
		
		Ent:SetBackfireSound( ply.UVTOOLMemory.backfiresound or "" )
		
		local Gears = {}
		local Data = string.Explode( ",", ply.UVTOOLMemory.Gears  )
		for i = 1, table.Count( Data ) do 
			local gRatio = tonumber( Data[i] )
			
			if isnumber( gRatio ) then
				if i == 1 then
					Gears[i] = math.Clamp( gRatio, -5, -0.001)
					
				elseif i == 2 then
					Gears[i] = 0
					
				else
					Gears[i] = math.Clamp( gRatio, 0.001, 5)
				end
			end
		end
		Ent.Gears = Gears
		
		if istable( ply.UVTOOLMemory.SubMaterials ) then
			for i = 0, table.Count( ply.UVTOOLMemory.SubMaterials ) do
				Ent:SetSubMaterial( i, ply.UVTOOLMemory.SubMaterials[i] )
			end
		end
		
		if ply.UVTOOLMemory.FrontDampingOverride and ply.UVTOOLMemory.FrontConstantOverride and ply.UVTOOLMemory.RearDampingOverride and ply.UVTOOLMemory.RearConstantOverride then
			Ent.FrontDampingOverride = tonumber( ply.UVTOOLMemory.FrontDampingOverride )
			Ent.FrontConstantOverride = tonumber( ply.UVTOOLMemory.FrontConstantOverride )
			Ent.RearDampingOverride = tonumber( ply.UVTOOLMemory.RearDampingOverride )
			Ent.RearConstantOverride = tonumber( ply.UVTOOLMemory.RearConstantOverride )
			
			local data = {
				[1] = {Ent.FrontConstantOverride,Ent.FrontDampingOverride},
				[2] = {Ent.FrontConstantOverride,Ent.FrontDampingOverride},
				[3] = {Ent.RearConstantOverride,Ent.RearDampingOverride},
				[4] = {Ent.RearConstantOverride,Ent.RearDampingOverride},
				[5] = {Ent.RearConstantOverride,Ent.RearDampingOverride},
				[6] = {Ent.RearConstantOverride,Ent.RearDampingOverride}
			}
			
			local elastics = Ent.Elastics
			if elastics then
				for i = 1, table.Count( elastics ) do
					local elastic = elastics[i]
					if Ent.StrengthenSuspension == true then
						if IsValid( elastic ) then
							elastic:Fire( "SetSpringConstant", data[i][1] * 0.5, 0 )
							elastic:Fire( "SetSpringDamping", data[i][2] * 0.5, 0 )
						end
						local elastic2 = elastics[i * 10]
						if IsValid( elastic2 ) then
							elastic2:Fire( "SetSpringConstant", data[i][1] * 0.5, 0 )
							elastic2:Fire( "SetSpringDamping", data[i][2] * 0.5, 0 )
						end
					else
						if IsValid( elastic ) then
							elastic:Fire( "SetSpringConstant", data[i][1], 0 )
							elastic:Fire( "SetSpringDamping", data[i][2], 0 )
						end
					end
				end
			end
		end
		
		Ent:SetFrontSuspensionHeight( tonumber( ply.UVTOOLMemory.FrontHeight ) )
		Ent:SetRearSuspensionHeight( tonumber( ply.UVTOOLMemory.RearHeight ) )
		
		local groups = string.Explode( ",", ply.UVTOOLMemory.BodyGroups)
		for i = 1, table.Count( groups ) do
			Ent:SetBodygroup(i, tonumber(groups[i]) )
		end
		
		Ent:SetSkin( ply.UVTOOLMemory.Skin )
		
		local c = string.Explode( ",", ply.UVTOOLMemory.Color )
		local Color =  Color( tonumber(c[1]), tonumber(c[2]), tonumber(c[3]), tonumber(c[4]) )
		
		local dot = Color.r * Color.g * Color.b * Color.a
		Ent.OldColor = dot
		Ent:SetColor( Color )
		
		local data = {
			Color = Color,
			RenderMode = 0,
			RenderFX = 0
		}
		duplicator.StoreEntityModifier( Ent, "colour", data )
		
		if Update then
			local PhysObj = Ent:GetPhysicsObject()
			if not IsValid( PhysObj ) then return end
			
			local freezeWhenDone = PhysObj:IsMotionEnabled()
			local freezeWheels = {}
			PhysObj:EnableMotion( false )
			Ent:SetNotSolid( true )
			
			local ResetPos = Ent:GetPos()
			local ResetAng = Ent:GetAngles()
			
			Ent:SetPos( ResetPos + Vector(0,0,30) )
			Ent:SetAngles( Angle(0,ResetAng.y,0) )
			
			for i = 1, table.Count( Ent.Wheels ) do
				local Wheel = Ent.Wheels[ i ]
				if IsValid( Wheel ) then
					local wPObj = Wheel:GetPhysicsObject()
					
					if IsValid( wPObj ) then
						freezeWheels[ i ] = {}
						freezeWheels[ i ].dofreeze = wPObj:IsMotionEnabled()
						freezeWheels[ i ].pos = Wheel:GetPos()
						freezeWheels[ i ].ang = Wheel:GetAngles()
						Wheel:SetNotSolid( true )
						wPObj:EnableMotion( true ) 
						wPObj:Wake() 
					end
				end
			end
			
			timer.Simple( 0.5, function()
				if not IsValid( Ent ) then return end
				if not IsValid( PhysObj ) then return end
				
				PhysObj:EnableMotion( freezeWhenDone )
				Ent:SetNotSolid( false )
				Ent:SetPos( ResetPos )
				Ent:SetAngles( ResetAng )
				
				for i = 1, table.Count( freezeWheels ) do
					local Wheel = Ent.Wheels[ i ]
					if IsValid( Wheel ) then
						local wPObj = Wheel:GetPhysicsObject()
						
						Wheel:SetNotSolid( false )
						
						if IsValid( wPObj ) then
							wPObj:EnableMotion( freezeWheels[i].dofreeze ) 
						end
						
						Wheel:SetPos( freezeWheels[ i ].pos )
						Wheel:SetAngles( freezeWheels[ i ].ang )
					end
				end
			end)
		end
		
		if Ent.CustomWheels then
			if Ent.GhostWheels then
				timer.Simple( Update and 0.25 or 0, function()
					if not IsValid( Ent ) then return end
					if ply.UVTOOLMemory.WheelTool_Foffset and ply.UVTOOLMemory.WheelTool_Roffset then
						SetWheelOffset( Ent, ply.UVTOOLMemory.WheelTool_Foffset, ply.UVTOOLMemory.WheelTool_Roffset )
					end
					
					if not ply.UVTOOLMemory.FrontWheelOverride and not ply.UVTOOLMemory.RearWheelOverride then return end
					
					local front_model = ply.UVTOOLMemory.FrontWheelOverride or vehicle.Members.CustomWheelModel
					local front_angle = GetAngleFromSpawnlist(front_model)
					
					local camber = ply.UVTOOLMemory.Camber or 0
					local rear_model = ply.UVTOOLMemory.RearWheelOverride or (vehicle.Members.CustomWheelModel_R and vehicle.Members.CustomWheelModel_R or front_model)
					local rear_angle = GetAngleFromSpawnlist(rear_model)
					
					if not front_model or not rear_model or not front_angle or not rear_angle then return end
					
					if ValidateModel( front_model ) and ValidateModel( rear_model ) then 
						Ent.Camber = camber
						ApplyWheel(Ent, {front_model,front_angle,rear_model,rear_angle,camber})
					else
						ply:PrintMessage( HUD_PRINTTALK, "selected wheel does not exist on the server")
					end
				end)
			end
		end
		
		Ent.UnitVehicle = ply
		Ent.callsign = ply:Nick()
		UVAddToPlayerUnitListVehicle(Ent)
		
	end)
	
	return true
end

function TOOL:GetVehicleData( ent, ply )
	if not IsValid(ent) then return end
	if not istable(ply.UVTOOLMemory) then ply.UVTOOLMemory = {} end
	
	table.Empty( ply.UVTOOLMemory )
	
	if ent.IsSimfphyscar then
		ply.UVTOOLMemory.VehicleBase = ent:GetClass()
		ply.UVTOOLMemory.SpawnName = ent:GetSpawn_List()
		ply.UVTOOLMemory.SteerSpeed = ent:GetSteerSpeed()
		ply.UVTOOLMemory.SteerFadeSpeed = ent:GetFastSteerConeFadeSpeed()
		ply.UVTOOLMemory.SteerAngFast = ent:GetFastSteerAngle()
		ply.UVTOOLMemory.SoundPreset = ent:GetEngineSoundPreset()
		ply.UVTOOLMemory.IdleRPM = ent:GetIdleRPM()
		ply.UVTOOLMemory.MaxRPM = ent:GetLimitRPM()
		ply.UVTOOLMemory.PowerStart = ent:GetPowerBandStart()
		ply.UVTOOLMemory.PowerEnd = ent:GetPowerBandEnd()
		ply.UVTOOLMemory.PeakTorque = ent:GetMaxTorque()
		ply.UVTOOLMemory.HasTurbo = ent:GetTurboCharged()
		ply.UVTOOLMemory.HasBlower = ent:GetSuperCharged()
		ply.UVTOOLMemory.HasRevLimiter = ent:GetRevlimiter()
		ply.UVTOOLMemory.HasBulletProofTires = ent:GetBulletProofTires()
		ply.UVTOOLMemory.MaxTraction = ent:GetMaxTraction()
		ply.UVTOOLMemory.GripOffset = ent:GetTractionBias()
		ply.UVTOOLMemory.BrakePower = ent:GetBrakePower()
		ply.UVTOOLMemory.PowerDistribution = ent:GetPowerDistribution()
		ply.UVTOOLMemory.Efficiency = ent:GetEfficiency()
		ply.UVTOOLMemory.HornSound = ent.snd_horn
		ply.UVTOOLMemory.HasBackfire = ent:GetBackFire()
		ply.UVTOOLMemory.DoesntStall = ent:GetDoNotStall()
		ply.UVTOOLMemory.SoundOverride = ent:GetSoundoverride()
		
		ply.UVTOOLMemory.FrontHeight = ent:GetFrontSuspensionHeight()
		ply.UVTOOLMemory.RearHeight = ent:GetRearSuspensionHeight()
		
		ply.UVTOOLMemory.Camber = ent.Camber or 0
		
		if ent.FrontDampingOverride and ent.FrontConstantOverride and ent.RearDampingOverride and ent.RearConstantOverride then
			ply.UVTOOLMemory.FrontDampingOverride = ent.FrontDampingOverride
			ply.UVTOOLMemory.FrontConstantOverride = ent.FrontConstantOverride
			ply.UVTOOLMemory.RearDampingOverride = ent.RearDampingOverride
			ply.UVTOOLMemory.RearConstantOverride = ent.RearConstantOverride
		end
		
		if ent.CustomWheels then
			if ent.GhostWheels then
				if IsValid(ent.GhostWheels[1]) then
					ply.UVTOOLMemory.FrontWheelOverride = ent.GhostWheels[1]:GetModel()
				elseif IsValid(ent.GhostWheels[2]) then
					ply.UVTOOLMemory.FrontWheelOverride = ent.GhostWheels[2]:GetModel()
				end
				
				if IsValid(ent.GhostWheels[3]) then
					ply.UVTOOLMemory.RearWheelOverride = ent.GhostWheels[3]:GetModel()
				elseif IsValid(ent.GhostWheels[4]) then
					ply.UVTOOLMemory.RearWheelOverride = ent.GhostWheels[4]:GetModel()
				end
			end
		end
		
		local tsc = ent:GetTireSmokeColor()
		ply.UVTOOLMemory.TireSmokeColor = tsc.r..","..tsc.g..","..tsc.b
		
		local Gears = ""
		for _,v in pairs(ent.Gears) do
			Gears = Gears..v..","
		end
		
		local c = ent:GetColor()
		ply.UVTOOLMemory.Color = c.r..","..c.g..","..c.b..","..c.a
		
		local bodygroups = {}
		for k,v in pairs(ent:GetBodyGroups()) do
			bodygroups[k] = ent:GetBodygroup( k ) 
		end
		
		ply.UVTOOLMemory.BodyGroups = string.Implode( ",", bodygroups)
		
		ply.UVTOOLMemory.Skin = ent:GetSkin()
		
		ply.UVTOOLMemory.Gears = Gears
		ply.UVTOOLMemory.FinalGear = ent:GetDifferentialGear()
		
		if ent.WheelTool_Foffset then
			ply.UVTOOLMemory.WheelTool_Foffset = ent.WheelTool_Foffset
		end
		
		if ent.WheelTool_Roffset then
			ply.UVTOOLMemory.WheelTool_Roffset = ent.WheelTool_Roffset
		end
		
		if ent.snd_blowoff then
			ply.UVTOOLMemory.snd_blowoff = ent.snd_blowoff
		end
		
		if ent.snd_spool then
			ply.UVTOOLMemory.snd_spool = ent.snd_spool
		end
		
		if ent.snd_bloweron then
			ply.UVTOOLMemory.snd_bloweron = ent.snd_bloweron
		end
		
		if ent.snd_bloweroff then
			ply.UVTOOLMemory.snd_bloweroff = ent.snd_bloweroff
		end
		
		ply.UVTOOLMemory.backfiresound = ent:GetBackfireSound()
		
		ply.UVTOOLMemory.SubMaterials = {}
		for i = 0, (table.Count( ent:GetMaterials() ) - 1) do
			ply.UVTOOLMemory.SubMaterials[i] = ent:GetSubMaterial( i )
		end
	elseif ent.IsGlideVehicle then
		local pos = ent:GetPos()
		duplicator.SetLocalPos( pos )
		
		ply.UVTOOLMemory = duplicator.Copy( ent )
		
		duplicator.SetLocalPos( vector_origin )
		duplicator.SetLocalAng( angle_zero )
		
		if ( not ply.UVTOOLMemory ) then return false end
		
		local Key = "VehicleBase"
		ply.UVTOOLMemory[Key] = ent.Base
		local Key2 = "SpawnName"
		ply.UVTOOLMemory[Key2] = ent:GetClass()
		ply.UVTOOLMemory.Mins = Vector(ply.UVTOOLMemory.Mins.x,ply.UVTOOLMemory.Mins.y,0)
		
		ply.UVTOOLMemory.Entities[next(ply.UVTOOLMemory.Entities)].Angle = Angle(0,180,0)

		local c = ent:GetColor()
		ply.UVTOOLMemory.Color = c.r..","..c.g..","..c.b..","..c.a
		
		local bodygroups = {}
		for k,v in pairs(ent:GetBodyGroups()) do
			bodygroups[k] = ent:GetBodygroup( k ) 
		end
		
		ply.UVTOOLMemory.BodyGroups = string.Implode( ",", bodygroups)
		
		ply.UVTOOLMemory.Skin = ent:GetSkin()
		
		ply.UVTOOLMemory.SubMaterials = {}
		for i = 0, (table.Count( ent:GetMaterials() ) - 1) do
			ply.UVTOOLMemory.SubMaterials[i] = ent:GetSubMaterial( i )
		end

		for _, v in pairs(ply.UVTOOLMemory.Entities) do
			if cffunctions then
				v.NitrousPower = ent.NitrousPower or 2
				v.NitrousDepletionRate = ent.NitrousDepletionRate or 0.5
				v.NitrousRegenRate = ent.NitrousRegenRate or 0.1
				v.NitrousRegenDelay = ent.NitrousRegenDelay or 2
				v.NitrousPitchChangeFrequency = ent.NitrousPitchChangeFrequency or 1 
				v.NitrousPitchMultiplier = ent.NitrousPitchMultiplier or 0.2
				v.NitrousBurst = ent.NitrousBurst or false
				v.NitrousColor = ent.NitrousColor or Color(35, 204, 255)
				v.NitrousStartSound = ent.NitrousStartSound or "glide_nitrous/nitrous_burst.wav"
				v.NitrousLoopingSound = ent.NitrousLoopingSound or "glide_nitrous/nitrous_burst.wav"
				v.NitrousEndSound = ent.NitrousEndSound or "glide_nitrous/nitrous_activation_whine.wav"
				v.NitrousEmptySound = ent.NitrousEmptySound or "glide_nitrous/nitrous_empty.wav"
				v.NitrousReadyBurstSound = ent.NitrousReadyBurstSound or "glide_nitrous/nitrous_burst/ready/ready.wav"
				v.NitrousStartBurstSound = ent.NitrousStartBurstSound or file.Find("sound/glide_nitrous/nitrous_burst/*", "GAME")
				v.NitrousStartBurstAnnotationSound = ent.NitrousStartBurstAnnotationSound or file.Find("sound/glide_nitrous/nitrous_burst/annotation/*", "GAME")
				v.CriticalDamageSound = ent.CriticalDamageSound or "glide_healthbar/criticaldamage.wav"
				v.NitrousEnabled = ent:GetNWBool( 'NitrousEnabled' )
			end
		end
		
	elseif ent:GetClass() == "prop_vehicle_jeep" then
		ply.UVTOOLMemory.VehicleBase = ent:GetClass()
		ply.UVTOOLMemory.SpawnName = ent:GetVehicleClass()
		ply.UVTOOLMemory.VehicleName = ent.VehicleName
		
		if not ply.UVTOOLMemory.SpawnName then 
			print("This vehicle dosen't have a vehicle class set" )
			return 
		end
		
		local c = ent:GetColor()
		ply.UVTOOLMemory.Color = c.r..","..c.g..","..c.b..","..c.a
		
		local bodygroups = {}
		for k,v in pairs(ent:GetBodyGroups()) do
			bodygroups[k] = ent:GetBodygroup( k ) 
		end
		
		ply.UVTOOLMemory.BodyGroups = string.Implode( ",", bodygroups)
		
		ply.UVTOOLMemory.Skin = ent:GetSkin()
		
		ply.UVTOOLMemory.SubMaterials = {}
		for i = 0, (table.Count( ent:GetMaterials() ) - 1) do
			ply.UVTOOLMemory.SubMaterials[i] = ent:GetSubMaterial( i )
		end
	end
	
	if not IsValid( ply ) then return end

	if ply.UVTOOLMemory.Entities then
		for _, v in pairs(ply.UVTOOLMemory.Entities) do
			v.OnDieFunctions = nil
			v.AutomaticFrameAdvance = nil
			v.BaseClass = nil
		end
	end

	if ply.UVTOOLMemory.Constraints then
		for _, v in pairs(ply.UVTOOLMemory.Constraints) do
			v.OnDieFunctions = nil
		end
	end
	
	net.Start("UVUnitManagerGetUnitInfo")
	net.WriteTable( ply.UVTOOLMemory )
	net.Send( ply )
	
end