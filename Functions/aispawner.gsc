AISpawnLocation(location)
{
    self.AISpawnLocation = location;
}

GetAISpawnLocation()
{
    switch(self.AISpawnLocation)
    {
        case "Crosshairs":
            return self TraceBullet();

        case "Self":
            return self.origin + (0, 0, 10);

        default:
            return self TraceBullet();
    }
}

ServerSpawnAI(amount, spawner)
{
    if(!isDefined(spawner) || !IsFunctionPtr((spawner)))
        return;

    for(a = 0; a < amount; a++)
    {
        self thread [[ spawner ]]();
        wait 0.1;
    }
}


//Zombies
ServerSpawnZombie()
{
    spawner = ArrayGetClosest(level.zombie_spawners, self.origin);
    zombie = zombie_utility::spawn_zombie(spawner);

    if(isDefined(zombie) && (self.AISpawnLocation == "Crosshairs" || self.AISpawnLocation == "Self"))
    {
        zombie endon("death");

        wait 0.1;
        zombie StopAnimScripted(0);
        target = self GetAISpawnLocation();

        linker = Spawn("script_origin", zombie.origin);
        linker.origin = zombie.origin;
        linker.angles = zombie.angles;

        zombie LinkTo(linker);
        linker MoveTo(target, 0.01);

        linker waittill("movedone");

        zombie Unlink();
        linker delete();

        zombie.completed_emerging_into_playable_area = 1;
        zombie.find_flesh_struct_string = "find_flesh";
        zombie.ai_state = "find_flesh";
        zombie notify("zombie_custom_think_done", "find_flesh");
    }
}



//Hellhounds
ServerSpawnDog()
{
    favorite_enemy = dogs_get_favorite_enemy();

    if(isDefined(level.dog_spawn_func))
    {
        spawn_loc = [[ level.dog_spawn_func ]](level.dog_spawners, favorite_enemy);
        ai = zombie_utility::spawn_zombie(level.dog_spawners[0]);

        if(isDefined(ai))
        {
            ai.favoriteenemy = favorite_enemy;
            self thread dog_spawn_fx(ai, spawn_loc);
            level flag::set("dog_clips");
        }
    }
    else
    {
        spawn_point = dog_spawn_factory_logic(favorite_enemy);
        ai = zombie_utility::spawn_zombie(level.dog_spawners[0]);

        if(isDefined(ai))
        {
            ai.favoriteenemy = favorite_enemy;
            self thread dog_spawn_fx(ai, spawn_point);
            level flag::set("dog_clips");
        }
    }
}

dogs_get_favorite_enemy()
{
    dog_targets = GetPlayers();
    least_hunted = dog_targets[0];

    for(i = 0; i < dog_targets.size; i++)
    {
        if(!isDefined(dog_targets[i].hunted_by))
            dog_targets[i].hunted_by = 0;

        if(!zm_utility::is_player_valid(dog_targets[i]))
            continue;

        if(!zm_utility::is_player_valid(least_hunted))
            least_hunted = dog_targets[i];

        if(dog_targets[i].hunted_by < least_hunted.hunted_by)
            least_hunted = dog_targets[i];
    }

    if(!zm_utility::is_player_valid(least_hunted))
        return undefined;

    least_hunted.hunted_by = (least_hunted.hunted_by + 1);

    return least_hunted;
}

dog_spawn_fx(ai, ent)
{
    ai endon("death");

    target = (self.AISpawnLocation == "Crosshairs" || self.AISpawnLocation == "Self") ? self GetAISpawnLocation() : ent.origin;
    ai SetFreeCameraLockOnAllowed(0);
    PlayFX(level._effect["lightning_dog_spawn"], target);
    PlaySoundAtPosition("zmb_hellhound_prespawn", target);
    wait 1.5;

    PlaySoundAtPosition("zmb_hellhound_bolt", target);
    Earthquake(0.5, 0.75, target, 1000);
    PlaySoundAtPosition("zmb_hellhound_spawn", target);

    angles = isDefined(ai.favoriteenemy) ? (ai.angles[0], VectorToAngles(ai.favoriteenemy.origin - target)[1], ai.angles[2]) : ent.angles;

    ai ForceTeleport(target, angles);
    ai zombie_setup_attack_properties_dog();
    ai util::stop_magic_bullet_shield();
    wait 0.1;

    ai Show();
    ai SetFreeCameraLockOnAllowed(1);
    ai.ignoreme = 0;
    ai notify("visible");
}

zombie_setup_attack_properties_dog()
{
    self zm_spawner::zombie_history("zombie_setup_attack_properties()");
    self thread dog_behind_audio();
    self.ignoreall = 0;
    self.meleeattackdist = 64;
    self.disablearrivals = 1;
    self.disableexits = 1;

    if(isDefined(level.dog_setup_func))
        self [[ level.dog_setup_func ]]();
}

dog_behind_audio()
{
    self thread stop_dog_sound_on_death();
    self endon("death");
    self util::waittill_any("dog_running", "dog_combat");
    self notify("bhtn_action_notify", "close");
    wait 3;

    while(1)
    {
        foreach(player in GetPlayers())
        {
            if(IsAlive(player) && !isDefined(player.revivetrigger) && Abs(AngleClamp180(VectorToAngles(self.origin - player.origin)[1] - player.angles[1])) > 90 && Distance2D(self.origin, player.origin) > 100)
            {
                self notify("bhtn_action_notify", "close");
                wait 3;
            }
        }

        wait 0.75;
    }
}

stop_dog_sound_on_death()
{
    self waittill("death");
    self StopSounds();
}

dog_spawn_factory_logic(favorite_enemy)
{
    dog_locs = array::randomize(level.zm_loc_types["dog_location"]);

    for(i = 0; i < dog_locs.size; i++)
    {
        if(isDefined(level.old_dog_spawn) && level.old_dog_spawn == dog_locs[i] || !isDefined(favorite_enemy))
            continue;

        dist_squared = DistanceSquared(dog_locs[i].origin, favorite_enemy.origin);

        if(dist_squared > 160000 && dist_squared < 1000000)
        {
            level.old_dog_spawn = dog_locs[i];
            return dog_locs[i];
        }
    }

    return dog_locs[0];
}



//Margwa
ServerSpawnMargwa()
{
    trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);

    origin = trace["position"];
    surface = trace["surfacetype"];

    if(surface == "none" || surface == "default")
        return self iPrintlnBold("^1ERROR: ^7Invalid Surface");

    s_location = (self.AISpawnLocation == "Crosshairs") ? self TraceBullet() : self.origin;

    if(!isDefined(level.var_b398aafa) || !IsArray(level.var_b398aafa))
        return;

    level.var_b398aafa[0].script_forcespawn = 1;
    ai = zombie_utility::spawn_zombie(level.var_b398aafa[0], "margwa", s_location);

    if(!isDefined(ai))
        return;

    ai DisableAimAssist();
    ai.actor_damage_func = ai.overrideactordamage;
    ai.canDamage = 0;
    ai.targetname = "margwa";
    ai.holdFire = 1;
    e_player = zm_utility::get_closest_player(s_location);
    v_dir = e_player.origin - s_location;
    v_dir = VectorNormalize(v_dir);
    v_angles = VectorToAngles(v_dir);
    ai ForceTeleport(s_location, v_angles);
    ai function_551e32b4();

    if(isDefined(level.var_7cef68dc))
        ai thread function_8d578a58();

    ai.ignore_round_robbin_death = 1;
    ai thread function_3d56f587();
}

function_551e32b4()
{
    self.isFrozen = 1;
    self Ghost();
    self NotSolid();
    self PathMode("dont move");
}

