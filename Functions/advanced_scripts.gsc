PopulateAdvancedScripts(menu)
{
    switch(menu)
    {
        case "Advanced Scripts":
            self addMenu(menu);
                self addOpt("Custom Sentry", ::newMenu, "Custom Sentry");
                self addOpt("Artillery Strike", ::ArtilleryStrike);
                self addOpt("Flyable UFO", ::FlyableUFO);
                self addOptSlider("AC-130", ::AC130, Array("Fly", "Walking"));
                self addOptSlider("Controllable Zombie", ::ControllableZombie, Array("Friendly", "Enemy"));
                self addOptBool(self.ZombieTeleportGrenades, "Zombie Teleport Grenades", ::ZombieTeleportGrenades);

                if(ReturnMapName() != "Moon" && ReturnMapName() != "Origins")
                    self addOptBool(level.MoonDoors, "Moon Doors", ::MoonDoors);
                
                self addOptBool(self.BodyGuard, "Body Guard", ::BodyGuard);
            break;
        
        case "Custom Sentry":
            if(!IsDefined(self.CustomSentryWeapon))
                self.CustomSentryWeapon = GetWeapon("minigun");

            self addMenu(menu);
                self addOptBool(self.CustomSentry, "Custom Sentry", ::CustomSentry);
                self addOpt("");
                self addOptBool((self.CustomSentryWeapon == GetWeapon("minigun")), "Death Machine", ::SetCustomSentryWeapon, GetWeapon("minigun"));

                if(!IsVerkoMap())
                {
                    arr = [];
                    weaps = GetArrayKeys(level.zombie_weapons);
                    weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");

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

CustomSentry(origin)
{
    self endon("disconnect");

    self.CustomSentry = BoolVar(self.CustomSentry);

    if(Is_True(self.CustomSentry))
    {
        if(!IsDefined(origin))
            origin = self.origin;

        self.CustomSentryOrigin = origin;
        
        sentrygun = self.CustomSentryWeapon;
        self.sentrygun_weapon = zm_utility::spawn_weapon_model(sentrygun, undefined, origin, (0, self GetPlayerAngles()[1], 0));
        self.sentrygun_weapon.owner = self;

        self.sentrygun_weapon clientfield::set("zm_aat_fire_works", 1);
        self.sentrygun_weapon MoveTo(origin + (0, 0, 56), 0.5);
        self.sentrygun_weapon waittill("movedone");
        
        while(Is_True(self.CustomSentry))
        {
            zombie = self.sentrygun_weapon CustomSentryGetTarget();
            v_target_pos = !IsDefined(zombie) ? (self.sentrygun_weapon.origin + VectorScale(AnglesToForward((0, RandomIntRange(0, 360), 0)), 40)) : zombie GetTagOrigin("j_head");

            if(IsDefined(zombie) && !IsDefined(v_target_pos))
                v_target_pos = zombie GetTagOrigin("tag_body");
            
            if(IsDefined(v_target_pos) && IsVec(v_target_pos))
            {
                self.sentrygun_weapon.angles = VectorToAngles(v_target_pos - self.sentrygun_weapon.origin);
                self.sentrygun_weapon DontInterpolate();

                if(IsDefined(zombie))
                    MagicBullet(sentrygun, self.sentrygun_weapon GetTagOrigin("tag_flash"), v_target_pos, self.sentrygun_weapon);
            }

            util::wait_network_frame();
        }
    }
    else
    {
        if(IsDefined(self.sentrygun_weapon))
        {
            self.sentrygun_weapon clientfield::set("zm_aat_fire_works", 0);
            wait 0.01;

            self.sentrygun_weapon Delete();
        }
    }
}

CustomSentryGetTarget()
{
    zombies = GetAITeamArray(level.zombie_team);

    if(!IsDefined(zombies) || !zombies.size)
        return;

    enemy = undefined;
    
    for(a = 0; a < zombies.size; a++)
    {
        if(!IsDefined(zombies[a]) || !IsAlive(zombies[a]) || zombies[a] DamageConeTrace(self.origin, self) < 0.1)
            continue;
        
        if(zombies[a].archetype == "zombie" && !Is_True(zombies[a].zombie_think_done) || zombies[a].archetype != "zombie" && Is_True(zombies[a].ignoreme))
            continue;
        
        if(!IsDefined(enemy))
            enemy = zombies[a];
        
        if(enemy == zombies[a])
            continue;
        
        if(Closer(self.origin, zombies[a].origin, enemy.origin))
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
    {
        for(a = 0; a < 2; a++)
            self CustomSentry(self.CustomSentryOrigin);
    }
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
    CZSavedAngles = self GetPlayerAngles();

    zombie = self ServerSpawnZombie(self.origin);
    self SetStance("stand");
    wait 0.1;
    
    if(IsDefined(zombie))
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

        while(!CanControl(zombie) && IsAlive(zombie))
        {
            if(self MeleeButtonPressed())
                zombie DoDamage(zombie.health + 666, zombie GetTagOrigin("j_head"));
            
            wait 0.1;
        }
        
        goalPos = SpawnScriptModel(GetGroundPos(self TraceBullet()), "tag_origin");
        PlayFXOnTag(level._effect["powerup_on"], goalPos, "tag_origin");
        
        goalPos SetInvisibleToAll();
        goalPos SetVisibleToPlayer(self);
        
        while(IsDefined(zombie) && IsAlive(zombie))
        {
            zombie.ignore_find_flesh = 1;
            zombie.ignoreme = 1;
            goalPos.origin = self TraceBullet();
            
            if(CanControl(zombie))
            {
                if(Distance(zombie.origin, goalPos.origin) >= 100)
                {
                    zombie SetGoal(goalPos.origin, true);

                    if(IsDefined(zombie.zombie_move_speed) && zombie.zombie_move_speed != "sprint")
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
    {
        self iPrintlnBold("^1ERROR: ^7Couldn't Spawn Zombie");
    }
    
    wait 0.1;

    if(!Is_True(self.Invisibility))
        self Show();
    
    self Unlink();
    self FreezeControlsAllowLook(false);
    self EnableWeapons();
    self EnableOffhandWeapons();

    if(IsDefined(viewModel))
        viewModel Delete();
    
    if(IsDefined(goalPos))
        goalPos Delete();
    
    self SetOrigin(CZSavedOrigin);
    self SetPlayerAngles(CZSavedAngles);

    if(Is_True(self.DisableMenuControls))
        self.DisableMenuControls = BoolVar(self.DisableMenuControls);

    if(Is_True(self.ControllableZombie))
        self.ControllableZombie = BoolVar(self.ControllableZombie);

    if(Is_True(self.ignoreme))
        self.ignoreme = false;
}

ZombieAttack()
{
    self endon("death");
    
    v_angles = self.angles;

    if(IsDefined(self.attacking_point))
    {
        v_angles = (self.attacking_point.v_center_pillar - self.origin);
        v_angles = VectorToAngles((v_angles[0], v_angles[1], 0));
    }
    
    animation = "ai_zombie_base_ad_attack_v1";
    self AnimScripted("attack_anim", self.origin, v_angles, animation);
    
    wait GetAnimLength(animation);
}

AC130(type)
{
    if(Is_True(self.AC130))
        return;
    self.AC130 = true;

    self endon("disconnect");

    if(Is_True(self.ThirdPerson))
    {
        self.ThirdPerson = undefined;
        self SetClientThirdPerson(0);
    }

    self closeMenu1();
    self.DisableMenuControls = true;
    
    if(type == "Fly")
    {
        ACSavedOrigin = self.origin;
        ACSavedAngles = self GetPlayerAngles();
        SetAngles = VectorToAngles(ACSavedOrigin - self GetEye());
        
        linker = SpawnScriptModel(ACSavedOrigin, "tag_origin", (0, SetAngles[1], 0));
        c130 = SpawnScriptModel(((linker.origin + (AnglesToRight(linker.angles) * 1800)) + (0, 0, ((self.StartOrigin[2] + 1500) - linker.origin[2]))), "tag_origin");

        if(!IsDefined(linker) || !IsDefined(c130))
        {
            if(IsDefined(linker))
                linker Delete();
            
            if(IsDefined(c130))
                c130 Delete();
            
            self.AC130 = undefined;
            self.DisableMenuControls = undefined;
            return;
        }
        
        c130.angles = VectorToAngles(linker.origin - c130.origin);
        c130 LinkTo(linker);
        linker thread AC130Rotate();

        self SetStance("stand");
        self AllowCrouch(false);
        self SetOrigin(c130.origin);
        self PlayerLinkToDelta(c130, "tag_origin", 0, 50, 50, 15, 15);
        self Hide();
    }

    if(!IsDefined(self.AC130DisableFire))
        self.AC130DisableFire = [];

    ammoType = GetWeapon("minigun");
    ammoTime = 0.01;

    self RefreshAC130HUD(ammoType);
    self DisableWeapons(true);
    self DisableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 0);
    
    while(1)
    {
        if(type == "Fly")
        {
            if(self GetStance() != "stand")
                self SetStance("stand");
        }

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
            if(!IsDefined(self.AC130Reloading))
            {
                self.AC130Reloading = self createText("objective", 1.4, 1, "RELOADING...", "CENTER", 320, 340, 1, (1, 1, 1));
                self.AC130Reloading thread AC130FlashingHud();
            }
        }
        else
        {
            if(IsDefined(self.AC130Reloading))
                self.AC130Reloading DestroyHud();
        }

        wait 0.01;
    }
    
    if(IsDefined(self.AC130HUD))
        destroyAll(self.AC130HUD);
    
    if(IsDefined(self.AC130Reloading))
        self.AC130Reloading DestroyHud();
    
    self EnableWeapons();
    self EnableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 1);

    if(type == "Fly")
    {
        if(IsDefined(linker))
            linker Delete();
        
        if(IsDefined(c130))
            c130 Delete();

        self AllowCrouch(true);

        if(IsDefined(ACSavedOrigin) && IsVec(ACSavedOrigin))
            self SetOrigin(ACSavedOrigin);
        
        if(IsDefined(ACSavedAngles) && IsVec(ACSavedAngles))
            self SetPlayerAngles(ACSavedAngles);

        if(!Is_True(self.Invisibility))
            self Show();
    }

    self.DisableMenuControls = undefined;
    self.AC130 = undefined;
}

AC130FlashingHud()
{
    if(!IsDefined(self))
        return;
    
    self endon("death");

    while(IsDefined(self))
    {
        self hudFade(0.2, 0.35);

        if(IsDefined(self))
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

    if(!IsDefined(self.AC130DisableFire))
        self.AC130DisableFire = [];
    
    self.AC130DisableFire[ammoType] = true;

    fire_origin = self GetTagOrigin("j_neck") + (AnglesToForward(self GetPlayerAngles()) * 5) + (AnglesToRight(self GetPlayerAngles()) * -5);
    weapon40MM = IsVerkoMap() ? GetWeapon("vk_tra_pis_t9_1911_rdw_lvl3") : zm_weapons::get_upgrade_weapon(level.start_weapon);

    if(ammoType == GetWeapon("hunter_rocket_turret_player"))
    {
        for(a = 0; a < 6; a++)
            MagicBullet(ammoType, fire_origin, BulletTrace(fire_origin, fire_origin + self GetWeaponForwardDir() * 100, 0, undefined)["position"] + (Cos(a * 60) * 3, Sin(a * 60) * 3, 0), self);
    }
    else
    {
        MagicBullet((ReturnMapName() == "Origins" && ammoType == weapon40MM) ? GetWeapon("hunter_rocket_turret_player") : ammoType, fire_origin, self TraceBullet(), self);
    }
    
    wait AC130FireRate(ammoType);

    if(Is_True(self.AC130DisableFire[ammoType]))
        self.AC130DisableFire[ammoType] = BoolVar(self.AC130DisableFire[ammoType]);
}

AC130Rotate()
{
    if(!IsDefined(self))
        return;
    
    while(IsDefined(self))
    {
        self RotateYaw(360, 50);
        wait 49.9;
    }
}

RefreshAC130HUD(ammo)
{
    if(IsDefined(self.AC130HUD))
        destroyAll(self.AC130HUD);

    self.AC130HUD = [];

    weapon40MM = IsVerkoMap() ? GetWeapon("vk_tra_pis_t9_1911_rdw_lvl3") : zm_weapons::get_upgrade_weapon(level.start_weapon);
    AC130HudValues = (ammo == GetWeapon("minigun")) ? Array("320,290,2,80", "360,240,60,2", "280,240,60,2", "140,391,2,50", "165,415,50,2", "500,391,2,50", "475,415,50,2", "500,89,2,50", "475,65,50,2", "140,89,2,50", "165,65,50,2") : (ammo == weapon40MM) ? Array("320,320,2,120", "320,160,2,120", "320,194,10,1", "320,148,10,1", "320,100,14,1", "320,286,10,1", "320,332,10,1", "320,380,14,1", "405,240,130,2", "235,240,130,2", "357,240,1,10", "395,240,1,10", "432,240,1,10", "470,240,1,14", "283,240,1,10", "245,240,1,10", "208,240,1,10", "170,240,1,14") : Array("320,265,51,2", "320,215,51,2", "345,240,2,51", "295,240,2,52", "320,290,2,51", "320,190,2,51", "370,240,51,2", "270,240,51,2", "545,401,2,30", "530,415,30,2", "95,401,2,30", "110,415,30,2", "95,79,2,30", "110,65,30,2", "545,79,2,30", "530,65,30,2");
    text = (ammo == GetWeapon("minigun")) ? "25mm" : (ammo == weapon40MM) ? "40mm" : "105mm";

    for(a = 0; a < AC130HudValues.size; a++)
        self.AC130HUD[self.AC130HUD.size] = self createRectangle("CENTER", Int(StrTok(AC130HudValues[a], ",")[0]), Int(StrTok(AC130HudValues[a], ",")[1]), Int(StrTok(AC130HudValues[a], ",")[2]), Int(StrTok(AC130HudValues[a], ",")[3]), (1, 1, 1), 1, 1, "white");
    
    button = self GamepadUsedLast() ? "[{+weapnext_inventory}]" : "[{+activate}]";
    self.AC130HUD[self.AC130HUD.size] = self createText("objective", 1.2, 1, text + "\n^3" + button + " ^7To Change Weapon", "LEFT", -80, 240, 1, (1, 1, 1));
}

FlyableUFO()
{
    if(Is_True(self.FlyableUFO))
        return;
    self.FlyableUFO = true;

    self endon("disconnect");

    if(Is_True(self.ThirdPerson))
    {
        self.ThirdPerson = undefined;
        self SetClientThirdPerson(0);
    }

    self closeMenu1();
    self.DisableMenuControls = true;

    savedOrigin = self.origin;
    savedAngles = self GetPlayerAngles();

    base = [];
    base[0] = SpawnScriptModel(savedOrigin + (0, 0, 1500), "test_sphere_silver");

    if(IsDefined(base[0]))
    {
        base[0] SetScale(4);
        playerLinker = SpawnScriptModel(base[0].origin, "tag_origin");
    }

    if(!IsDefined(base[0]) || !IsDefined(playerLinker))
    {
        self.FlyableUFO = undefined;
        self.DisableMenuControls = undefined;
        return self iPrintlnBold("^1ERROR: ^7Unable To Spawn Flyable UFO");
    }

    model = GetSpawnableBaseModel("vending_three_gun");

    for(a = 0; a < 10; a++)
    {
        base[base.size] = SpawnScriptModel(base[0].origin - (0, 0, 8), model, (0, a * 36, 90), 0.01);

        if(IsDefined(base[(base.size - 1)]))
        {
            base[(base.size - 1)] LinkTo(base[0]);
            base[(base.size - 1)] NotSolid();
            base[(base.size - 1)] SetScale(0.5);
        }
    }

    base[0] thread UFOSpin();
    
    self DisableWeapons(true);
    self DisableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 0);
    self SetStance("stand");
    self Hide();

    self PlayerLinkTo(playerLinker, "tag_origin");
    hud = self createWaypoint(self TraceBullet());
    self SetMenuInstructions(Array("[{+attack}] - Fire Orb", "[{+speed_throw}] - Move Forward", "[{+frag}] - Move Up", "[{+smoke}] - Move Down", "[{+melee}] - Exit"));
    
    while(1)
    {
        if(!IsDefined(base[0]) || !IsDefined(playerLinker))
            break;
        
        if(self GetStance() != "stand")
            self SetStance("stand");

        self.ignoreme = true;

        if(IsDefined(hud))
        {
            pos = BulletTrace(base[0].origin, base[0].origin + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, base[0])["position"];

            hud.x = pos[0];
            hud.y = pos[1];
            hud.z = pos[2];
        }

        playerLinker.angles = (playerLinker.angles[0], self GetPlayerAngles()[1], playerLinker.angles[2]);

        if(self AttackButtonPressed())
            self thread UFOShoot((base[0].origin + (AnglesToUp(base[0].angles) * -10)), base[0].origin, 350, 0.35, true, base[0]);

        if(self AdsButtonPressed())
            playerLinker.origin = playerLinker.origin + AnglesToForward(playerLinker.angles) * 25;

        if(self FragButtonPressed())
            playerLinker.origin = playerLinker.origin + AnglesToUp(playerLinker.angles) * 25;
        else if(self SecondaryOffhandButtonPressed())
            playerLinker.origin = playerLinker.origin - AnglesToUp(playerLinker.angles) * 25;
        
        if(self MeleeButtonPressed())
            break;
        
        base[0].origin = (self.origin + (AnglesToForward(playerLinker.angles) * 75) + (AnglesToUp(playerLinker.angles) * -25));

        wait 0.01;
    }

    if(!Is_True(self.Invisibility))
        self Show();

    if(IsDefined(base) && base.size)
    {
        for(a = 0; a < base.size; a++)
        {
            if(IsDefined(base[a]))
                base[a] Delete();
        }
    }
    
    if(IsDefined(playerLinker))
        playerLinker Delete();
    
    if(IsDefined(hud))
        hud Destroy();
    
    if(IsDefined(savedOrigin))
        self SetOrigin(savedOrigin);
    
    if(IsDefined(savedAngles))
        self SetPlayerAngles(savedAngles);

    if(!Is_True(self.playerIgnoreMe))
        self.ignoreme = false;
    
    if(Is_True(self.UFOShoot))
        self.UFOShoot = undefined;

    self EnableWeapons();
    self EnableOffhandWeapons();
    self SetClientUIVisibilityFlag("hud_visible", 1);
    self AllowCrouch(true);

    self.FlyableUFO = undefined;
    self.DisableMenuControls = undefined;
    self SetMenuInstructions();
}

UFOSpin()
{
    if(!IsDefined(self))
        return;
    
    self endon("death");

    while(IsDefined(self))
    {
        self RotateYaw(360, 1);
        wait 1;
    }
}

UFOShoot(startOrigin, endOrigin, range = 350, moveTime = 0.35, runTrace = false, ignoreEnt)
{
    if(Is_True(self.UFOShoot) || !IsDefined(startOrigin) || !IsVec(startOrigin) || !IsDefined(endOrigin) || !IsVec(endOrigin))
        return;
    
    if(Is_True(runTrace))
    {
        if(!IsDefined(ignoreEnt) || !IsEntity(ignoreEnt))
            ignoreEnt = self;

        trace = BulletTrace(endOrigin, endOrigin + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, ignoreEnt);
        surface = trace["surfacetype"];
        endOrigin = trace["position"];

        if(surface == "none" || surface == "default")
            return;
    }

    self.UFOShoot = true;

    self endon("disconnect");
    
    bullet = SpawnScriptModel(startOrigin, "tag_origin");

    if(IsDefined(bullet))
    {
        bullet clientfield::set("powerup_fx", Int(Pow(2, RandomInt(3))));

        if(IsDefined(level._effect["tesla_bolt"]))
            PlayFXOnTag(level._effect["tesla_bolt"], bullet, "tag_origin");

        time = moveTime;
        bullet MoveTo(endOrigin, time);
        wait (time / 2);

        self.UFOShoot = undefined;
        wait (time / 2);
        
        if(IsDefined(bullet))
            bullet Delete();
        
        Earthquake(0.75, 2, endOrigin, 255);
        RadiusDamage(endOrigin, range, 696969, 696969, self);

        if(IsDefined(level._effect["raps_impact"]))
            PlayFX(level._effect["raps_impact"], endOrigin);
        else if(IsDefined(level._effect["dog_gib"]))
            PlayFX(level._effect["dog_gib"], endOrigin);
    }
    else
    {
        self.UFOShoot = undefined;
    }
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
    {
        thread OpenCloseMoonDoors();
    }
    else
    {
        types = Array("zombie_door", "zombie_airlock_buy", "zombie_debris");
        script_strings = Array("rotate", "slide_apart", "move");

        for(a = 0; a < types.size; a++)
        {
            doors = GetEntArray(types[a], "targetname");

            if(!IsDefined(doors))
                continue;

            for(b = 0; b < doors.size; b++)
            {
                if(!IsDefined(doors[b]) || doors[b] IsDoorOpen(types[a]))
                    continue;
                
                for(c = 0; c < doors[b].doors.size; c++)
                {
                    if(IsDefined(doors[b].doors[c]) && isInArray(script_strings, doors[b].doors[c].script_string))
                        doors[b].doors[c] thread SetMoonDoorState(doors[b], true);
                }
            }
        }
    }

    if(IsDefined(menu) && IsDefined(curs))
        self RefreshMenu(menu, curs);
}

OpenCloseMoonDoors()
{
    types = Array("zombie_door", "zombie_airlock_buy", "zombie_debris");
    script_strings = Array("rotate", "slide_apart", "move");

    while(Is_True(level.MoonDoors))
    {
        for(a = 0; a < types.size; a++)
        {
            doors = GetEntArray(types[a], "targetname");

            if(!IsDefined(doors))
                continue;

            for(b = 0; b < doors.size; b++)
            {
                if(!IsDefined(doors[b]))
                    continue;
                
                if(AnyoneNearDoor(doors[b]) && !doors[b] IsDoorOpen(types[a]))
                {
                    for(c = 0; c < doors[b].doors.size; c++)
                    {
                        if(IsDefined(doors[b].doors[c]) && isInArray(script_strings, doors[b].doors[c].script_string))
                            doors[b].doors[c] thread SetMoonDoorState(doors[b], true);
                    }
                }
                else if(!AnyoneNearDoor(doors[b]) && doors[b] IsDoorOpen(types[a]))
                {
                    for(c = 0; c < doors[b].doors.size; c++)
                    {
                        if(IsDefined(doors[b].doors[c]) && isInArray(script_strings, doors[b].doors[c].script_string))
                            doors[b].doors[c] thread SetMoonDoorState(doors[b], false);
                    }
                }
            }
        }

        wait 0.01;
    }
}

SetMoonDoorState(door, open)
{
    time = IsDefined(self.script_transition_time) ? self.script_transition_time : 1;
    scale = open ? 1 : -1;
    door.has_been_opened = open;
    
    switch(self.script_string)
    {
        case "rotate":
            angles = open ? self.script_angles : self.savedAngles;

            if(IsDefined(angles))
            {
                self RotateTo(angles, time, 0, 0);
                self thread zm_blockers::door_solid_thread();

                wait time;
            }
            break;
        
        case "slide_apart":
            if(IsDefined(self.script_vector))
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
            if(IsDefined(self.script_vector))
            {
                goalOrigin = open ? (self.origin + VectorScale(self.script_vector, scale)) : self.savedOrigin;
                
                if(IsDefined(goalOrigin))
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
    {
        if(IsDefined(ai) && IsAlive(ai) && Distance(ai.origin, door.origin) <= 255)
            return true;
    }

    foreach(player in level.players)
    {
        if(IsDefined(player) && Is_Alive(player) && Distance(player.origin, door.origin) <= 255)
            return true;
    }

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
        self.BodyGuardZombie = self ServerSpawnZombie(self.origin);
        wait 0.1;
        
        if(Is_True(self.BodyGuard) && IsDefined(self.BodyGuardZombie) && IsAlive(self.BodyGuardZombie))
        {            
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

                if(!IsDefined(target))
                    target = self.BodyGuardZombie GetBodyGuardTarget(self.BodyGuardZombie); //Attempt to find a target that is near the body guard, if there isn't one near the player
                
                if(!IsDefined(target))
                {
                    self.BodyGuardZombie ClearForcedGoal();

                    goalPos = (self.origin + VectorScale(AnglesToForward(self GetPlayerAngles()), 100));
                    speed = (Distance(goalPos, self.BodyGuardZombie.origin) > 200) ? "super_sprint" : "walk";

                    if(IsDefined(self.BodyGuardZombie.zombie_move_speed) && self.BodyGuardZombie.zombie_move_speed != speed)
                        self.BodyGuardZombie thread zombie_utility::set_zombie_run_cycle(speed);

                    self.BodyGuardZombie SetGoal(goalPos, true, 255);
                }
                else
                {
                    if(IsDefined(self.BodyGuardZombie.zombie_move_speed) && self.BodyGuardZombie.zombie_move_speed != "super_sprint")
                        self.BodyGuardZombie thread zombie_utility::set_zombie_run_cycle("super_sprint");

                    self.BodyGuardZombie SetGoal(target.origin, true);
                }
                
                wait 0.01;
            }
        }
    }
    else
    {
        if(IsDefined(self.BodyGuardZombie))
        {
            self.BodyGuardZombie thread clientfield::set("zm_aat_turned", 0);

            self.BodyGuardZombie.no_gib = 0;
            self.BodyGuardZombie.allowdeath = 1;
            self.BodyGuardZombie.allowpain = 1;
            
            self.BodyGuardZombie DoDamage(self.BodyGuardZombie.health + 666, self.BodyGuardZombie GetTagOrigin("j_head"));
        }

        if(IsDefined(self.BodyGuardZombieLinker))
            self.BodyGuardZombieLinker Delete();
    }
}

GetBodyGuardTarget(player)
{
    zombie = undefined;
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!IsDefined(zombies[a]) || !IsAlive(zombies[a]) || zombies[a] == self || !zm_behavior::inplayablearea(zombies[a]))
            continue;
        
        if(Distance(player.origin, zombies[a].origin) > 500 || !player DamageConeTrace(zombies[a] GetCentroid()) || IsDefined(zombie) && Distance(player.origin, zombies[a].origin) > Distance(player.origin, zombie.origin))
            continue;
        
        zombie = zombies[a];
    }

    return zombie;
}

ZombieTeleportGrenades()
{
    self endon("disconnect");
    self endon("EndZombieTeleportGrenades");
    
    self.ZombieTeleportGrenades = BoolVar(self.ZombieTeleportGrenades);

    if(Is_True(self.ZombieTeleportGrenades))
    {
        while(IsDefined(self.ZombieTeleportGrenades))
        {
            self waittill("grenade_fire", grenade);

            while(IsDefined(grenade))
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
                zombies[a] ForceTeleport(origin);
                zombies[a].find_flesh_struct_string = "find_flesh";
                zombies[a].ai_state = "find_flesh";
            }
        }
    }
    else
    {
        self notify("EndZombieTeleportGrenades");
    }
}

ArtilleryStrike()
{
    if(Is_True(self.ArtilleryStrike))
        return;
    self.ArtilleryStrike = true;
    
    self endon("disconnect");

    self closeMenu1();
    wait 0.25;

    self.DisableMenuControls = true;
    self SetMenuInstructions(Array("[{+attack}] - Confirm Location", "[{+melee}] - Cancel"));
    hud = createWaypoint(self TraceBullet());
    
    while(1)
    {
        trace = BulletTrace(self GetEye(), self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
        origin = trace["position"];
        surface = trace["surfacetype"];

        if(IsDefined(hud))
        {
            hud.x = origin[0];
            hud.y = origin[1];
            hud.z = origin[2];
        }

        if(self UseButtonPressed() || self AttackButtonPressed())
        {
            if(surface != "none" && surface != "default")
            {
                targetPos = origin;
                break;
            }
            else
            {
                self iPrintlnBold("^1ERROR: ^7Invalid Surface");
            }
        }
        
        if(self MeleeButtonPressed())
            break;

        wait 0.01;
    }
    
    if(IsDefined(hud))
        hud Destroy();

    if(Is_True(self.DisableMenuControls))
        self.DisableMenuControls = BoolVar(self.DisableMenuControls);

    self SetMenuInstructions();
    
    if(IsDefined(targetPos))
    {
        targetPos = targetPos + (0, 0, 3500);

        for(a = -1; a < 2; a += 2)
        {
            for(b = 0; b < 5; b++)
            {
                MagicBullet(GetWeapon("launcher_standard"), targetPos, targetPos - (0, b * (a * 25), 2500));
                wait 0.25;
            }
        }

        for(a = -1; a < 2; a += 2)
        {
            for(b = 0; b < 5; b++)
            {
                MagicBullet(GetWeapon("launcher_standard"), targetPos, targetPos - (b * (a * 25), 0, 2500));
                wait 0.25;
            }
        }
    }
    
    if(Is_True(self.ArtilleryStrike))
        self.ArtilleryStrike = BoolVar(self.ArtilleryStrike);
}