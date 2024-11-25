PopulateAimbotMenu(menu, player)
{
    switch(menu)
    {
        case "Aimbot Menu":
            if(!isDefined(player.AimbotType))
                player.AimbotType = "Snap";
            
            if(!isDefined(player.AimBoneTag))
                player.AimBoneTag = "j_head";
            
            if(!isDefined(player.AimbotKey))
                player.AimbotKey = "None";
            
            if(!isDefined(player.AimbotVisibilityRequirement))
                player.AimbotVisibilityRequirement = "None";
            
            if(!isDefined(player.AimbotDistance))
                player.AimbotDistance = 100;
            
            if(!isDefined(player.SmoothSnaps))
                player.SmoothSnaps = 5;
            
            self addMenu("Aimbot Menu");
                self addOptBool(player.Aimbot, "Aimbot", ::Aimbot, player);
                self addOptSlider("Type", ::AimbotType, "Snap;Smooth Snap;Silent", player);
                self addOptSlider("Tag", ::AimBoneTag, "j_head;j_neck;j_spine4;j_spinelower;j_mainroot;pelvis;tag_body;j_ankle_le;j_ankle_ri", player);
                self addOptSlider("Key", ::AimbotKey, "None;Aiming;Firing", player);
                self addOptSlider("Requirement", ::AimbotVisibilityRequirement, "None;Visible;Damageable", player);
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

        if(Is_True(player.Noclip) || Is_True(player.UFOMode) || Is_True(player.ControllableZombie) || Is_True(player.AC130) || Is_True(player.MenuOpenCheck) && player isInMenu(true))
            enemy = undefined;

        if(isDefined(enemy) && Is_True(player.AimbotDistanceCheck) && Distance(player.origin, enemy.origin) > player.AimbotDistance)
            enemy = undefined;
        
        if(isDefined(enemy) && Is_True(player.PlayableAreaCheck) && !zm_behavior::inplayablearea(enemy))
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
                tags = Array("j_ankle_ri", "j_ankle_le", "pelvis", "j_mainroot", "j_spinelower", "j_spine4", "j_neck", "j_head", "tag_body");

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

                    if(Is_True(player.AutoFire))
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
    enemy = undefined;

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || Is_True(self.AimbotDistanceCheck) && Distance(self.origin, zombies[a].origin) > self.AimbotDistance || self.AimbotVisibilityRequirement == "Damageable" && zombies[a] DamageConeTrace(self GetEye(), self) < 0.1 || self.AimbotVisibilityRequirement == "Visible" && !self IsVisible(zombies[a]) || Is_True(self.PlayableAreaCheck) && !zm_behavior::inplayablearea(zombies[a]))
            continue;
        
        if(!isDefined(enemy))
            enemy = zombies[a];
        
        if(isDefined(enemy) && enemy != zombies[a])
        {
            if(!Closer(self.origin, zombies[a].origin, enemy.origin) || self.AimbotVisibilityRequirement == "Damageable" && zombies[a] DamageConeTrace(self GetEye(), self) < 0.1 || self.AimbotVisibilityRequirement == "Visible" && !self IsVisible(zombies[a]) || Is_True(self.AimbotDistanceCheck) && Distance(self.origin, zombies[a].origin) > self.AimbotDistance)
                continue;
            
            enemy = zombies[a];
        }
    }

    return enemy;
}

IsVisible(enemy)
{
    return VectorDot(AnglesToForward(self GetTagAngles("tag_weapon_right")), VectorNormalize(enemy GetEye() - self GetWeaponMuzzlePoint())) > Cos(40) && BulletTracePassed(self GetEye(), enemy GetEye(), false, self);
}

isFiring1()
{
    return (self isFiring() && !self IsMeleeing());
}

FireGun(startPosition, targetPosition, takeAmmo = false)
{
    self endon("disconnect");

    weapon = self GetCurrentWeapon();

    if(!isDefined(weapon) || weapon.name == "none")
        return;
    
    if(!self GetWeaponAmmoClip(weapon) || self IsReloading() || self isOnLadder() || self IsMantling() || self IsSwitchingWeapons() || self IsMeleeing() || self IsSprinting())
        return;
    
    startLocation = isDefined(startPosition) ? startPosition : self GetWeaponMuzzlePoint();
    targetLocation = isDefined(targetPosition) ? targetPosition : self TraceBullet();
    MagicBullet(weapon, startLocation, targetLocation, self);
    
    if(takeAmmo)
        self SetWeaponAmmoClip(weapon, (self GetWeaponAmmoClip(weapon) - 1));
    
    self WeaponPlayEjectBrass();
    time = weapon.fireTime;

    if(!isDefined(time) || time <= 0)
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