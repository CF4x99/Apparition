PopulateRevelationsScripts(menu)
{
    switch(menu)
    {
        case "Revelations Scripts":
            self addMenu("Revelations Scripts");
                self addOpt("Challenges", ::newMenu, "Map Challenges");
                self addOpt("Keeper Companion Parts", ::newMenu, "Revelations Keeper Companion");
                self addOptBool(level flag::get("all_power_on"), "Corrupt All Generators", ::RevelationsPowerOn);
                self addOptBool(level flag::get("apothicon_trapped"), "Trap Apothicon", ::TrapApothicon);
                self addOptBool(level flag::get("apotho_pack_freed"), "Free Pack 'a' Punch", ::RevelationsFreePackAPunch);
                self addOptBool(level flag::get("character_stones_done"), "Damage Tombstones", ::DamageTombstones);
            break;

        case "Revelations Keeper Companion":
            self addMenu("Keeper Companion");
                self addOptBool(level flag::get("keeper_callbox_gem_found"), "Gem", ::RevelationsKeeperCraftable, "gem");
                self addOptBool(level flag::get("keeper_callbox_head_found"), "Skull", ::RevelationsKeeperCraftable, "head");
                self addOptBool(level flag::get("keeper_callbox_totem_found"), "Keeper Flag", ::RevelationsKeeperCraftable, "totem");
            break;
    }
}

RevelationsKeeperCraftable(craftable)
{
    if(!isDefined(craftable) || !level flag::exists("keeper_callbox_" + craftable + "_found") || level flag::get("keeper_callbox_" + craftable + "_found"))
        return;

    partStruct = struct::get_array("companion_" + craftable + "_part", "targetname");

    foreach(part in partStruct)
        if(isDefined(part) && IsString(part.var_fdb628a4) && part.var_fdb628a4 == "keeper_callbox_" + craftable)
            cPart = part;

    if(isDefined(cPart))
        cPart notify("trigger_activated", self);
}

RevelationsPowerOn()
{
    if(level flag::get("all_power_on"))
        return self iPrintlnBold("^1ERROR: All Power Generators Are Already Corrupt");

    level flag::set("power_on");
}

TrapApothicon()
{
    if(level flag::get("apothicon_trapped"))
        return self iPrintlnBold("^1ERROR: ^7The Apothicon Has Already Been Trapped");

    if(!level flag::get("all_power_on"))
        return self iPrintlnBold("^1ERROR: ^7All Power Generators Must Be Corrupt First");

    if(isDefined(level.TrappingApothicon))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");

    level.TrappingApothicon = true;

    menu = self getCurrent();
    curs = self getCursor();

    if(!level flag::get("apothicon_near_trap"))
    {
        self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7Waiting For The Apothicon To Be Near The Trap");

        while(!level flag::get("apothicon_near_trap"))
            wait 0.01;
    }

    trapTrigger = struct::get("apothicon_trap_trig", "targetname");
    trapTrigger notify("trigger_activated", self);

    wait 0.1;
    self RefreshMenu(menu, curs);
    level.TrappingApothicon = undefined;
}

RevelationsFreePackAPunch()
{
    if(!level flag::get("apothicon_trapped"))
        return self iPrintlnBold("^1ERROR: ^7The Apothicon Needs To Be Trapped First");

    if(level flag::get("apotho_pack_freed"))
        return self iPrintlnBold("^1ERROR: ^7The Pack 'a' Punch Has Already Been Freed");

    menu = self getCurrent();
    curs = self getCursor();

    //I couldn't find the entities, so decided to go the lazy route after 10 minutes.
    origins = Array((1200, 139, -2769), (932, 418, -2817), (841, -206, -2822));

    for(a = 0; a < origins.size; a++)
        RadiusDamage(origins[a], 100, 999, 999, self);

    while(!level flag::get("apotho_pack_freed"))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

DamageTombstones()
{
    if(level flag::get("character_stones_done"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");

    if(Is_True(level.DamageGraveStones))
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