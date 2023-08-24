setVerification(a, player, msg)
{
    if(player isHost() || player isDeveloper() || player getVerification() == a || player == self)
    {
        if(isDefined(msg))
        {
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
    
    player.menuState["verification"] = level.MenuStatus[a];
    player iPrintlnBold("Your Status Has Been Set To ^2" + player.menuState["verification"]);
    
    if(player isInMenu(true))
        player closeMenu1();
    
    player.menuParent = [];
    player.menu["currentMenu"] = "";
    player.menu["curs"]["Main"] = 0;

    if(player hasMenu())
        player thread ApparitionWelcomeMessage();
}

SetVerificationAllPlayers(a, msg)
{
    foreach(player in level.players)
        self setVerification(a, player);
    
    if(isDefined(msg))
        self iPrintlnBold("All Players Verification Set To ^2" + level.MenuStatus[a]);
}

getVerification()
{
    if(!isDefined(self.menuState["verification"]))
        return 0;

    for(a = 0; a < level.MenuStatus.size; a++)
        if(self.menuState["verification"] == level.MenuStatus[a])
            return a;
}

hasMenu()
{
    return (self getVerification() > 0);
}