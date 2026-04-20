PopulateBulletMenu(menu, player)
{
    switch(menu)
    {
        case "Bullet Menu":
            self addMenu(menu);
                self addOpt("Projectiles", ::newMenu, "Weapon Projectiles");
                self addOpt("Equipment", ::newMenu, "Equipment Bullets");
                self addOpt("Effects", ::newMenu, "Bullet Effects");
                self addOpt("Spawnables", ::newMenu, "Bullet Spawnables");
                self addOpt("Explosive Bullets", ::newMenu, "Explosive Bullets");
                self addOpt("Reset", ::ResetBullet, player);
            break;
        
        case "Weapon Projectiles":
            if(!IsDefined(player.ProjectileMultiplier))
                player.ProjectileMultiplier = 1;
            
            if(!IsDefined(player.ProjectileSpreadMultiplier))
                player.ProjectileSpreadMultiplier = 1;
            
            self addMenu("Projectiles");
                self addOptIncSlider("Projectile Multiplier", ::ProjectileMultiplier, 1, 1, 5, 1, player);
                self addOptIncSlider("Spread Multiplier", ::ProjectileSpreadMultiplier, 1, 1, 50, 1, player);
                self addOpt("");

                if(IsVerkoMap())
                {
                    for(a = 0; a < level.var_21b77150.size; a++)
                        self addOpt(level.var_7df703ba[a], ::BulletProjectile, GetWeapon(level.var_21b77150[a]), "Projectile", player);
                }
                else
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
                                strng = (MakeLocalizedString(weaps[a].displayname) != "") ? weaps[a].displayname : weaps[a].name;
                                
                                if(!IsInArray(arr, strng))
                                {
                                    arr[arr.size] = strng;
                                    upgrade = zm_weapons::get_upgrade_weapon(weaps[a], 1);

                                    self addOptSlider(strng, ::ProjectileWeaponSelection, !IsDefined(upgrade) ? Array("Base Weapon") : Array("Base Weapon", "Upgraded"), weaps[a], player);
                                }
                            }
                        }
                    }
                }
            break;
        
        case "Equipment Bullets":

            if(IsDefined(level.zombie_include_equipment))
                include_equipment = GetArrayKeys(level.zombie_include_equipment);
            
            equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
            keys = GetArrayKeys(equipment);

            self addMenu("Equipment");

                if(IsDefined(keys) && keys.size || IsDefined(include_equipment) && include_equipment.size)
                {
                    foreach(weapon in GetArrayKeys(level.zombie_weapons))
                    {
                        if(IsSubStr(weapon.name, "shield"))
                            continue;
                        
                        if(isInArray(equipment, weapon))
                            self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                    }
                    

                    if(IsDefined(include_equipment) && include_equipment.size)
                    {
                        foreach(weapon in include_equipment)
                        {
                            if(IsSubStr(weapon.name, "shield"))
                                continue;

                            self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                        }
                    }
                }
            break;
        
        case "Bullet Effects":
            self addMenu("Effects");

                for(a = 0; a < level.menuFX.size; a++)
                    self addOpt(CleanString(level.menuFX[a]), ::BulletProjectile, level.menuFX[a], "Effect", player);
            break;
        
        case "Bullet Spawnables":
            self addMenu("Spawnables");

                if(IsDefined(level.menu_models) && level.menu_models.size)
                {
                    for(a = 0; a < level.menu_models.size; a++)
                        self addOpt(CleanString(level.menu_models[a]), ::BulletProjectile, level.menu_models[a], "Spawnable", player);
                }
            break;
        
        case "Explosive Bullets":
            if(!IsDefined(player.ExplosiveBulletsRange))
                player.ExplosiveBulletsRange = 250;
            
            if(!IsDefined(player.ExplosiveBulletsDamage))
                player.ExplosiveBulletsDamage = 100;
            
            self addMenu(menu);
                self addOptBool(player.ExplosiveBullets, "Explosive Bullets", ::ExplosiveBullets, player);
                self addOptBool(player.ExplosiveBulletEffect, "Effect", ::ExplosiveBulletEffect, player);
                self addOptIncSlider("Range", ::ExplosiveBulletRange, 25, 250, 500, 25, player);
                self addOptIncSlider("Damage", ::ExplosiveBulletDamage, 25, 100, 500, 25, player);
            break;
    }
}

