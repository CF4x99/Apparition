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
                
                //The only map Knockdown isn't registered on is The Giant
                if(ReturnMapName() != "The Giant")
                    self addOptSlider("Knockdown", ::KnockdownZombies, "Front;Back");

                //Push is only registered on SOE
                if(ReturnMapName() == "Shadows Of Evil")
                    self addOptSlider("Push", ::PushZombies, "Left;Right");
                
                self addOptSlider("Teleport", ::TeleportZombies, "Crosshairs;Self");
                self addOptIncSlider("Animation Speed", ::SetZombieAnimationSpeed, 1, 1, 2, 0.5);
                self addOptBool(level.ZombiesToCrosshairsLoop, "Teleport To Crosshairs", ::ZombiesToCrosshairsLoop);
                self addOptBool(level.DisableZombieCollision, "Disable Player Collision", ::DisableZombieCollision);
                self addOptBool((GetDvarString("ai_disableSpawn") == "1"), "Disable Spawning", ::DisableZombieSpawning);
                self addOptBool(level.DisableZombiePush, "Disable Push", ::DisableZombiePush);
                self addOptBool(level.ZombiesInvisibility, "Invisibility", ::ZombiesInvisibility);
                self addOptBool((GetDvarString("g_ai") == "0"), "Freeze", ::FreezeZombies);
                self addOptBool(level.ZombieDeathSounds, "Death Sounds", ::ZombieDeathSounds);
                self addOptBool(level.ZombieProjectileVomiting, "Projectile Vomit", ::ZombieProjectileVomiting);
                self addOptBool(level.DisappearingZombies, "Disappearing Zombies", ::DisappearingZombies);
                self addOptBool(level.ExplodingZombies, "Exploding Zombies", ::ExplodingZombies);
                self addOptBool(level.ZombieRagdoll, "Ragdoll After Death", ::ZombieRagdoll);
                self addOptBool(level.StackZombies, "Stack Zombies", ::StackZombies);
                self addOptBool(level.RemoveZombieEyes, "Remove Eyes", ::RemoveZombieEyes);
                self addOptBool((GetDvarVector("phys_gravity_dir") == (0, 0, -1)), "Bodies Float", ::BodiesFloat);
                self addOpt("Make Crawlers", ::ForceZombieCrawlers);
                self addOpt("Detach Heads", ::DetachZombieHeads);
                self addOpt("Clear All Corpses", ::ServerClearCorpses);
            break;
        
        case "AI Spawner":
            if(!isDefined(self.AISpawnLocation))
                self.AISpawnLocation = "Crosshairs";
            
            map = ReturnMapName();
            
            self addMenu("Spawner");
                self addOptSlider("Spawn Location", ::AISpawnLocation, "Crosshairs;Random;Self");
                self addOptIncSlider("Zombie", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnZombie);

                if(map != "Unknown")
                {
                    maps = Array("Shi No Numa", "The Giant", "Moon", "Kino Der Toten", "Der Eisendrache");

                    if(isInArray(maps, map))
                        self addOptIncSlider("Hellhound", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnDog);
                    
                    maps = Array("Shadows Of Evil", "Revelations", "Gorod Krovi");

                    if(isInArray(maps, map))
                    {
                        if(map != "Gorod Krovi")
                        {
                            self addOptIncSlider("Wasp", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnWasp);
                            self addOptIncSlider("Margwa", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMargwa);

                            if(map == "Shadows Of Evil")
                                self addOptIncSlider("Civil Protector", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnCivilProtector);
                        }
                        
                        if(map != "Revelations")
                            self addOptIncSlider("Raps", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnRaps);
                    }

                    maps = Array("Origins", "Der Eisendrache", "Revelations");

                    if(isInArray(maps, map))
                        self addOptIncSlider("Mechz", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMechz);
                    
                    if(map == "Gorod Krovi")
                    {
                        self addOptIncSlider("Sentinel Drone", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnSentinelDrone);
                        self addOptIncSlider("Mangler", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMangler);
                    }

                    if(map == "Zetsubou No Shima" || map == "Revelations")
                    {
                        if(map == "Zetsubou No Shima")
                            self addOptIncSlider("Thrasher", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnThrasher);
                        
                        self addOptIncSlider("Spider", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnSpider);
                    }

                    if(map == "Revelations")
                        self addOptIncSlider("Fury", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnFury);
                    
                    if(map == "Kino Der Toten")
                        self addOptIncSlider("Nova Zombie", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnNovaZombie);
                }
            break;
        
        case "Prioritize Players":
            self addMenu("Prioritize Players");
            
                foreach(player in level.players)
                    self addOptBool(player.AIPrioritizePlayer, CleanName(player getName()), ::AIPrioritizePlayer, player);
            break;
        
        case "Zombie Death Effect":
            
            if(!isDefined(level.ZombiesDeathFX))
                level.ZombiesDeathFX = level.MenuEffects[0];
            
            self addMenu("Death Effect");
                self addOptBool(level.ZombiesDeathEffect, "Death Effect", ::ZombiesDeathEffect);
                self addOpt("");

                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOptBool((level.ZombiesDeathFX == level.MenuEffects[a]), CleanString(level.MenuEffects[a]), ::SetZombiesDeathEffect, level.MenuEffects[a]);
            break;

        case "Zombie Damage Effect":

            if(!isDefined(level.ZombiesDamageFX))
                level.ZombiesDamageFX = level.MenuEffects[0];
            
            self addMenu("Damage Effect");
                self addOptBool(level.ZombiesDamageEffect, "Damage Effect", ::ZombiesDamageEffect);
                self addOpt("");

                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOptBool((level.ZombiesDamageFX == level.MenuEffects[a]), CleanString(level.MenuEffects[a]), ::SetZombiesDamageEffect, level.MenuEffects[a]);
            break;
        
        case "Zombie Animations":

            //These are base animations that will work on every map
            anims = Array("ai_zombie_base_ad_attack_v1", "ai_zombie_base_ad_attack_v2", "ai_zombie_base_ad_attack_v3", "ai_zombie_base_ad_attack_v4", "ai_zombie_taunts_4");
            notifies = Array("attack_anim", "attack_anim", "attack_anim", "attack_anim", "taunt_anim");

            //These are the animations that are map specific
            if(ReturnMapName() == "Origins")
            {
                add_anims = Array("ai_zombie_mech_ft_burn_player", "ai_zombie_mech_exit", "ai_zombie_mech_exit_hover", "ai_zombie_mech_arrive");
                add_notifies = Array("flamethrower_anim", "zm_fly_out", "zm_fly_hover_finished", "zm_fly_in");
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
        
        case "Zombie Model Manipulation":
            self addMenu("Model Manipulation");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    self addOptBool(!isDefined(level.ZombieModel), "Disable", ::DisableZombieModel);
                    self addOpt("");

                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOptBool((isDefined(level.ZombieModel) && level.ZombieModel == level.MenuModels[a]), CleanString(level.MenuModels[a]), ::SetZombieModel, level.MenuModels[a]);
                }
            break;
    }
}

