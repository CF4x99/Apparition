PopulateOriginsScripts(menu)
{
    switch(menu)
    {
        case "Origins Scripts":
            self addMenu("Origins Scripts");
                self addOptSlider("Weather", ::OriginsSetWeather, "None;Rain;Snow");
                self addOpt("Generators", ::newMenu, "Origins Generators");
                self addOpt("Gateways", ::newMenu, "Origins Gateways");
                self addOpt("Give Shovel", ::newMenu, "Give Shovel Origins");
                self addOpt("Give Helmet", ::newMenu, "Give Helmet Origins");
                self addOpt("Soul Boxes", ::newMenu, "Soul Boxes");
                self addOpt("Challenges", ::newMenu, "Origins Challenges");
                self addOpt("Staff Puzzles", ::newMenu, "Origins Puzzles");
                self addOptBool(isDefined(level.a_e_slow_areas), "Mud Slowdown", ::MudSlowdown);
                self addOptBool(level.DisableTankCooldown, "Disable Tank Cooldown", ::DisableTankCooldown);
                self addOptIncSlider("Tank Speed [Default = 8]", ::OriginsTankSpeed, 1, 8, 25, 1);
            break;

        case "Origins Generators":
            generators = struct::get_array("s_generator", "targetname");

            self addMenu("Generators");
                self addOptBool(AllOriginsGensActive(), "Enable All", ::EnableAllOriginsGens);

                for(a = 0; a < generators.size; a++)
                {
                    foreach(index, generator in struct::get_array("s_generator", "targetname"))
                    {
                        if(generator.script_int != (a + 1)) //The goal is to put the generators in the correct order 1 - 6
                            continue;

                        self addOptBool(generator flag::get("player_controlled"), "Generator " + generator.script_int, ::SetGeneratorState, index);
                    }
                }
            break;

        case "Origins Gateways":
            gateways = struct::get_array("trigger_teleport_pad", "targetname");

            self addMenu("Gateways");
                self addOptBool(AreAllGateWaysOpen(), "Enable All", ::OpenAllGateways);
                self addOpt("");

                for(a = 0; a < gateways.size; a++)
                    self addOptBool(GetGatewayState(gateways[a]), ReturnGatewayName(gateways[a].target), ::SetGatewayState, gateways[a]);
            break;

        case "Give Shovel Origins":
            self addMenu("Give Shovel");

                foreach(player in level.players)
                    self addOptSlider(CleanName(player getName()), ::GivePlayerShovel, "Normal;Golden", player);
            break;

        case "Give Helmet Origins":
            self addMenu("Give Helmet");

                foreach(player in level.players)
                    self addOptBool(player.dig_vars["has_helmet"], CleanName(player getName()), ::GivePlayerHelmet, player);
            break;


        case "Soul Boxes":
            boxes = GetEntArray("foot_box", "script_noteworthy");

            self addMenu("Soul Boxes");

                if(isDefined(boxes) && boxes.size)
                    foreach(index, box in boxes)
                        self addOpt(ReturnSoulBoxName(box.script_int) + " Soul Box", ::CompleteSoulbox, box);
            break;

        case "Origins Challenges":
            if(!isDefined(self.originsPlayer))
                self.originsPlayer = level.players[0];

            playerArray = [];

            foreach(player in level.players)
                playerArray[playerArray.size] = CleanName(player getName()) + " [" + player GetEntityNumber() + "]";

            self addMenu("Challenges");
                self addOptSlider("Player", ::SetOriginsPlayer, playerArray);

                foreach(challenge in level._challenges.a_stats)
                    self addOptBool(get_stat(challenge.str_name, self.originsPlayer).b_medal_awarded, ReturnOriginsIString(challenge.str_name), ::CompleteOriginChallenge, challenge.str_name, self.originsPlayer);
            break;

        case "Origins Puzzles":
            self addMenu("Puzzles");
                self addOpt("Ice", ::newMenu, "Ice Puzzles");
                self addOpt("Wind", ::newMenu, "Wind Puzzles");
                self addOpt("Fire", ::newMenu, "Fire Puzzles");
                self addOpt("Lightning", ::newMenu, "Lightning Puzzles");
                self addOpt("");
                self addOptSlider("115 Rings", ::Align115Rings, "Ice;Lightning;Fire;Wind");
            break;

        case "Ice Puzzles":
            self addMenu("Ice");
                self addOptBool(level flag::get("ice_puzzle_1_complete"), "Tiles", ::CompleteIceTiles);
                self addOptBool(level flag::get("ice_puzzle_2_complete"), "Tombstones", ::CompleteIceTombstones);
                self addOptBool(level flag::get("staff_water_upgrade_unlocked"), "Damage Orb", ::OriginsDamageOrb, "ice");
            break;

        case "Wind Puzzles":
            self addMenu("Wind");
                self addOptBool(level flag::get("air_puzzle_1_complete"), "Rings", ::CompleteWindRings);
                self addOptBool(level flag::get("air_puzzle_2_complete"), "Smoke", ::CompleteWindSmoke);
                self addOptBool(level flag::get("staff_air_upgrade_unlocked"), "Damage Orb", ::OriginsDamageOrb, "air");
            break;

        case "Fire Puzzles":
            self addMenu("Fire");
                self addOptBool(level flag::get("fire_puzzle_1_complete"), "Fill Cauldrons", ::ComepleteFireCauldrons);
                self addOptBool(level flag::get("fire_puzzle_2_complete"), "Light Torches", ::CompleteFireTorches);
                self addOptBool(level flag::get("staff_fire_upgrade_unlocked"), "Damage Orb", ::OriginsDamageOrb, "fire");
            break;

        case "Lightning Puzzles":
            self addMenu("Lightning");
                self addOptBool(level flag::get("electric_puzzle_1_complete"), "Song", ::CompleteLightningSong);
                self addOptBool(level flag::get("electric_puzzle_2_complete"), "Turn Dials", ::CompleteLightningDials);
                self addOptBool(level flag::get("staff_lightning_upgrade_unlocked"), "Damage Orb", ::OriginsDamageOrb, "lightning");
            break;
    }
}

