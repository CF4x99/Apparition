Aimbot(player)
{
    player.Aimbot = isDefined(player.Aimbot) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.Aimbot))
    {
        enemy = player GetClosestTarget();

        if(isDefined(player.Noclip) || isDefined(player.UFOMode) || isDefined(player.ControllableZombie) || isDefined(player.AC130))
            enemy = undefined;

        if(isDefined(enemy) && isDefined(player.AimbotDistanceCheck) && Distance(player.origin, enemy.origin) > player.AimbotDistance)
            enemy = undefined;
        
        if(isDefined(enemy) && isDefined(player.PlayableAreaCheck) && !zm_behavior::inplayablearea(enemy))
            enemy = undefined;
        
        if(isDefined(enemy) && player.AimbotVisibilityRequirement != "None")
        {
            if(player.AimbotVisibilityRequirement == "Damageable" && enemy DamageConeTrace(player GetEye(), player) < 0.1)
                enemy = undefined;
            
            if(player.AimbotVisibilityRequirement == "Visible" && !player IsVisible(enemy))
                enemy = undefined;
        }
        
        if(player.AimbotKey == "Aiming" && !player AdsButtonPressed() || player.AimbotKey == "Firing" && !player isFiring1())
            enemy = undefined;

        if(isDefined(enemy))
        {
            origin = enemy GetTagOrigin(player.AimBoneTag);

            if(!isDefined(origin)) //If the tag origin for the target tag can't be found, this will test the given tags to see if one can be used
            {
                tags = ["j_ankle_ri", "j_ankle_le", "pelvis", "j_mainroot", "j_spinelower", "j_spine4", "j_neck", "j_head", "tag_body"];

                for(a = 0; a < tags.size; a++)
                {
                    test = enemy GetTagOrigin(tags[a]);

                    if(isDefined(test))
                        origin = enemy GetTagOrigin(tags[a]);
                }
            }

            if(isDefined(origin))
            {
                if(player.AimbotType == "Snap")
                {
                    player SetPlayerAngles(VectorToAngles(origin - player GetEye()));

                    if(isDefined(player.AutoFire))
                        player FireGun();
                }
                else if(player.AimbotType == "Smooth Snap")
                {
                    if(!isDefined(player.smoothTarget) || player.smoothTarget != enemy)
                    {
                        player.smoothTarget = enemy;
                        player.snapsRemaining = player.SmoothSnaps;
                        player.snapAngles = VectorToAngles(origin - player GetEye());
                    }

                    if(player.snapsRemaining)
                    {
                        viewAngles = player GetPlayerAngles();
                        
                        smoothangles = (AngleNormalize180(player.snapAngles[0] - viewAngles[0]), AngleNormalize180(player.snapAngles[1] - viewAngles[1]), 0);
                        smoothangles /= player.snapsRemaining;

                        player SetPlayerAngles((AngleNormalize180(viewAngles[0] + smoothangles[0]), AngleNormalize180(viewAngles[1] + smoothangles[1]), 0));
                        player.snapsRemaining--;
                    }
                    else
                        player SetPlayerAngles(VectorToAngles(origin - player GetEye())); //After it has finished the smooth snap to the target, it will stay locked on

                    if(isDefined(player.AutoFire) && player.snapsRemaining <= 1)
                        player FireGun();
                }
                else if(player.AimbotType == "Silent")
                {
                    if(isDefined(player.AutoFire) || player AttackButtonPressed())
                        MagicBullet(player GetCurrentWeapon(), origin + (5, 0, 0), origin, player);
                }
            }
            else
            {
                if(isDefined(player.smoothTarget))
                {
                    player.smoothTarget = undefined;
                    player.snapsRemaining = undefined;
                    player.snapAngles = undefined;
                }
            }
        }
        else
        {
            if(isDefined(player.smoothTarget))
            {
                player.smoothTarget = undefined;
                player.snapsRemaining = undefined;
                player.snapAngles = undefined;
            }
        }

        wait 0.01;
    }
}

SetSmoothSnaps(snaps, player)
{
    player.SmoothSnaps = snaps;
}

GetClosestTarget()
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isDefined(self.AimbotDistanceCheck) && Distance(self.origin, zombies[a].origin) > self.AimbotDistance || self.AimbotVisibilityRequirement == "Damageable" && zombies[a] DamageConeTrace(self GetEye(), self) < 0.1 || self.AimbotVisibilityRequirement == "Visible" && !self IsVisible(zombies[a]) || isDefined(self.PlayableAreaCheck) && !zm_behavior::inplayablearea(zombies[a]))
            continue;
        
        if(!isDefined(enemy))
            enemy = zombies[a];
        
        if(isDefined(enemy) && enemy != zombies[a])
        {
            if(!Closer(self.origin, zombies[a].origin, enemy.origin) || self.AimbotVisibilityRequirement == "Damageable" && zombies[a] DamageConeTrace(self GetEye(), self) < 0.1 || self.AimbotVisibilityRequirement == "Visible" && !self IsVisible(zombies[a]) || isDefined(self.AimbotDistanceCheck) && Distance(self.origin, zombies[a].origin) > self.AimbotDistance)
                continue;
            
            enemy = zombies[a];
        }
    }

    return enemy;
}

IsVisible(enemy)
{
    if(VectorDot(AnglesToForward(self GetTagAngles("tag_weapon_right")), VectorNormalize(enemy GetEye() - self GetWeaponMuzzlePoint())) > Cos(40) && BulletTracePassed(self GetEye(), enemy GetEye(), false, self))
        return true;
    
    return false;
}

isFiring1()
{
    return (self isFiring() && !self IsMeleeing());
}

FireGun()
{
    self endon("disconnect");
    
    if(self GetCurrentWeapon().name == "none" || !self GetWeaponAmmoClip(self GetCurrentWeapon()) || self IsReloading() || self isOnLadder() || self IsMantling() || self IsSwitchingWeapons() || self IsMeleeing() || self IsSprinting())
        return;
    
    MagicBullet(self GetCurrentWeapon(), self GetWeaponMuzzlePoint(), self TraceBullet(), self);
    self SetWeaponAmmoClip(self GetCurrentWeapon(), (self GetWeaponAmmoClip(self GetCurrentWeapon()) - 1));
    self WeaponPlayEjectBrass();

    wait (self GetCurrentWeapon().fireTime / 2);
}

AimbotType(type, player)
{
    player.AimbotType = type;
}

AimBoneTag(tag, player)
{
    player.AimBoneTag = tag;
}

AimbotKey(key, player)
{
    player.AimbotKey = key;
}

AimbotVisibilityRequirement(requirement, player)
{
    player.AimbotVisibilityRequirement = requirement;
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
            player.PlayableAreaCheck = isDefined(player.PlayableAreaCheck) ? undefined : true;
            break;
        
        case 2:
            player.AutoFire = isDefined(player.AutoFire) ? undefined : true;
            break;
        
        case 3:
            player.AimbotDistanceCheck = isDefined(player.AimbotDistanceCheck) ? undefined : true;
            break;
        
        default:
            break;
    }
}