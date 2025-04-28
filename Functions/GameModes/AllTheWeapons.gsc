//All The Weapons game mode developed by CF4_99
initAllTheWeapons(type)
{
    if(Is_True(level.initAllTheWeapons))
        return;
    level.initAllTheWeapons = true;

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

    foreach(player in level.players)
    {
        if(player isDown())
            player thread PlayerRevive(player);
        
        if(player.sessionstate == "spectator")
            player thread ServerRespawnPlayer(player);
        
        if(player isInMenu(true))
            player thread closeMenu1();
        
        thread UnlimitedAmmo("Reload", player);

        if(!isDefined(player.perks_active) || player.perks_active.size != level.MenuPerks.size)
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

        if(Is_True(player.MenuInstructionsDisplay))
            player.MenuInstructionsDisplay = BoolVar(player.MenuInstructionsDisplay);
        
        player thread ModeWeaponMonitor(weaponArray);
    }

    wait 0.1;

    currentWeaponIndex = -1;
    level.indexAllTheWeapons = 0;
    level.killsAllTheWeapons = 0;
    level.killGoalAllTheWeapons = 15;
    level.currentWeaponAllTheWeapons = weaponArray[level.indexAllTheWeapons];

    foreach(msg in Array("Game Mode: All The Weapons\nDeveloped By: CF4_99", "You Will Get A New Weapon Every " + level.killGoalAllTheWeapons + " Kills\nEvery Kill Has To Be With The Given Weapon"))
        thread typeWriter(msg);

    while(level.indexAllTheWeapons < (weaponArray.size - 1))
    {
        if(!isDefined(player.weaponKillsCounter))
            player.weaponKillsCounter = LUI_createText("Kills: " + level.killsAllTheWeapons + "/" + level.killGoalAllTheWeapons, 2, 0, 55, 255, (1, 1, 1));
        else
        {
            if(player GetLUIMenuData(player.weaponKillsCounter, "text") != "Kills: " + level.killsAllTheWeapons + "/" + level.killGoalAllTheWeapons)
                player SetLUIMenuData(player.weaponKillsCounter, "text", "Kills: " + level.killsAllTheWeapons + "/" + level.killGoalAllTheWeapons);
        }
        
        if(currentWeaponIndex != level.indexAllTheWeapons)
        {
            currentWeaponIndex = level.indexAllTheWeapons;
            level.currentWeaponAllTheWeapons = weaponArray[level.indexAllTheWeapons];

            foreach(player in level.players)
            {
                TakePlayerWeapons(player);
                
                if(!isDefined(player.weaponIndexUI))
                    player.weaponIndexUI = LUI_createText("Weapon: " + (level.indexAllTheWeapons + 1) + "/" + weaponArray.size, 2, 0, 25, 255, (1, 1, 1));
                else
                    player SetLUIMenuData(player.weaponIndexUI, "text", "Weapon: " + (level.indexAllTheWeapons + 1) + "/" + weaponArray.size);

                newWeapon = player zm_weapons::weapon_give(level.currentWeaponAllTheWeapons, false, false, true);
                player GiveStartAmmo(newWeapon);
                player SwitchToWeapon(newWeapon);
            }
        }

        wait 0.1;
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
        if(isDefined(player.weaponKillsCounter))
            player CloseLUIMenu(player.weaponKillsCounter);
        
        if(isDefined(player.weaponIndexUI))
            player CloseLUIMenu(player.weaponIndexUI);
    }
}