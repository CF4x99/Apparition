PopulateServerTweakables(menu)
{
    switch(menu)
    {
        case "Server Tweakables":
            self addMenu("Server Tweakables");
                self addOpt("Enabled Power-Ups", ::newMenu, "Enabled Power-Ups");
                self addOptIncSlider("Pack 'a' Punch Camo Index", ::SetPackCamoIndex, 0, level.pack_a_punch_camo_index, 138, 1);
                self addOptIncSlider("Player Weapon Limit", ::SetPlayerWeaponLimit, 0, 0, 15, 1);
                self addOptIncSlider("Player Perk Limit", ::SetPlayerPerkLimit, 0, 0, level.MenuPerks.size, 1);
                self addOptIncSlider("Clip Size Multiplier", ::ServerSetClipSizeMultiplier, 1, 1, 10, 1);
                self addOptIncSlider("Revive Trigger Radius", ::ServerSetReviveRadius, 0, GetDvarInt("revive_trigger_radius"), 1000, 25);
                self addOptIncSlider("Last Stand Bleedout Time", ::ServerSetLastandTime, 0, GetDvarInt("player_lastStandBleedoutTime"), 1000, 1);
                self addOptBool((level.zombie_vars["zombie_between_round_time"] == 0.1), "Fast Round Intermission", ::FastRoundIntermission);
                self addOptBool(level.UpgradeWeaponWallbuys, "Upgrade Weapon Wallbuys", ::ServerUpgradeWeaponWallbuys);
                self addOptBool(level.ServerMaxAmmoClips, "Max Ammo Powerups Fill Clips", ::ServerMaxAmmoClips);
                self addOptBool(level.IncreasedDropRate, "Increased Power-Up Drop Rate", ::IncreasedDropRate);
                self addOptBool(level.PowerupsNeverLeave, "Power-Ups Never Leave", ::PowerupsNeverLeave);
                self addOptBool(level.DisablePowerups, "Disable Power-Ups", ::DisablePowerups);
                self addOptBool(level.ShootToRevive, "Shoot To Revive", ::ShootToRevive);
                self addOptBool(level.headshots_only, "Headshots Only", ::headshots_only);
                self addOpt("Pack 'a' Punch Price", ::NumberPad, ::EditPackAPunchPrice);
                self addOpt("Repack 'a' Punch Price", ::NumberPad, ::EditRepackAPunchPrice);
            break;
        
        case "Enabled Power-Ups":
            powerups = GetArrayKeys(level.zombie_include_powerups);

            self addMenu("Enabled Power-Ups");

                for(a = 0; a < powerups.size; a++)
                {
                    if(!isDefined(powerups[a]) || !isDefined(level.zombie_powerups[powerups[a]].func_should_drop_with_regular_powerups) || !IsFunctionPtr(level.zombie_powerups[powerups[a]].func_should_drop_with_regular_powerups))
                        continue;
                    
                    self addOptBool([[ level.zombie_powerups[powerups[a]].func_should_drop_with_regular_powerups ]](), ReturnPowerupName(powerups[a]), ::SetPowerUpState, powerups[a]);
                }
            break;
    }
}

SetPowerUpState(powerup)
{
    if(!isDefined(powerup) || !isDefined(level.zombie_powerups[powerup].func_should_drop_with_regular_powerups) || !IsFunctionPtr(level.zombie_powerups[powerup].func_should_drop_with_regular_powerups))
        return;
    
    if(GetActivePowerUpCount() < 2 && Is_True([[ level.zombie_powerups[powerup].func_should_drop_with_regular_powerups ]]()))
        return self iPrintlnBold("^1ERROR: ^7At Least One Power-Up Must Be Enabled");
    
    level.zombie_powerups[powerup].func_should_drop_with_regular_powerups = Is_True([[ level.zombie_powerups[powerup].func_should_drop_with_regular_powerups ]]()) ? zm_powerups::func_should_never_drop : zm_powerups::func_should_always_drop;
}

