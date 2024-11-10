PopulateFunScripts(menu, player)
{
    switch(menu)
    {
        case "Fun Scripts":
            if(!isDefined(player.DamagePointsMultiplier))
                player.DamagePointsMultiplier = 1;
            
            self addMenu("Fun Scripts");
                self addOpt("Earthquake", ::SendEarthquake, player);
                self addOpt("Adventure Time", ::AdventureTime, player);
                self addOpt("Force Field Options", ::newMenu, "Force Field Options");
                self addOpt("Audio Quotes", ::newMenu, "Sound/Music");
                self addOpt("Hit Markers", ::newMenu, "Hit Markers");
                self addOptSlider("Insta-Kill", ::PlayerInstaKill, "Disable;All;Melee", player);
                self addOptSlider("Mount Camera", ::PlayerMountCamera, "Disable;j_head;j_neck;j_spine4;j_spinelower;j_mainroot;pelvis;j_ankle_le;j_ankle_ri", player);
                self addOptBool(player.DropCamera, "Drop Camera", ::PlayerDropCamera, player);
                self addOptBool(player.DeadOpsView, "Dead Ops View", ::DeadOpsView, player);
                self addOptBool(player.ZombieCounter, "Zombie Counter", ::ZombieCounter, player);
                self addOptBool(player.LightProtector, "Light Protector", ::LightProtector, player);
                self addOptBool(player.SpecialMovements, "Special Movements", ::SpecialMovements, player);
                self addOptBool(player GetPlayerGravity() == 136, "Moon Gravity", ::MoonGravity, player);
                self addOptBool(player.IceSkating, "Ice Skating", ::IceSkating, player);
                self addOptBool(player.ForgeMode, "Forge Mode", ::ForgeMode, player);
                self addOptBool(player.SpecNade, "Spec-Nade", ::SpecNade, player);
                self addOptBool(player.NukeNades, "Nuke Nades", ::NukeNades, player);
                self addOptBool(player.CodJumper, "Cod Jumper", ::CodJumper, player);
                self addOptBool(player.Jetpack, "Jetpack", ::Jetpack, player);
                self addOptBool(player.ClusterGrenades, "Cluster Grenades", ::ClusterGrenades, player);
                self addOptBool(player.UnlimitedSpecialist, "Unlimited Specialist", ::UnlimitedSpecialist, player);
                self addOptBool(player.ElectricFireCherry, "Electric Fire Cherry", ::ElectricFireCherry, player);
                self addOptBool(player.ShootPowerUps, "Shoot Power-Ups", ::ShootPowerUps, player);
                self addOptBool(player.RocketRiding, "Rocket Riding", ::RocketRiding, player);
                self addOptBool(player.GrapplingGun, "Grappling Gun", ::GrapplingGun, player);
                self addOptBool(player.GravityGun, "Gravity Gun", ::GravityGun, player);
                self addOptBool(player.DeleteGun, "Delete Gun", ::DeleteGun, player);
                self addOptBool(player.RapidFire, "Rapid Fire", ::RapidFire, player);
                self addOptBool(player.ExtraGore, "Extra Gore", ::ExtraGore, player);
                self addOptBool(player.PowerUpMagnet, "Power-Up Magnet", ::PowerUpMagnet, player);
                self addOptBool(player.DisableEarningPoints, "Disable Earning Points", ::DisableEarningPoints, player);
                self addOptIncSlider("Points Multiplier", ::DamagePointsMultiplier, 1, 1, 10, 0.5, player);
            break;
        
        case "Hit Markers":
            if(!isDefined(player.HitmarkerFeedback))
                player.HitmarkerFeedback = "damage_feedback_glow_orange";
            
            if(!isDefined(self.HitMarkerColor))
                self.HitMarkerColor = (1, 1, 1);
            
            self addMenu("Hit Markers");
                self addOptBool(player.ShowHitmarkers, "Hit Markers", ::ShowHitmarkers, player);
                self addOptSlider("Feedback", ::HitmarkerFeedback, "damage_feedback_glow_orange;damage_feedback;damage_feedback_flak;damage_feedback_tac;damage_feedback_armor", player);
                self addOpt("");

                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((IsVec(self.HitMarkerColor) && self.HitMarkerColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::HitMarkerColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), player);
                
                self addOptBool((IsString(self.HitMarkerColor) && self.HitMarkerColor == "Rainbow"), "Smooth Rainbow", ::HitMarkerColor, "Rainbow", player);
            break;
        
        case "Sound/Music":
            self addMenu("Sound/Music");
                self addOpt("Perk Jingles & Quotes", ::newMenu, "Perk Jingles & Quotes");

                for(a = 0; a < level.MenuVOXCategory.size; a++)
                    self addOpt(level.MenuVOXCategory[a], ::newMenu, level.MenuVOXCategory[a]);
            break;
        
        case "Perk Jingles & Quotes":
            perkArray = [];
            vendings = GetEntArray("zombie_vending", "targetname");

            self addMenu("Perk Jingles & Quotes");
                
                for(a = 0; a < vendings.size; a++)
                {
                    if(!isDefined(vendings[a]))
                        continue;
                    
                    perkName = vendings[a].script_noteworthy;

                    if(isInArray(perkArray, perkName))
                        continue;
                    
                    self addOpt(ReturnPerkName(CleanString(vendings[a].script_noteworthy)) + " Jingle", ::PlayPerkMachineSound, vendings[a].script_sound, player);
                    self addOpt(ReturnPerkName(CleanString(vendings[a].script_noteworthy)) + " Quote", ::PlayPerkMachineSound, vendings[a].script_label, player);

                    perkArray[perkArray.size] = perkName;
                }
            break;
        
        case "Force Field Options":
            if(!isDefined(player.ForceFieldSize))
                player.ForceFieldSize = 250;
            
            self addMenu("Force Field Options");
                self addOptBool(player.ForceField, "Force Field", ::ForceField, player);
                self addOptIncSlider("Force Field Size", ::ForceFieldSize, 250, player.ForceFieldSize, 500, 25, player);
            break;
        
        default:
            if(isInArray(level.MenuVOXCategory, menu))
            {
                self addMenu(menu);

                foreach(category, sound in level.sndplayervox)
                {
                    if(CleanString(category, true) != menu)
                        continue;
                    
                    foreach(subcategory, vox in level.sndplayervox[category])
                    {
                        if(IsSubStr(subcategory, "specialty"))
                            voxDisplay = ReturnPerkName(CleanString(subcategory));
                        else
                            voxDisplay = CleanString(subcategory, true);
                        
                        self addOpt(voxDisplay, ::create_and_play_dialog, category, subcategory, player);
                    }
                }
            }
            break;
    }
}

