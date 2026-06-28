PopulateAimbotMenu(menu, player)
{
    switch(menu)
    {
        case "Aimbot Menu":
            if(!IsDefined(player.AimbotType))
                player.AimbotType = "Snap";
            
            if(!IsDefined(player.AimBoneTag))
                player.AimBoneTag = "j_head";
            
            if(!IsDefined(player.AimbotKey))
                player.AimbotKey = "None";
            
            if(!IsDefined(player.AimbotVisibilityRequirement))
                player.AimbotVisibilityRequirement = "None";
            
            if(!IsDefined(player.AimbotDistance))
                player.AimbotDistance = 100;
            
            if(!IsDefined(player.SmoothSnaps))
                player.SmoothSnaps = 5;
            
            self addMenu(menu);
                self addOptBool(player.Aimbot, "Aimbot", ::Aimbot, player);
                self addOptSlider("Type", ::AimbotType, Array("Snap", "Smooth Snap", "Silent"), player);
                self addOptSlider("Tag", ::AimBoneTag, Array("j_head", "j_neck", "j_spine4", "j_spinelower", "j_mainroot", "pelvis", "tag_body", "j_ankle_le", "j_ankle_ri"), player);
                self addOptSlider("Key", ::AimbotKey, Array("None", "Aiming", "Firing"), player);
                self addOptSlider("Requirement", ::AimbotVisibilityRequirement, Array("None", "Visible", "Damageable"), player);
                self addOptIncSlider("Smooth Snaps", ::SetSmoothSnaps, 5, 5, 15, 1, player);
                self addOptBool(player.PlayableAreaCheck, "In Playable Area", ::AimbotOptions, 1, player);
                self addOptBool(player.AutoFire, "Auto-Fire", ::AimbotOptions, 2, player);
                self addOptBool(player.MenuOpenCheck, "Menu Open Check", ::AimbotOptions, 3, player);
                self addOptBool(player.AimbotDistanceCheck, "Distance", ::AimbotOptions, 4, player);

                if(Is_True(player.AimbotDistanceCheck))
                    self addOptIncSlider("Max Distance", ::AimbotDistance, 100, 100, 1000, 100, player);
            break;
    }
}

