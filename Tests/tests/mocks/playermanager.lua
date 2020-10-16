if not managers then
    managers = {}
end

managers.player = {}

local is_interacting = false
local playerstate = {
    _interacting = function()
        return is_interacting
    end,

    _interact_params = {}
}

local player = {
    base = function()
        return {}
    end,

    movement = function()
        return {
            current_state = function()
                return playerstate
            end
        }
    end,

    damage = function()
        return {}
    end,

    position = function()
        return {0,1,0}
    end,

    _mockSetInteracting = function(self, interacting, total_time_to_finish, how_long_until_finished_time)
        is_interacting = interacting
        playerstate._interact_params.timer = total_time_to_finish
        playerstate._interact_expire_t = how_long_until_finished_time
    end
}

managers.player.player_unit = function(self)
    return player
end

managers.player._mockUpgrades = {

}

managers.player.has_category_upgrade = function(self, category, upgrade)
    return self._mockUpgrades[category] and self._mockUpgrades[category][upgrade] and true or false
end

managers.player._mockSetUpgrades = function(self, upgrades)
    self._mockUpgrades = upgrades
end
