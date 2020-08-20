--[[
local text_original = LocalizationManager.text
local testAllStrings = true  --Set to true to show all string ID's, false to return to normal.
function LocalizationManager:text(string_id, ...)

	return string_id == "hud_suspicion_detected" and ""
	or string_id == "bm_menu_weapon_movement_penalty_info" and "Move speed when drawn: "

	or testAllStrings == true and string_id
	or text_original(self, string_id, ...)
			
end
--]]


-- don't forget to change below
local pisswitch = "+10% switch speed"

local silstr = "\n\n+10 dmg falloff. Falloff begins/ends at 15m/30m." -- rifle suppressors
local silstr2 = ""--"\n\n-20% range" -- shotgun suppressors
local silstr3 = "\n\n-20% shield penetration damage" -- sniper suppressors
-- 

local switch_snubnose = "+35% weapon switch speed."

local bipodstr = "Press $BTN_BIPOD to deploy. 200% horizontal recoil when attached. 30% all recoil when deployed."
local tripodstr = "Press $BTN_BIPOD to deploy. 200% horizontal recoil when attached. 15% all recoil when deployed."

local charm = "\n\n+3% XP and money rewards for you and your crew"

local ironsights = {}
ironsights.keepname = "Default Ironsights"
ironsights.keepdesc = "Keeps the default ironsights when using attachable sights."

local speedpulldesc = "Magazine with speed pull tab to ease removal of magazines mid-combat."

local tritiumdesc = "Illuminated sights that are easier to see at night. Not like you go outside often."




