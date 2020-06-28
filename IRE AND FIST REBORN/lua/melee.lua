function BlackMarketTweakData:getmindmg(wpnname)
	return self.melee_weapons[wpnname].stats.min_damage * 10
end
function BlackMarketTweakData:getmaxdmg(wpnname)
	return self.melee_weapons[wpnname].stats.max_damage * 10
end

function BlackMarketTweakData:applystats(wpn, stats)
	self.melee_weapons[wpn].stats.min_damage = stats[1]
	self.melee_weapons[wpn].stats.max_damage = stats[2]
	self.melee_weapons[wpn].stats.min_damage_effect = stats[3]/self:getmindmg(wpn)
	self.melee_weapons[wpn].stats.max_damage_effect = stats[4]/self:getmaxdmg(wpn)
	self.melee_weapons[wpn].stats.charge_time = stats[5]
end

-- TODO: GET RID OF CHARGING SOUNDS FOR MOST WEAPONS
-- TODO: WEAPON RANGE
-- TODO: CONCEALMENT VS STATS
-- cap base knockdown to 666

-- early expire helps prevent magical floating weapons from sprintjumping

--[[
GOOD CHARGED SOUNDS
psycho
brick
road
--]]


--[[
MELEE_KNIFE
reverse grip
var1 = point stab and stop because there are no stop animations
var2 = left-to-right swing
var3 = right-to-left downstab
var4 = right-to-left downstab (identical?)
--]]
function BlackMarketTweakData:melee_knife_stick(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_knife"
	self.melee_weapons[wpn].anim_attack_vars = {"var1"}
	self.melee_weapons[wpn].repeat_expire_t = 0.70
	self.melee_weapons[wpn].expire_t = 1.60
	self.melee_weapons[wpn].early_expire_t = 0.60
	self.melee_weapons[wpn].melee_damage_delay = 0.1
	self.melee_weapons[wpn].speed_mult = 1.35
end
function BlackMarketTweakData:melee_knife_swing(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_knife"
	self.melee_weapons[wpn].anim_attack_vars = {"var3", "var4"}
	self.melee_weapons[wpn].repeat_expire_t = 0.40
	self.melee_weapons[wpn].expire_t = 1.00
	self.melee_weapons[wpn].early_expire_t = 0.45
	self.melee_weapons[wpn].melee_damage_delay = 0.1
	self.melee_weapons[wpn].speed_mult = 1.00
end

function BlackMarketTweakData:melee_psycho(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_psycho"
	self.melee_weapons[wpn].repeat_expire_t = 0.35
	self.melee_weapons[wpn].expire_t = 1.00
	self.melee_weapons[wpn].early_expire_t = 0.50
	self.melee_weapons[wpn].melee_damage_delay = 0.1
	self.melee_weapons[wpn].speed_mult = 1
end

--[[
MELEE_KNIFE2
saber grip
var1 = horizontal left-to-right swing
var2 = horizontal left-to-right swing (identical?)
var3 = horizontal right-to-left swing
var4 = slightly-diagonal right-to-left swing
--]]



--[[
MELEE_FIST
var1 = right jab
var2 = right hook
var3 = left hook
var4 = left jab
--]]
function BlackMarketTweakData:melee_fist(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_fist"
	self.melee_weapons[wpn].anim_attack_vars = {"var1", "var4"}
	self.melee_weapons[wpn].repeat_expire_t = 0.30
	self.melee_weapons[wpn].expire_t = 1
	self.melee_weapons[wpn].early_expire_t = 0
	self.melee_weapons[wpn].melee_damage_delay = 0.2
	self.melee_weapons[wpn].sounds.charge = nil
	self.melee_weapons[wpn].speed_mult = 1.50
end

-- NOT CHECKED!!
-- currently briefly re-equipping primary before a second swing even at best attack rate
function BlackMarketTweakData:melee_fist_slow(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_fist"
	self.melee_weapons[wpn].anim_attack_vars = {"var2", "var3"}
	self.melee_weapons[wpn].repeat_expire_t = 0.50
	self.melee_weapons[wpn].expire_t = 1
	self.melee_weapons[wpn].early_expire_t = 0
	self.melee_weapons[wpn].melee_damage_delay = 0.10
	self.melee_weapons[wpn].sounds.charge = nil
	self.melee_weapons[wpn].speed_mult = 1.50
end

--[[
MELEE_BLUNT
var1 = downbonk
var2 = right-to-left with pause
var3 = right-to-left with pause
var4 = downbonk
--]]

--[[
MELEE_AXE
very similar diagonals
--]]
function BlackMarketTweakData:melee_axe(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_axe"
	self.melee_weapons[wpn].repeat_expire_t = 0.40
	self.melee_weapons[wpn].expire_t = 0.85
	self.melee_weapons[wpn].early_expire_t = 0.45
	self.melee_weapons[wpn].melee_damage_delay = 0.10
	--self.melee_weapons[wpn].sounds.charge = nil
	self.melee_weapons[wpn].speed_mult = 0.80
end



function BlackMarketTweakData:melee_stab(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_stab"
	self.melee_weapons[wpn].repeat_expire_t = 0.30
	self.melee_weapons[wpn].expire_t = 0.90
	self.melee_weapons[wpn].early_expire_t = 0.35
	self.melee_weapons[wpn].melee_damage_delay = 0.1
	self.melee_weapons[wpn].speed_mult = 1
end

function BlackMarketTweakData:melee_machete(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_machete"
	self.melee_weapons[wpn].repeat_expire_t = 0.35
	self.melee_weapons[wpn].expire_t = 0.80
	self.melee_weapons[wpn].early_expire_t = 0.40
	self.melee_weapons[wpn].melee_damage_delay = 0.15
	--self.melee_weapons[wpn].sounds.charge = nil
	self.melee_weapons[wpn].speed_mult = 0.80
end


function BlackMarketTweakData:melee_baseballbat(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_baseballbat"
	self.melee_weapons[wpn].repeat_expire_t = 0.80
	self.melee_weapons[wpn].expire_t = 1.40
	self.melee_weapons[wpn].early_expire_t = 0.50
	self.melee_weapons[wpn].melee_damage_delay = 0.20
	--self.melee_weapons[wpn].sounds.charge = nil
	self.melee_weapons[wpn].speed_mult = 1
end

-- same as melee_baseballbat?
--[[
function BlackMarketTweakData:melee_baseballbat_miami(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_baseballbat_miami"
	self.melee_weapons[wpn].repeat_expire_t = 0.80
	self.melee_weapons[wpn].expire_t = 1.20
	self.melee_weapons[wpn].early_expire_t = 0.00
	self.melee_weapons[wpn].melee_damage_delay = 0.20
	--self.melee_weapons[wpn].sounds.charge = nil
	self.melee_weapons[wpn].speed_mult = 1
end
--]]

function BlackMarketTweakData:melee_great(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_great"
	self.melee_weapons[wpn].repeat_expire_t = 1.10
	self.melee_weapons[wpn].expire_t = 1.70
	self.melee_weapons[wpn].early_expire_t = 0.50
	self.melee_weapons[wpn].melee_damage_delay = 0.60
	--self.melee_weapons[wpn].sounds.charge = nil
	self.melee_weapons[wpn].speed_mult = 1.25
end

function BlackMarketTweakData:melee_taser(wpn)
	self.melee_weapons[wpn].anim_global_param = "melee_taser"
	self.melee_weapons[wpn].repeat_expire_t = 0.50
	self.melee_weapons[wpn].expire_t = 1.00
	self.melee_weapons[wpn].early_expire_t = 0.40
	self.melee_weapons[wpn].melee_damage_delay = 0.1
	self.melee_weapons[wpn].speed_mult = 1
end




--[[
melee_blunt -- poker anims
--]]



Hooks:PostHook(BlackMarketTweakData, "_init_melee_weapons", "inflern2melee", function(self, params)
	for _, wpn in pairs(self.melee_weapons) do
		-- remove obnoxious screen-shifting from charging a melee
		wpn.melee_charge_shaker = "player_melee_charge_wing"
		-- remove dumb stretching sound when charging
		wpn.sounds.charge = nil
	end


	local meleeval = {}
	-- dmg, chargedmg, knock, chargeknock, chargetime
	meleeval.veryfastknife = {4.0, 6.0, 10, 15, 1}
	meleeval.fastknife = {6.0, 10.0, 20, 40, 1}
	meleeval.bigknife = {7.5, 14.0, 25, 50, 1}
	meleeval.machete = {8.0, 16.0, 40, 80, 2}
	meleeval.bigshank = {10.0, 20.0, 50, 100, 2}
	meleeval.baton = {0.5, 1.0, 450, 600, 1}
	meleeval.beatstick = {4.5, 10.0, 200, 500, 2}
	meleeval.smackstick = {6.5, 9.0, 180, 400, 2}
	meleeval.whackstick = {7.5, 10.0, 150, 350, 2}
	meleeval.battaswing = {9.0, 18.0, 250, 600, 2}
	meleeval.sledgehammer = {10.0, 18.0, 300, 666, 3}
	meleeval.zapper = {1.5, 1.5, 666, 666, 2}





	-- Weapon Butt
	self.melee_weapons.weapon.infname = "Z. Weapon Butt"
	self.melee_weapons.weapon.stats.min_damage = 5.5
	self.melee_weapons.weapon.stats.max_damage = 5.5
	self.melee_weapons.weapon.stats.min_damage_effect = 200/self:getmindmg("weapon")
	self.melee_weapons.weapon.stats.max_damage_effect = 200/self:getmaxdmg("weapon")
	self.melee_weapons.weapon.stats.range = 180
	self.melee_weapons.weapon.stats.concealment = 30

	-- alabama razor
	self.melee_weapons.clean.infname = "As. Alabama Razor"
	self.melee_weapons.clean.repeat_expire_t = 0.20
	self.melee_weapons.clean.expire_t = 0.60
	self.melee_weapons.clean.early_expire_t = 0.40
	self.melee_weapons.clean.melee_damage_delay = 0.10
	self.melee_weapons.clean.speed_mult = 0.80
	self:applystats("clean", meleeval.veryfastknife)
	-- Berger
	self.melee_weapons.gerber.infname = "A. Berger Knife"
	self:melee_knife_swing("gerber")
	self:applystats("gerber", meleeval.fastknife)
	-- butterfly knife
	self.melee_weapons.wing.infname = "A. Wing Butterfly Knife"
	self:applystats("wing", meleeval.fastknife)
	self.melee_weapons.wing.repeat_expire_t = 0.30
	self.melee_weapons.wing.expire_t = 0.80
	self.melee_weapons.wing.early_expire_t = 0.40
	self.melee_weapons.wing.sounds.charge = "wing_charge"
	-- psycho knife
	self.melee_weapons.chef.infname = "A. Psycho Knife"
	self:melee_psycho("chef")
	self.melee_weapons.chef.stats.min_damage = 5.5
	self.melee_weapons.chef.stats.max_damage = 16.5
	self.melee_weapons.chef.stats.min_damage_effect = 1/self:getmindmg("chef")
	self.melee_weapons.chef.stats.max_damage_effect = 5/self:getmaxdmg("chef")
	self.melee_weapons.chef.stats.charge_time = 3
	self.melee_weapons.chef.sounds.charge = "halloween_charge"
	-- shawn's shears
	self.melee_weapons.shawn.infname = "A. Shawn's Shears"
	self:melee_psycho("shawn")
	self:applystats("shawn", meleeval.fastknife)

	-- Utility Knife/Boxcutter
	self.melee_weapons.boxcutter.infname = "As. Boxcutter"
	self.melee_weapons.boxcutter.repeat_expire_t = 0.30
	self.melee_weapons.boxcutter.expire_t = 0.70
	self.melee_weapons.boxcutter.early_expire_t = 0.35
	self:applystats("boxcutter", meleeval.veryfastknife)
	-- diving knife
	self.melee_weapons.pugio.infname = "As. Diving Knife"
	self:melee_stab("pugio")
	self:applystats("pugio", meleeval.veryfastknife)
	-- switchblade
	self.melee_weapons.switchblade.infname = "As. Switchblade"
	self:melee_stab("switchblade")
	self:applystats("switchblade", meleeval.veryfastknife)
	-- motherforker
	self.melee_weapons.fork.infname = "As. Motherforker"
	self:melee_stab("fork")
	self:applystats("fork", meleeval.veryfastknife)
	-- trench knife
	self.melee_weapons.fairbair.infname = "As. Trench Knife"
	self:melee_stab("fairbair")
	self:applystats("fairbair", meleeval.veryfastknife) -- faster and weaker archetype?
	-- nova shank
	self.melee_weapons.toothbrush.infname = "As. Toothbrush"
	self:melee_stab("toothbrush")
	self:applystats("toothbrush", meleeval.veryfastknife) -- faster and weaker archetype?
	-- knuckle daggers
	self.melee_weapons.grip.infname = "As. Knuckle Daggers"
	self:applystats("grip", meleeval.veryfastknife) -- faster and weaker archetype?
	self.melee_weapons.grip.repeat_expire_t = 0.20
	self.melee_weapons.grip.expire_t = 0.70
	self.melee_weapons.grip.repeat_expire_t = 0.45
	self.melee_weapons.grip.melee_damage_delay = 0.05
	self.melee_weapons.grip.speed_mult = 1.30
	-- the pen
	self.melee_weapons.sword.infname = "As. A Fucking Pencil"
	self:melee_stab("sword")
	self:applystats("sword", meleeval.veryfastknife)
	-- push daggers
	self.melee_weapons.push.infname = "As. Push Daggers"
	self:melee_fist("push")
	self:applystats("push", meleeval.veryfastknife)
	self.melee_weapons.push.speed_mult = 0.80

	-- kunai
	self.melee_weapons.cqc.infname = "As. Kunai"
	self:melee_stab("cqc")
	self.melee_weapons.cqc.stats.min_damage = 2.0
	self.melee_weapons.cqc.stats.max_damage = 4.0
	self.melee_weapons.cqc.stats.min_damage_effect = 10/self:getmindmg("cqc")
	self.melee_weapons.cqc.stats.max_damage_effect = 25/self:getmaxdmg("cqc")
	self.melee_weapons.cqc.stats.charge_time = 1
	-- syringe
	self.melee_weapons.fear.infname = "As. Syringe"
	self.melee_weapons.fear.repeat_expire_t = 0.50
	self.melee_weapons.fear.expire_t = 1.20
	self.melee_weapons.fear.early_expire_t = 0.60
	self.melee_weapons.fear.stats.min_damage = 2.0
	self.melee_weapons.fear.stats.max_damage = 10.0
	self.melee_weapons.fear.stats.min_damage_effect = 10/self:getmindmg("fear")
	self.melee_weapons.fear.stats.max_damage_effect = 25/self:getmaxdmg("fear")
	self.melee_weapons.fear.stats.charge_time = 1
	self.melee_weapons.fear.speed_mult = 1
	-- hook
	self.melee_weapons.catch.infname = "A. Hook"
	self.melee_weapons.catch.repeat_expire_t = 0.20
	self.melee_weapons.catch.expire_t = 0.60
	self.melee_weapons.catch.early_expire_t = 0.35
	self.melee_weapons.catch.stats.min_damage = 8.0 -- reduce damage/knock?
	self.melee_weapons.catch.stats.max_damage = 10.0
	self.melee_weapons.catch.stats.min_damage_effect = 60/self:getmindmg("catch")
	self.melee_weapons.catch.stats.max_damage_effect = 180/self:getmaxdmg("catch")
	self.melee_weapons.catch.stats.charge_time = 2
	self.melee_weapons.catch.speed_mult = 0.50
	-- talons (silent charge sound??)
	self.melee_weapons.tiger.infname = "A. Talons"
	self:melee_fist("tiger")
	self.melee_weapons.tiger.stats.min_damage = 5.0
	self.melee_weapons.tiger.stats.max_damage = 10.0
	self.melee_weapons.tiger.stats.min_damage_effect = 30/self:getmindmg("tiger")
	self.melee_weapons.tiger.stats.max_damage_effect = 75/self:getmaxdmg("tiger")
	self.melee_weapons.tiger.stats.charge_time = 2
	self.melee_weapons.tiger.speed_mult = 1.00


	-- Krieger
	self.melee_weapons.kampfmesser.infname = "Ba. Krieger Knife"
	self:melee_knife_stick("kampfmesser")
	self:applystats("kampfmesser", meleeval.bigknife)
	-- Trautman
	self.melee_weapons.rambo.infname = "Ba. Trautman"
	self:melee_knife_stick("rambo") -- more damage and slower?
	self:applystats("rambo", meleeval.bigknife)
	-- URSA Tanto
	self.melee_weapons.kabartanto.infname = "Ba. Kabar Tanto"
	self:melee_knife_stick("kabartanto")
	self:applystats("kabartanto", meleeval.bigknife)
	-- Arkansas Toothpick
	self.melee_weapons.bowie.infname = "Ba. Arkansas Toothpick"
	self:melee_knife_stick("bowie") -- more damage and slower?
	self:applystats("bowie", meleeval.bigknife)

	-- URSA
	self.melee_weapons.kabar.infname = "B. URSA Knife"
	self:melee_knife_swing("kabar")
	self:applystats("kabar", meleeval.fastknife) -- should ursa be using fastknife?
	-- Bayonet Knife
	self.melee_weapons.bayonet.infname = "B. Bayonet Knife"
	self:melee_knife_swing("bayonet")
	self:applystats("bayonet", meleeval.fastknife)
	-- Scout Knife
	self.melee_weapons.scoutknife.infname = "B. Scout Knife"
	self:melee_knife_swing("scoutknife")
	self:applystats("scoutknife", meleeval.fastknife)
	-- ballistic knife
	self.melee_weapons.ballistic.infname = "B. Ballistic Knife"
	self:applystats("ballistic", meleeval.fastknife)
	self.melee_weapons.ballistic.repeat_expire_t = 0.40
	self.melee_weapons.ballistic.expire_t = 1.10
	self.melee_weapons.ballistic.early_expire_t = 0.60
	-- x-46
	self.melee_weapons.x46.infname = "B. X-46 Knife"
	self:melee_knife_swing("x46")
	self:applystats("x46", meleeval.fastknife)

	-- kento's tanto
	self.melee_weapons.hauteur.infname = "B. Kento's Tanto"
	self.melee_weapons.hauteur.repeat_expire_t = 0.40
	self.melee_weapons.hauteur.expire_t = 1.30
	self.melee_weapons.hauteur.early_expire_t = 0.60
	self.melee_weapons.hauteur.stats.min_damage = 8.0
	self.melee_weapons.hauteur.stats.max_damage = 14.0
	self.melee_weapons.hauteur.stats.min_damage_effect = 30/self:getmindmg("hauteur")
	self.melee_weapons.hauteur.stats.max_damage_effect = 60/self:getmaxdmg("hauteur")
	self.melee_weapons.hauteur.stats.charge_time = 2



	-- el verdugo
	self.melee_weapons.agave.infname = "C. El Verdugo"
	self.melee_weapons.agave.can_bisect = true
	self:applystats("agave", meleeval.bigknife)
	self.melee_weapons.agave.repeat_expire_t = 0.25
	self.melee_weapons.agave.expire_t = 0.80
	self.melee_weapons.agave.early_expire_t = 0.50
	self.melee_weapons.agave.speed_mult = 0.70 -- dayamn son
	-- gerber gator
	self.melee_weapons.gator.infname = "C. Gerber Gator"
	self.melee_weapons.gator.can_bisect = true
	self:melee_machete("gator")
	self:applystats("gator", meleeval.machete)
	-- rezkoye
	self.melee_weapons.oxide.infname = "C. Rezkoye"
	self:melee_machete("oxide")
	self.melee_weapons.oxide.stats.min_damage = 7.5
	self.melee_weapons.oxide.stats.max_damage = 12.5
	self.melee_weapons.oxide.stats.min_damage_effect = 50/self:getmindmg("oxide")
	self.melee_weapons.oxide.stats.max_damage_effect = 75/self:getmaxdmg("oxide")
	self.melee_weapons.oxide.stats.charge_time = 1
	-- machete knife (HLM)
	self.melee_weapons.machete.infname = "C. HLM Machete"
	self.melee_weapons.machete.can_bisect = true
	self:melee_machete("machete")
	self.melee_weapons.machete.stats.min_damage = 10.0
	self.melee_weapons.machete.stats.max_damage = 15.0
	self.melee_weapons.machete.stats.min_damage_effect = 60/self:getmindmg("machete")
	self.melee_weapons.machete.stats.max_damage_effect = 90/self:getmaxdmg("machete")
	self.melee_weapons.machete.stats.charge_time = 3

	-- cleaver knife
	self.melee_weapons.cleaver.infname = "C. Cleaver Knife"
	self.melee_weapons.cleaver.repeat_expire_t = 0.40
	self.melee_weapons.cleaver.expire_t = 1.00
	self.melee_weapons.cleaver.early_expire_t = 0.45
	self:applystats("cleaver", meleeval.bigknife)

	-- shinsakuto katana
	self.melee_weapons.sandsteel.infname = "C. Shinsakuto Katana"
	self.melee_weapons.sandsteel.can_bisect = true
	--self.melee_weapons.sandsteel.repeat_expire_t = 0.50
	--self.melee_weapons.sandsteel.expire_t = 1.00
	self.melee_weapons.sandsteel.repeat_expire_t = 0.50
	self.melee_weapons.sandsteel.stats.min_damage = 9.0
	self.melee_weapons.sandsteel.stats.max_damage = 21.0
	self.melee_weapons.sandsteel.stats.min_damage_effect = 70/self:getmindmg("sandsteel")
	self.melee_weapons.sandsteel.stats.max_damage_effect = 140/self:getmaxdmg("sandsteel")
	self.melee_weapons.sandsteel.stats.charge_time = 4

	-- the most important weapon in the game, DOSH
	self.melee_weapons.moneybundle.infname = "Z. Money Bundle"
	self.melee_weapons.moneybundle.can_bisect = true -- bet someone will find this by codediving before it's actually found through playtime
	self:melee_axe("moneybundle")
	self.melee_weapons.moneybundle.stats.min_damage = 0.1
	self.melee_weapons.moneybundle.stats.max_damage = 0.5
	self.melee_weapons.moneybundle.stats.min_damage_effect = 300/self:getmindmg("moneybundle")
	self.melee_weapons.moneybundle.stats.max_damage_effect = 666/self:getmaxdmg("moneybundle") -- bitch chill out
	self.melee_weapons.moneybundle.stats.charge_time = 5
	self.melee_weapons.moneybundle.speed_mult = 1 -- L O D S O F E M O N E
	-- survival tomahawk
	self.melee_weapons.tomahawk.infname = "D. Survival Tomahawk"
	self.melee_weapons.tomahawk.can_bisect = true
	self:melee_axe("tomahawk")
	self.melee_weapons.tomahawk.stats.min_damage = 11.0
	self.melee_weapons.tomahawk.stats.max_damage = 15.0
	self.melee_weapons.tomahawk.stats.min_damage_effect = 75/self:getmindmg("tomahawk")
	self.melee_weapons.tomahawk.stats.max_damage_effect = 125/self:getmaxdmg("tomahawk")
	self.melee_weapons.tomahawk.stats.charge_time = 2
	self.melee_weapons.tomahawk.speed_mult = self.melee_weapons.tomahawk.speed_mult * 0.80
	-- scalper tomahawk
	self.melee_weapons.scalper.infname = "D. Scalper Tomahawk"
	self.melee_weapons.scalper.can_bisect = true
	self:melee_axe("scalper")
	self.melee_weapons.scalper.stats.min_damage = 11.0
	self.melee_weapons.scalper.stats.max_damage = 15.0
	self.melee_weapons.scalper.stats.min_damage_effect = 75/self:getmindmg("scalper")
	self.melee_weapons.scalper.stats.max_damage_effect = 125/self:getmaxdmg("scalper")
	self.melee_weapons.scalper.stats.charge_time = 2
	self.melee_weapons.scalper.speed_mult = self.melee_weapons.scalper.speed_mult * 0.80
	-- pitchfork
	self.melee_weapons.pitchfork.infname = "Gb. Pitchfork"
	self.melee_weapons.pitchfork.repeat_expire_t = 0.60
	self.melee_weapons.pitchfork.expire_t = 1.40
	self.melee_weapons.pitchfork.early_expire_t = 0.70
	self:applystats("pitchfork", meleeval.bigshank)
	-- dragan's cleaver
	self.melee_weapons.meat_cleaver.infname = "D. Dragan's Cleaver"
	self:melee_axe("meat_cleaver")
	self.melee_weapons.meat_cleaver.stats.min_damage = 8.0
	self.melee_weapons.meat_cleaver.stats.max_damage = 16.0
	self.melee_weapons.meat_cleaver.stats.min_damage_effect = 60/self:getmindmg("meat_cleaver")
	self.melee_weapons.meat_cleaver.stats.max_damage_effect = 100/self:getmaxdmg("meat_cleaver")
	self.melee_weapons.meat_cleaver.stats.charge_time = 3
	-- icepick
	self.melee_weapons.iceaxe.infname = "D. Icepick"
	self:melee_axe("iceaxe")
	self.melee_weapons.iceaxe.stats.min_damage = 9.0
	self.melee_weapons.iceaxe.stats.max_damage = 15.0
	self.melee_weapons.iceaxe.stats.min_damage_effect = 75/self:getmindmg("iceaxe")
	self.melee_weapons.iceaxe.stats.max_damage_effect = 150/self:getmaxdmg("iceaxe")
	self.melee_weapons.iceaxe.stats.charge_time = 2
	-- compact hatchet
	self.melee_weapons.bullseye.infname = "D. Bullseye"
	self:melee_axe("bullseye")
	self.melee_weapons.bullseye.stats.min_damage = 8.5
	self.melee_weapons.bullseye.stats.max_damage = 15.0
	self.melee_weapons.bullseye.stats.min_damage_effect = 50/self:getmindmg("bullseye")
	self.melee_weapons.bullseye.stats.max_damage_effect = 100/self:getmaxdmg("bullseye")
	self.melee_weapons.bullseye.stats.charge_time = 3
	-- utility machete
	self.melee_weapons.becker.infname = "D. Utility Machete"
	self:melee_axe("becker")
	self.melee_weapons.becker.stats.min_damage = 8.0
	self.melee_weapons.becker.stats.max_damage = 14.0
	self.melee_weapons.becker.stats.min_damage_effect = 60/self:getmindmg("becker")
	self.melee_weapons.becker.stats.max_damage_effect = 75/self:getmaxdmg("becker")
	self.melee_weapons.becker.stats.charge_time = 1
	-- poker
	self.melee_weapons.poker.infname = "D. Poker"
	self:melee_taser("poker")
	self.melee_weapons.poker.anim_attack_vars = {"var1"}
	self.melee_weapons.poker.stats.range = 200
	self.melee_weapons.poker.stats.min_damage = 8.0
	self.melee_weapons.poker.stats.max_damage = 12.0
	self.melee_weapons.poker.stats.min_damage_effect = 30/self:getmindmg("poker")
	self.melee_weapons.poker.stats.max_damage_effect = 40/self:getmaxdmg("poker")
	self.melee_weapons.poker.stats.charge_time = 2

	-- rivertown glen bottle
	self.melee_weapons.whiskey.infname = "Eb. Rivertown Glen"
	self:melee_axe("whiskey")
	self.melee_weapons.whiskey.stats.min_damage = 7.0
	self.melee_weapons.whiskey.stats.max_damage = 10.5
	self.melee_weapons.whiskey.stats.min_damage_effect = 150/self:getmindmg("whiskey")
	self.melee_weapons.whiskey.stats.max_damage_effect = 300/self:getmaxdmg("whiskey")
	self.melee_weapons.whiskey.stats.charge_time = 2
	-- pipe wrench
	self.melee_weapons.shock.infname = "Eb. Pipe Wrench"
	self:melee_axe("shock")
	self.melee_weapons.shock.stats.min_damage = 7.0
	self.melee_weapons.shock.stats.max_damage = 10.5
	self.melee_weapons.shock.stats.min_damage_effect = 150/self:getmindmg("shock")
	self.melee_weapons.shock.stats.max_damage_effect = 300/self:getmaxdmg("shock")
	self.melee_weapons.shock.stats.charge_time = 2
	-- potato masher
	self.melee_weapons.model24.infname = "Eb. Potato Masher"
	self:melee_axe("model24")
	self:applystats("model24", meleeval.smackstick)
	-- swagger stick
	self.melee_weapons.swagger.infname = "Eb. Swagger Stick"
	self:melee_axe("swagger")
	self:applystats("swagger", meleeval.smackstick)
	-- klas shovel
	self.melee_weapons.shovel.infname = "Eb. Shovel"
	self:melee_axe("shovel")
	self:applystats("shovel", meleeval.smackstick)
	-- you're mine
	self.melee_weapons.branding_iron.infname = "Ec. Branding Iron"
	self:melee_axe("branding_iron")
	self:applystats("branding_iron", meleeval.whackstick)
	-- clover's shillelagh
	self.melee_weapons.shillelagh.infname = "Ec. Shillelagh"
	self:melee_axe("shillelagh")
	self:applystats("shillelagh", meleeval.whackstick)
	-- carpenter's delight
	self.melee_weapons.hammer.infname = "Ec. Carpenter's Delight"
	self:melee_axe("hammer")
	self:applystats("hammer", meleeval.whackstick)
	-- tenderizer
	self.melee_weapons.tenderizer.infname = "Ec. Tenderizer"
	self:melee_axe("tenderizer")
	self:applystats("tenderizer", meleeval.whackstick)
	self.melee_weapons.tenderizer.melee_charge_shaker = nil -- disappears off screen when held charged
	-- SPEAR OF FREEDOM
	self.melee_weapons.freedom.infname = "Ec. Spear of Freedom"
	self.melee_weapons.freedom.repeat_expire_t = 0.90
	self.melee_weapons.freedom.expire_t = 1.60
	self.melee_weapons.freedom.early_expire_t = 0.60
	self.melee_weapons.freedom.stats.min_damage = 11.0
	self.melee_weapons.freedom.stats.max_damage = 22.0
	self.melee_weapons.freedom.stats.min_damage_effect = 100/self:getmindmg("freedom")
	self.melee_weapons.freedom.stats.max_damage_effect = 150/self:getmaxdmg("freedom")
	self.melee_weapons.freedom.stats.charge_time = 3
	self.melee_weapons.freedom.speed_mult = 1.35

	-- microphone
	self.melee_weapons.microphone.infname = "Ea. Microphone"
	self:melee_axe("microphone")
	self:applystats("microphone", meleeval.beatstick)
	self.melee_weapons.microphone.speed_mult = 1.25
	-- leather sap
	self.melee_weapons.sap.infname = "Ea. Leather Sap"
	self:melee_axe("sap")
	self:applystats("sap", meleeval.beatstick)
	self.melee_weapons.sap.speed_mult = 1.25
	-- tactical flashlight (quiet charge sound)
	self.melee_weapons.aziz.infname = "Ea. Flashlight"
	self:melee_psycho("aziz")
	self:applystats("aziz", meleeval.beatstick)
	self.melee_weapons.aziz.speed_mult = 0.90

	-- spatula
	self.melee_weapons.spatula.infname = "F. Spatula"
	self:melee_axe("spatula")
	self:applystats("spatula", meleeval.baton)
	-- telescopic baton
	self.melee_weapons.baton.infname = "F. Telescopic Baton"
	self:applystats("baton", meleeval.baton)
	-- old baton
	self.melee_weapons.oldbaton.infname = "F. Old Baton"
	self:melee_axe("oldbaton")
	self:applystats("oldbaton", meleeval.baton)
	-- selfie stick
	self.melee_weapons.selfie.infname = "F. Selfie Stick"
	self:melee_axe("selfie")
	self:applystats("selfie", meleeval.baton)
	self.melee_weapons.selfie.self_damage = 1.0
	-- hackaton
	self.melee_weapons.happy.infname = "F. Hackaton"
	self:applystats("happy", meleeval.baton)
	self.melee_weapons.happy.repeat_expire_t = 0.30
	self.melee_weapons.happy.expire_t = 0.70
	self.melee_weapons.happy.repeat_expire_t = 0.40
	-- okinawan-style sai
	self.melee_weapons.twins.infname = "C. Okinawan-Style Sai"
	self.melee_weapons.twins.repeat_expire_t = 0.40
	self.melee_weapons.twins.expire_t = 1.10
	self.melee_weapons.twins.early_expire_t = 0.60
	self.melee_weapons.twins.stats.min_damage = 2.0
	self.melee_weapons.twins.stats.max_damage = 6.0
	self.melee_weapons.twins.stats.min_damage_effect = 300/self:getmindmg("twins")
	self.melee_weapons.twins.stats.max_damage_effect = 450/self:getmaxdmg("twins")
	self.melee_weapons.twins.stats.charge_time = 2
	-- 50 blessings briefcase
	self.melee_weapons.briefcase.infname = "F. 50 Blessings Briefcase"
	self.melee_weapons.briefcase.repeat_expire_t = 0.70
	self.melee_weapons.briefcase.expire_t = 1.50
	self.melee_weapons.briefcase.early_expire_t = 0.50
	self.melee_weapons.briefcase.melee_damage_delay = 0.30
	self:applystats("briefcase", meleeval.baton)
	-- metal detector
	self.melee_weapons.detector.infname = "F. Metal Detector"
	self:melee_axe("detector")
	self.melee_weapons.detector.stats.min_damage = 3.0
	self.melee_weapons.detector.stats.max_damage = 4.5
	self.melee_weapons.detector.stats.min_damage_effect = 100/self:getmindmg("detector")
	self.melee_weapons.detector.stats.max_damage_effect = 200/self:getmaxdmg("detector")
	self.melee_weapons.detector.stats.charge_time = 2
	-- mic stand
	self.melee_weapons.micstand.infname = "F. Mic Stand"
	self:melee_axe("micstand")
	self.melee_weapons.micstand.stats.min_damage = 1.5
	self.melee_weapons.micstand.stats.max_damage = 2.0
	self.melee_weapons.micstand.stats.min_damage_effect = 60/self:getmindmg("micstand")
	self.melee_weapons.micstand.stats.max_damage_effect = 600/self:getmaxdmg("micstand")
	self.melee_weapons.micstand.stats.charge_time = 10
	self.melee_weapons.micstand.self_damage = 0.1
	-- jackpot
	self.melee_weapons.slot_lever.infname = "F. Jackpot"
	self:melee_axe("slot_lever")
	self.melee_weapons.slot_lever.stats.min_damage = 4.0 -- all-around inferior?
	self.melee_weapons.slot_lever.stats.max_damage = 6.0
	self.melee_weapons.slot_lever.stats.min_damage_effect = 100/self:getmindmg("slot_lever")
	self.melee_weapons.slot_lever.stats.max_damage_effect = 150/self:getmaxdmg("slot_lever")
	self.melee_weapons.slot_lever.stats.charge_time = 2
	-- croupier's rake
	self.melee_weapons.croupier_rake.infname = "F. Croupier's Rake"
	self:melee_axe("croupier_rake")
	self.melee_weapons.croupier_rake.stats.min_damage = 2.5
	self.melee_weapons.croupier_rake.stats.max_damage = 5.0
	self.melee_weapons.croupier_rake.stats.min_damage_effect = 150/self:getmindmg("croupier_rake")
	self.melee_weapons.croupier_rake.stats.max_damage_effect = 250/self:getmaxdmg("croupier_rake")
	self.melee_weapons.croupier_rake.stats.charge_time = 2
	-- hockey stick
	self.melee_weapons.hockey.infname = "F. Hockey Stick"
	self:melee_axe("hockey")
	self.melee_weapons.hockey.stats.min_damage = 4.5
	self.melee_weapons.hockey.stats.max_damage = 9.0
	self.melee_weapons.hockey.stats.min_damage_effect = 200/self:getmindmg("hockey")
	self.melee_weapons.hockey.stats.max_damage_effect = 750/self:getmaxdmg("hockey")
	self.melee_weapons.hockey.stats.charge_time = 2
	-- hotline 8000x
	self.melee_weapons.brick.infname = "F. Hotline 8000X"
	self.melee_weapons.brick.repeat_expire_t = 0.70
	self.melee_weapons.brick.expire_t = 1.40
	self.melee_weapons.brick.early_expire_t = 0.50
	self:applystats("brick", meleeval.beatstick)
	self.melee_weapons.brick.speed_mult = 1.25
	self.melee_weapons.brick.sounds.charge = "brick_charge"
	-- FISTS
	self.melee_weapons.fists.infname = "F. Fists"
	self:melee_fist("fists")
	self.melee_weapons.fists.stats.min_damage = 3.0
	self.melee_weapons.fists.stats.max_damage = 6.0
	self.melee_weapons.fists.stats.min_damage_effect = 100/self:getmindmg("fists")
	self.melee_weapons.fists.stats.max_damage_effect = 300/self:getmaxdmg("fists")
	self.melee_weapons.fists.stats.charge_time = 2
	-- brass knuckles
	self.melee_weapons.brass_knuckles.infname = "F. Brass Knuckles"
	self:melee_fist("brass_knuckles")
	self.melee_weapons.brass_knuckles.stats.min_damage = 4.0
	self.melee_weapons.brass_knuckles.stats.max_damage = 8.0
	self.melee_weapons.brass_knuckles.stats.min_damage_effect = 90/self:getmindmg("brass_knuckles")
	self.melee_weapons.brass_knuckles.stats.max_damage_effect = 270/self:getmaxdmg("brass_knuckles")
	self.melee_weapons.brass_knuckles.stats.charge_time = 2
	-- overkill boxing gloves
	self.melee_weapons.boxing_gloves.infname = "F. Boxing Gloves"
	self.melee_weapons.boxing_gloves.repeat_expire_t = 0.40
	self.melee_weapons.boxing_gloves.expire_t = 1.00
	self.melee_weapons.boxing_gloves.early_expire_t = 0.50
	self.melee_weapons.boxing_gloves.stats.min_damage = 4.0
	self.melee_weapons.boxing_gloves.stats.max_damage = 8.0
	self.melee_weapons.boxing_gloves.stats.min_damage_effect = 150/self:getmindmg("boxing_gloves")
	self.melee_weapons.boxing_gloves.stats.max_damage_effect = 450/self:getmaxdmg("boxing_gloves")
	self.melee_weapons.boxing_gloves.stats.charge_time = 2
	self.melee_weapons.boxing_gloves.sounds.charge = "boxing_charge"
	-- empty palm kata
	self.melee_weapons.fight.infname = "F. Empty Palm Kata"
	self.melee_weapons.fight.repeat_expire_t = 0.30
	self.melee_weapons.fight.expire_t = 1.10
	self.melee_weapons.fight.early_expire_t = 0.60
	self.melee_weapons.fight.anim_attack_vars = {"var1", "var2", "var3", "var4"} -- 5 causes timing awkwardness
	self.melee_weapons.fight.stats.min_damage = 4.5
	self.melee_weapons.fight.stats.max_damage = 9.0
	self.melee_weapons.fight.stats.min_damage_effect = 80/self:getmindmg("fight")
	self.melee_weapons.fight.stats.max_damage_effect = 240/self:getmaxdmg("fight")
	self.melee_weapons.fight.stats.charge_time = 3


	-- shephard's cane
	self.melee_weapons.stick.infname = "Ga. Shephard's Cane"
	self:melee_baseballbat("stick")
	self.melee_weapons.stick.stats.min_damage = 3.0
	self.melee_weapons.stick.stats.max_damage = 9.0
	self.melee_weapons.stick.stats.min_damage_effect = 300/self:getmindmg("stick")
	self.melee_weapons.stick.stats.max_damage_effect = 450/self:getmaxdmg("stick")
	self.melee_weapons.stick.stats.charge_time = 2
	self.melee_weapons.stick.speed_mult = 1.50
	-- chain whip
	self.melee_weapons.road.infname = "Ga. Chain Whip"
	self:applystats("road", meleeval.battaswing)
	--self.melee_weapons.road.repeat_expire_t = 2.00
	--self.melee_weapons.road.expire_t = 1.2
	self.melee_weapons.road.early_expire_t = 0.70
	self.melee_weapons.road.sounds.charge = "road_charge"
	-- buckler shield
	self.melee_weapons.buck.infname = "Ga. Buckler Shield"
	self:applystats("buck", meleeval.battaswing)
	self.melee_weapons.buck.stats.min_damage = 7.0
	self.melee_weapons.buck.stats.max_damage = 13.0
	self.melee_weapons.buck.stats.min_damage_effect = 250/self:getmindmg("buck")
	self.melee_weapons.buck.stats.max_damage_effect = 600/self:getmaxdmg("buck")
	self.melee_weapons.buck.repeat_expire_t = 0.80
	self.melee_weapons.buck.expire_t = 1.40
	self.melee_weapons.buck.early_expire_t = 0.50
	self.melee_weapons.buck.speed_mult = 1.25
	-- Bolt Cutters
	self.melee_weapons.cutters.infname = "Ga. Bolt Cutters"
	self:applystats("cutters", meleeval.battaswing)
	self.melee_weapons.cutters.sounds.charge = nil
	self.melee_weapons.cutters.anim_attack_vars = {"var1", "var2", "var3"} -- var4 is a weirdly-animated downward-and-then-jab-forward swing
	self.melee_weapons.cutters.repeat_expire_t = 0.80
	self.melee_weapons.cutters.expire_t = 1.30
	self.melee_weapons.cutters.early_expire_t = 0.40
	-- lucille
	self.melee_weapons.barbedwire.infname = "Ga. Lucille"
	self:melee_baseballbat("barbedwire")
	self:applystats("barbedwire", meleeval.battaswing)
	-- baseball bat
	self.melee_weapons.baseballbat.infname = "Ga. Baseball Bat"
	self:melee_baseballbat("baseballbat")
	self:applystats("baseballbat", meleeval.battaswing)

	-- ding dong breaching tool
	self.melee_weapons.dingdong.infname = "Ga. Ding Dong Breaching Tool"
	self:melee_baseballbat("dingdong")
	self:applystats("dingdong", meleeval.sledgehammer)
	-- alpha mauler
	self.melee_weapons.alien_maul.infname = "Ga. Alpha Maul"
	self:melee_baseballbat("alien_maul")
	self:applystats("alien_maul", meleeval.sledgehammer)
	-- morning star
	self.melee_weapons.morning.infname = "Ga. Morning Star"
	self:melee_axe("morning")
	self.melee_weapons.morning.stats.min_damage = 9.0
	self.melee_weapons.morning.stats.max_damage = 13.5
	self.melee_weapons.morning.stats.min_damage_effect = 140/self:getmindmg("morning")
	self.melee_weapons.morning.stats.max_damage_effect = 280/self:getmaxdmg("morning")
	self.melee_weapons.morning.stats.charge_time = 3

	-- gold fever
	self.melee_weapons.mining_pick.infname = "Gb. Gold Fever"
	self.melee_weapons.mining_pick.repeat_expire_t = 0.70
	self.melee_weapons.mining_pick.expire_t = 1.40
	self.melee_weapons.mining_pick.early_expire_t = 0.60
	self.melee_weapons.mining_pick.anim_attack_vars = {"var2"}
	self.melee_weapons.mining_pick.stats.min_damage = 13.0
	self.melee_weapons.mining_pick.stats.max_damage = 20.0
	self.melee_weapons.mining_pick.stats.min_damage_effect = 90/self:getmindmg("mining_pick")
	self.melee_weapons.mining_pick.stats.max_damage_effect = 240/self:getmaxdmg("mining_pick")
	self.melee_weapons.mining_pick.stats.charge_time = 3

	-- fire axe
	self.melee_weapons.fireaxe.infname = "Gb. Fire Axe"
	self.melee_weapons.fireaxe.can_bisect = true
	self.melee_weapons.fireaxe.repeat_expire_t = 1.00
	self.melee_weapons.fireaxe.expire_t = 1.90
	self.melee_weapons.fireaxe.early_expire_t = 0.70
	self.melee_weapons.fireaxe.melee_damage_delay = 0.60
	self.melee_weapons.fireaxe.stats.min_damage = 15.0
	self.melee_weapons.fireaxe.stats.max_damage = 30.0
	self.melee_weapons.fireaxe.stats.min_damage_effect = 90/self:getmindmg("fireaxe")
	self.melee_weapons.fireaxe.stats.max_damage_effect = 135/self:getmaxdmg("fireaxe")
	self.melee_weapons.fireaxe.stats.charge_time = 3
	self.melee_weapons.fireaxe.speed_mult = 1.35

	-- bearded axe
	self.melee_weapons.beardy.infname = "Gb. Bearded Axe"
	self.melee_weapons.beardy.can_bisect = true
	--self.melee_weapons.beardy.repeat_expire_t = 1.10
	--self.melee_weapons.beardy.expire_t = 1.50
	self.melee_weapons.beardy.early_expire_t = 0.30
	self.melee_weapons.beardy.stats.min_damage = 16.5
	self.melee_weapons.beardy.stats.max_damage = 33.0
	self.melee_weapons.beardy.stats.min_damage_effect = 100/self:getmindmg("beardy")
	self.melee_weapons.beardy.stats.max_damage_effect = 150/self:getmaxdmg("beardy")
	self.melee_weapons.beardy.stats.charge_time = 3
	self.melee_weapons.beardy.speed_mult = 1.35

	-- greatsword
	self.melee_weapons.great.infname = "Gb. Greatsword"
	self.melee_weapons.great.can_bisect = true
	self:melee_great("great")
	self.melee_weapons.great.stats.min_damage = 18.0
	self.melee_weapons.great.stats.max_damage = 36.0
	self.melee_weapons.great.stats.min_damage_effect = 75/self:getmindmg("great")
	self.melee_weapons.great.stats.max_damage_effect = 125/self:getmaxdmg("great")
	self.melee_weapons.great.stats.charge_time = 3

	-- great ruler
	self.melee_weapons.meter.infname = "Gb. Great Ruler"
	self.melee_weapons.meter.can_bisect = true
	self:melee_great("meter")
	self.melee_weapons.meter.stats.min_damage = 8.0
	self.melee_weapons.meter.stats.max_damage = 16.0
	self.melee_weapons.meter.stats.min_damage_effect = 300/self:getmindmg("meter")
	self.melee_weapons.meter.stats.max_damage_effect = 125/self:getmaxdmg("meter")
	self.melee_weapons.meter.stats.charge_time = 1
	self.melee_weapons.meter.speed_mult = self.melee_weapons.meter.speed_mult * 1.35

	-- pounder
	self.melee_weapons.nin.infname = "Gb. Pounder"
	self.melee_weapons.nin.repeat_expire_t = 0.50
	self.melee_weapons.nin.expire_t = 1.20
	self.melee_weapons.nin.early_expire_t = 0.60
	self.melee_weapons.nin.stats.min_damage = 9.5
	self.melee_weapons.nin.stats.max_damage = 9.5
	self.melee_weapons.nin.stats.min_damage_effect = 90/self:getmindmg("nin")
	self.melee_weapons.nin.stats.max_damage_effect = 350/self:getmaxdmg("nin")
	self.melee_weapons.nin.stats.charge_time = 2



	-- Electrical Brass Knuckles
	self.melee_weapons.zeus.infname = "H. Electrical Brass Knuckles"
	self:melee_fist_slow("zeus")
	self:applystats("zeus", meleeval.zapper)
	self.melee_weapons.zeus.speed_mult = 0.80
	self.melee_weapons.zeus.sounds.charge = "zeus_charge"
	self.melee_weapons.zeus.self_shock = true
	self.melee_weapons.zeus.self_shock_threshold = 0.25
	-- buzzer
	self.melee_weapons.taser.infname = "H. Buzzer"
	self:applystats("taser", meleeval.zapper)
	self:melee_machete("taser")
	self.melee_weapons.taser.speed_mult = 0.80
	self.melee_weapons.taser.sounds.charge = "buzzer_charge"












	-- kazaguruma
	self.melee_weapons.ostry.infname = "Z. Kazaguruma"
	self.melee_weapons.ostry.can_bisect = true
	self.melee_weapons.ostry.chainsaw_delay = 0.70
	self.melee_weapons.ostry.repeat_chainsaw_delay = 0.20
	self.melee_weapons.ostry.repeat_expire_t = 0.35
	self.melee_weapons.ostry.expire_t = 1.00
	self.melee_weapons.ostry.early_expire_t = 0.60
	self.melee_weapons.ostry.stats.tick_damage = 2.0
	self.melee_weapons.ostry.stats.min_damage = 6.0
	self.melee_weapons.ostry.stats.max_damage = 6.0
	self.melee_weapons.ostry.stats.min_damage_effect = 10/self:getmindmg("ostry")
	self.melee_weapons.ostry.stats.max_damage_effect = 10/self:getmaxdmg("ostry")
	self.melee_weapons.ostry.stats.charge_time = 4
	self.melee_weapons.ostry.sounds.charge = "ostry_charge"
	self.melee_weapons.ostry.chainsaw = true

	-- lumber lite l2 chainsaw
	self.melee_weapons.cs.infname = "Z. Chainsaw"
	self.melee_weapons.cs.can_bisect = true
	self.melee_weapons.cs.chainsaw_delay = 1.00
	--self.melee_weapons.cs.repeat_chainsaw_delay = 0.20
	self.melee_weapons.cs.repeat_expire_t = 2 -- irrelevant
	self.melee_weapons.cs.expire_t = 1.10
	self.melee_weapons.cs.early_expire_t = 0.50
	self.melee_weapons.cs.stats.tick_damage = 2.5
	self.melee_weapons.cs.stats.min_damage = 5.0
	self.melee_weapons.cs.stats.max_damage = 5.0
	self.melee_weapons.cs.stats.min_damage_effect = 100/self:getmindmg("cs")
	self.melee_weapons.cs.stats.max_damage_effect = 300/self:getmaxdmg("cs")
	self.melee_weapons.cs.stats.charge_time = 5
	self.melee_weapons.cs.sounds.charge = "cs_charge"
	self.melee_weapons.cs.chainsaw = true
	--self.melee_weapons.cs.stance_mod = {translation = Vector3(-20, 0, 0), rotation = Rotation(0, 0, 0)}
	self.melee_weapons.cs.stance_mod = {translation = Vector3(-15, 10, 5), rotation = Rotation(10, -35, 0)}





	-- apply speed mults
	-- does not apply to instant weapons because fuck those anyways
	for wpnname, wpn in pairs(self.melee_weapons) do
		if wpn.speed_mult then
			wpn.swing_anim_speed_mult = wpn.speed_mult
			wpn.expire_t = wpn.expire_t/wpn.speed_mult
			wpn.repeat_expire_t = wpn.repeat_expire_t/wpn.speed_mult
			wpn.melee_damage_delay = wpn.melee_damage_delay/wpn.speed_mult
			if wpn.early_expire_t then
				wpn.early_expire_t = wpn.early_expire_t/wpn.speed_mult
			end
			if wpn.attack_allowed_expire_t then
				wpn.attack_allowed_expire_t = wpn.attack_allowed_expire_t/wpn.speed_mult
			end
		end
		wpn.swing_anim_speed_mult = wpn.swing_anim_speed_mult or 1

--[[
		log((wpn.infname or wpnname) .. " - dmg/charge: " .. 10*wpn.stats.min_damage .. "/" .. 10*wpn.stats.max_damage .. ", knockdown: " .. 10*wpn.stats.min_damage*wpn.stats.min_damage_effect .. "/" .. 10*wpn.stats.max_damage*wpn.stats.max_damage_effect .. ", dps: " .. math.round(10*wpn.stats.min_damage/wpn.repeat_expire_t, 2) .. "/" .. math.round(10*wpn.stats.max_damage/(wpn.repeat_expire_t + wpn.stats.charge_time), 2) .. ", charge time: " .. wpn.stats.charge_time .. ", repeat expire: " .. wpn.repeat_expire_t .. ", concealment: " .. (wpn.stats.concealment or 100))
--]]


	end
end)