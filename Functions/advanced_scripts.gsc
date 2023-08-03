AC130(type)
{
    if(isDefined(self.AC130))
        return;
    self.AC130 = true;

    self endon("disconnect");

    self.menu["DisableMenuControls"] = true;
    self closeMenu1();
    
    if(type == "Fly")
    {
        self.ACSavedOrigin = self.origin;
        self.ACSavedAngles = self GetPlayerAngles();
        SetAngles = VectorToAngles(self.ACSavedOrigin - self GetEye());
        
        linker = SpawnScriptModel(self.ACSavedOrigin, "tag_origin", (0, SetAngles[1], 0));
        c130 = SpawnScriptModel(((linker.origin + (AnglesToRight(linker.angles) * 1800)) + (0, 0, ((self.StartOrigin[2] + 1500) - linker.origin[2]))), "tag_origin");
        c130.angles = VectorToAngles(linker.origin - c130.origin);

        c130 LinkTo(linker);
        linker thread AC130Rotate();

        self SetOrigin(c130.origin);
        self PlayerLinkToDelta(c130, "tag_origin", 0, 50, 50, 15, 15);
        self Hide();
    }

    ammoType = GetWeapon("minigun");
    ammoTime = 0.01;

    self RefreshAC130HUD(ammoType);

    self EnableInvulnerability();
    self DisableWeapons(true);
    self DisableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 0);
    self.menu["DisableMenuControls"] = true;
    
    while(1)
    {
        if(self AttackButtonPressed())
        {
            if(!isDefined(self.AC130DisableFire[ammoType]))
                self thread FireAC130(ammoType);
        }
        else if(self FragButtonPressed())
        {
            ammoType = AC130NextWeapon(ammoType);
            self RefreshAC130HUD(ammoType);
            
            wait 0.15;
        }

        if(self MeleeButtonPressed())
            break;

        wait 0.01;
    }
    
    if(isDefined(self.AC130HUD))
        destroyAll(self.AC130HUD);
    
    if(isDefined(self.AC130HUDLUI))
    {
        self CloseLUIMenu(self.AC130HUDLUI);
        self.AC130HUDLUI = undefined;
    }

    if(!isDefined(self.godmode))
        self DisableInvulnerability();
    
    self EnableWeapons();
    self EnableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 1);

    if(type == "Fly")
    {
        linker delete();
        c130 delete();

        self SetOrigin(self.ACSavedOrigin);
        self SetPlayerAngles(self.ACSavedAngles);

        if(!isDefined(self.Invisibility))
            self Show();
    }

    self.menu["DisableMenuControls"] = undefined;
    self.AC130 = undefined;
}

AC130NextWeapon(current)
{
    switch(current)
    {
        case GetWeapon("minigun"):
            return zm_weapons::get_upgrade_weapon(level.start_weapon);
        
        case zm_weapons::get_upgrade_weapon(level.start_weapon):
            return GetWeapon("hunter_rocket_turret_player");
        
        case GetWeapon("hunter_rocket_turret_player"):
            return GetWeapon("minigun");
        
        default:
            return GetWeapon("minigun");
    }
}

AC130FireRate(ammo)
{
    switch(ammo)
    {
        case GetWeapon("minigun"):
            return 0.01;
        
        case zm_weapons::get_upgrade_weapon(level.start_weapon):
            return 0.5;
        
        case GetWeapon("hunter_rocket_turret_player"):
            return 2;
        
        default:
            return 0.01;
    }
}

FireAC130(ammoType)
{
    self endon("disconnect");

    if(!isDefined(self.AC130DisableFire))
        self.AC130DisableFire = [];
    
    self.AC130DisableFire[ammoType] = true;

    fire_origin = self GetTagOrigin("j_neck") + (AnglesToForward(self GetPlayerAngles()) * 5) + (AnglesToRight(self GetPlayerAngles()) * -5);

    if(ammoType == GetWeapon("hunter_rocket_turret_player"))
        for(a = 0; a < 6; a++)
            MagicBullet(ammoType, fire_origin, BulletTrace(fire_origin, fire_origin + self GetWeaponForwardDir() * 100, 0, undefined)["position"] + (Cos(a * 60) * 3, Sin(a * 60) * 3, 0), self);
    else
        MagicBullet(ammoType, fire_origin, self TraceBullet(), self);
    
    wait AC130FireRate(ammoType);

    self.AC130DisableFire[ammoType] = undefined;
}

AC130Rotate()
{
    self endon("disconnect");
    
    while(isDefined(self))
    {
        self RotateYaw(360, 50);
        
        wait 49.9;
    }
}

