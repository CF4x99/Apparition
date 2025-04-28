ModeWeaponMonitor(weaponArray)
{
    if(Is_True(self.ModeWeaponMonitor))
        return;
    self.ModeWeaponMonitor = true;

    level endon("game_ended");

    while(1)
    {
        keepWeapon = Is_True(level.initSharpshooter) ? weaponArray[level.indexSharpshooter] : level.currentWeaponAllTheWeapons;

        foreach(weapon in self GetWeaponsList(1))
        {
            if(!isDefined(weapon) || weapon == level.weaponnone || weapon == keepWeapon)
                continue;
            
            wait 1; //This should fix the issue with the death machine powerup icon sticking
            self TakeWeapon(weapon);
        }

        wait 0.1;
    }
}