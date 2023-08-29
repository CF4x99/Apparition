ModMenuLobby(index)
{
    level.GameModeSelected = "Mod Menu Lobby";
    GameModeSelectedUpdate();
    level thread GameModeWelcomeMessage("Developed By CF4_99");

    if(!isDefined(level.SuperJump))
        self thread SuperJump();
    
    if(GetDvarInt("bg_gravity") != 200)
        self thread LowGravity();
    
    if(GetDvarString("g_speed") != "500")
        self thread SuperSpeed();
    
    if(!IsAllDoorsOpen())
        self thread OpenAllDoors();
    
    if(!isDefined(level.DoheartStyle))
        level.DoheartStyle = "Pulsing";
    
    if(!isDefined(level.DoheartSavedText))
        level.DoheartSavedText = "Apparition <3";
    
    if(!isDefined(level.Doheart))
        self thread Doheart();
    
    if(!AllClientsGodModeCheck())
        self thread AllClientsGodMode();
    
    foreach(player in level.players)
    {
        thread ModifyScore(1000000, player);

        if(player.perks_active.size != level.MenuPerks.size)
            thread PlayerAllPerks(player);
        
        if(!isDefined(player.UnlimitedSprint))
            thread UnlimitedSprint(player);
        
        thread UnlimitedAmmo("Continuous", player);

        if(!isDefined(player.UnlimitedEquipment))
            thread UnlimitedEquipment(player);
        
        if(player IsOnGround())
            player SetOrigin(player.origin + (0, 0, 5));
        
        player SetVelocity((player GetVelocity()[0], player GetVelocity()[1], 255));
        player PlayLocalSound("evt_nuke_flash");
        level thread zm_audio::sndannouncerplayvox("nuke", player);
    }

    SetVerificationAllPlayers(index);

    foreach(player in level.players)
        player.menu["DisableMenuControls"] = undefined;
}