RefreshAC130HUD(ammo)
{
    if(isDefined(self.AC130HUD))
        destroyAll(self.AC130HUD);
    
    if(isDefined(self.AC130HUDLUI))
        self CloseLUIMenu(self.AC130HUDLUI);

    self.AC130HUD = [];
    self.AC130HUDLUI = self LUI_createText("", 0, 20, 375, 1023, (1, 1, 1));

    switch(ammo)
    {
        case GetWeapon("minigun"):
            text = "25mm";
            AC130HudValues = ["0,50,2,80", "40,0,60,2", "-40,0,60,2", "-180,151,2,50", "-155,175,50,2", "180,151,2,50", "155,175,50,2", "180,-151,2,50", "155,-175,50,2", "-180,-151,2,50", "-155,-175,50,2"];
            break;
        
        case zm_weapons::get_upgrade_weapon(level.start_weapon):
            text = "40mm";
            AC130HudValues = ["0,80,2,120", "0,-80,2,120", "0,-46,10,1", "0,-92,10,1", "0,-140,14,1", "0,46,10,1", "0,92,10,1", "0,140,14,1", "85,0,130,2", "-85,0,130,2", "37,0,1,10", "75,0,1,10", "112,0,1,10", "150,0,1,14", "-37,0,1,10", "-75,0,1,10", "-112,0,1,10", "-150,0,1,14"];
            break;
        
        case GetWeapon("hunter_rocket_turret_player"):
            text = "105mm";
            AC130HudValues = ["0,25,51,2", "0,-25,51,2", "25,0,2,51", "-25,0,2,52", "0,50,2,51", "0,-50,2,51", "50,0,51,2", "-50,0,51,2", "225,161,2,30", "210,175,30,2", "-225,161,2,30", "-210,175,30,2", "-225,-161,2,30", "-210,-175,30,2", "225,-161,2,30", "210,-175,30,2"];
            break;
        
        default:
            text = "25mm";
            AC130HudValues = ["0,50,2,80", "40,0,60,2", "-40,0,60,2", "-180,151,2,50", "-155,175,50,2", "180,151,2,50", "155,175,50,2", "180,-151,2,50", "155,-175,50,2", "-180,-151,2,50", "-155,-175,50,2"];
            break;
    }

    self SetLUIMenuData(self.AC130HUDLUI, "text", AddToStringCache(text + "\n^3" + self ReturnButtonName("frag") + " ^7To Change Weapon"));

    for(a = 0; a < AC130HudValues.size; a++)
        self.AC130HUD[self.AC130HUD.size] = self createRectangle("CENTER", "CENTER", Int(StrTok(AC130HudValues[a], ",")[0]), Int(StrTok(AC130HudValues[a], ",")[1]), Int(StrTok(AC130HudValues[a], ",")[2]), Int(StrTok(AC130HudValues[a], ",")[3]), (1, 1, 1), 1, 1, "white");
}

RainPowerups()
{
    level.RainPowerups = isDefined(level.RainPowerups) ? undefined : true;

    while(isDefined(level.RainPowerups))
    {
        powerup = level CustomPowerupSpawn(GetArrayKeys(level.zombie_include_powerups)[RandomInt(level.zombie_include_powerups.size)], bot::get_host_player().origin + (RandomIntRange(-1000, 1000), RandomIntRange(-1000, 1000), RandomIntRange(750, 2000)));
        
        if(isDefined(powerup))
            powerup PhysicsLaunch(powerup.origin, (RandomIntRange(-5, 5), RandomIntRange(-5, 5), RandomIntRange(-5, 5)));

        wait 0.025;
    }
}