ElectricFireCherry(player)
{
    player endon("disconnect");
    player endon("EndElectricFireCherry");
    
    player.ElectricFireCherry = BoolVar(player.ElectricFireCherry);

    if(Is_True(player.ElectricFireCherry))
    {
        player.consecutive_electric_fire_cherry_attacks = 0;
        player.wait_on_reload = [];

        while(Is_True(player.ElectricFireCherry))
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

            //Makes sure electric_cherry is used, which will mean 'electric_cherry_reload_fx' is registered as a client field
            if(isDefined(level._effect["electric_cherry_explode"]))
                CodeSetClientField(player, "electric_cherry_reload_fx", 1);

            player PlaySound("zmb_bgb_powerup_burnedout");
            player PlaySound("zmb_cherry_explode");

            player clientfield::increment_to_player("zm_bgb_burned_out_1ptoplayer");
            player clientfield::increment("zm_bgb_burned_out_3p_allplayers");

            zombies = array::get_all_closest(player.origin, GetAITeamArray(level.zombie_team), undefined, undefined, 375);

            if(!isDefined(zombies) || !zombies.size)
            {
                //Makes sure electric_cherry is used, which will mean 'electric_cherry_reload_fx' is registered as a client field
                if(isDefined(level._effect["electric_cherry_explode"]))
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

            //Makes sure electric_cherry is used, which will mean 'electric_cherry_reload_fx' is registered as a client field
            if(isDefined(level._effect["electric_cherry_explode"]))
                CodeSetClientField(player, "electric_cherry_reload_fx", 0);
        }
    }
    else
    {
        //Makes sure electric_cherry is used, which will mean 'electric_cherry_reload_fx' is registered as a client field
        if(isDefined(level._effect["electric_cherry_explode"]))
            CodeSetClientField(player, "electric_cherry_reload_fx", 0);
        
        player notify("EndElectricFireCherry");
    }
}

