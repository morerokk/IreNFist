dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.enablenewcopbehavior then
	return
end

-- Allow cops to reload while moving
Hooks:PreHook(CopActionShoot, "update", "inf_copactionshoot_copscanshootwhilemoving", function(self)
	if not self._ext_anim then
		return
	end

	self._ext_anim.base_no_reload = false
end)
