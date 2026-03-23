PopulateAllPlayerOptions(menu)
{
    switch(menu)
    {
        case "All Players":
            self addMenu("All Players Menu");
                self addOpt("Verification", ::newMenu, "All Players Verification");
                self addOptSlider("Teleport", ::AllPlayersTeleport, Array("Self", "Crosshairs", "Sky"));
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

                for(a = 1; a < (GetAccessLevels().size - 2); a++)
                    self addOpt(GetAccessLevels()[a], ::SetVerificationAllPlayers, a, true);
            break;
        
        case "All Players Profile Management":
            self addMenu("Profile Management");
                self addOptBool(AllClientsLiquidsCheck(), "Liquid Divinium", ::AllClientsLiquids);
                self addOpt("Max Weapon Ranks", ::AllPlayersFunction, ::PlayerWeaponRanks, "Max");
                self addOpt("Complete All Challenges", ::AllPlayersFunction, ::AllChallenges, "Unlock");
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
                
                if(IsDefined(level.menu_models) && level.menu_models.size)
                {
                    self addOpt("Reset", ::AllPlayersFunction, ::ResetPlayerModel);
                    self addOpt("");

                    for(a = 0; a < level.menu_models.size; a++)
                        self addOpt(CleanString(level.menu_models[a]), ::AllPlayersFunction, ::SetPlayerModel, level.menu_models[a]);
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
    if(!IsDefined(fnc))
        return;
    
    foreach(player in level.players)
    {
        if(player IsHost() || player isDeveloper())
            continue;
        
        if(IsDefined(param2))
            self thread [[ fnc ]](param, param2, player);
        else if(!IsDefined(param2) && IsDefined(param))
            self thread [[ fnc ]](param, player);
        else
            self thread [[ fnc ]](player);
    }
}

AllPlayersTeleport(origin)
{
    level notify("EndAllPlayersTeleport");
    level endon("EndAllPlayersTeleport");

    switch(origin)
    {
        case "Sky":
            level.AllPlayersTeleporting = self;

            foreach(player in level.players)
            {
                if(!player IsHost() && !player isDeveloper() && player != self)
                    player SetOrigin(player.origin + (0, 0, 35000));
            }
            break;
        
        case "Crosshairs":
            level.AllPlayersTeleporting = self;

            foreach(player in level.players)
            {
                if(!player IsHost() && !player isDeveloper() && player != self)
                    player SetOrigin(self TraceBullet());
            }
            break;
        
        case "Self":
            level.AllPlayersTeleporting = self;

            foreach(player in level.players)
            {
                if(!player IsHost() && !player isDeveloper() && player != self)
                    player SetOrigin(self.origin);
            }
            break;
        
        default:
            break;
    }

    wait 2;
    level.AllPlayersTeleporting = undefined;
}

AllClientsGodModeCheck()
{
    foreach(player in level.players)
    {
        if(!Is_True(player.playerGodmode))
            return false;
    }
    
    return true;
}

AllClientsGodMode()
{
    if(!AllClientsGodModeCheck())
    {
        foreach(player in level.players)
        {
            if(!Is_True(player.playerGodmode))
                thread Godmode(player);
        }
    }
    else
    {
        foreach(player in level.players)
        {
            if(Is_True(player.playerGodmode))
                thread Godmode(player);
        }
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