--[[
POISON NOTE
applied every 0.5s, 1s if melee
first DoT dealt after 0.5s
--]]

if not tweak_data then return end

-- grenade
tweak_data.projectiles.frag.damage = 60.0

-- molotov central patch
tweak_data.projectiles.molotov.damage = 5.0
tweak_data.projectiles.molotov.fire_dot_data.dot_damage = 5.0
tweak_data.projectiles.molotov.fire_dot_data.dot_length = 6.1

tweak_data.projectiles.fir_com.fire_dot_data.dot_damage = 7.5
--tweak_data.projectiles.fir_com.fire_dot_data.dot_length = 2.1 -- every 0.5 sec

tweak_data.projectiles.wpn_prj_four.damage = 10.0
--tweak_data.projectiles.wpn_prj_four.launch_speed = 1500
--tweak_data.projectiles.wpn_prj_four.adjust_z = 0
tweak_data.projectiles.wpn_prj_ace.damage = 11.0
--tweak_data.projectiles.wpn_prj_ace.launch_speed = 1500
--tweak_data.projectiles.wpn_prj_ace.adjust_z = 0
tweak_data.projectiles.wpn_prj_target.damage = 22.0
tweak_data.projectiles.wpn_prj_target.launch_speed = 1250
tweak_data.projectiles.wpn_prj_target.adjust_z = 60
tweak_data.projectiles.wpn_prj_hur.damage = 40.0
tweak_data.projectiles.wpn_prj_hur.launch_speed = 1250
tweak_data.projectiles.wpn_prj_hur.adjust_z = 60
tweak_data.projectiles.wpn_prj_jav.damage = 150.0
--tweak_data.projectiles.wpn_prj_jav.launch_speed = 1500
--tweak_data.projectiles.wpn_prj_jav.adjust_z = 30

tweak_data.projectiles.smoke_screen_grenade.base_cooldown = 30	


tweak_data.dot_types = {poison = {
	damage_class = "PoisonBulletBase",
	dot_damage = 2.0,
	dot_length = 5.1,
	hurt_animation_chance = 1
}}

-- gl40/m32/compact
tweak_data.projectiles.launcher_frag.damage = 60.0
--tweak_data.projectiles.launcher_frag_m32.damage = 1.0 -- doesn't do shit
--tweak_data.projectiles.launcher_frag_slap.damage = 1.0 -- doesn't do shit either
--tweak_data.projectiles.launcher_m203.damage = 1.0 -- you wanna bet this does fuckin anything
tweak_data.projectiles.launcher_incendiary.damage = 1.0
tweak_data.projectiles.launcher_incendiary.fire_dot_data.dot_damage = 5.0
tweak_data.projectiles.launcher_incendiary_m32.damage = 1.0
tweak_data.projectiles.launcher_incendiary_m32.fire_dot_data.dot_damage = 5.0
tweak_data.projectiles.launcher_incendiary_slap.damage = 1.0
tweak_data.projectiles.launcher_incendiary_slap.fire_dot_data.dot_damage = 5.0

-- china lake
tweak_data.projectiles.launcher_frag_china.damage = 60.0
tweak_data.projectiles.launcher_incendiary_china.damage = 1.0
tweak_data.projectiles.launcher_incendiary_china.fire_dot_data.dot_damage = 5.0

-- arbiter
tweak_data.projectiles.launcher_frag_arbiter.damage = 30.0
tweak_data.projectiles.launcher_incendiary_arbiter.damage = 1.0
tweak_data.projectiles.launcher_incendiary_arbiter.fire_dot_data.dot_damage = 5.0


--tweak_data.projectiles.launcher_rocket.damage = 1250.0
--tweak_data.projectiles.rocket_ray_frag.damage = 620.0


-- plainsrider
tweak_data.projectiles.west_arrow.damage = 40.0
tweak_data.projectiles.bow_poison_arrow.damage = 20.0
tweak_data.projectiles.west_arrow_exp.damage = 40.0

