PopulateRevelationsScripts(menu)
{
    switch(menu)
    {
        case "Revelations Scripts":
            self addMenu("Revelations Scripts");
                self addOptBool(level flag::get("character_stones_done"), "Damage Tombstones", ::DamageGraveStones);
            break;
    }
}

DamageGraveStones()
{
    if(level flag::get("character_stones_done"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(isDefined(level.DamageGraveStones))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.DamageGraveStones = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    script_int = 1;
    stones = GetEntArray("tombstone", "targetname");

    while(script_int <= 4)
    {
        foreach(stone in stones)
        {
            if(stone.script_int != script_int)
                continue;
            
            stone notify("trigger");
            script_int++;

            wait 0.1;
        }
        
        wait 0.1;
    }

    while(!level flag::get("character_stones_done"))
        wait 0.1;

    self RefreshMenu(menu, curs);
}