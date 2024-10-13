PopulateServerModifications(menu)
{
    switch(menu)
    {
        case "Server Modifications":
            self addMenu("Server Modifications");
                self addOptBool(level.SuperJump, "Super Jump", ::SuperJump);
                self addOptBool((GetDvarInt("bg_gravity") == 200), "Low Gravity", ::LowGravity);
                self addOptBool((GetDvarString("g_speed") == "500"), "Super Speed", ::SuperSpeed);
                self addOptIncSlider("Timescale", ::ServerSetTimeScale, 0.5, GetDvarInt("timescale"), 5, 0.5);
                self addOpt("Set Round", ::NumberPad, ::SetRound);
                self addOptBool(level.AntiQuit, "Anti-Quit", ::AntiQuit);
                self addOptBool(level.AutoRevive, "Auto-Revive", ::AutoRevive);
                self addOptBool(level.AutoRespawn, "Auto-Respawn", ::AutoRespawn);
                self addOptBool(level.bzm_worldPaused, "Pause World", ::ServerPauseWorld);
                self addOptBool(level.Newsbar, "Newsbar", ::Newsbar);
                self addOpt("Doheart Options", ::newMenu, "Doheart Options");
                self addOpt("Lobby Timer Options", ::newMenu, "Lobby Timer Options");
                self addOptBool(IsAllDoorsOpen(), "Open All Doors & Debris", ::OpenAllDoors);
                self addOptSlider("Zombie Barriers", ::SetZombieBarrierState, "Break All;Repair All");
                self addOpt("Spawn Bot", ::SpawnBot);

                if(isDefined(level.zombie_include_craftables) && level.zombie_include_craftables.size && !isDefined(level.all_parts_required))
                    if(level.zombie_include_craftables.size > 1 || level.zombie_include_craftables.size && GetArrayKeys(level.zombie_include_craftables)[0] != "open_table")
                        self addOpt("Craftables", ::newMenu, "Zombie Craftables");

                if(isDefined(level.MenuZombieTraps) && level.MenuZombieTraps.size)
                    self addOpt("Zombie Traps", ::newMenu, "Zombie Traps");
                
                self addOpt("Mystery Box Options", ::newMenu, "Mystery Box Options");
                self addOpt("Server Tweakables", ::newMenu, "Server Tweakables");
                self addOpt("Change Map", ::newMenu, "Change Map");
                self addOpt("Restart Game", ::ServerRestartGame);
            break;
        
        case "Doheart Options":
            if(!isDefined(level.DoheartStyle))
                level.DoheartStyle = "Pulsing";
            
            if(!isDefined(level.DoheartSavedText))
                level.DoheartSavedText = CleanName(bot::get_host_player() getName());
            
            self addMenu("Doheart Options");
                self addOptBool(level.Doheart, "Doheart", ::Doheart);
                self addOptSlider("Text", ::DoheartTextPass, CleanName(bot::get_host_player() getName()) + ";" + level.menuName + ";CF4_99;Custom");
                self addOptSlider("Style", ::SetDoheartStyle, "Pulsing;Pulse Effect;Type Writer;Moving;Fade Effect");
            break;
        
        case "Lobby Timer Options":
            if(!isDefined(level.LobbyTime))
                level.LobbyTime = 10;
            
            self addMenu("Lobby Timer Options");
                self addOptBool(level.LobbyTimer, "Lobby Timer", ::LobbyTimer);
                self addOptIncSlider("Set Lobby Timer", ::SetLobbyTimer, 1, 10, 30, 1);
            break;
        
        case "Zombie Craftables":
            craftables = GetArrayKeys(level.zombie_include_craftables);

            self addMenu("Craftables");

                if(!IsAllCraftablesCollected())
                {
                    self addOpt("Collect All", ::CollectAllCraftables);
                    self addOpt("");
                }

                for(a = 0; a < craftables.size; a++)
                {
                    if(IsCraftableCollected(craftables[a]) || craftables[a] == "open_table" || IsSubStr(craftables[a], "ritual_"))
                        continue;
                    
                    self addOpt(CleanString(craftables[a]), ::newMenu, craftables[a]);
                }
            break;
        
        case "Zombie Traps":
            self addMenu("Zombie Traps");

                if(isDefined(level.MenuZombieTraps) && level.MenuZombieTraps.size)
                {
                    self addOpt("Activate All Traps", ::ActivateAllZombieTraps);

                    for(a = 0; a < level.MenuZombieTraps.size; a++)
                        if(isDefined(level.MenuZombieTraps[a]))
                        {
                            if(isDefined(level.MenuZombieTraps[a].prefabname))
                                optString = CleanString(level.MenuZombieTraps[a].prefabname);
                            else
                                optString = "Trap " + (a + 1);
                            
                            self addOpt(optString, ::ActivateZombieTrap, a);
                        }
                }
            break;
        
        case "Mystery Box Options":
            self addMenu("Mystery Box Options");
                self addOptBool(level.chests[level.chest_index].old_cost != 950, "Custom Price", ::NumberPad, ::SetBoxPrice);
                self addOptBool(AllBoxesActive(), "Show All", ::ShowAllChests);
                self addOpt("Force Joker", ::BoxForceJoker);
                self addOptBool((GetDvarString("magic_chest_movable") == "0"), "Never Moves", ::BoxNeverMoves);
                self addOpt("Weapons", ::newMenu, "Mystery Box Weapons");
                self addOpt("Joker Model", ::newMenu, "Joker Model");
            break;
        
        case "Mystery Box Weapons":
            self addMenu("Weapons");
                self addOpt("Normal", ::newMenu, "Mystery Box Normal Weapons");
                self addOpt("Upgraded", ::newMenu, "Mystery Box Upgraded Weapons");
            break;
        
        case "Joker Model":
            self addMenu("Joker Model");
                self addOptBool((level.chest_joker_model == level.savedJokerModel), "Reset", ::SetBoxJokerModel, level.savedJokerModel);

                for(a = 0; a < level.MenuModels.size; a++)
                    self addOptBool((level.chest_joker_model == level.MenuModels[a]), CleanString(level.MenuModels[a]), ::SetBoxJokerModel, level.MenuModels[a]);
            break;
        
        case "Server Tweakables":
            self addMenu("Server Tweakables");
                self addOptIncSlider("Pack 'a' Punch Camo Index", ::SetPackCamoIndex, 0, level.pack_a_punch_camo_index, 138, 1);
                self addOptIncSlider("Player Weapon Limit", ::SetPlayerWeaponLimit, 0, 0, 15, 1);
                self addOptIncSlider("Player Perk Limit", ::SetPlayerPerkLimit, 0, 0, level.MenuPerks.size, 1);
                self addOptIncSlider("Clip Size Multiplier", ::ServerSetClipSizeMultiplier, 1, 1, 10, 1);
                self addOptIncSlider("Revive Trigger Radius", ::ServerSetReviveRadius, 0, GetDvarInt("revive_trigger_radius"), 1000, 25);
                self addOptIncSlider("Last Stand Bleedout Time", ::ServerSetLastandTime, 0, GetDvarInt("player_lastStandBleedoutTime"), 1000, 1);
                self addOptBool(level.UpgradeWeaponWallbuys, "Upgrade Weapon Wallbuys", ::ServerUpgradeWeaponWallbuys);
                self addOptBool(level.ServerMaxAmmoClips, "Max Ammo Powerups Fill Clips", ::ServerMaxAmmoClips);
                self addOptBool(level.IncreasedDropRate, "Increased Power-Up Drop Rate", ::IncreasedDropRate);
                self addOptBool(level.PowerupsNeverLeave, "Power-Ups Never Leave", ::PowerupsNeverLeave);
                self addOptBool(level.DisablePowerups, "Disable Power-Ups", ::DisablePowerups);
                self addOptBool(level.ShootToRevive, "Shoot To Revive", ::ShootToRevive);
                self addOptBool(level.headshots_only, "Headshots Only", ::headshots_only);
                self addOpt("Pack 'a' Punch Price", ::NumberPad, ::EditPackAPunchPrice);
                self addOpt("Repack 'a' Punch Price", ::NumberPad, ::EditRepackAPunchPrice);
            break;
        
        case "Change Map":
            self addMenu("Change Map");

                for(a = 0; a < level.mapNames.size; a++)
                    self addOptBool((level.script == level.mapNames[a]), ReturnMapName(level.mapNames[a]), ::ServerChangeMap, level.mapNames[a]);
            break;
    }
}

