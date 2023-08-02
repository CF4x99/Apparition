ElectricFireCherry(player)
{
    player.ElectricFireCherry = isDefined(player.ElectricFireCherry) ? undefined : true;

    if(isDefined(player.ElectricFireCherry))
    {
        player endon("disconnect");
        player endon("EndElectricFireCherry");

        while(isDefined(player.ElectricFireCherry))
        {
            player waittill("reload_start");

            CodeSetClientField(player, "electric_cherry_reload_fx", 1);

            player PlaySound("zmb_bgb_powerup_burnedout");
            player PlaySound("zmb_cherry_explode");

            player clientfield::increment_to_player("zm_bgb_burned_out_1ptoplayer");
	        player clientfield::increment("zm_bgb_burned_out_3p_allplayers");

			zombies = array::get_all_closest(player.origin, GetAITeamArray(level.zombie_team), undefined, undefined, 350);

            if(!isDefined(zombies) || !zombies.size)
            {
                wait 3;
                continue;
            }

            targets = [];

            for(a = 0; a < zombies.size; a++)
            {
                if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isInArray(targets, zombies[a]))
                    continue;
                
                zombies[a].marked_for_death = 1;
                zombies[a] PlaySound("zmb_elec_jib_zombie");

                if(IsVehicle(zombies[a]))
                {
                    if(!(isDefined(zombies[a].head_gibbed) && zombies[a].head_gibbed))
                        zombies[a] clientfield::set("tesla_shock_eyes_fx_veh", 1);
                    else
                        zombies[a] clientfield::set("tesla_death_fx_veh", 1);
                    
                    zombies[a] clientfield::increment("zm_bgb_burned_out_fire_torso_vehicle");
                }
                else
                {
                    if(!(isDefined(zombies[a].head_gibbed) && zombies[a].head_gibbed))
                        zombies[a] clientfield::set("tesla_shock_eyes_fx", 1);
                    else
                        zombies[a] clientfield::set("tesla_death_fx", 1);
                    
                    zombies[a] clientfield::increment("zm_bgb_burned_out_fire_torso_actor");
                }
                
                targets[targets.size] = zombies[a];
            }

            wait 0.5;

            if(isDefined(targets) && targets.size)
            {
                for(a = 0; a < targets.size; a++)
                {
                    if(!isDefined(targets[a]) || !IsAlive(targets[a]))
                        continue;
                    
                    targets[a].ZombieFling = true;
                    targets[a] DoDamage(targets[a].health + 666, player.origin, player, player, "none");
                    player zm_score::add_to_player_score(40);
                }
            }
            
            wait 1;

            CodeSetClientField(player, "electric_cherry_reload_fx", 0);

            player EFC_Cooldown();
        }
    }
    else
        player notify("EndElectricFireCherry");
}

EFC_Cooldown()
{
    self endon("death");
    self endon("disconnect");
    
    reloadTime = self HasPerk("specialty_fastreload") ? (0.25 * GetDvarFloat("perk_weapReloadMultiplier")) : 0.25;
	coolDownTime = reloadTime + 30;

	wait coolDownTime;
}

ForceField(player)
{
    player.ForceField = isDefined(player.ForceField) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.ForceField))
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
            if(isDefined(zombies[a]) && Distance(player.origin, zombies[a].origin) <= player.ForceFieldSize && IsAlive(zombies[a]) && zombies[a] DamageConeTrace(player GetEye(), player) > 0.1)
            {
                zombies[a].ZombieFling = true;
                zombies[a] DoDamage((zombies[a].health + 666), player.origin, player);
            }

        wait 0.05;
    }
}

ForceFieldSize(num, player)
{
    if(!num)
        return self iPrintlnBold("^1ERROR: ^7Force Field Size Can't Be Less Than 1");

    player.ForceFieldSize = num;
}

Jetpack(player)
{
    if(player isPlayerLinked() && !isDefined(player.Jetpack))
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(isDefined(player.NoclipBind) && !isDefined(player.Jetpack))
        return self iPrintlnBold("^1ERROR: ^7Player Has Noclip Bind Enabled");

    player.Jetpack = isDefined(player.Jetpack) ? undefined : true;

    if(isDefined(player.Jetpack))
    {
        player endon("disconnect");

        player iPrintlnBold("Press & Hold " + self ReturnButtonName("frag") + " To Use Jetpack");

        while(isDefined(player.Jetpack))
        {
            if(player FragButtonPressed() && !player isPlayerLinked())
            {
                if(player IsOnGround())
                    player SetOrigin((player.origin + (0, 0, 5)));
                
                Earthquake(0.55, 0.05, player GetTagOrigin("back_low"), 25);
                player SetVelocity((player GetVelocity() + (0, 0, 50)));

                PlayFX(level._effect["character_fire_death_torso"], player GetTagOrigin("back_low"));
            }

            wait 0.05;
        }
    }
}

