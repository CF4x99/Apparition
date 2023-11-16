CompleteSoulbox(box)
{
	if(!isDefined(box) || box.n_souls_absorbed >= 30)
		return;
	
	curs = self getCursor();
    menu = self getCurrent();
	
	while(isDefined(box))
	{
		if(box.n_souls_absorbed < 30)
			box notify("soul_absorbed", self);
		
		wait 0.01;
	}

	self RefreshMenu(menu, curs, true);
}

OriginsSetWeather(weather)
{
    level.last_snow_round = 0;
    level.last_rain_round = 0;
    int = RandomIntRange(1, 5);
    
    switch(weather)
    {
        case "Rain":
            level.weather_snow = 0;
            level.weather_rain = int;
            level.weather_vision = 1;

            level util::set_lighting_state(1);
            break;
		
        case "Snow":
            level.weather_snow = int;
            level.weather_rain = 0;
            level.weather_vision = 2;

            level util::set_lighting_state(0);
            break;
		
        case "None":
            level.weather_snow = 0;
            level.weather_rain = 0;
            level.weather_vision = 3;

            level util::set_lighting_state(0);
            break;
		
        default:
            break;
    }
    
    level clientfield::set("rain_level", level.weather_rain);
    level clientfield::set("snow_level", level.weather_snow);
    
    foreach(player in level.players)
        if(zombie_utility::is_player_valid(player, 0, 1))
            player clientfield::set_to_player("player_weather_visionset", level.weather_vision);
}

SetGeneratorState(generator)
{
    generators = struct::get_array("s_generator", "targetname");

    struct = generators[generator];

    if(struct flag::get("zone_contested"))
        struct kill_all_capture_zombies();
    
    struct flag::clear("zone_contested");

    foreach(e_player in level.players)
        e_player thread zm_craftables::player_show_craftable_parts_ui(undefined, "zmInventory.capture_generator_wheel_widget", 0);
    
    if(!struct flag::get("player_controlled"))
    {
        level.zone_capture.last_zone_captured = struct;

        struct flag::set("player_controlled");
        struct flag::clear("attacked_by_recapture_zombies");
        level clientfield::set("zone_capture_hud_generator_" + struct.script_int, 1);
        level clientfield::set("zone_capture_monolith_crystal_" + struct.script_int, 0);

        if(!isDefined(struct.perk_fx_func) || [[ struct.perk_fx_func ]]())
            level clientfield::set("zone_capture_perk_machine_smoke_fx_" + struct.script_int, 1);

        struct flag::set("player_controlled");

        struct enable_perk_machines_in_zone();
        struct enable_random_perk_machines_in_zone();
        struct enable_mystery_boxes_in_zone();
        struct function_c3b54f6d();

        level notify("zone_captured_by_player", struct.str_zone);
        PlayFX(level._effect["capture_complete"], struct.origin);

		struct reward_players_in_capture_zone();
    }
    else
    {
        struct flag::clear("player_controlled");
        level clientfield::set("zone_capture_hud_generator_" + struct.script_int, 2);
        level clientfield::set("zone_capture_monolith_crystal_" + struct.script_int, 1);
        level clientfield::set("zone_capture_perk_machine_smoke_fx_" + struct.script_int, 0);

        struct disable_perk_machines_in_zone();
        struct disable_random_perk_machines_in_zone();
        struct disable_mystery_boxes_in_zone();
        struct function_1138b343();
    }

    update_captured_zone_count();
    struct.n_current_progress = struct flag::get("player_controlled") ? 100 : 0;
    struct.n_last_progress = struct.n_current_progress;
    level clientfield::set("state_" + struct.script_noteworthy, struct flag::get("player_controlled") ? 2 : 4);
    level clientfield::set(struct.script_noteworthy, struct.n_current_progress / 100);
    play_pap_anim(struct flag::get("player_controlled"));
}

kill_all_capture_zombies()
{
	while(isDefined(self.capture_zombies) && self.capture_zombies.size > 0)
	{
		foreach(var_31f13232, zombie in self.capture_zombies)
		{
			if(isDefined(zombie) && IsAlive(zombie))
			{
				PlayFX(level._effect["tesla_elec_kill"], zombie.origin);
				zombie DoDamage(zombie.health + 100, zombie.origin);
			}

			util::wait_network_frame();
		}

		self.capture_zombies = array::remove_dead(self.capture_zombies);
	}

	self.capture_zombies = [];
}

