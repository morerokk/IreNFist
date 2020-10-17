dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.beta then
    return
end

-- Create guardian perk deck indicator inside the health meter
Hooks:PostHook(HUDTeammate, "_create_radial_health", "inf_create_holdout_indicator", function(self, radial_health_panel)
    if not self._main_player then
        return
    end

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
