PopulateMoonScripts(menu)
{
    switch(menu)
    {
        case "Moon Scripts":
            self addMenu("Moon Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptSlider("Activate Excavator", ::ActivateDigger, "Teleporter;Hangar;Biodome");
                self addOptBool(level.FastExcavators, "Fast Excavators", ::FastExcavators);

                if(level flag::get("power_on"))
                {
                    self addOptBool(level flag::get("ss1"), "Samantha Says Part 1", ::CompleteSamanthaSays, "ss1");

                    if(level flag::get("ss1"))
                        self addOptBool(level flag::get("be2"), "Samantha Says Part 2", ::CompleteSamanthaSays, "be2");
                }
            break;
    }
}

ActivateDigger(force_digger)
{
    force_digger = ToLower(force_digger);

    if(level flag::get("start_" + force_digger + "_digger"))
        return self iPrintlnBold("^1ERROR: ^7Excavator Is Already Activated");

    level flag::set("start_" + force_digger + "_digger");
    level thread send_clientnotify(force_digger, 0);
    level thread play_digger_start_vox(force_digger);
    wait 1;

    level notify(force_digger + "_vox_timer_stop");
    level thread play_timer_vox(force_digger);
}

send_clientnotify(digger_name, pause)
{
    switch(digger_name)
    {
        case "hangar":
            util::clientnotify(!pause ? "Dz3" : "Dz3e");
            break;

        case "teleporter":
            util::clientnotify(!pause ? "Dz2" : "Dz2e");
            break;

        case "biodome":
            util::clientnotify(!pause ? "Dz5" : "Dz5e");
            break;

        default:
            break;
    }
}

play_digger_start_vox(digger_name)
{
    level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
    wait 7;

    if(!Is_True(level.on_the_moon))
        return;

    GetPlayers()[RandomIntRange(0, GetPlayers().size)] thread zm_audio::create_and_play_dialog("digger", "incoming");
}

do_mooncomp_vox(alias)
{
    for(i = 0; i < GetPlayers().size; i++)
        if(GetPlayers()[i] zm_equipment::is_active(level.var_f486078e))
            GetPlayers()[i] PlaySoundToPlayer(alias + "_f", GetPlayers()[i]);

    if(!isDefined(level.var_2ff0efb3))
        return;

    foreach(speaker in level.var_2ff0efb3)
    {
        PlaySoundAtPosition(alias, speaker.origin);
        wait 0.05;
    }
}

play_timer_vox(digger_name)
{
    level endon(digger_name + "_vox_timer_stop");

    time_left = level.diggers_global_time;
    played180sec = 0;
    played120sec = 0;
    played60sec = 0;
    played30sec = 0;
    digger_start_time = GetTime();

    while(time_left > 0)
    {
        time_left = (level.diggers_global_time - (GetTime() - (digger_start_time / 1000)));

        if(time_left <= 180 && !played180sec)
        {
            level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
            played180sec = 1;
        }

        if(time_left <= 120 && !played120sec)
        {
            level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
            played120sec = 1;
        }

        if(time_left <= 60 && !played60sec)
        {
            level thread play_mooncomp_vox("vox_mcomp_digger_time_60_", digger_name);
            played60sec = 1;
        }

        if(time_left <= 30 && !played30sec)
        {
            level thread play_mooncomp_vox("vox_mcomp_digger_time_30_", digger_name);
            played30sec = 1;
        }

        wait 1;
    }
}

play_mooncomp_vox(alias, digger)
{
    if(!isDefined(alias) || !Is_True(level.on_the_moon))
        return;

    if(isDefined(digger))
    {
        switch(digger)
        {
            case "hangar":
                num = 1;
                break;

            case "teleporter":
                num = 0;
                break;

            case "biodome":
                num = 2;
                break;

            default:
                num = 0;
                break;
        }
    }
    else
        num = "";

    if(!isDefined(level.mooncomp_is_speaking))
        level.mooncomp_is_speaking = 0;

    if(level.mooncomp_is_speaking == 0)
    {
        level.mooncomp_is_speaking = 1;
        level do_mooncomp_vox(alias + num);
        level.mooncomp_is_speaking = 0;
    }
}

CompleteSamanthaSays(part)
{
    if(!level flag::get("power_on"))
        return self iPrintlnBold("^1ERROR: ^7The Power Needs To Be Turned On Before Using This Option");

    if(part == "be2" && !level flag::get("vg_charged"))
        return self iPrintlnBold("^1ERROR: ^7This Step Can't Be Completed Yet");

    if(level flag::get(part))
        return self iPrintlnBold("^1ERROR: ^7Samantha Says Has Already Been Completed");

    if(Is_True(level.SamanthaSays))
        return self iPrintlnBold("^1ERROR: ^7Samantha Says Is Currently Being Completed");

    level.SamanthaSays = true;

    curs = self getCursor();
    menu = self getCurrent();

    while(!level flag::get(part))
    {
        level notify("ss_won");
        level._ss_sequence_matched = true;

        wait 0.025;
    }

    self RefreshMenu(menu, curs);

    if(Is_True(level.SamanthaSays))
        level.SamanthaSays = BoolVar(level.SamanthaSays);
}

FastExcavators()
{
    level endon("EndFastExcavators");

    level.FastExcavators = BoolVar(level.FastExcavators);

    if(Is_True(level.FastExcavators))
    {
        while(Is_True(level.FastExcavators))
        {
            level flag::wait_till("digger_moving");

            while(level flag::get("digger_moving")) //This needs to be looped. The speed is recalculated the whole time the excavators are moving.
            {
                foreach(digger in GetEntArray("digger_body", "targetname"))
                {
                    tracks = (digger.script_string == "teleporter_digger_stopped") ? GetEntArray(digger.target, "targetname")[0] : GetEntArray(digger.target, "targetname")[1];
                    tracks.digger_speed = 2000; //Set This To Whatever. Default is around 30 - 50. You don't need to reset it since it gets recalculated everytime they move.
                }

                wait 0.1;
            }
        }
    }
    else
        level notify("EndFastExcavators");
}