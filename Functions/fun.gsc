ElectricFireCherry(player)
{
    player.ElectricFireCherry = isDefined(player.ElectricFireCherry) ? undefined : true;

    if(isDefined(player.ElectricFireCherry))
    {
        player endon("disconnect");
        player endon("EndElectricFireCherry");

        player.consecutive_electric_fire_cherry_attacks = 0;

        while(isDefined(player.ElectricFireCherry))
        {
            player waittill("reload_start");

            current_weapon = player GetCurrentWeapon();

            if(isInArray(player.wait_on_reload, current_weapon))
                continue;
            
            player.wait_on_reload[player.wait_on_reload.size] = current_weapon;
            player.consecutive_electric_fire_cherry_attacks++;

            player thread check_for_reload_complete(current_weapon);
            player thread electric_fire_cherry_cooldown_timer(current_weapon);

            switch(player.consecutive_electric_fire_cherry_attacks)
			{
				case 0:
				case 1:
					n_zombie_limit = undefined;
					break;
                
				case 2:
					n_zombie_limit = 12;
					break;
                
				case 3:
					n_zombie_limit = 8;
					break;
                
				case 4:
					n_zombie_limit = 4;
					break;
                
				default:
					n_zombie_limit = 0;
                    break;
			}

            CodeSetClientField(player, "electric_cherry_reload_fx", 1);

            player PlaySound("zmb_bgb_powerup_burnedout");
            player PlaySound("zmb_cherry_explode");

            player clientfield::increment_to_player("zm_bgb_burned_out_1ptoplayer");
	        player clientfield::increment("zm_bgb_burned_out_3p_allplayers");

			zombies = array::get_all_closest(player.origin, GetAITeamArray(level.zombie_team), undefined, undefined, 375);

            if(!isDefined(zombies) || !zombies.size)
            {
                CodeSetClientField(player, "electric_cherry_reload_fx", 0);
                continue;
            }

            targets = [];

            for(a = 0; a < zombies.size; a++)
            {
                if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isInArray(targets, zombies[a]) || isDefined(n_zombie_limit) && targets.size >= n_zombie_limit)
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

            if(isDefined(targets) && targets.size)
            {
                for(a = 0; a < targets.size; a++)
                {
                    wait 0.1;

                    if(!isDefined(targets[a]) || !IsAlive(targets[a]))
                        continue;
                    
                    targets[a].ZombieFling = true;
                    targets[a] DoDamage((targets[a].health + 666), targets[a].origin);
                    player zm_score::add_to_player_score(40);
                }
            }

            CodeSetClientField(player, "electric_cherry_reload_fx", 0);
        }
    }
    else
        player notify("EndElectricFireCherry");
}

electric_fire_cherry_cooldown_timer(current_weapon)
{
	self notify("electric_fire_cherry_cooldown_started");
	self endon("electric_fire_cherry_cooldown_started");
    
	self endon("death");
	self endon("disconnect");

    reloadTime = self HasPerk("specialty_fastreload") ? (0.25 * GetDvarFloat("perk_weapReloadMultiplier")) : 0.25;
    waitTime = reloadTime + 3;

	wait waitTime;
	self.consecutive_electric_fire_cherry_attacks = 0;
}

check_for_reload_complete(weapon)
{
	self endon("death");
	self endon("disconnect");
	self endon("player_lost_weapon_" + weapon.name);

	self thread weapon_replaced_monitor(weapon);

	while(1)
	{
		self waittill("reload");

		current_weapon = self GetCurrentWeapon();

		if(current_weapon == weapon)
		{
			ArrayRemoveValue(self.wait_on_reload, weapon);
			self notify("weapon_reload_complete_" + weapon.name);

			break;
		}
	}
}

weapon_replaced_monitor(weapon)
{
	self endon("death");
	self endon("disconnect");
	self endon("weapon_reload_complete_" + weapon.name);

	while(1)
	{
		self waittill("weapon_change");

		primaryweapons = self GetWeaponsListPrimaries();

		if(!isInArray(primaryweapons, weapon))
		{
			self notify("player_lost_weapon_" + weapon.name);
			ArrayRemoveValue(self.wait_on_reload, weapon);

			break;
		}
	}
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
                zombies[a] DoDamage((zombies[a].health + 666), player.origin);
            }

        wait 0.05;
    }
}

