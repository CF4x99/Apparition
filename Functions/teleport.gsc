PopulateTeleportMenu(menu, player)
{
    switch(menu)
    {
        case "Teleport Menu":

            MenuSpawnPoints = ArrayCombine(struct::get_array("player_respawn_point_arena", "targetname"), struct::get_array("player_respawn_point", "targetname"), 0, 1);
            mapStr = ReturnMapName();
            
            self addMenu("Teleport Menu");
                self addOptBool(player.DisableTeleportEffect, "Disable Teleport Effect", ::DisableTeleportEffect, player);
                
                if(isDefined(MenuSpawnPoints) && MenuSpawnPoints.size)
                    self addOptIncSlider("Official Spawn Points", ::OfficialSpawnPoint, 0, 0, (MenuSpawnPoints.size - 1), 1, MenuSpawnPoints, player);
                
                if(ReturnMapName() != "Unknown")
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

OfficialSpawnPoint(index, points, player)
{
    player SetOrigin(points[index].origin);
    player SetPlayerAngles(points[index].angles);

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

GenerateMapTeleports()
{
    map = ReturnMapName();

    if(map != "Unknown") //Feel free to add your own custom teleport locations
    {
        //Teleport Name, Followed By The Origin
        //[< teleport location name >, < (x, y, z) origin >]

        switch(map)
        {
            case "Shadows Of Evil":
                locations = Array("Spawn", (1077.87, -5364.46, 124.719), "Pack 'a' Punch", (2614.68, -2348.33, -351.875), "Prison", (3007, -6542, 296.125));
                break;
            
            case "The Giant":
                locations = Array("Spawn", (-56.6293, 286.99, 98.125), "Power", (529.258, -1835.94, 61.6158), "Pack 'a' Punch", (-53.7356, 499.323, 101.125), "Prison", (-93.9053, -3268.56, -104.875));
                break;
            
            case "Der Eisendrache":
                locations = Array("Spawn", (421.786, 559.05, -47.875), "Power", (-27.8228, 2784.15, 848.125), "Pyramid", (-1476.97, 2253.83, 200.2), "Boss Fight Room", (-3182.63, 6962.58, -252.375), "Time Travel Room", (-278.407, 5001.93, 152.125), "Prison", (917.821, 912.26, 144.125));
                break;
            
            case "Zetsubou No Shima":
                locations = Array("Spawn", (393.455, -3181.32, -501.117), "Power", (-1475.2, 3456.67, -426.877), "Pack 'a' Punch", (246.815, 3818.53, -503.875), "Prison", (2608, 1135, -175.875));
                break;
            
            case "Gorod Krovi":
                locations = Array("Spawn", (-144, -184, 0.125), "Power", (102, 4969, 144.125), "Pack 'a' Punch", (-2967, 21660, 0.125), "Prison", (-2152, 3644, 160.125));
                break;
            
            case "Revelations":
                locations = Array("Spawn", (-4812, 72, -451.2), "Pack 'a' Punch", (819, 145, -3301.9), "Origins", (-3006, 3470, 1066), "Nacht Der Untoten", (109, 448, -379.6), "Verruckt", (5027, -2366, 230), "Kino Der Toten", (-1393, -9218, -1663.5), "Shangri-La", (-2023, -4151, -1699.5), "Mob Of The Dead", (478, 3301, 1264.125), "Prison", (154, 474, -740.125));
                break;
            
            case "Nacht Der Untoten":
                locations = Array("Spawn", (53, 415, 5.25), "Prison", (-162, -396, 1.125));
                break;
            
            case "Verruckt":
                locations = Array("Spawn", (1097, 302, 64.125), "Power", (-357, -219, 226.125), "Prison", (1154, 791, 64.125));
                break;
            
            case "Shi No Numa":
                locations = Array("Spawn", (10267, 514, -528.875), "Out Of The Map", (12374, 4523, -664.875), "Under The Map", (11838, -1614, -1217.94), "Prison", (12500, -939, -644.875));
                break;
            
            case "Kino Der Toten":
                locations = Array("Spawn", (13.2366, -1262.8, 90.125), "Power", (-619.298, 1391.23, -15.875), "Pack 'a' Punch", (5.74551, -376.756, 320.125), "Air Force Room", (1154.75, 2650.46, -367.875), "Surgical Room", (1948.13, -2204.91, 136.125), "Samantha's Room", (-2636.31, 189.825, 52.125), "Samantha's Red Room", (-2620.55, -1106.91, 53.3851), "Prison", (-1590.36, -4760.5, -167.875));
                break;
            
            case "Ascension":
                locations = Array("Spawn", (-512, 3, -484.875), "Power", (-464, 1028, 220.125), "Pack 'a' Punch", (487, 389, -303.875), "Prison", (-228, 1306, -485.875));
                break;
            
            case "Shangri-La":
                locations = Array("Spawn", (-10, -740, 20.125), "Pack 'a' Punch", (-2, 381, 289.125), "Prison", (1052, 1275, -547.875));
                break;
            
            case "Moon":
                locations = Array("Earth Spawn", (22250, -38663, -679.875), "Moon Spawn", (-4, 32, -1.875), "Power", (42, 3100, -587.875), "Dome", (-162, 6893, 0.45), "Prison", (743, 966, -220.875));
                break;
            
            case "Origins":
                locations = Array("Spawn", (2698.43, 5290.48, -346.219), "Staff Chamber", (-2.4956, -2.693, -751.875), "The Crazy Place", (10334.5, -7891.93, -411.875), "Lightning Tunnel", (-3234, -372, -188), "Wind Tunnel", (3330, 1227, -343), "Fire Tunnel", (3064, 4395, -599), "Ice Tunnel", (1431, -1728, -121), "Robot Head: Odin", (-6759.17, -6541.72, 159.375), "Robot Head: Thor", (-6223.59, -6547.65, 159.375), "Robot Head: Freya", (-5699.83, -6540.03, 159.375), "Prison", (-3142.11, 1125.09, -63.875));
                break;
            
            case "Mob Of The Dead":
                locations = ["Spawn", (-2185.649, 5548.136, 2688.125), "Pack 'a' Punch(Bridge)", (-10931.269, 31045.974, 3800.125), "Roof", (115.627, 4876.537, 3052.125), "Prison", (-2744.295, 3911.298, 2792.125)];
                break;
            
            case "Die Rise":
                locations = ["Spawn", (-880.691, 362.408, 1808.125), "Power", (460.962, -1024.275, -287.875), "Bank Showers", (0.08, -394.350, -287.875), "Prison", (-200.960, -1127.386, 944.125)];
                break;
            
            case "Bus Depot":
                locations = ["Spawn", (1444.05, 4467.5, 0.125), "Power", (1272.86, 4339.175, -151.625), "Pack 'a' Punch", (3121.84, 1892.9, 21.812), "Prison", (-484.175, 260.947, 0.125)];
                break;
            
            case "Tunnel":
                locations = ["Spawn", (1490.38, -2368.4, 275.8), "Power", (3952.9, -1431.5, 72.125), "Pack 'a' Punch", (1444.7, -449.98, 103.19), "Prison", (2175, -2836.6, 320.125)];
                break;
            
            case "Diner":
                locations = ["Spawn", (7583.19, -12471.09, -0.625), "Power", (10258.39, -12906.60, 95.125), "Pack 'a' Punch", (5171.02, -13046.58, 0.64), "Prison", (5516.14, -19922.40, -115.875)];
                break;
        }

        return locations;
    }
}