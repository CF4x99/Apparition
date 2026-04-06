PopulateMapChallenges(menu)
{
    switch(menu)
    {
        case "Map Challenges":
            if(!IsDefined(self.mapChallengesPlayer))
                self.mapChallengesPlayer = level.players[0];

            playerArray = [];

            foreach(player in level.players)
                playerArray[playerArray.size] = CleanName(player getName()) + " [" + player GetEntityNumber() + "]";

            self addMenu("Challenges");
                self addOptSlider("Player", ::SetMapChallengesPlayer, playerArray);
                self addOpt("");

                if(IsDefined(self.mapChallengesPlayer._challenges))
                    mapChallenge = Array(self.mapChallengesPlayer._challenges.challenge_1, self.mapChallengesPlayer._challenges.challenge_2, self.mapChallengesPlayer._challenges.challenge_3);
                else if(IsDefined(self.mapChallengesPlayer.s_challenges))
                    mapChallenge = Array(self.mapChallengesPlayer.s_challenges.a_challenge_1, self.mapChallengesPlayer.s_challenges.a_challenge_2, self.mapChallengesPlayer.s_challenges.a_challenge_3);


                if(IsDefined(mapChallenge) && mapChallenge.size)
                {
                    for(a = 0; a < mapChallenge.size; a++)
                        self addOptBool(self.mapChallengesPlayer flag::get("flag_player_completed_challenge_" + mapChallenge[a].n_index), ReturnMapChallengeIString(mapChallenge[a].str_notify), ::MapCompleteChallenge, mapChallenge[a], self.mapChallengesPlayer);
                }
                else
                {
                    self addOpt("Map Challenges Not Supported");
                }
            break;
    }
}

SetMapChallengesPlayer(playerName)
{
    foreach(player in level.players)
    {
        if(CleanName(player getName()) + " [" + player GetEntityNumber() + "]" == playerName) //I included the players entity number for the case two players have the same name
            self.mapChallengesPlayer = player;
    }

    self RefreshMenu(self getCurrent(), self getCursor());
}

MapCompleteChallenge(challenge, player)
{
    if(!IsDefined(challenge) || player flag::get("flag_player_completed_challenge_" + challenge.n_index))
        return;

    player endon("disconnect");

    curs = self getCursor();
    menu = self getCurrent();

    for(a = 0; a < challenge.n_count; a++)
    {
        player notify(challenge.str_notify);
        wait 0.01;
    }

    player flag::wait_till("flag_player_completed_challenge_" + challenge.n_index);
    self RefreshMenu(menu, curs);
}

ReturnMapChallengeIString(challenge)
{
    challengeTok = StrTok(challenge, "_");
    return ToUpper(level.script) + "_CHALLENGE_" + challengeTok[2] + "_" + challengeTok[3];
}

ActivateZombieTrap(index)
{
    traps = level.menu_traps;

    if(!IsDefined(traps[index]))
        return;

    if(!level flag::get(traps[index].script_flag_wait))
        level flag::set(traps[index].script_flag_wait);

    wait 0.05;
    savedCost = traps[index].zombie_cost;
    traps[index].zombie_cost = 0; //This doesn't work on all maps. Too lazy to add support for the rest.

    if(IsDefined(traps[index]._trap_use_trigs))
    {
        for(a = 0; a < traps[index]._trap_use_trigs.size; a++)
        {
            if(IsDefined(traps[index]._trap_use_trigs[a]))
                traps[index]._trap_use_trigs[a] notify("trigger", self);
        }
    }
    else
    {
        traps[index] notify("trigger", self);
    }

    wait 0.1;
    traps[index].zombie_cost = savedCost;
}

ActivateAllZombieTraps()
{
    if(IsDefined(level.menu_traps) && level.menu_traps.size)
    {
        for(a = 0; a < level.menu_traps.size; a++)
            self thread ActivateZombieTrap(a);
    }
}

ActivatePower()
{
    if(level flag::get("power_on"))
        return self iPrintlnBold("^1ERROR: ^7Power Has Already Been Turned On");

    curs = self getCursor();
    menu = self getCurrent();

    foundSwitch = false;
    switches = Array("use_power_switch", "use_master_switch", "use_elec_switch", "power_trigger_left", "power_trigger_right", "use_power_switch_vk");

    for(a = 0; a < switches.size; a++)
    {
        rightSwitch = GetEnt(switches[a], "targetname");

        if(IsDefined(rightSwitch))
        {
            foundSwitch = true;
            rightSwitch notify("trigger", self);
        }
    }

    if(!foundSwitch)
        return;

    level flag::wait_till("power_on");

    if(ReturnMapName() == "Gorod Krovi")
    {
        self TriggerSophia();
        wait 1;
    }

    self RefreshMenu(menu, curs);
}

SamanthasHideAndSeekSong()
{
    if(level flag::get("snd_zhdegg_completed"))
        return self iPrintlnBold("^1ERROR: ^7Samantha's Hide & Seek Has Already Been Completed");

    if(ReturnMapName() == "Kino Der Toten" && !level flag::get("snd_zhdegg_activate"))
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
        {
            if(IsDefined(ballerinas[index].var_ac086ffb))
                ballerinas[index].var_ac086ffb notify("damage", 100, self, (0, 0, 0), (0, 0, 0), "MOD_BULLET", "tag_origin", "", "", level.start_weapon);
        }

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

SpawnSacrificedZombie(goalEnt)
{
    zombie = zombie_utility::spawn_zombie(level.zombie_spawners[0]);

    if(IsDefined(zombie))
    {
        zombie endon("death");

        wait 0.1;
        zombie zombie_utility::makezombiecrawler(true);
        target = goalEnt.origin;

        linker = Spawn("script_origin", zombie.origin);
        linker.origin = zombie.origin;
        linker.angles = zombie.angles;

        zombie LinkTo(linker);
        linker MoveTo(target, 0.01);

        linker waittill("movedone");

        zombie Unlink();
        linker Delete();

        zombie LinkTo(goalEnt);
        zombie.completed_emerging_into_playable_area = 1;
        zombie Hide();
    }

    return zombie;
}