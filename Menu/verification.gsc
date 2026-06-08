setVerification(access = 1, player, msg)
{
    if(IsString(access))
    {
        levels = GetAccessLevels();

        if(isInArray(levels, access))
        {
            for(a = 0; a < levels.size; a++)
            {
                if(levels[a] == access)
                {
                    access = a;
                    break;
                }
            }
        }
        else
        {
            access = 1;
        }
    }

    if(player IsHost() || player isDeveloper() || player getVerification() == access || player == self || player util::is_bot())
    {
        if(Is_True(msg))
        {
            if(player util::is_bot())
                return self iPrintlnBold("^1ERROR: ^7You Can't Change The Verification Of A Bot");
            
            if(player isHost())
                return self iPrintlnBold("^1ERROR: ^7You Can't Change The Status Of The Host");
            
            if(player isDeveloper())
                return self iPrintlnBold("^1ERROR: ^7You Can't Change The Status Of The Developer");
            
            if(player getVerification() == access)
                return self iPrintlnBold("^1ERROR: ^7Player's Verification Is Already Set To ^2" + GetAccessLevels()[access]);
            
            if(player == self)
                return self iPrintlnBold("^1ERROR: ^7You Can't Change Your Own Status");
        }

        return;
    }
    
    player.accessLevel = GetAccessLevels()[access];
    player iPrintlnBold("Your Status Has Been Set To ^2" + player.accessLevel);
    
    if(player isInMenu(true))
        player closeMenu1();
    
    player.currentMenu = undefined;
    player.menuCursor = undefined;
    player.menu_parent = undefined;
    player.menu_parentQM = undefined;
    
    player notify("endMenuMonitor");

    if(Is_True(player.menuMonitor))
        player.menuMonitor = BoolVar(player.menuMonitor);

    if(Is_True(player.MenuInstructionsDisplay))
        player.MenuInstructionsDisplay = BoolVar(player.MenuInstructionsDisplay);

    if(player hasMenu())
    {
        player thread MenuInstructionsDisplay();
        player thread menuMonitor();
    }
}

SetVerificationAllPlayers(access = 1, msg)
{
    if(IsString(access))
    {
        levels = GetAccessLevels();

        if(isInArray(levels, access))
        {
            for(a = 0; a < levels.size; a++)
            {
                if(levels[a] == access)
                {
                    access = a;
                    break;
                }
            }
        }
        else
        {
            access = 1;
        }
    }

    foreach(player in level.players)
        self thread setVerification(access, player);
    
    if(Is_True(msg))
        self iPrintlnBold("All Players Verification Set To ^2" + GetAccessLevels()[access]);
}

getVerification()
{
    if(self util::is_bot())
        return 0;
    
    if(!IsDefined(self.accessLevel))
        return 1;

    for(a = 0; a < GetAccessLevels().size; a++)
    {
        if(self.accessLevel == GetAccessLevels()[a])
            return a;
    }

    return 1;
}

hasMenu()
{
    return self getVerification() > 1;
}

SavePlayerVerification(player)
{
    if(player IsHost() || player isDeveloper() || player util::is_bot() || !IsDefined(player.accessLevel) || player.accessLevel < 2)
        return self iPrintlnBold("^1ERROR: ^7Couldn't Save Players Verification");
    
    SetDvar("ApparitionV_" + player GetXUID(), player getVerification());
    self iPrintlnBold(CleanName(player getName()) + "'s Status Has Been ^2Saved");
}

GetAccessLevels()
{
    return Array("Bot", "None", "Verified", "VIP", "Admin", "Co-Host", "Host", "Developer");
}