SuperJump()
{
    if(!Is_True(level.SuperJump))
    {
        level.SuperJump = true;
        SetJumpHeight(1023);
    }
    else
    {
        level.SuperJump = false;
        SetJumpHeight(39);
    }
}

LowGravity()
{
    if(GetDvarInt("bg_gravity") == level.BgGravity)
        value = 200;
    else
        value = level.BgGravity;
    
    SetDvar("bg_gravity", value);
}

SuperSpeed()
{
    if(GetDvarString("g_speed") == level.GSpeed)
        value = "500";
    else
        value = level.GSpeed;
    
    SetDvar("g_speed", value);
}

ServerSetTimeScale(timescale)
{
    if(GetDvarInt("timescale") == timescale)
        return;
    
    SetDvar("timescale", timescale);
}

SetRound(round)
{
    round--;

    if(round >= 255)
        round = 254;
    
    if(round <= 0)
        round = 1;
    
    level.zombie_total = 0;
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
    if(!Is_True(level.AntiQuit))
        level.AntiQuit = true;
    else
        level.AntiQuit = false;

    SetMatchFlag("disableIngameMenu", level.AntiQuit);
}

AutoRevive()
{
    if(!Is_True(level.AutoRevive))
    {
        level.AutoRevive = true;

        while(Is_True(level.AutoRevive))
        {
            foreach(player in level.players)
                if(player isDown())
                    player thread PlayerRevive(player);

            wait 0.1;
        }
    }
    else
        level.AutoRevive = false;
}

