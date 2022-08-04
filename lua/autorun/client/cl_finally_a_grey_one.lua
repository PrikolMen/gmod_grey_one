local addon_name = "finaly_a_grey_one"
local CurTime = CurTime

language.Add( addon_name, "Finally! A Grey One!" )

do

	net.Receive(addon_name, function()
		if net.ReadBool() then

			local col = net.ReadVector() / 10
			local ply = LocalPlayer()

			local colorModify = {
				["$pp_colour_addr"] = col[1],
				["$pp_colour_addg"] = col[2],
				["$pp_colour_addb"] = col[3],
				["$pp_colour_brightness"] = 0.01,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 0,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0
			}

			local timeout = 0
			local DrawColorModify = DrawColorModify
			hook.Add("RenderScreenspaceEffects", addon_name, function()
				if ply:Alive() then
					DrawColorModify(colorModify)

					local curtime = CurTime()
					if (timeout < curtime) then
						local colour = colorModify["$pp_colour_colour"]
						if (colour > 0.9) then
							hook.Remove("RenderScreenspaceEffects", addon_name)
						else
							colorModify["$pp_colour_colour"] = colour + 0.1
						end

						timeout = curtime + 1
					end
				else
					hook.Remove("RenderScreenspaceEffects", addon_name)
				end
			end)

		else
			chat.AddText( net.ReadEntity(), Color( 230, 230, 230 ), " earned the achievement ", Color( 255, 200, 0 ), language.GetPhrase( "#" .. addon_name ) )
		end
	end)

end