update_captured_zone_count()
{
	level.total_capture_zones = get_captured_zone_count();

	if(level.total_capture_zones == 6)
		level flag::set("all_zones_captured");
	else
		level flag::clear("all_zones_captured");
}

get_captured_zone_count()
{
	n_player_controlled_zones = 0;

	foreach(var_df4e052f, generator in level.zone_capture.zones)
		if(generator flag::get("player_controlled"))
			n_player_controlled_zones++;

	return n_player_controlled_zones;
}

enable_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines) && IsArray(self.perk_machines))
	{
		a_keys = GetArrayKeys(self.perk_machines);

		for(a = 0; a < a_keys.size; a++)
		{
			level notify(a_keys[a] + "_on");

			e_perk_trigger = self.perk_machines[a_keys[a]];
			e_perk_trigger.is_locked = 0;
			e_perk_trigger zm_perks::reset_vending_hint_string();
		}
	}
}

enable_random_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines_random) && IsArray(self.perk_machines_random))
	{
		foreach(var_f4b001f6, random_perk_machine in self.perk_machines_random)
		{
			random_perk_machine.is_locked = 0;

			if(isDefined(random_perk_machine.current_perk_random_machine) && random_perk_machine.current_perk_random_machine)
			{
				random_perk_machine set_perk_random_machine_state("idle");
				continue;
			}

			random_perk_machine set_perk_random_machine_state("away");
		}
	}
}

set_perk_random_machine_state(state)
{
	wait 0.1;

	for(i = 0; i < self GetNumZBarrierPieces(); i++)
		self HideZBarrierPiece(i);

	self notify("zbarrier_state_change");
	self [[ level.perk_random_machine_state_func ]](state);
}

enable_mystery_boxes_in_zone()
{
	foreach(var_ee5097f2, mystery_box in self.mystery_boxes)
	{
		mystery_box.is_locked = 0;

		mystery_box.zbarrier [[ level.magic_box_zbarrier_state_func ]]("player_controlled"); 
		mystery_box.zbarrier clientfield::set("magicbox_runes", 1);
	}
}

function_c3b54f6d()
{
	level flag::set("power_on" + self.script_int);
}

disable_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines) && IsArray(self.perk_machines))
	{
		a_keys = GetArrayKeys(self.perk_machines);

		for(a = 0; a < a_keys.size; a++)
		{
			level notify(a_keys[a] + "_off");

			e_perk_trigger = self.perk_machines[a_keys[a]];
			e_perk_trigger.is_locked = 1;
			e_perk_trigger SetHintString(&"ZM_TOMB_ZC");
		}
	}
}

disable_random_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines_random) && IsArray(self.perk_machines_random))
	{
		foreach(var_77085d2, random_perk_machine in self.perk_machines_random)
		{
			random_perk_machine.is_locked = 1;

			if(isDefined(random_perk_machine.current_perk_random_machine) && random_perk_machine.current_perk_random_machine)
			{
				random_perk_machine set_perk_random_machine_state("initial");
				continue;
			}

			random_perk_machine set_perk_random_machine_state("power_off");
		}
	}
}

disable_mystery_boxes_in_zone()
{
	foreach(var_c5cf7f78, mystery_box in self.mystery_boxes)
	{
		mystery_box.is_locked = 1;

		mystery_box.zbarrier [[ level.magic_box_zbarrier_state_func ]]("zombie_controlled");
		mystery_box.zbarrier clientfield::set("magicbox_runes", 0);
	}
}

function_1138b343()
{
	var_43157bc9 = "power_on" + self.script_int;
	level flag::clear(var_43157bc9);
}

play_pap_anim(b_assemble)
{
	level clientfield::set("packapunch_anim", get_captured_zone_count());
}

