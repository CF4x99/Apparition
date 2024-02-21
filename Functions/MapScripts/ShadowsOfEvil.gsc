PopulateSOEScripts(menu)
{
	switch(menu)
	{
		case "Shadows Of Evil Scripts":
            self addMenu("Shadows Of Evil Scripts");
                self addOpt("Beast Mode", ::newMenu, "Beast Mode");
                self addOpt("Fumigator", ::newMenu, "SOE Fumigator");
                self addOpt("Smashables", ::newMenu, "SOE Smashables");
                self addOpt("Power Switches", ::newMenu, "SOE Power Switches");
                self addOpt("Show Symbol Code", ::SOEShowCode);
            break;
        
        case "Beast Mode":
            self addMenu("Beast Mode");
                
                foreach(player in level.players)
                    self addOptBool((isDefined(player.beastmode) && player.beastmode), CleanName(player getName()), ::PlayerBeastMode, player);
			break;
		
		case "SOE Fumigator":
			self addMenu("Fumigator");
				
				foreach(player in level.players)
					self addOptBool(player clientfield::get_to_player("pod_sprayer_held"), CleanName(player getName()), ::SOEGrabFumigator, player);
			break;
        
        case "SOE Smashables":
            self addMenu("Smashables");

                if(SOESmashablesRemaining())
                {
                    foreach(smashable in GetEntArray("beast_melee_only", "script_noteworthy"))
                    {
                        target = GetEnt(smashable.target, "targetname");

                        if(!isDefined(target))
                            continue;
                        
                        self addOpt(ReturnSOESmashableName(CleanString(smashable.targetname)), ::TriggerSOESmashable, smashable);
                    }
                }
            break;
        
        case "SOE Power Switches":
            self addMenu("Power Switches");

                if(SOEPowerSwitchesRemaining())
                {
                    foreach(ooze in GetEntArray("ooze_only", "script_noteworthy"))
                    {
                        if(IsSubStr(ooze.targetname, "keeper_sword") || IsSubStr(ooze.targetname, "ee_district_rail"))
                            continue;
                        
                        self addOpt(ReturnSOEPowerName(ooze.script_int), ::TriggerSOEESwitch, ooze);
                    }
                }
            break;
	}
}

PlayerBeastMode(player)
{
    curs = self getCursor();
    menu = self getCurrent();

	player endon("disconnect");

    if(!isDefined(player.beastmode) || isDefined(player.beastmode) && !player.beastmode)
    {
		player.altbody = 1;
		player.var_b2356a6c = player.origin;
		player.var_227fe352 = player.angles;
        player SetPerk("specialty_playeriszombie");
        player thread function_72c3fae0(1);
        player SetCharacterBodyType(level.var_3f7a17f["beast_mode"]);
        player SetCharacterBodyStyle(0);
        player SetCharacterHelmetStyle(0);
        player clientfield::set_to_player("player_in_afterlife", 1);
        player function_96a57786("beast_mode");
        player thread function_43af326a("beast_mode");
        callback = level.altbody_enter_callbacks["beast_mode"];

        if(isDefined(callback))
            player [[ callback ]]("beast_mode");

        player clientfield::set("player_altbody", 1);

		player thread BeastModeWatchForCancel();
    }
    else
		player notify("altbody_end");

    wait 0.1;
    self RefreshMenu(menu, curs);
}

Exit_BeastMode()
{
	self endon("disconnect");

	self.altbody = 0;
	self clientfield::set("player_altbody", 0);
	self clientfield::set_to_player("player_in_afterlife", 0);
	callback = level.altbody_exit_callbacks["beast_mode"];

	if(isDefined(callback))
		self [[ callback ]]("beast_mode");

	if(!isDefined(self.altbody_visionset))
		self.altbody_visionset = [];

	visionset = level.altbody_visionsets["beast_mode"];

	if(isDefined(visionset))
	{
		visionset_mgr::deactivate("visionset", visionset, self);
		self.altbody_visionset["beast_mode"] = 0;
	}

	self thread function_d97ca744("beast_mode");
	self UnSetPerk("specialty_playeriszombie");
	self DetachAll();
	self thread function_72c3fae0(0);
	self [[ level.givecustomcharacters ]]();
}

BeastModeWatchForCancel()
{
	self endon("death");
	self endon("disconnect");

	self waittill("altbody_end");

	self Exit_BeastMode();
}

function_72c3fae0(washuman)
{
	if(washuman)
		PlayFX(level._effect["human_disappears"], self.origin);
	else
	{
		PlayFX(level._effect["zombie_disappears"], self.origin);
		PlaySoundAtPosition("zmb_player_disapparate", self.origin);
		self PlayLocalSound("zmb_player_disapparate_2d");
	}
}

function_96a57786(name)
{
	self endon("disconnect");

	self bgb::suspend_weapon_cycling();
	loadout = level.altbody_loadouts[name];

	if(isDefined(loadout))
	{
		self DisableWeaponCycling();
		self.get_player_weapon_limit = ::function_9244ee8e;
		self.altbody_loadout[name] = zm_weapons::player_get_loadout();
		self zm_weapons::player_give_loadout(loadout, 0, 1);

		if(!isDefined(self.var_8b5ec154))
			self.var_8b5ec154 = [];

		if(isDefined(self.var_8b5ec154[name]) && self.var_8b5ec154[name])
			self SetEverHadWeaponAll(1);

		self.var_8b5ec154[name] = 1;
		self util::waittill_any_timeout(1, "weapon_change_complete");
		self ResetAnimations();
	}
}

