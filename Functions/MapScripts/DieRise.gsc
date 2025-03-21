PopulateDieRiseScripts(menu)
{
    switch(menu)
    {
        case "Die Rise Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOpt("Elevator Keys", ::newMenu, "Elevator Keys");
                self addOpt("Bank Cash", ::newMenu, "Bank Cash");
            break;
        
        case "Elevator Keys":
            self addMenu(menu);
                
                foreach(player in level.players)
                    self addOptBool(player.var_7e6e237, CleanName(player getName()), ::CollectElevatorKey, player);
            break;
        
        case "Bank Cash":
            self addMenu(menu);

                foreach(player in level.players)
                    self addOptSlider(CleanName(player getName()), ::SetPlayerBank, "Max;Reset", player);
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

        data = data + "|";
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