ZombieCounter(player)
{
    player.ZombieCounter = isDefined(player.ZombieCounter) ? undefined : true;

    if(isDefined(player.ZombieCounter))
    {
        player endon("disconnect");

        if(player hasMenu() && player isInMenu(true))
            player iPrintlnBold("^1NOTE: ^7The Zombie Counter Is Only Visible While The Menu Is Closed");

        while(isDefined(player.ZombieCounter))
        {
            if(!player isInMenu(true))
            {
                if(!isDefined(player.ZombieCounterHud) || !player.ZombieCounterHud.size)
                {
                    if(!isDefined(player.ZombieCounterHud))
                        player.ZombieCounterHud = [];
                    
                    player.ZombieCounterHud[0] = player createText("default", 1.4, 1, "Alive:", "LEFT", "CENTER", -400, -215, 1, level.RGBFadeColor);
                    player.ZombieCounterHud[1] = player createText("default", 1.4, 1, "Remaining For Round:", "LEFT", "CENTER", -400, -200, 1, level.RGBFadeColor);
                    
                    player.ZombieCounterHud[2] = player createText("default", 1.4, 1, 0, "LEFT", "CENTER", (-400 + (player.ZombieCounterHud[0] GetTextWidth() - 8)), -215, 1, level.RGBFadeColor);
                    player.ZombieCounterHud[3] = player createText("default", 1.4, 1, 0, "LEFT", "CENTER", (-400 + (player.ZombieCounterHud[1] GetTextWidth() - 38)), -200, 1, level.RGBFadeColor);

                    for(a = 0; a < player.ZombieCounterHud.size; a++)
                        if(isDefined(player.ZombieCounterHud[a]))
                            player.ZombieCounterHud[a] thread HudRGBFade();
                }
                else
                {
                    player.ZombieCounterHud[2] SetValue(zombie_utility::get_current_zombie_count());
                    player.ZombieCounterHud[3] SetValue(level.zombie_total);
                }
            }
            else
            {
                if(isDefined(player.ZombieCounterHud) && player.ZombieCounterHud.size)
                {
                    destroyAll(player.ZombieCounterHud);
                    player.ZombieCounterHud = [];
                }
            }

            wait 0.01;
        }
    }
    else
        destroyAll(player.ZombieCounterHud);
}

LightProtector(player)
{
    player.LightProtector = isDefined(player.LightProtector) ? undefined : true;

    if(isDefined(player.LightProtector))
    {
        player endon("disconnect");

        player.LightProtect = SpawnScriptModel(player GetTagOrigin("j_head") + (0, 0, 45), "tag_origin");
        PlayFXOnTag(level._effect["powerup_on"], player.LightProtect, "tag_origin");

        while(isDefined(player.LightProtector))
        {
            distance = 500;
            target = player GetLightProtectorTarget(distance);

            player.LightProtect MoveTo(player GetTagOrigin("j_head") + (0, 0, 45), 0.1);
            
            if(target DamageConeTrace(player GetEye(), player) >= 0.01 && Distance(player.origin, target.origin) <= distance)
            {
                time = CalcDistance(1100, player.LightProtect.origin, target GetTagOrigin("j_head"));
                player.LightProtect MoveTo(target GetTagOrigin("j_head"), time);
                wait time;

                target DoDamage(target.health + 999, (0, 0, 0), player);
                wait 0.1;

                time = CalcDistance(1100, player.LightProtect.origin, player GetTagOrigin("j_head") + (0, 0, 45));
                player.LightProtect MoveTo(player GetTagOrigin("j_head") + (0, 0, 45), time);

                wait time;
            }
            
            wait 0.1;
        }
    }
    else
        player.LightProtect delete();
}