CustomPowerupSpawn(powerup_name, drop_spot)
{
	powerup = zm_net::network_safe_spawn("powerup", 1, "script_model", (drop_spot + VectorScale((0, 0, 1), 40)));

	if(isDefined(powerup))
	{
		powerup zm_powerups::powerup_setup(powerup_name);

        if(!isDefined(powerup))
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

    if(!isDefined(self))
        return;
    
    self notify("powerup_timedout");
    self zm_powerups::powerup_delete();
}

LobbyRain(type, rain)
{
    level notify("EndLobbyRain");
    level endon("EndLobbyRain");
    
    while(1)
    {
        origin = (level.players[0].origin + (RandomIntRange(-2500, 2500), RandomIntRange(-2500, 2500), RandomIntRange(750, 3000)));

        switch(type)
        {
            case "Projectile":
                MagicBullet(rain, origin, (origin + (0, 0, -1000)));
                linker delete();
                
                time = 0.05;
                break;
            
            case "Model":
                RainModel = SpawnScriptModel(origin, rain);

                if(!isDefined(RainModel))
                    continue;
                
                RainModel NotSolid();
                RainModel Launch(VectorScale(AnglesToForward(RainModel.angles), 10));
                RainModel thread deleteAfter(10);

                time = 0.1;
                break;
            
            case "FX":
                linker = SpawnScriptModel(origin, "tag_origin");

                if(!isDefined(linker))
                    continue;
                
                linker thread RainPlayFXOnTag(level._effect[rain], "tag_origin");
                linker Launch(VectorScale(AnglesToForward(linker.angles), 10));
                linker thread deleteAfter(10);

                time = 0.05;
                break;
            
            default:
                break;
        }

        if(!isDefined(time))
            time = 0.1;
        
        wait time;
    }
}

RainPlayFXOnTag(FX, tag)
{
    while(isDefined(self))
    {
        PlayFXOnTag(FX, self, tag);

        wait 0.5;
    }
}

DisableLobbyRain()
{
    level notify("EndLobbyRain");
}

CustomSentry(origin)
{
    self endon("disconnect");

    self.CustomSentry = isDefined(self.CustomSentry) ? undefined : true;

    if(isDefined(self.CustomSentry))
    {
        self endon("EndCustomSentry");
        
        if(!isDefined(origin))
            origin = self.origin;

        angles = self.angles;
        self.CustomSentryOrigin = origin;
        
        sentrygun = self.CustomSentryWeapon;
        self.sentrygun_weapon = zm_utility::spawn_weapon_model(sentrygun, undefined, origin, angles[1]);
        self.sentrygun_weapon.owner = self;

        self.sentrygun_weapon thread clientfield::set("zm_aat_fire_works", 1);
        self.sentrygun_weapon MoveTo(origin + (0, 0, 56), 0.5);
        self.sentrygun_weapon waittill("movedone");
        
        while(isDefined(self.CustomSentry))
        {
            zombie = self.sentrygun_weapon CustomSentryGetTarget();

            if(!isDefined(zombie))
            {
                v_curr_yaw = (0, RandomIntRange(0, 360), 0);
                v_target_pos = self.sentrygun_weapon.origin + VectorScale(AnglesToForward(v_curr_yaw), 40);
            }
            else
            {
                v_target_pos = zombie GetTagOrigin("j_head");

                if(!isDefined(v_target_pos)) //Needed for AI that don't have the targeted bone tag(i.e. Spiders)
                    v_target_pos = zombie GetTagOrigin("tag_body");
            }
            
            self.sentrygun_weapon.angles = VectorToAngles(v_target_pos - self.sentrygun_weapon.origin);
            v_flash_pos = self.sentrygun_weapon GetTagOrigin("tag_flash");
            self.sentrygun_weapon DontInterpolate();

            if(isDefined(zombie))
                MagicBullet(sentrygun, v_flash_pos, v_target_pos, self.sentrygun_weapon);

            util::wait_network_frame();
        }
    }
    else
    {
        if(isDefined(self.sentrygun_weapon))
        {
            self notify("EndCustomSentry");
            self.sentrygun_weapon clientfield::set("zm_aat_fire_works", 0);

            wait 0.01;

            self.sentrygun_weapon delete();
        }
    }
}

CustomSentryGetTarget()
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || zombies[a] DamageConeTrace(self.origin, self) < 0.1)
            continue;
        
        if(!isDefined(enemy))
            enemy = zombies[a];
        
        if(isDefined(enemy) && enemy != zombies[a])
            if(Closer(self.origin, zombies[a].origin, enemy.origin) && zombies[a] DamageConeTrace(self.origin, self) >= 0.1)
                enemy = zombies[a];
    }

    return enemy;
}

SetCustomSentryWeapon(weapon)
{
    if(self.CustomSentryWeapon == weapon)
        return;
    
    self.CustomSentryWeapon = weapon;

    if(isDefined(self.CustomSentry))
        for(a = 0; a < 2; a++)
            self CustomSentry(self.CustomSentryOrigin);
}

