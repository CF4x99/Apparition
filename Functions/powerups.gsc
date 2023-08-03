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