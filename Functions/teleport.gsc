DisableTeleportEffect(player)
{
    player.DisableTeleportEffect = isDefined(player.DisableTeleportEffect) ? undefined : true;
}

TeleportPlayer(origin, player, angles, name)
{
    if(!isDefined(origin))
        return;

    if(IsPlayer(origin))
        newOrigin = origin.origin;
    
    if(origin == "Crosshairs")
        newOrigin = self TraceBullet();
    
    if(origin == "Sky")
        newOrigin = player.origin + (0, 0, 35000);
    
    if(!isDefined(newOrigin))
        newOrigin = origin;
    
    if(isDefined(name) && ReturnMapName(level.script) == "Origins" && IsSubStr(name, "Robot Head") && !isDefined(player.teleport_initial_origin))
        player.teleport_initial_origin = player.origin;
    
    player SetOrigin(newOrigin);

    if(isDefined(angles))
        player SetPlayerAngles(angles);

    player PlayTeleportEffect();
}

OfficialSpawnPoint(point, player)
{
    player SetOrigin(level.MenuSpawnPoints[point].origin);
    player SetPlayerAngles(level.MenuSpawnPoints[point].angles);

    player PlayTeleportEffect();
}

EntityTeleport(entity, player, eEntity)
{
    if(entity == "Mystery Box")
    {
        ent = level.chests[level.chest_index];
        entAngleDir = (AnglesToRight(ent.angles) * -1);
    }
    
    perks = GetEntArray("zombie_vending", "targetname");
                
    if(isDefined(perks) && perks.size)
    {
        foreach(perk in perks)
        {
            if(entity == perk.script_noteworthy)
            {
                ent = perk.machine;
                entAngleDir = AnglesToRight(ent.angles);

                break;
            }
        }
    }

    if(isDefined(eEntity) && eEntity == "BGB Machine")
    {
        ent = level.bgb_machines[entity];
        entAngleDir = AnglesToRight(ent.angles);
    }

    if(!isDefined(ent) || !isDefined(entAngleDir))
        return;
    
    if(!isDefined(distance))
        distance = 70; //Optional to pre-define the distance for specific entities. Defaults to this value.
           
    player SetOrigin(ent.origin + (entAngleDir * distance));
    player SetPlayerAngles(VectorToAngles((ent.origin + (0, 0, 55)) - player GetEye()));

    player PlayTeleportEffect();
}

TeleportGun(player)
{
    player.TeleportGun = isDefined(player.TeleportGun) ? undefined : true;

    if(isDefined(player.TeleportGun))
    {
        player endon("disconnect");
        player endon("EndTeleportGun");

        while(isDefined(player.TeleportGun))
        {
            player waittill("weapon_fired");
            
            player SetOrigin(player TraceBullet());
            player PlayTeleportEffect();
        }
    }
    else
        player notify("EndTeleportGun");
}

SaveCurrentLocation(player)
{
    player.SavedOrigin = player.origin;
    player.SavedAngles = player.angles;
}

LoadSavedLocation(player)
{
    if(!isDefined(player.SavedOrigin))
    {
        if(player != self)
            self iPrintlnBold("^1ERROR: ^7Player Doesn't Have A Location Saved");
        else
            self iPrintlnBold("^1ERROR: ^7You Have To Save A Location Before Using This Option");
        
        return;
    }
    
    player SetOrigin(player.SavedOrigin);
    player SetPlayerAngles(player.SavedAngles);

    player PlayTeleportEffect();
}

PlayTeleportEffect()
{
    if(!isDefined(self.DisableTeleportEffect))
    {
        PlayFX(level._effect["teleport_splash"], self.origin);
        PlayFX(level._effect["teleport_aoe_kill"], self GetTagOrigin("j_spineupper"));
    }
}