ArtilleryStrike()
{
    if(isDefined(self.ArtilleryStrike))
        return;
    self.ArtilleryStrike = true;
    
    self endon("disconnect");

    self closeMenu1();
    wait 0.25;
    
    goalPos = SpawnScriptModel(GetGroundPos(self TraceBullet()), "tag_origin");
    PlayFXOnTag(level._effect["powerup_on"], goalPos, "tag_origin");

    self.menu["DisableMenuControls"] = true;

    self SetMenuInstructions(self ReturnButtonName("attack") + " - Confirm Location\n" + self ReturnButtonName("melee") + " - Cancel");
    
    while(1)
    {
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
            
        origin = trace["position"];
        surface = trace["surfacetype"];
        
        goalPos.origin = origin;

        if(self UseButtonPressed() || self AttackButtonPressed())
        {
            if(surface != "none" && surface != "default")
            {
                targetPos = goalPos.origin;

                break;
            }
            else
                self iPrintlnBold("^1ERROR: ^7Invalid Surface");
        }
        
        if(self MeleeButtonPressed())
            break;

        wait 0.01;
    }
    
    goalPos delete();
    self.menu["DisableMenuControls"] = undefined;

    self SetMenuInstructions();
    
    if(isDefined(targetPos))
    {
        targetPos = targetPos + (0, 0, 3500);

        for(a = -1; a < 2; a += 2)
            for(b = 0; b < 5; b++)
            {
                MagicBullet(GetWeapon("launcher_standard"), targetPos, targetPos - (0, b * (a * 25), 2500), self);
                wait 0.25;
            }

        for(a = -1; a < 2; a += 2)
            for(b = 0; b < 5; b++)
            {
                MagicBullet(GetWeapon("launcher_standard"), targetPos, targetPos - (b * (a * 25), 0, 2500), self);
                wait 0.25;
            }
    }
    
    self.ArtilleryStrike = undefined;
}

