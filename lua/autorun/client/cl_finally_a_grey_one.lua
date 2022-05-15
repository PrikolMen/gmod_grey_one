local addon_name = "finaly_a_gray_one"

language.Add( addon_name, "Finally! A Grey One!" )

net.Receive(addon_name, function()
    local DrawColorModify = DrawColorModify
    local CurTime = CurTime

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
end)