GetLightProtectorTarget(distance)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]) && IsAlive(zombies[a]) && zombies[a] DamageConeTrace(self GetEye(), self) >= 0.1 && Distance(self.origin, zombies[a].origin) <= distance)
        {
            if(!isDefined(enemy))
                enemy = zombies[a];

            if(isDefined(enemy) && enemy != zombies[a] && Closer(self.origin, zombies[a].origin, enemy.origin) && zombies[a] DamageConeTrace(self GetEye(), self) >= 0.1)
                enemy = zombies[a];
        }
    }

    return enemy;
}

SpecialMovements(player)
{
    player.SpecialMovements = isDefined(player.SpecialMovements) ? undefined : true;

    if(isDefined(player.SpecialMovements))
    {
        player endon("disconnect");

        while(isDefined(player.SpecialMovements))
        {
            player.b_wall_run_enabled = 1;

            player AllowWallRun(1);
            player AllowDoubleJump(1);

            wait 0.1;
        }
    }
    else
    {
        player.b_wall_run_enabled = 0;

        player AllowWallRun(0);
        player AllowDoubleJump(0);
    }
}

AdventureTime(player)
{  
    if(isDefined(player.AdventureTime))
        return;

    if(player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");

    player endon("disconnect");

    player.AdventureTime = true;

    origin = player.origin;
    model = SpawnScriptModel(player.origin, "test_sphere_silver", (0, player.angles[1], 0));

    model SetScale(7);
    player PlayerLinkTo(model);

    for(a = 0; a < 10; a++)
    {
        newOrigin = origin + (RandomInt(7500), RandomInt(7500), RandomIntRange(1000, 5500));
        model MoveTo(newOrigin, 1.5);

        wait 3;
    }

    model MoveTo(origin, 3);
    wait 3.5;

    player Unlink();
    model delete();

    player.AdventureTime = undefined;
}

SendEarthquake(player)
{
    Earthquake(1, 15, player.origin, 750);
}

SpecNade(player) //Credit to Extinct for his spec-nade
{
    if(player isPlayerLinked() && !isDefined(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(isDefined(player.NoclipBind) && !isDefined(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7Player Has Noclip Bind Enabled");
    
    if(isDefined(player.DropCamera) && !isDefined(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7Player's Camera Has Been Dropped");

    player.SpecNade = isDefined(player.SpecNade) ? undefined : true;

    if(isDefined(player.SpecNade))
    {
        player endon("disconnect");
        player endon("EndSpecNade");

        while(isDefined(player.SpecNade))
        {
            player waittill("grenade_fire", grenade, weapon);
            
            if(zm_utility::is_placeable_mine(weapon) || player isPlayerLinked())
                continue;
            
            linker = SpawnScriptModel(grenade.origin - AnglesToForward(grenade.angles) * 50, "tag_origin");
            linker LinkToBlendToTag(grenade, "tag_origin");

            player.ignoreme = true;
            player Hide();

            player CameraSetPosition(linker);
            player CameraSetLookAt(grenade);
            player CameraActivate(true);

            grenade SpecNadeFollow(linker);

            player CameraActivate(false);
            linker delete();

            if(!isDefined(player.NoTarget))
                player.ignoreme = false;
            
            if(!isDefined(player.Invisibility))
                player Show();
        }
    }
    else
        player notify("EndSpecNade");
}

SpecNadeFollow(camera)
{
    self endon("death");

    while(isDefined(self))
    {
        camera.origin = (self.origin + (0, 0, 10)) - AnglesToForward(camera.angles) * 50;

        wait 0.05;
    }
}

NukeNades(player)
{
    player.NukeNades = isDefined(player.NukeNades) ? undefined : true;

    if(isDefined(player.NukeNades))
    {
        player endon("disconnect");
        player endon("EndNukeNades");
        
        while(isDefined(player.NukeNades))
        {
            player waittill("grenade_fire", grenade, weapon);
            
            if(zm_utility::is_placeable_mine(weapon))
                continue;

            grenade thread NukeNade();
        }
    }
    else
        player notify("EndNukeNades");
}

NukeNade()
{
    nukeModel = SpawnScriptModel(self.origin, "p7_zm_power_up_nuke", self.angles);
    nukeModel LinkTo(self);

    while(isDefined(self))
    {
        origin = self.origin;

        wait 0.05;
    }

    nukeModel delete();
    
    PlayFX(level._effect["grenade_samantha_steal"], origin);
    PlayFX(level._effect["poltergeist"], origin);
    PlayFX(level._effect["zombie/fx_powerup_nuke_zmb"], origin);

    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]) && IsAlive(zombies[a]) && Distance(origin, zombies[a].origin) <= 500)
        {
            zombies[a].ZombieFling = true;

            zombies[a] thread zombie_death::flame_death_fx();
            zombies[a] DoDamage((zombies[a].health + 666), origin);
        }
    }
}

ShootPowerUps(player)
{
    player.ShootPowerUps = isDefined(player.ShootPowerUps) ? undefined : true;

    if(isDefined(player.ShootPowerUps))
    {
        player endon("disconnect");
        player endon("EndShootPowerUps");

        while(isDefined(player.ShootPowerUps))
        {
            player waittill("weapon_fired");

            trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 0, player);
            
            origin = trace["position"];
            surface = trace["surfacetype"];

            if(surface == "none")
                continue;

            powerups = GetArrayKeys(level.zombie_include_powerups);
            player SpawnPowerUp(powerups[RandomInt(powerups.size)], origin);
        }
    }
    else
        player notify("EndShootPowerUps");
}

CodJumper(player)
{
    player.CodJumper = isDefined(player.CodJumper) ? undefined : true;
    
    if(isDefined(player.CodJumper))
    {
        player endon("disconnect");

        while(isDefined(player.CodJumper))
        {
            if(player isFiring1())
            {
                if(isDefined(player.codboxes))
                    for(a = 0; a < player.codboxes.size; a++)
                        player.codboxes[a] delete();
                else
                    player.codboxes = [];
                
                color = Pow(2, RandomInt(3));
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 0, player);
                
                origin = trace["position"];
                surface = trace["surfacetype"];

                if(surface != "none")
                {
                    for(a = 0; a < 3; a++)
                        for(b = 0; b < 4; b++)
                        {
                            player.codboxes[player.codboxes.size] = SpawnScriptModel(GetGroundPos(origin + ((a * 20), (b * 10), 0)), "p7_zm_power_up_max_ammo", (0, 0, 0));
                            player.codboxes[(player.codboxes.size - 1)] clientfield::set("powerup_fx", Int(color));
                        }
                }
            }
            
            if(isDefined(player.codboxes) && player.codboxes.size)
            {
                foreach(client in level.players)
                {
                    if(!Is_Alive(client) || client isDown() || isDefined(client.CodJumperLaunched))
                        continue;
                    
                    for(a = 0; a < player.codboxes.size; a++)
                        if(Distance(client.origin, player.codboxes[a].origin) < 15 && !isDefined(player.codboxes[a].isRotating))
                            player.codboxes[a] thread CodJumperBoxTrigger(client);
                }
            }
            
            wait 0.1;
        }
    }
    else
    {
        if(isDefined(player.codboxes))
            for(a = 0; a < player.codboxes.size; a++)
                player.codboxes[a] delete();
    }
}

CodJumperBoxTrigger(player)
{
    player endon("disconnect");

    player SetOrigin(player.origin + (0, 0, 5));
    player SetVelocity((player GetVelocity()[0], player GetVelocity()[1], 600));

    self RotateYaw(360, 0.5);
    self.isRotating = true;
    player.CodJumperLaunched = true;
    
    wait 0.5;

    player.CodJumperLaunched = undefined;
    self.isRotating = undefined;
}

ClusterGrenades(player)
{
    player.ClusterGrenades = isDefined(player.ClusterGrenades) ? undefined : true;

    if(isDefined(player.ClusterGrenades))
    {
        player endon("disconnect");
        player endon("EndClusterGrenades");

        while(isDefined(player.ClusterGrenades))
        {
            player waittill("grenade_fire", grenade, weapon);

            if(zm_utility::is_placeable_mine(weapon))
                continue;
            
            while(isDefined(grenade))
            {
                origin = grenade.origin;
                wait 0.1;
            }

            for(a = 0; a < 10; a++)
                player MagicGrenadeType(weapon, origin, GetRandomThrowSpeed(), ((30 + a) / 10));
        }
    }
    else
        player notify("EndClusterGrenades");
}

GetRandomThrowSpeed()
{
    yaw = RandomFloat(360);
    pitch = RandomFloatRange(65, 85);
    
    return (((Cos(yaw) * Cos(pitch)), (Sin(yaw) * Cos(pitch)), Sin(pitch)) * RandomFloatRange(400, 600));
}

UnlimitedSpecialist(player)
{
    player.UnlimitedSpecialist = isDefined(player.UnlimitedSpecialist) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.UnlimitedSpecialist))
    {
        if(player GadgetIsActive(0))
            player GadgetPowerSet(0, 99);
        else if(player GadgetPowerGet(0) < 100)
            player GadgetPowerSet(0, 100);

        wait 0.01;
    }
}

