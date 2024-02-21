PopulateShangriLaScripts(menu)
{
    switch(menu)
    {
        case "Shangri-La Scripts":
            self addMenu("Shangri-La Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::ShangHideAndSeekSong);
            break;
    }
}

ShangHideAndSeekSong()
{
    if(level flag::get("snd_zhdegg_completed"))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Completed");
    
    if(isDefined(level.StartedSamanthaSong))
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