ForceFieldSize(num, player)
{
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

        player iPrintlnBold("Press & Hold [{+frag}] To Use Jetpack");

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
                    
                    player.ZombieCounterHud[0] = player createText("default", 1.4, 1, "Alive:", "LEFT", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2) - 1), -145, 1, level.RGBFadeColor);
                    player.ZombieCounterHud[1] = player createText("default", 1.4, 1, "Remaining For Round:", "LEFT", "CENTER", player.ZombieCounterHud[0].x, (player.ZombieCounterHud[0].y + 15), 1, level.RGBFadeColor);
                    
                    player.ZombieCounterHud[2] = player createText("default", 1.4, 1, 0, "LEFT", "CENTER", (player.ZombieCounterHud[0].x + (player.ZombieCounterHud[0] GetTextWidth() - 8)), player.ZombieCounterHud[0].y, 1, level.RGBFadeColor);
                    player.ZombieCounterHud[3] = player createText("default", 1.4, 1, 0, "LEFT", "CENTER", (player.ZombieCounterHud[1].x + (player.ZombieCounterHud[1] GetTextWidth() - 38)), player.ZombieCounterHud[1].y, 1, level.RGBFadeColor);

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
        player endon("EndLightProtector");

        player.LightProtect = SpawnScriptModel(player GetTagOrigin("j_head") + (0, 0, 45), "tag_origin");

        if(isDefined(player.LightProtect))
            PlayFXOnTag(level._effect["powerup_on"], player.LightProtect, "tag_origin");

        while(isDefined(player.LightProtector) && isDefined(player.LightProtect))
        {
            player.LightProtect MoveTo(player GetTagOrigin("j_head") + (0, 0, 45), 0.1);
            target = player GetLightProtectorTarget(500);
            
            if(isDefined(target))
                player LightProtectorMoveToTarget(target);
            
            wait 0.1;
        }

        //In the case that the entity crash protection deletes the light protector, but the light protector variable is still true
        if(isDefined(player.LightProtector) && !isDefined(player.LightProtect))
            thread LightProtector(player);
    }
    else
    {
        player notify("EndLightProtector");

        if(isDefined(player.LightProtect))
            player.LightProtect delete();
    }
}

