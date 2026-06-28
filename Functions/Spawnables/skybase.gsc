SpawnSkybase()
{
    if(Is_True(level.spawnable["Skybase_Spawned"]))
        return false;
    
    //These values control the size of the base
    x = 10;
    y = 5;

    //DON'T CHANGE THESE VALUES
    width = 51;
    height = 90;

    origin = GetSkybaseOriginForMap();
    model = GetSpawnableBaseModel("vending_doubletap");
    location = (!IsVec(origin) || !IsDefined(level.SkybaseLocation)) ? "Custom" : level.SkybaseLocation;

    if(location == "Custom")
    {
        self closeMenu1();

        cancel = false;
        distance = 650;
        cfIndex = Int(Pow(2, RandomInt(3)));
        trace = BulletTrace(self GetEye(), self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), distance), 0, self)["position"];

        goalPos = SpawnScriptModel(trace, "tag_origin");
        goalPos clientfield::set("powerup_fx", cfIndex);

        if(!IsDefined(goalPos))
            return false;

        self.DisableMenuControls = true;
        self SetMenuInstructions(Array("[{+attack}] - Increase Distance", "[{+speed_throw}] - Decrease Distance", "[{+activate}] - Confirm Location", "[{+melee}] - Cancel"));

        preview = [];

        for(a = 0; a < x; a++)
        {
            for(b = 0; b < y; b++)
            {
                preview[preview.size] = SpawnScriptModel(trace + ((a * width), (b * height), 0), "tag_origin", (0, 0, 0));

                if(IsDefined(preview[(preview.size - 1)]))
                {
                    preview[(preview.size - 1)] clientfield::set("powerup_fx", cfIndex);
                    preview[(preview.size - 1)] LinkTo(goalPos);
                }
                else
                {
                    return false;
                }

                wait 0.01;
            }
        }

        while(1)
        {
            if(!IsDefined(goalPos))
            {
                cancel = true;
                break;
            }
            
            trace = BulletTrace(self GetEye(), self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), distance), 0, self)["position"];
            goalPos.origin = trace;

            if(self AttackButtonPressed())
            {
                distance += 25;
            }
            else if(self AdsButtonPressed())
            {
                distance -= 25;
            }
            else if(self UseButtonPressed())
            {
                origin = trace;
                break;
            }
            else if(self MeleeButtonPressed())
            {
                cancel = true;
                break;
            }

            if(distance < 100)
                distance = 100;
            else if(distance > 2500)
                distance = 2500;

            wait 0.01;
        }

        if(IsDefined(goalPos))
            goalPos Delete();
        
        if(IsDefined(preview) && preview.size)
        {
            for(a = 0; a < preview.size; a++)
            {
                if(IsDefined(preview[a]))
                    preview[a] Delete();
            }
        }
        
        if(Is_True(self.DisableMenuControls))
            self.DisableMenuControls = BoolVar(self.DisableMenuControls);
        
        self SetMenuInstructions();

        if(Is_True(cancel))
            return false;
    }

    if(!IsDefined(origin) || !IsVec(origin) || origin == (0, 0, 0))
        return false;
    
    level.SkybaseOrigin = origin;
    level.skybaseLinker = SpawnScriptModel(origin, "tag_origin");

    if(!IsDefined(level.skybaseLinker))
        return false;

    floor = [];
    roof = [];
    walls = [];
    corners = [];

    for(a = 0; a < x; a++)
    {
        for(b = 0; b < y; b++)
        {
            floor[floor.size] = SpawnScriptModel(origin + ((a * width), (b * height), 0), model, (0, 0, 90), 0.01);

            if(!IsDefined(floor[(floor.size - 1)]))
                return false;
            
            if(IsDefined(level.skybaseLinker))
                floor[(floor.size - 1)] LinkTo(level.skybaseLinker);
        }
    }

    array::thread_all(floor, ::SpawnableArray, "Skybase");

    for(a = 0; a < x; a++)
    {
        for(b = 0; b < y; b++)
        {
            roof[roof.size] = SpawnScriptModel(origin + ((a * width), (b * height), (height + 35)), model, (180, 0, 90), 0.01);

            if(!IsDefined(roof[(roof.size - 1)]))
                return false;
            
            if(IsDefined(level.skybaseLinker))
                roof[(roof.size - 1)] LinkTo(level.skybaseLinker);
        }
    }

    array::thread_all(roof, ::SpawnableArray, "Skybase");

    for(a = 0; a < 2; a++)
    {
        for(b = 0; b < y; b++)
        {
            walls[walls.size] = SpawnScriptModel(origin + (-25 + ((width * x) * a) + (10 * a), (b * height), 19), model, (90 - (180 * a), 0, 90), 0.01);

            if(!IsDefined(walls[(walls.size - 1)]))
                return false;
            
            if(IsDefined(level.skybaseLinker))
                walls[(walls.size - 1)] LinkTo(level.skybaseLinker);
        }
    }

    for(a = 0; a < 2; a++)
    {
        for(b = 0; b < (x - 4); b++)
        {
            walls[walls.size] = SpawnScriptModel(origin + (5 + width + (b * height), (height * -1) + ((height * y) * a), 19), model, (-90 + (180 * a), 0, 0 - (180 * a)), 0.01);

            if(!IsDefined(walls[(walls.size - 1)]))
                return false;
            
            if(IsDefined(level.skybaseLinker))
                walls[(walls.size - 1)] LinkTo(level.skybaseLinker);
        }
    }

    array::thread_all(walls, ::SpawnableArray, "Skybase");

    for(a = 0; a < 2; a++)
    {
        for(b = 0; b < 2; b++)
        {
            corners[corners.size] = SpawnScriptModel(origin + (0 - (((25 * b) + (25 * a)) - ((50 * a) * b)), (height * -1) + (15 * b) + (((height * y) - 15) * a), 44), model, (0, 0 - ((b * 90) + (a * 90)), 0), 0.01);

            if(!IsDefined(corners[(corners.size - 1)]))
                return false;
            
            if(IsDefined(level.skybaseLinker))
                corners[(corners.size - 1)] LinkTo(level.skybaseLinker);
        }
    }

    for(a = 0; a < 2; a++)
    {
        for(b = 0; b < 2; b++)
        {
            corners[corners.size] = SpawnScriptModel(origin + ((width * (x - 1)) + (((36 * b) + (36 * a)) - ((72 * a) * b)), (height * -1) + (15 * b) + (((height * y) - 15) * a), 44), model, (0, 0 + ((b * 90) + (a * 90)), 0), 0.01);

            if(!IsDefined(corners[(corners.size - 1)]))
                return false;
            
            if(IsDefined(level.skybaseLinker))
                corners[(corners.size - 1)] LinkTo(level.skybaseLinker);
        }
    }

    array::thread_all(corners, ::SpawnableArray, "Skybase");

    //SpawnProp(origin = (0, 0, 0), model = "defaultactor", angles = (0, 0, 0), bounce = true, glow = true, triggerFunction, hintString)
    bottle = SpawnProp(origin + (10, (55 * (y + 1)), 55), GetSpawnablePerkBottle(), (0, 0, 0), true, true, ::SkybasePerkTrigger, "Press ^3[{+activate}]^7 For All Perks");

    if(!IsDefined(bottle))
        return false;

    level.skybaseProps = Array(bottle);
    array::thread_all(level.skybaseProps, ::SpawnableArray, "Skybase");
    

    return true;
}

