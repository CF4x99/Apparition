SpawnSystem(action, type, func)
{
    checkModel = GetSpawnableBaseModel();

    if(!isDefined(checkModel))
        return self iPrintlnBold("^1ERROR: ^7Couldn't Find A Valid Base Model For Spawnables");
    
    if(!isDefined(level.spawnable))
        level.spawnable = [];
    
    if(isDefined(level.spawnable[type + "_Building"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Built");
    
    if(isDefined(level.spawnable[type + "_Dismantle"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Dismantled");
    
    if(isDefined(level.spawnable[type + "_Deleted"]))
        return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Is Being Deleted");
    
    if(!isDefined(level.spawnable[type + "_Spawned"]) && type != "Skybase")
    {
        traceSurface = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["surfacetype"];

        if(traceSurface == "none" || traceSurface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
    }

    if(action != "Spawn")
    {
        if(!isDefined(level.spawnable[type + "_Spawned"]))
            return self iPrintlnBold("^1ERROR: ^7" + CleanString(type) + " Hasn't Been Spawned Yet");
    }
    else
    {
        if(isDefined(level.spawnable["LargeSpawnable"]) && isLargeSpawnable(type))
            return self iPrintlnBold("^1ERROR: ^7You Must Delete The " + level.spawnable["LargeSpawnable"] + " First");
        
        if(isDefined(level.spawnable[type + "_Spawned"]))
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
            
            level.spawnable[type + "_Building"] = undefined;
            level.spawnable[type + "_Spawned"] = true;
            break;
        
        case "Delete":
            level notify(type + "_Stop");

            if(isLargeSpawnable(type))
                foreach(player in level.players)
                    if(isDefined(player.OnSpawnable))
                        player StopRidingSpawnable(type);
            
            level.spawnable[type + "_Deleted"] = true;
            
            for(a = 0; a < level.SpawnableArray[type].size; a++)
                if(isDefined(level.SpawnableArray[type][a]))
                    level.SpawnableArray[type][a] delete();
            
            level.SpawnableArray[type] = undefined;
            level.spawnable[type + "_Deleted"] = undefined;

            if(isLargeSpawnable(type))
                level.spawnable["LargeSpawnable"] = undefined;
            
            level.spawnable[type + "_Spawned"] = undefined;
            break;
        
        case "Dismantle":
            level notify(type + "_Stop");

            if(isLargeSpawnable(type))
                foreach(player in level.players)
                    if(isDefined(player.OnSpawnable))
                        player StopRidingSpawnable(type);
            
            level.spawnable[type + "_Dismantle"] = true;

            if(isDefined(level.SpawnableArray[type]) && level.SpawnableArray[type].size)
            { 
                for(a = 0; a < level.SpawnableArray[type].size; a++)
                {
                    if(!isDefined(level.SpawnableArray[type][a]))
                        continue;
                    
                    level.SpawnableArray[type][a] NotSolid();
                    level.SpawnableArray[type][a] Unlink();
                    level.SpawnableArray[type][a] Launch(VectorScale(AnglesToForward(level.SpawnableArray[type][a].angles), RandomIntRange(-255, 255)));
                    level.SpawnableArray[type][a] thread deleteAfter(5);
                }
            }

            wait 5;

            level.SpawnableArray[type] = undefined;

            level.spawnable[type + "_Dismantle"] = undefined;

            if(isLargeSpawnable(type))
                level.spawnable["LargeSpawnable"] = undefined;
            
            level.spawnable[type + "_Spawned"] = undefined;
            break;
        
        default:
            break;
    }

    level.SpawnableSystemBusy = undefined;
    RefreshMenu(menu, curs);
}

isLargeSpawnable(type)
{
    spawns = ["Skybase", "Merry Go Round", "Drop Tower"];

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

        if(isDefined(self.Rider) || isDefined(player.OnSpawnable) || player isPlayerLinked(self))
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

    self.OnSpawnable = undefined;
}

GetSpawnableBaseModel(favor)
{
    for(a = 0; a < level.MenuModels.size; a++)
        if(IsSubStr(level.MenuModels[a], "vending_doubletap") || IsSubStr(level.MenuModels[a], "vending_sleight") || IsSubStr(level.MenuModels[a], "vending_three_gun"))
        {
            model = level.MenuModels[a];

            if(model == favor || IsSubStr(model, favor))
                return model;
        }
    
    return model;
}