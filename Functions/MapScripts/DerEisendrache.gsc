PopulateDerEisendracheScripts(menu)
{
    switch(menu)
    {
        case "Der Eisendrache Scripts":
            self addMenu("Der Eisendrache Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("soul_catchers_charged"), "Feed Dragons", ::FeedDragons);
                self addOptBool(AreLandingPadsEnabled(), "Enable All Landing Pads", ::EnableAllLandingPads);

                if(level flag::get("soul_catchers_charged"))
                    self addOpt("Bow Quests", ::newMenu, "Bow Quests");
            break;

        case "Bow Quests":
            self addMenu("Bow Quests");
                self addOpt("Fire", ::newMenu, "Fire Bow");
                self addOpt("Lightning", ::newMenu, "Lightning Bow");
                self addOpt("Void", ::newMenu, "Void Bow");
                self addOpt("Wolf", ::newMenu, "Wolf Bow");
            break;

        case "Fire Bow":
            //level.var_c62829c7 <- player bound to fire quest

            self addMenu("Fire");
                self addOptBool(isDefined(level.var_714fae39), "Initiate Quest", ::InitFireBow);

                if(isDefined(level.var_714fae39))
                {
                    if(isDefined(level.var_c62829c7))
                    {
                        self addOptBool((level flag::get("rune_prison_obelisk") && !isDefined(level.MagmaRock)), "Shoot Magma Rock", ::MagmaRock);
                        self addOptBool(AllRunicCirclesCharged(), "Activate & Charge Runic Circles", ::RunicCircles);
                        self addOptBool(IsClockFireplaceComplete(), "Complete Fireplace Step", ::ClockFireplaceStep);
                        self addOptBool(level flag::get("rune_prison_repaired"), "Collect Repaired Arrows", ::CollectRepairedFireArrows);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
            break;

        case "Lightning Bow":
            //level.var_f8d1dc16 <- player bound to lightning quest
            trig = GetEnt("aq_es_weather_vane_trig", "targetname");

            self addMenu("Lightning");
                self addOptBool(!isDefined(trig), "Initiate Quest", ::InitLightningBow);

                if(!isDefined(trig))
                {
                    if(isDefined(level.var_f8d1dc16))
                    {
                        self addOptBool(AreBeaconsLit(), "Light Beacons", ::LightningBeacons);
                        self addOptBool(level flag::get("elemental_storm_wallrun"), "Wallrun Step", ::LightningWallrun);
                        self addOptBool(LightningBeaconsCharged(), "Fill Urns & Charge Beacons", ::LightningChargeBeacons);
                        self addOptBool(level flag::get("elemental_storm_repaired"), "Charge & Collect Arrows", ::ChargeLightningArrows);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
            break;

        case "Void Bow":
            //level.var_6e68c0d8 <- player bound to void quest
            symbol = GetEnt("aq_dg_gatehouse_symbol_trig", "targetname");

            self addMenu("Void");
                self addOptBool(IsDemonSymbolDestroyed(), "Initiate Quest", ::InitVoidBow);

                if(IsDemonSymbolDestroyed())
                {
                    if(isDefined(level.var_6e68c0d8))
                    {
                        fossils = GetEntArray("aq_dg_fossil", "script_noteworthy");

                        self addOptBool(level flag::get("demon_gate_seal"), "Release Demon Urn", ::ReleaseDemonUrn);
                        self addOptBool((!isDefined(fossils) || !fossils.size), "Trigger Fossil Heads", ::TriggerDemonFossils);
                        self addOptBool(level flag::get("demon_gate_crawlers"), "Feed Demon Urn", ::FeedDemonUrn);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
                break;

                case "Wolf Bow":
                self addMenu("Wolf");
                //removed for now
            break;
    }
}

FeedDragons()
{
    if(level flag::get("soul_catchers_charged"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.FeedingDragons))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.FeedingDragons = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    foreach(catcher in level.soul_catchers)
        catcher thread FeedDragon(self);
    
    while(!level flag::get("soul_catchers_charged"))
        wait 0.1;

    self RefreshMenu(menu, curs);

    if(Is_True(level.FeedingDragons))
        level.FeedingDragons = BoolVar(level.FeedingDragons);
}

FeedDragon(player)
{
    self notify("first_zombie_killed_in_zone", player);
    wait GetAnimLength("rtrg_o_zm_dlc1_dragonhead_intro");
    
    for(b = 0; b < 8; b++)
    {
        if(isDefined(self.var_98730ffa))
            self.var_98730ffa++;
        
        wait 0.01;
    }
}

EnableAllLandingPads()
{
    if(AreLandingPadsEnabled())
        return self iPrintlnBold("^1ERROR: ^7All Landing Pads Are Already Enabled");
    
    pads = GrabPadUniTriggers();

    foreach(pad in pads)
        pad notify("trigger");
}

AreLandingPadsEnabled()
{
    pads = GrabPadUniTriggers();
    return !pads.size;
}

GrabPadUniTriggers()
{
    if(!isDefined(level._unitriggers))
        return;
    
    if(!isDefined(level._unitriggers.trigger_stubs))
        return;
    
    pads      = [];
    padStruct = struct::get_array("115_flinger_landing_pad", "targetname");
    
    for(a = 0; a < level._unitriggers.trigger_stubs.size; a++)
    {
        if(isDefined(level._unitriggers.trigger_stubs[a]))
        {
            for(b = 0; b < padStruct.size; b++)
            {
                if(isDefined(padStruct[b]) && level._unitriggers.trigger_stubs[a].origin == padStruct[b].origin + vectorScale((0, 0, 1), 30))
                    pads[pads.size] = level._unitriggers.trigger_stubs[a];
            }
        }
    }

    return pads;
}







//Fire Bow Quest
InitFireBow()
{
    if(isDefined(level.var_714fae39))
        return;
    
    if(Is_True(level.InitFireBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitFireBow = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    clock = GetEnt("aq_rp_clock_wall_trig", "targetname");

    if(isDefined(clock))
        MagicBullet(GetWeapon("elemental_bow"), clock.origin, clock.origin + (0, 5, 0), self);

    while(!isDefined(level.var_714fae39) || !level.var_714fae39)
        wait 0.1;

    self RefreshMenu(menu, curs);
}

MagmaRock()
{
    if(Is_True(level.MagmaRock))
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

    if(Is_True(level.MagmaRock))
        level.MagmaRock = BoolVar(level.MagmaRock);
    
    self RefreshMenu(menu, curs);
}

RunicCircles()
{
    if(!level flag::get("rune_prison_obelisk"))
        return self iPrintlnBold("^1ERROR: ^7Magma Rock Step Must Be Completed First");
    
    if(Is_True(level.MagmaRock))
        return self iPrintlnBold("^1ERROR: ^7Magma Rock Is Still Being Completed");
    
    if(AllRunicCirclesCharged())
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.ChargingCircles))
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
    wait 5; //Allows buffer time between this, and the next step to help ensure we don't run into any issues

    if(Is_True(level.ChargingCircles))
        level.ChargingCircles = BoolVar(level.ChargingCircles);
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

    if(isDefined(circles) && circles.size)
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
    if(!AllRunicCirclesCharged() || Is_True(level.ChargingCircles))
        return self iPrintlnBold("^1ERROR: ^7Runic Circles Must Be Activated & Charged First");
    
    if(IsClockFireplaceComplete())
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.ClockFireplaceStep))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");

    level.ClockFireplaceStep = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    clock = struct::get("aq_rp_clock_use_struct", "targetname");
    clock.var_67b5dd94 notify("trigger", level.var_c62829c7);

    while(!isDefined(level.var_2e55cb98))
        wait 1;

    level.var_c62829c7 FreezeControls(1);
    level.var_2e55cb98.origin = level.var_c62829c7.origin;
    level.var_2e55cb98 LinkTo(level.var_c62829c7);
    wait 1;

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
    
    level.var_c62829c7 FreezeControls(0);

    while(!IsClockFireplaceComplete())
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

LocateFireplace()
{
    circles = GetEntArray("aq_rp_runic_circle_volume", "script_noteworthy");
    firePlaces = struct::get_array("aq_rp_fireplace_struct", "targetname");

    //By this point in the quest, only one runic circle should still be defined.
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

    if(!isDefined(magmaBall))
        return false;

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
    
    if(Is_True(level.CollectRepairedFireArrows))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");

    level.CollectRepairedFireArrows = true;

    menu = self getCurrent();
    curs = self getCursor();
    
    MagmaBall = struct::get("quest_reforge_rune_prison", "targetname");

    if(isDefined(MagmaBall))
        MagmaBall.var_67b5dd94 notify("trigger", level.var_c62829c7);

    level waittill(#"hash_79d94608");
    wait 3;

    if(isDefined(MagmaBall))
        MagmaBall.var_67b5dd94 notify("trigger", level.var_c62829c7);
    
    while(!level flag::get("rune_prison_repaired"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}


















//Lightning Bow Quest
InitLightningBow()
{
    trig = GetEnt("aq_es_weather_vane_trig", "targetname");

    if(!isDefined(trig))
        return;

    if(Is_True(level.InitLightningBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitLightningBow = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    if(isDefined(trig))
        MagicBullet(GetWeapon("elemental_bow"), trig.origin, trig.origin + (0, 0, 5), self);

    while(isDefined(trig))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

LightningBeacons()
{
    if(AreBeaconsLit())
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.LightningBeacons))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.LightningBeacons = true;

    menu = self getCurrent();
    curs = self getCursor();

    beacons = GetEntArray("aq_es_beacon_trig", "script_noteworthy");

    for(a = 0; a < beacons.size; a++)
    {
        if(!isDefined(beacons[a]))
            continue;
        
        MagicBullet(GetWeapon("elemental_bow"), beacons[a].origin + (0, 0, 5), beacons[a].origin, level.var_f8d1dc16);
        wait 0.1;
    }

    while(!AreBeaconsLit())
        wait 0.1;

    self RefreshMenu(menu, curs);
}

AreBeaconsLit()
{
    beacons = GetEntArray("aq_es_beacon_trig", "script_noteworthy");

    if(!isDefined(beacons))
        return false;

    for(a = 0; a < beacons.size; a++)
    {
        if(!isDefined(beacons[a]))
            continue;
        
        s_beacon = struct::get(beacons[a].target);
        
        if(!s_beacon.var_41f52afd clientfield::get("beacon_fx"))
            return false;
    }

    return true;
}

LightningWallrun()
{
    if(level flag::get("elemental_storm_wallrun"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.LightningWallrun))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!AreBeaconsLit())
        return self iPrintlnBold("^1ERROR: ^7Beacons Must Be Lit First");
    
    level.LightningWallrun = true;

    menu = self getCurrent();
    curs = self getCursor();

    trigs = GetEntArray("aq_es_wallrun_trigger", "targetname");

    for(a = 0; a < trigs.size; a++)
    {
        if(!isDefined(trigs[a]) || level.var_f8d1dc16.var_a4f04654 >= 4)
            continue;
        
        trigs[a] notify("trigger", level.var_f8d1dc16);
    }

    while(!level flag::get("elemental_storm_wallrun"))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

LightningChargeBeacons()
{
    if(LightningBeaconsCharged())
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.LightningChargeBeacons))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!level flag::get("elemental_storm_wallrun"))
        return self iPrintlnBold("^1ERROR: ^7Wallrun Step Must Be Completed First");
    
    level.LightningChargeBeacons = true;

    menu = self getCurrent();
    curs = self getCursor();

    if(!level flag::get("elemental_storm_batteries"))
    {
        beacons = GetEntArray("aq_es_battery_volume", "script_noteworthy");

        for(a = 0; a < beacons.size; a++)
        {
            if(!isDefined(beacons[a]))
                continue;
            
            while(!Is_True(beacons[a].b_activated))
            {
                beacons[a] notify("killed");
                wait 0.1;
            }

            wait 0.1;
        }

        level.var_f8d1dc16 thread LightningMissileCharger();
    }


    bTrigs = GetEntArray("aq_es_beacon_trig", "script_noteworthy");

    for(a = 0; a < bTrigs.size; a++)
    {
        if(!isDefined(bTrigs[a]) || isDefined(bTrigs[a].var_d5d05f50) && bTrigs[a].var_d5d05f50)
            continue;
        
        MagicBullet(GetWeapon("elemental_bow"), bTrigs[a].origin + (0, 0, 500), bTrigs[a].origin, level.var_f8d1dc16);
        wait 0.1;
    }

    while(!LightningBeaconsCharged())
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

LightningMissileCharger()
{
    used = [];

    while(!LightningBeaconsCharged())
    {
        self waittill("missile_fire", projectile, weapon);

        chosen = false;
        charged = GetEntArray("aq_es_battery_volume_charged", "script_noteworthy");

        for(a = 0; a < charged.size; a++)
        {
            if(!isDefined(charged[a]) || isInArray(used, a) || Is_True(chosen))
                continue;
            
            chosen = true;
            used[used.size] = a;
            projectile.var_8f88d1fd = charged[a];
            level.var_f8d1dc16.var_55301590 = charged[a];
        }

        projectile.var_e4594d27 = true;
    }
}

LightningBeaconsCharged()
{
    return (level flag::get("elemental_storm_batteries") && level flag::get("elemental_storm_beacons_charged"));
}

ChargeLightningArrows()
{
    if(level flag::get("elemental_storm_repaired"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.ChargeLightningArrows))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!LightningBeaconsCharged())
        return self iPrintlnBold("^1ERROR: ^7Urns Must Filled & Beacons Need To Be Charged First");

    level.ChargeLightningArrows = true;

    menu = self getCurrent();
    curs = self getCursor();

    storm = struct::get("quest_reforge_elemental_storm");

    if(isDefined(storm))
        storm.var_67b5dd94 notify("trigger", level.var_f8d1dc16);

    wait 18;

    if(isDefined(storm))
        storm.var_67b5dd94 notify("trigger", level.var_f8d1dc16);

    while(!level flag::get("elemental_storm_repaired"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}





















//Void Bow Quest
InitVoidBow()
{
    if(IsDemonSymbolDestroyed())
        return;
    
    if(Is_True(level.InitVoidBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitVoidBow = true;

    menu = self getCurrent();
    curs = self getCursor();

    symbol = GetEnt("aq_dg_gatehouse_symbol_trig", "targetname");

    if(isDefined(symbol))
        MagicBullet(GetWeapon("elemental_bow"), symbol.origin, symbol.origin + (0, 0, 5), self);

    while(isDefined(symbol))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

IsDemonSymbolDestroyed()
{
    return (level clientfield::get("quest_state_demon") > 0 || Is_True(level.InitVoidBow));
}

ReleaseDemonUrn()
{
    if(level flag::get("demon_gate_seal"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.ReleaseDemonUrn))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.ReleaseDemonUrn = true;

    menu = self getCurrent();
    curs = self getCursor();

    level flag::set("demon_gate_seal"); //Hate doing it this way. But, nothing will get skipped over by doing it like this.
    wait 5;

    urn = struct::get("aq_dg_urn_struct", "targetname");
    urn.var_67b5dd94 notify("trigger", level.var_6e68c0d8);

    while(!level flag::get("demon_gate_seal"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
    wait 5;

    if(Is_True(level.ReleaseDemonUrn))
        level.ReleaseDemonUrn = BoolVar(level.ReleaseDemonUrn);
}

TriggerDemonFossils()
{
    if(!level flag::get("demon_gate_seal") || level clientfield::get("quest_state_demon") < 2)
        return self iPrintlnBold("^1ERROR: ^7The Demon Urn Must Be Released First");
    
    fossils = GetEntArray("aq_dg_fossil", "script_noteworthy");

    if(!isDefined(fossils) || !fossils.size)
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.TriggerDemonFossils))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(Is_True(level.ReleaseDemonUrn))
        return self iPrintlnBold("^1ERROR: ^7Release Demon Urn Is Still Being Completed");
    
    level.TriggerDemonFossils = true;

    menu = self getCurrent();
    curs = self getCursor();

    for(a = 0; a < fossils.size; a++)
    {
        if(!isDefined(fossils[a]))
            continue;
        
        fossils[a].var_67b5dd94 notify("trigger", level.var_6e68c0d8);
        wait 0.1;
    }

    while(1)
    {
        if(!isDefined(fossils) || !fossils.size)
            break;
        
        wait 0.1;
    }
    
    self RefreshMenu(menu, curs);
}

FeedDemonUrn()
{
    fossils = GetEntArray("aq_dg_fossil", "script_noteworthy");

    if(isDefined(fossils) && fossils.size || level clientfield::get("quest_state_demon") < 3)
        return self iPrintlnBold("^1ERROR: ^7All Fossil Heads Must Be Triggered First");
    
    if(level flag::get("demon_gate_crawlers"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.FeedDemonUrn))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.FeedDemonUrn = true;

    menu = self getCurrent();
    curs = self getCursor();

    urnTrig = GetEnt("aq_dg_trophy_room_trig", "targetname");

    if(isDefined(urnTrig))
        urnTrig notify("trigger", level.var_6e68c0d8);

    wait 0.1;

    urn = GetEnt("aq_dg_demonic_circle_volume", "targetname");

    while(urn.var_e1f456ae < 6)
    {
        SpawnSacrificedZombie();
        wait 0.5;
    }

    while(!level flag::get("demon_gate_crawlers"))
        wait 0.1;
    
    if(isDefined(level.EESpawnedZM) && level.EESpawnedZM.size)
    {
        for(a = 0; a < level.EESpawnedZM.size; a++)
        {
            if(!isDefined(level.EESpawnedZM[a]) || !IsAlive(level.EESpawnedZM[a]))
                continue;
            
            level.EESpawnedZM[a] Hide();
            level.EESpawnedZM[a] DoDamage(level.EESpawnedZM[a].health + 666, level.EESpawnedZM[a].origin);
        }
    }
    
    self RefreshMenu(menu, curs);
}

SpawnSacrificedZombie()
{
    if(!isDefined(level.EESpawnedZM))
        level.EESpawnedZM = [];
    
    zombie = zombie_utility::spawn_zombie(level.zombie_spawners[0]);

    if(isDefined(zombie))
    {
        wait 0.1;

        zombie endon("death");

        level.EESpawnedZM[level.EESpawnedZM.size] = zombie;
        zombie zombie_utility::makezombiecrawler(true);

        goalEnt = GetEnt("aq_dg_demonic_circle_volume", "targetname");
        target = goalEnt.origin;

        linker = Spawn("script_origin", zombie.origin);
        linker.origin = zombie.origin;
        linker.angles = zombie.angles;

        zombie LinkTo(linker);
        linker MoveTo(target, 0.01);

        linker waittill("movedone");

        zombie Unlink();
        linker delete();

        zombie LinkTo(goalEnt);

        zombie.completed_emerging_into_playable_area = 1;
        zombie.find_flesh_struct_string = "find_flesh";
        zombie.ai_state = "find_flesh";
        zombie notify("zombie_custom_think_done", "find_flesh");
    }
}