GetActivePowerUpCount()
{
    index = 0;
    powerups = GetArrayKeys(level.zombie_include_powerups);

    for(a = 0; a < powerups.size; a++)
    {
        if(!isDefined(powerups[a]))
            continue;
        
        if(Is_True([[ level.zombie_powerups[powerups[a]].func_should_drop_with_regular_powerups ]]()))
            index++;
    }

    return index;
}

SetPackCamoIndex(index)
{
    level.pack_a_punch_camo_index = index;
}

SetPlayerWeaponLimit(limit)
{
    level.CustomPlayerWeaponLimit = limit;
    level.additionalprimaryweapon_limit = limit;

    foreach(player in level.players)
        if(isDefined(player.get_player_weapon_limit))
            player.get_player_weapon_limit = ::GetPlayerWeaponLimit;

    level.get_player_weapon_limit = ::GetPlayerWeaponLimit;
}

GetPlayerWeaponLimit(player)
{
    return level.CustomPlayerWeaponLimit;
}

SetPlayerPerkLimit(limit)
{
    level.CustomPerkLimit = limit;
    level.perk_purchase_limit = limit;
    level.get_player_perk_purchase_limit = ::GetPlayerPerkLimit;
}

GetPlayerPerkLimit(player)
{
    return level.CustomPerkLimit;
}

ServerSetClipSizeMultiplier(multiplier)
{
    SetDvar("player_clipSizeMultiplier", multiplier);
}

ServerSetReviveRadius(radius)
{
    SetDvar("revive_trigger_radius", radius);
}

ServerSetLastandTime(time)
{
    SetDvar("player_lastStandBleedoutTime", time);
}

FastRoundIntermission()
{
    level.zombie_vars["zombie_between_round_time"] = (level.zombie_vars["zombie_between_round_time"] == 0.1 ? level.roundIntermissionTime : 0.1);
}

ServerUpgradeWeaponWallbuys()
{
    level.UpgradeWeaponWallbuys = BoolVar(level.UpgradeWeaponWallbuys);

    if(Is_True(level.UpgradeWeaponWallbuys))
    {
        if(isDefined(level.wallbuy_should_upgrade_weapon_override))
            level.saved_wallbuy_should_upgrade_weapon_override = level.wallbuy_should_upgrade_weapon_override;
        
        level.wallbuy_should_upgrade_weapon_override = ::wallbuy_should_upgrade_weapon_override;
    }
    else
        level.wallbuy_should_upgrade_weapon_override = isDefined(level.saved_wallbuy_should_upgrade_weapon_override) ? level.saved_wallbuy_should_upgrade_weapon_override : undefined;
}

ServerMaxAmmoClips()
{
    level.ServerMaxAmmoClips = Boolvar(level.ServerMaxAmmoClips);

    if(Is_True(level.ServerMaxAmmoClips))
        level thread WatchForMaxAmmo();
    else
    {
        level.WatchForMaxAmmo = undefined;
        level notify("EndMaxAmmoMonitor");
    }
}

IncreasedDropRate()
{
    if(Is_True(level.DisablePowerups) && !Is_True(level.IncreasedDropRate))
        level DisablePowerups();
    
    level.IncreasedDropRate = BoolVar(level.IncreasedDropRate);

    if(Is_True(level.IncreasedDropRate))
    {
        while(Is_True(level.IncreasedDropRate))
        {
            if(isDefined(level.powerup_drop_count) && level.powerup_drop_count > 0 || !isDefined(level.powerup_drop_count))
                level.powerup_drop_count = 0;

            if(level.zombie_vars["zombie_drop_item"] != 1)
                level.zombie_vars["zombie_drop_item"] = 1;

            if(level.zombie_vars["zombie_powerup_drop_max_per_round"] != 999)
                level.zombie_vars["zombie_powerup_drop_max_per_round"] = 999;
            
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(isDefined(zombies[a]) && (!isDefined(zombies[a].no_powerup) || zombies[a].no_powerup))
                    zombies[a].no_powerup = false;
            }

            wait 0.01;
        }
    }
    else
        level.zombie_vars["zombie_powerup_drop_max_per_round"] = 4;
}

