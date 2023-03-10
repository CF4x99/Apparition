GiantLinkAllTeleporters()
{
    curs = self getCursor();
    menu = self getCurrent();
    
    if(!level flag::get("power_on"))
        return self iPrintlnBold("^1ERROR: ^7Power Needs To Be Activated First");
    
    for(a = 0; a < 3; a++)
        GiantLinkTeleporterToMainframe(a);

    if(level.active_links < 3)
        while(level.active_links < 3)
            wait 0.05;

    self RefreshMenu(menu, curs);
}

GiantLinkTeleporterToMainframe(index)
{
    if(!level flag::get("power_on"))
        return self iPrintlnBold("^1ERROR: ^7Power Needs To Be Activated First");
    
    if(level.teleport[index] == "active")
        return;
    
    if(level.teleport[index] == "waiting")
    {
        trigger = level.teleporter_pad_trig[index];
        trigger notify("trigger");
        wait 0.075;
    }

    trigger_core = GetEnt("trigger_teleport_core", "targetname");
    trigger_core notify("trigger");
}

GiantCompleteSixthPerk()
{
    if(level flag::get("snow_ee_completed"))
        return self iPrintlnBold("^1ERROR: ^7Sixth Perk Already Completed");
    
    curs = self getCursor();
    menu = self getCurrent();
    
    if(!level flag::get("power_on"))
        ActivatePower();

    wait 0.1;

    if(level.active_links < 3)
        GiantLinkAllTeleporters();
    
    wait 0.1;
    
    flags = ["one", "two", "three"];
    consoles = ["blue", "green", "red"];
    
    for(a = 0; a < flags.size; a++)
    {
        if(!level flag::get("console_" + flags[a] + "_completed"))
        {
            level flag::set("console_" + flags[a] + "_completed");
            level clientfield::set("console_" + consoles[a], 1);
        }
    }
    
    wait 0.1;
    
    TriggerUniTrigger(struct::get("snowpile_console"), "trigger_activated");
    level flag::wait_till("snow_ee_completed");

    self RefreshMenu(menu, curs);
}

InitializeGiantHideAndSeek()
{
    if(level flag::get("hide_and_seek") || isDefined(level.HideAndSeekInit))
        return self iPrintlnBold("^1ERROR: ^7Hide & Seek Already Started");

    level.HideAndSeekInit = true;
    
    curs = self getCursor();
    menu = self getCurrent();
    
    trig_control_panel = GetEnt("trig_ee_flytrap", "targetname");
    MagicBullet(GetWeapon("ray_gun_upgraded"), trig_control_panel.origin - (5, 5, 5), trig_control_panel.origin, self, trig_control_panel);
    
    level flag::wait_till("hide_and_seek");
    self RefreshMenu(menu, curs);
}

GiantCompleteHideAndSeek()
{
    if(isDefined(level.GiantHideAndSeekCompleted))
        return self iPrintlnBold("^1ERROR: ^7Hide & Seek Already Completed");

    curs = self getCursor();
    menu = self getCurrent();
    
    if(!level flag::get("hide_and_seek") && !isDefined(level.HideAndSeekInit))
    {
        InitializeGiantHideAndSeek();
        wait 0.1;
    }
    
    if(!level flag::get("hide_and_seek"))
        level flag::wait_till("hide_and_seek");
    
    ents = ["ee_exp_monkey", "ee_bowie_bear", "ee_perk_bear"];

    for(a = 0; a < ents.size; a++)
    {
        if(!level flag::set(ents[a]))
        {
            trig = GetEnt("trig_" + ents[a], "targetname");
            trig notify("trigger");
            wait 0.15;
        }
    }
    
    level.GiantHideAndSeekCompleted = true;
    
    self RefreshMenu(menu, curs);
}