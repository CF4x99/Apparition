PopulateSpawnables(menu)
{
    switch(menu)
    {
        case "Spawnables":
            if(!IsDefined(level.spawnable))
                level.spawnable = [];

            self addMenu("Spawnables");
                self addOptSlider("Skybase", ::SpawnSystem, Array("Spawn", "Dismantle", "Delete"), "Skybase", ::SpawnSkybase);

                if(Is_True(level.spawnable["Skybase_Spawned"]))
                {
                    self addOptBool((IsDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size), "Spawn Skybase Teleporter", ::SpawnSkybaseTeleporter);
                    self addOpt("");
                }

                self addOptSlider("Drop Tower", ::SpawnSystem, Array("Spawn", "Dismantle", "Delete"), "Drop Tower", ::SpawnDropTower);
                self addOptSlider("Merry Go Round", ::SpawnSystem, Array("Spawn", "Dismantle", "Delete"), "Merry Go Round", ::SpawnMerryGoRound);

                if(IsDefined(level.spawnable["Merry Go Round_Spawned"]))
                    self addOptIncSlider("Merry Go Round Speed", ::SetMerryGoRoundSpeed, 1, 1, 10, 1);
            break;
    }
}

SpawnSystem(action, type, func)
{
    checkModel = GetSpawnableBaseModel();

    if(!IsDefined(checkModel))
        return self iPrintlnBold("^1ERROR: ^7Couldn't Find A Valid Base Model For Spawnables");

    if(!IsDefined(level.spawnable))
        level.spawnable = [];

    if(Is_True(level.spawnable[type + "_Building"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Built");

    if(Is_True(level.spawnable[type + "_Dismantle"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Dismantled");

    if(Is_True(level.spawnable[type + "_Deleted"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Deleted");

    if(!Is_True(level.spawnable[type + "_Spawned"]) && type != "Skybase")
    {
        traceSurface = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["surfacetype"];

        if(traceSurface == "none" || traceSurface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
    }

    if(action != "Spawn")
    {
        if(!Is_True(level.spawnable[type + "_Spawned"]))
            return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Hasn't Been Spawned Yet");
    }
    else
    {
        if(Is_True(level.spawnable["LargeSpawnable"]) && isLargeSpawnable(type))
            return self iPrintlnBold("^1ERROR: ^7You Must Delete The " + level.spawnable["LargeSpawnable"] + " First");

        if(Is_True(level.spawnable[type + "_Spawned"]))
            return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Has Already Been Spawned");
    }

    if(IsDefined(level.SpawnableSystemBusy))
        return self iPrintlnBold("^1ERROR: ^7The Spawnable System Is Currently Busy");

    level.SpawnableSystemBusy = type;

    menu = self getCurrent();
    curs = self getCursor();

    switch(action)
    {
        case "Spawn":
            if(isLargeSpawnable(type))
                level.spawnable["LargeSpawnable"] = type;

            level.spawnable[type + "_Building"] = true;

            if(IsDefined(func))
                self [[ func ]]();

            if(Is_True(level.spawnable[type + "_Building"]))
                level.spawnable[type + "_Building"] = BoolVar(level.spawnable[type + "_Building"]);
            
            level.spawnable[type + "_Spawned"] = true;
            break;

        case "Delete":
            DeleteSpawnable(type, action);
            break;

        case "Dismantle":
            if(IsDefined(level.SpawnableArray[type]) && level.SpawnableArray[type].size)
            { 
                for(a = 0; a < level.SpawnableArray[type].size; a++)
                {
                    if(!IsDefined(level.SpawnableArray[type][a]))
                        continue;

                    level.SpawnableArray[type][a] NotSolid();
                    level.SpawnableArray[type][a] Unlink();
                    level.SpawnableArray[type][a] Launch(VectorScale(AnglesToForward(level.SpawnableArray[type][a].angles), RandomIntRange(-255, 255)));
                }
            }

            if(type == "Skybase")
            {
                if(IsDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size)
                {
                    for(a = 0; a < level.SkybaseTeleporters.size; a++)
                    {
                        if(!IsDefined(level.SkybaseTeleporters[a]))
                            continue;

                        level.SkybaseTeleporters[a] Unlink();
                        level.SkybaseTeleporters[a] Launch(VectorScale(AnglesToForward(level.SpawnableArray[type][a].angles), RandomIntRange(-255, 255)));
                    }
                }
            }

            DeleteSpawnable(type, action);
            break;

        default:
            break;
    }

    level.SpawnableSystemBusy = undefined;
    RefreshMenu(menu, curs);
}

DeleteSpawnable(spawn, type)
{
    level notify(spawn + "_Stop");

    if(isLargeSpawnable(spawn))
    {
        foreach(player in level.players)
        {
            if(Is_True(player.OnSpawnable))
                player StopRidingSpawnable(spawn);
        }
    }

    level.spawnable[spawn + "_" + type] = true;

    if(type == "Dismantle")
        wait 5;

    for(a = 0; a < level.SpawnableArray[spawn].size; a++)
    {
        if(IsDefined(level.SpawnableArray[spawn][a]))
            level.SpawnableArray[spawn][a] Delete();
    }

    if(spawn == "Skybase")
    {
        if(IsDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size)
        {
            for(a = 0; a < level.SkybaseTeleporters.size; a++)
            {
                if(!IsDefined(level.SkybaseTeleporters[a]))
                    continue;

                level.SkybaseTeleporters[a] Delete();
            }
        }

        level.SkybaseTeleporters = undefined;
    }

    //after delete
    level.SpawnableArray[spawn] = undefined;

    if(Is_True(level.spawnable[spawn + "_" + type]))
        level.spawnable[spawn + "_" + type] = BoolVar(level.spawnable[spawn + "_" + type]);

    if(Is_True(level.spawnable[spawn + "_Spawned"]))
        level.spawnable[spawn + "_Spawned"] = BoolVar(level.spawnable[spawn + "_Spawned"]);

    if(isLargeSpawnable(spawn))
        level.spawnable["LargeSpawnable"] = undefined;
}

isLargeSpawnable(type)
{
    spawns = Array("Skybase", "Merry Go Round", "Drop Tower");
    return isInArray(spawns, type);
}

SpawnableArray(spawn)
{
    if(!IsDefined(spawn) || !IsDefined(self))
        return;

    if(!IsDefined(level.SpawnableArray))
        level.SpawnableArray = [];

    if(!IsDefined(level.SpawnableArray[spawn]))
        level.SpawnableArray[spawn] = [];

    level.SpawnableArray[spawn][level.SpawnableArray[spawn].size] = self;
}

SeatSystem(type)
{
    if(!IsDefined(type) || !IsDefined(self))
        return;

    level endon(type + "_Stop");

    self MakeUsable();
    self SetCursorHint("HINT_NOICON");
    self SetHintString("Press [{+activate}] To Ride The " + type);

    while(IsDefined(self))
    {
        self waittill("trigger", player);

        if(IsDefined(self.Rider) && player == self.Rider)
        {
            player StopRidingSpawnable(type, self);
            wait 1;

            continue;
        }

        if(IsDefined(self.Rider) || Is_True(player.OnSpawnable) || player isPlayerLinked(self))
            continue;

        player.SpawnableSavedOrigin = player.origin;
        player.SpawnableSavedAngles = player.angles;

        switch(type)
        {
            case "Merry Go Round":
                player PlayerLinkTo(self);
                break;

            case "Drop Tower":
                player PlayerLinkToAbsolute(self);
                break;

            default:
                player PlayerLinkTo(self);
                break;
        }

        player.OnSpawnable = true;
        self.Rider = player;

        self SetHintString("Press [{+activate}] To Exit The " + type);
        wait 1;
    }
}

StopRidingSpawnable(type, seat)
{
    self Unlink();
    self SetOrigin(self.SpawnableSavedOrigin);
    self SetPlayerAngles(self.SpawnableSavedAngles);

    if(IsDefined(seat))
    {
        seat.Rider = undefined;
        seat SetHintString("Press [{+activate}] To Ride The " + type);
    }

    if(Is_True(self.OnSpawnable))
        self.OnSpawnable = BoolVar(self.OnSpawnable);
}

GetSpawnableBaseModel(favor)
{
    //This will be a fallback for maps that don't have the favored models for spawnables
    for(a = 0; a < level.menu_models.size; a++)
    {
        if(IsDefined(level.menu_models[a]) && IsSubStr(level.menu_models[a], "vending_") && !IsSubStr(level.menu_models[a], "upgrade") && !IsSubStr(level.menu_models[a], "packapunch"))
            model = level.menu_models[a];
    }
    
    for(a = 0; a < level.menu_models.size; a++)
    {
        if(IsSubStr(level.menu_models[a], "vending_doubletap") || IsSubStr(level.menu_models[a], "vending_sleight") || IsSubStr(level.menu_models[a], "vending_three_gun"))
        {
            model = level.menu_models[a];

            if(IsDefined(favor) && IsDefined(model) && (model == favor || IsSubStr(model, favor)))
                return model;
        }
    }

    if(!IsDefined(model)) //If a model still isn't found after this, then spawnbales won't be available for the map
    {
        for(a = 0; a < level.menu_models.size; a++)
        {
            if(IsDefined(level.menu_models[a]) && IsSubStr(level.menu_models[a], "machine"))
                model = level.menu_models[a];
        }
    }

    return model;
}