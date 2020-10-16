if CopUtils then
    return
end

CopUtils = {}

-- Quick and easy "private" variables
local this = {}
-- Determines how big the search radius is for getting an eligible cop to arrest the player
-- For reference, the medic's heal radius is 400
this.arrest_search_radius = 900
-- How big the radius for the actual (non-melee) arrest is
this.arrest_action_radius = 100
-- Must be interacting for at least this long to be arrested
this.minimum_interact_time = 0.35

-- Checks if the local player should be arrested
function CopUtils:CheckLocalMeleeDamageArrest(player_unit, attacker_unit, is_melee)
    -- Check if this is our own player unit
    if player_unit ~= managers.player:player_unit() then
        return nil, "not local player unit"
    end

    local state = player_unit:movement():current_state()
    -- Check if we're interacting
    local is_interacting = state._interacting and state:_interacting()
    if not is_interacting then
        return false, "not interacting"
    end

    -- But also check how long they've been interacting. It should be at least 0.35 seconds to avoid instant BS moments.
    if not state._interact_params or not state._interact_params.timer or not state._interact_expire_t then
        return false, "interaction params invalid"
    end

    -- Since I broke my brain making tests for this:
    -- interact_params.timer is the total time it takes to interact with a particular object, such as 5 seconds.
    -- interact_expire_t is the *remaining time* in the interaction, such as 3.8
    -- Therefore, state._interact_params.timer - state._interact_expire_t gives you how long you've been interacting for.
    local current_interact_t = state._interact_params.timer - state._interact_expire_t
    if current_interact_t < this.minimum_interact_time then
        return false, "interaction too short"
    end

    -- Check if the cop isn't too far away to do this
    if not is_melee and attacker_unit and alive(attacker_unit) then
        local dist = mvector3.distance(player_unit:position(), attacker_unit:position())
        if dist > this.arrest_action_radius then
            return false, "too far away for non-melee arrest"
        end
    end

    -- Counterstrike Aced
    if managers.player:has_category_upgrade("player", "counter_arrest") then
        return "countered"
    end

    return "arrested"
end

-- Check if another unmodded player should be arrested
-- Modded players can do this check themselves
-- Since husks are too simplistic, unmodded clients will always be arrested since getting their timer isn't as easy. Such is life
function CopUtils:CheckClientMeleeDamageArrest(player_unit, attacker_unit, is_melee)
    if Network and Network:is_client() then
        return nil, "not host, no husk check"
    end

    if not player_unit or not player_unit.movement or not player_unit:movement() or not player_unit:movement()._interaction_tweak then
        return false, "husk not interacting"
    end

    -- Check if the cop isn't too far away to do this
    if not is_melee and attacker_unit and alive(attacker_unit) then
        local dist = mvector3.distance(player_unit:position(), attacker_unit:position())
        if dist > this.arrest_action_radius then
            return false, "cop too far away from husk"
        end
    end

    return "arrested"
end

function CopUtils:CounterArrestAttacker(player_unit, attacker_unit)
    -- TODO
    return "countered"
end

function CopUtils:SendCopToArrestPlayer(player_unit)
    if Network and Network:is_client() then
        return
    end

    -- Don't do this in stealth
    if managers.groupai:state():whisper_mode() then
        return
    end

    local enemies = World:find_units_quick(player_unit, "sphere", player_unit:position(), this.arrest_search_radius, managers.slot:get_mask("enemies"))
    if not enemies or #enemies <= 0 then
        return
    end

    -- Get the closest enemy that's available for this assignment
    local lowest_distance = 999999
    local closest_enemy = nil
    local highest_found_priority = -100
    local playerpos = player_unit:position()

    local objective = {
        type = "free",
        haste = "run",
        pose = "stand",
        nav_seg = managers.navigation:get_nav_seg_from_pos(player_unit:position(), true),
        pos = mvector3.copy(player_unit:position()),
        --complete_clbk = callback(self, self, '_onCopArrivedAtArrestPosition', {cop = closest_enemy, target = player_unit}),
        forced = true,
        important = true
    }

    -- Find the highest-priority enemy
    -- If tied, select the closest among them
    for i, enemy in pairs(enemies) do
        -- If the guy is not actually an enemy (go figure, thanks Locke), don't
        if self:AreUnitsEnemies(player_unit, enemy) then
            -- Check if their chartweak allows them to arrest players (or if this is currently not an assault)
            local enemy_chartweak = enemy:base():char_tweak()
            local prio = enemy_chartweak.arrest_player_priority or -10

            if enemy_chartweak.arrest_player_priority or not managers.groupai:state():get_assault_mode() then

                -- Only take the highest priority enemies, then the closest
                local dist = mvector3.distance(enemy:position(), playerpos)
                local is_available = enemy:brain():is_available_for_assignment(objective)

                if prio > highest_found_priority and is_available then -- Enemy has higher priority
                    lowest_distance = dist
                    highest_found_priority = prio
                    closest_enemy = enemy
                elseif prio <= highest_found_priority and dist < lowest_distance and is_available then -- Enemy has *same* priority but is closer
                    lowest_distance = dist
                    highest_found_priority = prio
                    closest_enemy = enemy
                end

            end
        end
    end

    -- If an enemy was found, send them to arrest the player
    if closest_enemy then
        objective = {
            type = "free",
            haste = "run",
            pose = "stand",
            nav_seg = managers.navigation:get_nav_seg_from_pos(player_unit:position(), true),
            pos = mvector3.copy(player_unit:position()),
            complete_clbk = callback(self, self, '_onCopArrivedAtArrestPosition', {cop = closest_enemy, target = player_unit}),
            forced = true,
            important = true
        }
        closest_enemy:brain():set_objective(objective)
        closest_enemy:brain():set_logic("travel")
        closest_enemy:movement():action_request({
            type = "idle",
            body_part = 1,
            sync = true
        })
    end
