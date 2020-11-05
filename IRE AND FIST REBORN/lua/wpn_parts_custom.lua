local function checkfolders(subfolder, file)
    local filename = file or "main.xml"
    if SystemFS:exists("mods/" .. subfolder .. "/" .. filename) or SystemFS:exists("assets/mod_overrides/" .. subfolder .. "/" .. filename) then
        return true
    end
    return false
end

-- adds a set of parts to a single part's forbids list
local function add_multiple_to_forbids(forbidref, partlist)
    for a, b in ipairs(partlist) do
        table.insert(forbidref, b)
    end
end

-- Bunch of local variables, TODO refucktor

-- how many seconds to put off delay functions
-- necessary to prevent other weapon hooks from overwriting pixy's clearly superior stats
local delay = 0.50

local dummy = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy"

local shotgun_slug_mult = 0.20/0.50
local silencercustomstats = {falloff_min_dmg_penalty = 10, falloff_begin_mult = 0.75, falloff_end_mult = 0.75}
local shotgunsilencercustomstats = {}
local snpsilencercustomstats = {pen_shield_dmg_mult = 0.80}

-- rifle/pistol suppressors
local silstatsconc0 = {
    value = 1,
    suppression = 12,
    alert_size = 12,
    spread = 5,
    recoil = 0,
    concealment = 0
}
local silstatsconc1 = {
    value = 1,
    suppression = 12,
    alert_size = 12,
    spread = 5,
    recoil = 3,
    concealment = -1
}
local silstatsconc2 = {
    value = 1,
    suppression = 12,
    alert_size = 12,
    spread = 5,
    recoil = 6,
    concealment = -2
}
-- sniper rifle
local silstatssnp = {
    value = 1,
    suppression = 12,
    alert_size = 12,
    recoil = 4,
    concealment = -2
}
-- shotgun
local silstatssho = {
    value = 1,
    suppression = 12,
    alert_size = 12,
    recoil = 4,
    concealment = -2
}

-- barrel presets
local barrel_m1 = {
    value = 1,
    spread = 5,
    recoil = 3,
    reload = -5,
    concealment = -1
}
local barrel_m2 = {
    value = 2,
    spread = 10,
    recoil = 6,
    reload = -10,
    concealment = -2
}
local barrel_p1 = {
    value = 1,
    spread = -5,
    recoil = -2,
    reload = 5,
    concealment = 1
}
local barrel_p2 = {
    value = 2,
    spread = -10,
    recoil = -4,
    reload = 10,
    concealment = 2
}
local barrel_p3 = {
    value = 2,
    spread = -15,
    recoil = -6,
    reload = 15,
    concealment = 3
}
local barrelsho_m1 = {
    value = 1,
    spread = 10,
    recoil = 2,
    reload = -8,
    concealment = -1
}
local barrelsho_m2 = {
    value = 2,
    spread = 20,
    recoil = 4,
    reload = -16,
    concealment = -2
}
local barrelsho_m3 = {
    value = 2,
    spread = 30,
    recoil = 6,
    reload = -24,
    concealment = -2
}
local barrelsho_p1 = {
    value = 1,
    spread = -15,
    recoil = -2,
    reload = 8,
    concealment = 1
}
local barrelsho_p2 = {
    value = 2,
    spread = -20,
    recoil = -4,
    reload = 16,
    concealment = 2
}
local barrelsho_p3 = {
    value = 2,
    spread = -30,
    recoil = -6,
    reload = 24,
    concealment = 3
}
local barrelshoammo_m1 = {
    value = 1,
    spread = 10,
    recoil = 2,
    reload = -8,
    concealment = -1
}
local barrelshoammo_m2 = {
    value = 2,
    spread = 20,
    recoil = 4,
    reload = -16,
    concealment = -2
}
local barrelshoammo_p1 = {
    value = 1,
    spread = -10,
    recoil = -2,
    reload = 12,
    concealment = 1
}
local barrelshoammo_p2 = {
    value = 2,
    spread = -20,
    recoil = -4,
    reload = 24,
    concealment = 2
}
local barrelshoammo_p3 = {
    value = 2,
    spread = -30,
    recoil = -6,
    reload = 36,
    concealment = 3
}
-- stock presets
local stock_snp = {
    value = 1,
    recoil = 10,
    reload = -10,
    concealment = -2
}

-- double barrel presets
local db_barrel = {
    value = 1,
    spread = -30,
    reload = 20,
    concealment = 3
}
local db_stock = {
    value = 1,
    recoil = -10,
    reload = 10,
    concealment = 3
}

-- mag presets
local mag_17 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_17.reload,
    concealment = 5
}
local mag_25 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_25.reload,
    concealment = 5
}
local mag_33 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_33.reload,
    concealment = 4
}
local mag_50 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_50.reload,
    concealment = 3
}
local mag_66 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_66.reload,
    concealment = 2
}
local mag_75 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_75.reload,
    concealment = 2
}
local mag_125 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_125.reload,
    concealment = -1
}
local mag_133 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_133.reload,
    concealment = -2
}
local mag_150 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_150.reload,
    concealment = -2
}
local mag_200 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_200.reload,
    concealment = -2
}
local mag_250 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_250.reload,
    concealment = -2
}
local mag_300 = {
    value = 0,
    reload = InFmenu.wpnvalues.reload.mag_300.reload,
    concealment = -4
}
local mag_alternating = {
    value = 1,
    reload = -20,
    concealment = -1
}

local nostats = {
    value = 0,
    concealment = 0
}