electric_fire_cherry_cooldown_timer(current_weapon)
{
	self notify("electric_fire_cherry_cooldown_started");
    self endon("electric_fire_cherry_cooldown_started");
    
    self endon("death");
    self endon("disconnect");

    if(self HasPerk("specialty_fastreload"))
        reloadTime = (0.25 * GetDvarFloat("perk_weapReloadMultiplier"));
    else
        reloadTime = 0.25;
    
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

PlayPerkMachineSound(sound, player)
{
    player notify("sndDone");
	player PlaySoundWithNotify(sound, "sndDone");
}

create_and_play_dialog(category, subcategory, player)
{
    player zm_audio::create_and_play_dialog(category, subcategory);
}

ForceField(player)
{
    player endon("disconnect");

    player.ForceField = BoolVar(player.ForceField);

    while(Is_True(player.ForceField))
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
    player endon("disconnect");

    if(player isPlayerLinked() && !Is_True(player.Jetpack))
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(Is_True(player.NoclipBind1) && !Is_True(player.Jetpack))
        return self iPrintlnBold("^1ERROR: ^7Player Has Noclip Bind Enabled");
    
    player.Jetpack = BoolVar(player.Jetpack);

    if(Is_True(player.Jetpack))
    {
        player iPrintlnBold("Press & Hold [{+frag}] To Use Jetpack");

        while(Is_True(player.Jetpack))
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
    player endon("disconnect");

    player.ZombieCounter = BoolVar(player.ZombieCounter);
    
    if(Is_True(player.ZombieCounter))
    {
        if(player isInMenu(true))
            player iPrintlnBold("^1NOTE: ^7The Zombie Counter Is Only Visible While The Menu Is Closed");

        while(Is_True(player.ZombieCounter))
        {
            if(!player isInMenu(true))
            {
                if(!isDefined(player.ZombieCounterHud) || !player.ZombieCounterHud.size)
                {
                    if(!isDefined(player.ZombieCounterHud))
                        player.ZombieCounterHud = [];
                    
                    player.ZombieCounterHud[0] = player createText("default", 1.4, 1, "Alive:", "LEFT", "CENTER", -407, -145, 1, level.RGBFadeColor);
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
    player endon("disconnect");
    player endon("EndLightProtector");

    player.LightProtector = BoolVar(player.LightProtector);

    if(Is_True(player.LightProtector))
    {
        player.LightProtect = SpawnScriptModel(player GetTagOrigin("j_head") + (0, 0, 45), "tag_origin");

        if(isDefined(player.LightProtect))
            PlayFXOnTag(level._effect["powerup_on"], player.LightProtect, "tag_origin");

        while(Is_True(player.LightProtector) && isDefined(player.LightProtect))
        {
            player.LightProtect MoveTo(player GetTagOrigin("j_head") + (0, 0, 45), 0.1);
            target = player GetLightProtectorTarget(500);
            
            if(isDefined(target))
                player LightProtectorMoveToTarget(target);
            
            wait 0.1;
        }

        //In the case that the entity crash protection deletes the light protector, but the light protector variable is still true
        if(Is_True(player.LightProtector) && !isDefined(player.LightProtect))
            LightProtector(player);
    }
    else
    {
        if(isDefined(player.LightProtect))
            player.LightProtect delete();
        
        player notify("EndLightProtector");
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
            tags = Array("j_ankle_ri", "j_ankle_le", "pelvis", "j_mainroot", "j_spinelower", "j_spine4", "j_neck", "tag_body");

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
    enemy = undefined;

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
    player endon("disconnect");

    player.SpecialMovements = BoolVar(player.SpecialMovements);

    if(Is_True(player.SpecialMovements))
    {
        while(Is_True(player.SpecialMovements))
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

MoonGravity(player)
{
    if(player GetPlayerGravity() == 136)
        player ClearPlayerGravity();
    else
        player SetPlayerGravity(136);
}

PlayerMountCamera(tag, player)
{
    player endon("disconnect");

    if(Is_True(player.SpecNade) && !Is_True(player.PlayerMountCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(Is_True(player.DropCamera) && !Is_True(player.PlayerMountCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Drop Camera Is Enabled");
    
    if(Is_True(player.DeadOpsView) && !Is_True(player.PlayerMountCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Dead Ops View Is Enabled");
    
    if(tag != "Disable")
    {
        tagOrigin = player GetTagOrigin(tag);

        if(!isDefined(tagOrigin))
            return self iPrintlnBold("^1ERROR: ^7Couldn't Find Tag On Player");
        
        if(Is_True(player.PlayerMountCamera))
            PlayerMountCamera("Disable", player);
    }

    player.PlayerMountCamera = BoolVar(player.PlayerMountCamera);
    
    if(tag != "Disable")
    {
        player.camlinker = SpawnScriptModel(tagOrigin + (AnglesToForward(player GetPlayerAngles()) * 9), "tag_origin");
        player.camlinker LinkToBlendToTag(player, tag);

        player CameraSetPosition(player.camlinker);
        player CameraActivate(true);
    }
    else
    {
        player CameraActivate(false);
        
        if(isDefined(player.camlinker))
            player.camlinker delete();
    }
}

PlayerDropCamera(player)
{
    player endon("disconnect");
    
    if(Is_True(player.SpecNade) && !Is_True(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(Is_True(player.PlayerMountCamera) && !Is_True(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Mount Camera Is Enabled");
    
    if(Is_True(player.DeadOpsView) && !Is_True(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Dead Ops View Is Enabled");
    
    player.DropCamera = BoolVar(player.DropCamera);
    
    if(Is_True(player.DropCamera))
    {
        player.camlinker = SpawnScriptModel(player GetTagOrigin("j_head"), "tag_origin");

        player CameraSetLookAt(player);
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

DeadOpsView(player)
{
    if(!Is_Alive(player) && !Is_True(player.DeadOpsView))
        return iPrintlnBold("^1ERROR: ^7Player Needs To Be Alive To Enable Dead Ops View");
    
    if(Is_True(player.SpecNade) && !Is_True(player.DeadOpsView))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(Is_True(player.DropCamera) && !Is_True(player.DeadOpsView))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Drop Camera Is Enabled");
    
    player.DeadOpsView = BoolVar(player.DeadOpsView);
    
    if(Is_True(player.DeadOpsView))
    {
        player endon("disconnect");
        
        tracePosition    = BulletTrace(player.origin, player.origin + (0, 0, 350), 0, player)["position"];
        player.camlinker = SpawnScriptModel(tracePosition, "tag_origin", (90, 90, 0));
        
        player CameraSetPosition(player.camlinker);
        player CameraSetLookat(player.camlinker);
        player CameraActivate(true);
        
        while(Is_True(player.DeadOpsView))
        {
            if(IsAlive(player))
            {
                tracePosition = BulletTrace(player.origin, player.origin + (0, 0, 350), 0, player)["position"];
                
                if(isDefined(player.camlinker) && player.camlinker.origin != tracePosition)
                    player.camlinker.origin = tracePosition;
            }
            
            wait 0.01;
        }
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
    if(Is_True(player.AdventureTime))
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

    if(Is_True(player.AdventureTime))
        player.AdventureTime = BoolVar(player.AdventureTime);
}

SendEarthquake(player)
{
    Earthquake(1, 15, player.origin, 750);
}

IceSkating(player)
{
    player.IceSkating = BoolVar(player.IceSkating);
    player ForceSlick(Is_True(player.IceSkating));
}

ForgeMode(player)
{
    player endon("disconnect");

    if(Is_True(player.DeleteGun))
        player DeleteGun(player);
    
    if(Is_True(player.GravityGun))
        player GravityGun(player);
    
    player.ForgeMode = BoolVar(player.ForgeMode);

    if(Is_True(player.ForgeMode))
    {
        player iPrintlnBold("Aim At Entities/Zombies/Players To Pick Them Up");
        player iPrintlnBold("[{+attack}] To Release");
        
        grabEnt = undefined;

        while(Is_True(player.ForgeMode))
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

                if(isDefined(trace["entity"]) && trace["entity"].model != "tag_origin")
                    grabEnt = trace["entity"];
            }

            wait 0.01;
        }
    }
}

SpecNade(player) //Credit to Extinct for his spec-nade
{
    player endon("disconnect");
    player endon("EndSpecNade");
    
    if(player isPlayerLinked() && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(Is_True(player.NoclipBind1) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Noclip Bind Is Enabled");
    
    if(Is_True(player.DropCamera) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Drop Camera Is Enabled");
    
    if(Is_True(player.DeadOpsView) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Dead Ops View Is Enabled");
    
    if(Is_True(player.PlayerMountCamera) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Mount Camera Is Enabled");
    
    player.SpecNade = BoolVar(player.SpecNade);

    if(Is_True(player.SpecNade))
    {
        while(Is_True(player.SpecNade))
        {
            player waittill("grenade_fire", grenade, weapon);
            
            if(zm_utility::is_placeable_mine(weapon) || player isPlayerLinked() || !isDefined(grenade))
                continue;
            
            player.nadelinker = SpawnScriptModel(grenade.origin - AnglesToForward(grenade.angles) * 50, "tag_origin");
            player.nadelinker LinkToBlendToTag(grenade, "tag_origin");

            player.ignoreme = true;
            player Hide();

            player CameraSetPosition(player.nadelinker);
            player CameraSetLookAt(grenade);
            player CameraActivate(true);

            grenade SpecNadeFollow(player.nadelinker);

            player CameraActivate(false);
            player.nadelinker delete();

            if(Is_True(player.ignoreme))
                player.ignoreme = BoolVar(player.ignoreme);
            
            if(!Is_True(player.Invisibility))
                player Show();
        }
    }
    else
    {
        if(isDefined(player.nadelinker))
        {
            player CameraActivate(false);
            player.nadelinker delete();
            
            if(!Is_True(player.Invisibility))
                player Show();
        }

        if(Is_True(player.ignoreme))
            player.ignoreme = BoolVar(player.ignoreme);
        
        player notify("EndSpecNade");
    }
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
    player endon("disconnect");
    player endon("EndNukeNades");

    player.NukeNades = BoolVar(player.NukeNades);
    
    if(Is_True(player.NukeNades))
    {
        while(Is_True(player.NukeNades))
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
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || Distance(origin, zombies[a].origin) > 500)
            continue;
        
        zombies[a].ZombieFling = true;
        zombies[a] clientfield::increment("zm_nuked");
        wait 0.1;

        zombies[a] DoDamage((zombies[a].health + 666), origin);
    }
}

ShootPowerUps(player)
{
    player endon("disconnect");
    player endon("EndShootPowerUps");

    player.ShootPowerUps = BoolVar(player.ShootPowerUps);
    
    if(Is_True(player.ShootPowerUps))
    {
        while(Is_True(player.ShootPowerUps))
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
    player endon("disconnect");
    player endon("EndCodJumper");

    player.CodJumper = BoolVar(player.CodJumper);
    
    if(Is_True(player.CodJumper))
    {
        player.codboxes = [];

        while(Is_True(player.CodJumper))
        {
            player waittill("weapon_fired");
            
            if(isDefined(player.codboxes) && player.codboxes.size)
                for(a = 0; a < player.codboxes.size; a++)
                    if(isDefined(player.codboxes[a]))
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
    }
    else
    {
        if(isDefined(player.codboxes) && player.codboxes.size)
            foreach(box in player.codboxes)
                if(isDefined(box))
                    box delete();
        
        player notify("EndCodJumper");
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
    player endon("disconnect");
    player endon("EndClusterGrenades");

    player.ClusterGrenades = BoolVar(player.ClusterGrenades);
    
    if(Is_True(player.ClusterGrenades))
    {
        while(Is_True(player.ClusterGrenades))
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
    player endon("disconnect");

    player.UnlimitedSpecialist = BoolVar(player.UnlimitedSpecialist);

    while(Is_True(player.UnlimitedSpecialist))
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
    player endon("disconnect");
    player endon("EndRocketRiding");

    player.RocketRiding = BoolVar(player.RocketRiding);
    
    if(Is_True(player.RocketRiding))
    {
        while(Is_True(player.RocketRiding))
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
            
            if(Is_True(rider.RidingRocket))
            {
                rider notify("StopRidingRocket");
                rider Unlink();
                rider.RocketRidingLinker delete();
                rider.RidingRocket = BoolVar(rider.RidingRocket);
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
    
    if(Is_True(self.RidingRocket))
        self.RidingRocket = BoolVar(self.RidingRocket);
}

GrapplingGun(player)
{
    player endon("disconnect");
    player endon("EndGrapplingGun");
    
    player.GrapplingGun = BoolVar(player.GrapplingGun);

    if(Is_True(player.GrapplingGun))
    {
        while(Is_True(player.GrapplingGun))
        {
            player waittill("weapon_fired");
            
            trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 0, player);
            
            origin = trace["position"];
            surface = trace["surfacetype"];

            if(surface == "none" || surface == "default" || isDefined(player.grapplingent))
                continue;
            
            player.grapplingent = SpawnScriptModel(player.origin, "tag_origin");

            if(!isDefined(player.grapplingent))
                continue;

            player PlayerLinkTo(player.grapplingent);
            player.grapplingent MoveTo(origin, 1);

            player.grapplingent waittill("movedone");

            if(!isDefined(player.grapplingent))
                continue;
            
            player Unlink();
            player.grapplingent delete();
        }
    }
    else
    {
        if(isDefined(player.grapplingent))
            player.grapplingent delete();
        
        player notify("EndGrapplingGun");
    }
}

GravityGun(player)
{
    player endon("disconnect");

    if(Is_True(player.DeleteGun))
        player DeleteGun(player);
    
    if(Is_True(player.ForgeMode))
        player ForgeMode(player);
    
    player.GravityGun = BoolVar(player.GravityGun);

    if(Is_True(player.GravityGun))
    {
        player iPrintlnBold("Aim At Entities/Zombies/Players To Pick Them Up");
        player iPrintlnBold("[{+attack}] To Launch");

        grabEnt = undefined;
        
        while(Is_True(player.GravityGun))
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

                if(isDefined(trace["entity"]) && !Is_True(trace["entity"].GravityGunLaunched) && trace["entity"].model != "tag_origin")
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

    if(isDefined(self) && Is_True(self.GravityGunLaunched))
        self.GravityGunLaunched = BoolVar(self.GravityGunLaunched);
}

DeleteGun(player)
{
    player endon("disconnect");

    if(Is_True(player.GravityGun))
        player GravityGun(player);
    
    if(Is_True(player.ForgeMode))
        player ForgeMode(player);
    
    player.DeleteGun = BoolVar(player.DeleteGun);

    if(Is_True(player.DeleteGun))
    {
        player iPrintlnBold("Aim At Entities/Zombies To Delete Them");
        
        while(Is_True(player.DeleteGun))
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
    player endon("disconnect");
    player endon("EndRapidFire");

    player.RapidFire = BoolVar(player.RapidFire);
    
    if(Is_True(player.RapidFire))
    {
        while(Is_True(player.RapidFire))
        {
            player waittill("weapon_fired");

            weapon = player GetCurrentWeapon();

            if(!isDefined(weapon) || weapon == level.weaponnone)
                continue;

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

ExtraGore(player)
{
    player.ExtraGore = BoolVar(player.ExtraGore);
}

ShowHitmarkers(player)
{
    player.ShowHitmarkers = BoolVar(player.ShowHitmarkers);
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

    if(isDefined(player.hud_damagefeedback) && IsVec(color))
        player.hud_damagefeedback.color = color;
}

PowerUpMagnet(player)
{
    player endon("disconnect");
        
    player.PowerUpMagnet = BoolVar(player.PowerUpMagnet);
    
    while(Is_True(player.PowerUpMagnet))
    {
        powerups = zm_powerups::get_powerups(player.origin, 500);

        if(isDefined(powerups) && powerups.size)
        {
            foreach(index, powerup in powerups)
            {
                if(isDefined(powerup) && BulletTracePassed(player GetEye(), powerup.origin, 0, player) && !Is_True(powerup.movingtoplayer))
                {
                    powerup.movingtoplayer = true;
                    powerup MoveTo(player GetTagOrigin("j_mainroot"), CalcDistance(1100, powerup.origin, player GetTagOrigin("j_mainroot")));

                    wait 0.05;

                    if(isDefined(powerup) && Is_True(powerup.movingtoplayer)) //making sure the powerup still exists
                        powerup.movingtoplayer = BoolVar(powerup.movingtoplayer);
                }
            }
        }

        wait 0.1;
    }
}

PlayerInstaKill(type, player)
{
    if(isDefined(player.PlayerInstaKill) && type == "Disable")
        player.PlayerInstaKill = undefined;
    else if(type != "Disable")
        player.PlayerInstaKill = type;
}

DisableEarningPoints(player)
{
    player.DisableEarningPoints = BoolVar(player.DisableEarningPoints);
}

DamagePointsMultiplier(multiplier, player)
{
    player.DamagePointsMultiplier = multiplier;
}