GivePlayerShovel(player)
{
    player.dig_vars["has_shovel"] = !player.dig_vars["has_shovel"];
    player.dig_vars["has_upgraded_shovel"] = player.dig_vars["has_shovel"];
    player.dig_vars["has_helmet"] = player.dig_vars["has_shovel"];

    level clientfield::set("player" + player GetEntityNumber() + "hasItem", player.dig_vars["has_shovel"]);
}

GetGatewayState(gateway)
{
    return level flag::get("enable_teleporter_" + gateway.script_int);
}

SetGatewayState(gateway)
{
    target = struct::get_array("stargate_gramophone_pos", "targetname")[gateway.script_int];

    if(!GetGatewayState(gateway))
    {
        level flag::set("enable_teleporter_" + gateway.script_int);

        if(isDefined(target.script_flag))
            level flag::set(target.script_flag);
    }
    else
    {
        level flag::clear("enable_teleporter_" + gateway.script_int);

        if(isDefined(target.script_flag))
            level flag::clear(target.script_flag);
    }
}

ReturnGatewayName(targetname)
{
    switch(targetname)
    {
        case "fire_teleport_player":
            return "Fire";
		
        case "air_teleport_player":
            return "Wind";
		
        case "water_teleport_player":
            return "Ice";
		
        case "electric_teleport_player":
            return "Lightning";
		
        default:
            return "Unknown";
    }
}

MudSlowdown()
{
    level.a_e_slow_areas = isDefined(level.a_e_slow_areas) ? undefined : GetEntArray("player_slow_area", "targetname");
}

CompleteOriginChallenge(challenge, player)
{
	stat = get_stat(challenge, player);

	if(stat.b_medal_awarded)
		return;
	
	if(stat.n_value < stat.s_parent.n_goal)
	{
		diff = (stat.s_parent.n_goal - stat.n_value);
		player increment_stat(challenge, diff);
	}
}

reward_players_in_capture_zone()
{
	b_challenge_exists = challenge_exists("zc_zone_captures");

	if(self flag::get("player_controlled"))
	{
		foreach(var_a6c07c28, player in GetPlayers())
		{
			player notify("completed_zone_capture");

			if(b_challenge_exists)
				player increment_stat("zc_zone_captures");
		}
	}
}

challenge_exists(str_name)
{
	return isDefined(level._challenges.a_stats[str_name]);
}

increment_stat(str_stat, n_increment = 1)
{
	s_stat = get_stat(str_stat, self);
    
	if(!s_stat.b_medal_awarded)
	{
		s_stat.n_value = s_stat.n_value + n_increment;
		check_stat_complete(s_stat);
	}
}

get_stat(str_stat, player)
{
	return level._challenges.a_stats[str_stat].b_team ? level._challenges.s_team.a_stats[str_stat] : level._challenges.a_players[player.characterindex].a_stats[str_stat];
}

check_stat_complete(s_stat)
{
	if(s_stat.b_medal_awarded)
		return 1;

	if(s_stat.n_value >= s_stat.s_parent.n_goal)
	{
		s_stat.b_medal_awarded = 1;

		if(s_stat.s_parent.b_team)
		{
			s_team_stats = level._challenges.s_team;
			s_team_stats.n_completed++;
			s_team_stats.n_medals_held++;
			a_players = GetPlayers();

			foreach(var_9df16521, player in a_players)
			{
				player clientfield::set_to_player(s_stat.s_parent.cf_complete, 1);
				player function_fbbc8608(s_stat.s_parent.str_hint, s_stat.s_parent.n_index);
				player PlaySound("evt_medal_acquired");

				util::wait_network_frame();
			}
		}
		else
		{
			s_player_stats = level._challenges.a_players[self.characterindex];
			s_player_stats.n_completed++;
			s_player_stats.n_medals_held++;

			self PlaySound("evt_medal_acquired");
			self clientfield::set_to_player(s_stat.s_parent.cf_complete, 1);
			self function_fbbc8608(s_stat.s_parent.str_hint, s_stat.s_parent.n_index);
		}

		foreach(var_b057f17e, m_board in level.a_m_challenge_boards)
			m_board ShowPart(s_stat.str_glow_tag);

		if(IsPlayer(self))
		{
			if(level._challenges.a_players[self.characterindex].n_completed + level._challenges.s_team.n_completed == level._challenges.a_stats.size)
				self notify("all_challenges_complete");
		}
		else
		{
			foreach(var_f51cc11b, player in GetPlayers())
				if(isDefined(player.characterindex))
					if(level._challenges.a_players[player.characterindex].n_completed + level._challenges.s_team.n_completed == level._challenges.a_stats.size)
						player notify("all_challenges_complete");
		}

		util::wait_network_frame();
	}
}

