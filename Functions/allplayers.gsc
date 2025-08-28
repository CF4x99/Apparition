PopulateAllPlayerOptions(menu)
{
    switch(menu)
    {
        case "All Players":
            self addMenu("All Players");
                self addOpt("Verification", ::newMenu, "All Players Verification");
                self addOptSlider("Teleport", ::AllPlayersTeleport, "Self;Crosshairs;Sky");
                self addOpt("Profile Management", ::newMenu, "All Players Profile Management");
                self addOpt("Model Manipulation", ::newMenu, "All Players Model Manipulation");
                self addOpt("Malicious Options", ::newMenu, "All Players Malicious Options");
                self addOptBool(AllClientsGodModeCheck(), "God Mode", ::AllClientsGodMode);
                self addOpt("Send Message", ::Keyboard, ::MessageAllPLayers);
                self addOpt("Kick", ::AllPlayersFunction, ::KickPlayer);
                self addOpt("Down", ::AllPlayersFunction, ::PlayerDeath, "Down");
                self addOpt("Revive", ::AllPlayersFunction, ::PlayerRevive);
                self addOpt("Respawn", ::AllPlayersFunction, ::ServerRespawnPlayer);
            break;
        
        case "All Players Verification":
            self addMenu("Verification");

                for(a = 1; a < (level.MenuStatus.size - 2); a++)
                    self addOpt(level.MenuStatus[a], ::SetVerificationAllPlayers, a, true);
            break;
        
        case "All Players Profile Management":
            self addMenu("Profile Management");
                self addOptBool(AllClientsLiquidsCheck(), "Liquid Divinium", ::AllClientsLiquids);
                self addOpt("Max Weapon Ranks", ::AllPlayersFunction, ::PlayerWeaponRanks, "Max");
                self addOpt("Unlock All Challenges", ::AllPlayersFunction, ::AllChallenges, "Unlock");
                self addOpt("Unlock All Achievements", ::AllPlayersFunction, ::UnlockAchievements);
                self addOpt("Complete Daily Challenges", ::AllPlayersFunction, ::CompleteDailyChallenges);
                self addOpt("Clan Tag Options", ::newMenu, "Clan Tag Options All Players");
            break;
        
        case "Clan Tag Options All Players":
            colors = Array("Black", "Red", "Green", "Yellow", "Blue", "Cyan", "Pink");

            self addMenu("Clan Tag Options");
                self addOpt("Reset", ::AllPlayersFunction, ::SetClanTag, "");
                self addOpt("Invisible Name", ::AllPlayersFunction, ::SetClanTag, "^Hä");
                self addOpt("@CF4", ::AllPlayersFunction, ::SetClanTag, "@CF4");

                for(a = 0; a < colors.size; a++)
                    self addOpt(colors[a], ::AllPlayersFunction, ::SetClanTag, colors[a]);
            break;
        
        case "All Players Model Manipulation":
            self addMenu("Model Manipulation");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    self addOpt("Reset", ::AllPlayersFunction, ::ResetPlayerModel);
                    self addOpt("");

                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::AllPlayersFunction, ::SetPlayerModel, level.MenuModels[a]);
                }
            break;
        
        case "All Players Malicious Options":
            self addMenu("Malicious Options");
                self addOpt("Launch", ::AllPlayersFunction, ::LaunchPlayer);
                self addOpt("Mortar Strike", ::AllPlayersFunction, ::MortarStrikePlayer);
                self addOpt("Fake Derank", ::AllPlayersFunction, ::FakeDerank);
                self addOpt("Fake Damage", ::AllPlayersFunction, ::FakeDamagePlayer);
                self addOpt("Crash Game", ::AllPlayersFunction, ::CrashPlayer);
            break;
    }
}

AllPlayersFunction(fnc, param, param2)
{
    if(!isDefined(fnc))
        return;
    
    foreach(player in level.players)
    {
        if(!player IsHost() && !player isDeveloper())
        {
            if(isDefined(param2))
                self thread [[ fnc ]](param, param2, player);
            else if(!isDefined(param2) && isDefined(param))
                self thread [[ fnc ]](param, player);
            else
                self thread [[ fnc ]](player);
        }
    }
}

AllPlayersTeleport(origin)
{
    level notify("EndAllPlayersTeleport");
    level endon("EndAllPlayersTeleport");

    switch(origin)
    {
        case "Sky":
            level.AllPlayersTeleporting = true;

            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(player.origin + (0, 0, 35000));
            break;
        
        case "Crosshairs":
            level.AllPlayersTeleporting = true;

            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(self TraceBullet());
            break;
        
        case "Self":
            level.AllPlayersTeleporting = true;

            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(self.origin);
            break;
        
        default:
            break;
    }

    wait 2;

    if(Is_True(level.AllPlayersTeleporting))
        level.AllPlayersTeleporting = BoolVar(level.AllPlayersTeleporting);
}

AllClientsGodModeCheck()
{
    foreach(player in level.players)
        if(!Is_True(player.godmode))
            return false;
    
    return true;
}

AllClientsGodMode()
{
    if(!AllClientsGodModeCheck())
    {
        foreach(player in level.players)
            if(!Is_True(player.godmode))
                thread Godmode(player);
    }
    else
    {
        foreach(player in level.players)
            if(Is_True(player.godmode))
                thread Godmode(player);
    }
}

AllClientsLiquidsCheck()
{
    if(level.players.size < 2) //This won't include the host, so if it's a solo game, it will always return false
        return false;
    
    foreach(player in level.players)
    {
        if(player IsHost())
            continue;
        
        if(!Is_True(player.LiquidsLoop))
            return false;
    }

    return true;
}

AllClientsLiquids()
{
    if(level.players.size < 2) //This won't include the host, so if it's a solo game, it will return and do nothing
        return;
    
    if(!AllClientsLiquidsCheck())
    {
        foreach(player in level.players)
        {
            if(player IsHost() || Is_True(player.LiquidsLoop))
                continue;
            
            thread LiquidsLoop(player);
        }
    }
    else
    {
        foreach(player in level.players)
        {
            if(player IsHost() || !Is_True(player.LiquidsLoop))
                continue;
            
            thread LiquidsLoop(player);
        }
    }
}

MessageAllPLayers(msg)
{
    foreach(player in level.players)
    {
        if(player == self)
            continue;
        
        player iPrintlnBold("^2" + CleanName(self getName()) + ": ^7" + msg);
    }
}