function WeaponFactoryTweakData:_init_inf_custom_weapon_parts(gunlist_snp, customsightaddlist, primarysmgadds, primarysmgadds_specific)
    -- STUFF FOR CUSTOM WEAPON PARTS GOES HERE
    -- This stuff is all wrapped in a pcall if debug is disabled, if anything goes wrong it won't crash your whole game.
    -- NOTE THAT THIS MEANS ERRORS ARE BASICALLY EATEN unless "debug" mode is turned off in the InF options.
    -- When adding your own support, ALWAYS have debug enabled so it crashes early and crashes hard.
    -- Any errors in this file means that custom weapon parts won't have proper stats,
    -- and this might very rarely cause you to lose some custom weapons you have in your inventory (such as an AN-94 with an AK Pack attachment)
    -- You can just rebuy them of course, but still

    -- SR EINHERI PARTS
    if BeardLib.Utils:ModLoaded("SR-3M Vikhr") then
        -- default mag
        self.parts.wpn_fps_ass_sr3m_mag.stats = {}
        -- mounting sights in an aesthetic fashion
        self.parts.wpn_fps_upg_sr3m_cover_rail.stats = {}
        -- 20rnd mag
        self.parts.wpn_fps_upg_sr3m_mag_20rnd.stats = deep_clone(mag_66)
        self.parts.wpn_fps_upg_sr3m_mag_20rnd.stats.extra_ammo = -10
        -- no stock
        self.parts.wpn_fps_upg_sr3m_nostock.stats = {
            value = 0,
            recoil = -3,
            concealment = 1
        }
        -- CAA collapsible stock
        self.parts.wpn_fps_upg_sr3m_stock_caam4.stats = {
            value = 0,
            recoil = 3,
            concealment = -1
        }

        self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_standard = {
            stats = {
                value = 0,
                recoil = 3,
                concealment = -1
            }
        }
        self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_standard = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
        self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_pts = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
        self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_crane = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
        self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_mk46 = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
        self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_ubr = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard

        -- SR-3M suppressor
        self.parts.wpn_fps_upg_sr3m_supp.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_sr3m_supp.stats = deep_clone(silstatsconc2)
        -- groza suppressor
        self.parts.wpn_fps_upg_sr3m_supp_groza.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_sr3m_supp_groza.stats = deep_clone(silstatsconc2)
        -- no VFG
        self.parts.wpn_fps_upg_sr3m_vertgrip_cover.stats = deep_clone(nostats)


    end



    -- CZ-75 SHADOW PARTS
    if BeardLib.Utils:ModLoaded("cz") then
        -- prevents from loading after InF and overwriting my clearly-superior stats
        -- now done via delayed calls
        --Hooks:RemovePostHook("czInit")

        -- Stealth Suppressor
        self.parts.wpn_fps_pis_cz_sil.custom_stats = silencercustomstats
        self.parts.wpn_fps_pis_cz_sil.stats = deep_clone(silstatsconc1)
        -- Sharktooth Suppressor
        self.parts.wpn_fps_pis_cz_smallsil.custom_stats = silencercustomstats
        self.parts.wpn_fps_pis_cz_smallsil.stats = deep_clone(silstatsconc2)
        -- Snowflake Compensator
        self.parts.wpn_fps_pis_cz_comp.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        -- 
        self.parts.wpn_fps_pis_cz_m_ext.stats = deep_clone(mag_200)
        self.parts.wpn_fps_pis_cz_m_ext.stats.extra_ammo = 15

        self.parts.wpn_fps_pis_cz_g_bling.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz_g_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz_b_silver.stats = deep_clone(nostats)
        DelayedCalls:Add("cz75shadowdelay", delay, function()
            tweak_data.weapon.factory.wpn_fps_pis_x_cz.override.wpn_fps_pis_cz_m_ext.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_cz_m_ext.stats)
            tweak_data.weapon.factory.wpn_fps_pis_x_cz.override.wpn_fps_pis_cz_m_ext.stats.extra_ammo = tweak_data.weapon.factory.wpn_fps_pis_x_cz.override.wpn_fps_pis_cz_m_ext.stats.extra_ammo * 2
        end)
    end

    -- M2 HEAVY BARREL
    if BeardLib.Utils:ModLoaded("M2HB_HMG") then
        self.parts.inf_lmg_offset.stance_mod.wpn_fps_lmg_m2hb = {translation = Vector3(4, 0, -1)}
        self.parts.inf_lmg_offset_nongadget.stance_mod.wpn_fps_lmg_m2hb = {translation = Vector3(4, 0, -1)}
        table.insert(self.wpn_fps_lmg_m2hb.uses_parts, "inf_lmg_offset")
        table.insert(self.wpn_fps_lmg_m2hb.uses_parts, "inf_lmg_offset_nongadget")
    end

    -- MATEBA 6 UNICA PARTS
    if BeardLib.Utils:ModLoaded("Mateba Model 6 Unica") then
        -- Compensator
        self.parts.wpn_fps_upg_unica6_comp.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        -- Black Laminated Grip
        --self.parts.wpn_fps_upg_unica6_grip_black.stats = deep_clone(nostats)
    end


    if BeardLib.Utils:ModLoaded("Contender Special") then
        -- standard
        self.parts.wpn_fps_special_contender_shell_rifle.internal_part = true
        self.parts.wpn_fps_special_contender_shell_rifle.type = "ammo"
        self.parts.wpn_fps_special_contender_shell_rifle.stats = deep_clone(nostats)
        -- heavy
        self.parts.wpn_fps_special_contender_ammo_AP.internal_part = true
        self.parts.wpn_fps_special_contender_ammo_AP.type = "ammo"
        self.parts.wpn_fps_special_contender_ammo_AP.stats = {
            value = 0,
            total_ammo_mod = -333,
            damage = 40,
            recoil = -15,
            reload = -25,
            concealment = 0
        }
        -- light
        self.parts.wpn_fps_special_contender_ammo_22lr.internal_part = true
        self.parts.wpn_fps_special_contender_ammo_22lr.type = "ammo"
        self.parts.wpn_fps_special_contender_ammo_22lr.stats = {
            value = 0,
            total_ammo_mod = 500,
            damage = -16,
            recoil = 10,
            reload = 25,
            concealment = 0
        }
        -- shotgun
        self.parts.wpn_fps_special_contender_ammo_410bore.internal_part = true
        self.parts.wpn_fps_special_contender_ammo_410bore.type = "ammo"
        self.parts.wpn_fps_special_contender_ammo_410bore.stats = {
            value = 0,
            spread = -30,
            spread_multi = {1/shotgun_slug_mult, 1/shotgun_slug_mult},
            concealment = 0
        }
        -- why
        self.parts.wpn_fps_special_contender_ns_silencer.stats = {
            value = 0,
            alert_size = 12,
            suppression = 12,
            damage = -5,
            recoil = 5,
            concealment = -1
        }

        DelayedCalls:Add("contenderdelay", delay, function()
            -- why is the shield penetration being overwritten on the light round but not sdesc1
            -- fuck this gay earth

            -- standard
            --tweak_data.weapon.factory.parts.wpn_fps_special_contender_shell_rifle.custom_stats = {rays = 1}
            -- light
            tweak_data.weapon.factory.parts.wpn_fps_special_contender_ammo_22lr.custom_stats = {sdesc1 = "caliber_r3030", rays = 1, contender_shield_hack = true, can_shoot_through_enemy = true, can_shoot_through_shield = true, can_shoot_through_wall = true, ammo_pickup_min_mul = 1.5, ammo_pickup_max_mul = 1.5}
            -- heavy
            tweak_data.weapon.factory.parts.wpn_fps_special_contender_ammo_AP.custom_stats = {sdesc1 = "caliber_r3006", rays = 1, can_shoot_through_enemy = true, can_shoot_through_shield = true, can_shoot_through_wall = true, ammo_pickup_min_mul = 0.66, ammo_pickup_max_mul = 0.66}
            -- shotgun
            tweak_data.weapon.factory.parts.wpn_fps_special_contender_ammo_410bore.custom_stats = {sdesc1 = "caliber_s410", rays = 10, can_shoot_through_enemy = false, can_shoot_through_shield = false, can_shoot_through_wall = false, damage_far_mul = 0.10, damage_near_mul = 0.10}
        end)
    end


    if BeardLib.Utils:ModLoaded("m1c") then
        -- funnel compensator
        self.parts.wpn_fps_ass_m1c_comp.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        -- don't do it
        self.parts.wpn_fps_ass_m1c_rail.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_m1c_mag.stance_mod = {
            wpn_fps_ass_m1c = {translation = Vector3(0, 7, 0), rotation = Rotation(0, 0, 0)}
        }
    end

    if BeardLib.Utils:ModLoaded("Tokarev SVT-40") then
        -- upgraded muzzle brake
        self.parts.wpn_fps_upg_svt40_muzzle_brake_upg.stats = deep_clone(nostats)
        -- PU scopes
        self.parts.wpn_fps_upg_svt40_pu_scope.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_upg_svt40_pu_scope.stats = {
            value = 0,
            zoom = 5,
            concealment = -3
        }
        -- camo
        self.parts.wpn_fps_upg_svt40_stock_finish_snow2.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_svt40_stock_spetzjungle3.stats = deep_clone(nostats)
        -- prototype suppressor
        self.parts.wpn_fps_upg_svt40_suppressor.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_svt40_suppressor.stats = deep_clone(silstatsconc2)
    end

    if BeardLib.Utils:ModLoaded("AN-94 AR") and self.parts.wpn_fps_ass_akrocket_s_adjusted then
        self.parts.wpn_fps_ass_akrocket_s_adjusted.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_akrocket_g_mod.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_akrocket_fg_modern.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_akrocket_ns_sil.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_akrocket_ns_sil.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_ass_akrocket_b_heavy.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_ass_akrocket_b_long.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_ass_akrocket_m_fast.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_akrocket_m_extended.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_akrocket_m_fastext.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("tilt") then
        self.parts.wpn_fps_ass_tilt_g_wood.stats = deep_clone(nostats)
        -- bulk magazine
        self.parts.wpn_fps_ass_tilt_mag_big.stats = deep_clone(self.parts.wpn_fps_upg_ak_m_quad.stats)
        -- tactical magazine
        self.parts.wpn_fps_ass_tilt_mag_tactical.stats = deep_clone(nostats)
        -- swift magazine
        self.parts.wpn_fps_ass_tilt_mag_swift.stats = deep_clone(nostats)
        -- folding stock
        self.parts.wpn_fps_ass_tilt_stock_fold.stats = {
            value = 0,
            recoil = -5,
            concealment = 2
        }
        -- no stock
        self.parts.wpn_fps_ass_tilt_stock_none.stats = {
            value = 0,
            spread = -5,
            recoil = -5,
            concealment = 3
        }
        -- tactical stock
        self.parts.wpn_fps_ass_tilt_stock_tactical.stats = deep_clone(nostats)
        -- wood stock
        self.parts.wpn_fps_ass_tilt_stock_wood.stats = deep_clone(nostats)
        -- 7.62 ammo
        self:convert_part("wpn_fps_ass_tilt_a_fuerte", "lrifle", "mrifle")
        self.parts.wpn_fps_ass_tilt_a_fuerte.custom_stats.sdesc1 = "caliber_r762x39"
        self.parts.wpn_fps_ass_tilt_a_fuerte.internal_part = true
        DelayedCalls:Add("an92delayedcallaa", delay, function()
            self:convert_ammo_pickup("wpn_fps_ass_tilt_a_fuerte", InFmenu.wpnvalues.lrifle.ammo, InFmenu.wpnvalues.mrifle.ammo)
            self.parts.wpn_fps_upg_o_tilt_scopemount.stance_mod = {
                wpn_fps_ass_tilt = {
                    translation = Vector3(0, -10, 0), -- bring it closer to the face and fix that weird ADS offset that makes the sight unusable
                    rotation = Rotation(0, 0, 0)
                }
            }
        end)
    end


    if BeardLib.Utils:ModLoaded("Makarov Pistol") then
        -- pmm 12rnd mag
        self.parts.wpn_fps_pis_pm_m_custom.stats = deep_clone(mag_150)
        self.parts.wpn_fps_pis_pm_m_custom.stats.extra_ammo = 4
        self.parts.wpn_fps_pis_pm_m_custom.stats.concealment = 0
        -- dumbfuck single column
        self.parts.wpn_fps_pis_pm_m_extended.stats = deep_clone(mag_200)
        self.parts.wpn_fps_pis_pm_m_extended.stats.extra_ammo = 8
        -- go suck-start a shotgun
        self.parts.wpn_fps_pis_pm_m_drum.custom_stats = {rstance = InFmenu.rstance.lightpis, recoil_table = InFmenu.rtable.lightpis, armor_piercing_sub = 0.11, ammo_pickup_min_mul = 1.875, ammo_pickup_max_mul = 1.875}
        self.parts.wpn_fps_pis_pm_m_drum.stats = {
            value = 0,
            extra_ammo = 76,
            total_ammo_mod = 875, -- 80 to 150
            damage = -25,
            spread = -35,
            reload = -50,
            concealment = -15
        }
        -- modern body
        self.parts.wpn_fps_pis_pm_b_custom.stats = deep_clone(nostats)
        DelayedCalls:Add("makarovdelayedcall", delay, function(self, params)
            tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_custom.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_custom.stats)
            tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_custom.stats.extra_ammo = 8
            tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_extended.stats)
            tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_extended.stats.extra_ammo = 16
            tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_drum.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_drum.stats)
            tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_drum.stats.extra_ammo = 152

            tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_custom.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_custom.stats)
            tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_custom.stats.extra_ammo = 8
            tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_extended.stats)
            tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_extended.stats.extra_ammo = 16
            tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_drum.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_drum.stats)
            tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_drum.stats.extra_ammo = 152 -- 96 to 180
        end)
    end


    if BeardLib.Utils:ModLoaded("Remington Various Attachment") then
        -- heat-shielded barrel
        self.parts.wpn_fps_shot_mossberg_b_heat.stats = deep_clone(nostats)
        -- flashlight grip
        self.parts.wpn_fps_shot_870_fg_surefire.stats = {
            value = 0,
            concealment = -1
        }
        -- long rail system
        self.parts.wpn_fps_shot_870_rail_mcs.stats = {
            value = 0,
            concealment = -1
        }
        table.insert(self.parts.wpn_fps_shot_870_rail_mcs.forbids, "wpn_fps_ass_scar_o_flipups_up")
        table.insert(self.parts.wpn_fps_shot_870_rail_mcs.forbids, "wpn_fps_upg_870_o_ghostring")
        table.insert(self.parts.wpn_fps_shot_870_rail_mcs.forbids, "wpn_fps_upg_870_o_ghostring_short")
        -- short rail system
        self.parts.wpn_fps_shot_870_rail_aftermarket.stats = {
            value = 0,
            concealment = -1
        }
        table.insert(self.parts.wpn_fps_shot_870_rail_aftermarket.forbids, "wpn_fps_ass_scar_o_flipups_up")
        table.insert(self.parts.wpn_fps_shot_870_rail_aftermarket.forbids, "wpn_fps_upg_870_o_ghostring")
        table.insert(self.parts.wpn_fps_shot_870_rail_aftermarket.forbids, "wpn_fps_upg_870_o_ghostring_short")
        -- railed pump
        self.parts.wpn_fps_shot_870_fg_rail.stats = deep_clone(nostats)
        -- foreend strap
        self.parts.wpn_fps_shot_mossberg_fg_short.stats = deep_clone(nostats)
        -- synthetic pump
        self.parts.wpn_fps_shot_mossberg_fg_pump.stats = deep_clone(nostats)
        -- hunt down the refund pump
        self.parts.wpn_fps_shot_r870_fg_hdtf.stats = deep_clone(nostats)
        -- hunt down the refund stock
        self.parts.wpn_fps_shot_r870_s_hdtf.stats = deep_clone(nostats)
        -- loco vertical pump
        self.parts.wpn_fps_shot_870_fg_vertical.stats = deep_clone(nostats)
        -- semi-grip stock
        self.parts.wpn_fps_shot_mossberg_s_grip.stats = deep_clone(nostats)

        -- shielded ghost ring
        self.parts.wpn_fps_shot_mossberg_o_heat.forbids = self.parts.wpn_fps_shot_mossberg_o_heat.forbids or {}
        table.insert(self.parts.wpn_fps_shot_mossberg_o_heat.forbids, "wpn_fps_ass_scar_o_flipups_up")

        DelayedCalls:Add("reinbeckpartsdelayedcall", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_o_heat.stance_mod = {
                wpn_fps_shot_r870 = {translation = Vector3(0.1, -5, 0.3), rotation = Rotation(0, 0.5, 0)}
            }
        --[[
            tweak_data.weapon.factory.parts.wpn_fps_shot_870_iron_aftermarket.stance_mod = {
                wpn_fps_shot_r870 = {translation = Vector3(0, 0, -3.0), rotation = Rotation(0, 2.1, -0)},
                wpn_fps_shot_serbu = {translation = Vector3(-0.01, 0, -3.5), rotation = Rotation(0, 4, -0)}
            }
            tweak_data.weapon.factory.parts.wpn_fps_shot_870_iron_mcs.stance_mod = {
                wpn_fps_shot_r870 = {translation = Vector3(0, 0, -3.0), rotation = Rotation(0, 0.2, -0)},
                wpn_fps_shot_serbu = {translation = Vector3(0, 0, -3.0), rotation = Rotation(0, 0.2, -0)}
            }

            tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_o_heat.stance_mod = {
                wpn_fps_shot_r870 = {translation = Vector3(0.1, -5, -1.2), rotation = Rotation(0, 0.5, 0)}
            }
            tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_b_heat.override.wpn_fps_shot_mossberg_o_heat.stance_mod = {
                wpn_fps_shot_r870 = {translation = Vector3(0.09, -5, -1.0), rotation = Rotation(0, 0, -0)}
            }
            tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_b_heat.override.wpn_fps_shot_870_iron_aftermarket.stance_mod = {
                wpn_fps_shot_r870 = {translation = Vector3(-0.05, 0, -2.7), rotation = Rotation(-0.05, 1.1, -0)}
            }
        --]]

            -- locomotive gains stats with long stocks
            tweak_data.weapon.factory.wpn_fps_shot_serbu.override.wpn_fps_shot_mossberg_s_grip = {stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_shot_r870_s_solid.stats)}
            tweak_data.weapon.factory.wpn_fps_shot_serbu.override.wpn_fps_shot_r870_s_hdtf = {stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_shot_r870_s_solid.stats)}


            -- undo statfix for vanilla parts
            tweak_data.weapon.factory.parts.wpn_fps_shot_r870_body_rack.stats = {
                value = 0,
                reload = 5,
                concealment = -1
            }
            tweak_data.weapon.factory.parts.wpn_fps_shot_shorty_s_nostock_short.stats = {
                value = 0,
                recoil = 2,
                concealment = -1
            }
        end)

    end


    if BeardLib.Utils:ModLoaded("Winchester Model 1912") then
        -- base receiver
        self.parts.wpn_fps_shot_m1912_receiver.stats = deep_clone(nostats)
        -- field barrel
        self.parts.wpn_fps_upg_m1912_barrel_field.stats = {
            value = 0,
            spread = 10,
            recoil = 6,
            reload = -8,
            concealment = -2
        }
        -- riot barrel
        self.parts.wpn_fps_upg_m1912_barrel_riot.stats = {
            value = 0,
            spread = -10,
            concealment = 2
        }
        -- field forend
        self.parts.wpn_fps_upg_m1912_forend_field.stats = deep_clone(nostats)
        -- heat shield
        self.parts.wpn_fps_upg_m1912_heat_shield.stats = deep_clone(nostats)
        -- cutts compensator
        self.parts.wpn_fps_upg_m1912_ns_cutts.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
        -- duck choke
        self.parts.wpn_fps_upg_m1912_ns_duckbill.stats = deep_clone(self.parts.wpn_fps_upg_ns_duck.stats)
        -- cheek rest stock
        self.parts.wpn_fps_upg_m1912_stock_cheekrest.stats = deep_clone(nostats)
        -- cheek rest w/recoil pad
        self.parts.wpn_fps_upg_m1912_stock_cheekrest_pad.stats = deep_clone(nostats)
        -- recoil pad
        self.parts.wpn_fps_upg_m1912_stock_pad.stats = deep_clone(nostats)
        -- sawn-off stock
        self.parts.wpn_fps_upg_m1912_stock_sawnoff.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
        self.parts.wpn_fps_shot_m1912_receiver.stance_mod = {
            wpn_fps_shot_m1912 = {translation = Vector3(0, 1, 0)}
        }
    end


    if BeardLib.Utils:ModLoaded("KS-23") then
        -- shrapnel-25
        self.parts.wpn_fps_upg_ks23_ammo_buckshot_8pellet.custom_stats = {rays = 8, damage_near_mul = 25/15, damage_far_mul = 35/30, sdesc1 = "caliber_s23mm25"}
        self.parts.wpn_fps_upg_ks23_ammo_buckshot_8pellet.stats = {
            value = 0,
            damage = -20,
            spread = 20,
            concealment = 0
        }
        -- shrapnel-10
        self.parts.wpn_fps_upg_ks23_ammo_buckshot_20pellet.custom_stats = {rays = 20, damage_near_mul = 10/15, damage_far_mul = 20/30, sdesc1 = "caliber_s23mm10"}
        self.parts.wpn_fps_upg_ks23_ammo_buckshot_20pellet.stats = {
            value = 0,
            damage = 20,
            spread = -35,
            concealment = 0
        }
        -- barricade
        self.parts.wpn_fps_upg_ks23_ammo_slug.custom_stats = {damage_near_mul = 3, damage_far_mul = 3, rays = 1, armor_piercing_add = 1, sdesc3 = "range_shotslug", sdesc3_range_override = true, taser_hole = true, can_shoot_through_enemy = true, can_shoot_through_shield = true, can_shoot_through_wall = true}
        self.parts.wpn_fps_upg_ks23_ammo_slug.stats = {
            value = 0,
            damage = 40,
            spread = 20,
            spread_multi = {shotgun_slug_mult, shotgun_slug_mult},
            concealment = 0
        }

        -- short barrel
        self.parts.wpn_fps_upg_ks23_barrel_short.stats = {
            value = 0,
            spread = -15,
            reload = 15,
            concealment = 2
        }
        -- pistol grip
        self.parts.wpn_fps_upg_ks23_stock_pistolgrip.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
        -- pistol grip+wire stock
        self.parts.wpn_fps_upg_ks23_stock_pistolgrip_wire.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        -- receiver
        self.parts.wpn_fps_shot_ks23_rec.stance_mod = {
            wpn_fps_shot_ks23 = {translation = Vector3(0, 0, 0)}
        }
    end


    if BeardLib.Utils:ModLoaded("Marlin Model 1894 Custom") then
        -- default parts
        self.parts.wpn_fps_snp_m1894_loading_spring.stats = {}
        self.parts.wpn_fps_snp_m1894_irons.stats = {
            value = 0,
            zoom = 0,
            concealment = 0
        }
        self.parts.wpn_fps_upg_m1894_supp_gemtech_gm45.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_upg_m1894_supp_gemtech_gm45.stats = deep_clone(silstatsconc2)
    end

    -- primary svu/SVU-T
    if BeardLib.Utils:ModLoaded("svudragunov") then
        table.insert(gunlist_snp, {"wpn_fps_snp_svu_dragunov", -3})
        table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_spot")
        table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "inf_shortdot")
        table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_box")
        table.insert(customsightaddlist, {"wpn_fps_snp_svu_dragunov", "wpn_fps_snp_desertfox", true})
        self.parts.wpn_fps_upg_o_spot.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_spot.stance_mod.wpn_fps_snp_desertfox)
        self.parts.inf_shortdot.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.inf_shortdot.stance_mod.wpn_fps_snp_desertfox)
        self.parts.wpn_fps_upg_o_box.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_box.stance_mod.wpn_fps_snp_desertfox)
        -- default part
        self.parts.wpn_fps_snp_svu_dragunov_b_silencer.custom_stats = silencercustomstats
        self.parts.wpn_fps_snp_svu_dragunov_b_silencer.stats = deep_clone(nostats)
        -- i want my glaz sound
        table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "inf_svu_unsil")
        self.parts.inf_svu_unsil.unit = "units/mods/weapons/wpn_fps_snp_svu_dragunov_pts/wpn_fps_snp_svu_dragunov_b_silencer"
        self.parts.inf_svu_unsil.stats = {
            value = 0,
            alert_size = -11,
            suppression = -10,
            recoil = -6,
            concealment = 0
        }

        -- add parts that came out after the custom weapon did
        table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_45rds")
        self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_snp_desertfox)
        table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_45rds_v2")
        self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_snp_desertfox)
        table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_xpsg33_magnifier")
        self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.wpn_fps_snp_desertfox)
    end

    -- secondary svu
    if BeardLib.Utils:ModLoaded("SVU") then
        -- default parts
        self.parts.wpn_fps_snp_svu_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_svu_pso.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_snp_svu_pso.stats = {
            value = 0,
            zoom = 7,
            concealment = 0
        }

        self.parts.wpn_fps_upg_svu_bipod.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_svu_dtk2.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_upg_svu_grip_plastic.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_svu_handguard_camo.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_svu_handguard_plastic.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_svu_irons.stats = {
            value = 0,
            zoom = 0,
            concealment = 3
        }
        self.parts.wpn_fps_upg_svu_supp_pbs1.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_svu_supp_pbs1.stats = deep_clone(silstatsconc2)
        table.insert(gunlist_snp, {"wpn_fps_snp_svu", -3})
    end


    if BeardLib.Utils:ModLoaded("Gewehr 43") then
        table.insert(gunlist_snp, {"wpn_fps_snp_g43", -3})
        self.parts.wpn_fps_snp_g43_clothwrap.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_g43_sling.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_g43_zf4.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_snp_g43_zf4.stats = {
            value = 0,
            zoom = 7,
            concealment = 0
        }
        self.parts.wpn_fps_snp_g43_zf4_switch.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_snp_g43_zf4_switch.stats = {
            value = 0,
            zoom = 7,
            concealment = 0
        }
        self.parts.wpn_fps_snp_g43_zf4_irons.stats = {
            value = 0,
            gadget_zoom = 1,
            concealment = 0
        }
        self.parts.wpn_fps_snp_g43_irons.stats = {
            value = 0,
            zoom = 0,
            concealment = 3
        }
        self.parts.wpn_fps_snp_g43_silencer.custom_stats = silencercustomstats
        self.parts.wpn_fps_snp_g43_silencer.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_snp_g43_a_no_ap.custom_stats = {ammo_pickup_min_mul = 0.60, ammo_pickup_max_mul = 0.60, sdesc1 = "caliber_r792mauserk"}
        self.parts.wpn_fps_snp_g43_a_no_ap.stats = {
            value = 0,
            total_ammo_mod = -400,
            damage = 85,
            recoil = -5,
            reload = -15,
            concealment = 0
        }
    end

    -- primary mosin-nagant obrez
    if BeardLib.Utils:ModLoaded("Mosin Nagant Obrez Kit") then
        table.insert(self.parts.wpn_fps_snp_mosin_b_obrez.forbids, "inf_bipod_snp")
        self.parts.wpn_fps_snp_mosin_b_obrez.custom_stats = {muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_dragons_breath"}
        self.parts.wpn_fps_snp_mosin_b_obrez.stats = {
            value = 0,
            spread = -30,
            concealment = 3
        }
        self.parts.wpn_fps_snp_mosin_body_obrez.stats = {
            value = 0,
            recoil = -10,
            concealment = 3
        }
    end

    -- secondary obrez
    if BeardLib.Utils:ModLoaded("Mosin Nagant M9130 Obrez") then
        -- ridiculous flash is set in wpn_stats
        -- default part
        self.parts.wpn_fps_snp_obrez_clip.stats = deep_clone(nostats)

        -- sil
        self.parts.wpn_fps_upg_obrez_ns_supp.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_upg_obrez_ns_supp.stats = deep_clone(silstatssnp)
        -- svt-40 brake
        self.parts.wpn_fps_upg_obrez_ns_svt40_brake.stats = {
            value = 0,
            recoil = 3,
            concealment = -1
        }
    end


    -- BAR
    if BeardLib.Utils:ModLoaded("BAR LMG") then
        self.parts.wpn_fps_ass_bar_g_monitor.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_bar_bipod.custom_stats = {recoil_horizontal_mult = 2}
        self.parts.wpn_fps_ass_bar_bipod.adds = {"inf_bipod_part"}
        self.parts.wpn_fps_ass_bar_bipod.type = "bipod"
        self.parts.wpn_fps_ass_bar_bipod.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_bar_carryhandle.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_bar_b_para.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_ass_bar_fg_sleeve.stats = {
            value = 0,
            spread = -10,
            concealment = 2
        }
        self.parts.wpn_fps_ass_bar_m_extended.stats = deep_clone(mag_200)
        self.parts.wpn_fps_ass_bar_m_extended.stats.extra_ammo = 20
        self.parts.wpn_fps_ass_bar_ns_cutts.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }

        table.insert(self.wpn_fps_ass_bar.uses_parts, "inf_bar_slowfire")
        self.parts.inf_bar_slowfire.internal_part = true
        self.parts.inf_bar_slowfire.custom_stats = {has_burst_fire = true, burst_size = 300, adaptive_burst_size = true, burst_fire_rate_multiplier = 400/600}
        self.parts.inf_bar_slowfire.stats = deep_clone(nostats)
        DelayedCalls:Add("bardelaycall", delay, function(self, params)
            tweak_data.weapon.factory.wpn_fps_ass_bar.override.wpn_fps_snp_msr_ns_suppressor = {
                stats = deep_clone(silstatsconc2),
                custom_stats = silencercustomstats,
                desc_id = "bar_sil_desc",
                forbids = {"wpn_fps_ass_bar_bipod"}
            }
        end)
    end

    if BeardLib.Utils:ModLoaded("Seburo M5") then
        self.parts.wpn_fps_pis_seburo_g_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_seburo_f_silver.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_seburo_s_silver.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_seburo_autofire.stats = deep_clone(nostats)

        self.parts.wpn_fps_pis_seburo_m_extended.stats = deep_clone(mag_133)
        self.parts.wpn_fps_pis_seburo_m_extended.stats.extra_ammo = 6

        self.parts.wpn_fps_pis_seburo_s_s9.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_seburo_g_s9.stats = deep_clone(nostats)
        DelayedCalls:Add("seburom5delaycall", delay, function(self, params)
            tweak_data.weapon.factory.wpn_fps_pis_seburo.override.wpn_fps_pis_seburo_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_seburo_m_extended.stats)
            tweak_data.weapon.factory.wpn_fps_pis_x_seburo.override.wpn_fps_pis_seburo_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_seburo_m_extended.stats)
            tweak_data.weapon.factory.wpn_fps_pis_x_seburo.override.wpn_fps_pis_seburo_m_extended.stats.extra_ammo = tweak_data.weapon.factory.parts.wpn_fps_pis_seburo_m_extended.stats.extra_ammo * 2

            tweak_data.weapon.factory.parts.wpn_fps_pis_x_seburo_sight_up.stats.gadget_zoom = 3
            tweak_data.weapon.factory.parts.wpn_fps_pis_x_seburo_sight_up.stance_mod.wpn_fps_pis_x_seburo = {translation = Vector3(-3.8, 0, 0.9), rotation = Rotation(0, 0, 0)}
        end)
    end


    if BeardLib.Utils:ModLoaded("HKG11") then
        self.parts.wpn_fps_upg_temple_i_matthewreilly.perks = nil
        self.parts.wpn_fps_upg_temple_i_matthewreilly.custom_stats = {has_burst_fire = false, inf_rof_mult = 2100/460} -- this is fucking stupid
        self.parts.wpn_fps_upg_temple_i_matthewreilly.stats = {
            value = 0,
            spread = -20,
            concealment = 0
        }
    --[[
        self.parts.wpn_fps_ass_temple_o_dummy.scope_overlay_hide_weapon = true
        self.parts.wpn_fps_ass_temple_o_dummy.scope_overlay = "guis/dlcs/mods/textures/pd2/overlay/g11_reticleoverlay"
    --]]
        self.parts.wpn_fps_ass_temple_o_dummy.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_ass_temple_o_dummy.stats = {
            value = 0,
            zoom = 3,
            concealment = 0
        }
    end

    if BeardLib.Utils:ModLoaded("Beretta 93R") then
        self.parts.wpn_fps_upg_b93r_comp_93r.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        self.parts.wpn_fps_upg_b93r_comp_long.stats = {
            value = 0,
            spread = 5,
            concealment = -1
        }
        self.parts.wpn_fps_upg_b93r_flash.stats = {
            value = 0,
            spread = 2,
            recoil = 1,
            concealment = -1
        }
        self.parts.wpn_fps_upg_b93r_grip_plastic.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_b93r_leupold_pro.stats = {
            value = 0,
            zoom = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_b93r_ncstar_4.stats = {
            value = 0,
            zoom = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_b93r_sight_tritium.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_b93r_vertgrip_rail.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("TOZ-34") then
        self.parts.wpn_fps_shot_toz34_sight_rail.stance_mod = {wpn_fps_shot_toz34 = {translation = Vector3(0, -11, -0.2), rotation = Rotation(0, 0.2, 0)}}
        self.parts.wpn_fps_shot_toz34_body.stance_mod = {wpn_fps_shot_toz34 = {translation = Vector3(0, 11, 0.2), rotation = Rotation(0, -0.2, 0)}}
        self.parts.wpn_fps_shot_toz34_body.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_toz34_ammo_000_magnum.custom_stats = {
            rays = 8,
            damage_near_mul = 0.80,
            damage_far_mul = 0.80,
            sdesc1 = "caliber_s12g_000magnum",
            ammo_pickup_min_mul = 0.80,
            ammo_pickup_max_mul = 0.80
        }
        self.parts.wpn_fps_upg_toz34_ammo_000_magnum.stats = {
            value = 0,
            total_ammo_mod = -200,
            damage = 6
        }
        self.parts.wpn_fps_upg_toz34_barrel_short.stats = deep_clone(db_barrel)
        self.parts.wpn_fps_upg_toz34_choke.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
        self.parts.wpn_fps_upg_toz34_choke_modified.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
        self.parts.wpn_fps_upg_toz34_duckbill.stats = deep_clone(self.parts.wpn_fps_upg_ns_duck.stats)
        self.parts.wpn_fps_upg_toz34_stock_short.stats = deep_clone(db_stock)
    end


        -- MEUSOC grip
    if BeardLib.Utils:ModLoaded("Pachmayr Grip") then
        self.parts.wpn_fps_pis_1911_g_pachmayr.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("TOZ-66") then
        self.parts.wpn_fps_shot_toz66_body.stats = {}
        self.parts.wpn_fps_shot_toz66_body.stance_mod = {wpn_fps_shot_toz66 = {translation = Vector3(0, 0, 1.5)}}

        self.parts.wpn_fps_upg_toz66_ammo_000_magnum.custom_stats = {
            rays = 8,
            damage_near_mul = 0.80,
            damage_far_mul = 0.80,
            sdesc1 = "caliber_s12g_000magnum",
            ammo_pickup_min_mul = 0.80,
            ammo_pickup_max_mul = 0.80
        }
        self.parts.wpn_fps_upg_toz66_ammo_000_magnum.stats = {
            value = 0,
            total_ammo_mod = -200,
            damage = 6
        }
        self.parts.wpn_fps_upg_toz66_choke.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
        self.parts.wpn_fps_upg_toz66_choke_modified.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
        self.parts.wpn_fps_upg_toz66_duckbill.stats = deep_clone(self.parts.wpn_fps_upg_ns_duck.stats)
    end

    if BeardLib.Utils:ModLoaded("PU Scope") then
        self.parts.wpn_fps_snp_mosin_pu_scope.custom_stats = {disallow_ads_while_reloading = true}
    end

    if BeardLib.Utils:ModLoaded("pdr") then
        -- swift mag
        self.parts.wpn_fps_smg_pdr_m_pmag.stats = deep_clone(nostats)
        -- short mag
        self.parts.wpn_fps_smg_pdr_m_short.stats = deep_clone(mag_66)
        self.parts.wpn_fps_smg_pdr_m_short.stats.extra_ammo = -10
    end

    if BeardLib.Utils:ModLoaded("Steyr AUG A3 9mm XS") then
        self.parts.wpn_fps_smg_aug9mm_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_aug9mm_barrel_long.stats = {
            value = 0,
            spread = 15,
            recoil = 9,
            reload = -12,
            concealment = -2
        }
        self.parts.wpn_fps_upg_aug9mm_barrel_medium.stats = {
            value = 0,
            spread = 5,
            recoil = 3,
            reload = -4,
            concealment = -1
        }
        self.parts.wpn_fps_upg_aug9mm_mag_ext.stats = deep_clone(mag_133)
        self.parts.wpn_fps_upg_aug9mm_mag_ext.stats.extra_ammo = 8

        self.parts.wpn_fps_upg_aug9mm_supp_gm9.custom_stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_medium.custom_stats)
        self.parts.wpn_fps_upg_aug9mm_supp_gm9.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_medium.stats)
        self.parts.wpn_fps_upg_aug9mm_supp_osprey.custom_stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_large.custom_stats)
        self.parts.wpn_fps_upg_aug9mm_supp_osprey.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_large.stats)
        self.parts.wpn_fps_upg_aug9mm_vg_bcm.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_upg_aug9mm_vg_fab_reg.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_aug9mm_vg_m900.stats = {
            value = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_aug9mm_vg_troy.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_aug9mm_vg_troy_short.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("L115") then
        table.insert(gunlist_snp, {"wpn_fps_snp_l115", -3})
        self.parts.wpn_fps_snp_l115_mag.stats = nil
        table.insert(self.wpn_fps_snp_l115.uses_parts, "inf_shortdot")
        self.parts.inf_shortdot.stance_mod.wpn_fps_snp_l115 = deep_clone(self.parts.inf_shortdot.stance_mod.wpn_fps_snp_msr)

        self.parts.wpn_fps_upg_l115_barrel_awc.custom_stats = snpsilencercustomstats
        --self.parts.wpn_fps_upg_l115_barrel_awc.custom_stats.sdesc1 = "caliber_r308"
        self.parts.wpn_fps_upg_l115_barrel_awc.stats = deep_clone(silstatssnp)
        self.parts.wpn_fps_upg_l115_supp.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_upg_l115_supp.stats = deep_clone(silstatssnp)
        if BeardLib.Utils:ModLoaded("Custom Attachment Points") or BeardLib.Utils:ModLoaded("WeaponLib") then
            table.insert(self.wpn_fps_snp_l115.uses_parts, "inf_bipod_snp")
        end
    end

    if BeardLib.Utils:ModLoaded("US Optics ST-10 Scope") then
        self.parts.wpn_fps_upg_o_st10.customsight = true
        self.parts.wpn_fps_upg_o_st10.customsighttrans = {}
        self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 3, 0)}
        self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 10, 0)}
        self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0, -10, 0)}
        self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0, -10, 0)}
        self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0, -10, 0)}
        self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 14, 0)}
        self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 2, 0)}
        self.parts.wpn_fps_upg_o_st10.custom_stats = deep_clone(self.parts.wpn_fps_upg_o_specter.custom_stats)
        self.parts.wpn_fps_upg_o_st10.stats = {
            value = 0,
            zoom = 8,
            concealment = -3
        }
    end

    if BeardLib.Utils:ModLoaded("ZeissMod") then
        self.parts.wpn_fps_upg_o_zeiss.customsight = true
        self.parts.wpn_fps_upg_o_zeiss.stats = deep_clone(self.parts.wpn_fps_upg_o_t1micro.stats)
    end

    if BeardLib.Utils:ModLoaded("AK Topless") then
        self.parts.wpn_fps_ass_akm_topless.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_ass_akm_topless")
        table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_ass_akm_topless")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_akm_topless")
        table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_ass_akm_topless")
        primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_akm_topless")
    end

    if BeardLib.Utils:ModLoaded("Montana 5.56") then
        self.parts.wpn_fps_ass_yayo_fg_rail.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_yayo_mag_dual.custom_stats = {alternating_reload = 1.20/0.80}
        self.parts.wpn_fps_ass_yayo_mag_dual.stats = {
            value = 0,
            reload = -20,
            concealment = -1
        }
        self.parts.wpn_fps_ass_yayo_mag_pmag.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_yayo_mag_smol.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)
        -- pacino grip
        self.parts.wpn_fps_ass_yayo_g_ergo.stats = deep_clone(nostats)
        -- tony grip
        self.parts.wpn_fps_ass_yayo_g_hk.stats = deep_clone(nostats)
        -- soza stock (dark tactical)
        self.parts.wpn_fps_ass_yayo_s_tactical.stats = deep_clone(nostats)
        -- modern stock (dark standard)
        self.parts.wpn_fps_ass_yayo_s_modern.stats = deep_clone(nostats)
        --
        self:convert_part("wpn_fps_ass_yayo_potato", "lrifle", "lrifle", 120, InFmenu.wpnvalues.lrifle.ammo)
        self.parts.wpn_fps_ass_yayo_potato.custom_stats.sdesc3 = "misc_blank"
        self.parts.wpn_fps_ass_yayo_potato.stats = {
            value = 0,
            total_ammo_mod = 500,
            concealment = 4
        }

        self.parts.wpn_fps_ass_yayo_flipup.stance_mod.wpn_fps_ass_yayo = {translation = Vector3(0, 0, -1), rotation = Rotation(0, -0.5, 0)}
    end

    if BeardLib.Utils:ModLoaded("Bren Ten") then
        self.parts.wpn_fps_pis_sonny_sl_runt.stats = {
            value = 0,
            spread = -5,
            concealment = 1
        }
    end

    if BeardLib.Utils:ModLoaded("VisionKing VS1.5-5x30QZ") then
        self.parts.wpn_fps_upg_o_visionking.customsight = true
        self.parts.wpn_fps_upg_o_visionking.customsighttrans = {}
        self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 10, 0)}
        self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 16, 0)}
        self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 16, 0)}
        self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 8, 0)}
        self.parts.wpn_fps_upg_o_visionking.custom_stats = {self.parts.wpn_fps_upg_o_specter.custom_stats}
        self.parts.wpn_fps_upg_o_visionking.stats = {
            value = 0,
            zoom = 7,
            concealment = -3
        }
    end

    if BeardLib.Utils:ModLoaded("CompM4s Sight") then
        self.parts.wpn_fps_upg_o_compm4s.customsight = true
        self.parts.wpn_fps_upg_o_compm4s.stats = {
            value = 0,
            zoom = 0,
            concealment = -1,
        }
    end

    if BeardLib.Utils:ModLoaded("STG 44") then
        self.parts.wpn_fps_ass_stg44_b_short.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_ass_stg44_b_long.stats = {
            value = 0,
            spread = 5,
            concealment = -1
        }
        self.parts.wpn_fps_ass_stg44_m_short.stats = deep_clone(mag_33)
        self.parts.wpn_fps_ass_stg44_m_short.stats.extra_ammo = -20

        self.parts.wpn_fps_ass_stg44_m_long.stats = deep_clone(mag_133)
        self.parts.wpn_fps_ass_stg44_m_long.stats.extra_ammo = 10

        self.parts.wpn_fps_ass_stg44_m_double.custom_stats = {alternating_reload = 1.5}
        self.parts.wpn_fps_ass_stg44_m_double.stats = deep_clone(mag_alternating)

        self.parts.wpn_fps_ass_stg44_m_short_double.custom_stats = {alternating_reload = 1.5}
        self.parts.wpn_fps_ass_stg44_m_short_double.stats = deep_clone(mag_alternating)
        self.parts.wpn_fps_ass_stg44_m_short_double.stats.extra_ammo = -20

        self.parts.wpn_fps_ass_stg44_s_plast.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_stg44_sing.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_stg44_o_scope.custom_stats = deep_clone(self.parts.wpn_fps_upg_o_acog.custom_stats)
        self.parts.wpn_fps_ass_stg44_o_scope.stats = deep_clone(self.parts.wpn_fps_upg_o_acog.stats)
        self.parts.wpn_fps_ass_stg44_o_scope_switch.custom_stats = deep_clone(self.parts.wpn_fps_upg_o_acog.custom_stats)
        self.parts.wpn_fps_ass_stg44_o_scope_switch.stats = deep_clone(self.parts.wpn_fps_upg_o_acog.stats)
        self.parts.wpn_fps_ass_stg44_fg_mp5.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_stg44_fg_r.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_stg44_s_a280.stats = {
            value = 0,
            recoil = -5,
            concealment = 2
        }
        self.parts.wpn_fps_ass_stg44_fg_a280.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("HK G3A3 M203") then
        self.parts.wpn_fps_ass_g3m203_mag.stats = {}
        self.parts.wpn_fps_upg_g3m203_barrel_g3ka4.stats = {
            value = 0,
            spread = -5,
            concealment = 1
        }
        self.parts.wpn_fps_upg_g3m203_grip_psg1.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_handguard_rail.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_handguard_psg1.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_handguard_wide.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_handguard_wide_bipod.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_handguard_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_stock_g3ka4.stats = {
            value = 0,
            recoil = -5,
            concealment = 2
        }
        self.parts.wpn_fps_upg_g3m203_stock_magpul_prs.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_stock_magpul_prs_largepad.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        self.parts.wpn_fps_upg_g3m203_stock_psg1.stats = {
            value = 0,
            recoil = 4,
            concealment = -2
        }
        self.parts.wpn_fps_upg_g3m203_stock_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g3m203_supp_socom762.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_g3m203_supp_socom762.stats = deep_clone(silstatsconc1)
        self.parts.wpn_fps_upg_g3m203_trigger_group_navy.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_g3m203_gre_buckshot.custom_stats = self.parts.wpn_fps_upg_g3m203_gre_buckshot.custom_stats or {}
        self.parts.wpn_fps_upg_g3m203_gre_buckshot.custom_stats.sdesc3 = "misc_gl40x46mmbuck"
        self.parts.wpn_fps_upg_g3m203_gre_flechette.custom_stats = self.parts.wpn_fps_upg_g3m203_gre_flechette.custom_stats or {}
        self.parts.wpn_fps_upg_g3m203_gre_flechette.custom_stats.sdesc3 = "misc_gl40x46mmflechette"
        self.parts.wpn_fps_upg_g3m203_gre_incendiary.custom_stats = self.parts.wpn_fps_upg_g3m203_gre_incendiary.custom_stats or {}
        self.parts.wpn_fps_upg_g3m203_gre_incendiary.custom_stats.sdesc3 = "misc_gl40x46mmIC"
    end

    if BeardLib.Utils:ModLoaded("AAC Honey Badger") then
        -- default part
        self.parts.wpn_fps_ass_bajur_b_std.custom_stats = silencercustomstats

        self.parts.wpn_fps_upg_bajur_b_long.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_bajur_b_long.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_upg_bajur_b_long.stats.alert_size = 12
        self.parts.wpn_fps_upg_bajur_b_long.stats.spread = self.parts.wpn_fps_upg_bajur_b_long.stats.spread + 5
        self.parts.wpn_fps_upg_bajur_b_short.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_bajur_b_short.stats = {
            value = 0,
            alert_size = 12,
            spread = -5,
            concealment = 1
        }
        self.parts.wpn_fps_upg_bajur_m_quick.stats = deep_clone(mag_66)
        self.parts.wpn_fps_upg_bajur_m_quick.stats.extra_ammo = -10
        self.parts.wpn_fps_upg_bajur_m_plate.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_bajur_s_ext.stats = {
            value = 0,
            recoil = 5,
            concealment = -2
        }
        self.parts.wpn_fps_upg_bajur_s_nope.stats = {
            value = 0,
            recoil = -5,
            concealment = 2
        }
        self:convert_part("wpn_fps_upg_bajur_am_grendel", "mrifle", "hrifle")
        self.parts.wpn_fps_upg_bajur_am_grendel.custom_stats = {sdesc1 = "caliber_r65grendel"}
        self.parts.wpn_fps_upg_bajur_am_grendel.stats.extra_ammo = -5
        self.parts.wpn_fps_upg_bajur_am_grendel.stats.reload = 10

        self.parts.wpn_fps_upg_bajur_fg_dmr.stats.extra_ammo = -10
        self.parts.wpn_fps_upg_bajur_fg_dmr.stats.concealment = -1
        DelayedCalls:Add("bajurdelaycall", delay, function(self, params)
            tweak_data.weapon.factory:convert_part("wpn_fps_upg_bajur_fg_dmr", "mrifle", "ldmr")
            tweak_data.weapon.factory.parts.wpn_fps_upg_bajur_fg_dmr.custom_stats = {sdesc1 = "caliber_r50beowulf"}
        end)
    end

    if BeardLib.Utils:ModLoaded("Kobra Sight") then
        self.parts.wpn_fps_upg_o_kobra.customsight = true
        self.parts.wpn_fps_upg_o_kobra.stats = deep_clone(self.parts.wpn_fps_upg_o_t1micro.stats)
    end

    if BeardLib.Utils:ModLoaded("OKP-7 Sight") then
        self.parts.wpn_fps_upg_o_okp7.customsight = true
        self.parts.wpn_fps_upg_o_okp7.customsighttrans = {}
        self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0.6, 0, 0.93)}
        self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0.6, 0, 0.93)}
        self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0.6, 0, 0.93)}
        self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0.6, 0, 0.93)}
        self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0.6, 0, 0.93)}
        self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0.6, 0, 0.93)}
        self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0.6, 0, 0.93)}
        self.parts.wpn_fps_upg_o_okp7.stats = deep_clone(self.parts.wpn_fps_upg_o_t1micro.stats)
    end

    if BeardLib.Utils:ModLoaded("af2011") then
        self.parts.wpn_fps_pis_af2011_body_standard.stats = {
            value = 0,
            spread_multi = {2.00, 0.50},
            concealment = 0
        }

        self.parts.wpn_fps_pis_af2011_g_bling.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_af2011_g_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_af2011_b_silver.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_af2011_m_ext.stats = deep_clone(mag_150)
        self.parts.wpn_fps_pis_af2011_m_ext.stats.extra_ammo = 10
    --[[
        self.parts.wpn_fps_pis_af2011_a_uno.custom_stats = {sdesc1 = "caliber_p38spc"}
        self.parts.wpn_fps_pis_af2011_a_uno.stats = {
            value = 0,
            damage = -10,
            recoil = 10,
            concealment = 0
        }
    --]]
    --[[
        self.parts.wpn_fps_pis_af2011_a_shield.custom_stats = {sdesc1 = "caliber_p45s"}
        self.parts.wpn_fps_pis_af2011_a_shield.stats = {
            value = 0,
            damage = InFmenu.wpnvalues.supermediumpis.damage - InFmenu.wpnvalues.mediumpis.damage,
            recoil = InFmenu.wpnvalues.supermediumpis.recoil - InFmenu.wpnvalues.mediumpis.recoil,
            concealment = 0
        }
    --]]
        self:convert_part("wpn_fps_pis_af2011_a_uno", "mediumpis", "lightpis", 96, 160)
        self.parts.wpn_fps_pis_af2011_a_uno.custom_stats.sdesc1 = "caliber_p38spc"
        self:convert_part("wpn_fps_pis_af2011_a_shield", "mediumpis", "supermediumpis", 96, 64)
        self.parts.wpn_fps_pis_af2011_a_shield.custom_stats.sdesc1 = "caliber_p45s"
        DelayedCalls:Add("af2011delaycall", delay, function(self, params)
            tweak_data.weapon.factory.wpn_fps_pis_x_af2011.override.wpn_fps_pis_af2011_m_ext.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_af2011_m_ext.stats)
            tweak_data.weapon.factory.wpn_fps_pis_x_af2011.override.wpn_fps_pis_af2011_m_ext.stats.extra_ammo = tweak_data.weapon.factory.parts.wpn_fps_pis_af2011_m_ext.stats.extra_ammo * 2
        end)
    end

    if BeardLib.Utils:ModLoaded("1P69 Giperon Scope CS5") then
        self.parts.wpn_fps_upg_o_1p69.customsight = true
        self.parts.wpn_fps_upg_o_1p69.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_upg_o_1p69.stats = {
            value = 0,
            zoom = 8,
            concealment = -3
        }
    end

    if BeardLib.Utils:ModLoaded("STF-12") then
        -- it's a short barrel
        -- it's fixed by now
        self.parts.wpn_fps_shot_stf12_b_short.stats = deep_clone(barrelsho_p1)
        -- long barrel here
        self.parts.wpn_fps_shot_stf12_b_long.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_shot_stf12_choke.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)

        -- fix ADS
        self.parts.wpn_fps_shot_stf12_body_standard.stance_mod = {}
        --self.parts.wpn_fps_shot_stf12_body_standard.stance_mod.wpn_fps_shot_stf12 = {translation = Vector3(0, 0, -1.5), rotation = Rotation(0, 0, 0)}
        -- can't just stick the magnifier on without a sight to magnify
        self.parts.wpn_fps_shot_stf12_sights.forbids = self.parts.wpn_fps_shot_stf12_sights.forbids or {}
        table.insert(self.parts.wpn_fps_shot_stf12_sights.forbids, "wpn_fps_upg_o_xpsg33_magnifier")
        table.insert(customsightaddlist, {"wpn_fps_shot_stf12", "wpn_fps_shot_r870", true})
    end

    if BeardLib.Utils:ModLoaded("PO 4x24P Scope") then
        self.parts.wpn_fps_upg_o_po4.customsight = true
        self.parts.wpn_fps_upg_o_po4.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_upg_o_po4.stats = {
            value = 0,
            zoom = 6,
            concealment = -2
        }
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_m4 = {translation = Vector3(0.204, 0, 0.70)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_amcar = {translation = Vector3(0.204, -1, 1.16)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_m16 = {translation = Vector3(0.2, 0, 1.15)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_olympic = {translation = Vector3(0.2, 0, 1.14)} -- automatically transferred to primary version
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_74 = {translation = Vector3(0.2, -16, -1.9)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_akm = {translation = Vector3(0.2, -16, -1.9)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_akm_gold = {translation = Vector3(0.2, -16, -1.9)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_asval = {translation = Vector3(0.205, 3, 1.27)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_saiga = {translation = Vector3(0.26, -16, -1.71)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_r870 = {translation = Vector3(0.217, -5, -3.51)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_akmsu = {translation = Vector3(0.2, -16, -2.07)} --
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_ak5 = {translation = Vector3(0.22, -5, -2.26)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_aug = {translation = Vector3(0.2, 0, -1.53)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_g36 = {translation = Vector3(0.18, -5, -1.71)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_m14 = {translation = Vector3(0.18, -15, -2.59)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mp5 = {translation = Vector3(0.2, 0, -1.67)} --
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_s552 = {translation = Vector3(0.155, 0, -0.88)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_scar = {translation = Vector3(0.2, -3, 0.97)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_m95 = {translation = Vector3(0.2, -4, -2.56)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_msr = {translation = Vector3(0.205, -14, -2.295)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_r93 = {translation = Vector3(0.20, -10, -2.51)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_fal = {translation = Vector3(0.2, 0, -2.27)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_ben = {translation = Vector3(0.2, -5, -1.97)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_ksg = {translation = Vector3(0.2, 0, -0.05)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_g3 = {translation = Vector3(0.235, -8, -2.14)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_galil = {translation = Vector3(0.20, -2, -1.96)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_famas = {translation = Vector3(0.20, -5, -5)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_spas12 = {translation = Vector3(0.04, 0, -2.69)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_mosin = {translation = Vector3(0.2, -32, -3.03)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_thompson = {translation = Vector3(0.2, -24, -2.95)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_l85a2 = {translation = Vector3(0.19, 2, 3.135)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_vhs = {translation = Vector3(0.195, -4, 0.07)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_aa12 = {translation = Vector3(0.19, 0, 1.35)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_gre_m32 = {translation = Vector3(0.2, 3, 2.2)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_wa2000 = {translation = Vector3(0.195, -9, 2.015)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_tecci = {translation = Vector3(0.205, 2, -0.43)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_model70 = {translation = Vector3(0.2, -12, -2.78)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_hajk = {translation = Vector3(0.2, 0, 0.77)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_desertfox = {translation = Vector3(0.195, -20, -2.69)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_schakal = {translation = Vector3(0.2, 0, -1.55)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_contraband = {translation = Vector3(0.195, -5, -0.43)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_tti = {translation = Vector3(0.2, 1, 1.15)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_siltstone = {translation = Vector3(0.2, 4, -2.76)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_flint = {translation = Vector3(0.19, 0, -1.435)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_coal = {translation = Vector3(0.2, 10, -2.75)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_ching = {translation = Vector3(0.2, -18, -1.51)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_bow_ecp = {translation = Vector3(0.2, -10, -2.08)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_corgi = {translation = Vector3(0.2, -11, -1.03)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_shepheard = {translation = Vector3(0.195, -8, 0.84)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_komodo = {translation = Vector3(0.2, 3, 1.35)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_bow_elastic = {translation = Vector3(0.2, 0, -0.25)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_serbu = {translation = Vector3(0.22, -4, -3.5)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_p90 = {translation = Vector3(0.195, -4, -1.77)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mp9 = {translation = Vector3(0.2, 4, -2.22)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mac10 = {translation = Vector3(0.2, -12, -1.84)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_m45 = {translation = Vector3(0.195, -14, -2.67)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mp7 = {translation = Vector3(0.195, -4, -1.56)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_pis_rage = {translation = Vector3(0.17, -15, -3.35)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_pis_deagle = {translation = Vector3(0.2, -18, -3.45)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_striker = {translation = Vector3(0.2, 0, -1.51)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_scorpion = {translation = Vector3(0.195, -10, -3.92)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_tec9 = {translation = Vector3(0.2, -2, -3.73)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_uzi = {translation = Vector3(0.2, -6, -3.83)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_pis_judge = {translation = Vector3(0.24, -16, -4.06)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_rpg7 = {translation = Vector3(0.2, 3, 1.28)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_polymer = {translation = Vector3(0.2, 2, 0.60)}
        --self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_m37 = {translation = Vector3(0.2, -8, -2.80)} -- not usable
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_sr2 = {translation = Vector3(0.195, 10, -3.31)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_rota = {translation = Vector3(0.2, -6, 0.84)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_gre_arbiter = {translation = Vector3(0.2, 0, 0.85)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_erma = {translation = Vector3(0.202, -4, -2.9)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_basset = {translation = Vector3(0.195, -2, 0.56)}
        self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_gre_slap = {translation = Vector3(0.18, 0, -0.59)}
    end

    if BeardLib.Utils:ModLoaded("CheyTac M200") then
        -- big default scope with 8 zoom
        table.insert(gunlist_snp, {"wpn_fps_snp_m200", -4})
        self.parts.wpn_fps_snp_m200_deltatitanium.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_snp_m200_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m200_barrel_bipod.adds = {"inf_bipod_part"}
        self.parts.wpn_fps_upg_m200_barrel_bipod.stats = {
            value = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_m200_supp.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_upg_m200_supp.stats = deep_clone(silstatssnp)
    end

    if BeardLib.Utils:ModLoaded("EOTech 552 Holographic Sight") then
        self.parts.wpn_fps_upg_o_eotech552.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)

        self.parts.wpn_fps_upg_o_eotech552.customsight = true
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans = {}
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 0, 0.335)}
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 0, 0.335)}
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0, 0, 0.335)}
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0, 0, 0.335)}
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0, 0, 0.335)}
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 0, 0.335)}
        self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 0, 0.335)}
        DelayedCalls:Add("eotech552_grayingmyhair", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_upg_o_eotech552.stance_mod.wpn_fps_ass_mk18s = {translation = Vector3(0, -10, -1)}
        end)
    end

    if BeardLib.Utils:ModLoaded("Minebea SMG") then
        self.parts.wpn_fps_smg_minebea_m_standard.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_minebea_m_extended.stats = deep_clone(mag_150)
        self.parts.wpn_fps_smg_minebea_m_extended.stats.extra_ammo = 10
        self.parts.wpn_fps_smg_minebea_s_no.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_smg_minebea_s_extended.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        --self.parts.wpn_fps_smg_minebea_barrelext.custom_stats = {muzzleflash = "effects/payday2/particles/weapons/9mm_auto_silence"}
        self.parts.wpn_fps_smg_minebea_barrelext.stats = {
            value = 0,
            spread = 5,
            concealment = -1
        }
        self.parts.wpn_fps_smg_minebea_g_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_minebea_o_adapter.forbidden_by_sight_rail = true
        self.parts.wpn_fps_smg_minebea_ironsight.forbids = {"inf_sightrail_invis"}
        DelayedCalls:Add("minebeadelay", delay, function(self, params)
            tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_smg_minebea_m_extended.stats)
            tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_m_extended.stats.extra_ammo = tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_m_extended.stats.extra_ammo * 2

            tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_s_extended = {desc_id = "bm_wp_wpn_fps_smg_minebea_s_extended_desc_x"}
            tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_s_no = {desc_id = "bm_wp_wpn_fps_smg_minebea_s_no_desc_x"}

            tweak_data.weapon.factory.parts.wpn_fps_smg_minebea_ironsight.stance_mod = {
                wpn_fps_smg_minebea = {translation = Vector3(-0.025, -7, -0.7)}
            }
        end)
    end

    if BeardLib.Utils:ModLoaded("Thermal Scope") then
        self.parts.wpn_fps_upg_o_thersig.stats = deep_clone(self.parts.wpn_fps_upg_o_aimpoint.stats)
    end

    if BeardLib.Utils:ModLoaded("Ghost Ring Sight") then
        self.parts.wpn_fps_upg_p226_o_ghostring.stats = deep_clone(nostats)
        local r870stocks = {"wpn_fps_shot_r870_s_folding", "wpn_fps_upg_m4_s_standard", "wpn_fps_upg_m4_s_pts", "wpn_fps_upg_m4_s_crane", "wpn_fps_upg_m4_s_mk46", "wpn_fps_upg_m4_s_ubr", "wpn_fps_snp_tti_s_vltor"}
        for a, stock in pairs(r870stocks) do
            self.parts[stock].forbids = self.parts[stock].forbids or {}
            table.insert(self.parts[stock].forbids, "wpn_fps_upg_870_o_ghostring")
            table.insert(self.parts[stock].forbids, "wpn_fps_upg_870_o_ghostring_short")
        end

        self.parts.wpn_fps_upg_870_o_ghostring.forbids = self.parts.wpn_fps_upg_870_o_ghostring.forbids or {}
        table.insert(self.parts.wpn_fps_upg_870_o_ghostring.forbids, "wpn_fps_ass_scar_o_flipups_up")
        self.parts.wpn_fps_upg_870_o_ghostring_short.forbids = self.parts.wpn_fps_upg_870_o_ghostring_short.forbids or {}
        table.insert(self.parts.wpn_fps_upg_870_o_ghostring_short.forbids, "wpn_fps_ass_scar_o_flipups_up")

        table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_upg_m37_o_ghostring")
        self.wpn_fps_shot_m37primary.adds = self.wpn_fps_shot_m37primary.adds or {}
        self.wpn_fps_shot_m37primary.adds.wpn_fps_upg_m37_o_ghostring = {"inf_sightdummy"}

    -- no worky
    --[[
    DelayedCalls:Add("ghostringdelay", delay, function(self, params)
        tweak_data.weapon.factory.parts.wpn_fps_upg_m37_o_ghostring.stance_mod.wpn_fps_shot_m37primary = {translation = Vector3(0, 0, -0.61)}
    end)
    --]]
    end

    if BeardLib.Utils:ModLoaded("HX25 Handheld Grenade Launcher") then
        self.parts.wpn_fps_gre_hx25_barrel.custom_stats = {}
        self.parts.wpn_fps_gre_hx25_barrel.stats = {
            value = 0,
            spread_multi = {2, 2},
            concealment = 0
        }
        -- default ammo
        self.parts.wpn_fps_gre_hx25_explosive_ammo.custom_stats = {
            ignore_statistic = true,
            damage_far_mul = 10,
            damage_near_mul = 10,
            bullet_class = "InstantExplosiveBulletBase",
            rays = 1,
            sdesc3 = nil,
            sdesc3_range_override = true,
            instant_multishot_per_1ammo = 7,
            instant_multishot_dmg_mul = 1/7,
            bullet_damage_fraction = 0.25
        }
        self.parts.wpn_fps_upg_hx25_buckshot_ammo.sound_switch = {suppressed = "infalt"}
        self.parts.wpn_fps_upg_hx25_buckshot_ammo.custom_stats = {rays = 20, sdesc1 = "caliber_ghx25buck", ammo_pickup_max_mul = 2}
        self.parts.wpn_fps_upg_hx25_buckshot_ammo.stats = {
            value = 0,
            spread = -20,
            concealment = 0
        }
        --[[
        self.parts.wpn_fps_upg_hx25_dragons_breath_ammo.custom_stats = {
            armor_piercing_add = 1,
            ammo_pickup_max_mul = 2,
            ignore_statistic = true,
            muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_dragons_breath",
            bullet_class = "FlameBulletBase",
            can_shoot_through_shield = true,
            rays = 12,
            fire_dot_data = {
                dot_trigger_chance = "100",
                dot_damage = "1.5",
                dot_length = "3.1",
                dot_trigger_max_distance = "1500",
                dot_tick_period = "0.5"
            },
            sdesc1 = "caliber_ghx25db",
            sdesc3 = "range_shotdb",
            sdesc3_range_override = true
        }
        
        self.parts.wpn_fps_upg_hx25_dragons_breath_ammo.sound_switch = {suppressed = "infalt"}
        self.parts.wpn_fps_upg_hx25_dragons_breath_ammo.stats = {
            value = 0,
            damage = -12,
            spread = -35,
            concealment = 0
        }
        ]]
        self.parts.wpn_fps_upg_hx25_sight_iron_il.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_hx25_sight_rmr.stats = {
            value = 0,
            concealment = -1
        }
    end

    if BeardLib.Utils:ModLoaded("Illuminated Iron Sight Pack") then
        self.parts.wpn_fps_upg_1911_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_b92fs_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_baka_tritium.stats = {value = 0, concealment = 0}
        --self.parts.wpn_fps_upg_colt_def_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_deagle_tritium.stats = {value = 0, concealment = 0}
        --self.parts.wpn_fps_upg_fs_tritium.stats = {value = 0, concealment = 0}
        --self.parts.wpn_fps_upg_g18c_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_g22c_tritium.stats = {value = 0, concealment = 0}
        --self.parts.wpn_fps_upg_g26_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_hs2000_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_sparrow_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_p226_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_pl14_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_usp_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_asval_nightsight.stats = {value = 0, concealment = 0}
        primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_akmsu_nightsight")
        primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_cz805_tritium")
        primarysmgadds_specific.wpn_fps_smg_schakalprimary = primarysmgadds_specific.wpn_fps_smg_schakalprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_upg_ump45_tritium")
        self.parts.wpn_fps_upg_asval_nightsight.forbids = {"inf_sightrail"}
        
        self.parts.wpn_fps_upg_beer_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_chinchilla_fiber.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_czech_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_shrew_tritium.stats = {value = 0, concealment = 0}
        self.parts.wpn_fps_upg_stech_tritium.stats = {value = 0, concealment = 0}
    end

    if BeardLib.Utils:ModLoaded("stock_attachment_pack") then
        primarysmgadds_specific.wpn_fps_smg_mp5primary = primarysmgadds_specific.wpn_fps_smg_mp5primary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_mp5primary, "wpn_fps_smg_mp5_s_folded")
        table.insert(primarysmgadds_specific.wpn_fps_smg_mp5primary, "wpn_fps_smg_mp5_s_adjusted")
        table.insert(primarysmgadds_specific.wpn_fps_smg_mp5primary, "wpn_fps_smg_mp5_s_nostock")
        primarysmgadds_specific.wpn_fps_smg_schakalprimary = primarysmgadds_specific.wpn_fps_smg_schakalprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_smg_schakal_s_nostock")
        primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_smg_hajk_s_nostock")
        table.insert(self.wpn_fps_smg_x_hajk.uses_parts, "wpn_fps_smg_hajk_s_nostock")
        primarysmgadds_specific.wpn_fps_smg_coalprimary = primarysmgadds_specific.wpn_fps_smg_coalprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_coalprimary, "wpn_fps_smg_coal_s_nostock")
        primarysmgadds_specific.wpn_fps_smg_olympicprimary = primarysmgadds_specific.wpn_fps_smg_olympicprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_smg_olympic_s_adjusted")

        self.parts.wpn_fps_ass_tecci_s_extended.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        self.parts.wpn_fps_smg_tec9_s_retrac2.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        self.parts.wpn_fps_smg_tec9_s_retrac1.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_m4_s_collapsed.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_upg_m4_s_pts_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_upg_m4_s_crane_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_upg_m4_s_mk46_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_upg_m4_s_ubr_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_smg_olympic_s_adjusted.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_ass_ak5_s_ak5c_ret.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_ass_tecci_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_shot_r870_s_unfolded.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_smg_mp9_s_folded.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_smg_cobray_s_folded.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_smg_coal_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_smg_mp7_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
        self.parts.wpn_fps_gre_slap_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)

        self.parts.wpn_upg_ak_s_collapsed.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.wpn_fps_ass_asval.override = self.wpn_fps_ass_asval.override or {}
        self.wpn_fps_ass_asval.override.wpn_upg_ak_s_collapsed = {adds = {"wpn_fps_ass_asval_g_standard"}}

        self.parts.wpn_upg_ak_s_folded_gold.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_upg_saiga_s_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_upg_ak_s_skfolded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_ak5_s_ak5a_col.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_ak5_s_ak5b_col.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_ak5_s_ak5c_col.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_m14_body_collapsed.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_smg_mp5_s_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_asval_s_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_lmg_m249_s_retracted.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_smg_cobray_s_nostock.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_galil_s_sta_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_galil_s_fab_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_galil_s_light_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_galil_s_plastic_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_galil_s_skeletal_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_galil_s_sniper_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_ass_galil_s_wood_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
        self.parts.wpn_fps_smg_schakal_s_nostock.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)

        self.parts.wpn_fps_ass_g3_s_nostock.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
        self.parts.wpn_fps_smg_mp5_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_smg_uzi_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_smg_polymer_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_ass_fal_s_folded.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_snp_winchester_s_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_snp_r93_body_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_snp_msr_body_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_snp_model70_s_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_lmg_mg42_reciever_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_lmg_hk21_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_smg_hajk_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
        self.parts.wpn_fps_smg_mp5_s_adjusted.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)

        self.parts.wpn_fps_sho_ben_s_nostock.stats = {
            value = 0,
            recoil = -9,
            concealment = 3
        }

        self.wpn_fps_smg_x_mp5.override.wpn_fps_smg_mp5_s_folded = {
            stats = {
                value = 0,
                recoil = 3,
                concealment = -1
            }
        }
        self.wpn_fps_smg_x_mp5.override.wpn_fps_smg_mp5_s_adjusted = {stats = deep_clone(nostats)}
        self.wpn_fps_smg_x_mp5.override.wpn_fps_smg_mp5_s_nostock = {stats = deep_clone(nostats)}
    end

    if BeardLib.Utils:ModLoaded("amt") then
        self.parts.wpn_fps_upg_amt_visionking.stats = {
            value = 0,
            zoom = 7,
            concealment = -3
        }
        self.parts.wpn_fps_pis_amt_g_smooth.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_amt_g_rosewood.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_amt_b_long.stats = deep_clone(barrel_m2)
        self.parts.wpn_fps_pis_amt_m_short.stats = deep_clone(mag_150)
        self.parts.wpn_fps_pis_amt_m_short.stats.extra_ammo = 4
    end

    if BeardLib.Utils:ModLoaded("Vanilla Styled Weapon Mods") and self.parts.wpn_fps_pis_lebman_body_classic then
        self.parts.wpn_fps_ass_flint_b_short.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_ass_flint_b_long.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_ass_flint_m_long.stats = deep_clone(mag_133)
        self.parts.wpn_fps_ass_flint_m_long.stats.extra_ammo = 10
        self.parts.wpn_fps_ass_flint_g_custom.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_flint_s_solid.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_contraband_b_long.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_ass_contraband_s_tecci.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }

        -- the barrel just floats lmao
        self.parts.wpn_fps_smg_shepheard_body_long.stats = deep_clone(barrel_m2)
        if not table.contains(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_smg_shepheard_body_long") then
            table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_smg_shepheard_body_long")
            table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_smg_shepheard_fg_long")
        end

        self.parts.wpn_fps_ass_komodo_b_long.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_lmg_shuno_b_long.custom_stats = {spin_up_time_mult = 0.60/0.40}
        self.parts.wpn_fps_lmg_shuno_b_long.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_pis_lemming_b_long.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_pis_lemming_body_silver.stats = deep_clone(nostats)

        self.parts.wpn_fps_snp_siltstone_b_short.stats = deep_clone(barrel_p2)

        self.parts.wpn_fps_pis_breech_g_stealth.stats = deep_clone(nostats)

        self.parts.wpn_fps_snp_winchester_b_short.stats = deep_clone(barrel_p2)

        self.parts.wpn_fps_pis_c96_b_short.stats = deep_clone(barrel_p1)

        self.parts.wpn_fps_pis_packrat_sl_silver.stats = deep_clone(nostats)

        self.parts.wpn_fps_smg_cobray_m_extended.stats = deep_clone(mag_125)
        self.parts.wpn_fps_smg_cobray_m_extended.stats.extra_ammo = 8
        self.parts.wpn_fps_smg_cobray_m_extended_akimbo.stats = deep_clone(mag_125)
        self.parts.wpn_fps_smg_cobray_m_extended_akimbo.stats.extra_ammo = 16

        self.parts.wpn_fps_ass_scar_m_extended.stats = deep_clone(mag_150)
        self.parts.wpn_fps_ass_scar_m_extended.stats.extra_ammo = 10

        self.parts.wpn_fps_snp_tti_b_long.stats = deep_clone(barrel_m1)

        self.parts.wpn_fps_ass_corgi_b_medium.stats = deep_clone(barrel_p1)

        self.parts.wpn_fps_pis_g18c_b_long.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_tecci_s_minicontra.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_tecci_vg_ergo.stats = deep_clone(nostats)

        self.parts.wpn_fps_shot_shorty_fg_rail.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_ak_m_proto.stats = deep_clone(nostats)

        self.parts.wpn_fps_shot_m37_o_expert.stats = deep_clone(nostats)
        table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_o_expert")
        self.parts.wpn_fps_shot_m37_o_expert.stance_mod.wpn_fps_shot_m37primary = deep_clone(self.parts.wpn_fps_shot_m37_o_expert.stance_mod.wpn_fps_shot_m37)

        self.parts.wpn_fps_sho_b_spas12_small.stats = deep_clone(barrelsho_p2)
        self.parts.wpn_fps_smg_uzi_b_carbine.stats = deep_clone(barrel_m2)
        self.parts.wpn_fps_pis_g17_b_bling.stats = deep_clone(nostats)

        -- Reinbeck foregrip/pumps
        self.parts.wpn_fps_shot_beck_pump_custom.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_beck_pump_swat.stats = { value = 1, concealment = -1 }

        -- SGS parts
        -- Sniper stock
        self.parts.wpn_fps_snp_sgs_s_sniper.stats = deep_clone(nostats)
        -- Marksman grip
        self.parts.wpn_fps_snp_sgs_g_black.stats = deep_clone(nostats)
        -- Scout Foregrip
        self.parts.wpn_fps_snp_sgs_fg_rail.stats = deep_clone(nostats)
        -- Extended Barrel
        self.parts.wpn_fps_snp_sgs_b_long.stats = deep_clone(barrel_m1)
        -- Silenced Barrel
        self.parts.wpn_fps_snp_sgs_b_sil.stats = deep_clone(silstatssnp)

        -- ACAR-9 parts
        -- Extended mags
        self.parts.wpn_fps_smg_car9_m_extended.stats.extra_ammo = 5
        self.parts.wpn_fps_smg_car9_m_extended_akimbo.stats.extra_ammo = 10 -- Isn't this what overrides are for?
        -- Steel Barrel
        self.parts.wpn_fps_smg_car9_b_long.stats = deep_clone(barrel_m1)
        -- Hush foregrip
        self.parts.wpn_fps_smg_car9_fg_rail.stats = deep_clone(nostats)

        -- Dragon 5.45 parts
        -- Discreet Foregrip
        self.parts.wpn_fps_pis_smolak_fg_polymer.stats = deep_clone(nostats)

        -- Add Ivans Legacy
        table.insert(self.wpn_fps_pis_smolak.uses_parts, "inf_ivan")

        -- Lebman/Crosskill auto parts
        -- Room broom kit
        self.parts.wpn_fps_pis_lebman_body_classic.stats = deep_clone(nostats)
        -- Chrome slides
        self.parts.wpn_fps_pis_lebman_b_chrome.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_lebman_b_chrome_akimbo.stats = deep_clone(nostats)
        -- Giant stock lmao
        self.parts.wpn_fps_pis_lebman_stock.stats = {
            value = 0,
            spread = 5,
            recoil = 2,
            reload = -10,
            concealment = -2
        }
        -- Crosskill classic grip
        self.parts.wpn_fps_pis_1911_g_classic.stats = deep_clone(nostats)
        -- Wooden grip
        self.parts.wpn_fps_pis_cold_g_wood.stats = deep_clone(nostats)
        -- Crosskill classic sneaky frame
        self.parts.wpn_fps_pis_cold_body_custom.stats = deep_clone(nostats)
        -- Crosskill classic extended mag
        self.parts.wpn_fps_pis_cold_m_extended.stats = {
            extra_ammo = 5,
            concealment = -2
        }
        self.parts.wpn_fps_pis_x_cold_m_extended.stats = {
            extra_ammo = 10,
            concealment = -2
        }

        -- AMR-12 parts
        -- Enforcer foregrip
        self.parts.wpn_fps_shot_amr12_fg_railed.stats = deep_clone(nostats)
        -- Breacher Foregrip
        self.parts.wpn_fps_shot_amr12_fg_short.stats = deep_clone(barrelsho_p2)

        -- Reinbeck M1 Parts
        -- Classic Heat Barrel
        self.parts.wpn_fps_shot_beck_b_heat_dummy.stats = deep_clone(nostats)
        -- Trench Sweeper Nozzle
        self.parts.wpn_fps_upg_ns_shot_grinder.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        -- Enforcer stock
        self.parts.wpn_fps_shot_beck_s_tac.stats = deep_clone(nostats)
        -- Ghost stock
        self.parts.wpn_fps_shot_beck_s_wrist.stats = {
            value = 0,
            concealment = 2,
            recoil = -2
        }
        -- Shell rack
        self.parts.wpn_fps_shot_beck_shells.stats = {
            value = 0,
            reload = 5,
            concealment = -1
        }

        -- Valkyrie Stock
        self.parts.wpn_fps_ass_m16_s_op.stats = deep_clone(nostats)
        -- Ratnik Stock
        self.parts.wpn_fps_ass_m4_s_russian.stats = deep_clone(nostats)
        -- Sport Grip
        self.parts.wpn_fps_ass_m4_g_fancy.stats = deep_clone(nostats)
        -- Schafer Grip
        self.parts.wpn_fps_ass_m4_g_sg.stats = deep_clone(nostats)
        -- Heavy Compensator
        self.parts.wpn_fps_upg_ns_ass_smg_heavy.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
        -- Grievky Nozzle
        self.parts.wpn_fps_upg_ns_ass_smg_russian.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats)
        -- Fugitive Foregrip
        self.parts.wpn_fps_ass_amcar_fg_covers_base.stats = deep_clone(nostats)
        -- Cylinder Foregrip
        self.parts.wpn_fps_ass_amcar_fg_cylinder.stats = deep_clone(nostats)
        -- HeistEye Gadget
        self.parts.wpn_fps_upg_fl_ass_smg_sho_marker.stats = { concealment = -1 }
        -- AK titanium grip
        self.parts.wpn_upg_ak_g_titanium.stats = deep_clone(nostats)
        -- AK Speedpull Mag
        self.parts.wpn_fps_pis_smolak_m_custom.stats = deep_clone(nostats)
        -- Smooth AK Cover
        self.parts.wpn_fps_sho_saiga_upper_receiver_smooth.stats = deep_clone(nostats)
        -- Low profile pistol compensator
        self.parts.wpn_fps_upg_pis_ns_edge.stats = {
            value = 0,
            spread = 2,
            recoil = 1,
            concealment = -1
        }
        -- HS covert frame
        self.parts.wpn_fps_pis_hs2000_body_stealth.stats = deep_clone(nostats)

        -- Theia micro sight
        self.parts.wpn_fps_upg_o_cqb.stats = {
            value = 0,
            concealment = -1
        }

        -- Continental Mag
        self.parts.wpn_fps_ass_m4_m_wick.stats = deep_clone(mag_66)
        self.parts.wpn_fps_ass_m4_m_wick.stats.extra_ammo = -10

        -- M308 classic body
        self.parts.wpn_fps_ass_m14_body_old.stats = deep_clone(nostats)

        -- SG-416 long barrel
        self.parts.wpn_fps_ass_sg416_b_long.stats = deep_clone(barrel_m1)

        -- Charging handle
        self.parts.wpn_fps_ass_sg416_dh_custom.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_sg416_fg_custom.stats = deep_clone(nostats)

        -- Pistol mag
        -- Wait what the fuck are you doing?
        self:convert_part("wpn_fps_ass_m4_m_stick", "lrifle", "lightpis")
        self.parts.wpn_fps_ass_m4_m_stick.stats.total_ammo_mod = nil
        self.parts.wpn_fps_ass_m4_m_stick.stats.spread = 0
        self.parts.wpn_fps_ass_m4_m_stick.custom_stats.sdesc1 = "caliber_p9x19"

        self:convert_part("wpn_fps_ass_m4_m_stick_heavy", "lrifle", "mediumpis")
        self.parts.wpn_fps_ass_m4_m_stick_heavy.custom_stats.sdesc1 = "caliber_p9x19"

        self:convert_part("wpn_fps_ass_m4_m_stick_sg", "lrifle", "lightpis")
        self.parts.wpn_fps_ass_m4_m_stick_sg.stats.total_ammo_mod = nil
        self.parts.wpn_fps_ass_m4_m_stick_sg.stats.spread = 0
        self.parts.wpn_fps_ass_m4_m_stick_sg.custom_stats.sdesc1 = "caliber_p9x19"

        self:convert_part("wpn_fps_ass_m4_m_stick_amcar", "lrifle", "lightpis")
        self.parts.wpn_fps_ass_m4_m_stick_amcar.stats.total_ammo_mod = nil
        self.parts.wpn_fps_ass_m4_m_stick_amcar.stats.spread = 0
        self.parts.wpn_fps_ass_m4_m_stick_amcar.custom_stats.sdesc1 = "caliber_p9x19"
    end

    -- Vanilla styled modpack 2
    if BeardLib.Utils:ModLoaded("Vanilla Styled Weapon Mods Volume 2") and self.parts.wpn_fps_shot_minibeck_shells then
        self.parts.wpn_fps_shot_minibeck_shells.stats = {
            value = 0,
            reload = 5,
            concealment = -1
        }
        self.parts.wpn_fps_upg_ns_ass_smg_pro.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_upg_ns_ass_smg_pro.custom_stats = silencercustomstats

        -- M60 long barrel
        self.parts.wpn_fps_lmg_m60_b_longer.stats = deep_clone(barrel_m1)

        -- R700 ironsights
        self.parts.wpn_fps_snp_r700_o_is.stats = {
            value = 1,
            concealment = 3
        }

        -- R700 wood
        self.parts.wpn_fps_snp_r700_s_redwood.stats = deep_clone(nostats)

        -- Uzi barrel
        self.parts.wpn_fps_smg_uzi_b_longue.stats = deep_clone(barrel_m2)

        -- B93R expert slide
        self.parts.wpn_fps_pis_beer_sl_expert.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("Zenith 10mm") then
        self.parts.wpn_fps_upg_zenith_ammo_ap.custom_stats = {sdesc1 = "caliber_p10hr", pen_shield_dmg_mult = 0.20/0.25, ammo_pickup_min_mul = 0.50, ammo_pickup_max_mul = 0.50, can_shoot_through_shield = true, can_shoot_through_wall = true}
        self.parts.wpn_fps_upg_zenith_ammo_ap.internal_part = true
        self.parts.wpn_fps_upg_zenith_ammo_ap.stats = {
            value = 0,
            total_ammo_mod = -500,
            concealment = 0
        }
        self.parts.wpn_fps_upg_zenith_mag_ext.stats = deep_clone(mag_150)
        self.parts.wpn_fps_upg_zenith_mag_ext.stats.extra_ammo = 4
        self.parts.wpn_fps_upg_zenith_supp.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_upg_zenith_compact_laser.desc_id = "bm_wp_wpn_fps_upg_zenith_compact_laser_desc"
    end

    if BeardLib.Utils:ModLoaded("Widowmaker TX") then
        self.parts.wpn_fps_shot_wmtx_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_wmtx_ammo_minishell.custom_stats = {sdesc1 = "caliber_s12dx", rays = 6, ammo_pickup_min_mul = 1.50, ammo_pickup_max_mul = 1.50}
        self.parts.wpn_fps_upg_wmtx_ammo_minishell.stats = {
            value = 0,
            extra_ammo = 4,
            total_ammo_mod = 500,
            damage = -10,
            recoil = 15,
            concealment = 0
        }

        self.parts.wpn_fps_upg_wmtx_gastube_burst.custom_stats = {has_burst_fire = true, burst_size = 2}
        self.parts.wpn_fps_upg_wmtx_gastube_burst.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_wmtx_heatshield.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_wmtx_ns_firebull.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("DP12 Shotgun") then
        self.parts.wpn_fps_sho_dp12_o_standard.stance_mod = {wpn_fps_sho_dp12 = {translation = Vector3(0, 0, -0.3)}}
        self.parts.wpn_fps_sho_dp12_ns_breacher.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)

        self.parts.wpn_fps_sho_dp12_fg_novg.custom_stats = {set_reload_stance_mod = {ads = {translation = Vector3(15, -20, 0), rotation = Rotation(0, 0, 0)}}}
        self.parts.wpn_fps_sho_dp12_fg_novg.stance_mod = {wpn_fps_sho_dp12 = {translation = Vector3(0, 0, -1.4)}}
        self.parts.wpn_fps_sho_dp12_fg_novg.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_sho_dp12_fg_novg_rail.custom_stats = {set_reload_stance_mod = {ads = {translation = Vector3(15, -20, 0), rotation = Rotation(0, 0, 0)}}}
        self.parts.wpn_fps_sho_dp12_fg_novg_rail.stance_mod = {wpn_fps_sho_dp12 = {translation = Vector3(0, 0, -1.4)}}
        self.parts.wpn_fps_sho_dp12_fg_novg_rail.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_sho_dp12_m_ext.stats = {
            value = 0,
            extra_ammo = 2,
            concealment = -1
        }
        self.parts.wpn_fps_sho_dp12_b_ext.stats = deep_clone(barrelsho_m1)

        DelayedCalls:Add("dp12delay", delay, function(self, params)
            -- clear double-firing overrides, the barrels can be fired separately now
            tweak_data.weapon.factory.wpn_fps_sho_dp12.override = {}
        end)
    end

    if BeardLib.Utils:ModLoaded("ELCAN SpecterDR with Docter Sight") then
        self.parts.wpn_fps_upg_o_su230_docter.customsight = true
        self.parts.wpn_fps_upg_o_su230_docter.stats = {
            value = 0,
            zoom = 5,
            concealment = -3
        }
        --self.parts.wpn_fps_upg_o_su230_docter_switch.type = "gadget" -- game needs this so it doesn't apply the second sight's data to the ADS by default
        self.parts.wpn_fps_upg_o_su230_docter_switch.stats = {
            value = 0,
            gadget_zoom = 1,
            concealment = 0,
        }

        -- is this hair loss
        DelayedCalls:Add("specdoc_grayingmyhair", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_upg_o_su230_docter.stance_mod.wpn_fps_ass_mk18s = {translation = Vector3(0, -12, -1.3)}
            tweak_data.weapon.factory.parts.wpn_fps_upg_o_su230_docter_switch.stance_mod.wpn_fps_ass_mk18s = {translation = Vector3(0, -18, -5.3)}
        end)
    end

    if BeardLib.Utils:ModLoaded("gsup") then
        -- pistol sils
        self.parts.wpn_fps_ass_ns_g_sup1.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup1.stats = deep_clone(silstatsconc2) --3

        self.parts.wpn_fps_ass_ns_g_sup2.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup2.stats = deep_clone(silstatsconc1)

        -- rifle sils
        self.parts.wpn_fps_ass_ns_g_sup3.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup3.stats = deep_clone(silstatsconc2)

        self.parts.wpn_fps_ass_ns_g_sup4.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup4.stats = deep_clone(silstatsconc2)

        self.parts.wpn_fps_ass_ns_g_sup5.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup5.stats = deep_clone(silstatsconc1) --

        -- pistol sil
        self.parts.wpn_fps_ass_ns_g_sup6.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup6.stats = deep_clone(silstatsconc2) --

        -- model 70
        self.parts.wpn_fps_ass_ns_g_sup7.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup7.stats = deep_clone(silstatssnp)

        -- pistol sil
        self.parts.wpn_fps_ass_ns_g_sup8.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ns_g_sup8.stats = deep_clone(silstatsconc2) --

        table.insert(primarysmgadds, "wpn_fps_ass_ns_g_sup3")
        table.insert(primarysmgadds, "wpn_fps_ass_ns_g_sup4")
        table.insert(primarysmgadds, "wpn_fps_ass_ns_g_sup5")
    end

    if BeardLib.Utils:ModLoaded("Lost Gadgets Pack") then
        self.parts.wpn_fps_upg_fl_anpeq2.desc_id = "bm_wp_wpn_fps_upg_fl_anpeq2_desc"
        self.parts.wpn_fps_upg_fl_anpeq2.stats = {
            value = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_fl_dbal_d2.desc_id = "bm_wp_wpn_fps_upg_fl_dbal_d2_desc"
        self.parts.wpn_fps_upg_fl_dbal_d2.stats = {
            value = 0,
            concealment = -2
        }
        self.parts.wpn_fps_upg_fl_m600p.desc_id = "bm_wp_wpn_fps_upg_fl_m600p_desc"
        self.parts.wpn_fps_upg_fl_m600p.stats = {
            value = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_fl_utg.desc_id = "bm_wp_wpn_fps_upg_fl_utg_desc"
        self.parts.wpn_fps_upg_fl_utg.stats = {
            value = 0,
            concealment = 0
        }

        self.parts.wpn_fps_upg_fl_unimax.desc_id = "bm_wp_wpn_fps_upg_fl_unimax_desc"
        self.parts.wpn_fps_upg_fl_unimax.stats = {
            value = 0,
            concealment = 0
        }
        -- every one of these part names just blends into the next and on top of that they recycle existing descriptions
        self.parts.wpn_fps_upg_fl_pis_inforce_apl.desc_id = "bm_wp_wpn_fps_upg_fl_pis_inforce_apl_desc"
        self.parts.wpn_fps_upg_fl_pis_inforce_apl.stats = {
            value = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_fl_pis_unimax.desc_id = "bm_wp_wpn_fps_upg_fl_pis_unimax_desc"
        self.parts.wpn_fps_upg_fl_pis_unimax.stats = {
            value = 0,
            concealment = 0
        }
        self.parts.wpn_fps_upg_fl_pis_utg.desc_id = "bm_wp_wpn_fps_upg_fl_utg_desc"
        self.parts.wpn_fps_upg_fl_pis_utg.stats = {
            value = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_fl_unimax_inforce.desc_id = "bm_wp_wpn_fps_upg_fl_unimax_inforce_desc"
        self.parts.wpn_fps_upg_fl_unimax_inforce.stats = {
            value = 0,
            concealment = -1
        }
    end

    if BeardLib.Utils:ModLoaded("Heavy Metal Muzzle Device Pack") then
        self.parts.wpn_fps_upg_ns_ass_mb556k.stats = deep_clone(self.parts.wpn_fps_upg_ass_ns_surefire.stats)
        self.parts.wpn_fps_upg_ns_ass_tbrake.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
        self.parts.wpn_fps_upg_ns_ass_vortex.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)
        table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_mb556k")
        table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_tbrake")
        table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_vortex")

        self.parts.wpn_fps_upg_ns_pis_aek919.stats = deep_clone(self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats)
        self.parts.wpn_fps_upg_ns_pis_tact_flash.stats = deep_clone(self.parts.wpn_fps_upg_pis_ns_flash.stats)
        self.parts.wpn_fps_upg_ns_pis_yhm.stats = deep_clone(self.parts.wpn_fps_upg_ns_pis_meatgrinder.stats)
        self.parts.wpn_fps_upg_ns_pis_major.stats = deep_clone(self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats)

        self.parts.wpn_fps_upg_ns_shot_gk_01.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
        self.parts.wpn_fps_upg_ns_shot_nomad.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
    end

    if BeardLib.Utils:ModLoaded("Magpul Attachments Pack - AK") then
        self.parts.wpn_fps_upg_fg_ak_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g_ak_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_s_ak_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ak_m_pmag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ak556_m_pmag.stats = deep_clone(nostats)

        primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_g_ak_moe")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_s_ak_moe")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_ak_m_pmag")
    end

    if BeardLib.Utils:ModLoaded("Magpul Attachments Pack - M4") then
        self.parts.wpn_fps_upg_fg_moe2.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g_m4_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_s_m4_sl_c.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.wpn_fps_smg_mac10.override.wpn_fps_upg_s_m4_sl_c = {stats = deep_clone(nostats)}
        self.parts.wpn_fps_upg_m4_m_pmag40.stats = deep_clone(mag_125)
        self.parts.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = 10
        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40 = {
            stats = deep_clone(mag_200)
        }
        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = 20
        self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag40 = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40.stats)
        }
        self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag40 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40)
        self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo * 2
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag40 = {}
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag40.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_pmag40.stats)
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = 20
        self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag40 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40)
        self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag40 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40)

        primarysmgadds_specific.wpn_fps_smg_olympicprimary = primarysmgadds_specific.wpn_fps_smg_olympicprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_g_m4_moe")
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_sl_c")
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag40")
        primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_pts")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_sl_c")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag40")

        -- add VAL grip or you'll be holding onto air
    --[[
        self.wpn_fps_ass_asval.override = self.wpn_fps_ass_asval.override or {}
        self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_pts = {adds = {"wpn_fps_ass_asval_g_standard"}}
        self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_sl = {adds = {"wpn_fps_ass_asval_g_standard"}}
        self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_sl_c = {adds = {"wpn_fps_ass_asval_g_standard"}}
        self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_pts_c = {adds = {"wpn_fps_ass_asval_g_standard"}}
    --]]
    end

    if BeardLib.Utils:ModLoaded("Magpul Attachments Pack - Universal") then
        self.parts.wpn_fps_upg_fg_moe2_short.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_s_m4_ubr.stats = deep_clone(nostats)
        primarysmgadds_specific.wpn_fps_smg_olympicprimary = primarysmgadds_specific.wpn_fps_smg_olympicprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_ubr")
        --
        self.parts.wpn_fps_upg_s_m4_prs.stats = {
            value = 0,
            spread = 5,
            recoil = 5,
            reload = -10,
            concealment = -2
        }
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_prs")
        --
        self.parts.wpn_fps_upg_s_m4_pts.stats = deep_clone(nostats)
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_pts")
        primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_pts")
        --
        self.parts.wpn_fps_upg_s_m4_sl.stats = deep_clone(nostats)
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_sl")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_sl")
        self.parts.wpn_fps_upg_s_m4_pts_c.stats = { 
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.wpn_fps_smg_mac10.override.wpn_fps_upg_s_m4_sl_c = {stats = deep_clone(nostats)}
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_pts_c")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_pts_c")
        --
        self.parts.wpn_fps_upg_m4_m_pmagsolid.stats = deep_clone(nostats)
        self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmagsolid = {
            stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
        }
        self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmagsolid = {
            stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
        }
        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmagsolid = {
            stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
        }
        self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmagsolid = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmagsolid.stats)
        }
        self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmagsolid = deep_clone(self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std)
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmagsolid")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmagsolid")
        --
        self.parts.wpn_fps_upg_m4_m_pmag10.stats = deep_clone(mag_33)
        self.parts.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = 8

        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10 = {
            stats = deep_clone(mag_50)
        }
        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = -10
        self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag10 = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10.stats)
        }
        self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag10 = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10.stats)
        }
        self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = -20
        self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag10 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10)
        self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag10 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10)
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmagsolid")
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag10")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmagsolid")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag10")
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag10 = {}
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag10.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_pmag10.stats)
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = -40
        --
        self.parts.wpn_fps_upg_m4_m_pmag20.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)
        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20 = {
            stats = deep_clone(nostats)
        }
        self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag20 = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20.stats)
        }
        self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag20 = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20.stats)
        }
        self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
        self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag20 = {}
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag20.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_pmag20.stats)
        self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag20.stats.extra_ammo = -20
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag20")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag20")
        --
    --[[
        self.parts.wpn_fps_upg_m4_m_pmag3.stats = deep_clone(nostats)
        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3 = {
            stats = self.parts.wpn_fps_m4_uupg_m_std.stats
        }
        self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag3 = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3.stats)
        }
        self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag3 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3)
        self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag3 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3)
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag3")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag3")
    --]]
        --
        self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20 = {
            stats = deep_clone(nostats)
        }
        self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag20 = {
            stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20.stats)
        }
        self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
        self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
        table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag20")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag20")
    end

    if BeardLib.Utils:ModLoaded("Lahti L-35") then
        self.parts.wpn_fps_upg_l35_barrel_long.stats = {
            value = 0,
            spread = 5,
            concealment = -1
        }
        self.parts.wpn_fps_upg_l35_grip_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_l35_grip_wood_window.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_l35_mag_drum.stats = deep_clone(mag_300)
        self.parts.wpn_fps_upg_l35_mag_drum.stats.extra_ammo = 24
        self.parts.wpn_fps_upg_l35_mag_drum.stats.spread = -20

        self.parts.wpn_fps_upg_l35_mag_ext.stats = deep_clone(mag_150)
        self.parts.wpn_fps_upg_l35_mag_ext.stats.extra_ammo = 4

        self.parts.wpn_fps_upg_l35_mag_long.stats = deep_clone(mag_200)
        self.parts.wpn_fps_upg_l35_mag_long.stats.extra_ammo = 8
    end

    if BeardLib.Utils:ModLoaded("OTs-14-4A Groza") then
        self.parts.wpn_fps_ass_ots_14_4a_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ots_14_4a_supp.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_upg_ots_14_4a_supp_b.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_upg_ots_14_4a_supp_b.stats.spread = 0
        self.parts.wpn_fps_upg_ots_14_4a_supp_b.stats.concealment = -1

        table.insert(self.wpn_fps_ass_ots_14_4a.uses_parts, "inf_groza_762")
        table.insert(self.wpn_fps_ass_ots_14_4a.uses_parts, "inf_groza_545")
        table.insert(self.wpn_fps_ass_ots_14_4a.uses_parts, "inf_groza_556")
        self.parts.inf_groza_762.unit = self.parts.wpn_upg_ak_m_akm.unit
        self.parts.inf_groza_762.third_unit = self.parts.wpn_upg_ak_m_akm.third_unit
        self.parts.inf_groza_762.custom_stats = {sdesc1 = "caliber_r762x39"}
        self.parts.inf_groza_762.stats = deep_clone(mag_150)
        self.parts.inf_groza_762.stats.extra_ammo = 10

        self.parts.inf_groza_545.unit = self.parts.wpn_fps_ass_74_m_standard.unit
        self.parts.inf_groza_545.third_unit = self.parts.wpn_fps_ass_74_m_standard.third_unit
        self:convert_part("inf_groza_545", "mrifle", "lrifle")
        self.parts.inf_groza_545.custom_stats.sdesc1 = "caliber_r545x39"
        self.parts.inf_groza_545.stats.extra_ammo = 10
        self.parts.inf_groza_545.stats.reload = mag_150.reload
        self.parts.inf_groza_545.stats.concealment = mag_150.concealment

        self.parts.inf_groza_556.unit = self.parts.wpn_fps_m4_uupg_m_std_vanilla.unit
        self.parts.inf_groza_556.third_unit = self.parts.wpn_fps_m4_uupg_m_std_vanilla.third_unit
        self:convert_part("inf_groza_556", "mrifle", "lrifle")
        self.parts.inf_groza_556.custom_stats.sdesc1 = "caliber_r556x45"
        self.parts.inf_groza_556.stats.extra_ammo = 10
        self.parts.inf_groza_556.stats.reload = mag_150.reload
        self.parts.inf_groza_556.stats.concealment = mag_150.concealment
    end

    if BeardLib.Utils:ModLoaded("M16A1 Wooden Furniture") then
        self.parts.wpn_fps_ass_m16_fg_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_m16_s_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_m16_g_wood.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("MK18 Specialist") then
        self.parts.wpn_fps_ass_mk18s_fg_black.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_mk18s_grip_black.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_mk18s_tacstock.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_mk18s_vg_ptk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_mk18s_carry.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_mk18s_mag_speed.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_mk18s_mag_big.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_quad.stats)
        self.parts.wpn_fps_ass_mk18s_mag_smol.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)

        self.parts.wpn_fps_ass_mk18s_a_weak.custom_stats = {sdesc1 = "caliber_r556x45m193"}
        self.parts.wpn_fps_ass_mk18s_a_weak.stats = deep_clone(nostats)

        self:convert_part("wpn_fps_ass_mk18s_a_classic", "lrifle", "mrifle")
        self.parts.wpn_fps_ass_mk18s_a_classic.custom_stats.sdesc1 = "caliber_r556x45mk262"

        self:convert_part("wpn_fps_ass_mk18s_a_strong", "lrifle", "mrifle")
        self.parts.wpn_fps_ass_mk18s_a_strong.custom_stats.sdesc1 = "caliber_r556x45m855"

        self:convert_part("wpn_fps_ass_mk18s_a_dmr", "lrifle", "hrifle")
        self.parts.wpn_fps_ass_mk18s_a_dmr.custom_stats.sdesc1 = "caliber_r556x45mk318"

        table.insert(self.wpn_fps_ass_mk18s.uses_parts, "inf_mk18_nomagwelldevice")
    end

    if BeardLib.Utils:ModLoaded("Lewis Gun") then
        self.parts.wpn_fps_upg_lewis_bolt_aa.stats = {
            value = 0,
            spread = -5,
            concealment = 0
        }
        --self.wpn_fps_lmg_lewis.override.inf_bipod_part = {a_obj = "a_b"}
        self.parts.wpn_fps_upg_lewis_bipod.custom_stats = {recoil_horizontal_mult = 2}
    --[[
        self.parts.wpn_fps_upg_lewis_bipod.animations = nil -- don't have improvedbipods crash the game thx
        self.parts.wpn_fps_upg_lewis_bipod.perks = nil
        -- 
        self.parts.wpn_fps_upg_lewis_bipod.adds = {"inf_bipod_part"}
    --]]
        self.parts.wpn_fps_upg_lewis_handle.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_lewis_sight_zf12.stats = deep_clone(self.parts.wpn_fps_upg_o_specter.stats)
        self.parts.wpn_fps_upg_lewis_stock_aa.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
    end

    if BeardLib.Utils:ModLoaded("HK416") then
        self.parts.wpn_fps_ass_hk416_bolt.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_hk416_grip_magpul_miad.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_hk416_grip_magpul_moe.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_hk416_grip_vindicator.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_hk416_mag_pull_assist.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_hk416_sights_frontfold.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_hk416_barrel_long.stats = {
            value = 0,
            spread = 5,
            concealment = -1
        }
        self.parts.wpn_fps_upg_hk416_handguard_long.stats = {
            value = 0,
            spread = 5,
            concealment = -1
        }
        self.parts.wpn_fps_upg_hk416_barrel_short.stats = {
            value = 0,
            spread = -5,
            concealment = 1
        }
        self.parts.wpn_fps_upg_hk416_handguard_c.stats = {
            value = 0,
            spread = -5,
            concealment = 1
        }
        self.parts.wpn_fps_upg_hk416_stock_hk416c.stats = deep_clone(self.parts.wpn_fps_m4_uupg_s_fold.stats)
        self.parts.wpn_fps_upg_hk416_stock_hk416c_collapsed.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }

        -- New handguards
        self.parts.wpn_fps_upg_hk416_handguard_elite.stats = {
            value = 0,
            recoil = -1,
            concealment = 1
        }
        self.parts.wpn_fps_upg_hk416_handguard_hera_irs.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_hk416_handguard_smr.stats = {
            value = 0,
            spread = 1,
            concealment = -1
        }
        self.parts.wpn_fps_upg_hk416_handguard_smrlong.stats = {
            value = 0,
            spread = 2,
            concealment = -2
        }
        self.parts.wpn_fps_upg_hk416_handguard_troyalpha.stats = {
            recoil = 1,
            concealment = -1
        }

        -- New stocks
        self.parts.wpn_fps_upg_hk416_stock_e1.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_hk416_stock_slimline.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("HK416C Standalone") then
        self.parts.wpn_fps_upg_drongo_s_orig.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_drongo_s_compact.stats = deep_clone(self.parts.wpn_fps_m4_uupg_s_fold.stats)
        self.parts.wpn_fps_ass_drongo_lower.stance_mod = {
            wpn_fps_ass_drongo = {translation = Vector3(-0.07, -7, -1.17)}
        }

        -- taking the nuclear option
        Hooks:RemovePostHook("drongo_boneless_Init")
        self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_aimpoint.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_aimpoint_2.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_docter.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_eotech.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_t1micro.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_cmore.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_cs.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_eotech_xps.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_reflex.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_rx01.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_rx30.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_spot.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.drongo = deep_clone(self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.wpn_fps_ass_m4)
        self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_ass_m4)
    end

    if BeardLib.Utils:ModLoaded("HK417 Standalone") then
        self.parts.wpn_fps_upg_recce_s_orig.stats = deep_clone(nostats)

        table.insert(self.wpn_fps_ass_recce.uses_parts, "inf_hk417_dmr")
        self:convert_part("inf_hk417_dmr", "hrifle", "ldmr", nil, nil, 600, nil)
        self.parts.inf_hk417_dmr.custom_stats.sdesc1 = "caliber_r762x51dm151"
        self.parts.inf_hk417_dmr.perks = {"fire_mode_single"}
        self.parts.inf_hk417_dmr.stats.reload = -20
    end

    if BeardLib.Utils:ModLoaded("acwr") then
        self.parts.wpn_fps_ass_acwr_expert.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_acwr_mag_pmag.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_acwr_covers.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_acwr_mag_smol.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)
        self.parts.wpn_fps_ass_acwr_b_short.stats = deep_clone(barrel_p2)

        self.parts.wpn_fps_ass_acwr_gl_fire.custom_stats = {sdesc3 = "misc_gl40x46mmIC"}
    end

    if BeardLib.Utils:ModLoaded("SAI GRY") then
        self.parts.wpn_fps_upg_saigry_mag_pmag.stats = deep_clone(mag_75)
        self.parts.wpn_fps_upg_saigry_mag_pmag.stats.extra_ammo = -10
        self.parts.wpn_fps_upg_saigry_mag_stanag.stats = deep_clone(self.parts.wpn_fps_upg_saigry_mag_pmag.stats)
        self.parts.wpn_fps_upg_saigry_stock_folded.stats = deep_clone(self.parts.wpn_fps_m4_uupg_s_fold.stats)
        self.parts.wpn_fps_upg_saigry_jailbrake.stats = {
            value = 0,
            recoil = 4,
            concealment = -2
        }
        self:convert_part("wpn_fps_upg_saigry_a_556", "mrifle", "lrifle")
        self.parts.wpn_fps_upg_saigry_a_556.custom_stats.sdesc1 = "caliber_r556x45"
    end

    if BeardLib.Utils:ModLoaded("Owen Gun") then
        self.parts.wpn_fps_smg_owen_b_43.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_owen_s_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_owen_sling.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_owen_low_window.stats = deep_clone(nostats)

        self.parts.wpn_fps_smg_owen_m_double.custom_stats = {alternating_reload = 1.20/0.80}
        self.parts.wpn_fps_smg_owen_m_double.stats = {
            value = 0,
            reload = -20,
            concealment = -2
        }
        self.parts.wpn_fps_smg_owen_s_no.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_smg_owen_s_wood.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
    end

    if BeardLib.Utils:ModLoaded("PP-19-01 Vityaz") then
        self.parts.wpn_fps_smg_vityaz_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_grip_ak.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_grip_molot.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_grip_rk3.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_grip_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_handguard_akm.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_handguard_arsenal.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_handguard_chaos.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_handguard_terminator.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_handguard_zenit.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_stock_molot.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vityaz_stock_zenit.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_vityaz_stock.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_vityaz_stock.pcs = nil

        self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.override = {}
        self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.override_weapon = {}
        self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.override_weapon_add = {}
        self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.override_weapon_multiply = {}
        
        self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.internal_part = true
        self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.custom_stats = {sdesc1 = "caliber_p10", armor_piercing_add = 0.13}
        
        self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.stats = {
            value = 0,
            damage = 10,
            recoil = -10,
            concealment = 0
        }
        self.parts.wpn_fps_upg_vityaz_barrel_long.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_upg_vityaz_bolt_lightweight.forbids = {"wpn_fps_upg_i_autofire"}
        self.parts.wpn_fps_upg_vityaz_bolt_lightweight.custom_stats = deep_clone(self.parts.wpn_fps_upg_i_autofire.custom_stats)
        self.parts.wpn_fps_upg_vityaz_bolt_lightweight.stats = deep_clone(self.parts.wpn_fps_upg_i_autofire.stats)

        self.parts.wpn_fps_upg_vityaz_supp.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_vityaz_supp.stats = deep_clone(silstatsconc2)

        self.parts.wpn_fps_upg_vityaz_mag_dual.custom_stats = {alternating_reload = 1.20/0.80}
        self.parts.wpn_fps_upg_vityaz_mag_dual.stats = {
            value = 0,
            reload = -20,
            concealment = -2
        }
        self.parts.wpn_fps_upg_vityaz_stock_akm.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
    end

    if BeardLib.Utils:ModLoaded("Tactical Operator Attachments") then
        self.parts.wpn_fps_upg_s_devgru.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_fg_ropup.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_fg_daniel.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_fg_deadline.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_fg_patrick.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_scar_s_collapsed.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_wellgrip.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_ns_dragon.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)
        self.parts.wpn_fps_upg_ns_hock.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_ns_hock.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_upg_ns_osprey.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_ns_osprey.stats = deep_clone(silstatsconc2)

        table.insert(primarysmgadds, "wpn_fps_upg_ns_dragon")
        table.insert(primarysmgadds, "wpn_fps_upg_ns_hock")
        table.insert(primarysmgadds, "wpn_fps_upg_ns_osprey")

        self.parts.wpn_fps_upg_tecci_am_beefy.custom_stats = {sdesc1 = "caliber_r556x45m193"}
        self.parts.wpn_fps_upg_tecci_am_beefy.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_mp9_s_no.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_upg_sub2000_m_short.custom_stats = {}
        self.parts.wpn_fps_upg_sub2000_m_short.stats = deep_clone(mag_50)
        self.parts.wpn_fps_upg_sub2000_m_short.stats.extra_ammo = -16

        self:convert_part("wpn_fps_upg_ching_am_crap", "dmr", "ldmr", 56, InFmenu.wpnvalues.ldmr.ammo + 8)
        self.parts.wpn_fps_upg_ching_am_crap.custom_stats.sdesc1 = "caliber_r3006surplus"
        self.parts.wpn_fps_upg_ching_am_crap.stats.threat = 0
        self.parts.wpn_fps_upg_ching_am_crap.stats.reload = 25

        -- wat do
        self.parts.wpn_fps_upg_am_hollow_small.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_am_hollow_small.pcs = nil
        self.parts.wpn_fps_upg_am_hollow_large.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_am_hollow_large.pcs = nil
        self.parts.wpn_fps_upg_am_gomerpyle.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_am_gomerpyle.pcs = nil
        self.parts.wpn_fps_upg_am_lame.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_am_lame.pcs = nil

        self.parts.wpn_fps_upg_m14_m_tape.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_mp5_m_ten.stats = deep_clone(self.parts.wpn_fps_smg_mp5_m_straight.stats)
        self:convert_part("wpn_fps_upg_schakal_m_nine", "longsmg", "shortsmg")
        self.parts.wpn_fps_upg_schakal_m_nine.custom_stats.sdesc1 = "caliber_p9x19"
        self.parts.wpn_fps_upg_schakal_m_atai.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_vg_bcm.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vg_cadex.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vg_jowi.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vg_angle.stats = deep_clone(nostats)
        primarysmgadds_specific.wpn_fps_smg_schakalprimary = primarysmgadds_specific.wpn_fps_smg_schakalprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_upg_vg_bcm")
        table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_upg_vg_cadex")
        primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_vg_bcm")
        table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_vg_cadex")

        self.parts.wpn_fps_upg_pn_over.custom_stats = {inf_rof_mult = 1.10}
        self.parts.wpn_fps_upg_pn_over.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_pn_under.custom_stats = {inf_rof_mult = 0.90}
        self.parts.wpn_fps_upg_pn_under.stats = deep_clone(nostats)

        DelayedCalls:Add("carlsoperatorattachdelay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_upg_am_gomerpyle.custom_stats = {}
            tweak_data.weapon.factory.parts.wpn_fps_upg_am_hollow_small.custom_stats = {}
            tweak_data.weapon.factory.parts.wpn_fps_upg_am_hollow_large.custom_stats = {headshot_dmg_mult = 1}

            tweak_data.weapon.factory.parts.wpn_fps_upg_m14_m_tape.custom_stats = {}

            tweak_data.weapon.factory.parts.wpn_fps_upg_mp5_m_ten.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_smg_mp5_m_straight.stats)
            tweak_data.weapon.factory:convert_ammo_pickup("wpn_fps_upg_schakal_m_nine", InFmenu.wpnvalues.longsmg.ammo, InFmenu.wpnvalues.shortsmg.ammo)
            tweak_data.weapon.factory.parts.wpn_fps_upg_schakal_m_atai.custom_stats = {}

            tweak_data.weapon.factory.parts.wpn_fps_upg_tr_match.override_weapon_multiply = nil

            tweak_data.weapon.factory.parts.wpn_fps_upg_pn_over.override_weapon_multiply = {fire_mode_data = {fire_rate = 1}}
            tweak_data.weapon.factory.parts.wpn_fps_upg_pn_under.override_weapon_multiply = {fire_mode_data = {fire_rate = 1}}
        end)
    end

    if BeardLib.Utils:ModLoaded("l1a1") then
        self.parts.wpn_fps_ass_l1a1_grip_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_l1a1_foregrip_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_l1a1_stock_wood.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_l1a1_barrel_long.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_ass_l1a1_ns_fal.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats)

        self.parts.wpn_fps_ass_l1a1_mag_big.stats = deep_clone(mag_150)
        self.parts.wpn_fps_ass_l1a1_mag_big.stats.extra_ammo = 10
        self.parts.wpn_fps_ass_l1a1_mag_short.stats = deep_clone(mag_50)
        self.parts.wpn_fps_ass_l1a1_mag_short.stats.extra_ammo = -10
    end

    if BeardLib.Utils:ModLoaded("Mk14") then
        -- Mk14 has ironsights, no need for this
        --table.insert(gunlist_snp, {"wpn_fps_snp_wargoddess", -3})
        --self.parts.wpn_fps_snp_wargoddess_b_ebr.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_snp_wargoddess_o_dummy.stats = {
            value = 0,
            concealment = 0
        }
        self.parts.wpn_fps_snp_wargoddess_s_mod0_un.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_wargoddess_s_mod0_in.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_snp_wargoddess_supp.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_snp_wargoddess_supp.stats = deep_clone(silstatssnp)
    end

    if BeardLib.Utils:ModLoaded("sg552") then
        self.parts.wpn_fps_ass_sg552_g_ergo.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_sg552_m_milspec.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_sg552_s_tactical.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_sg552_s_modern.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_sg552_a_dmg.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_sg552_fg_large.stats = {
            value = 0,
            spread = 10,
            recoil = 2,
            reload = -10,
            concealment = -2
        }
        self.parts.wpn_fps_ass_sg552_fg_holo.stats = {
            value = 0,
            spread = 15,
            recoil = 3,
            reload = -15,
            concealment = -3
        }
        self.parts.wpn_fps_ass_sg552_s_folding.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_sg552_s_modern.stats = deep_clone(stock_snp)

        -- fixing attachable sight alignment
        -- custom sights still wrong tho bcuz lmao
        self.parts.wpn_fps_ass_sg552_b_standard.stance_mod = {
            wpn_fps_ass_sg552 = {translation = Vector3(0.12, 0, -0.35)}
        }
        self.parts.wpn_fps_ass_sg552_b_standard.adds = {"wpn_fps_ass_m16_os_frontsight"}
        self.wpn_fps_ass_sg552.override = self.wpn_fps_ass_sg552.override or {}
        self.wpn_fps_ass_sg552.override.wpn_fps_ass_m16_os_frontsight = {
            unit = dummy, third_unit = dummy,
            stance_mod = {
                wpn_fps_ass_sg552 = {translation = Vector3(-0.12, 0, 0.35)}
            }
        }

        DelayedCalls:Add("sg552delay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_ass_sg552_a_dmg.custom_stats = {sdesc1 = "caliber_r556x45"}

            --tweak_data.weapon.factory.parts.wpn_fps_ass_sg552_o_flipup.stance_mod.wpn_fps_ass_sg552.translation = tweak_data.weapon.factory.parts.wpn_fps_ass_sg552_o_flipup.stance_mod.wpn_fps_ass_sg552.translation + Vector3(0.12, 0, -0.35)
        end)
    end

    if BeardLib.Utils:ModLoaded("Beretta Px4 Storm") and self.parts.wpn_fps_pis_px4_mag then
        self.parts.wpn_fps_pis_px4_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_px4_barrel_sd.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_px4_grip_backstrap_rubber.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_px4_sight_dot.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_px4_sight_tritium.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_px4_ammo_9mm.override = {}
        self.parts.wpn_fps_upg_px4_ammo_9mm.override_weapon = {}
        self.parts.wpn_fps_upg_px4_ammo_9mm.override_weapon_add = {}
        self.parts.wpn_fps_upg_px4_ammo_9mm.override_weapon_multiply = {}
        self:convert_part("wpn_fps_upg_px4_ammo_9mm", "mediumpis", "lightpis")
        self.parts.wpn_fps_upg_px4_ammo_9mm.custom_stats.sdesc1 = "caliber_p9x19"
        self.parts.wpn_fps_upg_px4_ammo_9mm.internal_part = true

        self.parts.wpn_fps_upg_px4_ammo_45acp.override = {}
        self.parts.wpn_fps_upg_px4_ammo_45acp.override_weapon = {}
        self.parts.wpn_fps_upg_px4_ammo_45acp.override_weapon_add = {}
        self.parts.wpn_fps_upg_px4_ammo_45acp.override_weapon_multiply = {}
        self:convert_part("wpn_fps_upg_px4_ammo_45acp", "mediumpis", "supermediumpis")
        self.parts.wpn_fps_upg_px4_ammo_45acp.custom_stats.sdesc1 = "caliber_p45s"
        self.parts.wpn_fps_upg_px4_ammo_45acp.internal_part = true
    end

    if BeardLib.Utils:ModLoaded("Sword Cutlass Grips") then
        self.parts.wpn_fps_pis_beretta_g_cutlass.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("Walther P99 AS") then
        self:convert_part("wpn_fps_upg_p99_ammo_40sw", "lightpis", "mediumpis", nil, 84)
        self.parts.wpn_fps_upg_p99_ammo_40sw.custom_stats.sdesc1 = "caliber_p40sw"
        self.parts.wpn_fps_upg_p99_ammo_40sw.stats.extra_ammo = -3
        self.parts.wpn_fps_upg_p99_ammo_40sw.stats.reload = 0
        self.parts.wpn_fps_upg_p99_ammo_40sw.internal_part = true

        self.parts.wpn_fps_upg_p99_barrel_threaded.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_p99_sight_ghostring.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_p99_sight_tritium.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_p99_barrel_ported.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        self.parts.wpn_fps_upg_p99_mag_ext.stats = deep_clone(mag_133)
        self.parts.wpn_fps_upg_p99_mag_ext.stats.extra_ammo = 5
        self.parts.wpn_fps_upg_p99_sight_rail.stats = {
            value = 0,
            concealment = -1
        }
    end

    if BeardLib.Utils:ModLoaded("Leupold DeltaPoint Sight") then
        self.parts.wpn_fps_upg_o_deltapoint.stats = {
            value = 0,
            zoom = 0,
            concealment = 0
        }
    end

    if BeardLib.Utils:ModLoaded("Tromix Barrel-Ext") then
        self.parts.wpn_fps_upg_ns_ass_smg_tromix.stats = {
            value = 0,
            recoil = 3,
            concealment = -2
        }
        table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_smg_tromix")
    end

    if BeardLib.Utils:ModLoaded("M45A1 CQBP") then
        self.parts.wpn_fps_pis_m45a1_m_ext.stats = deep_clone(mag_150)
        self.parts.wpn_fps_pis_m45a1_m_ext.stats.extra_ammo = 3
    end

    if BeardLib.Utils:ModLoaded("Mossberg 590") then
        self.parts.wpn_fps_shot_m590_ironsight.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m590_sightrail.stats = deep_clone(nostats)

        self.parts.wpn_fps_shot_m590_s_old.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m590_heat_shield.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m590_s_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m590_fg_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m590_fg_hdtf.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m590_s_hdtf.stats = deep_clone(nostats)

        self.parts.wpn_fps_shot_m590_b_short.stats = deep_clone(barrelsho_p2)
        self.parts.wpn_fps_shot_m590_b_short.stats.extra_ammo = -1

        self.parts.wpn_fps_shot_m590_b_silencer.custom_stats = shotgunsilencercustomstats
        self.parts.wpn_fps_shot_m590_b_silencer.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_thick.stats)

        DelayedCalls:Add("mossberg590delay", delay, function(self, params)
            tweak_data.weapon.factory.wpn_fps_shot_m590.override.wpn_fps_shot_r870_body_rack.stats = nil
        end)
    end

    if BeardLib.Utils:ModLoaded("Vepr-12") then
        self.parts.wpn_fps_upg_vepr12_grip_ak_plastic.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vepr12_grip_ak_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vepr12_handguard_ak_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vepr12_handguard_midwest.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vepr12_handguard_terminator.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vepr12_stock_ak_plastic.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vepr12_stock_ak_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_vepr12_stock_sok.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_vepr12_mag_sgm.stats = deep_clone(mag_150)
        self.parts.wpn_fps_upg_vepr12_mag_sgm.stats.extra_ammo = 4

        self.parts.wpn_fps_upg_vepr12_barrel_long.stats = deep_clone(barrelsho_m1)
    end

    if BeardLib.Utils:ModLoaded("M3 Grease Gun") then
        self.parts.wpn_fps_smg_m3_b_suppressor.custom_stats = silencercustomstats
        self.parts.wpn_fps_smg_m3_b_suppressor.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_smg_m3_s_ext.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        self.parts.wpn_fps_smg_m3_s_no.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_smg_m3_b_small.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_smg_m3_sling.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_m3_sling_l.stats = deep_clone(nostats)

        self.parts.wpn_fps_smg_m3_m_short.stats = deep_clone(mag_66)
        self.parts.wpn_fps_smg_m3_m_short.stats.extra_ammo = -10
        self.parts.wpn_fps_smg_m3_m_long.stats = deep_clone(mag_133)
        self.parts.wpn_fps_smg_m3_m_long.stats.extra_ammo = 10
        self.parts.wpn_fps_smg_m3_m_double.custom_stats = {alternating_reload = 1.20/0.80}
        self.parts.wpn_fps_smg_m3_m_double.stats = {
            value = 0,
            reload = -20,
            concealment = -2
        }

        DelayedCalls:Add("greasegundelay", delay, function(self, params)
            tweak_data.weapon.factory:convert_part("wpn_fps_smg_m3_a_9mm", "shortsmg", "longsmg")
            tweak_data.weapon.factory.parts.wpn_fps_smg_m3_a_ovk_9mm.custom_stats = {sdesc1 = "caliber_p9x19nade"}
            tweak_data.weapon.factory.parts.wpn_fps_smg_m3_a_ovk_9mm.stats = deep_clone(nostats)
        end)
    end

    if BeardLib.Utils:ModLoaded("Howa AR") then
        self:convert_part("wpn_fps_ass_howa_t64_body", "lrifle", "hrifle")
        self.parts.wpn_fps_ass_howa_t64_body.custom_stats.sdesc1 = "caliber_r762x51jp"
        self.parts.wpn_fps_ass_howa_t64_body.custom_stats.use_reload_2 = true
        self.parts.wpn_fps_ass_howa_t64_body.stats.reload = 0

        self.parts.wpn_fps_ass_howa_s_wrapped.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_howa_m_supido.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_howa_bayonet.stats = deep_clone(self.parts.wpn_fps_snp_mosin_ns_bayonet.stats)
        self.parts.wpn_fps_ass_howa_bayonet.perks = {
            "bayonet"
        }
        self.parts.wpn_fps_ass_howa_b_para.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_ass_howa_s_skeletal.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_howa_m_para.stats = deep_clone(mag_66)
        self.parts.wpn_fps_ass_howa_m_para.stats.extra_ammo = -10
        DelayedCalls:Add("howadelay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_ass_howa_t64_body.override_weapon_add = {}
            tweak_data.weapon.factory.parts.wpn_fps_ass_howa_t64_body.override.wpn_fps_ass_howa_b_para.stats = {}
        end)
    end

    if BeardLib.Utils:ModLoaded("vp70") then
        self.parts.wpn_fps_pis_vp70_body_early.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_vp70_s_scifi.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_vp70_stp_standard.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_vp70_m_speed_std.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_vp70_grip_ergo.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_vp70_ac_9x21imi.custom_stats = {sdesc1 = "caliber_p9x21imi"}
        self.parts.wpn_fps_pis_vp70_ac_9x21imi.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_vp70_lc_stormtrooper.stats = deep_clone(nostats)

        self.parts.wpn_fps_pis_vp70_autofire.stats = {
            value = 0,
            spread = -15,
            concealment = 0
        }
        self.parts.wpn_fps_pis_vp70_stock_standard.custom_stats = {has_burst_fire = true, burst_fire_rate_table = {2100/600, 2100/600, 0.33}}
        self.parts.wpn_fps_pis_vp70_stock_standard.stats = {
            value = 0,
            recoil = 8,
            reload = -25,
            concealment = -4
        }
        self:convert_ammo_pickup("wpn_fps_pis_vp70_stock_standard", 144, 108)
        self:convert_total_ammo_mod("wpn_fps_pis_vp70_stock_standard", 144, 108)
        self.parts.wpn_fps_pis_vp70_m_ext.stats = deep_clone(mag_133)
        self.parts.wpn_fps_pis_vp70_m_ext.stats.extra_ammo = 6
    end

    if BeardLib.Utils:ModLoaded("lapd") then
        self.parts.wpn_fps_pis_lapd_grip_pearl.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_lapd_grip_polymer.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_lapd_grip_cherry.stats = deep_clone(nostats)

        table.insert(self.wpn_fps_pis_lapd.uses_parts, "inf_lapd_556")
        table.insert(self.wpn_fps_pis_x_lapd.uses_parts, "inf_lapd_556")
        self.parts.inf_lapd_556.custom_stats = {sdesc1 = "caliber_r556x45"}
        self.parts.inf_lapd_556.sound_switch = {suppressed = "infalt"}
        self.parts.inf_lapd_556.stats = deep_clone(nostats)

        self.parts.wpn_fps_pis_lapd_b_standard.stance_mod = {
            wpn_fps_pis_lapd = {translation = Vector3(0.2, 0, 0)}
        }
    --[[
        self.parts.wpn_fps_pis_lapd_a_bronco.stats = {
            value = 0,
            damage = 195 - InFmenu.wpnvalues.heavypis.damage,
            recoil = -10,
            concealment = 0
        }
        self:convert_total_ammo_mod("wpn_fps_pis_lapd_a_bronco", 35, 30)
    DelayedCalls:Add("bladerunnerdelayedcall", delay, function(self, params)
        tweak_data.weapon.factory:convert_ammo_pickup("wpn_fps_pis_lapd_a_bronco", 35, 30)
        tweak_data.weapon.factory.parts.wpn_fps_pis_lapd_a_bronco.custom_stats.sdesc1 = "caliber_r556x45"
    end)
    --]]
    end

    if BeardLib.Utils:ModLoaded("Valday 1P87") then
        self.parts.wpn_fps_upg_o_valday1p87.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)
        self.parts.wpn_fps_upg_o_valday1p87.customsight = true
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans = {}
        local valdayoffset = -0.8
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 0, valdayoffset)}
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 0, valdayoffset)}
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0, 0, valdayoffset)}
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0, 0, valdayoffset)}
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0, 0, valdayoffset)}
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 0, valdayoffset)}
        self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 0, valdayoffset)}
    end

    if BeardLib.Utils:ModLoaded("Remington R5 RGP") then
        self.parts.wpn_fps_upg_mikon_s_viper.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_mikon_am_parp.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_mikon_am_parp.custom_stats = {sdesc1 = "caliber_r556x45m193"}
        self:convert_part("wpn_fps_upg_mikon_am_spc", "lrifle", "mrifle")
        self.parts.wpn_fps_upg_mikon_am_spc.custom_stats.sdesc1 = "caliber_r300blackout"
        self.parts.wpn_fps_upg_mikon_am_spc.stats.extra_ammo = 0
    end

    if BeardLib.Utils:ModLoaded("Parker-Hale PDW") then
        self.parts.wpn_fps_upg_nya_s_nope.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_upg_nya_cpu_turbo.custom_stats = {burst_fire_rate_multiplier = 800/1400}
        self.parts.wpn_fps_upg_nya_cpu_turbo.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_nya_cpu_slow.custom_stats = {burst_fire_rate_multiplier = 600/1400}
        self.parts.wpn_fps_upg_nya_cpu_slow.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_nya_am_dillon.stats = deep_clone(nostats)

        self.wpn_fps_smg_x_nya.override = self.wpn_fps_smg_x_nya.override or {}
        self.wpn_fps_smg_x_nya.override.wpn_fps_upg_nya_cpu_turbo = {
            custom_stats = {inf_rof_mult = 800/1400},
            desc_id = "inf_xidw_cpu_turbo_desc"
        }
        self.wpn_fps_smg_x_nya.override.wpn_fps_upg_nya_cpu_slow = {
            custom_stats = {inf_rof_mult = 600/1400},
            desc_id = "inf_xidw_cpu_slow_desc"
        }
        DelayedCalls:Add("memecatdelay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_upg_nya_am_dillon.custom_stats = {sdesc1 = "caliber_p9x19idw"}
            tweak_data.weapon.factory.parts.wpn_fps_upg_nya_cpu_slow.override_weapon = nil
            tweak_data.weapon.factory.parts.wpn_fps_upg_nya_cpu_turbo.override_weapon = nil
        end)
    end

    if BeardLib.Utils:ModLoaded("ARX-160 REBORN") then
        table.insert(self.wpn_fps_ass_lazy.uses_parts, "inf_car4_ironsretain")
        self.parts.wpn_fps_upg_lazy_b_long.stats = deep_clone(barrel_m2)
    --[[
        self.parts.wpn_fps_upg_lazy_s_fold.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
    --]]
        --self.parts.wpn_fps_upg_lazy_am_beefish.stats = 
    end

    if BeardLib.Utils:ModLoaded("DP28") then
        self.parts.wpn_fps_lmg_dp28_stock_dpm.stats = deep_clone(nostats)
        self.parts.wpn_fps_lmg_dp28_g_dpm.stats = deep_clone(nostats)
        self.parts.wpn_fps_lmg_dp28_bipod.custom_stats = {recoil_horizontal_mult = 2}
        self.parts.wpn_fps_lmg_dp28_bipod.stats = deep_clone(nostats)
        self.parts.wpn_fps_lmg_dp28_tripod_top.custom_stats = {recoil_horizontal_mult = 2.00, bipod_recoil_vertical_mult = 0.50, bipod_recoil_horizontal_mult = 0.50}
        self.parts.wpn_fps_lmg_dp28_tripod_top.stats = {
            value = 0,
            concealment = -5
        }
        self.parts.wpn_fps_lmg_dp28_barrel_lord.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_lmg_dp28_barrel_dt.stats = deep_clone(nostats)

        self.parts.wpn_fps_lmg_dp28_stock_dt.stats = deep_clone(nostats)
        self.parts.wpn_fps_lmg_dp28_g_dt.stats = deep_clone(nostats)
        self.parts.wpn_fps_lmg_dp28_barrel_dpm36.stats = deep_clone(nostats)


        self.parts.wpn_fps_lmg_dp28_m_dt.custom_stats = {deploy_ads_stance_mod = {translation = Vector3(0, 2.5, -1.825), rotation = Rotation(0, 0, 0)}}
        self.parts.wpn_fps_lmg_dp28_m_dt.stats = deep_clone(mag_125)
        self.parts.wpn_fps_lmg_dp28_m_dt.stats.extra_ammo = 13
        self.parts.wpn_fps_lmg_dp28_m_dpm36.stance_mod = {
            wpn_fps_lmg_dp28 = {translation = Vector3(0, 0, 1.6), rotation = Rotation(0, 0, 0)}
        }
        self.parts.wpn_fps_lmg_dp28_m_dpm36.stats = deep_clone(mag_75)
        self.parts.wpn_fps_lmg_dp28_m_dpm36.stats.extra_ammo = -13
        self.parts.wpn_fps_lmg_dp28_m_dpm35.stats = {
            value = 0,
            extra_ammo = 153,
            spread = -40,
            reload = -50,
            concealment = -5
        }
        DelayedCalls:Add("dp28delay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_lmg_dp28_m_dpm35.timer_adder = nil -- fuck your reload timers
        end)
    end

    -- Actually ingame now, this mod is now broken to begin with sadly
    --[[
    if BeardLib.Utils:ModLoaded("M60") then
        self.parts.wpn_fps_lmg_m60_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m60_bipod.custom_stats = {recoil_horizontal_mult = 2}
        self.parts.wpn_fps_upg_m60_bipod.desc_id = "bm_wp_wpn_fps_upg_m60_bipod_desc"

        -- bad company 2 vietnam ADS
        self.parts.wpn_fps_upg_m60_irons.override = self.parts.wpn_fps_upg_m60_irons.override or {}
        self.parts.wpn_fps_upg_m60_irons.override.wpn_fps_upg_m60bc2v_body = {
            stance_mod = {
                wpn_fps_lmg_m60 = {translation = Vector3(0.06, -9, 0), rotation = Rotation(0, -0.1, -0)}
            }
        }

        -- m60e4 ADS
        if self.parts.wpn_fps_lmg_m60e4_furnisight then
            self.parts.wpn_fps_lmg_m60e4_furnisight.stance_mod = {
                wpn_fps_lmg_m60 = {translation = Vector3(0, 0, 3), rotation = Rotation(0, 0, 0)}
            }
        end
    end
    ]]

    if BeardLib.Utils:ModLoaded("RPD") then
        self.parts.wpn_fps_upg_rpd_bipod.custom_stats = {recoil_horizontal_mult = 2}
        self.parts.wpn_fps_upg_rpd_bipod.desc_id = "bm_wp_wpn_fps_upg_rpd_bipod_desc"
        self.parts.wpn_fps_lmg_rpd_mag.stats = deep_clone(nostats)
        -- irons are slightly off
        self.parts.wpn_fps_lmg_rpd_mag.stance_mod = {
            wpn_fps_lmg_rpd = {translation = Vector3(0.05, 0, 0), rotation = Rotation(-0.1, 0, 0)}
        }
    end

    if BeardLib.Utils:ModLoaded("LSAT") then
        self.parts.wpn_fps_lmg_lsat_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_lsat_barrel_long.stats = deep_clone(barrel_m2)
        self.parts.wpn_fps_upg_lsat_barrel_short.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_upg_lsat_bipod.custom_stats = {recoil_horizontal_mult = 2}
        self.parts.wpn_fps_upg_lsat_fab_ptk.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_lsat_magpul_afg.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_lsat_stock_collapsed.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_upg_lsat_irons.internal_part = true
    end

    if BeardLib.Utils:ModLoaded("GSPS Various Attachment") then
        self.parts.wpn_fps_shot_m37_b_trench.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m37_b_deerslayer.stats = deep_clone(barrelsho_m2)
        self.parts.wpn_fps_shot_m37_s_rack.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_m37_s_stakeout.stats = deep_clone(self.parts.wpn_fps_shot_m37_s_short.stats)

        table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_b_trench")
        table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_b_deerslayer")
        table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_s_rack")
        table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_s_stakeout")
    end

    if BeardLib.Utils:ModLoaded("gtt33") then
        self.parts.wpn_fps_pis_gtt33_g_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_gtt33_g_white.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_gtt33_g_bling.stats = deep_clone(nostats)
        --self.parts.wpn_fps_pis_gtt33_comp.stats = deep_clone(self.parts.wpn_fps_pis_g18c_co_1.stats)
        self.parts.wpn_fps_pis_gtt33_comp2.stats = deep_clone(self.parts.wpn_fps_pis_g18c_co_1.stats)
        self.parts.wpn_fps_pis_gtt33_m_extended.stats = deep_clone(mag_200)
        self.parts.wpn_fps_pis_gtt33_m_extended.stats.extra_ammo = 8

        self.parts.wpn_fps_pis_gtt33_a_c45.internal_part = true
        self.parts.wpn_fps_pis_gtt33_a_c45.custom_stats = {sdesc1 = "caliber_p762x25badtaste"}
        self.parts.wpn_fps_pis_gtt33_a_c45.stats = deep_clone(nostats)
        --self:convert_part("wpn_fps_pis_gtt33_a_c45", "", "")
    end

    if BeardLib.Utils:ModLoaded("Fang-45") then
        self.parts.wpn_fps_smg_fang45_m_std.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_fang45_s_folded.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
    end

    if BeardLib.Utils:ModLoaded("CZ 75 B") then
        self.parts.wpn_fps_pis_cz75b_g_pre.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_g_b.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_g_rub.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_g_coco.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_g_wal.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_f_stainless.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_sl_stainless.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_f_blued.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_f_gold.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_sl_gold.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_ba_ext.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_ba_threaded.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_sl_comp.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_cz75b_fg_mag.stats = {
            value = 0,
            recoil = 4,
            concealment = -2
        }
        self.parts.wpn_fps_pis_cz75b_f_comp.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_pis_cz75b_m_comp.stats = { -- not used
            value = 0,
            extra_ammo = -2,
            reload = 10,
            concealment = 2
        }
        self.parts.wpn_fps_pis_cz75b_m_ext.stats = deep_clone(mag_150)
        self.parts.wpn_fps_pis_cz75b_m_ext.stats.extra_ammo = 8
        self.parts.wpn_fps_pis_cz75b_ba_std.stance_mod = {
            wpn_fps_pis_cz75b = {translation = Vector3(-0.05, 0, -0.3), rotation = Rotation(0, 0.9, 0)}
        }
        -- wpn_fps_pis_cz75b_ba_ext
        DelayedCalls:Add("cz75bdelay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_pis_cz75b_ba_std.weapon_stance_override = nil -- fix this shit later
            tweak_data.weapon.factory.parts.wpn_fps_pis_cz75b_ba_ext.weapon_stance_override = nil
        end)
    end

    if BeardLib.Utils:ModLoaded("CZ 75 Short Rail") then
        self.parts.wpn_fps_pis_rally_m_ext.stats = deep_clone(mag_150)
        self.parts.wpn_fps_pis_rally_m_ext.stats.extra_ammo = 10
        self.parts.wpn_fps_pis_rally_g_wood.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_rally_g_bacon.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_rally_ba_dummy.stance_mod = {
            wpn_fps_pis_rally = {translation = Vector3(0.05, 0, -0.2), rotation = Rotation(0, 0, 0)}
        }
        DelayedCalls:Add("gunsmithcatsdelay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_pis_rally_sl_std.weapon_stance_override = nil -- fix this shit later
            tweak_data.weapon.factory.parts.wpn_fps_pis_rally_sl_silver.weapon_stance_override = nil
        end)
    end

    if BeardLib.Utils:ModLoaded("CZ Auto Pistol") then
        self.parts.wpn_fps_pis_czauto_ns_compensated.stats = deep_clone(self.parts.wpn_fps_pis_g18c_co_1.stats)
        self.parts.wpn_fps_pis_czauto_m_extended.stats = deep_clone(mag_150)
        self.parts.wpn_fps_pis_czauto_m_extended.stats.extra_ammo = 10
        self.parts.wpn_fps_pis_czauto_vg_mag.stats = {
            value = 0,
            recoil = 4,
            concealment = -2
        }
        self.parts.wpn_fps_pis_czauto_g_wooden.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_czauto_g_walnut.stats = deep_clone(nostats)

        DelayedCalls:Add("czopdelay", delay, function(self, params)
            if tweak_data.weapon.factory.parts.wpn_fps_pis_czauto_vg_mag.override_weapon then
                tweak_data.weapon.factory.parts.wpn_fps_pis_czauto_vg_mag.override_weapon.use_stance = nil -- fix this shit later
            end
        end)
    end

    if BeardLib.Utils:ModLoaded("Chiappa Rhino 60DS") and self.parts.wpn_fps_pis_rhino_bullets then
        self.parts.wpn_fps_pis_rhino_bullets.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_rhino_grip_rubber_small.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_rhino_grip_wood_small.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_rhino_sight_fiber.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_rhino_ammo_40sw.override_weapon_add = {}
        self.parts.wpn_fps_upg_rhino_ammo_40sw.override_weapon_multiply = {}
        self.parts.wpn_fps_upg_rhino_ammo_40sw.override_weapon = {}
        self.parts.wpn_fps_upg_rhino_ammo_40sw.override = {}
        self:convert_part("wpn_fps_upg_rhino_ammo_40sw", "heavypis", "supermediumpis")
        self.parts.wpn_fps_upg_rhino_ammo_40sw.custom_stats.sdesc1 = "caliber_p40sw"

        -- self.parts.wpn_fps_upg_rhino_frame_200ds.custom_stats = {switchspeed_mult = switch_snubnose}
        --[[
        self.parts.wpn_fps_upg_rhino_frame_200ds.stats = {
            value = 0,
            spread = -30,
            recoil = -10,
            reload = 20,
            concealment = 3
        }
        ]]
    end

    if BeardLib.Utils:ModLoaded("Sjögren Inertia") then
        self.parts.wpn_fps_upg_sjogren_barrel_medium.stats = deep_clone(barrelsho_p1)
        self.parts.wpn_fps_upg_sjogren_barrel_short.stats = deep_clone(barrelsho_p3)
    end


    if BeardLib.Utils:ModLoaded("ThompsonM1a1") then
        self.parts.wpn_fps_smg_tm1a1_ns_ext.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_tm1a1_body_black.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_tm1a1_body_noiron.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_tm1a1_body_blacknoiron.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_tm1a1_b_standard.stats = deep_clone(barrel_p3)
        self.parts.wpn_fps_smg_tm1a1_ns_cutts.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)
        self.parts.wpn_fps_smg_tm1a1_s_unfolded.stats = {
            value = 0,
            recoil = 4,
            concealment = -2
        }
        self.parts.wpn_fps_smg_tm1a1_m_extended.stats = deep_clone(mag_150)
        self.parts.wpn_fps_smg_tm1a1_m_extended.stats.extra_ammo = 10
        self.parts.wpn_fps_smg_x_tm1a1_m_extended.stats = deep_clone(mag_150)
        self.parts.wpn_fps_smg_x_tm1a1_m_extended.stats.extra_ammo = 20
        self.parts.wpn_fps_smg_tm1a1_m_jungle.custom_stats = {alternating_reload = 1.20/0.80}
        self.parts.wpn_fps_smg_tm1a1_m_jungle.stats = {
            value = 0,
            reload = -20,
            concealment = -2
        }
        self.parts.wpn_fps_smg_x_tm1a1_m_jungle.custom_stats = {alternating_reload = 1.20/0.80}
        self.parts.wpn_fps_smg_x_tm1a1_m_jungle.stats = {
            value = 0,
            reload = -20,
            concealment = -2
        }
        self:convert_part_half_a("wpn_fps_smg_tm1a1_lower_reciever_30", "longsmg", "carbine")
        self.parts.wpn_fps_smg_tm1a1_lower_reciever_30.stats.spread = 0
        self.parts.wpn_fps_smg_tm1a1_lower_reciever_30.stats.suppression = 0

        self.parts.wpn_fps_smg_tm1a1_body_standard.stance_mod = {
            wpn_fps_smg_tm1a1 = {translation = Vector3(0, 2, 0), rotation = Rotation(0, 0, 0)}
        }

        DelayedCalls:Add("ww2tommydelay", delay, function(self, params)
            tweak_data.weapon.factory:convert_part_half_b("wpn_fps_smg_tm1a1_lower_reciever_30", "longsmg", "carbine")
            tweak_data.weapon.factory.parts.wpn_fps_smg_tm1a1_lower_reciever_30.custom_stats.sdesc1 = "caliber_r30carbine"
        end)
    end

    if BeardLib.Utils:ModLoaded("M6G Magnum") then
        self.parts.wpn_fps_pis_m6g_grip_discrete.stats = {
            value = 0,
            concealment = 2
        }
        self.parts.wpn_fps_pis_m6g_a_fire.custom_stats = {
            sdesc1 = "caliber_p117ic",
            bullet_class = "FlameBulletBase",
            fire_dot_data = {
                dot_trigger_chance = "100",
                dot_damage = "1.5",
                dot_length = "3.1",
                dot_trigger_max_distance = "10000", -- 100m
                dot_tick_period = "0.5"
            }
        }
        self.parts.wpn_fps_pis_m6g_a_fire.stats = {
            value = 0,
            damage = -20,
            concealment = 0
        }
        self.parts.wpn_fps_pis_m6g_a_he.custom_stats = {sdesc1 = "caliber_p117he", bullet_class = "InstantExplosiveBulletBase", ignore_statistic = true, bullet_damage_fraction = 80/200}
        self.parts.wpn_fps_pis_m6g_a_he.stats = {
            value = 0,
            damage = 30,
            concealment = 0
        }
        self.parts.wpn_fps_pis_m6g_a_shield.custom_stats = {sdesc1 = "caliber_p117saphe", bullet_class = "InstantExplosiveBulletBase", ignore_statistic = true, bullet_damage_fraction = 120/180}
        self.parts.wpn_fps_pis_m6g_a_shield.sub_type = "ammo_explosive"
        self.parts.wpn_fps_pis_m6g_a_shield.stats = {
            value = 0,
            damage = 10,
            concealment = 0
        }
    end

    if BeardLib.Utils:ModLoaded("AK-9") then
        self.parts.wpn_fps_ass_heffy_939_ba_tiss.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_939_fh_tiss.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_939_st_tiss.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_939_ur_tiss.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_939_m_tiss_20.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_o_ak9_l_scopemount.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_heffy_939_st_none.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
    end

    if BeardLib.Utils:ModLoaded("AK-47") then
        self.parts.wpn_fps_ass_heffy_762_pg_t2.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_ak47.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ba_akm.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_akm.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ur_akm.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_akmsu.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lr_akmsu.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lr_rpk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lfg_rpk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ufg_rpk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_st_rpk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_bp_rpk_folded.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_ak103.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lfg_ak103.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ufg_ak103.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_pg_ak103.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_st_ak103.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_ak104.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ba_vepr.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lr_vepr.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_st_vepr.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_md90.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ba_t56.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_t56.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lfg_bl_t56.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ufg_bl_t56.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_pg_bl_t56.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_stp_mpi.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_amd63.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ba_amd63.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lfg_m70.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_st_m70.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lr_m92.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_m92.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ro_m92.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_tabuk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_sp_tabuk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ba_rk62.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_rk62.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_pg_rk62.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_st_rk62.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_m_bake_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ufg_none.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lfg_none.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_none.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fm_m92.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fm_tabuk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fm_ty56.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fm_amd65.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fm_rk62.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_st_tabuk.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_pg_amd65.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ba_ak109.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_o_ak47_l_scopemount.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_vg_amd63.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_vg_amd65.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_lfg_md90.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ch_akm.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_m70.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_heffy_762_ba_akmsu.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_ass_heffy_762_ba_rpk.stats = deep_clone(barrel_m2)
        self.parts.wpn_fps_ass_heffy_762_ba_ak104.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_ass_heffy_762_ba_md90.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_ass_heffy_762_ba_amd65.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_ass_heffy_762_ba_m92.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_ass_heffy_762_ba_tabuk.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_ass_heffy_762_bp_rpk.custom_stats = {recoil_horizontal_mult = 2}
        self.parts.wpn_fps_ass_heffy_762_bp_rpk.stats = {
            value = 0,
            concealment = -1
        }

        self.parts.wpn_fps_ass_heffy_762_m_steel_5.stats = deep_clone(mag_17)
        --self.parts.wpn_fps_ass_heffy_762_m_steel_5.stats.extra_ammo = -25
        self.parts.wpn_fps_ass_heffy_762_m_steel_10.stats = deep_clone(mag_33)
        --self.parts.wpn_fps_ass_heffy_762_m_steel_10.stats.extra_ammo = -20
        self.parts.wpn_fps_ass_heffy_762_m_bake_10.stats = deep_clone(mag_33)
        --self.parts.wpn_fps_ass_heffy_762_m_bake_10.stats.extra_ammo = -20
        self.parts.wpn_fps_ass_heffy_762_m_steel_20.stats = deep_clone(mag_66)
        --self.parts.wpn_fps_ass_heffy_762_m_steel_20.stats.extra_ammo = -10
        self.parts.wpn_fps_ass_heffy_762_m_steel_40.stats = deep_clone(mag_133)
        --self.parts.wpn_fps_ass_heffy_762_m_steel_40.stats.extra_ammo = 10
        self.parts.wpn_fps_ass_heffy_762_m_steel_75.stats = {
            value = 0,
            --extra_ammo = 45,
            spread = -15,
            recoil = 10,
            reload = -30,
            concealment = -9
        }

        self.parts.wpn_fps_ass_heffy_762_st_none.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }

        self.parts.wpn_fps_ass_heffy_762_st_akms.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_762_st_akmsu.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_762_st_amd65.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_762_st_2_mpi.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_762_st_3_mpi.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_762_st_bl_t56.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_762_st_br_t56.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
    end

    -- Apparently theres two mods called AK74? Thanks
    if BeardLib.Utils:ModLoaded("AK-74") and self.parts.wpn_fps_ass_heffy_545_fh_ak74 then
        self.parts.wpn_fps_ass_heffy_545_fh_ak74.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_fh_aks74u.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_lr_aks74u.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_lr_rpk74.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_fh_rpk74.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_lfg_rpk74.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_ufg_rpk74.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_bp_rpk74_folded.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_lr_ak74m.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_lfg_ak74m.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_ufg_ak74m.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_pg_ak74m.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_st_ak74m.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_ba_ak105.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_fh_ak105.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_ba_ak107.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_fh_ak107.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_fh_tantal.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_m_steel_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_st_rpk74.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_o_ak74_l_scopemount.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_ufg_74flat.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_lfg_74flat.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_pg_74flat.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_st_74flat.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_st_ak74_poly.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_heffy_545_ba_aks74u.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_ass_heffy_545_ba_rpk74.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_ass_heffy_545_st_none.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
        self.parts.wpn_fps_ass_heffy_545_st_aks74.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_545_st_aks74u.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_ass_heffy_545_st_md86.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }

        self.parts.wpn_fps_ass_heffy_545_m_bake_45.stats = deep_clone(mag_150)
        --self.parts.wpn_fps_ass_heffy_545_m_bake_45.stats.extra_ammo = 15
        self.parts.wpn_fps_ass_heffy_545_m_poly_45.stats = deep_clone(mag_150)
        --self.parts.wpn_fps_ass_heffy_545_m_poly_45.stats.extra_ammo = 15
        self.parts.wpn_fps_ass_heffy_545_m_poly_60.stats = deep_clone(mag_200)
        --self.parts.wpn_fps_ass_heffy_545_m_poly_60.stats.extra_ammo = 30
    end

    if BeardLib.Utils:ModLoaded("AK-101") and self.parts.wpn_fps_ass_heffy_556_fh_ak101 then
        self.parts.wpn_fps_ass_heffy_556_fh_ak101.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_fh_ak102.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_ba_ak108.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_fh_ak108.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_o_ak101_l_scopemount.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_ba_t84s.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_ch_t84s.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_fh_t84s.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_ur_t84s.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_heffy_556_ba_ak102.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_ass_heffy_556_ba_t84s_long.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_ass_heffy_556_st_none.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
    end

    if BeardLib.Utils:ModLoaded("AK Color Attachments") then
        self.parts.wpn_fps_ass_heffy_all_mc_bake_bl.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_mc_bake_or.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_camo.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("AK Extra Attachments") then
        self.parts.wpn_fps_ass_heffy_545_st_ivan.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }

        self.parts.wpn_fps_ass_heffy_all_ufg_heat.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_lfg_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ufg_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_pg_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_st_moe.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ufg_ulti.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_lfg_honor.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ufg_honor.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_lfg_zenit.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ufg_zenit.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_pg_rk3.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_pg_rub.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_pg_sco.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_pg_laminate.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ufg_laminate.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_lfg_laminate.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_st_laminate.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_st_sho.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_st_pkm.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ro_blops.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fm_blops.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ro_ins.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_stpa_gl.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_m_banana_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_m_pmag_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_m_proto_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_m_fleur_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_m_circle_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_556_m_wieger_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_ch_ak117.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_lfg_warrior.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ro_warrior.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_fo_warrior.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_m_ak103_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_m_ivan_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_m_pmag_30.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_fh_fun.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_545_fh_tank.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_fun.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_fh_tank.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_fh_krebs.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ufg_krebs.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_lfg_krebs.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_ufg_alpha.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_lfg_alpha.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_762_pg_akmwood.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_pg_saw.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_tr_alpha.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_heffy_762_m_star_20.stats = deep_clone(mag_66)
        --self.parts.wpn_fps_ass_heffy_762_m_star_20.stats.extra_ammo = -10
        self.parts.wpn_fps_ass_heffy_762_m_bar_20.stats = deep_clone(mag_66)
        --self.parts.wpn_fps_ass_heffy_762_m_bar_20.stats.extra_ammo = -10
        self.parts.wpn_fps_ass_heffy_762_m_box_20.stats = deep_clone(mag_66)
        --self.parts.wpn_fps_ass_heffy_762_m_box_20.stats.extra_ammo = -10
        self.parts.wpn_fps_ass_heffy_762_m_pmag_20.stats = deep_clone(mag_66)
        self.parts.wpn_fps_ass_heffy_762_m_pmag_10.stats = deep_clone(mag_33)
        self.parts.wpn_fps_ass_heffy_762_m_helical_64.stats = deep_clone(mag_200)
        --self.parts.wpn_fps_ass_heffy_762_m_helical_64.stats.extra_ammo = 34

        self.parts.wpn_fps_ass_heffy_762_m_steel_8.stats = deep_clone(mag_25)
        self.parts.wpn_fps_ass_heffy_762_m_steel_50.stats = deep_clone(mag_200)
        self.parts.wpn_fps_ass_heffy_762_m_steel_50.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_50.stats.reload + 3
        self.parts.wpn_fps_ass_heffy_762_m_steel_60.stats = deep_clone(mag_200)
        --self.parts.wpn_fps_ass_heffy_762_m_steel_60.stats.extra_ammo = 30
        self.parts.wpn_fps_ass_heffy_762_m_steel_70.stats = deep_clone(mag_200)
        self.parts.wpn_fps_ass_heffy_762_m_steel_70.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_70.stats.reload - 3
        self.parts.wpn_fps_ass_heffy_762_m_steel_80.stats = deep_clone(mag_300)
        self.parts.wpn_fps_ass_heffy_762_m_steel_80.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_80.stats.reload + 3
        self.parts.wpn_fps_ass_heffy_762_m_steel_90.stats = deep_clone(mag_300)
        --self.parts.wpn_fps_ass_heffy_762_m_steel_90.stats.extra_ammo = 60
        self.parts.wpn_fps_ass_heffy_762_m_steel_100.stats = deep_clone(mag_300)
        self.parts.wpn_fps_ass_heffy_762_m_steel_100.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_100.stats.reload - 3
        self.parts.wpn_fps_ass_heffy_762_m_steel_180.stats = {
            value = 0,
            --extra_ammo = 150,
            total_ammo_mod = 2000,
            spread = -50,
            recoil = 20,
            --reload = -50,
            concealment = -12
        }
        self.parts.wpn_fps_ass_heffy_762_m_steel_180.stats.reload = InFmenu.wpnvalues.reload.mag_300.reload - math.floor(0.2*(100 + InFmenu.wpnvalues.reload.mag_300.reload))
        self.parts.wpn_fps_ass_heffy_762_m_steel_260.stats = {
            value = 0,
            --extra_ammo = 230,
            total_ammo_mod = 3000,
            spread = -60,
            recoil = 20,
            --reload = -60,
            concealment = -15
        }
        self.parts.wpn_fps_ass_heffy_762_m_steel_260.stats.reload = InFmenu.wpnvalues.reload.mag_300.reload - math.floor(0.4*(100 + InFmenu.wpnvalues.reload.mag_300.reload))
        self.parts.wpn_fps_ass_heffy_762_m_steel_1160A.stats = {
            value = 0,
            --extra_ammo_new = 1130,
            total_ammo_mod = 10000,
            spread = -80,
            recoil = 30,
            --reload = -80,
            concealment = -30
        }
        self.parts.wpn_fps_ass_heffy_762_m_steel_1160A.stats.reload = InFmenu.wpnvalues.reload.mag_300.reload - math.floor(0.8*(100 + InFmenu.wpnvalues.reload.mag_300.reload))


        primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_fh_fun")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_fh_tank")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_star_20")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_bar_20")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_box_20")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_pmag_20")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_pmag_10")
        --table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_helical_64")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_8")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_50")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_60")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_70")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_80")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_90")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_100")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_180")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_260")
        table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_1160A")

        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_fh_fun")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_fh_tank")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_star_20")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_bar_20")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_box_20")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_pmag_20")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_pmag_10")
        --table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_helical_64")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_8")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_50")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_60")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_70")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_80")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_90")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_100")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_180")
        table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_260")



        self.parts.wpn_fps_ass_heffy_all_gl_gp25_sight_up.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_all_gl_gp25.stats = {
            value = 0,
            concealment = -5
        }
        self:convert_ammo_pickup("wpn_fps_ass_heffy_all_gl_gp25", "lrifle", "lrifle_gl")
        self:convert_total_ammo_mod("wpn_fps_ass_heffy_all_gl_gp25", "lrifle", "lrifle_gl")
        self.parts.wpn_fps_ass_heffy_all_gl_gp25.custom_stats = {sdesc3 = "misc_gl40vog"}

        self.parts.wpn_fps_upg_gl_lpo70.chamber = 0
        self.parts.wpn_fps_upg_gl_lpo70.stats = {
            value = 0,
            concealment = -5
        }
        self:convert_ammo_pickup("wpn_fps_upg_gl_lpo70", "lrifle", "lrifle_gl")
        self:convert_total_ammo_mod("wpn_fps_upg_gl_lpo70", "lrifle", "lrifle_gl")
        self.parts.wpn_fps_upg_gl_lpo70.custom_stats = {sdesc3 = "misc_flammen"}


        local mrifle_gl_mult = InFmenu.wpnvalues.mrifle_gl.ammo/InFmenu.wpnvalues.mrifle.ammo
        local mrifle_with_underbarrel = {"wpn_fps_ass_heffy_762", "wpn_fps_ass_heffy_gold"}
        local mrifle_underbarrel = {"wpn_fps_ass_heffy_all_gl_gp25", "wpn_fps_upg_gl_lpo70"}
        for a, b in pairs(mrifle_with_underbarrel) do
            for c, d in pairs(mrifle_underbarrel) do
                self[b].override = self[b].override or {}
                self[b].override[c] = self[b].override[c] or {}
                self[b].override[c].custom_stats = {
                    ammo_pickup_min_mul = mrifle_gl_mult, ammo_pickup_max_mul = mrifle_gl_mult
                }
                if c == "wpn_fps_upg_gl_lpo70" then
                    self[b].override[c].custom_stats.sdesc3 = "misc_flammen"
                    --self[b].override[c].desc_id = "bm_wp_wpn_fps_upg_gl_lpo70_desc2" -- SHIT DON'T WANT TO WORK
                else
                    self[b].override[c].custom_stats.sdesc3 = "misc_gl40vog"
                    --self[b].override[c].desc_id = "bm_wp_wpn_fps_ass_heffy_all_gl_gp25_desc2"
                end
                self[b].override[c].stats = {
                    value = 0,
                    concealment = -5
                }
                self[b].override[c].stats.total_ammo_mod = math.floor(((mrifle_gl_mult - 1) * 1000) + 0.5)
            end
        end

        self.parts.wpn_fps_ass_heffy_all_sm_cover.stance_mod = {
            wpn_fps_ass_heffy_762 = {translation = Vector3(0, 0, 0.45)},
            wpn_fps_ass_heffy_939 = {translation = Vector3(0, 0, 0.45)},
            wpn_fps_ass_heffy_545 = {translation = Vector3(0, 0, 0.45)},
            wpn_fps_ass_heffy_556 = {translation = Vector3(0, 0, 0.45)}
        }
        self.parts.wpn_fps_ass_heffy_all_sm_cover.adds = {"inf_sightdummy2"}
    end

    if BeardLib.Utils:ModLoaded("Golden-AKMS") then
        self.parts.wpn_fps_ass_heffy_gold_st_akm.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_gold_st_akms.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_heffy_gold_fh_none.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_o_gold_l_scopemount.stats = deep_clone(nostats)

        self.parts.wpn_fps_ass_heffy_gold_m_steel_40.stats = deep_clone(mag_133)
        --self.parts.wpn_fps_ass_heffy_gold_m_steel_40.stats.extra_ammo = 10
        self.parts.wpn_fps_ass_heffy_gold_st_none.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
    end

    if BeardLib.Utils:ModLoaded("Saiga-12") then
        self.parts.wpn_fps_sho_heffy_12g_ext_saiga12k.stats = deep_clone(nostats)
        self.parts.wpn_fps_sho_heffy_12g_lfg_utg_short.stats = deep_clone(nostats)
        self.parts.wpn_fps_sho_heffy_12g_lfg_utg_long.stats = deep_clone(nostats)
        self.parts.wpn_fps_sho_heffy_12g_ro_rail.stats = deep_clone(nostats)

        self.parts.wpn_fps_sho_heffy_12g_m_poly_10.stats = deep_clone(mag_200)
        --self.parts.wpn_fps_sho_heffy_12g_m_poly_10.stats.extra_ammo = 5

        self.parts.wpn_fps_sho_heffy_12g_st_none.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
    end

    if BeardLib.Utils:ModLoaded("Nagant M1895") then
        self.parts.wpn_fps_pis_m1895_cylinder.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m1895_body_blued.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m1895_body_gold.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m1895_body_polished.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m1895_body_worn.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m1895_irons_radium.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_m1895_supp_ro2.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_m1895_supp_ro2.stats = deep_clone(silstatsconc0)
        self.parts.wpn_fps_upg_m1895_supp_gemtech_gm9.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_m1895_supp_gemtech_gm9.stats = deep_clone(silstatsconc1)
        self.parts.wpn_fps_upg_m1895_supp_osprey.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_m1895_supp_osprey.stats = deep_clone(silstatsconc2)

        self.parts.wpn_fps_upg_m1895_barrel_long.stats = deep_clone(barrel_m1)
    end

    if BeardLib.Utils:ModLoaded("VHS Various Attachment") then
        self.parts.wpn_fps_ass_vhs_body_future.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_vhs_m_lsw.stats = {
            value = 0,
            reload = -10,
            concealment = -2
        }
        self.parts.wpn_fps_ass_vhs_ub_nade.stats = {
            value = 0,
            concealment = -3
        }
        self:convert_part("wpn_fps_ass_vhs_ub_nade", "lrifle", "lrifle_gl")
        self.parts.wpn_fps_ass_vhs_ub_nade.custom_stats = {sdesc3 = "misc_gl40x46mm"}
    end

    if BeardLib.Utils:ModLoaded("Aimpoint CompM2 Sight") then
        self.parts.wpn_fps_upg_o_compm2.customsight = true
        self.parts.wpn_fps_upg_o_compm2.stats = {
            value = 0,
            zoom = 3,
            concealment = -1,
        }
    end

    if BeardLib.Utils:ModLoaded("Stealth Flashlights") then
        self.parts.wpn_fps_upg_fl_wml.desc_id = "bm_wp_wpn_fps_upg_fl_wml_desc"
        self.parts.wpn_fps_upg_fl_pis_micro90.desc_id = "bm_wp_wpn_fps_upg_fl_micro90_desc"
    end

    if BeardLib.Utils:ModLoaded("Gepard GM6 Lynx") then
        table.insert(gunlist_snp, {"wpn_fps_snp_lynx", -3})
        self.parts.wpn_fps_snp_lynx_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_lynx_a_low.internal_part = true
        self.parts.wpn_fps_snp_lynx_a_low.stats = deep_clone(nostats)

        self.parts.wpn_fps_snp_lynx_o_special.custom_stats = {disallow_ads_while_reloading = true}

        self.parts.wpn_fps_snp_lynx_b_cqb.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_snp_msr_ns_suppressor.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_snp_lynx_b_supp.stats = deep_clone(silstatssnp)

        self.parts.wpn_fps_snp_lynx_m_short.stats = deep_clone(mag_50)
        self.parts.wpn_fps_snp_lynx_m_short.stats.extra_ammo = -6
        DelayedCalls:Add("lynxdelay", delay, function(self, params)
            tweak_data.weapon.factory.parts.wpn_fps_snp_lynx_a_low.custom_stats = {sdesc1 = "caliber_r127x108"}
        end)
    end

    if BeardLib.Utils:ModLoaded("PPSh-41") then
        --self.parts.wpn_fps_upg_ppsh_barrel_extension.stats = deep_clone(barrel_m1)
        --self.parts.wpn_fps_upg_ppsh_stock_black.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_ppsh_stock_camo_jungle.stats = deep_clone(nostats)
        self.parts.wpn_fps_smg_ppsh_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ppsh_barrel_k50m.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ppsh_barrel_sawnoffcomp.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ppsh_stock_k50m.stats = {
            value = 0,
            recoil = -6,
            concealment = 2,
        }
        self.parts.wpn_fps_upg_ppsh_stock_k50m_ext.stats = {
            value = 0,
            recoil = -9,
            concealment = 3,
        }

        self.parts.wpn_fps_upg_ppsh_mag_drum.custom_stats = {use_reload_2 = true, mod_empty_reload_speed_mult = 0.80, set_reload_stance_mod = {hip = {translation = Vector3(0, 0, -5), rotation = Rotation(0, 0, 0)}, ads = {translation = Vector3(0, 0, -5), rotation = Rotation(0, 0, 0)}}}
        self.parts.wpn_fps_upg_ppsh_mag_drum.stats = deep_clone(mag_200)
        self.parts.wpn_fps_upg_ppsh_mag_drum.stats.extra_ammo = 36
    end

    if BeardLib.Utils:ModLoaded("CSGO Sniper Scope") then
        self.parts.wpn_fps_upg_o_csgoscope.customsight = true
        self.parts.wpn_fps_upg_o_csgoscope.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_upg_o_csgoscope.stats = {
            value = 0,
            zoom = 8,
            concealment = -3
        }
    end

    if BeardLib.Utils:ModLoaded("M1 Garand Modpack") then
        self.parts.wpn_fps_ass_ching_o_m84.customsight = true
        self.parts.wpn_fps_ass_ching_o_m84.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_ass_ching_o_m84.stats = {
            value = 0,
            zoom = 10,
            concealment = -3
        }
        --wpn_fps_ass_ching_ironsight_switch

        self.parts.wpn_fps_ass_ching_ns_flashhider.stats = deep_clone(self.parts.wpn_fps_upg_ass_ns_linear.stats)

        self.parts.wpn_fps_ass_ching_ns_expsilencer.custom_stats = silencercustomstats
        self.parts.wpn_fps_ass_ching_ns_expsilencer.stats = deep_clone(silstatsconc1)
    end

    if BeardLib.Utils:ModLoaded("Kel-Tec RFB") then
        self.parts.wpn_fps_upg_leet_fg_ext.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_leet_b_smol.stats = deep_clone(barrel_p2)
    end

    if BeardLib.Utils:ModLoaded("Silent Killer High Standard HDM") then
        self.parts.wpn_fps_pis_hshdm_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_hshdm_frame_gold.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_hshdm_barrel.custom_stats = silencercustomstats
    end

    if BeardLib.Utils:ModLoaded("Silent Killer Maxim 9") then
        self.parts.wpn_fps_pis_max9_b_standard.custom_stats = silencercustomstats

        self.parts.wpn_fps_pis_max9_b_short.custom_stats = silencercustomstats
        self.parts.wpn_fps_pis_max9_b_short.stats = {
            value = 0,
            suppression = 12,
            alert_size = 12,
            spread = -5,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_pis_max9_b_short.stats.reload = barrel_p1.reload

        self.parts.wpn_fps_pis_max9_b_nosup.custom_stats = {sdesc4 = "misc_blank", falloff_min_dmg_penalty = 0}
        self.parts.wpn_fps_pis_max9_b_nosup.stats = {
            value = 0,
            spread = -10,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_pis_max9_b_nosup.stats.reload = barrel_p2.reload
    end

    if BeardLib.Utils:ModLoaded("Silent Killer Welrod") then
        self.parts.wpn_fps_pis_welrod_b_bolt.custom_stats = silencercustomstats
        self.parts.wpn_fps_pis_welrod_b_short.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_pis_welrod_b_short.stats.alert_size = -2
        self.parts.wpn_fps_pis_welrod_b_short.stats.suppression = -2
        self.parts.wpn_fps_pis_welrod_glow.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_welrod_trigger_guard.custom_stats = {use_goldeneye_reload = false}
        self.parts.wpn_fps_pis_welrod_trigger_guard.stats = deep_clone(nostats)

        self.parts.wpn_fps_pis_welrod_a_ap.stats = deep_clone(nostats)
        self:convert_ammo_pickup("wpn_fps_pis_welrod_a_ap", "heavypis", 30)
        self:convert_total_ammo_mod("wpn_fps_pis_welrod_a_ap", "heavypis", 30)
    end

    if BeardLib.Utils:ModLoaded("PB") then
        self.parts.wpn_fps_pis_pb_ns_std.custom_stats = silencercustomstats
        self.parts.wpn_fps_pis_pb_ns_std.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_pis_pb_ns_std.stats.concealment = -1
    end

    if BeardLib.Utils:ModLoaded("G3 Various Attachment") then
        --self.parts.wpn_fps_upg_g3_bipod.type = "bipod"
        --self.parts.wpn_fps_upg_g3_bipod.adds = {"inf_bipod_part"}
        self.parts.wpn_fps_upg_g3_bipod.custom_stats = {recoil_horizontal_mult = 2}
        self.parts.wpn_fps_upg_g3_bipod.stats = {
            value = 0,
            concealment = -1
        }

        self.parts.wpn_fps_ass_g3_g_ergo.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_g3_s_polymer.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_g3_fg_carbine.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_ass_g3_s_retractable.stats = {
            value = 0,
            recoil = -6,
            concealment = 2
        }

        self.parts.wpn_fps_ass_g3_m_50drum.stats = deep_clone(mag_250)
        self.parts.wpn_fps_ass_g3_m_50drum.stats.extra_ammo = 30
        self.parts.wpn_fps_ass_g3_m_30mag.stats = deep_clone(mag_150)
        self.parts.wpn_fps_ass_g3_m_30mag.stats.extra_ammo = 10
    end

    if BeardLib.Utils:ModLoaded("Browning Auto Shotgun") then
        self.parts.wpn_fps_shot_auto5_b_short.stats = deep_clone(barrelsho_p1)
        self.parts.wpn_fps_shot_auto5_b_reinforced.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_auto5_s_pad.stats = deep_clone(nostats)
        self.parts.wpn_fps_shot_auto5_s_grip.stats = deep_clone(nostats)

        self.parts.wpn_fps_shot_auto5_m_extended.stats = {
            value = 0,
            extra_ammo = 2,
            concealment = -2
        }
        self.parts.wpn_fps_shot_auto5_m_long.stats = {
            value = 0,
            extra_ammo = 4,
            concealment = -3
        }
        self.parts.wpn_fps_shot_auto5_s_sawed.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }
    end

    if BeardLib.Utils:ModLoaded("M40A5") then
        table.insert(self.wpn_fps_snp_m40a5.uses_parts, "inf_bipod_snp")
        table.insert(gunlist_snp, {"wpn_fps_snp_m40a5", -3})
        self.parts.wpn_fps_snp_m40a5_m8541.custom_stats = {disallow_ads_while_reloading = true}
        self.parts.wpn_fps_snp_m40a5_mag.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_m40a5_omega.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_upg_m40a5_omega.stats = deep_clone(silstatssnp)
    end

    if BeardLib.Utils:ModLoaded("PKA-S Sight") then
        self.parts.wpn_fps_upg_o_pkas.stats = deep_clone(self.parts.wpn_fps_upg_o_aimpoint.stats)
        self.parts.wpn_fps_upg_o_pkas.customsight = true
    end

    if BeardLib.Utils:ModLoaded("Trijicon ACOG TA648 Scope") then
        self.parts.wpn_fps_upg_o_ta648.stats = {
            value = 0,
            zoom = 6,
            concealment = -3
        }
        self.parts.wpn_fps_upg_o_ta648.customsight = true
        self.parts.wpn_fps_upg_o_ta648.custom_stats = {disallow_ads_while_reloading = true}
    end

    if BeardLib.Utils:ModLoaded("Desert Tech MDR") then
        self.parts.wpn_fps_ass_mdr_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_mdr_vg_bcm.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_mdr_vg_fab_reg.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_mdr_vg_lt_fug.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_mdr_barrel_long.stats = deep_clone(barrel_m2)
        self.parts.wpn_fps_upg_mdr_comp.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)

        self.parts.wpn_fps_upg_mdr_mag_30.stats = deep_clone(mag_150)
        self.parts.wpn_fps_upg_mdr_mag_30.stats.extra_ammo = 10
        self.parts.wpn_fps_upg_mdr_pmag.stats = deep_clone(mag_150)
        self.parts.wpn_fps_upg_mdr_pmag.stats.extra_ammo = 10

        self.parts.wpn_fps_upg_mdr_supp_omega.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_mdr_supp_omega.stats = deep_clone(silstatsconc1)
    end

    if BeardLib.Utils:ModLoaded("FN SCAR-L") then
        self.parts.wpn_fps_upg_scarl_barrel_cqc.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_upg_scarl_barrel_cqc_mod.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_upg_scarl_upper_pdw.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_upg_scarl_barrel_long.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_upg_scarl_stock_cheek.stats = {
            value = 0,
            recoil = 2,
            concealment = -1
        }
        self.parts.wpn_fps_upg_scarl_stock_collapsed.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_upg_scarl_stock_pdw.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_upg_scarl_stock_pdw_collapsed.stats = {
            value = 0,
            recoil = -6,
            concealment = 3
        }

        self.parts.wpn_fps_upg_scarl_mag_pdw.stats = deep_clone(mag_66)
        self.parts.wpn_fps_upg_scarl_mag_pdw.stats.extra_ammo = -10

        --self.parts.wpn_fps_upg_scarl_grip_magpul_miad.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_scarl_grip_magpul_moe.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_scarl_grip_vindicator.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_scarl_mag_pull_assist.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_scarl_rail_nitro_v.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_scarl_rail_pws_srx.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_scarl_rail_vltor_casv.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_scarl_rail_kinetic_mrex.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_scarl_rail_midwest_ext.stats = deep_clone(nostats)
    end

    if BeardLib.Utils:ModLoaded("FN SCAR-L M203") then
        self.parts.wpn_fps_upg_scar_m203_barrel_long.stats = deep_clone(barrel_m2)

        self.parts.wpn_fps_upg_scar_m203_stock_collapsed.stats = {
            value = 0,
            recoil = -2,
            concealment = 1
        }
        self.parts.wpn_fps_upg_scar_m203_stock_pdw.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
        self.parts.wpn_fps_upg_scar_m203_sight.stats = {
            value = 0,
            gadget_zoom = 2,
            concealment = 0
        }

        --self.parts.wpn_fps_upg_scar_m203_grip_magpul_miad.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_scar_m203_grip_magpul_moe.stats = deep_clone(nostats)
        --self.parts.wpn_fps_upg_scar_m203_grip_vindicator.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_scar_m203_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_scar_m203_mag_pull_assist.stats = deep_clone(nostats)
    end

    --[[
    if BeardLib.Utils:ModLoaded("Kar98k") then
        self.parts.wpn_fps_snp_kar98k_b_medium.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_snp_kar98k_b_short.stats = deep_clone(barrel_p2)

        self.parts.wpn_fps_snp_kar98k_b_geha.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_kar98k_body_black.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_kar98k_body_1935.stats = deep_clone(nostats)
        self.parts.wpn_fps_snp_kar98k_body_1935_black.stats = deep_clone(nostats)

        self.parts.wpn_fps_snp_kar98k_b_sniper.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_snp_kar98k_b_sniper.stats = deep_clone(silstatssnp)

        self.parts.wpn_fps_snp_kar98k_m_geha.stats = {
            value = 0,
            extra_ammo = -2,
            spread = -30,
            concealment = 0
        }

    DelayedCalls:Add("kar98kdelay", delay, function(self, params)
        tweak_data.weapon.factory.parts.wpn_fps_snp_kar98k_iron_sight.stats = deep_clone(nostats)
        tweak_data.weapon.factory.parts.wpn_fps_snp_kar98k_iron_sight.stats.zoom = 0
        tweak_data.weapon.factory.parts.wpn_fps_upg_a_german12.custom_stats = {
            rays = 10,
            armor_piercing_add = 0,
            can_shoot_through_enemy = false, 
            can_shoot_through_shield = false, 
            can_shoot_through_wall = false,
            damage_far_mul = 0.15,
            damage_near_mul = 0.30,
        }
    end)
    end
    --]]

    if BeardLib.Utils:ModLoaded("SKS") then
        self.parts.wpn_fps_ass_sks_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_sks_mag_tapco.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_sks_supp_dtk4.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_sks_supp_dtk4.stats = deep_clone(silstatsconc1)
        self.parts.wpn_fps_upg_sks_supp_pbs1.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_sks_supp_pbs1.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_upg_sks_barrel_short_sksd.stats = deep_clone(barrel_p1)
        self.parts.wpn_fps_upg_sks_dtk1.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
        self.parts.wpn_fps_upg_sks_dtk2.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
    end

    if BeardLib.Utils:ModLoaded("MAS-49") then
        table.insert(gunlist_snp, {"wpn_fps_snp_mas49", -3})
        self.parts.wpn_fps_snp_mas49_scope_apx.custom_stats = {disallow_ads_while_reloading = true}

        self.parts.wpn_fps_upg_mas49_barrel_short.stats = deep_clone(barrel_p3)
        self.parts.wpn_fps_upg_mas49_irons.custom_stats = {sdesc3 = "misc_irons"}
        self.parts.wpn_fps_upg_mas49_irons.stats = {
            value = 0,
            concealment = 0 -- auto-bumped up to 3
        }
    end

    if BeardLib.Utils:ModLoaded("AK-12") then
        self.parts.wpn_fps_ass_ak12_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ak12_grip_molot.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ak12_mag_magpul.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_ak12_mag_quad.stats = deep_clone(mag_200)
        self.parts.wpn_fps_upg_ak12_mag_quad.stats.extra_ammo = 30
        self.parts.wpn_fps_upg_ak12_barrel_ak12u.stats = deep_clone(barrel_p2)
        self.parts.wpn_fps_upg_ak12_barrel_rpk12.stats = deep_clone(barrel_m2)
        self:convert_part("wpn_fps_upg_ak12_barrel_svk12", "lrifle", "ldmr")
        self.parts.wpn_fps_upg_ak12_barrel_svk12.stats.extra_ammo = -10
        self.parts.wpn_fps_upg_ak12_barrel_svk12.custom_stats.rof_mult = nil
        self.parts.wpn_fps_upg_ak12_barrel_svk12.custom_stats.sdesc1 = "caliber_r762x51"

        self.parts.wpn_fps_upg_ak12_dtk1.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
        self.parts.wpn_fps_upg_ak12_supp_tgp_a.custom_stats = silencercustomstats
        self.parts.wpn_fps_upg_ak12_supp_tgp_a.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
        
        self.parts.wpn_fps_upg_ak12_stock_folding.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
    end

    if BeardLib.Utils:ModLoaded("AK-12/76") and self.parts.wpn_fps_shot_ak12_76_mag then
        self.parts.wpn_fps_shot_ak12_76_mag.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ak12_76_grip_molot.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_ak12_76_mag_magpul.stats = deep_clone(nostats)

        self.parts.wpn_fps_upg_ak12_76_gk_01.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
        self.parts.wpn_fps_upg_ak12_76_stock_folding.stats = {
            value = 0,
            recoil = -4,
            concealment = 2
        }
    end

    if BeardLib.Utils:ModLoaded("RAZOR AMG UH-1") and self.parts.wpn_fps_upg_o_razoramg then
        self.parts.wpn_fps_upg_o_razoramg.customsight = true
        self.parts.wpn_fps_upg_o_razoramg.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)
    end

    if BeardLib.Utils:ModLoaded("Trijicon RMR Sight") and self.parts.wpn_fps_upg_o_rmr_riser then
        self.parts.wpn_fps_upg_o_rmr_riser.customsight = true
        self.parts.wpn_fps_upg_o_rmr_riser.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)
    end

    -- McMillan CS5
    if BeardLib.Utils:ModLoaded("McMillan CS5") and self.parts.wpn_fps_upg_cs5_barrel_short then
        -- Long barrel
        self.parts.wpn_fps_upg_cs5_barrel_long.stats = deep_clone(barrel_m1)
        -- Short barrel
        self.parts.wpn_fps_upg_cs5_barrel_short.stats = deep_clone(barrel_p2)
        -- Suppressed barrel
        self.parts.wpn_fps_upg_cs5_barrel_suppressed.custom_stats = snpsilencercustomstats
        self.parts.wpn_fps_upg_cs5_barrel_suppressed.stats = deep_clone(silstatssnp)
        -- Bipod
        self.parts.wpn_fps_upg_cs5_harris_bipod.stats = {
            value = 0,
            concealment = -1
        }
        self.parts.wpn_fps_upg_cs5_harris_bipod.custom_stats = {recoil_horizontal_mult = 2}

        -- Add the McMillan CS5 to be eligible for all the sniper custom parts, like the customizable Leupold
        table.insert(self.wpn_fps_snp_cs5.uses_parts, "wpn_fps_upg_o_spot")
        table.insert(self.wpn_fps_snp_cs5.uses_parts, "inf_shortdot")
        table.insert(self.wpn_fps_snp_cs5.uses_parts, "wpn_fps_upg_o_box")
        table.insert(gunlist_snp, {"wpn_fps_snp_cs5", -3})
    end

    -- FN SCAR MK17 (Eagle Tactical)
    if BeardLib.Utils:ModLoaded("MK17") and self.parts.wpn_fps_upg_mk17_b_smol then
        -- Long barrel
        self.parts.wpn_fps_upg_mk17_b_long.stats = deep_clone(barrel_m1)
        -- Short barrel
        self.parts.wpn_fps_upg_mk17_b_smol.stats = deep_clone(barrel_p1)

        -- Heavy Bolt, converts to light DMR
        self:convert_part("wpn_fps_upg_mk17_bolt_old", "hrifle", "ldmr")

        -- Extended Rail
        self.parts.wpn_fps_upg_mk17_ex_rail.stats = deep_clone(nostats)

        -- Night Ops Kit
        self.parts.wpn_fps_upg_mk17_rec_lower_black.stats = deep_clone(nostats)

        -- Speed-pull mag
        self.parts.wpn_fps_upg_mk17_m_quick.stats = deep_clone(nostats)

        -- Golden State magazine
        self.parts.wpn_fps_upg_mk17_m_smol.stats = {
            value = 0,
            extra_ammo = -10,
            concealment = 2
        }

        -- Extended stock
        self.parts.wpn_fps_upg_mk17_s_extended.stats = {
            value = 2,
            recoil = 2,
            concealment = -1
        }
        -- No stock
        self.parts.wpn_fps_upg_mk17_s_no.stats = {
            value = 1,
            recoil = -2,
            concealment = 1
        }

        -- DMR Kit, converts to DMR
        -- No shield piercing because that only seems to work on "ammo" weaponmod types >:(
        -- TODO: Give this part no stats, but give it a hidden DMR ammo dummy mod.
        self:convert_part("wpn_fps_upg_mk17_rec_upper_mk20", "hrifle", "dmr")
    end

    -- CARL WAS HERE AGAIN
    -- my own guns
    -- FN Five-seveN MK2
    if BeardLib.Utils:ModLoaded("Not Rarted Five-seveN") and self.parts.wpn_fps_upg_hoxy_o_scopemount then
        -- I REGRET NOTHING.
        -- threaded barrel
        self.parts.wpn_fps_upg_hoxy_b_threaded.stats = deep_clone(barrel_m1)

        -- +p+ boolet
        self:convert_part("wpn_fps_upg_hoxy_am_plusp", "lightpis", "mediumpis")

        -- um3 scope mount
        self.parts.wpn_fps_upg_hoxy_o_scopemount.stats = deep_clone(nostats)
        -- todo update this for when the gemtech sfn suppressor gets unfucked
    end

    -- ST AR-15
    if BeardLib.Utils:ModLoaded("Spikes Tactical AR-15") and self.parts.wpn_fps_upg_flat_bolt_sai then
        -- Remove ST AR-15 posthook because it causes issues, sorry
        Hooks:RemovePostHook("star15_init")

        self.parts.wpn_fps_upg_flat_bolt_sai.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_flat_fg_blk.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_flat_rec_lower_blk.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_flat_rec_upper_blk.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_flat_s_pod.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_flat_vg_no.stats = deep_clone(nostats)

        -- Silencer barrel ext
        self.parts.wpn_fps_upg_flat_ns_thic.stats = deep_clone(silstatsconc2)
        self.parts.wpn_fps_upg_flat_ns_thic.custom_stats = silencercustomstats

        -- Conversion kits for anti-materiel and regular AR
        -- Remove all the overrides and multiplications/custom stats first
        self.parts.wpn_fps_upg_flat_am_woof.custom_stats = {}
        self.parts.wpn_fps_upg_flat_am_woof.override_weapon_multiply = {}
        self.parts.wpn_fps_upg_flat_am_woof.override_weapon = {}
        self.parts.wpn_fps_upg_flat_am_woof.override = {}

        self.parts.wpn_fps_upg_flat_am_weak.custom_stats = {}
        self.parts.wpn_fps_upg_flat_am_weak.override_weapon_multiply = {}
        self.parts.wpn_fps_upg_flat_am_weak.override_weapon = {}
        self.parts.wpn_fps_upg_flat_am_weak.override = {}

        self:convert_part("wpn_fps_upg_flat_am_woof", "ldmr", "hdmr", 80, 40)
        self.parts.wpn_fps_upg_flat_am_woof.stats.extra_ammo = -20
        self.parts.wpn_fps_upg_flat_am_woof.custom_stats.sdesc1 = "caliber_r762x51dm151"
        -- Forbid using this with larger or smaller mags
        if not self.parts.wpn_fps_upg_flat_am_woof.forbids then
            self.parts.wpn_fps_upg_flat_am_woof.forbids = {}
        end
        table.insert(self.parts.wpn_fps_upg_flat_am_woof.forbids, "wpn_fps_upg_m4_m_quad")
        table.insert(self.parts.wpn_fps_upg_flat_am_woof.forbids, "wpn_fps_upg_m4_m_straight")
        if self.parts.wpn_fps_ass_m4_m_wick then
            table.insert(self.parts.wpn_fps_upg_flat_am_woof.forbids, "wpn_fps_ass_m4_m_wick")
        end

        self:convert_part("wpn_fps_upg_flat_am_weak", "ldmr", "mrifle", 80, 120)
        self.parts.wpn_fps_upg_flat_am_weak.custom_stats.sdesc1 = "caliber_r556x45"

        self.parts.wpn_fps_upg_flat_am_woof.override_weapon = {
            categories = { "snp" },
            sounds = {
                fire = "spikes_fire_bwlf",
                fire_single = "spikes_fire_bwlf"
            }
        }
    end

    -- Desert Eagle Duet
    -- Deagle XIX
    if BeardLib.Utils:ModLoaded("Desert Eagle XIX") and self.parts.wpn_fps_upg_deltaoneniner_frame_borat then
        -- Bling Frame
        self.parts.wpn_fps_upg_deltaoneniner_frame_borat.stats = deep_clone(nostats)
        -- Sweetheart Grip
        self.parts.wpn_fps_upg_deltaoneniner_g_waifu.stats = deep_clone(nostats)
        -- Extended Mag
        self.parts.wpn_fps_upg_deltaoneniner_m_extended.stats = deep_clone(mag_150)
        self.parts.wpn_fps_upg_deltaoneniner_m_extended.stats.extra_ammo = 3
    end

    -- Deagle L5
    if BeardLib.Utils:ModLoaded("Desert Eagle L5") and self.parts.wpn_fps_upg_limafive_frame_pink then
        -- Pink Frame
        self.parts.wpn_fps_upg_limafive_frame_pink.stats = deep_clone(nostats)
        -- Sweetheart Grip
        self.parts.wpn_fps_upg_limafive_g_waifu.stats = deep_clone(nostats)
        -- Extended Mag
        self.parts.wpn_fps_upg_limafive_m_extended.stats = deep_clone(mag_150)
        self.parts.wpn_fps_upg_limafive_m_extended.stats.extra_ammo = 3
        -- Dakota Special Slide
        self:convert_part("wpn_fps_upg_limafive_sl_morbid", "heavypis", "supermediumpis")
        self.parts.wpn_fps_upg_limafive_sl_morbid.custom_stats.sdesc1 = "caliber_p38spc"
    end

    -- HL1 9mm pistol
    if BeardLib.Utils:ModLoaded("Half Life 1 Glock") and self.parts.wpn_fps_pis_hl1g_suppress then
        self.parts.wpn_fps_pis_hl1g_suppress.custom_stats = silencercustomstats
        self.parts.wpn_fps_pis_hl1g_suppress.stats = deep_clone(silstatsconc1)
    end

    -- Glock 17 Gen 3
    -- So many calibers, holy
    if BeardLib.Utils:ModLoaded("Glock 17 Gen 3") then
        -- .22 LR conversion kit
        self.parts.wpn_fps_pis_glawk_a1_22lr.stats = deep_clone(nostats)
        self.parts.wpn_fps_pis_glawk_a1_22lr.stats.spread = -2
        self.parts.wpn_fps_pis_glawk_a1_22lr.stats.recoil = 2
        self.parts.wpn_fps_pis_glawk_a1_22lr.custom_stats.sdesc1 = "caliber_p22lr"

        -- .40 S&W conversion kit
        self:convert_part("wpn_fps_pis_glawk_a1_40sw", "lightpis", "mediumpis")
        self.parts.wpn_fps_pis_glawk_a1_40sw.custom_stats.sdesc1 = "caliber_p40sw"

        -- 10mm auto conversion kit
        self:convert_part("wpn_fps_pis_glawk_a2_10mm", "lightpis", "mediumpis")
        self.parts.wpn_fps_pis_glawk_a2_10mm.custom_stats.sdesc1 = "caliber_p10"

        -- .357 SIG conversion kit
        self:convert_part("wpn_fps_pis_glawk_a3_357sig", "lightpis", "supermediumpis")
        self.parts.wpn_fps_pis_glawk_a3_357sig.custom_stats.sdesc1 = "caliber_p357sig"

        -- .45 ACP conversion kit
        self:convert_part("wpn_fps_pis_glawk_a4_45acp", "lightpis", "supermediumpis")
        self.parts.wpn_fps_pis_glawk_a4_45acp.custom_stats.sdesc1 = "caliber_p45acp"

        -- .45 GAP conversion kit
        self:convert_part("wpn_fps_pis_glawk_a5_45gap", "lightpis", "supermediumpis")
        self.parts.wpn_fps_pis_glawk_a5_45gap.custom_stats.sdesc1 = "caliber_p45gap"

        -- Pachmayr Grip
        self.parts.wpn_fps_pis_glawk_gr_pachmayr.stats = deep_clone(nostats)
    end

    -- Glock 19
    if BeardLib.Utils:ModLoaded("Glock 19") and self.parts.wpn_fps_upg_g19_ammo_9mm_p then
        self:convert_part("wpn_fps_upg_g19_ammo_9mm_p", "lightpis", "mediumpis")
        self.parts.wpn_fps_upg_g19_ammo_9mm_p.custom_stats.sdesc1 = "caliber_p9x19nade"
    end

    -- TR-1
    if BeardLib.Utils:ModLoaded("TR-1") and self.parts.wpn_fps_ass_hugsforleon_upper then
        self.parts.wpn_fps_ass_hugsforleon_upper.stats = deep_clone(nostats)
    end

    -- ACR
    if BeardLib.Utils:ModLoaded("acwr") and self.parts.wpn_fps_ass_acwr_b_short then
        self.parts.wpn_fps_ass_acwr_b_short.stats = deep_clone(barrel_p1)
    end

    -- Dokkaebi M14
    if BeardLib.Utils:ModLoaded("Dokkaebi M14 modpack") and self.parts.wpn_fps_ass_m14_body_goblin then
        self.parts.wpn_fps_ass_m14_body_goblin.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_m14_body_goblin.custom_stats = {}
        
        -- By default this mod forbids the firemode mods, the M14 doesn't have these anymore
        -- There's no real reason to forbid anything except the scope mount then
        self.parts.wpn_fps_ass_m14_body_goblin.forbids = {
            "wpn_fps_upg_o_m14_scopemount"
        }
    end

    -- Dokkaebi SMG-12
    if BeardLib.Utils:ModLoaded("Dokkaebi SMG12 modpack") and self.parts.wpn_fps_mp_master_m_standard then
        -- No speedpull speed
        self.parts.wpn_fps_mp_master_m_standard.stats = deep_clone(nostats)

        -- Large mag
        self.parts.wpn_fps_mp_master_m_extended.stats = deep_clone(mag_200)
        self.parts.wpn_fps_mp_master_m_extended.stats.extra_ammo = 15

        -- No stock
        self.parts.wpn_fps_mp_master_s_no.stats = {
            value = 0,
            recoil = -2,
            concealment = 2
        }
        -- Folded stock
        self.parts.wpn_fps_mp_master_s_extended.stats = {
            value = 0,
            recoil = -1,
            concealment = 1
        }

        -- Silencer
        self.parts.wpn_fps_mp_master_ns_silent.custom_stats = silencercustomstats
        self.parts.wpn_fps_mp_master_ns_silent.stats = deep_clone(silstatsconc2)

        -- Foregrips
        self.parts.wpn_fps_mp_master_vg_angle.stats = deep_clone(nostats)
        self.parts.wpn_fps_mp_master_vg_straight.stats = deep_clone(nostats)
    end

    -- Triton TR-15
    if BeardLib.Utils:ModLoaded("Triton TR-15") and self.parts.wpn_fps_ass_hometown_ba_wylde then
        self.parts.wpn_fps_ass_hometown_ba_wylde.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_hometown_st_moe_bp.stats = deep_clone(nostats)
        self.parts.wpn_fps_ass_hometown_st_slk.stats = deep_clone(nostats)
    end

    -- TTI Pack
    if BeardLib.Utils:ModLoaded("TTI Attachment Pack") and self.parts.wpn_fps_upg_g22c_body_tti then
        self.parts.wpn_fps_upg_g22c_body_tti.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_m_tti.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_g22c_sl_tti.stats = deep_clone(barrel_m1)
        self.parts.wpn_fps_upg_shepheard_m_tti.stats = deep_clone(nostats)
        self.parts.wpn_fps_upg_s_tti.stats = deep_clone(nostats)

        -- Extended mag for MPX
        self.parts.wpn_fps_upg_shepheard_m_tti_ext.stats = deep_clone(mag_200)
        self.parts.wpn_fps_upg_shepheard_m_tti_ext.stats.extra_ammo = 15
        self.wpn_fps_smg_x_shepheard.override.wpn_fps_upg_shepheard_m_tti_ext = self.wpn_fps_smg_x_shepheard.override.wpn_fps_upg_shepheard_m_tti_ext or {}
        self.wpn_fps_smg_x_shepheard.override.wpn_fps_upg_shepheard_m_tti_ext.stats = deep_clone(self.parts.wpn_fps_upg_shepheard_m_tti_ext.stats)
        self.wpn_fps_smg_x_shepheard.override.wpn_fps_upg_shepheard_m_tti_ext.stats.extra_ammo = self.wpn_fps_smg_x_shepheard.override.wpn_fps_upg_shepheard_m_tti_ext.stats.extra_ammo * 2
        self.wpn_fps_smg_x_shepheard.override.wpn_fps_upg_shepheard_m_tti_ext.stats.reload = self.wpn_fps_smg_x_shepheard.override.wpn_fps_upg_shepheard_m_tti_ext.stats.reload - 15
    end

    -- M45 MEUSOC threaded barrel
    if self.parts.wpn_fps_pis_meusoc_b_thr then
        self.parts.wpn_fps_pis_meusoc_b_thr.stats = deep_clone(nostats)
    end

    -- Trench Gun 1897
    if BeardLib.Utils:ModLoaded("Trench Shotgun") and self.parts.wpn_fps_shot_trench_b_long then
        self.parts.wpn_fps_shot_trench_b_long.stats = deep_clone(barrelsho_m1)
        self.parts.wpn_fps_shot_trench_bayonet.stats = {
            value = 0,
            min_damage = 10.0,
            max_damage = 10.0,
            min_damage_effect = 0.10,
            max_damage_effect = 0.10,
            concealment = -2,
            range = 100
        }
        self.parts.wpn_fps_shot_trench_bayonet.perks = {
            "bayonet"
        }
        self.parts.wpn_fps_shot_trench_s_rack.stats = {
            value = 1,
            reload = 5,
            concealment = -1
        }
        self.parts.wpn_fps_shot_trench_s_chinrest.stats = deep_clone(nostats)

        -- Remove stats override from shell rack
        self.wpn_fps_shot_trench.override.wpn_fps_shot_r870_body_rack = nil
    end

    -- HOW TO ADD CUSTOM WEAPON MOD SUPPORT
    -- This applies to any BeardLib mod that adds custom weapon mods, whether they come with an actual weapon or not.
    -- You first need the weapon mod's ID, which can be found in the mod's XML files (such as main.xml).

    -- You need to check if the BeardLib mod is loaded, but also check if at least 1 given part is not nil.
    -- This will help prevent crashes if someone else makes a beardlib mod with the same name, or if the author drastically changes their weapon mods around.
    -- The BeardLib mod's name is actually defined in the main.xml file. This is <table name="mymod">, where the name would then be "mymod".

    -- Example:
    -- if BeardLib.Utils:ModLoaded("Glock 19") and self.parts.wpn_fps_upg_g19_ammo_9mm_p then
        -- This is a "conversion mod". It converts the weapon from A to B. In this case, this higher-caliber ammo changes the glock 19 from a light pistol into a medium pistol,
        -- effectively making it equal to other medium pistols such as the Crosskill.
        -- The from/to is based on the weapon values in InfMenu (infcore.lua). So it's not "pistol light", but "lightpis".
        -- self:convert_part("wpn_fps_upg_g19_ammo_9mm_p", "lightpis", "mediumpis")
        -- This also changes the caliber in the weapon's short description.
        -- self.parts.wpn_fps_upg_g19_ammo_9mm_p.custom_stats.sdesc1 = "caliber_p9x19nade"
    -- end

    -- One note about conversion kits (especially to/from DMR's) is that shield and enemy piercing gets iffy
    -- if you try to apply that to a weaponmod that isn't of the "ammo" type.

    -- This is something you will see a lot. Any weapon mod that shouldn't have any stat changes (grips, front guards etc) should have its stats cloned from the "nostats" table.
    -- self.parts.wpn_fps_pis_glawk_gr_pachmayr.stats = deep_clone(nostats)

    -- Silencers are another common feature. Clone their stats from the most appropriate silencer preset (depending on size) and also clone the silencer custom stats.
    -- self.parts.wpn_fps_pis_hl1g_suppress.custom_stats = silencercustomstats
    -- self.parts.wpn_fps_pis_hl1g_suppress.stats = deep_clone(silstatsconc1)

    -- Barrels is something you see often, these also have presets. There's long/longer, short/shorter, etc.
    -- m1 and m2 are long/longer, p1 and p2 are short/shorter.
    -- There's more, you can find them further up in this file.
    -- self.parts.wpn_fps_ass_myar_barrel.stats = deep_clone(barrel_m1)

    -- For anything else (such as sights) you'll just have to look at other weaponmods added in this file.
    -- The most useful ones for you to look at will probably be other custom ones, but vanilla mods might also give you some insight.

    -- For custom weapons that have additional tweakdata in weapontweakdata or weaponfactorytweakdata, sometimes their code runs after InF does.
    -- The best way to fix this is to remove their PostHook using Hooks:RemovePostHook("hook_id")
    -- If that hook normally does some required setup work (such as mod compatibility or custom attachment points) then please do so in your code as well.
    -- A delayed call can also be done to fix the tweakdata but this is incredibly unreliable.

    -- Finally, please use a code editor that can spot and highlight syntax errors for you. Test it out and make sure it catches errors.
    -- Visual Studio Code has a few addons that merely highlight Lua syntax, but there are others that also highlight syntax errors. Get one of those.
end
