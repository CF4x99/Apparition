CompleteSamanthaSays(part)
{
    if(!level flag::get("power_on"))
        return self iPrintlnBold("^1ERROR: ^7The Power Needs To Be Turned On Before Using This Option");
    
    if(level flag::get(part))
        return self iPrintlnBold("^1ERROR: ^7Samantha Says Has Already Been Completed");
    
    if(isDefined(level.SamanthaSays))
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
    level.SamanthaSays = undefined;
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

SetDiggerSpeed(speed)
{
    level.DiggerSpeed = speed;
}

FastExcavators()
{
    level.FastExcavators = isDefined(level.FastExcavators) ? undefined : true;

    if(isDefined(level.FastExcavators))
    {
        level endon("EndFastExcavators");
        
        while(isDefined(level.FastExcavators))
        {
            level flag::wait_till("digger_moving");

            while(level flag::get("digger_moving")) //This needs to be looped. The speed is recalculated the whole time the excavators are moving.
            {
                diggers = GetEntArray("digger_body", "targetname");

                foreach(digger in diggers)
                {
                    targets = GetEntArray(digger.target, "targetname");

                    if(targets[0].model == "p7_zm_moo_crane_mining_body_vista")
                        tracks = targets[0];
                    else
                        tracks = targets[1];

                    if(digger.script_string == "teleporter_digger_stopped")
                        tracks = targets[0];
                    else
                        tracks = targets[1];

                    tracks.digger_speed = 2000; //Set This To Whatever. Default is around 30 - 50. You don't need to reset it since it gets recalculated everytime they move.
                }

                wait 0.1;
            }
        }
    }
    else
        level notify("EndFastExcavators");
}

send_clientnotify(digger_name, pause)
{
	switch(digger_name)
	{
		case "hangar":
			if(!pause)
				util::clientnotify("Dz3");
			else
				util::clientnotify("Dz3e");
			break;
		
		case "teleporter":
			if(!pause)
				util::clientnotify("Dz2");
			else
				util::clientnotify("Dz2e");
			break;
		
		case "biodome":
			if(!pause)
				util::clientnotify("Dz5");
			else
				util::clientnotify("Dz5e");
			break;
		
		default:
			break;
	}
}

play_digger_start_vox(digger_name)
{
	level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
	wait 7;

	if(!(isDefined(level.on_the_moon) && level.on_the_moon))
		return;

	players = GetPlayers();
	players[RandomIntRange(0, players.size)] thread zm_audio::create_and_play_dialog("digger", "incoming");
}

do_mooncomp_vox(alias)
{
	players = GetPlayers();

	for(i = 0; i < players.size; i++)
		if(players[i] zm_equipment::is_active(level.var_f486078e))
			players[i] PlaySoundToPlayer(alias + "_f", players[i]);

	if(!isDefined(level.var_2ff0efb3))
		return;
    
	foreach(var_5ede318f, speaker in level.var_2ff0efb3)
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
		curr_time = GetTime();
		time_used = (curr_time - (digger_start_time / 1000));
		time_left = (level.diggers_global_time - time_used);

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
	if(!isDefined(alias) || !level.on_the_moon)
		return;
    
	num = 0;

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