RocketRiding(player)
{
    player.RocketRiding = isDefined(player.RocketRiding) ? undefined : true;

    if(isDefined(player.RocketRiding))
    {
        player endon("disconnect");
        player endon("EndRocketRiding");
        
        while(isDefined(player.RocketRiding))
        {
            player waittill("missile_fire", missile, weaponName);

            if(zm_utility::GetWeaponClassZM(weaponName) == "weapon_launcher")
            {
                wait 0.2;
                
                if(!isDefined(player.RidingRocket))
                {
                    player.RidingRocket = true;
                    linker = SpawnScriptModel(missile.origin, "tag_origin");

                    linker LinkTo(missile);
                    player SetOrigin(linker.origin);
                    player PlayerLinkTo(linker);

                    wait 0.1;
                    player thread WatchRocket(missile, linker);
                }
            }
        }
    }
    else
        player notify("EndRocketRiding");
}

WatchRocket(rocket, linker)
{
    self endon("disconnect");
    
    while(isDefined(rocket) && Is_Alive(self))
    {
        if(self MeleeButtonPressed() || self AttackButtonPressed())
            break;

        wait 0.05;
    }
    
    self Unlink();
    linker delete();
    self.RidingRocket = undefined;
}

GrapplingGun(player)
{
    player.GrapplingGun = isDefined(player.GrapplingGun) ? undefined : true;

    if(isDefined(player.GrapplingGun))
    {
        player endon("disconnect");
        player endon("EndGrapplingGun");
        
        while(isDefined(player.GrapplingGun))
        {
            player waittill("weapon_fired");
            
            trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 0, player);
            
            origin = trace["position"];
            surface = trace["surfacetype"];
            
            if(surface != "none")
            {
                ent = SpawnScriptModel(player.origin, "tag_origin");

                player PlayerLinkTo(ent);
                ent MoveTo(origin, 1);

                ent waittill("movedone");
                player Unlink();
                ent delete();
            }
        }
    }
    else
        player notify("EndGrapplingGun");
}