function_8d578a58()
{
    if(!isDefined(self))
        return;

    self waittill("death", attacker, mod, weapon);

    foreach(player in level.players)
        if(isDefined(player.am_i_valid) && player.am_i_valid && (!(isDefined(level.var_1f6ca9c8) && level.var_1f6ca9c8)) && (!(isDefined(self.var_2d5d7413) && self.var_2d5d7413)))
            scoreevents::processScoreEvent("kill_margwa", player, undefined, undefined);

    level notify(#"hash_1a2d33d7");
    [[ level.var_7cef68dc ]]();
}

function_3d56f587()
{
    util::wait_network_frame();
    self clientfield::increment("margwa_fx_spawn");
    wait 3;

    self function_26c35525();
    self.canDamage = 1;
    self.needSpawn = 1;
}

function_26c35525()
{
    self.isFrozen = 0;
    self Show();
    self Solid();
    self PathMode("move allowed");
}



//Wasp
ServerSpawnWasp()
{
    players = GetPlayers();
    favorite_enemy = wasp_get_favorite_enemy();
    spawn_enemy = favorite_enemy;

    if(!isDefined(spawn_enemy))
        spawn_enemy = players[0];

    if(isDefined(level.wasp_spawn_func))
        spawn_point = [[ level.wasp_spawn_func ]](spawn_enemy);

    while(!isDefined(spawn_point))
    {
        if(!isDefined(spawn_point))
            spawn_point = wasp_spawn_logic(spawn_enemy);

        if(isDefined(spawn_point))
            break;

        wait 0.05;
    }

    //SOE and Revelations have different wasp spawner variables
    spawner = isDefined(level.var_c200ab6) ? level.var_c200ab6[0] : level.wasp_spawners[0];

    ai = zombie_utility::spawn_zombie(spawner);
    v_spawn_origin = spawn_point.origin;

    if(isDefined(ai))
    {
        queryresult = PositionQuery_Source_Navigation(v_spawn_origin, 0, 32, 32, 15, "navvolume_small");

        if(queryresult.data.size)
            v_spawn_origin = queryresult.data[RandomInt(queryresult.data.size)].origin;

        ai set_parasite_enemy(favorite_enemy);
        ai.does_not_count_to_round = 1;
        level thread wasp_spawn_init(ai, v_spawn_origin, 1);
    }
}

wasp_get_favorite_enemy()
{
    if(level.a_wasp_priority_targets.size > 0)
    {
        e_enemy = level.a_wasp_priority_targets[0];

        if(isDefined(e_enemy))
        {
            ArrayRemoveValue(level.a_wasp_priority_targets, e_enemy);
            return e_enemy;
        }
    }

    if(isDefined(level.fn_custom_wasp_favourate_enemy))
    {
        e_enemy = [[ level.fn_custom_wasp_favourate_enemy ]]();
        return e_enemy;
    }

    target = get_parasite_enemy();

    return target;
}

get_parasite_enemy()
{
    parasite_targets = GetPlayers();
    least_hunted = parasite_targets[0];

    for(i = 0; i < parasite_targets.size; i++)
    {
        if(!isDefined(parasite_targets[i].hunted_by))
            parasite_targets[i].hunted_by = 0;

        if(!wasp_is_target_valid(parasite_targets[i]))
            continue;

        if(!wasp_is_target_valid(least_hunted))
            least_hunted = parasite_targets[i];

        if(parasite_targets[i].hunted_by < least_hunted.hunted_by)
            least_hunted = parasite_targets[i];
    }

    if(!wasp_is_target_valid(least_hunted))
        return undefined;

    return least_hunted;
}

wasp_is_target_valid(target)
{
    if(!isDefined(target))
        return 0;

    if(!IsAlive(target))
        return 0;

    if(IsPlayer(target) && target.sessionstate == "spectator")
        return 0;

    if(IsPlayer(target) && target.sessionstate == "intermission")
        return 0;

    if(isDefined(target.ignoreme) && target.ignoreme)
        return 0;

    if(target IsNoTarget())
        return 0;

    if(isDefined(self.is_target_valid_cb))
        return self [[ self.is_target_valid_cb ]](target);

    return 1;
}

wasp_spawn_logic(favorite_enemy)
{
    queryresult = PositionQuery_Source_Navigation(favorite_enemy.origin + (0, 0, RandomIntRange(40, 100)), 300, 1200, 10, 10, "navvolume_small");

    foreach(point in array::randomize(queryresult.data))
    {
        if(BulletTracePassed(point.origin, favorite_enemy.origin, 0, favorite_enemy))
        {
            level.old_wasp_spawn = point;
            return point;
        }
    }

    return array::randomize(queryresult.data)[0];
}

set_parasite_enemy(enemy)
{
    if(!wasp_is_target_valid(enemy))
        return;

    if(isDefined(self.parasiteenemy))
    {
        if(!isDefined(self.parasiteenemy.hunted_by))
            self.parasiteenemy.hunted_by = 0;

        if(self.parasiteenemy.hunted_by > 0)
            self.parasiteenemy.hunted_by--;
    }

    self.parasiteenemy = enemy;

    if(!isDefined(self.parasiteenemy.hunted_by))
        self.parasiteenemy.hunted_by = 0;

    self.parasiteenemy.hunted_by++;
    self SetLookAtEnt(self.parasiteenemy);
    self SetTurretTargetEnt(self.parasiteenemy);
}

wasp_spawn_init(ai, origin, should_spawn_fx)
{
    if(!isDefined(should_spawn_fx))
        should_spawn_fx = 1;

    ai endon("death");

    ai SetInvisibleToAll();
    v_origin = isDefined(origin) ? origin : ai.origin;

    if(should_spawn_fx)
        PlayFX(level._effect["lightning_wasp_spawn"], v_origin);

    wait 1.5;
    Earthquake(0.3, 0.5, v_origin, 256);

    angle = isDefined(ai.favoriteenemy) ? VectorToAngles(ai.favoriteenemy.origin - v_origin) : ai.angles;
    angles = (ai.angles[0], angle[1], ai.angles[2]);

    ai.origin = v_origin;
    ai.angles = angles;
    ai thread zombie_setup_attack_properties_wasp();

    if(isDefined(level._wasp_death_cb))
        ai callback::add_callback(#"hash_acb66515", level._wasp_death_cb);

    ai SetVisibleToAll();
    ai.ignoreme = 0;
    ai notify("visible");
}

zombie_setup_attack_properties_wasp()
{
    self zm_spawner::zombie_history("zombie_setup_attack_properties()");
    self thread wasp_behind_audio();

    self.ignoreall = 0;
    self.meleeattackdist = 64;
    self.disablearrivals = 1;
    self.disableexits = 1;

    if(level.wasp_round_count == 2)
        self ai::set_behavior_attribute("firing_rate", "medium");
    else if(level.wasp_round_count > 2)
        self ai::set_behavior_attribute("firing_rate", "fast");
}

wasp_behind_audio()
{
    self thread stop_wasp_sound_on_death();
    self endon("death");

    self util::waittill_any("wasp_running", "wasp_combat");
    wait 3;

    while(1)
    {
        players = GetPlayers();

        foreach(player in GetPlayers())
        {
            if(IsAlive(player) && !isDefined(player.revivetrigger))
                if(Abs(AngleClamp180(VectorToAngles(self.origin - player.origin)[1] - player.angles[1])) > 90 && Distance2D(self.origin, player.origin) > 100)
                    wait 3;
        }

        wait 0.75;
    }
}

stop_wasp_sound_on_death()
{
    self waittill("death");
    self StopSounds();
}

function_7085a2e4(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal)
{
    if(IsPlayer(eattacker) && (isDefined(eattacker.var_e8e8daad) && eattacker.var_e8e8daad))
        idamage = Int(idamage * 1.5);

    return idamage;
}


//Civil Protector
ServerSpawnCivilProtector()
{
    trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);

    origin = trace["position"];
    surface = trace["surfacetype"];

    if(surface == "none" || surface == "default")
        return self iPrintlnBold("^1ERROR: ^7Invalid Surface");

    v_ground_position = (self.AISpawnLocation == "Crosshairs") ? self TraceBullet() : self.origin;
    var_36e9b69a = v_ground_position + VectorScale((0, 0, 1), 650);
    level thread function_70541dc1(v_ground_position);

    spawner = level flag::get("ee_complete") ? level.var_c1b7d765[0] : level.zombie_robot_spawners[0];
    level.ai_robot = spawner SpawnFromSpawner("companion_spawner", 1);
    level.ai_robot.maxhealth = level.ai_robot.health;
    level.ai_robot.allow_zombie_to_target_ai = 0;
    level.ai_robot.on_train = 0;
    level.ai_robot.can_gib_zombies = 1;
    level.ai_robot SetCanDamage(0);
    level.ai_robot.time_expired = 0;
    level.ai_robot PlayLoopSound("fly_civil_protector_loop");

    foreach(player in level.players)
        player SetPerk("specialty_pistoldeath");

    if(isDefined(level.ai_robot))
    {
        level.ai_robot ForceTeleport(var_36e9b69a);
        level.ai_robot thread function_ab4d9ece(v_ground_position);
        level.ai_robot scene::play("cin_zod_robot_companion_entrance");
        level notify(#"hash_10a36fa2");
        level.ai_robot.companion_anchor_point = v_ground_position;
    }

    level thread function_f9a6039c(level.ai_robot, "active", 2);
    level.ai_robot thread function_be60a9fd();
    level.ai_robot thread function_677061ac();
    function_490cbdf5();
    level.ai_robot.time_expired = 1;

    while(level.ai_robot.reviving_a_player == 1)
        wait 0.05;

    foreach(player in level.players)
        player UnSetPerk("specialty_pistoldeath");

    level.ai_robot SetCanDamage(1);

    if(isDefined(level.o_zod_train))
        if([[ level.o_zod_train ]]() is_touching_train_volume(level.ai_robot))
            level.ai_robot LinkTo([[ level.o_zod_train ]]() function_8cf8e3a5());

    level.ai_robot scene::play("cin_zod_robot_companion_exit_death");
    level.ai_robot = undefined;
    players = GetPlayers();

    if(players.size != 1 || !level flag::get("solo_game") || (!(isDefined(players[0].waiting_to_revive) && players[0].waiting_to_revive)))
        level zm::checkforalldead();
}

function_8cf8e3a5()
{
    return self.var_36e768e4;
}

is_touching_train_volume(ent)
{
    return ent IsTouching(self.m_e_volume);
}

function_70541dc1(v_ground_position)
{
    var_b47822ca = Spawn("script_model", v_ground_position);
    var_b47822ca SetModel("tag_origin");

    PlayFXOnTag(level._effect["robot_ground_spawn"], var_b47822ca, "tag_origin");
    level waittill(#"hash_10a36fa2");
    var_b47822ca delete();
}

function_ab4d9ece(var_21e230b7)
{
    level.ai_robot thread robot_sky_trail();
    wait 0.5;

    Earthquake(0.55, 1.2, var_21e230b7, 1200);
    PlayFX(level._effect["robot_landing"], var_21e230b7);
    level thread function_fa1df614(var_21e230b7, undefined, 350);

    for(i = 0; i < 5; i++)
    {
        foreach(player in level.players)
            player PlayRumbleOnEntity("damage_heavy");

        wait 0.1;
    }
}

robot_sky_trail()
{
    var_8d888091 = Spawn("script_model", self.origin);
    var_8d888091 SetModel("tag_origin");
    PlayFXOnTag(level._effect["robot_sky_trail"], var_8d888091, "tag_origin");
    var_8d888091 LinkTo(self);
    level waittill(#"hash_10a36fa2");
    var_8d888091 delete();
}

function_fa1df614(v_origin, eattacker, n_radius)
{
    team = isDefined(level.zombie_team) ? level.zombie_team : "axis";
    a_ai_zombies = array::get_all_closest(v_origin, GetAITeamArray(team), undefined, undefined, n_radius);

    foreach(ai_zombie in a_ai_zombies)
    {
        ai_zombie DoDamage(ai_zombie.health + 10000, ai_zombie.origin, isDefined(eattacker) ? eattacker : undefined);

        v_fling = VectorNormalize(((ai_zombie.origin - v_origin) + VectorScale((0, 0, 1), 15)));
        v_fling = (v_fling[0], v_fling[1], abs(v_fling[2]));
        v_fling = VectorScale(v_fling, (70 * (DistanceSquared(ai_zombie.origin, v_origin) / (n_radius * n_radius))));

        ai_zombie StartRagdoll();
        ai_zombie LaunchRagdoll(v_fling);
    }
}

function_f9a6039c(entity, suffix, delay)
{
    entity endon("death");
    entity endon("disconnect");

    num_variants = zm_spawner::get_number_variants("vox_crbt_robot_" + suffix);

    if(num_variants <= 0)
        return;

    if(isDefined(delay))
        wait delay;

    if(isDefined(entity) && (!(isDefined(entity.is_speaking) && entity.is_speaking)))
    {
        entity.is_speaking = 1;
        entity PlaySoundWithNotify("vox_crbt_robot_" + suffix + "_" + RandomIntRange(0, num_variants + 1), "sndDone");
        entity waittill("snddone");
        entity.is_speaking = 0;
    }
}

function_be60a9fd()
{
    self endon("death");
    self endon("disconnect");

    while(1)
    {
        self waittill("killed", who);

        if(RandomIntRange(0, 101) <= 30)
            level thread function_f9a6039c(level.ai_robot, "kills");
    }
}

function_677061ac()
{
    self endon("death");
    self endon("disconnect");

    while(1)
    {
        wait RandomIntRange(15, 25);
        level thread function_f9a6039c(level.ai_robot, "active");
    }
}

function_490cbdf5()
{
    level endon(#"hash_223edfde");
    wait 120;
}

update_readouts_for_remaining_robot_cost()
{
    foreach(e_readout in GetEntArray("robot_readout_model", "targetname"))
        e_readout update_readout_for_remaining_robot_cost();
}

update_readout_for_remaining_robot_cost()
{
    a_cost = get_placed_array_from_number(level.ai_robot_remaining_cost);

    for(i = 0; i < 4; i++)
    {
        j = 0;

        while(j < 10)
        {
            self HidePart("J_" + i + "_" + j);
            j++;
        }

        self ShowPart("J_" + i + "_" + a_cost[i]);
    }
}

get_placed_array_from_number(n_number)
{
    a_number = [];

    for(i = 0; i < 4; i++)
    {
        n_place = Pow(10, 3 - i);
        a_number[i] = Floor(n_number / n_place);
        n_number = n_number - a_number[i] * n_place;
    }

    return a_number;
}



//Raps
ServerSpawnRaps()
{
    if(!isDefined(level.raps_spawners) || level.raps_spawners.size < 1)
        return;

    favorite_enemy = raps_get_favorite_enemy();

    if(!isDefined(favorite_enemy))
        return;

    if(isDefined(level.raps_spawn_func))
        s_spawn_loc = [[ level.raps_spawn_func ]](favorite_enemy);
    else
        s_spawn_loc = raps_calculate_spawn_position(favorite_enemy);

    if(!isDefined(s_spawn_loc))
        return;

    ai = zombie_utility::spawn_zombie(level.raps_spawners[0]);

    if(isDefined(ai))
    {
        ai.favoriteenemy = favorite_enemy;
        ai.favoriteenemy.hunted_by++;
        s_spawn_loc thread raps_spawn_fx(ai, s_spawn_loc);
        level.zombie_total--;
    }
}

raps_get_favorite_enemy()
{
    raps_targets = GetPlayers();
    e_least_hunted = undefined;

    for(i = 0; i < raps_targets.size; i++)
    {
        e_target = raps_targets[i];

        if(!isDefined(e_target.hunted_by))
            e_target.hunted_by = 0;

        if(!zm_utility::is_player_valid(e_target))
            continue;

        if(isDefined(level.is_player_accessible_to_raps) && ![[ level.is_player_accessible_to_raps ]](e_target))
            continue;

        if(!isDefined(e_least_hunted))
        {
            e_least_hunted = e_target;
            continue;
        }

        if(e_target.hunted_by < e_least_hunted.hunted_by)
            e_least_hunted = e_target;
    }

    return e_least_hunted;
}

raps_calculate_spawn_position(favorite_enemy)
{
    position = favorite_enemy.last_valid_position;

    if(!isDefined(position))
        position = favorite_enemy.origin;

    switch(level.players.size)
    {
        case 1:
            n_raps_spawn_dist_min = 450;
            n_raps_spawn_dist_max = 900;
            break;

        case 2:
            n_raps_spawn_dist_min = 450;
            n_raps_spawn_dist_max = 850;
            break;

        case 3:
            n_raps_spawn_dist_min = 700;
            n_raps_spawn_dist_max = 1000;
            break;

        case 4:
            n_raps_spawn_dist_min = 800;
            n_raps_spawn_dist_max = 1200;
            break;
    }

    query_result = PositionQuery_Source_Navigation(position, n_raps_spawn_dist_min, n_raps_spawn_dist_max, 200, 32, 16);

    if(query_result.data.size)
    {
        a_s_locs = array::randomize(query_result.data);

        if(isDefined(a_s_locs))
        {
            foreach(s_loc in a_s_locs)
            {
                if(zm_utility::check_point_in_enabled_zone(s_loc.origin, 1, level.active_zones))
                {
                    s_loc.origin = s_loc.origin + VectorScale((0, 0, 1), 16);
                    return s_loc;
                }
            }
        }
    }

    return undefined;
}

raps_spawn_fx(ai, ent)
{
    ai endon("death");

    if(!isDefined(ent))
        ent = self;

    ai vehicle_ai::set_state("scripted");
    trace = BulletTrace(ent.origin, ent.origin + VectorScale((0, 0, -1), 720), 0, ai);
    raps_impact_location = trace["position"];
    angle = VectorToAngles(ai.favoriteenemy.origin - ent.origin);
    angles = (ai.angles[0], angle[1], ai.angles[2]);
    ai.origin = raps_impact_location;
    ai.angles = angles;
    ai Hide();
    pos = raps_impact_location + VectorScale((0, 0, 1), 720);

    if(!BulletTracePassed(ent.origin, pos, 0, ai))
    {
        trace = BulletTrace(ent.origin, pos, 0, ai);
        pos = trace["position"];
    }

    portal_fx_location = Spawn("script_model", pos);
    portal_fx_location SetModel("tag_origin");

    if(!isDefined(level._effect["raps_portal"]))
        level._effect["raps_portal"] = "zombie/fx_meatball_portal_sky_zod_zmb";

    PlayFXOnTag(level._effect["raps_portal"], portal_fx_location, "tag_origin");
    ground_tell_location = Spawn("script_model", raps_impact_location);
    ground_tell_location SetModel("tag_origin");

    if(!isDefined(level._effect["raps_ground_spawn"]))
        level._effect["raps_ground_spawn"] = "zombie/fx_meatball_impact_ground_tell_zod_zmb";

    PlayFXOnTag(level._effect["raps_ground_spawn"], ground_tell_location, "tag_origin");
    ground_tell_location PlaySound("zmb_meatball_spawn_tell");
    PlaySoundAtPosition("zmb_meatball_spawn_rise", pos);
    ai thread cleanup_meteor_fx(portal_fx_location, ground_tell_location);
    wait 0.5;

    raps_meteor = Spawn("script_model", pos);
    model = ai.model;
    raps_meteor SetModel(model);
    raps_meteor.angles = angles;
    raps_meteor PlayLoopSound("zmb_meatball_spawn_loop", 0.25);

    if(!isDefined(level._effect["raps_meteor_fire"]))
        level._effect["raps_meteor_fire"] = "zombie/fx_meatball_trail_sky_zod_zmb";

    PlayFXOnTag(level._effect["raps_meteor_fire"], raps_meteor, "tag_origin");
    fall_dist = Sqrt(DistanceSquared(pos, raps_impact_location));
    fall_time = fall_dist / 720;
    raps_meteor MoveTo(raps_impact_location, fall_time);
    raps_meteor.ai = ai;
    raps_meteor thread cleanup_meteor();
    wait fall_time;

    raps_meteor delete();

    if(isDefined(portal_fx_location))
        portal_fx_location delete();

    if(isDefined(ground_tell_location))
        ground_tell_location delete();

    ai vehicle_ai::set_state("combat");
    ai.origin = raps_impact_location;
    ai.angles = angles;
    ai Show();

    if(!isDefined(level._effect["raps_impact"]))
        level._effect["raps_impact"] = "zombie/fx_meatball_impact_ground_zod_zmb";

    PlayFX(level._effect["raps_impact"], raps_impact_location);
    PlaySoundAtPosition("zmb_meatball_spawn_impact", raps_impact_location);
    Earthquake(0.3, 0.75, raps_impact_location, 512);

    ai zombie_setup_attack_properties_raps();
    ai SetVisibleToAll();
    ai.ignoreme = 0;
    ai notify("visible");
}

cleanup_meteor_fx(portal_fx, ground_tell)
{
    self waittill("death");

    if(isDefined(portal_fx))
        portal_fx delete();

    if(isDefined(ground_tell))
        ground_tell delete();
}

cleanup_meteor()
{
    self endon("death");

    self.ai waittill("death");
    self delete();
}

zombie_setup_attack_properties_raps()
{
    self zm_spawner::zombie_history("zombie_setup_attack_properties()");
    self.ignoreall = 0;
    self.meleeattackdist = 64;
    self.disablearrivals = 1;
    self.disableexits = 1;
}



//Mechz
ServerSpawnMechz(pos)
{
    if(!isDefined(pos))
    {
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);

        origin = trace["position"];
        surface = trace["surfacetype"];

        if(surface == "none" || surface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");

        s_location = (self.AISpawnLocation == "Crosshairs") ? self TraceBullet() : self.origin;
    }
    else
        s_location = pos;

    flyin = 0;

    if(isDefined(level.var_7f2a926d))
        [[ level.var_7f2a926d ]]();

    level.mechz_spawners[0].script_forcespawn = 1;
    ai = zombie_utility::spawn_zombie(level.mechz_spawners[0], "mechz", s_location);

    if(isDefined(ai))
    {
        ai DisableAimAssist();
        ai thread function_ef1ba7e5();
        ai thread function_949a3fdf();

        ai.actor_damage_func = ai.actor_damage_func;
        ai.damage_scoring_function = ::function_b03abc02;
        ai.mechz_melee_knockdown_function = ::function_55483494;
        ai.health = level.mechz_health;
        ai.faceplate_health = level.mechz_faceplate_health;
        ai.powercap_cover_health = level.mechz_powercap_cover_health;
        ai.powercap_health = level.mechz_powercap_health;
        ai.left_knee_armor_health = level.var_2cbc5b59;
        ai.right_knee_armor_health = level.var_2cbc5b59;
        ai.left_shoulder_armor_health = level.var_2cbc5b59;
        ai.right_shoulder_armor_health = level.var_2cbc5b59;
        ai.heroweapon_kill_power = 10;
        e_player = zm_utility::get_closest_player(s_location);
        v_dir = e_player.origin - s_location;
        v_dir = VectorNormalize(v_dir);
        v_angles = VectorToAngles(v_dir);
        var_89f898ad = zm_utility::flat_angle(v_angles);

        v_ground_position = s_location;
        var_1750e965 = v_ground_position;

        if(isDefined(level.var_e1e49cc1))
            ai thread [[ level.var_e1e49cc1 ]]();

        ai ForceTeleport(var_1750e965, var_89f898ad);

        if(flyin == 1)
        {
            ai thread function_d07fd448();
            ai thread scene::play("cin_zm_castle_mechz_entrance", ai);
            ai thread function_c441eaba(var_1750e965);
            ai thread function_bbdc1f34(var_1750e965);
        }
        else if(isDefined(level.var_7d2a391d))
            ai thread [[ level.var_7d2a391d ]]();

        ai.b_flyin_done = 1;
        ai thread function_bb048b27();
        ai.ignore_round_robbin_death = 1;

        return ai;
    }
}

function_ef1ba7e5()
{
    self waittill("death");

    if(IsPlayer(self.attacker))
    {
        if(!(isDefined(self.deathpoints_already_given) && self.deathpoints_already_given))
            self.attacker zm_score::player_add_points("death_mechz", 1500);

        if(isDefined(level.hero_power_update))
            [[ level.hero_power_update ]](self.attacker, self);
    }
}

function_949a3fdf()
{
    self waittill(#"hash_46c1e51d");

    v_origin = self.origin;
    a_ai = GetAISpeciesArray(level.zombie_team);
    a_ai_kill_zombies = ArraySortClosest(a_ai, v_origin, 18, 0, 200);

    foreach(ai_enemy in a_ai_kill_zombies)
    {
        if(isDefined(ai_enemy))
        {
            if(ai_enemy.archetype == "mechz")
                ai_enemy DoDamage(level.mechz_health * 0.25, v_origin);
            else
                ai_enemy DoDamage(ai_enemy.health + 100, v_origin);
        }

        wait 0.05;
    }
}

function_b03abc02(inflictor, attacker, damage, dflags, mod, weapon, point, dir, hitloc, offsettime, boneindex, modelindex)
{
    if(isDefined(attacker) && IsPlayer(attacker))
        if(!(isDefined(self.no_damage_points) && self.no_damage_points))
            attacker zm_score::player_add_points(zm_spawner::player_using_hi_score_weapon(attacker) ? "damage" : "damage_light", mod, hitloc, self.isdog, self.team, weapon);
}

function_55483494()
{
    a_zombies = GetAIArchetypeArray("zombie");

    foreach(var_a3a3ed4c, zombie in a_zombies)
    {
        if(!isDefined(zombie) || !IsAlive(zombie))
            continue;

        if(zombie function_10d36217(self) && DistanceSquared(self.origin, zombie.origin) <= 12544)
            self function_3efae612(zombie);
    }
}

function_10d36217(mechz)
{
    facing_vec = AnglesToForward(mechz.angles);
    enemy_vec = (self.origin - mechz.origin);
    enemy_dot = VectorDot(VectorNormalize((facing_vec[0], facing_vec[1], 0)), VectorNormalize((enemy_vec[0], enemy_vec[1], 0)));

    if(enemy_dot < 0.7)
        return 0;

    if(Abs(AngleClamp180(VectorToAngles(enemy_vec)[0])) > 45)
        return 0;

    return 1;
}

function_3efae612(zombie)
{
    zombie.knockdown = 1;
    zombie.knockdown_type = "knockdown_shoved";
    zombie_to_mechz = self.origin - zombie.origin;
    zombie_to_mechz_2d = VectorNormalize((zombie_to_mechz[0], zombie_to_mechz[1], 0));
    zombie_forward = AnglestoForward(zombie.angles);
    zombie_forward_2d = VectorNormalize((zombie_forward[0], zombie_forward[1], 0));
    zombie_right = AnglestoRight(zombie.angles);
    zombie_right_2d = VectorNormalize((zombie_right[0], zombie_right[1], 0));
    dot = VectorDot(zombie_to_mechz_2d, zombie_forward_2d);

    if(dot >= 0.5)
    {
        zombie.knockdown_direction = "front";
        zombie.getup_direction = "getup_back";
    }
    else if(dot < 0.5 && dot > -0.5)
    {
        dot = VectorDot(zombie_to_mechz_2d, zombie_right_2d);

        if(dot > 0)
        {
            zombie.knockdown_direction = "right";
            zombie.getup_direction = math::cointoss() ? "getup_back" : "getup_belly";
        }
        else
        {
            zombie.knockdown_direction = "left";
            zombie.getup_direction = "getup_belly";
        }
    }
    else
    {
        zombie.knockdown_direction = "back";
        zombie.getup_direction = "getup_belly";
    }
}

function_d07fd448()
{
    self endon("death");

    self.b_flyin_done = 0;
    self.bgbignorefearinheadlights = 1;
    self util::waittill_any("mechz_flyin_done", "scene_done");
    self.b_flyin_done = 1;
    self.bgbignorefearinheadlights = 0;
}

function_c441eaba(var_678a2319)
{
    self endon("death");

    self waittill(#"hash_f93797a6");

    foreach(e_zombie in GetAIArchetypeArray("zombie"))
        if(DistanceSquared(e_zombie.origin, var_678a2319) <= 2304)
            e_zombie Kill();

    foreach(player in GetPlayers())
    {
        dist_sq = DistanceSquared(player.origin, var_678a2319);

        if(dist_sq <= 2304)
            player DoDamage(100, var_678a2319, self, self);

        scale = 2250000 - dist_sq / 2250000;

        if(scale <= 0 || scale >= 1)
            return;

        earthquake_scale = scale * 0.15;
        Earthquake(earthquake_scale, 0.1, var_678a2319, 1500);

        if(scale >= 0.66)
        {
            player PlayRumbleOnEntity("shotgun_fire");
            continue;
        }

        if(scale >= 0.33)
        {
            player PlayRumbleOnEntity("damage_heavy");
            continue;
        }

        player PlayRumbleOnEntity("reload_small");
    }

    if(isDefined(self.var_1411e129))
        self.var_1411e129 delete();
}

function_bbdc1f34(var_678a2319)
{
    self endon("death");
    self endon(#"hash_f93797a6");

    self waittill(#"hash_3d18ed4f");
    distance = 9216;

    while(1)
    {
        foreach(player in GetPlayers())
        {
            if(DistanceSquared(player.origin, var_678a2319) <= distance)
                if(!(isDefined(player.is_burning) && player.is_burning) && zombie_utility::is_player_valid(player, 0))
                    player function_3389e2f3(self);
        }

        foreach(e_zombie in function_d41418b8())
        {
            if(DistanceSquared(e_zombie.origin, var_678a2319) <= distance && self.var_e05d0be2 != 1)
            {
                self function_3efae612(e_zombie);
                e_zombie function_f4defbc2();
            }
        }

        wait 0.1;
    }
}

function_3389e2f3(mechz)
{
    if(!(isDefined(self.is_burning) && self.is_burning) && zombie_utility::is_player_valid(self, 1))
    {
        self.is_burning = 1;
        self burnplayer::setplayerburning(1.5, 0.5, !self HasPerk("specialty_armorvest") ? 30 : 20, mechz, undefined);

        wait 1.5;
        self.is_burning = 0;
    }
}

function_d41418b8()
{
    a_zombies = GetAIArchetypeArray("zombie");
    a_filtered_zombies = array::filter(a_zombies, 0, ::function_b804eb62);

    return a_filtered_zombies;
}

function_b804eb62(ai_zombie)
{
    return ai_zombie.is_elemental_zombie != 1;
}

function_361f6caa(ai_zombie, type)
{
    return ai_zombie.var_9a02a614 == type;
}

function_f4defbc2()
{
    if(isDefined(self))
    {
        ai_zombie = self;
        var_ac4641b = function_4aeed0a5("napalm");

        if(!isDefined(level.var_bd64e31e) || var_ac4641b < level.var_bd64e31e)
        {
            if(!isDefined(ai_zombie.is_elemental_zombie) || ai_zombie.is_elemental_zombie == 0)
            {
                ai_zombie.is_elemental_zombie = 1;
                ai_zombie.var_9a02a614 = "napalm";
                ai_zombie clientfield::set("arch_actor_fire_fx", 1);
                ai_zombie clientfield::set("napalm_sfx", 1);
                ai_zombie.health = Int(ai_zombie.health * 0.75);
                ai_zombie thread napalm_zombie_death();
                ai_zombie thread function_d070bfba();
                ai_zombie zombie_utility::set_zombie_run_cycle("sprint");
            }
        }
    }
}

function_4aeed0a5(type)
{
    a_zombies = function_c50e890f(type);
    return a_zombies.size;
}

function_c50e890f(type)
{
    a_zombies = GetAIArchetypeArray("zombie");
    a_filtered_zombies = array::filter(a_zombies, 0, ::function_361f6caa, type);

    return a_filtered_zombies;
}

napalm_zombie_death()
{
    ai_zombie = self;
    ai_zombie waittill("death", attacker);

    if(!isDefined(ai_zombie) || ai_zombie.nuked == 1)
        return;

    ai_zombie clientfield::set("napalm_zombie_death_fx", 1);
    ai_zombie zombie_utility::gib_random_parts();
    gibserverutils::annihilate(ai_zombie);

    if(isDefined(level.var_36b5dab) && level.var_36b5dab || (isDefined(ai_zombie.var_36b5dab) && ai_zombie.var_36b5dab))
        ai_zombie.custom_player_shellshock = ::function_e6cd7e78;

    RadiusDamage(ai_zombie.origin + VectorScale((0, 0, 1), 35), 128, 70, 30, self, "MOD_EXPLOSIVE");
}

function_e6cd7e78(damage, attacker, direction_vec, point, mod)
{
    if(GetDvarString("blurpain") == "on")
        self Shellshock("pain_zm", 0.5);
}

function_d070bfba()
{
    self endon("entityshutdown");
    self endon("death");

    while(1)
    {
        self waittill("damage");

        if(RandomInt(100) < 50)
            self clientfield::increment("napalm_damaged_fx");

        wait 0.05;
    }
}

function_bb048b27()
{
    self endon("death");

    while(1)
    {
        wait RandomIntRange(9, 14);
        self PlaySound("zmb_ai_mechz_vox_ambient");
    }
}








//Sentinel Drone
ServerSpawnSentinelDrone()
{
    trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);

    origin = trace["position"];
    surface = trace["surfacetype"];

    if(surface == "none" || surface == "default")
        return self iPrintlnBold("^1ERROR: ^7Invalid Surface");

    s_location = (self.AISpawnLocation == "Crosshairs") ? self TraceBullet() : self.origin;
    s_location += (0, 0, 25);
    ai = function_fded8158(level.var_fda4b3f3[0]);

    if(isDefined(ai))
    {
        ai.nuke_damage_func = ::function_306f9403;
        ai.instakill_func = ::function_306f9403;
        ai.s_spawn_loc = s_location;
        ai thread function_b27530eb(s_location);

        level.zombie_total--;
    }
}

function_f9c9e7e0()
{
    a_s_spawn_locs = [];
    s_spawn_loc = undefined;

    foreach(var_12e32073, s_zone in level.zones)
    {
        if(s_zone.is_enabled && isDefined(s_zone.a_loc_types["sentinel_location"]) && s_zone.a_loc_types["sentinel_location"].size)
        {
            foreach(var_ef5f441b, s_loc in s_zone.a_loc_types["sentinel_location"])
            {
                foreach(var_6b780c35, player in level.activeplayers)
                {
                    n_dist_sq = DistanceSquared(player.origin, s_loc.origin);

                    if(n_dist_sq > 65536 && n_dist_sq < 2250000)
                    {
                        if(!isDefined(a_s_spawn_locs))
                            a_s_spawn_locs = [];
                        else if(!IsArray(a_s_spawn_locs))
                            a_s_spawn_locs = Array(a_s_spawn_locs);

                        a_s_spawn_locs[a_s_spawn_locs.size] = s_loc;

                        break;
                    }
                }
            }
        }
    }

    s_spawn_loc = array::random(a_s_spawn_locs);

    if(!isDefined(s_spawn_loc))
        s_spawn_loc = array::random(level.zm_loc_types["sentinel_location"]);

    return s_spawn_loc;
}

function_fded8158(spawner, s_spot)
{
    var_663b2442 = zombie_utility::spawn_zombie(level.var_fda4b3f3[0], "sentinel", s_spot);

    if(isDefined(var_663b2442))
        var_663b2442.check_point_in_enabled_zone = zm_utility::check_point_in_playable_area;

    return var_663b2442;
}

function_306f9403(player, mod, hit_location)
{
    return 1;
}

function_b27530eb(v_pos)
{
    self endon("death");

    self sentinel_intro();
    var_92968756 = v_pos + VectorScale((0, 0, 1), 30);
    self.origin = v_pos + VectorScale((0, 0, 1), 5000);
    self.angles = (0, RandomIntRange(0, 360), 0);
    e_origin = Spawn("script_origin", self.origin);
    e_origin.angles = self.angles;
    self LinkTo(e_origin);
    e_origin MoveTo(var_92968756, 0.01);
    e_origin PlaySound("zmb_sentinel_intro_spawn");
    e_origin util::delay(0.01, undefined, ::function_e6bf0279);
    self clientfield::set("sentinel_spawn_fx", 1);
    wait 0.05;

    self clientfield::set("sentinel_spawn_fx", 0);
    wait 0.05;

    self.origin = var_92968756;
    self Unlink();
    e_origin Delete();
    self flag::set("completed_spawning");

    wait 0.05;
    self sentinel_introcompleted();
}

toggle_sounds(on)
{
    self clientfield::set("toggle_sounds", !on);
}

function_e6bf0279()
{
    self PlaySound("zmb_sentinel_intro_land");
}

sentinel_intro()
{
    sentinel_navigationstandstill();
    self.playing_intro_anim = 1;
    self ASMRequestSubstate("intro@default");
}

sentinel_navigationstandstill()
{
    self endon("change_state");
    self endon("death");
    self notify("abort_navigation");
    self notify("near_goal");

    wait 0.05;

    if(GetDvarInt("sentinel_NavigationStandStill_new", 0) > 0)
    {
        self ClearVehGoalPos();
        self SetVehVelocity((0, 0, 0));
        self.vehaircraftcollisionenabled = 1;

        return;
    }

    if(GetDvarInt("sentinel_ClearVehGoalPos", 1) == 1)
        self ClearVehGoalPos();

    if(GetDvarInt("sentinel_PathVariableOffsetClear", 1) == 1)
        self PathVariableOffsetClear();

    if(GetDvarInt("sentinel_PathFixedOffsetClear", 1) == 1)
        self PathFixedOffsetClear();

    if(GetDvarInt("sentinel_ClearSpeed", 1) == 1)
    {
        self SetSpeed(0);
        self SetVehVelocity((0, 0, 0));
        self SetPhysAcceleration((0, 0, 0));
        self SetAngularVelocity((0, 0, 0));
    }

    self.vehaircraftcollisionenabled = 1;
}

sentinel_introcompleted()
{
    self.playing_intro_anim = 0;

    if(!self is_instate("scripted"))
        self thread sentinel_navigatetheworld();
}

is_instate(statename)
{
    if(isDefined(self.current_role) && isDefined(self.state_machines[self.current_role].current_state))
        return self.state_machines[self.current_role].current_state.name == statename;

    return 0;
}

sentinel_navigatetheworld()
{
    self endon("change_state");
    self endon("death");
    self endon("abort_navigation");
    self notify("sentinel_navigatetheworld");
    self endon("sentinel_navigatetheworld");

    lasttimechangeposition = 0;
    self.shouldgotonewposition = 0;
    self.last_failsafe_count = 0;
    sentinel_move_speed = GetDvarInt("Sentinel_Move_Speed", 25);
    sentinel_evade_speed = GetDvarInt("Sentinel_Evade_Speed", 40);
    self SetSpeed(sentinel_move_speed);
    self ASMRequestSubstate("locomotion@movement");
    self.current_pathto_pos = undefined;
    self.next_near_player_check = 0;
    b_use_path_finding = 1;

    while(1)
    {
        current_pathto_pos = undefined;
        b_in_tactical_position = 0;

        if(isDefined(self.playing_intro_anim) && self.playing_intro_anim)
            wait 0.1;
        else if(self.goalforced)
        {
            returndata = [];
            returndata["origin"] = self GetClosestPointOnNavVolume(self.goalpos, 100);
            returndata["centerOnNav"] = IsPointInNavVolume(self.origin, "navvolume_small");
            current_pathto_pos = returndata["origin"];
        }
        else if(isDefined(self.forced_pos))
        {
            returndata = [];
            returndata["origin"] = self GetClosestPointOnNavVolume(self.forced_pos, 100);
            returndata["centerOnNav"] = IsPointInNavVolume(self.origin, "navvolume_small");
            current_pathto_pos = returndata["origin"];
        }
        else if(sentinel_shouldchangesentinelposition())
        {
            if(isDefined(self.evading_player) && self.evading_player)
            {
                self.evading_player = 0;
                self SetSpeed(sentinel_evade_speed);
            }
            else
                self SetSpeed(sentinel_move_speed);

            returndata = sentinel_getnextmovepositiontactical(self.should_buff_zombies);
            current_pathto_pos = returndata["origin"];
            self.lastjuketime = GetTime();
            self.nextjuketime = GetTime() + 1000 + RandomInt(4000);
            b_in_tactical_position = 1;
        }
        else if(GetTime() > self.next_near_player_check && sentinel_isnearanotherplayer(self.origin, 100))
        {
            self.evading_player = 1;
            self.next_near_player_check = GetTime() + 1000;
            self.nextjuketime = 0;
            self notify("near_goal");
        }

        is_on_nav_volume = IsPointInNavVolume(self.origin, "navvolume_small");

        if(isDefined(current_pathto_pos))
        {
            if(isDefined(self.stucktime) && (isDefined(is_on_nav_volume) && is_on_nav_volume))
                self.stucktime = undefined;

            if(self SetVehGoalPos(current_pathto_pos, 1, b_use_path_finding))
            {
                b_use_path_finding = 1;
                self.b_in_tactical_position = b_in_tactical_position;
                self thread sentinel_pathupdateinterrupt();
                self waittill_pathing_done(5);
                current_pathto_pos = undefined;
            }
            else if(isDefined(is_on_nav_volume) && is_on_nav_volume)
            {
                self sentinel_killmyself();
                self.last_failsafe_time = undefined;
            }
        }

        if(!(isDefined(is_on_nav_volume) && is_on_nav_volume))
        {
            if(!isDefined(self.last_failsafe_time))
                self.last_failsafe_time = GetTime();

            if(GetTime() - self.last_failsafe_time >= 3000)
                self.last_failsafe_count = 0;
            else
                self.last_failsafe_count++;

            self.last_failsafe_time = GetTime();

            if(self.last_failsafe_count > 25)
            {
                new_sentinel_pos = self GetClosestPointOnNavVolume(self.origin, 120);

                if(isDefined(new_sentinel_pos))
                {
                    dvar_sentinel_getback_to_volume_epsilon = GetDvarInt("dvar_sentinel_getback_to_volume_epsilon", 5);

                    if(Distance(self.origin, new_sentinel_pos) < dvar_sentinel_getback_to_volume_epsilon)
                        self.origin = new_sentinel_pos;
                    else
                    {
                        self.vehaircraftcollisionenabled = 0;

                        if(self SetVehGoalPos(new_sentinel_pos, 1, 0))
                        {
                            self thread sentinel_pathupdateinterrupt();
                            self waittill_pathing_done(5);
                            current_pathto_pos = undefined;
                        }

                        self.vehaircraftcollisionenabled = 1;
                    }
                }
                else if(self.last_failsafe_count > 100)
                    self sentinel_killmyself();
            }
        }

        if(!(isDefined(is_on_nav_volume) && is_on_nav_volume))
        {
            if(!isDefined(self.stucktime))
                self.stucktime = GetTime();

            if(GetTime() - self.stucktime > 15000)
                self sentinel_killmyself();
        }

        wait 0.1;
    }
}

sentinel_shouldchangesentinelposition()
{
    if(GetTime() > self.nextjuketime || isDefined(self.sentinel_droneenemy) && isDefined(self.lastjuketime) && GetTime() - self.lastjuketime > 3000 && self GetSpeed() < 1 && !sentinel_isinsideengagementdistance(self.origin, self.sentinel_droneenemy.origin + VectorScale((0, 0, 1), 48), 1))
        return 1;

    return 0;
}

sentinel_isinsideengagementdistance(origin, position, b_accept_negative_height)
{
    if(!(Distance2DSquared(position, origin) > sentinel_getengagementdistmin() * sentinel_getengagementdistmin() && Distance2DSquared(position, origin) < sentinel_getengagementdistmax() * sentinel_getengagementdistmax()))
        return 0;

    if(isDefined(b_accept_negative_height) && b_accept_negative_height)
        return Abs(origin[2] - position[2]) >= sentinel_getengagementheightmin() && Abs(origin[2] - position[2]) <= sentinel_getengagementheightmax();

    return position[2] - origin[2] >= sentinel_getengagementheightmin() && position[2] - origin[2] <= sentinel_getengagementheightmax();
}

sentinel_getengagementdistmin()
{
    if(sentinel_isenemyinnarrowplace())
        return self.settings.engagementdistmin * 0.2;

    if(isDefined(self.in_compact_mode) && self.in_compact_mode)
        return self.settings.engagementdistmin * 0.5;

    return self.settings.engagementdistmin;
}

sentinel_getengagementdistmax()
{
    if(sentinel_isenemyinnarrowplace())
        return self.settings.engagementdistmax * 0.3;

    if(isDefined(self.in_compact_mode) && self.in_compact_mode)
        return self.settings.engagementdistmax * 0.85;

    return self.settings.engagementdistmax;
}

sentinel_getengagementheightmin()
{
    if(!isDefined(self.sentinel_droneenemy))
        return self.settings.engagementheightmin * 3;

    return self.settings.engagementheightmin;
}

sentinel_getengagementheightmax()
{
    if(isDefined(self.in_compact_mode) && self.in_compact_mode)
        return self.settings.engagementheightmax * 0.8;

    return self.settings.engagementheightmax;
}

sentinel_isenemyinnarrowplace()
{
    if(!isDefined(self.sentinel_droneenemy))
        return 0;

    if(!isDefined(self.v_narrow_volume))
        self.v_narrow_volume = GetEnt("sentinel_narrow_nav", "targetname");

    if(isDefined(self.v_narrow_volume) && isDefined(self.sentinel_droneenemy))
        if(self.sentinel_droneenemy IsTouching(self.v_narrow_volume))
            return 1;

    return 0;
}

sentinel_getnextmovepositiontactical(b_do_not_chase_enemy)
{
    self endon("change_state");
    self endon("death");

    selfdisttotarget = isDefined(self.sentinel_droneenemy) ? Distance2D(self.origin, self.sentinel_droneenemy.origin) : 0;
    gooddist = 0.5 * sentinel_getengagementdistmin() + sentinel_getengagementdistmax();
    closedist = 1.2 * gooddist;
    fardist = 3 * gooddist;
    querymultiplier = MapFloat(closedist, fardist, 1, 3, selfdisttotarget);
    preferedheightrange = 0.5 * sentinel_getengagementheightmax() + sentinel_getengagementheightmin();
    randomness = 20;
    sentinel_drone_too_close_to_self_dist_ex = GetDvarInt("SENTINEL_DRONE_TOO_CLOSE_TO_SELF_DIST_EX", 70);
    sentinel_drone_move_dist_max_ex = GetDvarInt("SENTINEL_DRONE_MOVE_DIST_MAX_EX", 600);
    sentinel_drone_move_spacing = GetDvarInt("SENTINEL_DRONE_MOVE_SPACING", 25);
    sentinel_drone_radius_ex = GetDvarInt("SENTINEL_DRONE_RADIUS_EX", 35);
    sentinel_drone_hight_ex = GetDvarInt("SENTINEL_DRONE_HIGHT_EX", Int(preferedheightrange));
    spacing_multiplier = 1.5;
    query_min_dist = self.settings.engagementdistmin;
    query_max_dist = sentinel_drone_move_dist_max_ex;

    if(!(isDefined(b_do_not_chase_enemy) && b_do_not_chase_enemy) && isDefined(self.sentinel_droneenemy) && GetTime() > self.targetplayertime)
    {
        charge_at_position = self.sentinel_droneenemy.origin + VectorScale((0, 0, 1), 48);

        if(!IsPointInNavVolume(charge_at_position, "navvolume_small"))
        {
            closest_point_on_nav_volume = GetDvarInt("closest_point_on_nav_volume", 120);
            charge_at_position = self GetClosestPointOnNavVolume(charge_at_position, closest_point_on_nav_volume);
        }

        if(!isDefined(charge_at_position))
            queryresult = PositionQuery_Source_Navigation(self.origin, sentinel_drone_too_close_to_self_dist_ex, sentinel_drone_move_dist_max_ex * querymultiplier, sentinel_drone_hight_ex * querymultiplier, sentinel_drone_move_spacing, "navvolume_small", sentinel_drone_move_spacing * spacing_multiplier);
        else if(sentinel_isenemyinnarrowplace())
        {
            spacing_multiplier = 1;
            sentinel_drone_move_spacing = 15;
            query_min_dist = self.settings.engagementdistmin * GetDvarFloat("sentinel_query_min_dist", 0.2);
            query_max_dist = query_max_dist * 0.5;
        }
        else if(isDefined(self.in_compact_mode) && self.in_compact_mode || sentinel_isenemyindoors())
        {
            spacing_multiplier = 1;
            sentinel_drone_move_spacing = 15;
            query_min_dist = self.settings.engagementdistmin * GetDvarFloat("sentinel_query_min_dist", 0.5);
        }

        queryresult = PositionQuery_Source_Navigation(charge_at_position, query_min_dist, query_max_dist * querymultiplier, sentinel_drone_hight_ex * querymultiplier, sentinel_drone_move_spacing, "navvolume_small", sentinel_drone_move_spacing * spacing_multiplier);
    }
    else
        queryresult = PositionQuery_Source_Navigation(self.origin, sentinel_drone_too_close_to_self_dist_ex, sentinel_drone_move_dist_max_ex * querymultiplier, sentinel_drone_hight_ex * querymultiplier, sentinel_drone_move_spacing, "navvolume_small", sentinel_drone_move_spacing * spacing_multiplier);

    PositionQuery_Filter_DistanceToGoal(queryresult, self);
    PositionQuery_Filter_OutOfGoalAnchor(queryresult);

    if(isDefined(self.sentinel_droneenemy))
    {
        if(RandomInt(100) > 15)
            self PositionQuery_Filter_EngagementDist(queryresult, self.sentinel_droneenemy, sentinel_getengagementdistmin(), sentinel_getengagementdistmax());

        goalheight = self.sentinel_droneenemy.origin[2] + 0.5 * sentinel_getengagementheightmin() + sentinel_getengagementheightmax();
        enemy_origin = self.sentinel_droneenemy.origin + VectorScale((0, 0, 1), 48);
    }
    else
    {
        goalheight = self.origin[2] + 0.5 * sentinel_getengagementheightmin() + sentinel_getengagementheightmax();
        enemy_origin = self.origin;
    }

    best_point = undefined;
    best_score = undefined;
    trace_count = 0;

    foreach(var_5855669, point in queryresult.data)
    {
        if(sentinel_isinsideengagementdistance(enemy_origin, point.origin))
            point.score = point.score + 25;

        point.score = point.score + RandomFloatRange(0, randomness);

        if(isDefined(point.distawayfromengagementarea))
            point.score = point.score + point.distawayfromengagementarea * -1;

        is_near_another_sentinel = sentinel_isnearanothersentinel(point.origin, 200);

        if(isDefined(is_near_another_sentinel) && is_near_another_sentinel)
            point.score = point.score + -200;

        is_overlap_another_sentinel = sentinel_isnearanothersentinel(point.origin, 100);

        if(isDefined(is_overlap_another_sentinel) && is_overlap_another_sentinel)
            point.score = point.score + -2000;

        is_near_another_player = sentinel_isnearanotherplayer(point.origin, 150);

        if(isDefined(is_near_another_player) && is_near_another_player)
            point.score = point.score + -200;

        distfrompreferredheight = Abs(point.origin[2] - goalheight);

        if(distfrompreferredheight > preferedheightrange)
        {
            heightscore = distfrompreferredheight - preferedheightrange * 3;
            point.score = point.score + heightscore * -1;
        }

        if(!isDefined(best_score))
        {
            best_score = point.score;
            best_point = point;
            best_point.visibile = isDefined(self.sentinel_droneenemy) ? Int(BulletTracePassed(point.origin, enemy_origin, 0, self, self.sentinel_droneenemy)) : Int(BulletTracePassed(point.origin, enemy_origin, 0, self));

            continue;
        }

        if(point.score > best_score)
        {
            point.visibile = isDefined(self.sentinel_droneenemy) ? Int(BulletTracePassed(point.origin, enemy_origin, 0, self, self.sentinel_droneenemy)) : Int(BulletTracePassed(point.origin, enemy_origin, 0, self));

            if(point.visibile >= best_point.visibile)
            {
                best_score = point.score;
                best_point = point;
            }
        }
    }

    if(isDefined(best_point))
        if(best_point.score < -1000)
            best_point = undefined;

    returndata = [];
    returndata["origin"] = isDefined(best_point) ? best_point.origin : undefined;
    returndata["centerOnNav"] = queryresult.centeronnav;

    return returndata;
}

sentinel_isenemyindoors()
{
    if(!isDefined(self.v_compact_mode))
        v_compact_mode = GetEnt("sentinel_compact", "targetname");

    if(isDefined(v_compact_mode))
        if(self.sentinel_droneenemy IsTouching(v_compact_mode))
            return 1;

    return 0;
}

positionquery_filter_outofgoalanchor(queryresult, tolerance = 1)
{
    foreach(point in queryresult.data)
        if(point.disttogoal > tolerance)
            point.score = (point.score + ((-10000 - point.disttogoal) * 10));
}

positionquery_filter_engagementdist(queryresult, enemy, engagementdistancemin, engagementdistancemax)
{
    if(!isDefined(enemy))
        return;

    engagementdistance = engagementdistancemin + engagementdistancemax * 0.5;
    half_engagement_width = Abs(engagementdistancemax - engagementdistance);
    enemy_origin = (enemy.origin[0], enemy.origin[1], 0);
    vec_enemy_to_self = VectorNormalize((self.origin[0], self.origin[1], 0) - enemy_origin);

    foreach(var_27b71730, point in queryresult.data)
    {
        point.distawayfromengagementarea = 0;
        vec_enemy_to_point = (point.origin[0], point.origin[1], 0) - enemy_origin;
        dist_in_front_of_enemy = VectorDot(vec_enemy_to_point, vec_enemy_to_self);

        if(Abs(dist_in_front_of_enemy) < engagementdistancemin)
            dist_in_front_of_enemy = engagementdistancemin * -1;

        dist_away_from_sweet_line = Abs(dist_in_front_of_enemy - engagementdistance);

        if(dist_away_from_sweet_line > half_engagement_width)
            point.distawayfromengagementarea = dist_away_from_sweet_line - half_engagement_width;

        too_far_dist = engagementdistancemax * 1.1;
        too_far_dist_sq = too_far_dist * too_far_dist;
        dist_from_enemy_sq = Distance2DSquared(point.origin, enemy_origin);

        if(dist_from_enemy_sq > too_far_dist_sq)
        {
            ratiosq = dist_from_enemy_sq / too_far_dist_sq;
            dist = ratiosq * too_far_dist;
            dist_outside = dist - too_far_dist;

            if(dist_outside > point.distawayfromengagementarea)
                point.distawayfromengagementarea = dist_outside;
        }
    }
}

sentinel_isnearanothersentinel(point, min_distance)
{
    if(!isDefined(level.a_sentinel_drones))
        return 0;

    for(i = 0; i < level.a_sentinel_drones.size; i++)
    {
        if(!isDefined(level.a_sentinel_drones[i]))
            continue;

        if(level.a_sentinel_drones[i] == self)
            continue;

        if(DistanceSquared(level.a_sentinel_drones[i].origin, point) < (min_distance * min_distance))
            return 1;
    }

    return 0;
}

sentinel_isnearanotherplayer(origin, min_distance)
{
    foreach(player in GetPlayers())
    {
        if(!sentinel_is_target_valid(player))
            continue;

        if(DistanceSquared(origin, player.origin + VectorScale((0, 0, 1), 48)) < (min_distance * min_distance))
            return 1;
    }

    return 0;
}

sentinel_is_target_valid(target)
{
    if(!isDefined(target))
        return 0;

    if(!IsAlive(target))
        return 0;

    if(IsPlayer(target) && target.sessionstate == "spectator")
        return 0;

    if(IsPlayer(target) && target.sessionstate == "intermission")
        return 0;

    if(isDefined(target.ignoreme) && target.ignoreme)
        return 0;

    if(target IsNoTarget())
        return 0;

    if(isDefined(target.is_elemental_zombie) && target.is_elemental_zombie)
        return 0;

    if(isDefined(level.is_valid_player_for_sentinel_drone))
        if(![[ level.is_valid_player_for_sentinel_drone ]](target))
            return 0;

    if(isDefined(self.should_buff_zombies) && self.should_buff_zombies && IsPlayer(target))
        if(isDefined(get_sentinel_nearest_zombie()))
            return 0;

    return 1;
}

get_sentinel_nearest_zombie(b_ignore_elemental = 1, b_outside_playable_area = 1, radius = 2000)
{
    if(isDefined(self.sentinel_getnearestzombie))
    {
        ai_zombie = [[ self.sentinel_getnearestzombie ]](self.origin, b_ignore_elemental, b_outside_playable_area, radius);
        return ai_zombie;
    }

    return undefined;
}

sentinel_pathupdateinterrupt()
{
    self endon("death");
    self endon("change_state");
    self endon("near_goal");
    self endon("reached_end_node");
    self notify("sentinel_pathupdateinterrupt");
    self endon("sentinel_pathupdateinterrupt");

    skip_sentinel_pathupdateinterrupt = GetDvarInt("skip_sentinel_PathUpdateInterrupt", 1);

    if(skip_sentinel_pathupdateinterrupt == 1)
        return;

    wait 1;

    while(1)
    {
        if(isDefined(self.current_pathto_pos))
        {
            if(Distance2DSquared(self.origin, self.goalpos) < self.goalradius * self.goalradius)
            {
                wait 0.2;
                self notify("near_goal");
            }
        }

        wait 0.2;
    }
}

waittill_pathing_done(maxtime = 15)
{
    self endon("change_state");
    self util::waittill_any_ex(maxtime, "near_goal", "force_goal", "reached_end_node", "goal", "pathfind_failed", "change_state");
}

sentinel_killmyself()
{
    self DoDamage(self.health + 100, self.origin);
}
















//Mangler
ServerSpawnMangler()
{
    var_19764360 = mangler_get_favorite_enemy();

    if(!isDefined(var_19764360))
        return;

    trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);

    origin = trace["position"];
    surface = trace["surfacetype"];

    if(surface == "none" || surface == "default")
        return self iPrintlnBold("^1ERROR: ^7Invalid Surface");

    s_location = (self.AISpawnLocation == "Crosshairs") ? self TraceBullet() : self.origin;
    ai = function_665a13cd(level.var_6bca5baa[0]);

    if(isDefined(ai))
    {
        ai thread function_b8671cc0(s_location);
        ai ForceTeleport(s_location);

        if(isDefined(var_19764360))
        {
            ai.favoriteenemy = var_19764360;
            ai.favoriteenemy.hunted_by++;
        }

        level.zombie_total--;
    }
}

mangler_get_favorite_enemy()
{
    var_bc3f44bf = GetPlayers();
    e_least_hunted = undefined;

    foreach(var_9e2c0900, e_target in var_bc3f44bf)
    {
        if(!isDefined(e_target.hunted_by))
            e_target.hunted_by = 0;

        if(!zm_utility::is_player_valid(e_target) || isDefined(level.var_3fded92e) && ![[ level.var_3fded92e ]](e_target))
            continue;

        if(!isDefined(e_least_hunted))
        {
            e_least_hunted = e_target;
            continue;
        }

        if(e_target.hunted_by < e_least_hunted.hunted_by)
            e_least_hunted = e_target;
    }

    return e_least_hunted;
}

function_665a13cd(spawner, s_spot)
{
    var_a09c80cd = zombie_utility::spawn_zombie(level.var_6bca5baa[0], "raz", s_spot);

    if(isDefined(var_a09c80cd))
    {
        var_a09c80cd.check_point_in_enabled_zone = zm_utility::check_point_in_playable_area;
        var_a09c80cd thread zombie_utility::round_spawn_failsafe();
        var_a09c80cd thread function_b8671cc0(s_spot);
    }

    return var_a09c80cd;
}

function_b8671cc0(s_spot)
{
    if(isDefined(level.var_71ab2462))
        self thread [[ level.var_71ab2462 ]](s_spot);

    if(isDefined(level.var_ae95a175))
        self thread [[ level.var_ae95a175 ]]();
}










//Thrasher
ServerSpawnThrasher()
{
    s_loc = self GetAISpawnLocation();
    var_e3372b59 = zombie_utility::spawn_zombie(level.var_feebf312[0], "thrasher", s_loc);

    if(isDefined(var_e3372b59) && isDefined(s_loc))
    {
        var_e3372b59 Forceteleport(s_loc);
        PlaySoundAtPosition("zmb_vocals_thrash_spawn", var_e3372b59.origin);

        if(!var_e3372b59 zm_utility::in_playable_area())
        {
            player = array::random(level.players);

            if(zm_utility::is_player_valid(player, 0, 1))
                var_e3372b59 thread function_89976d94(player.origin);
        }

        return var_e3372b59;
    }
}

function_89976d94(v_pos)
{
    self endon("death");

    var_2e57f81c = util::spawn_model("tag_origin", self.origin, self.angles);
    var_2e57f81c thread scene::play("scene_zm_dlc2_thrasher_teleport_out", self);
    self util::waittill_notify_or_timeout("thrasher_teleport_out_done", 4);
    a_v_points = util::positionquery_pointarray(v_pos, 128, 750, 32, 64, self);

    if(isDefined(self.thrasher_teleport_dest_func))
        a_v_points = self [[ self.thrasher_teleport_dest_func ]](a_v_points);

    var_72436e1a = ArrayGetFarthest(v_pos, a_v_points);

    if(isDefined(var_72436e1a))
    {
        var_948d85e3 = util::spawn_model("tag_origin", var_72436e1a, VectorToAngles(VectorNormalize((v_pos - var_72436e1a))));
        var_2e57f81c scene::stop("scene_zm_dlc2_thrasher_teleport_out");
        var_948d85e3 thread scene::play("scene_zm_dlc2_thrasher_teleport_in_v1", self);
    }
    else
    {
        var_948d85e3 = util::spawn_model("tag_origin", v_pos, (0, 0, 0));
        var_2e57f81c scene::stop("scene_zm_dlc2_thrasher_teleport_out");
        var_948d85e3 thread scene::play("scene_zm_dlc2_thrasher_teleport_in_v1", self);
    }
}














//Spiders
ServerSpawnSpider()
{
    ai = zombie_utility::spawn_zombie(level.var_c38a4fee[0]);

    if(isDefined(ai))
    {
        thread function_49e57a3b(ai);
        level.zombie_total--;
        level flag::set("spider_clips");
    }

    if(isDefined(ai))
        return ai;
}

spider_get_favorite_enemy()
{
    var_5a210579 = level.players;
    e_least_hunted = var_5a210579[0];

    for(i = 0; i < var_5a210579.size; i++)
    {
        if(!isDefined(var_5a210579[i].hunted_by))
            var_5a210579[i].hunted_by = 0;

        if(!zm_utility::is_player_valid(var_5a210579[i]))
            continue;

        if(!zm_utility::is_player_valid(e_least_hunted))
            e_least_hunted = var_5a210579[i];

        if(var_5a210579[i].hunted_by < e_least_hunted.hunted_by)
            e_least_hunted = var_5a210579[i];
    }

    e_least_hunted.hunted_by = (e_least_hunted.hunted_by + 1);

    return e_least_hunted;
}

function_49e57a3b(var_c79d3f71)
{
    var_c79d3f71 endon("death");

    var_c79d3f71 ai::set_ignoreall(1);
    spawn_location = self GetAISpawnLocation();
    var_c79d3f71 Ghost();
    var_c79d3f71 util::delay(0.2, "death", ::Show);
    var_c79d3f71 util::delay_notify(0.2, "visible", "death");
    var_c79d3f71.origin = spawn_location;
    var_c79d3f71 vehicle_ai::set_state("scripted");

    if(IsAlive(var_c79d3f71))
    {
        a_ground_trace = GroundTrace((var_c79d3f71.origin + VectorScale((0, 0, 1), 100)), (var_c79d3f71.origin - VectorScale((0, 0, 1), 1000)), 0, var_c79d3f71, 1);
        var_197f1988 = util::spawn_model("tag_origin", isDefined(a_ground_trace["position"]) ? a_ground_trace["position"] : var_c79d3f71.origin, var_c79d3f71.angles);

        var_197f1988 scene::play("scene_zm_dlc2_spider_burrow_out_of_ground", var_c79d3f71);
        var_c79d3f71 vehicle_ai::set_state((RandomFloat(1) > 0.6) ? "meleeCombat" : "combat");
        var_c79d3f71 SetVisibleToAll();
        var_c79d3f71 ai::set_ignoreme(0);
    }

    var_c79d3f71 ai::set_ignoreall(0);
}


















//Fury
ServerSpawnFury()
{
    s_loc = self GetAISpawnLocation();
    var_33504256 = SpawnActor("spawner_zm_genesis_apothicon_fury", s_loc, (0, 0, 0), undefined, 1, 1);

    if(isDefined(var_33504256))
    {
        var_33504256 endon("death");

        var_33504256.spawn_time = GetTime();
        var_33504256.var_1cba9ac3 = 1;
        var_33504256.heroweapon_kill_power = 2;
        var_33504256.completed_emerging_into_playable_area = 1;
        var_33504256 thread apothicon_fury_death();
        var_33504256 thread zm::update_zone_name();
        level thread zm_spawner::zombie_death_event(var_33504256);
        var_33504256 thread zm_spawner::enemy_death_detection();
        var_33504256 thread function_7ba80ea7();
        var_33504256 thread function_1be68e3f();
        var_33504256.voiceprefix = "fury";
        var_33504256.animname = "fury";
        var_33504256 thread zm_spawner::play_ambient_zombie_vocals();
        var_33504256 thread zm_audio::zmbaivox_notifyconvert();
        var_33504256 PlaySound("zmb_vocals_fury_spawn");

        wait 1;
        var_33504256.zombie_think_done = 1;

        return var_33504256;
    }

    return undefined;
}

apothicon_fury_death()
{
    self waittill("death", e_attacker);

    if(isDefined(e_attacker) && isDefined(e_attacker.var_4d307aef))
        e_attacker.var_4d307aef++;

    if(isDefined(e_attacker) && isDefined(e_attacker.var_8b5008fe))
        e_attacker.var_8b5008fe++;
}

function_7ba80ea7()
{
    self.is_zombie = 1;
    zombiehealth = level.zombie_health;

    if(!isDefined(zombiehealth))
        zombiehealth = level.zombie_vars["zombie_health_start"];

    self.maxhealth = (level.round_number <= 20) ? (zombiehealth * 1.2) : (level.round_number <= 50) ? (zombiehealth * 1.5) : (zombiehealth * 1.7);

    if(!isDefined(self.maxhealth) || self.maxhealth <= 0 || self.maxhealth > 2147483647 || self.maxhealth != self.maxhealth)
        self.maxhealth = zombiehealth;

    self.health = Int(self.maxhealth);
}

function_1be68e3f()
{
    self endon("death");

    while(1)
    {
        if(isDefined(self.zone_name))
            if(self.zone_name == "dark_arena_zone" || self.zone_name == "dark_arena2_zone")
                if(!IsPointOnNavMesh(self.origin))
                    self ForceTeleport(GetClosestPointOnNavMesh(self.origin, 256, 30));

        wait 0.25;
    }
}














//Quad Zombie(Nova Gas Zombie)
ServerSpawnNovaZombie()
{
    spawn_array = isDefined(level.quad_spawners) ? level.quad_spawners : GetEntArray("quad_zombie_spawner", "script_noteworthy");
    spawn_point = spawn_array[RandomInt(spawn_array.size)];
    ai = zombie_utility::spawn_zombie(spawn_point);
    s_loc = self GetAISpawnLocation();

    if(isDefined(ai))
    {
        ai thread zombie_utility::round_spawn_failsafe();
        ai thread QuadSetup();
        wait 1;

        linker = Spawn("script_origin", ai.origin);
        linker.origin = ai.origin;
        linker.angles = ai.angles;

        ai LinkTo(linker);
        linker MoveTo(s_loc, 0.01);

        linker waittill("movedone");

        ai Unlink();
        linker delete();

        ai thread quad_traverse_death_fx();
    }
}

quad_traverse_death_fx()
{
    self endon("traverse_anim");

    self waittill("death");
    PlayFX(level._effect["quad_grnd_dust_spwnr"], self.origin);
}

QuadSetup()
{
    self.animname = "quad_zombie";
    self.no_gib = 1;
    self.no_eye_glow = 1;
    self.no_widows_wine = 1;
    self.canbetargetedbyturnedzombies = 1;
    self zm_spawner::zombie_spawn_init(1);
    self.zombie_can_sidestep = 0;
    self.maxhealth = Int((self.maxhealth * 0.75));
    self.health = self.maxhealth;
    self.freezegun_damage = 0;
    self.meleedamage = 45;
    self PlaySound("zmb_quad_spawn");
    self.death_explo_radius_zomb = 96;
    self.death_explo_radius_plr = 96;
    self.death_explo_damage_zomb = 1.05;
    self.death_gas_radius = 125;
    self.death_gas_time = 7;

    if(isDefined(level.quad_explode) && level.quad_explode)
    {
        self.deathfunction = ::quad_post_death;
        self.actor_killed_override = ::quad_killed_override;
    }

    self set_default_attack_properties();
    self.thundergun_knockdown_func = ::quad_thundergun_knockdown;
    self.pre_teleport_func = ::quad_pre_teleport;
    self.post_teleport_func = ::quad_post_teleport;
    self.can_explode = 0;
    self.exploded = 0;
    self thread quad_trail();
    self AllowPitchAngle(1);
    self SetPhysParams(15, 0, 24);

    if(isDefined(level.quad_prespawn))
        self thread [[ level.quad_prespawn ]]();
}

quad_post_death(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime)
{
    self zm_spawner::zombie_death_animscript();
    return 0;
}

quad_killed_override(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime)
{
    if(smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET")
        self.can_explode = 1;
    else
    {
        self.can_explode = 0;

        if(isDefined(self.fx_quad_trail))
        {
            self.fx_quad_trail unlink();
            self.fx_quad_trail delete();
        }
    }

    if(isDefined(level._override_quad_explosion))
        [[ level._override_quad_explosion ]](self);
}

set_default_attack_properties()
{
    self.goalradius = 16;
    self.maxsightdistsqrd = 16384;
    self.can_leap = 0;
}

quad_thundergun_knockdown(player, gib)
{
    self DoDamage(Int(self.maxhealth * 0.5), player.origin, player);
}

quad_pre_teleport()
{
    if(isDefined(self.fx_quad_trail))
    {
        self.fx_quad_trail unlink();
        self.fx_quad_trail delete();

        wait 0.1;
    }
}

quad_post_teleport()
{
    if(isDefined(self.fx_quad_trail))
    {
        self.fx_quad_trail unlink();
        self.fx_quad_trail delete();
    }

    if(self.health > 0)
    {
        self.fx_quad_trail = Spawn("script_model", self GetTagOrigin("tag_origin"));
        self.fx_quad_trail.angles = self GetTagAngles("tag_origin");
        self.fx_quad_trail SetModel("tag_origin");
        self.fx_quad_trail LinkTo(self, "tag_origin");
        zm_net::network_safe_play_fx_on_tag("quad_fx", 2, level._effect["quad_trail"], self.fx_quad_trail, "tag_origin");
    }
}

quad_trail()
{
    self endon("death");

    self.fx_quad_trail = Spawn("script_model", self GetTagOrigin("tag_origin"));
    self.fx_quad_trail.angles = self GetTagAngles("tag_origin");
    self.fx_quad_trail SetModel("tag_origin");
    self.fx_quad_trail LinkTo(self, "tag_origin");
    zm_net::network_safe_play_fx_on_tag("quad_fx", 2, level._effect["quad_trail"], self.fx_quad_trail, "tag_origin");
}