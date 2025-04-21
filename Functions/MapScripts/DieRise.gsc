PopulateDieRiseScripts(menu)
{
    switch(menu)
    {
        case "Die Rise Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOpt("Elevator Keys", ::newMenu, "Die Rise Elevator Keys");
                self addOpt("Bank Cash", ::newMenu, "Die Rise Bank Cash");
                self addOpt("Player Ranks", ::newMenu, "Die Rise Player Ranks");
            break;
        
        case "Die Rise Elevator Keys":
            self addMenu(menu);
                
                foreach(player in level.players)
                    self addOptBool(player.var_7e6e237, CleanName(player getName()), ::CollectElevatorKey, player);
            break;
        
        case "Die Rise Bank Cash":
            self addMenu(menu);

                foreach(player in level.players)
                    self addOptSlider(CleanName(player getName()), ::SetPlayerBank, "Max;Reset", player);
            break;
        
        case "Die Rise Player Ranks":
            if(!isDefined(self.DieRiseRankPlayer))
                self.DieRiseRankPlayer = level.players[0];

            playerArray = [];

            foreach(player in level.players)
                playerArray[playerArray.size] = CleanName(player getName()) + " [" + player GetEntityNumber() + "]";
            
            self addMenu(menu);
                self addOptSlider("Player", ::SetDieRiseRankPlayer, playerArray);
                self addOpt("");
                self addOptIncSlider("Rank", ::SetDieRisePlayerRank, 1, 1, 5, 1, self.DieRiseRankPlayer);
                //self addOptIncSlider("Tallies", ::DieRiseTallyMarks, 0, 0, 5, 1, self.DieRiseRankPlayer);
                //The tally mark system hasn't been fully implemented into Die Rise yet.
                //I made a script that will work for it when it gets implemented(script has been removed until the system is implemented)
            break;
    }
}

CollectElevatorKey(player)
{
    if(!Is_True(player.var_7e6e237) && isDefined(player.var_6f657589) && isDefined(player.var_6f657589.trigger))
        player.var_6f657589.trigger notify("trigger_activated", player);
}

SetPlayerBank(amount, player)
{
    cash = (amount == "Max") ? 250 : 0;
    player SetClientDieRiseStat("bank_account_value", cash);
    player.account_value = cash;
}

SetClientDieRiseStat(stat_name, stat_value)
{
    if(!isDefined(self.var_37f38876) || !isDefined(self.var_37f38876[stat_name]))
        return;

    self.var_37f38876[stat_name].value = stat_value;
    self.pers[stat_name] = stat_value;
    self.stats_this_frame[stat_name] = 1;
    self ForceSaveStatsDieRise();
}

GetClientDieRiseStat(stat_name)
{
    if(!IsDefined(self.var_37f38876) || !IsDefined(self.var_37f38876[stat_name]))
        return 0;

    return self.var_37f38876[stat_name].value;
}

ForceSaveStatsDieRise()
{
    self.var_977970a0 = 1;
    self notify(#"hash_412e4eb1");
    self function_56809df9();
    function_4e89efbc(self, "UploadData", "bruh");
    self.var_977970a0 = 0;
}

function_56809df9()
{
    self endon("disconnect");

    foreach(var_2f24aac7 in self.var_3d64c45d)
    {
        data = var_2f24aac7 + "=";

        foreach(stat in self.var_37f38876)
            if(!IsInt(stat) && stat.set == var_2f24aac7 && (isDefined(stat.var_f82847be) && stat.var_f82847be))
                data = (((data + stat.name) + ".") + stat.value) + ",";

        data += "|";
        function_4e89efbc(self, "UpdateDataSet", data);
        util::wait_network_frame();
        wait 0.05;
    }
}

function_4e89efbc(player, type, msg)
{
    if(isPlayer(player))
        level util::setClientSysState("dbSendClientMsg", type + "-**" + msg, player);
}

SetDieRiseRankPlayer(playerName)
{
    foreach(player in level.players)
    {
        if(CleanName(player getName()) + " [" + player GetEntityNumber() + "]" == playerName) //I included the players entity number for the case two players have the same name
            self.DieRiseRankPlayer = player;
    }

    self RefreshMenu(self getCurrent(), self getCursor());
}

SetDieRisePlayerRank(rank, player)
{
    time_played = player GetClientDieRiseStat("total_time_played");
	rounds = player GetClientDieRiseStat("weighted_rounds");
	downs = player GetClientDieRiseStat("weighted_downs");

    if(rank > 1)
    {
        if(!downs)
        {
            player SetClientDieRiseStat("weighted_downs", 1);
            downs = player GetClientDieRiseStat("weighted_downs");
        }
        
        if(!rounds)
        {
            player SetClientDieRiseStat("weighted_rounds", 1);
            rounds = player GetClientDieRiseStat("weighted_rounds");
        }
    }

    newRatio = false;
    ratio = (rounds / downs);

    switch(rank)
    {
        case 1:
            player SetClientDieRiseStat("total_time_played", 0); //the ratio doesn't matter for rank 1
            break;
        
        case 2:
            if(time_played < 3600 || time_played >= 18000)
                player SetClientDieRiseStat("total_time_played", 3600);
            
            newRatio = (ratio < 0.005);
            break;
        
        case 3:
            if(time_played < 18000 || time_played >= 54000)
                player SetClientDieRiseStat("total_time_played", 18000);
            
            newRatio = (ratio < 0.013);
            break;
        
        case 4:
            if(time_played < 54000 || time_played >= 108000)
                player SetClientDieRiseStat("total_time_played", 54000);
            
            newRatio = (ratio < 0.054);
            break;
        
        case 5:
            if(time_played < 108000)
                player SetClientDieRiseStat("total_time_played", 108000);
            
            newRatio = (ratio < 0.13);
            break;
    }

    if(newRatio)
        player SetClientDieRiseStat("weighted_rounds", player GetClientDieRiseStat("weighted_downs")); //this will make the new ratio 1(which will allow the player to meet the standard for any rank)

    level notify("force_player_rank_update");
}