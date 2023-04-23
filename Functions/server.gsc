SuperJump()
{
    level.SuperJump = isDefined(level.SuperJump) ? undefined : true;
    SetJumpHeight(isDefined(level.SuperJump) ? 1023 : 39);
}

LowGravity()
{
    SetDvar("bg_gravity", (GetDvarInt("bg_gravity") == level.BgGravity) ? 200 : level.BgGravity);
}

SuperSpeed()
{
    SetDvar("g_speed", (GetDvarString("g_speed") == level.GSpeed) ? "500" : level.GSpeed);
}

SetRound(round)
{
    round--;

    if(round >= 255)
        round = 254;
    
    if(round <= 0)
        round = 1;
    
    level.zombie_total = 0;
	level.round_number = round;
	world.roundnumber = (round ^ 115);
    SetRoundsPlayed(round);

    level notify("kill_round");

    wait 1;

    for(a = 0; a < 3; a++)
    {
	    KillZombies("Head Gib");

        wait 0.15;
    }

    foreach(player in level.players)
        if(player.sessionstate == "spectator")
            player thread ServerRespawnPlayer(player);
}

AntiQuit()
{
    level.AntiQuit = isDefined(level.AntiQuit) ? undefined : true;
    SetMatchFlag("disableIngameMenu", isDefined(level.AntiQuit));
}

AntiJoin()
{
    level.AntiJoin = isDefined(level.AntiJoin) ? undefined : true;
}

AntiEndGame()
{
    level.AntiEndGame = isDefined(level.AntiEndGame) ? undefined : true;

    if(isDefined(level.AntiEndGame))
    {
        level.hostforcedend = true;
        level.forcedend = true;
        level.gameended = true;
        
        foreach(player in level.players)
            player thread WatchForEndRound();
    }
    else
    {
        level notify("EndAntiEndGame");

        level.hostforcedend = false;
        level.forcedend = false;
        level.gameended = false;
    }
}

WatchForEndRound()
{
    self endon("disconnect");
    level endon("EndAntiEndGame");

    while(isDefined(level.AntiEndGame))
    {
        self waittill("menuresponse", menu, response);

        if(response == "endround" || response == "killserverpc" || response == "endgame")
        {
            if(self IsHost())
            {
                level.hostforcedend = false;
                level.forcedend = false;
                level.gameended = false;
                wait 0.1;

                level thread globallogic::forceEnd();
            }
            else
            {
                self iPrintlnBold("^1ERROR: ^7" + level.menuName + " Blocked End Game Response");
                bot::get_host_player() iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^2" + CleanName(self getName()) + " ^7Tried To End The Game");
            }
        }
    }
}

AutoRevive()
{
    level.AutoRevive = isDefined(level.AutoRevive) ? undefined : true;

    while(isDefined(level.AutoRevive))
    {
        foreach(player in level.players)
            if(player isDown())
                player thread PlayerRevive(player);

        wait 0.1;
    }
}

AutoRespawn()
{
    level.AutoRespawn = isDefined(level.AutoRespawn) ? undefined : true;

    while(isDefined(level.AutoRevive))
    {
        foreach(player in level.players)
            if(player.sessionstate == "spectator")
                player thread ServerRespawnPlayer(player);

        wait 0.1;
    }
}

SetAutoVerification(num)
{
    level.AutoVerify = num;
    self thread SetVerificationAllPlayers(num);
}

ServerPauseWorld()
{
    level.ServerPauseWorld = isDefined(level.ServerPauseWorld) ? undefined : true;
    SetPauseWorld(isDefined(level.ServerPauseWorld));
}

Doheart()
{
    level.Doheart = isDefined(level.Doheart) ? undefined : true;

    if(isDefined(level.Doheart))
        level thread SetDoheartText(level.DoheartSavedText, true);
    else
    {
        if(isDefined(level.DoheartText))
            level.DoheartText destroy();
    }
}

SetDoheartText(text, refresh)
{
    if(level.DoheartSavedText == text && (!isDefined(refresh) || !refresh))
        return;
    
    level.DoheartSavedText = text;

    if(!isDefined(level.Doheart) || !isDefined(text))
        return;
    
    if(isDefined(level.DoheartText))
        level.DoheartText destroy();

    level.DoheartText = level createServerText("objective", 2, 1, "", "CENTER", "CENTER", 0, -215, 1, (1, 1, 1));
    
    switch(level.DoheartStyle)
    {
        case "Pulsing":
            level thread PulsingText(level.DoheartSavedText, level.DoheartText);
            break;
        
        case "Pulse Effect":
            level thread PulseFXText(level.DoheartSavedText, level.DoheartText);
            break;
        
        case "Moving":
            level thread RandomPosText(level.DoheartSavedText, level.DoheartText);
            break;
        
        case "Fade Effect":
            level thread FadingTextEffect(level.DoheartSavedText, level.DoheartText);
            break;
        
        default:
            break;
    }
}

