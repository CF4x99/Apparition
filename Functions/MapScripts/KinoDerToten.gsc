CompleteDoorKnockingCombination()
{
    if(level flag::get("snd_zhdegg_activate"))
        return self iPrintlnBold("^1ERROR: ^7The Door Knocking Combination Has Already Been Completed");
    
    if(isDefined(level.KnockingCombination))
        return self iPrintlnBold("^1ERROR: ^7The Door Knocking Combination Is Currently Being Completed");
    
    level.KnockingCombination = true;

    while(1) //This will complete it properly. If you just set the flag, the knocking will continue.
    {
        if(level flag::get("snd_zhdegg_activate"))
            break;
        
        level notify("zhd_knocker_success");

        wait 0.025;
    }
    
    level.KnockingCombination = undefined;
    level flag::set("snd_zhdegg_activate");
}

CompleteMeteorEE()
{
    foreach(meteor in struct::get_array("songstructs", "targetname"))
    {
        triggerObj = undefined;

        foreach(ent in GetEntArray("script_origin", "classname"))
        {
            if(ent.origin == meteor.origin)
            {
                triggerObj = ent;
                break;
            }
        }

        if(isDefined(triggerObj))
            triggerObj notify("trigger_activated", self);
        
        wait 0.05;
    }
}