AIPrioritizePlayer(player)
{
    player endon("disconnect");
        
    player.AIPrioritizePlayer = BoolVar(player.AIPrioritizePlayer);
    
    if(Is_True(player.AIPrioritizePlayer))
    {
        if(Is_True(player.playerIgnoreMe))
            NoTarget(player);
        
        while(Is_True(player.AIPrioritizePlayer))
        {
            if(!Is_True(player.b_is_designated_target))
                player.b_is_designated_target = true;
            
            wait 0.1;
        }
    }
    else
        player.b_is_designated_target = false;
}

ZombiesDeathEffect()
{
    level.ZombiesDeathEffect = BoolVar(level.ZombiesDeathEffect);
}

SetZombiesDeathEffect(effect)
{
    level.ZombiesDeathFX = effect;
}

ZombiesDamageEffect()
{
    level.ZombiesDamageEffect = BoolVar(level.ZombiesDamageEffect);
}

SetZombiesDamageEffect(effect)
{
    level.ZombiesDamageFX = effect;
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

SetZombieModel(model)
{
    if(isDefined(level.ZombieModel) && model != level.ZombieModel || !isDefined(level.ZombieModel))
    {
        level.ZombieModel = model;
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(isDefined(zombies[a]) && IsAlive(zombies[a]) && zombies[a].model != level.ZombieModel)
            {
                if(!isDefined(zombies[a].savedModel))
                    zombies[a].savedModel = zombies[a].model;
                
                zombies[a] SetModel(level.ZombieModel);
            }
        }

        spawner::add_archetype_spawn_function("zombie", ::SetZombieSpawnModel);
    }
    else
        DisableZombieModel();
}

SetZombieSpawnModel()
{
    while(!IsAlive(self))
        wait 0.1;
    
    self.savedModel = self.model;

    if(isDefined(level.ZombieModel))
        self SetModel(level.ZombieModel);
}

DisableZombieModel()
{
    level.ZombieModel = undefined;
    spawner::remove_global_spawn_function("zombie", ::SetZombieSpawnModel);
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]) && isDefined(zombies[a].savedModel))
            zombies[a] SetModel(zombies[a].savedModel);
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