DoheartTextPass(string)
{
    if(string != "Custom")
        self thread SetDoheartText(string);
    else
        self Keyboard("Doheart Text", ::SetDoheartText);
}

SetDoheartStyle(style)
{
    if(level.DoheartStyle == style)
        return;
    
    level.DoheartStyle = style;

    if(isDefined(level.Doheart) && isDefined(level.DoheartSavedText))
        level thread SetDoheartText(level.DoheartSavedText, true);
}

LobbyTimer()
{
    level.LobbyTimer = isDefined(level.LobbyTimer) ? undefined : true;

    if(isDefined(level.LobbyTimer))
    {
        level endon("EndLobbyTimer");

        n_time = (level.LobbyTime * 60);

        foreach(player in level.players)
        {
            player.LobbyTimer = player OpenLUIMenu("HudElementTimer");

            player SetLUIMenuData(player.LobbyTimer, "x", 25);
            player SetLUIMenuData(player.LobbyTimer, "y", 600);
            player SetLUIMenuData(player.LobbyTimer, "height", 28);
            player SetLUIMenuData(player.LobbyTimer, "time", (GetTime() + (n_time * 1000)));
        }

        wait (level.LobbyTime * 60);

        foreach(player in level.players)
            if(isDefined(player.LobbyTimer))
                player CloseLUIMenu(player.LobbyTimer);
        
        if(isDefined(level.AntiEndGame))
            level AntiEndGame();

        level thread globallogic::forceend();
    }
    else
    {
        foreach(player in level.players)
            if(isDefined(player.LobbyTimer))
                player CloseLUIMenu(player.LobbyTimer);

        level notify("EndLobbyTimer");
    }
}

SetLobbyTimer(time)
{
    if(time <= 0)
        return self iPrintln("^1ERROR: ^7Lobby Timer Must Be Greater Than 0");

    level.LobbyTime = time;

    if(isDefined(level.LobbyTimer))
        for(a = 0; a < 2; a++)
            LobbyTimer();
}

OpenAllDoors()
{
    if(IsAllDoorsOpen())
        return;
    
    curs = self getCursor();
    menu = self getCurrent();
    
    SetDvar("zombie_unlock_all", 1);
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];

    for(i = 0; i < 2; i++) //Runs twice to ensure all doors open
    {
        for(a = 0; a < types.size; a++)
        {
            doors = GetEntArray(types[a], "targetname");

            if(isDefined(doors))
            {
                for(b = 0; b < doors.size; b++)
                {
                    if(isDefined(doors[b]))
                    {
                        if(types[a] == "zombie_door" && doors[b] IsDoorOpen(types[a]))
                            continue;
                        
                        if(types[a] == "zombie_debris")
                            doors[b] notify("trigger", self, 1);
                        else
                        {
                            doors[b] notify("trigger");

                            if(types[a] == "zombie_door")
                            {
                                if(doors[b].script_noteworthy == "electric_door" || doors[b].script_noteworthy == "electric_buyable_door" || doors[b].script_noteworthy == "local_electric_door")
                                {
                                    if(doors[b].script_noteworthy == "local_electric_door")
                                        doors[b] notify("local_power_on");
                                    else
                                        doors[b] notify("power_on");
                                    
                                    doors[b].power_on = true;
                                }
                            }
                        }

                        wait 0.05;
                    }
                }
            }
        }

        if(IsAllDoorsOpen())
            break;

        wait 1;
    }

    level.local_doors_stay_open = 1;
	level.power_local_doors_globally = 1;

    wait 0.5;

    level notify("open_sesame");
    self RefreshMenu(menu, curs);

    wait 1;
    SetDvar("zombie_unlock_all", 0);
}

IsAllDoorsOpen()
{
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];

    for(a = 0; a < types.size; a++)
    {
        doors = GetEntArray(types[a], "targetname");

        if(isDefined(doors))
            for(b = 0; b < doors.size; b++)
                if(isDefined(doors[b]))
                    if(!doors[b] IsDoorOpen(types[a]))
                        return false;
    }
    
    return true;
}