function_fbbc8608(str_hint, var_7ca2c2ae)
{
	self luinotifyevent(&"trial_complete", 3, &"ZM_TOMB_CHALLENGE_COMPLETED", str_hint, var_7ca2c2ae);
}











//Ice Staff

CompleteIceTiles()
{
	if(level flag::get("ice_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
	
	if(isDefined(level.IceTilesInit))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	level.IceTilesInit = true;
	
	curs = self getCursor();
    menu = self getCurrent();
	ice_gem = GetEnt("ice_chamber_gem", "targetname");

	while(!level flag::get("ice_puzzle_1_complete"))
	{
		if(isDefined(level.unsolved_tiles) && level.unsolved_tiles.size)
		{
			if(!isDefined(ice_gem))
				break;
			
			foreach(tile in level.unsolved_tiles)
			{
				if(!isDefined(tile) || ice_gem.value != tile.value || !tile.showing_tile_side)
					continue;
				
				tile notify("damage", 1, self, (0, 0, 0), tile.origin, undefined, undefined, undefined, undefined, GetWeapon("staff_water"));
			}
		}

		wait 0.01;
	}

	wait 0.1;

	self RefreshMenu(menu, curs);
}

CompleteIceTombstones()
{
	if(!level flag::get("ice_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7Tiles Must Be Completed Before Using This Option");
	
	if(level flag::get("ice_puzzle_2_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
	
	if(isDefined(level.IceTombstones))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	level.IceTombstones = true;
	
	curs = self getCursor();
    menu = self getCurrent();
	tombstones = struct::get_array("puzzle_stone_water", "targetname");

	while(!level flag::get("ice_puzzle_2_complete"))
	{
		if(isDefined(tombstones) && tombstones.size)
		{
			foreach(tombstone in tombstones)
			{
				if(!isDefined(tombstone) || !isDefined(tombstone.e_model))
					continue;
				
				if(tombstone.e_model.model != "p7_zm_ori_note_rock_01_anim")
				{
					tombstone.e_model notify("damage", 1, self, (0, 0, 0), tombstone.e_model.origin, undefined, undefined, undefined, undefined, GetWeapon("staff_water"));

					wait 0.5;
				}

				tombstone.e_model notify("damage", 1, self, (0, 0, 0), tombstone.e_model.origin, "BULLET", undefined, undefined, undefined, level.start_weapon);
			}
		}

		wait 0.01;
	}

	wait 0.1;

	self RefreshMenu(menu, curs);
}








//Wind Staff

CompleteWindRings()
{
	if(level flag::get("air_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
	
	if(isDefined(level.WindRings))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	curs = self getCursor();
    menu = self getCurrent();
	level.WindRings = true;

	if(!isDefined(level.a_ceiling_rings))
		level.a_ceiling_rings = GetEntArray("ceiling_ring", "script_noteworthy");
	
	while(!level flag::get("air_puzzle_1_complete"))
	{
		if(isDefined(level.a_ceiling_rings) && level.a_ceiling_rings.size)
		{
			foreach(ring in level.a_ceiling_rings)
			{
				while(ring.position != ring.script_int)
				{
					if(IsSubStr(ring.targetname, "01"))
						point = ring.origin + (120, 0, 0);
					else if(IsSubStr(ring.targetname, "02"))
						point = ring.origin + (180, 0, 0);
					else if(IsSubStr(ring.targetname, "03"))
						point = ring.origin + (240, 0, 0);
					else if(IsSubStr(ring.targetname, "04"))
						point = ring.origin + (300, 0, 0);

					ring notify("damage", 1, self, (0, 0, 0), point, undefined, undefined, undefined, undefined, GetWeapon("staff_air"));

					wait 1;
				}

				wait 0.1;
			}
		}

		wait 0.01;
	}

	wait 0.1;

	self RefreshMenu(menu, curs);
}

CompleteWindSmoke()
{
	if(!level flag::get("air_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7Rings Must Be Completed Before Using This Option");
	
	if(level flag::get("air_puzzle_2_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
	
	if(isDefined(level.WindSmoke))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	level.WindSmoke = true;

	curs = self getCursor();
    menu = self getCurrent();
	smokes = struct::get_array("puzzle_smoke_origin", "targetname");
	s_dest = struct::get("puzzle_smoke_dest", "targetname");

	foreach(smoke in smokes)
	{
		if(!isDefined(smoke) || !isDefined(smoke.detector_brush))
			continue;
		
		v_to_dest = VectorNormalize(s_dest.origin - smoke.origin);
		smoke.detector_brush notify("damage", 1, self, v_to_dest, undefined, undefined, undefined, undefined, undefined, GetWeapon("staff_air"));
	}

	while(!level flag::get("air_puzzle_2_complete"))
		wait 0.1;
	
	self RefreshMenu(menu, curs);
}









//Fire Staff

ComepleteFireCauldrons()
{
	if(level flag::get("fire_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");

	if(!is_chamber_occupied())
		return self iPrintlnBold("^1ERROR: ^7A Player Must Be In The Crazy Place To Complete This Step");
	
	if(isDefined(level.FireCauldrons))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	level.FireCauldrons = true;
	curs = self getCursor();
    menu = self getCurrent();
	
	if(!isDefined(level.sacrifice_volumes))
		level.sacrifice_volumes = GetEntArray("fire_sacrifice_volume", "targetname");

	if(isDefined(level.sacrifice_volumes) && level.sacrifice_volumes.size)
	{
		foreach(vols in level.sacrifice_volumes)
		{
			if(vols.b_gods_pleased || vols.num_sacrifices_received >= 32)
				continue;
			
			self notify("projectile_impact", GetWeapon("staff_fire"), vols.origin, 100, GetWeapon("staff_fire"));

			for(a = 0; a < 33; a++)
			{
				level notify("vo_try_puzzle_fire1", self);
				vols.num_sacrifices_received++;
				vols.pct_sacrifices_received = (vols.num_sacrifices_received / 32);

				wait 0.1;
			}

			self notify("projectile_impact", GetWeapon("staff_fire"), vols.origin, 100, GetWeapon("staff_fire"));

			vols.b_gods_pleased = 1;

			wait 2;
		}
	}

	while(!level flag::get("fire_puzzle_1_complete"))
		wait 0.1;
	
	self RefreshMenu(menu, curs);
}

is_chamber_occupied()
{
	a_players = GetPlayers();

	foreach(var_e3bb182, e_player in a_players)
		if(is_point_in_chamber(e_player.origin))
			return 1;
	
	return 0;
}

is_point_in_chamber(v_origin)
{
	if(!isDefined(level.s_chamber_center))
	{
		level.s_chamber_center = struct::get("chamber_center", "targetname");
		level.s_chamber_center.radius_sq = (level.s_chamber_center.script_float * level.s_chamber_center.script_float);
	}

	return (Distance2DSquared(level.s_chamber_center.origin, v_origin) < level.s_chamber_center.radius_sq);
}

CompleteFireTorches()
{
	if(!level flag::get("fire_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7The Cauldrons Must Be Filled Before Using This Option");
	
	if(level flag::get("fire_puzzle_2_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
	
	if(isDefined(level.FireTorches))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	level.FireTorches = true;
	curs = self getCursor();
    menu = self getCurrent();
	
	torches = GetEntArray("fire_torch_ternary", "script_noteworthy");

	if(isDefined(torches) && torches.size)
	{
		foreach(torch in torches)
		{
			target = struct::get(torch.target, "targetname");

			if(!isDefined(target) || !target.b_correct_torch)
				continue;
			
			self notify("projectile_impact", GetWeapon("staff_fire"), target.origin, 100, GetWeapon("staff_fire"));

			wait 0.5;
		}
	}

	while(!level flag::get("fire_puzzle_2_complete"))
		wait 0.1;
	
	self RefreshMenu(menu, curs);
}












//Lightning Staff

CompleteLightningSong()
{
	if(level flag::get("electric_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");

	if(!is_chamber_occupied())
		return self iPrintlnBold("^1ERROR: ^7A Player Must Be In The Crazy Place To Complete This Step");
	
	if(isDefined(level.LightningSong))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	level.LightningSong = true;
	curs = self getCursor();
    menu = self getCurrent();

	a_piano_keys = struct::get_array("piano_key", "script_noteworthy");
	order = [11, 7, 3, 7, 4, 2, 9, 5, 3]; //The order is always the same

	for(a = 0; a < 3; a++)
	{
		for(b = (0 + (3 * a)); b < ((0 + (3 * a)) + 3); b++)
		{
			self notify("projectile_impact", GetWeapon("staff_lightning"), a_piano_keys[order[b]].origin);

			wait 0.5;
		}

		wait 5;
	}

	while(!level flag::get("electric_puzzle_1_complete"))
		wait 0.1;
	
	self RefreshMenu(menu, curs);
}

CompleteLightningDials()
{
	if(!level flag::get("electric_puzzle_1_complete"))
		return self iPrintlnBold("^1ERROR: ^7The Song Must Be Completed Before Using This Option");
	
	if(level flag::get("electric_puzzle_2_complete"))
		return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
	
	if(isDefined(level.turndials))
		return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
	
	level.turndials = true;
	curs = self getCursor();
    menu = self getCurrent();

	foreach(relay in level.electric_relays)
	{
		if(relay.position == 2)
			continue;

		while(!isDefined(relay.connections[relay.position]) || relay.connections[relay.position] == "")
		{
			relay.trigger_stub notify("trigger", self);

			wait 0.1;
		}

		wait 0.5;
	}

	while(!level flag::get("electric_puzzle_2_complete"))
		wait 0.1;
	
	self RefreshMenu(menu, curs);
}

//End Staff Puzzles





Align115Rings(type)
{
	if(level flag::get("disc_rotation_active"))
		return self iPrintlnBold("^1ERROR: ^7Rings Are Currently Rotating");
	
	switch(type)
	{
		case "Ice":
			num = 0;
			break;
		
		case "Lightning":
			num = 1;
			break;
		
		case "Fire":
			num = 2;
			break;
		
		case "Wind":
			num = 3;
			break;
		
		default:
			num = 0;
			break;
	}
	
	rings = GetEntArray("crypt_puzzle_disc", "script_noteworthy");
	level flag::set("disc_rotation_active");
	
	foreach(ring in rings)
	{
		if(ring.position == num || !isDefined(ring.target))
			continue;
		
		ring.position = num;

		self RotateTo((self.angles[0], (self.position * 90), self.angles[2]), 1, 0, 0);
		self PlaySound("zmb_crypt_disc_turn");

		wait 0.75;

		self.n_bryce_cake = ((self.n_bryce_cake + 1) % 2);

		if(isDefined(self.var_b1c02d8a))
			self.var_b1c02d8a clientfield::set("bryce_cake", self.n_bryce_cake);
		
		wait 0.25;

		self.n_bryce_cake = ((self.n_bryce_cake + 1) % 2);

		if(isDefined(self.var_b1c02d8a))
			self.var_b1c02d8a clientfield::set("bryce_cake", self.n_bryce_cake);
		
		self PlaySound("zmb_crypt_disc_stop");
		rumble_nearby_players(self.origin, 1000, 2);

		wait 1;

		level notify("crypt_disc_rotation");
	}

	level flag::clear("disc_rotation_active");
}

rumble_nearby_players(v_center, n_range, n_rumble_enum)
{
	n_range_sq = (n_range * n_range);
	a_players = GetPlayers();
	a_rumbled_players = [];

	foreach(var_19408b7d, e_player in a_players)
	{
		if(DistanceSquared(v_center, e_player.origin) < n_range_sq)
		{
			e_player clientfield::set_to_player("player_rumble_and_shake", n_rumble_enum);
			a_rumbled_players[a_rumbled_players.size] = e_player;
		}
	}

	util::wait_network_frame();

	foreach(var_5bcc30be, e_player in a_rumbled_players)
		e_player clientfield::set_to_player("player_rumble_and_shake", 0);
}