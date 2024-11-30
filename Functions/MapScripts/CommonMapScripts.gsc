PopulateMapChallenges(player)
{
    self addMenu("Challenges");

        if(isDefined(player._challenges))
        {
            self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_4687355c.n_index), ReturnMapChallengeIString(player._challenges.var_4687355c.str_notify), ::MapCompleteChallenge, player._challenges.var_4687355c, player);
            self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_b88ea497.n_index), ReturnMapChallengeIString(player._challenges.var_b88ea497.str_notify), ::MapCompleteChallenge, player._challenges.var_b88ea497, player);
            self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_928c2a2e.n_index), ReturnMapChallengeIString(player._challenges.var_928c2a2e.str_notify), ::MapCompleteChallenge, player._challenges.var_928c2a2e, player);
        }
}

ActivateZombieTrap(index)
{
    traps = level.MenuZombieTraps;

    if(!level flag::get(traps[index].script_flag_wait))
        level flag::set(traps[index].script_flag_wait);

    wait 0.05;

    savedCost = traps[index].zombie_cost;
    traps[index].zombie_cost = 0; //This doesn't work on all maps. Too lazy to add support for the rest.

    if(isDefined(traps[index]._trap_use_trigs))
        for(a = 0; a < traps[index]._trap_use_trigs.size; a++)
            traps[index]._trap_use_trigs[a] notify("trigger", self);
    else
        traps[index] notify("trigger", self);

    wait 0.1;
    traps[index].zombie_cost = savedCost;
}

ActivateAllZombieTraps()
{
    traps = GetEntArray("zombie_trap", "targetname");

    if(isDefined(level.MenuZombieTraps) && level.MenuZombieTraps.size)
        for(a = 0; a < level.MenuZombieTraps.size; a++)
            self thread ActivateZombieTrap(a);
}

ActivatePower()
{
    if(level flag::get("power_on"))
        return self iPrintlnBold("^1ERROR: ^7Power Has Already Been Turned On");

    curs = self getCursor();
    menu = self getCurrent();

    switches = Array("use_power_switch", "use_master_switch", "use_elec_switch", "power_trigger_left", "power_trigger_right");

    for(a = 0; a < switches.size; a++)
    {
        rightSwitch = GetEnt(switches[a], "targetname");

        if(isDefined(rightSwitch))
            rightSwitch notify("trigger", self);
    }

    level flag::wait_till("power_on");
    self RefreshMenu(menu, curs);
}

SamanthasHideAndSeekSong()
{
    if(level flag::get("snd_zhdegg_completed"))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Completed");

    if(ReturnMapName(level.script) == "Kino Der Toten" && !level flag::get("snd_zhdegg_activate"))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Can't Be Completed Until The Door Knocking Combination Has Been Completed");

    self endon("disconnect");

    curs = self getCursor();
    menu = self getCurrent();

    if(!level flag::get("snd_zhdegg_activate"))
    {
        TriggerUniTrigger(struct::get_array("zhdaudio_button", "targetname"), "trigger_activated");
        wait 3;
    }

    trigger = struct::get("s_ballerina_start", "targetname");
    trigger notify("trigger_activated");

    wait 0.5;
    ballerinas = struct::get_array("s_ballerina_timed", "targetname");

    for(a = 0; a < ballerinas.size; a++)
    {
        foreach(index, ballerina in ballerinas)
            if(isDefined(ballerinas[index].var_ac086ffb))
                ballerinas[index].var_ac086ffb notify("damage", 100, self, (0, 0, 0), (0, 0, 0), "MOD_BULLET", "tag_origin", "", "", level.start_weapon);

        wait 0.1;
    }

    wait 0.5;
    trigger = struct::get("s_ballerina_end", "targetname");
    trigger notify("trigger_activated");

    level flag::wait_till("snd_zhdegg_completed");

    if(Is_True(level.StartedSamanthaSong))
        level.StartedSamanthaSong = BoolVar(level.StartedSamanthaSong);
    
    self RefreshMenu(menu, curs);
}

MapCompleteChallenge(challenge, player)
{
    if(!isDefined(challenge) || player flag::get("flag_player_completed_challenge_" + challenge.n_index))
        return;

    player endon("disconnect");

    curs = self getCursor();
    menu = self getCurrent();

    for(a = 0; a < challenge.n_count; a++)
    {
        player notify(challenge.str_notify);
        wait 0.01;
    }

    while(!player flag::get("flag_player_completed_challenge_" + challenge.n_index))
        wait 0.1;

    self RefreshMenu(menu, curs);
}

ReturnMapChallengeIString(challenge)
{
    challengeTok = StrTok(challenge, "_");
    return ToUpper(level.script) + "_CHALLENGE_" + challengeTok[2] + "_" + challengeTok[3];
}