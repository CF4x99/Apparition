PopulateProfileManagement(menu, player)
{
    switch(menu)
    {
        case "Profile Management":
            self addMenu("Profile Management");
                self addOptBool(player.LiquidsLoop, "Liquid Divinium", ::LiquidsLoop, player);
                self addOptSlider("Challenges", ::AllChallenges, "Unlock;Lock", player);
                self addOpt("Complete Daily Challenges", ::CompleteDailyChallenges, player);
                self addOptSlider("Weapon Ranks", ::PlayerWeaponRanks, "Max;Reset", player);
                self addOptIncSlider("Rank", ::SetPlayerRank, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == level.maxprestige) ? 36 : 1, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == level.maxprestige) ? 36 : 1, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == level.maxprestige) ? 1000 : 35, 1, player);
                self addOptIncSlider("Prestige", ::SetPlayerPrestige, 0, player.pers["plevel"], 11, 1, player);
                self addOpt("Unlock All Achievements", ::UnlockAchievements, player);
                self addOpt("Clan Tag Options", ::newMenu, "Clan Tag Options");
                self addOpt("Custom Stats", ::newMenu, "Custom Stats");
                self addOpt("EE Stats", ::newMenu, "EE Stats");
            break;
        
        case "Clan Tag Options":
            self addMenu("Clan Tag Options");
                self addOpt("Reset", ::SetClanTag, "", player);
                self addOpt("Invisible Name", ::SetClanTag, "^Hä", player);
                self addOpt("@CF4", ::SetClanTag, "@CF4", player);
                self addOptSlider("Name Color", ::SetClanTag, "Black;Red;Green;Yellow;Blue;Cyan;Pink", player);
                self addOpt("Custom", ::Keyboard, ::SetClanTag, player);
            break;
        
        case "Custom Stats":

            if(!isDefined(player.CustomStatsValue))
                player.CustomStatsValue = 0;
            
            if(!isDefined(player.CustomStatsArray))
                player.CustomStatsArray = [];
            
            self addMenu("Custom Stats");
                self addOpt("Clear Selected Stats", ::ClearCustomStats, player);
                self addOpt("Custom Value: " + Int(player.CustomStatsValue), ::NumberPad, ::CustomStatsValue, player);
                self addOpt("Send Selected Stats", ::SetCustomStats, player);
                self addOpt("");
                self addOpt("General", ::newMenu, "General Stats");
                self addOpt("Gobblegum Uses", ::newMenu, "Gobblegum Stats");
                self addOpt("Maps", ::newMenu, "Map Stats");
            break;
        
        case "General Stats":
            stats = Array("kills", "headshots", "downs", "total_downs", "deaths", "revives", "rounds", "total_rounds_survived", "total_points", "perks_drank", "bgbs_chewed", "grenade_kills", "doors_purchased", "use_magicbox", "use_pap", "power_turnedon", "buildables_built", "total_shots", "hits", "misses", "distance_traveled", "total_games_played", "time_played_total");

            self addMenu("General");
                
                for(a = 0; a < stats.size; a++)
                    self addOptBool(isInArray(player.CustomStatsArray, stats[a]), CleanString(stats[a]), ::AddToCustomStats, stats[a], player);
            break;
        
        case "Gobblegum Stats":
            self addMenu("Gobblegum Uses");
                self addOptBool(player IsAllBGBStatsEnabled(), "Enable All", ::AllBGBStats, player);
                self addOpt("");

                if(isDefined(level.MenuBGB) && level.MenuBGB.size)
                    for(a = 0; a < level.MenuBGB.size; a++)
                        self addOptBool(isInArray(player.CustomStatsArray, level.MenuBGB[a]), GobblegumName(level.MenuBGB[a]), ::AddToCustomStats, level.MenuBGB[a], player);
            break;
        
        case "Map Stats":
            mapNames = Array("zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb");
            
            self addMenu("Map Stats");

                for(a = 0; a < mapNames.size; a++)
                    self addOpt(ReturnMapName(mapNames[a]), ::newMenu, "Map Stats " + mapNames[a]);
            break;
        
        case "EE Stats":
            stats = Array("DARKOPS_ZOD_EE", "DARKOPS_FACTORY_EE", "DARKOPS_CASTLE_EE", "DARKOPS_ISLAND_EE", "DARKOPS_STALINGRAD_EE", "DARKOPS_GENESIS_EE", "DARKOPS_ZOD_SUPER_EE", "DARKOPS_FACTORY_SUPER_EE", "DARKOPS_CASTLE_SUPER_EE", "DARKOPS_ISLAND_SUPER_EE", "DARKOPS_STALINGRAD_SUPER_EE", "DARKOPS_GENESIS_SUPER_EE");

            self addMenu("EE Stats");

            for(a = 0; a < stats.size; a++)
            {
                statTok = StrTok(stats[a], "_");
                map = ReturnMapName("zm_" + ToLower(statTok[1]));

                if(IsSubStr(ToLower(stats[a]), "super"))
                    map += " Super";

                self addOptBool(player GetDStat("PlayerStatsList", stats[a], "StatValue"), map + " EE", ::PlayerBoolStat, stats[a], player);
            }
            break;
    }
}

