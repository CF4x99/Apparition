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
    player.ExplosiveBullets = isDefined(player.ExplosiveBullets) ? undefined : true;

    if(isDefined(player.ExplosiveBullets))
    {
        player endon("disconnect");
        player endon("EndExplosiveBullets");
        
        while(isDefined(player.ExplosiveBullets))
        {
            player waittill("weapon_fired");
            
            RadiusDamage(player TraceBullet(), player.ExplosiveBulletsRange, player.ExplosiveBulletsDamage, player.ExplosiveBulletsDamage, player);
        }
    }
    else
        player notify("EndExplosiveBullets");
}

ExplosiveBulletDamage(num, player)
{
    if(!num)
        return self iPrintln("^1ERROR: ^7Explosive Bullet Damage Can't Be Lower Than 1");

    player.ExplosiveBulletsDamage = num;
}

ExplosiveBulletRange(num, player)
{
    if(!num)
        return self iPrintln("^1ERROR: ^7Explosive Bullet Range Can't Be Lower Than 1");
    
    player.ExplosiveBulletsRange = num;
}

ResetBullet(player)
{
    player notify("endProjectile");
    player.ExplosiveBullets = undefined;
    player notify("EndExplosiveBullets");
}