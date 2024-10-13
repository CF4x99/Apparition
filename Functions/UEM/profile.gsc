
UEMCompleteCurrentCamo(player)
{
    currentWeapon = player GetCurrentWeapon();
    var_480fed80 = player function_1c1990e8(currentWeapon);

    if(!isDefined(var_480fed80))
        return self iPrintlnBold("^1ERROR: ^7Weapon Not Found");
    
    if(var_480fed80.var_4c25c2f2 >= 20)
        return self iPrintlnBold("^1ERROR: ^7Weapon Camo Is At Max");
    
    if(Is_True(player.CompleteCurrentCamo))
        return self iPrintlnBold("^1ERROR: ^7Camo Is Being Completed");
    player.CompleteCurrentCamo = true;
    
    var_480fed80.var_79fe8f18 = level.var_ce9bfb71[var_480fed80.var_4c25c2f2];
    player LUINotifyEvent(&"spx_gun_level", 2, Int(var_480fed80.var_79fe8f18), Int(level.var_ce9bfb71[var_480fed80.var_4c25c2f2]));
    wait 0.1;

    if(var_480fed80.var_79fe8f18 >= level.var_ce9bfb71[var_480fed80.var_4c25c2f2])
    {
        var_480fed80.var_4c25c2f2 = (var_480fed80.var_4c25c2f2 + 1);
        var_480fed80.var_79fe8f18 = 0;
        var_480fed80.pap_camo_to_use = level.var_1e656cc4[var_480fed80.var_4c25c2f2];

		/*
			This part of the block is guess work
			The real line is getplayers()[0] function_c8540b60(self.damageWeapon, getplayers()[0] calcweaponoptions(level.var_1e656cc4[var_480fed80.var_4c25c2f2], 0, 0));
		*/
        player TakeWeapon(currentWeapon);
        player GiveWeapon(currentWeapon, player CalcWeaponOptions(level.var_1e656cc4[var_480fed80.var_4c25c2f2], 0, 0));
        player SetSpawnWeapon(currentWeapon, true);

        player LUINotifyEvent(&"spx_camo_notification", 1, int(var_480fed80.var_4c25c2f2));
        player LUINotifyEvent(&"spx_gun_level", 2, Int(var_480fed80.var_79fe8f18), Int(level.var_ce9bfb71[var_480fed80.var_4c25c2f2]));
        player thread function_e5bef058(var_480fed80.var_4c25c2f2);
    }

    player thread function_cf47e18304e(var_480fed80.stored_weapon.rootweapon.name, var_480fed80.var_4c25c2f2, var_480fed80.var_79fe8f18);
    player.CompleteCurrentCamo = false;
}

function_1c1990e8(weapon)
{
	if(isDefined(self.var_3818be12) && self.var_3818be12.size > 0)
		foreach(var_52bd8d74 in self.var_3818be12)
			if(var_52bd8d74.stored_weapon == weapon.rootweapon)
				return var_52bd8d74;
    
	return undefined;
}

function_e5bef058(var_4c25c2f2)
{
	values = Array(25, 50, 100, 150, 200, 300, 400, 600, 800, 1000, 1200, 1200, 1400, 1400, 1600, 1600, 1800, 1800, 2000, 2000, 2200, 2200);

	self.pers["player_points"] += values[(var_4c25c2f2 - 1)];
	self notify("hash_79ef118b", "camo_" + var_4c25c2f2 + "_obtained");
}

function_cf47e18304e(var_bd058c01, weapon_level, var_2b90edc8)
{
	if(!isDefined(weapon_level))
		weapon_level = 0;
    
	if(!isDefined(var_2b90edc8))
		var_2b90edc8 = 0;
    
	if(self IsSplitScreen() && self.name == level.players[0].name + " 1" || (self IsSplitScreen() && self.name == level.players[0].name + " 2") || (self IsSplitScreen() && self.name == level.players[0].name + " 3") || (self IsSplitScreen() && self.name == level.players[0].name + " 4") || (self IsSplitScreen() && self.name == level.players[0].name + " 5") || (self IsSplitScreen() && self.name == level.players[0].name + " 6") || (self IsSplitScreen() && self.name == level.players[0].name + " 7"))
		return;
    
    self LUINotifyEvent(&"spx_weapon_save_data", 2, Int(level.var_e2a6fd15["xuid"]), Int(self GetXUID(1)));
    wait 0.1;

    self LUINotifyEvent(&"spx_weapon_save_data", 2, Int(level.var_e2a6fd15["reset_keyword"]), Int(35184));
    wait 0.1;

    self LUINotifyEvent(&"spx_weapon_save_data", 3, Int(level.var_e2a6fd15[var_bd058c01]), Int(weapon_level), Int(var_2b90edc8));
    wait 0.1;
}

UEMUnlockHat(type, player)
{
    type = ToLower(type);

    player.pers[type + "_hat"] = 1;
    wait 0.1;

    UEMForceSaveStats(player);
}

UEMForceSaveStats(player)
{
    if(isDefined(player.var_c6452f46["leveling"]) && player.var_c6452f46["leveling"])
		player thread function_e35ae7ed(level.var_ac46587c, &"spx_save_data");

	if(isDefined(player.var_c6452f46["map"]) && player.var_c6452f46["map"])
		player thread function_e35ae7ed(level.var_c3e446a, &"spx_maps_save_data");
    
	if(isDefined(player.var_c6452f46["weapon"]) && player.var_c6452f46["weapon"])
		player thread function_e35ae7ed(level.var_e2a6fd15, &"spx_weapon_save_data");
    
    player SetControllerUIModelValue("UEM.send_leaderboard_data", 1);
    wait 1;
    
    player SetControllerUIModelValue("UEM.send_leaderboard_data", 0);
	player iPrintlnBold("Stats ^2Saved");
}