LiquidsLoop(player)
{
    player endon("disconnect");

    player.LiquidsLoop = BoolVar(player.LiquidsLoop);

    if(Is_True(player.LiquidsLoop))
    {
        reports = 0;
        
        while(Is_True(player.LiquidsLoop))
        {
            player ReportLootReward("3", 200);
            reports += 200;

            if(reports % 2000)
                player iPrintlnBold(reports + " ^BBUTTON_ZM_VIAL_ICON^ Reported");

            wait 0.1;
        }
    }
}

AllChallenges(type, player)
{
    if(Is_True(player.AllChallenges))
        return;
    player.AllChallenges = true;

    player endon("disconnect");

    if(player != self)
    {
        self iPrintlnBold("^2" + CleanName(player getName()) + ":^7 " + type + " All Challenges ^2Started");
        self iPrintlnBold("You'll Be Notified When Complete");
    }
    
    player iPrintlnBold(type + " All Challenges ^2Started");
    player iPrintlnBold("You'll Be Notified When Complete");

    for(a = 512; a < 642; a++)
    {
        stat = SpawnStruct();
        stat.value = Int(TableLookup("gamedata/stats/zm/statsmilestones3.csv", 0, a, 2));
        stat.type = TableLookup("gamedata/stats/zm/statsmilestones3.csv", 0, a, 3);
        stat.name = TableLookup("gamedata/stats/zm/statsmilestones3.csv", 0, a, 4);
        stat.split = TableLookup("gamedata/stats/zm/statsmilestones3.csv", 0, a, 13);

        switch(stat.type)
        {
            case "global":
                player SetDStat("PlayerStatsList", stat.name, "StatValue", (type == "Unlock") ? stat.value : 0);
                player SetDStat("PlayerStatsList", stat.name, "ChallengeValue", (type == "Unlock") ? stat.value : 0);
                break;

            case "attachment":
                foreach(attachment in StrTok(stat.split, " "))
                {
                    player SetDStat("attachments", attachment, "stats", stat.name, "StatValue", (type == "Unlock") ? stat.value : 0);
                    player SetDStat("attachments", attachment, "stats", stat.name, "ChallengeValue", (type == "Unlock") ? stat.value : 0);

                    for(b = 1; b < 8; b++)
                    {
                        player SetDStat("attachments", attachment, "stats", "challenge" + b, "StatValue", (type == "Unlock") ? stat.value : 0);
                        player SetDStat("attachments", attachment, "stats", "challenge" + b, "ChallengeValue", (type == "Unlock") ? stat.value : 0);
                    }
                }
                break;

            default:
                if(isDefined(stat.split))
                {
                    toks = StrTok(stat.split, " ");

                    if(isDefined(toks) && toks.size)
                    {
                        foreach(weapon in StrTok(stat.split, " "))
                            player AddWeaponStat(GetWeapon(weapon), stat.name, stat.value);
                    }
                }
                break;
        }

        wait 0.1;
    }

    player.AllChallenges = undefined;
    UploadStats(player);

    if(self != player)
        self iPrintlnBold("^2" + CleanName(player getName()) + ":^7 " + type + " All Challenges ^2Complete");
    
    player iPrintlnBold(type + " All Challenges ^2Completed");
}

