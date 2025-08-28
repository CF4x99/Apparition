//Sharpshooter game mode developed by CF4_99
initSharpshooter(type)
{
    if(Is_True(level.initSharpshooter))
        return;
    level.initSharpshooter = true;

    level endon("game_ended");
    
    thread SetRound(15);
    level.zombie_vars["zombie_between_round_time"] = 0.1;
    level thread GameOverHandle();

    weaponArray = [];
    usedWeaponArray = !IsVerkoMap() ? (type == "Base Weapons") ? GetArrayKeys(level.zombie_weapons) : (type == "Upgraded Weapons") ? GetArrayKeys(level.zombie_weapons_upgraded) : ArrayCombine(GetArrayKeys(level.zombie_weapons), GetArrayKeys(level.zombie_weapons_upgraded), 0, 1) : (type == "Base Weapons") ? level.var_21b77150 : (type == "Upgraded Weapons") ? level.var_2b893b73 : ArrayCombine(level.var_21b77150, level.var_2b893b73, 0, 1);

    foreach(weapon in usedWeaponArray)
    {
        wpn = !IsVerkoMap() ? weapon : GetWeapon(weapon);

        if(wpn.isgrenadeweapon || wpn.ismeleeweapon || type == "Base Weapons" && IsSubStr(wpn.name, "upgraded") || wpn.name == "none")
            continue;
        
        weaponArray[weaponArray.size] = wpn;
    }

    weaponArray = array::randomize(weaponArray);

    MenuPerks = [];
    perks = GetArrayKeys(level._custom_perks);

    for(a = 0; a < perks.size; a++)
        array::add(MenuPerks, perks[a], 0);

    foreach(player in level.players)
    {
        if(player isDown())
            player thread PlayerRevive(player);
        
        if(player.sessionstate == "spectator")
            player thread ServerRespawnPlayer(player);
        
        if(player isInMenu(true))
            player thread closeMenu1();
        
        thread UnlimitedAmmo("Reload", player);

        if(!isDefined(player.perks_active) || player.perks_active.size != MenuPerks.size)
            thread PlayerAllPerks(player);
        
        if(!Is_True(player._retain_perks))
            thread PlayerRetainPerks(player);
        
        //remove everyones verification
        player.verification = level.MenuStatus[1];
        
        if(player isInMenu(true))
            player thread closeMenu1();
        
        player notify("endMenuMonitor");

        if(Is_True(player.menuMonitor))
            player.menuMonitor = BoolVar(player.menuMonitor);
        
        player thread ModeWeaponMonitor(weaponArray);
    }

    wait 0.1;
    level.indexSharpshooter = 0;

    foreach(msg in Array("Game Mode: Sharpshooter\nDeveloped By: CF4_99", "You Will Get A New Weapon Every 30 Seconds\nSurvive As Long As You Can"))
        thread typeWriter(msg);

    while(level.indexSharpshooter < (weaponArray.size - 1))
    {
        foreach(player in level.players)
        {
            TakePlayerWeapons(player);
            
            if(!isDefined(player.weaponIndexUI))
                player.weaponIndexUI = player LUI_createText("Weapon: " + (level.indexSharpshooter + 1) + "/" + weaponArray.size, 2, 0, 25, 255, (1, 1, 1));
            
            player.timerSharpshooter = player OpenLUIMenu("HudElementTimer", true);

            player SetLUIMenuData(player.timerSharpshooter, "x", 600);
            player SetLUIMenuData(player.timerSharpshooter, "y", 25);
            player SetLUIMenuData(player.timerSharpshooter, "height", 28);
            player SetLUIMenuData(player.timerSharpshooter, "time", (GetTime() + 30000));

            newWeapon = player zm_weapons::weapon_give(weaponArray[level.indexSharpshooter], false, false, true);
            player GiveStartAmmo(newWeapon);
            player SwitchToWeapon(newWeapon);
        }

        wait 30;
        level.indexSharpshooter++;

        foreach(player in level.players)
        {
            if(isDefined(player.timerSharpshooter))
                player CloseLUIMenu(player.timerSharpshooter);
            
            if(isDefined(player.weaponIndexUI))
                player SetLUIMenuData(player.weaponIndexUI, "text", "Weapon: " + (level.indexSharpshooter + 1) + "/" + weaponArray.size);
        }
    }

    wait 1;
    foreach(player in level.players)
        if(Is_Alive(player))
            PlayerDeath("Kill", player);
}

GameOverHandle()
{
    level waittill("game_ended");

    foreach(player in level.players)
    {
        if(isDefined(player.timerSharpshooter))
            player CloseLUIMenu(player.timerSharpshooter);
        
        if(isDefined(player.weaponIndexUI))
            player CloseLUIMenu(player.weaponIndexUI);
    }
}