KillZombies(type = "Death")
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        switch(type)
        {
            case "Death":
                zombies[a] DoDamage((zombies[a].health + 666), zombies[a].origin);
                break;
            
            case "Head Gib":
                zombies[a] thread ZombieHeadGib();
                break;
            
            case "Flame":
                zombies[a] thread zombie_death::flame_death_fx();

                if(isDefined(zombies[a]) && IsAlive(zombies[a]))
                    zombies[a] DoDamage((zombies[a].health + 666), zombies[a].origin);
                break;
            
            case "Delete":
                zombies[a] delete();
                break;
            
            default:
                break;
        }
    }
}

ZombieHeadGib()
{
    if(!isDefined(self) || !IsAlive(self))
        return;

    self endon("death");

    self clientfield::set("zm_bgb_mind_ray_fx", 1);
    wait RandomFloatRange(0.65, 2.5);

    self clientfield::set("zm_bgb_mind_pop_fx", 1);
    self PlaySoundOnTag("zmb_bgb_mindblown_pop", "tag_eye");
    self zombie_utility::zombie_head_gib();
    wait 0.1;

    if(isDefined(self) && IsAlive(self))
        self DoDamage((self.health + 666), self.origin);
}

SetZombieHealth(type)
{
    switch(type)
    {
        case "Custom":
            self thread NumberPad(::SetZombieSpawnHealth);
            break;
        
        case "Reset":
            spawner::remove_global_spawn_function("zombie", ::EditZombieHealth);
            level SetZombieHealth1(GetZombieHealthFromRound(level.round_number));
            break;
        
        default:
            break;
    }
}

SetZombieSpawnHealth(health)
{
    spawner::remove_global_spawn_function("zombie", ::EditZombieHealth);
    wait 0.1;

    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isDefined(zombies[a].maxhealth) && zombies[a].maxhealth == health)
            continue;
        
        zombies[a] thread EditZombieHealth(health);
    }

    //This will only apply to zombies that haven't spawned yet. The code above, will set the health of zombies that have already been spawned
    spawner::add_archetype_spawn_function("zombie", ::EditZombieHealth, health);
}

EditZombieHealth(health)
{
    while(!isDefined(self.maxhealth) && isDefined(self) && IsAlive(self))
        wait 0.1;
    
    if(isDefined(self) && IsAlive(self))
    {
        self.maxhealth = health;
        self.health = health;
    }
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
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || isDefined(zombies[a].maxhealth) && zombies[a].maxhealth == health)
            continue;
        
        zombies[a].maxhealth = health;
        zombies[a].health = zombies[a].maxhealth;
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

KnockdownZombies(dir)
{
    switch(dir)
    {
        case "Back":
            knockDir = "front";
            upDir = "getup_back";
            break;
        
        case "Front":
            knockDir = "back";
            upDir = "getup_belly";
            break;
    }

    if(!isDefined(knockDir) || !isDefined(upDir))
        return;

    zombies = GetAITeamArray(level.zombie_team);
    
    foreach(zombie in zombies)
    {
        if(!isDefined(zombie) || !IsAlive(zombie) || zombie.missinglegs || Is_True(zombie.knockdown))
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
        if(!isDefined(zombie) || !IsAlive(zombie) || zombie.missinglegs || Is_True(zombie.pushed))
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

TeleportZombies(loc)
{
    origin = (IsString(loc) && loc == "Crosshairs") ? self TraceBullet() : self.origin;
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
        {
            zombies[a] StopAnimScripted(0);
            zombies[a] ForceTeleport(origin);
            zombies[a].find_flesh_struct_string = "find_flesh";
            zombies[a].ai_state = "find_flesh";
            zombies[a] notify("zombie_custom_think_done", "find_flesh");
        }
    }
}

SetZombieAnimationSpeed(rate)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        if(rate != 1)
            zombies[a] thread ZombieAnimationWait(rate);
        else
            zombies[a] ASMSetAnimationRate(rate);
    }

    spawner::remove_global_spawn_function("zombie", ::ZombieAnimationWait);

    if(rate != 1)
        spawner::add_archetype_spawn_function("zombie", ::ZombieAnimationWait, rate);
}

ZombieAnimationWait(rate)
{
    while(!self CanControl() && IsAlive(self))
        wait 0.1;
    
    if(IsAlive(self))
        self ASMSetAnimationRate(rate);
}

