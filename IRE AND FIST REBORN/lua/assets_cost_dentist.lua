dofile(ModPath .. "infcore.lua")

if InFmenu.settings.changeitemprices then
	Hooks:PostHook( PrePlanningTweakData , "init" , "gib_preplans_plox" , function( self , params )

		for i in pairs(self.types) do
			self.types[i].cost = 0
		end

		self.gui.MAX_DRAW_POINTS = math.huge

	end)
end