end

-- Callback is executed when the cop arrives at their arrest position
function CopUtils:_onCopArrivedAtArrestPosition(clbk_data)
    if Network and Network:is_client() then
        return
    end

    local cop = clbk_data.cop
    local player_unit = clbk_data.target

    if not cop or not player_unit then
        log("[InF] Cop arrived at arrest position but there was no cop or player set")
        return
    end

    -- Check whether we are evaluating an actual player or a husk
    local result = nil
    if player_unit == managers.player:player_unit() then
        result = self:CheckLocalMeleeDamageArrest(player_unit, cop)
    else
        -- If the client has InF, they can figure it out for themselves
        local peer = managers.network:session():peer_by_unit(player_unit)
        if peer and IreNFist.peersWithMod[peer:id()] then
            return CopUtils:TellClientCheckArrest(peer:id(), cop:id())
        end

        -- Client does not have InF, do a simple check ourselves
        result = self:CheckClientMeleeDamageArrest(player_unit, cop)
    end

    if result == "arrested" then
        -- This works on both the local player and husks thankfully
        player_unit:movement():on_cuffed()
    end
end

-- Tell the client that they should do the arrest check themselves
function CopUtils:TellClientCheckArrest(peer_id, cop_id)
    LuaNetworking:SendToPeer(peer_id, "irenfist_checkarrest", tostring(cop_id))
end

-- Get the requested enemy from just a unit ID
function CopUtils:GetCopFromId(unit_id)
    local enemies = managers.enemy:all_enemies()
    for i, unit_data in pairs(enemies) do
        if unit_data and unit_data.unit and alive(unit_data.unit) and unit_data.unit.id and tostring(unit_data.unit:id()) == unit_id then
            return unit
        end
    end
    return nil
end

-- Find out if unit A is an enemy of unit B
function CopUtils:AreUnitsEnemies(unit_a, unit_b)
    if not unit_a or not unit_b or not unit_a:movement() or not unit_b:movement() then
        return false
    end

    return unit_a:movement():team().foes[unit_b:movement():team().id] and true or false
end

-- Network receive function for arrest check
Hooks:Add('NetworkReceivedData', 'NetworkReceivedData_irenfist_coputils', function(sender, messageType, data)
    -- Only check arrest messages
    if messageType ~= "irenfist_checkarrest" then
        return
    end

    -- Only the host may tell us this
    if sender ~= 1 then
        return
    end

    -- Sanity check, if we are the host then we shouldn't be getting this message anyway
    if not Network or Network:is_server() then
        return
    end

    -- Attempt to get the actual cop unit from their ID
    local unit_id = tonumber(data)
    if not unit_id then
        return
    end

    local cop = CopUtils:GetCopFromId(unit_id)
    if not cop then
        return
    end

    -- Check if this cop should arrest us
    local result = CopUtils:CheckLocalMeleeDamageArrest(managers.player:player_unit(), cop)
    if result == "countered" then
        -- TODO: Arrest the cop instead of just knocking them down
        CopUtils:CounterArrestAttacker(managers.player:player_unit(), cop)
        return
    elseif result == "arrested" then
        managers.player:player_unit():movement():on_cuffed()
        return
    end

    -- Nothing happened
    return
end)
