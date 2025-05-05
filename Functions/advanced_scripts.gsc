PopulateAdvancedScripts(menu)
{
    switch(menu)
    {
        case "Advanced Scripts":
            self addMenu("Advanced Scripts");
                self addOpt("Rain Options", ::newMenu, "Rain Options");
                self addOpt("Custom Sentry", ::newMenu, "Custom Sentry");
                self addOptSlider("Controllable Zombie", ::ControllableZombie, "Friendly;Enemy");
                self addOptSlider("Teleporter", ::SpawnTeleporter, "Spawn;Delete All");
                self addOptSlider("AC-130", ::AC130, "Fly;Walking");
                self addOptIncSlider("Mexican Wave", ::MexicanWave, 2, 2, 15, 1);
                self addOptIncSlider("Spiral Staircase", ::SpiralStaircase, 5, 5, 50, 1);

                if(isDefined(level.zombie_include_powerups) && level.zombie_include_powerups.size)
                    self addOptBool(level.RainPowerups, "Rain Power-Ups", ::RainPowerups);
                
                if(ReturnMapName() != "Moon" && ReturnMapName() != "Origins")
                    self addOptBool(level.MoonDoors, "Moon Doors", ::MoonDoors);
                
                self addOptBool(self.BodyGuard, "Body Guard", ::BodyGuard);
                self addOptBool(level.TornadoSpawned, "Tornado", ::Tornado);
                self addOptBool(self.ZombieTeleportGrenades, "Zombie Teleport Grenades", ::ZombieTeleportGrenades);
                self addOpt("Artillery Strike", ::ArtilleryStrike);
            break;
        
        case "Rain Options":
            self addMenu("Rain Options");
                self addOpt("Disable", ::DisableLobbyRain);
                self addOpt("Models", ::newMenu, "Rain Models");
                self addOpt("Effects", ::newMenu, "Rain Effects");
                self addOpt("Projectiles", ::newMenu, "Rain Projectiles");
            break;
        
        case "Rain Models":
            self addMenu("Models");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::LobbyRain, "Model", level.MenuModels[a]);
            break;
        
        case "Rain Effects":
            self addMenu("Effects");

                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOpt(CleanString(level.MenuEffects[a]), ::LobbyRain, "FX", level.MenuEffects[a]);
            break;
        
        case "Rain Projectiles":
            self addMenu("Projectiles");

                if(!IsVerkoMap())
                {
                    arr = [];
                    weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");
                    weaps = GetArrayKeys(level.zombie_weapons);

                    if(isDefined(weaps) && weaps.size)
                    {
                        for(a = 0; a < weaps.size; a++)
                        {
                            if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                            {
                                strn = (MakeLocalizedString(weaps[a].displayname) != "") ? weaps[a].displayname : weaps[a].name;
                                
                                if(!IsInArray(arr, strn))
                                {
                                    arr[arr.size] = strn;
                                    self addOpt(strn, ::LobbyRain, "Projectile", weaps[a]);
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
        
        case "Custom Sentry":
            if(!isDefined(self.CustomSentryWeapon))
                self.CustomSentryWeapon = GetWeapon("minigun");

            self addMenu("Custom Sentry");
                self addOptBool(self.CustomSentry, "Custom Sentry", ::CustomSentry);
                self addOpt("");
                self addOptBool((self.CustomSentryWeapon == GetWeapon("minigun")), "Death Machine", ::SetCustomSentryWeapon, GetWeapon("minigun"));

                if(!IsVerkoMap())
                {
                    arr = [];
                    weaps = GetArrayKeys(level.zombie_weapons);
                    weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");

                    if(isDefined(weaps) && weaps.size)
                    {
                        for(a = 0; a < weaps.size; a++)
                        {
                            if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                            {
                                strn = (MakeLocalizedString(weaps[a].displayname) != "") ? weaps[a].displayname : weaps[a].name;
                                
                                if(!IsInArray(arr, strn))
                                {
                                    arr[arr.size] = strn;
                                    self addOptBool((self.CustomSentryWeapon == weaps[a]), strn, ::SetCustomSentryWeapon, weaps[a]);
                                }
                            }
                        }
                    }
                }
                else
                {
                    for(a = 0; a < level.var_21b77150.size; a++)
                        self addOptBool((self.CustomSentryWeapon == GetWeapon(level.var_7df703ba[a])), level.var_7df703ba[a], ::SetCustomSentryWeapon, GetWeapon(level.var_21b77150[a]));
                }
            break;
    }
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
                break;
            
            case "Model":
                RainModel = SpawnScriptModel(origin, rain);

                if(!isDefined(RainModel))
                    break;
                
                RainModel NotSolid();
                RainModel Launch(VectorScale(AnglesToForward(RainModel.angles), 10));
                RainModel thread deleteAfter(10);
                break;
            
            case "FX":
                linker = SpawnScriptModel(origin, "tag_origin");

                if(!isDefined(linker))
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

    self.CustomSentry = BoolVar(self.CustomSentry);

    if(Is_True(self.CustomSentry))
    {
        if(!isDefined(origin))
            origin = self.origin;

        self.CustomSentryOrigin = origin;
        
        sentrygun = self.CustomSentryWeapon;
        self.sentrygun_weapon = zm_utility::spawn_weapon_model(sentrygun, undefined, origin, (0, self.angles[1], 0));
        self.sentrygun_weapon.owner = self;

        self.sentrygun_weapon thread clientfield::set("zm_aat_fire_works", 1);
        self.sentrygun_weapon MoveTo(origin + (0, 0, 56), 0.5);
        self.sentrygun_weapon waittill("movedone");
        
        while(Is_True(self.CustomSentry))
        {
            zombie = self.sentrygun_weapon CustomSentryGetTarget();
            v_target_pos = !isDefined(zombie) ? (self.sentrygun_weapon.origin + VectorScale(AnglesToForward((0, RandomIntRange(0, 360), 0)), 40)) : zombie GetTagOrigin("j_head");

            if(isDefined(zombie) && !isDefined(v_target_pos)) //Needed for AI that don't have the targeted bone tag(i.e. Spiders)
                v_target_pos = zombie GetTagOrigin("tag_body");
            
            self.sentrygun_weapon.angles = VectorToAngles(v_target_pos - self.sentrygun_weapon.origin);
            self.sentrygun_weapon DontInterpolate();

            if(isDefined(zombie))
                MagicBullet(sentrygun, self.sentrygun_weapon GetTagOrigin("tag_flash"), v_target_pos, self.sentrygun_weapon);

            util::wait_network_frame();
        }
    }
    else
    {
        if(isDefined(self.sentrygun_weapon))
        {
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

    if(Is_True(self.CustomSentry))
        for(a = 0; a < 2; a++)
            self CustomSentry(self.CustomSentryOrigin);
}

ControllableZombie(team)
{
    if(Is_True(self.ControllableZombie))
        return;
    
    if(self isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(Is_True(self.BodyGuard))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use Controllable Zombie While Body Guard Is Enabled");
    
    self endon("disconnect");
    
    self closeMenu1();
    self.ControllableZombie = true;
    self.DisableMenuControls = true;
    self.ignoreme = true;

    CZSavedOrigin = self.origin;
    CZSavedAngles = self.angles;

    spawner = ArrayGetClosest(level.zombie_spawners, self.origin);
    zombie = zombie_utility::spawn_zombie(spawner);
    
    self SetStance("stand");
    wait 0.1;
    
    if(isDefined(zombie))
    {
        self Hide();
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

    if(!Is_True(self.Invisibility))
        self Show();
    
    self Unlink();
    self FreezeControlsAllowLook(false);
    self EnableWeapons();
    self EnableOffhandWeapons();

    viewModel delete();
    goalPos delete();
    
    self SetOrigin(CZSavedOrigin);
    self SetPlayerAngles(CZSavedAngles);

    if(Is_True(self.DisableMenuControls))
        self.DisableMenuControls = BoolVar(self.DisableMenuControls);

    if(Is_True(self.ControllableZombie))
        self.ControllableZombie = BoolVar(self.ControllableZombie);

    if(Is_True(self.ignoreme))
        self.ignoreme = false;
}

CanControl()
{
    if(Is_True(self.is_traversing))
        return false;
    
    if(Is_True(self.is_leaping))
        return false;
    
    if(Is_True(self.barricade_enter))
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

SpawnTeleporter(action = "Spawn", origin, skipLink = false, skipDelete = false)
{
    if(isDefined(action) && action == "Delete All")
    {
        DeleteTeleporters();
        return;
    }

    if(!isDefined(origin))
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
    if(!isDefined(level.ActiveTeleporters) || !level.ActiveTeleporters.size)
        return;
    
    foreach(teleporter in level.ActiveTeleporters)
        if(isDefined(teleporter) && !Is_True(teleporter.skipDelete))
            teleporter delete();
}

AddActiveTeleporter(skipLink = false, skipDelete = false)
{
    if(!isDefined(level.ActiveTeleporters))
        level.ActiveTeleporters = [];
    
    if(isInArray(level.ActiveTeleporters, self))
        return;
    
    if(level.ActiveTeleporters.size && !skipLink)
    {
        if(isDefined(level.ActiveTeleporters[(level.ActiveTeleporters.size - 1)]) && !isDefined(level.ActiveTeleporters[(level.ActiveTeleporters.size - 1)].LinkedTeleporter))
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

    while(isDefined(self))
    {
        PlayFXOnTag(level._effect["teleport_aoe_kill"], self, "tag_origin");
        wait 0.25;
    }
}

ActivateTeleporter()
{
    if(isDefined(self.TeleporterActivated))
        return;
    self.TeleporterActivated = true;

    while(isDefined(self))
    {
        self waittill("trigger", player);
        
        if(Is_True(player.UsingTeleporter) || !isDefined(self))
            continue;
        
        if(!isDefined(self.LinkedTeleporter))
        {
            player iPrintlnBold("^1ERROR: ^7No Linked Teleporter Found");
            continue;
        }
        
        player thread UseTeleporter(self);
    }
}

UseTeleporter(teleporter)
{
    if(!isDefined(teleporter) || Is_True(self.UsingTeleporter) || !isDefined(teleporter.LinkedTeleporter))
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

AC130(type)
{
    if(Is_True(self.AC130))
        return;
    self.AC130 = true;

    self endon("disconnect");

    self.DisableMenuControls = true;
    self closeMenu1();
    
    if(type == "Fly")
    {
        self.ACSavedOrigin = self.origin;
        self.ACSavedAngles = self GetPlayerAngles();
        SetAngles = VectorToAngles(self.ACSavedOrigin - self GetEye());
        
        linker = SpawnScriptModel(self.ACSavedOrigin, "tag_origin", (0, SetAngles[1], 0));
        c130 = SpawnScriptModel(((linker.origin + (AnglesToRight(linker.angles) * 1800)) + (0, 0, ((self.StartOrigin[2] + 1500) - linker.origin[2]))), "tag_origin");

        if(!isDefined(linker) || !isDefined(c130))
            return;
        
        c130.angles = VectorToAngles(linker.origin - c130.origin);
        c130 LinkTo(linker);
        linker thread AC130Rotate();

        self AllowCrouch(false);
        self SetOrigin(c130.origin);
        self PlayerLinkToDelta(c130, "tag_origin", 0, 50, 50, 15, 15);
        self Hide();
    }

    if(!isDefined(self.AC130DisableFire))
        self.AC130DisableFire = [];

    ammoType = GetWeapon("minigun");
    ammoTime = 0.01;

    self RefreshAC130HUD(ammoType);
    self DisableWeapons(true);
    self DisableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 0);
    
    while(1)
    {
        if(self AttackButtonPressed())
        {
            if(!Is_True(self.AC130DisableFire[ammoType]))
                self thread FireAC130(ammoType);
        }
        else if(self GamepadUsedLast() && self WeaponSwitchButtonPressed() || !self GamepadUsedLast() && self UseButtonPressed())
        {
            ammoType = AC130NextWeapon(ammoType);
            self RefreshAC130HUD(ammoType);
            
            wait 0.15;
        }

        if(self MeleeButtonPressed())
            break;
        
        if(Is_True(self.AC130DisableFire[ammoType]) && ammoType != GetWeapon("minigun"))
        {
            if(!isDefined(self.AC130Reloading))
            {
                self.AC130Reloading = self createText("default", 1.4, 1, "RELOADING...", "CENTER", "CENTER", 0, 100, 1, (1, 1, 1));
                self.AC130Reloading thread AC130FlashingHud();
            }
        }
        else
        {
            if(isDefined(self.AC130Reloading))
                self.AC130Reloading DestroyHud();
        }

        wait 0.01;
    }
    
    if(isDefined(self.AC130HUD))
        destroyAll(self.AC130HUD);
    
    if(isDefined(self.AC130Reloading))
        self.AC130Reloading DestroyHud();
    
    self EnableWeapons();
    self EnableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 1);

    if(type == "Fly")
    {
        if(isDefined(linker))
            linker delete();
        
        if(isDefined(c130))
            c130 delete();

        self AllowCrouch(true);
        self SetOrigin(self.ACSavedOrigin);
        self SetPlayerAngles(self.ACSavedAngles);

        if(!Is_True(self.Invisibility))
            self Show();
    }

    if(Is_True(self.DisableMenuControls))
        self.DisableMenuControls = BoolVar(self.DisableMenuControls);

    if(Is_True(self.AC130))
        self.AC130 = BoolVar(self.AC130);
}

AC130FlashingHud()
{
    if(!isDefined(self))
        return;
    
    self endon("death");

    while(isDefined(self))
    {
        self hudFade(0.2, 0.35);

        if(isDefined(self))
            self hudFade(1, 0.35);
        
        wait 0.01;
    }
}

AC130NextWeapon(current)
{
    weapon40MM = IsVerkoMap() ? GetWeapon("vk_tra_pis_t9_1911_rdw_lvl3") : zm_weapons::get_upgrade_weapon(level.start_weapon);
    return (current == GetWeapon("minigun")) ? weapon40MM : (current == weapon40MM) ? GetWeapon("hunter_rocket_turret_player") : GetWeapon("minigun");
}

AC130FireRate(ammo)
{
    weapon40MM = IsVerkoMap() ? GetWeapon("vk_tra_pis_t9_1911_rdw_lvl3") : zm_weapons::get_upgrade_weapon(level.start_weapon);
    return (ammo == GetWeapon("minigun")) ? 0.01 : (ammo == weapon40MM) ? 1 : 5;
}

FireAC130(ammoType)
{
    self endon("disconnect");

    if(!isDefined(self.AC130DisableFire))
        self.AC130DisableFire = [];
    
    self.AC130DisableFire[ammoType] = true;

    fire_origin = self GetTagOrigin("j_neck") + (AnglesToForward(self GetPlayerAngles()) * 5) + (AnglesToRight(self GetPlayerAngles()) * -5);
    weapon40MM = IsVerkoMap() ? GetWeapon("vk_tra_pis_t9_1911_rdw_lvl3") : zm_weapons::get_upgrade_weapon(level.start_weapon);

    if(ammoType == GetWeapon("hunter_rocket_turret_player"))
        for(a = 0; a < 6; a++)
            MagicBullet(ammoType, fire_origin, BulletTrace(fire_origin, fire_origin + self GetWeaponForwardDir() * 100, 0, undefined)["position"] + (Cos(a * 60) * 3, Sin(a * 60) * 3, 0), self);
    else
        MagicBullet((ReturnMapName() == "Origins" && ammoType == weapon40MM) ? GetWeapon("hunter_rocket_turret_player") : ammoType, fire_origin, self TraceBullet(), self);
    
    wait AC130FireRate(ammoType);

    if(Is_True(self.AC130DisableFire[ammoType]))
        self.AC130DisableFire[ammoType] = BoolVar(self.AC130DisableFire[ammoType]);
}

AC130Rotate()
{
    if(!isDefined(self))
        return;
    
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

    self.AC130HUD = [];

    weapon40MM = IsVerkoMap() ? GetWeapon("vk_tra_pis_t9_1911_rdw_lvl3") : zm_weapons::get_upgrade_weapon(level.start_weapon);
    AC130HudValues = (ammo == GetWeapon("minigun")) ? Array("0,50,2,80", "40,0,60,2", "-40,0,60,2", "-180,151,2,50", "-155,175,50,2", "180,151,2,50", "155,175,50,2", "180,-151,2,50", "155,-175,50,2", "-180,-151,2,50", "-155,-175,50,2") : (ammo == weapon40MM) ? Array("0,80,2,120", "0,-80,2,120", "0,-46,10,1", "0,-92,10,1", "0,-140,14,1", "0,46,10,1", "0,92,10,1", "0,140,14,1", "85,0,130,2", "-85,0,130,2", "37,0,1,10", "75,0,1,10", "112,0,1,10", "150,0,1,14", "-37,0,1,10", "-75,0,1,10", "-112,0,1,10", "-150,0,1,14") : Array("0,25,51,2", "0,-25,51,2", "25,0,2,51", "-25,0,2,52", "0,50,2,51", "0,-50,2,51", "50,0,51,2", "-50,0,51,2", "225,161,2,30", "210,175,30,2", "-225,161,2,30", "-210,175,30,2", "-225,-161,2,30", "-210,-175,30,2", "225,-161,2,30", "210,-175,30,2");
    text = (ammo == GetWeapon("minigun")) ? "25mm" : (ammo == weapon40MM) ? "40mm" : "105mm";

    for(a = 0; a < AC130HudValues.size; a++)
        self.AC130HUD[self.AC130HUD.size] = self createRectangle("CENTER", "CENTER", Int(StrTok(AC130HudValues[a], ",")[0]), Int(StrTok(AC130HudValues[a], ",")[1]), Int(StrTok(AC130HudValues[a], ",")[2]), Int(StrTok(AC130HudValues[a], ",")[3]), (1, 1, 1), 1, 1, "white");
    
    button = self GamepadUsedLast() ? "[{+weapnext_inventory}]" : "[{+activate}]";
    self.AC130HUD[self.AC130HUD.size] = self createText("default", 1.2, 1, text + "\n^3" + button + " ^7To Change Weapon", "LEFT", "CENTER", -400, 0, 1, (1, 1, 1));
}

MexicanWave(size)
{
    if(isDefined(self.MexicanWave) && self.MexicanWave.size)
    {
        for(a = 0; a < self.MexicanWave.size; a++)
            self.MexicanWave[a] delete();
        
        self.MexicanWave = undefined;
        return;
    }
    
    self.MexicanWave = [];

    for(a = 0; a < size; a++)
    {
        self.MexicanWave[self.MexicanWave.size] = SpawnScriptModel(self.origin + AnglesToRight(self.angles) * (a * 45), "defaultactor", self.angles);
        self.MexicanWave[(self.MexicanWave.size - 1)] thread MexicanWaveMove(a);
    }
}

MexicanWaveMove(index)
{
    wait (index * 0.2);

    while(isDefined(self))
    {
        self MoveZ(55, 0.75);
        wait 0.74;

        if(isDefined(self))
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

        if(Is_True(level.SpiralStaircaseDeleting))
            level.SpiralStaircaseDeleting = BoolVar(level.SpiralStaircaseDeleting);
    }
    else
    {
        model = GetSpawnableBaseModel();
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);

        if(!isInArray(level.MenuModels, model))
            return self iPrintlnBold("^1ERROR: ^7Couldn't Find A Valid Base Model For The Spiral Staircase");
    
        origin = trace["position"];
        surface = trace["surfacetype"];

        if(isDefined(surface) && (surface == "none" || surface == "default"))
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
        
        level.SpiralStaircaseSpawning = true;

        if(!isDefined(level.SpiralStaircase))
            level.SpiralStaircase = [];
        
        level.SpiralStaircase[0] = SpawnScriptModel(origin, model, (-28, self.angles[1], 90));
        
        for(a = 1; a < size; a++)
        {
            if(!isDefined(level.SpiralStaircase[(level.SpiralStaircase.size - 1)]))
                continue;
            
            level.SpiralStaircase[level.SpiralStaircase.size] = SpawnScriptModel((level.SpiralStaircase[(level.SpiralStaircase.size - 1)].origin + (AnglesToForward(level.SpiralStaircase[(level.SpiralStaircase.size - 1)].angles) * 10) + (0, 0, 8)), model, (level.SpiralStaircase[0].angles[0], (level.SpiralStaircase[(level.SpiralStaircase.size - 1)].angles[1] + 12), level.SpiralStaircase[0].angles[2]), 0.01);
        }

        if(Is_True(level.SpiralStaircaseSpawning))
            level.SpiralStaircaseSpawning = BoolVar(level.SpiralStaircaseSpawning);
    }
}

RainPowerups()
{
    level.RainPowerups = BoolVar(level.RainPowerups);

    while(Is_True(level.RainPowerups))
    {
        powerup = level CustomPowerupSpawn(GetArrayKeys(level.zombie_include_powerups)[RandomInt(level.zombie_include_powerups.size)], bot::get_host_player().origin + (RandomIntRange(-1000, 1000), RandomIntRange(-1000, 1000), RandomIntRange(750, 2000)));
        
        if(isDefined(powerup))
            powerup PhysicsLaunch(powerup.origin, (RandomIntRange(-5, 5), RandomIntRange(-5, 5), RandomIntRange(-5, 5)));

        wait 0.05;
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

MoonDoors()
{
    if(!Is_True(level.MoonDoors) && !IsAllDoorsOpen())
    {
        menu = self getCurrent();
        curs = self getCursor();

        self OpenAllDoors();
    }

    level.MoonDoors = BoolVar(level.MoonDoors);
    
    if(Is_True(level.MoonDoors))
        thread OpenCloseMoonDoors();
    else
    {
        types = Array("zombie_door", "zombie_airlock_buy", "zombie_debris");

        for(a = 0; a < types.size; a++)
        {
            doors = GetEntArray(types[a], "targetname");

            if(isDefined(doors))
            {
                for(b = 0; b < doors.size; b++)
                {
                    if(isDefined(doors[b]))
                    {
                        script_strings = Array("rotate", "slide_apart", "move");
                        
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

    if(isDefined(menu) && isDefined(curs))
        self RefreshMenu(menu, curs);
}

OpenCloseMoonDoors()
{
    types = Array("zombie_door", "zombie_airlock_buy", "zombie_debris");

    while(Is_True(level.MoonDoors))
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
                        script_strings = Array("rotate", "slide_apart", "move");
                        
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
                
                if(isDefined(goalOrigin))
                {
                    if(time >= 0.5)
                        self MoveTo(goalOrigin, time, (time * 0.25), (time * 0.25));
                    else
                        self MoveTo(goalOrigin, time);

                    self thread zm_blockers::door_solid_thread();
                }

                wait time;
            }
            break;
        
        default:
            break;
    }
}

AnyoneNearDoor(door)
{
    foreach(ai in GetAITeamArray(level.zombie_team))
        if(isDefined(ai) && IsAlive(ai) && Distance(ai.origin, door.origin) <= 255)
            return true;

    foreach(player in level.players)
        if(Distance(player.origin, door.origin) <= 255)
            return true;

    return false;
}

BodyGuard()
{
    self endon("disconnect");
    
    if(Is_True(self.ControllableZombie) && !Is_True(self.BodyGuard))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use Body Guard While Controllable Zombie Is Enabled");
    
    self.BodyGuard = BoolVar(self.BodyGuard);
    
    if(Is_True(self.BodyGuard))
    {
        spawner = ArrayGetClosest(level.zombie_spawners, self.origin);
        self.BodyGuardZombie = zombie_utility::spawn_zombie(spawner);
        wait 0.1;
        
        if(Is_True(self.BodyGuard) && isDefined(self.BodyGuardZombie) && IsAlive(self.BodyGuardZombie))
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
            self.BodyGuardZombie.n_aat_turned_zombie_kills = 0;
            self.BodyGuardZombie clientfield::set("zm_aat_turned", 1);
            
            while(Is_True(self.BodyGuard))
            {
                target = self.BodyGuardZombie GetBodyGuardTarget(self);

                if(!isDefined(target))
                    target = self.BodyGuardZombie GetBodyGuardTarget(self.BodyGuardZombie); //Attempt to find a target that is near the body guard, if there isn't one near the player
                
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
    zombie = undefined;
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || zombies[a] == self || !zm_behavior::inplayablearea(zombies[a]))
            continue;
        
        if(Distance(player.origin, zombies[a].origin) > 500 || !player DamageConeTrace(zombies[a] GetCentroid()) || isDefined(zombie) && Distance(player.origin, zombies[a].origin) > Distance(player.origin, zombie.origin))
            continue;
        
        zombie = zombies[a];
    }

    return zombie;
}

Tornado()
{
    if(!Is_True(level.TornadoSpawned))
    {
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
        
        origin = trace["position"];
        surface = trace["surfacetype"];

        if(isDefined(surface) && (surface == "none" || surface == "default"))
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
    }
    else
    {
        if(!isDefined(level.SpawnableArray["Tornado"]) || !level.SpawnableArray["Tornado"].size)
            return;
        
        for(a = 0; a < level.SpawnableArray["Tornado"].size; a++)
            if(isDefined(level.SpawnableArray["Tornado"][a]))
                level.SpawnableArray["Tornado"][a] delete();
        
        level notify("Tornado_Stop");
        level.TornadoSpawned = BoolVar(level.TornadoSpawned);

        return;
    }

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
        }
    }

    TornadoParts[0] thread TornadoMovement(TornadoParts[0].origin);
    level thread TornadoWatchEntities(TornadoParts);
}

TornadoMovement(defaultOrigin)
{
    level endon("Tornado_Stop");
    self endon("EndTornadoMovement");
    
    while(1)
    {
        self zm_utility::create_zombie_point_of_interest(5000, 255, 10000, 1);
        self MoveTo(self.origin + (RandomIntRange(-100, 100), RandomIntRange(-100, 100), 0), 3);
        self RotateYaw(360, 3);
        wait 3;

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
        foreach(entity in GetEntArray("script_model", "classname"))
        {
            if(!isDefined(entity) || isInArray(TornadoParts, entity) || Is_True(entity.OnTornado) || entity.model == "tag_origin")
                continue;
            
            for(a = 1; a < TornadoParts.size; a++)
            {
                if(Distance(TornadoParts[a].origin, entity.origin) <= 100)
                {
                    entity thread TornadoLaunchEntity(a, TornadoParts);
                    break;
                }
            }
        }

        foreach(player in level.players)
        {
            if(!isDefined(player) || !Is_Alive(player) || player isPlayerLinked() || Is_True(player.OnTornado))
                continue;
            
            for(a = 1; a < TornadoParts.size; a++)
            {
                if(Distance(TornadoParts[a].origin, player.origin) <= 100)
                {
                    player thread TornadoLaunchPlayer(a, TornadoParts);
                    break;
                }
            }
        }
        
        foreach(zombie in GetAITeamArray(level.zombie_team))
        {
            if(!isDefined(zombie) || !IsAlive(zombie) || Is_True(zombie.OnTornado))
                continue;
            
            for(a = 1; a < TornadoParts.size; a++)
            {
                if(Distance(TornadoParts[a].origin, zombie.origin) <= 100)
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
    if(!isDefined(self) || !Is_Alive(self))
        return;
    
    level endon("Tornado_Stop");
    self endon("disconnect");

    self.OnTornado = true;

    for(b = a; b < TornadoParts.size; b++)
    {
        if(!isDefined(self) || !Is_Alive(self))
            break;
        
        if(isDefined(TornadoParts[b]) && b % 2)
        {
            self PlayerLinkTo(TornadoParts[b], "tag_origin");
            wait 0.025;
        }
    }

    if(!isDefined(self) || !Is_Alive(self))
        return;

    self Unlink();

    if(self IsOnGround())
        self SetOrigin(self.origin + (0, 0, 5));

    self SetVelocity((450, 450, 850));
    wait 1;

    if(!isDefined(self) || !Is_Alive(self))
        return;

    if(Is_True(self.OnTornado))
        self.OnTornado = BoolVar(self.OnTornado);
}

TornadoLaunchZombie(a, TornadoParts)
{
    if(!isDefined(self) || !IsAlive(self))
        return;
    
    level endon("Tornado_Stop");

    self.OnTornado = true;

    for(b = a; b < TornadoParts.size; b++)
    {
        if(!isDefined(self) || !IsAlive(self))
            break;
        
        if(b % 2 && isDefined(TornadoParts[b]))
        {
            self ForceTeleport(TornadoParts[b].origin);
            self LinkTo(TornadoParts[b]);

            wait 0.025;
        }
    }
    
    if(!isDefined(self) || !IsAlive(self))
        return;

    linker = SpawnScriptModel(self.origin, "tag_origin");
    self LinkTo(linker, "tag_origin");
    linker Launch(AnglesToForward(self.angles) * 3500);
    wait 1;

    if(!isDefined(self) || !IsAlive(self))
        return;

    if(isDefined(linker))
        linker delete();
    
    if(Is_True(self.OnTornado))
        self.OnTornado = BoolVar(self.OnTornado);
}

TornadoLaunchEntity(a, TornadoParts)
{
    if(!isDefined(self))
        return;
    
    self.OnTornado = true;

    for(b = a; b < TornadoParts.size; b++)
    {
        if(!isDefined(self))
            break;
        
        if(b % 2 && isDefined(TornadoParts[b]))
        {
            self.origin = TornadoParts[b].origin;
            self LinkTo(TornadoParts[b]);

            wait 0.025;
        }
    }

    if(!isDefined(self))
        return;

    self Unlink();
    self Launch(AnglesToForward(self.angles) * 5500);
    wait 1;

    if(!isDefined(self))
        return;

    if(Is_True(self.OnTornado))
        self.OnTornado = BoolVar(self.OnTornado);
}

ZombieTeleportGrenades()
{
    self endon("disconnect");
    self endon("EndZombieTeleportGrenades");
    
    self.ZombieTeleportGrenades = BoolVar(self.ZombieTeleportGrenades);

    if(Is_True(self.ZombieTeleportGrenades))
    {
        while(isDefined(self.ZombieTeleportGrenades))
        {
            self waittill("grenade_fire", grenade);

            while(isDefined(grenade))
            {
                origin = grenade.origin;
                wait 0.05;
            }

            PlayFX(level._effect["samantha_steal"], origin);
            PlayFX(level._effect["teleport_splash"], origin);
            PlayFX(level._effect["teleport_aoe"], origin);

            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                zombies[a] forceteleport(origin);
                zombies[a].find_flesh_struct_string = "find_flesh";
                zombies[a].ai_state = "find_flesh";
            }
        }
    }
    else
        self notify("EndZombieTeleportGrenades");
}

ArtilleryStrike()
{
    if(Is_True(self.ArtilleryStrike))
        return;
    self.ArtilleryStrike = true;
    
    self endon("disconnect");

    self closeMenu1();
    wait 0.25;
    
    goalPos = SpawnScriptModel(GetGroundPos(self TraceBullet()), "tag_origin");
    PlayFXOnTag(level._effect["powerup_on"], goalPos, "tag_origin");

    self.DisableMenuControls = true;
    self SetMenuInstructions("[{+attack}] - Confirm Location\n[{+melee}] - Cancel");
    
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

    if(Is_True(self.DisableMenuControls))
        self.DisableMenuControls = BoolVar(self.DisableMenuControls);

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
    
    if(Is_True(self.ArtilleryStrike))
        self.ArtilleryStrike = BoolVar(self.ArtilleryStrike);
}