function_e35ae7ed(var_6820b605, var_66873ffe)
{
	var_c0d6d88 = 0;

	for(i = 0; i < GetPlayers().size; i++)
		if(self IsSplitScreen() && self.name == level.players[i].name + " 1" || (self IsSplitScreen() && self.name == level.players[i].name + " 2") || (self IsSplitScreen() && self.name == level.players[i].name + " 3") || (self IsSplitScreen() && self.name == level.players[i].name + " 4"))
			var_c0d6d88 = 1;

	if(!(isDefined(var_c0d6d88) && var_c0d6d88))
	{
		self LUINotifyEvent(var_66873ffe, 2, var_6820b605["savedata"], 1);

		if(self.var_9ee9bcc6 >= 20 && self.var_dc71288)
			self LUINotifyEvent(var_66873ffe, 2, var_6820b605["savedatabackup"], 1);
        
		if(self.var_9ee9bcc6 == 5 && self.var_dc71288)
			self LUINotifyEvent(var_66873ffe, 2, var_6820b605["savedatabackupfirst"], 1);
	}
}

UEMLeaderboardKiller()
{
    stats = Array("kills", "time_played_total", "highest_round", "total_games_played", "powerups_grabbed", "special_kills", "zombie_kills", "highest_total_playtime", "game_bgbs_chewed", "headshots", "total_rounds", "game_use_magicbox", "game_distance_traveled", "succesful_exfil", "exfil_started", "player_points", "assists", "revives", "wunderfizz_used", "perks_drank", "total_points");

    foreach(stat in stats)
        self function_7e18304e("spx_save_data", stat, 9999999, 0);

    extra = Array("prestige_legend", "prestige_absolute", "prestige_ultimate");

    foreach(stat in extra)
        self function_7e18304e("spx_save_data", stat, 5, 0);
	
	self function_7e18304e("spx_save_data", "xuid", "76561199540349999", 0);
	self thread function_7e18304e("spx_maps_save_data", "xuid", "76561199540349999", 0);
	wait 1;

    foreach(data in self.var_84298650)
    {
        if(!isDefined(data.type) || !isDefined(data.var_bd058c01) || !isDefined(data.value))
            continue;

        if(data.type == "spx_save_data")
            self luinotifyevent(&"spx_save_data", 2, int(level.var_ac46587c[data.var_bd058c01]), int(data.value));
        else if(data.type == "spx_end_game_save_data")
        {
            if(isDefined(data.overwrite) && data.overwrite)
                self.pers[data.var_bd058c01] = data.value;
            else
                self.pers[data.var_bd058c01] = self.pers[data.var_bd058c01] + data.value;

            self luinotifyevent(&"spx_end_game_save_data", 2, int(level.var_5e620cb1[data.var_bd058c01]), int(self.pers[data.var_bd058c01]));
        }
		else if(data.type == "spx_maps_save_data")
			self luinotifyevent(&"spx_maps_save_data", 2, int(level.var_c3e446a[data.var_bd058c01]), int(data.value));
    }

    wait 1;
    self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7Force Save Stats Now");
}

function_7e18304e(type, var_bd058c01, value, overwrite, priority, var_363c7886, var_e0ea0acc, var_52f17a07, var_2ceeff9e, var_6ee29b91, var_48e02128)
{
	if(!isDefined(overwrite))
		overwrite = 0;
    
	if(!isDefined(priority))
		priority = 0;
    
	if(!isDefined(var_363c7886))
		var_363c7886 = 0;
    
	if(!isDefined(var_e0ea0acc))
		var_e0ea0acc = undefined;
    
	if(!isDefined(var_52f17a07))
		var_52f17a07 = undefined;
    
	if(!isDefined(var_2ceeff9e))
		var_2ceeff9e = undefined;
    
	if(!isDefined(var_6ee29b91))
		var_6ee29b91 = undefined;
    
	if(!isDefined(var_48e02128))
		var_48e02128 = undefined;

	if(isDefined(self.var_c6452f46["leveling"]) && self.var_c6452f46["leveling"])
	{
		if(!isDefined(value))
			value = 0;
        
		if(!isDefined(self.var_84298650))
			self.var_84298650 = [];
        
		if(!isDefined(self.var_1c3ca2eb))
			self.var_1c3ca2eb = [];

		key = var_bd058c01;

		if(isDefined(var_363c7886) && var_363c7886)
			key = var_bd058c01 + RandomIntRange(0, 1000000);

		if(isDefined(self.var_84298650[var_bd058c01]))
			self.var_84298650[var_bd058c01].value = value;
		else
		{
			var_535f7585 = SpawnStruct();
			var_535f7585.type = type;
			var_535f7585.var_bd058c01 = var_bd058c01;
			var_535f7585.value = value;
			var_535f7585.var_e0ea0acc = var_e0ea0acc;
			var_535f7585.var_52f17a07 = var_52f17a07;
			var_535f7585.var_2ceeff9e = var_2ceeff9e;
			var_535f7585.var_6ee29b91 = var_6ee29b91;
			var_535f7585.var_48e02128 = var_48e02128;
			var_535f7585.overwrite = overwrite;
			var_535f7585.priority = priority;

			if(isDefined(var_363c7886) && var_363c7886)
				var_535f7585.Randomized = key;

			if(isDefined(priority) && priority)
				self.var_1c3ca2eb[key] = var_535f7585;
			else
				self.var_84298650[key] = var_535f7585;
		}
	}
}