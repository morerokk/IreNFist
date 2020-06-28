-- grenade pickup can only occur every other ammo pickup
local function on_ammo_pickup(unit, pickup_chance, increase)
	local gained_throwable = false
	local chance = pickup_chance

	if unit == managers.player:player_unit() then
		local nadetype = BlackMarketManager:equipped_grenade()
		local nadetable = {
			["frag"] = {1, 1}, -- frag nade
			["frag_com"] = {1, 1}, -- community frag
			["molotov"] = {1, 1}, -- molotov
			["dynamite"] = {1, 1}, -- dynamite
			["fir_com"] = {1.5, 1}, -- incendiary
			["concussion"] = {2, 1}, -- concussion
			["wpn_prj_jav"] = {2, 1}, -- javelin
			["wpn_prj_four"] = {2, 3}, -- shuriken
			["wpn_prj_target"] = {2, 3}, -- throwing knife
			["wpn_prj_hur"] = {2, 2}, -- throwing axe
			["wpn_prj_ace"] = {4, 4} -- throwing card
		}

		local random = math.random()
		if nadetable[nadetype] and (random < chance * (nadetable[nadetype][1] or 1)) then
			gained_throwable = true
			managers.player:add_grenade_amount(nadetable[nadetype][2] or 1, true)
		elseif random < chance then
			managers.player:add_grenade_amount(1, true)
		else
			chance = chance + increase
		end
	end

	return gained_throwable, chance
end

PlayerAction.FullyLoaded = {}
PlayerAction.FullyLoaded.Priority = 1

PlayerAction.FullyLoaded.Function = function (player_manager, pickup_chance, increase)
	local co = coroutine.running()
	local gained_throwable = false
	local chance = pickup_chance

	-- Lines: 29 to 31
	local function on_ammo_pickup_message(unit)
		gained_throwable, chance = on_ammo_pickup(unit, chance, increase)
	end

	player_manager:register_message(Message.OnAmmoPickup, co, on_ammo_pickup_message)
	player_manager:register_message(Message.OnAmmoPickup, co, on_ammo_pickup)

	while not gained_throwable do
		coroutine.yield(co)
	end

	player_manager:unregister_message(Message.OnAmmoPickup, co)
end

