Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "throwablecount", function(self, params)
	self.projectiles.wpn_prj_four.max_amount = 9
	self.projectiles.wpn_prj_ace.max_amount = 26
	self.projectiles.wpn_prj_hur.max_amount = 6
	self.projectiles.wpn_prj_target.max_amount = 9
end)