function_9244ee8e(player)
{
	return 16;
}

function_43af326a(name)
{
	self endon("disconnect");

	if(!isDefined(self.altbody_visionset))
		self.altbody_visionset = [];

	visionset = level.altbody_visionsets[name];

	if(isDefined(visionset))
	{
		if(isDefined(self.altbody_visionset[name]) && self.altbody_visionset[name])
		{
			visionset_mgr::deactivate("visionset", visionset, self);
			util::wait_network_frame();
			util::wait_network_frame();

			if(!isDefined(self))
				return;
		}

		visionset_mgr::activate("visionset", visionset, self);
		self.altbody_visionset[name] = 1;
	}
}

function_d97ca744(name, trigger)
{
	self endon("disconnect");

	loadout = level.altbody_loadouts[name];

	if(isDefined(loadout))
	{
		if(isDefined(self.altbody_loadout[name]))
		{
			self zm_weapons::switch_back_primary_weapon(self.altbody_loadout[name].current, 1);
			self.altbody_loadout[name] = undefined;
			self util::waittill_any_timeout(1, "weapon_change_complete");
		}

		self zm_weapons::player_take_loadout(loadout);
		self.get_player_weapon_limit = undefined;
		self ResetAnimations();
		self EnableWeaponCycling();
	}

	self bgb::resume_weapon_cycling();
}

TriggerSOESmashable(smashable)
{
	target = GetEnt(smashable.target, "targetname");

	if(!isDefined(smashable) || !isDefined(target))
		return;
	
	curs = self getCursor();
    menu = self getCurrent();
	
	level notify("beast_melee", self, smashable.origin);

	wait 0.1;
    self RefreshMenu(menu, curs);
}

ReturnSOESmashableName(name)
{
	switch(name)
	{
		case "Pf29459 Auto3":
			return "Canal Apothicon Statue";
		
		case "Pf29461 Auto3":
			return "Junction Apothicon Statue";
		
		case "Pf29468 Auto3":
			return "Waterfront Apothicon Statue";
		
		case "Pf29470 Auto3":
			return "Rift Apothicon Statue";
		
		case "Unlock Quest Key":
			return "Summoning Key";
		
		case "Memento Detective Drop":
			return "Detective Badge";
		
		case "Memento Femme Drop":
			return "Hair Piece";
		
		case "Memento Boxer Drop":
			return "Championship Belt";
		
		case "Smash Trigger Open Slums":
			return "Boxing Gym Door";
		
		case "Smash Unnamed 0":
			return "Loading Dock Door";
		
		case "Canal Portal":
			return "Canal Rift Door";
		
		case "Theater Portal":
			return "Theater Rift Door";
		
		case "Slums Portal":
			return "Slums Rift Portal";
		
		default:
			return "Unknown";
	}
}

SOESmashablesRemaining()
{
	foreach(smashable in GetEntArray("beast_melee_only", "script_noteworthy"))
	{
		target = GetEnt(smashable.target, "targetname");

		if(isDefined(target))
			return true;
	}

	return false;
}

SOEPowerSwitchesRemaining()
{
	foreach(ooze in GetEntArray("ooze_only", "script_noteworthy"))
	{
		if(IsSubStr(ooze.targetname, "keeper_sword") || IsSubStr(ooze.targetname, "ee_district_rail"))
			continue;
		
		return true;
	}

	return false;
}

TriggerSOEESwitch(eswitch)
{
	target = GetEnt(eswitch.target, "targetname");

	if(!isDefined(eswitch) || !isDefined(target))
		return;
	
	curs = self getCursor();
    menu = self getCurrent();
	
	target notify("damage", 1, self, undefined, undefined, undefined, undefined, undefined, undefined, GetWeapon("zombie_beast_lightning_dwl"));

	wait 0.1;
    self RefreshMenu(menu, curs);
}

ReturnSOEPowerName(int)
{
	switch(int)
	{
		case 1:
			return "Quick Revive";
		
		case 2:
			return "Stamin-Up";
		
		case 3:
			return "Mule Kick";
		
		case 4:
			return "Jugger-Nog";
		
		case 5:
			return "Speed Cola";
		
		case 6:
			return "Double Tap";
		
		case 7:
			return "Widow's Wine";
		
		case 11:
			return "Waterfront Stairs";
		
		case 12:
			return "Canal Stairs";
		
		case 13:
			return "Footlight Stairs";
		
		case 14:
			return "Neros Landing Stairs";
		
		case 15:
			return "Rift Power Door";
		
		case 16:
			return "Ruby Rabbit Stairs";
		
		case 20:
			return "Golden Fountain Pen Crane";
		
		case 21:
			return "The Black Lace Door";
		
		case 23:
			return "Canal Power";
		
		default:
			return "unknown";
	}
}

SOEShowCode()
{
	self iPrintlnBold((level.o_canal_beastcode.m_a_codes[0][0] + 1) + " " + (level.o_canal_beastcode.m_a_codes[0][1] + 1) + " " + (level.o_canal_beastcode.m_a_codes[0][2] + 1));
}

SOEGrabFumigator(player)
{
	if(player clientfield::get_to_player("pod_sprayer_held"))
		return;
	
	a_sprayers = struct::get_array("pod_sprayer_location", "targetname");
	a_sprayers = array::randomize(a_sprayers);

	foreach(spray in a_sprayers)
		if(isDefined(spray) && isDefined(spray.trigger))
		{
			spray.trigger notify("trigger", player);
			break;
		}
}