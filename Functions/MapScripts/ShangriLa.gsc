PopulateShangriLaScripts(menu)
{
    switch(menu)
    {
        case "Shangri-La Scripts":
            self addMenu("Shangri-La Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::ShangHideAndSeekSong);
                
                if(level.players.size < 4)
                    self addOptBool(level.TempleAllowFullEE, "Allow Full Easter Egg(Less Than 4 Players)", ::TempleAllowFullEE);
            break;
    }
}

ShangHideAndSeekSong()
{
    if(level flag::get("snd_zhdegg_completed"))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Completed");

    if(Is_True(level.StartedSamanthaSong))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Started");

    level.StartedSamanthaSong = true;

    curs = self getCursor();
    menu = self getCurrent();

    gongs = GetEntArray("sq_gong", "targetname");

    for(a = 0; a < gongs.size; a++)
        if(gongs[a].right_gong)
            gongs[a] notify("triggered", self);

    wait 0.1;
    pans = GetEntArray("zhdsnd_pans", "targetname");

    for(a = 0; a < pans.size; a++) //Magic Bullet Has To Be The Starting Pistol
    {
        if(pans[a].script_int == 1) //Pan 1 Has To Get Shot Twice
        {
            for(b = 0; b < 2; b++)
            {
                MagicBullet(level.start_weapon, pans[a].origin + (-5, 0, 0), pans[a].origin, self);
                wait 0.05;
            }
        }
        else if(pans[a].script_int == 5) //Pan 5 Has To Get Shot Once
            MagicBullet(level.start_weapon, pans[a].origin + (-5, 0, 0), pans[a].origin, self);

        wait 0.05;
    }

    wait 3;
    self SamanthasHideAndSeekSong();
}

TempleAllowFullEE()
{
    level.TempleAllowFullEE = BoolVar(level.TempleAllowFullEE);

    while(Is_True(level.TempleAllowFullEE))
    {
        playerCount = level.players.size;

        if(level._sundial_buttons_pressed == playerCount)
            level._sundial_buttons_pressed = 4;

        if(playerCount == 1 && isDefined(level.var_66c77de0))
            level.var_d8ceed1b = level.var_66c77de0;

        if(level.var_a775df2e >= (playerCount - 1) && !level flag::get("dgcwf_on_plate"))
            level flag::set("dgcwf_on_plate");

        if(level flag::get("dgcwf_on_plate") && level.var_a775df2e < (playerCount - 1))
            level flag::clear("dgcwf_on_plate");

        wait 0.01;
    }
}