tweak_data.projectiles.west_arrow.launch_speed = 3500
tweak_data.projectiles.west_arrow.adjust_z = -100
tweak_data.projectiles.bow_poison_arrow.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.bow_poison_arrow.adjust_z = tweak_data.projectiles.west_arrow.adjust_z
tweak_data.projectiles.west_arrow_exp.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.west_arrow_exp.adjust_z = tweak_data.projectiles.west_arrow.adjust_z

-- longbow
tweak_data.projectiles.long_arrow.damage = 50.0
tweak_data.projectiles.long_poison_arrow.damage = 35.0
tweak_data.projectiles.long_arrow_exp.damage = 50.0

tweak_data.projectiles.long_arrow.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.long_arrow.adjust_z = tweak_data.projectiles.west_arrow.adjust_z
tweak_data.projectiles.long_poison_arrow.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.long_poison_arrow.adjust_z = tweak_data.projectiles.west_arrow.adjust_z
tweak_data.projectiles.long_arrow_exp.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.long_arrow_exp.adjust_z = tweak_data.projectiles.west_arrow.adjust_z

-- compound bow
tweak_data.projectiles.elastic_arrow.damage = 50.0
tweak_data.projectiles.elastic_arrow_poison.damage = 35.0
tweak_data.projectiles.elastic_arrow_exp.damage = 50.0

tweak_data.projectiles.elastic_arrow.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.elastic_arrow.adjust_z = -130
tweak_data.projectiles.elastic_arrow_poison.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.elastic_arrow_poison.adjust_z = -130
tweak_data.projectiles.elastic_arrow_exp.launch_speed = tweak_data.projectiles.west_arrow.launch_speed
tweak_data.projectiles.elastic_arrow_exp.adjust_z = -130

-- pistol crossbow
tweak_data.projectiles.crossbow_arrow.damage = 25.0
tweak_data.projectiles.crossbow_poison_arrow.damage = 10.0
tweak_data.projectiles.crossbow_arrow_exp.damage = 25.0

tweak_data.projectiles.crossbow_arrow.launch_speed = 2000
tweak_data.projectiles.crossbow_arrow.adjust_z = 50
tweak_data.projectiles.crossbow_poison_arrow.launch_speed = 2000
tweak_data.projectiles.crossbow_poison_arrow.adjust_z = 50
tweak_data.projectiles.crossbow_arrow_exp.launch_speed = 2000
tweak_data.projectiles.crossbow_arrow_exp.adjust_z = 50

-- light crossbow
tweak_data.projectiles.frankish_arrow.damage = 40.0
tweak_data.projectiles.frankish_poison_arrow.damage = 25.0
tweak_data.projectiles.frankish_arrow_exp.damage = 40.0

tweak_data.projectiles.frankish_arrow.launch_speed = 3000
tweak_data.projectiles.frankish_arrow.adjust_z = 0
tweak_data.projectiles.frankish_poison_arrow.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.frankish_poison_arrow.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z
tweak_data.projectiles.frankish_arrow_exp.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.frankish_arrow_exp.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z

-- heavy crossbow
tweak_data.projectiles.arblast_arrow.damage = 100.0
tweak_data.projectiles.arblast_poison_arrow.damage = 85.0
tweak_data.projectiles.arblast_arrow_exp.damage = 100.0

tweak_data.projectiles.arblast_arrow.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.arblast_arrow.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z
tweak_data.projectiles.arblast_poison_arrow.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.arblast_poison_arrow.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z
tweak_data.projectiles.arblast_arrow_exp.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.arblast_arrow_exp.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z

-- airbow
tweak_data.projectiles.ecp_arrow.damage = 22.0
tweak_data.projectiles.ecp_arrow_poison.damage = 7.0
tweak_data.projectiles.ecp_arrow_exp.damage = 22.0

tweak_data.projectiles.arblast_arrow.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.arblast_arrow.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z
tweak_data.projectiles.arblast_poison_arrow.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.arblast_poison_arrow.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z
tweak_data.projectiles.arblast_arrow_exp.launch_speed = tweak_data.projectiles.frankish_arrow.launch_speed
tweak_data.projectiles.arblast_arrow_exp.adjust_z = tweak_data.projectiles.frankish_arrow.adjust_z