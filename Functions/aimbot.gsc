Aimbot(player)
{
    player.Aimbot = isDefined(player.Aimbot) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.Aimbot))
    {
        enemy = player GetClosestTarget();

        if(isDefined(player.AimingRequired) && !player AdsButtonPressed() || isDefined(player.Noclip) || isDefined(player.UFOMode) || isDefined(player.ControllableZombie) || isDefined(player.AC130))
            enemy = undefined;

        if(isDefined(enemy) && isDefined(player.AimbotDistanceCheck) && Distance(player.origin, enemy.origin) > player.AimbotDistance)
            enemy = undefined;

        if(isDefined(enemy))
        {
            origin = (player.AimBoneTag == "Best") ? enemy GetTagOrigin(player ScanForBestTag(enemy)) : enemy GetTagOrigin(player.AimBoneTag);

            if(!isDefined(origin)) //Needed for AI that don't have the targeted bone tag(i.e. Spiders)
                origin = enemy GetTagOrigin("tag_body");

            if(isDefined(origin))
            {
                if(isDefined(player.AimSnap))
                    player SetPlayerAngles(VectorToAngles(origin - player GetEye()));

                if(isDefined(player.ShootThruWalls) && (isDefined(player.AutoFire) || player AttackButtonPressed()))
                    MagicBullet(player GetCurrentWeapon(), origin + (5, 0, 0), origin, player);
            }

            if(isDefined(player.AutoFire))
                player FireGun();
        }

        wait 0.01;
    }
}

GetClosestTarget()
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isDefined(self.VisibilityCheck) && zombies[a] DamageConeTrace(self GetEye(), self) < 0.1 || isDefined(self.PlayableAreaCheck) && !zm_behavior::inplayablearea(zombies[a]))
            continue;
        
        if(!isDefined(enemy))
            enemy = zombies[a];
        
        if(isDefined(enemy) && enemy != zombies[a])
        {
            if(!Closer(self.origin, zombies[a].origin, enemy.origin) || isDefined(self.VisibilityCheck) && zombies[a] DamageConeTrace(self GetEye(), self) < 0.1)
                continue;
            
            enemy = zombies[a];
        }
    }

    return enemy;
}

ScanForBestTag(target)
{
    if(!isDefined(target) || !IsAlive(target))
        return;
    
    tags = ["j_ankle_ri", "j_ankle_le", "pelvis", "j_mainroot", "j_spinelower", "j_spine4", "j_neck", "j_head"];
    scanValue = 0;

    for(a = 0; a < tags.size; a++)
    {
        currentScan = target DamageConeTrace(self GetEye(), self);

        if(currentScan >= scanValue)
        {
            scanValue = currentScan;
            tag = tags[a];
        }
    }

    return tag;
}

isFiring1()
{
    return (self isFiring() && !self IsMeleeing());
}

FireGun()
{
    MagicBullet(self GetCurrentWeapon(), self GetWeaponMuzzlePoint(), self TraceBullet(), self);
    wait self GetCurrentWeapon().fireTime;
}

AimBoneTag(tag, player)
{
    player.AimBoneTag = tag;
}

AimbotDistance(distance, player)
{
    player.AimbotDistance = distance;
}

AimbotOptions(a, player)
{
    switch(a)
    {
        case 1:
            player.AimingRequired = isDefined(player.AimingRequired) ? undefined : true;
            break;
        
        case 2:
            player.AimSnap = isDefined(player.AimSnap) ? undefined : true;
            break;
        
        case 3:
            player.ShootThruWalls = isDefined(player.ShootThruWalls) ? undefined : true;
            break;
        
        case 4:
            player.VisibilityCheck = isDefined(player.VisibilityCheck) ? undefined : true;
            break;
        
        case 5:
            player.PlayableAreaCheck = isDefined(player.PlayableAreaCheck) ? undefined : true;
            break;
        
        case 6:
            player.AutoFire = isDefined(player.AutoFire) ? undefined : true;
            break;
        
        case 7:
            player.AimbotDistanceCheck = isDefined(player.AimbotDistanceCheck) ? undefined : true;
            break;
        
        default:
            break;
    }
}