AutoRespawn()
{
    if(!Is_True(level.AutoRespawn))
    {
        level.AutoRespawn = true;

        while(Is_True(level.AutoRespawn))
        {
            foreach(player in level.players)
                if(player.sessionstate == "spectator")
                    player thread ServerRespawnPlayer(player);

            wait 0.1;
        }
    }
    else
        level.AutoRespawn = false;
}

ServerPauseWorld()
{
    if(!Is_True(level.bzm_worldPaused))
    {
        level.bzm_worldPaused = true;
        level flag::set("world_is_paused");
    }
    else
    {
        level.bzm_worldPaused = false;
        level flag::clear("world_is_paused");
    }

    SetPauseWorld(level.bzm_worldPaused);
}

Newsbar()
{
    if(!Is_True(level.Newsbar))
    {
        level.Newsbar = true;

        level.NewsbarBG   = level createServerRectangle("CENTER", "CENTER", 0, -232, 5000, 18, (0, 0, 0), 1, 0.6, "white");
        level.NewsbarText = level createServerText("default", 1, 3, "", "CENTER", "CENTER", 0, -255, 1, (1, 1, 1));
        
        strings = Array("Welcome To ^1" + level.menuName + " ^7Developed By ^1CF4_99", "Your Host Today Is ^1" + CleanName(bot::get_host_player() getName()), "[{+speed_throw}] & [{+melee}] To Open ^1" + level.menuName, "YouTube.Com/^1CF4_99", "^5Enjoy Your Stay!");
        
        level endon("EndNewsBar");
        
        while(Is_True(level.Newsbar))
        {
            for(a = 0; a < strings.size; a++)
            {
                level.NewsbarText SetTextString(strings[a]);
                level.NewsbarText hudMoveY(-232, 0.55);
                level.NewsbarText ChangeFontscaleOverTime1(1.2, 0.75);
                wait 5;
                
                level.NewsbarText ChangeFontscaleOverTime1(1, 0.3);
                wait 0.3;
                
                level.NewsbarText thread hudMoveY(-255, 0.55);
                wait 0.55;
            }
        }
    }
    else
    {
        if(isDefined(level.NewsbarBG))
            level.NewsbarBG destroy();
        
        if(isDefined(level.NewsbarText))
            level.NewsbarText destroy();
        
        level notify("EndNewsBar");

        level.Newsbar = false;
    }
}

Doheart()
{
    if(!Is_True(level.Doheart))
    {
        level.Doheart = true;
        level thread SetDoheartText(level.DoheartSavedText, true);
    }
    else
    {
        level.Doheart = false;

        if(isDefined(level.DoheartText))
            level.DoheartText destroy();
    }
}

SetDoheartText(text, refresh)
{
    if(level.DoheartSavedText == text && (!isDefined(refresh) || !refresh))
        return;
    
    level.DoheartSavedText = text;

    if(!Is_True(level.Doheart) || !isDefined(text))
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
        
        case "Type Writer":
            level thread TypeWriterFXText(level.DoheartSavedText, level.DoheartText);
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
        self Keyboard(::SetDoheartText);
}

