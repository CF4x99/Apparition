PopulateBulletMenu(menu, player)
{
    switch(menu)
    {
        case "Bullet Menu":
            self addMenu("Bullet Menu");
                self addOpt("Weapon Projectiles", ::newMenu, "Weapon Projectiles");
                self addOpt("Equipment", ::newMenu, "Equipment Bullets");
                self addOpt("Effects", ::newMenu, "Bullet Effects");
                self addOpt("Spawnables", ::newMenu, "Bullet Spawnables");
                self addOpt("Explosive Bullets", ::newMenu, "Explosive Bullets");
                self addOpt("Reset", ::ResetBullet, player);
            break;
        
        case "Weapon Projectiles":
            if(!isDefined(player.ProjectileMultiplier))
                player.ProjectileMultiplier = 1;
            
            if(!isDefined(player.ProjectileSpreadMultiplier))
                player.ProjectileSpreadMultiplier = 10;
            
            self addMenu("Weapon Projectiles");
                self addOpt("Weapon Projectile", ::newMenu, "Weapon Bullets");
                self addOptIncSlider("Projectile Multiplier", ::ProjectileMultiplier, 1, 1, 5, 1, player);
                self addOptIncSlider("Spread Multiplier", ::ProjectileSpreadMultiplier, 1, 5, 50, 1, player);
            break;
        
        case "Weapon Bullets":
            self addMenu("Weapon Bullets");
                self addOpt("Normal", ::newMenu, "Normal Weapon Bullets");
                self addOpt("Upgraded", ::newMenu, "Upgraded Weapon Bullets");
            break;
        
        case "Normal Weapon Bullets":
            arr = [];
            weaps = GetArrayKeys(level.zombie_weapons);
            weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");
            
            self addMenu("Normal Weapons");

                if(isDefined(weaps) && weaps.size)
                {
                    for(a = 0; a < weaps.size; a++)
                    {
                        if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                        {
                            string = weaps[a].name;

                            if(MakeLocalizedString(weaps[a].displayname) != "")
                                string = weaps[a].displayname;
                            
                            if(!IsInArray(arr, string))
                            {
                                arr[arr.size] = string;
                                self addOpt(string, ::BulletProjectile, weaps[a], "Projectile", player);
                            }
                        }
                    }
                }
            break;
        
        case "Upgraded Weapon Bullets":
            arr = [];
            weaps = GetArrayKeys(level.zombie_weapons_upgraded);
            weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");
            
            self addMenu("Upgraded Weapons");
            
                if(isDefined(weaps) && weaps.size)
                {
                    for(a = 0; a < weaps.size; a++)
                    {
                        if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                        {
                            string = weaps[a].name;

                            if(MakeLocalizedString(weaps[a].displayname) != "")
                                string = weaps[a].displayname;
                            
                            if(!IsInArray(arr, string))
                            {
                                arr[arr.size] = string;
                                self addOpt(string, ::BulletProjectile, weaps[a], "Projectile", player);
                            }
                        }
                    }
                }
            break;
        
        case "Equipment Bullets":
            if(isDefined(level.zombie_include_equipment))
                include_equipment = GetArrayKeys(level.zombie_include_equipment);
            
            equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
            keys = GetArrayKeys(equipment);

            self addMenu("Equipment");

                if(isDefined(keys) && keys.size || isDefined(include_equipment) && include_equipment.size)
                {
                    foreach(index, weapon in GetArrayKeys(level.zombie_weapons))
                        if(isInArray(equipment, weapon))
                            self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                    

                    if(isDefined(include_equipment) && include_equipment.size)
                        foreach(weapon in include_equipment)
                            self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                }
            break;
        
        case "Bullet Effects":
            self addMenu("Bullet Effect");

                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOpt(level.MenuEffects[a].displayName, ::BulletProjectile, level.MenuEffects[a].name, "Effect", player);
            break;
        
        case "Bullet Spawnables":
            self addMenu("Bullet Spawnables");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::BulletProjectile, level.MenuModels[a], "Spawnable", player);
            break;
        
        case "Explosive Bullets":
            if(!isDefined(player.ExplosiveBulletsRange))
                player.ExplosiveBulletsRange = 250;
            
            if(!isDefined(player.ExplosiveBulletsDamage))
                player.ExplosiveBulletsDamage = 100;
            
            self addMenu("Explosive Bullets");
                self addOptBool(player.ExplosiveBullets, "Explosive Bullets", ::ExplosiveBullets, player);
                self addOptBool(player.ExplosiveBulletEffect, "Effect", ::ExplosiveBulletEffect, player);
                self addOptIncSlider("Range", ::ExplosiveBulletRange, 25, 250, 500, 25, player);
                self addOptIncSlider("Damage", ::ExplosiveBulletDamage, 25, 100, 500, 25, player);
            break;
    }
}

BulletProjectile(projectile, type, player)
{
    player notify("endProjectile");
    player endon("endProjectile");
    player endon("disconnect");
    
    while(1)
    {
        player waittill("weapon_fired");

        switch(type)
        {
            case "Projectile":
                for(a = 0; a < player.ProjectileMultiplier; a++)
                    MagicBullet(projectile, player GetWeaponMuzzlePoint(), BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + player GetWeaponForwardDir() * 100, 0, undefined)["position"] + (RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier)), player);
                break;
            
            case "Equipment":
                player MagicGrenadeType(projectile, player GetWeaponMuzzlePoint(), VectorScale(VectorNormalize(AnglesToForward(player GetPlayerAngles())), 3000), 1);
                break;
            
            case "Spawnable":
                bspawn = SpawnScriptModel(player TraceBullet(), projectile);

                if(isDefined(bspawn))
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
    if(!Is_True(player.ExplosiveBullets))
    {
        player endon("disconnect");
        player endon("EndExplosiveBullets");

        player.ExplosiveBullets = true;
        
        while(Is_True(player.ExplosiveBullets))
        {
            player waittill("weapon_fired");

            targetPosition = player TraceBullet();

            if(Is_True(player.ExplosiveBulletEffect))
            {
                if(isDefined(level._effect["raps_impact"]))
                    PlayFX(level._effect["raps_impact"], targetPosition);
                else if(isDefined(level._effect["dog_gib"]))
                    PlayFX(level._effect["dog_gib"], targetPosition);
            }

            RadiusDamage(targetPosition, player.ExplosiveBulletsRange, player.ExplosiveBulletsDamage, player.ExplosiveBulletsDamage, player);
        }
    }
    else
    {
        player notify("EndExplosiveBullets");
        player.ExplosiveBullets = false;
    }
}

ExplosiveBulletEffect(player)
{
    player.ExplosiveBulletEffect = !Is_True(player.ExplosiveBulletEffect);
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
    player.ExplosiveBullets = false;
    player notify("EndExplosiveBullets");
}