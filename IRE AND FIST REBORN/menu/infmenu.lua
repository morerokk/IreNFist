Hooks:Add('LocalizationManagerPostInit', 'infmenu_wordswordswords', function(loc)
	InFmenu:Load()
	loc:load_localization_file(InFmenu._path .. 'menu/infmenu_en.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'infmenu_init', function(menu_manager)

	MenuCallbackHandler.infsave = function(this, item)
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_donothing = function(this, item)
		-- do nothing
	end

	MenuCallbackHandler.infcb_runkick = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_kickyeet = function(this, item)
		InFmenu.settings.kickyeet = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_dashcontrols = function(this, item)
		InFmenu.settings.dashcontrols = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_slidestealth = function(this, item)
		InFmenu.settings.slidestealth = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_slideloud = function(this, item)
		InFmenu.settings.slideloud = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_slidewpnangle = function(this, item)
		InFmenu.settings.slidewpnangle = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_wallrunwpnangle = function(this, item)
		InFmenu.settings[item:name()] = tonumber(item:value())
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_allpenwalls = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_reloadbreaksads = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_disable_autoreload = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_ene_rainbowassault = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_skulldozersahoy = function(this, item)
		InFmenu.settings.skulldozersahoy = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_sanehp = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_copfalloff = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_copmiss = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_txt_wpnname = function(this, item)
		InFmenu.settings[item:name()] = tonumber(item:value())
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_goldeneye = function(this, item)
		InFmenu.settings[item:name()] = tonumber(item:value())
		InFmenu:Save()
	end
	
	MenuCallbackHandler.infcb_disablefrogmanwarnings = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end


	InFmenu:Load()
	--MenuHelper:LoadFromJsonFile(InFmenu._path .. 'menu/infmenu2.txt', InFmenu, InFmenu.settings)
	MenuHelper:LoadFromJsonFile(InFmenu._path .. 'menu/infmenu.txt', InFmenu, InFmenu.settings)
end)

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_inf_frogman", function(menu_manager, nodes)
	if not InFmenu.settings.disablefrogmanwarnings then
		local fss = BLT.Mods:GetModByName("Full Speed Swarm")
		if not fss or not fss:IsEnabled() then
			return
		end
	
		QuickMenu:new("FSS Detected", "You are using Full Speed Swarm, which breaks some IreNFist features. We strongly recommend removing Full Speed Swarm for the best gameplay experience.\n\nYou can disable this warning in the IreNFist mod options.", {
			[1] = {
				text = "OK",
				is_cancel_button = true
			}
		}):show()
	end
end)
