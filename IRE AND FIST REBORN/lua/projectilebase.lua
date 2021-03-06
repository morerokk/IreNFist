Hooks:PostHook(ProjectileBase, "init", "inf_setup_projectile_armor_damage", function(self)
    -- Any sort of arrow, throwing knife or shuriken should always just nearly ignore the body armor damage reduction, for gameplay and fun reasons
    -- Throwing 6 knives into a tan and still not have him flinch is dumb
    -- On Overkill, this value is just enough to kill them with 1 throwing knife headshot or 2 bodyshots.
    -- Axes one-hit kill.
    self._body_armor_dmg_penalty_mul = 0.25
end)