UnlockAchievements(player)
{
    achievements = Array("CP_COMPLETE_PROLOGUE", "CP_COMPLETE_NEWWORLD", "CP_COMPLETE_BLACKSTATION", "CP_COMPLETE_BIODOMES", "CP_COMPLETE_SGEN", "CP_COMPLETE_VENGEANCE", "CP_COMPLETE_RAMSES", "CP_COMPLETE_INFECTION", "CP_COMPLETE_AQUIFER", "CP_COMPLETE_LOTUS", "CP_HARD_COMPLETE", "CP_REALISTIC_COMPLETE", "CP_CAMPAIGN_COMPLETE", "CP_FIREFLIES_KILL", "CP_UNSTOPPABLE_KILL", "CP_FLYING_WASP_KILL", "CP_TIMED_KILL", "CP_ALL_COLLECTIBLES", "CP_DIFFERENT_GUN_KILL", "CP_ALL_DECORATIONS", "CP_ALL_WEAPON_CAMOS", "CP_CONTROL_QUAD", "CP_MISSION_COLLECTIBLES", "CP_DISTANCE_KILL", "CP_OBSTRUCTED_KILL", "CP_MELEE_COMBO_KILL", "CP_COMPLETE_WALL_RUN", "CP_TRAINING_GOLD", "CP_COMBAT_ROBOT_KILL", "CP_KILL_WASPS", "CP_CYBERCORE_UPGRADE", "CP_ALL_WEAPON_ATTACHMENTS", "CP_TIMED_STUNNED_KILL", "CP_UNLOCK_DOA", "ZM_COMPLETE_RITUALS", "ZM_SPOT_SHADOWMAN", "ZM_GOBBLE_GUM", "ZM_STORE_KILL", "ZM_ROCKET_SHIELD_KILL", "ZM_CIVIL_PROTECTOR", "ZM_WINE_GRENADE_KILL", "ZM_MARGWA_KILL", "ZM_PARASITE_KILL", "MP_REACH_SERGEANT", "MP_REACH_ARENA", "MP_SPECIALIST_MEDALS", "MP_MULTI_KILL_MEDALS", "ZM_CASTLE_EE", "ZM_CASTLE_ALL_BOWS", "ZM_CASTLE_MINIGUN_MURDER", "ZM_CASTLE_UPGRADED_BOW", "ZM_CASTLE_MECH_TRAPPER", "ZM_CASTLE_SPIKE_REVIVE", "ZM_CASTLE_WALL_RUNNER", "ZM_CASTLE_ELECTROCUTIONER", "ZM_CASTLE_WUNDER_TOURIST", "ZM_CASTLE_WUNDER_SNIPER", "ZM_ISLAND_COMPLETE_EE", "ZM_ISLAND_DRINK_WINE", "ZM_ISLAND_CLONE_REVIVE", "ZM_ISLAND_OBTAIN_SKULL", "ZM_ISLAND_WONDER_KILL", "ZM_ISLAND_STAY_UNDERWATER", "ZM_ISLAND_THRASHER_RESCUE", "ZM_ISLAND_ELECTRIC_SHIELD", "ZM_ISLAND_DESTROY_WEBS", "ZM_ISLAND_EAT_FRUIT", "ZM_STALINGRAD_NIKOLAI", "ZM_STALINGRAD_WIELD_DRAGON", "ZM_STALINGRAD_TWENTY_ROUNDS", "ZM_STALINGRAD_RIDE_DRAGON", "ZM_STALINGRAD_LOCKDOWN", "ZM_STALINGRAD_SOLO_TRIALS", "ZM_STALINGRAD_BEAM_KILL", "ZM_STALINGRAD_STRIKE_DRAGON", "ZM_STALINGRAD_FAFNIR_KILL", "ZM_STALINGRAD_AIR_ZOMBIES", "ZM_GENESIS_EE", "ZM_GENESIS_SUPER_EE", "ZM_GENESIS_PACKECTOMY", "ZM_GENESIS_KEEPER_ASSIST", "ZM_GENESIS_DEATH_RAY", "ZM_GENESIS_GRAND_TOUR", "ZM_GENESIS_WARDROBE_CHANGE", "ZM_GENESIS_WONDERFUL", "ZM_GENESIS_CONTROLLED_CHAOS", "DLC2_ZOMBIE_ALL_TRAPS", "DLC2_ZOM_LUNARLANDERS", "DLC2_ZOM_FIREMONKEY", "DLC4_ZOM_TEMPLE_SIDEQUEST", "DLC4_ZOM_SMALL_CONSOLATION", "DLC5_ZOM_CRYOGENIC_PARTY", "DLC5_ZOM_GROUND_CONTROL", "ZM_DLC4_TOMB_SIDEQUEST", "ZM_DLC4_OVERACHIEVER", "ZM_PROTOTYPE_I_SAID_WERE_CLOSED", "ZM_ASYLUM_ACTED_ALONE", "ZM_THEATER_IVE_SEEN_SOME_THINGS");
    
    for(a = 0; a < achievements.size; a++)
        player GiveAchievement(achievements[a]);
}

