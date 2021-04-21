dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.homeruncontest then
	return
end

-- Home run!
-- Sadly won't work if the cop flies out of bounds and gets deleted
Hooks:PostHook(CopActionHurt, "_freeze_ragdoll", "inf_freezeragdoll_homeruncontest", function(self)
	if not self._unit or not self._unit.base or not self._unit:base() or not self._unit:base().homeruncontest_deathpos then
		return
	end

	local player_unit = managers.player and managers.player:player_unit()
	if not player_unit then
		return
	end

	local playerpos = player_unit:position()
	if not playerpos then
		return
	end

	if not managers.chat then
		return
	end

	local dist = math.floor(mvector3.distance(playerpos, self._unit:base().homeruncontest_deathpos) / 100)

	if dist > 5 then
		managers.chat:feed_system_message(1, "[InF] Cop distance flown: " .. tostring(dist) .. " meters!")
		if dist > 1000 then
			managers.chat:feed_system_message(1, "[InF] Homerun!")
			-- TODO: play challenge complete sound
		end
	end
end)