Tornado()
{
    if(!isDefined(level.TornadoSpawned))
    {
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
        
        origin = trace["position"];
        surface = trace["surfacetype"];

        if(surface == "none" || surface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
    }
    
    level.TornadoSpawned = isDefined(level.TornadoSpawned) ? undefined : true;

    if(!isDefined(level.TornadoSpawned))
    {
        if(!isDefined(level.SpawnableArray["Tornado"]) || !level.SpawnableArray["Tornado"].size)
            return;
        
        for(a = 0; a < level.SpawnableArray["Tornado"].size; a++)
            if(isDefined(level.SpawnableArray["Tornado"][a]))
                level.SpawnableArray["Tornado"][a] delete();
        
        level notify("Tornado_Stop");

        return;
    }

    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
        ents[a] thread TornadoWatchEntities();

    thread TornadoWatchPlayers();
    thread TornadoWatchZombies();
    
    level.TornadoParts = [];
    level.tornadoTime = 0;
    
    level.TornadoParts[0] = SpawnScriptModel(origin, "tag_origin");
    level.TornadoParts[0] SpawnableArray("Tornado");
    color = Int(Pow(2, RandomInt(3)));

    for(a = 1; a < 15; a++)
    {
        for(b = 0; b < (a + 2); b++)
        {
            level.TornadoParts[level.TornadoParts.size] = SpawnScriptModel(level.TornadoParts[0].origin + (Cos((b * 360) / (a + 2)) * (a * 6), Sin((b * 360) / (a + 2)) * (a * 6), (a * 18)), "tag_origin");
            
            level.TornadoParts[(level.TornadoParts.size - 1)] LinkTo(level.TornadoParts[0]);
            level.TornadoParts[(level.TornadoParts.size - 1)] SpawnableArray("Tornado");
            level.TornadoParts[(level.TornadoParts.size - 1)] clientfield::set("powerup_fx", color);
        }
    }

    level.TornadoParts[0] thread TornadoMovement();
    level.TornadoParts[0] thread TornadoMovementWatch(level.TornadoParts[0].origin);
    level.TornadoParts[0] thread RotateTornadoYaw(360, 3);
}

TornadoMovement()
{
    level endon("Tornado_Stop");
    self endon("EndTornadoMovement");
    
    while(1)
    {
        self zm_utility::create_zombie_point_of_interest(5000, 255, 10000, 1);
        self MoveTo(self.origin + (RandomIntRange(-100, 100), RandomIntRange(-100, 100), 0), 3);

        self waittill("movedone");
    }
}

TornadoMovementWatch(DefOrg)
{
    level endon("Tornado_Stop");
    
    while(1)
    {
        if(Distance(DefOrg, self.origin) >= 750)
        {
            self notify("EndTornadoMovement");
            self MoveTo(DefOrg, 3);

            wait 3.5;

            self thread TornadoMovement();
        }

        wait 0.01;
    }
}

TornadoWatchPlayers()
{
    level endon("Tornado_Stop");

    wait 3;

    while(1)
    {
        foreach(player in level.players)
            for(a = 0; a < level.TornadoParts.size; a++)
                if(Distance(level.TornadoParts[a].origin, player.origin) <= 100 && !isDefined(level.TornadoIgnorePlayers) && !isDefined(player.OnTornado) && !player isPlayerLinked())
                    player thread TornadoLaunchPlayer(a);

        wait 0.01;
    }
}

TornadoLaunchPlayer(a)
{
    level endon("Tornado_Stop");
    self endon("disconnect");

    self.OnTornado = true;

    for(b = a; b < level.TornadoParts.size; b++)
    {
        if(!(b % 2))
            continue;
        
        self PlayerLinkTo(level.TornadoParts[b], "tag_origin");

        wait 0.025;
    }

    self Unlink();

    if(self IsOnGround())
        self SetOrigin(self.origin + (0, 0, 5));

    self SetVelocity((450, 450, 850));

    wait 1;

    self.OnTornado = undefined;
}

TornadoWatchEntities()
{
    level endon("Tornado_Stop");

    wait 3;

    while(isDefined(self))
    {
        for(a = 1; a < level.TornadoParts.size; a++)
            if(Distance(level.TornadoParts[a].origin, self.origin) <= 100 && !isDefined(level.TornadoIgnoreEntities) && !isDefined(self.OnTornado))
                self thread TornadoLaunchEntity(a);

        wait 0.01;
    }
}

TornadoLaunchEntity(a)
{
    self.OnTornado = true;

    for(b = a; b < level.TornadoParts.size; b++)
    {
        if(!(b % 2))
            continue;
        
        self.origin = level.TornadoParts[b].origin;
        self LinkTo(level.TornadoParts[b]);

        wait 0.025;
    }

    self Unlink();
    self Launch(AnglesToForward(self.angles) * 7500);

    wait 1;

    self.OnTornado = undefined;
}

TornadoWatchZombies()
{
    level endon("Tornado_Stop");

    wait 3;

    while(1)
    {
        for(a = 1; a < level.TornadoParts.size; a++)
            foreach(zombie in GetAITeamArray(level.zombie_team))
                if(isDefined(zombie) && IsAlive(zombie) && Distance(level.TornadoParts[a].origin, zombie.origin) <= 100 && !isDefined(level.TornadoIgnoreZombies) && !isDefined(zombie.OnTornado))
                    zombie thread TornadoLaunchZombie(a);

        wait 0.01;
    }
}

TornadoLaunchZombie(a)
{
    level endon("Tornado_Stop");

    self.OnTornado = true;

    for(b = a; b < level.TornadoParts.size; b++)
    {
        if(!IsAlive(self) || !isDefined(self))
            break;
        
        if(!(b % 2))
            continue;
        
        self ForceTeleport(level.TornadoParts[b].origin);
        self LinkTo(level.TornadoParts[b]);

        wait 0.025;
    }
    
    if(!isDefined(self) || !IsAlive(self))
        return;

    linker = SpawnScriptModel(self.origin, "tag_origin");
    self LinkTo(linker, "tag_origin");
    linker Launch(AnglesToForward(self.angles) * 7500);

    wait 1;

    if(!isDefined(self) || !IsAlive(self))
        return;

    linker delete();
    self.OnTornado = undefined;
}

RotateTornadoYaw(int, time)
{
    level endon("Tornado_Stop");

    while(1)
    {
        self RotateYaw(int, time);
        wait time;
    }
}

TornadoIgnorePlayers()
{
    level.TornadoIgnorePlayers = isDefined(level.TornadoIgnorePlayers) ? undefined : true;
}

TornadoIgnoreEntities()
{
    level.TornadoIgnoreEntities = isDefined(level.TornadoIgnoreEntities) ? undefined : true;
}

MoonDoors()
{
    if(!isDefined(level.MoonDoors) && !IsAllDoorsOpen())
    {
        menu = self getCurrent();
        curs = self getCursor();

        self OpenAllDoors();
    }
    
    level.MoonDoors = isDefined(level.MoonDoors) ? undefined : true;

    if(isDefined(menu) && isDefined(curs))
        self RefreshMenu(menu, curs);
    
    if(isDefined(level.MoonDoors))
        thread OpenCloseMoonDoors();
    else
    {
        types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];

        for(a = 0; a < types.size; a++)
        {
            doors = GetEntArray(types[a], "targetname");

            if(isDefined(doors))
            {
                for(b = 0; b < doors.size; b++)
                {
                    if(isDefined(doors[b]))
                    {
                        script_strings = ["rotate", "slide_apart", "move"];
                        
                        if(!doors[b] IsDoorOpen(types[a]))
                        {
                            for(c = 0; c < doors[b].doors.size; c++)
                                if(isDefined(doors[b].doors[c]) && isInArray(script_strings, doors[b].doors[c].script_string))
                                    doors[b].doors[c] thread SetMoonDoorState(doors[b], true);
                        }
                    }
                }
            }
        }
    }
}

