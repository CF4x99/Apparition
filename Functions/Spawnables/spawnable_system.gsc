PopulateSpawnables(menu)
{
    switch(menu)
    {
        case "Spawnables":
            if(!IsDefined(level.spawnable))
                level.spawnable = [];

            self addMenu(menu);
                self addOpt("Rain Options", ::newMenu, "Rain Options");
                self addOpt("Small Spawnables", ::newMenu, "Small Spawnables");
                self addOpt("Large Spawnables", ::newMenu, "Large Spawnables");
            break;
        
        case "Rain Options":
            self addMenu(menu);
                self addOpt("Disable", ::DisableLobbyRain);
                self addOpt("Models", ::newMenu, "Rain Models");
                self addOpt("Effects", ::newMenu, "Rain Effects");
                self addOpt("Projectiles", ::newMenu, "Rain Projectiles");

                if(IsDefined(level.zombie_include_powerups) && level.zombie_include_powerups.size)
                    self addOptBool(level.RainPowerups, "Rain Power-Ups", ::RainPowerups);
            break;
        
        case "Rain Models":
            self addMenu("Models");

                if(IsDefined(level.menu_models) && level.menu_models.size)
                {
                    for(a = 0; a < level.menu_models.size; a++)
                    {
                        isCurrent = IsDefined(level.LobbyRainType) && level.LobbyRainType == "Model" && IsDefined(level.LobbyRain) && level.LobbyRain == level.menu_models[a];
                        self addOptBool(isCurrent, CleanString(level.menu_models[a]), ::LobbyRain, "Model", level.menu_models[a]);
                    }
                }
            break;
        
        case "Rain Effects":
            self addMenu("Effects");

                for(a = 0; a < level.menuFX.size; a++)
                {
                    isCurrent = IsDefined(level.LobbyRainType) && level.LobbyRainType == "FX" && IsDefined(level.LobbyRain) && level.LobbyRain == level.menuFX[a];
                    self addOptBool(isCurrent, CleanString(level.menuFX[a]), ::LobbyRain, "FX", level.menuFX[a]);
                }
            break;
        
        case "Rain Projectiles":
            self addMenu("Projectiles");

                if(!IsVerkoMap())
                {
                    arr = [];
                    weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");
                    weaps = GetArrayKeys(level.zombie_weapons);

                    if(IsDefined(weaps) && weaps.size)
                    {
                        for(a = 0; a < weaps.size; a++)
                        {
                            if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                            {
                                strn = (MakeLocalizedString(weaps[a].displayname) != "") ? weaps[a].displayname : weaps[a].name;
                                
                                if(!IsInArray(arr, strn))
                                {
                                    arr[arr.size] = strn;
                                    isCurrent = IsDefined(level.LobbyRainType) && level.LobbyRainType == "Projectile" && IsDefined(level.LobbyRain) && level.LobbyRain == weaps[a];

                                    self addOptBool(isCurrent, strn, ::LobbyRain, "Projectile", weaps[a]);
                                }
                            }
                        }
                    }
                }
                else
                {
                    for(a = 0; a < level.var_21b77150.size; a++)
                        self addOpt(level.var_7df703ba[a], ::LobbyRain, "Projectile", GetWeapon(level.var_21b77150[a]));
                }
            break;
        
        case "Small Spawnables":
            self addMenu(menu);
                self addOptBool(level.TornadoSpawned, "Tornado", ::Tornado);
                self addOptIncSlider("Mexican Wave", ::MexicanWave, 2, 2, 15, 1);
                self addOptIncSlider("Spiral Staircase", ::SpiralStaircase, 5, 5, 50, 1);
                self addOptSlider("Teleporter", ::SpawnTeleporter, Array("Spawn", "Delete All"));
            break;
        
        case "Large Spawnables":
            self addMenu(menu);
                self addOpt("Skybase", ::newMenu, "Skybase");
                self addOptSlider("Drop Tower", ::SpawnSystem, Array("Spawn", "Dismantle", "Delete"), "Drop Tower", ::SpawnDropTower);
                self addOptSlider("Merry Go Round", ::SpawnSystem, Array("Spawn", "Dismantle", "Delete"), "Merry Go Round", ::SpawnMerryGoRound);

                if(IsDefined(level.spawnable["Merry Go Round_Spawned"]))
                    self addOptIncSlider("Merry Go Round Speed", ::SetMerryGoRoundSpeed, 1, 1, 10, 1);
            break;
        
        case "Skybase":
            self addMenu(menu);

                /*
                This was used for getting the pre-set locations for the skybase
                I left it here and commented it out in case anyone wants to make changes to the locations
                The origin doesn't auto-update in the menu, so you will need to exit the skybase submenu and reenter it to see the new origin if/when changed
                
                origin = IsDefined(level.SkybaseOrigin) ? level.SkybaseOrigin : (0, 0, 0);
                self addOpt("Origin: " + origin);
                */

                baseOrigin = GetSkybaseOriginForMap();
                
                if(!IsDefined(level.SkybaseLocation))
                    level.SkybaseLocation = IsVec(baseOrigin) ? "Pre-Set" : "Custom";

                self addOptSlider("Skybase", ::SpawnSystem, Array("Spawn", "Dismantle", "Delete"), "Skybase", ::SpawnSkybase);
                self addOptSlider("Location", ::SkybaseLocation, IsVec(baseOrigin) ? Array("Pre-Set", "Custom") : Array("Custom"));
                self addOptBool((IsDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size), "Spawn Skybase Teleporter", ::SpawnSkybaseTeleporter);
                
                self addOpt("");
                self addOptIncSlider("Move X", ::MoveSkybase, -25, 0, 25, 1, "X");
                self addOptIncSlider("Move Y", ::MoveSkybase, -25, 0, 25, 1, "Y");
                self addOptIncSlider("Move Z", ::MoveSkybase, -25, 0, 25, 1, "Z");
            break;
    }
}