GravityGun(player)
{
    if(isDefined(player.DeleteGun))
        player DeleteGun(player);

    player.GravityGun = isDefined(player.GravityGun) ? undefined : true;

    if(isDefined(player.GravityGun))
    {
        player endon("disconnect");

        player iPrintlnBold("Aim At Entities/Zombies/Players To Pick Them Up");
        player iPrintlnBold("Shoot To Launch");

        grabEnt = undefined;
        
        while(isDefined(player.GravityGun))
        {
            if(isDefined(grabEnt))
            {
                if(!IsPlayer(grabEnt) && !grabEnt isZombie())
                    grabEnt.origin = (player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250));
                else
                {
                    if(!isDefined(grabEnt.originLinker))
                        grabEnt.originLinker = SpawnScriptModel(grabEnt.origin, "tag_origin", grabEnt.angles);

                    if(!grabEnt isLinkedTo(grabEnt.originLinker))
                    {
                        if(IsPlayer(grabEnt))
                            grabEnt PlayerLinkTo(grabEnt.originLinker);
                        else
                            grabEnt LinkTo(grabEnt.originLinker);
                    }

                    grabEnt.originLinker.origin = (player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250));
                }
                
                if(player AttackButtonPressed() && isDefined(grabEnt))
                {
                    if(isDefined(grabEnt.originLinker))
                    {
                        grabEnt Unlink();
                        grabEnt.originLinker delete();
                    }

                    wait 0.01;

                    shootEnt = SpawnScriptModel(grabEnt.origin, "tag_origin");

                    if(IsPlayer(grabEnt))
                        grabEnt PlayerLinkTo(shootEnt);
                    else
                        grabEnt LinkTo(shootEnt);

                    shootEnt Launch(VectorScale(AnglesToForward(player GetPlayerAngles()), 5000));

                    grabEnt.GravityGunLaunched = true;
                    shootEnt.GravityGunLaunched = true;

                    shootEnt thread deleteAfter(5);

                    if(IsPlayer(grabEnt) || grabEnt isZombie())
                        grabEnt thread GravityGunUnlinkAfter(5);

                    grabEnt = undefined;
                }
            }

            if(player AdsButtonPressed() && !isDefined(grabEnt))
            {
                foreach(zombie in GetAITeamArray(level.zombie_team))
                    if(!isDefined(zombie.GravityGunLaunched) && IsAlive(zombie) && Distance(player TraceBullet(), zombie.origin) <= 100)
                        grabEnt = zombie;
                
                foreach(ent in GetEntArray("script_model", "classname"))
                    if(!isDefined(ent.GravityGunLaunched) && Distance(player TraceBullet(), ent.origin) <= 100)
                        grabEnt = ent;
                
                foreach(client in level.players)
                    if(!isDefined(client.GravityGunLaunched) && client != player && Distance(player TraceBullet(), client.origin) <= 100)
                        grabEnt = client;
                

            }

            wait 0.01;
        }
    }
}