SetDoheartStyle(style)
{
    if(level.DoheartStyle == style)
        return;
    
    level.DoheartStyle = style;

    if(Is_True(level.Doheart) && isDefined(level.DoheartSavedText))
        level thread SetDoheartText(level.DoheartSavedText, true);
}

LobbyTimer()
{
    if(!Is_True(level.LobbyTimer))
    {
        level endon("EndLobbyTimer");

        level.LobbyTimer = true;

        n_time = (level.LobbyTime * 60);

        foreach(player in level.players)
        {
            player.LobbyTimer = player OpenLUIMenu("HudElementTimer", true);

            player SetLUIMenuData(player.LobbyTimer, "x", 25);
            player SetLUIMenuData(player.LobbyTimer, "y", 600);
            player SetLUIMenuData(player.LobbyTimer, "height", 28);
            player SetLUIMenuData(player.LobbyTimer, "time", (GetTime() + (n_time * 1000)));
        }

        wait (level.LobbyTime * 60);

        foreach(player in level.players)
            if(isDefined(player) && isDefined(player.LobbyTimer))
                player CloseLUIMenu(player.LobbyTimer);
        
        if(Is_True(level.AntiEndGame))
            level AntiEndGame();
        
        level thread globallogic::forceend();
    }
    else
    {
        foreach(player in level.players)
            if(isDefined(player.LobbyTimer))
                player CloseLUIMenu(player.LobbyTimer);

        level notify("EndLobbyTimer");
        level.LobbyTimer = false;
    }
}

SetLobbyTimer(time)
{
    if(time <= 0)
        return self iPrintln("^1ERROR: ^7Lobby Timer Must Be Greater Than 0");

    level.LobbyTime = time;

    if(Is_True(level.LobbyTimer))
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
    types = Array("zombie_door", "zombie_airlock_buy", "zombie_debris");

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
    if(Is_True(level.MoonDoors))
        return true;
    
    types = Array("zombie_door", "zombie_airlock_buy", "zombie_debris");

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
        if(!Is_True(self.has_been_opened))
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

                    if(isDefined(windows[a].clip))
                    {
                        windows[a].clip TriggerEnable(1);
                        windows[a].clip DisconnectPaths();
                    }
                    else
                        zm_blockers::blocker_disconnect_paths(windows[a].neg_start, windows[a].neg_end);
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
    bot.equipment_enabled = 0;
    wait 0.5;
    
    if(bot.sessionstate == "spectator")
        ServerRespawnPlayer(bot);
}

