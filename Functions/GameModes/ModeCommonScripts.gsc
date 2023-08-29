GameModeSelectedUpdate()
{
    foreach(player in level.players)
    {
        if(!player isDown())
            thread PlayerRevive(player);
        
        if(player.sessionstate == "spectator")
            thread ServerRespawnPlayer(player);
        
        if(!player hasMenu())
            continue;
        
        player.menu["DisableMenuControls"] = true;
        
        if(player isInMenu(true))
            player closeMenu1();
        
        if(player getCurrent() == "Game Modes" || isInArray(player.menuParent, "Game Modes"))
        {
            player.menuParent = [];
            player.menu["currentMenu"] = "Main";
            player.menuParent = [];
        }
    }
}

GameModeWelcomeMessage(text)
{
    level.GameModeWelcome = [];

    level.GameModeWelcome[0] = level createServerText("default", 1.4, 1, "^2Game Mode Selected: ^7" + level.GameModeSelected, "CENTER", "CENTER", 0, -500, 1, (1, 1, 1));
    level.GameModeWelcome[1] = level createServerText("default", 1.4, 1, text, "CENTER", "CENTER", 0, 500, 1, (1, 1, 1));

    for(a = 0; a < 2; a++)
    {
        level.GameModeWelcome[a] hudMoveY(-10 + (a * 20), 1);
        wait (1 + (a * 4));
    }

    for(a = 0; a < 2; a++)
        level.GameModeWelcome[a] thread hudMoveX(-700 + (a * 1400), 1);
    
    wait 1;

    for(a = 0; a < 2; a++)
        level.GameModeWelcome[a] destroy();
}