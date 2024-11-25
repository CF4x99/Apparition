PopulateShinoScripts(menu)
{
    switch(menu)
    {
        case "Shi No Numa Scripts":
            self addMenu("Shi No Numa Scripts");
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::ShinoHideAndSeek);
                self addOptBool(level.ShinoTheOneSong, "The One Song", ::ShinoTheOneSong);
            break;
    }
}

ShinoHideAndSeek()
{
    if(level flag::get("snd_zhdegg_completed"))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Completed");

    if(Is_True(level.StartedSamanthaSong))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Started");

    level.StartedSamanthaSong = true;

    curs = self getCursor();
    menu = self getCurrent();

    plates = GetEntArray("sndzhd_plates", "targetname");

    for(a = 0; a < plates.size; a++)
    {
        MagicBullet(level.start_weapon, plates[a].origin + (AnglesToForward(plates[a].angles) * 2), plates[a].origin, self);
        wait 0.05;
    }

    wait 3;
    self SamanthasHideAndSeekSong();
}

ShinoTheOneSong()
{
    if(Is_True(level.ShinoTheOneSong))
        return iPrintlnBold("^1ERROR: ^7The One Song Has Already Been Activated");

    level.ShinoTheOneSong = true;
    trigger = struct::get("s_phone_egg", "targetname");

    for(a = 0; a < 4; a++)
    {
        trigger notify("trigger_activated");
        wait !a ? 1 : 0.25;
    }
}