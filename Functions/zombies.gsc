PopulateZombieOptions(menu)
{
    switch(menu)
    {
        case "Zombie Options":
            self addMenu("Zombie Options");
                self addOpt("Spawner", ::newMenu, "AI Spawner");
                self addOpt("Prioritize", ::newMenu, "Prioritize Players");
                self addOpt("Death Effect", ::newMenu, "Zombie Death Effect");
                self addOpt("Damage Effect", ::newMenu, "Zombie Damage Effect");
                self addOpt("Animations", ::newMenu, "Zombie Animations");
                self addOpt("Model", ::newMenu, "Zombie Model Manipulation");
                self addOptSlider("Gib", ::ZombieGibBone, "Random;Head;Right Leg;Left Leg;Right Arm;Left Arm");
                self addOptSlider("Kill", ::KillZombies, "Death;Head Gib;Flame;Delete");
                self addOptSlider("Health", ::SetZombieHealth, "Custom;Reset");
                self addOptSlider("Movement", ::SetZombieRunSpeed, "Walk;Run;Sprint;Super Sprint");
                self addOptIncSlider("Animation Speed", ::SetZombieAnimationSpeed, 1, 1, 2, 0.5);

                //The only map Knockdown isn't registered on is The Giant
                if(ReturnMapName(level.script) != "The Giant")
                    self addOptSlider("Knockdown", ::KnockdownZombies, "Front;Back");

                //Push is only registered on SOE
                if(ReturnMapName(level.script) == "Shadows Of Evil")
                    self addOptSlider("Push", ::PushZombies, "Left;Right");
                
                self addOptSlider("Teleport", ::TeleportZombies, "Crosshairs;Self");
                self addOptBool(level.ZombiesToCrosshairsLoop, "Teleport To Crosshairs", ::ZombiesToCrosshairsLoop);
                self addOptBool((GetDvarString("ai_disableSpawn") == "1"), "Disable Spawning", ::DisableZombieSpawning);
                self addOptBool(level.DisableZombieCollision, "Disable Player Collision", ::DisableZombieCollision);
                self addOptBool(level.DisableZombiePush, "Disable Push", ::DisableZombiePush);
                self addOptBool(level.ZombiesInvisibility, "Invisibility", ::ZombiesInvisibility);
                self addOptBool((GetDvarString("g_ai") == "0"), "Freeze", ::FreezeZombies);
                self addOptBool(level.ZombieProjectileVomiting, "Projectile Vomit", ::ZombieProjectileVomiting);
                self addOptBool(level.DisappearingZombies, "Disappearing Zombies", ::DisappearingZombies);
                self addOptBool(level.ExplodingZombies, "Exploding Zombies", ::ExplodingZombies);
                self addOptBool(level.ZombieRagdoll, "Ragdoll After Death", ::ZombieRagdoll);
                self addOptBool(level.StackZombies, "Stack Zombies", ::StackZombies);
                self addOpt("Make Crawlers", ::ForceZombieCrawlers);
                self addOpt("Detach Heads", ::DetachZombieHeads);
                self addOpt("Clear All Corpses", ::ServerClearCorpses);
            break;
        
        case "AI Spawner":
            if(!isDefined(self.AISpawnLocation))
                self.AISpawnLocation = "Crosshairs";
            
            map = ReturnMapName(level.script);
            
            self addMenu("Spawner");
                self addOptSlider("Spawn Location", ::AISpawnLocation, "Crosshairs;Random;Self");
                self addOptIncSlider("Spawn Zombie", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnZombie);

                if(map != "Unknown")
                {
                    maps = ["Shi No Numa", "The Giant", "Moon", "Kino Der Toten", "Der Eisendrache"];

                    if(isInArray(maps, map))
                        self addOptIncSlider("Spawn Hellhound", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnDog);
                    
                    maps = ["Shadows Of Evil", "Revelations", "Gorod Krovi"];

                    if(isInArray(maps, map))
                    {
                        if(map != "Gorod Krovi")
                        {
                            self addOptIncSlider("Spawn Wasp", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnWasp);
                            self addOptIncSlider("Spawn Margwa", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMargwa);

                            if(map == "Shadows Of Evil")
                                self addOptIncSlider("Spawn Civil Protector", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnCivilProtector);
                        }
                        
                        if(map != "Revelations")
                            self addOptIncSlider("Spawn Raps", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnRaps);
                    }

                    maps = ["Origins", "Der Eisendrache", "Revelations"];

                    if(isInArray(maps, map))
                        self addOptIncSlider("Spawn Mechz", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMechz);
                    
                    if(map == "Gorod Krovi")
                    {
                        self addOptIncSlider("Spawn Sentinel Drone", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnSentinelDrone);
                        self addOptIncSlider("Spawn Mangler", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMangler);
                    }

                    if(map == "Zetsubou No Shima" || map == "Revelations")
                    {
                        if(map == "Zetsubou No Shima")
                            self addOptIncSlider("Spawn Thrasher", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnThrasher);
                        
                        self addOptIncSlider("Spawn Spider", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnSpider);
                    }

                    if(map == "Revelations")
                        self addOptIncSlider("Spawn Fury", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnFury);
                    
                    if(map == "Kino Der Toten")
                        self addOptIncSlider("Spawn Nova Zombie", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnNovaZombie);
                }
            break;
        
        case "Prioritize Players":
            self addMenu("Prioritize Players");
            
                foreach(player in level.players)
                    self addOptBool(player.AIPrioritizePlayer, CleanName(player getName()), ::AIPrioritizePlayer, player);
            break;
        
        case "Zombie Model Manipulation":
            self addMenu("Model Manipulation");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    self addOptBool(!isDefined(level.ZombieModel), "Disable", ::DisableZombieModel);
                    self addOpt("");

                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOptBool(level.ZombieModel == level.MenuModels[a], CleanString(level.MenuModels[a]), ::SetZombieModel, level.MenuModels[a]);
                }
            break;
        
        case "Zombie Animations":

            //These are base animations that will work on every map
            anims = ["ai_zombie_base_ad_attack_v1", "ai_zombie_base_ad_attack_v2", "ai_zombie_base_ad_attack_v3", "ai_zombie_base_ad_attack_v4", "ai_zombie_taunts_4"];
            notifies = ["attack_anim", "attack_anim", "attack_anim", "attack_anim", "taunt_anim"];

            //These are the animations that are map specific
            if(ReturnMapName(level.script) == "Origins")
            {
                add_anims = ["ai_zombie_mech_ft_burn_player", "ai_zombie_mech_exit", "ai_zombie_mech_exit_hover", "ai_zombie_mech_arrive"];
                add_notifies = ["flamethrower_anim", "zm_fly_out", "zm_fly_hover_finished", "zm_fly_in"];
            }
            
            if(isDefined(add_anims) && add_anims.size)
            {
                anims = ArrayCombine(anims, add_anims, 0, 1);
                notifies = ArrayCombine(notifies, add_notifies, 0, 1);
            }

            self addMenu("Animations");

                for(a = 0; a < anims.size; a++)
                    self addOpt(CleanString(anims[a]), ::ZombieAnimScript, anims[a], notifies[a]);
            break;
        
        case "Zombie Death Effect":
            
            if(!isDefined(level.ZombiesDeathFX))
                level.ZombiesDeathFX = level.MenuEffects[0];
            
            self addMenu("Death Effect");
                self addOptBool(level.ZombiesDeathEffect, "Death Effect", ::ZombiesDeathEffect);
                self addOpt("");

                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOptBool((level.ZombiesDeathFX == level.MenuEffects[a].name), level.MenuEffects[a].displayName, ::SetZombiesDeathEffect, level.MenuEffects[a].name);
            break;

        case "Zombie Damage Effect":

            if(!isDefined(level.ZombiesDamageFX))
                level.ZombiesDamageFX = level.MenuEffects[0];
            
            self addMenu("Damage Effect");
                self addOptBool(level.ZombiesDamageEffect, "Damage Effect", ::ZombiesDamageEffect);
                self addOpt("");

                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOptBool((level.ZombiesDamageFX == level.MenuEffects[a].name), level.MenuEffects[a].displayName, ::SetZombiesDamageEffect, level.MenuEffects[a].name);
            break;
    }
}

