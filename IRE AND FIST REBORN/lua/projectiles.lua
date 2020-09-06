dofile(ModPath .. "infcore.lua")


Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "throwablecount", function(self, params)
	self.projectiles.wpn_prj_four.max_amount = 9
	self.projectiles.wpn_prj_ace.max_amount = 26
	self.projectiles.wpn_prj_hur.max_amount = 6
	self.projectiles.wpn_prj_target.max_amount = 9

	-- Change Sicario smoke grenade cooldown from 60 to 30
	if not IreNFist.mod_compatibility.sso then
		self.projectiles.smoke_screen_grenade.base_cooldown = 30
	end
end)