Hooks:Add("LocalizationManagerPostInit", "inf_fuckyourtext", function(loc)

	local function get_string_by_option(optionarg, text)
		local option = optionarg
		if type(optionarg) == "boolean" then
			if optionarg == true then
				option = 2
			else
				option = 1
			end
		end
		return text[option]
	end

	-- strings that fall back to default
if InFmenu.settings.txt_wpnname > 1 then
	LocalizationManager:add_localized_strings({
		bm_w_amcar = "AMCAR",
		bm_w_m4 = "CAR-4",
		bm_w_tecci = "'Bootleg'",
		bm_w_m16 = "AMR-16",
		bm_w_olympic = "CAR-23 Para",
		bm_w_x_olympic = "Akimbo Paras",
		bm_w_olympicprimary = "CAR-23 Para",
		bm_w_contraband = "SG417D + 'Little Friend'",

		bm_w_ak74 = "AKS.74",
		bm_w_akm = "AK.762",
		bm_w_akm_gold = "AuK.762",
		bm_w_akmsu = "AKS.74U 'Krinkov'",
		bm_w_akmsuprimary = "AKS.74U 'Krinkov'",
		bm_w_x_akmsu = "Akimbo Krinkovs",
		bm_w_ak12 = "AK.12",

		bm_w_ak5 = "Ak 5",
		bm_w_asval = "AS Valkyria",
		bm_w_aug = "UAR-A2",
		bm_w_sub2000 = "CAV-2000", -- concealed assault vector
		bm_w_famas = "Clarion F1",
		bm_w_s552 = "KG 552-R Commando",
		bm_w_corgi = "Millenium",
		bm_w_komodo = "MPES-95",
		bm_w_g36 = "JP36 KV",
		bm_w_vhs = "Strojnica HVH-D2",
		bm_w_l85a2 = "L95A2",
		bm_w_scar = "Eagle Heavy",
		bm_w_fal = "FALCON",
		bm_w_g3 = "Gewehr 3",
		bm_w_galil = "Galil HAR", -- heavy automatic rifle

		bm_w_m14 = "M308",
		bm_w_ching = "M1 Garand",
		bm_w_tti = "Condottiere",
		bm_w_siltstone = "SVD",

		bm_w_winchester1874 = "Repeater 1873",
		bm_w_msr = "Rattlesnake MSR",
		bm_w_wa2000 = "LA2000", -- lakner arms
		bm_w_model70 = "Winchester Model 70",
		bm_w_r93 = "R93 T2",
		bm_w_mosin = "Mosin-Nagant",
		bm_w_desertfox = "Vulpeserda Covert", -- vulpes zerda
		bm_w_m95 = "M95 Thanatos",

		bm_w_coal = "Bizon",
		bm_w_coalprimary = "Bizon",
		bm_w_x_coal = "Akimbo Bizons",
		bm_w_tec9 = "Blaster 9",
		bm_w_x_tec9 = "Akimbo Blaster 9s",
		bm_w_m1928 = "Chicago Typewriter",
		bm_w_m1928primary = "Chicago Typewriter",
		bm_w_x_m1928 = "Akimbo Typewriters",
		bm_w_scorpion = "Skorpion",
		bm_w_x_scorpion = "Akimbo Skorpions",
		bm_w_mp9 = "CMP 9",
		bm_w_x_mp9 = "Akimbo CMPs",
		bm_w_mp5 = "Compact-5",
		bm_w_new_mp5primary = "Compact-5",
		bm_w_x_mp5 = "Akimbo Compact-5s",
		bm_w_schakal = "Impact-45",
		bm_w_schakalprimary = "Impact-45",
		bm_w_x_schakal = "Akimbo Impact-45s",
		bm_w_hajk = "CZ 805B",
		bm_w_hajkprimary = "CZ 805B",
		bm_w_x_hajk = "Akimbo CZ 805Bs",
		bm_w_mac10 = "Mark 10",
		bm_w_x_mac10 = "Akimbo Mark 10s",
		bm_w_cobray = "Jacket's Piece",
		bm_w_x_cobray = "Akimbo Jacket's Pieces",
		bm_w_erma = "MP40",
		bm_w_x_erma = "Akimbo MP40s",
		bm_w_mp7 = "MP46 A2",
		bm_w_x_mp7 = "Akimbo MP46s",
		bm_w_sterling = "Patchett Mk4",
		bm_w_x_sterling = "Akimbo Patchetts",
		bm_w_p90 = "Project 90 (TR)",
		bm_w_x_p90 = "Akimbo Project 90s",
		bm_w_shepheard = "MPX",
		bm_w_shepheardprimary = "MPX",
		bm_w_x_shepheard = "Akimbo MPXs",
		bm_w_m45 = "Swedish K",
		bm_w_x_m45 = "Akimbo Swedish Ks",
		bm_w_uzi = "Uzi",
		bm_w_x_uzi = "Akimbo Uzis",
		bm_w_baka = "Micro Uzi",
		bm_w_x_baka = "Akimbo Micro Uzis",
		bm_w_polymer = "Vector",
		bm_w_x_polymer = "Akimbo Vectors",
		bm_w_sr2 = "Veresk",
		bm_w_x_sr2 = "Akimbo Veresks",

		bm_w_b682 = "Joceline 682 O/U",
		bm_w_huntsman = "Mosconi SxS",
		bm_w_aa12 = "Firebrand Auto-Assault CQB",
		bm_w_boot = "Breaker 1887",
		bm_w_r870 = "Reinbeck 870 Tactical",
		bm_w_serbu = "Locomotive Super Shorty",
		bm_w_ksg = "KSG Raven", -- kel-tec shot gun
		bm_w_spas12 = "SPAS-12",
		bm_w_saiga = "SAIKA.12",
		bm_w_benelli = "M1014",
		bm_w_judge = "Judge",
		bm_w_x_judge = "Akimbo Judges",
		bm_w_striker = "Street Sweeper",
		bm_w_m37 = "M37",
		bm_w_m37primary = "M37",
		bm_w_rota = "Goliath",
		bm_w_x_rota = "Akimbo Goliaths",
		bm_w_basset = "GRIMM",
		bm_w_x_basset = "Brothers GRIMM",
		bm_w_coach = "Claire Exposed-Hammer SxS",
		bm_w_coachprimary = "Claire Exposed-Hammer SxS",

		bm_w_rpk = "RPK",
		bm_w_m249 = "KSP 249",
		bm_w_hk21 = "Brenner 21E",
		bm_w_mg42 = "MG 42",
		bm_w_par = "KSP 58",

		bm_w_sparrow = "Sparrow 941 RPL",
		bm_w_x_sparrow = "Akimbo Sparrows",
		bm_w_pl14 = "PL-14",
		bm_w_x_pl14 = "Akimbo PL-14s",
		bm_w_packrat = "Contractor Tactical",
		bm_w_x_packrat = "Akimbo Contractors",
		bm_w_b92fs = "Bernetti 9-S",
		bm_w_x_b92fs = "Akimbo Bernettis",
		bm_w_lemming = "AP Army",
		bm_w_legacy = "M13",
		bm_w_x_legacy = "Akimbo M13s",
		bm_w_glock_17 = "Chimano 88",
		bm_w_x_g17 = "Akimbo Chimano 88s",
		bm_w_glock_18c = "Chimano 18C STRYK",
		bm_w_x_g18c = "Akimbo STRYKs",

		bm_w_g22c = "Chimano 22 Custom",
		bm_w_x_g22c = "Akimbo Chimano Customs",
		bm_wp_pis_g26 = "Chimano 26 Compact",
		bm_w_jowi = "Akimbo Chimano Compacts",
		bm_w_usp = "Interceptor Tactical",
		bm_w_x_usp = "Akimbo Interceptors",
		bm_w_ppk = "Gruber Kurz",
		bm_w_x_ppk = "Akimbo Gruber Kurzes",
		bm_w_colt_1911 = "Crosskill Operator",
		bm_w_x_1911 = "Akimbo Crosskill Operators",
		bm_w_shrew = "Crosskill Guard",
		bm_w_x_shrew = "Akimbo Crosskill Guards",
		bm_w_p226 = "Signature 40",
		bm_w_x_p226 = "Akimbo Signatures",
		bm_w_hs2000 = "LEO-45",
		bm_w_x_hs2000 = "Akimbo LEOs",
		bm_w_c96 = "C96",
		bm_w_x_c96 = "Akimbo C96s",
		bm_w_breech = "Pistole Parabellum",
		bm_w_x_breech = "Akimbo Parabellums",

		bm_w_peacemaker = "Peacemaker",
		bm_w_raging_bull = "Bronco .44",
		bm_w_x_rage = "Akimbo Broncos",
		bm_w_deagle = "Deagle Mk XIX",
		bm_w_x_deagle = "Akimbo Deagles",
		bm_w_mateba = "Matever 2006M",
		bm_w_x_2006m = "Akimbo Matevers",
		bm_w_chinchilla = "M29 Castigo",
		bm_w_x_chinchilla = "Akimbo Castigos",

		bm_w_gre_m79 = "GL40",
		bm_w_slap = "GL320",
		bm_w_m32 = "Seraph MGL",
		bm_w_china = "China Lake Launcher",
		bm_w_arbiter = "XM25 Arbiter",
		bm_w_rpg7 = "RPG.7",

		bm_w_ray = "M202 SOLDAT",
		bm_w_flamethrower_mk2 = "Urobach",
		bm_w_system = "The Big Torch",
		bm_w_hunter = "Hunter TC1-50", -- cb1-50
		bm_w_arblast = "Arbalest",
		bm_w_frankish = "Stakeholder",
		--bm_w_long = "English Longbow",
		bm_w_elastic = "QR5 Compound Bow",
		--bm_w_ecp = "Airbow",
		bm_w_m134 = "Hephaestus",
		bm_w_shuno = "XL Microgun",

		-- custom weapons
		bm_w_sr3m = "SR Einheri",
		bm_w_contender = "The Contender",
		bm_w_unica6 = "Matever 6 Unica",
		bm_w_m2hb = "M2 Heavy Barrel",
		bm_w_cz = "CZ 75 Shadow Tactical",
		bm_w_x_cz = "Akimbo Shadow Tacticals",
		bm_w_svt40 = "SVT.40",
		bm_w_akrocket = "AN.94M",
		bm_w_tilt = "AN.92",
		bm_w_pm = "Makarov",
		bm_w_x_pm = "Akimbo Makarovs",
		bm_w_xs_pm = "Akimbo Makarovs",
		bm_w_m1912 = "Winchester Model 1912",
		bm_w_m1894 = "Marlin 1894 Custom",
		bm_w_svudragunov = "SVU-T",
		bm_w_svu = "SVU",
		bm_w_g43 = "Gewehr 43",
		bm_w_obrez = "Obrez",
		bm_w_bar = "BAR",
		bm_w_qbz97b = "QBZ-97B",
		bm_w_seburo = "Seburo M5",
		bm_w_temple = "Weltallzauberei 11", -- space magic
		bm_w_b93r = "Bernetti Raffica",
		bm_w_x_toz66 = "Akimbo TOZ-66s",
		bm_w_pdr = "PDR",
		bm_w_aug9mm = "UAR9-XS",
		bm_w_yayo = "Montana AR-15 + 'Little Friend'",
		bm_w_sonny = "Bren Ten",
		bm_w_x_sonny = "Akimbo Bren Tens",
		bm_w_stg44 = "StG 44",
		bm_w_g3m203 = "Gewehr 3 Ausf. 3GL",
		bm_w_bajur = "Itachi .300",
		bm_w_m200 = "Intervention",
		bm_w_x_minebea = "Akimbo Minebeas",
		bm_w_af2011 = "Crosskill Double-Take",
		bm_w_x_af2011 = "Akimbo Double-Takes",
		bm_w_hx25 = "HX25",
		bm_w_amt = "AutoMag",
		bm_w_ots_14_4a = "Groza",
		bm_w_mk18s = "Mk 18 Mod 1",
		bm_w_drongo = "SG416C",
		bm_w_recce = "SG417D",
		bm_w_acwr2 = "Masada ACR",
		bm_w_acwr = "Masada ACR + M203",
		bm_w_saigry = "SAIGYO",
		bm_w_vityaz = "SN Vityaz",
		bm_w_wargoddess = "Mk 14 EBR",
		bm_w_px4 = "Px4 Storm",
		bm_w_p99 = "P99AS",
		bm_w_vepr12 = "VEPR.12",
		bm_w_m3 = "Grease Gun",
		bm_w_x_m3 = "Akimbo Grease Guns",
		bm_w_howa = "Howa Type 89",
		bm_w_vp70 = "VP70M",
		bm_w_x_vp70 = "Akimbo VP70Zs",
		bm_w_lapd = "M2019",
		bm_w_x_lapd = "Akimbo M2019s",
		bm_w_mikon = "Onmyoji R5",
		bm_w_nya = "Danya IDW",
		bm_w_x_nya = "Akimbo Danya IDWs",
		bm_w_lazy = "ARX160 A2",
		bm_w_m60 = "M60",
		bm_w_lsat = "LSAT LMG",
		bm_w_fang45 = "Fang 45",
		bm_w_czauto = "CZ 75 Automatic",
		bm_w_trench = "Winchester Model 1897",
		--bm_w_tm1a1 = "Thompson M1A1",
		bm_w_x_tm1a1 = "Akimbo Thompson M1A1s",
		bm_w_m6g = "M6G PDWS",
		bm_w_x_m6g = "Akimbo M6Gs",
		bm_w_kolibri = "Kolibri",
		bm_w_lynx = "GM-6 Lynx",
		bm_w_leet = "KBR Robin", -- kel-tec battle/bullpup rifle, in the same vein as the raven
		bm_w_max9 = "Maxim 9",
		bm_w_auto5 = "Browning Auto-5",
		bm_w_scarl = "Eagle Light",
		bm_w_scar_m203 = "Eagle Light + M203",
		bm_w_ak12_200 = "AK-2013",
		bm_w_ak12_76 = "AK-2013/76",
		bm_w_beer = "Beretta 93R",
		bm_w_x_beer = "Akimbo Beretta 93R",
		--bm_w_mas49 = "MAS-49",
		--bm_w_sks = "SKS",
		bm_w_kar98k = "Karabiner 98k"
		--bm_w_mdr = "Desert Tech MDR",
		--bm_w_m40a5 = "M40A5",
		--bm_w_pb = "PB",
		--bm_w_welrod = "Welrod",
		--bm_w_hshdm = "High Standard HDM",
		--bm_w_x_hshdm = "Akimbo High Standard HDM",
		--bm_w_heffy_939 = "AK-9",
		--bm_w_heffy_762 = "AK-47",
		--bm_w_heffy_556 = "AK-101",
		--bm_w_m1895 = "Nagant M1895",
		--bm_w_ppsh = "PPSh-41",
		--bm_w_pps43 = "PPS-43",
		--bm_w_sjogren = "Sjögren Inertia",
		--bm_w_rhino = "Chiappa Rhino 60DS",
		--bm_w_rally = "CZ 75 Short Rail",
		--bm_w_x_rally = "Akimbo CZ 75 Short Rail",
		--bm_w_cz75b = "CZ 75 B",
		--bm_w_x_cz75b = "Akimbo CZ 75 B",
		--bm_w_gtt33 = "TT-33",
		--bm_w_rpd = "RPD",
		--bm_w_dp28 = "DP-27",
		--bm_w_m45a1 = "M45A1 CQBP",
		--bm_w_sg552 = "SG 552",
		--bm_w_l1a1 = "L1A1 SLR",
		--bm_w_owen = "Owen Gun",
		--bm_w_toz34 = "TOZ-34",
		--bm_w_toz66 = "TOZ-66",
		--bm_w_l115 = "L115",
		--bm_w_stf12 = "STF-12 Compact",
		--bm_w_minebea = "Minebea PM-9"
		--bm_w_zenith = "Zenith 10mm"
		--bm_w_wmtx = "Widowmaker TX"
		--bm_w_dp12 = "DP-12"
		--bm_w_l35 = "Lahti L-35"
		--bm_w_lewis = "Lewis Gun"
		--bm_w_hk416 = "HK416"
		--bm_w_m1894 = ""
	})
else
	-- lame default-styled names
	LocalizationManager:add_localized_strings({
		bm_w_m37primary = "GSPS 12G",
		bm_w_coachprimary = "Claire 12G",
		bm_w_olympicprimary = "Para Submachine Gun",
		bm_w_coalprimary = "Tatonka Submachine Gun",
		bm_w_m1928primary = "Chicago Typewriter Submachine Gun",
		bm_w_hajkprimary = "CR 805B Submachine Gun",
		bm_w_shepheardprimary = "Signature Submachine Gun",
		bm_w_new_mp5primary = "Compact-5 Submachine Gun",
		bm_w_mp9primary = "CMP Submachine Gun",
		bm_w_schakalprimary = "Jackal Submachine Gun",
		bm_w_ermaprimary = "MP40 Submachine Gun",
		bm_w_sr2primary = "Heather Submachine Gun",
		bm_w_p90primary = "Kobus 90 Submachine Gun",
		bm_w_m45primary = "Swedish K Submachine Gun",
		bm_w_akmsuprimary = "Krinkov Submachine Gun",
		bm_w_mp7primary = "SpecOps Submachine Gun",
		bm_w_scorpionprimary = "Cobra Submachine Gun",
		bm_w_tec9primary = "Blaster 9mm Submachine Gun",
		bm_w_uziprimary = "Uzi Submachine Gun",
		bm_w_cobrayprimary = "Jacket's Piece",
		bm_w_bakaprimary = "Micro Uzi Submachine Gun"
	})
end


	LocalizationManager:add_localized_strings({
	-- primary weapon categories
	menu_assault_rifle = "Light Rifle",
	menu_rifle_m = "Medium Rifle",
	menu_rifle_h = "Heavy Rifle",
	menu_dmr = "Marksman Rifle",
	menu_akimbo_pistol = "Akimbo L.Pistol",
	menu_akimbo_pistol_m = "Akimbo M.Pistol",
	menu_akimbo_pistol_h = "Akimbo H.Pistol",
	menu_akimbo_smg = "Akimbo S.SMG",
	menu_akimbo_smg_h = "Akimbo L.SMG",
	menu_akimbo_carbine = "Akimbo Carbine",

	-- secondary weapon categories
	menu_pistol = "Light Pistol",
	menu_pistol_m = "Medium Pistol",
	menu_pistol_h = "Heavy Pistol",
	menu_smg = "Short SMG",
	menu_smg_h = "Long SMG",
	menu_carbine = "Carbine",
	menu_lmg = "Machine Gun",

	menu_l_global_value_infmod = "This is an IREnFIST item!",


	-- weapon mod categories
	bm_menu_ammo2 = "Ammunition",
	bm_menu_foregrip = "Handguard",
	bm_menu_foregrip_plural = "Handguards",
	bm_menu_removal = "Removal",
	bm_menu_removal_plural = "Removals",
	bm_menu_sight_irons = "Ironsight",
	bm_menu_sight_irons_plural = "Ironsights",
	bm_menu_sight_rail = "Sight Rail",
	bm_menu_sight_rail_plural = "Sight Rails",
	bm_menu_custom = "Internals",
	bm_menu_custom_plural = "Internals",
	bm_menu_weirdmagthing = "Magwell",
	bm_menu_weirdmagthing_plural = "Magwells",
	bm_menu_zzzz = "????",
	bm_menu_zzzz_plural = "????",
	-- operator attachment pack
	bm_menu_piston = "Gas System",


	caliber_r556x45 = "5.56x45mm.",
	caliber_r556x45m855 = "5.56x45mm M855A1.",
	caliber_r556x45m193 = "5.56x45mm M193.",
	caliber_r556x45mk262 = "5.56x45mm Mk 262 Mod 1.",
	caliber_r556x45mk318 = "5.56x45mm Mk 318.",
	caliber_r556x45jp = "5.56x45mm Japanese.",
	caliber_r556x45ct = "5.56x45mm Cased Telescoped.",
	caliber_r56gp90 = "5.6mm GP 90.",
	caliber_r545x39 = "5.45x39mm.",
	--caliber_r545x39ap = "5.45x39mm 7M22.",
	caliber_r762x39 = "7.62x39mm.",
	--caliber_r762x39ap = "7.62x39mm 7N23.",
	caliber_r762x51 = "7.62x51mm.",
	caliber_r762x51dm151 = "7.62x51mm DM151.", -- too lazy to spend hours digging up info on this
	caliber_r762x51m80 = "7.62x51mm M80.",
	caliber_r762x51jp = "7.62x51mm Japanese.",
	caliber_r762x54r = "7.62x54mmR.",
	caliber_r3006 = ".30-06 Springfield.",
	caliber_r3006surplus = ".30-06 M2 Ball.",
	caliber_r3030 = ".30-30 Winchester.",
	caliber_r338 = ".338 Lapua Magnum.",
	caliber_r9x39 = "9x39mm.",
	caliber_r9x39sp6 = "9x39mm SP-6.",
	caliber_r9x39bp = "9x39mm BP.",
	caliber_r4440 = ".44-40 Repeater.",
	caliber_r50bmg = ".50 BMG.",
	caliber_r50bmgm8 = ".50 BMG M8 API.",
	caliber_r50bmgmk211 = ".50 BMG Mk 211 Mod 0 HEIAP.",
	caliber_r792mauser = "7.92x57mm Mauser.",
	caliber_r792mauserk = "7.92x57mm S.m.K.",
	caliber_r792x33 = "7.92x33mm Kurz.",
	caliber_r68 = "6.8x43mm SPC.",
	caliber_r50beowulf = ".50 Beowulf.",
	caliber_r300blackout = ".300 AAC Blackout.",
	caliber_r65grendel = "6.5mm Grendel.",
	caliber_r30carbine = ".30 Carbine.",
	caliber_r58x42 = "5.8x42mm DBP87.",
	caliber_r473x33 = "4.73x33mm DM11.",
	caliber_r308 = ".308 Winchester.",
	caliber_r408cheytac = ".408 CheyTac.",
	caliber_r280 = ".280 British.",
	caliber_r303 = ".303 British.",
	caliber_r127x108 = "12.7x108mm.",
	caliber_r75x54 = "7.5x54mm French.",

	caliber_p9x18 = "9x18mm Makarov.",
	caliber_p9x19 = "9x19mm Parabellum.",
	caliber_p9x19idw = "9x19mm G&K.",
	caliber_p9x19m39b = "9x19mm m/39B.",
	caliber_p9x19nade = "9x19mm +P",
	caliber_p9x21 = "9x21mm Gyurza.",
	caliber_p9x21imi = "9x21mm IMI.",
	caliber_p10 = "10mm Auto.",
	caliber_p10hr = "10mm QAP.",
	caliber_p40sw = ".40 S&W.",
	caliber_p45acp = ".45 ACP.",
	caliber_p45s = ".45 Super.",
	caliber_p32acp = ".32 ACP.",
	caliber_p46 = "4.6x30mm.",
	caliber_p57 = "5.7x28mm.",
	caliber_p762x25 = "7.62x25mm Tokarev.",
	caliber_p762x25badtaste = "7.62x25mm Anectine.",
	caliber_p763mauser = "7.63x25mm Mauser.",
	caliber_p45lc = ".45 Long Colt.",
	caliber_p357 = ".357 Magnum.",
	caliber_p44 = ".44 Magnum.",
	caliber_p50ae = ".50 Action Express.",
	caliber_p545x18 = "5.45x18mm 7N7.",
	caliber_p38spc = ".38 Special.",
	caliber_p38sup = ".38 Super.",
	caliber_p44amp = ".44 AMP.",
	caliber_p117saphp = "12.7x40mm M228 SAP-HP.", -- high pen, not hollow point
	caliber_p117he = "12.7x40mm M227 HE.", -- that's a made-up number
	caliber_p117ic = "12.7x40mm M226 IC.", -- ditto
	caliber_p117saphe = "12.7x40mm M225 SAP-HE.",
	caliber_p762x38r = "7.62x38mmR.",
	caliber_p2mmkolibri = "2.7x9mm Kolibri.",
	caliber_p22lr = ".22 Long Rifle.",
	caliber_pscaramanga = "4.2mm Gold-Nickel.",

	caliber_s12g = "12 gauge 2 3/4\".",
	caliber_s12g_ap = "12 gauge 2 3/4\" AP slug.",
	caliber_s12g_000 = "12 gauge 2 3/4\" 000 buck.",
	caliber_s12g_he = "12 gauge 2 3/4\" HE-FRAG.",
	caliber_s12g_fl = "12 gauge 2 3/4\" flechette.",
	caliber_s12g_db = "12 gauge 2 3/4\" dragon's breath.",
	caliber_s12g_breach = "12 gauge 2 3/4\" breacher.",
	caliber_s12g_000magnum = "12 gauge magnum 000 buck.",
	caliber_s12g1887 = "12 gauge 2 5/8\".",
	caliber_s12g1887_ap = "12 gauge 2 5/8\" AP slug.",
	caliber_s12g1887_000 = "12 gauge 2 5/8\" 000 buck.",
	caliber_s12g1887_he = "12 gauge 2 5/8\" HE-FRAG.",
	caliber_s12g1887_fl = "12 gauge 2 5/8\" flechette.",
	caliber_s12g1887_db = "12 gauge 2 5/8\" dragon's breath.",
	caliber_s12g1887_breach = "12 gauge 2 5/8\" breacher.",
	caliber_s410 = ".410 bore.",
	caliber_s410_ap = ".410 AP slug.",
	caliber_s410_000 = ".410 000 buck.",
	caliber_s410_he = ".410 HE-FRAG.",
	caliber_s410_fl = ".410 flechette.",
	caliber_s410_db = ".410 dragon's breath.",
	caliber_s410_breach = ".410 breacher.",
	caliber_s23mm = "23x75mmR.",
	caliber_s23mm10 = "23x75mmR SHRAPNEL-10.",
	caliber_s23mm25 = "23x75mmR SHRAPNEL-25.",
	caliber_s12dx = "12 gauge Ostrava.",

	caliber_g40mm = "40x46mm grenade.",
	caliber_g40mmIC = "40x46mm incendiary grenade.",
	caliber_g25mm = "25x40mm grenade.",
	caliber_g25mmIC = "25x40mm incendiary grenade.",
	caliber_ghx25 = "Horzine cluster grenade.",
	caliber_ghx25buck = "Horzine buckshot grenade.",
	caliber_ghx25db = "Horzine Dragon's Breath grenade.",

	caliber_apoison = "Poison arrow.",
	caliber_aexplosive = "Explosive arrow.",
	caliber_bpoison = "Poison bolt.",
	caliber_bexplosive = "Explosive bolt.",

	caliber_saw = "420mm multipurpose blade.",
	caliber_saw_sharp = "420mm sharpened blade.",
	caliber_saw_durable = "420mm durable blade.",

	caliber_flammenwerfer = "Flammable gas mix.",
	caliber_forcommies = "Fast-burning gas mix.",
	caliber_forjournalists = "Long-burning gas mix.",


	action_gas = "Gas-operated action.",
	action_gaslong = "Long-stroke gas-operated action.",
	action_gaslongaks74 = "Long-stroke gas-operated action with muzzle booster.",
	action_gasshort = "Short-stroke gas-operated action.",
	action_gaslsat = "Gas-piston and swinging chamber.",
	action_di = "Direct impingement action.",
	action_blowback = "Blowback-operated action.",
	action_blowbackstraight = "Straight blowback action.",
	action_blowbackdelayed = "Delayed blowback action.",
	action_blowbackgasdelayed = "Gas-delayed blowback action.",
	action_blowbacklever = "Lever-delayed blowback action.",
	action_blowbackroller = "Roller-delayed blowback action.",
	action_blowbackapi = "API blowback action.",
	action_piston = "Gas piston action.",
	action_pistonshort = "Short-stroke piston action.",
	action_rollerlock = "Roller-locked recoil operation.",
	action_recoil = "Recoil-operated action.",
	action_longrecoil = "Long recoil action.",
	action_shortrecoil = "Short recoil action.",
	action_shortrecoilmod = "Modified short recoil action.",
	action_shortrecoilluger = "Toggle-locked short recoil action.",
	action_an94 = "Gas and pulley action.",

	action_breech = "Breech-loaded.",
	action_lever = "Lever action.",
	action_bolt = "Bolt action.",
	action_pump = "Pump action.",
	action_breakopen = "Break-open.",
	action_breakou = "Break-open over-under.",
	action_breaksxs = "Break-open side-by-side.",
	action_spas_valve = "Special pump-action.",
	action_spas_sven = "Pump/semi-automatic action.",

	action_sa = "Single-action trigger.",
	action_da = "Double-action trigger.",
	action_dasa = "DA/SA trigger.",
	action_mateba = "Semi-auto DA/SA trigger.",

	action_minigun = "Motor-driven rotary gun.",
	action_flammenwerfer = "Dual ignition system.",
	action_blowtorch = "Novelty blowtorch.",

	action_saw = "Standard electric motor.",
	action_saw_fast = "Boosted electric motor.",
	action_saw_silent = "Muffled electric motor.",

	action_devotion = "Cyclic accelerator.",

	action_wang = "Wang action.",


	--misc_quickdraw = "+10% switch speed.",
	misc_quickdraw = "switch speed.",
	misc_alwayssilent = "Integral suppressor.",
	misc_gl40x46mm = "Underbarrel 40x46mm grenade launcher.",
	misc_gl40x46mmbuck = "Underbarrel 40x46mm buckshot launcher.",
	misc_gl40x46mmflechette = "Underbarrel 40x46mm flechette launcher.",
	misc_gl40x46mmIC = "Underbarrel 40x46mm incendiary launcher.",
	misc_gl40vog = "Underbarrel 40mm caseless grenade launcher.",
	misc_flammen = "Underbarrel flamethrower.",
	misc_irons = "Ironsighted.",
	misc_blank = "",

	sdesc3_falloff = "100%/0% damage at ",
	sdesc3_spinup = " spin up/down time.",

	range_shotslug = "Range falloff removed.",
	range_shotdb = "15m range.",




	-- CODEX SHIT
	menu_infcodex = "IREnFIST",

	infcodex_recoil = "Recoil",
	infcodex_recoil_desc = "All weapons have a table or list of recoil values that dictate the recoil's strength and direction. This makes recoil predictable to an extent, as you can know exactly when a gun begins to slip out of your control and how it will act before then.",
	infcodex_recoil2_desc = "Everyone shot moves you one entry up the table. Not shooting for 0.25 seconds allows recoil recovery to begin. Every 0.03 seconds after, you move back one entry in the table. Recoil tables are of finite length. Going beyond that length resets your position on the table to an earlier point, so you won't take 3.25 seconds to recover from emptying a Bootleg.",
	infcodex_recoil3_desc = "Shotguns and sniper rifles are unusual in that they have no strict pattern. Horizontal recoil chooses a range of values like in vanilla PAYDAY, rather than using a strictly defined value.",

	infcodex_shotgun = "Shotguns",
	infcodex_shotgun_desc = "Buckshot damage is scaled per target based on how many of the pellets fired hit that target. With almost all shotguns, the minimum possible damage is 25%.",
	infcodex_shotgun2_desc = "Given P = number of pellets fired and H = number of pellets that hit a given target, the damage scaling is as follows:\nMultiplier = (P + 5H)/6P\n\nShotguns fire ten pellets by default.",

	infcodex_scavenge = "Ammo Scavenging",
	infcodex_scavenge_desc = "Ammo scavenge mechanics for most weapons work like in vanilla PAYDAY, except that the base ammo scavenge per box is set to 2%-6% of max ammo instead of varying by weapon type.\n\nCertain weapons in vanilla PAYDAY could randomly scavenge zero ammo. IREnFIST has replaced this with a non-random 'ammo fraction' system.",
	infcodex_scavenge2_desc = "Weapons using the 'ammo fraction' system fill up a percentage tracker when scavenging from ammo boxes. When this percent reaches 100%, 1 ammo is granted and the percent is reset to 0%. The percent gained per ammo box is affected by ammo scavenge bonuses i.e. Walk-In Closet, Fully Loaded Aced.",
	infcodex_scavenge3_desc = "Example: The GL-40 has a base ammo fraction value of 20% per box. It takes five pickups to scavenge one grenade (20*5 = 100). With Walk-In-Closet's 35% bonus, it takes four (27*4 = 108). With Fully-Loaded Ace's 75% bonus, it takes three (35*3 = 105).",
	infcodex_scavenge4_desc = "Ammo fraction values for base game weapons:\n- 15%: Little Friend launcher, Seraph MGL/Piglet, China Lake/China Puff, M320\n - 20%: GL40, Arbiter\n - 100%: Bow (except Arbalest/Heavy Crossbow)\n - OTHER: Thanatos (50%), RPG-7 (3%), M202 SOLDAT/Commando 101 (6%), Arbalest/Heavy Crossbow (60%)",
	infcodex_scavenge5_desc = "Ammo fraction values for custom weapons:\n- 15%: Montana 5.56 Grenade, G3A3 Grenade, SCAR-L grenade\n- 50%: G3A3 Shotguns, SCAR-L shotguns, HX25 Grenade, Golden Gun\n100%: KS-23, HX25 Buckshot",

	infcodex_ap = "Armor Piercing",
	infcodex_ap_desc = "Tan chestplates are always penetrated, but usually at a damage penalty. The multiplier depends on base weapon type and can be affected by weapon mods.",
	infcodex_ap2_desc = "- Light Rifle/Medium/Heavy Rifle/DMR: 75%/66%/75%/100%\n- Sniper Rifle: 100%\n- Light/Medium/Heavy Pistol: 64%/75%/100%\n- Shotgun/KS-23: 50%/100%\n- SMG/Carbine: 60%/75%\n- 50dmg LMG/55dmg LMG/Minigun: 60%/80%/50%",

	infcodex_enehp = "Enemy Health",
	infcodex_enehp_desc = "OVERKILL TRASH\nNAME: HEALTH/HS MULT (HEAD HEALTH)\nBlues: 135/3 (45)\nGreens: 150/3 (50)\nGrays: 165/3 (55)\nWhiteheads: 175/2.5 (70)\nTans: 200/2 (100)",
	infcodex_enehp2_desc = "OVERKILL SPECIALS\nNAME: HEALTH/HS MULT (HEAD HEALTH)\nShield: 100/2 (50, 200 through shield)\nSniper: 50/2 (25)\nTaser/Medic: 310/2 (155)\nCloaker: 360/4 (90)\nBulldozer: 9000/25 (360)\nBosses: 4000/2 (2000)",
	infcodex_enehp3_desc = "MAYHEM TRASH\nNAME: HEALTH/HS MULT (HEAD HEALTH)\nBlues: 150/2 (75)\nGreens: 160/2 (80)\nGrays: 200/2.5 (80)\nWhiteheads: 240/2 (120)\nTans: 270/1.8 (150)",
	infcodex_enehp4_desc = "MAYHEM SPECIALS\nNAME: HEALTH/HS MULT (HEAD HEALTH)\nShield: 110/2 (55, 220 through shield)\nSniper: 70/2 (35)\nTaser/Medic: 385/1.75 (220)\nCloaker: 560/4 (140)\nBulldozer: 10,000/20 (500)\nBosses: 5000/2 (2500)",
	infcodex_enehp5_desc = "DW TRASH\nNAME: HEALTH/HS MULT (HEAD HEALTH)\nBlues: 200/2 (100)\nGreens: 210/2 (105)\nGrays: 220/2 (110)\nWhiteheads: 270/1.8 (150)\nTans: 390/2 (195)",
	infcodex_enehp6_desc = "DW SPECIALS\nNAME: HEALTH/HS MULT (HEAD HEALTH)\nShield: 140/1.75 (80, 320 through shield)\nSniper: 100/2 (50)\nTaser/Medic: 455/1.75 (260)\nCloaker: 600/4 (150)\nBulldozer: 11,250/15 (750)\nBosses: 7000/2 (3500)",
	infcodex_enehp7_desc = "DEATH SENTENCE\nEnemy health and damage is identical to Death Wish. The grace period between taking two shots of equivalent or less damage is reduced from 0.35 seconds to 0.20 seconds.",

	infcodex_categories = "Weapon Categories",
	infcodex_categories_desc = "For the purposes of the activating skills etc, the listed weapon categories are treated as follows:\n- Marksman Rifles/Carbines are Assault Rifles",

	infcodex_movement = "Advanced Movement",
	infcodex_movement_desc = "GENERAL INFO\n- All advanced movement options grant 10% dodge and use stamina unless otherwise stated.",
	infcodex_movement2_desc = "SLIDING\n- To slide, crouch from a sprint or sprint-jump. If hold-to-slide is on (check the mod options to change), also hold a movement key while sliding.\n- Use movement keys to change slide direction or stop. Slides are instantly stopped by uncrouching.\n- Slides can be extended or shortened by sloped surfaces.",
	infcodex_movement3_desc = "WALLHANGING/WALLKICKING\n- To wallhang, hold jump while approaching or near a wall to hang on it. While hanging, release jump to wallkick in the direction you're facing.\n- Aiming down sights makes you slip down the wall at 25% speed for up to 6 seconds.",
	infcodex_movement4_desc = "KICKING\n- To kick: sprint, wallkick, dash, or slide into an object or enemy for 50 damage and 500 knockdown. Kicks done from a wallkick deal twice as much damage and have stronger knockdown.\n- Shields can be knocked over from the front with Shock and Awe aced.\n- Hitting enemies drains stamina. Hitting inanimate objects does not.",
	infcodex_movement5_desc = "DASHING\n- To dash, double-tap a directional movement key. This can be done while sliding.\n- Dashes grant 20% dodge instead of 10%.\n- Dashes do not cost stamina, but will stop stamina regeneration.",
	infcodex_movement6_desc = "WALLRUNNING\n- To wallrun, jump towards a wall and tap (or mash) sprint, or wallkick into a wall.\n- Jump while wallrunning to wallkick.\n- Wallrunning requires a long and flat surface to work at all, making it hard or nearly impossible to use without a purpose-designed wallrunning map.",

	infcodex_flace = "Fully Loaded Aced",
	infcodex_flace_desc = "SCAVENGE CHANCE AND QUANTITY\nIncendiary Grenade: 1.5x base chance\nStun Grenade: 2x base chance\nJavelin: 2x base chance\nShuriken: 2x base chance, 3 per scavenge\nThrowing Knives: 2x base chance, 3 per scavenge\nThrowing Axes: 2x base chance, 2 per scavenge\nThrowing Cards: 4x base chance, 4 per scavenge\nAll others: no change",



	-- skill renames

	-- MASTERMIND
	menu_stable_shot_beta = "Cool Under Pressure",
	menu_stable_shot_beta_desc = "BASIC: ##$basic##\nYou reload all weapons ##5%## faster.\n\nACE: ##$pro##\nYour reload speed bonus is increased to ##10%##.",
	-- marksman
	menu_sharpshooter_beta_desc = "BASIC: ##$basic##\nYou gain ##10## accuracy with SMGs, assault rifles, and sniper rifles fired in single-fire mode.\n\nACE: ##$pro##\nYou deal ##17.5%## more damage with headshots.",
	-- rifleman
	menu_rifleman_beta_desc = "BASIC: ##$basic##\nYou aim down the sights ##100%## faster with all weapons and reload sniper rifles ##15%## faster.\n\nACE: ##$pro##\nYou also reload SMGs and assault rifles ##15%## faster.",
	menu_speedy_reload_beta = "Have a Plan",
	menu_speedy_reload_beta_desc = "BASIC: ##$basic##\nYou regain ##5## armor after headshotting with a sniper rifle.\n\nACE: ##$pro##\nThe armor regain is increased to ##50##.",
	-- Stockholm Syndrome
	menu_stockholm_syndrome_beta_desc = "BASIC: ##$basic##\nCivilians are intimidated by the noise you make and remain intimidated ##50%## longer.\n\nYou can call over civilians and converted enemies to revive you. The civilian can be tied or untied.\n\nACE: ##$pro##\nYour hostages will not flee when they have been rescued by law enforcers. Whenever you get into custody, your hostages will trade themselves for your safe return. This effect can occur during assaults, but only ##1## time during a heist.",

	-- ENFORCER
	-- fully loaded
	menu_bandoliers_beta_desc = "BASIC: ##$basic##\nYou hold ##25%## more total ammo.\n\nACE: ##$pro##\nYour ammo scavenge rate is set to ##150%##. You also have a base ##5%## chance to get a throwable from scavenging, increasing by ##1%## for every ammo pickup without a throwable. This chance resets upon finding a throwable. Throwables with higher capacities have higher scavenge rate and quantity.\n\nSee the Contact Database for exact values.",
	-- overkill
	menu_overkill_beta = "Last Word",
	menu_overkill_beta_desc = "BASIC: ##$basic##\nOn shotguns with a base capacity of at least ##4##, the last shell deals ##100%## more damage.\n\nACE: ##$pro##\nThe second-to-last shell also deals ##100%## more damage.",
	-- far away
	menu_far_away_beta = "Surgical Shot",
	menu_far_away_beta_desc = "BASIC: ##$basic##\nYour shotguns lose ##25%## less damage from not having every pellet hit the same target.\n\nACE: ##$pro##\nThe damage loss from not hitting the same target with all pellets is now reduced by ##50%##.\n\nNote: Damage scales from 100% to roughly 30% depending the percentage of pellets that hit the same target.",
	-- close by
	menu_close_by_beta = "Danger Close",
	menu_close_by_beta_desc = "BASIC: ##$basic##\nYou can now hip-fire with shotguns while sprinting.\n\nACE: ##$pro##\nHaving a non-akimbo shotgun equipped increases all weapon switch speed by ##30%##.",
	-- shotgun cqb
	menu_shotgun_cqb_beta_desc = "BASIC: ##$basic##\nYou reload shotguns ##10%## faster.\n\nACE: ##$pro##\nYour shotgun reload speed bonus is increased to ##20%##.",
	-- shotgun impact
	--menu_shotgun_impact_beta_desc = "BASIC: ##$basic##\nYour damage with shotguns is increased by ##10##.\n\nACE: ##$pro##\nYour damage bonus with shotguns is increased to ##25##.",
	menu_shotgun_impact_beta = "Close Range Assault",
	menu_shotgun_impact_beta_desc = "BASIC: ##$basic##\nKilling an enemy while sliding or dashing restores ##2## stamina. Killing an enemy while wallkicking or wallrunning restores ##3## stamina.\n\nACE: ##$pro##\nStamina restoration from advanced movement kills is ##doubled##.",

	-- GHOST
	-- duck and cover
	menu_sprinter_beta_desc = "BASIC: ##$basic##\nYour stamina starts regenerating ##25%## earlier and ##25%## faster. You also sprint ##25%## faster.\n\nACE: ##$pro##\nYou have a ##10%## increased chance to dodge while sprinting or sliding.",
	-- shockproof
	menu_insulation_beta_desc = "BASIC: ##$basic##\nWhen tased, the shock effect has a ##30%## chance to backfire on the Taser, knocking them back.\n\nACE: ##$pro##\nWhen tased, you are able to free yourself from the taser by interacting with it within ##2## seconds of getting tased.\n\nWhile being tased, your bullets will electrify enemies.",

	-- FUGITIVE
	-- desperado
	menu_expert_handling_desc = "BASIC: ##$basic##\nYou aim down the sights ##100%## faster with pistols.\n\nACE: ##$pro##\nYou reload both single and akimbo pistols ##20%## faster.",
	-- gun nut
	menu_dance_instructor = "Gun Kata",
	menu_dance_instructor_desc = "BASIC: ##$basic##\nHaving a pistol equipped as your secondary increases all weapon switch speed by ##10%##.\n\nACE: ##$pro##\nThe weapon switch speed bonus is increased to ##20%##.",
	-- akimbo
	menu_akimbo_skill_beta = "New York Reload",
	menu_akimbo_skill_beta_desc = "BASIC: ##$basic##\nWhen your akimbo weapons are empty, you switch weapons ##20%## faster.\n\nACE: ##$pro##\nYour akimbo weapons reload ##15%## faster when empty.",
	-- pumping iron
	menu_steroids_beta_desc = "BASIC: ##$basic##\nYou deal ##50%## more melee damage.\n\nACE: ##$pro##\nYour melee weapons charge ##100%## faster.",
	-- bloodthirst
	menu_bloodthirst_desc = "BASIC: ##$basic##\nEvery kill you get increases your melee damage by ##25%##, up to a maximum of ##300%##. This effect resets when you kill an enemy with a melee attack.\n\nACE: ##$pro##\nWhenever you kill an enemy with a melee attack, you gain a ##25%## increase in reload speed for ##5## seconds.",
	-- one-handed talent
	menu_gun_fighter_beta = "Off-Handed Reload",
	menu_gun_fighter_beta_desc = "BASIC: ##$basic##\nAfter switching to your secondary pistol, your primary weapon will automatically begin reloading itself. This reload takes ##4## times as long as a standard reload and is interrupted if you switch back to your primary.\n\nACE: ##$pro##\nYour off-hand reloads now only take ##3## times as long as a standard reload, and can also be initiated by switching to a secondary SMG, carbine, shotgun, or crossbow.",
	-- equilibrium
	menu_equilibrium_beta = "Plan B",
	menu_equilibrium_beta_desc = "BASIC: ##$basic##\nSwitch speed bonus for secondary pistols is increased to ##25%##.\n\nACE: ##$pro##\nSwitch speed bonus for secondary pistols is increased to ##30%##.",


	-- TECHNICIAN
	-- surefire
	menu_fast_fire_beta = "Bunker",
	menu_fast_fire_beta_desc = "BASIC: ##$basic##\nYou deploy bipods ##100%## faster.\n\nACE: ##$pro##\nYou take ##50%## less bullet damage when you have a bipod deployed.",
	-- steady grip
	menu_steady_grip_beta_desc = "BASIC: ##$basic##\nYou gain a minor stability bonus roughly equivalent to ##5%## recoil reduction.\n\nACE: ##$pro##\nThis stability bonus is now doubled to roughly ##10%##.",
	-- lock 'n load
	menu_shock_and_awe_beta_desc = "BASIC: ##$basic##\nYou can now hipfire your weapons while sprinting.\n\nACE: ##$pro##\nYour automatic rifles, sniper rifles, shotguns, SMGs, LMGs, and miniguns reload up to ##25%## faster as the magazine runs low.",
	-- fire control
	menu_fire_control_beta_desc = "BASIC: ##$basic##\nYour weapons now have ##10%## less horizontal recoil.\n\nACE: ##$pro##\nYour horizontal recoil is now reduced by ##30%##.",





	-- OVERDOGs
	menu_deck8_7_desc = "When you are surrounded by three or more enemies, you receive ##12%## less damage from enemies.\n\nYour second and each consecutive melee hit within ##5## seconds of the last one will deal ##2## times the damage. Missing a swing will reset this.",
	menu_deck9_1_desc = "When you are surrounded by three or more enemies, you receive ##12%## less damage from enemies.\n\nYour second and each consecutive melee hit within ##5## seconds of the last one will deal ##2## times the damage. Missing a swing will reset this.",

	menu_deckall_2 = "Get Cracking",
	menu_deckall_2_desc = "You gain ##45%## more experience from heists.",
	menu_deckall_4 = "Hustle",
	menu_deckall_4_desc = "When wearing armor, your movement speed is ##15%## less affected.",
	menu_deckall_6_desc = "Unlocks an armor bag equipment for you to use. The armor bag can be used to change your armor during a heist.",

	-- Sicario cooldown reduction
	menu_deck18_1_desc = "Unlocks and equips the throwable Smoke Bomb.\n\nWhen deployed, the smoke bomb creates a smoke screen that lasts for ##10## seconds. While standing inside the smoke screen, you and any of your allies automatically avoid ##50%## of all bullets. Any enemies that stand in the smoke will see their accuracy reduced by ##50%##.\n\nAfter the smoke screen dissipates, the Smoke Bomb is on a cooldown for ##30## seconds, but killing enemies will reduce this cooldown by ##1## second.",





	-- crew bonuses
	-- interact inspire scavenge ai ap ammo
	-- healthy sturdy evasive motivated regen quiet generous eager
	menu_crew_eager_desc = "Players reload and switch weapons 25% faster.",
	menu_crew_motivated_desc = "Players have 25 more stamina and the armor speed penalty is reduced by 25%.",





	-- BOOSTS
	bm_menu_bonus = "Charm",

	bm_wp_upg_bonus_team_exp_money_p3 = "Wear and Tear",
	bm_wp_upg_bonus_team_exp_money_p3_desc = "I fear not the man who has fired five thousand weapons once, but the man who has fired one weapon five thousand times." .. charm,

	bm_menu_bonus_concealment = "Natural Oil",
	bm_menu_bonus_concealment_desc = "The best gear used by the best heisters deserve the best treatment." .. charm,

	bm_menu_bonus_recoil = "Four-Leaf Clover",
	bm_menu_bonus_recoil_desc = "A traditional symbol of good luck. Well preserved." .. charm,

	bm_menu_bonus_spread = "Low-Background Metal",
	bm_menu_bonus_spread_desc = "A component specially made from uncontaminated metal produced before the first atomic tests." .. charm,

	bm_menu_bonus_total_ammo = "Microdrive",
	bm_menu_bonus_total_ammo_desc = "A tiny data storage device embedded inside the weapon." .. charm,




	bm_wp_inf_sightrail = "Sight Rail",
	bm_wp_inf_sightrail_desc = "Mounts sights in an alternative position.",
	bm_wp_inf_sightrail_invis = "Sight Rail",
	bm_wp_inf_sightrail_invis_desc = "Mounts sights in an alternative position.",


	-- lunacy
	inf_sight_wtfstop = "Oh shit, what are you doing?",

	-- default sniper scope
	bm_wp_inf_shortdot = "Hyperion-CR Magnified Scope",
	bm_wp_inf_shortdot_desc = "Standard mid-range optical scope, except now with customizable reticle. Courtesy of Gage.\n\nZoom level 6.",

	-- inf
	bm_wp_inf_bipod_snp = "Sniper Bipod",
	bm_wp_inf_bipod_snp_desc = "Press $BTN_GADGET to deploy. When deployed, reduce recoil by 50% and increase rate of fire by 25%.",

	-- backup irons
	bm_wp_inf_buis = "Backup Ironsights",
	bm_wp_inf_buis_desc = "Allows toggling between standard sights and backup sights.",
	bm_wp_inf_buis_desc_aug = "Allows use of backup sights on top of the A1 Scope.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_inf_lmg_offset = "Offset Aiming",
	bm_wp_inf_lmg_offset_desc = "Allows toggling between aiming directly down the sights and holding the weapon offset.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_inf_lmg_offset_nongadget = "Offset Aiming",
	bm_wp_inf_lmg_offset_nongadget_desc = "Holds the weapon offset to the side instead of aiming directly down the sights.\n\nToggle by pressing $BTN_GADGET.",

	-- ironsight retain
	bm_wp_inf_car4_ironsretain = ironsights.keepname,
	bm_wp_inf_car4_ironsretain_desc = ironsights.keepdesc,
	bm_wp_inf_amr16_ironsretain = ironsights.keepname,
	bm_wp_inf_amr16_ironsretain_desc = ironsights.keepdesc,
	bm_wp_inf_contraband_ironsretain = ironsights.keepname,
	bm_wp_inf_contraband_ironsretain_desc = ironsights.keepdesc,


	bm_wp_inf_m231fpw = "FPW Kit",
	bm_wp_inf_m231fpw_desc = "Experimental firing port weapon conversion kit. Fast, finicky, and wild.\n\nConverts weapon to open bolt.",


	bm_wp_inf_amr16_har = "M855A1 EPR",
	bm_wp_inf_amr16_har_desc = "Enhanced general-purpose 5.56x45mm cartridge. Intended to reduce lead accumulation at training ranges, but expanded into a general improvement program.",
	-- 300 blackout
	bm_wp_inf_car4_blk = ".300 AAC Blackout",
	bm_wp_inf_car4_blk_desc = "Enhanced-power round designed for use in US 5.56x45mm carbines with only a change in barrel.\n\n-33% ammo scavenge.",
	-- burst fire
	bm_wp_inf_burst_only = "Burst-Only Trigger Group",
	bm_wp_inf_burst_only_desc = "Trigger pack capable of semi-automatic and three-shot burst.",
	bm_wp_inf_burst = "Burst-Enabled Trigger Group",
	bm_wp_inf_burst_desc = "Trigger pack capable of semi-automatic, three-shot burst at +20% RPM, and fully automatic.",
	
	bm_wp_inf_burst_only_norpm = "Burst-Only Trigger Group",
	bm_wp_inf_burst_only_norpm_desc = "Trigger pack capable of semi-automatic and three-shot burst.",
	bm_wp_inf_burst_norpm = "Burst-Enabled Trigger Group",
	bm_wp_inf_burst_norpm_desc = "Trigger pack capable of semi-automatic, three-shot burst, and fully automatic.",
	
	--
	bm_wp_inf_contraband_grip = "German Grip",

	-- InF
	bm_wp_inf_ivan = "Ivan's Legacy",
	bm_wp_inf_ivan_desc = "????",
	bm_wp_inf_ak74_zastava = "7.92x57mm Mauser",
	bm_wp_inf_ak74_zastava_desc = "German military round that continues to see use in Serbia, though it is now being phased out in favor of 7.62x54mmR.\n\n-78% ammo scavenge. Penetrates shields.",
	bm_wp_inf_akm_zastava = "7.92x57mm Mauser",
	bm_wp_inf_akm_zastava_desc = "German military round that continues to see use in Serbia, though it is now being phased out in favor of 7.62x54mmR.\n\n-66% ammo scavenge. Penetrates shields.",
	bm_wp_inf_akmsu_har = "Okurok 762",
	bm_wp_inf_akmsu_har_desc = "Little Bitch. The Stubber. Ksyukha. The genuine 7.62x39mm variant is a myth shrouded in mystery and colorful names. The copies are a call to the gunsmith away.",

	-- imagine using fat subsonic blobs as armor penetrators lmao
	bm_wp_inf_asval_dmr = "9x39mm BP",
	bm_wp_inf_asval_dmr_desc = "Modern high-penetration rounds.\n\n-66% ammo scavenge. Penetrates shields.",
	bm_wp_inf_asval_sp6 = "9x39mm SP-6",
	bm_wp_inf_asval_sp6_desc = "Rounds with hard-metal armor-piercing core.",

	-- hrifle conversion
	bm_wp_inf_m308_20rnd = "The Surplus Special",
	bm_wp_inf_m308_20rnd_desc = "Old military-issue M80 ball ammunition. Enables fully-automatic fire.\n\n+200% ammo scavenge. No shield penetration.",

	bm_wp_inf_m95_nobipod = "Remove Bipod",
	bm_wp_inf_m95_nobipod_desc = "It's not like you were using it.",

	bm_wp_inf_hajk_ironsretain = ironsights.keepname,
	bm_wp_inf_hajk_ironsretain_desc = ironsights.keepdesc,

	-- inf action mods
	bm_wp_inf_spas_valve = "Mesa Nero Action",
	bm_wp_inf_spas_valve_desc = "Converts the SPAS-12 to pump action with toggleable double-shot mode.",
	bm_wp_inf_spas_sven = "Vichingo Action",
	bm_wp_inf_spas_sven_desc = "Converts the SPAS-12 to pump action with toggleable 360 RPM automatic mode.", --Automatic mode has 25% more spread (roughly -13 accuracy).",

	-- devotion
	bm_wp_inf_devotion = "Cyclic Accelerator",
	bm_wp_inf_devotion_desc = "Replaces automatic fire with continuous ramp-up burst mode. Ramps up from 60% ROF to 150% ROF as the trigger is held.",

	bm_wp_inf_c96_auto = "M1931 Kit", -- fictional variant
	bm_wp_inf_c96_auto_desc = "Conversion kit to a fully-automatic variant.",

	bm_wp_inf_svu_unsil = "KBP Device",
	bm_wp_inf_svu_unsil_desc = "Production-model muzzle brake without sound suppression effect.\n\n+25% shield penetration damage",

	bm_wp_inf_bar_slowfire = "Rate Reducer",
	bm_wp_inf_bar_slowfire_desc = "Toggleable mechanism to reduce rate of fire for controllability. Adds a 400 RPM fire mode.",
	bar_sil_desc = "A modified silencer originally meant for sniper rifles." .. silstr,

	bm_wp_inf_akcover_smooth = "Smooth Cover",
	bm_wp_inf_akcover_smooth_desc = "It's not being cheap, it's 'manufacturing efficiency'.",
	bm_wp_inf_akcover_rib = "Ribbed Cover",
	bm_wp_inf_akcover_rib_desc = "Keeps dust and capitalism out.",

	bm_wp_inf_groza_762 = "OTs-14-1A",
	bm_wp_inf_groza_762_desc = "7.62x39mm variant. Adopted by the Russian Army for airborne and Spetsnaz use for its power and logistical advantage over the 9x39mm variant.",
	bm_wp_inf_groza_545 = "OTs-14-2A",
	bm_wp_inf_groza_545_desc = "Experimental 5.45x39mm variant. Not adopted due to the superior ballistic performance of 7.62x39mm through a short barrel.",
	bm_wp_inf_groza_556 = "OTs-14-3A",
	bm_wp_inf_groza_556_desc = "Experimental 5.56x45mm variant. Not adopted due to lack of interest in NATO calibers.",

	bm_wp_inf_mk18_nomagwelldevice = "No Grip",
	bm_wp_inf_mk18_nomagwelldevice_desc = "Removes the magwell grip.",

	bm_wp_inf_hk417_dmr = "7.62x51mm DM151",
	bm_wp_inf_hk417_dmr_desc = "High-penetration tungsten core ammo.\n\n-58% ammo scavenge. Penetrates shields.",

	bm_wp_inf_lapd_556 = "5.56x45mm",
	bm_wp_inf_lapd_556_desc = "You know why.\n\nChanges to New Vegas firing sound.",

	inf_xidw_cpu_turbo_desc = "Decreases rate of fire per gun from 1400 to 800.",
	inf_xidw_cpu_slow_desc = "Decreases rate of fire per gun from 1400 to 600.",

	hahabenis = "fuck commas"
})



if InFmenu.settings.txt_wpnname > 1 then
	LocalizationManager:add_localized_strings({

	-- SIGHTS
	-- Pistol Red Dot
	bm_wp_upg_o_rmr = "Roach Sight",
	bm_wp_upg_o_rmr_desc = "Pistol reflex sight. True to its namesake, it's built tough.",
	-- Marksman Irons
	bm_wp_upg_o_marksmansight_rear_desc = "Custom iron sights.",

	-- Riktpunkt Holosight
	bm_wp_upg_o_rikt = "Aimpoint Acro P-1 Sight",
	bm_wp_upg_o_rikt_desc = "Reliable and very durable, will survive Russian winters and Groningen earthquakes alike.",

	-- SKOLD Reflex Micro Sight
	bm_wp_upg_o_rms = "SHIELD RMSc",
	bm_wp_upg_o_rms_desc = "The SHIELD Reflex Mini Sight Compact. A covert red-dot sight which lacks a reflective red filter on the lens, ensuring minimum visual signature.",

	-- Holographic Sight
	bm_wp_upg_o_eotech = "Jotun Holosight",
	bm_wp_upg_o_eotech_desc = "Holographic sight powered by lithium batteries. A favorite of AR-toting operators everywhere.",
	-- Professional's Choice
	--bm_wp_upg_o_t1micro = "Aimpoint Micro T-1 Red Dot",
	bm_wp_upg_o_t1micro_desc = "Raised reflex sight. Lightweight and long-lived.",
	-- Surgeon Sight
	bm_wp_upg_o_docter = "Surgeon Reflex Sight",
	bm_wp_upg_o_docter_desc = "Low-weight reflex sight with protective housing and auto-controlled illumination settings.",
	-- See More Sight
	bm_wp_upg_o_cmore = "Sey-Mour Sight",
	bm_wp_upg_o_cmore_desc = "Reflex sight that touts high visibility and low weight.",
	-- Compact Holo
	bm_wp_upg_o_eotech_xps = "Ettin Compact Holosight",
	bm_wp_upg_o_eotech_xps_desc = "A cousin of the Jotun sight. The shorter battery compartment takes up less rail space.",
	-- Speculator Sight
	bm_wp_upg_o_reflex = "Speculator Reflex Sight",
	bm_wp_upg_o_reflex_desc = "High-visiblity reflex sight with low-weight aluminum frame.",
	-- Trigonom Sight
	bm_wp_upg_o_rx01 = "Trigonom Desert Sight",
	bm_wp_upg_o_rx01_desc = "Dust-resistant reflex sight suitable for day or night fighting.\n\nZoom level 3.",
	-- Solar Sight
	--bm_wp_upg_o_rx30 = "Solar Sight",
	bm_wp_upg_o_rx30_desc = "Reflex sight illuminated by tritium and fiber optics. Not a cupholder.\n\nZoom level 3.",
	-- Combat Sight
	--bm_wp_upg_o_cs = "Combat Sight",
	bm_wp_upg_o_cs_desc = "Dot sight made for Swedes by Swedes. They like it, and so should you.\n\nZoom level 3.",
	-- Military Red Dot
	bm_wp_upg_o_aimpoint = "PATROL Red Dot Sight",
	bm_wp_upg_o_aimpoint_desc = "Nightvision-compatible dot sight. Durable, aside from that sticker.\n\nZoom level 3.",
	bm_wp_upg_o_aimpoint_2 = "PATRON Red Dot Sight",
	bm_wp_upg_o_aimpoint_2_desc = "Battle-hardened dot sight. A thank-you gift.\n\nZoom level 3.",
	-- Milspec Sight
	bm_wp_upg_o_specter = "HKRK Milspec Sight",
	bm_wp_upg_o_specter_desc = "Milspec optical sight with crosshair. Suitable out to medium range.\n\nZoom level 5.",
	-- ACOUGH
	bm_wp_upg_o_acog = "ACOS Optical Sight", -- advanced combat optical sight
	bm_wp_upg_o_acog_desc = "Telescopic sight with tritium and light pipe illumination developed for the US Army.\n\nZoom level 5.",
	-- Reconnaissance Sight
	bm_wp_upg_o_spot = "Recon Sight",
	bm_wp_upg_o_spot_desc = "Stacked-mount system with high-zoom optic and rangefinder.\n\nZoom level 5.",
	-- Theia
	bm_wp_upg_o_leupold = "Theia Mk4 Scope",
	bm_wp_upg_o_leupold_desc = "Ballistic scope with rangefinding and automatic marking features.\n\nZoom level 10.",
	-- Box Buddy Sight
	bm_wp_upg_o_box = "The Box Buddy",
	bm_wp_upg_o_box_desc = "Digital sight with target ID and video recording features.\n\nZoom level 10.",
	-- BMG Combat Sight (Trijicon 6x48)
	bm_wp_upg_o_bmg = "Trigonom ACOG Combat Sight",
	bm_wp_upg_o_bmg_desc = "A high-magnification ACOG sight. Advertised with the *revolutionary* idea of \"keeping both eyes open\".\n\nZoom level 5.",
	-- FC1 compact profile sight
	bm_wp_upg_o_fc1 = "Compact Tactical Sight",
	bm_wp_upg_o_fc1_desc = "An unbranded generic sight. If you actually liked the Tediore box sights, this might be a good fit.",
	-- Maelstrom sight
	bm_wp_upg_o_uh = "Maelstrom Sight",
	bm_wp_upg_o_uh_desc = "Ideal for close quarters. Designed with a large viewing window and zero distortion.",

	-- Hayha Mode
	bm_wp_mosin_iron_sight = "Iron Sights",
	bm_wp_mosin_iron_sight_desc = "Remove the scope and use iron sights.",


	-- GADGETS
	-- Lion Bipod
	bm_wp_upg_lmg_lionbipod = "Bipod",
	bm_wp_upg_lmg_lionbipod_desc_pc = bipodstr,

	-- Assault Light
	bm_wp_upg_fl_ass_smg_sho_surefire_desc = "Xenon halogen lamp designed for rifles and carbines.\n\nToggle by pressing $BTN_GADGET.",
	-- Compact Laser Module
	bm_wp_upg_fl_ass_laser_desc = "Low-profile laser emitter.\n\nToggle by pressing $BTN_GADGET.",
	-- Ugly Laser Box
	bm_wp_upg_fl_ass_smg_sho_peqbox_desc = "Mountable laser dot projector.\n\nToggle by pressing $BTN_GADGET.",
	-- Military Laser Module
	bm_wp_upg_fl_ass_peq15_desc = "US Military night combat illumination system.\n\nToggle by pressing $BTN_GADGET.",
	-- LED Combo
	bm_wp_upg_fl_ass_utg_desc = "Second-generation light/laser system.\n\nToggle by pressing $BTN_GADGET.",

	-- Tactical Pistol Light
	bm_wp_upg_fl_pis_tlr1_desc = "Aluminum LED tactical light. Made in the US of A.\n\nToggle by pressing $BTN_GADGET.",
	-- Polymer Flashlight
	bm_wp_upg_fl_pis_m3x_desc = "Low-weight mil-spec tactical light.\n\nToggle by pressing $BTN_GADGET.",
	-- Micro Laser
	bm_wp_upg_fl_crimson_desc = "Pistol-sized low-profile laser.\n\nToggle by pressing $BTN_GADGET.",
	-- Pistol Laser
	bm_wp_upg_fl_pis_laser_desc = "Pistol-sized laser sight.\n\nToggle by pressing $BTN_GADGET.",
	-- Combined Module
	bm_wp_upg_fl_x400v_desc = "Dual-purpose illuminator/laser sight.\n\nToggle by pressing $BTN_GADGET.",

	-- Glock Grip Laser
	bm_wp_pis_g_laser_desc = "Laser-emitting bling for your gat.\n\nToggle by pressing $BTN_GADGET.",
	-- PPK Laser Grip
	bm_wp_pis_ppk_g_laser_desc = "Hard polymer grips with laser sight.\n\nToggle by pressing $BTN_GADGET.",

	-- Angled Sight
	bm_wpn_fps_upg_o_45iron = "Angled Ironsights",
	bm_wpn_fps_upg_o_45iron_desc = "Allows toggling between standard sights and angled sight.\n\nToggle by pressing $BTN_GADGET.",
	-- 45-degree red dot
	bm_wpn_fps_upg_o_45rds = "Angled T8 Red Dot Sight",
	bm_wpn_fps_upg_o_45rds_desc = "Allows toggling between standard sights and angled dot sight.\n\nToggle by pressing $BTN_GADGET.",
	-- riktpunkt red dot
	bm_wpn_fps_upg_o_45rds_desc = "Angled Riktpunkt PC2 Sight",
	bm_wpn_fps_upg_o_45rds_desc = "Allows toggling between standard sights and angled dot sight.\n\nToggle by pressing $BTN_GADGET.",
	-- riktpunkt magnifier
	bm_wpn_fps_upg_o_xpsg33_magnifier = "Riktpunkt XMAG Magnifier",
	bm_wpn_fps_upg_o_xpsg33_magnifier_desc = "Allows switching between standard and level 7 zoom.\n\nToggle by pressing $BTN_GADGET.",



	-- Single Fire
	bm_wp_upg_i_singlefire = "Rate Reducer",
	bm_wp_upg_i_singlefire_desc = "Mechanism used to slow cyclic fire rate.",
	-- Auto Fire
	bm_wp_upg_i_autofire = "Lightened Bolt",
	bm_wp_upg_i_autofire_desc = "Reduces bolt weight to increase cyclic fire rate.",



	-- BARREL EXTENSIONS
	-- Stubby Compensator
	bm_wp_upg_ns_ass_smg_stubby = "The Stub",
	bm_wp_upg_ns_ass_smg_stubby_desc = "Puts a little extra sting in everything.",
	-- The Tank
	bm_wp_upg_ns_ass_smg_tank_desc = "Not actually based on a modern tank gun.",
	-- Fire Breather
	bm_wp_upg_ns_ass_smg_firepig_desc = "A deceptively simple item. There's a reason it's called Fire Breather.",
	-- Funnel of Fun
	bm_wp_upg_ass_ns_linear_desc = "Turbulence might be complex, but applied kinetic energy isn't.",
	-- Competitor's Compensator
	bm_wp_upg_ass_ns_jprifles_desc = "When a lot of money is on the line, you can't afford subpar performance.",
	-- Tactical Compensator
	bm_wp_upg_ass_ns_surefire_desc = "As a side effect, it'll also redirect your muzzle blast.",
	-- Ported Compensator
	bm_wp_ns_battle_desc = "Kicks recoil to the curb, according to the promotional material.",
	-- Marmon compensator
	bm_wp_upg_ns_ass_smg_v6_desc = "Nothing like a fistful of heavy metal.",

	-- Flash Hider
	bm_wp_upg_pis_ns_flash_desc = "This would be useful for protecting your ability to see at night if you went out at night more often.",
	-- Facepunch Compensator
	bm_wp_upg_ns_meatgrinder_desc = "It's hard to imagine why you'd punch a man with the end of a gun before shooting him, but that's niche products for you.",
	-- IPSC Compensator
	bm_wp_upg_ns_ipsccomp_desc = "When everyone has to know you can shoot straight, even your gun.",
	-- Hurricane Compensator
	bm_wp_upg_ns_typhoon_desc = "For those who prefer their Democracy leaded.",

	-- Low Profile Suppressor
	bm_wp_upg_ns_ass_smg_small_desc = "Easily-mounted suppressor designed for low weight and size." .. silstr,
	-- Medium Suppressor
	bm_wp_upg_ns_ass_smg_medium_desc = "Notable for surviving all manner of harsh conditions, including that one incident with the chicken tendies." .. silstr,
	-- The Bigger The Better
	bm_wp_upg_ns_ass_smg_large_desc = "In addition to doing its job, it also looks nice in photos." .. silstr,
	-- PBS Suppressor
	bm_wp_upg_ns_ass_pbs1_desc = "Otherwise known as a reserved Russian greeting." .. silstr,

	-- Size Doesn't Matter
	bm_wp_upg_ns_pis_small_desc = "That's what they all say." .. silstr,
	-- Standard Issue Suppressor
	bm_wp_upg_ns_pis_medium_desc = "Sets the benchmark for wetwork gear." .. silstr,
	-- Monolith Suppressor
	bm_wp_upg_ns_pis_large_desc = "Big, black, and imposing. If you want to impress without causing ear damage, look no further." .. silstr,
	-- Budget Suppressor
	bm_wp_upg_ns_ass_filter_desc = "Necessity is the mother of comedy." .. silstr,
	-- Roctec Suppressor
	bm_wp_upg_ns_medium_gem_desc = "Short suppressor originally made for larger-caliber pistol rounds." .. silstr,
	-- Champion's Suppressor
	bm_wp_upg_ns_large_kac_desc = "High-precision suppressor based on a military prototype." .. silstr,
	-- Asepsis Suppressor
	bm_wp_upg_ns_pis_medium_slim_desc = "Cleanliness is next to stealthiness." .. silstr,
	-- Jungle Ninja
	bm_wp_upg_ns_pis_jungle_desc = "Suppressor allegedly never used in any operations by the clandestine groups that received it." .. silstr,

	-- Shark Teeth
	bm_wp_upg_ns_shot_shark = "Shark Teeth",
	bm_wp_upg_ns_shot_shark_desc = "Some nasty bite for close encounters of the doorknob kind.",
	-- King's Crown
	bm_wp_upg_shot_ns_king = "King's Crown",
	bm_wp_upg_shot_ns_king_desc = "If a shotgun wedding sounded bad, just wait until you see a shotgun coronation.",
	-- Donald's Horizontal Leveller
	bm_wp_ns_duck = "The Leveller",
	bm_wp_ns_duck_desc = "Have you ever used a shotgun but thought that the shot pattern was just too round?",

	-- Silent Killer
	bm_wp_upg_ns_shot_thick_desc = "Now that's a can." .. silstr2,
	-- Ssh!
	bm_wp_upg_ns_sho_salvo_large_desc = "They might see it coming, but they won't hear it." .. silstr2,






	-- AP Slug
	bm_wp_upg_a_slug = "Armor Piercing Slugs",
	bm_wp_upg_a_slug_desc = "Fires a large penetrating slug.\n\nRemoves falloff. Fully penetrates tan armor.",
	-- 000 Buckshot
	bm_wp_upg_a_custom = "Triple-Ought Buck",
	bm_wp_upg_a_custom_desc = "Fires fewer and larger pellets.\n\nFires 8 pellets instead of 10.",
	--bm_wp_upg_a_custom2_desc = "Fires fewer and larger pellets.\n\nFires 8 pellets instead of 10, -20% range",
	-- breacher rounds
	bm_wp_upg_a_custom_free = "Breaching Round",
	bm_wp_upg_a_custom_free_desc = "Dense frangible round designed to destroy locks and hinges. Breaches any target the OVE9000 portable saw can.\n\nExtremely short range.",
	-- Frag Rounds/HE Rounds
	bm_wp_upg_a_explosive = "HE-Frag Rounds",
	bm_wp_upg_a_explosive_desc = "Fires a fin-stabilized explosive round that explodes upon impact, disorienting or killing anyone in the blast.\n\n-25% ammo scavenge.",
	-- Flechette Rounds
	bm_wp_upg_a_piercing = "Flechette Rounds",
	bm_wp_upg_a_piercing_desc = "Fires thin tungsten rods that deal less damage, but retain their velocity over greater distances.\n\nFires 14 flechettes instead of 10 pellets, +25% range",
	-- Dragon's Breath
	bm_wp_upg_a_dragons_breath = "Dragon's Breath",
	bm_wp_upg_a_dragons_breath_desc = "Fires pellets that go up in spark and flame. Nearly guaranteed to start a fire.\n\n+25% spread, 15m ignition range, 30 damage/sec for 3sec",




	-- AMCAR FAMILY
	-- amcar, kills babies
	bm_w_amcar_desc = "Produced in large numbers with the intent to deliver them to pro-American regimes. Always available in the local black markets due to a minor warehouse mishap.",
	-- car-4, kills even more babies
	bm_w_m4_desc = "Carbine derivative of the AMR-16. Renown for its high modification potential. Frequently used by well-funded western forces and gun enthusiasts.", --get_string_by_option(InFmenu.settings.txt_wpnname, {"Carbine derivative renown for its high modification potential. Frequently used by well-funded western forces and gun enthusiasts.", "Carbine derivative of the AMR-16. Renown for its high modification potential. Frequently used by well-funded western forces and gun enthusiasts."}),
	-- amr-16, kills minority babies
	bm_w_m16_desc = "A rifle staunchly opposed by traditionalists in the Army and nearly ruined by sabotage. It has since set the bar by which western rifles are measured.",
	bm_wp_wpn_fps_m16_extra_bipod_desc = "Hope you brought a heavy barrel.\n\n" .. bipodstr,
	-- para, goodness gracious that's a lot of baby-killing
	bm_w_olympic_desc = "Designed as a small vehicle defense weapon chambered in 5.56x45. Useful where an SMG's penetration is insufficient but a full length rifle is too cumbersome.",
	bm_w_olympicprimary_desc = "Designed as a small vehicle defense weapon chambered in 5.56x45. Useful where an SMG's penetration is insufficient but a full length rifle is too cumbersome.",
	bm_w_x_olympic_desc = "Nothing is free. Not even advice. After all, what is the pain of a hard lesson learned if not life's fee for educating you?",
	-- bootleg, big-mag baby killer
	bm_w_tecci_desc = "Modernized carbine intended to increase reliability and reduce wear. Customized for use with a drum magazine.",
	-- little friend, say hello to code changes
	bm_w_contraband_desc = "This modern take on the old classic leaves little downtime between grenade launch and follow-up gunfire by combining both weapons into one.",


	-- Long Barrel
	bm_wp_m4_uupg_b_long_desc = "Full-length barrel. Marginally used prior to your ownership of it.",
	-- Medium Barrel
	bm_wp_m4_uupg_b_medium_desc = "Carbine-length barrel.",
	-- Short Barrel
	bm_wp_m4_uupg_b_short_desc = "Super-short barrel.",
	-- Stealth Barrel
	bm_wp_m4_uupg_b_sd_desc = "Integral suppressor designed for the CAR-4." .. silstr, --get_string_by_option(InFmenu.settings.txt_wpnname, {"Integral suppressor designed for mid-length carbines." .. silstr, "Integral suppressor designed for the CAR-4." .. silstr}),
	-- CAR DMR
	bm_wp_upg_ass_m4_b_beowulf = "Heavy Barrel",
	bm_wp_upg_ass_m4_b_beowulf_desc = "Reinforced heavy barrel intended for firing heavy rounds.",

	-- CAR-4 Aftermarket Special
	bm_wp_m4_uupg_fg_lr300_desc = "TRs-301 handguard. Sighted in Ukraine in the hands of mercenary forces.",
	-- CAR-4 YOUR META MAKES RIFLES THAT LOOK LIKE GARBAGE
	bm_wp_upg_fg_jp = "Competition Handguard",
	bm_wp_upg_fg_jp_desc = "Light high-accuracy handguard. Connects with the receiver's rail.",
	-- CAR-4 Gazelle Rail
	bm_wp_upg_fg_smr_desc = "Desert-colored modular rail. Easily installed and removed.",
	-- CAR-4 OVAL IS A SHITTY NAME
	bm_wp_upg_ass_m4_fg_lvoa = "Lovis Handguard",
	bm_wp_upg_ass_m4_fg_lvoa_desc = "Designed for fire from concealed positions. Uses coatings to reduce thermal visibility.",
	-- CAR-4 EMO IS AN EVEN SHITTIER NAME
	bm_wp_upg_ass_m4_fg_moe = "River Handguard",
	bm_wp_upg_ass_m4_fg_moe_desc = "Heat-resistant polymer handguard with optional accessory slots.",
	-- AMR-16 Tactical Handguard
	bm_wp_m16_fg_railed_desc = "Light railed handguard with free-floating barrel design.",
	-- AMR-16 Blast From the Past
	bm_wp_m16_fg_vietnam_desc = "Early-model triangular handguard.",
	-- AMR-16 Long Ergo WHAT THE FUCK AM I LOOKING AT
	bm_wp_upg_ass_m16_fg_stag = "Long Ergonomic Handguard",
	bm_wp_upg_ass_m16_fg_stag_desc = "Ergonomic aluminum handguard. Smooth side grooves ensures good grip without sharp angles.",
	-- Para Railed Handguard
	bm_wp_olympic_fg_railed = "Ailette Railed Handguard",
	bm_wp_olympic_fg_railed_desc = "Short railed handguard that allows free-floating barrels. Lean and mean.",
	-- Para Aftermarket Shorty
	bm_wp_upg_smg_olympic_fg_lr300_desc = "Short aluminum handguard based on the TRs-301 design.",

	-- Ergo Grip
	bm_wp_m4_g_ergo_desc = "High-friction finger-grooved grip.",
	-- FILTHY GAIJIN GO HOME AND TAKE YOUR PRO GRIP WITH YOU
	bm_wp_m4_g_sniper_desc = "Drop-in replacement grip styled after a German marksman rifle's grip.",
	-- Rubber Grip
	bm_wp_upg_m4_g_hgrip_desc = "Rubber/fiberglass grip for increased first-shot precision.",
	-- Straight Grip
	bm_wp_upg_m4_g_mgrip_desc = "Low-profile grip angled for compact weapons.",

	-- Milspec Mag
	bm_wp_m4_uupg_m_std = "Milspec Mag",
	bm_wp_m4_uupg_m_std_desc = "General-issue 30-round magazine.",
	-- Vintage Mag
	bm_wp_m4_m_straight = "Vintage Mag",
	bm_wp_m4_m_straight_desc = "Flat-bottomed 20-round magazine.",
	-- Tactical Vomit Bag
	bm_wp_m4_m_pmag = "Tactical Mag",
	bm_wp_m4_m_pmag_desc = "Polymer magazine. Fully curved on the inside.",
	-- Expert Mag
	bm_wp_l85a2_m_emag_desc = "Cleanly-feeding magazine with side windows. Made for British use.",
	-- L5 Mag
	bm_wp_upg_m4_m_l5 = "Lancer Mag",
	bm_wp_upg_m4_m_l5_desc = "Impact-resistant textured magazine.",
	-- CAR Quadstack
	bm_wp_upg_m4_m_quad = "Quad-Stack Mag",
	bm_wp_upg_m4_m_quad_desc = "Also aptly known as a casket magazine.",
	-- speed pull
	bm_wp_m4_m_quick = "Speed Pull Sleeve",
	bm_wp_m4_m_quick_desc = speedpulldesc,

	-- Standard-Issue Stock
	bm_wp_m4_s_standard_desc = "Common six-position collapsible stock.",
	bm_wp_m4_s_standard_desc_fine = "WHY ATTACH NEW PART? PROBLEM IS NOT RIFLE.",
	-- Tactical Stock
	-- i like my girls the same way i like my gun parts: NOT TAN
	bm_wp_m4_s_pts_desc = "Aftermarket stock replacement. Sturdy, slick, and nightmarish for color coordination.",
	bm_wp_m4_s_pts_desc_fine = "YOU THINK YOU GO TO DESERT AND SHOOT SOMEONE NOT YOURSELF?",
	-- Folding Stock
	bm_wp_m4_uupg_s_fold_desc = "Early-model TRs-301 folding stock with modified gas system.",
	-- War-Torn Stock
	bm_wp_upg_m4_s_mk46_desc = "Stock modified with a cheek rest for accurate shooting.",
	bm_wp_upg_m4_s_mk46_desc_fine = "WHAT IS PURPOSE? TRASH ON MORE TRASH ONLY MAKE MORE TRASH!",
	-- Wide Stock
	bm_wp_upg_m4_s_crane = "Crane Stock",
	bm_wp_upg_m4_s_crane_desc = "Snag-resistant tactical stock for US military use. Designed for speed and comfort.",
	bm_wp_upg_m4_s_crane_desc_fine = "GET REFUND. OR NOT, IS NOT MY PROBLEM.",
	-- more like two piece of shit stock
	bm_wp_upg_m4_s_ubr = "Two-Piece Stock",
	bm_wp_upg_m4_s_ubr_desc = "Adjustable stock that maintains cheek weld.",
	bm_wp_upg_m4_s_ubr_desc_fine = "WHY DO THING SIMPLE WAY WHEN CAN DO STUPID WAY?",
	-- Para Shorter Than Short
	bm_wp_olympic_s_short_desc = "A reinforced buffer tube, and little else.",

	-- Exotique Upper
	bm_wp_m4_upper_reciever_edge = "Exotique",
	bm_wp_m4_upper_reciever_edge_desc = "Thick-walled upper receiver.",
	-- LW Upper
	bm_wp_upg_ass_m4_upper_reciever_ballos = "Helios",
	bm_wp_upg_ass_m4_upper_reciever_ballos_desc = "Reinforced receiver specially manufactured for harsh conditions.",
	-- Thrust Upper
	bm_wp_upg_ass_m4_upper_reciever_core = "Thrust Primus",
	bm_wp_upg_ass_m4_upper_reciever_core_desc = "Upper receiver with titanium nitride bolt carrier group.",
	-- Thrust Lower Receiver
	bm_wp_upg_ass_m4_lower_reciever_core = "Thrust Secundus",
	bm_wp_upg_ass_m4_lower_reciever_core_desc = "Lower receiver with pared-back magazine well.",





	-- AK WEAPONS
	-- AKS.74
	bm_w_ak74_desc = "Intermediate-caliber AK. Replaced the AK.762 due to the increasing importance of light high-velocity rounds on the modern battlefield. Its distinct muzzle brake helps offset recoil.",
	-- AK.762
	bm_w_akm_desc = "An update of the original with improved handling and weight. Will survive the apocalypse or a full crate of corrosive ammo, whichever ends last.",
	-- AuK.762/gold AK
	bm_w_akm_gold_desc = "Look, it's a golden AK. Any questions?",
	-- krinkov
	bm_w_akmsu_desc = "Automatic carbine made extremely compact for special forces and vehicle crews. Resembles a child: small, loud, and uncontrollable.",
	bm_w_akmsuprimary_desc = "Automatic carbine made extremely compact for special forces and vehicle crews. Resembles a child: small, loud, and uncontrollable.",
	-- akimbo krinkov
	bm_w_x_akmsu_desc = "Doubling down is a bold move when the risk is this high. You could have backed off and retired rich, but that would mean leaving the greatest heist of all on the table.",
	--bm_w_x_akmsu_desc = "They're like twins. Two uncontrollable screaming hellions for the price of one. What's not to love?",
	-- ak.12
	bm_w_ak12_desc = "Newly-adopted rifle of the Russian military, due to replace the outdated AKS.74. As this was a recent decision, full replacement may take some time.",

	-- slavic dragon barrel
	bm_wp_upg_ak_b_draco = "Draco Barrel",
	bm_wp_upg_ak_b_draco_desc = "Reinforced short barrel. Sometimes said to roar like a dragon. Or burn your eyebrows like one.",
	bm_wp_upg_ak_b_draco_desc_fine = "INSPECT CAREFULLY THE RIFLE AND BE SURE THERE IS NO CARTRIDGE PRESENT BECAUSE BARREL POINTS AT FACE SOON.",
	-- modern barrel
	bm_wp_upg_ak_b_ak105 = "Modern Carbine Barrel",
	bm_wp_upg_ak_b_ak105_desc = "Barrel and gas system based on the AK.105 modernized carbine design. Related to the Krinkov.",
	bm_wp_upg_ak_b_ak105_desc_fine = "YOU NOTICE AND AVOID BARREL IF HAS POCKMARKS LIKE ASS OF FAT GIRL.",
	-- dmr kit
	bm_wp_upg_ass_ak_b_zastava = "Long Barrel",
	bm_wp_upg_ass_ak_b_zastava_desc = "Accurized marksman barrel for long-ranged work.",
	bm_wp_upg_ass_ak_b_zastava_desc_fine = "YOU MUST INSPECT BARREL BEFORE BUY.",

	-- scope mount
	bm_wp_upg_o_ak_scopemount = "Sight Mount",
	bm_wp_upg_o_ak_scopemount_desc = "Aluminum/steel mount. Places sights onto a rail directly over the rear of the receiver.",
	bm_wp_upg_o_ak_scopemount_desc_fine = "MAYBE YOU PUT SEX DILDO ON TOP TO FUCK YOURSELF IN ASSHOLE FOR MAKING SHAMEFUL TRAVESTY OF RIFLE.",

	-- railed wooden grip
	bm_wp_ak_fg_combo2_desc = "Exposes the gas tube and adds a rail mount to it.",
	bm_wp_ak_fg_combo2_desc_fine = "RIFLE WAS FINE BEFORE YOU FUCK IT. NOW IS TRASH.",
	-- tactical russian
	bm_wp_ak_fg_combo3_desc = "High strength metal fore-end with rails.",
	bm_wp_ak_fg_combo3_desc_fine = "YOU WANT RAIL FOR KALASHNIKOV? WHY YOU WANT RAIL FOR KALASHNIKOV?",
	-- battleproven
	bm_wp_upg_ak_fg_tapco_desc = "A well-worn handguard with minor modifications for better grip.",
	bm_wp_upg_ak_fg_tapco_desc_fine = "STUPID HICK AMERICAN LOOKS AT PERFECTLY FINE RIFLE AND ADDS DUMB SHIT ON IT.",
	-- lightweight rail
	bm_wp_upg_fg_midwest_desc = "Quad-railed tactical mounting platform.",
	bm_wp_upg_fg_midwest_desc_fine = "WHAT ELSE YOU FUCK? YOU PUT NEW BOLT EDIFICE?",
	-- crabs rail
	bm_wp_upg_ak_fg_krebs = "Scarab Rail",
	bm_wp_upg_ak_fg_krebs_desc = "Light interface system. Snugly mounted.",
	bm_wp_upg_ak_fg_krebs_desc_fine = "IS NOT GOOD ENOUGH AS PROCURED FROM IZHEVSK MECHANICAL WORKS?",
	-- keymod rail
	bm_wp_upg_ak_fg_trax = "Sarcophagus Rail",
	bm_wp_upg_ak_fg_trax_desc = "Modular rail system with keymod interface.",
	bm_wp_upg_ak_fg_trax_desc_fine = "YOU HAVE DISEASE OF AMERICAN CAPITALIST, CHANGE THING THAT IS FINE FOR NO REASON EXCEPT TO LOOK DIFFERENT FROM COMRADE.",
	-- moscow special (krinkov)
	bm_wp_akmsu_fg_rail = "The Moscow Special",
	bm_wp_akmsu_fg_rail_desc = "Quad-railed handguard for the accessorizing drunkard.",
	bm_wp_akmsu_fg_rail_desc_fine = "YOU THINK NEEDS IMPROVEMENT? MAYBE YOU FIND JOB WITH ARMY OF RUSSIA! OR MAYBE NOT. PROBABLY IS BECAUSE YOU NEVER DESIGN WEAPON IN WHOLE LIFE.",
	-- aluminum handguard (krinkov)
	bm_wp_upg_ak_fg_zenit = "Aluminum Handguard",
	bm_wp_upg_ak_fg_zenit_desc = "Aluminum: it's for people who can't feel secure when holding wood.",
	bm_wp_upg_ak_fg_zenit_desc_fine = "FOR REST OF WORLD THERE IS WOOD WHICH IS SAME HOLD FOR LESS COST.",

	-- default grip
	bm_wp_ak_g_standard = "Standard Grip",
	-- rubber grip
	bm_wp_upg_ak_g_hgrip_desc = "Comfortable rubber over a fiberglass base.",
	bm_wp_upg_ak_g_hgrip_desc_fine = "WHAT IN FUCK IS DONE TO THIS POOR RIFLE?",
	-- plastic grip
	bm_wp_upg_ak_g_pgrip_desc = "Made from proprietary polymer.",
	bm_wp_upg_ak_g_pgrip_desc_fine = "LARGE MOUND FORMS OVER COMRADE'S GRAVE BY CONSTANT TUMBLING OF HIS ANGRY CORPSE. IS FAULT OF PEOPLE LIKE YOU.",
	-- wood grip
	bm_wp_upg_ak_g_wgrip_desc = "Goes with all the other wooden stuff.",
	bm_wp_upg_ak_g_wgrip_desc_fine = "IF ONLY IS WOOD MISSING, IS NOT SUCH BIG PROBLEM.",
	-- aluminum grip
	bm_wp_upg_ak_g_rk3_desc = "Includes a small waterproof storage compartment.",
	bm_wp_upg_ak_g_rk3_desc_fine = "WHAT IS REASON FOR PISTOL GRIP? YOU MISS EVERY ENEMY!",

	-- low drag mag
	bm_wp_upg_ak_m_uspalm_desc = "High-grip polymer magazine for faster reloads.",
	bm_wp_upg_ak_m_uspalm_desc_fine = "LOOK AT CHEAP PLASTIC MAGAZINE. FEEDS LIKE CONSTANTLY JAMMING PEZ CANDY BOX.",
	-- AK quadstack
	bm_wp_upg_ak_m_quad_desc = "Quantity is its own quality.",
	bm_wp_upg_ak_m_quad_desc_fine = "IT ONLY GET HEAVY. YOU STILL NO HIT LARGEST SIDE OF BARN.",
	-- AK speed pull
	bm_wp_ak_m_quick_desc = speedpulldesc,
	bm_wp_ak_m_quick_desc_fine = "I AM CONGRATULATE. YOU ARE NOW SPETSNAZ. MAKE SURE ENEMY DOES NOT SEE TEDDY BEAR OR HE MAYBE SO AFRAID HE SHITS IN PANTS.",

	-- folding stock
	bm_wp_ak_s_folding_desc = "Underfolding stock used by airborne troops.",
	bm_wp_ak_s_folding_desc_fine = "MINOR PROBLEMS NOT SO BIG LIKE CAPITALIST DISEASE.",
	-- side-folding stock
	bm_wp_ak_s_skfoldable_desc = "Side-folding stock designed for the AKS.74.",
	bm_wp_ak_s_skfoldable_akmsu_desc = "Get out of here, STALKER.",
	bm_wp_ak_s_skfoldable_desc_fine = "IS MADE TO FALL OUT OF PLANE.",
	-- wooden sniper stock
	bm_wp_ak_s_psl_desc = "A sniping stock made from the finest Romanian wood. Will not crack, loosen, or become sapient.",
	bm_wp_ak_s_psl_desc_fine = "IS EFFECTIVE DISTANCE OF UP TO ONE HUNDRED SCORES OF ARSHIN.",
	-- classic stock
	bm_wp_upg_ak_s_solidstock_desc = "No improvement needed.",
	bm_wp_upg_ak_s_solidstock_desc_fine = "RIFLE IS FINE.",





	-- AK5
	bm_w_ak5_desc = "Swedish rifle adapted for use in arctic conditions, as evidenced by certain key changes such as enlarging the trigger guard to accomodate gloved hands.",
	-- CQB Barrel
	bm_wp_ak5_b_short_desc = "Current military-issue 350mm barrel.",
	-- Karbin Ceres
	bm_wp_ak5_fg_ak5c_desc = "C-model handguard. Features increased accuracy and reduced weight.",
	-- Belgian Heat
	bm_wp_ak5_fg_fnc_desc = "A return to roots.",
	-- Bertil Stock
	bm_wp_ak5_s_ak5b_desc = "B-model marksman stock with cheek rest.",
	-- Caesar Stock
	bm_wp_ak5_s_ak5c_desc = "Adjustable stock used on C-model rifles.",


	-- AS VAL
	bm_w_asval_desc = "Fires a heavy subsonic bullet through an integral suppressor. Will penetrate steel helmets out to 400 meters, to the concern of everyone wearing a steel helmet.",
	-- Prototype Barrel
	bm_wp_asval_b_proto = "Prototype Suppressor",
	bm_wp_asval_b_proto_desc = "Short railed suppressor design. Abandoned in prototyping due to durability issues.",
	-- Solid Stock
	bm_wp_asval_s_solid = "Solid Stock",
	bm_wp_asval_s_solid_desc = "Solid stock as seen on certain other Russian developments.", -- vss vanir


	-- AUG A2
	bm_w_aug_desc = "One of the earliest successful bullpup designs, featuring a durable polymer housing and quick-change barrels. Nearly half a decade later, it still looks futuristic.",
	-- the only sight you should use
	bm_wp_wpn_fps_aug_o_scope_a1_desc = "The Swarovski scope, integrated into factory A1 models. At 300m, a 180cm man-sized target will completely fill the center reticle.\n\nZoom level 5.",
	-- long barrel
	bm_wp_aug_b_long_desc = "900mm support-length barrel, sans bipod.",
	-- short barrel
	bm_wp_aug_b_short_desc = "690mm carbine-length barrel.",
	-- A3 rail
	bm_wp_aug_fg_a3 = "A3 Tactical Rail",
	bm_wp_aug_fg_a3_desc = "Rail component taken from the A3 variant. Extra intimidating.",
	-- raptor body
	bm_wp_aug_body_f90 = "Raptor Body",
	bm_wp_aug_body_f90_desc = "The polymer body from Australia's licensed copy.",
	-- ew
	bm_wp_aug_m_quick_desc = speedpulldesc,


	-- CAVITY 9MM/CAV-2000
	bm_w_sub2000_desc = "Concealable pistol-caliber carbine with the ability to be unfolded and ready to fire within seconds. Designed to accept popular pistol magazines.",
	-- appalachian handguard
	bm_wp_sub2000_fg_gen2 = "Probe Handguard", -- periodontal probe
	bm_wp_sub2000_fg_gen2_desc = "Second-generation handguard with built-in rails.",
	-- delabarre handguard
	bm_wp_sub2000_fg_railed = "Curette Handguard",
	bm_wp_sub2000_fg_railed_desc = "Picatinny-covered handguard.",
	-- tooth fairy suppressor
	bm_wp_sub2000_fg_suppressed = "Impact Suppressor",
	bm_wp_sub2000_fg_suppressed_desc = "It's not what you can hear that you need to be afraid of.",


	-- CLARION
	bm_w_famas_desc = "An ambidextrous bullpup designed to fire French-spec 5.56x56mm ammo. Its length, agility, and blistering rate of fire make it a deadly close-range contender.",
	-- long barrel
	bm_wp_famas_b_long_desc = "Extended 620mm barrel offered by the manufacturer with little success.",
	-- short barrel
	bm_wp_famas_b_short_desc = "Commando-variant 405mm barrel.",
	-- sniper barrel
	bm_wp_famas_b_sniper = "Heavy Barrel",
	bm_wp_famas_b_sniper_desc = "Reinforced non-ribbed barrel.", -- i don't know shit about the sniper/commando famas variants, assuming they actually exist
	-- suppressed barrel
	bm_wp_famas_b_suppressed = "The Silent Horn",
	bm_wp_famas_b_suppressed_desc = "What was once ignored and forgotten by the world at large may yet come to be appreciated." .. silstr,
	-- G2 grip
	bm_wp_famas_g_retro_desc = "Second-generation grip that better accomodates thick gloves.",


	-- SG552
	bm_w_s552_desc = get_string_by_option(InFmenu.settings.txt_wpnname, {"The short variant of its family with a 226mm barrel, tactical rail, and folding sights. Unlike its bigger brother, the 552 puts agility over accuracy.", "A shortened variant of the Krieggewehr 550 with a 226mm barrel, tactical rail, and folding sights. Unlike its bigger brother, the 552 puts agility over accuracy."}),
	-- long barrel
	bm_wp_ass_s552_b_long_desc = "363mm Commando 551 barrel.",
	-- enhanced ugly
	bm_wp_ass_s552_fg_standard_green = "Enhanced Handguard",
	bm_wp_ass_s552_fg_standard_green_desc = "Handguard with enhanced finish.",
	--
	bm_wp_ass_s552_fg_railed = "Railed Handguard",
	bm_wp_ass_s552_fg_railed_desc = "Metal handguard with rails.",
	-- enhanced ugly
	bm_wp_ass_s552_g_standard_green = "Enhanced Grip",
	bm_wp_ass_s552_g_standard_green_desc = "Grip made from high-friction materials.",
	-- enhanced ugly
	bm_wp_ass_s552_s_standard_green = "Enhanced Stock",
	bm_wp_ass_s552_s_standard_green_desc = "Stock with enhanced finish.",
	-- heat-treated receiver
	bm_wp_ass_s552_body_standard_black = "Covert Receiver",
	bm_wp_ass_s552_body_standard_black_desc = "Modified receiver with a less conspicuous appearance.",


	-- UNION
	bm_w_corgi_desc = "Ambidextrous bullpup assault rifle. Its unique forward casing ejection system allows swapping between left and right-handed firing at a moment's notice.",


	-- MTAR
	bm_w_komodo_desc = "Israeli carbine intended to replace non-Israeli assault rifles as standard-issue. Designed for ease-of-maintenance, reliability, and probably international sales.",


	-- JP36
	bm_w_g36_desc = get_string_by_option(InFmenu.settings.txt_wpnname, {"Created to replace the Bundeswehr's rifles with something lighter chambered in 5.56x45mm NATO. Used by police and special forces units.", "Created to replace the Gewehr 3 with a lighter and more maneuverable rifle chambered in 5.56x45mm NATO. Used by police and special forces units."}),
	-- sniper stock
	bm_wp_g36_s_sl8_desc = "Fixed thumbhole stock with adjustable cheekpiece and buttplate.",
	-- solid stock
	bm_wp_g36_s_kv_desc = "Heavier folding stock. Won't snag on stray branches.",
	-- compact
	bm_wp_g36_fg_c = "Compact Handguard",
	bm_wp_g36_fg_c_desc = "Subcarbine handguard variant. Uses a redesigned gas block.",
	-- polizei special
	bm_wp_g36_fg_ksk = "Polizei Special",
	bm_wp_g36_fg_ksk_desc = "Reinforced railed handguard with enhanced air cooling.",
	-- long handguard
	bm_wp_g36_fg_long = "KSI Handguard",
	bm_wp_g36_fg_long_desc = "Original model barrel and handguard.",
	-- original sight
	bm_wp_g36_o_vintage = "KSI Sight",
	bm_wp_g36_o_vintage_desc = "Original model sight and carry handle.\n\nZoom level 5.",
	bm_wp_g36_m_quick_desc = speedpulldesc,
	--
	bm_wp_wpn_fps_g36_fg_bipod_desc = "Try not to melt the gun.\n\n" .. bipodstr,


	-- LION'S ROAR
	bm_w_vhs_desc = "The second iteration of a long-running Croatian rifle project that has undergone many major design changes. This redesign enabled ambidexterity and discards rifle grenades in favor of an undermounted launcher.",
	-- short barrel
	bm_wp_vhs_b_short = "Tiglon Barrel",
	bm_wp_vhs_b_short_desc = "Smaller just means they're harder to see coming.",
	-- sniper barrel
	bm_wp_vhs_b_sniper = "Apex Barrel",
	bm_wp_vhs_b_sniper_desc = "You'd best believe that long fangs aren't for show.",
	--
	bm_wp_vhs_b_silenced = "Selachii Barrel",
	bm_wp_vhs_b_silenced_desc = "What do you think happens to people who can't watch their own backs?" .. silstr,


	-- L85
	bm_w_l85a2_desc = "British rifle whose earliest iterations are better described as a rifle in need of service than a service rifle. The A2 redesign brought it up to modern standards.",
	bm_wp_l85a2_b_long_desc = "A hair longer.",
	bm_wp_l85a2_b_short_desc = "A touch shorter.",
	bm_wp_l85a2_g_worn = "Weathered Grip",
	bm_wp_l85a2_g_worn_desc = "Grip modified with tape for extra grip.",
	bm_wp_l85a2_fg_short = "Versatile Handguard",
	bm_wp_l85a2_fg_short_desc = "Quad-railed handguard without lots of green on it.",




	-- EAGLE HEAVY
	bm_w_scar_desc = "Accurate and reliable, even under adverse conditions. While its little 5.56x45mm brother has faded into obscurity, the heavy sibling continues to impress.",
	bm_wp_scar_b_long_desc = "Extended 20-inch barrel.",
	bm_wp_scar_b_short_desc = "CQC variant barrel.",
	bm_wp_scar_s_sniper_desc = "Non-folding precision-fire stock.",


	-- FALCON
	bm_w_fal_desc = "The quintessential post-WW2 battle rifle. Nicknamed \"the right arm of the free world\" due to its popularity among NATO countries during the Cold War.",
	bm_wp_fal_body_standard = "CQB Handguard",
	bm_wp_fal_body_standard_desc = "Shortened aluminum handguard made for modernized variants.",
	bm_wp_fal_fg_03 = "Retro Handguard",
	bm_wp_fal_fg_03_desc = "Israeli variant handguard. Replaced in service by the Galil.",
	bm_wp_fal_fg_04 = "Marksman Handguard",
	bm_wp_fal_fg_04_desc = "Handguard of Brazilian make.",
	bm_wp_fal_fg_wood = "Wooden Handguard",
	bm_wp_fal_fg_wood_desc = "Handguard built from sturdy wood.",
	bm_wp_fal_m_01 = "Tercel Magazine",
	bm_wp_fal_m_01_desc = "If you're going big, you may as well go big.",
	-- cqb stock
	bm_wp_fal_s_01_desc = "You know what they say about birds and hollow bones.",
	bm_wp_fal_s_03 = "Marksman Stock",
	bm_wp_fal_s_03_desc = "Adjustable and comfortable.",
	bm_wp_fal_s_wood_desc = "Old and gold.",
	-- DMR kit
	bm_wp_inf_fnfal_dmrkit = "Marksman Kit",
	bm_wp_inf_fnfal_dmrkit_desc = "High-penetration rounds. The way this weapon is meant to be.\n\n-58% ammo scavenge. Penetrates shields. Locked to semi-automatic.",
	-- British .280 kit
	bm_wp_inf_fnfal_classickit = "British Kit",
	bm_wp_inf_fnfal_classickit_desc = "Chambers the weapon into the original slightly lighter British .280 rounds.\n\nMore ammo scavenge.",


	-- G3
	bm_w_g3_desc = "German rifle that traces its lineage to the Third Reich. A number of accurized variants were also created for police and military purposes.",
	bm_wp_g3_b_short = "Short Barrel",
	bm_wp_g3_b_short_desc = "Shortened barrel.",
	bm_wp_g3_b_sniper = "Scharfschuetze Kit",
	bm_wp_g3_b_sniper_desc = "Accurized long barrel and high-penetration rounds.\n\n-58% ammo scavenge. Penetrates shields.",
	bm_wp_g3_fg_psg = "Precision Handguard",
	bm_wp_g3_fg_psg_desc = "Handguard modeled after the PSG-1's handguard.",
	bm_wp_g3_fg_railed = "Tactical Handguard",
	bm_wp_g3_fg_railed_desc = "Everyone needs rails these days.",
	bm_wp_g3_fg_retro = "Wooden Handguard",
	bm_wp_g3_fg_retro_desc = "Early-model handguard.",
	bm_wp_g3_fg_retro_plastic = "Polymer Handguard",
	bm_wp_g3_fg_retro_plastic_desc = "A Swedish licensed product.", -- ak 4,
	bm_wp_g3_g_retro_desc = "When's the last time you saw one of these? That's right.",
	bm_wp_g3_g_sniper = "Precision Grip",
	bm_wp_g3_g_sniper_desc = "New trigger and grip with palm shelf.",
	bm_wp_g3_s_sniper = "Precision Stock",
	bm_wp_g3_s_sniper_desc = "Something to rest your head on.",
	bm_wp_g3_s_wood_desc = "The OG look.",
	bm_wp_wpn_fps_g3_fg_expbipod_desc = "Put that bipod to use.\n\n" .. bipodstr,


	-- GECKO/GALIL
	bm_w_galil_desc = "A weapon family created to replace battle rifles in Israeli service with a shorter, more reliable, and more controllable weapon.",
	bm_wp_galil_fg_sniper = "Tzalafim Handguard",
	bm_wp_galil_fg_sniper_desc = "Match-grade barrel and flash hider.",
	-- light handguard
	bm_wp_galil_fg_sar_desc = "High-impact polymer handguard.",
	-- cqb handguard
	bm_wp_galil_fg_mar_desc = "'Micro' variant barrel and handguard.",
	-- fabulous handguard
	bm_wp_galil_fg_fab = "FAB Handguard",
	bm_wp_galil_fg_fab_desc = "Railed aluminum handguard. Comes in black, black, and still black.",
	-- sniper grip
	bm_wp_galil_g_sniper = "Tzalafim Grip",
	bm_wp_galil_g_sniper_desc = "Don't forget to buy the other fancy parts.",
	-- sniper stock
	bm_wp_galil_s_sniper_desc = "Solid wood. Metal is for chumps.",
	-- skeletal stock
	bm_wp_galil_s_skeletal_desc = "'Micro' variant stock.",
	-- light stock
	bm_wp_galil_s_light_desc = "Not that the others are particularly heavy.",
	-- fabulous stock
	bm_wp_galil_s_fab = "FAB Stock",
	bm_wp_galil_s_fab_desc = "An older model.",
	-- plastic stock
	bm_wp_galil_s_plastic = "Plastic Cheekrest",
	bm_wp_galil_s_plastic_desc = "Hard Israeli foam. Intended to bring the eye right in light with the scope.",
	-- wooden stock
	bm_wp_galil_s_wood = "Wooden Cheekrest",
	bm_wp_galil_s_wood_desc = "Don't look at me like that.",
	--
	bm_wp_wpn_fps_ass_galil_bipod_folded_desc = "Folds away the bipod. 0.55x horizontal recoil.",


	-- M308
	bm_w_m14_desc = "Post-WW2 rifle given the impossible task of replacing four guns. Found its present marksman role when it was replaced as the standard service rifle.",
	-- i don't even remember who it was that insisted the KF rifle was an M14 as opposed to a Mk14, but hopefully you're less of a brainlet today than you were all those years ago
	bm_wp_m14_body_ebr_desc = "High-strength military frame for close marksman support.",
	bm_wp_m14_body_jae_desc = "Aluminum thumbhole stock and body.",
	bm_wp_upg_o_m14_scopemount_desc = "Improved mounting position that places sights closer to the eye.",
	--
	bm_wp_wpn_fps_m14_extra_bipod_desc = "When the jungle speaks, listen.\n\n" .. bipodstr,
	-- B-team stock
	bm_wp_m14_body_ruger = "Ruger Mini-14 Body",
	bm_wp_m14_body_ruger_desc = "A second-choice stock. Fitting for a B-Team like you.",


	-- Galant/Garand
	bm_w_ching_desc = "An icon of World War 2. Pronounced the greatest battle implement ever devised, and pronounced as rhyming with errand. Keep those clips flying.",
	bm_wp_ching_b_short_desc = "An experiment that never went beyond that, until someone saw a commercial opportunity.",
	bm_wp_ching_fg_railed = "Custom Rail",
	bm_wp_ching_fg_railed_desc = "Aw, come on. This thing is history. You can't just do shit like this.",


	-- CONTRACTOR 308
	bm_w_tti_desc = get_string_by_option(InFmenu.settings.txt_wpnname, {"A custom ordered marksman rifle built on a .308 receiver. Being light and quick on follow-up shots, it makes short work of unwanted problems.", "A custom ordered marksman rifle built on a .308 AMCAR-10 receiver. Being light and quick on follow-up shots, it makes short work of unwanted problems."}),
	bm_wp_tti_ns_hex = "Silent Assassin",
	bm_wp_tti_ns_hex_desc = "It's fine if they know that a hit occurred. They just don't need to know from where." .. silstr,
	bm_wp_tti_s_vltor = "Ultor Stock",
	bm_wp_tti_s_vltor_desc = "Can't have the stock snagging on anything.",
	bm_wp_tti_s_vltor_desc_fine = "WHAT WAS WRONG WITH STOCK? NOT HOLLYWOOD ENOUGH?",


	-- SVD/GROM
	bm_w_siltstone_desc = "Soviet rifle created to retain squad range engagement capabilities when the standardization of assault rifles reduced average effective range.",



	-- REPEATER 1874
	bm_w_winchester1874_desc = "Also known as \"The Gun that Won the West\". Chambered in the popular handgun rounds of the day to keep ammo purchases simple.",
	bm_wp_winchester_b_long_desc = "A barrel for dealing with those low-down varmints from range.",
	bm_wp_winchester_b_suppressed_desc = "Most likely a modern fabrication not used by historical outlaws." .. silstr3,
	bm_wp_winchester_sniper_scope_desc = "An old-fashioned way of looking at things.\n\nZoom level 10.",


	-- RATTLESNAKE
	bm_w_msr_desc = "SOCOM sniper rifle currently replacing all bolt-action sniper rifles in US special forces. Theoretically capable of putting five shots into a half-foot circle a kilometer away.",
	bm_wp_snp_msr_b_long_desc = "Extended range barrel.",
	bm_wp_snp_msr_ns_suppressor = "Silent Rattle",
	bm_wp_snp_msr_ns_suppressor_desc = "It's not a rude surprise if they never see it coming." .. silstr3,
	bm_wp_msr_body_msr = "Diamondback Body",
	bm_wp_msr_body_msr_desc = "A dark metal body for special operations.",


	-- WA2000
	bm_w_wa2000_desc = "Designed as a compact and fast-firing sniper rifle. Although used by German police and popular in fiction, it is best known in the underworld as a hitman's weapon.",
	-- langer barrel
	bm_wp_wa2000_b_long_desc = "Extended barrel made in secrecy just two miles from your safehouse.",
	-- gedaempfter barrel
	bm_wp_wa2000_b_suppressed_desc = "You did not kill that man and fade into the night. You were never there. Nobody can prove it." .. silstr3,
	-- leichter grip
	bm_wp_wa2000_g_light_desc = "Lightweight high-friction grips for increased mobility.",
	-- subtiler grip
	bm_wp_wa2000_g_stealth_desc = "Low-visibility furniture made from dark wood.",
	-- walnuss grip
	bm_wp_wa2000_g_walnut_desc = "Sturdy walnut grips for the discerning heister.",
	--
	bm_wp_wpn_fps_snp_wa2000_bipod_desc = "Press $BTN_BIPOD to deploy. When deployed, reduce recoil by 50% and increase rate of fire by 25%.",
	bm_wp_wpn_fps_snp_wa2000_nobipod_desc = "Feels like nothing at all.",


	-- PLATYPUS
	bm_w_model70_desc = "The rifleman's rifle. Highly regarded in both sporting and military use. Most famously wielded by the White Feather, a legendary sniper and record-setter.",
	-- beak suppressor
	bm_wp_model70_ns_suppressor = "Ocreata Suppressor",
	bm_wp_model70_ns_suppressor_desc = "The one you have to worry about is the one you don't have to see coming." .. silstr3,
	bm_wp_model70_iron_sight_desc = "No glint to give you away.",


	-- R93
	bm_w_r93_desc = "Inherits its straight-pull bolt and take-down capability from the original hunting rifle design. Favored by Germanic police and the occasional military.",
	-- wooden body
	bm_wp_r93_body_wood = "Sporter Stock",
	bm_wp_r93_body_wood_desc = "Suitable for hunting the most dangerous game.",
	-- short barrel
	bm_wp_r93_b_short_desc = "You're not firing from a hundred meters, are you?",
	-- suppressed barrel
	bm_wp_r93_b_suppressed = "Harvester Suppressor",
	bm_wp_r93_b_suppressed_desc = "You reap what doesn't shoot back first." .. silstr3,


	-- MOSIN-NAGANT
	bm_w_mosin_desc = "Introduced over a century ago. Still as good now as it was back then, and God help you if you disagree with that within earshot of the wrong person.",
	bm_wp_mosin_b_long_desc = "Standard long-barreled variant issued to Soviet infantry.",
	bm_wp_mosin_b_short_desc = "Shorter carbine variant for second-echelon use.",
	bm_wp_mosin_b_sniper = "Mitin Suppressor",
	bm_wp_mosin_b_sniper_desc = "Bring them to their ultimate fate." .. silstr3,
	bm_wp_mosin_ns_bayonet_desc = "A point affixed to the end of your weapon. Equip Weapon Butt as your melee weapon to use.\n100 damage. 10 knockdown.",
	bm_wp_mosin_iron_sight_desc = "The White Death comes.",
	bm_wp_mosin_body_conceal = "Monokhromnyy",
	bm_wp_mosin_body_conceal_desc = "Survival of the hidden.",


	-- DESERT FOX
	bm_w_desertfox_desc = "Shorter and lighter than any conventional sniper rifle, and has a better trigger than any comparable bullpup rifle. When bulk is at a premium, look no further.",
	--
	bm_wp_desertfox_b_long = "Fennec Barrel",
	bm_wp_desertfox_b_long_desc = "Hate will blind you. Quell it.",
	--
	bm_wp_desertfox_b_silenced = "Gaff Suppressor", -- operation gaff
	bm_wp_desertfox_b_silenced_desc = "So silent that you may as well have not been there." .. silstr3,


	-- THANATOS
	bm_w_m95_desc = "Anti-materiel rifle: the kind of weapon you use when you need to stop someone and their armored car from a mile away. With great power comes great hearing damage.",
	bm_wp_m95_b_barrel_long_desc = "Compensating for... recoil, I take it.",
	bm_wp_m95_b_barrel_short_desc = "A short-ranged weapon for blowing out eardrums.",
	bm_wp_m95_b_barrel_suppressed_desc = "Silence is golden, and pink mists are silver.",
	bm_wp_m95_b_barrel_suppressed_desc = "Less 'whispering death' and more 'furtively hissing death'." .. silstr3,
	bm_wp_inf_50bmg_incendiary = "M8 Armor Piercing Incendiary",
	bm_wp_inf_50bmg_incendiary_desc = "Armor piercing round with steel core and incendiary filler. Effective against armored targets.\n\n30 damage/sec for 3 seconds.",
	bm_wp_inf_50bmg_raufoss = "Mk 211 Mod 0 Multipurpose",
	bm_wp_inf_50bmg_raufoss_desc = "High-explosive incendiary armor-piercing. The Raufoss round does it all.\n\n-50% ammo scavenge. +50% damage if hitting Bulldozer visors. Damage is 80%/20% bullet/explosive. 30 damage/sec for 3 seconds on direct hit.",
	bm_wp_inf_50bmg_raufoss_restricted_desc = "ITEM CANNOT BE USED WITHOUT: Fix Custom Weapon Dragons Breath Crash (http://modwork.shop/24695)",
	
	-- R700
	bm_w_r700_desc = "Favored by both the police and the military, the R700 is a classic (if you can deal with the accidental discharges).",


	-- BIZON
	bm_w_coal_desc = "Law-enforcement and counter-terror SMG based on the AKS.74. Simple, high-capacity, and excellent for extended close-range encounters.",
	bm_w_coalprimary_desc = "Law-enforcement and counter-terror SMG based on the AKS.74. Simple, high-capacity, and excellent for extended close-range encounters.",
	bm_w_x_coal_desc = "Nothing lasts forever, but long enough is good enough as far as anyone should be concerned.",


	-- BLASTER 9MM
	bm_w_tec9_desc = "Black market SMG. Failed to attract government buyers, so it was sold to civilians as a pistol and then promptly banned for ease of conversion to full auto.",
	bm_w_x_tec9_desc = "What could drive a man to violence? How many among us are ready to snap - powder kegs waiting for a spark?",
	-- ghetto blaster
	bm_wp_tec9_ns_ext_desc = "Barrel extension with some shoulder thing that goes up.",
	-- short barrel
	bm_wp_tec9_b_standard = "Pocket Heat",
	bm_wp_tec9_b_standard_desc = "Post-ban unthreaded barrel. Might stop an amateur from attaching a suppressor.",
	-- ext mag
	bm_wp_tec9_m_extended_desc = "For self defense, of course. Lots of it.",
	-- just bend it
	bm_wp_tec9_s_unfolded_desc = "A little wire can go a long way.",


	-- CHICAGO TYPEWRITER
	bm_w_m1928_desc = "The Tommy Gun. Most famously seen in the hands of old school gangsters from back when religion and fedoras were still fashionable.",
	bm_w_m1928primary_desc = "The Tommy Gun. Most famously seen in the hands of old school gangsters from back when religion and fedoras were still fashionable.",
	bm_w_x_m1928_desc = "As the past becomes more distant, as our memories of its blemishes fall further into oblivion, we begin to romanticize what used to be.",
	bm_wp_m1928_b_long = "Long Barrel",
	bm_wp_m1928_b_long_desc = "It's 'long arm of the law', not 'long-arm of the law'.",
	bm_wp_m1928_b_short = "Stubby Barrel",
	bm_wp_m1928_b_short_desc = "If you're going to hold it by your hip and unleash, you don't need barrel harmonics getting in the way.",
	-- discrete parts
	bm_wp_m1928_fg_discrete = "Synthetic Foregrip",
	bm_wp_m1928_fg_discrete_desc = "Not everyone shows their face enough to become public enemy number one.",
	bm_wp_m1928_g_discrete = "Synthetic Grip",
	bm_wp_m1928_g_discrete_desc = "Yesterday's ideas carried out through tomorrow's tricks.",
	bm_wp_m1928_s_discrete = "Synthetic Stock",
	bm_wp_m1928_s_discrete_desc = "The magic spot is right beneath everyone's noses. That's where it all goes down. Or downhill.",
	-- qd stock
	bm_wp_m1928_s_nostock_desc = "This'll put the 'violin case' in 'case of violence'.",


	-- COBRA
	bm_w_scorpion_desc = "Czechoslovakian SMG developed as a concealed automatic weapon for security and special forces, but also issued to vehicle crews. Easy to carry if you don't buy a tiny holster.",
	bm_w_x_scorpion_desc = "A weakness is a point of vulnerability and opportunity. It's also a point of very embarrassing underestimations.",
	bm_wp_scorpion_m_extended = "Dual Magazines",
	bm_wp_scorpion_m_extended_desc = "Two magazines joined together.\n\nEvery other reload is 50% faster.",
	bm_wp_scorpion_g_ergo_desc = "Shaped pistol grip.",
	bm_wp_scorpion_g_wood_desc = "Original Czechoslovak pistol grip.",
	bm_wp_scorpion_b_suppressed = "Silent Stinger",
	bm_wp_scorpion_b_suppressed_desc = "Watch your back.",
	bm_wp_scorpion_s_nostock_desc = "I've heard the smaller ones are easier to hold close to your heart.",
	bm_wp_scorpion_s_unfolded_desc = "Stocks exist for a reason.",


	-- CMP
	bm_w_mp9_desc = "A descendant of the TMP, whose fate was sealed by unfavorable export laws. Can be fired one-handed, as certain law enforcers will demonstrate.",
	bm_w_x_mp9_desc = "Don't get too attached to something if you aren't willing to move the world for it. One dog can travel a thousand miles to find its owner. A hundred others will die trying.",
	bm_wp_mp9_m_extended_desc = "Full-sized magazine.",
	-- skeletal stock
	bm_wp_mp9_s_skel = "Solid Stock",
	bm_wp_mp9_s_skel_desc = "Fixed stock typically found on a related but distinct tactical machine pistol.", -- tmp stock


	-- COMPACT-5
	bm_w_mp5_desc = "SMG based on the manufacturer's existing rifle designs. Reached iconic status in the western world. Currently used by a large number of law enforcement and military units.",
	bm_w_new_mp5primary_desc = "SMG based on the manufacturer's existing rifle designs. Reached iconic status in the western world. Currently used by a large number of law enforcement and military units.",
	bm_w_x_mp5_desc = "Just because you can do the inadvisable doesn't mean you should. But it also doesn't mean you can't.",
	-- Sehr Kurze
	--bm_wp_mp5_fg_m5k = "Sehr Kurze",
	bm_wp_mp5_fg_m5k_desc = "Short railed handguard.",
	-- Polizei Tactical
	--bm_wp_mp5_fg_mp5a5 = "Polizei Tactical",
	bm_wp_mp5_fg_mp5a5_desc = "Tactical railed handguard.",
	-- The Ninja
	--bm_wp_mp5_fg_mp5sd = "The Ninja",
	bm_wp_mp5_fg_mp5sd_desc = "High-performance integral suppressor." .. silstr,
	-- Adjustable Stock
	bm_wp_mp5_s_adjust = "Retractable Stock",
	bm_wp_mp5_s_adjust_desc = "Extending metal stock with polymer buttplate.",
	-- Bare Essentials
	--bm_wp_mp5_s_ring = "Bare Essentials",
	bm_wp_mp5_s_ring_desc = "Just you, a gun, and a sling loop.",
	-- spartan stock
	bm_wp_mp5_s_folding_desc = "Every personal defense weapon should have one.",
	-- straight grip
	bm_wp_wpn_fps_smg_mp5_fg_stripped = "Kaufmann Configuration",
	bm_wp_wpn_fps_smg_mp5_fg_stripped_desc = "Also known as the briefcase blaster.",
	--
	bm_wp_mp5_m_straight = "The Black Ten Special",
	bm_wp_mp5_m_straight_desc = "10mm Auto. It's too spicy for the feds. Much like a certain someone I know, come to think of it.",


	-- JACKAL/UMP
	bm_w_schakal_desc = "Developed as a successor to the Compact-5, but ultimately ended up sharing the limelight. Favored by some for its greater controllability.",
	bm_w_schakalprimary_desc = "Developed as a successor to the Compact-5, but ultimately ended up sharing the limelight. Favored by some for its greater controllability.",
	bm_w_x_schakal_desc = "Age brings intangible qualities, for better and for worse. Those we remember manage to do more with less.",
	bm_wp_schakal_m_long_desc = "The edge of practicality. Keep it in good condition.",
	bm_wp_schakal_m_short_desc = "The other side of the coin. A little embarrassing to look at.",
	bm_wp_schakal_vg_surefire = "Anubis Grip",
	bm_wp_schakal_vg_surefire_desc = "Guidance. For the dead or to the soon-to-be, you'll have to find out.",


	-- CR 805B
	bm_w_hajk_desc = "Czech assault rifle developed to replace a Cold War rifle that resembled but was internally different from the AK.762.",
	bm_w_x_hajk_desc = "Work is not done with the tools you want, but with the tools you have.",
	bm_w_hajkprimary_desc = "Czech assault rifle developed to replace a Cold War rifle that resembled but was internally different from the AK.762.",



	-- MARK 10
	bm_w_mac10_desc = "Violent and uncontrollable. Originally designed for sale to militaries, but export laws pushed it into the streets where it earned its seedy reputation.",
	--bm_w_x_mac10_desc = "The world looks completely different when you forget the norms. Lives become cheap, and bullets even cheaper.",
	bm_w_x_mac10_desc = "Some people live in a whole other world from others. The question is who separated from who.",
	bm_wp_mac10_m_extended = "The Downtown Deal",
	bm_wp_mac10_m_extended_desc = "It all has to go south sometime.",
	bm_wp_mac10_body_ris_desc = "Impress your friends. Miss less. Impress your friends by missing less.",
	bm_wp_mac10_s_skel_desc = "It beats using the wire.",


	-- JACKET'S PIECE
	bm_w_cobray_desc = "A 9mm derivative of the Mark 11, which itself was derived from the Mark 10. Fast and deadly, like its owner.",
	bm_w_x_cobray_desc = "Is this just an obligation, or do you actually like what you do? Should you even like what you do? Think about what your answer implies for someone in this line of work.",
	bm_wp_cobray_body_upper_jacket_desc = "Do you like hurting other people?",


	-- MP40
	bm_w_erma_desc = "The iconic SMG of the Third Reich, made to streamline production of the M38. Refrain from holding the magazine while firing.",
	bm_w_x_erma_desc = "\"Father said if I'd done wrong, a monster would creep out at night and come for me. I tried to do no wrong, but the monster came all the same.\"",


	-- SPECOPS SMG
	bm_w_mp7_desc = "Designed as a lighter and more maneuverable competitor to the Project 90. Fires similar low-weight armor penetrating rounds through a more traditional design.",
	bm_w_x_mp7_desc = "What is greater than you can seem insurmountable, but given enough force, any problem that cannot be solved can at least be rendered irrelevant.",
	bm_wp_mp7_m_extended_desc = "40-round magazine. Perfect for city warfare.",
	bm_wp_mp7_s_long = "Extended Stock",
	bm_wp_mp7_s_long_desc = "Why didn't you think of this before?",


	-- PATCHETT
	bm_w_sterling_desc = "More accurate and reliable than its cheaply-manufactured wartime predecessor, the Sten. Served all the way until 1994, when it was fully replaced with the L95.",
	bm_w_x_sterling_desc = "Not everything lost can be returned. Sometimes, there's no way to bring it all back like it used to be, no way to avoid the mess of glue to hold it together.",


	-- KOBUS 90
	bm_w_p90_desc = "Railed variant of the Project 90. Though designed as a compact emergency weapon, it proved popular with special forces, counter-terrorists, and TV shows.",
	bm_w_x_p90_desc = "There's two things you make a lot of in this line of work: money, and enemies. Bring enough bullets, and you can solve your problems with both.",
	bm_wp_p90_b_long_desc = "Extended barrel with slant-cut muzzle brake.",
	bm_wp_p90_b_civilian = "Shrouded Barrel",
	bm_wp_p90_b_civilian_desc = "Ventilated shroud with high-accuracy barrel.",
	bm_wp_p90_b_ninja_desc = "Don't settle for less.",

	-- PDW AP Kit
	bm_wp_inf_pdw_apkit = "PDW Armor-Piercing Kit",
	bm_wp_inf_pdw_apkit_desc = "Converts the weapon for armor-piercing rounds.\n\nPenetrates shields and armor. Slightly less damage to fleshy bits.\n\n-50% ammo scavenge. No damage penalty for shooting through walls.",


	-- SIGNATURE SMG
	bm_w_shepheard_desc = "Recent SMG designed with CAR-like controls for military and law enforcement use. Unusually for an SMG, it features a closed rotating bolt.",
	bm_w_shepheardprimary_desc = "Recent SMG designed with CAR-like controls for military and law enforcement use. Unusually for an SMG, it features a closed rotating bolt.",
	bm_w_x_shepheard_desc = "All roads may lead to Rome, but it is a fool who never seeks the best path.",
	bm_wp_shepheard_m_extended = "Full-Length Magazine",
	bm_wp_shepheard_m_extended_desc = "Tactical reloads are just annoying reloads when you're performing them every five seconds.",


	-- SWEDISH K
	bm_w_m45_desc = "Simple automatic-only SMG used by the Swedish Army for two decades. Will fire almost immediately after being pulled out of the water.",
	bm_w_x_m45_desc = "What will you do when your mask can no longer protect you? What can you hide from someone who knows who you really are?",
	bm_wp_smg_m45_m_extended = "Lahti's Legacy",
	bm_wp_smg_m45_m_extended_desc = "One coffin mag is enough for ten funerals.",


	-- UZI
	bm_w_uzi_desc = "One of the earliest SMGs to reduce weight and length by using a telescoping bolt. Widely used by law enforcement, military, and security forces around the world.",
	bm_w_x_uzi_desc = "What cannot be overcome by strength must be overcome by trickery. Just as an external threat unites, a seed of discord divides.",


	-- MICRO UZI
	bm_w_baka_desc = "Exceedingly small, exceedingly fast, and exceedingly deadly. A concealable killer for the heister on the go.",
	bm_w_x_baka_desc = "Calculations create false certainty. The purity of mathematics makes it easy to forget that no right conclusion is derived from the wrong data.",
	-- spring
	bm_wp_baka_b_smallsupp_desc = "Covered by a wrapping that mostly protects your warranty." .. silstr,
	-- maki
	bm_wp_baka_b_midsupp_desc = "What it lacks in length, it makes up for in girth." .. silstr,
	-- futomaki
	bm_wp_baka_b_longsupp_desc = "There's always something bigger. Just not very many things or by very much." .. silstr,


	-- VECTOR
	bm_w_polymer_desc = "Achieves extreme rate of fire at a low weight, making it a close-range killer. The otherwise-unmanageable recoil is kept in check by a special diversion action.",
	bm_w_x_polymer_desc = "Time is precious. For every opportunity revealed by meticulous forethought, another is lost to time.",
	--bm_w_x_polymer_desc = "There isn't always time to fret over the details. Think on your feet. Live fast. Shoot faster.",


	-- VERESK
	bm_w_sr2_desc = "Compact SMG used primarily by Russian security agencies and law enforcement. Typical of Russian engineering, its action is directly based on that of a rifle.",
	bm_w_x_sr2_desc = "You can tell a lot about a person by seeing them at their limit - knowing how far they would go, and for what purpose.",
	--bm_w_x_sr2_desc = "I couldn't tell you precisely what Spetsnaz train for, but it probably isn't this. Their loss.",




	-- SHOTGUNS
	-- JOCELINE
	bm_w_b682_desc = "Classy and accurate. At home in the great untamed wilderness or in America's financial systems. Go bag yourself a few trophy Cloakers.",
	bm_wp_b682_b_short_desc = "Long barrels are a liability at close range.",
	-- wrist wrecker
	bm_wp_b682_s_short_desc = "That name isn't a joke.",
	bm_wp_b682_s_ammopouch_desc = "Reload with class. You didn't pay a premium to look like a peasant.",


	-- MOSCONI
	bm_w_huntsman_desc = "An old-fashioned enforcer's best friend. Will more than likely vaporize any kneecaps you point it at, along with most of the leg around it.",
	-- road warrior
	bm_wp_huntsman_b_short_desc = "The worst part of hunting is when your prey simply falls down instead of launching backwards into the distance.",
	-- gangsta special
	bm_wp_huntsman_s_short_desc = "A minor ergonomic adjustment. Great for storage. Not so great for delicate sensibilities.",


	-- steakout is a fucking trash name for an aa-12
	bm_w_aa12_desc = "Best known for its fully automatic action, proprietary gas system, and drum magazine. Great for clearing rooms or ending a zombie apocalypse in a hurry.",
	-- drum mag
	bm_wp_aa12_mag_drum = "Inferno Mag",
	bm_wp_aa12_mag_drum_desc = "You know how it is. People live and people die.\n\n-17% scavenge",
	-- long barrel
	bm_wp_aa12_barrel_long = "Standard Barrel",
	bm_wp_aa12_barrel_long_desc = "Full-length barrel used on non-CQC models.",
	--
	bm_wp_aa12_barrel_silenced = "Urn of Shadows",
	bm_wp_aa12_barrel_silenced_desc = "Do you know what it takes to carbonize a human body?" .. silstr2,


	-- BREAKER
	bm_w_boot_desc = "One of the first successful repeating shotguns ever. The perfect choice for cowboys, history aficionados, and killer robots from the future.",
	bm_wp_boot_b_long_desc = "Lets you reach a little further.",
	bm_wp_boot_b_short_desc = "This is about as small as it gets.",
	-- treated body
	bm_wp_boot_body_exotic_desc = "Puts the die in tie-dye.",
	bm_wp_boot_s_long_desc = "A counterweight you can use to aim, I suppose.",


	-- REINFELD 870
	bm_w_r870_desc = "One of the most-produced shotguns in the world for its excellent balance of accuracy, power, and capacity. Don't take a direct hit from one if you enjoy breathing.",
	-- WOO WOO HERE COMES THE LOCOMOTIVE
	bm_w_serbu_desc = "A dramatically shortened Reinbeck. The quintessential Enforcer sidearm.",
	-- zombie hunter
	bm_wp_r870_fg_wood_desc = "Anyone who tells you to aim for the body doesn't know how to aim.",


	-- RAVEN
	bm_w_ksg_desc = "Bullpup pump shotgun. Unusual dual-tube design with automatic feed toggle allows high capacity. Loads and ejects through the same port.",
	bm_wp_ksg_b_long = "Long Tubes",
	bm_wp_ksg_b_long_desc = "More range and more fun.",
	bm_wp_ksg_b_short = "Short Tubes",
	bm_wp_ksg_b_short_desc = "You've got something to hide, and it's going to make a real splash.",


	-- PREDATOR
	bm_w_spas12_desc = "A silver screen star due to its thick and powerful appearance. Rarely do movie stars get to fire it on semi-auto.",
	-- extended mag
	bm_wp_spas12_b_long_desc = "The right shell in the wrong place can make all the difference in the world.",
	-- folded stock
	bm_wp_spas12_s_folded_desc = "You weren't using those sights anyways.",
	-- solid stock
	bm_wp_spas12_s_solid_desc = "Solid stock made for the American market.",
	-- no stock
	bm_wp_spas12_s_no_desc = "Frees your weapon from the tyranny of the shoulder stock.",


	-- IZHMA
	bm_w_saiga_desc = "Combines the flesh-rending punch of a shotgun with the engineering of an AK. Used to deadly effect by the only law enforcers big enough to handle it.",
	bm_wp_saiga_b_short_desc = "Careful not to burn your fingers off.",
	bm_wp_saiga_b_short_desc_fine = "WHERE YOU PLANNING TO PUT GUN? UP OWN ASS?",
	bm_wp_saiga_fg_lowerrail_desc = "A rail system. Not the most comfortable thing to hold on to.",
	bm_wp_saiga_fg_lowerrail_desc_fine = "LASER NOT MAKE GUN SHOOT STRAIGHT. YOU ONLY MAKE CAT DANCE.",
	bm_wp_saiga_fg_holy = "The Ventilator",
	bm_wp_saiga_fg_holy_desc = "The space age is here.",
	bm_wp_saiga_fg_holy_desc_fine = "YOU THINK WEIGHT SAVED GO TO SMALL PENIS?",


	-- M1014
	bm_w_benelli_desc = "Requested, purchased, and used by American forces. Good enough for desert warfare, which means you'd have to be the bane of all technology to break it.",
	bm_wp_ben_b_long_desc = "Standard full-length barrel.",
	bm_wp_ben_b_short_desc = "Short entry barrel. The last thing someone needs to see coming around a corner.",
	bm_wp_ben_s_collapsed_desc = "You weren't using it, were you?",
	-- stock that can't kill babies
	bm_wp_ben_fg_standard = "Solid Stock",
	bm_wp_ben_fg_standard_desc = "A fixed tactical stock.",


	-- JUDGE
	bm_w_judge_desc = "Named for its association with certain officials. Marketed as the ultimate in personal defense because it combines the best (and worst) of shotguns and handguns.",
	bm_w_x_judge_desc = "A successful criminal defies the law. A truly successful criminal defines it.",


	-- STREET SWEEPER
	bm_w_striker_desc = "Uses a non-detaching revolving cylinder for higher damage potential. Designed to control crowds by force, hopefully before you have to start reloading it.",
	bm_wp_striker_b_long_desc = "18\" barrel used meet minimum length requirements for sale in America.",
	bm_wp_striker_b_suppressed_desc = "Custom-designed suppressor for the indoor defense of upstanding citizens such as yourself.",


	-- GSPS
	bm_w_m37_desc = "Holds the world record for longest production run for a pump shotgun. Popular with police forces, too. Show them what the other side of the barrel looks like.",
	bm_w_m37primary_desc = "Holds the world record for longest production run for a pump shotgun. Popular with police forces, too. Show them what the other side of the barrel looks like.",


	-- GOLIATH
	bm_w_rota_desc = "Revolving bullpup shotgun. Unlike its namesake, the Goliath is very light and compact, even seeing use as an underbarrel accessory in cut-down form.",
	bm_w_x_rota_desc = "Everyone loves a good underdog story until they're on the wrong side of it.",
	
	-- Silenced barrel
	bm_wp_rota_b_silenced_desc = "Silenced barrel for when you want to launch someone across the street... quietly." .. silstr2,


	-- GRIMM
	bm_w_basset_desc = "A bullpup SAIKA-12 conversion, providing magazine-fed semi-automatic fire in a shorter package.",
	--bm_w_x_basset_desc = "Not safe for children.",
	bm_w_x_basset_desc = "Recognition and reputation open doors that no amount of money alone can unlock. Of course, having immense amounts of money helps.",
	bm_wp_basset_m_extended_desc = "There's a story behind every wound. Or a wound behind every story.",
	bm_wp_basset_m_extended_desc_fine = "NOTHING EVER GOOD ENOUGH FOR HICK AMERICAN. EVERYTHING MUST BE FATTER.",


	-- CLAIRE
	bm_w_coach_desc = "A non-descript break-open shotgun with exposed hammers. When what you have are two hammers, everything starts looking like a nail.",
	bm_w_coachprimary_desc = "A non-descript break-open shotgun with exposed hammers. When what you have are two hammers, everything starts looking like a nail.",




	-- RPK
	bm_w_rpk_desc = "Developed alongside its rifle cousin as a support weapon. Besides the obvious barrel difference, the RPK also has a modified receiver and mechanism.",


	-- M249
	bm_w_m249_desc = "Replaced heavier MGs as the US standard squad-level support weapon. Its high-capacity ammo box allow it to lay down plenty of suppressing fire.",
	bm_wp_m249_b_long_desc = "Just a little extra tip.",
	bm_wp_m249_fg_mk46 = "Railed Handguard",
	bm_wp_m249_fg_mk46_desc = "Lighter handguard preferred by US Special Operations.",
	bm_wp_m249_s_solid_desc = "A plastic stock as solid as a rock.",


	-- BRENNER 21
	bm_w_hk21_desc = "GPMG based on the Gewehr 3, such that nearly half of all parts are interchangeable. Comes with a side grip, just like the one you got years ago.",
	bm_wp_hk21_b_long_desc = "Extended heavy barrel. Slightly compensates for your inability to hit things.",
	bm_wp_hk21_fg_short = "Classic Handguard",
	bm_wp_hk21_fg_short_desc = "You old-timers out there might appreciate it.",
	bm_wp_hk21_g_ergo_desc = "Shaped pistol grip.",


	-- BUZZSAW
	bm_w_mg42_desc = "Simple, reliable, and incredibly deadly to anything unfortunate enough to be downrange. Gained the nickname \"buzzsaw\" from its saw-like report.",
	bm_wp_mg42_b_mg34 = "Maschinengewehr 34",
	bm_wp_mg42_b_mg34_desc = "The first general-purpose machine gun in the world.",


	-- KSP 58
	bm_w_par_desc = "A general purpose machine gun used and produced by over eighty countries. A truly universal weapon found on bipods, tripods, and vehicles of various kinds.",





	-- BABY DEAGLE
	bm_w_sparrow_desc = "The \"Baby Deagle\". Actually based on the acclaimed CZ-75, taking on the Deagle name purely for marketing purposes.",
	bm_w_x_sparrow_desc = "The most dangerous man in the world is one who thinks there is nothing for him to lose. The second most dangerous man merely knows better than to lose anything.",
	bm_wp_sparrow_body_941 = "F-Model Kit",
	bm_wp_sparrow_body_941_desc = "Can't go wrong with the classics.",
	bm_wp_sparrow_g_cowboy = "Weighted Grip",
	bm_wp_sparrow_g_cowboy_desc = "You're gonna... nah, that's too obvious.",


	-- WHITE STREAK
	bm_w_pl14_desc = "Prototype handgun designed in conjunction with top Russian shooters. Made to survive hot Russian rounds, cold Russian winters, and many Russian gunfights.",
	bm_w_x_pl14_desc = "A fresh perspective can change everything. Every blind spot is a question waiting to be asked and an answer waiting to be revealed.",


	-- CONTRACTOR PISTOL
	bm_w_packrat_desc = "Ambidextrous German police pistol. A descendent of the Interceptor and P2000. An aggressively lethal handgun for aggressively lethal people, like Wick.",
	bm_w_x_packrat_desc = "To get much more than you bargained for is an exciting prospect until the moment you realize you were better off leaving what you took.",
	bm_wp_packrat_ns_extended = "Custom Compensator",
	bm_wp_packrat_ns_extended_desc = "The future is detailed blocks. Trust me.",


	-- BERNETTI 9
	bm_w_b92fs_desc = "Easy to find, easy to unjam, and only moderately difficult to fire in a slow-motion dive. Good for some bloodshed and heroics.",
	bm_w_x_b92fs_desc = "Personal problems demand personal solutions. A system is slow and unfeeling. A man, driven to action, is anything but.",
	-- the professional compensator
	bm_wp_beretta_co_co1_desc = "\"Cleaners\" was a misnomer. They were making a mess of it.",
	-- the competitor compensator
	bm_wp_beretta_co_co2_desc = "I had a bullet with her name on it. I had ten thousand bullets with the hag's name on them.",
	bm_wp_beretta_g_ergo_desc = "Firing a gun is a binary choice. Either you pull the trigger or you don't.",
	bm_wp_beretta_g_engraved = "Engraved Grip",
	bm_wp_beretta_g_engraved_desc = "A bomb went off, turning snow into liquid gold.",
	bm_wp_beretta_m_extended_desc = "I want to sleep to forget. To change the past. I wanted unlimited ammo and a license to kill.",
	bm_wp_beretta_sl_brigadier_desc = "Both of us knew how this would end: in pain and suffering.",
	-- custom titanium frame, beretta 92a1?
	bm_wp_beretta_body_modern_desc = "Built to withstand, unless you're about to stuff high explosive into the chamber.",


	-- Five-seveN
	bm_w_lemming_desc = "Lightweight. Polymer. Armor-piercing. Large-magazined. Good thing they're outlawed, or criminals might get their hands on one.",
	-- AP Kit
	bm_wp_inf_lemming_apkit = "AP Kit",
	bm_wp_inf_lemming_apkit_desc = "Converts the weapon for armor-piercing rounds.\n\nPenetrates shields and armor. Slightly less damage to fleshy bits.\n\n-50% ammo scavenge. No damage penalty for shooting through walls.",


	-- M13
	bm_w_legacy_desc = "German police pocket pistol. Features a unique gas-delayed blowback locking system to slow the rearward motion of the slide until the bullet has left the barrel.",
	bm_w_x_legacy_desc = "Readiness is not a matter of convenience, but of necessity. No amount of wishful thinking will change an empty magazine for you.",


	-- CHIMANO 88
	bm_w_glock_17_desc = "Created for the Austrian Armed Forces to replace the old Pistole 38. Its widespread popularity gave its manufacturer dominance over the handgun market.",
	bm_w_x_g17_desc = "Loyalty means a lot in a world that's out to get you. When wealth is commonplace, the greatest treasures are what cannot be bought.",


	-- STRYK 18C
	bm_w_glock_18c_desc = "Fully automatic pistol. Features a series of compensator cuts to reduce muzzle rise because going full auto will empty the magazine in under two seconds.",
	bm_w_x_g18c_desc = "Violence is best made swift and terrible. Dragging it out would be uncouth, not to mention unnecessarily risky.",


	-- CHIMANO CUSTOM
	bm_w_g22c_desc = "A bigger and meaner take on a classic handgun. Favored by American law enforcement agencies, including the FBI, for its improved stopping power.",
	bm_w_x_g22c_desc = "Moderation is a tricky thing to handle. An insurmountable wall may call for force, but the smart man knows how much to use.",


	-- CHIMANO COMPACT
	bm_wp_pis_g26_desc = "Made to be as small and light as possible, which required significant work on the frame, locking block, and spring assembly. Not invisible to metal detectors.",
	bm_w_jowi_desc = "Wealth and power go a long way in an unkind world, but not even a king's ransom can pay a priceless debt if the reaper comes to collect.",


	-- INTERCEPTOR 45
	bm_w_usp_desc = "German service pistol based on a larger special forces handgun and subjected to the same rigorous standards.",
	bm_w_x_usp_desc = "Have you unearthed your every desire? Have you cracked every secret? What was hidden may have been hidden for a reason, not that you care.",


	-- GRUBER KURZ
	bm_w_ppk_desc = "An influential and iconic weapon. Carries just enough in a magazine to be the secret agent you've always wanted to be. Secret agents don't miss, buddy.",
	bm_w_x_ppk_desc = "Bullets, like all forms of force, are most efficiently used when concentrated exactly where they need to be.",


	-- CROSSKILL
	bm_w_colt_1911_desc = "Came from the grandfather of the modern handgun, which served America's armies for 75 years. As long as freedom lives, it will serve the American people for 75 more.",
	bm_w_x_1911_desc = "Someone for hire needs to set standards. Shoot straight, make only as much of a mess as you need to, and get the job done. Bonus points for dressing nicely, too.",


	-- CROSSKILL GUARD
	bm_w_shrew_desc = "A shortened Crosskill, suitable for concealed carry. Unlike previous attempts at a short Crosskill, this one maintains reliable feeding and shooting.",
	bm_w_x_shrew_desc = "There was a time when the way your father did it was the way his father did it too. Those times are behind us.",


	-- SIGNATURE 40
	bm_w_p226_desc = "Competed with the Bernetti for the privilege of being the US Army's next sidearm. Though it narrowly lost, it nevertheless saw international success.",
	bm_w_x_p226_desc = "In failing to find what you originally sought, you may come across something greater.",


	-- LEO/HS2000
	bm_w_hs2000_desc = "A polymer-framed handgun developed by the Croatian arms industry over the course of a decade. Came to the American market under the LEO name.",
	bm_w_x_hs2000_desc = "America is a land of opportunity, and there just so happens to be a lot more opportunity if you can play both sides of the law.",


	-- C96
	bm_w_c96_desc = "Boasted greater range and power than its contemporaries. Its distinctive appearance makes it a collector's choice. Don't ask about the sights.",
	bm_w_x_c96_desc = "The finer points of life need not be grand. Observe: a pair of guns for a man of discerning taste, pressed suits, and excess holsters.",


	-- PARABELLUM/LUGER
	bm_w_breech_desc = "The pistol for which the ubiquitous 9x19mm cartridge was made. A historical icon and prized war trophy.",
	bm_w_x_breech_desc = "It's easy to lose sight of the little things when you're caught up in the big picture. Remember: save a bullet for yourself.",


	-- PEACEMAKER
	bm_w_peacemaker_desc = "The Single Action Army. One of the most famous six-shooters of all time. In modern times, it has been reinforced for a little more punch.",


	-- BRONCO
	bm_w_raging_bull_desc = "Combines the classic six shots with modern materials. Marketed to big game hunters, which means it's strong enough to take someone's head off.",
	bm_w_x_rage_desc = "Twelve is a special number. Twelve months. Twelve signs. Twelve Apostles. Twelve Gods.\n\nTwelve bullets.",
	bm_wp_pis_rage_extra = "Handgun Sight Mount",
	bm_wp_pis_rage_extra_desc = "Frame-mounted sight rail.",
	bm_wp_rage_b_comp1_desc = "Barrel with black compensator to quicken follow-up shots.",
	bm_wp_rage_b_short_desc = "It's short. Short enough to make you narrate your life in metaphors.\n\n" .. switch_snubnose,
	bm_wp_rage_b_comp2_desc = "Barrel with side-venting muzzle device.",
	bm_wp_rage_b_long_desc = "Either a very large handgun or a very small cannon.",
	bm_wp_rage_g_ergo_desc = "Larger grip with deeper finger grooves.",
	bm_wp_rage_body_smooth_desc = "Smooth.",


	-- DEAGLE
	bm_w_deagle_desc = "The most powerful semi-automatic handgun ever mass produced, without question. Only a revolver could match a cannon like this blow-for-blow.",
	bm_w_x_deagle_desc = "There will come a time when you have no options, and all that's left to do is hand over the gun - one bullet at a time.",

	-- Milled barrel
	bm_wp_deagle_b_modern_desc = "Standard slide with a side-venting muzzle device.",


	-- MATEBA
	bm_w_mateba_desc = "A mix of old-fashioned perspectives and innovative thinking. Its lower barrel position helps reduce muzzle rise, if not loading speed.",
	bm_w_x_2006m_desc = "Many think of elegance and brutality as mutally exclusive. The truth is that unrelenting force has an elegance of its own.",
	bm_wp_2006m_b_short_desc = switch_snubnose,


	-- CASTIGO
	bm_w_chinchilla_desc = "The most powerful handgun in the world? Maybe not. But a skull doesn't care for the finer points of bullet energy if it goes straight through all the same.",
	bm_w_x_chinchilla_desc = "Some people ask themselves if they're lucky. A poor decision, really. It's not about luck when you can count where the numbers matter.",

	-- B93R
	bm_w_beer_desc = "A rapid-fire version of the Beretta 92. The \"R\" stands for Raffica, or \"burst\". Designed for use where both size and firepower are important.",
	bm_w_x_beer_desc = "Liberty is simultaneously its own greatest ally, and its own greatest enemy. It is up to the free to protect it from the oppressed.",
	
	-- CZ 75
	bm_w_czech = "CZ-75 Auto",
	bm_w_czech_desc = "A classic Czech handgun modified for full-auto firing mode.",
	bm_w_x_czech = "Akimbo CZ-75 Auto",
	bm_w_x_czech_desc = "Violence is for the weak, yet the weak are the ones at the receiving end of it.",
	
	-- Stechkin/Igor
	bm_w_stech = "Stechkin Automatic",
	bm_w_stech_desc = "A deadly Russian select-fire machine pistol. Artillery and mortar crew used these in lieu of bulky assault rifles.",
	bm_w_x_stech = "Akimbo Stechkin Automatic",
	bm_w_x_stech_desc = "True strength comes from within. A 9x19 Parabellum to the face will hurt just as much, though.",
	
	-- Hudson H9/Holt
	bm_w_holt = "Hudson H9",
	bm_w_holt_desc = "A light and slightly unusually shaped pistol designed to minimize recoil. Borrows the better aspects of many other handguns, but ultimately discontinued due to mismanagement.",
	
	bm_w_x_holt = "Akimbo Hudson H9",
	bm_w_x_holt_desc = "Even when you can do something better than anyone else, it won't mean a thing if you don't do it.",

	-- GL40
	bm_w_gre_m79_desc = "Thump Gun. Pro Pipe. Noob Tube. Blooper. The things we love have many names. Many sizes too, if you feel like sawing it down.",


	-- COMPACT 40MM
	bm_w_slap_desc = "New grenade launcher designed for the US Army, intended to improve on its predecessor in all respects while maintaining grenade compatibility.",


	-- PIGLET
	bm_w_m32_desc = "Multiple grenade launcher. It takes roughly a week to load, but you can rest on the seventh day because six grenades will smite a platoon.",


	-- CHINA PUFF LAUNCHER
	bm_w_china_desc = "A pump-action prototype. Due to its lack of official designation, it is typically referred to by its place of origin.",


	-- ARBITER
	bm_w_arbiter_desc = "Noun. One with the power to resolve a dispute. One whose opinion is considered authoritative. Sounds about right.",


	-- "GOD IS GREAT"
	bm_w_rpg7_desc_short = "PG-7VL HEAT rocket. Mechanical ignition system with manually-cocked hammer.",
	bm_w_rpg7_desc = "The most iconic and prolific shoulder-mounted weapon in the world. Causes massive area damage to friend and foe alike, so watch where you're firing.",


	-- COMMANDO
	bm_w_ray_desc_short = "M78 HEAT rocket. Quadruple firing pin trigger.",
	bm_w_ray_desc = "Though developed to replace flamethrowers with a longer-ranged and more effective system, a series of accidents relegated it to the anti-fortification role.",


	-- Flamethrower
	bm_w_flamethrower_mk2_desc = "Portable flamethrower system using gaseous fuel instead of a liquid projection system to reduce weight. Has gruesome effects on the minds and bodies of your enemies.",
	bm_wp_fla_mk2_mag_rare_desc = "Compressed low-temperature gas mixture. Reduced immediate burn, but starts deadly fires all the same.\n\n+50% ammo scavenge.",
	bm_wp_fla_mk2_mag_welldone_desc = "Volatile high-temperature gas mixture in internally-shielded canister. Share the joy of a good roasting, both verbally and chemically.\n\n-50% ammo scavenge.",


	-- Other Flamethrower
	bm_w_system_desc = "Of all the things that aren't flamethrowers, this is the most not a flamethrower.",
	bm_wp_system_m_high_desc = "Volatile high-temperature gas mixture in internally-shielded canister.\n\n-50% ammo scavenge.",
	bm_wp_system_m_low_desc = "Compressed low-temperature gas mixture. Reduced immediate burn, but starts deadly fires all the same.\n\n+50% ammo scavenge.",


	-- Plainsrider Bow
	bm_w_plainsrider_desc_short = "Native American flatbow. Osage timber.",
	bm_w_plainsrider_desc = "Quiet and graceful. A weapon with history. The tradition of archery still lives on today, though greatly diminished due to small details like firearms being much easier to aim.",
	bm_wpn_fps_upg_a_bow_explosion_desc = "Arrows tipped with explosives that detonate on impact. Unleash your inner Rambo.\n\n-75% ammo scavenge.",
	bm_wp_upg_a_bow_poison_desc = "Arrows tipped with a quick-acting poison. Will cause vomiting, shortly followed by death.",


	-- Pistol Crossbow
	bm_w_hunter_desc_short = "Mini-crossbow. Plastic/metal construction.",
	bm_w_hunter_desc = "Low-profile crossbow. Built with modern materials to be the ultimate tactical throwback to the past. Requires a high degree of skill to use at range.",
	bm_wp_upg_a_crossbow_explosion_desc = "Bolts tipped with explosives that detonate on impact. Unleash your inner Rambo.\n\n-75% ammo scavenge.",
	bm_wp_upg_a_crossbow_poison_desc = "Bolts tipped with a quick-acting poison. Will cause vomiting, shortly followed by death.",
	bm_wp_bow_hunter_b_carbon_desc = "CFRP crossbow limb. Higher performance and tacticool per ounce.",
	bm_wp_bow_hunter_b_skeletal_desc = "Lightweight limb made from improved materials.",
	bm_wp_bow_hunter_g_camo_desc = "Guaranteed to be inconspicuous.",
	bm_wp_bow_hunter_g_walnut_desc = "Walnut parts with grip sleeve.",


	-- Heavy Crossbow
	bm_w_arblast_desc_short = "12th century arbalest. Drawn via cranequin.",
	bm_w_arblast_desc = "Steel-barred crossbow. Its high draw weight mandated the use of draw mechanisms, further reducing fire rate. However, its raw power could only be matched by a trained longbowman.",


	-- Light Crossbow
	bm_w_frankish_desc_short = "Medieval crossbow. Hand-drawn.",
	bm_w_frankish_desc = "Horizontal bow assembly. Though less powerful than longbows, crossbows took days instead of years to learn, allowing them to be used en masse by conscript and mercenary armies.",


	-- Longbow
	bm_w_long_desc_short = "Longbow. Ash timber.",
	bm_w_long_desc = "The famous longbow. A six-foot limb of yew made to rain death from 300 yards away. Longbow volleys were used to devastating effect, most famously at Agincourt.",

	-- DECA technologies compound bow
	bm_w_elastic_desc_short = "Compound bow. Durafuse finish.",
	bm_w_elastic_desc = "The more things change, the more they stay the same. For all the bells, whistles, and doodads to behold, a bow is still a bow, and a shaft through the head is still going to kill.",
	bm_wp_elastic_m_explosive_desc = "Arrows tipped with explosives that detonate on impact. It's like a Rambo remake with method acting.\n\n-75% ammo scavenge.",
	bm_wp_elastic_m_poison_desc = "Arrows tipped with a quick-acting poison. Will cause vomiting, shortly followed by death.",

	-- airbow
	bm_w_ecp_desc_short = "Pneumatic gun. Dual compressed air canisters.",
	bm_w_ecp_desc = "Repeating pneumatic weapon. The top-mounted magazine and side-mounted sight allow for fast and accurate shooting to make the Chinese blush.",


	-- Vulcan Minigun
	bm_w_m134_desc = "Powered rotary gun. Typically mounted on vehicles, which is what any sane person would do. Do you need any more proof of your divinity?",
	-- the stump
	bm_wp_m134_barrel_short_desc = "Very short barrels for a very scary weapon.\n\n-40% spin-up/down time.",
	-- aerial assault
	bm_wp_m134_barrel_extreme_desc = "Shrouded aircraft-type barrel set. Puts the 'close' in 'close air support'.\n\n+60% spin-up time.",
	-- i'll take half that
	bm_wp_m134_body_upper_light = "Xander Machines T14", -- XM214
	bm_wp_m134_body_upper_light_desc = "An experiment in lighter infantry-portable rotary guns.",

	-- microgun
	bm_w_shuno_desc = "Shouldered rotary gun. An unusual development, but more than deadly enough in close range.",
	bm_wp_shuno_b_heat_long = "Heat-Shielded Barrel",
	bm_wp_shuno_b_heat_long_desc = "Just in case you ever plan to hold it by the barrels.",
	bm_wp_shuno_b_heat_short = "Short Heat-Shielded Barrel",
	bm_wp_shuno_b_heat_short_desc = "Maybe it'll make you feel a little safer.\n\n-40% spin-up/down time", -- close enough tbh
	bm_wp_shuno_b_short = "Short Barrel",
	bm_wp_shuno_b_short_desc = "What do you have to lose besides a few pounds?\n\n-40% spin-up/down time",


	-- OVE9000 SAW
	bm_w_saw_desc = "Powered circular saw. Though intended for cutting open locks, the blades will also cut through armor and brains with disgusting ease.",
	bm_wp_saw_m_blade_durable_desc = "Slow and steady cracks the deposit boxes.\n\n+100% scavenge.",
	bm_wp_saw_m_blade_sharp_desc = "Brittle high-performance blade. Looks nasty and does nasty things.\n\n+100% damage vs enemies. -50% scavenge.",









	-- MELEE WEAPONS
	-- Weapon Butt
	bm_melee_weapon_desc = "The use of a firearm as a melee weapon is common in armed robberies, as stabbing or shooting may cause more panic than compliance. In combat, it may be the emergency strike needed to buy breathing room.\n\nIt's exactly what you have on hand. Nothing more, nothing less.",
	-- Fists
	bm_melee_fists_desc = "A weapon you always have two of, barring any unfortunate accidents.\n\nYou're no wasteland superhero, but the recipe to knuckle sandwiches is older than fire. Just keep force-feeding them until they stop moving.",
	-- Brass Knuckles
	bm_melee_brass_knuckles = "Brass Knuckles",
	bm_melee_brass_knuckles_desc = "Knuckle weapons are an ancient idea and very simple in principle - focus the force of the punch to hit harder.\n\nKnuckle weapons also protect your fingers during the punch, so you can break other peoples' bones without breaking your own.",
	-- Money Bundle
	bm_melee_moneybundle = "Dallas Dosh",
	bm_melee_moneybundle_desc = "It's loads of money.\n\nWell, it's loads of fake money, so you can avoid giving your enemies the honor of being slapped by bills worth more than the paper they're printed on. Grab it while it's hot.",
	-- URSA Knife
	bm_melee_kabar_desc = "A no-nonsense knife the US Marine Corps adopted in 1942. The Navy were sufficiently impressed that they followed suit.\n\nIt's equal parts utility and fighting knife, so even Mother Nature can't hold you down.",
	-- URSA Tanto
	bm_melee_kabar_tanto = "URSA Tanto Knife",
	bm_melee_kabar_tanto_desc = "A low-visibility knife with the grip of an URSA and the back-stabbing potential of a tanto blade. A winning combination if I've ever seen one.\n\nYou could sink it into a bear's skull if you really wanted. Or a pig's, for that matter.",
	-- Krieger Blade
	bm_melee_kampfmesser_desc = "The standard knife of the German Army and the most prolific tanto military knife. Comes with serrations for utility purposes.\n\nIt cuts quite deeply if you put enough force behind your stab.",
	-- Berger Combat Knife
	bm_melee_gerber_desc = "A popular tactical knife with a folding clip point blade. The blade is easily deployed and retracted, and it'll resist being gummed up by blood.\n\nIt's as much proof as you need that good things come in small packages.",
	-- Trautman Knife
	bm_melee_rambo_desc = "A survival knife with a big bowie blade. The handle, capped by a compass, contains a small kit including fishing hooks, wire, and matches.\n\nThe length, serrated spine, and centered tip of the blade make it equally useful for killing.",
	-- KLAS Shovel
	bm_melee_shovel_desc = "Shovels are used for a variety of purposes. One possibility is as a weapon - sharpen the edges and you'll be cutting through flesh and bone. If you use it correctly, that is.\n\nWhich you won't.",
	-- Telescopic Baton
	bm_melee_baton_desc = "A perennial favorite for crowd control and beatings. Small, light, and stings like hell. The expandable baton truly does it all.\n\nExcept kill. Only a sadistic freak would use this to kill, right?",
	-- Survival Tomahawk
	bm_melee_tomahawk_desc = "The tomahawk has adapted through time to meet varying needs, whether it be as tool or throwing weapon.\n\nThis one is for breaching drywall and killing people who thought they were entering a knife fight.",
	-- Utility Machete
	bm_melee_becker_desc = "A machete is a large cleaver-like knife frequently used in tropical countries for dealing with vegetation, rebellions, and agriculture.\n\nHaving a strong and versatile machete can get you a lot of things, like money.",
	-- Nova's Shank
	bm_melee_toothbrush_desc = "These improvised weapons, known as shivs or shanks, are a frequent product of prisoner populations. Though crude, repeated stabs can cause fatal bleeding.\n\nThis particular shank was carved from a large toothbrush, creating a small nimble stiletto.",
	-- Psycho Knife
	bm_melee_chef_desc = "A chef's knife is a versatile food preparation tool. Its availability and utility make it a common tool for culinary artists, a common weapon for murderers, and a common fear for horror movie characters.",
	-- Lucille
	bm_melee_baseballbat_desc = "A baseball bat with a nasty addition. The barbed wire shreds exposed flesh and punctures kevlar or other protective layers.\n\nDon't grab onto the wrong end and you'll be fine.",
	-- Rivertown Glen Bottle
	bm_melee_whiskey = "Rivertown Glen Scotch",
	bm_melee_whiskey_desc = "The humble bottle makes for a surprisingly effective improvised weapon. A chunk of transparent drink-holder is surprisingly weighty, grippable, and resilient to being bashed against skulls.",
	-- OVERKILL Boxing Gloves
	bm_melee_boxing_gloves_desc = "Boxing gloves are cushioned gloves used to reduce injuries to the hand and face. It just so happens to allow you to throw stronger punches without fear of self-injury.\n\nGiven enough force, even a padded glove can cause brain damage or dislocate a jaw.",
	-- Alpha Mauler
	bm_melee_alien_maul_desc = "This strange weapon was acquired from an alien dimension at great cost.\n\nWhile perfectly serviceable, it's a little overpriced for a fancy hammer.",
	-- Bayonet
	bm_melee_bayonet_desc = "Bayonets are sharp weapons attached to the end of a firearm. Their use has declined, but bayonet knives are still issued as multi-purpose blades.\n\nThis one was made for AKs, but it'll fit nicely into your palm too.",
	-- Compact Hatchet
	bm_melee_bullseye_desc = "A sharp single-piece steel hatchet with rubber grip. It's used by hunters to clear underbrush and cut up game animals at an affordable price.\n\nAll things considered, a rather economical way to remove someone's fingers.",
	-- X46
	bm_melee_x46_desc = "A single-piece steel knife treated with anti-corrosion coating. It's designed for both utility and combat.\n\nIt's sharp, comfortable, invincible, and expensive. It pairs nicely with a big rifle, too.",
	-- Ding Dong
	bm_melee_dingdong_desc = "Slegehammers are large two-handed hammers used for pounding. This one happens to be a combination hammer, ram, and pry bar.\n\nLet's be honest, though. You're not using the pry bar to crack heads.",
	-- Baseball Bat
	bm_melee_bat_desc = "The seemingly-simple baseball bat is a carefully designed tool for strong and balanced swings. It symbolizes an American pastime and is beloved by atheletes and criminals alike.\n\nBat a thousand, and you can win a million.",
	-- HLM Cleaver
	bm_melee_cleaver_desc = "The Chinese chef's knife, often mistaken for a cleaver because of its rectangular shape, is an all-purpose culinary knife.\n\nIt's perfect for chopping vegetables, fish, and unwanted rivals.",
	-- HLM Machete
	bm_melee_machete_desc = "A home-made machete with a rough blade, clearly made to leave a large ragged canyon across someone's face. Make no mistake, this is a crude and violent tool.\n\nI'm not one to get personal with my gear, but one might say it has a lot in common with its owner.",
	-- Fire Axe
	bm_melee_fireaxe_desc = "Fire axes can be recognized by their head shape and high-visibility coloring. They're often used to break down doors and windows for emergency rescue teams.\n\nA lot of dollars are in distress. Go rescue them.",
	-- 50 Blessings Briefcase (NO, I WILL NOT CALL IT A BOX-SHAPED BAG)
	bm_melee_briefcase_desc = "Briefcases are narrow hard-sided cases used to carry important documents and other thin objects. They are often used in business because of their portable nature.\n\nIt's only appropriate to carry one when your entire career is in high-value financial transactions.",
	-- Swagger Stick
	bm_melee_swagger_desc = "Swagger sticks are short sticks traditionally carried as a symbol of authority. Their history can be traced as far back as Ancient Rome.\n\nAll of this will go over the head of your average cop, though. Especially when you're beating them with it.",
	-- Potato Masher
	bm_melee_model24_desc = "The Model 24 Stielhandgranate was the standard German grenade through both world wars. Its distinctive throwing handle proved to be too bulky, so it was withdrawn after World War 2.\n\nThis one's disarmed. After the first few beatings, the cops might start wishing it wasn't.",
	-- Trench Knife
	bm_melee_fairbair_desc = "A small dagger most famous for being issued to British forces in World War 2. It made a great thrusting weapon, suitable for pushing past ribs.\n\nYou know you've got something good going if you influence knife design for decades.",
	-- Spear of Freedom
	bm_melee_freedom_desc = "America is represented by many things. Freedom. Baseball. Might. Fast food. Bald eagles. Buffalos.\n\nThis flagpole.",
	-- Carpenter's Delight
	bm_melee_hammer_desc = "The claw hammer is a woodworker's best friend. A blunt side for driving nails into wood, and a forked side for pulling them back out.\n\nWhen all you have is a hammer, everything starts looking like a nail.",
	-- Clover's Shillelagh
	bm_melee_shillelagh_desc = "Shillelaghs are wooden clubs, often made of blackthorn wood. The head is sometimes filled with lead to give it extra weight.\n\nIrish tradition gave you the club. Thief tradition calls for you to hit someone with it.",
	-- Dragan Cleaver
	bm_melee_meat_cleaver_desc = "It can be hard to tell a Chinese knife apart from a cleaver. It's the cleavers that are strong enough to reliably chop bone, letting you get to the juicy bits.\n\nThe juicy bits are what interrogations are all about, right?",
	-- Motherforker
	bm_melee_fork_desc = "Forks are multi-pronged tools meant to hold or lift food. A barbecue fork has two large prongs for spearing meat, which you'll undoubtably do.\n\nIt'll do pretty nasty things to goggles if you get a good grip on it. Trust me.",
	-- Spatula
	bm_melee_spatula_desc = "Spatulas are broad flat tools used to lift foods. Their name is derived from the Latin word for a flat piece of wood, which itself is derived from the Latin word for broadsword.\n\nJust the thing for making and flipping bacon strips.",
	-- Poker
	bm_melee_poker_desc = "Fireplace pokers are used to nudge the burning materials in a fire without risk of self-injury. In their most primitive forms, they could be as old as fire itself.\n\nYou should poke someone with it.",
	-- Tenderizer
	bm_melee_tenderizer_desc = "Meat is often tenderized to make it easier to consume. Applying force to break the meat's fiber is one way to reach the desired softness.\n\nYou can also clobber someone with it. It'll scramble a few eggs, to say the least.",
	-- You're Mine
	bm_melee_branding_iron_desc = "Branding irons were used to burn marks of ownership onto livestock. Though surpassed, fire-heated irons have never fully faded.\n\nIt should be noted that striking human beings with unheated branding irons is not typical use.",
	-- Scalper Tomahawk
	bm_melee_scalper_desc = "Scalping was a Native American technique used to show dominance and skill on the battlefield. It was usually performed with knives. Usually.\n\nIt's not very popular anymore. All the more reason to bring it back.",
	-- Arkansas Toothpick
	bm_melee_bowie_desc = "The Arkansas Toothpick was created by the same man who invented the Bowie knife, with which it shares two traits. The first is that neither name carries a clear-cut definition. The second is that neither should be used as a toothpick.",
	-- Gold Fever
	bm_melee_mining_pick_desc = "Gold prospecting is the art of riches and fortune. Gold can be found by panning in rivers, mining in hills, or by simple surface examination.\n\nIt can also be found in vaults, which means you'll need some special tools for digging your way in.",
	-- Microphone
	bm_melee_microphone_desc = "Microphones convert sound into electrical signals. They allow a single person to send a message out to anyone who can hear it.\n\nSometimes, the message is \"I'm going to beat you to a pulp with this microphone.\"",
	-- Classic Baton
	bm_melee_oldbaton_desc = "The side-handle baton is a symbol of the law. It hits harder and can be wielded more variably than an expanding baton, making it a prime choice for police brutality.\n\nA little irony never hurt anyone.",
	-- Metal Detector
	bm_melee_detector_desc = "Metal detectors are used in security to detect concealed weapons. They can be used alone or with larger walk-through detectors.\n\nYou won't detect anything but balls of steel. Try keeping it somewhere besides your pants.",
	-- Microphone Stand
	bm_melee_micstand_desc = "The epitome of awkward weapons. This devious contraption will jab you with every swing and cause mild irritation to whoever you hit.\n\nAt least they'll fall over laughing at you.",
	-- Hockey Stick
	bm_melee_hockey_desc = "A hockey stick is used to handle the puck in ice hockey. Like with any other sports equipment, it has been refined into a carefully-regulated tool made for a singular purpose.\n\nWe tend to use it as a club.",
	-- Jackpot
	bm_melee_slot_lever_desc = "Well, maybe not a jackpot. But at least you won something tangible, and they kicked you out for it.\n\nYou even get to beat others over the head with your own misfortune. That's a moral victory, right?",
	-- Croupier's Rake
	bm_melee_croupier_rake_desc = "Something for raking in cash. What could possibly be more appropriate for someone in your line of work? Okay, maybe you're not the house.\n\nBut the nature of gambling means it's not just the house that can win big.",
	-- Switchblade
	bm_melee_switchblade_desc = "The only knife shorter than a knife is a switchblade. Their use by teenage street gangs made waves in the fifties.\n\nThis fine Italian stiletto is specifically banned by law. Add that to your list of crimes.",
	-- Buzzer
	bm_melee_taser_desc = "Electroshock weapons are designed to subdue via pain and muscle spasm. Prolonged shock may be dangerous to the victim, and police accountability seems to be at an all-time low.\n\nNow you've got one too. Payback's a bitch, isn't it?",
	bm_melee_taser_info = "",
	-- Empty Fist Kata
	bm_melee_fight_desc = "In martial arts, even a single strike can take on a great deal of nuance. The centuries have provided time to study each movement throughly, leading to strange new techniques.\n\nA hand provides many surfaces to use. All the better to strike with.",
	-- Talons
	bm_melee_tiger_desc = "Ninja talons were worn on the hand like claws and primarily used to inflict long wounds. Their size can also be used defensively to deflect blows.\n\nYou could seriously maul someone with these, like a very angry bear.",
	-- Kunai Knife
	bm_melee_cqc = "Poisoned Kunai",
	bm_melee_cqc_desc = "Like many ninja weapons, the kunai was both tool and weapon. Its ease of carry made it accessible when needed and concealable when not.\n\nIf that wasn't enough for you, here's a bonus: your's is tipped with vomit-inducing poison.",
	bm_melee_cqc_info = "",
	-- Okinawan Style Sai
	bm_melee_twins_desc = "Okinawan sai are often used in pairs. Okinawan police enjoyed their versatility, as they can be used in forward or reverse grip, offensively or defensively, and for puncturing or bludgeoning.\n\nThey also have a nice exotic look to them.",
	-- MOTHERFUCKING SHINSAKUTO KATANA
	bm_melee_sandsteel_desc = "A modern blade forged with traditional laborious techniques. The nearly-ritualized process creates a weapon with artistic and cultural value, making it appeal to warriors and collectors alike.\n\nIt can bisect a Cloaker. Just like my animes.",
	-- Buckler Shield
	bm_melee_buck_desc = "Though poor against projectiles, the Buckler proved useful in melee combat. A light shield could guard its wielder's arm one moment and strike with blunt force the next.\n\nJust don't try to stop bullets with it.",
	-- Bearded Axe
	bm_melee_beardy_desc = "The bearded axe was made famous by the Vikings, who raided Europe for centuries. The 'beard' provided extra cutting area and could grab at enemy gear.\n\nPerfect for the heister with an angry streak.",
	-- Morning Star
	bm_melee_morning_desc = "A mace with a spiked end, not to be confused with any ball-and-chain flails. It combined flesh-rending spikes with blunt concussive force, allowing it to smack everyone around equally.\n\nThere's nothing holy about it, but you can definitely make angels.",
	-- Great Sword
	bm_melee_great_desc = "A hefty European sword with a grip long enough for two-handed use. Though relegated to ceremonial use, four pounds of sharp steel will still slice through flesh and cloth with ease.\n\nThey'd better forget about knife-proof vests. It's cheaper to buy good running shoes.",
	-- Chain Whip
	bm_melee_road_desc = "Chains, not to be confused with the Payday Gang's enforcer, are series of connected metal links. They are distinct from ropes in their rigidity.\n\nLike Chains, however, they're dark, scary, and excellent for heavy lifting. And just like Chains, getting in the way is bad for your life expectancy.",
	-- Bolt Cutters
	bm_melee_boltcutter_desc = "Bolt cutters are the enterprising crook's skeleton key. They're perfect for removing fences and chains - a snip and a snap will get you one step closer to your payday.\n\nIt's also a chunk of forged iron with handles, so if it all goes to shit, you have a plan B.",
	-- Electrical Brass Knuckles
	bm_melee_zeus = "Electrician's Nightmare",
	bm_melee_zeus_desc = "A do-it-yourself masterpiece. A shocking display of power, if you will. They say necessity is the mother of invention, and as you can see, her children definitely aren't born with pretty faces.\n\nThis item will briefly stun anyone who sees it and not-so-briefly stun anyone dumb or misfortunate enough to touch the prongs, including you if you charge it enough.",
	-- Nail Gun
	bm_melee_nin = "The Pounder",
	bm_melee_nin_desc = "Wolf's favorite little number. A canister of flammable gas, a spark plug, and a touch of industrial might. Drives nails through wood faster than pigs go through donuts.\n\nWould you say that's on the mark? Because I'd say I nailed it.",
	-- Butterfly Knife
	-- it's no black rose, though
	bm_melee_wing = "Wing",
	bm_melee_wing_desc = "Balisongs are a type of folding pocket knife. Skilled users can perform elaborate tricks with them, showing off the kind of confident flair that separates criminals from true heisters.\n\nRemember, it's not just stage fright when you've got butterflies in your stomach.",
	-- Ballistic Knives
	bm_melee_ballistic = "Specialist Knives",
	bm_melee_ballistic_desc = "A pair of ballistic knives designed to launch their blades via the springs in their handles, extending your range by about five meters.\n\nUnfortunately, they're also broken. This leaves you at the industry-standard effective range of \"directly inside someone's face.\"",
	-- Ice Pick
	bm_melee_topaz_desc = "Ice picks have many functions. If you're scaling mountainous tombs, you need it to climb your way up. If you're infiltrating Siberian outposts, you need it to stop your falls.\n\nAnd if you run into the law, you need a good way to break the ice.",
	-- Selfie Stick
	bm_melee_selfie_desc = "Selfie sticks are usually banned from public venues because of general nuisance and safety concerns, and you happen to be both.\n\nSwinging this weapon will cause minor brain damage, both to you and whoever you hit.",
	-- Shepherd's Cane
	bm_melee_stick = "Shepherd's Crook",
	bm_melee_stick_desc = "A wise man once said, \"Speak softly, and carry a big stick.\" Good advice, no?\n\nThe 'crook' part exists to help catch and manage animals. Perhaps a different kind of crook would find a different use for it.",
	-- Diving Knife
	bm_melee_pugio = "Phorcys Diving Knife",
	bm_melee_pugio_desc = "Named after a primordial god of the sea, and for good reason. There's no finer knife for the job when you need to take a swim, push almost nine inches of stainless steel through someone's scuba gear, and get paid.",
	-- Utility Knife
	bm_melee_boxcutter = "Boxcutter",
	bm_melee_boxcutter_desc = "A utilitarian dream tool. Don't let its name fool you, the cutting potential with this puppy is endless. Boxes, paper, cloth, kevlar, skin, flesh, ribbons, the whole nine yards.\n\nNot safes, though. Sorry.",
	-- Scout Knife
	bm_melee_scoutknife = "Rusted Scout Knife",
	bm_melee_scoutknife_desc = "An outdoor knife that's presumably been outdoors for far too long. I'm sure that if it could talk, it'd have a few choice words for its previous owner.\n\nIt'll still cut things just fine, though. As a bonus, it could help you figure out who missed their tetanus shots.",
	-- Machetaxe
	bm_melee_gator = "The Alligator",
	bm_melee_gator_desc = "They say you can last three weeks without food and three days without water. If you fall into the wrong place, though, it won't be deprivation that kills you.\n\nWhen you're in the lion's den, there's only one question you need to ask. Are you the predator, or are you the prey?",
	-- Pitchfork
	bm_melee_pitchfork_desc = "Pitchforks are the weapon of angry peasants. The prongs, normally used to lift loose material, can be used to puncture organs and keep enemies at bay.\n\nOnce you're done taking down the rich, you can use this to redistribute the wealth to your liking.",
	-- Sheep Shears
	bm_melee_shawn = "Rusted Sheep Shears",
	bm_melee_shawn_desc = "The wool industry is an old one. It made the fortunes of Ancient Knossos. It built the economy of Medieval England. It even drove Australian invention.\n\nIf you give it a chance, it'll build your legacy too.",

	-- Kazaguruma
	bm_melee_ostry_desc = "Kazuguruma. Windmill. A pair of triple-edged haladie daggers, made with modern materials. A little bit of style and mysticism won't hurt. The blades will, though, so don't cut yourself.\n\nDeals 100 dmg/sec while held in front of you.",
	-- Stainless Steel Syringe
	bm_melee_fear_desc = "A special design originally invented at Mercy Hospital. It's deceptively tough to bend, can jab through thick fabric, and carries plenty of fluid to inject.\n\nNaturally, it's filled with something horribly toxic.",
	-- Kento's Tanto
	bm_melee_hauteur_desc = "A compact knife of Japanese make, concealed within a small sheathe. A blade this small is useful indoors, where a larger blade may prove inconvenient, or for ritual suicide.\n\nWas it a keepsake? A gift? Who knows? Its former owner can no longer tell.",
	-- Monkey Wrench
	bm_melee_shock = "Pipe Wrench",
	bm_melee_shock_desc = "An adjustable wrench with hard serrated teeth to tightly grip softer metal. It is designed so that pressure on the handle pulls the jaws tighter, increasing grip without binding the tool to the pipe it works on.\n\nThough many are made with aluminum bodies, the jaws of the wrench have remained good heavy steel.",
	-- El Verdugo
	bm_melee_agave_desc = "Not something to be taken lightly, especially when in the hands of someone familiar enough with it to spin it about, swinging it from one direction to another as if it were his own hand.\n\nWhen intimidation isn't enough, there's always the obvious alternative.",
	-- Push Dagger
	bm_melee_push_desc = "Trench warfare created a need for close-combat weapons, leading to a variety of creations both improvised and manufactured. Where a wide swing of a blade may catch, the push dagger passes with flying colors.\n\nThe motion is simple and intuitive. Think of the guy who beat you up once, and imagine punching his jaw clean off.",
	-- Leather Sap
	bm_melee_sap_desc = "A gentleman's weapon. Though out of fashion and rather inconspicuous, the lead weight at the end lends it a nasty punch that can surprise even more than it stuns.\n\nIt's unbecoming of a gentleman to lose his temper, but we are merely human, and so is whoever's getting clobbered.",
	-- Tactical Flashlight
	bm_melee_aziz_desc = "An LED flashlight with a knurled body for maximum grip. Provides a couple hundred lumen and a decent bludgeoning tool. Given that you can simply attach a light to your gun, you're just doing this to laugh at the guards, aren't you?\n\nI must say, people's strange habits are quite illuminating.",
	-- Hackaton
	bm_melee_happy_desc = "Hacking is a game of cleverness and obscurity. Vulnerabilities are ruthlessly exploited and system turned against system in an expensive game of cat and mouse. But sometimes, there isn't a security hole that any amount of code can exploit.\n\nSometimes, you just need to break something. Or someone.",
	-- Lumber Lite L2 chainsaw
	bm_melee_cs_desc = "Chainsaws are rarely efficient in a fight. They're cumbersome, heavy, and come with little things like safety features and maintenance.\n\nThat said, the sound of one next to your ear will raise your hair so well that you could get a free haircut out of the whole ordeal.\n\nDeals 125 dmg/sec while held in front of you.",
	-- Alabama Razor
	bm_melee_clean_desc = "Straight razors were invented in 1680, becoming the prime method of shaving for over two centuries. They've been on the decline since the late 19th century, when idiot-proof razors began to appear.\n\nA skilled hand has little to fear from it. Those who stand in your way might.",
	-- Hotline 8000x
	bm_melee_brick_desc = "The height of 80's technology, in the palm of your hand. A Motorola phone, priced at nearly $4000 - over $9000 today. And what do you get for it? Nothing now, because nobody operates analog network cells anymore.\n\nIt's a bricked brick phone. You can use it like a brick.",
	-- Hook
	bm_melee_catch_desc = "Hook.", -- don't fuck with it, it's perfect
	-- Rezkoye
	bm_melee_oxide_desc = "A spetsnaz survival machete. It hammers, it chops, it cuts, it pries, it saws, it pummels, and it even acts as a ruler and protractor. What can't it do?\n\nBe balanced and remotely comfortable to use, apparently. Russians never tell you about the downsides until you've already bought the thing.",
	-- Knuckle Daggers
	bm_melee_grip_desc = "A pair of knuckle dusters, combining a knife with an English punch. Weapons like these were a necessity when the enemy was right on top of you, too close to bring your rifle to bear.\n\nConsidering the force that the cops will bring to bear, you might as well dig in.",
	-- A Fucking Pencil
	bm_melee_sword = "A Fucking Pencil",
	bm_melee_sword_desc = "Not afraid? You should be. John Wick killed three people with a pencil. A fucking pencil. He wasn't even a pencil specialist, it was just handy at the time.\n\nI suppose there are worse ways to write your name into history.",
	-- Great Ruler
	bm_melee_meter_desc = "An impressively rigid measurement tool. It's too expensive (and sharp) to properly use for its ostensible purpose, as if it were meant for cutting things down to size.",


	-- THROWABLES
	bm_grenade_frag_desc = "The frag grenade is an old concept: a thrown casing that explodes, launching fragments that slice through flesh. They are typically used to soften and 'gently dissuade' clusters of enemies, a task at which they excel.\n\nCapacity: 3\nDamage: 600\nBlast Radius: 5m",
	bm_grenade_frag_com_desc = "A custom-manufactured gift from our Swedish contacts to make up for lost time. It's the classic pin-pulling room-clearing action that you know and love, except for free. I'm sure the cops won't mind if you pass the generosity on to them.\n\nCapacity: 3\nDamage: 600\nBlast Radius: 5m",
	bm_dynamite_desc = "Alfred Nobel created dynamite as a safer alternative to explosives such as black powder or nitroglycerin. Although created to blast rock, it is unsurprising that a strong and controllable explosive also has military applications.\n\nCapacity: 3\nDamage: 600\nBlast Radius: 5m",
	bm_concussion = "Stun Grenade",
	bm_concussion_desc = "SWAT's stunning little beauty. Perfectly designed to destroy your target's sense of balance and vision, leaving everything else unfortunately intact. So the old saying goes, it's not the flash that kills you but the sudden burst of gunfire at the end.\n\nCapacity: 6\nDamage: 0\nFlash Radius: 15m",
	bm_grenade_molotov_desc = "The Molotov cocktail is a very simple and iconic weapon. As little more than a bottle of flammable fluid with a rag for a fuse, it is easily created by the ill-equipped groups it is often associated with. Excellent for holding back the tide.\n\nCapacity: 3\nDamage inside fire: 50 every 0.5s\nFire Duration: 6 seconds",
	bm_wpn_prj_ace_desc = "Throwing cards are generally associated with magicians splitting watermelons across a stage, but add some weight and razor edges and you have a silent killer. The best part is we've got a guy making these by the thousands, so everyone gets a half-deck for free.\n\nCapacity: 26\nDamage: 110\nThrow Rate: 3/s",
	bm_wpn_prj_four_desc = "Though \"shuriken\" literally translates to \"sword hidden in user's hand\", they were historically used to inflict light wounds and transfer poison rather than directly kill. These, on the other hand, will chop right through helmets and induce sudden vomiting and nausea.\n\nCapacity: 9\nDamage: 60 + 200 over 5 seconds\nThrow Rate: 2/s",
	bm_wpn_prj_target_desc = "A silent and elegant killer. Many engineering hours went into to finding the perfect weight distribution, maximizing the chance of a point-first impact, and enhancing damage. All that's missing is the perfect thrower.\n\nCapacity: 9\nDamage: 220\nThrow Rate: 2/s",
	bm_wpn_prj_hur_desc = "A weapon once used by the Franks, now brought to the modern ages. Ostensibly for sporting purposes, biker gangs began buying these en masse when it turned out a big throwable blade was exactly what they needed for a little 'peace of mind' on the highways.\n\nCapacity: 6\nDamage: 400\nThrow Rate: 2/s",
	bm_wpn_prj_jav_desc = "It's older than Neanderthals, but hand-thrown spears remain as simple as they are deadly. The skill required to wield such a weapon is made worthwhile by the fact you're throwing a whole kilogram of pain at someone.\n\nCapacity: 3\nDamage: 1500\nThrow Rate: 0.66/s",
	bm_grenade_dada_com_desc = "Matryoshka dolls come as a set, opening up to reveal innards hiding innards. In this case, the outer-most doll is a fragmentation jacket and the inner-most doll is a violent explosion.\n\nCapacity: 3\nDamage: 600\nBlast Radius: 5m",
	bm_grenade_fir_com_desc = "Grenade with thermate filler, a composition that burns hot enough to melt through car engines. Works underwater, and sure as hell works on human flesh and kevlar fibers.\n\nCapacity: 6\nDamage: 150/sec for 2 sec\nBlast Radius: 5m",








	-- CUSTOM WEAPONS
	-- SR-3M Vikhr
	-- https://modworkshop.net/mydownloads.php?action=view_down&did=17333
	bm_w_sr3m_desc = "Compact rifle used by special forces and high-security details. Though it fires the same rounds as its predecessor, the integral suppressor has been omitted to reduce length.",


	-- CZ-75 Shadow
	bm_w_cz_desc = "An accurate and reliable choice for handgun connoisseurs. The Shadow is a modernized variant of the original 'Wonder Nine', meeting the bar for competitive use.",
	bm_w_x_cz_desc = "Equipment sells itself more readily than training, but when the chips are down, it's not the equipment that will lead you to the right decisions.",
	bm_wp_wpn_fps_pis_cz_sil_desc = "Those points intimidate the air into compliance.",
	bm_wp_wpn_fps_pis_cz_smallsil_desc = "As opposed to a hearing protection suppressor." .. silstr,
	bm_wp_wpn_fps_pis_cz_m_ext_desc = "Fifteen rounds isn't enough for sixteen targets." .. silstr,
	bm_wp_wpn_fps_pis_cz_comp_desc = "Very special. Or not, but don't say that to its face.",
	bm_wp_wpn_fps_pis_cz_g_bling_desc = "Forget the silver spoons. Being born with a silver gun in your hand is where it's at.",
	bm_wp_wpn_fps_pis_cz_g_wood_desc = "Some things never go out of style.",
	bm_wp_wpn_fps_pis_cz_b_silver_desc = "Never settle for only one color.",


	-- M2HB MA DEUCE
	bm_w_m2hb_desc = "The old Ma Deuce. A survivor from an era when new cartridges grew on trees and American guns weren't all clones of each other. Hits just as hard now as she did back then.",


	-- MATEBA 6 UNICA
	bm_w_unica6_desc = "A rare semi-automatic revolver. When fired, the entire upper assembly slides backwards to recock the hammer. It's not often you see a weapon more unusual than its wielder.",
	bm_wp_wpn_fps_upg_unica6_comp_desc = "Let not the tool substitute for the skill and determination of the man who wields it.",


	-- CONTENDER SPECIAL
	bm_w_contender_desc = "A single-shot rifle/pistol originally chambered for small-caliber rounds. As higher-powered rounds gained popularity, so did the Contender for its ability to easily accept them.\n\nPenetrates shields and receives sniper rifle bonuses.",
	bm_wp_wpn_fps_special_contender_ammo_AP = ".30-06 Springfield",
	bm_wp_wpn_fps_special_contender_ammo_AP_desc = "A classic. Widely produced and more than enough to bag anything but the biggest game.",
	bm_wp_wpn_fps_special_contender_ammo_22lr = ".30-30 Winchester",
	bm_wp_wpn_fps_special_contender_ammo_22lr_desc = "The minimum bar to clear if you want to go big game hunting.\n\nNo shield penetration.",
	bm_wp_wpn_fps_special_contender_ammo_410bore = ".410 Shotshell",
	bm_wp_wpn_fps_special_contender_ammo_410bore_desc = "Not legal in California. What a shame.",
	bm_wp_wpn_fps_special_contender_o_scope = "ACOS-G Optical Sight",
	bm_wp_wpn_fps_special_contender_o_scope_desc = "Telescopic sight with tritium and light pipe illumination developed for the US Army.\n\nZoom level 5.",
	bm_wp_wpn_fps_special_contender_ns_silencer_desc = "Don't ask how it works. It just does.",
	-- real chamberings: .223 remington, .44 magnum, .45/70 govt
	-- game chamberings: .30-30, 6.8mm, .30-06


	-- M1 Carbine
	bm_w_m1c_desc = "US Army carbine during World War 2. A light weapon produced at half the cost of an M1 Garand for support personnel and paratrooper use. Due to concerns over its gas system, it was an early adopter of non-corrosive primers.",
	bm_wp_wpn_fps_ass_m1c_rail = "Railed Cover",
	bm_wp_wpn_fps_ass_m1c_rail_desc = "Bet you're not even going to put anything on it.",
	-- veteran stock
	bm_wp_wpn_fps_ass_m1c_body_black_desc = "It's for nighttime work, I swear.",
	-- funnel compensator
	bm_wp_wpn_fps_ass_m1c_comp = "Flash Hider", -- t23
	bm_wp_wpn_fps_ass_m1c_comp_desc = "It won't hide the noise.",


	-- SVT-40
	bm_w_svt40_desc = "The Red Army's new service rifle, until World War 2 disrupted its production. Despite Stalin's interest in semi-automatic rifles, quality issues and maintenance difficulties pushed it aside in favor of SMGs and the venerable Mosin-Nagant.",
	bm_wp_wpn_fps_upg_svt40_muzzle_brake_upg_desc = "You can tell it's better by counting the number of slats.",
	bm_wp_wpn_fps_upg_svt40_suppressor_desc = "Not everyone can handle dissent in a calm and collected manner. Fewer still can handle it with a whisper." .. silstr3,
	bm_wp_wpn_fps_upg_svt40_pu_scope = "PU Scope w/Backup Ironsights",
	bm_wp_wpn_fps_upg_svt40_pu_scope_desc = "Fixed-magnification scope, adjustable for range and windage.\n\nZoom level 5. Toggle backup sight by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_svt40_stock_finish_snow2_desc = "Apologize to the Finnish.",
	bm_wp_wpn_fps_upg_svt40_stock_spetzjungle3 = "Bringing back the 40s, one corpse at a time.",

	-- AN-94
	bm_w_akrocket_desc = "Advanced assault rifle capable of firing 1800 RPM two-shot bursts. The modernized version introduces modularity, increasing versatility for the few units equipped with such an expensive rifle.",
	bm_wp_wpn_fps_ass_akrocket_b_long_desc = "Extended barrel without front sight post.",
	bm_wp_wpn_fps_ass_akrocket_b_heavy_desc = "Barrel with gratuitously enlarged muzzle device.",
	bm_wp_wpn_fps_ass_akrocket_ns_sil_desc = "Suppressor specially designed to fit the muzzle device.",
	bm_wp_wpn_fps_ass_akrocket_fg_modern_desc = "Modern wood may be comprised of various non-wood materials.",
	bm_wp_wpn_fps_ass_akrocket_g_mod_desc = "Dark grip designed to more-closely match the shape of the human hand.",
	bm_wp_wpn_fps_ass_akrocket_m_fast = "Dual Magazine",
	bm_wp_wpn_fps_ass_akrocket_m_fast_desc = "Sometimes, even slavs are too good for tape.",
	bm_wp_wpn_fps_ass_akrocket_m_extended = "Dark Magazine",
	bm_wp_wpn_fps_ass_akrocket_m_extended_desc = "All magazines are equal, but some are more equal than others.",
	bm_wp_wpn_fps_ass_akrocket_m_fastext = "Double Dark Magazine",
	bm_wp_wpn_fps_ass_akrocket_m_fastext_desc = "Two for the price of one.",
	bm_wp_wpn_fps_ass_akrocket_s_adjusted_desc = "There's beauty in ugliness, and then there's just being plain ugly.",

	-- AN-92
	bm_w_tilt_desc = "A prototype stolen from the heart of Russia. Although it bears a few differences to the final product, the distinguishing 1800 RPM two-shot burst is still present.",
	bm_wp_wpn_fps_ass_tilt_bayonet = "Ornamental Bayonet",
	bm_wp_wpn_fps_ass_tilt_bayonet_desc = "Real intimidating, there.",
	bm_wp_wpn_fps_ass_tilt_a_fuerte = "7.62x39mm Ammunition",
	bm_wp_wpn_fps_ass_tilt_a_fuerte_desc = "I mean, if you want to screw with a priceless historical relic that badly.\n\n-33% scavenge",
	bm_wp_wpn_fps_ass_tilt_mag_big_desc = "Try not to fire it all in once place.",
	bm_wp_wpn_fps_ass_tilt_g_wood_desc = "A wood grip with some decent worksmanship, for once.",
	bm_wp_wpn_fps_ass_tilt_mag_swift = "Prototype Magazine",
	bm_wp_wpn_fps_ass_tilt_mag_swift_desc = "I'm sure someone will call you out on it eventually.",
	bm_wp_wpn_fps_ass_tilt_mag_tactical_desc = "Interim magazine used in the modernization program.",
	bm_wp_wpn_fps_ass_tilt_stock_none_desc = "Feels like nothing at all.",
	bm_wp_wpn_fps_ass_tilt_stock_fold_desc = "Not to say that the usual stock doesn't fold.",
	bm_wp_wpn_fps_ass_tilt_stock_wood_desc = "Can't go wrong with wood, for the most part.",


	-- Makarov
	bm_w_pm_desc = "Soviet post-WW2 pistol. Its simplicity and reliability led to it being produced nearly-unchanged for decades, with most efforts focused on improved production rather than performance.",
	bm_w_x_pm_desc = "What isn't broken may yet be fixed. It may be revolution that brings about change, but it is evolution that brings about progress.",
	bm_w_xs_pm_desc = "What isn't broken may yet be fixed. It may be revolution that brings about change, but it is evolution that brings about progress.",
	bm_wp_wpn_fps_pis_pm_m_custom_desc = "Double-column Makarov M magazine.",
	bm_wp_wpn_fps_pis_pm_m_extended_desc = "Extended single-column magazine.",
	bm_wp_wpn_fps_pis_pm_m_drum_desc = "There's a point where we should have stopped, and we passed it long ago.\n\n+88% ammo scavenge.",
	bm_wp_wpn_fps_pis_pm_fi_re_desc = "Applies to original non-modernized Makarovs only.",
	bm_wp_wpn_fps_pis_pm_fi_steel_desc = "Applies to original non-modernized Makarovs only.",
	bm_wp_wpn_fps_pis_pm_body_custom_desc = "Modern-production frame and less-phallic grips.",
	bm_wp_wpn_fps_pis_pm_b_custom_desc = "Modern-production slide with minor improvements.",


	-- remington various parts
	bm_wp_wpn_fps_shot_870_fg_vertical_desc = "Something familiar, yet foreign.",
	bm_wp_wpn_fps_shot_870_fg_surefire = "Flashlight Forend",
	bm_wp_wpn_fps_shot_870_fg_surefire_desc = "Pump with integrated flashlight.\n\nToggle flashlight by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_shot_870_rail_mcs_desc = "The M stands for modular.",
	bm_wp_wpn_fps_shot_870_rail_aftermarket_desc = "A short rail, enough for a sight of some description.",
	bm_wp_wpn_fps_shot_mossberg_b_heat = "Heat-Shielded Barrel",
	bm_wp_wpn_fps_shot_mossberg_b_heat_desc = "Allows heat to vent without letting your hands touch the barrel.",
	bm_wp_wpn_fps_shot_mossberg_o_heat = "Shielded Ghost Ring Sight",
	bm_wp_wpn_fps_shot_mossberg_o_heat_desc = "Not as spooky as it sounds.",
	-- synthetic pump
	bm_wp_wpn_fps_shot_mossberg_fg_pump_desc = "Simple and effective.",
	bm_wp_wpn_fps_shot_mossberg_s_grip = "Semi-Grip Stock",
	bm_wp_wpn_fps_shot_mossberg_s_grip_desc = "Going hunting?",
	bm_wp_wpn_fps_shot_r870_fg_hdtf = "HDTF Forend",
	bm_wp_wpn_fps_shot_r870_fg_hdtf_desc = "We don't talk about HDTF around here.",
	bm_wp_wpn_fps_shot_r870_s_hdtf = "HDTF Stock",
	bm_wp_wpn_fps_shot_r870_s_hdtf_desc = "We don't talk about HDTF around here.",
	bm_wp_wpn_fps_shot_870_fg_rail_desc = "A truly gratuitous amount of rail estate.",
	-- forend strap
	bm_wp_wpn_fps_shot_mossberg_fg_short_desc = "Just in case it tries to fly out of your hand, which will probably happen after every shot.",


	-- Winchester Model 1912
	bm_w_m1912_desc = "High-quality pump-action shotgun based on the work of the legendary John Moses Browning. A classic that only fell when its competition became too cheap to compete with.",
	bm_wp_wpn_fps_upg_m1912_barrel_field_desc = "When the slightest noise can set you back hours, you can't afford to put anything less than perfection into your first shot.",
	bm_wp_wpn_fps_upg_m1912_barrel_riot_desc = "Five shells can put down a lot of problems in a hurry.",
	bm_wp_wpn_fps_upg_m1912_forend_field_desc = "Going hunting?",
	bm_wp_wpn_fps_upg_m1912_heat_shield = "Trench Kit",
	bm_wp_wpn_fps_upg_m1912_heat_shield_desc = "Heat shield and bayonet lug. Guaranteed to start an incident, even if only because you didn't bring the bayonet.",
	bm_wp_wpn_fps_upg_m1912_ns_cutts = "Cutts Compensator",
	bm_wp_wpn_fps_upg_m1912_ns_cutts_desc = "Noisy, but results are results.",
	bm_wp_wpn_fps_upg_m1912_ns_duckbill_desc = "A bunch of ducks at rest aren't just going to arrange themselves in a nice circular pattern for you.\n\nFlattens the shot pattern.",
	bm_wp_wpn_fps_upg_m1912_stock_cheekrest_desc = "Stock with cheek rest and checking to help you line up your shot just right.",
	bm_wp_wpn_fps_upg_m1912_stock_cheekrest_pad_desc = "Get nice and comfortable.",
	bm_wp_wpn_fps_upg_m1912_stock_pad_desc = "Takes a bit of the bite out of one end of the gun.",
	bm_wp_wpn_fps_upg_m1912_stock_sawnoff_desc = "Not that the length goes down by much, but still.",


	-- KS-23
	bm_w_ks23_desc = "Riot shotgun made with rejected 23mm anti-aircraft gun barrels. Although firing large shotgun ammunition, it is officially classified as a carbine.",
	bm_wp_wpn_fps_upg_ks23_ammo_buckshot_8pellet = "SHRAPNEL-25",
	bm_wp_wpn_fps_upg_ks23_ammo_buckshot_8pellet_desc = "Buckshot with effective range of 25 meters.\n\nLowers pellet count from 10 to 8. Increases falloff ranges to 25m/60m. Reduces ammo scavenge rate.",
	bm_wp_wpn_fps_upg_ks23_ammo_buckshot_20pellet = "SHRAPNEL-10",
	bm_wp_wpn_fps_upg_ks23_ammo_buckshot_20pellet_desc = "Buckshot with effective range of 10 meters.\n\nIncreases pellet count from 10 to 20. Reduces falloff ranges to 10m/30m.",
	bm_wp_wpn_fps_upg_ks23_ammo_slug_desc = "Powerful steel slug.\n\nPierces shields. Removes damage falloff.",
	bm_wp_wpn_fps_upg_ks23_barrel_short = "Short Barrel",
	bm_wp_wpn_fps_upg_ks23_barrel_short_desc = "Shortened barrel from the modernized variant.",
	bm_wp_wpn_fps_upg_ks23_stock_pistolgrip = "Pistol Grip",
	bm_wp_wpn_fps_upg_ks23_stock_pistolgrip_desc = "Pistol grip from the modernized variant.",
	bm_wp_wpn_fps_upg_ks23_stock_pistolgrip_wire = "Pistol Grip and Wire Stock",
	bm_wp_wpn_fps_upg_ks23_stock_pistolgrip_wire_desc = "Pistol grip with wire stock. Lets you pretend to have some semblence of control.",

	-- Marlin Model 1894 Custom
	bm_w_m1894_desc = "A cut-down and heavily customized lever action rifle. Compared to its immediate predecessor, it features a stronger lever mechanism and greater safety.",
	bm_wp_wpn_fps_upg_m1894_irons_desc = "It was good enough back then.",
	bm_wp_wpn_fps_upg_m1894_supp_gemtech_gm45_desc = "Quick to clean. Not-so-quick to wear out." .. silstr3,
	bm_wp_wpn_fps_upg_m1894_supp_osprey_desc = "It's all fun and games until you lay your big black can on the table." .. silstr3,
	bm_wp_wpn_fps_upg_m1894_gadgets_toprail_desc = "As long as you're not using ironsights or the big scope.",

	-- primary SVU
	bm_w_svudragunov_desc = "A bullpup variant of the SVD. Spawned from a minor modernization program that expanded into a reconfiguration of the weapon. Unlike standard production models, the Tikhar variant is equipped with a functional suppressor.",

	-- secondary SVU
	bm_w_svu_desc = "A bullpup variant of the SVD. Spawned from a minor modernization program that expanded into a reconfiguration of the weapon. Its flash hider/muzzle brake is sometimes mistaken for a silencer.",
	bm_wp_wpn_fps_upg_svu_dtk2 = "DTK-2",
	bm_wp_wpn_fps_upg_svu_dtk2_desc = "Flash hider designed for use on Russian weapons.",
	bm_wp_wpn_fps_upg_svu_grip_camo_desc = "Few things you meet in those particular woods can truly be considered friendly.",
	bm_wp_wpn_fps_upg_svu_handguard_camo_desc = "Few things you meet in those particular woods can truly be considered friendly.",
	bm_wp_wpn_fps_upg_svu_grip_plastic_desc = "Not made by Mattel.",
	bm_wp_wpn_fps_upg_svu_handguard_plastic_desc = "Not made by Mattel.",
	bm_wp_wpn_fps_upg_svu_irons_desc = "Not everything will give you the luxury of distance.",
	bm_wp_wpn_fps_upg_svu_leupold_pro = "DeltaPoint Sight",
	bm_wp_wpn_fps_upg_svu_leupold_pro_desc = "You wouldn't want your sights to weigh you down, would you?",
	bm_wp_wpn_fps_upg_svu_bipod_desc = "Just to keep up appearances.",
	bm_wp_wpn_fps_upg_svu_supp_pbs1_desc = "Otherwise known as a reserved Russian greeting." .. silstr3,

	-- gewehr 43
	bm_w_g43_desc = "German semi-automatic rifle. Plagued by development hell almost entirely produced by crippling design requirements, which were increasingly ignored over time.",
	bm_wp_wpn_fps_snp_g43_irons_desc = "If your grandfather could do it, so can you.",
	bm_wp_wpn_fps_snp_g43_clothwrap_desc = "A lot of things in this world need to be warmed up.",
	bm_wp_wpn_fps_snp_g43_worn_desc = "Some things age like fine wine, but nothing ages like notoriety.",
	bm_wp_wpn_fps_snp_g43_zf4_desc = "Scope never made in the numbers that the Third Reich wanted, nor in the expected quality once the factories took a few bombs.\n\nZoom level 7.",
	bm_wp_wpn_fps_snp_g43_zf4_switch = "ZF4 Scope w/Backup Ironsights",
	bm_wp_wpn_fps_snp_g43_zf4_switch_desc = "Scope never made in the numbers that the Third Reich wanted, nor in the expected quality once the factories took a few bombs.\n\nZoom level 7. Toggle backup sight by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_snp_g43_silencer = "Silent Night",
	bm_wp_wpn_fps_snp_g43_silencer_desc = "All is calm. All is bright." .. silstr3,
	bm_wp_wpn_fps_snp_g43_a_no_ap = "K-Bullet",
	bm_wp_wpn_fps_snp_g43_a_no_ap_desc = "Steel armor piercing bullet, made to penetrate the first tanks.\n\n-40% ammo scavenge.",

	-- primary mosin-nagant stock
	bm_wp_wpn_fps_snp_mosin_b_obrez_desc = "If you can't find a concealable handgun, just make your own.",
	bm_wp_wpn_fps_snp_mosin_body_obrez_desc = "If you can't find a concealable handgun, just make your own.",

	-- secondary obrez
	bm_w_obrez_desc = "When a Russian bolt-action rifle meets a hacksaw. Used as a concealable option when nothing small enough is strong enough.",
	bm_wp_wpn_fps_upg_obrez_ns_svt40_brake = "Tokarev Muzzle Brake",
	bm_wp_wpn_fps_upg_obrez_ns_svt40_brake_desc = "Taken right off of the semi-automatic rifle.",
	bm_wp_wpn_fps_upg_obrez_ns_supp = "Mitin Suppressor",
	bm_wp_wpn_fps_upg_obrez_ns_supp_desc = "Bring them to their ultimate fate.",

	-- browning automatic rifle
	bm_w_bar_desc = "A beast of a gun fitting somewhere between machine gun and rifle. Light enough for a single man to move, but heavy enough to fire .30-06 on full auto without flying out of your hand.",
	bm_wp_wpn_fps_ass_bar_b_para_desc = "A custom cut-down job.",
	bm_wp_wpn_fps_ass_bar_g_monitor_desc = "A particular item offered to the cops back in the day.",
	bm_wp_wpn_fps_ass_bar_fg_sleeve = "Original Handguard",
	bm_wp_wpn_fps_ass_bar_fg_sleeve_desc = "Predates its more-recognizable successor by a couple decades.",
	bm_wp_wpn_fps_ass_bar_bipod = "A2 Bipod",
	bm_wp_wpn_fps_ass_bar_bipod_desc = "Skid-footed bipod mounted on later-model BARs.\n\n" .. bipodstr,
	bm_wp_wpn_fps_ass_bar_carryhandle_desc = "A late-war addition. For your use cases, it's more of a fashion statement than a utilitarian choice.",
	bm_wp_wpn_fps_ass_bar_m_extended_desc = "An experimental magazine developed for dual-BAR anti-aircraft mounts. One wonders why that concept didn't work out.",
	bm_wp_wpn_fps_ass_bar_ns_cutts = "Cutts Compensator",
	bm_wp_wpn_fps_ass_bar_ns_cutts_desc = "Noisy, but results are results.",


	-- QBZ-97B
	bm_w_qbz97b_desc = "Chinese carbine modified to fire 5.56x45mm NATO for export. Similar in most respects to the QBZ-95B, its native variant. Little real combat data is available.",
	bm_wp_wpn_fps_ass_qbz97b_mag_short_desc = "A nearly flat-bottomed 20-round magazine.",
	bm_wp_wpn_fps_ass_qbz97b_mag_pmag_desc = "Polymer magazine. Hopefully not made in china.",
	bm_wp_wpn_fps_ass_qbz97b_mag_magpul_desc = speedpulldesc,
	bm_wp_wpn_fps_ass_qbz97b_95b_body_desc = "Military-issue carbine firing proprietary Chinese rounds. Primarily issued within the Navy.",

	-- seburo m5
	bm_w_seburo_desc = "Compact handgun firing small high-velocity Russian ammunition. Primarily sold to governmental and law enforcement agencies.",
	bm_w_x_seburo_desc = "What makes us human? How much can you take away before no humanity remains?",
	bm_wp_wpn_fps_pis_seburo_g_wood_desc = "Some things never go completely out of style.",
	bm_wp_wpn_fps_pis_seburo_f_silver_desc = "Put on your tactical two-tone.",
	bm_wp_wpn_fps_pis_seburo_s_silver_desc = "Shiny, just like everything in the future ought to be.",
	bm_wp_wpn_fps_pis_seburo_m_extended_desc = "Turns concealed carry into just plain carry.",
	bm_wp_wpn_fps_pis_seburo_s_s9_desc = "No information about this is publicly available.",
	bm_wp_wpn_fps_pis_seburo_g_s9_desc = "No information about this is publicly available.",

	-- G11
	bm_w_temple_desc = "Unusual rifle firing caseless ammunition at controlled or hyperburst rates. Underwent a protracted development, after which the rifle failed to be adopted due to costs, politics, and other considerations.",
	bm_wp_wpn_fps_upg_temple_i_matthewreilly_desc = "Post-cancellation rapid-fire technology. Disables hyperburst.",

	-- Beretta 93R
	bm_w_b93r_desc = "Burst-capable pistol designed for use where both size and firepower are important. Its burst mode fires three rounds at 1100 RPM to bridge the gap between semi and full auto.",
	bm_wp_wpn_fps_upg_b93r_comp_93r = "Raffica Brake",
	bm_wp_wpn_fps_upg_b93r_comp_93r_desc = "Production-model muzzle brake.",
	bm_wp_wpn_fps_upg_b93r_comp_long_desc = "You know you like it that way.",
	bm_wp_wpn_fps_upg_b93r_flash_desc = "Not everyone appreciates a blinding fireball close to their face.",
	bm_wp_wpn_fps_upg_b93r_grip_plastic_desc = "Black polymer picks up where wood left off.",
	bm_wp_wpn_fps_upg_b93r_leupold_pro_desc = "Small, light, and durable.",
	bm_wp_wpn_fps_upg_b93r_ncstar_4_desc = "The model 4. Batteries not included.",
	bm_wp_wpn_fps_upg_b93r_sight_tritium_desc = "Shooting people at night works better when you can see what you're aiming with.",
	bm_wp_wpn_fps_upg_b93r_slide_stainless_desc = "Calling it 'inox' sounds cooler.",
	bm_wp_wpn_fps_upg_b93r_vertgrip_folded_desc = "Just hold on tight.",
	bm_wp_wpn_fps_upg_b93r_vertgrip_rail_desc = "Necessary if you enjoy using gadgets.",

	-- TOZ-34
	bm_w_toz34_desc = "An over-under shotgun especially popular with amateur 'hunters' in Ukraine. Its greatest advantage over shotguns used by more-experienced 'hunters' is its range and power.",
	bm_wp_wpn_fps_upg_toz34_ammo_000_magnum = "Magnum Triple-Ought Buck",
	bm_wp_wpn_fps_upg_toz34_ammo_000_magnum_desc = "Fires fewer and larger pellets from elongated shells.\n\nFires 8 pellets instead of 10. -20% range. -20% ammo scavenge.",
	bm_wp_wpn_fps_upg_toz34_barrel_short_desc = "When forced to fight within arm's length, it helps to have a shorter arm.",
	bm_wp_wpn_fps_upg_toz34_choke = "Lamprey Choke",
	bm_wp_wpn_fps_upg_toz34_choke_desc = "Press it right up to your target.",
	bm_wp_wpn_fps_upg_toz34_choke_modified = "Modified Choke",
	bm_wp_wpn_fps_upg_toz34_choke_modified_desc = "Modified from what, Gage won't say.",
	bm_wp_wpn_fps_upg_toz34_duckbill_desc = "A bunch of ducks at rest aren't just going to arrange themselves in a nice circular pattern for you.\n\nFlattens the shot pattern.",
	bm_wp_wpn_fps_upg_toz34_stock_short_desc = "Calling this a stock is being charitable.",

	-- MEUSOC grip
	bm_wp_wpn_fps_pis_1911_g_pachmayr_desc = "The USMC has their own particular way of doing things.",

	-- TOZ-66
	bm_w_toz66_desc = "A sawed-off hunting shotgun. Favorited by those of ill-repute due to its high power, low size, and excellent intimidation.",
	bm_wp_wpn_fps_upg_toz66_ammo_000_magnum = "Magnum Triple-Ought Buck",
	bm_wp_wpn_fps_upg_toz66_ammo_000_magnum_desc = "Fires fewer and larger pellets from elongated shells.\n\nFires 8 pellets instead of 10. -20% range. -20% ammo scavenge.",
	bm_wp_wpn_fps_upg_toz66_choke = "Lamprey Choke",
	bm_wp_wpn_fps_upg_toz66_choke_desc = "Press it right up to your target.",
	bm_wp_wpn_fps_upg_toz66_choke_modified = "Modified Choke",
	bm_wp_wpn_fps_upg_toz66_choke_modified_desc = "Modified from what, Gage won't say.",
	bm_wp_wpn_fps_upg_toz66_duckbill_desc = "A bunch of ducks at rest aren't just going to arrange themselves in a nice circular pattern for you.\n\nFlattens the shot pattern.",

	-- akimbo toz-66
	bm_w_x_toz66_desc = "When entertainment turns into a surreal reflection of your life, you're a lucky man if you can laugh at the joke.", -- "the shit i say", by max payne

	-- PU scope
	bm_wp_wpn_fps_snp_mosin_pu_scope_desc = "Fixed-magnification scope, adjustable for range and windage.\n\nZoom level 8. Toggle backup sight by pressing $BTN_GADGET.",

	-- Magpul PDR
	bm_w_pdr_desc = "Prototype PDW firing 5.56x45mm NATO to maintain ammo commonality with standard rifles while offering comapct medium-range firepower. Although cancelled, the concept and futuristic aesthetic continue to live on.",
	bm_wp_wpn_fps_smg_pdr_body_green_desc = "Don't get caught on the trees.",
	bm_wp_wpn_fps_smg_pdr_body_tan_desc = "Mind the dust.",
	bm_wp_wpn_fps_smg_pdr_body_white_desc = "Here comes the snow.",
	-- swift mag
	bm_wp_wpn_fps_smg_pdr_m_pmag = "Waffle Mag",
	bm_wp_wpn_fps_smg_pdr_m_pmag_desc = "Another product from the company that produced the prototype.",
	bm_wp_wpn_fps_smg_pdr_m_short_desc = "Every ounce counts.",
	bm_wp_wpn_fps_smg_pdr_o_new_desc = "A little bit of extra height.",

	-- AUG A3 9MM XS
	bm_w_aug9mm_desc = "Rifle-to-SMG conversion intended for law enforcement groups requiring accurate yet compact firepower. ",
	bm_wp_wpn_fps_upg_aug9mm_barrel_long_desc = "Little Para wants to be a big boy too, I see.",
	bm_wp_wpn_fps_upg_aug9mm_barrel_medium_desc = "A little bit of extra length can go a long way.",
	bm_wp_wpn_fps_upg_aug9mm_body_olive_desc = "When gray is not an option.",
	bm_wp_wpn_fps_upg_aug9mm_body_tan_desc = "Automatic fire is not a valid form of sandblasting.",
	bm_wp_wpn_fps_upg_aug9mm_gadgets_leftrail_desc = "Makes it easier to wipe the blood off.",
	bm_wp_wpn_fps_upg_aug9mm_mag_ext_desc = "You can never have enough 9mm.",
	bm_wp_wpn_fps_upg_aug9mm_troy_iron_desc = "Don't get caught flipping them up after a fight starts.",
	bm_wp_wpn_fps_upg_aug9mm_supp_gm9_desc = "Check out that company branding on the front.",
	bm_wp_wpn_fps_upg_aug9mm_supp_osprey_desc = "Big and black, no turning back.",
	bm_wp_wpn_fps_upg_aug9mm_vg_bcm_desc = "Any shorter and you're better off holding the barrel.",
	bm_wp_wpn_fps_upg_aug9mm_vg_fab_reg_desc = "Fits the shape of your, or at least somebody out there's hand.",
	bm_wp_wpn_fps_upg_aug9mm_vg_m900_desc = "It's a grip! It's a light! It's both!\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_aug9mm_vg_troy_desc = "Relies on grip rather than shape to keep your hand in place.",
	bm_wp_wpn_fps_upg_aug9mm_vg_troy_short_desc = "Hold on tight.",

	-- SAVE THE AWP
	bm_w_l115_desc = "The iconic one. Works in the snow, works in the desert, even works through walls. Life just isn't complete without it.",
	bm_wp_wpn_fps_upg_l115_barrel_awc_desc = "Combination barrel-suppressor system. Discretion and power in a single package." .. silstr3,
	bm_wp_wpn_fps_upg_l115_body_black_desc = "Get all sneaky-beaky-like.",
	bm_wp_wpn_fps_upg_l115_body_olive_drab_desc = "Colors to rush B with.",
	bm_wp_wpn_fps_upg_l115_supp_desc = "It helps to not immediately announce which lane you're watching when you fire." .. silstr3,

	-- US Optics ST-10
	bm_wp_wpn_fps_upg_o_st10_desc = "Rugged fixed-magnification scope.\n\nZoom level 8.",

	-- zeiss z-point reflex sight
	bm_wp_wpn_fps_upg_o_zeiss_desc = "Reflex sight powered by a combination of battery and solar power.",

	-- the AK they give to all the guards at the all-important moscow jamming stations when they all have to go outside and shit seriously wtf
	bm_wp_wpn_fps_ass_akm_topless = "No Cover",
	bm_wp_wpn_fps_ass_akm_topless_desc = "Wouldn't want to fire this outdoors.",

	-- montana 5.56
	bm_w_yayo_desc = "A modified rifle with an underslung 40mm grenade launcher. Perfect for someone itching to send their greetings downrange in short order.",
	bm_wp_wpn_fps_ass_yayo_fg_rail_desc = "The times are changing.",
	bm_wp_wpn_fps_ass_yayo_irons2_desc = "Don't tell anyone, but it can be flipped back down.",
	bm_wp_wpn_fps_ass_yayo_flipup_desc = "Let the bodies hit the floor.",
	bm_wp_wpn_fps_ass_yayo_s_tactical_desc = "Like the other one, but in matching colors.",
	bm_wp_wpn_fps_ass_yayo_s_modern_desc = "Deja vu.",
	-- pacino grip
	bm_wp_wpn_fps_ass_yayo_g_ergo_desc = "A little change can go a long way.",
	-- tony grip
	bm_wp_wpn_fps_ass_yayo_g_hk_desc = "Taking a new angle on things.", 
	-- yayo grip
	bm_wp_wpn_fps_ass_yayo_snp_desc = "The kind of rubber you can trust.", -- based on a hogue rubber pistol grip?
	bm_wp_wpn_fps_ass_yayo_mag_dual = "Dual Magazines",
	bm_wp_wpn_fps_ass_yayo_mag_dual_desc = "Double the trouble.\n\nEvery other reload is 50% faster.",
	bm_wp_wpn_fps_ass_yayo_mag_pmag_desc = "Polymer magazine. People always try updating the classics when you aren't looking.",
	bm_wp_wpn_fps_ass_yayo_mag_smol_desc = "The standard didn't used to be 30.",
	bm_wp_wpn_fps_ass_yayo_potato_desc = "If the world's trying to catch up with you, it pays to save some weight.\n\nIncreases ammo scavenge by 50%.",

	-- bren ten
	bm_w_sonny_desc = "The power of a revolver with the speed of an automatic. The gun that introduced the mighty 10mm to the world. A commercial failure, but it lives on in the hearts of enthusiasts.",
	bm_w_x_sonny_desc = "How does the pain of loss compare to the pain of never having been?",
	bm_wp_wpn_fps_pis_sonny_sl_runt_desc = "The compact model.",

	-- VisionKing VS1.5-5x30QZ
	bm_wp_wpn_fps_upg_o_visionking_desc = "Chinese multi-coated rifle scope.\n\nZoom level 7.",

	-- Aimpoint CompM4s Sight
	bm_wp_wpn_fps_upg_o_compm4s_desc = "If it can withstand the US Army, it'll probably survive you.",

	-- stg 44
	bm_w_stg44_desc = "The assault rifle. First of its kind to truly gain currency, in name and in concept. Though short lived, its influence determined the path of small arms development in the years since.",
	bm_wp_wpn_fps_ass_stg44_b_short_desc = "Hopefully, you know what you're doing.",
	bm_wp_wpn_fps_ass_stg44_b_long_desc = "Enhances destruction of enemies and sale value in one fell swoop.",
	bm_wp_wpn_fps_ass_stg44_m_short_desc = "Saving weight by any means.",
	bm_wp_wpn_fps_ass_stg44_m_long_desc = "A sure way to drive the detail-oriented insane.",
	bm_wp_wpn_fps_ass_stg44_m_double_desc = "Actually two magazines stuck together.\n\nEvery other reload is 50% faster.",
	bm_wp_wpn_fps_ass_stg44_m_short_double_desc = "There's no way you could go on a spree shooting with these. Nope.\n\nEvery other reload is 50% faster.",
	bm_wp_wpn_fps_ass_stg44_s_plast_desc = "If they're going to make you a boogeyman, you might as well be one.",
	bm_wp_wpn_fps_ass_stg44_o_scope_desc = "An attempt to increase the accuracy of the average infantryman. Planned for much wider use than it actually saw.\n\nZoom level 5.",
	bm_wp_wpn_fps_ass_stg44_o_scope_switch_desc = "An attempt to increase the accuracy of the average infantryman. Planned for much wider use than it actually saw.\n\nZoom level 5. Toggle sight by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_ass_stg44_sing_desc = "Believe me, you wouldn't want to drop this thing.",
	bm_wp_wpn_fps_ass_stg44_fg_mp5_desc = "You Germans guns all look alike.",
	bm_wp_wpn_fps_ass_stg44_fg_r_desc = "One would think that the art of making a gun easy to hold wouldn't require so much work.",
	bm_wp_wpn_fps_ass_stg44_fg_a280_desc = "Made a long time ago.",
	bm_wp_wpn_fps_ass_stg44_s_a280_desc = "Made somewhere far away.",

	-- G3A3 M203
	bm_w_g3m203_desc = "Part sturm, part gewehr. A rifle not equipped with the proprietary grenade launcher made for it, but a proper 40mm launcher is a 40mm launcher all the same.",
	bm_wp_wpn_fps_upg_g3m203_barrel_g3ka4 = "Karabiner Barrel",
	bm_wp_wpn_fps_upg_g3m203_barrel_g3ka4_desc = "Shortened barrel unsuitable for use with bayonets or rifle grenades.",
	-- XM576/XM576E1/M576: 20x #4 buckshot
	-- XM576E2: 27x #4 buckshot
	bm_wp_wpn_fps_upg_g3m203_gre_buckshot = "M576 Buckshot",
	bm_wp_wpn_fps_upg_g3m203_gre_buckshot_desc = "Effectively a 40mm shotgun shell packed with 00 buckshot.\n\nDamage: 500\nAccuracy: 20\nFalloff Ranges: 10m/25m",
	bm_wp_wpn_fps_upg_g3m203_gre_flechette = "Beehive APERS-T",
	bm_wp_wpn_fps_upg_g3m203_gre_flechette_desc = "Anti-personnel flechette round developed while flechettes were still in vogue.\n\nDamage: 375\nAccuracy: 40\nFalloff Ranges: 12m/31m",
	bm_wp_wpn_fps_upg_g3m203_gre_incendiary = "Incendiary Grenade",
	bm_wp_wpn_fps_upg_g3m203_grip_psg1_desc = "A grip with a palm shelf.",
	bm_wp_wpn_fps_upg_g3m203_handguard_rail_desc = "Handy for attaching things, like that grenade launcher.",
	bm_wp_wpn_fps_upg_g3m203_handguard_psg1_desc = "If you try hard enough, you can still pretend you're a sharpshooter.",
	bm_wp_wpn_fps_upg_g3m203_handguard_wide_desc = "None of that slimline business.",
	bm_wp_wpn_fps_upg_g3m203_handguard_wide_bipod_desc = "If it makes you feel better.",
	bm_wp_wpn_fps_upg_g3m203_handguard_wood_desc = "Some things age like fine wine.",
	bm_wp_wpn_fps_upg_g3m203_polymer_black_desc = "Police Green is not a creative color.",
	bm_wp_wpn_fps_upg_g3m203_sight_mount_claw_desc = "Be warned: it's not short.",
	bm_wp_wpn_fps_upg_g3m203_stock_g3ka4 = "Karabiner Stock",
	bm_wp_wpn_fps_upg_g3m203_stock_g3ka4_desc = "KA4-model sliding stock.",
	bm_wp_wpn_fps_upg_g3m203_stock_magpul_prs_desc = "It's that aftermarket stuff you keep seeing.",
	bm_wp_wpn_fps_upg_g3m203_stock_magpul_prs_largepad_desc = "If you're going to buy something, don't cheap out.",
	bm_wp_wpn_fps_upg_g3m203_stock_psg1_desc = "Something thick to rest your head on.",
	bm_wp_wpn_fps_upg_g3m203_stock_wood_desc = "There's something timeless about dead trees on guns.",
	bm_wp_wpn_fps_upg_g3m203_supp_socom762_desc = "Light, quick to attach, and marine-proofed." .. silstr,
	bm_wp_wpn_fps_upg_g3m203_trigger_group_navy_desc = "Three-position ambidextrous trigger group.",


	-- honey badger
	bm_w_bajur_desc = "Shortened integrally-silenced weapon. Created in cooperation with special operations units to deal with a world where submachine guns just don't liberate fast enough.",
	bm_wp_wpn_fps_upg_bajur_b_long_desc = "Something wicked this way comes. American forces in the AO.",
	bm_wp_wpn_fps_upg_bajur_b_short_desc = "Size matters.",
	bm_wp_wpn_fps_upg_bajur_m_quick_desc = "Short magazine with speed pull tab to ease removal of magazines mid-combat.",
	bm_wp_wpn_fps_upg_bajur_s_ext_desc = "It's there for a reason.",
	bm_wp_wpn_fps_upg_bajur_s_nope_desc = "The highest speed and the lowest drag.",
	bm_wp_wpn_fps_upg_bajur_am_grendel = "6.5mm Grendel",
	bm_wp_wpn_fps_upg_bajur_am_grendel_desc = "A high-powered round designed to fit the length of the western world's most bog-standard magazine. Capacity is reduced due to the round's increased diameter.",
	--bm_wp_wpn_fps_upg_bajur_fg_dmr = "Extended Handguard",
	--bm_wp_wpn_fps_upg_bajur_fg_dmr_desc = "Look at all that extra Picatinny real estate.",
	bm_wp_wpn_fps_upg_bajur_fg_dmr = "Heorot Kit",
	bm_wp_wpn_fps_upg_bajur_fg_dmr_desc = "Upper receiver kit with extended handguard and .50 Beowulf rechambering.\n\nPenetrates shields. -33% ammo scavenge.",

	-- kobra sight
	bm_wp_wpn_fps_upg_o_kobra_desc = "Russian red dot sight developed for AK-series rifles.",

	-- af2011
	bm_w_af2011_desc = "Effectively two pistols combined into one frame. That's twice as much lead output, twice as much kick, and four times as many problems for everyone involved.",
	bm_w_x_af2011_desc = "Quantity is its own quality, in the best and worst of ways.",
	bm_wp_wpn_fps_pis_af2011_m_ext_desc = "Double tap... triple tap... triskaidekatap?",
	bm_wp_wpn_fps_pis_af2011_g_bling_desc = "You know you bought this thing just to show it off.",
	bm_wp_wpn_fps_pis_af2011_g_wood_desc = "One color, one trigger, one kill.",
	bm_wp_wpn_fps_pis_af2011_b_silver_desc = "Just like yesteryear's hitman would have done it.",
	bm_wp_wpn_fps_pis_af2011_a_uno = ".38 Special",
	bm_wp_wpn_fps_pis_af2011_a_uno_desc = "The old police revolver round. Still as popular as ever.\n\n+66% ammo scavenge",
	bm_wp_wpn_fps_pis_af2011_a_shield = ".45 Super",
	bm_wp_wpn_fps_pis_af2011_a_shield_desc = "High pressure rounds based on and interchangeable with .45 ACP, assuming your handgun won't explode by the first magazine.\n\n-33% ammo scavenge.",

	-- OKP-7 sight
	bm_wp_wpn_fps_upg_o_okp7_desc = "Lightweight Russian red dot sight.",

	-- 169P Giperon
	bm_wp_wpn_fps_upg_o_1p69_desc = "Modern Russian daylight sniper optic.\n\nZoom level 8.",

	-- FABARM STF-12
	bm_w_stf12_desc = "Italian pump-action shotgun aimed at the military, law enforcement, and security market. Not to say that it's unavailable on the civilian market, but you're not supposed to enjoy your new purchase more than is legally acceptable.",
	bm_wp_wpn_fps_shot_stf12_b_long_desc = "Every inch count to you?",
	bm_wp_wpn_fps_shot_stf12_fin_fde_desc = "Tough, corrosion-resistant, and all that jazz.",
	bm_wp_wpn_fps_shot_stf12_choke_desc = "Directs the muzzle flash in not one, not two, but three different directions.",

	-- po 4x24p
	bm_wp_wpn_fps_upg_o_po4_desc = "Sight calibrated for 5.45x39mm rounds. At the range you're firing at, all you need is the center.\n\nZoom level 6.",

	-- m200 intervention
	bm_w_m200_desc = "How to reach out and touch someone from two kilometers away. Designed for accuracy in every respect, down to its choice of rounds.",
	bm_wp_wpn_fps_upg_m200_barrel_bipod_desc = "Press $BTN_BIPOD to deploy. When deployed, reduce recoil by 50% and increase rate of fire by 25%.",
	bm_wp_wpn_fps_upg_m200_supp = "Angel Suppressor",
	bm_wp_wpn_fps_upg_m200_supp_desc = "Some people are blessed to have a guardian angel watching over them. The rest can pay for some high-caliber overwatch." .. silstr3,
	bm_wp_wpn_fps_upg_m200_body_tan_desc = "Made for a rifle and its natural environment.",

	-- eotech 552
	bm_wp_wpn_fps_upg_o_eotech552 = "Ymir Holosight",
	bm_wp_wpn_fps_upg_o_eotech552_desc = "It all has to start somewhere.",

	-- minebea pm-9
	bm_w_minebea_desc = "Mini Uzi-based SMG issued to Japanese non-frontline forces. Due for replacement in the near future - an opportunity worth taking advantage of.",
	bm_w_x_minebea_desc = "Look to your own interests. Who else will? Who else can you rely on to do so, without exploiting you for their own?",
	bm_wp_wpn_fps_smg_minebea_m_extended_desc = "Keeps your fighting spirit going 40% longer.",
	bm_wp_wpn_fps_smg_minebea_s_extended_desc = "Shouldering it is a start.",
	bm_wp_wpn_fps_smg_minebea_s_extended_desc_x = "You could tuck them under your arms or something.",
	bm_wp_wpn_fps_smg_minebea_s_no_desc = "You weren't using it anyways.",
	bm_wp_wpn_fps_smg_minebea_s_no_desc_x = "You weren't using them anyways.",
	bm_wp_wpn_fps_smg_minebea_barrelext_desc = "Not a sound suppressor.",
	bm_wp_wpn_fps_smg_minebea_g_wood = "Older-issue wooden grips.",

	-- thermal scope
	bm_wp_wpn_fps_upg_o_thersig_desc = "Advanced penetrating threat-recognition sight. Range is limited, so use of a back-up sight is advised.\n\nZoom level 3.",

	-- ghost ring sight
	bm_wp_wpn_fps_upg_870_o_ghostring_desc = "Aperture sight with thin rear ring, allowing fast target acquisition.",
	bm_wp_wpn_fps_upg_870_o_ghostring_short_desc = "Aperture sight with thin rear ring, allowing fast target acquisition.",
	bm_wp_wpn_fps_upg_m37_o_ghostring_desc = "Aperture sight with thin rear ring, allowing fast target acquisition.",
	bm_wp_wpn_fps_upg_m1887_o_ghostring_desc = "Aperture sight with thin rear ring, allowing fast target acquisition.",
	bm_wp_wpn_fps_upg_p30l_o_ghostring_desc = "Aperture sight with thin rear ring, allowing fast target acquisition.",
	bm_wp_wpn_fps_upg_p226_o_ghostring_desc = "Aperture sight with thin rear ring, allowing fast target acquisition.",

	-- hx25 grenade pistol
	bm_w_hx25_desc = "Single-shot grenade pistol used by Horzine mercenaries. Fires a cluster of seven explosive pellets. Aim at hard surfaces near targets to produce maximum secondary fragmentation or shield spallation.",
	bm_wp_wpn_fps_upg_hx25_buckshot_ammo = "Ashot Round",
	bm_wp_wpn_fps_upg_hx25_buckshot_ammo_desc = "A more direct application of fast-moving object to squishy man.\n\n+100% ammo scavenge. Falloff Ranges: 15m/45m",
	bm_wp_wpn_fps_upg_hx25_dragons_breath_ammo_desc = "The firebug special. Twelve fast-burning incendiary pellets packed into a grenade.\n\n+100% ammo scavenge. Ignition range: 15m, DoT: 30/sec for 3sec",
	bm_wp_wpn_fps_upg_hx25_sight_iron_il_desc = "A precaution for firing in poorly-lit laboratories.",
	bm_wp_wpn_fps_upg_hx25_sight_rmr_desc = "By the time the lens cracks, you'll have much bigger problems to deal with.",

	-- automag .44
	bm_w_amt_desc = "High-caliber semi-automatic pistol. A hand cannon, a name, and a short production run. In true classic style, even as factories come and go, the design will only be retired for good in a distant future unrecognizable to it, and perhaps us.",
	bm_wp_wpn_fps_pis_amt_b_long_desc = "Longer than Clint Eastwood's.",
	bm_wp_wpn_fps_upg_amt_visionking_desc = "Chinese multi-coated rifle scope.\n\nZoom level 7.",
	bm_wp_wpn_fps_pis_amt_m_short_desc = "There are an awful lot of days to be made.",

	-- vanilla-styled mod pack
	bm_wp_wpn_fps_lmg_shuno_b_long_desc = "Your back can take it. Probably. Maybe.\n\n+60% spin-up/down time.",
	bm_wp_wpn_fps_pis_packrat_sl_silver = "Steiner-Bisley Slide",
	bm_wp_wpn_fps_pis_packrat_sl_silver_desc = "If only you could get the fancy quantum rounds, too.",
	bm_wp_wpn_fps_shot_m37_o_expert_desc = "Some sort of military-styled assault sight, probably.",
	bm_wp_wpn_fps_sho_b_spas12_small_desc = "A shortened barrel for a drying world.",

	-- zenith 10mm
	bm_w_zenith_desc = "Recently-introduced semi-automatic pistol. Built to be a versatile platform, with future plans to offer caliber conversions, stun-gun dart capability, and more to be swapped in or out with equal ease.",
	bm_wp_wpn_fps_upg_zenith_ammo_ap_desc = "Advanced ammunition able to use quantum tunnelling to bypass armor at the cost of terminal ballistics.\n\nPenetrates shields for 20% damage. -50% ammo scavenge.",
	bm_wp_wpn_fps_upg_zenith_mag_ext_desc = "Not something you need for the quiet approach.",
	bm_wp_wpn_fps_upg_zenith_compact_laser_desc = "The future isn't complete without a manufacturer locking you into their wares.\n\nToggle by pressing $BTN_GADGET.",

	-- widowmaker tx
	bm_w_wmtx_desc = "Czech close-quarters shotgun with unusual rotating magazine system. Favored by units that put the brutality in police brutality for its light weight, short length, and rapid-fire punch.",
	bm_wp_wpn_fps_upg_wmtx_ammo_minishell = "Ostravan MiniShells",
	bm_wp_wpn_fps_upg_wmtx_ammo_minishell_desc = "Short Widowmaker-specific shells intended to maximize magazine capacity.\n\nLowers pellet count to 6. +50% ammo scavenge.",
	bm_wp_wpn_fps_upg_wmtx_rec_tf2 = "Conagher FDE Finish",
	bm_wp_wpn_fps_upg_wmtx_gastube_burst_desc = "Modifications to add a toggleable two-shell burst fire mode.",

	-- DP-12
	bm_w_dp12_desc = "Double-barreled pump action shotgun. Fires alternating barrels with each pull of the trigger, allowing two shots between each pump.",
	bm_wp_wpn_fps_sho_dp12_o_non_desc = "It's not like you need any on a shotgun.",
	bm_wp_wpn_fps_shot_dp12_norail = "No Top Rail",
	bm_wp_wpn_fps_sho_dp12_fg_novg_desc = "Standard grip, best grip.",
	bm_wp_wpn_fps_sho_dp12_fg_novg_rail = "Rail Grip",
	bm_wp_wpn_fps_sho_dp12_fg_novg_rail_desc = "Might as well put a gadget down there since you've got it.",
	bm_wp_wpn_fps_sho_dp12_so_quiet_desc = "For people who enjoy not being deaf.",
	bm_wp_wpn_fps_sho_dp12_m_ext = "Extended Tubes",

	-- SpecterDR with Docter Sight
	bm_wp_wpn_fps_upg_o_su230_docter = "HKRK-DR w/RedDoc Sight",
	bm_wp_wpn_fps_upg_o_su230_docter_desc = "Combination rifle scope and reflex sight.\n\nZoom level 5. Toggle sight by pressing $BTN_GADGET.",

	-- sneaky suppressor pack
	bm_wp_wpn_fps_ass_ns_g_sup1_desc = "Death is cold." .. silstr,
	bm_wp_wpn_fps_ass_ns_g_sup2_desc = "All hail the twenty-second element." .. silstr,
	bm_wp_wpn_fps_ass_ns_g_sup3_desc = "Light suppressor for light-footed work." .. silstr,
	bm_wp_wpn_fps_ass_ns_g_sup4_desc = "What was that noise?" .. silstr,
	bm_wp_wpn_fps_ass_ns_g_sup5_desc = "The Tracker model. Hunt in silence, leave no trace. Shell catcher sold separately." .. silstr,
	bm_wp_wpn_fps_ass_ns_g_sup6_desc = "Everything you could want, unless you want a peek inside." .. silstr,
	bm_wp_wpn_fps_ass_ns_g_sup7_desc = "So light, you'd swear it had wings." .. silstr,
	bm_wp_wpn_fps_ass_ns_g_sup8_desc = "Let nothing give you away." .. silstr,

	-- lost gadgets pack
	bm_wp_wpn_fps_upg_fl_anpeq2_desc = "Laser sight that can be chucked down 20 meters of water. A related but distinct question is whether or not you ever should.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_dbal_d2_desc = "Laser and light for fighting at night.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_m600p_desc = "600 lumens of light.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_unimax_desc = "Warning: This product can expose you to lasers.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_utg_desc = "Sticks to rails like white on rice.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_pis_inforce_apl_desc = "For visual confirmation of how many times you missed the target.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_pis_unimax_desc = "Warning: This product can expose you to lasers.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_unimax_inforce_desc = "It's gadget rails all the way down.\n\nToggle by pressing $BTN_GADGET.",

	-- AK MOE furniture
	bm_wp_wpn_fps_upg_g_ak_moe = "River AK Grip",
	bm_wp_wpn_fps_upg_s_ak_moe = "River AK Stock",
	bm_wp_wpn_fps_upg_fg_ak_moe = "River AK Handguard",
	bm_wp_wpn_fps_upg_ak_m_pmag = "AK River Magazine",

	-- M4 MOE furniture
	bm_wp_wpn_fps_upg_g_m4_moe = "River Grip",
	bm_wp_wpn_fps_upg_fg_moe2 = "T-LOCK Long Handguard",
	bm_wp_wpn_fps_upg_fg_moe2_short = "T-LOCK Short Handguard",
	bm_wp_wpn_fps_upg_s_m4_pts = "Dark Tactical Stock",
	bm_wp_wpn_fps_upg_s_m4_pts_c = "Retracted Dark Tactical Stock",
	--bm_wp_wpn_fps_upg_s_m4_sl
	--bm_wp_wpn_fps_upg_s_m4_sl_c
	bm_wp_wpn_fps_upg_s_m4_ubr = "Full Two-Piece Stock",
	bm_wp_wpn_fps_upg_m4_m_pmag3 = "River-30W Magazine",
	bm_wp_wpn_fps_upg_m4_m_pmagsolid = "River-30 Magazine",
	bm_wp_wpn_fps_upg_m4_m_pmag10 = "River-10 Magazine",
	bm_wp_wpn_fps_upg_m4_m_pmag20 = "River-20 Magazine",
	bm_wp_wpn_fps_upg_m4_m_pmag40 = "River-40 Magazine",

	-- lahti l-35
	bm_w_l35_desc = "Finnish WW2 pistol. Used a bolt accelerator, uncommon in pistols, to ensure proper cycling in cold conditions. Considered robust and reliable, if a bit heavy.",
	bm_wp_wpn_fps_upg_l35_grip_rubber_window = "Windowed Rubber Grip",
	bm_wp_wpn_fps_upg_l35_grip_wood_window = "Windowed Wooden Grip",
	bm_wp_wpn_fps_upg_l35_mag_drum_desc = "A reminder that we didn't used to know better about what to do with 30 rounds of 9mm.",
	bm_wp_wpn_fps_upg_l35_mag_ext_desc = "You weren't going to rest the grip on your hand, were you?",
	bm_wp_wpn_fps_upg_l35_mag_long_desc = "There'd better be seventeen dead commies by the time you pull it out.",

	-- groza
	bm_w_ots_14_4a_desc = "Bullpup special operations weapon. Although based on the Krinkov, no 5.45x39mm variant went into production due to a lack of interest in smaller intermediate calibers.",
	bm_wp_wpn_fps_upg_ots_14_4a_handle_rail_desc = "Mounts sights on top of the handle",
	bm_wp_wpn_fps_upg_ots_14_4a_leupold_pro_desc = "Zoom level 0.",
	bm_wp_wpn_fps_upg_ots_14_4a_visionking_desc = "Zoom level 6.",
	bm_wp_wpn_fps_upg_ots_14_4a_supp_desc = "" .. silstr,
	bm_wp_wpn_fps_upg_ots_14_4a_supp_b_desc = "" .. silstr,

	-- wooden amr-16
	bm_wp_wpn_fps_ass_m16_fg_wood_desc = "So, Vlad, what say we make a wish come true?",

	-- MK18 specialist
	bm_w_mk18s_desc = "US Navy-developed upper receiver equipped to a carbine to shorten it to the length of an SMG. The Mod 1 was modified to maximize available rail space.",
	bm_wp_wpn_fps_ass_mk18s_mag_big_desc = "For militaries only.",
	bm_wp_wpn_fps_ass_mk18s_grip_black = "Dark Grip",
	bm_wp_wpn_fps_ass_mk18s_grip_black_desc = "",
	bm_wp_wpn_fps_ass_mk18s_fg_black = "Dark Handguard",
	bm_wp_wpn_fps_ass_mk18s_fg_black_desc = "Everything's scarier when black.",
	bm_wp_wpn_fps_ass_mk18s_a_weak = "M193",
	bm_wp_wpn_fps_ass_mk18s_a_weak_desc = "Original US .223 Remington. Formed the basis for the 5.56x45mm SS109 round selected by NATO to replace the heavier 7.62x51mm NATO.",
	bm_wp_wpn_fps_ass_mk18s_a_classic = "Mk 262 Mod 1",
	bm_wp_wpn_fps_ass_mk18s_a_classic_desc = "Heavy SOCOM 5.56x45mm cartridge. Tumbles well within standard engagement range. The Mod 1 was developed due to issues with temperature induced failures.\n\n-33% ammo scavenge.",
	bm_wp_wpn_fps_ass_mk18s_a_strong = "M855A1",
	bm_wp_wpn_fps_ass_mk18s_a_strong_desc = "Enhanced general-purpose 5.56x45mm cartridge. Intended to reduce lead accumulation at training ranges, but expanded into a general improvement program.\n\n-33% ammo scavenge.",
	bm_wp_wpn_fps_ass_mk18s_a_dmr = "Mk 318",
	bm_wp_wpn_fps_ass_mk18s_a_dmr_desc = "Barrier-penetrating round with two-part bullet. The front half crushes against hard surfaces, allowing the rear half to penetrate with less loss of accuracy and damage.\n\n-33% ammo scavenge.",

	-- lewis gun
	bm_w_lewis_desc = "The classic light machine gun, and the first to be fired from an aircraft. Its relatively low weight made it popular for both infantry and aerial use.",
	bm_wp_wpn_fps_upg_lewis_bipod_desc = bipodstr,
	bm_wp_wpn_fps_upg_lewis_sights_vanilia = "Offset Aiming",
	bm_wp_wpn_fps_upg_lewis_sights_vanilia_desc = "Holds the weapon offset to the side instead of aiming directly down the sights.",
	bm_wp_wpn_fps_upg_lewis_bolt_aa_desc = "Bolt used on aircraft-mounted variants.",
	bm_wp_wpn_fps_upg_lewis_handle_desc = "Carrying handle clamped onto the Dutch infantry variant.",
	bm_wp_wpn_fps_upg_lewis_sight_zf12_desc = "Prismatic optical sight designed for the German MG08.\n\nZoom level 5.",

	-- hk416
	bm_w_hk416_desc = "An AR with a piston system, reducing heating and fouling. All the comfort of familiarity, but with more reliability. Little wonder everybody wants one.",
	bm_wp_wpn_fps_upg_hk416_mag_pull_assist_desc = speedpulldesc,

	-- hk416c
	bm_w_drongo_desc = "Compact carbine 416 variant developed for UK special forces. Though obtained from the same source that Sydney appropriated her's from, the 416 is incapable of accepting available drum magazines without significant modification.",
	bm_wp_wpn_fps_upg_drongo_s_orig_desc = "Factory-standard stock.",

	-- hk417
	bm_w_recce_desc = "The 7.62x51mm counterpart to the 416. Trades capacity and controllability in exchange for greater power. Like its little brother, it has seen significant adoption internationally.",
	bm_wp_wpn_fps_upg_recce_s_orig_desc = "Factory-standard stock.",

	-- remington ACR
	bm_w_acwr2_desc = "Lightweight modular rifle combining several aspects from contemporary rifles. Designed by Magpul and produced in select-fire/semi-auto by Remington and Bushmaster, respectively.",
	bm_w_acwr_desc = "Lightweight modular rifle combining several aspects from contemporary rifles. The underslung grenade launcher rounds off the package with a bang.",

	-- things that would never get InF stats if nobody asked for them
	bm_w_saigry_desc = "AR-15 rifle with proprietary rail system that retains zero. Fully field-serviceable without special tools.",
	bm_wp_wpn_fps_upg_saigry_a_556 = "5.56x45mm NATO",
	bm_wp_wpn_fps_upg_saigry_a_556_desc = "Standard service caliber commonly found in the western world.\n\n+50% ammo scavenge.",

	-- owen gun
	bm_w_owen_desc = "The Australian SMG. Though SMGs were viewed with disdain at the time, the young Owen's creation was refined into a simple and reliable weapon - qualities that soldiers in the field greatly appreciated.",
	bm_wp_wpn_fps_smg_owen_m_double_desc = "Two magazines joined together.\n\nEvery other reload is 50% faster.",

	-- pp-19-01 vityaz
	bm_w_vityaz_desc = "An evolution of the Bizon. The standard SMG for Russian military and police forces. ",
	bm_wp_wpn_fps_upg_vityaz_supp = "Icepick Suppressor",
	bm_wp_wpn_fps_upg_vityaz_supp_desc = "When the going gets tough, drink copiously and fire at will." .. silstr,
	bm_wp_wpn_fps_upg_vityaz_mag_dual_desc = "Two magazines joined together.\n\nEvery other reload is 50% faster.",
	bm_wp_wpn_fps_upg_vityaz_ammo_9mm_p_desc = "Still not a one-shot headshot.",

	-- operator attachment pack
	bm_wp_wpn_fps_upg_sub2000_m_short = "Short Magazine",
	bm_wp_wpn_fps_upg_sub2000_m_short_desc = "It's easier to conceal when you aren't hiding an entire tetris piece under your suit.",
	bm_wp_wpn_fps_upg_tecci_am_beefy = "M193",
	bm_wp_wpn_fps_upg_tecci_am_beefy = "Original US .223 Remington. Formed the basis for the 5.56x45mm SS109 round selected by NATO to replace the heavier 7.62x51mm NATO.",
	bm_wp_wpn_fps_upg_ching_am_crap = "Surplus M2 Ball",
	bm_wp_wpn_fps_upg_ching_am_crap_desc = "An assortment of WW2-era surplus.\n\n+76% ammo scavenge.",
	bm_wp_wpn_fps_upg_ns_dragon_desc = "Imbued with the mystical energies of the arms industry.",
	bm_wp_wpn_fps_upg_ns_hock_desc = "The only thing more futuristic than hexagons is hexagons on curved surfaces." .. silstr,
	--bm_wp_wpn_fps_upg_ns_osprey = "Megalith Suppressor",
	bm_wp_wpn_fps_upg_ns_osprey_desc = "Bigger and badder than ever." .. silstr,
	bm_wp_wpn_fps_upg_m14_m_tape_desc = "A war-battered, well-used magazine. It's been through rough times. Probably on its third roll of duct tape at this point.",
	bm_wp_wpn_fps_upg_mp5_m_ten = "The Tan Ten Special",
	bm_wp_wpn_fps_upg_mp5_m_ten_desc = "The off-brand version!",
	bm_wp_wpn_fps_upg_schakal_m_nine = "9x19mm Conversion",
	bm_wp_wpn_fps_upg_schakal_m_nine_desc = "Hold on, is that really the right magazine?",
	bm_wp_wpn_fps_upg_schakal_m_atai = "Blue Magazine",
	bm_wp_wpn_fps_upg_schakal_m_atai_desc = "Claims of performance enhancement based on chromatic modification are unfounded. Baka.",
	bm_wp_wpn_fps_upg_tr_match_desc = "A light touch is all you need.",
	bm_wp_wpn_fps_upg_pn_over_desc = "Increases the amount of gas being used to cycle the weapon. Voids the warranty.",
	bm_wp_wpn_fps_upg_pn_under_desc = "Decreases the amount of gas being used to cycle the weapon.",

	-- l1a1
	bm_w_l1a1_desc = "The \"inch pattern\" rifle, manufactured under license in Britain with changes for imperial measurements. The majority were semi-automatic only.",

	-- mk14 ebr
	bm_w_wargoddess_desc = "A modern adaptation of the old battle rifle. Originally designed for special operations use, but more widely issued to increase the effective range and armor penetration available to deployed units.",
	bm_wp_wpn_fps_snp_wargoddess_b_ebr_desc = "Bring your green laser, too.",
	bm_wp_wpn_fps_snp_wargoddess_s_mod0_folded = "Retracted SEAL Stock",
	bm_wp_wpn_fps_snp_wargoddess_s_mod0_unfolded = "Extended SEAL Stock",

	-- sg552
	bm_w_sg552_desc = "A fresh shipment of rifles, almost like the ones you got back when armored truck hits were the new and exciting thing. Comes with factory-standard sights and some fresh handguards.",
	bm_wp_wpn_fps_ass_sg552_a_dmg = "5.56x45mm NATO",
	bm_wp_wpn_fps_ass_sg552_a_dmg_desc = "Everyone knew what you were really firing anyways.",

	-- px4 storm
	bm_w_px4_desc = "Current-generation Italian pistol. More modular, durable, and ergonomic than the manufacturer's last media darling.",
	bm_wp_wpn_fps_upg_px4_ammo_45acp = ".45 Super",
	bm_wp_wpn_fps_upg_px4_ammo_45acp_desc = "High pressure rounds based on and interchangeable with .45 ACP, assuming your handgun won't explode by the first magazine.\n\n-29% ammo scavenge.",
	bm_wp_wpn_fps_upg_px4_ammo_9mm = "9x19mm Parabellum",
	bm_wp_wpn_fps_upg_px4_ammo_9mm_desc = "The gold standard. Or lead, as the case may be.\n\n+90% ammo scavenge",

	-- p99
	bm_w_p99_desc = "A handgun for the discerning shooter. Comfortable to hold, reliable in a pinch, and prone to laeving an impression - visually and physically.",
	bm_wp_wpn_fps_upg_p99_mag_ext = "Extended Magazine",
	bm_wp_wpn_fps_upg_p99_mag_ext_desc = "Some people make a lot of enemies.",
	bm_wp_wpn_fps_upg_p99_ammo_40sw = ".40 S&W",
	bm_wp_wpn_fps_upg_p99_ammo_40sw_desc = "More powerful than 9mm. More manageable than 10mm.\n\n-44% ammo scavenge.",

	-- black lagrips
	bm_wp_wpn_fps_pis_beretta_g_cutlass = "Sword and Cutlass",
	bm_wp_wpn_fps_pis_beretta_g_cutlass_desc = "There are few universal truths.",

	-- leupold deltapoint
	bm_wp_wpn_fps_upg_o_deltapoint_desc = "If you can throw it to the ground a couple thousand times without damage, then it's fit for a pistol.",

	-- m45a1
	bm_w_m45a1_desc = "An upgraded 1911 for the people stubborn enough to stick to their guns in a literal fashion. It's hard to replace a classic, and harder still if you're a marine.",
	bm_wp_wpn_fps_pis_m45a1_m_ext_desc = "Too many bullets to count, methinks.",
	bm_wp_wpn_fps_pis_m45a1_gr_ball_desc = "I seriously hope you guys don't use these.",

	-- mossberg 590
	bm_w_m590_desc = "Hunters. Soldiers. Cops. Homeowners. Crooks. Everyone's fired a Mossberg for a reason.",
	bm_wp_wpn_fps_shot_m590_b_silencer_desc = "" .. silstr2,

	-- vepr-12
	bm_w_vepr12_desc = "A direct competitor to the more famous Russian mag-loading shotgun, from the same manufacturer. Patterned after the RPK receiver, which is more heavily-built than the standard AK receiver.",

	-- grease gun
	bm_w_m3_desc = "Low-cost alternative to the Thompson SMG. Built to reduce required man-hours per unit produced to the point that the weapon was initially considered disposable.",
	bm_w_x_m3_desc = "The marginal gains of perfection are wasted in the field. It takes one bullet to spill blood. It takes millions to bleed a war machine dry.",
	bm_wp_wpn_fps_smg_m3_a_9mm = "9x19mm Parabellum",
	bm_wp_wpn_fps_smg_m3_a_9mm_desc = "The gold standard. Or lead, as the case may be.",
	bm_wp_wpn_fps_smg_m3_m_double_desc = "Two magazines joined together.\n\nEvery other reload is 50% faster.",
	bm_wp_wpn_fps_smg_m3_a_ovk_9mm = "9x19mm +P",
	bm_wp_wpn_fps_smg_m3_a_ovk_9mm_desc = "9mm rounds that operate at higher pressure, increasing effectiveness.",

	-- howa type 89
	bm_w_howa_desc = "JSDF assault rifle partially based on the AR-18, also manufactured by Howa. Taking lessons learned from the previous Type 64, the Type 89 was significantly simplified, though not enough to bring cost below government expectations.",
	bm_wp_wpn_fps_ass_howa_t64_body = "Type 64",
	bm_wp_wpn_fps_ass_howa_t64_body_desc = "Previous JSDF battle rifle. Uses a rate reducer and slightly reduced load as 7.62x51mm NATO was felt to be too powerful to handle.\n\n-33% ammo scavenge.",

	-- vp70
	bm_w_vp70_desc = "The past's future pistol, with a number of features unorthodox in its time and today. The M (Military) version is capable of three-round bursts with the stock attached.",
	bm_w_x_vp70_desc = "What is truly new? The future is built in layers upon the past, and through it we can still see where we once were.",
	bm_wp_wpn_fps_pis_vp70_stock_standard_desc = "Combination holster and stock with a fire select switch, enabling three-round bursts.\n\n-25% ammo scavenge.",
	bm_wp_wpn_fps_pis_vp70_ac_9x21imi = "9x21mm IMI",
	bm_wp_wpn_fps_pis_vp70_ac_9x21imi_desc = "Alternate chambering made for the Italian civilian market, where 9x19mm is a privilege of the state.",

	-- that gun
	bm_w_lapd_desc = "Special-issue revolver. An uncommon weapon for an exotic purpose.",
	bm_w_x_lapd_desc = "Every bullet creates and erases. A flash created. A memory erased.",

	-- valday
	bm_wp_wpn_fps_upg_o_valday1p87_desc = "A newer Russian sight.",

	-- remington r5 rgp
	bm_w_mikon_desc = "America's oldest gun manufacturer enters the AR carbine market. Takes the common step of swapping out the direct impingement system for a gas piston system and adds in an internal redesign to maintain accuracy without increasing length.",
	bm_wp_wpn_fps_upg_mikon_am_spc_desc = "It doesn't take a diviner to know what .300 Blackout will do to a human skull.\n\n-33% ammo scavenge.",
	bm_wp_wpn_fps_upg_mikon_am_parp = "M193",
	bm_wp_wpn_fps_upg_mikon_am_parp_desc = "Original US .223 Remington. Formed the basis for the 5.56x45mm SS109 round selected by NATO to replace the heavier 7.62x51mm NATO.",

	-- I D W DA NYAAAA
	bm_w_nya_desc = "Prototype SMG regulated by computer-controlled hydraulics, bringing cyclic fire rate down to a more-controllable 400 RPM. This one has been modified with a more-modern CPU to allow instant toggling of the regulator.",
	bm_w_x_nya_desc = "It doesn't take a trained eye to see desperation.",
	bm_wp_wpn_fps_upg_nya_s_nope_desc = "Lewd.",
	bm_wp_wpn_fps_upg_nya_cpu_slow = "Regulator MOD1",
	bm_wp_wpn_fps_upg_nya_cpu_slow_desc = "Increases regulated rate of fire from 400 to 600.",
	bm_wp_wpn_fps_upg_nya_cpu_turbo = "Regulator MOD2",
	bm_wp_wpn_fps_upg_nya_cpu_turbo_desc = "Increases regulated rate of fire from 400 to 800.",
	bm_wp_wpn_fps_upg_nya_am_dillon = "Waifu Merch",
	bm_wp_wpn_fps_upg_nya_am_dillon_desc = "Branded products designed to fleece weebs out of their cash.",
	bm_wp_wpn_fps_upg_nya_sfx_nya_desc = "Don't do this if you're not the type to sacrifice your own body for her.",

	-- arx160
	bm_w_lazy_desc = "Italian future rifle and present product. The A2 is the carbine configuration, sometimes known as the 'Special Forces' model due to its extended rail and carbine length.",
	bm_wp_wpn_fps_upg_lazy_b_long_desc = "The full sixteen inches.",

	-- dp-28
	bm_w_dp28_desc = "Soviet machine gun made in many variants for infantry and vehicular use, known as DP or DP-27. The name DP-28 comes exclusively from western sources, likely from the year it reached wider-scale circulation.",
	bm_wp_wpn_fps_lmg_dp28_bipod_desc = bipodstr,
	bm_wp_wpn_fps_lmg_dp28_tripod_top_desc = tripodstr .. " -30% movement speed.",

	-- m60
	bm_w_m60_desc = "The Pig. A descendent of both American and German designs. Its nickname was both derisive and affectionate in manner due to its versatility, teething problems, and the nasty things a jungle does to a weapon.",
	bm_wp_wpn_fps_upg_m60_bipod_desc = bipodstr,
	bm_wp_wpn_fps_upg_m60_irons_desc = "Aims directly down the sights.",
	-- kits
	bm_wp_wpn_fps_lmg_m60e4_body = "M60E4 Conversion Kit",
	bm_wp_wpn_fps_lmg_m60e4_body_desc = "Modernized variant with several reliability improvements.",
	bm_wp_wpn_fps_upg_m60bc2v_body = "Vietnam Model",
	bm_wp_wpn_fps_upg_m60bc2v_body_desc = "Nothing comes back the same.",

	-- RPD
	bm_w_rpd_desc = "Machine gun developed during World War II, but not delivered until well after. As the barrels are not designed to be quickly changed, RPD gunners were trained to fire in bursts to preserve barrel life.",
	bm_wp_wpn_fps_upg_rpd_bipod_desc = bipodstr,

	-- LSAT LMG
	bm_w_lsat_desc = "Developing machine gun representing two parts of the LSAT program - lightened ammo and lightened weapon. Despite this, the LSAT LMG is felt to be more reliable and effective.",
	bm_wp_wpn_fps_upg_lsat_bipod_desc = bipodstr,
	bm_wp_wpn_fps_upg_lsat_irons_desc = "Aims directly down the sights.",

	-- tt-33
	bm_w_gtt33_desc = "The Red Army's replacement for its obsolescent revolvers. Widely copied throughout the Soviet bloc due to its robust design.",
	bm_wp_wpn_fps_pis_gtt33_a_c45 = "Coffin Rounds", -- shino in uniform is pretty much the only reason i paid much attention to SAO so naturally i'm not the only creepy-ass admirer she has
	bm_wp_wpn_fps_pis_gtt33_a_c45_desc = "It stops being a game when you pull that trigger.",

	-- fang 45
	bm_w_fang45_desc = "Modern .45 ACP SMG with all the usual bells and whistles. Though derivative on the outside, its internals are of unusual design allowing it to fire the first five shots of any burst 15% faster.",

	-- cz75b
	bm_w_cz75b_desc = "One of the original 'wonder nines'. The B variant is the standard production model made for mass production and export.",
	bm_w_x_cz75b_desc = "Success is never free. A sacrifice must be made.",

	-- cz75
	bm_w_rally_desc = "One of the original 'wonder nines'. The pinnacle of semi-automatic handgun evolution. Made from high-grade steel.",
	bm_w_x_rally_desc = "You like guns too much.",

	-- cz75 auto
	bm_w_czauto_desc = "One of the original 'wonder nines'. This select-fire variant was made for law enforcement and military use.",

	-- chiappa rhino
	bm_w_rhino_desc = "Nontraditional revolver bearing Emilio Ghisoni's trademark 6 o'clock barrel. Named after the owner of Chiappa Firearms, but one might be forgiven for thinking otherwise.",
	bm_wp_wpn_fps_upg_rhino_ammo_40sw = ".40 S&W",
	bm_wp_wpn_fps_upg_rhino_ammo_40sw_desc = "A round more suitable for hunting men than rhinos.\n\n+43% ammo scavenge",
	bm_wp_wpn_fps_upg_rhino_frame_200ds_desc = switch_snubnose,

	-- trench gun 1897
	bm_w_trench_desc = "The trench gun. The standard. Popular before the Great War and even more popular after.",

	-- sjogren inertia
	bm_w_sjogren_desc = "An early pioneer of interia-based shotgun cycling. The shotgun and its rifle counterpart failed to draw significant interest, but derivatives of the system are in popular use today.",

	-- m1a1 thompson
	bm_w_tm1a1_desc = "The Tommy Gun, US Army variant. Features a number of changes to reduce production cost and increase reliability, including the inability to use drum magazines.",
	bm_w_x_tm1a1_desc = "People need heroes. The ugly truths behind it all only serve to dampen their spirits.",
	bm_wp_wpn_fps_smg_tm1a1_m_jungle_desc = "Every other reload is 50% faster.",
	bm_wp_wpn_fps_smg_x_tm1a1_m_jungle_desc = "Every other reload is 50% faster.",
	bm_wp_wpn_fps_smg_tm1a1_lower_reciever_30_desc = "A historical consideration, submitted to and promptly rejected from the competition that produced the M1 Carbine. Perhaps being double the weight requirement had something to do with it.",

	-- halo pistol
	bm_w_m6g_desc = "Concept anti-extraterrestrial pistol. Equipped with a smart-linked optical scope and built to fire extremely powerful rounds in hopes of overcoming superior alien personal armor.",
	bm_w_x_m6g_desc = "If you're going to finish something, finish it right.",
	bm_wp_wpn_fps_pis_m6g_a_he = "M227 HE",
	bm_wp_wpn_fps_pis_m6g_a_he_desc = "Contact-detonating explosive round. Despite its lessened direct penetration, the round is lethal to light armored targets due to spallation.\n\nDamage is 40%/60% bullet/explosive.",
	bm_wp_wpn_fps_pis_m6g_a_fire = "M226 IC",
	bm_wp_wpn_fps_pis_m6g_a_fire_desc = "Incendiary round. Rarely seen in use.\n\n15 damage/sec for 3 seconds on direct hit.",
	bm_wp_wpn_fps_pis_m6g_a_shield = "M225 SAP-HE",
	bm_wp_wpn_fps_pis_m6g_a_shield_desc = "Semi-armor-piercing high-explosive. Standard service round for the M6. Highly effective against infantry, but with notable effect against armored targets.\n\nDamage is 66%/33% bullet/explosive.",
	--bm_wp_wpn_fps_pis_m6g_grip_discrete = "",
	bm_wp_wpn_fps_pis_m6g_grip_discrete_desc = "Removes the optical sight and laser.",

	-- ak-9
	bm_w_heffy_939_desc = "New-generation 9x39mm rifle based on 100-series Kalashnikov rifles. As an iterative improvement, it has only seen limited production and use, and has not been officially adopted.",
	bm_w_x_heffy_939_desc = "Being at the right place at the right time makes all the difference.",

	-- ak-47
	bm_w_heffy_762_desc = "The Kalashnikov. THE Kalashnikov. As cheap and rugged as they come.",

	-- ak-101
	bm_w_heffy_556_desc = "Export AK-74M chambered for 5.56x45mm. Made with modern materials to reduce weight and increase accuracy.",

	-- ak extra attachments
	bm_wp_wpn_fps_ass_heffy_all_gl_gp25_desc = "Underbarrel caseless grenade launcher.\n\nReduced ammo scavenge (-33% for light rifles, -25% for medium rifles).",
	bm_wp_wpn_fps_ass_heffy_all_gl_gp25_desc2 = "Underbarrel caseless grenade launcher.\n\n-25% ammo scavenge.",
	bm_wp_wpn_fps_upg_gl_lpo70_desc = "Underbarrel incendiary device.\n\nReduced ammo scavenge (-33% for light rifles, -25% for medium rifles).",
	bm_wp_wpn_fps_upg_gl_lpo70_desc2 = "Underbarrel incendiary device.\n\n-25% ammo scavenge.",

	-- saiga-12
	bm_w_heffy_12g_desc = "Combines the flesh-rending punch of a shotgun with the engineering of an AK.",

	-- AK pack 2.0 stuff
	-- AK-74
	bm_w_ak_stamp_545_desc = "The most iconic Soviet Union AK rifle. Still used to this day by military and armed militia alike.",

	-- AK-101
	bm_w_ak_stamp_556_desc = "A more standardized and export-friendly version of the AK-74, adopting a more standard NATO 5.56x45mm cartridge while keeping the Kalashnikov reliability.",

	-- AKM
	bm_w_ak_stamp_762_desc = "A modernised version of the AK-47. Still has the same amount of oomph behind every shot. Will probably outlast you and your entire bloodline.",

	-- Golden AKMS
	bm_w_ak_stamp_gold_desc = "A gold-plated AKMS. Do I need to say any more?\n\nCURRENTLY BROKEN DUE TO UNKNOWN REASONS. Contact the mod author and ask them why this is clashing with the AK12, and why the stats cannot be changed.",

	-- Why does the AK pack not have any localization for their weapon mod categories???
	bm_menu_stock_adapter = "Stock Adapter",
	bm_menu_barrel2 = "AK Barrel",
	bm_menu_bolt = "Bolt",

	-- nagant 1895
	bm_w_m1895_desc = "Russian revolver with unusual gas-sealing mechanism and cartridge, allowing it to be easily suppressed. Despite its obsolescence on debut, it saw widespread service due to its low cost and near-invulnerability.",

	-- vhs various attachment
	bm_wp_vhs_o_standard = "Standard Iron Sights",
	bm_wp_wpn_fps_ass_vhs_ub_nade = "HVH-BG2 Launcher",
	bm_wp_wpn_fps_ass_vhs_ub_nade_desc = "Underbarrel 40mm grenade launcher redesigned for breech loading.",

	-- kolibri
	bm_w_kolibri_desc = "The smallest commercial pistol ever built. Most likely to kill by infection when it was designed, or asphyxiation in the age of modern medicine, because those bullets by themselves aren't going to be enough.",

	-- aimpoint compm2
	bm_wp_wpn_fps_upg_o_compm2_desc = "NVG-compatible red dot sight. Resistant to water up to 25 meters of depth.\n\nZoom level 3.",

	-- stealth flashlights
	bm_wp_wpn_fps_upg_fl_wml_desc = "Low-profile weapon light with universal rail clamps.\n\nToggle by pressing $BTN_GADGET.",
	bm_wp_wpn_fps_upg_fl_micro90_desc = "Lightweight LED pistol light.\n\nToggle by pressing $BTN_GADGET.",

	-- lynx
	bm_w_lynx_desc = "Hungarian semi-automatic anti-materiel rifle. The GM6 features a number of small improvements over its predecessors, including reduced weight and length.",
	bm_wp_wpn_fps_snp_lynx_a_low = "12.7x108mm",
	bm_wp_wpn_fps_snp_lynx_a_low_desc = "Russian anti-materiel round. Would make a great underground currency if they weren't so useful for their intended purpose.",
	bm_wp_wpn_fps_snp_lynx_o_special = "Zoom level 10.",

	-- ppsh-41
	bm_w_ppsh_desc = "The gun to introduce stamped metal to the Soviet Union. Bears the Soviet hallmarks of being cheaper than dirt and lower-maintenance than a pet rock.",
	bm_wp_wpn_fps_upg_ppsh_mag_drum_desc = "-35% reload speed.",

	-- pps-43
	bm_w_pps43_desc = "The attempt to replace the PPSh-41 with an even less expensive SMG with lower rate of fire. Despite halving machining time and steel usage, huge investments into PPSh-41 tooling made it uneconomical to achieve full replacement.",

	-- csgo scope
	bm_wp_wpn_fps_upg_o_csgoscope = "Arctic Scope",
	bm_wp_wpn_fps_upg_o_csgoscope_desc = "You know where it belongs.\n\nZoom level 8.",

	-- m1 garand modpack
	bm_wp_wpn_fps_ass_ching_o_m84_desc = "Scope produced at the very end of WW2 for sniper-variant Garands.\n\nZoom level 10. Press $BTN_GADGET to switch to ironsights.",
	bm_wp_wpn_fps_ass_ching_ns_expsilencer_desc = "" .. silstr,

	-- kel-tec RFB
	bm_w_leet_desc = "Fully-ambidextrous bullpup rifle using FAL magazines. Features forward casing ejection and an excellent trigger for quickly following up lethal shots with gratuitous shots.",

	-- high standard HDM
	bm_w_hshdm_desc = "Integrally silenced OSS pistol based on a pre-existing target pistol. Hard to find due to the silence of its recipients - whether they received the guns or the bullets.",
	bm_w_x_hshdm_desc = "Nobody will know the full story. Like a rock in the river, the truth of your deeds will be worn away, and its place taken by the public imagination.",
	bm_wp_wpn_fps_pis_hshdm_frame_gold_desc = "Don't say it. We all know what you're going to say.",

	-- maxim 9
	bm_w_max9_desc = "Integrally silenced 9x19mm pistol with removable suppressor sections for variation in length and sound suppression. The future is now.",
	bm_wp_wpn_fps_pis_max9_b_short_desc = "Removing suppressor sections reduces length.",
	bm_wp_wpn_fps_pis_max9_b_nosup_desc = "No silence, no problem.\n\nRemoves damage falloff.",

	-- welrod
	bm_w_welrod_desc = "Integrally silenced bolt-action pistol. A silent tool - and I stress tool, as it scarcely looks like a weapon when unloaded - for changing minds one bullet at a time.",
	bm_wp_wpn_fps_pis_welrod_a_ap_desc = "Extra-special penetrator rounds. Will punch through Shields and walls while remaining silent. Don't ask how these were made, much less where we got them.\n\n-29% ammo scavenge.",
	bm_wp_wpn_fps_pis_welrod_b_short_desc = "The short ones are always a little louder.",
	bm_wp_wpn_fps_pis_welrod_glow = "They're supposed to glow out of the factory, but time likes to fade things out.",

	-- PB
	bm_w_pb_desc = "A Makarov derivative developed for KGB use. Extensively redesigned for a two-piece integral suppressor, allowing the choice between greater concealment or silent shooting.",
	bm_wp_wpn_fps_pis_pb_ns_std_desc = "" .. silstr,

	-- g3 various attachment
	bm_wp_wpn_fps_upg_g3_bipod_desc = bipodstr,

	-- browning auto-5
	bm_w_auto5 = "Browning Auto-5",
	bm_w_auto5_desc = "The world's first successful semi-automatic shotgun. Named for its five-shell capacity, including one in the chamber. Remained in production for nearly a century, so you know it's good.",

	-- m40a5
	bm_w_m40a5_desc = "Sniper rifle standardized for the USMC during the Vietnam War. What was once a civilian rifle has been modified to feature a free-floating barrel, fiberglass stock, and detachable magazine.",
	bm_wp_wpn_fps_upg_m40a5_omega_desc = "A marine, sufficiently angered, suddenly becomes so quiet as to make one wish he'd be loud again." .. silstr3,

	-- PKA-S sight
	bm_wp_wpn_fps_upg_o_pkas_desc = "Reflex sight with backup black dot in the event that you refuse to replace the batteries.\n\nZoom level 3.",

	-- trijicon acog ta648
	bm_wp_wpn_fps_upg_o_ta648_desc = "Fiber-optic/tritium-illuminated sight with more bullet drop compensators than you'll ever use.\n\nZoom level 6.",

	-- desert tech MDR
	bm_w_mdr_desc = "The battle rifle for the length-conscious man. Being fully ambidextrous and as short as can be, it's also good for lefties who don't feel the need to compensate.",

	-- fn scar-l
	bm_w_scarl_desc = "The forgotten little brother. Though a competent rifle in its own right, reality conspires to make spending on a complete replacement of multiple extant rifle types for marginal gain an unattractive use of limited budget.",
	bm_wp_wpn_fps_upg_scarl_mag_pdw_desc = "It's short, but there's nothing sweet about being on the receiving end of twenty rounds.",
	bm_wp_wpn_fps_upg_scarl_mag_pull_assist_desc = speedpulldesc,
	bm_wp_wpn_fps_upg_scarl_upper_pdw = "It makes sense, but you're still holding a cartoon.",

	-- scar-l + m203
	bm_w_scar_m203_desc = "With its larger brother receiving 5.56x45mm conversion kits the little one has been removed from SOCOM inventory. It'd be a shame if it and a certain other toy ended up in your hands instead.",
	bm_wp_wpn_fps_upg_scar_m203_mag_pull_assist_desc = speedpulldesc,
	bm_wp_wpn_fps_upg_scar_m203_buckshot = "M576 Buckshot",
	bm_wp_wpn_fps_upg_scar_m203_buckshot_desc = "Effectively a 40mm shotgun shell packed with 00 buckshot.\n\nDamage: 500\nAccuracy: 20\nFalloff Ranges: 10m/25m",
	bm_wp_wpn_fps_upg_scar_m203_flechette = "Beehive APERS-T",
	bm_wp_wpn_fps_upg_scar_m203_flechette_desc = "Anti-personnel flechette round developed while flechettes were still in vogue.\n\nDamage: 375\nAccuracy: 40\nFalloff Ranges: 12m/31m",
	bm_wp_wpn_fps_upg_scar_m203_incen = "Incendiary Grenade",

	-- kar98k
	bm_w_kar98k_desc = "Became the standard service rifle for the Wehrmacht a few years before World War 2, and ended its lifetime in 1945. The Soviets confiscated most of these rifles, and therefore the Karabiner 98k still appears in times of conflict around the world.",

	-- golden gun
	bm_w_goldgun_desc = "A weapon assembled from a set of unlikely-seeming items. Fires custom bullets made of gold, which is significantly denser than lead and perhaps a bit ostentatious, not to mention a feat of propellant.",

	-- SKS
	bm_w_sks_desc = "A vanguard of the trend towards intermediate rifles during and after WW2. The SKS remained in use despite the AK's imminent arrival obsoleting it due to its use outside of the Soviet Union, leading to high production numbers.",
	bm_wp_wpn_fps_upg_sks_supp_dtk4_desc = silstr,
	bm_wp_wpn_fps_upg_sks_supp_pbs1 = silstr,
	bm_wp_wpn_fps_upg_sks_mag_tapco_desc = "THERE WAS NOTHING WRONG WITH THE STANDARD MAGAZINE",

	-- mas-49
	bm_w_mas49_desc = "French post-WW2 semi-automatic rifle. Eight years after introduction, a shortened version was designed, mass-produced, and widely issued to the French military. Carries with it a reputation for reliability under harsh conditions.",
	bm_wp_wpn_fps_upg_mas49_barrel_short_desc = "Shortened even beyond what the MAS-49/56 offers.",

	-- ak-12
	bm_w_ak12_200_desc = "2013 prototype of Russia's new service rifle featuring 1000 RPM three-round burst mode. Due to unspecified issues, this model was cancelled and a different AK variant as base for the final design.",
	bm_wp_wpn_fps_upg_ak12_barrel_svk12 = "SVK-2013",
	bm_wp_wpn_fps_upg_ak12_barrel_svk12_desc = "Hypothetical 7.62x51mm NATO DMR variant, brought to life.\n\n-56% ammo scavenge.",
	bm_wp_wpn_fps_upg_ak12_barrel_ak12u = "AK-2013U Barrel",
	bm_wp_wpn_fps_upg_ak12_barrel_ak12u_desc = "Hypothetical carbine variant, brought to life.",
	bm_wp_wpn_fps_upg_ak12_barrel_rpk12 = "RPK-2013 Barrel",
	bm_wp_wpn_fps_upg_ak12_barrel_rpk12_desc = "Hypothetical support variant, brought to life.",
	bm_wp_wpn_fps_upg_ak12_mag_magpul_desc = speedpulldesc,

	-- ak-12/76
	bm_w_ak12_76_desc = "Hypothesized development for the 2013 prototype platform. Though not known to be officially proposed at any point, concept images continue to circulate throughout the internet.",
	bm_wp_wpn_fps_upg_ak12_76_mag_magpul_desc = speedpulldesc,

	-- razor amg uh-1
	bm_wp_wpn_fps_upg_o_razoramg_desc = "Zero-distortion close combat sight.",

	-- trijicon RMR
	bm_wp_wpn_fps_upg_o_rmr_riser_desc = "If it can handle being tossed around by a pistol slide, a rifle won't even faze it.",

	-- bm_wp_wpn_fps_
	bm_wp_wpn_fps_upg_il_tritium_desc = tritiumdesc,

	-- M4 SOPMOD
	bm_w_soppo = "CAR-4 SOPMOD II",

	-- Vanilla Styled Mod (and weapon) Pack 1
	-- 2 when?
	bm_w_amr12_desc = "A macgyvered shotgun variant of the AMR-16, meant to compete with the SAIGA-12. A total abomination, but gets the job done nonetheless.",
	bm_w_aknato_desc = "The AK's take on the CAR-4 platform. Atypically for an AK, it fires 5.56.",
	bm_w_sg416_desc = "Very similar to the CAR-4, the SG-416 boasts high customizability and that trademark precision German engineering.",
	bm_w_sgs_desc = "KG 552 Commando modified to shoot .308 Winchester. A truly frightening marksman rifle.",
	bm_w_lebman = "Crosskill .38 Auto",
	bm_w_x_lebman = "Akimbo Crosskill .38 Auto",
	bm_w_lebman_desc = "A full-auto Crosskill conversion, modified to shoot .38 Super. Mind the recoil.",
	bm_w_cold_desc = "The original Crosskill from the New York days. Found in an old unopened box in the old safehouse.",
	bm_w_smolak_desc = "Gage had the bizarre idea of trying to turn old leftover AK parts into a pistol. The result is this. Please don't tell Ivan.",
	bm_w_ak5s_desc = "Experimental AK-5 SMG variant, reluctantly shared by Wolf.",
	bm_w_car9_desc = "Very similarly to the CAR-23 Para, the ACAR-9 is an SMG on the CAR platform. Custom barrel and flip-up iron sights.",
	bm_w_spike_desc = "A full-length rifle variant of the GRIMM Bullpup Shotgun. The ultimate mall ninja AK.",
	bm_w_beck_desc = "Stashed away behind a fake brick wall in the old safehouse. Its days of shattering visor glass might be over, but that doesn't mean it isn't still brutally effective.",

	bm_w_x_lebman_desc = "Slander is deadly at any range, but a pair of bullet hoses is arguably more effective up close.",
	bm_w_x_cold_desc = "If the action is the juice for you, why do you always choose the path of more money?",
	bm_w_x_smolak_desc = "Greed is good, but is more greed always better?",
	bm_w_x_car9_desc = "You can't improve perfection, but nothing is truly perfect.",
	bm_w_x_ak5s_desc = "Dangerous freedom is better than peaceful slavery. But when forced to bear the responsibility either way, are you truly free?",

	bm_wp_wpn_fps_sho_saiga_upper_receiver_smooth_desc = "It's not being cheap, it's 'manufacturing efficiency'.",

	bm_w_minibeck_desc = "A miniature semi-auto variant of the Reinbeck M1. Just as effective up close, but lacks range. Absolutely not a sharpshooter weapon, no matter what Hoxton tells you.",

	-- Ivans legacy smolak/draco pistol parts
	bm_wp_wpn_fps_pis_smolak_fg_polymer_desc = "Polymer foregrip for those nighttime Soviet compound infiltrations.",
	bm_wp_wpn_fps_pis_smolak_fg_polymer_desc_fine = "MIGHT AS WELL SEND SERGEI BIRTHDAY CARD. \"HAPPY BIRTHDAY SERGEI! I PISS ON ALL YOU CREATE!\"",
	bm_wp_wpn_fps_pis_smolak_m_custom_desc = "Magazine with speedpull sleeve to ease removal during combat.",
	bm_wp_wpn_fps_pis_smolak_m_custom_desc_fine = "I AM CONGRATULATE. YOU ARE NOW SPETSNAZ. MAKE SURE ENEMY DOES NOT SEE TEDDY BEAR OR HE MAYBE SO AFRAID HE SHITS IN PANTS.",

	-- Flak Jacket Desc
	bm_armor_level_5_desc = "Medium movement penalty, medium visibility, +50% ammo pickup.\n\nThe flak jacket by Gensec Security Industries is a modern take on the classic version. It absorbs the impact from firearm projectiles and shrapnel from explosions.\n\nIt combines a heavy ballistic vest with shoulder and side protection armor components, offering spine protection as well.\n\nFlak jackets are worn by Marines, combat soldiers and Gensec FTSU task forces.",
	-- !!

	-- Vanilla mod pack 2
	-- Hornet .300
	bm_w_bdgr_desc = "Your enemies are deathly allergic to the Hornet .300's silent sting.",

	-- Shadow Warrior 2 pack and Deck-ARD
	bm_w_uzi_lowang_desc = "Spray and pray. Maybe concentrate on praying.",
	bm_w_x_uzi_lowang_desc = "Baldness cannot just be forced, it must be earned.",

	bm_w_deckard_desc = "A revolver from the future. Contrary to popular belief, it works just as well on cops as it does on Replicants.",
	bm_w_x_deckard_desc = "Who wants some Wang?",

	-- McMillan CS5
	bm_w_cs5_desc = "A sniper rifle dedicated to being stealthy and concealable in urban environments. Originally meant for the military, but that won't stop you.",
	bm_wp_wpn_fps_upg_cs5_barrel_suppressed_desc = "It's not a rude surprise if they never see it coming." .. silstr3,
	bm_wp_wpn_fps_upg_cs5_harris_bipod_desc = "Press $BTN_GADGET to deploy. When deployed, reduce recoil by 50% and increase rate of fire by 25%.",

	-- who the fuck thought it was a good idea to cover the center of the screen with text exactly when you want to make a quick and accurate shot
	hud_suspicion_detected = ""

	})
end
end)