AIPrioritizePlayer(player)
{
    player.AIPrioritizePlayer = isDefined(player.AIPrioritizePlayer) ? undefined : true;

    if(isDefined(player.AIPrioritizePlayer))
    {
        player endon("disconnect");

        while(isDefined(player.AIPrioritizePlayer))
        {
            if(!isDefined(player.b_is_designated_target) || !player.b_is_designated_target)
                player.b_is_designated_target = true;
            
            wait 0.1;
        }
    }
    else
        player.b_is_designated_target = false;
}

SetZombieHealth(type)
{
    switch(type)
    {
        case "Custom":
            self thread NumberPad(::EditZombieHealth);
            break;
        
        case "Reset":
            level notify("EndZombieHealth");
            level thread EditZombieHealth();
            break;
        
        default:
            break;
    }
}

EditZombieHealth(health)
{
    level notify("EndZombieHealth");
    level endon("EndZombieHealth");
    
    if(isDefined(health) && health)
    {
        while(1)
        {
            level SetZombieHealth1(health);
            wait 0.1;
        }
    }
    else
        level SetZombieHealth1(GetZombieHealthFromRound(level.round_number));
}

GetZombieHealthFromRound(round_number)
{
    zombie_health = level.zombie_vars["zombie_health_start"];

    for(a = 2; a <= round_number; a++)
    {
        if(a >= 10)
        {
            old_health = zombie_health;
            zombie_health = zombie_health + (Int(level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"]));

            if(level.zombie_health < old_health)
                return old_health;
        }
        else
            zombie_health = Int(zombie_health + level.zombie_vars["zombie_health_increase"]);
    }

    return zombie_health;
}

SetZombieHealth1(health)
{
    level.zombie_health = health;
    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || zombies[a].maxhealth == health)
            continue;
        
        zombies[a].maxhealth = health;
        zombies[a].health = zombies[a].maxhealth;
    }
}