ProjectileWeaponSelection(type, weapon, player)
{
    if(!IsDefined(type) || !IsDefined(weapon))
        return;
    
    if(type == "Upgraded")
    {
        upgrade_weapon = zm_weapons::get_upgrade_weapon(weapon, 1);
        
        if(!IsDefined(upgrade_weapon))
            return;
        
        weapon = upgrade_weapon;
    }
    
    BulletProjectile(weapon, "Projectile", player);
}

BulletProjectile(projectile, type, player)
{
    player notify("endProjectile");
    player endon("endProjectile");
    player endon("disconnect");
    
    while(1)
    {
        player waittill("weapon_fired");

        start = player GetWeaponMuzzlePoint();

        if(!IsDefined(start) || !IsVec(start))
            start = player GetEye();

        switch(type)
        {
            case "Projectile":
                for(a = 0; a < player.ProjectileMultiplier; a++)
                    MagicBullet(projectile, start, BulletTrace(start, start + player GetWeaponForwardDir() * 100, 0, undefined)["position"] + (RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier)), player);
                break;
            
            case "Equipment":
                player MagicGrenadeType(projectile, start, VectorScale(VectorNormalize(AnglesToForward(player GetPlayerAngles())), 3000), 1);
                break;
            
            case "Spawnable":
                bspawn = SpawnScriptModel(player TraceBullet(), projectile);

                if(IsDefined(bspawn))
                {
                    bspawn NotSolid();
                    bspawn thread deleteAfter(5);
                }
                break;
            
            case "Effect":
                PlayFX(level._effect[projectile], player TraceBullet());
                break;
            
            default:
                break;
        }
    }
}

ProjectileMultiplier(multiplier, player)
{
    player.ProjectileMultiplier = multiplier;
}

ProjectileSpreadMultiplier(multiplier, player)
{
    player.ProjectileSpreadMultiplier = multiplier;
}

ExplosiveBullets(player)
{
    player endon("disconnect");
    player endon("EndExplosiveBullets");
    
    player.ExplosiveBullets = BoolVar(player.ExplosiveBullets);

    if(Is_True(player.ExplosiveBullets))
    {
        while(Is_True(player.ExplosiveBullets))
        {
            player waittill("weapon_fired");

            if(Is_True(player.ExplosiveBulletEffect))
            {
                if(IsDefined(level._effect["raps_impact"]))
                    PlayFX(level._effect["raps_impact"], player TraceBullet());
                else if(IsDefined(level._effect["dog_gib"]))
                    PlayFX(level._effect["dog_gib"], player TraceBullet());
            }

            RadiusDamage(player TraceBullet(), player.ExplosiveBulletsRange, player.ExplosiveBulletsDamage, player.ExplosiveBulletsDamage, player);
        }
    }
    else
    {
        player notify("EndExplosiveBullets");
    }
}

ExplosiveBulletEffect(player)
{
    player.ExplosiveBulletEffect = BoolVar(player.ExplosiveBulletEffect);
}

ExplosiveBulletDamage(num, player)
{
    player.ExplosiveBulletsDamage = num;
}

ExplosiveBulletRange(num, player)
{
    player.ExplosiveBulletsRange = num;
}

ResetBullet(player)
{
    player notify("endProjectile");
    player notify("EndExplosiveBullets");

    if(Is_True(player.ExplosiveBullets))
        player.ExplosiveBullets = BoolVar(player.ExplosiveBullets);
}