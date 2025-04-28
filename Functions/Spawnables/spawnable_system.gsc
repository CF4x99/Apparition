PopulateSpawnables(menu)
{
    switch(menu)
    {
        case "Spawnables":
            if(!isDefined(level.spawnable))
                level.spawnable = [];

            self addMenu("Spawnables");
                self addOptSlider("Skybase", ::SpawnSystem, "Spawn;Dismantle;Delete", "Skybase", ::SpawnSkybase);

                if(Is_True(level.spawnable["Skybase_Spawned"]))
                {
                    self addOptBool((isDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size), "Spawn Skybase Teleporter", ::SpawnSkybaseTeleporter);
                    self addOpt("");
                }

                self addOptSlider("Drop Tower", ::SpawnSystem, "Spawn;Dismantle;Delete", "Drop Tower", ::SpawnDropTower);
                self addOptSlider("Merry Go Round", ::SpawnSystem, "Spawn;Dismantle;Delete", "Merry Go Round", ::SpawnMerryGoRound);

                if(isDefined(level.spawnable["Merry Go Round_Spawned"]))
                    self addOptIncSlider("Merry Go Round Speed", ::SetMerryGoRoundSpeed, 1, 1, 10, 1);
            break;
    }
}

SpawnSystem(action, type, func)
{
    checkModel = GetSpawnableBaseModel();

    if(!isDefined(checkModel))
        return self iPrintlnBold("^1ERROR: ^7Couldn't Find A Valid Base Model For Spawnables");

    if(!isDefined(level.spawnable))
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

    if(isDefined(level.SpawnableSystemBusy))
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

            if(isDefined(func))
                self [[ func ]]();

            if(Is_True(level.spawnable[type + "_Building"]))
                level.spawnable[type + "_Building"] = BoolVar(level.spawnable[type + "_Building"]);
            
            level.spawnable[type + "_Spawned"] = true;
            break;

        case "Delete":
            DeleteSpawnable(type, action);
            break;

        case "Dismantle":
            if(isDefined(level.SpawnableArray[type]) && level.SpawnableArray[type].size)
            { 
                for(a = 0; a < level.SpawnableArray[type].size; a++)
                {
                    if(!isDefined(level.SpawnableArray[type][a]))
                        continue;

                    level.SpawnableArray[type][a] NotSolid();
                    level.SpawnableArray[type][a] Unlink();
                    level.SpawnableArray[type][a] Launch(VectorScale(AnglesToForward(level.SpawnableArray[type][a].angles), RandomIntRange(-255, 255)));
                }
            }

            if(type == "Skybase")
            {
                if(isDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size)
                {
                    for(a = 0; a < level.SkybaseTeleporters.size; a++)
                    {
                        if(!isDefined(level.SkybaseTeleporters[a]))
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
        foreach(player in level.players)
            if(Is_True(player.OnSpawnable))
                player StopRidingSpawnable(spawn);

    level.spawnable[spawn + "_" + type] = true;

    if(type == "Dismantle")
        wait 5;

    for(a = 0; a < level.SpawnableArray[spawn].size; a++)
        if(isDefined(level.SpawnableArray[spawn][a]))
            level.SpawnableArray[spawn][a] delete();

    if(spawn == "Skybase")
    {
        if(isDefined(level.SkybaseTeleporters) && level.SkybaseTeleporters.size)
        {
            for(a = 0; a < level.SkybaseTeleporters.size; a++)
            {
                if(!isDefined(level.SkybaseTeleporters[a]))
                    continue;

                level.SkybaseTeleporters[a] delete();
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
    if(!isDefined(spawn) || !isDefined(self))
        return;

    if(!isDefined(level.SpawnableArray))
        level.SpawnableArray = [];

    if(!isDefined(level.SpawnableArray[spawn]))
        level.SpawnableArray[spawn] = [];

    level.SpawnableArray[spawn][level.SpawnableArray[spawn].size] = self;
}

SeatSystem(type)
{
    if(!isDefined(type) || !isDefined(self))
        return;

    level endon(type + "_Stop");

    self MakeUsable();
    self SetCursorHint("HINT_NOICON");
    self SetHintString("Press [{+activate}] To Ride The " + type);

    while(isDefined(self))
    {
        self waittill("trigger", player);

        if(isDefined(self.Rider) && player == self.Rider)
        {
            player StopRidingSpawnable(type, self);
            wait 1;

            continue;
        }

        if(isDefined(self.Rider) || Is_True(player.OnSpawnable) || player isPlayerLinked(self))
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

    if(isDefined(seat))
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
    for(a = 0; a < level.MenuModels.size; a++)
        if(isDefined(level.MenuModels[a]) && IsSubStr(level.MenuModels[a], "vending_") && !IsSubStr(level.MenuModels[a], "upgrade") && !IsSubStr(level.MenuModels[a], "packapunch"))
            model = level.MenuModels[a];
    
    for(a = 0; a < level.MenuModels.size; a++)
    {
        if(IsSubStr(level.MenuModels[a], "vending_doubletap") || IsSubStr(level.MenuModels[a], "vending_sleight") || IsSubStr(level.MenuModels[a], "vending_three_gun"))
        {
            model = level.MenuModels[a];

            if(isDefined(favor) && isDefined(model) && (model == favor || IsSubStr(model, favor)))
                return model;
        }
    }

    if(!isDefined(model)) //If a model still isn't found after this, then spawnbales won't be available for the map
        for(a = 0; a < level.MenuModels.size; a++)
            if(isDefined(level.MenuModels[a]) && IsSubStr(level.MenuModels[a], "machine"))
                model = level.MenuModels[a];

    return model;
}