KillZombies(type)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        switch(type)
        {
            case "Head Gib":
                zombies[a] thread zombie_utility::zombie_head_gib();
                break;
            
            case "Flame":
                zombies[a] thread zombie_death::flame_death_fx();
                break;
            
            case "Delete":
                zombies[a] delete();
                break;
            
            default:
                break;
        }
        
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] DoDamage((zombies[a].health + 666), zombies[a].origin);
    }
}

SetZombieRunSpeed(speed)
{
    speed = ToLower(speed);

    if(speed == "super sprint")
        speed = "super_sprint";

    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] zombie_utility::set_zombie_run_cycle(speed);
}

SetZombieAnimationSpeed(rate)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        zombies[a] thread ZombieAnimationWait(rate);
    }

    spawner::remove_global_spawn_function("zombie", ::ZombieAnimationWait);
    spawner::add_archetype_spawn_function("zombie", ::ZombieAnimationWait, rate);
}

ZombieAnimationWait(rate)
{
    while(!self CanControl() && IsAlive(self))
        wait 0.1;
    
    if(IsAlive(self))
        self ASMSetAnimationRate(rate);
}

ForceZombieCrawlers()
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        zombies[a] zombie_utility::makezombiecrawler(true);
}

ZombieGibBone(bone)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        switch(bone)
        {
            case "Random":
                switch(RandomInt(5))
                {
                    case 0:
                        zombies[a] thread zombie_utility::zombie_head_gib();
                        break;
                    
                    case 1:
                        thread gibserverutils::gibrightleg(zombies[a]);
                        break;
                    
                    case 2:
                        thread gibserverutils::gibleftleg(zombies[a]);
                        break;
                    
                    case 3:
                        thread gibserverutils::gibrightarm(zombies[a]);
                        break;
                    
                    case 4:
                        thread gibserverutils::gibleftarm(zombies[a]);
                        break;
                    
                    default:
                        zombies[a] thread zombie_utility::zombie_head_gib();
                        break;
                }
                break;
            
            case "Head":
                zombies[a] thread zombie_utility::zombie_head_gib();
                break;
            
            case "Right Leg":
                thread gibserverutils::gibrightleg(zombies[a]);
                break;
            
            case "Left Leg":
                thread gibserverutils::gibleftleg(zombies[a]);
                break;
            
            case "Right Arm":
                thread gibserverutils::gibrightarm(zombies[a]);
                break;
            
            case "Left Arm":
                thread gibserverutils::gibleftarm(zombies[a]);
                break;
            
            default:
                zombies[a] thread zombie_utility::zombie_head_gib();
                break;
        }
    }
}