ZombiesToCrosshairsLoop()
{
    level.ZombiesToCrosshairsLoop = BoolVar(level.ZombiesToCrosshairsLoop);

    if(Is_True(level.ZombiesToCrosshairsLoop))
    {
        origin = self TraceBullet();

        while(Is_True(level.ZombiesToCrosshairsLoop))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
                if(isDefined(zombies[a]) && IsAlive(zombies[a]) && IsActor(zombies[a]))
                {
                    zombies[a] StopAnimScripted(0);
                    zombies[a] ForceTeleport(origin);
                }

            wait 0.05;
        }
    }
}

DisableZombieCollision()
{
    level.DisableZombieCollision = BoolVar(level.DisableZombieCollision);
    zombies = GetAITeamArray(level.zombie_team);

    if(Is_True(level.DisableZombieCollision))
        spawner::add_archetype_spawn_function("zombie", ::DisableZombieSpawnCollision);
    else
        spawner::remove_global_spawn_function("zombie", ::DisableZombieSpawnCollision);

    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] SetPlayerCollision(!Is_True(level.DisableZombieCollision));
    }
}

DisableZombieSpawnCollision()
{
    while(!IsAlive(self))
        wait 0.1;
    
    self SetPlayerCollision(0);
}

DisableZombieSpawning()
{
    SetDvar("ai_disableSpawn", (GetDvarString("ai_disableSpawn") == "0") ? "1" : "0");
    KillZombies("Head Gib");
}

DisableZombiePush()
{
    level.DisableZombiePush = BoolVar(level.DisableZombiePush);

    if(Is_True(level.DisableZombiePush))
    {
        while(Is_True(level.DisableZombiePush))
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
    level.ZombiesInvisibility = BoolVar(level.ZombiesInvisibility);

    if(Is_True(level.ZombiesInvisibility))
    {
        while(Is_True(level.ZombiesInvisibility))
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

FreezeZombies()
{
    SetDvar("g_ai", (GetDvarString("g_ai") == "1") ? "0" : "1");
}

ZombieDeathSounds()
{
    level.ZombieDeathSounds = BoolVar(level.ZombieDeathSounds);
    zombies = GetAITeamArray(level.zombie_team);

    if(Is_True(level.ZombieDeathSounds))
        spawner::add_archetype_spawn_function("zombie", ::ZombieSpawnDisappearingZombie);
    else
        spawner::remove_global_spawn_function("zombie", ::ZombieSpawnDisappearingZombie);
    
    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a].bgb_tone_death = Is_True(level.ZombieDeathSounds) ? true : undefined;
}

ZombieDeathSound()
{
    if(!isDefined(self))
        return;
    
    self.bgb_tone_death = true;
}

ZombieProjectileVomiting()
{
    level.ZombieProjectileVomiting = BoolVar(level.ZombieProjectileVomiting);

    while(Is_True(level.ZombieProjectileVomiting))
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || Is_True(zombies[a].ProjectileVomit))
                continue;
            
            zombies[a] thread ZombieProjectileVomit();
        }

        wait 0.1;
    }
}

ZombieProjectileVomit()
{
    if(!isDefined(self) || !IsAlive(self) || Is_True(self.ProjectileVomit))
        return;
    
    self endon("death");
    
    self.ProjectileVomit = true;
    self clientfield::increment("projectile_vomit", 1);
    wait 6;

    if(Is_True(self.ProjectileVomit))
        self.ProjectileVomit = BoolVar(self.ProjectileVomit);
}

DisappearingZombies()
{
    level.DisappearingZombies = BoolVar(level.DisappearingZombies);
    zombies = GetAITeamArray(level.zombie_team);

    if(Is_True(level.DisappearingZombies))
        spawner::add_archetype_spawn_function("zombie", ::ZombieSpawnDisappearingZombie);
    else
    {
        spawner::remove_global_spawn_function("zombie", ::ZombieSpawnDisappearingZombie);
        level notify("EndDisappearingZombies");
    }

    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
        {
            if(Is_True(level.DisappearingZombies))
                zombies[a] thread DisappearingZombie();
            else
            {
                if(Is_True(zombies[a].disappearing))
                    zombies[a].disappearing = BoolVar(zombies[a].disappearing);

                if(!Is_True(level.ZombiesInvisibility))
                    zombies[a] Show();
                else
                    zombies[a] Hide();
            }
        }
    }
}

ZombieSpawnDisappearingZombie()
{
    while(!IsAlive(self))
        wait 0.1;
    
    self thread DisappearingZombie();
}

