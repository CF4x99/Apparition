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
	north_pos = GetEnt("zipline_door_n_pos", "script_noteworthy");
	south_pos = GetEnt("zipline_door_s_pos", "script_noteworthy");

	lander.door_north thread move_gate(north_pos, 1);
	lander.door_south thread move_gate(south_pos, 1);
}

close_lander_gate(time)
{
	lander = GetEnt("lander", "targetname");
	north_pos = GetEnt("zipline_door_n_pos", "script_noteworthy");
	south_pos = GetEnt("zipline_door_s_pos", "script_noteworthy");

	lander.door_north thread move_gate(north_pos, 0, time);
	lander.door_south thread move_gate(south_pos, 0, time);
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

    self endon("disconnect");

    curs = self getCursor();
    menu = self getCurrent();

    self GivePlayerEquipment(GetWeapon("black_hole_bomb"), self);
    wait 0.01;

    self MagicGrenadeType(GetWeapon("black_hole_bomb"), (-1610, 2770, -203), (0, 0, 0), 1);

    while(!level flag::get("target_teleported"))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

ActivateComputer()
{
    if(!level flag::get("target_teleported"))
        return self iPrintlnBold("^1ERROR: ^7Generator Must Be Teleported First");

    if(level flag::get("rerouted_power"))
        return self iPrintlnBold("^1ERROR: ^7Computer Has Already Been Activated");

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
        return self iPrintlnBold("^1ERROR: ^7This Can Only Be Activated On A Monkey Round");

    switches = struct::get_array("sync_switch_start", "targetname");

    foreach(swtch in switches)
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
}

RefuelRocket()
{
    if(!level flag::get("switches_synced"))
        return self iPrintlnBold("^1ERROR: ^7Switches Must Be Activated First");

    if(level flag::get("lander_a_used") && level flag::get("lander_b_used") && level flag::get("lander_c_used") && level flag::get("launch_activated"))
        return self iPrintlnBold("^1ERROR: ^7Rocket Already Refueled");

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
}

LaunchRocket()
{
    if(!level flag::get("lander_a_used") || !level flag::get("lander_b_used") || !level flag::get("lander_c_used") || !level flag::get("launch_activated"))
        return self iPrintlnBold("^1ERROR: ^7Rocket Must Be Refueled First");

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
}

CompleteTimeClock()
{
    if(!level flag::get("launch_complete"))
        return self iPrintlnBold("^1ERROR: ^7Rocket Must Be Launched First");

    if(level flag::get("pressure_sustained"))
        return self iPrintlnBold("^1ERROR: ^7Time Clock Already Completed");

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