SkybasePerkTrigger()
{
    MenuPerks = [];
    perks = GetArrayKeys(level._custom_perks);

    for(a = 0; a < perks.size; a++)
        array::add(MenuPerks, perks[a], 0);
    
    if(IsDefined(self.perks_active) && self.perks_active.size == MenuPerks.size)
        return;
    
    PlayerAllPerks(self);
}

SpawnSkybaseTeleporter()
{
    if(Is_True(level.spawnable["Skybase_Building"]) || Is_True(level.spawnable["Skybase_Dismantle"]) || Is_True(level.spawnable["Skybase_Deleted"]) || !Is_True(level.spawnable["Skybase_Spawned"]))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option Right Now");

    if(!IsDefined(level.SkybaseTeleporters) || !level.SkybaseTeleporters.size)
    {
        traceSurface = BulletTrace(self GetEye(), self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["surfacetype"];

        if(traceSurface == "none" || traceSurface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");

        crosshairs = self TraceBullet();
        level.SkybaseTeleporters = [];

        for(a = 0; a < 2; a++)
            level.SkybaseTeleporters[level.SkybaseTeleporters.size] = SpawnTeleporter("Spawn", a ? (level.SkybaseOrigin + (20, -45, 45)) : (crosshairs + (0, 0, 45)), !a, true);
    }
    else
    {
        foreach(teleporter in level.SkybaseTeleporters)
            teleporter Delete();

        level.SkybaseTeleporters = undefined;
    }
}

SkybaseLocation(location)
{
    level.SkybaseLocation = location;
}

GetSkybaseOriginForMap()
{
    map = ReturnMapName();

    switch(map)
    {
        case "Shadows Of Evil":
            return (2546, -5263, 450);

        case "The Giant":
            return (-230, -515, 522);
        
        case "Der Eisendrache":
            return (-754, 342, 877);

        case "Zetsubou No Shima":
            return (3407, 1277, -475);
        
        case "Gorod Krovi":
            return (-218, -803, 216);

        case "Revelations":
            return (271, -864, -272);

        case "Nacht Der Untoten":
            return (1182, 572, 296);

        case "Verruckt":
            return (16, -69, 308);

        case "Shi No Numa":
            return (10165, 974, -268);

        case "Kino Der Toten":
            return (-360, 328, 239);

        case "Ascension":
            return (-2461, 1682, 361);

        case "Shangri-La":
            return (-2401, -1066, -162);

        case "Moon":
            return (21835, -37689, -529);

        case "Origins":
            return (294.5, 1213, 557);
        
        default:
            return "invalid";
    }
}

MoveSkybase(amount = 0, axis = "X")
{
    if(Is_True(level.spawnable["Skybase_Building"]))
        return self iPrintlnBold("^1ERROR: ^7You Can't Move The Skybase While It's Being Built");
    
    if(!Is_True(level.spawnable["Skybase_Spawned"]))
        return self iPrintlnBold("^1ERROR: ^7The Skybase Hasn't Been Spawned Yet");
    
    if(Is_True(level.spawnable["Skybase_Dismantle"]) || Is_True(level.spawnable["Skybase_Deleted"]))
        return self iPrintlnBold("^1ERROR: ^7You Can't Move The Skybase Right Now");
    
    if(!IsDefined(level.skybaseLinker))
        return self iPrintlnBold("^1ERROR: ^7Failed To Move Skybase");
    
    switch(axis)
    {
        case "X":
            level.skybaseLinker.origin += (amount, 0, 0);

            if(IsDefined(level.SkybaseOrigin))
                level.SkybaseOrigin += (amount, 0, 0);

            for(a = 0; a < level.skybaseProps.size; a++)
            {
                if(IsDefined(level.skybaseProps[a]))
                {
                    level.skybaseProps[a].origin += (amount, 0, 0);

                    if(IsDefined(level.skybaseProps[a].original_origin) && IsVec(level.skybaseProps[a].original_origin))
                        level.skybaseProps[a].original_origin += (amount, 0, 0);
                }
            }
            break;
        
        case "Y":
            level.skybaseLinker.origin += (0, amount, 0);

            if(IsDefined(level.SkybaseOrigin))
                level.SkybaseOrigin += (0, amount, 0);

            for(a = 0; a < level.skybaseProps.size; a++)
            {
                if(IsDefined(level.skybaseProps[a]))
                {
                    level.skybaseProps[a].origin += (0, amount, 0);

                    if(IsDefined(level.skybaseProps[a].original_origin) && IsVec(level.skybaseProps[a].original_origin))
                        level.skybaseProps[a].original_origin += (0, amount, 0);
                }
            }
            break;
        
        case "Z":
            level.skybaseLinker.origin += (0, 0, amount);

            if(IsDefined(level.SkybaseOrigin))
                level.SkybaseOrigin += (0, 0, amount);

            for(a = 0; a < level.skybaseProps.size; a++)
            {
                if(IsDefined(level.skybaseProps[a]))
                {
                    level.skybaseProps[a].origin += (0, 0, amount);

                    if(IsDefined(level.skybaseProps[a].original_origin) && IsVec(level.skybaseProps[a].original_origin))
                        level.skybaseProps[a].original_origin += (0, 0, amount);
                }
            }
            break;
        
        default:
            break;
    }
}