LightProtectorMoveToTarget(target)
{
    if(!isDefined(target) || !IsAlive(target) || !isDefined(self.LightProtect))
        return;
    
    self endon("disconnect");
    self endon("EndLightProtector");

    if(target DamageConeTrace(self GetEye(), self) >= 0.01 && Distance(self.origin, target.origin) <= 500)
    {
        origin = target GetTagOrigin("j_head");

        if(!isDefined(origin)) //If the tag origin for the target tag can't be found, this will test the given tags to see if one can be used
        {
            tags = ["j_ankle_ri", "j_ankle_le", "pelvis", "j_mainroot", "j_spinelower", "j_spine4", "j_neck", "tag_body"];

            for(a = 0; a < tags.size; a++)
            {
                test = target GetTagOrigin(tags[a]);

                if(isDefined(test))
                    origin = target GetTagOrigin(tags[a]);
            }
        }

        time = CalcDistance(1100, self.LightProtect.origin, origin);
        self.LightProtect MoveTo(origin, time);
        wait time;

        target.ZombieFling = true;
        target DoDamage((target.health + 666), self.origin);
        wait 0.1;

        newTarget = self GetLightProtectorTarget(500);

        if(isDefined(newTarget))
        {
            self thread LightProtectorMoveToTarget(target);
            return;
        }

        if(!isDefined(self.LightProtect))
            return;
        
        time = CalcDistance(1100, self.LightProtect.origin, self GetTagOrigin("j_head") + (0, 0, 45));
        self.LightProtect MoveTo(self GetTagOrigin("j_head") + (0, 0, 45), time);

        wait time;
    }
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

    player endon("disconnect");

    if(isDefined(player.SpecialMovements))
    {
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

PlayerMountCamera(tag, player)
{
    player endon("disconnect");

    if(isDefined(player.SpecNade) && !isDefined(player.PlayerMountCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(isDefined(player.DropCamera) && !isDefined(player.PlayerMountCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Drop Camera Is Enabled");
    
    if(tag != "Disable")
    {
        if(isDefined(player.PlayerMountCamera))
            PlayerMountCamera("Disable", player);

        player.PlayerMountCamera = true;

        player.camlinker = SpawnScriptModel((player GetTagOrigin(tag) + (AnglesToForward(player GetPlayerAngles()) * 9)), "tag_origin");
        player.camlinker LinkToBlendToTag(player, tag);

        player CameraSetPosition(player.camlinker);
        player CameraActivate(true);
    }
    else
    {
        player CameraActivate(false);
        
        if(isDefined(player.camlinker))
            player.camlinker delete();
        
        player.PlayerMountCamera = undefined;
    }
}

PlayerDropCamera(player)
{
    player endon("disconnect");
    
    if(isDefined(player.SpecNade) && !isDefined(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(isDefined(player.PlayerMountCamera) && !isDefined(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Mount Camera Is Enabled");
    
    player.DropCamera = isDefined(player.DropCamera) ? undefined : true;

    if(isDefined(player.DropCamera))
    {
        player.camlinker = SpawnScriptModel(player GetTagOrigin("j_head"), "tag_origin");

        player CameraSetPosition(player.camlinker);
        player CameraActivate(true);

        player.camlinker Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 10));
    }
    else
    {
        player CameraActivate(false);

        if(isDefined(player.camlinker))
            player.camlinker delete();
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

IceSkating(player)
{
    player.IceSkating = isDefined(player.IceSkating) ? undefined : true;
    player ForceSlick(isDefined(player.IceSkating));
}

ForgeMode(player)
{
    if(isDefined(player.DeleteGun))
        player DeleteGun(player);
    
    if(isDefined(player.GravityGun))
        player GravityGun(player);

    player.ForgeMode = isDefined(player.ForgeMode) ? undefined : true;

    if(isDefined(player.ForgeMode))
    {
        player endon("disconnect");

        player iPrintlnBold("Aim At Entities/Zombies/Players To Pick Them Up");
        player iPrintlnBold("[{+attack}] To Release");
        
        while(isDefined(player.ForgeMode))
        {
            if(isDefined(grabEnt) && (IsPlayer(grabEnt) && !Is_Alive(grabEnt) || grabEnt isZombie() && !IsAlive(grabEnt)))
                grabEnt = undefined;
            
            if(isDefined(grabEnt))
            {
                if(IsPlayer(grabEnt))
                    grabEnt SetOrigin((player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250)));
                else if(grabEnt isZombie())
                    grabEnt ForceTeleport((player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250)));
                else
                    grabEnt.origin = (player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250));

                if(player AttackButtonPressed())
                    grabEnt = undefined;
            }

            if(player AdsButtonPressed() && !isDefined(grabEnt))
            {
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 1, player);

                if(isDefined(trace["entity"]))
                    grabEnt = trace["entity"];
            }

            wait 0.01;
        }
    }
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
            
            if(zm_utility::is_placeable_mine(weapon) || player isPlayerLinked() || !isDefined(grenade))
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
    if(!isDefined(camera))
        return;
    
    self endon("death");

    while(isDefined(self))
    {
        if(isDefined(camera))
            camera.origin = ((self.origin + (0, 0, 10)) - (AnglesToForward(camera.angles) * 50));

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
            
            if(zm_utility::is_placeable_mine(weapon) || !isDefined(grenade))
                continue;

            grenade thread NukeNade();
        }
    }
    else
        player notify("EndNukeNades");
}

NukeNade()
{
    if(!isDefined(self))
        return;
    
    nukeModel = SpawnScriptModel(self.origin, "p7_zm_power_up_nuke", self.angles);

    if(isDefined(nukeModel))
        nukeModel LinkTo(self);

    while(isDefined(self))
    {
        origin = self.origin;

        wait 0.05;
    }
    
    origin += (0, 0, 25);

    if(isDefined(nukeModel))
        nukeModel delete();
    
    PlayFX(level._effect["grenade_samantha_steal"], origin);
    PlayFX(level._effect["poltergeist"], origin);
    PlayFX("zombie/fx_powerup_nuke_zmb", origin);

    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies) || Distance(origin, zombies[a].origin) > 500)
            continue;
        
        zombies[a].ZombieFling = true;
        zombies[a] clientfield::increment("zm_nuked");

        wait 0.1;

        zombies[a] DoDamage((zombies[a].health + 666), origin);
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

            if(surface == "none" || surface == "default")
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

        player.codboxes = [];

        while(isDefined(player.CodJumper))
        {
            if(player isFiring1())
            {
                if(isDefined(player.codboxes))
                    for(a = 0; a < player.codboxes.size; a++)
                        player.codboxes[a] delete();
                
                color = Pow(2, RandomInt(3));
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 0, player);
                
                origin = trace["position"];
                surface = trace["surfacetype"];

                if(surface != "none" && surface != "default")
                {
                    for(a = 0; a < 3; a++)
                        for(b = 0; b < 4; b++)
                        {
                            player.codboxes[player.codboxes.size] = SpawnScriptModel(GetGroundPos(origin + ((a * 20), (b * 10), 0)), "p7_zm_power_up_max_ammo", (0, 0, 0));
                            player.codboxes[(player.codboxes.size - 1)] clientfield::set("powerup_fx", Int(color));

                            player.codboxes[(player.codboxes.size - 1)] thread CodBoxHandler();
                        }
                }
            }
            
            wait 0.1;
        }
    }
    else
    {
        if(isDefined(player.codboxes) && player.codboxes.size)
            foreach(box in player.codboxes)
                if(isDefined(box))
                    box delete();
    }
}

CodBoxHandler()
{
    while(isDefined(self))
    {
        foreach(player in level.players)
        {
            if(!Is_Alive(player) || player isDown() || !player IsTouching(self))
                continue;
            
            if(player IsOnGround())
                player SetOrigin(player.origin + (0, 0, 5));
            
            player SetVelocity((player GetVelocity()[0], player GetVelocity()[1], 600));
        }

        wait 0.01;
    }
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

            if(!isDefined(grenade) || !isDefined(weapon) || zm_utility::is_placeable_mine(weapon))
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

            if(zm_utility::GetWeaponClassZM(weaponName) != "weapon_launcher")
                continue;
            
            trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 200), 1, player);
            
            rider = undefined;

            foreach(client in level.players)
            {
                if(!Is_Alive(client) || client == player)
                    continue;
                
                if(Distance(client.origin, trace["position"]) <= 225)
                {
                    if(!isDefined(rider))
                        rider = client;
                    else
                    {
                        if(Distance(client, trace["position"]) < Distance(rider, trace["position"]))
                            rider = client;
                    }
                }
            }
            
            if(!isDefined(rider))
                rider = player;
            
            if(isDefined(rider.RidingRocket))
            {
                rider notify("StopRidingRocket");
                rider Unlink();
                rider.RocketRidingLinker delete();
                rider.RidingRocket = undefined;
            }
            
            wait 0.2;
            
            rider.RidingRocket = true;
            rider.RocketRidingLinker = SpawnScriptModel(missile.origin, "tag_origin");

            if(isDefined(rider.RocketRidingLinker))
                rider.RocketRidingLinker LinkTo(missile);
            
            rider SetOrigin(rider.RocketRidingLinker.origin);
            rider PlayerLinkTo(rider.RocketRidingLinker);

            wait 0.1;
            rider thread WatchRocket(missile);
        }
    }
    else
        player notify("EndRocketRiding");
}