GravityGunUnlinkAfter(time)
{
    if(IsPlayer(self))
        self endon("disconnect");
    
    wait time;

    if(isDefined(self))
        self Unlink();

    if(isDefined(self))
        self.GravityGunLaunched = undefined;
}

DeleteGun(player)
{
    if(isDefined(player.GravityGun))
        player GravityGun(player);

    player.DeleteGun = isDefined(player.DeleteGun) ? undefined : true;

    if(isDefined(player.DeleteGun))
    {
        player endon("disconnect");

        player iPrintlnBold(self ReturnButtonName("speed_throw") + " To ^2Delete Entities/Zombies");
        
        while(isDefined(player.DeleteGun))
        {
            if(player AdsButtonPressed())
            {
                foreach(zombie in GetAITeamArray(level.zombie_team))
                    if(Distance(player TraceBullet(), zombie.origin) <= 100)
                        deleteEnt = zombie;

                foreach(ent in GetEntArray("script_model", "classname"))
                    if(Distance(player TraceBullet(), ent.origin) <= 100)
                        deleteEnt = ent;
                
                if(isDefined(deleteEnt))
                    deleteEnt delete();
            }

            wait 0.01;
        }
    }
}

RapidFire(player)
{
    player.RapidFire = isDefined(player.RapidFire) ? undefined : true;

    player endon("disconnect");
    
    while(isDefined(player.RapidFire))
    {
        player waittill("weapon_fired");

        weapon = self GetCurrentWeapon();

        for(a = 0; a < 3; a++)
        {
            MagicBullet(weapon, player GetWeaponMuzzlePoint(), BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + player GetWeaponForwardDir() * 100, 0, undefined)["position"] + (RandomFloatRange(-5, 5), RandomFloatRange(-5, 5), RandomFloatRange(-5, 5)), player);

            wait 0.05;
        }
    }
}

ShowHitmarkers(player)
{
    player.ShowHitmarkers = isDefined(player.ShowHitmarkers) ? undefined : true;
}

HitmarkerFeedback(feedback, player)
{
    player.HitmarkerFeedback = feedback;

    if(isDefined(player.hud_damagefeedback))
        player.hud_damagefeedback SetShaderValues(player.HitmarkerFeedback, 24, 48);
}

HitMarkerColor(color, player)
{
    player.HitMarkerColor = color;

    if(isDefined(player.hud_damagefeedback) && color != "Rainbow")
        player.hud_damagefeedback.color = color;
}

PowerUpMagnet(player)
{
    player.PowerUpMagnet = isDefined(player.PowerUpMagnet) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.PowerUpMagnet))
    {
        powerups = zm_powerups::get_powerups(player.origin, 500);

        if(isDefined(powerups) && powerups.size)
        {
            foreach(index, powerup in powerups)
            {
                if(isDefined(powerup) && BulletTracePassed(player GetEye(), powerup.origin, 0, player) && !isDefined(powerup.movingtoplayer))
                {
                    powerup.movingtoplayer = true;
                    powerup MoveTo(player GetTagOrigin("j_mainroot"), CalcDistance(1100, powerup.origin, player GetTagOrigin("j_mainroot")));

                    wait 0.05;

                    if(isDefined(powerup)) //making sure the powerup still exists
                        powerup.movingtoplayer = undefined;
                }
            }
        }

        wait 0.1;
    }
}

PlayerInstaKill(player)
{
    player.PlayerInstaKill = isDefined(player.PlayerInstaKill) ? undefined : true;
}

DisableEarningPoints(player)
{
    player.DisableEarningPoints = isDefined(player.DisableEarningPoints) ? undefined : true;
}

DamagePointsMultiplier(multiplier, player)
{
    player.DamagePointsMultiplier = multiplier;
}