SetZombieModel(model)
{
    level notify("EndZombieModel");
    level endon("EndZombieModel");

    if(model != level.ZombieModel)
    {
        level.ZombieModel = model;

        while(isDefined(level.ZombieModel))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
                if(isDefined(zombies[a]) && IsAlive(zombies[a]) && zombies[a].model != level.ZombieModel)
                {
                    if(!isDefined(zombies[a].savedModel))
                        zombies[a].savedModel = zombies[a].model;
                    
                    zombies[a] SetModel(level.ZombieModel);
                }
            
            wait 0.1;
        }
    }
    else
        level DisableZombieModel();
}

DisableZombieModel()
{
    level notify("EndZombieModel");
    
    level.ZombieModel = undefined;
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]) && isDefined(zombies[a].savedModel))
            zombies[a] SetModel(zombies[a].savedModel);
}

ZombieAnimScript(anm, ntfy)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        zombies[a] StopAnimScripted(0);
        zombies[a] AnimScripted(ntfy, zombies[a].origin, zombies[a].angles, anm);
    }
}

DisableZombieSpawning()
{
    SetDvar("ai_disableSpawn", (GetDvarString("ai_disableSpawn") == "0") ? "1" : "0");
    KillZombies();
}

TeleportZombies(loc)
{
    origin = self.origin;

    if(loc == "Crosshairs")
        origin = self TraceBullet();
    
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]))
        {
            zombies[a] StopAnimScripted(0);
            zombies[a] ForceTeleport(origin);
            zombies[a].find_flesh_struct_string = "find_flesh";
            zombies[a].ai_state = "find_flesh";
            zombies[a] notify("zombie_custom_think_done", "find_flesh");
        }
    }
}

ZombiesToCrosshairsLoop()
{
    level.ZombiesToCrosshairsLoop = isDefined(level.ZombiesToCrosshairsLoop) ? undefined : true;

    origin = self TraceBullet();

    while(isDefined(level.ZombiesToCrosshairsLoop))
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
            if(isDefined(zombies[a]))
            {
                zombies[a] StopAnimScripted(0);
                zombies[a] ForceTeleport(origin);
            }

        wait 0.05;
    }
}

DisableZombieCollision()
{
    level.DisableZombieCollision = isDefined(level.DisableZombieCollision) ? undefined : true;

    if(isDefined(level.DisableZombieCollision))
    {
        while(isDefined(level.DisableZombieCollision))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isDefined(zombies[a].DisableCollision))
                    continue;
                
                zombies[a] SetPlayerCollision(0);
                zombies[a].DisableCollision = true;
            }

            wait 0.1;
        }
    }
    else
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
                continue;
            
            zombies[a] SetPlayerCollision(1);
            zombies[a].DisableCollision = undefined;
        }
    }
}

DisableZombiePush()
{
    level.DisableZombiePush = isDefined(level.DisableZombiePush) ? undefined : true;

    if(isDefined(level.DisableZombiePush))
    {
        while(isDefined(level.DisableZombiePush))
        {
            foreach(player in level.players)
                player SetClientPlayerPushAmount(0);

            wait 0.1;
        }
    }
    else
    {
        foreach(player in level.players)
            player SetClientPlayerPushAmount(1);
    }
}