IsDoorOpen(type)
{
    if(type == "zombie_door")
    {
        if(!isDefined(self.has_been_opened) || isDefined(self.has_been_opened) && !self.has_been_opened)
            return false;
    }
    else
    {
        if(isDefined(self.script_flag))
        {
            tokens = StrTok(self.script_flag, ",");

            for(a = 0; a < tokens.size; a++)
                if(!level flag::get(tokens[a]))
                    return false;
        }
    }

    return true;
}

SetZombieBarrierState(state)
{
    switch(state)
    {
        case "Repair All":
            windows = struct::get_array("exterior_goal", "targetname");

            for(a = 0; a < windows.size; a++)
            {
                if(zm_utility::all_chunks_intact(windows[a], windows[a].barrier_chunks))
                    continue;

                while(!zm_utility::all_chunks_intact(windows[a], windows[a].barrier_chunks))
                {
                    chunk = zm_utility::get_random_destroyed_chunk(windows[a], windows[a].barrier_chunks);

                    if(!isDefined(chunk))
                        break;

                    windows[a] thread zm_blockers::replace_chunk(windows[a], chunk, undefined, zm_powerups::is_carpenter_boards_upgraded(), 1);

                    if(isDefined(windows.clip))
                    {
                        windows.clip TriggerEnable(1);
                        windows.clip DisconnectPaths();
                    }
                    else
                        zm_blockers::blocker_disconnect_paths(windows.neg_start, windows.neg_end);
                }
            }
            break;
        
        case "Break All":
            zm_blockers::open_all_zbarriers();
            break;
        
        default:
            break;
    }
}

SpawnBot()
{
    bot = AddTestClient();

    if(!isDefined(bot))
        return self iPrintlnBold("^1ERROR: ^7Couldn't Spawn Bot");

    bot.pers["isBot"] = 1;

    wait 0.5;
    
    if(bot.sessionstate == "spectator")
        ServerRespawnPlayer(bot);
}

CollectCraftableParts(craftable)
{
    menu = self getCurrent();
    curs = self getCursor();

	foreach(part in level.zombie_include_craftables[craftable].a_piecestubs)
		if(isDefined(part.pieceSpawn))
			self zm_craftables::player_take_piece(part.pieceSpawn);
    
    wait 0.05;

    self RefreshMenu(menu, curs);
}

IsCraftableCollected(craftable)
{
    if(craftable == "open_table")
        return true;
    
    foreach(part in level.zombie_include_craftables[craftable].a_piecestubs)
        if(isDefined(part.pieceSpawn.model))
            return false;
    
    return true;
}

IsAllCraftablesCollected()
{
    craftables = GetArrayKeys(level.zombie_include_craftables);

    for(a = 0; a < craftables.size; a++)
        if(isDefined(craftables[a]) && craftables[a] != "open_table" && !IsCraftableCollected(craftables[a]))
            return false;
    
    return true;
}

SetBoxPrice(price)
{
    foreach(chest in level.chests)
    {
        chest.old_cost = price;
        
        if(!isDefined(level.zombie_vars["zombie_powerup_fire_sale_on"]) || isDefined(level.zombie_vars["zombie_powerup_fire_sale_on"]) && !level.zombie_vars["zombie_powerup_fire_sale_on"])
            chest.zombie_cost = price;
    }
}

ShowAllChests()
{
    if(isDefined(level.ShowAllChestsWaiting))
        return;
    level.ShowAllChestsWaiting = true;

    menu = self getCurrent();
    curs = self getCursor();

    if(!AllBoxesActive())
    {
        foreach(chest in level.chests)
        {
            if(chest.hidden)
                chest thread zm_magicbox::show_chest();
            
            chest thread TriggerFix();
            chest thread FirsaleFix();
        }
        
        SetDvar("magic_chest_movable", "0");

        while(!AllBoxesActive())
            wait 0.1;
        
        self RefreshMenu(menu, curs);
        level.ShowAllChestsWaiting = undefined;
    }
    else
    {
        foreach(chest in level.chests)
        {
            if(!chest.hidden && chest != level.chests[level.chest_index])
            {
                chest.was_temp = true;
                chest zm_magicbox::hide_chest();
            }
            
            chest notify("EndBoxFixes");
        }
        
        SetDvar("magic_chest_movable", "1");

        while(AllBoxesActive())
            wait 0.1;
        
        self RefreshMenu(menu, curs);
        level.ShowAllChestsWaiting = undefined;
    }
}

TriggerFix()
{
    self endon("EndBoxFixes");
    
    while(isDefined(self))
    {
        self.zbarrier waittill("closed");

        thread zm_unitrigger::register_static_unitrigger(self.unitrigger_stub, zm_magicbox::magicbox_unitrigger_think);
    }
}