Aimbot(player)
{
    player endon("disconnect");

    player.Aimbot = BoolVar(player.Aimbot);

    while(Is_True(player.Aimbot))
    {
        enemy = player GetClosestTarget();

        if(Is_True(player.Noclip) || Is_True(player.UFOMode) || Is_True(player.ControllableZombie) || Is_True(player.AC130) || Is_True(player.FlyableUFO) || Is_True(player.MenuOpenCheck) && player isInMenu(true))
            enemy = undefined;

        if(IsDefined(enemy) && Is_True(player.AimbotDistanceCheck) && Distance(player.origin, enemy.origin) > player.AimbotDistance)
            enemy = undefined;
        
        if(IsDefined(enemy) && Is_True(player.PlayableAreaCheck) && enemy.archetype == "zombie" && !zm_behavior::inplayablearea(enemy))
            enemy = undefined;
        
        if(IsDefined(enemy) && player.AimbotVisibilityRequirement != "None")
        {
            if(player.AimbotVisibilityRequirement == "Damageable" && enemy DamageConeTrace(player GetEye(), player) < 0.1)
                enemy = undefined;
            
            if(player.AimbotVisibilityRequirement == "Visible" && !player IsVisible(enemy, player.AimBoneTag))
                enemy = undefined;
        }
        
        if(player.AimbotKey == "Aiming" && !player AdsButtonPressed() || player.AimbotKey == "Firing" && !player isFiring1())
            enemy = undefined;

        if(IsDefined(enemy))
        {
            origin = enemy GetTagOrigin(player.AimBoneTag);

            if(!IsDefined(origin) || !IsVec(origin))
            {
                test = enemy GetTagOrigin("tag_body");

                if(!IsDefined(test) || !IsVec(test))
                    enemy = undefined;
                else
                    origin = test;
            }

            if(IsDefined(enemy) && IsDefined(origin) && IsVec(origin))
            {
                if(player.AimbotType == "Snap")
                {
                    player SetPlayerAngles(VectorToAngles(origin - player GetEye()));

                    if(Is_True(player.AutoFire))
                        player FireGun();
                }
                else if(player.AimbotType == "Smooth Snap")
                {
                    if(!IsDefined(player.smoothTarget) || player.smoothTarget != enemy)
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
                    {
                        player SetPlayerAngles(VectorToAngles(origin - player GetEye())); //After it has finished the smooth snap to the target, it will stay locked on
                    }

                    if(Is_True(player.AutoFire) && player.snapsRemaining <= 1)
                        player FireGun();
                }
                else if(player.AimbotType == "Silent")
                {
                    if(Is_True(player.AutoFire) || player isFiring1())
                        player FireGun(origin + (5, 0, 0), origin, false);
                }
            }
            else
            {
                if(IsDefined(player.smoothTarget))
                {
                    player.smoothTarget = undefined;
                    player.snapsRemaining = undefined;
                    player.snapAngles = undefined;
                }
            }
        }
        else
        {
            if(IsDefined(player.smoothTarget))
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
    enemy = undefined;

    for(a = 0; a < zombies.size; a++)
    {
        if(!IsDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        if(Is_True(self.AimbotDistanceCheck) && Distance(self.origin, zombies[a].origin) > self.AimbotDistance)
            continue;
        
        if(self.AimbotVisibilityRequirement == "Damageable" && zombies[a] DamageConeTrace(self GetEye(), self) < 0.1)
            continue;
        
        if(self.AimbotVisibilityRequirement == "Visible" && !self IsVisible(zombies[a], self.AimBoneTag))
            continue;
        
        if(Is_True(self.PlayableAreaCheck) && zombies[a].archetype == "zombie" && !zm_behavior::inplayablearea(zombies[a]))
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

IsVisible(enemy, tag)
{
    if(!IsDefined(enemy) || !IsAlive(enemy))
        return false;
    
    tag = !IsDefined(tag) ? enemy GetEye() : enemy GetTagOrigin(tag);

    if(!IsDefined(tag) || !IsVec(tag))
    {
        test = enemy GetTagOrigin("tag_body");
        
        if(!IsDefined(test) || !IsVec(test))
            return false;
        
        tag = test;
    }

    return VectorDot(AnglesToForward(self GetTagAngles("tag_weapon_right")), VectorNormalize(tag - self GetEye())) > Cos(40) && BulletTracePassed(self GetEye(), tag, false, self);
}

isFiring1()
{
    return (self isFiring() && !self IsMeleeing());
}

FireGun(startPosition, targetPosition, takeAmmo = false)
{
    self endon("disconnect");

    weapon = self GetCurrentWeapon();

    if(!IsDefined(weapon) || weapon == level.weaponnone)
        return;
    
    if(!self GetWeaponAmmoClip(weapon) || self IsReloading() || self isOnLadder() || self IsMantling() || self IsSwitchingWeapons() || self IsMeleeing() || self IsSprinting())
        return;
    
    start = self GetWeaponMuzzlePoint();

    if(!IsDefined(start) || !IsVec(start))
        start = self GetEye();
    
    MagicBullet(weapon, (IsDefined(startPosition) && IsVec(startPosition)) ? startPosition : start, IsDefined(targetPosition) ? targetPosition : self TraceBullet(), self);
    
    if(Is_True(takeAmmo))
        self SetWeaponAmmoClip(weapon, (self GetWeaponAmmoClip(weapon) - 1));
    
    self WeaponPlayEjectBrass();
    time = weapon.fireTime;

    if(!IsDefined(time) || time <= 0)
        time = 0.1;

    wait (time / 2);
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
            player.PlayableAreaCheck = BoolVar(player.PlayableAreaCheck);
            break;
        
        case 2:
            player.AutoFire = BoolVar(player.AutoFire);
            break;
        
        case 3:
            player.MenuOpenCheck = BoolVar(player.MenuOpenCheck);
            break;
        
        case 4:
            player.AimbotDistanceCheck = BoolVar(player.AimbotDistanceCheck);
            break;
        
        default:
            break;
    }
}