DisappearingZombie()
{
    if(Is_True(self.disappearing))
        return;
    self.disappearing = true;

    if(!isDefined(self) || !IsAlive(self))
        return;
    
    level endon("EndDisappearingZombies");
    
    while(isDefined(self) && IsAlive(self))
    {
        self Hide();
        wait RandomFloatRange(1, 5);

        if(isDefined(self) && IsAlive(self))
            self Show();
        
        wait RandomFloatRange(1, 5);
    }
}

ExplodingZombies()
{
    level.ExplodingZombies = BoolVar(level.ExplodingZombies);

    if(Is_True(level.ExplodingZombies))
    {
        while(Is_True(level.ExplodingZombies))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!IsAlive(zombies[a]) || Is_True(zombies[a].explodingzombie))
                    continue;
                
                zombies[a].explodingzombie = true;
                zombies[a] clientfield::set("arch_actor_fire_fx", 1);
                zombies[a] thread ZombieBurnPlayers();
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

            if(Is_True(zombies[a].explodingzombie))
                zombies[a].explodingzombie = BoolVar(zombies[a].explodingzombie);

            if(Is_True(zombies[a].burnplayers))
                zombies[a].burnplayers = BoolVar(zombies[a].burnplayers);
        }
    }
}

ZombieBurnPlayers()
{
    if(Is_True(self.burnplayers))
        return;
    self.burnplayers = true;

    self endon("death");

    while(IsAlive(self) && Is_True(level.ExplodingZombies))
    {
        foreach(player in GetPlayers())
        {
            if(DistanceSquared(player.origin, self.origin) <= 9216 && !Is_True(player.is_burning) && zombie_utility::is_player_valid(player, 0))
                player function_3389e2f3(self);
        }

        wait 0.1;
    }
}

ZombieRagdoll()
{
    level.ZombieRagdoll = BoolVar(level.ZombieRagdoll);
}

StackZombies()
{
    level endon("EndStackZombies");
    
    level.StackZombies = BoolVar(level.StackZombies);

    if(Is_True(level.StackZombies))
    {
        while(Is_True(level.StackZombies))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || Is_True(zombies[a].stacked) || !zombies[a] CanControl())
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
                    if(!isDefined(zombies[b]) || !IsAlive(zombies[b]) || Is_True(zombies[b].stacked) || !zombies[a] CanControl() || zombies[b] == bottom)
                        continue;
                    
                    top = zombies[b];
                }

                if(isDefined(bottom) && isDefined(top))
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
            if(!isDefined(zombies[a]) || !IsAlive(zombies[a]) || !Is_True(zombies[a].stacked))
                continue;
            
            zombies[a] Unlink();

            if(Is_True(zombies[a].stacked))
                zombies[a].stacked = BoolVar(zombies[a].stacked);
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
    {
        top Unlink();

        if(Is_True(top.stacked))
            top.stacked = BoolVar(top.stacked);
    }
}

RemoveZombieEyes()
{
    level.RemoveZombieEyes = BoolVar(level.RemoveZombieEyes);
    zombies = GetAITeamArray(level.zombie_team);

    if(Is_True(level.RemoveZombieEyes))
    {
        spawner::add_archetype_spawn_function("zombie", ::ZombieSpawnNoEyes);

        foreach(zombie in zombies)
        {
            if(!isDefined(zombie) || !IsAlive(zombie) || Is_True(zombie.no_eye_glow))
                continue;
            
            zombie clientfield::set("zombie_has_eyes", 0);
            zombie.no_eye_glow = true;
        }
    }
    else
    {
        spawner::remove_global_spawn_function("zombie", ::ZombieSpawnNoEyes);

        foreach(zombie in zombies)
        {
            if(!isDefined(zombie) || !IsAlive(zombie) || !Is_True(zombie.no_eye_glow))
                continue;
            
            zombie clientfield::set("zombie_has_eyes", 1);
            zombie.no_eye_glow = false;
        }
    }
}

ZombieSpawnNoEyes()
{
    if(Is_True(self.no_eye_glow))
        return;
    
    self clientfield::set("zombie_has_eyes", 0);
    self.no_eye_glow = true;
}

BodiesFloat()
{
    SetDvar("phys_gravity_dir", ((GetDvarVector("phys_gravity_dir") == (0, 0, -1)) ? (0, 0, 1) : (0, 0, -1)));
}

ForceZombieCrawlers()
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] zombie_utility::makezombiecrawler(true);
}

DetachZombieHeads()
{
    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] DetachAll();
}

ServerClearCorpses()
{
    corpse_array = GetCorpseArray();

    if(isDefined(corpse_array) && corpse_array.size)
    {
        for(a = 0; a < corpse_array.size; a++)
            if(isDefined(corpse_array[a]))
                corpse_array[a] delete();
    }
}