FirsaleFix()
{
    self endon("EndBoxFixes");
    
    while(isDefined(self))
    {
        level waittill("fire_sale_off");

        self.was_temp = undefined;
    }
}

AllBoxesActive()
{
    foreach(chest in level.chests)
        if(chest.hidden)
            return false;
    
    return true;
}

BoxForceJoker()
{
    if(AllBoxesActive())
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While All Mystery Boxes Are Active");
    
    SetDvar("magic_chest_movable", "1");
    level.chest_accessed = 999;
    level.chest_moves = 0;

    self RefreshMenu(self getCurrent(), self getCursor()); //Needs to refresh the menu since 'magic_chest_movable' is a dvar used as a bool option
}

BoxNeverMoves()
{
    if(AllBoxesActive())
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While All Mystery Boxes Are Active");
    
    SetDvar("magic_chest_movable", (GetDvarString("magic_chest_movable") == "1") ? "0" : "1");
}

IsWeaponInBox(weapon)
{
    return isInArray(level.customBoxWeapons, weapon);
}

SetBoxWeaponState(weapon, upgraded)
{
    if(isInArray(level.customBoxWeapons, weapon))
        level.customBoxWeapons = ArrayRemove(level.customBoxWeapons, weapon);
    else
        level.customBoxWeapons[level.customBoxWeapons.size] = weapon;
    
    level.CustomRandomWeaponWeights = ::CustomBoxWeight;
}

IsAllWeaponsInBox()
{
    weaps = GetArrayKeys(level.zombie_weapons);
    weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
    equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
    equipmentCombined = GetArrayKeys(equipment);

    for(a = 0; a < weaps.size; a++)
        if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
            if(!IsWeaponInBox(weaps[a]))
                return false;
    
    if(!IsWeaponInBox(GetWeapon("minigun")))
        return false;
    
    if(!IsWeaponInBox(GetWeapon("defaultweapon")))
        return false;

    if(isDefined(equipmentCombined) && equipmentCombined.size)
        for(a = 0; a < weaps.size; a++)
            if(isInArray(equipment, weaps[a]))
                if(!IsWeaponInBox(weaps[a]))
                    return false;
    
    return true;
}

EnableAllWeaponsInBox()
{
    if(IsAllWeaponsInBox())
        level.customBoxWeapons = [];
    else
    {
        weaps = GetArrayKeys(level.zombie_weapons);
        weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
        equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
        keys = GetArrayKeys(equipment);

        for(a = 0; a < weaps.size; a++)
            if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                if(!IsWeaponInBox(weaps[a]))
                    level.customBoxWeapons[level.customBoxWeapons.size] = weaps[a];
        
        if(!IsWeaponInBox(GetWeapon("minigun")))
            level.customBoxWeapons[level.customBoxWeapons.size] = GetWeapon("minigun");
        
        if(!IsWeaponInBox(GetWeapon("defaultweapon")))
            level.customBoxWeapons[level.customBoxWeapons.size] = GetWeapon("defaultweapon");

        if(isDefined(keys) && keys.size)
            for(a = 0; a < weaps.size; a++)
                if(isInArray(equipment, weaps[a]) && !IsWeaponInBox(weaps[a]))
                    level.customBoxWeapons[level.customBoxWeapons.size] = weaps[a];
    }
}

CustomBoxWeight(keys)
{
    return array::randomize(level.customBoxWeapons);
}

SetBoxJokerModel(model)
{
    level.chest_joker_model = model;
}

ShootToRevive()
{
    level.ShootToRevive = isDefined(level.ShootToRevive) ? undefined : true;

    foreach(player in level.players)
    {
        if(isDefined(level.ShootToRevive))
            player thread PlayerShootToRevive();
        else
            player notify("EndShootToRevive");
    }
}

PlayerShootToRevive()
{
    self endon("disconnect");
    self endon("EndShootToRevive");

    while(isDefined(level.ShootToRevive))
    {
        self waittill("weapon_fired");

        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), true, self);
        traceBullet = self TraceBullet();
        tracePlayer = trace["entity"];

        if(isDefined(tracePlayer) && tracePlayer == self)
            tracePlayer = undefined;
        
        if(!isDefined(tracePlayer))
        {
            foreach(player in level.players)
                if(player != self && IsAlive(player) && player IsDown())
                    if(Distance(traceBullet, player.origin) <= 30)
                        if(!isDefined(tracePlayer) || isDefined(tracePlayer) && Distance(traceBullet, tracePlayer.origin) > Distance(traceBullet, player.origin))
                            tracePlayer = player;
        }

        if(isDefined(tracePlayer) && IsPlayer(tracePlayer) && IsAlive(tracePlayer) && tracePlayer IsDown())
        {
            if(isDefined(self.hud_damagefeedback))
                self zombie_utility::show_hit_marker();

            PlayerRevive(tracePlayer);
        }
    }
}