OpenCloseMoonDoors()
{
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];

    while(isDefined(level.MoonDoors))
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
                        script_strings = ["rotate", "slide_apart", "move"];
                        
                        if(AnyoneNearDoor(doors[b]) && !doors[b] IsDoorOpen(types[a]))
                        {
                            for(c = 0; c < doors[b].doors.size; c++)
                                if(isDefined(doors[b].doors[c]) && isInArray(script_strings, doors[b].doors[c].script_string))
                                    doors[b].doors[c] thread SetMoonDoorState(doors[b], true);
                        }
                        else if(!AnyoneNearDoor(doors[b]) && doors[b] IsDoorOpen(types[a]))
                        {
                            for(c = 0; c < doors[b].doors.size; c++)
                                if(isDefined(doors[b].doors[c]) && isInArray(script_strings, doors[b].doors[c].script_string))
                                    doors[b].doors[c] thread SetMoonDoorState(doors[b], false);
                        }
                    }
                }
            }
        }

        wait 0.01;
    }
}

SetMoonDoorState(door, open)
{
    time = isDefined(self.script_transition_time) ? self.script_transition_time : 1;
    scale = open ? 1 : -1;
    door.has_been_opened = open;
    door.door_is_moving = true;
    
    switch(self.script_string)
    {
        case "rotate":
            angles = open ? self.script_angles : self.savedAngles;

            if(isDefined(angles))
            {
                self RotateTo(angles, time, 0, 0);
                self thread zm_blockers::door_solid_thread();

                wait time;
            }
            break;
        
        case "slide_apart":
            if(isDefined(self.script_vector))
            {
                vector = VectorScale(self.script_vector, scale);
                goalOrigin = open ? (self.origin + vector) : self.savedOrigin;

                if(time >= 0.5)
                    self MoveTo(goalOrigin, time, (time * 0.25), (time * 0.25));
                else
                    self MoveTo(goalOrigin, time);

                self thread zm_blockers::door_solid_thread();

                wait time;
            }
            break;
        
        case "move":
            if(isDefined(self.script_vector))
            {
                vector = VectorScale(self.script_vector, scale);
                goalOrigin = open ? (self.origin + vector) : self.savedOrigin;

                if(time >= 0.5)
                    self MoveTo(goalOrigin, time, (time * 0.25), (time * 0.25));
                else
                    self MoveTo(goalOrigin, time);

                self thread zm_blockers::door_solid_thread();

                wait time;
            }
            break;
        
        default:
            break;
    }
    
    door.door_is_moving = undefined;
}

AnyoneNearDoor(door)
{
    foreach(ai in GetAITeamArray(level.zombie_team))
        if(Distance(ai.origin, door.origin) <= 255)
            return true;

    foreach(player in level.players)
        if(Distance(player.origin, door.origin) <= 255)
            return true;

    return false;
}

