-- Fix ene_fbi_3 using SWAT tweaktable instead of FBI
Hooks:PreHook(CopBase, "init", "inf_copbase_init_fixfbitweaktable_pre", function(self, unit)
	if unit:name() == Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3") then
		self._tweak_table = "fbi"
		self._char_tweak = tweak_data.character.fbi
	end
end)

Hooks:PostHook(CopBase, "init", "inf_copbase_init_fixfbitweaktable_post", function(self, unit)
	if unit:name() == Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3") then
		self._tweak_table = "fbi"
		self._char_tweak = tweak_data.character.fbi
	end
end)


