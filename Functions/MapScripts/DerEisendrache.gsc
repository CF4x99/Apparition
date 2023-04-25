FeedDragons()
{
    if(level flag::get("soul_catchers_charged"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(isDefined(level.FeedingDragons))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.FeedingDragons = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    foreach(catcher in level.soul_catchers)
        catcher thread FeedDragon(self);
    
    while(!level flag::get("soul_catchers_charged"))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

FeedDragon(player)
{
    self notify("first_zombie_killed_in_zone", player);
    
    wait GetAnimLength("rtrg_o_zm_dlc1_dragonhead_intro");
    
    for(b = 0; b < 8; b++)
    {
        self.var_98730ffa++;
        
        wait 0.01;
    }
}







//Fire Bow Quest

InitFireBow()
{
    if(isDefined(level.var_714fae39))
        return;
    
    if(isDefined(level.InitFireBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitFireBow = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    clock = GetEnt("aq_rp_clock_wall_trig", "targetname");

    if(isDefined(clock))
        MagicBullet(GetWeapon("elemental_bow"), clock.origin, clock.origin + (0, 5, 0), self);

    wait 0.1;

    self RefreshMenu(menu, curs);
}

MagmaRock()
{
    if(isDefined(level.MagmaRock))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(level flag::get("rune_prison_obelisk"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    level.MagmaRock = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    level flag::set("rune_prison_obelisk_magma_enabled");

    wait 0.1;

    rock = GetEnt("aq_rp_obelisk_magma_trig", "targetname");

    if(isDefined(rock))
        MagicBullet(GetWeapon("elemental_bow"), rock.origin, rock.origin + (0, 5, 0), level.var_c62829c7);
    
    while(!level flag::get("rune_prison_obelisk"))
        wait 0.1;
    
    wait 9;

    level.MagmaRock = undefined;

    self RefreshMenu(menu, curs);
}

RunicCircles()
{
    if(!level flag::get("rune_prison_obelisk"))
        return self iPrintlnBold("^1ERROR: ^7Magma Rock Step Must Be Completed First");
    
    if(isDefined(level.MagmaRock))
        return self iPrintlnBold("^1ERROR: ^7Magma Rock Is Still Being Completed");
    
    if(AllRunicCirclesCharged())
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(isDefined(level.ChargingCircles))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.ChargingCircles = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    level.var_c62829c7.var_122a2dda = true;

    wait 1;

    circles = GetEntArray("aq_rp_runic_circle_volume", "script_noteworthy");

    if(isDefined(circles))
    {
        for(a = 0; a < circles.size; a++)
        {
            if(!isDefined(circles[a]) || circles[a] flag::get("runic_circle_activated"))
                continue;
            
            cirTarget = GetEnt(circles[a].target + "_trig", "targetname");

            if(isDefined(cirTarget))
                MagicBullet(GetWeapon("elemental_bow"), cirTarget.origin, cirTarget.origin, level.var_c62829c7);
            
            wait 0.05;
        }
    }

    wait 1;

    level.var_c62829c7.var_122a2dda = false;

    array::thread_all(circles, ::ChargeRunicCircle);

    while(!AllRunicCirclesCharged())
        wait 0.1;
    
    self RefreshMenu(menu, curs);

    wait 3;

    level.ChargingCircles = undefined; //Allows buffer time between this, and the next step.
}

ChargeRunicCircle()
{
    if(!isDefined(self) || self flag::get("runic_circle_charged"))
        return;
    
    while(!self flag::get("runic_circle_activated"))
        wait 0.1;
    
    while(!self flag::get("runic_circle_charged"))
    {
        self notify("killed");

        wait 0.1;
    }
}

AllRunicCirclesCharged()
{
    circles = GetEntArray("aq_rp_runic_circle_volume", "script_noteworthy");

    if(isDefined(circles))
    {
        for(a = 0; a < circles.size; a++)
        {
            if(!isDefined(circles[a]))
                continue;
            
            if(!circles[a] flag::get("runic_circle_activated") || !circles[a] flag::get("runic_circle_charged"))
                return false;
        }
    }

    return true;
}

ClockFireplaceStep()
{
    if(!AllRunicCirclesCharged() || isDefined(level.ChargingCircles))
        return self iPrintlnBold("^1ERROR: ^7Runic Circles Must Be Activated & Charged First");
    
    if(IsClockFireplaceComplete())
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(isDefined(level.ClockFireplaceStep))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");

    level.ClockFireplaceStep = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    clock = struct::get("aq_rp_clock_use_struct", "targetname");
    clock.var_67b5dd94 notify("trigger", level.var_c62829c7);

    while(!isDefined(level.var_2e55cb98))
        wait 0.1;

    level.var_2e55cb98.origin = level.var_c62829c7.origin;
    level.var_2e55cb98 LinkTo(level.var_c62829c7.origin, "j_mainroot");

    wait 0.5;

    target = GetEnt(level.var_2e55cb98.var_336f1366.target, "targetname");
    firePlace = LocateFireplace(); //Need to find the fireplace before this part of the step is completed

    if(isDefined(target))
        for(a = 0; a < 2; a++) //Target must be hit twice
        {
            MagicBullet(GetWeapon("elemental_bow"), target.origin, target.origin + (0, 5, 0), level.var_c62829c7);

            wait 0.1;
        }

    if(isDefined(firePlace))
        firePlace.var_67b5dd94 notify("trigger", level.var_c62829c7);

    while(!IsClockFireplaceComplete())
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

LocateFireplace()
{
    circles = GetEntArray("aq_rp_runic_circle_volume", "script_noteworthy");
    firePlaces = struct::get_array("aq_rp_fireplace_struct", "targetname");

    //By this point, only one runic circle should still be defined.
    //But, we're still gonna scan through just to be sure.

    if(isDefined(circles))
    {
        for(a = 0; a < circles.size; a++)
        {
            if(!isDefined(circles[a]))
                continue;
            
            for(b = 0; b < firePlaces.size; b++)
                if(circles[a].script_label == firePlaces[b].script_noteworthy)
                    return firePlaces[b];
        }
    }
}

IsClockFireplaceComplete()
{
    magmaBall = GetEnt("aq_rp_magma_ball_tag", "targetname");

    if(level flag::get("rune_prison_golf") && magmaBall flag::get("magma_ball_move_done"))
        return true;
    
    return false;
}

CollectRepairedFireArrows()
{
    if(level flag::get("rune_prison_repaired"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(!IsClockFireplaceComplete())
        return self iPrintlnBold("^1ERROR: ^7The Fireplace Step Must Be Completed First");
    
    if(isDefined(level.CollectRepairedFireArrows))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");

    level.CollectRepairedFireArrows = true;

    menu = self getCurrent();
    curs = self getCursor();
    
    MagmaBall = struct::get("quest_reforge_rune_prison", "targetname");
    MagmaBall.var_67b5dd94 notify("trigger", level.var_c62829c7);

    level waittill(#"hash_79d94608");

    wait 3;

    if(isDefined(MagmaBall))
        MagmaBall.var_67b5dd94 notify("trigger", level.var_c62829c7);
    
    while(!level flag::get("rune_prison_repaired"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}