ZombiesInvisibility()
{
    level.ZombiesInvisibility = isDefined(level.ZombiesInvisibility) ? undefined : true;

    if(isDefined(level.ZombiesInvisibility))
    {
        while(isDefined(level.ZombiesInvisibility))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
                if(isDefined(zombies[a]) && IsAlive(zombies[a]))
                    zombies[a] Hide();

            wait 0.5;
        }
    }
    else
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
            if(isDefined(zombies[a]) && IsAlive(zombies[a]))
                zombies[a] Show();
    }
}

ZombieProjectileVomiting()
{
    level.ZombieProjectileVomiting = isDefined(level.ZombieProjectileVomiting) ? undefined : true;

    while(isDefined(level.ZombieProjectileVomiting))
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isDefined(zombies[a].ProjectileVomit))
                continue;
            
            zombies[a] thread ZombieProjectileVomit();
        }

        wait 0.1;
    }
}

ZombieProjectileVomit()
{
    if(!isDefined(self) || !IsAlive(self) || isDefined(self.ProjectileVomit))
        return;
    
    self endon("death");
    
    self.ProjectileVomit = true;
    self clientfield::increment("projectile_vomit", 1);
    wait 6;

    self.ProjectileVomit = undefined;
}

FreezeZombies()
{
    SetDvar("g_ai", (GetDvarString("g_ai") == "1") ? "0" : "1");
}

DisappearingZombies()
{
    level.DisappearingZombies = isDefined(level.DisappearingZombies) ? undefined : true;

    if(isDefined(level.DisappearingZombies))
    {
        while(isDefined(level.DisappearingZombies))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!IsAlive(zombies[a]) && isDefined(zombies[a].disappearing))
                    continue;
                
                zombies[a] thread DisappearingZombie();
            }

            wait 0.01;
        }
    }
    else
    {
        level notify("EndDisappearingZombies");
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
                continue;
            
            zombies[a].disappearing = undefined;

            if(!isDefined(level.ZombiesInvisibility))
                zombies[a] Show();
            else
                zombies[a] Hide();
        }
    }
}

DisappearingZombie()
{
    if(!isDefined(self) || !IsAlive(self))
        return;
    
    self.disappearing = true;
    level endon("EndDisappearingZombies");
    
    while(isDefined(self) && IsAlive(self))
    {
        if(isDefined(self) && IsAlive(self))
            self Hide();
        
        wait RandomFloatRange(3, 5);

        if(isDefined(self) && IsAlive(self))
            self Show();
        
        wait RandomFloatRange(3, 5);
    }
}

ExplodingZombies()
{
    level.ExplodingZombies = isDefined(level.ExplodingZombies) ? undefined : true;

    if(isDefined(level.ExplodingZombies))
    {
        while(isDefined(level.ExplodingZombies))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!IsAlive(zombies[a]) || isDefined(zombies[a].explodingzombie))
                    continue;
                
                zombies[a].explodingzombie = true;

                zombies[a] clientfield::set("arch_actor_fire_fx", 1);
                zombies[a] clientfield::set("napalm_sfx", 1);
            }
            
            wait 0.01;
        }
    }
    else
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            zombies[a] clientfield::set("arch_actor_fire_fx", 0);
            zombies[a] clientfield::set("napalm_sfx", 0);

            zombies[a].explodingzombie = undefined;
        }
    }
}

ZombieRagdoll()
{
    level.ZombieRagdoll = isDefined(level.ZombieRagdoll) ? undefined : true;
}

