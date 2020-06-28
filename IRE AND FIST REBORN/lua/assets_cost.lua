Hooks:PostHook( AssetsTweakData , "_init_assets" , "remove_denbts" , function( self , params )
	for i in pairs(self) do
		if self[i].money_lock and (self[i].money_lock ~= 0) then
			self[i].money_lock = 0
		end
	end
end)