WatchRocket(rocket)
{
    self endon("death");
    self endon("disconnect");
    self endon("StopRidingRocket");
    
    while(isDefined(rocket) && Is_Alive(self))
    {
        if(self MeleeButtonPressed())
            break;

        wait 0.05;
    }
    
    self Unlink();

    if(isDefined(self.RocketRidingLinker))
        self.RocketRidingLinker delete();
    
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

            if(surface == "none" || surface == "default")
                continue;
            
            ent = SpawnScriptModel(player.origin, "tag_origin");

            player PlayerLinkTo(ent);
            ent MoveTo(origin, 1);

            ent waittill("movedone");
            player Unlink();
            ent delete();
        }
    }
    else
        player notify("EndGrapplingGun");
}

GravityGun(player)
{
    if(isDefined(player.DeleteGun))
        player DeleteGun(player);
    
    if(isDefined(player.ForgeMode))
        player ForgeMode(player);

    player.GravityGun = isDefined(player.GravityGun) ? undefined : true;

    if(isDefined(player.GravityGun))
    {
        player endon("disconnect");

        player iPrintlnBold("Aim At Entities/Zombies/Players To Pick Them Up");
        player iPrintlnBold("[{+attack}] To Launch");
        
        while(isDefined(player.GravityGun))
        {
            if(isDefined(grabEnt) && (IsPlayer(grabEnt) && !Is_Alive(grabEnt) || grabEnt isZombie() && !IsAlive(grabEnt)))
                grabEnt = undefined;
            
            if(isDefined(grabEnt))
            {
                if(IsPlayer(grabEnt))
                    grabEnt SetOrigin((player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250)));
                else if(grabEnt isZombie())
                    grabEnt ForceTeleport((player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250)));
                else
                    grabEnt.origin = (player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250));
                
                if(player AttackButtonPressed() && isDefined(grabEnt))
                {
                    shootEnt = SpawnScriptModel(grabEnt.origin, "tag_origin");

                    if(IsPlayer(grabEnt))
                        grabEnt PlayerLinkTo(shootEnt);
                    else
                        grabEnt LinkTo(shootEnt);
                    
                    grabEnt.GravityGunLaunched = true;
                    shootEnt.GravityGunLaunched = true;
                    shootEnt thread deleteAfter(5);
                    grabEnt thread GravityGunUnlinkAfter(5);
                    
                    shootEnt Launch(VectorScale(AnglesToForward(player GetPlayerAngles()), 2500));

                    wait 0.1;

                    grabEnt = undefined;
                }
            }

            if(player AdsButtonPressed() && !isDefined(grabEnt))
            {
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 1, player);

                if(isDefined(trace["entity"]) && !isDefined(trace["entity"].GravityGunLaunched))
                    grabEnt = trace["entity"];
            }

            wait 0.01;
        }
    }
}

