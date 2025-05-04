ModeWeaponMonitor(weaponArray)
{
    if(Is_True(self.ModeWeaponMonitor))
        return;
    self.ModeWeaponMonitor = true;

    level endon("game_ended");

    while(1)
    {
        self waittill("weapon_change", newWeapon);
        wait 0.1; //this buffer should help avoid the death machine powerup icon from sticking

        keepWeapon = Is_True(level.initSharpshooter) ? weaponArray[level.indexSharpshooter] : level.currentWeaponAllTheWeapons;

        if(newWeapon != keepWeapon)
        {
            self TakeWeapon(newWeapon);

            if(!self HasWeapon(keepWeapon))
            {
                keepWeapon = self zm_weapons::weapon_give(keepWeapon, false, false, true);
                self GiveStartAmmo(newWeapon);
            }
            
            self SwitchToWeapon(keepWeapon);
        }
    }
}