ControllableZombie(team)
{
    if(isDefined(self.ControllableZombie))
        return;
    
    if(self isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(isDefined(self.BodyGuard))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use Controllable Zombie While Body Guard Is Enabled");
    
    self.ControllableZombie = true;
    
    self endon("disconnect");
    
    self closeMenu1();
    self.menu["DisableMenuControls"] = true;

    CZSavedOrigin = self.origin;
    CZSavedAngles = self.angles;

    spawner = ArrayGetClosest(level.zombie_spawners, self.origin);
    zombie = zombie_utility::spawn_zombie(spawner);

    self SetStance("stand");

    wait 0.1;
    
    if(isDefined(zombie))
    {
        self EnableInvulnerability();
        self Hide();

        self.ignoreme = 1;
        zombie.ignoreme = 1;

        viewModel = SpawnScriptModel((zombie.origin + (0, 0, 18)) + (AnglesToForward(zombie.angles) * -40), "tag_origin", zombie.angles);
        viewModel LinkTo(zombie);
        
        self PlayerLinkToDelta(viewModel, "tag_origin", 0, 85, 85, 35, 35, true, true);
        self FreezeControlsAllowLook(true);
        self DisableWeapons();
        self DisableOffhandWeapons();
        self SetPlayerAngles(zombie.angles);
        
        zombie.ignore_find_flesh = 1;
        zombie.team = (team == "Friendly") ? self.team : level.zombie_team;
        zombie thread zombie_utility::set_zombie_run_cycle("sprint");

        while(!zombie CanControl() && IsAlive(zombie))
        {
            if(self MeleeButtonPressed())
                zombie DoDamage(zombie.health + 666, zombie GetTagOrigin("j_head"));
            
            wait 0.1;
        }
        
        goalPos = SpawnScriptModel(GetGroundPos(self TraceBullet()), "tag_origin");
        PlayFXOnTag(level._effect["powerup_on"], goalPos, "tag_origin");
        
        goalPos SetInvisibleToAll();
        goalPos SetVisibleToPlayer(self);
        
        while(IsAlive(zombie))
        {
            zombie.ignore_find_flesh = 1;
            self.ignoreme = 1;
            zombie.ignoreme = 1;
            goalPos.origin = self TraceBullet();
            
            if(isDefined(zombie) && IsAlive(zombie) && zombie CanControl())
            {
                if(Distance(zombie.origin, goalPos.origin) >= 100)
                {
                    zombie SetGoal(goalPos.origin, true);

                    if(isDefined(zombie.zombie_move_speed) && zombie.zombie_move_speed != "sprint")
                        zombie thread zombie_utility::set_zombie_run_cycle("sprint");
                }
                
                if(self AttackButtonPressed())
                    zombie ZombieAttack();
            }
            
            if(self MeleeButtonPressed())
            {
                zombie DoDamage((zombie.health + 666), zombie GetTagOrigin("j_head"));
                wait 0.8;

                break;
            }
            
            wait 0.01;
        }
    }
    else
        self iPrintlnBold("^1ERROR: ^7Couldn't Spawn Zombie");
    
    wait 0.1;

    if(!isDefined(self.Invisibility))
        self Show();
    
    if(!isDefined(self.godmode))
        self DisableInvulnerability();

    self Unlink();
    self FreezeControlsAllowLook(false);
    self EnableWeapons();
    self EnableOffhandWeapons();

    if(!isDefined(self.NoTarget))
        self.ignoreme = 0;

    viewModel delete();
    goalPos delete();
    
    self SetOrigin(CZSavedOrigin);
    self SetPlayerAngles(CZSavedAngles);
    self.menu["DisableMenuControls"] = undefined;
    self.ControllableZombie = undefined;
}

CanControl()
{
    if(isDefined(self.is_traversing) && self.is_traversing)
        return false;
    
    if(isDefined(self.is_leaping) && self.is_leaping)
        return false;
    
    if(isDefined(self.barricade_enter) && self.barricade_enter)
        return false;
    
    if(!zm_behavior::inplayablearea(self))
        return false;
    
    return true;
}

ZombieAttack()
{
    self endon("death");
    
    v_angles = self.angles;

    if(isDefined(self.attacking_point))
    {
        v_angles = (self.attacking_point.v_center_pillar - self.origin);
        v_angles = VectorToAngles((v_angles[0], v_angles[1], 0));
    }
    
    animation = "ai_zombie_base_ad_attack_v1";
    self AnimScripted("attack_anim", self.origin, v_angles, animation);
    
    wait GetAnimLength(animation);
}

BodyGuard()
{
    if(isDefined(self.ControllableZombie) && !isDefined(self.BodyGuard))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use Body Guard While Controllable Zombie Is Enabled");
    
    self.BodyGuard = isDefined(self.BodyGuard) ? undefined : true;

    if(isDefined(self.BodyGuard))
    {
        self endon("disconnect");
        self endon("EndBodyGuard");
        
        spawner = ArrayGetClosest(level.zombie_spawners, self.origin);
        self.BodyGuardZombie = zombie_utility::spawn_zombie(spawner);

        wait 0.1;
        
        if(isDefined(self.BodyGuardZombie))
        {
            self.BodyGuardZombieLinker = spawn("script_origin", self.BodyGuardZombie.origin);

            self.BodyGuardZombieLinker.origin = self.BodyGuardZombie.origin;
            self.BodyGuardZombieLinker.angles = self.BodyGuardZombie.angles;

            self.BodyGuardZombie LinkTo(self.BodyGuardZombieLinker);
            self.BodyGuardZombieLinker MoveTo(self.origin, 0.01);
            self.BodyGuardZombieLinker waittill("movedone");

            self.BodyGuardZombie Unlink();
            self.BodyGuardZombieLinker delete();
            self.BodyGuardZombie.find_flesh_struct_string = "find_flesh";
            self.BodyGuardZombie.ai_state = "find_flesh";
            self.BodyGuardZombie notify("zombie_custom_think_done", "find_flesh");
            
            self.BodyGuardZombie.ignoreme = 1;
            self.BodyGuardZombie.team = self.team;
            self.BodyGuardZombie.no_gib = 1;
            self.BodyGuardZombie.allowdeath = 0;
            self.BodyGuardZombie.allowpain = 0;
            self.BodyGuardZombie.aat_turned = 1;
            self.BodyGuardZombie thread clientfield::set("zm_aat_turned", 1);
            
            while(isDefined(self.BodyGuard))
            {
                target = self.BodyGuardZombie GetBodyGuardTarget(self);
                
                if(!isDefined(target))
                {
                    self.BodyGuardZombie ClearForcedGoal();
                    goalPos = (self.origin + VectorScale(AnglesToForward(self GetPlayerAngles()), 100));
                    
                    speed = (Distance(goalPos, self.BodyGuardZombie.origin) > 200) ? "super_sprint" : "walk";

                    if(isDefined(self.BodyGuardZombie.zombie_move_speed) && self.BodyGuardZombie.zombie_move_speed != speed)
                        self.BodyGuardZombie thread zombie_utility::set_zombie_run_cycle(speed);

                    self.BodyGuardZombie SetGoal(goalPos, true, 255);
                }
                else
                {
                    if(isDefined(self.BodyGuardZombie.zombie_move_speed) && self.BodyGuardZombie.zombie_move_speed != "super_sprint")
                        self.BodyGuardZombie thread zombie_utility::set_zombie_run_cycle("super_sprint");

                    self.BodyGuardZombie SetGoal(target.origin, true);
                }
                
                wait 0.01;
            }
        }
    }
    else
    {
        self notify("EndBodyGuard");

        if(isDefined(self.BodyGuardZombie))
        {
            self.BodyGuardZombie thread clientfield::set("zm_aat_turned", 0);

            self.BodyGuardZombie.no_gib = 0;
            self.BodyGuardZombie.allowdeath = 1;
            self.BodyGuardZombie.allowpain = 1;
            
            self.BodyGuardZombie DoDamage(self.BodyGuardZombie.health + 666, self.BodyGuardZombie GetTagOrigin("j_head"));
        }

        if(isDefined(self.BodyGuardZombieLinker))
            self.BodyGuardZombieLinker delete();
    }
}

GetBodyGuardTarget(player)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        zombieOrigin = zombies[a] GetCentroid();

        if(zombies[a] == self || !zm_behavior::inplayablearea(zombies[a]) || Distance(player.origin, zombieOrigin) > 500 || !player DamageConeTrace(zombies[a] GetCentroid()) || isDefined(zombie) && Distance(player.origin, zombieOrigin) > Distance(player.origin, zombie.origin))
            continue;
        
        zombie = zombies[a];
    }

    return zombie;
}

