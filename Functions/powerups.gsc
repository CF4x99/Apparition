PopulatePowerupMenu(menu)
{
    switch(menu)
    {
        case "Power-Up Menu":
            if(!isDefined(self.PowerUpSpawnLocation))
                self.PowerUpSpawnLocation = "Crosshairs";
            
            powerups = GetArrayKeys(level.zombie_include_powerups);
            
            self addMenu("Power-Up Menu");
                
                if(isDefined(powerups) && powerups.size)
                {
                    self addOptSlider("Spawn Location", ::PowerUpSpawnLocation, "Crosshairs;Self");
                    self addOpt("Reign Drops", zm_bgb_reign_drops::activation);

                    for(a = 0; a < powerups.size; a++)
                        if(powerups[a] != "free_perk")
                            self addOpt(CleanString(powerups[a]), ::SpawnPowerUp, powerups[a]);
                        else
                            self addOpt("Free Perk", ::SpawnPowerUp, powerups[a]);
                }
            break;
    }
}
PowerUpSpawnLocation(location)
{
    self.PowerUpSpawnLocation = location;
}

SpawnPowerUp(powerup, origin)
{
    if(!isDefined(origin))
    {
        if(self.PowerUpSpawnLocation == "Self")
            origin = self.origin;
        else
        {
            trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
            
            origin = trace["position"];
            surface = trace["surfacetype"];

            if(surface == "none" || surface == "default")
                return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
        }
    }
    
    drop = level zm_powerups::specific_powerup_drop(powerup, origin);

    if(isDefined(level.powerup_drop_count) && level.powerup_drop_count)
        level.powerup_drop_count--;
}