SetClanTag(tag, player)
{
    switch(tag)
    {
        case "Black":
            tag = "^0";
            break;
        
        case "Red":
            tag = "^1";
            break;
        
        case "Green":
            tag = "^2";
            break;
        
        case "Yellow":
            tag = "^3";
            break;
        
        case "Blue":
            tag = "^4";
            break;
        
        case "Cyan":
            tag = "^5";
            break;
        
        case "Pink":
            tag = "^6";
            break;
        
        default:
            break;
    }
    
    player SetDStat("clanTagStats", "clanName", tag);
}

ClearCustomStats(player)
{
    player.CustomStatsArray = [];
}

CustomStatsValue(value, player)
{
    player.CustomStatsValue = value;
}

AddToCustomStats(stat, player)
{
    if(!isDefined(player.CustomStatsArray))
        player.CustomStatsArray = [];
    
    if(isInArray(player.CustomStatsArray, stat))
        player.CustomStatsArray = ArrayRemove(player.CustomStatsArray, stat);
    else
        player.CustomStatsArray[player.CustomStatsArray.size] = stat;
}

SetCustomStats(player)
{
    if(!isDefined(player.CustomStatsArray) || !player.CustomStatsArray.size)
        return self iPrintlnBold("^1ERROR: ^7No Stats Have Selected");
    
    player endon("disconnect");
    
    for(a = 0; a < player.CustomStatsArray.size; a++)
    {
        if(isInArray(level.MenuBGB, player.CustomStatsArray[a]))
            player SetDStat("ItemStats", level.bgb[player.CustomStatsArray[a]].item_index, "stats", "used", "StatValue", player.CustomStatsValue);
        else if(IsMapStat(player.CustomStatsArray[a], false))
            player SetDStat("PlayerStatsByMap", IsMapStat(player.CustomStatsArray[a], true), "stats", RemoveMapFromStat(player.CustomStatsArray[a]), "StatValue", player.CustomStatsValue);
        else
            player SetDStat("PlayerStatsList", player.CustomStatsArray[a], "StatValue", player.CustomStatsValue);
    }
    
    wait 0.1;
    UploadStats(player);
}

