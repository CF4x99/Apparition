VerrucktHideAndSeekSong()
{
    if(level flag::get("snd_zhdegg_completed"))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Completed");
    
    if(isDefined(level.StartedSamanthaSong))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Started");

    level.StartedSamanthaSong = true;
    
    curs = self getCursor();
    menu = self getCurrent();

    toilets = struct::get_array("s_toilet_zhd", "targetname");

    foreach(index, toilet in toilets)
    {
        for(a = 0; a < toilet.script_int; a++)
        {
            toilet notify("trigger_activated");
            wait 0.1;
        }

        wait 0.5;
    }

    wait 3;
    self SamanthasHideAndSeekSong();
}

VerrucktLullabyForADeadMan()
{
    if(isDefined(level.VerrucktLullaby))
        return iPrintlnBold("^1ERROR: ^7Lullaby For A Dead Man Already Activated");

    level.VerrucktLullaby = true;
    
    trigger = struct::get("snd_flusher", "targetname");
    
    for(a = 0; a < 3; a++)
    {
        trigger notify("trigger_activated");
        wait 3.8;
    }
}