-- Achievement
do

	local surface_DrawTexturedRect = surface.DrawTexturedRect
	local surface_SetDrawColor = surface.SetDrawColor
	local surface_SetMaterial = surface.SetMaterial
	local mesh_AdvanceVertex = mesh.AdvanceVertex
	local render_SetMaterial = render.SetMaterial
	local table_SortByMember = table.SortByMember
	local surface_DrawRect = surface.DrawRect
	local draw_DrawText = draw.DrawText
	local mesh_Position = mesh.Position
	local math_Clamp = math.Clamp
	local mesh_Begin = mesh.Begin
	local mesh_Color = mesh.Color
	local FrameTime = FrameTime
	local mesh_End = mesh.End

	local mat_white = Material( "vgui/white" )
	local function draw_LinearGradient( x, y, w, h, stops, horizontal, alpha )
		if #stops == 0 then
			return
		elseif #stops == 1 then
			surface_SetDrawColor( stops[1].color )
			surface_DrawRect( x, y, w, h )
			return
		end

		table_SortByMember(stops, "offset", true)
		render_SetMaterial(mat_white)

		mesh_Begin(7, #stops - 1)
		for i = 1, #stops - 1 do
			local offset1 = math_Clamp(stops[i].offset, 0, 1)
			local offset2 = math_Clamp(stops[i + 1].offset, 0, 1)
			if offset1 == offset2 then continue end

			local deltaX1, deltaY1, deltaX2, deltaY2

			local color1 = stops[i].color
			local color2 = stops[i + 1].color

			local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
			local r2, g2, b2, a2
			local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
			local r4, g4, b4, a4

			if horizontal then
				r2, g2, b2, a2 = r3, g3, b3, a3
				r4, g4, b4, a4 = r1, g1, b1, a1
				deltaX1 = offset1 * w
				deltaY1 = 0
				deltaX2 = offset2 * w
				deltaY2 = h
			else
				r2, g2, b2, a2 = r1, g1, b1, a1
				r4, g4, b4, a4 = r3, g3, b3, a3
				deltaX1 = 0
				deltaY1 = offset1 * h
				deltaX2 = w
				deltaY2 = offset2 * h
			end

			mesh_Color(r1, g1, b1, a1)
			mesh_Position(Vector(x + deltaX1, y + deltaY1))
			mesh_AdvanceVertex()

			mesh_Color(r2, g2, b2, a2)
			mesh_Position(Vector(x + deltaX2, y + deltaY1))
			mesh_AdvanceVertex()

			mesh_Color(r3, g3, b3, a3)
			mesh_Position(Vector(x + deltaX2, y + deltaY2))
			mesh_AdvanceVertex()

			mesh_Color(r4, g4, b4, a4)
			mesh_Position(Vector(x + deltaX1, y + deltaY2))
			mesh_AdvanceVertex()
		end

		mesh_End()

	end

	local aw, ah = 0, 0
	local fontName = "Grey One Achievement Font"

	local w, h = ScrW(), ScrH()
	local function init()
		w, h = ScrW(), ScrH()

		local sp = math.min( w, h ) / 100
		aw, ah = sp * 22, sp * 8

		surface.CreateFont( fontName, {
			["font"] = "Roboto",
			["size"] = sp * 1.7,
		} )

	end

	hook.Add( "OnScreenSizeChanged", "Grey One Achievement", init )
	init()

	local PANEL = {}
	PANEL.Image = Material( "materials/prikolmen/grey_one.png", "noclamp smooth" )
	PANEL.Sound = Sound( "ui/buttonrollover.wav" )
	PANEL.BaseText = "Achievement Unlocked!"
	PANEL.Title = "#" .. addon_name

	function PANEL:TextChanged()
		surface.SetFont( fontName )
		local x1, y1 = surface.GetTextSize( self.BaseText )
		local x2, y2 = surface.GetTextSize( self.Title )

		self.TextW = math.max( x1, x2 )
		self.TextH = y1
	end

	function PANEL:Init()
		self.Direction = 1
		self.Offset = 0
		self.Speed = 3
		self.Slot = 1
		self.TextW = 32

		self:SetPaintedManually( true )
		self:NoClipping( true )
		self:TextChanged()

		hook.Add("PostRender", self, function( self )
			cam.Start2D()
				self:SetAlpha( self.Offset * 255 )
				self:PaintManual()
			cam.End2D()
		end)
	end

	function PANEL:OnRemove()
		hook.Remove( "PostRender", self )
	end

	function PANEL:Think()
		self.Offset = math_Clamp(self.Offset + (self.Direction * FrameTime() * self.Speed), 0, 1)
		self:InvalidateLayout()

		if (self.Direction == 1) and (self.Offset == 1) then
			self.Direction = 0
			self.Down = CurTime() + 5
		end

		if (self.Down ~= nil) and (CurTime() > self.Down) then
			self.Direction = -1
			self.Down = nil
		end

		if (self.Offset == 0) then
			self:Remove()
		end

		if (self.SoundPlayed == nil) then
			surface.PlaySound( self.Sound )
			self.SoundPlayed = true
		end
	end

	function PANEL:PerformLayout()
		self:SetSize( aw + self.TextW / 2, ah + 1 )
		self:SetPos( w - aw - self.TextW / 2, h - (ah * self.Offset * self.Slot) )
	end

	local col0 = Color(42, 46, 51)
	local col1 = Color(18, 26, 42)
	local col2 = Color(42, 71, 94)

	local preset1 = {
		{offset = 0, color = col1},
		{offset = 1, color = col2},
	}

	local preset2 = {
		{offset = 0, color = col0},
		{offset = 1, color = col1},
	}

	local white = Color( 255, 255, 255 )
	local white2 = Color( 221, 221, 221 )
	local white3 = Color( 198, 206, 218 )

	function PANEL:Paint(w, h)
		local x, y = self:GetPos()

		local w2 = w / 2
		surface_SetDrawColor( col1 )
		surface_DrawRect(0, 0, w2 + 1, h)

		draw_LinearGradient( x + w2, y, w2 + 1, h, preset1 )
		draw_LinearGradient( x + 1, y + 1, w - 2, h - 1, preset2 )

		surface_SetDrawColor( white )
		surface_SetMaterial( self.Image or defaultIcon )
		surface_DrawTexturedRect(14, 15, 64, 64)

		draw_DrawText( self.BaseText, fontName, 87, 23, white2, TEXT_ALIGN_LEFT )
		draw_DrawText( self.Title, fontName, 87, 50, white3, TEXT_ALIGN_LEFT )
	end

	vgui.Register( "grey_one_achievement", PANEL )

end

do
	local panel = NULL
	concommand.Add("grey_one_achievement", function()
		if IsValid( panel ) then
			panel:Remove()
		end

		panel = vgui.Create( "grey_one_achievement" )
	end)
end