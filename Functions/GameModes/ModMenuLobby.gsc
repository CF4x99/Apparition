InitModMenuLobby(access)
{
    if(Is_True(level.GameModeSelected))
        return;
    level.GameModeSelected = true;

    if(!Is_True(level.AutoRevive))
        level thread AutoRevive();
    
    if(!Is_True(level.AutoRespawn))
        level thread AutoRespawn();

    MenuPerks = [];
    perks = GetArrayKeys(level._custom_perks);

    for(a = 0; a < perks.size; a++)
        array::add(MenuPerks, perks[a], 0);

    foreach(player in level.players)
    {
        player.playerGodmode = true;

        if(Is_True(player.PlayerDemiGod))
            player.PlayerDemiGod = undefined;
        
        thread UnlimitedAmmo("Continuous", player);

        if(!IsDefined(player.perks_active) || player.perks_active.size != MenuPerks.size)
            thread PlayerAllPerks(player);
        
        if(!Is_True(player._retain_perks))
            thread PlayerRetainPerks(player);
        
        if(!Is_True(player.ReducedSpread))
            ReducedSpread(player);
        
        ModifyScore(4194303, player);
        CustomCrosshairs("+", player);

        player SetPerk("specialty_unlimitedsprint");
        player SetPerk("specialty_sprintfire");

        if(player isInMenu(true))
            player thread closeMenu1();
        
        player.currentMenu = undefined;
        player.menuCursor = undefined;
        player.menu_parent = undefined;
        player.menu_parentQM = undefined;
    }

    SetVerificationAllPlayers(access);
    level thread ModMenuLobbyMessage();

    wait 1;
    level.SuperJump = true;
    SetJumpHeight(1023);
    SetDvar("bg_gravity", 200);
    SetDvar("g_speed", "500");

    if(!Is_True(level.Newsbar))
        level thread Newsbar();
    
    if(!Is_True(level.Doheart))
    {
        level.DoheartStyle = "Moving";
        level.DoheartSavedText = "discord.gg/apparitionbo3";
        level thread Doheart();
    }

    foreach(player in level.players)
    {
        if(!Is_Alive(player))
            continue;
        
        player SetOrigin(player.origin + (0, 0, 5));
        player SetVelocity(player GetVelocity() + (0, 0, RandomIntRange(750, 1000)));
    }
}

ModMenuLobbyMessage()
{
    messages = Array("Welcome To " + GetMenuName() + " Developed By CF4_99", "Lobby Hosted By: " + CleanName(bot::get_host_player() getName()));
    ModMenuLobbyMessage = [];

    for(a = 0; a < messages.size; a++)
    {
        ModMenuLobbyMessage[a] = createServerText("objective", 2.1, 1, "", "CENTER", "CENTER", 0, -100 + (a * 23), 1, level.RGBFadeColor);
        ModMenuLobbyMessage[a] thread SetTextFX(messages[a], 10);
        ModMenuLobbyMessage[a] thread HudRGBFade();
        wait 1;
    }
}