PowerupsNeverLeave()
{
    level.PowerupsNeverLeave = BoolVar(level.PowerupsNeverLeave);
    level._powerup_timeout_override = Is_True(level.PowerupsNeverLeave) ? PowerUpTime() : undefined;
}

PowerUpTime()
{
    return 0;
}

DisablePowerups()
{
    if(Is_True(level.IncreasedDropRate) && !Is_True(level.DisablePowerups))
        level IncreasedDropRate();
    
    level.DisablePowerups = BoolVar(level.DisablePowerups);

    if(Is_True(level.DisablePowerups))
    {
        powerups = zm_powerups::get_powerups(self.origin, 46340); //active powerups array is being weird and not returning all of the active powerups? -- distancesquared(origin, powerup.origin) < (radius * radius) -- 46340.50 is sqrt of int max

        if(isDefined(powerups) && powerups.size)
        {
            foreach(index, powerup in powerups)
            {
                powerup notify("powerup_timedout");
                powerup zm_powerups::powerup_delete();

                wait 0.01;
            }
        }
        
        while(Is_True(level.DisablePowerups))
        {
            level waittill("powerup_dropped", powerup);
            
            if(isDefined(powerup))
            {
                powerup notify("powerup_timedout");
                powerup thread zm_powerups::powerup_delete();
            }
        }
    }
    else
        level.powerup_drop_count = 0;
}

ShootToRevive()
{
    level.ShootToRevive = BoolVar(level.ShootToRevive);

    if(Is_True(level.ShootToRevive))
    {
        foreach(player in level.players)
            player thread PlayerShootToRevive();
    }
    else
        level notify("EndShootToRevive");
}

PlayerShootToRevive()
{
    self endon("disconnect");
    level endon("EndShootToRevive");

    while(Is_True(level.ShootToRevive))
    {
        self waittill("weapon_fired");

        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), true, self);

        traceEntity = trace["entity"];
        tracePosition = trace["position"];
        
        /*
            For less of a hassle for the player, I'm running two traces.
            The first one is the case where you didn't shoot directly at the downed player, but shot near them
            The second one is the case that you shot them directly
        */

        if(!isDefined(traceEntity) || !IsPlayer(traceEntity))
        {
            foreach(player in level.players)
            {
                if(player == self || !Is_Alive(player) || !player IsDown() || Distance(tracePosition, player.origin) > 50)
                    continue;
                
                self thread PlayerShootRevive(player);
            }
        }
        else
        {
            if(!Is_Alive(traceEntity) || !traceEntity IsDown())
                continue;
            
            self thread PlayerShootRevive(traceEntity);
        }
    }
}

PlayerShootRevive(player)
{
    if(!isDefined(player) || !IsPlayer(player))
        return;
    
    if(isDefined(self.hud_damagefeedback))
        self zombie_utility::show_hit_marker();

    self PlayerRevive(player);
}

headshots_only()
{
    level.headshots_only = BoolVar(level.headshots_only);
}

EditPackAPunchPrice(price)
{
    vending_weapon_upgrade_trigger = level.pack_a_punch.triggers;

    if(isDefined(vending_weapon_upgrade_trigger) && vending_weapon_upgrade_trigger.size >= 1)
        foreach(index, trigger in vending_weapon_upgrade_trigger)
            trigger.cost = price;
}

EditRepackAPunchPrice(price)
{
    vending_weapon_upgrade_trigger = level.pack_a_punch.triggers;

    if(isDefined(vending_weapon_upgrade_trigger) && vending_weapon_upgrade_trigger.size >= 1)
        foreach(index, trigger in vending_weapon_upgrade_trigger)
            trigger.aat_cost = price;
}