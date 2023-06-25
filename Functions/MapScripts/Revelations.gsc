DamageGraveStones()
{
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