SpiralStaircase(size)
{
    model = GetSpawnableBaseModel();

    if(!isInArray(level.MenuModels, model))
        return self iPrintlnBold("^1ERROR: ^7Couldn't Find A Valid Base Model For The Spiral Staircase");
    
    if(isDefined(level.SpiralStaircaseSpawning))
        return self iPrintlnBold("^1ERROR: ^7Spiral Staircase Is Being Built");
    
    if(isDefined(level.SpiralStaircaseDeleting))
        return self iPrintlnBold("^1ERROR: ^7Spiral Staircase Is Being Deleted");
    
    if(isDefined(level.SpiralStaircase) && level.SpiralStaircase.size)
    {
        level.SpiralStaircaseDeleting = true;

        for(a = 0; a < level.SpiralStaircase.size; a++)
            if(isDefined(level.SpiralStaircase[a]))
            {
                level.SpiralStaircase[a] Launch(VectorScale(AnglesToForward(level.SpiralStaircase[a].angles), 255));
                level.SpiralStaircase[a] NotSolid();
                level.SpiralStaircase[a] thread deleteAfter(5);

                wait 0.01;
            }
        
        wait 5;

        level.SpiralStaircase = [];
        level.SpiralStaircaseDeleting = undefined;
    }
    else
    {
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
    
        origin = trace["position"];
        surface = trace["surfacetype"];

        if(surface == "none" || surface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
        
        level.SpiralStaircaseSpawning = true;

        if(!isDefined(level.SpiralStaircase))
            level.SpiralStaircase = [];
        
        level.SpiralStaircase[0] = SpawnScriptModel(origin, model, (-28, self.angles[1], 90));
        
        for(a = 1; a < size; a++)
        {
            origin = level.SpiralStaircase[(level.SpiralStaircase.size - 1)].origin;
            angles = level.SpiralStaircase[(level.SpiralStaircase.size - 1)].angles;
            
            level.SpiralStaircase[level.SpiralStaircase.size] = SpawnScriptModel((origin + (AnglesToForward(angles) * 10) + (0, 0, 8)), model, (level.SpiralStaircase[0].angles[0], (angles[1] + 12), level.SpiralStaircase[0].angles[2]), 0.01);
        }

        level.SpiralStaircaseSpawning = undefined;
    }
}