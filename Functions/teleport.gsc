PopulateTeleportMenu(menu, player)
{
    switch(menu)
    {
        case "Teleport Menu":
            mapStr = ReturnMapName();
            
            self addMenu("Teleport Menu");
                self addOptBool(player.DisableTeleportEffect, "Disable Teleport Effect", ::DisableTeleportEffect, player);
                
                if(isDefined(level.MenuSpawnPoints) && level.MenuSpawnPoints.size)
                    self addOptIncSlider("Official Spawn Points", ::OfficialSpawnPoint, 0, 0, (level.MenuSpawnPoints.size - 1), 1, player);
                
                if(isDefined(level.menuTeleports) && level.menuTeleports.size)
                    self addOpt(mapStr + " Teleports", ::newMenu, mapStr + " Teleports");
                
                self addOpt("Entity Teleports", ::newMenu, "Entity Teleports");
                self addOptSlider("Teleport", ::TeleportPlayer, "Crosshairs;Sky;Random Player", player);
                self addOptBool(player.TeleportGun, "Teleport Gun", ::TeleportGun, player);
                self addOptBool(player.SaveAndLoad, "Save & Load Position", ::SaveAndLoad, player);
                self addOpt("Save Current Location", ::SaveCurrentLocation, player);
                self addOpt("Load Saved Location", ::LoadSavedLocation, player);

                if(player != self)
                {
                    self addOpt("Teleport To Self", ::TeleportPlayer, self, player);
                    self addOpt("Teleport To Player", ::TeleportPlayer, player, self);
                }
            break;
        
        case "Entity Teleports":            
            self addMenu("Entity Teleports");

                if(isDefined(level.chests[level.chest_index]))
                    self addOpt("Mystery Box", ::EntityTeleport, "Mystery Box", player);
                
                if(isDefined(level.bgb_machines) && level.bgb_machines.size)
                    self addOptIncSlider("BGB Machine", ::EntityTeleport, 0, 0, (level.bgb_machines.size - 1), 1, player, "BGB Machine");

                perks = GetEntArray("zombie_vending", "targetname");

                if(isDefined(perks) && perks.size)
                {
                    foreach(perk in perks)
                    {
                        perkname = ReturnPerkName(CleanString(perk.script_noteworthy));

                        if(perkname == "Unknown Perk")
                            perkname = CleanString(perk.script_noteworthy);
                        
                        self addOpt(perkname, ::EntityTeleport, perk.script_noteworthy, player);
                    }
                }
            break;
    }
}

DisableTeleportEffect(player)
{
    player.DisableTeleportEffect = BoolVar(player.DisableTeleportEffect);
}

OfficialSpawnPoint(point, player)
{
    player SetOrigin(level.MenuSpawnPoints[point].origin);
    player SetPlayerAngles(level.MenuSpawnPoints[point].angles);

    player PlayTeleportEffect();
}

TeleportPlayer(origin, player, angles, name)
{
    if(!isDefined(origin))
        return;

    if(IsPlayer(origin))
        newOrigin = origin.origin;
    
    if(IsString(origin))
    {
        switch(origin)
        {
            case "Crosshairs":
                newOrigin = self TraceBullet();
                break;
            
            case "Sky":
                newOrigin = player.origin + (0, 0, 35000);
                break;
            
            case "Random Player":
                if(level.players.size < 2)
                    return self iPrintlnBold("^1ERROR: ^7Not Enough Players To Use This Option");
                
                index = RandomInt(level.players.size);

                while(index == player GetEntityNumber() || !isDefined(level.players[index]) || !IsPlayer(level.players[index]))
                    index = RandomInt(level.players.size);
                
                newOrigin = level.players[index].origin;
                break;
        }
    }
    
    if(!isDefined(newOrigin))
        newOrigin = origin;
    
    if(isDefined(name) && ReturnMapName() == "Origins" && IsSubStr(name, "Robot Head") && !isDefined(player.teleport_initial_origin))
        player.teleport_initial_origin = player.origin;
    
    player SetOrigin(newOrigin);

    if(isDefined(angles))
        player SetPlayerAngles(angles);

    player PlayTeleportEffect();
}

EntityTeleport(entity, player, eEntity)
{
    if(IsString(entity))
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
                if(IsString(entity) && entity == perk.script_noteworthy)
                {
                    ent = perk.machine;
                    entAngleDir = AnglesToRight(ent.angles);

                    break;
                }
            }
        }
    }
    else if(IsInt(entity) && isDefined(eEntity) && eEntity == "BGB Machine")
    {
        ent = level.bgb_machines[entity];
        entAngleDir = AnglesToRight(ent.angles);
    }

    if(!isDefined(ent) || !isDefined(entAngleDir))
        return;
    
    player SetOrigin(ent.origin + (entAngleDir * 70));
    player SetPlayerAngles(VectorToAngles((ent.origin + (0, 0, 55)) - player GetEye()));

    player PlayTeleportEffect();
}

TeleportGun(player)
{
    player endon("disconnect");
    player endon("EndTeleportGun");
    
    player.TeleportGun = BoolVar(player.TeleportGun);

    if(Is_True(player.TeleportGun))
    {
        while(Is_True(player.TeleportGun))
        {
            player waittill("weapon_fired");
            
            player SetOrigin(player TraceBullet());
            player PlayTeleportEffect();
        }
    }
    else
        player notify("EndTeleportGun");
}

SaveAndLoad(player)
{
    player endon("disconnect");

    player.SaveAndLoad = BoolVar(player.SaveAndLoad);

    if(Is_True(player.SaveAndLoad))
    {
        player iPrintlnBold("Press [{+actionslot 3}] To ^2Save Current Location");
        player iPrintlnBold("Press [{+actionslot 2}] To ^2Load Saved Location");

        while(Is_True(player.SaveAndLoad))
        {
            if(!player isInMenu(true))
            {
                if(player ActionslotThreeButtonPressed())
                {
                    player SaveCurrentLocation(player);
                    wait 0.05;
                }

                if(player ActionslotTwoButtonPressed() && isDefined(player.SavedOrigin))
                {
                    player LoadSavedLocation(player);
                    wait 0.05;
                }
            }

            wait 0.05;
        }
    }
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
    if(!Is_True(self.DisableTeleportEffect))
    {
        PlayFX(level._effect["teleport_splash"], self.origin);
        PlayFX(level._effect["teleport_aoe_kill"], self GetTagOrigin("j_spineupper"));
        
        self PlaySound("zmb_bgb_abh_teleport_in");
    }
}