dofile(ModPath .. "infcore.lua")

-- Debug: debugging a very iffy crash when people join in
-- Why is this happening? self._team is nil even though I literally set it in the prehook below
function CopMovement:save(save_data)
	local my_save_data = {}

	if self._stance.code ~= 1 then
		my_save_data.stance_code = self._stance.code
	end

	if self._stance.transition then
		if self._stance.transition.end_values[4] ~= 0 then
			my_save_data.stance_wnd = true
		end
	elseif self._stance.values[4] ~= 0 then
		my_save_data.stance_wnd = true
	end

	for _, action in ipairs(self._active_actions) do
		if action and action.save then
			local action_save_data = {}

			action:save(action_save_data)

			if next(action_save_data) then
				my_save_data.actions = my_save_data.actions or {}

				table.insert(my_save_data.actions, action_save_data)
			end
		end
	end

	if self._allow_fire then
		my_save_data.allow_fire = true
	end

    if self._team then
        my_save_data.team_id = self._team.id
    else
        log("[InF] Cop team was nil when saving movement!")
        local new_team_id = tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")
        my_save_data.team_id = new_team_id
        log("Obtained team ID:")
        log(tostring(new_team_id))
    end

	if self._attention then
		if self._attention.pos then
			my_save_data.attention = self._attention
		elseif self._attention.unit:id() == -1 then
			local attention_pos = self._attention.handler and self._attention.handler:get_detection_m_pos() or self._attention.unit:movement() and self._attention.unit:movement():m_com() or self._unit:position()
			my_save_data.attention = {
				pos = attention_pos
			}
		else
			managers.enemy:add_delayed_clbk("clbk_sync_attention" .. tostring(self._unit:key()), callback(self, self, "clbk_sync_attention", self._attention), TimerManager:game():time() + 0.1)
		end
	end

	if self._equipped_gadgets then
		local equipped_items = {}
		my_save_data.equipped_gadgets = equipped_items

		local function _get_item_type_from_unit(item_unit)
			local wanted_item_name = item_unit:name()

			for item_type, item_unit_names in pairs(self._gadgets) do
				for i_item_unit_name, item_unit_name in ipairs(item_unit_names) do
					if item_unit_name == wanted_item_name then
						return item_type
					end
				end
			end
		end

		local function _is_item_droppable(item_unit)
			if not self._droppable_gadgets then
				return
			end

			local wanted_item_key = item_unit:key()

			for _, droppable_unit in ipairs(self._droppable_gadgets) do
				if droppable_unit:key() == wanted_item_key then
					return true
				end
			end
		end

		for align_place, item_list in pairs(self._equipped_gadgets) do
			for i_item, item_unit in ipairs(item_list) do
				if alive(item_unit) then
					table.insert(equipped_items, {
						_get_item_type_from_unit(item_unit),
						align_place,
						_is_item_droppable(item_unit)
					})
				end
			end
		end
	end

	if next(my_save_data) then
		save_data.movement = my_save_data
	end
end

-- Sometimes HRT's spawn without a team set which crashes the game
-- Set a default team for cop units if they dont have a team
Hooks:PreHook(CopMovement, "team", "inf_setcopteamifnoteam", function(self)
    if not self._team then
        self:set_team(managers.groupai:state()._teams[tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
    end
end)

function CopMovement:_override_weapons(primary, secondary)

    if not primary or secondary then
        return
    end

    if primary then
        self._unit:inventory():add_unit_by_name(primary, true)
    end
    if secondary then
        self._unit:inventory():add_unit_by_name(secondary, true)
    end
end