GravityGunUnlinkAfter(time)
{
    self endon("death");
    self endon("disconnect");
    
    wait time;

    if(isDefined(self))
        self Unlink();

    if(isDefined(self))
        self.GravityGunLaunched = undefined;
}

DeleteGun(player)
{
    player endon("disconnect");

    if(isDefined(player.GravityGun))
        player GravityGun(player);
    
    if(isDefined(player.ForgeMode))
        player ForgeMode(player);

    player.DeleteGun = isDefined(player.DeleteGun) ? undefined : true;

    if(isDefined(player.DeleteGun))
    {
        player iPrintlnBold("Aim At Entities/Zombies To Delete Them");
        
        while(isDefined(player.DeleteGun))
        {
            if(player AdsButtonPressed())
            {
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 1, player);

                if(isDefined(trace["entity"]) && !IsPlayer(trace["entity"]))
                    trace["entity"] delete();
            }

            wait 0.01;
        }
    }
}

RapidFire(player)
{
    player.RapidFire = isDefined(player.RapidFire) ? undefined : true;
    
    if(isDefined(player.RapidFire))
    {
        player endon("disconnect");
        player endon("EndRapidFire");

        while(isDefined(player.RapidFire))
        {
            player waittill("weapon_fired");

            weapon = player GetCurrentWeapon();

            for(a = 0; a < 3; a++)
            {
                MagicBullet(weapon, player GetWeaponMuzzlePoint(), BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + player GetWeaponForwardDir() * 100, 0, undefined)["position"] + (RandomFloatRange(-5, 5), RandomFloatRange(-5, 5), RandomFloatRange(-5, 5)), player);

                wait 0.05;
            }
        }
    }
    else
        player notify("EndRapidFire");
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