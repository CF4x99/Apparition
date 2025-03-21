PopulateAscensionScripts(menu)
{
    switch(menu)
    {
        case "Ascension Scripts":
            self addMenu("Ascension Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOpt("Control Lunar Lander", ::ControlLunarLander);
                self addOpt("");

                if(!level flag::get("target_teleported"))
                    self addOpt("Throw Gersch At Generator", ::TeleportGenerator);

                if(!level flag::get("rerouted_power"))
                    self addOpt("Activate Computer", ::ActivateComputer);

                if(!level flag::get("switches_synced"))
                    self addOpt("Activate Switches", ::ActivateSwitches);

                if(!(level flag::get("lander_a_used") && level flag::get("lander_b_used") && level flag::get("lander_c_used") && level flag::get("launch_activated")))
                    self addOpt("Refuel The Rocket", ::RefuelRocket);

                if(!level flag::get("launch_complete"))
                    self addOpt("Launch The Rocket", ::LaunchRocket);

                if(!level flag::get("pressure_sustained"))
                    self addOpt("Complete Time Clock", ::CompleteTimeClock);
                
                if(!level flag::get("passkey_confirmed"))
                    self addOpt("Complete Lander Password", ::CompleteLanderPassword);
                
                if(!level flag::get("weapons_combined"))
                    self addOpt("Send Orb To Space", ::CompleteCosmoOrb);
            break;
    }
}

ControlLunarLander()
{
    if((level.lander_in_use || level flag::get("lander_inuse")) && !Is_True(self.ControlLunarLander))
        return self iPrintlnBold("^1ERROR: ^7Lunar Lander Is In Use");

    if(level.lander_in_use && Is_True(self.ControlLunarLander))
        return self iPrintlnBold("^1ERROR: ^7You're Already Controling The Lunar Lander");

    self endon("disconnect");

    self closeMenu1();
    self.ControlLunarLander = true;
    level.lander_in_use = true;
    level flag::set("lander_inuse");

    lander = GetEnt("lander", "targetname");
    spots = GetEntArray("zipline_spots", "script_noteworthy");
    base = GetEnt("lander_base", "script_noteworthy");
    zipline_door1 = GetEnt("zipline_door_n", "script_noteworthy");
    zipline_door2 = GetEnt("zipline_door_s", "script_noteworthy");
    lander_trig = GetEnt("zip_buy", "script_noteworthy");
    rider_trigger = GetEnt(lander.station + "_riders", "targetname");

    level.LanderSavedPosition = lander.anchor.origin;
    level.LanderSavedAngles = lander.anchor.angles;

    for(a = 0; a < level.players.size; a++)
    {
        player = level.players[a];

        if(!isDefined(player) || !IsAlive(player) || Is_True(player.lander) || !player IsTouching(zipline_door1) && !player IsTouching(zipline_door2) && !player IsTouching(lander_trig) && !player IsTouching(rider_trigger) && !player IsTouching(base) && player != self)
            continue;

        player SetOrigin(spots[a].origin);
        player PlayerLinkTo(spots[a]);

        player.lander = true;
        player.DisableMenuControls = true;

        lander.riders++;
    }

    close_lander_gate(0.05);
    lander thread takeoff_nuke(undefined, 80, 1, rider_trigger);

    lander.anchor MoveTo(lander.anchor.origin + (0, 0, 950), 3, 2, 1);
    lander.anchor thread lander_takeoff_wobble();
    base clientfield::set("COSMO_LANDER_ENGINE_FX", 1);
    SetLanderFX(lander, base, 1);

    lander.anchor waittill("movedone");
    lander.anchor notify("KillWobble");

    wait 1;
    self thread ControlLander(lander);
}

ControlLander(lander)
{
    self endon("disconnect");
    level endon("KillLanderControls");

    base = GetEnt("lander_base", "script_noteworthy");
    self SetMenuInstructions("[{+attack}] - Move Forward\n[{+melee}] - Exit");

    while(1)
    {
        if(self AttackButtonPressed())
        {
            lander.anchor MoveTo(lander.anchor.origin + AnglesToForward(self GetPlayerAngles()) * 60, 0.1);
            lander.anchor thread lander_takeoff_wobble();

            SetLanderFX(lander, base, 1);
        }
        else if(self MeleeButtonPressed())
            break;
        else
        {
            SetLanderFX(lander, base, 0);
            lander.anchor.wobble = false;
        }

        wait 0.1;
    }

    SetLanderFX(lander, base, 1);

    lander.anchor thread lander_takeoff_wobble();
    lander.anchor MoveTo((lander.anchor.origin[0], lander.anchor.origin[1], level.LanderSavedPosition[2] + 950), 3, 2, 1);
    lander.anchor waittill("movedone");

    lander.anchor MoveTo((level.LanderSavedPosition[0], level.LanderSavedPosition[1], level.LanderSavedPosition[2] + 950), 3, 2, 1);
    lander.anchor waittill("movedone");

    SetLanderFX(lander, base, 0);
    lander.anchor.wobble = false;
    lander.anchor waittill("rotatedone");

    lander.anchor thread lander_takeoff_wobble();
    lander.anchor MoveTo(level.LanderSavedPosition, 3, 2, 1);
    player_blocking_lander();
    lander.anchor waittill("movedone");

    lander.anchor.wobble = false;

    PlayFX(level._effect["lunar_lander_dust"], base.origin);
    base clientfield::set("COSMO_LANDER_ENGINE_FX", 0);
    SetLanderFX(lander, base, 0);

    wait 0.5;
    open_lander_gate();

    for(a = 0; a < level.players.size; a++)
    {
        player = level.players[a];

        if(!isDefined(player) || !IsAlive(player) || !Is_True(player.lander))
            continue;

        player Unlink();

        if(Is_True(player.DisableMenuControls))
            player.DisableMenuControls = BoolVar(player.DisableMenuControls);
        
        player.lander = false;
    }

    self SetMenuInstructions();
    lander.riders = 0;
    lander clientfield::set("COSMO_LANDER_MOVE_FX", 0);

    if(Is_True(self.ControlLunarLander))
        self.ControlLunarLander = BoolVar(self.ControlLunarLander);
    
    level.lander_in_use = false;
    level flag::clear("lander_inuse");
}

SetLanderFX(lander, base, state)
{
    if(isDefined(lander) && lander clientfield::get("COSMO_LANDER_MOVE_FX") != state)
        lander clientfield::set("COSMO_LANDER_MOVE_FX", state);

    if(isDefined(base) && base clientfield::get("COSMO_LANDER_RUMBLE_AND_QUAKE") != state)
        base clientfield::set("COSMO_LANDER_RUMBLE_AND_QUAKE", state);
}

lander_takeoff_wobble()
{
    if(Is_True(self.wobble))
        return;

    self.wobble = true;

    while(Is_True(self.wobble))
    {
        self RotateTo((RandomFloatRange(-5, 5), 0, RandomFloatRange(-5, 5)), 0.5);
        wait 0.5;
    }

    self RotateTo(level.LanderSavedAngles, 0.1);
}

open_lander_gate()
{
    lander = GetEnt("lander", "targetname");

    lander.door_north thread move_gate(GetEnt("zipline_door_n_pos", "script_noteworthy"), 1);
    lander.door_south thread move_gate(GetEnt("zipline_door_s_pos", "script_noteworthy"), 1);
}

close_lander_gate(time)
{
    lander = GetEnt("lander", "targetname");

    lander.door_north thread move_gate(GetEnt("zipline_door_n_pos", "script_noteworthy"), 0, time);
    lander.door_south thread move_gate(GetEnt("zipline_door_s_pos", "script_noteworthy"), 0, time);
}

move_gate(pos, lower, time = 1)
{
    lander = GetEnt("lander", "targetname");
    self Unlink();

    if(lower)
    {
        self NotSolid();

        if(self.classname == "script_brushmodel")
            self MoveTo(pos.origin + (VectorScale((0, 0, -1), 132)), time);
        else
        {
            self PlaySound("zmb_lander_gate");
            self MoveTo(pos.origin + (VectorScale((0, 0, -1), 44)), time);
        }

        self waittill("movedone");

        if(self.classname == "script_brushmodel")
            self NotSolid();
    }
    else
    {
        if(self.classname != "script_brushmodel")
            self PlaySound("zmb_lander_gate");

        self NotSolid();
        self MoveTo(pos.origin, time);
        self waittill("movedone");

        if(self.classname == "script_brushmodel")
            self Solid();
    }

    self LinkTo(lander.anchor);
}

takeoff_nuke(max_zombies, range, delay, trig)
{
    if(isDefined(delay))
        wait delay;

    zombies = GetAISpeciesArray("axis");
    spot = self.origin;
    zombies = util::get_array_of_closest(self.origin, zombies, undefined, max_zombies, range);

    for(i = 0; i < zombies.size; i++)
    {
        if(!zombies[i] IsTouching(trig))
            continue;

        zombies[i] thread zombie_burst();
    }

    wait 0.5;
    lander_clean_up_corpses(spot, 250);
}

zombie_burst()
{
    self endon("death");

    wait RandomFloatRange(0.2, 0.3);
    level.zombie_total++;

    PlaySoundAtPosition("nuked", self.origin);
    PlayFX(level._effect["zomb_gib"], self.origin);

    if(isDefined(self.lander_death))
        self [[ self.lander_death ]]();

    self delete();
}

lander_clean_up_corpses(spot, range)
{
    corpses = GetCorpseArray();

    if(isDefined(corpses) && corpses.size)
        for(i = 0; i < corpses.size; i++)
            if(DistanceSquared(spot, corpses[i].origin) <= (range * range))
                corpses[i] thread lander_remove_corpses();
}

lander_remove_corpses()
{
    wait RandomFloatRange(0.05, 0.25);

    if(!isDefined(self))
        return;

    PlayFX(level._effect["zomb_gib"], self.origin);
    self delete();
}

player_blocking_lander()
{
    players = GetPlayers();
    lander = GetEnt("lander", "targetname");
    rider_trigger = GetEnt(lander.station + "_riders", "targetname");
    crumb = struct::get(rider_trigger.target, "targetname");

    for(i = 0; i < players.size; i++)
    {
        if(rider_trigger IsTouching(players[i]))
        {
            players[i] SetOrigin(crumb.origin + (RandomIntRange(-20, 20), RandomIntRange(-20, 20), 0));
            players[i] DoDamage(players[i].health + 10000, players[i].origin);
        }
    }

    zombies = GetAISpeciesArray("axis");

    for(i = 0; i < zombies.size; i++)
    {
        if(isDefined(zombies[i]))
        {
            if(rider_trigger IsTouching(zombies[i]))
            {
                level.zombie_total++;

                PlaySoundAtPosition("nuked", zombies[i].origin);
                PlayFX(level._effect["zomb_gib"], zombies[i].origin);

                if(isDefined(zombies[i].lander_death))
                    zombies[i] [[ zombies[i].lander_death ]]();

                zombies[i] delete();
            }
        }
    }

    wait 0.5;
}

TeleportGenerator()
{
    if(level flag::get("target_teleported"))
        return self iPrintlnBold("^1ERROR: ^7Generator Has Already Been Teleported");
    
    if(Is_True(level.TeleportingGenerator))
        return self iPrintlnBold("^1ERROR: ^7Generator Is Already Being Teleported");
    
    level.TeleportingGenerator = BoolVar(level.TeleportingGenerator);

    self endon("disconnect");

    curs = self getCursor();
    menu = self getCurrent();

    self GivePlayerEquipment(GetWeapon("black_hole_bomb"), self);
    wait 0.01;

    self MagicGrenadeType(GetWeapon("black_hole_bomb"), (-1610, 2770, -203), (0, 0, 0), 1);

    while(!level flag::get("target_teleported"))
        wait 0.1;

    self RefreshMenu(menu, curs);
    level.TeleportingGenerator = BoolVar(level.TeleportingGenerator);
}

ActivateComputer()
{
    if(!level flag::get("target_teleported"))
        return self iPrintlnBold("^1ERROR: ^7Generator Must Be Teleported First");

    if(level flag::get("rerouted_power"))
        return self iPrintlnBold("^1ERROR: ^7Computer Has Already Been Activated");
    
    if(Is_True(level.ActivatingComputer))
        return self iPrintlnBold("^1ERROR: ^7Computer Is Already Being Activated");
    
    level.ActivatingComputer = BoolVar(level.ActivatingComputer);

    self endon("disconnect");

    curs = self getCursor();
    menu = self getCurrent();
    location = struct::get("casimir_monitor_struct", "targetname");

    foreach(trigger in GetEntArray("trigger_radius", "classname"))
    {
        if(trigger.origin == location.origin)
        {
            trigger.origin = self.origin;
            wait 0.01;

            trigger notify("trigger", self);
            wait 0.01;

            if(isDefined(trigger))
                trigger.origin = location.origin;

            break;
        }
    }

    while(!level flag::get("rerouted_power"))
        wait 0.1;

    self RefreshMenu(menu, curs);
    level thread activate_casimir_light(1);
    level.ActivatingComputer = BoolVar(level.ActivatingComputer);
}

ActivateSwitches()
{
    if(!level flag::get("rerouted_power"))
        return self iPrintlnBold("^1ERROR: ^7Computer Must Be Activated First");

    if(level flag::get("switches_synced"))
        return self iPrintlnBold("^1ERROR: ^7Switched Already Activated");

    curs = self getCursor();
    menu = self getCurrent();

    if(!level flag::get("monkey_round"))
        return self iPrintlnBold("^1ERROR: ^7This Can Only Be Done During A Monkey Round");
    
    if(Is_True(level.ActivatingSwitches))
        return self iPrintlnBold("^1ERROR: ^7Switches Are Already Being Activated");
    
    level.ActivatingSwitches = BoolVar(level.ActivatingSwitches);

    foreach(swtch in struct::get_array("sync_switch_start", "targetname"))
    {
        level notify("sync_button_pressed");
        swtch.pressed = true;
    }

    /*level flag::set("switches_synced"); //If you don't want to wait for a monkey round
    level notify("switches_synced");*/

    while(!level flag::get("switches_synced"))
        wait 0.1;

    self RefreshMenu(menu, curs);
    level thread activate_casimir_light(2);
    level.ActivatingSwitches = BoolVar(level.ActivatingSwitches);
}

RefuelRocket()
{
    if(!level flag::get("switches_synced"))
        return self iPrintlnBold("^1ERROR: ^7Switches Must Be Activated First");

    if(level flag::get("lander_a_used") && level flag::get("lander_b_used") && level flag::get("lander_c_used") && level flag::get("launch_activated"))
        return self iPrintlnBold("^1ERROR: ^7Rocket Already Refueled");
    
    if(Is_True(level.RocketRefueling))
        return self iPrintlnBold("^1ERROR: ^7Rocket Is Already Being Refueled");
    
    level.RocketRefueling = BoolVar(level.RocketRefueling);

    curs = self getCursor();
    menu = self getCurrent();
    lander = GetEnt("lander", "targetname");

    if(!level flag::get("lander_a_used"))
    {
        level flag::set("lander_a_used");
        lander clientfield::set("COSMO_LAUNCH_PANEL_BASEENTRY_STATUS", 1);

        wait 0.1;
    }

    if(!level flag::get("lander_b_used"))
    {
        level flag::set("lander_b_used");
        lander clientfield::set("COSMO_LAUNCH_PANEL_CATWALK_STATUS", 1);

        wait 0.1;
    }

    if(!level flag::get("lander_c_used"))
    {
        level flag::set("lander_c_used");
        lander clientfield::set("COSMO_LAUNCH_PANEL_STORAGE_STATUS", 1);

        wait 0.1;
    }

    level flag::set("launch_activated");
    wait 0.1;

    panel = GetEnt("rocket_launch_panel", "targetname");

    if(isDefined(panel))
        panel SetModel("p7_zm_asc_console_launch_key_full_green");

    while(!(level flag::get("lander_a_used") && level flag::get("lander_b_used") && level flag::get("lander_c_used") && level flag::get("launch_activated")))
        wait 0.1;

    self RefreshMenu(menu, curs);
    level.RocketRefueling = BoolVar(level.RocketRefueling);
}

LaunchRocket()
{
    if(!level flag::get("lander_a_used") || !level flag::get("lander_b_used") || !level flag::get("lander_c_used") || !level flag::get("launch_activated"))
        return self iPrintlnBold("^1ERROR: ^7Rocket Must Be Refueled First");
    
    if(Is_True(level.LaunchingRocket))
        return self iPrintlnBold("^1ERROR: ^7The Rocket Is Already Being Launched");

    level.LaunchingRocket = BoolVar(level.LaunchingRocket);

    curs = self getCursor();
    menu = self getCurrent();
    trig = GetEnt("trig_launch_rocket", "targetname");

    if(level flag::get("launch_complete") || !isDefined(trig))
        return self iPrintlnBold("^1ERROR: ^7Rocket Has Already Been Launched");

    if(isDefined(trig))
        trig notify("trigger", self);

    while(!level flag::get("launch_complete"))
        wait 0.1;

    self RefreshMenu(menu, curs);
    level.LaunchingRocket = BoolVar(level.LaunchingRocket);
}

CompleteTimeClock()
{
    if(!level flag::get("launch_complete"))
        return self iPrintlnBold("^1ERROR: ^7Rocket Must Be Launched First");

    if(level flag::get("pressure_sustained"))
        return self iPrintlnBold("^1ERROR: ^7Time Clock Already Completed");
    
    if(Is_True(level.CompletingTimeClock))
        return self iPrintlnBold("^1ERROR: ^7Time Clock Is Currently Being Completed");
    
    level.CompletingTimeClock = BoolVar(level.CompletingTimeClock);

    curs = self getCursor();
    menu = self getCurrent();

    level flag::set("pressure_sustained");

    foreach(model in GetEntArray("script_model", "classname"))
    {
        if(model.model == "p7_zm_kin_clock_second_hand")
            timer_hand = model;

        if(model.model == "p7_zm_tra_wall_clock")
            clock = model;
    }

    if(isDefined(clock))
        clock delete();

    if(isDefined(timer_hand))
        timer_hand delete();

    while(!level flag::get("pressure_sustained"))
        wait 0.1;

    self RefreshMenu(menu, curs);
    level thread activate_casimir_light(3);
    level.CompletingTimeClock = BoolVar(level.CompletingTimeClock);
}

activate_casimir_light(num)
{
    spot = struct::get("casimir_light_" + num, "targetname");

    alreadySpawned = false;

    foreach(ent in GetEntArray("script_model", "classname"))
        if(ent.model == "tag_origin" && ent.origin == spot.origin)
            alreadySpawned = true;

    if(isDefined(spot) && !alreadySpawned)
    {
        light = Spawn("script_model", spot.origin);
        light SetModel("tag_origin");

        light.angles = spot.angles;
        fx = PlayFXOnTag(level._effect["fx_light_ee_progress"], light, "tag_origin");
        level.casimir_lights[level.casimir_lights.size] = light;
    }
}

CompleteLanderPassword()
{
    if(!level flag::get("pressure_sustained"))
        return self iPrintlnBold("^1ERROR: ^7Time Clock Step Needs To Be Completed First");

    if(level flag::get("passkey_confirmed"))
        return self iPrintlnBold("^1ERROR: ^7Lander Password Has Already Been Completed");

    level.passkey_progress = 4;
    level flag::set("passkey_confirmed");
}

CompleteCosmoOrb()
{
    if(!level flag::get("passkey_confirmed"))
        return self iPrintlnBold("^1ERROR: ^7The Lander Password Needs To Be Completed First");

    if(level flag::get("weapons_combined"))
        return self iPrintlnBold("^1ERROR: ^7Orb Has Already Been Sent To Space");

    if(Is_True(level.CompleteCosmoOrb))
        return self iPrintlnBold("^1ERROR: ^7The Orb Is Currently Being Sent To Space");

    level.CompleteCosmoOrb = BoolVar(level.CompleteCosmoOrb);

    level thread play_egg_vox("vox_ann_egg6_success", "vox_gersh_egg6_success", 9);
    level thread wait_for_gersh_vox();
    level flag::set("weapons_combined");
    wait 2;

    PlaySoundAtPosition("zmb_samantha_earthquake", (0, 0, 0));
    PlaySoundAtPosition("zmb_samantha_whispers", (0, 0, 0));
    wait 6;

    level clientfield::set("COSMO_EGG_SAM_ANGRY", 1);
    PlaySoundAtPosition("zmb_samantha_scream", (0, 0, 0));
    wait 6;

    level clientfield::set("COSMO_EGG_SAM_ANGRY", 0);
    level.CompleteCosmoOrb = BoolVar(level.CompleteCosmoOrb);
}

play_egg_vox(ann_alias, gersh_alias, plr_num)
{
    if(isDefined(ann_alias))
        level play_cosmo_announcer_vox(ann_alias);

    if(isDefined(plr_num) && !isDefined(level.var_92ed253c))
    {
        players = GetPlayers();
        rand = RandomIntRange(0, players.size);

        players[rand] PlaySoundWithNotify("vox_plr_" + players[rand].characterindex + "_level_start_" + randomintrange(0, 4), "level_start_vox_done");
        players[rand] waittill("level_start_vox_done");
        level.var_92ed253c = 1;
    }

    if(isDefined(gersh_alias))
        level play_gersh_vox(gersh_alias);

    if(isDefined(plr_num))
        players[RandomIntRange(0, GetPlayers().size)] zm_audio::create_and_play_dialog("eggs", "gersh_response", plr_num);
}

play_cosmo_announcer_vox(alias, alarm_override, wait_override)
{
    if(!isDefined(alias))
        return;

    if(!isDefined(level.cosmann_is_speaking))
        level.cosmann_is_speaking = 0;

    if(!isDefined(alarm_override))
        alarm_override = 0;

    if(!isDefined(wait_override))
        wait_override = 0;

    if(level.cosmann_is_speaking == 0 && wait_override == 0)
    {
        level.cosmann_is_speaking = 1;

        if(!alarm_override)
        {
            structs = struct::get_array("amb_warning_siren", "targetname");
            wait 1;

            for(i = 0; i < structs.size; i++)
                PlaySoundAtPosition("evt_cosmo_alarm_single", structs[i].origin);

            wait 0.5;
        }

        level zm_utility::really_play_2d_sound(alias);
        level.cosmann_is_speaking = 0;
    }
    else if(wait_override == 1)
        level zm_utility::really_play_2d_sound(alias);
}

play_gersh_vox(alias)
{
    if(!isDefined(alias))
        return;

    if(!isDefined(level.gersh_is_speaking))
        level.gersh_is_speaking = 0;

    if(level.gersh_is_speaking == 0)
    {
        level.gersh_is_speaking = 1;
        level zm_utility::really_play_2d_sound(alias);
        level.gersh_is_speaking = 0;
    }
}

wait_for_gersh_vox()
{
    wait 12.5;

    foreach(player in GetPlayers())
        player thread reward_wait();
}

reward_wait()
{
    while(!zombie_utility::is_player_valid(self) || (self UseButtonPressed() && self zm_utility::in_revive_trigger()))
        wait 1;

    if(!self bgb::is_enabled("zm_bgb_disorderly_combat"))
        level thread zm_powerup_weapon_minigun::minigun_weapon_powerup(self, 90);

    self zm_utility::give_player_all_perks();
}