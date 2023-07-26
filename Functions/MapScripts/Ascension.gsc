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