OriginsSetWeather(weather)
{
    level.last_snow_round = 0;
    level.last_rain_round = 0;

    switch(weather)
    {
        case "Rain":
            level.weather_snow = 0;
            level.weather_rain = RandomIntRange(1, 5);
            level.weather_vision = 1;
            break;

        case "Snow":
            level.weather_snow = RandomIntRange(1, 5);
            level.weather_rain = 0;
            level.weather_vision = 2;
            break;

        case "None":
            level.weather_snow = 0;
            level.weather_rain = 0;
            level.weather_vision = 3;
            break;

        default:
            break;
    }

    level clientfield::set("rain_level", level.weather_rain);
    level clientfield::set("snow_level", level.weather_snow);

    level util::set_lighting_state(weather == "Rain");

    foreach(player in level.players)
        if(zombie_utility::is_player_valid(player, 0, 1))
            player clientfield::set_to_player("player_weather_visionset", level.weather_vision);
}

EnableAllOriginsGens()
{
    allActive = AllOriginsGensActive();

    foreach(index, generator in struct::get_array("s_generator", "targetname"))
    {
        if(!allActive && !generator flag::get("player_controlled") || allActive && generator flag::get("player_controlled"))
            thread SetGeneratorState(index);
    }
}

AllOriginsGensActive()
{
    foreach(index, generator in struct::get_array("s_generator", "targetname"))
        if(!generator flag::get("player_controlled"))
            return false;

    return true;
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
        foreach(zombie in self.capture_zombies)
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

    foreach(generator in level.zone_capture.zones)
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

            self.perk_machines[a_keys[a]].is_locked = 0;
            self.perk_machines[a_keys[a]] zm_perks::reset_vending_hint_string();
        }
    }
}

