-- meltdown, bomb: forest, shadow raid?
-- what the fuck why do my weapons specifically break the damn game when switched to on those maps
function CoreUnitDamage:update_proximity(unit, t, dt, data, range_data)
	local pos = nil

	if data.ref_object then
		pos = data.ref_object:position()
	else
		pos = self._unit:position()
	end

	local unit_list = {}
	local units = self._unit:find_units_quick("all", data.slotmask)

	for _, unit in ipairs(units) do
		-- crash occurs because unit:movement() is nil apparently
		-- but Y THO
		if unit:movement() and (mvector3.distance(pos, unit:movement():m_newest_pos()) < range_data.range) then
			table.insert(unit_list, unit)
		end
	end

	if data.is_within and range_data.is_within ~= data.is_within or not data.is_within and range_data.is_within == data.is_within then
		return #unit_list <= range_data.count
	else
		return range_data.count <= #unit_list
	end
end