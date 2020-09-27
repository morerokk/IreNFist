local movement_yes = function()
    return {
        _team = true
    }
end

local movement_no = function()
    return nil
end

CopDamage = {}
CopDamage._unit = {
    movement = movement_yes,
	get_body_index = function() return "head" end
}

function CopDamage:mock_make_movable()
    self._unit.movement = movement_yes
end

function CopDamage:mock_make_stationary()
    self._unit.movement = movement_no
end

function CopDamage:damage_bullet()

end

function CopDamage:damage_melee()

end