StackZombies()
{
    level.StackZombies = isDefined(level.StackZombies) ? undefined : true;

    if(isDefined(level.StackZombies))
    {
        while(isDefined(level.StackZombies))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isDefined(zombies[a].stacked) || !zombies[a] CanControl())
                    continue;
                
                tag = "tag_origin"; //Had to choose a tag that doesn't move/rotate
                tagCheck = zombies[a] GetTagOrigin(tag); //Gonna be used to make sure it's a valid tag for the ai
                offset = (0, 0, 70); //(x, y, z) offset for the given tag

                if(!isDefined(tagCheck))
                {
                    tag = "tag_body"; //Backup tag for ai that don't have the default tag given
                    tagCheck = zombies[a] GetTagOrigin(tag);
                }

                if(!isDefined(tagCheck)) //If the backup tag can't be used for the AI, then it will be skipped
                    continue;
                
                bottom = zombies[a];

                for(b = 0; b < zombies.size; b++)
                {
                    if(!isDefined(zombies[b]) || !IsAlive(zombies[b]) || isDefined(zombies[b].stacked) || !zombies[a] CanControl())
                        continue;
                    
                    top = zombies[b];
                }

                if(isDefined(bottom) && isDefined(top) && isDefined(tag))
                {
                    top LinkTo(bottom, tag, offset);
                    bottom thread StackedZombieWatcher(top);

                    top.stacked = true;
                    bottom.stacked = true;
                }
            }

            wait 1;
        }
    }
    else
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || !isDefined(zombies[a].stacked))
                continue;
            
            zombies[a] Unlink();
            zombies[a].stacked = undefined;
        }

        level notify("EndStackZombies");
    }
}

StackedZombieWatcher(top)
{
    if(!isDefined(self) || !IsAlive(self) || !isDefined(top) || !IsAlive(top))
        return;
    
    level endon("EndStackZombies");
    top endon("death");

    self waittill("death");

    if(isDefined(top) && IsAlive(top))
        top Unlink();
}

ZombiesDeathEffect()
{
    level.ZombiesDeathEffect = isDefined(level.ZombiesDeathEffect) ? undefined : true;
}

SetZombiesDeathEffect(effect)
{
    level.ZombiesDeathFX = effect;
}

ZombiesDamageEffect()
{
    level.ZombiesDamageEffect = isDefined(level.ZombiesDamageEffect) ? undefined : true;
}

SetZombiesDamageEffect(effect)
{
    level.ZombiesDamageFX = effect;
}

DetachZombieHeads()
{
    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] DetachAll();
}

KnockdownZombies(dir)
{
    switch(dir)
    {
        case "Front":
            knockDir = "front";
            upDir = "getup_back";
            break;
        
        case "Back":
        
        default:
            knockDir = "back";
            upDir = "getup_belly";
            break;
    }

    zombies = GetAITeamArray(level.zombie_team);
    
    foreach(zombie in zombies)
    {
        if(!isDefined(zombie) || !IsAlive(zombie) || zombie.missinglegs || isDefined(zombie.knockdown) && zombie.knockdown)
            continue;
        
        zombie.knockdown = 1;
        zombie.knockdown_direction = knockDir;
        zombie.getup_direction = upDir;
        zombie.knockdown_type = "knockdown_shoved";

        BlackBoardAttribute(zombie, "_knockdown_direction", zombie.knockdown_direction);
        BlackBoardAttribute(zombie, "_knockdown_type", zombie.knockdown_type);
        BlackBoardAttribute(zombie, "_getup_direction", zombie.getup_direction);
    }
}

PushZombies(dir)
{
    zombies = GetAITeamArray(level.zombie_team);
    
    foreach(zombie in zombies)
    {
        if(!isDefined(zombie) || !IsAlive(zombie) || zombie.missinglegs || isDefined(zombie.pushed) && zombie.pushed)
            continue;
        
        zombie.pushed = 1;
        zombie.push_direction = ToLower(dir);

        BlackBoardAttribute(zombie, "_push_direction", zombie.push_direction);
    }
}

BlackBoardAttribute(entity, attributename, attributevalue)
{
    if(isDefined(entity.__blackboard[attributename]))
		if(!isDefined(attributevalue) && IsFunctionPtr(entity.__blackboard[attributename]))
			return;

    entity.__blackboard[attributename] = attributevalue;
}

ServerClearCorpses()
{
    corpse_array = GetCorpseArray();

    if(isDefined(corpse_array) && corpse_array.size)
        for(a = 0; a < corpse_array.size; a++)
            if(isDefined(corpse_array[a]))
                corpse_array[a] delete();
}