enable_random_perk_machines_in_zone()
{
    if(isDefined(self.perk_machines_random) && IsArray(self.perk_machines_random))
    {
        foreach(random_perk_machine in self.perk_machines_random)
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
    foreach(mystery_box in self.mystery_boxes)
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
        foreach(random_perk_machine in self.perk_machines_random)
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
    foreach(mystery_box in self.mystery_boxes)
    {
        mystery_box.is_locked = 1;

        mystery_box.zbarrier [[ level.magic_box_zbarrier_state_func ]]("zombie_controlled");
        mystery_box.zbarrier clientfield::set("magicbox_runes", 0);
    }
}

function_1138b343()
{
    level flag::clear("power_on" + self.script_int);
}

play_pap_anim(b_assemble)
{
    level clientfield::set("packapunch_anim", get_captured_zone_count());
}

AreAllGateWaysOpen()
{
    gateways = struct::get_array("trigger_teleport_pad", "targetname");

    foreach(gateway in gateways)
    {
        if(!isDefined(gateway))
            continue;
        
        if(!GetGatewayState(gateway))
            return false;
    }

    return true;
}

OpenAllGateways()
{
    state = !AreAllGateWaysOpen();
    gateways = struct::get_array("trigger_teleport_pad", "targetname");

    foreach(gateway in gateways)
    {
        if(!isDefined(gateway))
            continue;

        if(GetGateWayState(gateway) != state)
            SetGateWayState(gateway);
    }
}

SetGatewayState(gateway)
{
    target = struct::get_array("stargate_gramophone_pos", "targetname")[gateway.script_int];

    if(!GetGatewayState(gateway))
    {
        level flag::set("enable_teleporter_" + gateway.script_int);

        if(isDefined(target) && isDefined(target.script_flag))
            level flag::set(target.script_flag);
    }
    else
    {
        level flag::clear("enable_teleporter_" + gateway.script_int);

        if(isDefined(target) && isDefined(target.script_flag))
            level flag::clear(target.script_flag);
    }
}

GetGatewayState(gateway)
{
    return level flag::get("enable_teleporter_" + gateway.script_int);
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

GivePlayerShovel(type, player)
{
    if(!player.dig_vars["has_shovel"])
    {
        player.dig_vars["has_shovel"] = 1;
        level clientfield::set("player" + player GetEntityNumber() + "hasItem", 1);
        player PlaySound("zmb_craftable_pickup");

        wait 0.1;
    }

    if(type == "Normal")
        return;

    //Golden shovel
    player.dig_vars["has_upgraded_shovel"] = 1;
    level clientfield::set("player" + player GetEntityNumber() + "hasItem", 2);
    player PlaySoundToPlayer("zmb_squest_golden_anything", player);
}

GivePlayerHelmet(player)
{
    if(player.dig_vars["has_helmet"])
        return;

    player.dig_vars["has_helmet"] = 1;
    level clientfield::set("player" + player GetEntityNumber() + "wearableItem", 1);
    player PlaySoundToPlayer("zmb_squest_golden_anything", player);

    if(!isDefined(player.var_8e065802))
        player.var_8e065802 = SpawnStruct();

    player.var_8e065802.model = "c_t7_zm_dlchd_origins_golden_helmet";
    player.var_8e065802.tag = "j_head";
    player.var_ae07e72c = "golden_helmet";
    player Attach(player.var_8e065802.model, player.var_8e065802.tag);

    if(player.characterindex == 1)
        player SetCharacterBodyStyle(2);
}

CompleteSoulbox(box)
{
    if(!isDefined(box))
        return;

    if(Is_True(box.fillingBox) || box.n_souls_absorbed >= 30)
        return self iPrintlnBold("^1ERROR: ^7Soul Box Is Already Being Filled");

    box.fillingBox = BoolVar(box.fillingBox);

    curs = self getCursor();
    menu = self getCurrent();

    while(isDefined(box))
    {
        if(isDefined(box) && box.n_souls_absorbed < 30)
            box notify("soul_absorbed", self);

        wait 0.01;
    }

    self RefreshMenu(menu, curs, true);
}

ReturnSoulBoxName(index)
{
    switch(index)
    {
        case 0:
            return "Pack 'a' Punch";

        case 1:
            return "Generator 4";

        case 2:
            return "Church";

        case 3:
            return "Generator 5";
    }
}

SetOriginsPlayer(playerName)
{
    foreach(player in level.players)
    {
        if(CleanName(player getName()) + " [" + player GetEntityNumber() + "]" == playerName) //I included the players entity number for the case two players have the same name
            self.originsPlayer = player;
    }

    self RefreshMenu(self getCurrent(), self getCursor());
}

ReturnOriginsIString(stat)
{
    switch(stat)
    {
        case "zc_headshots":
            return "ZM_TOMB_CH1";

        case "zc_zone_captures":
            return "ZM_TOMB_CH2";

        case "zc_points_spent":
            return "ZM_TOMB_CH3";

        case "zc_boxes_filled":
            return "ZM_TOMB_CHT";

        default:
            return "Unknown";
    }
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
    if(self flag::get("player_controlled"))
    {
        foreach(player in GetPlayers())
        {
            player notify("completed_zone_capture");

            if(challenge_exists("zc_zone_captures"))
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
    if(level._challenges.a_stats[str_stat].b_team)
        return level._challenges.s_team.a_stats[str_stat];

    return level._challenges.a_players[player.characterindex].a_stats[str_stat];
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
            level._challenges.s_team.n_completed++;
            level._challenges.s_team.n_medals_held++;

            foreach(player in GetPlayers())
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

        foreach(m_board in level.a_m_challenge_boards)
            m_board ShowPart(s_stat.str_glow_tag);

        if(IsPlayer(self))
        {
            if(level._challenges.a_players[self.characterindex].n_completed + level._challenges.s_team.n_completed == level._challenges.a_stats.size)
                self notify("all_challenges_complete");
        }
        else
        {
            foreach(player in GetPlayers())
                if(isDefined(player.characterindex) && level._challenges.a_players[player.characterindex].n_completed + level._challenges.s_team.n_completed == level._challenges.a_stats.size)
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

    if(Is_True(level.IceTilesInit))
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

    if(Is_True(level.IceTombstones))
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

    if(Is_True(level.WindRings))
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

    if(Is_True(level.WindSmoke))
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
    
    if(Is_True(level.FireCauldrons))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");

    if(!is_chamber_occupied())
        return self iPrintlnBold("^1ERROR: ^7A Player Must Be In The Crazy Place To Complete This Step");

    level.FireCauldrons = true;
    curs = self getCursor();
    menu = self getCurrent();
    self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7A Player Must Stay In The Crazy Place While This Step Is Being Completed");

    if(!isDefined(level.sacrifice_volumes))
        level.sacrifice_volumes = GetEntArray("fire_sacrifice_volume", "targetname");

    if(isDefined(level.sacrifice_volumes) && level.sacrifice_volumes.size)
    {
        foreach(vols in level.sacrifice_volumes)
        {
            if(!is_chamber_occupied())
            {
                level.FireCauldrons = undefined;
                return self iPrintlnBold("^1ERROR: ^7Fire Cauldrons Reset -- A Player Must Remain In The Crazy Place While The Step Is Being Completed");
            }

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
    foreach(e_player in GetPlayers())
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

    if(Is_True(level.FireTorches))
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
    
    if(Is_True(level.LightningSong))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");

    if(!is_chamber_occupied())
        return self iPrintlnBold("^1ERROR: ^7A Player Must Be In The Crazy Place To Complete This Step");

    level.LightningSong = true;
    curs = self getCursor();
    menu = self getCurrent();
    self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7A Player Must Stay In The Crazy Place While This Step Is Being Completed");

    order = Array(11, 7, 3, 7, 4, 2, 9, 5, 3); //The order is always the same

    level notify("piano_keys_stop");
	level.a_piano_keys_playing = [];
    wait 4;

    for(a = 0; a < 3; a++)
    {
        if(!is_chamber_occupied())
        {
            level.LightningSong = undefined;
            return self iPrintlnBold("^1ERROR: ^7Lightning Song Reset -- A Player Must Remain In The Crazy Place While The Step Is Being Completed");
        }

        for(b = (0 + (3 * a)); b < (3 + (3 * a)); b++)
        {
            self notify("projectile_impact", GetWeapon("staff_lightning"), struct::get_array("piano_key", "script_noteworthy")[order[b]].origin);
            wait 0.5;
            self iPrintlnBold("Impact: " + level.a_piano_keys_playing.size);
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

    if(Is_True(level.turndials))
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


//This script was thrown together in the matter of a few minutes. So it is a little sloppy and not fully tested :P
// Suggested by: aesthet_ic
OriginsDamageOrb(type)
{
    fixType = (type == "ice") ? "water" : type;

    if(level flag::get("staff_" + fixType + "_upgrade_unlocked"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    menu = self getCurrent();
    curs = self getCursor();

    gems = GetEntArray("crypt_gem", "script_noteworthy");
    gemType = (type == "lightning") ? "elec" : type;

    foreach(gem in gems)
    {
        if(!isDefined(gem) || gem.targetname != "crypt_gem_" + gemType)
            continue;
        
        targetGem = gem;
    }

    if(isDefined(targetGem)) //based on the code, if the gem still exists, then we aren't ready for this step yet.
        return self iPrintlnBold("^1ERROR: ^7This Step Can't Be Completed Yet");

    if(!isDefined(level.damageOrb))
        level.damageOrb = [];
    
    if(Is_True(level.damageOrb[type]))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.damageOrb[type] = true;
    rings = Align115Rings((type == "air") ? "wind" : type);

    if(!Is_True(rings))
    {
        level.damageOrb[type] = undefined;
        return self iPrintlnBold("^1ERROR: ^7Couldn't Align Rings For Orb");
    }

    foreach(ent in GetEntArray("script_model", "classname"))
    {
        if(!isDefined(ent) || ent.model != struct::get(type + "_orb_exit_path", "targetname").model)
            continue;
        
        ent notify("damage", 99, self, (0, 0, 0), ent.origin, undefined, undefined, undefined, undefined, GetWeapon("staff_" + fixType));
    }

    while(!level flag::get("staff_" + fixType + "_upgrade_unlocked"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
    level.damageOrb[type] = undefined;
}



Align115Rings(type)
{
    type = ToLower(type);

    if(level flag::get("disc_rotation_active"))
        return self iPrintlnBold("^1ERROR: ^7Rings Are Currently Rotating");

    switch(type)
    {
        case "ice":
            num = 0;
            break;

        case "lightning":
            num = 1;
            break;

        case "fire":
            num = 2;
            break;

        case "wind":
            num = 3;
            break;

        default:
            num = 0;
            break;
    }

    level flag::set("disc_rotation_active");

    foreach(ring in GetEntArray("crypt_puzzle_disc", "script_noteworthy"))
    {
        if(ring.position == num || !isDefined(ring.target))
            continue;

        ring.position = num;
        ring RotateTo((ring.angles[0], (ring.position * 90), ring.angles[2]), 1, 0, 0);
        ring PlaySound("zmb_crypt_disc_turn");

        wait 0.75;
        ring.n_bryce_cake = ((ring.n_bryce_cake + 1) % 2);

        if(isDefined(ring.var_b1c02d8a))
            ring.var_b1c02d8a clientfield::set("bryce_cake", ring.n_bryce_cake);

        wait 0.25;
        ring.n_bryce_cake = ((ring.n_bryce_cake + 1) % 2);

        if(isDefined(ring.var_b1c02d8a))
            ring.var_b1c02d8a clientfield::set("bryce_cake", ring.n_bryce_cake);

        ring PlaySound("zmb_crypt_disc_stop");
        rumble_nearby_players(ring.origin, 1000, 2);

        wait 1;
        level notify("crypt_disc_rotation");
    }

    level flag::clear("disc_rotation_active");
    return true;
}

rumble_nearby_players(v_center, n_range, n_rumble_enum)
{
    a_rumbled_players = [];

    foreach(e_player in GetPlayers())
    {
        if(DistanceSquared(v_center, e_player.origin) < (n_range * n_range))
        {
            e_player clientfield::set_to_player("player_rumble_and_shake", n_rumble_enum);
            a_rumbled_players[a_rumbled_players.size] = e_player;
        }
    }

    util::wait_network_frame();

    foreach(e_player in a_rumbled_players)
        e_player clientfield::set_to_player("player_rumble_and_shake", 0);
}

MudSlowdown()
{
    level.a_e_slow_areas = isDefined(level.a_e_slow_areas) ? undefined : GetEntArray("player_slow_area", "targetname");
}

DisableTankCooldown()
{
    level notify("EndDisableCooldown");
    level endon("EndDisableCooldown");

    level.DisableTankCooldown = BoolVar(level.DisableTankCooldown);

    while(isDefined(level.DisableTankCooldown))
    {
        level.vh_tank.n_cooldown_timer = 2; //2 seconds is the minimum cooldown time(if it's anything less than 2, then it gets reset to 2)
        level.vh_tank waittill("tank_stop");
    }
}

OriginsTankSpeed(speed)
{
    level notify("EndTankSpeed");
    level endon("EndTankSpeed");

    if(speed != 8)
    {
        while(1)
        {
            while(level.vh_tank flag::get("tank_moving"))
            {
                level.vh_tank SetSpeedImmediate(speed);
                wait 0.5;
            }

            level.vh_tank flag::wait_till("tank_moving");
        }
    }
    else
    {
        if(level.vh_tank flag::get("tank_moving"))
            level.vh_tank SetSpeedImmediate(8);
    }
}