IsMapStat(stat, returnMap)
{
    mapNames = Array("zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb");

    for(a = 0; a < mapNames.size; a++)
        if(IsSubStr(stat, mapNames[a]))
            return returnMap ? mapNames[a] : true;
    
    return returnMap ? undefined : false;
}

RemoveMapFromStat(stat)
{
    if(!IsMapStat(stat, false))
        return;
    
    mapStats = Array("score", "total_games_played", "total_rounds_survived", "highest_round_reached", "time_played_total", "total_downs");

    for(a = 0; a < mapStats.size; a++)
        if(IsSubStr(stat, mapStats[a]) || mapStats[a] == stat)
            return mapStats[a];
}

IsAllBGBStatsEnabled()
{
    if(isDefined(level.MenuBGB) && level.MenuBGB.size)
        for(a = 0; a < level.MenuBGB.size; a++)
            if(!isInArray(self.CustomStatsArray, level.MenuBGB[a]))
                return false;
    
    return true;
}

AllBGBStats(player)
{
    if(isDefined(level.MenuBGB) && level.MenuBGB.size)
    {
        if(!player IsAllBGBStatsEnabled())
        {
            for(a = 0; a < level.MenuBGB.size; a++)
                if(!isInArray(player.CustomStatsArray, level.MenuBGB[a]))
                    self AddToCustomStats(level.MenuBGB[a], player);
        }
        else
        {
            for(a = 0; a < level.MenuBGB.size; a++)
                if(isInArray(player.CustomStatsArray, level.MenuBGB[a]))
                    self AddToCustomStats(level.MenuBGB[a], player);
        }
    }
}

SetPlayerPrestige(prestige, player)
{
    player endon("disconnect");

    menu = self getCurrent();
    curs = self getCursor();

    player SetDStat("PlayerStatsList", "plevel", "StatValue", prestige);
    player SetRank(player rank::getRankForXp(player rank::getRankXP()), player GetDStat("PlayerStatsList", "plevel", "StatValue"));

    wait 0.1;
    RefreshMenu(menu, curs);
    UploadStats(player);
}

SetPlayerRank(rank, player)
{
    player endon("disconnect");

    stat = (rank > 35) ? "paragon_rankxp" : "rankxp";
    rtnColumn = (rank == 35 || rank == 1000) ? 7 : 2;
    value = (rank > 35) ? Int(TableLookup("gamedata/tables/zm/zm_paragonranktable.csv", 13, rank, rtnColumn)) : Int(TableLookup("gamedata/tables/zm/zm_ranktable.csv", 0, (rank - 1), rtnColumn));
    
    player AddRankXPValue("win", (value - player GetDStat("PlayerStatsList", stat, "StatValue")));
    
    wait 0.1;
    UploadStats(player);
}

PlayerBoolStat(stat, player)
{
    player endon("disconnect");

    player SetDStat("PlayerStatsList", stat, "StatValue", !Int(player GetDStat("PlayerStatsList", stat, "StatValue")));

    wait 0.1;
    UploadStats(player);
}

CompleteDailyChallenges(player)
{
    player endon("disconnect");
    
    for(a = 768; a < 809; a++)
        player AddPlayerStat(TableLookup("gamedata/stats/zm/statsmilestones4.csv", 0, a, 4), Int(TableLookup("gamedata/stats/zm/statsmilestones4.csv", 0, a, 2)));

    wait 0.1;
    UploadStats(player);
}

PlayerWeaponRanks(type, player)
{
    if(Is_True(player.PlayerWeaponRanks))
        return;
    player.PlayerWeaponRanks = true;

    player endon("disconnect");

    for(a = 512; a < 548; a++)
        foreach(weapon in StrTok(TableLookup("gamedata/stats/zm/statsmilestones3.csv", 0, a, 13), " "))
            player SetDStat("ItemStats", GetBaseWeaponItemIndex(GetWeapon(weapon)), "xp", (type == "Max") ? 665535 : 0);

    wait 0.1;
    UploadStats(player);
    player.PlayerWeaponRanks = undefined;
}