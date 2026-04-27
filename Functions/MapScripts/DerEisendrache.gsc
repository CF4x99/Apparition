PopulateDerEisendracheScripts(menu)
{
    switch(menu)
    {
        case "Der Eisendrache Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("soul_catchers_charged"), "Feed Dragons", ::FeedDragons);
                self addOptBool(level flag::get("pap_reform_available"), "Activate Pack 'a' Punch Machine", ::CastleActivatePAP);
                self addOptBool(AreLandingPadsEnabled(), "Enable All Landing Pads", ::EnableAllLandingPads);
                self addOpt("Side Easter Eggs", ::newMenu, "Castle Side Easter Eggs");
                self addOpt("Bow Quests", ::newMenu, "Bow Quests");
            break;
        
        case "Castle Side Easter Eggs":
            self addMenu("Side Easter Eggs");
                self addOptBool(level flag::get("ee_disco_inferno"), "Disco Inferno", ::DiscoInferno);
                self addOptBool(level flag::get("ee_claw_hat"), "Claw Hat", ::ClawHat);
                self addOptBool(self HasWeapon(GetWeapon("knife_plunger")), "Plunger Melee", ::PlungerMelee);
            break;

        case "Bow Quests":
            self addMenu(menu);
                if(level flag::get("soul_catchers_charged"))
                {
                    self addOpt("Fire", ::newMenu, "Fire Bow");
                    self addOpt("Lightning", ::newMenu, "Lightning Bow");
                    self addOpt("Void", ::newMenu, "Void Bow");
                    self addOpt("Wolf", ::newMenu, "Wolf Bow");
                }
                else
                    self addOpt("Feed The Dragons First");
            break;

        case "Fire Bow":
            //level.var_c62829c7 <- player bound to fire quest

            self addMenu("Fire");
                self addOptBool(IsDefined(level.var_714fae39), "Initiate Quest", ::InitFireBow);

                if(IsDefined(level.var_714fae39))
                {
                    if(IsDefined(level.var_c62829c7))
                    {
                        magmaRock = (!IsDefined(level.MagmaRock) || !Is_True(level.MagmaRock));

                        self addOptBool((level flag::get("rune_prison_obelisk") && magmaRock), "Shoot Magma Rock", ::MagmaRock);
                        self addOptBool(AllRunicCirclesCharged(), "Activate & Charge Runic Circles", ::RunicCircles);
                        self addOptBool(IsClockFireplaceComplete(), "Shoot Fireplace", ::ClockFireplaceStep);
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
                self addOptBool(!IsDefined(trig), "Initiate Quest", ::InitLightningBow);

                if(!IsDefined(trig))
                {
                    if(IsDefined(level.var_f8d1dc16))
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
                self addOptBool(level clientfield::get("quest_state_demon") > 0, "Initiate Quest", ::InitVoidBow);

                if(level clientfield::get("quest_state_demon") > 0)
                {
                    if(IsDefined(level.var_6e68c0d8))
                    {
                        fossils = GetEntArray("aq_dg_fossil", "script_noteworthy");

                        self addOptBool(level flag::get("demon_gate_seal"), "Release Demon Urn", ::ReleaseDemonUrn);
                        self addOptBool((!IsDefined(fossils) || !fossils.size), "Fossil Heads", ::TriggerDemonFossils);
                        self addOptBool(level flag::get("demon_gate_crawlers"), "Feed Demon Urn", ::FeedDemonUrn);
                        self addOptBool(level flag::get("demon_gate_runes"), "Inscribe Demon Name", ::InscribeDemonName);
                        self addOptBool(level flag::get("demon_gate_repaired"), "Collect Reforged Arrow", ::CollectVoidArrow);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
                break;

        case "Wolf Bow":
            //level.var_52978d72 <- player bound to the wolf quest

            self addMenu("Wolf");
                self addOptBool(level flag::get("wolf_howl_paintings"), "Initiate Quest", ::InitWolfBow);
                
                if(level flag::get("wolf_howl_paintings"))
                {
                    if(IsDefined(level.var_52978d72))
                    {
                        self addOptBool((level clientfield::get("quest_state_wolf") >= 2), "Collect Skull Shrine", ::CollectSkullShrine);
                        self addOptBool((level clientfield::get("quest_state_wolf") >= 3), "Attach Skull To Skeleton", ::WolfAttachSkull);
                        self addOptBool(level flag::get("wolf_howl_escort"), "Escort & Collect Wolf Souls", ::CollectWolfSouls);
                        self addOptBool(level flag::get("wolf_howl_repaired"), "Collect Reforged Arrows", ::CollectReforgedArrows);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
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
        if(IsDefined(self.var_98730ffa))
            self.var_98730ffa++;
        else
            self.var_98730ffa = 0;
        
        wait 0.01;
    }
}

CastleActivatePAP()
{
    if(level flag::get("pap_reform_available"))
        return self iPrintlnBold("^1ERROR: ^7The Pack 'a' Punch Has Already Been Activated");
    
    if(Is_True(level.CastleActivatePAP))
        return self iPrintlnBold("^1ERROR: ^7The Pack 'a' Punch Is Currently Being Activated");
    
    level.CastleActivatePAP = true;
    menu = self getCurrent();
    curs = self getCursor();
    
    foreach(trigger in level._unitriggers.trigger_stubs)
    {
        foreach(pap in struct::get_array("s_pap_tp"))
        {
            if(trigger.origin != pap.origin + (0, 0, 30) || Is_True(trigger.parent_struct.activated))
                continue;
            
            trigger notify("trigger", self);
        }
    }

    while(!level flag::get("pap_reform_available"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

EnableAllLandingPads()
{
    if(AreLandingPadsEnabled())
        return self iPrintlnBold("^1ERROR: ^7All Landing Pads Are Already Enabled");
    
    foreach(pad in GrabPadUniTriggers())
        pad notify("trigger");
}

AreLandingPadsEnabled()
{
    pads = GrabPadUniTriggers();
    return !pads.size;
}

GrabPadUniTriggers()
{
    if(!IsDefined(level._unitriggers))
        return;
    
    if(!IsDefined(level._unitriggers.trigger_stubs))
        return;
    
    pads      = [];
    padStruct = struct::get_array("115_flinger_landing_pad", "targetname");
    
    for(a = 0; a < level._unitriggers.trigger_stubs.size; a++)
    {
        if(IsDefined(level._unitriggers.trigger_stubs[a]))
        {
            for(b = 0; b < padStruct.size; b++)
            {
                if(IsDefined(padStruct[b]) && level._unitriggers.trigger_stubs[a].origin == padStruct[b].origin + vectorScale((0, 0, 1), 30))
                    pads[pads.size] = level._unitriggers.trigger_stubs[a];
            }
        }
    }

    return pads;
}

DiscoInferno()
{
    if(level flag::get("ee_disco_inferno"))
        return self iPrintlnBold("^1ERROR: ^7The Disco Inferno Side EE Is Already Enabled");
    
    level flag::set("ee_disco_inferno");
}

ClawHat()
{
    if(level flag::get("ee_claw_hat"))
        return self iPrintlnBold("^1ERROR: ^7The Claw Hat Side EE Has Already Been Completed");
    
    if(Is_True(level.ClawHat))
        return self iPrintlnBold("^1ERROR: ^7The Claw Hat Side EE Is Already Being Completed");
    
    menu = self getCurrent();
    curs = self getCursor();
    level.ClawHat = true;

    foreach(claw in level.var_23825200)
    {
        if(!IsDefined(claw) || IsDefined(claw) && claw flag::get("mechz_claw_revealed"))
            continue;
        
        MagicBullet(level.start_weapon, claw.origin, claw.origin + (0, 0, -5), self);
        wait 0.1;
    }

    wait 1;
    
    foreach(claw in level.var_23825200)
    {
        if(!IsDefined(claw))
            continue;
        
        mechz = ServerSpawnMechz(claw.origin + (AnglesToForward(claw.angles) * 255));
        wait 0.1;

        if(!IsDefined(mechz))
            continue;

        MagicBullet(level.start_weapon, claw.origin, claw.origin + (0, 0, 5), self);
    }

    while(!level flag::get("ee_claw_hat"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

PlungerMelee()
{
    if(self HasWeapon(GetWeapon("knife_plunger")))
        return;
    
    if(Is_True(level.completingPlungerEE))
        return;
    
    level.completingPlungerEE = true;
    
    curs = self getCursor();
    menu = self getCurrent();
    
    plunger_ent = struct::get("ee_plunger_pickup");

    if(IsDefined(plunger_ent))
        trig_stub = plunger_ent.unitrigger_stub.stub;

    zm_spawner::register_zombie_death_event_callback(::plunger_zombie_kill);

    foreach(player in level.activePlayers)
    {
        if(IsDefined(player) && Is_Alive(player))
            player thread award_player_plunger();
    }

    callback::on_spawned(::award_player_plunger);

    if(IsDefined(trig_stub))
        trig_stub zm_unitrigger::run_visibility_function_for_all_triggers();
    
    while(!self HasWeapon(GetWeapon("knife_plunger")))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
    level.completingPlungerEE = undefined;
}

plunger_zombie_kill(e_attacker)
{
    m_weap = GetWeapon("knife_plunger");

    if(m_weap == self.damageWeapon)
    {
        self zombie_utility::zombie_head_gib();
        return true;
    }

    return false;
}

award_player_plunger()
{
    self.widows_wine_knife_override = ::function_9ce92341;
    self zm_melee_weapon::award_melee_weapon("knife_plunger");
    self thread function_9daec9e3();
    self thread function_1fcb04d7();
}

function_9ce92341(){}

function_9daec9e3()
{
    self endon("disconnect");

    m_weap = GetWeapon("knife_plunger");

    while(1)
    {
        self waittill("weapon_melee", weapon);
        
        if(weapon == m_weap && IsDefined(self.var_ea5424ae) && self.var_ea5424ae > 0)
            self clientfield::increment_to_player("plunger_charged_strike");
    }
}

function_1fcb04d7()
{
    self endon("disconnect");

    self waittill("bled_out");
    self.widows_wine_knife_override = undefined;
}


















//Fire Bow Quest
InitFireBow()
{
    if(IsDefined(level.var_714fae39))
        return;
    
    if(Is_True(level.InitFireBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitFireBow = true;
    
    menu = self getCurrent();
    curs = self getCursor();
    clock = GetEnt("aq_rp_clock_wall_trig", "targetname");

    if(IsDefined(clock))
        MagicBullet(GetWeapon("elemental_bow"), clock.origin, clock.origin + (0, 5, 0), self);

    while(!IsDefined(level.var_714fae39) || !level.var_714fae39)
        wait 0.1;

    self RefreshMenu(menu, curs);
}

MagmaRock()
{
    if(Is_True(level.MagmaRock))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(level flag::get("rune_prison_obelisk"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(!IsDefined(level.var_c62829c7))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.MagmaRock = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    level flag::set("rune_prison_obelisk_magma_enabled");
    wait 0.1;

    rock = GetEnt("aq_rp_obelisk_magma_trig", "targetname");

    if(IsDefined(rock))
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
    
    if(!IsDefined(level.var_c62829c7))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.ChargingCircles = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    level.var_c62829c7.is_flung = true;
    wait 1;

    circles = GetEntArray("aq_rp_runic_circle_volume", "script_noteworthy");

    if(IsDefined(circles))
    {
        for(a = 0; a < circles.size; a++)
        {
            if(!IsDefined(circles[a]) || circles[a] flag::get("runic_circle_activated"))
                continue;
            
            cirTarget = GetEnt(circles[a].target + "_trig", "targetname");

            if(IsDefined(cirTarget))
                MagicBullet(GetWeapon("elemental_bow"), cirTarget.origin, cirTarget.origin, level.var_c62829c7);
            
            wait 0.05;
        }
    }

    wait 1;
    level.var_c62829c7.is_flung = false;
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
    if(!IsDefined(self) || self flag::get("runic_circle_charged"))
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

    if(IsDefined(circles) && circles.size)
    {
        for(a = 0; a < circles.size; a++)
        {
            if(!IsDefined(circles[a]))
                continue;
            
            if(!circles[a] flag::exists("runic_circle_activated") || !circles[a] flag::get("runic_circle_activated") || !circles[a] flag::exists("runic_circle_charged") || !circles[a] flag::get("runic_circle_charged"))
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
    
    if(!IsDefined(level.var_c62829c7))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");

    level.ClockFireplaceStep = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    clock = struct::get("aq_rp_clock_use_struct", "targetname");
    clock.var_67b5dd94 notify("trigger", level.var_c62829c7);

    while(!IsDefined(level.var_2e55cb98))
        wait 1;

    level.var_c62829c7 FreezeControls(1);
    level.var_2e55cb98.origin = level.var_c62829c7.origin;
    wait 1;

    target = GetEnt(level.var_2e55cb98.var_336f1366.target, "targetname");
    firePlace = LocateFireplace(); //Need to find the fireplace before this part of the step is completed

    if(IsDefined(target))
    {
        for(a = 0; a < 2; a++) //Target must be hit twice
        {
            MagicBullet(GetWeapon("elemental_bow"), target.origin, target.origin + (0, 5, 0), level.var_c62829c7);
            wait 0.1;
        }
    }

    if(IsDefined(firePlace))
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

    if(IsDefined(circles))
    {
        for(a = 0; a < circles.size; a++)
        {
            if(!IsDefined(circles[a]))
                continue;
            
            for(b = 0; b < firePlaces.size; b++)
            {
                if(circles[a].script_label == firePlaces[b].script_noteworthy)
                    return firePlaces[b];
            }
        }
    }
}

IsClockFireplaceComplete()
{
    magmaBall = GetEnt("aq_rp_magma_ball_tag", "targetname");

    if(level flag::exists("rune_prison_golf") && level flag::get("rune_prison_golf"))
    {
        if(!IsDefined(magmaBall))
            return true;
        
        if(IsDefined(magmaBall) && magmaBall flag::exists("magma_ball_move_done") && magmaBall flag::get("magma_ball_move_done"))
            return true;
    }

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
    
    if(!IsDefined(level.var_c62829c7))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");

    level.CollectRepairedFireArrows = true;

    menu = self getCurrent();
    curs = self getCursor();
    
    MagmaBall = struct::get("quest_reforge_rune_prison", "targetname");

    if(IsDefined(MagmaBall))
        MagmaBall.var_67b5dd94 notify("trigger", level.var_c62829c7);

    wait 9;

    if(IsDefined(MagmaBall))
        MagmaBall.var_67b5dd94 notify("trigger", level.var_c62829c7);
    
    while(!level flag::get("rune_prison_repaired"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}


















//Lightning Bow Quest
InitLightningBow()
{
    trig = GetEnt("aq_es_weather_vane_trig", "targetname");

    if(!IsDefined(trig))
        return;

    if(Is_True(level.InitLightningBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitLightningBow = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    if(IsDefined(trig))
        MagicBullet(GetWeapon("elemental_bow"), trig.origin, trig.origin + (0, 0, 5), self);

    while(IsDefined(trig))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

LightningBeacons()
{
    if(AreBeaconsLit())
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.LightningBeacons))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_f8d1dc16))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.LightningBeacons = true;

    menu = self getCurrent();
    curs = self getCursor();

    beacons = GetEntArray("aq_es_beacon_trig", "script_noteworthy");

    for(a = 0; a < beacons.size; a++)
    {
        if(!IsDefined(beacons[a]))
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

    if(!IsDefined(beacons))
        return false;

    for(a = 0; a < beacons.size; a++)
    {
        if(!IsDefined(beacons[a]))
            continue;
        
        s_beacon = struct::get(beacons[a].target);

        if(!IsDefined(s_beacon) || !IsDefined(s_beacon.var_41f52afd) || !s_beacon.var_41f52afd clientfield::get("beacon_fx"))
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
    
    if(!IsDefined(level.var_f8d1dc16))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.LightningWallrun = true;

    menu = self getCurrent();
    curs = self getCursor();
    trigs = GetEntArray("aq_es_wallrun_trigger", "targetname");

    for(a = 0; a < trigs.size; a++)
    {
        if(!IsDefined(trigs[a]) || IsDefined(level.var_f8d1dc16.var_a4f04654) && level.var_f8d1dc16.var_a4f04654 >= 4)
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
    
    if(!IsDefined(level.var_f8d1dc16))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.LightningChargeBeacons = true;

    menu = self getCurrent();
    curs = self getCursor();

    if(!level flag::get("elemental_storm_batteries"))
    {
        beacons = GetEntArray("aq_es_battery_volume", "script_noteworthy");

        for(a = 0; a < beacons.size; a++)
        {
            if(!IsDefined(beacons[a]))
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
        if(!IsDefined(bTrigs[a]) || IsDefined(bTrigs[a].b_charged) && bTrigs[a].b_charged)
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
            if(!IsDefined(charged[a]) || isInArray(used, a) || Is_True(chosen))
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
    
    if(!IsDefined(level.var_f8d1dc16))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");

    level.ChargeLightningArrows = true;

    menu = self getCurrent();
    curs = self getCursor();
    storm = struct::get("quest_reforge_elemental_storm");

    if(IsDefined(storm))
        storm.var_67b5dd94 notify("trigger", level.var_f8d1dc16);

    wait 18;

    if(IsDefined(storm))
        storm.var_67b5dd94 notify("trigger", level.var_f8d1dc16);

    while(!level flag::get("elemental_storm_repaired"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}





















//Void Bow Quest
InitVoidBow()
{
    if(level clientfield::get("quest_state_demon") > 0)
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.InitVoidBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitVoidBow = true;

    menu = self getCurrent();
    curs = self getCursor();
    symbol = GetEnt("aq_dg_gatehouse_symbol_trig", "targetname");

    if(IsDefined(symbol))
        MagicBullet(GetWeapon("elemental_bow"), symbol.origin, symbol.origin + (0, 0, 5), self);

    while(IsDefined(symbol))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

ReleaseDemonUrn()
{
    if(level flag::get("demon_gate_seal"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.ReleaseDemonUrn))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_6e68c0d8))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
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

    if(!IsDefined(fossils) || !fossils.size)
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.TriggerDemonFossils))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(Is_True(level.ReleaseDemonUrn))
        return self iPrintlnBold("^1ERROR: ^7Release Demon Urn Is Still Being Completed");
    
    if(!IsDefined(level.var_6e68c0d8))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.TriggerDemonFossils = true;

    menu = self getCurrent();
    curs = self getCursor();

    for(a = 0; a < fossils.size; a++)
    {
        if(!IsDefined(fossils[a]))
            continue;
        
        fossils[a].var_67b5dd94 notify("trigger", level.var_6e68c0d8);
        wait 0.1;
    }

    while(1)
    {
        fossils = GetEntArray("aq_dg_fossil", "script_noteworthy");

        if(!IsDefined(fossils) || !fossils.size)
            break;
        
        wait 0.1;
    }
    
    self RefreshMenu(menu, curs);
}

FeedDemonUrn()
{
    fossils = GetEntArray("aq_dg_fossil", "script_noteworthy");

    if(IsDefined(fossils) && fossils.size || level clientfield::get("quest_state_demon") < 3)
        return self iPrintlnBold("^1ERROR: ^7All Fossil Heads Must Be Triggered First");
    
    if(level flag::get("demon_gate_crawlers"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.FeedDemonUrn))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_6e68c0d8))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.FeedDemonUrn = true;

    menu = self getCurrent();
    curs = self getCursor();
    wait 2;

    urnTrig = GetEnt("aq_dg_trophy_room_trig", "targetname");

    if(IsDefined(urnTrig))
        urnTrig notify("trigger", level.var_6e68c0d8);

    wait 0.1;
    urn = GetEnt("aq_dg_demonic_circle_volume", "targetname");

    sacrificedZombies = [];
    goalEnt = GetEnt("aq_dg_demonic_circle_volume", "targetname");

    while(urn.var_e1f456ae < 6)
    {
        sacrificedZombie = SpawnSacrificedZombie(goalEnt);

        if(IsDefined(sacrificedZombie))
            sacrificedZombies[sacrificedZombies.size] = sacrificedZombie;
        
        wait 1;
    }

    while(!level flag::get("demon_gate_crawlers"))
        wait 0.1;
    
    if(IsDefined(sacrificedZombies) && sacrificedZombies.size)
    {
        for(a = 0; a < sacrificedZombies.size; a++)
        {
            if(!IsDefined(sacrificedZombies[a]) || !IsAlive(sacrificedZombies[a]))
                continue;
            
            sacrificedZombies[a] DoDamage(sacrificedZombies[a].health + 666, sacrificedZombies[a].origin);
        }
    }
    
    self RefreshMenu(menu, curs);
}

InscribeDemonName()
{
    if(!level flag::get("demon_gate_crawlers") || level clientfield::get("quest_state_demon") < 4)
        return self iPrintlnBold("^1ERROR: ^7You Must Feed The Demon Urn First");
    
    if(level flag::get("demon_gate_runes"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.InscribeDemonName))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_6e68c0d8))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    menu = self getCurrent();
    curs = self getCursor();
    level.InscribeDemonName = true;
    
    powerups = GetArrayKeys(level.zombie_include_powerups);

    for(a = 0; a < powerups.size; a++)
    {
        if(!IsDefined(powerups[a]) || !IsSubStr(powerups[a], "rune"))
            continue;
        
        drop = level zm_powerups::specific_powerup_drop(powerups[a], level.var_6e68c0d8.origin);
    }

    wait 1;
    
    foreach(icon in struct::get_array("aq_dg_rune_sequence_struct", "script_noteworthy"))
    {
        foreach(trig in GetEntArray("aq_dg_circle_rune_trig", "targetname"))
        {
            iconTok = StrTok(icon.var_a991b2d8, "_");
            trigTok = StrTok(trig.script_noteworthy, "_");

            if(iconTok[(iconTok.size - 1)] != trigTok[(trigTok.size - 1)])
                continue;
            
            MagicBullet(GetWeapon("elemental_bow"), trig.origin + (0, 0, 5), trig.origin, level.var_6e68c0d8);
            wait 1;
        }
    }

    while(!level flag::get("demon_gate_runes"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
    wait 8;

    level.InscribeDemonName = BoolVar(level.InscribeDemonName);
}

CollectVoidArrow()
{
    if(!level flag::get("demon_gate_runes") || Is_True(level.InscribeDemonName))
        return self iPrintlnBold("^1ERROR: ^7You Must Inscribe The Demon Name First");
    
    if(level flag::get("demon_gate_repaired"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.CollectVoidArrow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_6e68c0d8))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    menu = self getCurrent();
    curs = self getCursor();
    level.CollectVoidArrow = true;

    reforgeGate = struct::get("quest_reforge_demon_gate", "targetname");
    reforgeGate.var_67b5dd94 notify("trigger", level.var_6e68c0d8);

    level waittill(#"hash_66b2458c");
    wait 4;

    reforgeGate.var_67b5dd94 notify("trigger", level.var_6e68c0d8);

    while(!level flag::get("demon_gate_repaired"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}




























//Wolf Bow Quest
InitWolfBow()
{
    if(level flag::get("wolf_howl_paintings"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(!self HasWeapon(getweapon("elemental_bow")))
        return self iPrintlnBold("^1ERROR: ^7You Need To Have The Elemental Bow To Complete This Step");
    
    if(Is_True(level.InitWolfBow))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.InitWolfBow = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    paintings = Array("p7_zm_ctl_kings_painting_01", "p7_zm_ctl_kings_painting_02", "p7_zm_ctl_kings_painting_03", "p7_zm_ctl_kings_painting_04");
    paintStruct = struct::get_array("aq_wh_painting_struct", "script_noteworthy");

    for(a = 0; a < paintings.size; a++)
    {
        for(b = 0; b < paintStruct.size; b++)
        {
            if(paintStruct[b].var_b5b31795.model != paintings[a])
                continue;
            
            paintStruct[b].var_67b5dd94 notify("trigger", self);
        }

        wait 0.1;
    }

    while(!level flag::get("wolf_howl_paintings"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

CollectSkullShrine()
{
    if(!level flag::get("wolf_howl_paintings"))
        return self iPrintlnBold("^1ERROR: ^7The Wolf Bow Quest Must Be Initiated First");
    
    if(level clientfield::get("quest_state_wolf") >= 2)
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");

    if(Is_True(level.CollectSkullShrine))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_52978d72))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.CollectSkullShrine = true;

    menu = self getCurrent();
    curs = self getCursor();
    
    shrine = GetEnt("aq_wh_skull_shrine_trig", "targetname");
    MagicBullet(GetWeapon("elemental_bow"), shrine.origin + (0, 0, 5), shrine.origin, level.var_52978d72);
    wait 10;

    skull = GetEnt("wolf_skull_roll_down", "targetname");
    skull.var_67b5dd94 notify("trigger", level.var_52978d72);
    wait 3;

    while(1)
    {
        skull = GetEnt("wolf_skull_roll_down", "targetname");

        if(!IsDefined(skull))
            break;
        
        wait 0.1;
    }
    
    self RefreshMenu(menu, curs);
    level.CollectSkullShrine = BoolVar(level.CollectSkullShrine);
}

WolfAttachSkull()
{
    if(level clientfield::get("quest_state_wolf") < 2 || Is_True(level.CollectSkullShrine))
        return self iPrintlnBold("^1ERROR: ^7Skull Shrine Must Be Collected First");
    
    if(level clientfield::get("quest_state_wolf") >= 3)
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");

    if(Is_True(level.WolfAttachSkull))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_52978d72))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    menu = self getCurrent();
    curs = self getCursor();
    
    level.WolfAttachSkull = true;

    skull = GetEnt("aq_wh_skadi_skull", "targetname");
    skull.var_67b5dd94 notify("trigger", level.var_52978d72);

    while(level clientfield::get("quest_state_wolf") < 2)
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

CollectWolfSouls()
{
    if(level clientfield::get("quest_state_wolf") < 3)
        return self iPrintlnBold("^1ERROR: ^7You Must Attach The Skull To The Skeleton First");
    
    if(level flag::get("wolf_howl_escort"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");

    if(Is_True(level.CollectWolfSouls))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_52978d72))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    menu = self getCurrent();
    curs = self getCursor();
    
    level.CollectWolfSouls = true;
    self iPrintlnBold("^1" + ToUpper(GetMenuName()) + ": ^7This Step Is Going To Take A Few Minutes To Complete");

    while(!level flag::get("wolf_howl_escort"))
    {
        /*
            This notify will end the script checking if the player loses the wolf.
            Usually, if the player loses the wolf(wolf isn't in sight of the player for too long) it will end the quest step, and it will have to be started again by the player
        */
        level.var_52978d72 notify("player_found_skadi");

        if(!IsDefined(level.var_e6d07014) && !level flag::get("wolf_howl_escort")) //This is a fail safe, in the case the quest step gets killed. It will allow the script to be ran again when the step is restarted
        {
            self iPrintlnBold("^1ERROR: ^7Failed To Escort & Collect Wolf Souls");
            break;
        }
        
        if(IsDefined(level.var_e6d07014.var_5c4d212e) && !level.var_e6d07014.var_5c4d212e flag::get("dig_spot_complete"))
        {
            sacrificedZombies = [];
            targetName = level.var_e6d07014.var_5c4d212e.targetName;
            targetToks = StrTok(targetName, "_");

            while(level.var_e6d07014.var_5c4d212e.var_252d000d < 10)
            {
                zombie = SpawnSacrificedZombie(level.var_e6d07014.var_5c4d212e);

                if(IsDefined(zombie))
                {
                    sacrificedZombies[sacrificedZombies.size] = zombie;
                    MagicBullet(GetWeapon("elemental_bow"), zombie.origin + (0, 0, 5), zombie.origin, level.var_52978d72);
                }
                
                wait 0.05;
            }

            wait 10;
            bonePile = GetEnt("aq_wh_bones_" + targetToks[(targetToks.size - 1)], "targetname");
            bonePile.var_67b5dd94 notify("trigger", level.var_52978d72);

            if(IsDefined(sacrificedZombies) && sacrificedZombies.size)
            {
                for(a = 0; a < sacrificedZombies.size; a++)
                {
                    if(!IsDefined(sacrificedZombies[a]) || !IsAlive(sacrificedZombies[a]))
                        continue;
                    
                    sacrificedZombies[a] DoDamage(sacrificedZombies[a].health + 666, sacrificedZombies[a].origin);
                }
            }
        }

        wait 1;
    }

    level.CollectWolfSouls = BoolVar(level.CollectWolfSouls);
    self RefreshMenu(menu, curs);
}

CollectReforgedArrows()
{
    if(!level flag::get("wolf_howl_escort"))
        return self iPrintlnBold("^1ERROR: ^7You Must Escort & Collect Wolf Souls First");
    
    if(level flag::get("wolf_howl_repaired"))
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.CollectReforgedArrows))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    if(!IsDefined(level.var_52978d72))
        return self iPrintlnBold("^1ERROR: ^7There Is No Player Bound To The Quest");
    
    level.CollectReforgedArrows = true;
    
    menu = self getCurrent();
    curs = self getCursor();
    rtnValue = level.var_52978d72.var_374fd3ef;
    
    damageTrig = GetEnt("aq_wh_burial_chamber_damage_trig", "targetname");
    level.var_52978d72 thread WolfWallRunning();
    MagicBullet(GetWeapon("elemental_bow"), damageTrig.origin + (AnglesToForward(damageTrig.angles) * -10), damageTrig.origin + (0, 0, 5), level.var_52978d72);

    ledgeCollision = GetEnt("aq_wh_ledge_collision", "targetname");

    while(!ledgeCollision flag::get("ledge_built"))
        wait 0.1;

    reforgedArrows = struct::get("quest_reforge_wolf_howl", "targetname");
    reforgedArrows.var_67b5dd94 notify("trigger", level.var_52978d72);

    wait 5.5;
    reforgedArrows.var_67b5dd94 notify("trigger", level.var_52978d72);

    while(!level flag::get("wolf_howl_repaired"))
        wait 0.1;
    
    self RefreshMenu(menu, curs);
}

WolfWallRunning()
{
    self endon("disconnect");

    ledgeCollision = GetEnt("aq_wh_ledge_collision", "targetname");

    while(!level flag::get("wolf_howl_repaired"))
    {
        self.var_374fd3ef = true;
        wait 0.01;
    }
}