SpawnSystem(action, type, func)
{
    checkModel = GetSpawnableBaseModel();

    if(!IsDefined(checkModel))
        return self iPrintlnBold("^1ERROR: ^7Couldn't Find A Valid Base Model For Spawnables");

    if(!IsDefined(level.spawnable))
        level.spawnable = [];

    if(Is_True(level.spawnable[type + "_Building"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Built");

    if(Is_True(level.spawnable[type + "_Dismantle"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Dismantled");

    if(Is_True(level.spawnable[type + "_Deleted"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Deleted");

    if(!Is_True(level.spawnable[type + "_Spawned"]) && type != "Skybase")
    {
        traceSurface = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["surfacetype"];

        if(traceSurface == "none" || traceSurface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
    }

    if(action != "Spawn")
    {
        if(!Is_True(level.spawnable[type + "_Spawned"]))
            return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Hasn't Been Spawned Yet");
    }
    else
    {
        if(IsDefined(level.spawnable["LargeSpawnable"]) && isLargeSpawnable(type))
            return self iPrintlnBold("^1ERROR: ^7You Must Delete The " + level.spawnable["LargeSpawnable"] + " First");

        if(Is_True(level.spawnable[type + "_Spawned"]))
            return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Has Already Been Spawned");
    }

    if(IsDefined(level.SpawnableSystemBusy))
        return self iPrintlnBold("^1ERROR: ^7The Spawnable System Is Currently Busy");

    level.SpawnableSystemBusy = type;

    menu = self getCurrent();
    curs = self getCursor();

    if(!IsDefined(level.SpawnableArray))
        level.SpawnableArray = [];
    
    if(!IsDefined(level.SpawnableArray[type]))
        level.SpawnableArray[type] = [];

    switch(action)
    {
        case "Spawn":
            if(isLargeSpawnable(type))
                level.spawnable["LargeSpawnable"] = type;

            level.spawnable[type + "_Building"] = true;

            if(IsDefined(func) && IsFunctionPtr(func))
                built = self [[ func ]]();
            
            if(Is_True(level.spawnable[type + "_Building"]))
                level.spawnable[type + "_Building"] = BoolVar(level.spawnable[type + "_Building"]);
            
            if(!IsDefined(func) || !IsFunctionPtr(func) || !Is_True(built))
            {
                DeleteSpawnable(type, "Delete");
                self iPrintlnBold("^1ERROR: ^7Failed To Spawn " + type);
            }
            else
            {
                level.spawnable[type + "_Spawned"] = true;
            }

            break;

        case "Delete":
            DeleteSpawnable(type, action);
            break;

        case "Dismantle":
            if(IsDefined(level.SpawnableArray[type]) && level.SpawnableArray[type].size)
            { 
                for(a = 0; a < level.SpawnableArray[type].size; a++)
                {
                    if(!IsDefined(level.SpawnableArray[type][a]))
                        continue;

                    if(Is_True(level.SpawnableArray[type][a].propActivated))
                        level.SpawnableArray[type][a].propActivated = false;
                    
                    level.SpawnableArray[type][a] NotSolid();
                    level.SpawnableArray[type][a] Unlink();
                    level.SpawnableArray[type][a] Launch(VectorScale(AnglesToForward(level.SpawnableArray[type][a].angles), RandomIntRange(-255, 255)));
                }
            }

            if(type == "Skybase")
            {
                if(IsDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size)
                {
                    for(a = 0; a < level.SkybaseTeleporters.size; a++)
                    {
                        if(!IsDefined(level.SkybaseTeleporters[a]))
                            continue;

                        level.SkybaseTeleporters[a] Unlink();
                        level.SkybaseTeleporters[a] Launch(VectorScale(AnglesToForward(level.SkybaseTeleporters[a].angles), RandomIntRange(-255, 255)));
                    }
                }
            }

            DeleteSpawnable(type, action);
            break;

        default:
            break;
    }

    level.SpawnableSystemBusy = undefined;
    RefreshMenu(menu, curs);
}

DeleteSpawnable(spawn, type)
{
    level notify(spawn + "_Stop");

    if(!IsDefined(level.spawnable))
        level.spawnable = [];

    if(!IsDefined(level.SpawnableArray))
        level.SpawnableArray = [];
    
    if(!IsDefined(level.SpawnableArray[type]))
        level.SpawnableArray[type] = [];

    if(isLargeSpawnable(spawn))
    {
        foreach(player in level.players)
        {
            if(Is_True(player.OnSpawnable))
                player StopRidingSpawnable(spawn);
        }
    }

    level.spawnable[spawn + "_" + type] = true;

    if(type == "Dismantle")
        wait 5;

    if(IsDefined(level.SpawnableArray) && IsDefined(level.SpawnableArray[spawn]) && level.SpawnableArray[spawn].size)
    {
        for(a = 0; a < level.SpawnableArray[spawn].size; a++)
        {
            if(IsDefined(level.SpawnableArray[spawn][a]))
                level.SpawnableArray[spawn][a] Delete();
        }
    }

    if(spawn == "Skybase")
    {
        if(IsDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size)
        {
            for(a = 0; a < level.SkybaseTeleporters.size; a++)
            {
                if(!IsDefined(level.SkybaseTeleporters[a]))
                    continue;

                level.SkybaseTeleporters[a] Delete();
            }

            level.SkybaseTeleporters = undefined;
        }
    }

    //after delete
    level.SpawnableArray[spawn] = undefined;

    if(Is_True(level.spawnable[spawn + "_" + type]))
        level.spawnable[spawn + "_" + type] = BoolVar(level.spawnable[spawn + "_" + type]);

    if(Is_True(level.spawnable[spawn + "_Spawned"]))
        level.spawnable[spawn + "_Spawned"] = BoolVar(level.spawnable[spawn + "_Spawned"]);

    if(isLargeSpawnable(spawn))
        level.spawnable["LargeSpawnable"] = undefined;
}

isLargeSpawnable(type)
{
    spawns = Array("Skybase", "Merry Go Round", "Drop Tower");
    return isInArray(spawns, type);
}

SpawnableArray(spawn)
{
    if(!IsDefined(self) || !IsDefined(spawn))
        return;

    if(!IsDefined(level.SpawnableArray))
        level.SpawnableArray = [];

    if(!IsDefined(level.SpawnableArray[spawn]))
        level.SpawnableArray[spawn] = [];

    level.SpawnableArray[spawn][level.SpawnableArray[spawn].size] = self;
}

SeatSystem(type)
{
    if(!IsDefined(type) || !IsDefined(self))
        return;

    level endon(type + "_Stop");

    self MakeUsable();
    self SetCursorHint("HINT_NOICON");
    self SetHintString("Press [{+activate}] To Ride The " + type);

    while(IsDefined(self))
    {
        self waittill("trigger", player);

        if(IsDefined(self.Rider) && player == self.Rider)
        {
            player StopRidingSpawnable(type, self);
            wait 1;

            continue;
        }

        if(IsDefined(self.Rider) || Is_True(player.OnSpawnable) || player isPlayerLinked(self))
            continue;

        player.SpawnableSavedOrigin = player.origin;
        player.SpawnableSavedAngles = player.angles;

        switch(type)
        {
            case "Merry Go Round":
                player PlayerLinkTo(self);
                break;

            case "Drop Tower":
                player PlayerLinkToAbsolute(self);
                break;

            default:
                player PlayerLinkTo(self);
                break;
        }

        player.OnSpawnable = true;
        self.Rider = player;

        self SetHintString("Press [{+activate}] To Exit The " + type);
        wait 1;
    }
}

StopRidingSpawnable(type, seat)
{
    self Unlink();
    self SetOrigin(self.SpawnableSavedOrigin);
    self SetPlayerAngles(self.SpawnableSavedAngles);

    if(IsDefined(seat))
    {
        seat.Rider = undefined;
        seat SetHintString("Press [{+activate}] To Ride The " + type);
    }

    if(Is_True(self.OnSpawnable))
        self.OnSpawnable = BoolVar(self.OnSpawnable);
}

GetSpawnableBaseModel(favor)
{
    //This will be a fallback for maps that don't have the favored models for spawnables
    for(a = 0; a < level.menu_models.size; a++)
    {
        if(IsDefined(level.menu_models[a]) && IsSubStr(level.menu_models[a], "vending_") && !IsSubStr(level.menu_models[a], "upgrade") && !IsSubStr(level.menu_models[a], "packapunch"))
            model = level.menu_models[a];
    }
    
    for(a = 0; a < level.menu_models.size; a++)
    {
        if(IsSubStr(level.menu_models[a], "vending_doubletap") || IsSubStr(level.menu_models[a], "vending_sleight") || IsSubStr(level.menu_models[a], "vending_three_gun"))
        {
            model = level.menu_models[a];

            if(IsDefined(favor) && IsDefined(model) && (model == favor || IsSubStr(model, favor)))
                return model;
        }
    }

    if(!IsDefined(model)) //If a model still isn't found after this, then spawnbales won't be available for the map
    {
        for(a = 0; a < level.menu_models.size; a++)
        {
            if(IsDefined(level.menu_models[a]) && IsSubStr(level.menu_models[a], "machine"))
                model = level.menu_models[a];
        }
    }

    return model;
}

GetSpawnablePerkBottle()
{
    for(a = 0; a < level.menu_models.size; a++)
    {
        if(IsDefined(level.menu_models[a]) && IsSubStr(level.menu_models[a], "perk_bottle") && !IsSubStr(level.menu_models[a], "broken"))
            return level.menu_models[a];
    }

    //If there is no perk bottle found on the map, then we will just use the insta-kill model..if that isn't found, it will fallback to defaultactor
    return (IsDefined(level.zombie_powerups) && IsDefined(level.zombie_powerups["insta_kill"])) ? level.zombie_powerups["insta_kill"].model_name : "defaultactor";
}





//Rain Options
DisableLobbyRain(includePowerups = true)
{
    level notify("EndLobbyRain");

    if(Is_True(includePowerups))
        level.RainPowerups = undefined;
    
    level.LobbyRain = undefined;
    level.LobbyRainType = undefined;
}

LobbyRain(type, rain)
{
    if(IsDefined(level.LobbyRain) && IsDefined(level.LobbyRainType) && level.LobbyRainType == type && level.LobbyRain == rain)
        return DisableLobbyRain(false);

    level notify("EndLobbyRain");
    level endon("EndLobbyRain");

    level.LobbyRain = rain;
    level.LobbyRainType = type;
    
    while(1)
    {
        player = bot::get_host_player();

        if(!IsDefined(player) || !Is_Alive(player))
        {
            foreach(client in level.players)
            {
                if(!IsDefined(client) || !Is_Alive(client))
                    continue;
                
                player = client;
                break;
            }
        }

        origin = (player.origin + (RandomIntRange(-2500, 2500), RandomIntRange(-2500, 2500), RandomIntRange(750, 3000)));

        switch(type)
        {
            case "Projectile":
                MagicBullet(rain, origin, (origin + (0, 0, -1000)));
                break;
            
            case "Model":
                RainModel = SpawnScriptModel(origin, rain);

                if(!IsDefined(RainModel))
                    break;
                
                RainModel NotSolid();
                RainModel Launch(VectorScale(AnglesToForward(RainModel.angles), 10));
                RainModel thread deleteAfter(10);
                break;
            
            case "FX":
                linker = SpawnScriptModel(origin, "tag_origin");

                if(!IsDefined(linker))
                    break;
                
                linker thread RainPlayFXOnTag(level._effect[rain], "tag_origin");
                linker Launch(VectorScale(AnglesToForward(linker.angles), 10));
                linker thread deleteAfter(10);
                break;
            
            default:
                break;
        }
        
        wait (type == "Model") ? 0.1 : 0.05;
    }
}

RainPlayFXOnTag(FX, tag)
{
    while(IsDefined(self))
    {
        PlayFXOnTag(FX, self, tag);
        wait 0.5;
    }
}

RainPowerups()
{
    level.RainPowerups = BoolVar(level.RainPowerups);

    while(Is_True(level.RainPowerups))
    {
        player = bot::get_host_player();

        if(!IsDefined(player) || !Is_Alive(player))
        {
            foreach(client in level.players)
            {
                if(!IsDefined(client) || !Is_Alive(client))
                    continue;
                
                player = client;
                break;
            }
        }

        powerup = level CustomPowerupSpawn(GetArrayKeys(level.zombie_include_powerups)[RandomInt(level.zombie_include_powerups.size)], player.origin + (RandomIntRange(-1000, 1000), RandomIntRange(-1000, 1000), RandomIntRange(750, 2000)));
        
        if(IsDefined(powerup))
            powerup PhysicsLaunch(powerup.origin, (RandomIntRange(-5, 5), RandomIntRange(-5, 5), RandomIntRange(-5, 5)));

        wait 0.05;
    }
}

CustomPowerupSpawn(powerup_name, drop_spot)
{
    powerup = zm_net::network_safe_spawn("powerup", 1, "script_model", (drop_spot + VectorScale((0, 0, 1), 40)));

    if(IsDefined(powerup))
    {
        powerup zm_powerups::powerup_setup(powerup_name);

        if(!IsDefined(powerup))
            return;

        if(isInArray(level.active_powerups, powerup))
            level.active_powerups = ArrayRemove(level.active_powerups, powerup);

        powerup thread custom_powerup_timeout();
        powerup thread zm_powerups::powerup_grab();
        powerup thread zm_powerups::powerup_wobble_fx();

        return powerup;
    }
}

custom_powerup_timeout()
{
    wait 15;

    if(!IsDefined(self))
        return;
    
    self notify("powerup_timedout");
    self zm_powerups::powerup_delete();
}








//Small Spawnables
Tornado()
{
    if(!Is_True(level.TornadoSpawned))
    {
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
        
        origin = trace["position"];
        surface = trace["surfacetype"];

        if(IsDefined(surface) && (surface == "none" || surface == "default"))
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
    }
    else
    {
        if(!IsDefined(level.SpawnableArray["Tornado"]) || !level.SpawnableArray["Tornado"].size)
            return;
        
        for(a = 0; a < level.SpawnableArray["Tornado"].size; a++)
        {
            if(IsDefined(level.SpawnableArray["Tornado"][a]))
                level.SpawnableArray["Tornado"][a] Delete();
        }
        
        level notify("Tornado_Stop");
        level.TornadoSpawned = BoolVar(level.TornadoSpawned);
        return;
    }

    level endon("Tornado_Stop");
    level.TornadoSpawned = true;
    
    TornadoParts = [];
    level.tornadoTime = 0;
    
    TornadoParts[0] = SpawnScriptModel(origin, "tag_origin");
    TornadoParts[0] SpawnableArray("Tornado");
    color = Int(Pow(2, RandomInt(3)));

    for(a = 1; a < 15; a++)
    {
        for(b = 0; b < (a + 2); b++)
        {
            TornadoParts[TornadoParts.size] = SpawnScriptModel(TornadoParts[0].origin + (Cos((b * 360) / (a + 2)) * (a * 6), Sin((b * 360) / (a + 2)) * (a * 6), (a * 18)), "tag_origin");
            
            TornadoParts[(TornadoParts.size - 1)] LinkTo(TornadoParts[0]);
            TornadoParts[(TornadoParts.size - 1)] SpawnableArray("Tornado");
            TornadoParts[(TornadoParts.size - 1)] clientfield::set("powerup_fx", color);
            wait 0.01;
        }
    }

    TornadoParts[0] thread TornadoMovement(TornadoParts[0].origin);
    level thread TornadoWatchEntities(TornadoParts);
}

TornadoMovement(defaultOrigin)
{
    level endon("Tornado_Stop");
    self endon("EndTornadoMovement");
    
    while(IsDefined(self))
    {
        self zm_utility::create_zombie_point_of_interest(5000, 255, 10000, 1);
        self MoveTo(self.origin + (RandomIntRange(-100, 100), RandomIntRange(-100, 100), 0), 3);
        self RotateYaw(360, 3);
        wait 3;
    
        if(!IsDefined(self))
            break;

        if(Distance(defaultOrigin, self.origin) >= 750)
        {
            self MoveTo(defaultOrigin, 3);
            self RotateYaw(360, 3);

            wait 3;
        }
    }
}

TornadoWatchEntities(TornadoParts)
{
    level endon("Tornado_Stop");

    wait 3;

    while(1)
    {
        if(!IsDefined(TornadoParts) || !TornadoParts.size)
            break;
        
        foreach(entity in GetEntArray("script_model", "classname"))
        {
            if(!IsDefined(entity) || isInArray(TornadoParts, entity) || Is_True(entity.OnTornado) || entity.model == "tag_origin")
                continue;
            
            for(a = 1; a < TornadoParts.size; a++)
            {
                if(IsDefined(TornadoParts[a]) && Distance(TornadoParts[a].origin, entity.origin) <= 100)
                {
                    entity thread TornadoLaunchEntity(a, TornadoParts);
                    break;
                }
            }
        }

        foreach(player in level.players)
        {
            if(!IsDefined(player) || !Is_Alive(player) || player isPlayerLinked() || Is_True(player.OnTornado))
                continue;
            
            for(a = 1; a < TornadoParts.size; a++)
            {
                if(IsDefined(TornadoParts[a]) && Distance(TornadoParts[a].origin, player.origin) <= 100)
                {
                    player thread TornadoLaunchPlayer(a, TornadoParts);
                    break;
                }
            }
        }
        
        foreach(zombie in GetAITeamArray(level.zombie_team))
        {
            if(!IsDefined(zombie) || !IsAlive(zombie) || Is_True(zombie.OnTornado))
                continue;
            
            for(a = 1; a < TornadoParts.size; a++)
            {
                if(IsDefined(TornadoParts[a]) && Distance(TornadoParts[a].origin, zombie.origin) <= 100)
                {
                    zombie thread TornadoLaunchZombie(a, TornadoParts);
                    break;
                }
            }
        }

        wait 0.01;
    }
}

TornadoLaunchPlayer(a, TornadoParts)
{
    if(!IsDefined(self) || !Is_Alive(self))
        return;
    
    level endon("Tornado_Stop");
    self endon("disconnect");

    self.OnTornado = true;

    for(b = a; b < TornadoParts.size; b++)
    {
        if(!IsDefined(self) || !Is_Alive(self))
            break;
        
        if(IsDefined(TornadoParts[b]) && b % 2)
        {
            self PlayerLinkTo(TornadoParts[b], "tag_origin");
            wait 0.025;
        }
    }

    if(!IsDefined(self) || !Is_Alive(self))
        return;

    self Unlink();

    if(self IsOnGround())
        self SetOrigin(self.origin + (0, 0, 5));

    self SetVelocity(AnglesToForward(self GetPlayerAngles()) * 3500);
    wait 1;

    if(!IsDefined(self) || !Is_Alive(self))
        return;

    if(Is_True(self.OnTornado))
        self.OnTornado = BoolVar(self.OnTornado);
}

TornadoLaunchZombie(a, TornadoParts)
{
    if(!IsDefined(self) || !IsAlive(self))
        return;
    
    level endon("Tornado_Stop");

    self.OnTornado = true;

    for(b = a; b < TornadoParts.size; b++)
    {
        if(!IsDefined(self) || !IsAlive(self))
            break;
        
        if(IsDefined(TornadoParts[b]) && b % 2)
        {
            self ForceTeleport(TornadoParts[b].origin);
            self LinkTo(TornadoParts[b]);

            wait 0.025;
        }
    }
    
    if(!IsDefined(self) || !IsAlive(self))
        return;

    linker = SpawnScriptModel(self.origin, "tag_origin");
    self LinkTo(linker, "tag_origin");
    linker Launch(AnglesToForward(self.angles) * 3500);
    wait 1;

    if(!IsDefined(self) || !IsAlive(self))
        return;

    if(IsDefined(linker))
        linker Delete();
    
    if(Is_True(self.OnTornado))
        self.OnTornado = BoolVar(self.OnTornado);
}

TornadoLaunchEntity(a, TornadoParts)
{
    if(!IsDefined(self))
        return;
    
    self.OnTornado = true;

    for(b = a; b < TornadoParts.size; b++)
    {
        if(!IsDefined(self))
            break;
        
        if(b % 2 && IsDefined(TornadoParts[b]))
        {
            self.origin = TornadoParts[b].origin;
            self LinkTo(TornadoParts[b]);

            wait 0.025;
        }
    }

    if(!IsDefined(self))
        return;

    self Unlink();
    self Launch(AnglesToForward(self.angles) * 5500);
    wait 1;

    if(!IsDefined(self))
        return;

    if(Is_True(self.OnTornado))
        self.OnTornado = BoolVar(self.OnTornado);
}

MexicanWave(size)
{
    if(IsDefined(self.MexicanWave) && self.MexicanWave.size)
    {
        for(a = 0; a < self.MexicanWave.size; a++)
        {
            if(IsDefined(self.MexicanWave[a]))
                self.MexicanWave[a] Delete();
        }
        
        self.MexicanWave = undefined;
        return;
    }
    
    self.MexicanWave = [];

    for(a = 0; a < size; a++)
    {
        self.MexicanWave[self.MexicanWave.size] = SpawnScriptModel(self.origin + AnglesToRight(self GetPlayerAngles()) * (a * 45), "defaultactor", self GetPlayerAngles());
        self.MexicanWave[(self.MexicanWave.size - 1)] thread MexicanWaveMove(a);
    }
}

MexicanWaveMove(index)
{
    wait (index * 0.2);

    while(IsDefined(self))
    {
        self MoveZ(55, 0.75);
        wait 0.74;

        if(IsDefined(self))
            self MoveZ(-55, 0.75);
        
        wait 0.74;
    }
}

SpiralStaircase(size)
{
    if(Is_True(level.SpiralStaircaseSpawning))
        return self iPrintlnBold("^1ERROR: ^7Spiral Staircase Is Being Built");
    
    if(Is_True(level.SpiralStaircaseDeleting))
        return self iPrintlnBold("^1ERROR: ^7Spiral Staircase Is Being Deleted");
    
    if(IsDefined(level.SpiralStaircase) && level.SpiralStaircase.size)
    {
        level.SpiralStaircaseDeleting = true;

        for(a = 0; a < level.SpiralStaircase.size; a++)
        {
            if(IsDefined(level.SpiralStaircase[a]))
            {
                level.SpiralStaircase[a] Launch(VectorScale(AnglesToForward(level.SpiralStaircase[a].angles), 255));
                level.SpiralStaircase[a] NotSolid();
                level.SpiralStaircase[a] thread deleteAfter(5);

                wait 0.01;
            }
        }
        
        wait 5;
        level.SpiralStaircase = [];

        if(Is_True(level.SpiralStaircaseDeleting))
            level.SpiralStaircaseDeleting = BoolVar(level.SpiralStaircaseDeleting);
    }
    else
    {
        model = GetSpawnableBaseModel();
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);

        if(!isInArray(level.menu_models, model))
            return self iPrintlnBold("^1ERROR: ^7Couldn't Find A Valid Base Model For The Spiral Staircase");
    
        origin = trace["position"];
        surface = trace["surfacetype"];

        if(IsDefined(surface) && (surface == "none" || surface == "default"))
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
        
        level.SpiralStaircaseSpawning = true;

        if(!IsDefined(level.SpiralStaircase))
            level.SpiralStaircase = [];
        
        level.SpiralStaircase[0] = SpawnScriptModel(origin, model, (-28, self GetPlayerAngles()[1], 90));
        
        for(a = 1; a < size; a++)
        {
            if(!IsDefined(level.SpiralStaircase[(level.SpiralStaircase.size - 1)]))
                continue;
            
            level.SpiralStaircase[level.SpiralStaircase.size] = SpawnScriptModel((level.SpiralStaircase[(level.SpiralStaircase.size - 1)].origin + (AnglesToForward(level.SpiralStaircase[(level.SpiralStaircase.size - 1)].angles) * 10) + (0, 0, 8)), model, (level.SpiralStaircase[0].angles[0], (level.SpiralStaircase[(level.SpiralStaircase.size - 1)].angles[1] + 12), level.SpiralStaircase[0].angles[2]), 0.01);
        }

        if(Is_True(level.SpiralStaircaseSpawning))
            level.SpiralStaircaseSpawning = BoolVar(level.SpiralStaircaseSpawning);
    }
}

SpawnTeleporter(action = "Spawn", origin, skipLink = false, skipDelete = false)
{
    if(IsDefined(action) && action == "Delete All")
    {
        DeleteTeleporters();
        return;
    }

    if(!IsDefined(origin))
    {
        traceSurface = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["surfacetype"];

        if(traceSurface == "none" || traceSurface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
        
        origin = self TraceBullet() + (0, 0, 45);
    }

    linker = SpawnScriptModel(origin, "tag_origin");
    linker thread AddActiveTeleporter(skipLink, skipDelete);

    return linker;
}

DeleteTeleporters()
{
    if(!IsDefined(level.ActiveTeleporters) || !level.ActiveTeleporters.size)
        return;
    
    foreach(teleporter in level.ActiveTeleporters)
    {
        if(IsDefined(teleporter) && !Is_True(teleporter.skipDelete))
            teleporter Delete();
    }
}

AddActiveTeleporter(skipLink = false, skipDelete = false)
{
    if(!IsDefined(level.ActiveTeleporters))
        level.ActiveTeleporters = [];
    
    if(isInArray(level.ActiveTeleporters, self))
        return;
    
    if(level.ActiveTeleporters.size && !skipLink)
    {
        if(IsDefined(level.ActiveTeleporters[(level.ActiveTeleporters.size - 1)]) && !IsDefined(level.ActiveTeleporters[(level.ActiveTeleporters.size - 1)].LinkedTeleporter))
        {
            self.LinkedTeleporter = level.ActiveTeleporters[(level.ActiveTeleporters.size - 1)];
            level.ActiveTeleporters[(level.ActiveTeleporters.size - 1)].LinkedTeleporter = self;
        }
    }

    self.skipDelete = skipDelete;
    level.ActiveTeleporters[level.ActiveTeleporters.size] = self;

    self MakeUsable();
    self SetCursorHint("HINT_NOICON");
    self SetHintString("Press [{+activate}] To Teleport");
    self thread ActivateTeleporter();

    while(IsDefined(self))
    {
        PlayFXOnTag(level._effect["teleport_aoe_kill"], self, "tag_origin");
        wait 0.25;
    }
}

ActivateTeleporter()
{
    if(IsDefined(self.TeleporterActivated))
        return;
    self.TeleporterActivated = true;

    while(IsDefined(self))
    {
        self waittill("trigger", player);
        
        if(Is_True(player.UsingTeleporter) || !IsDefined(self))
            continue;
        
        if(!IsDefined(self.LinkedTeleporter))
        {
            player iPrintlnBold("^1ERROR: ^7No Linked Teleporter Found");
            continue;
        }
        
        player thread UseTeleporter(self);
    }
}

UseTeleporter(teleporter)
{
    if(!IsDefined(teleporter) || Is_True(self.UsingTeleporter) || !IsDefined(teleporter.LinkedTeleporter))
        return;
    
    self.UsingTeleporter = true;
    PlayFX(level._effect["teleport_splash"], teleporter.origin);
    wait 0.05;

    self SetOrigin(teleporter.LinkedTeleporter.origin);
    PlayFX(level._effect["teleport_splash"], teleporter.LinkedTeleporter.origin);
    wait 1.5;

    if(Is_True(self.UsingTeleporter))
        self.UsingTeleporter = BoolVar(self.UsingTeleporter);
}