SetPackCamoIndex(index)
{
    level.pack_a_punch_camo_index = index;
}

SetPlayerWeaponLimit(limit)
{
    level.CustomPlayerWeaponLimit = limit;
    level.additionalprimaryweapon_limit = limit;

    foreach(player in level.players)
        if(isDefined(player.get_player_weapon_limit))
            player.get_player_weapon_limit = ::GetPlayerWeaponLimit;

    level.get_player_weapon_limit = ::GetPlayerWeaponLimit;
}

GetPlayerWeaponLimit(player)
{
    return level.CustomPlayerWeaponLimit;
}

SetPlayerPerkLimit(limit)
{
    level.CustomPerkLimit = limit;
    level.perk_purchase_limit = limit;
    level.get_player_perk_purchase_limit = ::GetPlayerPerkLimit;
}

GetPlayerPerkLimit(player)
{
    return level.CustomPerkLimit;
}

IncreasedDropRate()
{
    if((isDefined(level.no_powerups) && level.no_powerups) && !isDefined(level.IncreasedDropRate))
        level DisablePowerups();

    level.IncreasedDropRate = isDefined(level.IncreasedDropRate) ? undefined : true;

    while(isDefined(level.IncreasedDropRate))
    {
        level.powerup_drop_count = 0;
        level.zombie_vars["zombie_powerup_drop_max_per_round"] = 999;
        level.zombie_vars["zombie_drop_item"] = 1;
        
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(isDefined(zombies[a].no_powerup) && zombies[a].no_powerup)
                zombies[a].no_powerups = false;
        }

        wait 0.01;
    }
    
    if(!isDefined(level.IncreasedDropRate))
        level.zombie_vars["zombie_powerup_drop_max_per_round"] = 4;
}

PowerupsNeverLeave()
{
    level.PowerupsNeverLeave = isDefined(level.PowerupsNeverLeave) ? undefined : true;
    level._powerup_timeout_override = isDefined(level.PowerupsNeverLeave) ? PowerUpTime() : undefined;
}

PowerUpTime()
{
    return 0;
}

DisablePowerups()
{
    if(isDefined(level.IncreasedDropRate) && !isDefined(level.DisablePowerups))
        level IncreasedDropRate();

    level.DisablePowerups = isDefined(level.DisablePowerups) ? undefined : true;

    if(isDefined(level.DisablePowerups))
    {
        foreach(index, powerup in level.active_powerups)
        {
            powerup notify("powerup_timedout");
            powerup zm_powerups::powerup_delete();

            wait 0.01;
        }
        
        while(isDefined(level.DisablePowerups))
        {
            level waittill("powerup_dropped", powerup);
            
            if(isDefined(powerup))
            {
                powerup notify("powerup_timedout");
                powerup thread zm_powerups::powerup_delete();
            }
        }
    }
    else
        level.powerup_drop_count = 0;
}

headshots_only()
{
    level.headshots_only = isDefined(level.headshots_only) ? undefined : true;
}

ServerSetClipSizeMultiplier(multiplier)
{
    SetDvar("player_clipSizeMultiplier", multiplier);
}

EditPackAPunchPrice(price)
{
    vending_weapon_upgrade_trigger = level.pack_a_punch.triggers;

    if(isDefined(vending_weapon_upgrade_trigger) && vending_weapon_upgrade_trigger.size >= 1)
        foreach(index, trigger in vending_weapon_upgrade_trigger)
            trigger.cost = price;
}

EditRepackAPunchPrice(price)
{
    vending_weapon_upgrade_trigger = level.pack_a_punch.triggers;

    if(isDefined(vending_weapon_upgrade_trigger) && vending_weapon_upgrade_trigger.size >= 1)
        foreach(index, trigger in vending_weapon_upgrade_trigger)
            trigger.aat_cost = price;
}

ServerChangeMap(map)
{
    if(!MapExists(map))
        return self iPrintlnBold("Map Doesn't Exist");
    
    if(level.script == map)
        return;
    
    Map(map);
}

ServerRestartGame()
{
    Map_Restart(false);
}

ServerEndGame()
{
    if(isDefined(level.AntiEndGame))
        return self iPrintlnBold("^1ERROR: ^7You Can't End The Game While Anti-End Game Is Enabled");
    
    level globallogic::forceend();
}