CollectAllCraftables()
{
    menu = self getCurrent();
    curs = self getCursor();
    
    keys = GetArrayKeys(level.zombie_include_craftables);

    foreach(key in keys)
    {
        if(IsCraftableCollected(key) || key == "open_table" || IsSubStr(key, "ritual_"))
            continue;
        
        foreach(part in level.zombie_include_craftables[key].a_piecestubs)
            if(isDefined(part.pieceSpawn))
                self zm_craftables::player_take_piece(part.pieceSpawn);
    }
    
    wait 0.05;
    self RefreshMenu(menu, curs);
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

CollectCraftablePart(part)
{
    menu = self getCurrent();
    curs = self getCursor();

    if(isDefined(part.pieceSpawn))
        self zm_craftables::player_take_piece(part.pieceSpawn);
    
    wait 0.05;
    self RefreshMenu(menu, curs);
}

IsCraftableCollected(craftable)
{
    if(craftable == "open_table" || IsSubStr(craftable, "ritual_"))
        return true;
    
    foreach(part in level.zombie_include_craftables[craftable].a_piecestubs)
        if(isDefined(part.pieceSpawn.model))
            return false;
    
    return true;
}

IsPartCollected(part)
{
    if(isDefined(part.pieceSpawn.model))
        return false;
    
    return true;
}

IsAllCraftablesCollected()
{
    craftables = GetArrayKeys(level.zombie_include_craftables);

    for(a = 0; a < craftables.size; a++)
        if(isDefined(craftables[a]) && !IsSubStr(craftables[a], "ritual_") && craftables[a] != "open_table" && !IsCraftableCollected(craftables[a]))
            return false;
    
    return true;
}

SetBoxPrice(price)
{
    foreach(chest in level.chests)
    {
        chest.old_cost = price;
        
        if(!Is_True(level.zombie_vars["zombie_powerup_fire_sale_on"]))
            chest.zombie_cost = price;
    }
}

ShowAllChests()
{
    if(Is_True(level.ShowAllChestsWaiting))
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
        level.ShowAllChestsWaiting = false;
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
        level.ShowAllChestsWaiting = false;
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
        if(Is_True(chest.hidden))
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
    
    if(GetDvarString("magic_chest_movable") == "1")
        value = "0";
    else
        value = "1";
    
    SetDvar("magic_chest_movable", value);
}

IsWeaponInBox(weapon)
{
    if(!isDefined(level.customBoxWeapons))
        return false;
    
    return isInArray(level.customBoxWeapons, weapon);
}

SetBoxWeaponState(weapon, upgraded)
{
    if(!isDefined(level.customBoxWeapons))
        return;
    
    if(isInArray(level.customBoxWeapons, weapon))
        level.customBoxWeapons = ArrayRemove(level.customBoxWeapons, weapon);
    else
        level.customBoxWeapons[level.customBoxWeapons.size] = weapon;
    
    level.CustomRandomWeaponWeights = ::CustomBoxWeight;
}

IsAllWeaponsInBox(type)
{
    weaps = GetArrayKeys(type);
    weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");
    typeArry = GetArrayKeys(level.zombie_weapons_upgraded);
    
    for(a = 0; a < weaps.size; a++)
    {
        if(weaps[0] == typeArry[0])
            classWeapons = zm_utility::GetWeaponClassZM(zm_weapons::get_base_weapon(weaps[a]));
        else
            classWeapons = zm_utility::GetWeaponClassZM(weaps[a]);

        if(IsInArray(weaponsVar, ToLower(CleanString(classWeapons))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
            if(!IsWeaponInBox(weaps[a]))
                return false;
    }
    
    if(weaps[0] != typeArry[0])
    {
        equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
        equipmentCombined = GetArrayKeys(equipment);

        if(!IsWeaponInBox(GetWeapon("minigun")))
            return false;
        
        if(!IsWeaponInBox(GetWeapon("defaultweapon")))
            return false;

        if(isDefined(equipmentCombined) && equipmentCombined.size)
            for(a = 0; a < weaps.size; a++)
                if(isInArray(equipment, weaps[a]))
                    if(!IsWeaponInBox(weaps[a]))
                        return false;
    }
    
    return true;
}

EnableAllWeaponsInBox(type)
{
    if(IsAllWeaponsInBox(type))
        level.customBoxWeapons = [];
    else
    {
        weaps = GetArrayKeys(type);
        weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");
        typeArry = GetArrayKeys(level.zombie_weapons_upgraded);
        
        for(a = 0; a < weaps.size; a++)
        {
            if(weaps[0] == typeArry[0])
                classWeapons = zm_utility::GetWeaponClassZM(zm_weapons::get_base_weapon(weaps[a]));
            else
                classWeapons = zm_utility::GetWeaponClassZM(weaps[a]);

            if(IsInArray(weaponsVar, ToLower(CleanString(classWeapons))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                if(!IsWeaponInBox(weaps[a]))
                    level.customBoxWeapons[level.customBoxWeapons.size] = weaps[a];
        }
        
        if(weaps[0] != typeArry[0])
        {
            equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
            keys = GetArrayKeys(equipment);

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
}

CustomBoxWeight(keys)
{
    return array::randomize(level.customBoxWeapons);
}

SetBoxJokerModel(model)
{
    level.chest_joker_model = model;
}

ServerUpgradeWeaponWallbuys()
{
    if(!Is_True(level.UpgradeWeaponWallbuys))
    {
        level.UpgradeWeaponWallbuys = true;

        if(isDefined(level.wallbuy_should_upgrade_weapon_override))
            level.saved_wallbuy_should_upgrade_weapon_override = level.wallbuy_should_upgrade_weapon_override;
        
        level.wallbuy_should_upgrade_weapon_override = ::wallbuy_should_upgrade_weapon_override;
    }
    else
    {
        level.UpgradeWeaponWallbuys = false;

        if(isDefined(level.saved_wallbuy_should_upgrade_weapon_override))
            level.wallbuy_should_upgrade_weapon_override = level.saved_wallbuy_should_upgrade_weapon_override;
        else
            level.wallbuy_should_upgrade_weapon_override = undefined;
    }
}

ServerMaxAmmoClips()
{
    if(!Is_True(level.ServerMaxAmmoClips))
    {
        level.ServerMaxAmmoClips = true;
        level thread WatchForMaxAmmo();
    }
    else
    {
        level.ServerMaxAmmoClips = false;
        level.WatchForMaxAmmo = false;
        level notify("EndMaxAmmoMonitor");
    }
}

ShootToRevive()
{
    if(!Is_True(level.ShootToRevive))
    {
        level.ShootToRevive = true;

        foreach(player in level.players)
            player thread PlayerShootToRevive();
    }
    else
    {
        level.ShootToRevive = false;
        level notify("EndShootToRevive");
    }
}

PlayerShootToRevive()
{
    self endon("disconnect");
    level endon("EndShootToRevive");

    while(Is_True(level.ShootToRevive))
    {
        self waittill("weapon_fired");

        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), true, self);

        traceEntity = trace["entity"];
        tracePosition = trace["position"];
        
        /*
            For less of a hassle for the player, I'm running two traces.
            The first one is the case where you didn't shoot directly at the downed player, but you got within 50m of them.
            The second one is the case that you shot them directly
        */

        if(!isDefined(traceEntity) || !IsPlayer(traceEntity))
        {
            foreach(player in level.players)
            {
                if(player == self || !Is_Alive(player) || !player IsDown() || Distance(tracePosition, player.origin) > 50)
                    continue;
                
                self thread PlayerShootRevive(player);
            }
        }
        else
        {
            if(!Is_Alive(traceEntity) || !traceEntity IsDown())
                continue;
            
            self thread PlayerShootRevive(traceEntity);
        }
    }
}

PlayerShootRevive(player)
{
    if(!isDefined(player) || !IsPlayer(player))
        return;
    
    if(isDefined(self.hud_damagefeedback))
        self zombie_utility::show_hit_marker();

    self PlayerRevive(player);
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
    if(Is_True(level.no_powerups) && !Is_True(level.IncreasedDropRate))
        level DisablePowerups();

    if(!Is_True(level.IncreasedDropRate))
    {
        level.IncreasedDropRate = true;

        while(Is_True(level.IncreasedDropRate))
        {
            if(isDefined(level.powerup_drop_count) && level.powerup_drop_count > 0 || !isDefined(level.powerup_drop_count))
                level.powerup_drop_count = 0;

            if(level.zombie_vars["zombie_drop_item"] != 1)
                level.zombie_vars["zombie_drop_item"] = 1;

            if(level.zombie_vars["zombie_powerup_drop_max_per_round"] != 999)
                level.zombie_vars["zombie_powerup_drop_max_per_round"] = 999;
            
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(isDefined(zombies[a]) && (!isDefined(zombies[a].no_powerup) || zombies[a].no_powerup))
                    zombies[a].no_powerups = false;
            }

            wait 0.01;
        }
    }
    else
    {
        level.IncreasedDropRate = false;
        level.zombie_vars["zombie_powerup_drop_max_per_round"] = 4;
    }
}

PowerupsNeverLeave()
{
    if(!Is_True(level.PowerupsNeverLeave))
    {
        level.PowerupsNeverLeave = true;
        level._powerup_timeout_override = PowerUpTime();
    }
    else
    {
        level.PowerupsNeverLeave = false;
        level._powerup_timeout_override = undefined;
    }
}

PowerUpTime()
{
    return 0;
}

DisablePowerups()
{
    if(Is_True(level.IncreasedDropRate) && !Is_True(level.DisablePowerups))
        level IncreasedDropRate();

    if(!Is_True(level.DisablePowerups))
    {
        level.DisablePowerups = true;

        foreach(powerup in level.active_powerups)
        {
            powerup notify("powerup_timedout");
            powerup zm_powerups::powerup_delete();

            wait 0.01;
        }
        
        while(Is_True(level.DisablePowerups))
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
    {
        level.powerup_drop_count = 0;
        level.DisablePowerups = false;
    }
}

headshots_only()
{
    level.headshots_only = !Is_True(level.headshots_only);
}

ServerSetClipSizeMultiplier(multiplier)
{
    SetDvar("player_clipSizeMultiplier", multiplier);
}

ServerSetReviveRadius(radius)
{
    SetDvar("revive_trigger_radius", radius);
}

ServerSetLastandTime(time)
{
    SetDvar("player_lastStandBleedoutTime", time);
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
    if(isInArray(level.mapNames, level.script))
        Map(level.script);
    else
        MissionFailed();
}