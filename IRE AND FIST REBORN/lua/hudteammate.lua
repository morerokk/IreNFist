dofile(ModPath .. "infcore.lua")

if IreNFist.mod_compatibility.wolfhud or IreNFist.mod_compatibility.pdthhud then
    function HUDTeammate:set_holdout_indicator_enabled(enabled)

    end

    function HUDTeammate:set_bulletstorm_charge_level(level)

    end

    return
end

-- Create guardian perk deck indicator inside the health meter
-- This also creates the bulletstorm indicator
Hooks:PostHook(HUDTeammate, "_create_radial_health", "inf_create_holdout_bs_indicator", function(self, radial_health_panel)
    if not self._main_player then
        return
    end

	local bulletstorm_charge = radial_health_panel:bitmap({
		texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_fg",
		name = "bulletstorm_charge",
		visible = false,
		render_template = "VertexColorTexturedRadial",
		layer = 4,
		color = Color(1023,1023,1023),
		w = radial_health_panel:w() * 0.7,
		h = radial_health_panel:h() * 0.7
	})
	bulletstorm_charge:set_center(radial_health_panel:w() / 2,radial_health_panel:h() / 2)	
	self._bulletstorm_charge = bulletstorm_charge

    local shield_texture, shield_rect = tweak_data.hud_icons:get_icon_data("pd2_defend")

	local holdout_indicator = radial_health_panel:bitmap({
		texture = shield_texture,
		name = "holdout_indicator",
		visible = false,
		layer = 5,
        color = Color(1023,1023,1023),
        texture_rect = shield_rect,
		w = radial_health_panel:w() * 0.5,
		h = radial_health_panel:h() * 0.5
    })

	holdout_indicator:set_center(radial_health_panel:w() / 2, radial_health_panel:h() / 2)	
    self._holdout_indicator = holdout_indicator
end)

function HUDTeammate:set_holdout_indicator_enabled(enabled)
    if not self._main_player or not self._holdout_indicator then
        return
    end

    self._holdout_indicator:set_visible(enabled and true or false)
end

function HUDTeammate:set_bulletstorm_charge_enabled(enabled)
    if not self._main_player or not self._bulletstorm_charge then
        return
    end

    self._bulletstorm_charge:set_visible(enabled and true or false)
end

-- Bulletstorm charge circle go brr
function HUDTeammate:set_bulletstorm_charge_level(data)
    if not self._main_player or not self._bulletstorm_charge or not data or not data.max or not data.current then
        return
    end

    local ratio = data.current > 0 and (data.current / data.max) or 0

    self._bulletstorm_charge:set_color(Color(ratio, data.current, data.max))
end
