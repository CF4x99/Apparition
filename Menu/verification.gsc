setVerification(a, player, msg)
{
    if(player isHost() || player isDeveloper() || player getVerification() == a || player == self || player util::is_bot())
    {
        if(Is_True(msg))
        {
            if(player util::is_bot())
                return self iPrintlnBold("^1ERROR: ^7You Can't Change The Verification Of A Bot");
            
            if(player isHost())
                return self iPrintlnBold("^1ERROR: ^7You Can't Change The Status Of The Host");
            
            if(player isDeveloper())
                return self iPrintlnBold("^1ERROR: ^7You Can't Change The Status Of The Developer");
            
            if(player getVerification() == a)
                return self iPrintlnBold("^1ERROR: ^7Player's Verification Is Already Set To ^2" + level.MenuStatus[a]);
            
            if(player == self)
                return self iPrintlnBold("^1ERROR: ^7You Can't Change Your Own Status");
        }

        return;
    }
    
    player.verification = level.MenuStatus[a];
    player iPrintlnBold("Your Status Has Been Set To ^2" + player.verification);
    
    if(player isInMenu(true))
        player closeMenu1();
    
    player.currentMenu = "";
    player.menuCurs["Main"] = 0;
    player.menuParent = [];
    
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

SetVerificationAllPlayers(a, msg)
{
    foreach(player in level.players)
        self thread setVerification(a, player);
    
    if(isDefined(msg) && msg)
        self iPrintlnBold("All Players Verification Set To ^2" + level.MenuStatus[a]);
}

getVerification()
{
    if(!isDefined(self.verification))
        return 1;

    for(a = 0; a < level.MenuStatus.size; a++)
        if(self.verification == level.MenuStatus[a])
            return a;
}

hasMenu()
{
    return self getVerification() > 1;
}

SavePlayerVerification(player)
{
    if(player IsHost() || player isDeveloper() || player util::is_bot())
        return self iPrintlnBold("^1ERROR: ^7Couldn't Save Players Verification");
    
    SetDvar("ApparitionV_" + player GetXUID(), player getVerification());
    self iPrintlnBold(CleanName(player getName()) + "'s Status Has Been ^2Saved");
}